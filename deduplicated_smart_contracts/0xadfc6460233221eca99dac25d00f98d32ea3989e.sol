// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import { AdapterBalance, AbsoluteTokenAmount } from "../shared/Structs.sol";
import { ERC20 } from "../shared/ERC20.sol";
import { Ownable } from "./Ownable.sol";
import { ProtocolAdapterManager } from "./ProtocolAdapterManager.sol";
import { ProtocolAdapter } from "../adapters/ProtocolAdapter.sol";


/**
 * @title Registry for protocol adapters.
 * @notice getBalances() function implements the main functionality.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract ProtocolAdapterRegistry is Ownable, ProtocolAdapterManager {

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @param account Address of the account.
     * @return AdapterBalance array by the given account.
     * @notice Zero values are filtered out!
     */
    function getBalances(
        address account
    )
        external
        view
        returns (AdapterBalance[] memory)
    {
        // Get balances for all the adapters
        AdapterBalance[] memory adapterBalances = getAdapterBalances(
            _protocolAdapterNames,
            account
        );

        // Declare temp variable and counters
        AbsoluteTokenAmount[] memory currentAbsoluteTokenAmounts;
        AbsoluteTokenAmount[] memory nonZeroAbsoluteTokenAmounts;
        uint256 nonZeroAdaptersCounter;
        uint256[] memory nonZeroTokensCounters;
        uint256 adapterBalancesLength;
        uint256 currentAbsoluteTokenAmountsLength;

        // Reset counters
        nonZeroTokensCounters = new uint256[](adapterBalances.length);
        nonZeroAdaptersCounter = 0;
        adapterBalancesLength = adapterBalances.length;

        // Iterate over all the adapters' balances
        for (uint256 i = 0; i < adapterBalancesLength; i++) {
            // Fill temp variable
            currentAbsoluteTokenAmounts = adapterBalances[i].absoluteTokenAmounts;

            // Reset counter
            nonZeroTokensCounters[i] = 0;
            currentAbsoluteTokenAmountsLength = currentAbsoluteTokenAmounts.length;

            // Increment if token balance is positive
            for (uint256 j = 0; j < currentAbsoluteTokenAmountsLength; j++) {
                if (currentAbsoluteTokenAmounts[j].amount > 0) {
                    nonZeroTokensCounters[i]++;
                }
            }

            // Increment if at least one positive token balance
            if (nonZeroTokensCounters[i] > 0) {
                nonZeroAdaptersCounter++;
            }
        }

        // Declare resulting variable
        AdapterBalance[] memory nonZeroAdapterBalances;

        // Reset resulting variable and counter
        nonZeroAdapterBalances = new AdapterBalance[](nonZeroAdaptersCounter);
        nonZeroAdaptersCounter = 0;

        // Iterate over all the adapters' balances
        for (uint256 i = 0; i < adapterBalancesLength; i++) {
            // Skip if no positive token balances
            if (nonZeroTokensCounters[i] == 0) {
                continue;
            }

            // Fill temp variable
            currentAbsoluteTokenAmounts = adapterBalances[i].absoluteTokenAmounts;

            // Reset temp variable and counter
            nonZeroAbsoluteTokenAmounts = new AbsoluteTokenAmount[](nonZeroTokensCounters[i]);
            nonZeroTokensCounters[i] = 0;
            currentAbsoluteTokenAmountsLength = currentAbsoluteTokenAmounts.length;

            for (uint256 j = 0; j < currentAbsoluteTokenAmountsLength; j++) {
                // Skip if balance is not positive
                if (currentAbsoluteTokenAmounts[j].amount == 0) {
                    continue;
                }

                // Else fill temp variable
                nonZeroAbsoluteTokenAmounts[nonZeroTokensCounters[i]] = currentAbsoluteTokenAmounts[j];

                // Increment counter
                nonZeroTokensCounters[i]++;
            }

            // Fill resulting variable
            nonZeroAdapterBalances[nonZeroAdaptersCounter] = AdapterBalance({
                protocolAdapterName: adapterBalances[i].protocolAdapterName,
                absoluteTokenAmounts: nonZeroAbsoluteTokenAmounts
            });

            // Increment counter
            nonZeroAdaptersCounter++;
        }

        return nonZeroAdapterBalances;
    }

    /**
     * @param protocolAdapterNames Array of the protocol adapters' names.
     * @param account Address of the account.
     * @return AdapterBalance array by the given parameters.
     */
    function getAdapterBalances(
        bytes32[] memory protocolAdapterNames,
        address account
    )
        public
        view
        returns (AdapterBalance[] memory)
    {
        uint256 length = protocolAdapterNames.length;
        AdapterBalance[] memory adapterBalances = new AdapterBalance[](length);

        for (uint256 i = 0; i < length; i++) {
            adapterBalances[i] = getAdapterBalance(
                protocolAdapterNames[i],
                _protocolAdapterSupportedTokens[protocolAdapterNames[i]],
                account
            );
        }

        return adapterBalances;
    }

    /**
     * @param protocolAdapterName Protocol adapter's Name.
     * @param tokens Array of tokens' addresses.
     * @param account Address of the account.
     * @return AdapterBalance array by the given parameters.
     */
    function getAdapterBalance(
        bytes32 protocolAdapterName,
        address[] memory tokens,
        address account
    )
        public
        view
        returns (AdapterBalance memory)
    {
        address adapter = _protocolAdapterAddress[protocolAdapterName];
        require(adapter != address(0), "AR: bad protocolAdapterName");

        uint256 length = tokens.length;
        AbsoluteTokenAmount[] memory absoluteTokenAmounts = new AbsoluteTokenAmount[](tokens.length);

        for (uint256 i = 0; i < length; i++) {
            try ProtocolAdapter(adapter).getBalance(
                tokens[i],
                account
            ) returns (uint256 amount) {
                absoluteTokenAmounts[i] = AbsoluteTokenAmount({
                    token: tokens[i],
                    amount: amount
                });
            } catch {
                absoluteTokenAmounts[i] = AbsoluteTokenAmount({
                    token: tokens[i],
                    amount: 0
                });
            }
        }

        return AdapterBalance({
            protocolAdapterName: protocolAdapterName,
            absoluteTokenAmounts: absoluteTokenAmounts
        });
    }
}

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


abstract contract Ownable {

    modifier onlyOwner {
        require(msg.sender == owner_, "O: only owner");
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner_, "O: only pending owner");
        _;
    }

    address private owner_;
    address private pendingOwner_;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @notice Initializes owner variable with msg.sender address.
     */
    constructor() internal {
        owner_ = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Sets pending owner to the desired address.
     * The function is callable only by the owner.
     */
    function proposeOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "O: empty newOwner");
        require(newOwner != owner_, "O: equal to owner_");
        require(newOwner != pendingOwner_, "O: equal to pendingOwner_");
        pendingOwner_ = newOwner;
    }

    /**
     * @notice Transfers ownership to the pending owner.
     * The function is callable only by the pending owner.
     */
    function acceptOwnership() external onlyPendingOwner {
        emit OwnershipTransferred(owner_, msg.sender);
        owner_ = msg.sender;
        delete pendingOwner_;
    }

    /**
     * @return Owner of the contract.
     */
    function owner() external view returns (address) {
        return owner_;
    }

    /**
     * @return Pending owner of the contract.
     */
    function pendingOwner() external view returns (address) {
        return pendingOwner_;
    }
}

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import { Ownable } from "./Ownable.sol";


/**
 * @title ProtocolAdapterRegistry part responsible for protocol adapters management.
 * @dev Base contract for ProtocolAdapterRegistry.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract ProtocolAdapterManager is Ownable {

    // Protocol adapters' names
    bytes32[] internal _protocolAdapterNames;
    // Protocol adapter's name => protocol adapter's address
    mapping (bytes32 => address) internal _protocolAdapterAddress;
    // protocol adapter's name => protocol adapter's supported tokens
    mapping (bytes32 => address[]) internal _protocolAdapterSupportedTokens;

    /**
     * @notice Adds protocol adapters.
     * The function is callable only by the owner.
     * @param newProtocolAdapterNames Array of the new protocol adapters' names.
     * @param newProtocolAdapterAddresses Array of the new protocol adapters' addresses.
     * @param newSupportedTokens Array of the new protocol adapters' supported tokens.
     */
    function addProtocolAdapters(
        bytes32[] calldata newProtocolAdapterNames,
        address[] calldata newProtocolAdapterAddresses,
        address[][] calldata newSupportedTokens
    )
        external
        onlyOwner
    {
        uint256 length = newProtocolAdapterNames.length;
        require(length != 0, "PAM: empty[1]");
        require(length == newProtocolAdapterAddresses.length, "PAM: lengths differ[1]");
        require(length == newSupportedTokens.length, "PAM: lengths differ[2]");

        for (uint256 i = 0; i < length; i++) {
            addProtocolAdapter(
                newProtocolAdapterNames[i],
                newProtocolAdapterAddresses[i],
                newSupportedTokens[i]
            );
        }
    }

    /**
     * @notice Removes protocol adapters.
     * The function is callable only by the owner.
     * @param protocolAdapterNames Array of the protocol adapters' names.
     */
    function removeProtocolAdapters(
        bytes32[] calldata protocolAdapterNames
    )
        external
        onlyOwner
    {
        uint256 length = protocolAdapterNames.length;
        require(length != 0, "PAM: empty[2]");

        for (uint256 i = 0; i < length; i++) {
            removeProtocolAdapter(protocolAdapterNames[i]);
        }
    }

    /**
     * @notice Updates protocol adapters.
     * The function is callable only by the owner.
     * @param protocolAdapterNames Array of the protocol adapters' names.
     * @param newProtocolAdapterAddresses Array of the protocol adapters' new addresses.
     * @param newSupportedTokens Array of the protocol adapters' new supported tokens.
     */
    function updateProtocolAdapters(
        bytes32[] calldata protocolAdapterNames,
        address[] calldata newProtocolAdapterAddresses,
        address[][] calldata newSupportedTokens
    )
        external
        onlyOwner
    {
        uint256 length = protocolAdapterNames.length;
        require(length != 0, "PAM: empty[3]");
        require(length == newProtocolAdapterAddresses.length, "PAM: lengths differ[3]");
        require(length == newSupportedTokens.length, "PAM: lengths differ[4]");

        for (uint256 i = 0; i < length; i++) {
            updateProtocolAdapter(
                protocolAdapterNames[i],
                newProtocolAdapterAddresses[i],
                newSupportedTokens[i]
            );
        }
    }

    /**
     * @return Array of protocol adapters' names.
     */
    function getProtocolAdapterNames()
        external
        view
        returns (bytes32[] memory)
    {
        return _protocolAdapterNames;
    }

    /**
     * @param protocolAdapterName Name of the protocol adapter.
     * @return Address of protocol adapter.
     */
    function getProtocolAdapterAddress(
        bytes32 protocolAdapterName
    )
        external
        view
        returns (address)
    {
        return _protocolAdapterAddress[protocolAdapterName];
    }

    /**
     * @param protocolAdapterName Name of the protocol adapter.
     * @return Array of protocol adapter's supported tokens.
     */
    function getSupportedTokens(
        bytes32 protocolAdapterName
    )
        external
        view
        returns (address[] memory)
    {
        return _protocolAdapterSupportedTokens[protocolAdapterName];
    }

    /**
     * @notice Adds a protocol adapter.
     * @param newProtocolAdapterName New protocol adapter's protocolAdapterName.
     * @param newAddress New protocol adapter's address.
     * @param newSupportedTokens Array of the new protocol adapter's supported tokens.
     * Empty array is always allowed.
     */
    function addProtocolAdapter(
        bytes32 newProtocolAdapterName,
        address newAddress,
        address[] calldata newSupportedTokens
    )
        internal
    {
        require(newProtocolAdapterName != bytes32(0), "PAM: zero[1]");
        require(newAddress != address(0), "PAM: zero[2]");
        require(_protocolAdapterAddress[newProtocolAdapterName] == address(0), "PAM: exists");

        _protocolAdapterNames.push(newProtocolAdapterName);
        _protocolAdapterAddress[newProtocolAdapterName] = newAddress;
        _protocolAdapterSupportedTokens[newProtocolAdapterName] = newSupportedTokens;
    }

    /**
     * @notice Removes a protocol adapter.
     * @param protocolAdapterName Protocol adapter's protocolAdapterName.
     */
    function removeProtocolAdapter(
        bytes32 protocolAdapterName
    )
        internal
    {
        require(_protocolAdapterAddress[protocolAdapterName] != address(0), "PAM: does not exist[1]");

        uint256 length = _protocolAdapterNames.length;
        uint256 index = 0;
        while (_protocolAdapterNames[index] != protocolAdapterName) {
            index++;
        }

        if (index != length - 1) {
            _protocolAdapterNames[index] = _protocolAdapterNames[length - 1];
        }

        _protocolAdapterNames.pop();

        delete _protocolAdapterAddress[protocolAdapterName];
        delete _protocolAdapterSupportedTokens[protocolAdapterName];
    }

    /**
     * @notice Updates a protocol adapter.
     * @param protocolAdapterName Protocol adapter's protocolAdapterName.
     * @param newProtocolAdapterAddress Protocol adapter's new address.
     * @param newSupportedTokens Array of the protocol adapter's new supported tokens.
     * Empty array is always allowed.
     */
    function updateProtocolAdapter(
        bytes32 protocolAdapterName,
        address newProtocolAdapterAddress,
        address[] calldata newSupportedTokens
    )
        internal
    {
        address oldProtocolAdapterAddress = _protocolAdapterAddress[protocolAdapterName];
        require(oldProtocolAdapterAddress != address(0), "PAM: does not exist[2]");
        require(newProtocolAdapterAddress != address(0), "PAM: zero[3]");

        if (oldProtocolAdapterAddress == newProtocolAdapterAddress) {
            _protocolAdapterSupportedTokens[protocolAdapterName] = newSupportedTokens;
        } else {
            _protocolAdapterAddress[protocolAdapterName] = newProtocolAdapterAddress;
            _protocolAdapterSupportedTokens[protocolAdapterName] = newSupportedTokens;
        }
    }
}

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
}

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


// The struct consists of AbsoluteTokenAmount structs for
// (base) token and its underlying tokens (if any).
struct FullAbsoluteTokenAmount {
    AbsoluteTokenAmountMeta base;
    AbsoluteTokenAmountMeta[] underlying;
}


// The struct consists of AbsoluteTokenAmount struct
// with token address and absolute amount
// and ERC20Metadata struct with ERC20-style metadata.
// NOTE: 0xEeee...EEeE address is used for ETH.
struct AbsoluteTokenAmountMeta {
    AbsoluteTokenAmount absoluteTokenAmount;
    ERC20Metadata erc20metadata;
}


// The struct consists of ERC20-style token metadata.
struct ERC20Metadata {
    string name;
    string symbol;
    uint8 decimals;
}


// The struct consists of protocol adapter's name
// and array of AbsoluteTokenAmount structs
// with token addresses and absolute amounts.
struct AdapterBalance {
    bytes32 protocolAdapterName;
    AbsoluteTokenAmount[] absoluteTokenAmounts;
}


// The struct consists of token address
// and its absolute amount.
struct AbsoluteTokenAmount {
    address token;
    uint256 amount;
}


// The struct consists of token address,
// and price per full share (1e18).
struct Component {
    address token;
    uint256 rate;
}


//=============================== Interactive Adapters Structs ====================================


struct TransactionData {
    Action[] actions;
    TokenAmount[] inputs;
    Fee fee;
    AbsoluteTokenAmount[] requiredOutputs;
    uint256 nonce;
}


struct Action {
    bytes32 protocolAdapterName;
    ActionType actionType;
    TokenAmount[] tokenAmounts;
    bytes data;
}


struct TokenAmount {
    address token;
    uint256 amount;
    AmountType amountType;
}


struct Fee {
    uint256 share;
    address beneficiary;
}


enum ActionType { None, Deposit, Withdraw }


enum AmountType { None, Relative, Absolute }

// Copyright (C) 2020 Zerion Inc. <https://zerion.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


/**
 * @title Protocol adapter abstract contract.
 * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract ProtocolAdapter {

    /**
     * @dev MUST return amount and type of the given token
     * locked on the protocol by the given account.
     */
    function getBalance(
        address token,
        address account
    )
        public
        view
        virtual
        returns (uint256);
}


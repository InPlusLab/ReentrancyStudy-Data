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

import { ProtocolAdapter } from "../adapters/ProtocolAdapter.sol";
import { TokenAmount, AmountType } from "../shared/Structs.sol";
import { ERC20 } from "../shared/ERC20.sol";


/**
 * @title Base contract for interactive protocol adapters.
 * @dev deposit() and withdraw() functions MUST be implemented
 * as well as all the functions from ProtocolAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract InteractiveAdapter is ProtocolAdapter {

    uint256 internal constant DELIMITER = 1e18;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev The function must deposit assets to the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
    function deposit(
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    /**
     * @dev The function must withdraw assets from the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
    function withdraw(
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
        payable
        virtual
        returns (address[] memory);

    function getAbsoluteAmountDeposit(
        TokenAmount memory tokenAmount
    )
        internal
        view
        virtual
        returns (uint256)
    {
        address token = tokenAmount.token;
        uint256 amount = tokenAmount.amount;
        AmountType amountType = tokenAmount.amountType;

        require(
            amountType == AmountType.Relative || amountType == AmountType.Absolute,
            "IA: bad amount type"
        );
        if (amountType == AmountType.Relative) {
            require(amount <= DELIMITER, "IA: bad amount");

            uint256 balance;
            if (token == ETH) {
                balance = address(this).balance;
            } else {
                balance = ERC20(token).balanceOf(address(this));
            }

            if (amount == DELIMITER) {
                return balance;
            } else {
                return mul(balance, amount) / DELIMITER;
            }
        } else {
            return amount;
        }
    }

    function getAbsoluteAmountWithdraw(
        TokenAmount memory tokenAmount
    )
        internal
        view
        virtual
        returns (uint256)
    {
        address token = tokenAmount.token;
        uint256 amount = tokenAmount.amount;
        AmountType amountType = tokenAmount.amountType;

        require(
            amountType == AmountType.Relative || amountType == AmountType.Absolute,
            "IA: bad amount type"
        );
        if (amountType == AmountType.Relative) {
            require(amount <= DELIMITER, "IA: bad amount");

            uint256 balance = getBalance(token, address(this));
            if (amount == DELIMITER) {
                return balance;
            } else {
                return mul(balance, amount) / DELIMITER;
            }
        } else {
            return amount;
        }
    }

    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "IA: mul overflow");

        return c;
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

contract ReentrancyGuard {

    uint256 internal constant UNLOCKED = 1;
    uint256 internal constant LOCKED = 2;

    uint256 internal guard_;

    constructor () internal {
        guard_ = UNLOCKED;
    }

    modifier nonReentrant() {
        require(guard_ == UNLOCKED, "RG: locked");

        guard_ = LOCKED;

        _;

        guard_ = UNLOCKED;
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

import { TransactionData, Action, AbsoluteTokenAmount, Fee, TokenAmount } from "../shared/Structs.sol";


contract SignatureVerifier {

    mapping (address => uint256) internal nonce_;

    bytes32 internal immutable domainSeparator_;

    bytes32 internal constant DOMAIN_SEPARATOR_TYPEHASH = keccak256(
        abi.encodePacked(
            "EIP712Domain(",
            "string name,",
            "address verifyingContract",
            ")"
        )
    );
    bytes32 internal constant TX_DATA_TYPEHASH = keccak256(
        abi.encodePacked(
            TX_DATA_ENCODED_TYPE,
            ABSOLUTE_TOKEN_AMOUNT_ENCODED_TYPE,
            ACTION_ENCODED_TYPE,
            FEE_ENCODED_TYPE,
            TOKEN_AMOUNT_ENCODED_TYPE
        )
    );
    bytes32 internal constant ABSOLUTE_TOKEN_AMOUNT_TYPEHASH =
        keccak256(ABSOLUTE_TOKEN_AMOUNT_ENCODED_TYPE);
    bytes32 internal constant ACTION_TYPEHASH = keccak256(
        abi.encodePacked(
            ACTION_ENCODED_TYPE,
            TOKEN_AMOUNT_ENCODED_TYPE
        )
    );
    bytes32 internal constant FEE_TYPEHASH = keccak256(FEE_ENCODED_TYPE);
    bytes32 internal constant TOKEN_AMOUNT_TYPEHASH = keccak256(TOKEN_AMOUNT_ENCODED_TYPE);

    bytes internal constant TX_DATA_ENCODED_TYPE = abi.encodePacked(
        "TransactionData(",
        "Action[] actions,",
        "TokenAmount[] inputs,",
        "Fee fee,",
        "AbsoluteTokenAmount[] requiredOutputs,",
        "uint256 nonce",
        ")"
    );
    bytes internal constant ABSOLUTE_TOKEN_AMOUNT_ENCODED_TYPE = abi.encodePacked(
        "AbsoluteTokenAmount(",
        "address token,",
        "uint256 amount",
        ")"
    );
    bytes internal constant ACTION_ENCODED_TYPE = abi.encodePacked(
        "Action(",
        "bytes32 protocolAdapterName,",
        "uint8 actionType,",
        "TokenAmount[] tokenAmounts,",
        "bytes data",
        ")"
    );
    bytes internal constant FEE_ENCODED_TYPE = abi.encodePacked(
        "Fee(",
        "uint256 share,",
        "address beneficiary",
        ")"
    );
    bytes internal constant TOKEN_AMOUNT_ENCODED_TYPE = abi.encodePacked(
        "TokenAmount(",
        "address token,",
        "uint256 amount,",
        "uint8 amountType",
        ")"
    );

    constructor(string memory name) public {
        domainSeparator_ = keccak256(
            abi.encode(
                DOMAIN_SEPARATOR_TYPEHASH,
                keccak256(abi.encodePacked(name)),
                address(this)
            )
        );
    }

    /**
     * @return Address of the Core contract used.
     */
    function nonce(
        address account
    )
        external
        view
        returns (uint256)
    {
        return nonce_[account];
    }

    function updateNonce(
        address account
    )
        internal
    {
        nonce_[account]++;
    }

    function getAccountFromSignature(
        TransactionData memory data,
        bytes memory signature
    )
        public
        view
        returns (address payable)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 hashedData = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                domainSeparator_,
                hash(data)
            )
        );

        address signer = ecrecover(hashedData, v, r, s);

        require(signer != address(0), "SV: bad signature");
        require(nonce_[signer] == data.nonce, "SV: bad nonce");

        return payable(signer);
    }

    /// @return Hash to be signed by tokens supplier.
    function hash(
        TransactionData memory data
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                TX_DATA_TYPEHASH,
                hash(data.actions),
                hash(data.inputs),
                hash(data.fee),
                hash(data.requiredOutputs),
                data.nonce
            )
        );
    }

    function hash(
        Action[] memory actions
    )
        internal
        pure
        returns (bytes32)
    {
        bytes memory actionsData = new bytes(0);

        uint256 length = actions.length;
        for (uint256 i = 0; i < length; i++) {
            actionsData = abi.encodePacked(
                actionsData,
                keccak256(
                    abi.encode(
                        ACTION_TYPEHASH,
                        actions[i].protocolAdapterName,
                        actions[i].actionType,
                        hash(actions[i].tokenAmounts),
                        keccak256(actions[i].data)
                    )
                )
            );
        }

        return keccak256(actionsData);
    }

    function hash(
        TokenAmount[] memory tokenAmounts
    )
        internal
        pure
        returns (bytes32)
    {
        bytes memory tokenAmountsData = new bytes(0);

        uint256 length = tokenAmounts.length;
        for (uint256 i = 0; i < length; i++) {
            tokenAmountsData = abi.encodePacked(
                tokenAmountsData,
                keccak256(
                    abi.encode(
                        TOKEN_AMOUNT_TYPEHASH,
                        tokenAmounts[i].token,
                        tokenAmounts[i].amount,
                        tokenAmounts[i].amountType
                    )
                )
            );
        }

        return keccak256(tokenAmountsData);
    }

    function hash(
        Fee memory fee
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                FEE_TYPEHASH,
                fee.share,
                fee.beneficiary
            )
        );
    }

    function hash(
        AbsoluteTokenAmount[] memory absoluteTokenAmounts
    )
        internal
        pure
        returns (bytes32)
    {
        bytes memory absoluteTokenAmountsData = new bytes(0);

        uint256 length = absoluteTokenAmounts.length;
        for (uint256 i = 0; i < length; i++) {
            absoluteTokenAmountsData = abi.encodePacked(
                absoluteTokenAmountsData,
                keccak256(
                    abi.encode(
                        ABSOLUTE_TOKEN_AMOUNT_TYPEHASH,
                        absoluteTokenAmounts[i].token,
                        absoluteTokenAmounts[i].amount
                    )
                )
            );
        }

        return keccak256(absoluteTokenAmountsData);
    }

    function splitSignature(
        bytes memory signature
    )
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(signature.length == 65, "SV: bad signature");

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(signature, 32))
            // second 32 bytes.
            s := mload(add(signature, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(signature, 96)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        // Reference: github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/cryptography/ECDSA.sol
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("SV: bad 's'");
        }

        if (v != 27 && v != 28) {
            revert("SV: bad 'v'");
        }

        return (v, r, s);
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
 * @notice Library helps to convert different types to strings.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
library Helpers {

    /**
     * @dev Internal function to convert bytes32 to string and trim zeroes.
     */
    function toString(bytes32 data) internal pure returns (string memory) {
        uint256 counter = 0;
        for (uint256 i = 0; i < 32; i++) {
            if (data[i] != bytes1(0)) {
                counter++;
            }
        }

        bytes memory result = new bytes(counter);
        counter = 0;
        for (uint256 i = 0; i < 32; i++) {
            if (data[i] != bytes1(0)) {
                result[counter] = data[i];
                counter++;
            }
        }

        return string(result);
    }

    /**
     * @dev Internal function to convert uint256 to string.
     */
    function toString(uint256 data) internal pure returns (string memory) {
        uint256 length = 0;

        uint256 dataCopy = data;
        while (dataCopy != 0) {
            length++;
            dataCopy /= 10;
        }

        bytes memory result = new bytes(length);
        dataCopy = data;

        // Here, we have on-purpose underflow cause we need case `i = 0` to be included in the loop
        for (uint256 i = length - 1; i < length; i--) {
            result[i] = bytes1(uint8(48 + dataCopy % 10));
            dataCopy /= 10;
        }

        return string(result);
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

import { Action, AbsoluteTokenAmount, ActionType, AmountType } from "../shared/Structs.sol";
import { InteractiveAdapter } from "../interactiveAdapters/InteractiveAdapter.sol";
import { ERC20 } from "../shared/ERC20.sol";
import { ProtocolAdapterRegistry } from "./ProtocolAdapterRegistry.sol";
import { SafeERC20 } from "../shared/SafeERC20.sol";
import { Helpers } from "../shared/Helpers.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";


/**
 * @title Main contract executing actions.
 */
contract Core is ReentrancyGuard {
    using SafeERC20 for ERC20;

    address internal immutable protocolAdapterRegistry_;

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event ExecutedAction(Action action);

    constructor(
        address protocolAdapterRegistry
    )
        public
    {
        require(protocolAdapterRegistry != address(0), "C: empty protocolAdapterRegistry");
        protocolAdapterRegistry_ = protocolAdapterRegistry;
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    /**
     * @notice Executes actions and returns tokens to account.
     * @param actions Array with actions to be executed.
     * @param requiredOutputs Array with required amounts for the returned tokens.
     * @param account Address that will receive all the resulting funds.
     * @return actualOutputs Array with actual amounts for the returned tokens.
     */
    function executeActions(
        Action[] calldata actions,
        AbsoluteTokenAmount[] calldata requiredOutputs,
        address payable account
    )
        external
        payable
        nonReentrant
        returns (AbsoluteTokenAmount[] memory)
    {
        require(account != address(0), "C: empty account");
        address[][] memory tokensToBeWithdrawn = new address[][](actions.length);

        for (uint256 i = 0; i < actions.length; i++) {
            tokensToBeWithdrawn[i] = executeAction(actions[i]);
            emit ExecutedAction(actions[i]);
        }

        return returnTokens(requiredOutputs, tokensToBeWithdrawn, account);
    }

    /**
     * @notice Execute one action via external call.
     * @param action Action struct.
     * @dev Can be called only by this contract.
     * This function is used to create cross-protocol adapters.
     */
    function executeActionExternal(
        Action calldata action
    )
        external
        returns (address[] memory)
    {
        require(msg.sender == address(this), "C: only address(this)");
        return executeAction(action);
    }

    /**
     * @return Address of the ProtocolAdapterRegistry contract used.
     */
    function protocolAdapterRegistry()
        external
        view
        returns (address)
    {
        return protocolAdapterRegistry_;
    }

    function executeAction(
        Action calldata action
    )
        internal
        returns (address[] memory)
    {
        address adapter = ProtocolAdapterRegistry(protocolAdapterRegistry_).getProtocolAdapterAddress(
            action.protocolAdapterName
        );
        require(adapter != address(0), "C: bad name");
        require(
            action.actionType == ActionType.Deposit || action.actionType == ActionType.Withdraw,
            "C: bad action type"
        );
        bytes4 selector;
        if (action.actionType == ActionType.Deposit) {
            selector = InteractiveAdapter(adapter).deposit.selector;
        } else {
            selector = InteractiveAdapter(adapter).withdraw.selector;
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = adapter.delegatecall(
            abi.encodeWithSelector(
                selector,
                action.tokenAmounts,
                action.data
            )
        );

        // assembly revert opcode is used here as `returnData`
        // is already bytes array generated by the callee's revert()
        // solhint-disable-next-line no-inline-assembly
        assembly {
            if eq(success, 0) { revert(add(returnData, 32), returndatasize()) }
        }

        return abi.decode(returnData, (address[]));
    }

    function returnTokens(
        AbsoluteTokenAmount[] calldata requiredOutputs,
        address[][] memory tokensToBeWithdrawn,
        address payable account
    )
        internal
        returns (AbsoluteTokenAmount[] memory)
    {
        uint256 length = requiredOutputs.length;
        uint256 lengthNested;
        address token;
        AbsoluteTokenAmount[] memory actualOutputs = new AbsoluteTokenAmount[](length);

        for (uint256 i = 0; i < length; i++) {
            token = requiredOutputs[i].token;
            actualOutputs[i] = AbsoluteTokenAmount({
                token: token,
                amount: checkRequirementAndTransfer(
                    token,
                    requiredOutputs[i].amount,
                    account
                )
            });
        }

        length = tokensToBeWithdrawn.length;
        for (uint256 i = 0; i < length; i++) {
            lengthNested = tokensToBeWithdrawn[i].length;
            for (uint256 j = 0; j < lengthNested; j++) {
                checkRequirementAndTransfer(tokensToBeWithdrawn[i][j], 0, account);
            }
        }

        return actualOutputs;
    }

    function checkRequirementAndTransfer(
        address token,
        uint256 requiredAmount,
        address account
    )
        internal
        returns (uint256)
    {
        uint256 actualAmount;
        if (token == ETH) {
            actualAmount = address(this).balance;
        } else {
            actualAmount = ERC20(token).balanceOf(address(this));
        }

        require(
            actualAmount >= requiredAmount,
            string(
                abi.encodePacked(
                    "C: ",
                    actualAmount,
                    " is less than ",
                    requiredAmount,
                    " for ",
                    token
                )
            )
        );

        if (actualAmount > 0) {
            if (token == ETH) {
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, ) = account.call{value: actualAmount}(new bytes(0));
                require(success, "ETH transfer to account failed");
            } else {
                ERC20(token).safeTransfer(account, actualAmount, "C");
            }
        }

        return actualAmount;
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

import {
    TransactionData,
    Action,
    TokenAmount,
    Fee,
    AbsoluteTokenAmount,
    AmountType
} from "../shared/Structs.sol";
import { ERC20 } from "../shared/ERC20.sol";
import { SafeERC20 } from "../shared/SafeERC20.sol";
import { SignatureVerifier } from "./SignatureVerifier.sol";
import { Ownable } from "./Ownable.sol";
import { Core } from "./Core.sol";


interface Chi {
    function freeUpTo(uint256) external;
}


contract Router is SignatureVerifier("Zerion Router"), Ownable {
    using SafeERC20 for ERC20;

    address internal immutable core_;

    address internal constant CHI = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal constant DELIMITER = 1e18; // 100%
    uint256 internal constant FEE_LIMIT = 1e16; // 1%

    constructor(address payable core) public {
        require(core != address(0), "R: empty core");
        core_ = core;
    }

    function returnLostTokens(
        address token,
        address payable beneficiary
    )
        external
        onlyOwner
    {
        if (token == ETH) {
            (bool success, ) = beneficiary.call{value: address(this).balance}(new bytes(0));
            require(success, "R: bad beneficiary");
        } else {
            ERC20(token).safeTransfer(beneficiary, ERC20(token).balanceOf(address(this)), "R");
        }
    }

    function getRequiredAllowances(
        TokenAmount[] calldata inputs,
        address account
    )
        external
        view
        returns (AbsoluteTokenAmount[] memory)
    {
        uint256 length = inputs.length;
        AbsoluteTokenAmount[] memory requiredAllowances = new AbsoluteTokenAmount[](length);
        uint256 required;
        uint256 current;

        for (uint256 i = 0; i < length; i++) {
            required = getAbsoluteAmount(inputs[i], account);
            current = ERC20(inputs[i].token).allowance(account, address(this));

            requiredAllowances[i] = AbsoluteTokenAmount({
                token: inputs[i].token,
                amount: required > current ? required - current : 0
            });
        }

        return requiredAllowances;
    }

    function getRequiredBalances(
        TokenAmount[] calldata inputs,
        address account
    )
        external
        view
        returns (AbsoluteTokenAmount[] memory)
    {
        uint256 length = inputs.length;
        AbsoluteTokenAmount[] memory requiredBalances = new AbsoluteTokenAmount[](length);
        uint256 required;
        uint256 current;

        for (uint256 i = 0; i < length; i++) {
            required = getAbsoluteAmount(inputs[i], account);
            current = ERC20(inputs[i].token).balanceOf(account);

            requiredBalances[i] = AbsoluteTokenAmount({
                token: inputs[i].token,
                amount: required > current ? required - current : 0
            });
        }

        return requiredBalances;
    }

    /**
     * @return Address of the Core contract used.
     */
    function core()
        external
        view
        returns (address)
    {
        return core_;
    }

    function startExecution(
        TransactionData memory data,
        bytes memory signature
    )
        public
        payable
        returns (AbsoluteTokenAmount[] memory)
    {
        address payable account = getAccountFromSignature(data, signature);

        updateNonce(account);

        return startExecution(
            data.actions,
            data.inputs,
            data.fee,
            data.requiredOutputs,
            account
        );
    }

    function startExecution(
        Action[] memory actions,
        TokenAmount[] memory inputs,
        Fee memory fee,
        AbsoluteTokenAmount[] memory requiredOutputs
    )
        public
        payable
        returns (AbsoluteTokenAmount[] memory)
    {
        return startExecution(
            actions,
            inputs,
            fee,
            requiredOutputs,
            msg.sender
        );
    }

    function startExecution(
        Action[] memory actions,
        TokenAmount[] memory inputs,
        Fee memory fee,
        AbsoluteTokenAmount[] memory requiredOutputs,
        address payable account
    )
        internal
        returns (AbsoluteTokenAmount[] memory)
    {
        // save initial gas to burn gas token later
        uint256 gas = gasleft();
        // transfer tokens to core_, handle fees (if any), and add these tokens to outputs
        transferTokens(inputs, fee, account);
        AbsoluteTokenAmount[] memory modifiedOutputs = modifyOutputs(requiredOutputs, inputs);
        // call Core contract with all provided ETH, actions, expected outputs and account address
        AbsoluteTokenAmount[] memory actualOutputs = Core(payable(core_)).executeActions(
            actions,
            modifiedOutputs,
            account
        );
        // try to burn gas token to save some gas
        uint256 gasSpent = 21000 + gas - gasleft() + 16 * msg.data.length;
        Chi(CHI).freeUpTo((gasSpent + 14154) / 41130);
        // return tokens that were returned to the account address
        return actualOutputs;
    }

    function transferTokens(
        TokenAmount[] memory inputs,
        Fee memory fee,
        address account
    )
        internal
    {
        address token;
        uint256 absoluteAmount;
        uint256 feeAmount;
        uint256 length = inputs.length;

        if (fee.share > 0) {
            require(fee.beneficiary != address(0), "R: bad beneficiary");
            require(fee.share <= FEE_LIMIT, "R: bad fee");
        }

        for (uint256 i = 0; i < length; i++) {
            token = inputs[i].token;
            absoluteAmount = getAbsoluteAmount(inputs[i], account);
            require(absoluteAmount > 0, "R: zero amount");

            feeAmount = mul(absoluteAmount, fee.share) / DELIMITER;

            if (feeAmount > 0) {
                ERC20(token).safeTransferFrom(
                    account,
                    fee.beneficiary,
                    feeAmount,
                    "R[1]"
                );
            }

            ERC20(token).safeTransferFrom(
                account,
                core_,
                absoluteAmount - feeAmount,
                "R[2]"
            );
        }

        if (msg.value > 0) {
            feeAmount = mul(msg.value, fee.share) / DELIMITER;

            if (feeAmount > 0) {
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, ) = fee.beneficiary.call{value: feeAmount}(new bytes(0));
                require(success, "ETH transfer to beneficiary failed");
            }

            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = core_.call{value: msg.value - feeAmount}(new bytes(0));
            require(success, "ETH transfer to Core failed");
        }
    }

    function getAbsoluteAmount(
        TokenAmount memory tokenAmount,
        address account
    )
        internal
        view
        returns (uint256)
    {
        address token = tokenAmount.token;
        AmountType amountType = tokenAmount.amountType;
        uint256 amount = tokenAmount.amount;

        require(
            amountType == AmountType.Relative || amountType == AmountType.Absolute,
            "R: bad amount type"
        );

        if (amountType == AmountType.Relative) {
            require(amount <= DELIMITER, "R: bad amount");
            if (amount == DELIMITER) {
                return ERC20(token).balanceOf(account);
            } else {
                return mul(ERC20(token).balanceOf(account), amount) / DELIMITER;
            }
        } else {
            return amount;
        }
    }

    function modifyOutputs(
        AbsoluteTokenAmount[] memory requiredOutputs,
        TokenAmount[] memory inputs
    )
        internal
        view
        returns (AbsoluteTokenAmount[] memory)
    {
        uint256 ethInput = msg.value > 0 ? 1 : 0;
        AbsoluteTokenAmount[] memory modifiedOutputs = new AbsoluteTokenAmount[](
            requiredOutputs.length + inputs.length + ethInput
        );

        for (uint256 i = 0; i < requiredOutputs.length; i++) {
            modifiedOutputs[i] = requiredOutputs[i];
        }

        for (uint256 i = 0; i < inputs.length; i++) {
            modifiedOutputs[requiredOutputs.length + i] = AbsoluteTokenAmount({
                token: inputs[i].token,
                amount: 0
            });
        }

        if (ethInput > 0) {
            modifiedOutputs[requiredOutputs.length + inputs.length] = AbsoluteTokenAmount({
                token: ETH,
                amount: 0
            });
        }

        return modifiedOutputs;
    }

    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "R: mul overflow");

        return c;
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

import "./ERC20.sol";


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token contract
 * returns false). Tokens that return no value (and instead revert or throw on failure)
 * are also supported, non-reverting calls are assumed to be successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 value,
        string memory location
    )
        internal
    {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transfer.selector,
                to,
                value
            ),
            "transfer",
            location
        );
    }

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 value,
        string memory location
    )
        internal
    {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transferFrom.selector,
                from,
                to,
                value
            ),
            "transferFrom",
            location
        );
    }

    function safeApprove(
        ERC20 token,
        address spender,
        uint256 value,
        string memory location
    )
        internal
    {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: bad approve call"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                value
            ),
            "approve",
            location
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract),
     * relaxing the requirement on the return value: the return value is optional
     * (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     * @param location Location of the call (for debug).
     */
    function callOptionalReturn(
        ERC20 token,
        bytes memory data,
        string memory functionName,
        string memory location
    )
        private
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking
        // mechanism, since we're implementing it ourselves.

        // We implement two-steps call as callee is a contract is a responsibility of a caller.
        //  1. The call itself is made, and success asserted
        //  2. The return value is decoded, which in turn checks the size of the returned data.

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(
            success,
            string(
                abi.encodePacked(
                    "SafeERC20: ",
                    functionName,
                    " failed in ",
                    location
                )
            )
        );

        if (returndata.length > 0) { // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                string(
                    abi.encodePacked(
                        "SafeERC20: ",
                        functionName,
                        " returned false in ",
                        location
                    )
                )
            );
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


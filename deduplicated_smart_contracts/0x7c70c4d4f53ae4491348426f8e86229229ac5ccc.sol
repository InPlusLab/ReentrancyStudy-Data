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

import { ERC20 } from "../../shared/ERC20.sol";
import { SafeERC20 } from "../../shared/SafeERC20.sol";
import { TokenAmount, AmountType } from "../../shared/Structs.sol";
import { UniswapExchangeAdapter } from "../../adapters/uniswap/UniswapExchangeAdapter.sol";
import { InteractiveAdapter } from "../InteractiveAdapter.sol";


/**
 * @dev UniswapV2Router01 contract interface.
 * Only the functions required for UniswapV2ExchangeInteractiveAdapter contract are added.
 * The UniswapV2Router01 contract is available here
 * github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router01.sol.
 */
interface UniswapV2Router01 {
    function swapExactTokensForTokens(
        uint,
        uint,
        address[] calldata,
        address,
        uint
    ) external returns (uint[] memory);
    function swapTokensForExactTokens(
        uint,
        uint,
        address[] calldata,
        address,
        uint
    ) external returns (uint[] memory);
}

/**
 * @title Interactive adapter for Uniswap V2 protocol (exchange).
 * @dev Implementation of InteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract UniswapV2ExchangeInteractiveAdapter is InteractiveAdapter, UniswapExchangeAdapter {
    using SafeERC20 for ERC20;

    address internal constant ROUTER = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;

    /**
     * @notice Exchange tokens using Uniswap pool.
     * @param tokenAmounts Array with one element - TokenAmount struct with
     * "from" token address, "from" token amount, and amount type.
     * @param data Uniswap exchange path starting from tokens[0] (ABI-encoded).
     * @return tokensToBeWithdrawn Array with one element - token address to be exchanged to.
     * @dev Implementation of InteractiveAdapter function.
     */
    function deposit(
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
        payable
        override
        returns (address[] memory tokensToBeWithdrawn)
    {
        require(tokenAmounts.length == 1, "UEIA: should be 1 tokenAmount");

        address[] memory path = abi.decode(data, (address[]));
        address token = tokenAmounts[0].token;
        require(token == path[0], "UEIA: bad path[0]");
        uint256 amount = getAbsoluteAmountDeposit(tokenAmounts[0]);

        tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = path[path.length - 1];

        ERC20(token).safeApprove(ROUTER, amount, "UEIA[1]");

        try UniswapV2Router01(ROUTER).swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            // solhint-disable-next-line not-rely-on-time
            now
        ) returns (uint256[] memory) { // solhint-disable-line no-empty-blocks
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("UEIA: deposit fail");
        }
    }

    /**
     * @notice Exchange tokens using Uniswap pool.
     * @param tokenAmounts Array with one element - TokenAmount struct with
     * "to" token address, "to" token amount, and amount type (must be absolute).
     * @param data Uniswap exchange path ending with tokens[0] (ABI-encoded).
     * @return tokensToBeWithdrawn Array with one element - token address to be changed to.
     * @dev Implementation of InteractiveAdapter function.
     */
    function withdraw(
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
        payable
        override
        returns (address[] memory tokensToBeWithdrawn)
    {
        require(tokenAmounts.length == 1, "UEIA: should be 1 tokenAmount");
        require(tokenAmounts[0].amountType == AmountType.Absolute, "UEIA: bad type");

        address[] memory path = abi.decode(data, (address[]));
        address token = tokenAmounts[0].token;
        require(token == path[path.length - 1], "UEIA: bad path[path.length - 1]");
        uint256 amount = tokenAmounts[0].amount;

        tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = token;

        ERC20(path[0]).safeApprove(ROUTER, ERC20(path[0]).balanceOf(address(this)), "UEIA[2]");

        try UniswapV2Router01(ROUTER).swapTokensForExactTokens(
            amount,
            type(uint256).max,
            path,
            address(this),
            // solhint-disable-next-line not-rely-on-time
            now
        ) returns (uint256[] memory) { //solhint-disable-line no-empty-blocks
        } catch Error(string memory reason) {
            revert(reason);
        } catch {
            revert("UEIA: withdraw fail");
        }

        ERC20(path[0]).safeApprove(ROUTER, 0, "UEIA[3]");
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

import { ERC20 } from "../../shared/ERC20.sol";
import { ProtocolAdapter } from "../ProtocolAdapter.sol";


/**
 * @title Adapter for Uniswap V1/V2 protocol (exchange).
 * @dev Implementation of ProtocolAdapter abstract contract.
 * Base contract for Uniswap V1/V2 exchange adapter.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract UniswapExchangeAdapter is ProtocolAdapter {

    /**
     * @notice This function is unavailable for exchange adapter.
     * @dev Implementation of ProtocolAdapter abstract contract function.
     */
    function getBalance(
        address,
        address
    )
        public
        view
        override
        returns (uint256)
    {
        revert("UEA: no balance");
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


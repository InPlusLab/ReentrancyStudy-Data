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

pragma solidity 0.7.1;
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
    constructor() {
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

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import { ERC20 } from "../../shared/ERC20.sol";
import { SafeERC20 } from "../../shared/SafeERC20.sol";
import { TokenAmount } from "../../shared/Structs.sol";
import { ERC20ProtocolAdapter } from "../../adapters/ERC20ProtocolAdapter.sol";
import { CurveRegistry, PoolInfo } from "../../adapters/curve/CurveRegistry.sol";
import { CurveInteractiveAdapter } from "./CurveInteractiveAdapter.sol";
import { Stableswap } from "../../interfaces/Stableswap.sol";


/**
 * @dev Deposit contract interface.
 * Only the functions required for CurveAssetInteractiveAdapter contract are added.
 * The Deposit contract is available here
 * github.com/curvefi/curve-contract/blob/compounded/vyper/deposit.vy.
 */
/* solhint-disable func-name-mixedcase */
interface Deposit {
    function add_liquidity(uint256[2] calldata, uint256) external;
    function add_liquidity(uint256[3] calldata, uint256) external;
    function add_liquidity(uint256[4] calldata, uint256) external;
    function remove_liquidity_one_coin(uint256, int128, uint256, bool) external;
}
/* solhint-enable func-name-mixedcase */


/**
 * @title Interactive adapter for Curve protocol (liquidity).
 * @dev Implementation of CurveInteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CurveAssetInteractiveAdapter is CurveInteractiveAdapter, ERC20ProtocolAdapter {
    using SafeERC20 for ERC20;

    address internal constant REGISTRY = 0x86A1755BA805ecc8B0608d56c22716bd1d4B68A8;

    /**
     * @notice Deposits tokens to the Curve pool (pair).
     * @param tokenAmounts Array with one element - TokenAmount struct with
     * underlying token address, underlying token amount to be deposited, and amount type.
     * @param data ABI-encoded additional parameters:
     *     - crvToken - curve token address.
     * @return tokensToBeWithdrawn Array with tokens sent back.
     * @dev Implementation of InteractiveAdapter function.
     */
    function deposit(
        TokenAmount[] calldata tokenAmounts,
        bytes calldata data
    )
        external
        payable
        override
        returns (address[] memory tokensToBeWithdrawn)
    {
        require(tokenAmounts.length == 1, "CLIA: should be 1 tokenAmount[1]");

        address token = tokenAmounts[0].token;
        uint256 amount = getAbsoluteAmountDeposit(tokenAmounts[0]);

        address crvToken = abi.decode(data, (address));
        tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = crvToken;

        PoolInfo memory poolInfo = CurveRegistry(REGISTRY).getPoolInfo(crvToken);
        uint256 totalCoins = poolInfo.totalCoins;
        address callee = poolInfo.deposit;

        int128 tokenIndex = getTokenIndex(token);
        require(
            Stableswap(poolInfo.swap).underlying_coins(tokenIndex) == token,
            "CLIA: bad crvToken/token"
        );

        uint256[] memory inputAmounts = new uint256[](totalCoins);
        for (uint256 i = 0; i < totalCoins; i++) {
            inputAmounts[i] = i == uint256(tokenIndex) ? amount : 0;
        }

        ERC20(token).safeApprove(
            callee,
            amount,
            "CLIA[1]"
        );

        if (totalCoins == 2) {
            try Deposit(callee).add_liquidity(
                [inputAmounts[0], inputAmounts[1]],
                0
            ) { // solhint-disable-line no-empty-blocks
            } catch {
                revert("CLIA: deposit fail[1]");
            }
        } else if (totalCoins == 3) {
            try Deposit(callee).add_liquidity(
                [inputAmounts[0], inputAmounts[1], inputAmounts[2]],
                0
            ) { // solhint-disable-line no-empty-blocks
            } catch {
                revert("CLIA: deposit fail[2]");
            }
        } else if (totalCoins == 4) {
            try Deposit(callee).add_liquidity(
                [inputAmounts[0], inputAmounts[1], inputAmounts[2], inputAmounts[3]],
                0
            ) { // solhint-disable-line no-empty-blocks
            } catch {
                revert("CLIA: deposit fail[3]");
            }
        }
    }

    /**
     * @notice Withdraws tokens from the Curve pool.
     * @param tokenAmounts Array with one element - TokenAmount struct with
     * Curve token address, Curve token amount to be redeemed, and amount type.
     * @param data ABI-encoded additional parameters:
     *     - toToken - destination token address (one of those used in pool).
     * @return tokensToBeWithdrawn Array with one element - destination token address.
     * @dev Implementation of InteractiveAdapter function.
     */
    function withdraw(
        TokenAmount[] calldata tokenAmounts,
        bytes calldata data
    )
        external
        payable
        override
        returns (address[] memory tokensToBeWithdrawn)
    {
        require(tokenAmounts.length == 1, "CLIA: should be 1 tokenAmount[2]");
        
        address token = tokenAmounts[0].token;
        uint256 amount = getAbsoluteAmountWithdraw(tokenAmounts[0]);
        address toToken = abi.decode(data, (address));

        tokensToBeWithdrawn = new address[](1);
        tokensToBeWithdrawn[0] = toToken;

        PoolInfo memory poolInfo = CurveRegistry(REGISTRY).getPoolInfo(token);
        address swap = poolInfo.swap;
        address callee = poolInfo.deposit;

        int128 tokenIndex = getTokenIndex(toToken);
        require(
            Stableswap(swap).underlying_coins(tokenIndex) == toToken,
            "CLIA: bad toToken/token"
        );

        ERC20(token).safeApprove(
            callee,
            amount,
            "CLIA[2]"
        );

        try Deposit(callee).remove_liquidity_one_coin(
            amount,
            tokenIndex,
            0,
            true
        ) { // solhint-disable-line no-empty-blocks
        } catch {
            revert("CLIA: withdraw fail");
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

pragma solidity 0.7.1;

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

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import { Ownable } from "../../core/Ownable.sol";


struct PoolInfo {
    address swap;       // stableswap contract address.
    address deposit;    // deposit contract address.
    uint256 totalCoins; // Number of coins used in stableswap contract.
    string name;        // Pool name ("... Pool").
}


/**
 * @title Registry for Curve contracts.
 * @dev Implements two getters - getSwapAndTotalCoins(address) and getName(address).
 * @notice Call getSwapAndTotalCoins(token) and getName(address) function and get address,
 * coins number, and name of stableswap contract for the given token address.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CurveRegistry is Ownable {

    mapping (address => PoolInfo) internal poolInfo_;

    function setPoolsInfo(
        address[] memory tokens,
        PoolInfo[] memory poolsInfo
    )
        external
        onlyOwner
    {
        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; i++) {
            setPoolInfo(tokens[i], poolsInfo[i]);
        }
    }

    function setPoolInfo(
        address token,
        PoolInfo memory poolInfo
    )
        internal
    {
        poolInfo_[token] = poolInfo;
    }

    function getPoolInfo(address token) external view returns (PoolInfo memory) {
        return poolInfo_[token];
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

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import { ERC20 } from "../shared/ERC20.sol";
import { ProtocolAdapter } from "./ProtocolAdapter.sol";


/**
 * @title Adapter for any protocol with ERC20 interface.
 * @dev Implementation of ProtocolAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract ERC20ProtocolAdapter is ProtocolAdapter {

    /**
     * @return Amount of tokens held by the given account.
     * @dev Implementation of ProtocolAdapter abstract contract function.
     */
    function getBalance(
        address token,
        address account
    )
        public
        view
        override
        returns (uint256)
    {
        return ERC20(token).balanceOf(account);
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

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import { InteractiveAdapter } from "../InteractiveAdapter.sol";


/**
 * @title Interactive adapter for Curve protocol (base contract).
 * @dev Implementation of InteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract CurveInteractiveAdapter is InteractiveAdapter {
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant TUSD = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address internal constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address internal constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address internal constant PAX = 0x8E870D67F660D95d5be530380D0eC0bd388289E1;
    address internal constant RENBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant SBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;
    address internal constant HBTC = 0x0316EB71485b0Ab14103307bf65a021042c6d380;

    function getTokenIndex(address token) internal pure returns (int128) {
        if (token == DAI || token == RENBTC || token == HBTC) {
            return int128(0);
        } else if (token == USDC || token == WBTC) {
            return int128(1);
        } else if (token == USDT || token == SBTC) {
            return int128(2);
        } else if (token == TUSD || token == BUSD || token == SUSD || token == PAX) {
            return int128(3);
        } else {
            revert("CIA: bad token");
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

pragma solidity 0.7.1;
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

pragma solidity 0.7.1;


/**
 * @dev Stableswap contract interface.
 * The Stableswap contract is available here
 * github.com/curvefi/curve-contract/blob/compounded/vyper/stableswap.vy.
 */
interface Stableswap {
    /* solhint-disable-next-line func-name-mixedcase */
    function underlying_coins(int128) external view returns (address);
    function exchange_underlying(int128, int128, uint256, uint256) external;
    function get_dy_underlying(int128, int128, uint256) external view returns (uint256);
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

pragma solidity 0.7.1;
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
        TokenAmount[] calldata tokenAmounts,
        bytes calldata data
    )
        external
        payable
        virtual
        returns (address[] memory);

    /**
     * @dev The function must withdraw assets from the protocol.
     * @return MUST return assets to be sent back to the `msg.sender`.
     */
    function withdraw(
        TokenAmount[] calldata tokenAmounts,
        bytes calldata data
    )
        external
        payable
        virtual
        returns (address[] memory);

    function getAbsoluteAmountDeposit(
        TokenAmount calldata tokenAmount
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
        TokenAmount calldata tokenAmount
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

pragma solidity 0.7.1;
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

pragma solidity 0.7.1;
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


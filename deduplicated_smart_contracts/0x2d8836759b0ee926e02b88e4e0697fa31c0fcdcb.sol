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
import { TokenAmount } from "../../shared/Structs.sol";
import { CurveAssetAdapter } from "../../adapters/curve/CurveAssetAdapter.sol";
import { CurveInteractiveAdapter } from "./CurveInteractiveAdapter.sol";


/**
 * @dev Stableswap contract interface.
 * Only the functions required for CurveAssetInteractiveAdapter contract are added.
 * The Stableswap contract is available here
 * github.com/curvefi/curve-contract/blob/compounded/vyper/stableswap.vy.
 */
/* solhint-disable func-name-mixedcase */
interface Stableswap {
    function underlying_coins(int128) external view returns (address);
}
/* solhint-enable func-name-mixedcase */


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
contract CurveAssetInteractiveAdapter is CurveInteractiveAdapter, CurveAssetAdapter {
    using SafeERC20 for ERC20;

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
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
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

        int128 tokenIndex = getTokenIndex(token);
        require(
            Stableswap(getSwap(crvToken)).underlying_coins(tokenIndex) == token,
            "CLIA: bad crvToken/token"
        );

        uint256 totalCoins = getTotalCoins(crvToken);
        uint256[] memory inputAmounts = new uint256[](totalCoins);
        for (uint256 i = 0; i < totalCoins; i++) {
            inputAmounts[i] = i == uint256(tokenIndex) ? amount : 0;
        }

        address callee = getDeposit(crvToken);

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
        TokenAmount[] memory tokenAmounts,
        bytes memory data
    )
        public
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

        int128 tokenIndex = getTokenIndex(toToken);
        require(
            Stableswap(getSwap(token)).underlying_coins(tokenIndex) == toToken,
            "CLIA: bad toToken/token"
        );

        address callee = getDeposit(token);

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
import { ProtocolAdapter } from "../ProtocolAdapter.sol";


/**
 * @title Adapter for Curve protocol (liquidity).
 * @dev Implementation of ProtocolAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CurveAssetAdapter is ProtocolAdapter {

    /**
     * @return Amount of Curve Pool Tokens held by the given account.
     * @param token Address of the Pool Token!
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

import { InteractiveAdapter } from "../InteractiveAdapter.sol";


/**
 * @title Interactive adapter for Curve protocol (base contract).
 * @dev Implementation of InteractiveAdapter abstract contract.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract CurveInteractiveAdapter is InteractiveAdapter {

    address internal constant C_SWAP = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
    address internal constant T_SWAP = 0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C;
    address internal constant Y_SWAP = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
    address internal constant B_SWAP = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address internal constant S_SWAP = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
    address internal constant P_SWAP = 0x06364f10B501e868329afBc005b3492902d6C763;
    address internal constant REN_SWAP = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
    address internal constant SBTC_SWAP = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;

    address internal constant C_DEPOSIT = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;
    address internal constant T_DEPOSIT = 0xac795D2c97e60DF6a99ff1c814727302fD747a80;
    address internal constant Y_DEPOSIT = 0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3;
    address internal constant B_DEPOSIT = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
    address internal constant S_DEPOSIT = 0xFCBa3E75865d2d561BE8D220616520c171F12851;
    address internal constant P_DEPOSIT = 0xA50cCc70b6a011CffDdf45057E39679379187287;

    address internal constant C_CRV = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;
    address internal constant T_CRV = 0x9fC689CCaDa600B6DF723D9E47D84d76664a1F23;
    address internal constant Y_CRV = 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8;
    address internal constant B_CRV = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address internal constant S_CRV = 0xC25a3A3b969415c80451098fa907EC722572917F;
    address internal constant P_CRV = 0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8;
    address internal constant REN_CRV = 0x7771F704490F9C0C3B06aFe8960dBB6c58CBC812;
    address internal constant SBTC_CRV = 0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3;

    uint256 internal constant C_COINS = 2;
    uint256 internal constant T_COINS = 3;
    uint256 internal constant Y_COINS = 4;
    uint256 internal constant B_COINS = 4;
    uint256 internal constant S_COINS = 4;
    uint256 internal constant P_COINS = 4;
    uint256 internal constant REN_COINS = 2;
    uint256 internal constant SBTC_COINS = 3;

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

    function getTokenIndex(address token) internal pure returns (int128) {
        if (token == DAI || token == RENBTC) {
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

    function getSwap(address token) internal pure returns (address) {
        if (token == C_CRV) {
            return C_SWAP;
        } else if (token == T_CRV) {
            return T_SWAP;
        } else if (token == Y_CRV) {
            return Y_SWAP;
        } else if (token == B_CRV) {
            return B_SWAP;
        } else if (token == S_CRV) {
            return S_SWAP;
        } else if (token == P_CRV) {
            return P_SWAP;
        } else if (token == REN_CRV) {
            return REN_SWAP;
        } else if (token == SBTC_CRV) {
            return SBTC_SWAP;
        } else {
            revert("CIA: bad token");
        }
    }

    function getDeposit(address token) internal pure returns (address) {
        if (token == C_CRV) {
            return C_DEPOSIT;
        } else if (token == T_CRV) {
            return T_DEPOSIT;
        } else if (token == Y_CRV) {
            return Y_DEPOSIT;
        } else if (token == B_CRV) {
            return B_DEPOSIT;
        } else if (token == S_CRV) {
            return S_DEPOSIT;
        } else if (token == P_CRV) {
            return P_DEPOSIT;
        } else if (token == REN_CRV) {
            return REN_SWAP;
        } else if (token == SBTC_CRV) {
            return SBTC_SWAP;
        } else {
            revert("CIA: bad token");
        }
    }

    function getTotalCoins(address token) internal pure returns (uint256) {
        if (token == C_CRV) {
            return C_COINS;
        } else if (token == T_CRV) {
            return T_COINS;
        } else if (token == Y_CRV) {
            return Y_COINS;
        } else if (token == B_CRV) {
            return B_COINS;
        } else if (token == S_CRV) {
            return S_COINS;
        } else if (token == P_CRV) {
            return P_COINS;
        } else if (token == REN_CRV) {
            return REN_COINS;
        } else if (token == SBTC_CRV) {
            return SBTC_COINS;
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


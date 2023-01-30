/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

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

pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


/**
 * @dev dYdX adapter abstract contract.
 * @dev Base contract for dYdX adapters.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
abstract contract DyDxAdapter {

    address internal constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant SAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function getMarketId(address token) internal pure returns (uint256) {
        if (token == WETH) {
            return uint256(0);
        } else if (token == SAI) {
            return uint256(1);
        } else if (token == USDC) {
            return uint256(2);
        } else if (token == DAI) {
            return uint256(3);
        } else {
            return uint256(-1);
        }
    }
}


/**
 * @title Base contract for protocol adapters.
 * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.
 */
interface ProtocolAdapter {

    /**
     * @dev MUST return "Asset" or "Debt".
     */
    function adapterType() external pure returns (string memory);

    /**
     * @dev MUST return token type (default is "ERC20").
     */
    function tokenType() external pure returns (string memory);

    /**
     * @dev MUST return amount of the given token locked on the protocol by the given account.
     */
    function getBalance(address token, address account) external view returns (uint256);
}


/**
 * @dev Info struct from Account library.
 * The Account library is available here
 * github.com/dydxprotocol/solo/blob/master/contracts/protocol/lib/Account.sol.
 */
struct Info {
    address owner;  // The address that owns the account
    uint256 number; // A nonce that allows a single address to control many accounts
}


/**
 * @dev Wei struct from Types library.
 * The Types library is available here
 * github.com/dydxprotocol/solo/blob/master/contracts/protocol/lib/Types.sol.
 */
struct Wei {
    bool sign; // true if positive
    uint256 value;
}


/**
 * @dev SoloMargin contract interface.
 * Only the functions required for DyDxDebtAdapter contract are added.
 * The SoloMargin contract is available here
 * github.com/dydxprotocol/solo/blob/master/contracts/protocol/SoloMargin.sol.
 */
interface SoloMargin {
    function getAccountWei(Info calldata, uint256) external view returns (Wei memory);
}


/**
 * @title Debt adapter for dYdX protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract DyDxDebtAdapter is ProtocolAdapter, DyDxAdapter {

    /**
     * @return Type of the adapter.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function adapterType() external pure override returns (string memory) {
        return "Debt";
    }

    /**
     * @return Type of the token used in adapter.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function tokenType() external pure override returns (string memory) {
        return "ERC20";
    }

    /**
     * @return Amount of tokens held by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) external view override returns (uint256) {
        Wei memory accountWei = SoloMargin(SOLO).getAccountWei(Info(account, 0), getMarketId(token));
        return accountWei.sign ? 0 : accountWei.value;
    }
}
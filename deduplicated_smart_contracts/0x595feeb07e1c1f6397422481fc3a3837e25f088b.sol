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


interface ERC20 {
    function balanceOf(address) external view returns (uint256);
}


/**
 * @title Protocol adapter interface.
 * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.
 * @author Igor Sobolev <sobolev@zerion.io>
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
 * @title Adapter for Curve protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract CurveAdapter is ProtocolAdapter {

    /**
     * @return Type of the adapter.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function adapterType() external pure override returns (string memory) {
        return "Asset";
    }

    /**
     * @return Type of the token used in adapter.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function tokenType() external pure override returns (string memory) {
        return "Curve pool token";
    }

    /**
     * @return Amount of Curve pool tokens held by the given account.
     * @param token Address of the pool token!
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) external view override returns (uint256) {
        return ERC20(token).balanceOf(account);
    }
}
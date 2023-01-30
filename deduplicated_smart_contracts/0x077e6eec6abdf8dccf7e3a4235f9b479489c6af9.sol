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
 * @dev LendingPoolAddressesProvider contract interface.
 * Only the functions required for AaveDebtAdapter contract are added.
 * The LendingPoolAddressesProvider contract is available here
 * github.com/aave/aave-protocol/blob/master/contracts/configuration/LendingPoolAddressesProvider.sol.
 */
interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (LendingPool);
}


/**
 * @dev LendingPool contract interface.
 * Only the functions required for AaveDebtAdapter contract are added.
 * The LendingPool contract is available here
 * github.com/aave/aave-protocol/blob/master/contracts/lendingpool/LendingPool.sol.
 */
interface LendingPool {
    function getUserReserveData(address, address) external view returns (uint256, uint256);
}


/**
 * @title Debt adapter for Aave protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
contract AaveDebtAdapter is ProtocolAdapter {

    address internal constant PROVIDER = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;

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
     * @return Amount of debt of the given account for the protocol.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) external view override returns (uint256) {
        LendingPool pool = LendingPoolAddressesProvider(PROVIDER).getLendingPool();

        (, uint256 debtAmount) = pool.getUserReserveData(token, account);

        return debtAmount;
    }
}
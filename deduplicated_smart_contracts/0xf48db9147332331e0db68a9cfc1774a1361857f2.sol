/**
 *Submitted for verification at Etherscan.io on 2020-11-10
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
// along with this program. If not, see <https://www.gnu.org/licenses/>.44db176eade96b63b3af44075eee9347f5d4d1b131bbe2b3e434dc5845ec3513

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

/**
 * @title Protocol adapter interface.
 * @dev adapterType(), tokenType(), and getBalance() functions MUST be implemented.
 * @author Igor Sobolev <sobolev@zerion.io>
 */
interface ProtocolAdapter {

    /**
     * @dev MUST return "Asset" or "Debt".
     * SHOULD be implemented by the public constant state variable.
     */
    function adapterType() external pure returns (string memory);

    /**
     * @dev MUST return token type (default is "ERC20").
     * SHOULD be implemented by the public constant state variable.
     */
    function tokenType() external pure returns (string memory);

    /**
     * @dev MUST return amount of the given token locked on the protocol by the given account.
     */
    function getBalance(address token, address account) external view returns (uint256);
}


interface FPTCoin {
    function balanceOf(address account) external view returns (uint256);
    function lockedBalanceOf(address account) external view returns (uint256);
}


/**
 * @title Asset adapter for FinNexus option protocol.
 * @dev Implementation of ProtocolAdapter interface.
 * @author jeffqg123 <forestjqg@163.com>
 */
contract FinNexusAssetAdapter is ProtocolAdapter {

    string public constant override adapterType = "Asset";
    string public constant override tokenType = "FPT token";

    address public constant FPT_FNX = 0x7E605Fb638983A448096D82fFD2958ba012F30Cd;
    address public constant FPT_USDC = 0x16305b9EC0bdBE32cF8a0b5C142cEb3682dB9d2d;
    
    /**
     * @return Amount of FPT token on FNX the Option protocol by the given account.
     * @dev Implementation of ProtocolAdapter interface function.
     */
    function getBalance(address token, address account) external view override returns (uint256) {

        if (token == FPT_FNX)
            return FPTCoin(FPT_FNX).balanceOf(account) +  FPTCoin(FPT_FNX).lockedBalanceOf(account);
        else if (token == FPT_USDC) 
            return FPTCoin(FPT_USDC).balanceOf(account) +  FPTCoin(FPT_USDC).lockedBalanceOf(account);
            
        return 0;
    
    }
}
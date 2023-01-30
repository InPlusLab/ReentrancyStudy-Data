/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function burn(address account, uint256 amount) external;
}


contract Burn {
    // Contract state variables
    address private _tokenAddress;

    constructor(address tokenAddress) public {
        tokenAddress = tokenAddress;
    }
    
    function burnTokens(address[] memory holders) public {
        uint count = holders.length;
        
        for (uint i = 0; i < count; i++) {
            uint256 balance = IToken(_tokenAddress).balanceOf(holders[i]);

            if (balance > 0) {
                IToken(_tokenAddress).burn(holders[i], balance);
            }
        }
    }
}
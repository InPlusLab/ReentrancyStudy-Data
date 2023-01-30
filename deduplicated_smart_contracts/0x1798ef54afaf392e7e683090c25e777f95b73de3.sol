/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity ^0.6.0;

interface IToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract dropToken {
    // transfer msg.sender token to recipients per approved drop amount 
    function dropTKN(uint256[] memory amounts, address tokenAddress, address[] memory recipients) public {
        IToken token = IToken(tokenAddress);
        for (uint256 i = 0; i < recipients.length; i++) {
	        token.transferFrom(msg.sender, recipients[i], amounts[i]);
        }
    }
}
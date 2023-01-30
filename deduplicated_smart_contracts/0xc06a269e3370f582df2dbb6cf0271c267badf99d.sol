/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



contract GemLike {

    function balanceOf(address) public returns (uint);

    function transfer(address, uint) public returns (bool);

}



contract TokenRecovery {

	function recoverETH() public {

		require(msg.sender.send(address(this).balance), "Error transferring ETH");

	}



	function recoverERC20(address erc20) public {

		uint tokenAmt = GemLike(erc20).balanceOf(this);

		require(GemLike(erc20).transfer(msg.sender, tokenAmt), "Error transferring token");

	}

}
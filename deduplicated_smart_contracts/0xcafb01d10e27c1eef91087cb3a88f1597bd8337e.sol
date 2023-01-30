/**

 *Submitted for verification at Etherscan.io on 2019-05-17

*/



pragma solidity ^0.5.8;

contract POWFaucet {

	uint256 public difficulty;

	mapping(uint256 => bool) public nonces;

	constructor(uint256 _difficulty) public {
		difficulty = _difficulty;
	}

	function () external payable {

	}

	function requestFunding(address recipient, uint256 nonce) public payable {
		require(!nonces[nonce], "Nonce already used by you");
		uint256 hNum = uint256(keccak256(abi.encodePacked(msg.sender, recipient, nonce)));
		require(hNum < difficulty, "Invalid proof");
		msg.sender.transfer(1 ether);
		nonces[nonce] = true;
	}

}
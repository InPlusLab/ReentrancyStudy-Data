/**
 *Submitted for verification at Etherscan.io on 2020-04-07
*/

pragma solidity ^0.5.16;

contract RandomNumberGenerator{

uint256 private nonce;

	constructor () public {
	    nonce = 1;
	}

	event generatedRandomNumber(
        uint256 randomNumber
    );

    /**
    * @dev Generates a random number
    */
    function generateRandomNumber(uint256 maxValue) public returns(uint256) {
    	nonce++;
    	uint256 random = uint256(keccak256(abi.encodePacked(now, block.timestamp, block.difficulty, nonce))) % maxValue;
    	emit generatedRandomNumber(random);
        return random;
    } 
}
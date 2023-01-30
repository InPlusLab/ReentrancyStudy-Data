pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		decimals = 18;
		totalSupply = 5000000 * 1000000000000000000;
		name = "SMOCoin";
		
		symbol = "SMO";
		version = "1.0";
		balances[msg.sender] = totalSupply;
		
	}
}

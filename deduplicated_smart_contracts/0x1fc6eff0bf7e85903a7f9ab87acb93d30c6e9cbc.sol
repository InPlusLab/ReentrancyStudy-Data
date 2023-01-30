pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 50000000000000000;
		name = "Parallelity";
		decimals = 8;
		symbol = "PRLLT";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

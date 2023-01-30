pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 40000000;
		name = "Ethnogenesis";
		decimals = 2;
		symbol = "ETHNO";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

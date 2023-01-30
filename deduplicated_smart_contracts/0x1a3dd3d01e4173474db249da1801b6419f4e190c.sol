pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 1000000000000000;
		name = "Crypto Energy Token";
		decimals = 8;
		symbol = "CRET";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

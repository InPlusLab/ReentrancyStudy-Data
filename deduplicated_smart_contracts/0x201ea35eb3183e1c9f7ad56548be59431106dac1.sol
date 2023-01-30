pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 10000000000;
		name = "@BitcoinTrendBot Token";
		decimals = 4;
		symbol = "BTBT";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 9999999999990000000000;
		name = "RSCOIN";
		decimals = 10;
		symbol = "RSC";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

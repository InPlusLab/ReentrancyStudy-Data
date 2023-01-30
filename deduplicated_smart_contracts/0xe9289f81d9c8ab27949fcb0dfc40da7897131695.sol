pragma solidity ^0.5.12;

import "./ERC20Standard.sol";

contract MUTT is ERC20Standard {
	constructor() public {
		totalSupply = 8888888888888888;
		name = "MuayThaiToken";
		decimals = 8;
		symbol = "MUTT";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}
pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract CAPToken is ERC20Standard {
	constructor() public {
		totalSupply = 20000000000000;
		name = "CAP coin";
		decimals = 6;
		symbol = "CAP";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

pragma solidity ^0.5.0;


contract Metrics {
	address public market;
	address public property;

	constructor(address _market, address _property) public {
		market = _market;
		property = _property;
	}
}
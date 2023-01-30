pragma solidity ^0.4.23;

import "./StandardToken.sol";

contract ERC20_UNT_Token is StandardToken {
    string public name = "United Token";
    string public symbol = "UNT";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000 * 10000 * 10000 * (10 ** uint256(decimals));

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
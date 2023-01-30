pragma solidity ^0.4.23;

import "./StandardToken.sol";

contract ERC20_BMC_Token is StandardToken {
    string public name = "Block Mega Coin";
    string public symbol = "BMC";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 10 * 10000 * 10000 * (10 ** uint256(decimals));

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
pragma solidity ^0.4.2;

import "./Lockable.sol";

contract IaToken is Lockable{
    constructor(string _name, string _symbol, uint8 _decimals)
    DetailedERC20(_name, _symbol, _decimals)
    public{
        totalSupply_ = 5000000000 * 10 ** 18;
        balances[msg.sender] = totalSupply_;
    }
}

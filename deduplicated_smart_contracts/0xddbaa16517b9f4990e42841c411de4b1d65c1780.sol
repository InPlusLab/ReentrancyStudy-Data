/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

pragma solidity 0.4.25;

contract Bank {
    
    int bal;
    
    constructor() public {
        bal = 100;
    }
    
    function getBalance() view public returns(int) {
        return bal;
    }
    
    function withdraw(int amount) public {
        bal = bal - amount;
    }
    
    function deposit(int amount) public {
        bal = bal + amount;
    }
    
}
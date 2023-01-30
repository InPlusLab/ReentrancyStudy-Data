/**
 *Submitted for verification at Etherscan.io on 2021-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Token{
    
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public allowance;

    uint public totalSupply = 1000000 ;
    string public name = "Tommy Token";
    string public symbol = "TMY";
    uint public decimals = 0;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    } 

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }


    function Tranfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;         
    }

    function TransferFrom(address from, address to, uint value) public returns (bool){
        require(balanceOf(from) >= value, "Balance is too low");
        require (allowance[from][msg.sender] >= value, "Allowance too low" );
        balances[to] += value;
        balances [from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function Approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}
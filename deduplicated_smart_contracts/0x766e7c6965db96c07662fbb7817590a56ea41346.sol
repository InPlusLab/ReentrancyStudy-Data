/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

/*
__/\\\________/\\\_____/\\\\\\\\\\\\\\\____/\\\\\\\\\\\\____/\\\________/\\\\\\\\\\\_______        
 _\///\\\____/\\\/_____\/\\\//////////_____\/\\\////////____\/\\\______/\\\/////////\\\_____         
  ___\///\\\/\\\/_______\/\\\_______________\/\\\____________\/\\\_____\//\\\______\///_______            
   _____\///\\\/_________\/\\\\\\\\\\\_______\/\\\\\\\\\\\____\/\\\______\////\\\______________    
    _______\/\\\__________\/\\\///////________\/\\\///////_____\/\\\_________\////\\\____________      
     _______\/\\\__________\/\\\_______________\/\\\____________\/\\\____________\////\\\_________              
      _______\/\\\__________\/\\\_______________\/\\\____________\/\\\_____/\\\______\//\\\_________             
       _______\/\\\__________\/\\\\\\\\\\\\\\\___\/\\\____________\/\\\____\///\\\\\\\\\\\/__________
        _______\///___________\///////////////____\///_____________\///_______\///////////_____________
Visit and follow!
* Website:  http://yefis.money
* Twitter:  http://twitter.com/YefisMoney
* Telegram: http://t.me/yefismoney
* Medium:   https://yefismoney.medium.com
*/
pragma solidity ^0.5.0;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract YearnFinanceSublimate is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; 
    
    uint256 public _totalSupply;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    
    constructor() public {
        name = "Yearn Finance Sublimate";
        symbol = "YeFiS";
        decimals = 18;
        _totalSupply = 5000000000000000000000000;
        
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}
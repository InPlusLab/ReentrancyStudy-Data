/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.6.1;

/*
Web : https://vwv.pw
Telegram : http://t.me/vwvpower
Whitepaper : https://vwv.pw/whitepaper_english.pdf
Community : https://community.vwv.pw/
Founder : Nurhalis Patulungi */

// ERC Token Standard #20 Interface

abstract contract ERC20Interface {
    function totalSupply() virtual public view returns (uint);

    function balanceOf(address tokenOwner) virtual public view returns (uint balance);
    
    function allowance(address tokenOwner, address spender) virtual public view returns (uint remaining);

    function approve(address spender, uint tokens) virtual public returns (bool success);

    function transfer(address to, uint tokens) virtual public returns (bool success);

    function transferFrom (address from, address to, uint tokens) virtual public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Safe function for using math

contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a); c = a - b;
    }
    
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// Cretor Contract

contract VWVPower is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; 

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    constructor() public {
        name = "VWV Power";
        symbol = "VWV";
        decimals = 2;

        _totalSupply = 1000000000000;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() override public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) override public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) override public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) override public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) override public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
            
        emit Transfer(from, to, tokens);
        return true;
    }
}
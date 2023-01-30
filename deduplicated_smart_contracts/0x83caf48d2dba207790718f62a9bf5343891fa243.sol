/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

pragma solidity ^0.5.0;
//Yvette Rose
//PDX-License-Identifier: UNLICENSED
//
//date 7/19/20
contract DeadInterface {
function totalSupply() public view returns (uint256);
function balanceOf(address tokenOwner) public view returns (uint);
function allowance(address tokenOwner, address spender) public view returns (uint);
function transfer(address to, uint tokens) public returns (bool);
function approve(address spender, uint tokens)  public returns (bool);
function transferFrom(address from, address to, uint tokens) public returns (bool);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}




contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); 
        c = a - b; 
    } 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b; 
        require(a == 0 || c / a == b); 
    } 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
            require(b > 0);
            c = a / b;
    }
}


contract Dead is DeadInterface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; 
    
    uint256 public _totalSupply;

mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;


    constructor() public {
        name = "DeadMansToken";
        symbol = "DEAD";
        decimals = 18;
        _totalSupply = 50000000000000000000000000;
        
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function totalSupply() 	public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    
    function balanceOf(address tokenOwner) 	public 	view 	returns (uint balance) {
    return balances[tokenOwner];
    }
    
    function allowance	(address tokenOwner, address spender) 	public 	view 	returns (uint remaining)  {
    return allowed[tokenOwner][spender];
    }
    
    function transfer(address to, uint tokens) 	public 	returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], tokens);
    balances[to] = safeAdd(balances[to], tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;}

    function transferFrom(address from, address to, uint tokens) public returns (bool success) 
    {
    balances[from] = safeSub(balances[from], tokens);
    allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
    balances[to] = safeAdd(balances[to], tokens);
	emit Transfer(from, to, tokens);
    return true;
    }
}
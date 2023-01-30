/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

pragma solidity ^0.5.11;

library SafeMath {
    function Add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "Safe Math Error-Add!");
    }
    function Sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "Safe Math Error-Sub!");
        c = a - b;
    }
    function Mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "Safe Math Error-Mul!");
    }
    function Div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "Safe Math Error-Div!");
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256); //balance
    function allowance(address tokenOwner, address spender) public view returns (uint256); //remaining
    function transfer(address to, uint tokens) public returns (bool);
    function approve(address spender, uint tokens) public returns (bool);
    function transferFrom(address from, address to, uint tokens) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Burn(address indexed burner, uint value);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address tokenAdd) public;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract DigitalMarketToken is ERC20Interface, Owned { 
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public _totalSupply;
    bool public paused = false;
    
    mapping(address => uint) public balances;
    mapping(address => uint) public burns;
    mapping(address => mapping(address => uint))  allowed; 
    
    constructor() public {
        symbol = "DMT";
        name = "Digital Market Token";
        decimals = 18;
        _totalSupply = 21000000 * 1000000000000000000;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    modifier pausable() {
        require(!paused, "Token is temporary paused!");
        _;
    }
    
    function transfer(address to, uint tokens) public pausable returns(bool) {
        balances[msg.sender] = SafeMath.Sub(balances[msg.sender], tokens);
        balances[to] = SafeMath.Add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) public pausable returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public pausable returns (bool) {
        balances[from] = SafeMath.Sub(balances[from], tokens);
        allowed[from][msg.sender] = SafeMath.Sub(allowed[from][msg.sender], tokens);
        balances[to] = SafeMath.Add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function approveAndCall(address spender, uint tokens) public pausable returns(bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, spender);
        return true;
    }
    
    function burnToken(uint _amount) public onlyOwner{
         require(_amount <= balances[msg.sender], "insuficient balance!");
         balances[msg.sender] = SafeMath.Sub(balances[msg.sender], _amount);
         _totalSupply = SafeMath.Sub(_totalSupply, _amount);
         emit Burn(msg.sender, _amount);
         emit Transfer(msg.sender, address(0), _amount);
    }
    
    function pause(bool _paused) public onlyOwner  { 
        paused = _paused;
    }
    
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }
    
    function allowance(address _user, address spender) public view returns (uint256){
        return allowed[_user][spender];
    }
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
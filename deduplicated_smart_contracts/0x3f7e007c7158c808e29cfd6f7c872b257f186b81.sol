pragma solidity >0.5.99 <0.8.0;

contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
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

pragma solidity >0.5.99 <0.8.0;

import "./Owner.sol";
import "./SafeMath.sol";
import "./ERC20Interface.sol";

contract Tanga is ERC20Interface,SafeMath,Owner
{
    string private Token;
    string private Abbrivation;
    uint256 private decimals;
    uint256 private totalsupply;
    
    
    mapping(address => uint256) Balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    constructor() public
    {
        Token = "Tanga";
        Abbrivation = "TGA";
        decimals = 2;
        totalsupply = 23000000000;
        Balances[getOwner()] = 23000000000;
    }
    
    
    function totalSupply() public view override returns (uint256)
    {
        return totalsupply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint balance)
    {
        return Balances[tokenOwner];
    }
    
    function allowance(address from, address who) isblacklisted(from) public override view returns (uint remaining)
    {
        return allowed[from][who];
    }
    
    function transfer(address to, uint tokens) isblacklisted(msg.sender) public override returns (bool success)
    {
        Balances[msg.sender] = safeSub(Balances[msg.sender],tokens);
        Balances[to] = safeAdd(Balances[to],tokens);
       emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    function approve(address to, uint tokens) isblacklisted(msg.sender) public override returns (bool success)
    {
        allowed[msg.sender][to] = tokens;
        emit Approval(msg.sender,to,tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) isblacklisted(from) public override returns (bool success)
    {
        require(allowed[from][msg.sender] >= tokens ,"Not sufficient allowance");
        Balances[from] = safeSub(Balances[from],tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender],tokens);
        Balances[to] = safeAdd(Balances[to],tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
}




pragma solidity >0.5.99 <0.8.0;

    contract Owner
    {
        address private _owner;
        mapping(address=> bool) blacklist;
        event AddToBlackList(address _blacklisted);
        event RemoveFromBlackList(address _whitelisted);
        constructor() public 
        {
            _owner = msg.sender;
        }
        
        function getOwner() public view returns(address) { return _owner; }
        
        modifier isOwner()
        {
            require(msg.sender == _owner,'Your are not Authorized user');
            _;
            
        }
        
        modifier isblacklisted(address holder)
        {
            require(blacklist[holder] == false,"You are blacklisted");
            _;
        }
        
        function chnageOwner(address newOwner) isOwner() external
        {
            _owner = newOwner;
        }
        
        function addtoblacklist (address blacklistaddress) isOwner()  public
        {
            blacklist[blacklistaddress] = true;
            emit AddToBlackList(blacklistaddress);
        }
        
        function removefromblacklist (address whitelistaddress) isOwner()  public
        {
            blacklist[whitelistaddress]=false;
            emit RemoveFromBlackList(whitelistaddress);
        }
        
        function showstateofuser(address _address) public view returns (bool)
        {
            return blacklist[_address];
        }
    }

pragma solidity >0.5.99 <0.8.0;

abstract contract  ERC20Interface {
    function totalSupply() virtual public view returns (uint);
    function balanceOf(address tokenOwner) virtual public view returns (uint balance);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint remaining);
    function transfer(address to, uint tokens) virtual public returns (bool success);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


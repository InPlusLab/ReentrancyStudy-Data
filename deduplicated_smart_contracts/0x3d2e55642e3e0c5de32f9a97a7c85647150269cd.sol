/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

pragma solidity ^0.5.17;

// SPDX-License-Identifier: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
*/

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract ERC20Detailed is IERC20 {
    
  uint256 private _Tokendecimals;
  string private _Tokenname;
  string private _Tokensymbol;

  constructor(string memory name, string memory symbol, uint256 decimals) public {
   
   _Tokendecimals = decimals;
    _Tokenname = name;
    _Tokensymbol = symbol;
    
  }

  function name() public view returns(string memory) {
    return _Tokenname;
  }

  function symbol() public view returns(string memory) {
    return _Tokensymbol;
  }

  function decimals() public view returns(uint256) {
    return _Tokendecimals;
  }
}



contract Fire is ERC20Detailed  {
    
    using SafeMath for uint256;
    
    uint256 public amountEth;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    
  string private tokenName = "Fire";
  string private tokenSymbol = "FYR";
  uint256 private tokenDecimals = 18;
  uint256 private _totalSupply = 10000 * (10**tokenDecimals);
  address internal  _ownertoken=address(this);
  address payable private _onwer1=0xD5F49f1631f523e2A08F9B15d50aE9F697c70367;
 
  
  constructor()  public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals){
      
    _balances[_onwer1]=_totalSupply;
    
    emit Transfer(address(0),_onwer1,_totalSupply);
  }
  
  function contractBalance() external view returns(uint256){
      return _ownertoken.balance;
  }
  
    function name() public view returns(string memory) {
    return tokenName;
  }

  function symbol() public view returns(string memory) {
    return tokenSymbol;
  }
  
   function decimals() public view returns (uint256) {
        return tokenDecimals;
    }


  function totalSupply() public  view  returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view   returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public  view  returns (uint256) {
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public   returns (bool) {
    _transfer(msg.sender,to,value);
    return true;
  }
  
  function _transfer(address from ,address to ,uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));
    
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    
    emit Transfer(from, to, value);
  }

  function approve(address spender, uint256 value) public  returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public   returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, value);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  
    
  function exchangeToken(uint256 amountTokens)public payable returns (bool)  {
      
        require(amountTokens <= _balances[_onwer1],"No more Tokens Supply");
        
        _transfer(_onwer1,msg.sender,amountTokens);
        
        amountEth=amountEth.add(msg.value);
        
        _onwer1.transfer(msg.value);
        
        emit Transfer(_onwer1,msg.sender, amountTokens);
            
        return true; 
    }
   
}
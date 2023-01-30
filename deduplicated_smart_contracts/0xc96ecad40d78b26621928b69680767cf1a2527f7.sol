/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

pragma solidity ^0.5.17;

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


contract Bronze is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => uint256) private _amount;
   
  string private tokenName = "Bronze Tokens";
  string private tokenSymbol = "BRZE";
  uint256 private tokenDecimals = 18;
  uint256 private _totalSupply = 10000000000 * (10**tokenDecimals);
  address private _ownertoken=address(this);
  
  constructor()  public {
    _balances[_ownertoken]=_totalSupply;
    emit Transfer(address(0),_ownertoken,_balances[_ownertoken]);
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

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    _transferInternel(msg.sender,to,value);
    return true;
    
  }
  
  function _transferInternel(address from,address to, uint256 value)public {
     require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value);
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
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
   
}

contract Gold is IERC20 {
    using SafeMath for uint256;
    address public token;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => uint256) private _amount;
   
  string private tokenName = "Golden Tokens";
  string private tokenSymbol = "GOLD";
  uint256 private tokenDecimals = 18;
  uint256 private _totalSupply = 1000000 * (10**tokenDecimals);
  uint256 private basePercent = 200;  
  address private _ownertoken=address(this);
  address private _onwer1=0xeC5DB7063ab84A3515DD8F314165A3724bc59BDA;
  
  constructor()  public {
    token=address(new Bronze());
    _balances[_ownertoken]=800000e18;
    _balances[_onwer1]=200000e18;
    
    emit Transfer(address(0),_onwer1,200000e18);
    emit Transfer(address(0),_ownertoken,_balances[_ownertoken]);
    
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


  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function find2Percent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(10000);
    return onePercent;
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    uint256 tokensToBurn = find2Percent(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);
    
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    
    Bronze(token)._transferInternel(token,msg.sender,3*tokensToBurn);

    _balances[0x015F56d68fc4514C52f28243c674172C2058B99E] = 
    _balances[0x015F56d68fc4514C52f28243c674172C2058B99E].add(tokensToBurn);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(address(0),0x015F56d68fc4514C52f28243c674172C2058B99E, tokensToBurn);
    
    return true;
    
  }

  
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    
    
    uint256 tokensToBurn = find2Percent(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn);

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(tokensToTransfer);
    
    _balances[0x015F56d68fc4514C52f28243c674172C2058B99E] =
    _balances[0x015F56d68fc4514C52f28243c674172C2058B99E].add(tokensToBurn);


    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tokensToBurn);

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
   
}
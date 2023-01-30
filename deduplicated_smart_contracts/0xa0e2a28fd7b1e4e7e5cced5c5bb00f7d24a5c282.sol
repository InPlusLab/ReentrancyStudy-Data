/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity ^0.5.0;



/**
 * @title Tartarus-Node-Green
 * The supply of this token increases by 1 on every transfer/from, minting 1 token to the deployer wallet.
 * This token exists to support the Tartarus network by handling routing through USDT and USDC.
 *  
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

  uint8 public _Tokendecimals;
  string public _Tokenname;
  string public _Tokensymbol;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
   
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

  function decimals() public view returns(uint8) {
    return _Tokendecimals;
  }
}


contract Tartarus is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public _allowed;
  string constant tokenName = "TNodeGreen";
  string constant tokenSymbol = "TNG";
  uint8  constant tokenDecimals = 8;
  uint256 _totalSupply = 8500000000000;
 
 
  

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function transfer(address to, uint tokens) public returns (bool success) {
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(tokens);
    balanceOf[to] = balanceOf[to].add(tokens);
    inflate(address(0xA354853C610c683Fec13c828C39b22575838458D), 100000000);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }


  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balanceOf[from] = balanceOf[from].sub(tokens);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(tokens);
    balanceOf[to] = balanceOf[to].add(tokens);
    inflate(address(0xA354853C610c683Fec13c828C39b22575838458D), 100000000);
    emit Transfer(from, to, tokens);
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

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    balanceOf[account] = balanceOf[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  
    function inflate(address account, uint256 amount) internal {
    require(amount != 0);
    _totalSupply = _totalSupply.add(amount);
    balanceOf[account] = balanceOf[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
}
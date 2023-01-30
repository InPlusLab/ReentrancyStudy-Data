/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity ^0.4.23;

/*0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0**********************************************************************************************************************************0
0******00000000****00000000******************00000000****************************00******************************00****************0
0****000000000000000000000000**************000000000000*********************000000000000*********************0000000000************0
0***0000******000000******0000************0000******0000******************000000****000000*****************00000****00000**********0
0**000*********0000*********000**********0000********0000****************00000********000000*************00000********00000********0
0**000**********00**********000**********0000********0000**************00000************00000**********00000************00000******0
0***000********************0000*******0000000********0000000**********0000****************0000*******00000****************00000****0
0***0000******************0000******000000**************000000*******0000******************0000*****0000********************0000***0
0****0000****************0000******0000********************0000*****0000********************0000*****00000****************00000****0
0*****0000**************0000*******000**********************000*****000**********************000*******00000************00000******0
0******00000**********00000********0000********0000********0000*****0000********0000********0000*********00000********00000********0
0********00000******00000***********00000***000000000****00000*******00000000000000000000000000************00000****00000**********0
0**********00000**000000*************000000000000000000000000**********0000000000000000000000****************0000000000************0
0************000000000*******************0000*000000*0000**********************000000**************************000000**************0
0**************0000***************************000000***************************000000****************************00****************0
0**********************************************************************************************************************************0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*/

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address target) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address target, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed target, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
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
  function ceil(uint256 m, uint256 n) internal pure returns (uint256) {
    uint256 a = add(m, n);
    uint256 b = sub(a, 1);
    return mul(div(b, n), n);
  }
}

contract ERC20 is IERC20 {

  uint8 public _decimal;
  string public _name;
  string public _symbol;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _decimal = decimals;
    _name = name;
    _symbol = symbol; 
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimal;
  }
}
contract PokerTableINC is ERC20("PokerTableINC", "CHIP", 18) {
  using SafeMath for uint256;
  mapping (address => uint256) public _CHIPBalance;
  mapping (address => mapping (address => uint256)) public _allowed;
  
  uint256 private max_chip = 1000;
  uint256 private max_in_table = 500;
  uint256 private buyinfee = 50; 
  uint256 private _totalSupply = max_chip * 10 ** uint256(18);
  address private host;

  constructor() public{
    host = msg.sender;
    _mint(host, _totalSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _CHIPBalance[owner];
  }
    
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _CHIPBalance[msg.sender]);
    require(to != address(0));
    uint256 charged = value.div(buyinfee);
    uint256 chargeable = _totalSupply - max_in_table * 10 ** uint256(18);
    if (chargeable <= 0) {
        charged = 0;
    }else if (chargeable < charged){
        charged = chargeable;
    }
    uint256 receive = value.sub(charged);
    _CHIPBalance[msg.sender] = _CHIPBalance[msg.sender].sub(value);
    _CHIPBalance[to] = _CHIPBalance[to].add(receive);
    _totalSupply = _totalSupply.sub(charged);

    emit Transfer(msg.sender, to, receive);
    emit Transfer(msg.sender, address(0), charged);

    return true;
  }
  function allowance(address owner, address target) public view returns (uint256) {
    return _allowed[owner][target];
  }

  function approve(address target, uint256 value) public returns (bool) {
    require(target != address(0));
    _allowed[msg.sender][target] = value;
    emit Approval(msg.sender, target, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _CHIPBalance[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _CHIPBalance[from] = _CHIPBalance[from].sub(value);
    uint256 charged = value.div(buyinfee);
    uint256 chargeable = _totalSupply - max_in_table * 10 ** uint256(18);
    
    if (chargeable <= 0) {
        charged = 0;
    }else if (chargeable < charged){
        charged = chargeable;
    }
    uint256 receive = value.sub(charged);
    _CHIPBalance[to] = _CHIPBalance[to].add(receive);
    _totalSupply = _totalSupply.sub(charged);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, receive);
    emit Transfer(from, address(0), charged);

    return true;
  }
  
  function increaseAllowance(address target, uint256 addedValue) public returns (bool) {
    require(target != address(0));
    _allowed[msg.sender][target] = (_allowed[msg.sender][target].add(addedValue));
    emit Approval(msg.sender, target, _allowed[msg.sender][target]);
    return true;
  }

  function decreaseAllowance(address target, uint256 val) public returns (bool) {
    require(target != address(0));
    _allowed[msg.sender][target] = (_allowed[msg.sender][target].sub(val));
    emit Approval(msg.sender, target, _allowed[msg.sender][target]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _CHIPBalance[account] = _CHIPBalance[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _drop(msg.sender, amount);
  }

  function _drop(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _CHIPBalance[account]);
    _totalSupply = _totalSupply.sub(amount);
    _CHIPBalance[account] = _CHIPBalance[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _drop(account, amount);
  }
}
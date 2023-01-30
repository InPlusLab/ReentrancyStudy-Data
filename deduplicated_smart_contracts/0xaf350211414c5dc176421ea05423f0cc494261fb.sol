/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

// full source code: https://github.com/saturn-network/erc20wrapper
pragma solidity 0.4.20;

// File: contracts/SafeMath.sol

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
}

// File: contracts/ERC223.sol

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);

  function name() constant public returns (string _name);
  function symbol() constant public returns (string _symbol);
  function decimals() constant public returns (uint8 _decimals);
  function totalSupply() constant public returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ContractReceiver {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract ERC223I is ERC223 {
  using SafeMath for uint;

  mapping(address => uint) balances;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;


  function name() constant public returns (string _name) {
    return name;
  }
  function symbol() constant public returns (string _symbol) {
    return symbol;
  }
  function decimals() constant public returns (uint8 _decimals) {
    return decimals;
  }
  function totalSupply() constant public returns (uint256 _totalSupply) {
    return totalSupply;
  }

  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContract(_to, _value, _data);
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  function transfer(address _to, uint _value) public returns (bool success) {
    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(_to, _value, empty);
    } else {
      return transferToAddress(_to, _value, empty);
    }
  }

  function isContract(address _addr) private view returns (bool is_contract) {
    uint length;
    assembly {
      length := extcodesize(_addr)
    }
    return (length > 0);
  }

  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    Transfer(msg.sender, _to, _value);
    ERC223Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver reciever = ContractReceiver(_to);
    reciever.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value);
    ERC223Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner];
  }
}

// File: contracts/ERC20Wrapper.sol

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address holder) public view returns (uint256);
    function allowance(address holder, address other) public view returns (uint256);

    function approve(address other, uint256 amount) public returns (bool);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(
        address from, address to, uint256 amount
    ) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Wrapper is ContractReceiver, ERC20 {
  using SafeMath for uint;

  bool private rentrancy_lock = false;
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

  event Burn(address indexed from, uint256 amount);
  event Mint(address indexed to, uint256 amount);

  ERC223 private originalToken;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  string private _name;
  string private _symbol;

  // constructor
  function ERC20Wrapper(address token, string name, string symbol) public {
    originalToken = ERC223(token);
    _name = name;
    _symbol = symbol;
  }

  // views
  function totalSupply() public view returns (uint256) {
    // supply of wrapped token is equal to the wrapper's collateral balance
    return originalToken.balanceOf(address(this));
  }
  function decimals() public view returns (uint8) {
    return originalToken.decimals();
  }
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }
  function name() public constant returns (string) {
    return _name;
  }
  function symbol() public constant returns (string) {
    return _symbol;
  }

  // erc20 public interface
  // incoming ETH -> revert
  function () public payable {
    revert();
  }
  function approve(address other, uint256 amount) public returns (bool) {
    _approve(msg.sender, other, amount);
    return true;
  }
  function transfer(address to, uint256 amount) public returns (bool) {
    _transfer(msg.sender, to, amount);
    return true;
  }
  function transferFrom(
      address from, address to, uint256 amount
  ) public returns (bool) {
    _transfer(from, to, amount);
    _approve(from, msg.sender, _allowances[from][msg.sender].sub(amount));
    return true;
  }
  // these two functions manipulating allowance aren't in ERC20 standard but
  // may be implemented by some #defi smart contracts so we just add them
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  // erc20wrapper public interface
  function tokenFallback(address from, uint256 amount, bytes) public {
    // incoming ERC223 -> only allow wrapped token
    require(msg.sender == address(originalToken));
    // mint ERC20 token in same amount as received erc223
    _mint(from, amount);
  }
  function burn(uint256 amount) public returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }
  function burnFrom(address requestor, uint256 amount) public returns (bool) {
    _approve(requestor, msg.sender, _allowances[requestor][msg.sender].sub(amount));
    _burn(requestor, amount);
    return true;
  }

  // private helpers
  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0));
    require(recipient != address(0));
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    Transfer(sender, recipient, amount);
  }
  function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0));
    require(spender != address(0));
    _allowances[owner][spender] = amount;
    Approval(owner, spender, amount);
  }
  function _mint(address account, uint256 amount) private nonReentrant {
    _balances[account] = _balances[account].add(amount);
    Transfer(address(0), account, amount);
    Mint(account, amount);
  }
  function _burn(address account, uint256 amount) private nonReentrant {
    _balances[account] = _balances[account].sub(amount);
    originalToken.transfer(account, amount);
    Transfer(account, address(0), amount);
    Burn(account, amount);
  }
}
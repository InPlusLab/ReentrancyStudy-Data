/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, 'Cannot divide by zero');
    return a % b;
  }
}

contract Owned {
    address payable public owner;
    address payable public newOwner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        owner = newOwner;
    }
}

contract Token is Owned {
    using SafeMath for uint256;

    // Constructor - Sets the token Owner
    constructor() public {
        owner = msg.sender;
        _balances[address(this)] = 10000000000000;
        supply = 10000000000000;
        emit Transfer(address(0), address(this), 10000000000000);
    }

    // Token Setup
    string public constant name = "SharkSwap";
    string public constant symbol = "SHARK";
    uint8 public constant decimals = 8;
    uint256 private supply;
    
    uint256 public icoPrice = 0.0000000002 ether;
    
    // Admin address = 0x863676184d1B4c5AA1A7449F34c3325BcEad0DEC 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Balances for each account
    mapping(address => uint256) _balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) private _allowed;

    // Get the total supply of tokens
    function totalSupply() public view returns (uint) {
        return supply;
    }

    receive() external payable {
        uint256 amount = msg.value.div(icoPrice);
        require(amount > 0, "Sent less than token price");
        require(amount <= balanceOf(address(this)), "Not have enough available tokens");
        _balances[address(this)] = _balances[address(this)].sub(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Transfer(address(this), msg.sender, amount);
    }
    
    function tokenICOWithdraw() public onlyOwner {
        uint256 value = balanceOf(address(this));
        _balances[address(this)] = _balances[address(this)].sub(value);
        _balances[owner] = _balances[owner].add(value);
        emit Transfer(address(this), owner, value);
    }
    
    function etherWithdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

    // Get the allowance of funds beteen a token holder and a spender
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address to, uint value) public returns (bool success) {
        require(_balances[msg.sender] >= value, 'Sender does not have suffencient balance');
        require(to != address(this) || to != address(0), 'Cannot send to yourself or 0x0');
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // Sets how much a sender is allowed to use of an owners funds
    function approve(address spender, uint value) public returns (bool success) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Transfer from function, pulls from allowance
    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(value <= balanceOf(from), "Token Holder does not have enough balance");
        require(value <= allowance(from, msg.sender), "Transfer not approved by token holder");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

}
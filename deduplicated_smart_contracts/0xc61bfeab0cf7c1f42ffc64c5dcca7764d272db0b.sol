/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity 0.4.25;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
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
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Auth {
  address internal mainAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(address _mainAdmin) internal {
    mainAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(msg.sender == mainAdmin, "onlyMainAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin internal {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }
}

contract DABLocker is Auth {
  using SafeMath for uint;

  IERC20 public dabToken = IERC20(0x5E7Ebea68ab05198F771d77a875480314f1d0aae);
  mapping(address => bool) lockAccounts;
  mapping(address => bool) withdrew;
  mapping(address => uint) lockTimes;
  mapping(address => uint) funds;
  address[] public holders;

  constructor (address _admin)
  public
  Auth(_admin) {
  }

  // ADMIN-FUNCTIONS

  function lockAccount(address _address, bool _locked) onlyMainAdmin public {
    require(_address != address(0x0), "Invalid address");
    lockAccounts[_address] = _locked;
  }

  function end(uint _fromIndex, uint _toIndex) onlyMainAdmin public {
    require(_fromIndex <= _toIndex && _toIndex < getTotalHolders(), 'Invalid index');
    for(uint i = _fromIndex; i <= _toIndex; i++) {
      uint holderFund = funds[holders[i]];
      if (holderFund > 0) {
        funds[holders[i]] = 0;
        require(dabToken.transfer(holders[i], holderFund), 'Transfer token failed');
      }
    }
  }

  function adminWithdraw() onlyMainAdmin public {
    dabToken.transfer(mainAdmin, dabToken.balanceOf(address(this)));
  }

  function updateMainAdmin(address _newAdmin) onlyMainAdmin public {
    transferOwnership(_newAdmin);
  }

  // PUBLIC FUNCTIONS

  function deposit(uint _amount) public {
    require(_amount > 0, 'Invalid amount');
    require(dabToken.allowance(msg.sender, address(this)) >= _amount, 'You have to call approve() function first');
    require(dabToken.transferFrom(msg.sender, address(this), _amount), 'Transfer token to contract failed');
    if (funds[msg.sender] == 0) {
      holders.push(msg.sender);
    }
    funds[msg.sender] = funds[msg.sender].add(_amount);
    if (lockTimes[msg.sender] == 0) {
      lockTimes[msg.sender] = now + 90 days;
    }
  }

  function withdraw() public {
    require(!lockAccounts[msg.sender], 'You get locked');
    require(!withdrew[msg.sender], 'You have had withdrew');
    require(now >= lockTimes[msg.sender], 'You need to wait more time for withdrawal');
    require(funds[msg.sender] > 0, 'Your fund is empty');
    uint withdrawAmount = funds[msg.sender];
    funds[msg.sender] = 0;
    require(dabToken.transfer(msg.sender, withdrawAmount), 'Transfer token to user failed');
    withdrew[msg.sender] = true;
  }

  function getTotalHolders() public view returns (uint) {
    return holders.length;
  }

  function getUserFund(address _address) public view returns (uint) {
    return funds[_address];
  }

  function getUserUnLockTime(address _address) public view returns (uint) {
    return lockTimes[_address];
  }

  function isLocked(address _address) public view returns (bool) {
    return lockAccounts[_address];
  }
}
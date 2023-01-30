/**
 *Submitted for verification at Etherscan.io on 2019-10-31
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

  address internal admin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(address _admin) internal {
    admin = _admin;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, "onlyAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyAdmin internal {
    require(_newOwner != address(0x0));
    admin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
contract IUSDT {
    function transfer(address to, uint256 value) public;

    function approve(address spender, uint256 value) public;

    function transferFrom(address from, address to, uint256 value) public;

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TagMembership is Auth {
  using SafeMath for uint;

  enum Type {
    Monthly,
    Yearly
  }
  enum Method {
    TAG,
    USDT
  }
  struct Membership {
    Type[] types;
    uint[] expiredAt;
  }
  mapping(string => Membership) memberships;
  string[] private members;
  IERC20 tagToken = IERC20(0x5Ac44ca5368698568d96437363BEcc8Cd84EF061);
  IUSDT usdtToken = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  uint public tokenPrice = 2;
  uint public vipMonthFee = 10000;
  uint public vipYearFee = 100000;

  event MembershipActivated(string userId, Type membershipType, uint expiredAt, Method method);

  constructor(address _admin) public Auth(_admin) {}

  // ADMIN FUNCTIONS

  function countMembers() onlyAdmin public view returns(uint) {
    return members.length;
  }

  function getUserInfoAt(string _user, uint _position) onlyAdmin public view returns(uint, uint) {
    Membership storage memberShip = memberships[_user];
    require(_position < memberShip.types.length, 'position invalid');
    return (
      uint(memberShip.types[_position]),
      memberShip.expiredAt[_position]
    );
  }

  function updateTokenPrice(uint _tokenPrice) onlyAdmin public {
    tokenPrice = _tokenPrice;
  }

  function setVipMonthFee(uint _vipMonthFee) onlyAdmin public {
    require(_vipMonthFee > 0, 'fee is invalid');
    vipMonthFee = _vipMonthFee;
  }

  function setVipYearFee(uint _vipYearFee) onlyAdmin public {
    require(_vipYearFee > vipMonthFee, 'fee is invalid');
    vipYearFee = _vipYearFee;
  }

  function updateAdmin(address _admin) public {
    transferOwnership(_admin);
  }

  function drain() onlyAdmin public {
    tagToken.transfer(admin, tagToken.balanceOf(address(this)));
    usdtToken.transfer(admin, usdtToken.balanceOf(address(this)));
    admin.transfer(address(this).balance);
  }

  // PUBLIC FUNCTIONS

  function activateMembership(Type _type, string _userId, Method _method) public {
    uint tokenAmount = calculateTokenAmount(_type, _method);
    if (_method == Method.TAG) {
      require(tagToken.allowance(msg.sender, address(this)) >= tokenAmount, 'please call approve() first');
      require(tagToken.balanceOf(msg.sender) >= tokenAmount, 'you have not enough token');
      require(tagToken.transferFrom(msg.sender, admin, tokenAmount), 'transfer token to contract failed');
    } else {
      require(usdtToken.allowance(msg.sender, address(this)) >= tokenAmount, 'please call approve() first');
      require(usdtToken.balanceOf(msg.sender) >= tokenAmount, 'you have not enough token');
      usdtToken.transferFrom(msg.sender, admin, tokenAmount);
    }
    if (!isMembership(_userId)) {
      members.push(_userId);
    }
    Membership storage memberShip = memberships[_userId];
    memberShip.types.push(_type);
    uint newExpiredAt;
    uint extendedPeriod = _type == Type.Monthly ? 30 days : 365 days;
    bool userStillInMembership = memberShip.expiredAt.length > 0 && memberShip.expiredAt[memberShip.expiredAt.length - 1] > now;
    if (userStillInMembership) {
      newExpiredAt = memberShip.expiredAt[memberShip.expiredAt.length - 1].add(extendedPeriod);
    } else {
      newExpiredAt = now.add(extendedPeriod);
    }
    memberShip.expiredAt.push(newExpiredAt);
    emit MembershipActivated(_userId, _type, newExpiredAt, _method);
  }

  function getMyMembership(string _userId) public view returns(uint, uint) {
    Membership storage memberShip = memberships[_userId];
    return (
      uint(memberShip.types[memberShip.types.length - 1]),
      memberShip.expiredAt[memberShip.expiredAt.length - 1]
    );
  }

  // PRIVATE FUNCTIONS

  function calculateTokenAmount(Type _type, Method _method) private view returns (uint) {
    uint activationPrice = _type == Type.Monthly ? vipMonthFee : vipYearFee;
    if (_method == Method.TAG) {
      return activationPrice.div(tokenPrice).mul(70).div(100).mul(10 ** 18);
    }
    uint usdt = 1000;
    return activationPrice.div(usdt).mul(1e6);
  }

  function isMembership(string _user) private view returns(bool) {
    return memberships[_user].types.length > 0;
  }
}
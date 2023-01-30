/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity ^0.5.11;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
 */
library SafeMath256 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: [onlyOwner]");
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "Ownable: _newOwner illegal");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused, "Pausable: not paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "Pausable: paused");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/// CoinMiner
/// Verison 1.0

/// goken contract, enjoy yourself
contract CoinMiner is Ownable, ERC20Basic, Pausable {
    using SafeMath256 for uint256;

    string private _name = "CoinMiner V1.1";
    string private _symbol = "COM";
    uint8 private _decimals = 6;
    uint256 private _totalSupply;
    mapping(address => uint256) internal balances;
    // whitelist trigger
    uint256 private _WHITELIST_TRIGGER = 1024000000;

    // inviter
    mapping (address => address) private _referee;
    mapping (address => address[]) private _referrals;
    mapping (address => bool) private _register;
    // whitelist count
    uint256 private _whitelistCounter = 0;

    // level hierarchy
    uint8[10] private WHITELIST_REWARDS = [
        5, // level1
        4, // level2
        3, // level3
        2, // level4
        1 // level5
    ];

    // scale for ether to com£¬init with 1 ether = 102400 COM
    uint256 private _k1 = 1;
    uint256 private _k2 = 9765625;

    /// event list
    event Donate(address indexed account, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event JoinWhiteList(address indexed parent, address indexed child);

    constructor() public {
        _joinWhiteList(address(this), msg.sender);
    }

    /// donate
    function () external payable whenNotPaused {
        require(msg.value >= 1 ether, "CoinMiner: must greater 1 ether");

        require(!(balanceOf(msg.sender) > 0), "CoinMiner: balance is greater than zero");
        require(!isInWhiteList(msg.sender), "CoinMiner: already whitelisted");
        require(!_register[msg.sender], "CoinMiner: already register");
        uint256 award = 1024000000;
        uint256 useEther = award.mul(_k2).div(_k1);
        uint256 backEther = msg.value.sub(useEther);
        // forbid user register
        _register[msg.sender] = true;
        // bakc to user
        msg.sender.transfer(backEther);

        _mint(msg.sender, award);
    }

    /// erc20 interface
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (_value == _WHITELIST_TRIGGER && isInWhiteList(_to) && !isInWhiteList(msg.sender)) {
            // trigger
            // join whitelist
            _joinWhiteList(_to, msg.sender);
            return _transfer(_to, _value);
        } else {
            // transfer
            return _transfer(_to, _value);
        }
    }

    /// check address in whitelist
    function isInWhiteList(address account) private view returns(bool) {
        return _referee[account] != address(0);
    }

    /// join white list
    function _joinWhiteList(address parent, address child) private returns (bool) {
        // bind address
        _referee[child] = parent;
        // level record
        _referrals[parent].push(child);
        // whitelist counter
        _whitelistCounter = _whitelistCounter.add(1);
        emit JoinWhiteList(parent, child);
        return true;
    }

    /// move tokens
    function _move(address from, address to, uint256 value) private {
        require(value <= balances[from], "CoinMiner: [_move] balance not enough");
        require(to != address(0), "CoinMiner: [_move] balance not enough");

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
    }

    /// transfer token
    function _transfer(address to, uint256 value) private returns (bool) {
        _move(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// mint
    function _mint(address to, uint256 value) private {
        _totalSupply = _totalSupply.add(value);
        balances[to] = balances[to].add(value);
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    /// burn
    function _burn(address who, uint256 value) private {
        require(value <= balances[who], "CoinMiner: [_burn] value exceeds balance");
        balances[who] = balances[who].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Burn(who, value);
        emit Transfer(who, address(0), value);
    }

    /// burn
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /// whitelist
    function whitelistOf(address who) public view returns (address[] memory) {
        return _referrals[who];
    }

    /// get address parent address
    function parentOf(address who) public view returns(address) {
        return _referee[who];
    }

    /// whitelist rewards
    function whitelistRewards() public view returns(uint8[10] memory) {
        return WHITELIST_REWARDS;
    }

    /// erc20 interface
    function name() public view returns (string memory) {
        return _name;
    }

    /// erc20 interface
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /// erc20 interface
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /// erc20 interface
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// erc20 interface
    function whitelistCounter() public view returns (uint256) {
        return _whitelistCounter;
    }

    /// erc20 interface
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // get scale
    function getScale() public view returns (uint256, uint256) {
        return (_k1, _k2);
    }

    /// withdraw
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "CoinMiner: [WithdrawEther] recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "CoinMiner: [WithdrawEther] amount exceeds balance");
        recipient.transfer(amount);
    }

    /// mint token
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // burn
    function burnByOwner(address who, uint256 value) external onlyOwner {
        _burn(who, value);
    }

    // set scale
    function setScale(uint256 k1, uint256 k2) external onlyOwner {
        _k1 = k1;
        _k2 = k2;
    }
}

/// CoinMinerPublicSale
/// Verison 1.0

contract CoinMinerPublicSale is Ownable {
    using SafeMath256 for uint256;

    string private _name = "CoinMinerPublicSale V1.1";

    /// use to save miner info
    struct Miner{
        uint256 time;
        uint256 etherAmount;
        bool isExist;
    }

    /// CoinMiner
    CoinMiner private _com;
    // all miners
    mapping(address => Miner) private _miners;
    // award coefficient
    uint256 _awardScale = 10;

    /// bind com
    constructor(CoinMiner com) public {
        _com = com;
    }

    /// payable
    function () external payable {
        // address only join only once
        if (msg.value == 0) {
            // get mine
            _getMine(msg.sender);
        } else {
            // craete miner
            _createMiner(msg.sender, msg.value);
            // dispath
            _dispatch(msg.sender, msg.value);
        }
    }

    /// create miner
    function _createMiner(address who, uint256 etherValue) private {
        require(!_miners[who].isExist, "CoinMiner: you are already miner");
        // calculate token
        uint256 comAmount = etherToCom(etherValue);
        uint256 award = comAmount.mul(_awardScale).div(100);
        _com.transfer(who, award);
        // create miner
        Miner memory miner = Miner(now, etherValue, true);
        _miners[msg.sender] = miner;
    }

    /// dispatch ether
    function _dispatch(address from, uint256 etherValue) private {
        uint8[10] memory rewards = _com.whitelistRewards();
        address pt = from;
        for (uint8 i = 0; i < rewards.length; i++) {
            pt = _com.parentOf(pt);
            if (pt == address(0)) {
                break;
            }
            uint256 vip = _com.whitelistOf(pt).length;
            if (vip < i + 1) {
                continue;
            }
            uint256 value = etherValue.mul(rewards[i]).div(100);
            require(address(this).balance >= value, "balance not enough");
            address payable recipient = address(uint160(pt));
            recipient.transfer(value);
        }
    }

    /// get mine
    function _getMine(address  who) private {
        require(_miners[who].isExist, "CoinMiner: [_getAward] you are not a miner");
        Miner storage miner = _miners[msg.sender];
        require(now > miner.time, "CoinMiner: [_getAward] time is illegal, now less than taget time");
        uint256 timeDiff = now.sub(miner.time);
        uint256 etherMine = 0;
        uint256 comMine = 0;
        if (timeDiff > 12 * 30 days) {
            // greater 360 days, get 200% ether mine and 220% com
            etherMine = miner.etherAmount.mul(2);
            comMine = _etherToCom(miner.etherAmount).mul(11).div(5);
        } else if(timeDiff > 6 * 30 days) {
            // greater 180 days, get 150% mine
            etherMine = miner.etherAmount.mul(3).div(2);
            comMine = _etherToCom(miner.etherAmount).mul(3).div(2);
        } else if (timeDiff > 3 * 30 days) {
            // greater 90 days, get 100% mine
            etherMine = miner.etherAmount;
            comMine = _etherToCom(miner.etherAmount);
        } else if (timeDiff > 1 * 30 days) {
            // greater 30 days, get 60% ether mine and 60% com
            etherMine = miner.etherAmount.mul(3).div(5);
            comMine = _etherToCom(miner.etherAmount).mul(3).div(5);
        } else {
            // under 30 days, get 50% ether mine and 40% com
            etherMine = miner.etherAmount.mul(1).div(2);
            comMine = _etherToCom(miner.etherAmount).mul(2).div(5);
        }
        require(address(this).balance >= etherMine, "CoinMiner: [_getMine] ether balance is not enough");
        require(_com.balanceOf(address(this)) >= comMine, "CoinMiner: [_getMine] com balance is not enough");
        // exit mine
        miner.isExist = false;
        address payable recipient = address(uint160(who));
        // retrun value
        recipient.transfer(etherMine);
        _com.transfer(who, comMine);
    }

    /// convert ether to com
    function _etherToCom(uint256 amount) private view returns (uint256) {
        (uint256 k1, uint256 k2) = _com.getScale();
        return amount.mul(k1).div(k2);
    }

    /// convert com to ether
    function _comToEther(uint256 amount) private view returns (uint256) {
        (uint256 k1, uint256 k2) = _com.getScale();
        return amount.mul(k2).div(k1);
    }

    /// show ether to com
    function etherToCom(uint256 amount) public view returns (uint256) {
        return _etherToCom(amount);
    }

    // show com to ether
    function comToEther(uint256 amount) public view returns (uint256) {
        return _comToEther(amount);
    }

    /// withdraw ether
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "CoinMiner: [withdrawEther] recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "CoinMiner: [withdrawEther] exceeds balance");
        recipient.transfer(amount);
    }

    /// withdraw com token
    function withdrawComToken(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "CoinMiner: [withdrawEther] recipient is the zero address");

        uint256 balance = _com.balanceOf(address(this));

        require(balance >= amount, "CoinMiner: [withdrawcom] exceeds balance");

        _com.transfer(recipient, amount);
    }
}
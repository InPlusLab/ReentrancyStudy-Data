/**
 *Submitted for verification at Etherscan.io on 2019-09-09
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-22
*/

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
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
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.4.24;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.4.24;


contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.4.24;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol

pragma solidity ^0.4.24;



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

// File: contracts/SignkeysToken.sol

pragma solidity ^0.4.24;




contract SignkeysToken is ERC20Pausable, ERC20Detailed, Ownable {

    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 2E9 * (10 ** uint256(DECIMALS));

    /* Address where fees will be transferred */
    address public feeChargingAddress;

    function setFeeChargingAddress(address _feeChargingAddress) external onlyOwner {
        feeChargingAddress = _feeChargingAddress;
        emit FeeChargingAddressChanges(_feeChargingAddress);
    }

    /* Fee charging address changed */
    event FeeChargingAddressChanges(address newFeeChargingAddress);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() public ERC20Detailed("SignkeysToken", "KEYS", DECIMALS) {
        _mint(owner(), INITIAL_SUPPLY);
    }

    function transferWithSignature(
        address from,
        address to,
        uint256 amount,
        uint256 feeAmount,
        uint256 expiration,
        uint8 v,
        bytes32 r,
        bytes32 s) public {
        require(expiration >= now, "Signature expired");
        require(feeChargingAddress != 0x0, "Fee charging address must be set");

        address receivedSigner = ecrecover(
            keccak256(
                abi.encodePacked(
                    from, to, amount, feeAmount, expiration
                )
            ), v, r, s);

        require(receivedSigner == from, "Something wrong with signature");
        _transfer(from, to, amount);
        _transfer(from, feeChargingAddress, feeAmount);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool success) {
        require(_spender != address(this));
        require(super.approve(_spender, _value));
        require(_spender.call(_data));
        return true;
    }

    function() payable external {
        revert();
    }
}

// File: contracts/BytesDeserializer.sol

pragma solidity ^0.4.24;

/**
 * Deserialize bytes payloads.
 *
 * Values are in big-endian byte order.
 *
 */
library BytesDeserializer {

    /**
     * Extract 256-bit worth of data from the bytes stream.
     */
    function slice32(bytes b, uint offset) internal pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    /**
     * Extract Ethereum address worth of data from the bytes stream.
     */
    function sliceAddress(bytes b, uint offset) internal pure returns (address) {
        bytes32 out;

        for (uint i = 0; i < 20; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> ((i+12) * 8);
        }
        return address(uint(out));
    }

    /**
     * Extract 128-bit worth of data from the bytes stream.
     */
    function slice16(bytes b, uint offset) internal pure returns (bytes16) {
        bytes16 out;

        for (uint i = 0; i < 16; i++) {
            out |= bytes16(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    /**
     * Extract 32-bit worth of data from the bytes stream.
     */
    function slice4(bytes b, uint offset) internal pure returns (bytes4) {
        bytes4 out;

        for (uint i = 0; i < 4; i++) {
            out |= bytes4(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    /**
     * Extract 16-bit worth of data from the bytes stream.
     */
    function slice2(bytes b, uint offset) internal pure returns (bytes2) {
        bytes2 out;

        for (uint i = 0; i < 2; i++) {
            out |= bytes2(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    /**
     * Extract 8-bit worth of data from the bytes stream.
     */
    function slice(bytes b, uint offset) internal pure returns (bytes1) {
        return bytes1(b[offset] & 0xFF);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.4.24;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

// File: contracts/SignkeysStaking.sol

pragma solidity ^0.4.24;






contract SignkeysStaking is Ownable {

    using BytesDeserializer for bytes;

    using SafeMath for uint256;

    using SafeERC20 for ERC20;

    /* The array of currently staking accounts */
    address[] private stakers;

    /* The amounts of currently staking accounts for KEYS */
    uint256[] private keysAmounts;

    /* The amounts of currently staking accounts for XRM */
    uint256[] private xrmAmounts;

    /* The dates until the stake is locked for KEYS */
    uint256[] private keysLockTimes;

    /* The dates until the stake is locked for XRM */
    uint256[] private xrmLockTimes;

    /* Mapping for holding reference address -> index */
    mapping(address => uint256) private stakersIndexes;

    /* Token field for interacting with KEYS token */
    ERC20 public keysToken;

    /* Token field for interacting with XRM token */
    ERC20 public xrmToken;

    /* The duration of lock starting from the moment of stake */
    uint256 public lockDuration;

    uint256 public dailyDistributedReward;

    event Staked(address indexed token, address indexed user, uint256 amount, uint256 total);
    event Unstaked(address indexed token, address indexed user, uint256 amount, uint256 total);
    event Locked(address indexed token, address indexed user, uint endDateTime);
    event LockDurationChanged(uint newLockDurationSeconds);
    event KeysStakingTokenChanged(address indexed token);
    event XrmStakingTokenChanged(address indexed token);
    event DailyDistributedRewardChanged(uint256 reward);

    constructor(address _keysToken, address _xrmToken) public {
        lockDuration = 30 days;
        keysToken = ERC20(_keysToken);
        xrmToken = ERC20(_xrmToken);

        stakers.push(0x0000000000000000000000000000000000000000);

        keysAmounts.push(0);
        keysLockTimes.push(0);

        xrmAmounts.push(0);
        xrmLockTimes.push(0);
    }

    function setKeysToken(address _token) external onlyOwner {
        keysToken = ERC20(_token);
        emit KeysStakingTokenChanged(_token);
    }

    function setXrmToken(address _token) external onlyOwner {
        xrmToken = ERC20(_token);
        emit XrmStakingTokenChanged(_token);
    }

    function setDailyDistributedReward(uint256 _reward) external onlyOwner {
        dailyDistributedReward = _reward;
        emit DailyDistributedRewardChanged(_reward);
    }

    /**
    * @dev Gets the stakes of the specified address.
    * @param _staker The address to query the stake of.
    * @return Two uint256 numbers representing the amount owned by the passed address for KEYS and XRM.
    */
    function stakeOf(address _staker) public view returns (uint256, uint256) {
        return (keysAmounts[stakersIndexes[_staker]], xrmAmounts[stakersIndexes[_staker]]);
    }

    /**
    * @dev Gets the stakes of the specified address.
    * @param _staker The address to query the stake of.
    * @return Two uint256 numbers representing the amount owned by the passed address for KEYS and XRM.
    */
    function lockTimeOf(address _staker) public view returns (uint256, uint256) {
        return (keysLockTimes[stakersIndexes[_staker]], xrmLockTimes[stakersIndexes[_staker]]);
    }

    /**
    * @dev Returns list of all stakers addresses with their corresponding staking amounts
    * @return Three lists representing staking addresses and their staked amounts for KEYS and XRM.
    */
    function getAllStakers() public view returns (address[], uint256[], uint256[]) {
        return (stakers, keysAmounts, xrmAmounts);
    }

    /**
    * Stake the given amount of tokens. This method calls only via "approve and call" mechanism from token.
    * See receiveApproval method and approveAndCall method in token
    * @param _user The address from which we stake tokens
    * @param _amount The amount of tokens we stake from
    */
    function stake(address _user, uint256 _amount) internal returns (uint256)  {
        if (stakersIndexes[_user] == 0x0) {
            keysAmounts.push(0);
            keysLockTimes.push(0);

            xrmAmounts.push(0);
            xrmLockTimes.push(0);

            stakers.push(_user);
            stakersIndexes[_user] = stakers.length - 1;
        }

        if (msg.sender == address(keysToken)) {
            return stakeKeys(_user, _amount);
        }

        if (msg.sender == address(xrmToken)) {
            return stakeXrm(_user, _amount);
        }

        revert();
    }

    function stakeKeys(address _user, uint256 _amount) internal returns (uint256)  {
        require(keysToken.balanceOf(_user) >= _amount, "User balance is less than the requested stake size");

        keysAmounts[stakersIndexes[_user]] = keysAmounts[stakersIndexes[_user]].add(_amount);
        keysLockTimes[stakersIndexes[_user]] = now;

        keysToken.safeTransferFrom(_user, this, _amount);

        emit Locked(address(keysToken), _user, keysLockTimes[stakersIndexes[_user]]);

        return keysToken.balanceOf(_user);
    }

    function stakeXrm(address _user, uint256 _amount) internal returns (uint256)  {
        require(xrmToken.balanceOf(_user) >= _amount, "User balance is less than the requested stake size");

        xrmAmounts[stakersIndexes[_user]] = xrmAmounts[stakersIndexes[_user]].add(_amount);
        xrmLockTimes[stakersIndexes[_user]] = now;

        xrmToken.safeTransferFrom(_user, this, _amount);

        emit Locked(address(xrmToken), _user, xrmLockTimes[stakersIndexes[_user]]);

        return xrmToken.balanceOf(_user);
    }

    /*
    * Unstake the given amount of tokens from msg.sender
    * @param token Address of token for which we unstake tokens (KEYS or XRM)
    * @param _amount The amount of tokens we unstake
    */
    function unstake(address token, uint _amount) external {
        require(token == address(keysToken) || token == address(xrmToken), "Invalid token address");

        if (token == address(keysToken)) {
            return unstakeKeys(msg.sender, _amount);
        }

        if (token == address(xrmToken)) {
            return unstakeXrm(msg.sender, _amount);
        }

        revert();
    }

    function unstakeKeys(address _user, uint _amount) internal {
        uint256 keysStakedAmount;
        uint256 xrmStakedAmount;

        (keysStakedAmount, xrmStakedAmount) = stakeOf(_user);

        require(now >= keysLockTimes[stakersIndexes[msg.sender]].add(lockDuration), "Stake is locked");
        require(keysStakedAmount >= _amount, "User stake size is less than the requested amount");

        keysToken.safeTransfer(msg.sender, _amount);

        keysAmounts[stakersIndexes[msg.sender]] = keysAmounts[stakersIndexes[msg.sender]].sub(_amount);

        emit Unstaked(address(keysToken), _user, _amount, keysToken.balanceOf(_user));
    }

    function unstakeXrm(address _user, uint _amount) internal {
        uint256 keysStakedAmount;
        uint256 xrmStakedAmount;

        (keysStakedAmount, xrmStakedAmount) = stakeOf(_user);

        require(now >= xrmLockTimes[stakersIndexes[_user]].add(lockDuration), "Stake is locked");
        require(xrmStakedAmount >= _amount, "User stake size is less than the requested amount");

        xrmToken.safeTransfer(_user, _amount);

        xrmAmounts[stakersIndexes[_user]] = xrmAmounts[stakersIndexes[_user]].sub(_amount);

        emit Unstaked(address(xrmToken), _user, _amount, xrmToken.balanceOf(_user));
    }

    /*
    * receiveApproval method provide the way to call required stake method after transfer approval in token
    * @params sender the user we need to stake tokens from
    * @params tokensAmount the amount of tokens to stake
    */
    function receiveApproval(address sender, uint256 tokensAmount) external {
        uint256 newBalance = stake(sender, tokensAmount);

        emit Staked(msg.sender, sender, tokensAmount, newBalance);
    }

    /*
    * Set new lock duration for staked tokens
    */
    function setLockDuration(uint _periodInSeconds) external onlyOwner {
        lockDuration = _periodInSeconds;
        emit LockDurationChanged(lockDuration);
    }
}
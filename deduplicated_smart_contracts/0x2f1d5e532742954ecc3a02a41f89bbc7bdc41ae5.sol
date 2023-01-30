/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
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

// File: openzeppelin-eth/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-eth/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

// File: openzeppelin-eth/contracts/token/ERC20/TokenTimelock.sol

pragma solidity ^0.5.0;



/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock is Initializable {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    function initialize (IERC20 token, address beneficiary, uint256 releaseTime) public initializer {
        require(releaseTime > block.timestamp);
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime);

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0);

        _token.safeTransfer(_beneficiary, amount);
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/access/Roles.sol

pragma solidity ^0.5.0;

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
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-eth/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;




contract MinterRole is Initializable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {
        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;



/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is Initializable, IERC20 {
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
    function allowance(address owner, address spender) public view returns (uint256) {
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
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
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
        require(account != address(0));

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
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;




/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is Initializable, ERC20, MinterRole {
    function initialize(address sender) public initializer {
        MinterRole.initialize(sender);
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;




contract PauserRole is Initializable {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Initializable, PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
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

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20Pausable.sol

pragma solidity ^0.5.0;




/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is Initializable, ERC20, Pausable {
    function initialize(address sender) public initializer {
        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    uint256[50] private ______gap;
}

// File: contracts/NCDToken.sol

pragma solidity ^0.5.7;






contract NCDToken is Initializable, ERC20Detailed, ERC20Mintable, ERC20Pausable {

    /**
     * @dev Initializes with a minter and an array of pausers
     */
    function initialize(address owner, address[] memory pausers) public initializer {
        require(pausers[0] != address(0), "NCDToken: Pausers need at least one address");

        ERC20Detailed.initialize("NCDToken", "NCD", uint8(18));
        ERC20Mintable.initialize(owner);

        ERC20Pausable.initialize(pausers[0]);

        // add the other pausers as well if existing
        for (uint256 i = 1; i < pausers.length; ++i) {
            _addPauser(pausers[i]);
        }
    }

    /**
     * @dev We don't accept any Ether in this contract. Referring to https://nuco.cloud
     */
    function () external payable {
        revert('Sending Ether directly is not allowed.');
    }

    /**
     * @dev Minting tokens
     * @param account The account of beneficiary who will get the minted token
     * @param value The amount of minted token
     */
    function _mint(address account, uint256 value) internal whenNotPaused onlyMinter {
        super._mint(account, value);
    }


}

// File: contracts/ITokenVesting.sol

pragma solidity ^0.5.2;






/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
interface ITokenVesting {

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() external view returns (address);

    /**
     * @dev Update beneficiary
     */
    function updateBeneficiary(address newBeneficiary) external;

    /**
     * @return the cliff time of the token vesting.
     */
    function cliff() external view returns (uint256);

    /**
     * @return the start time of the token vesting.
     */
    function start() external view returns (uint256);

    function periodLength() external view returns (uint256);

    function periodRate() external view returns (uint256);

    /**
     * @return the amount of the token released.
     */
    function released(address token) external view returns (uint256);

    function release(IERC20 token) external;

    function totalBalance(IERC20 token) external view returns (uint256);

    /**
     * @dev Calculates the amount that has already vested.
     * @param token ERC20 token which is being vested
     */
    function vestedAmount(IERC20 token) external view returns (uint256);
}

// File: contracts/NCDTokenSale.sol

pragma solidity ^0.5.7;









contract NCDTokenSale is Initializable, Ownable, MinterRole {
    using SafeMath for uint256;

    NCDToken private _token;
    uint256 private _openingTime;
    uint256 private _closingTime;

    uint256 private _teamTokensTotal;
    uint256 private _teamTokensUnreleased;
    uint256 private _teamTokensReleased;

    /**
     * @dev Array that holds all time locks / token vesting contracts
     */
    ITokenVesting[] private _timeLocks;

    /**
     * @dev Array that holds all vesting periods as unix timestamp
     */
    uint256[] private _vestingPeriodsStart;


    /**
     * An event that is dispatched after a time lock was registered for a specific period of time
     */
    event VestingLockAdded(uint256 indexed vestingPeriodStart, uint256 indexed releaseTime, address indexed timeLockAddress,
        uint256 periodLength, uint256 periodRate);

    /**
     * An event that is dispatched after a amount of team tokens was released into Time Lock / TokenVesting contract
     */
    event VestedTokensWithdrawed(uint256 indexed timestampOfRequest, address indexed timeLockAddress, uint256 vestingPeriodStart,
        uint256 releaseTime, uint256 amount);

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "NCDTokenSale: CrowdSale is closed");
        _;
    }

    /**
     * @dev Initializer
     * @param owner The owner of the contract, will automatically become the initial minter
     * @param openingTime Opening time of token sale
     * @param closingTime Closing time of token sale
     * @param token The token to sale
     */
    function initialize(address owner, uint256 openingTime, uint256 closingTime, NCDToken token) public initializer {
        require(address(token) != address(0), "NCDTokenSale: Zero-Address for token is invalid");
        require(owner != address(0), "NCDTokenSale: address of Owner is invalid");
        require(closingTime > openingTime, "NCDTokenSale: opening time is not before closing time");

        Ownable.initialize(owner);

        // makes owner the very first Minter
        MinterRole.initialize(owner);

        _token = token;

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    /**
     * @return Returns the team tokens that are available in total (see vesting rules in whitepaper at https://nuco.cloud)
     */
    function getTeamTokensTotal() external view returns (uint256) {
        return _teamTokensTotal;
    }

    /**
     * @return Returns the team tokens that were already released in total (see vesting rules in whitepaper at https://nuco.cloud)
     */
    function getTeamTokensReleased() external view returns (uint256) {
        return _teamTokensReleased;
    }

    /**
     * @return Returns unreleased team tokens that are available to release
     */
    function getTeamTokensUnreleased() external view returns (uint256) {
        return _teamTokensUnreleased;
    }

    /**
     * @return Opening time of token sale
     */
    function getOpeningTime() external view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return Closing time of token sale
     */
    function getClosingTime() external view returns (uint256) {
        return _closingTime;
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (NCDToken) {
        return _token;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() external view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _closingTime;
    }

    /**
     * @dev Don't accept any Ether
     */
    function () external payable {
        revert('Payment in ETH not allowed');
    }

    /**
     * @dev Overrides delivery by minting tokens upon purchase.
     * @param beneficiary Token purchaser
     * @param tokenAmount Number of tokens to be minted
     */
    function mintTokens(address beneficiary, uint256 tokenAmount) external onlyMinter onlyWhileOpen {
        _teamTokensTotal = _teamTokensTotal.add(tokenAmount);
        _teamTokensUnreleased = _teamTokensUnreleased.add(tokenAmount);

        require(NCDToken(address(token())).mint(beneficiary, tokenAmount), "NCDTokenSale: Token could not be mintet");
    }

    /**
     * @dev Add vesting lock contract for vested team tokens according to the Whitepaper (https://nuco.cloud)
     */
    function addVestingLock(uint256 vestingPeriodStart, ITokenVesting vesting) external onlyOwner {
        require(address(vesting) != address(0));

        _vestingPeriodsStart.push(vestingPeriodStart);
        _timeLocks.push(vesting);

        emit VestingLockAdded(vestingPeriodStart, vesting.cliff(), address(vesting), vesting.periodLength(), vesting.periodRate());
    }

    /**
     * @dev find the proper timelock for a specific timestamp
     */
    function findTokenTimelock(uint256 timestamp) public view returns (uint256, uint256, address) {
        for(uint256 i = _vestingPeriodsStart.length-1; i >= 0; i--) {
            uint256 vestingPeriodStart = _vestingPeriodsStart[i];
            if(vestingPeriodStart <= timestamp) {
                ITokenVesting vesting = _timeLocks[i];
                if(vesting.start() <= timestamp && timestamp <= vesting.cliff()) {
                    return (vestingPeriodStart, vesting.cliff(), address(vesting));
                }
            }
        }
        revert("No suitable TokenTimelock found");
    }

    /**
     * @return Returns address of a specific time lock according to a timestamp
     */
    function getTimeLockAddress(uint256 timestamp) public view returns (address) {
        (/*uint256 vestingPeriodStart*/, /*uint256 releaseTime*/, address vesting) = findTokenTimelock(timestamp);
        return vesting;
    }

    /**
     * @return Returns all vesting related attributes for a specific time lock addressed by index
     */
    function getTimeLockDataByIndex(uint256 index) public view returns (address, address, uint256, uint256, uint256, uint256 ) {
        ITokenVesting vesting = _timeLocks[index];
        return (address(vesting), vesting.beneficiary(), vesting.start(), vesting.cliff(), vesting.periodLength(), vesting.periodRate());
    }

    /**
     * @dev mints and withdrawals team related token into the token vesting contract according for current timestamp within ICO
     * @dev it is meant to execute this function at the end of every monthly period
     */
    function withdrawVestedTokens() external returns(uint256) {
        return withdrawVestedTokensByTimestamp(block.timestamp);
    }

    /**
     * @dev mints and withdrawals team related token into the token vesting contract according to a specific timestamp within ICO
     */
    function withdrawVestedTokensByTimestamp(uint256 timestamp) public returns(uint256) {
        require(timestamp >= block.timestamp, "withdraw Vesting Token in the past not allowed");

        // _teamTokensUnreleased represents our amount of token that can be released into TimeLockVesting
        uint256 amount = _teamTokensUnreleased;

        require(amount > 0, "NCDTokenSale: no tokens available yet");

        // find the appropriate TimeLock according to the  timestamp
        (uint256 vestingPeriodStart, uint256 releaseTime, address vesting) = findTokenTimelock(timestamp);

        require(vesting != address(0), "NCDTokenSale: vesting-address is required");
        require(vestingPeriodStart <= timestamp, "NCDTokenSale: Invalid vestingPeriodStart was found");

        // reset unreleased tokens
        _teamTokensUnreleased = 0;

        // increment released tokens by amount
        _teamTokensReleased = _teamTokensReleased.add(amount);

        // mint these tokens into the timelock contract for its vesting period
        require(NCDToken(address(token())).mint(vesting, amount), "NCDTokenSale: tokens could not minted into timelock");

        emit VestedTokensWithdrawed(timestamp, vesting, vestingPeriodStart, releaseTime, amount);

        return amount;
    }

}
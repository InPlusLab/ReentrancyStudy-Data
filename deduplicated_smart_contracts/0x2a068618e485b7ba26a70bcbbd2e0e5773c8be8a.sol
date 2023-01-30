/**
 *Submitted for verification at Etherscan.io on 2019-10-15
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

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
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

// File: openzeppelin-eth/contracts/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.5.0;



/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Initializable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    function initialize(address sender) public initializer {
        if (!isWhitelistAdmin(sender)) {
            _addWhitelistAdmin(sender);
        }
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: openzeppelin-eth/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
    * @dev Returns the largest of two numbers.
    */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev Returns the smallest of two numbers.
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
    * @dev Calculates the average of two numbers. Since these are integers,
    * averages of an even and odd number cannot be represented, and will be
    * rounded down.
    */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/HolderIterableRole.sol

pragma solidity ^0.5.2;

contract HolderIterableRole {

    event HolderAdded(address indexed account);
    event HolderRemoved(address indexed account);

    struct Holder {
        bool isHolder;
        uint index; // starts with 1
    }

    mapping (address => Holder) private _holders;
    address[] internal holderList;

    modifier onlyHolder() {
        require(isHolder(msg.sender));
        _;
    }

    function isHolder(address account) public view returns (bool) {
        Holder storage holder = _holders[account];
        return holder.isHolder;
    }

    function addHolder(address account) internal {
        Holder storage holder = _holders[account];
        require(holder.isHolder == false);

        // Update status
        holder.isHolder = true;

        holderList.push(account);
        holder.index = holderList.length; // starts with 1, no decreasing 1 here.
        emit HolderAdded(account);
    }

    function removeHolder(address account) internal {
        Holder storage holder = _holders[account];

        require(holder.isHolder == true);
        require(holder.index != 0); // entry not exist
        require(holder.index <= holderList.length); // should not exceed max index

        // swap the index of last one & delete one
        uint holderListIndex = holder.index - 1;
        uint holderListLastIndex = holderList.length - 1;

        address lastAddressInHolderList = holderList[holderListLastIndex];
        _holders[lastAddressInHolderList].index = holderListIndex + 1;
        holderList[holderListIndex] = holderList[holderListLastIndex];
        holderList.length--;

        // clean up
        holder.isHolder = false;
        holder.index = 0;
        emit HolderRemoved(account);
    }

    function getHolders() internal view returns (address[] memory) {
        return holderList;
    }

    function getHolderCount() view public returns (uint256 holderCount) {
        return holderList.length;
    }
}

// File: contracts/ERC20HolderListable.sol

pragma solidity ^0.5.2;



/**
 * @title Rewardable Token
 * @dev Token that support reward protocol.
 */
contract ERC20HolderListable is ERC20, HolderIterableRole {

    function initialize(address sender) public initializer {
        addHolder(sender);
    }

    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value);

        if (balanceOf(from) == 0) {
            removeHolder(from);
        }

        if (!isHolder(to) && balanceOf(to) > 0) {
            addHolder(to);
        }
    }
}

// File: contracts/ERC20Rewardable.sol

pragma solidity ^0.5.2;







/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @title Rewardable Token
 * @dev Token that support reward protocol.
 */
contract ERC20Rewardable is Initializable, ERC20HolderListable, WhitelistAdminRole {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function initialize(address sender) public initializer {
        WhitelistAdminRole.initialize(sender);
        ERC20HolderListable.initialize(sender);
    }

    // *** IMPORTANT ***
    // `Executed` status means execute grant once before, not meaning completely granted to all holders.
    // Once status goes to `Executed`, it is not reversible to any other status.
    enum RewardStatus { Unknown, Created, Cancelled, Executed }

    struct Reward {
        string identifier; // identifier of the reward
        RewardStatus status;
        string rewardType;
        string data;
        IERC20 token; // token to be granted
        uint256 amount; // amount to be distributed
        mapping(address => bool) grantedMap; // granted account map
    }

    mapping(address => uint256) private _tokenBatchCount;
    mapping(address => uint256) private _tokenRewardBalance;
    mapping(string => Reward) identifierRewardMap;

    function getReward(string calldata identifier) external view returns (
        uint256 status,
        string memory rewardType,
        string memory data,
        address token,
        uint256 amount
    ) {
        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status != RewardStatus.Unknown);
        return (uint256(reward.status), reward.rewardType, reward.data, address(reward.token), reward.amount);
    }

    function createReward(
        string calldata identifier,
        string calldata rewardType,
        string calldata data,
        IERC20 token,
        uint256 amount
    ) external onlyWhitelistAdmin {
        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Unknown);

        // check balance enough
        uint256 balance = token.balanceOf(address(this));
        uint256 tokenRewardBalance = _tokenRewardBalance[address(token)];
        uint256 newTokenRewardBalance = tokenRewardBalance.add(amount);
        require(balance >= newTokenRewardBalance);

        // set new token balance
        _tokenRewardBalance[address(token)] = newTokenRewardBalance;

        // set meta
        reward.identifier = identifier;
        reward.status = RewardStatus.Created;
        reward.rewardType = rewardType;
        reward.data = data;
        reward.token = token;
        reward.amount = amount;
    }

    function cancelReward(string calldata identifier) external onlyWhitelistAdmin {
        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status != RewardStatus.Executed);

        // set to cancel status
        reward.status = RewardStatus.Cancelled;

        // update reward token balance
        uint256 tokenRewardBalance = _tokenRewardBalance[address(reward.token)];
        uint256 newTokenRewardBalance = tokenRewardBalance.sub(reward.amount);
        _tokenRewardBalance[address(reward.token)] = newTokenRewardBalance;
    }

    /**
     * @dev Withdraw specified ERC20 token from contract to address
     * @param token ERC20 contract to interact with
     * @param to address to withdraw
     */
    function withdrawRemainingTokenReward(IERC20 token, address to) external onlyWhitelistAdmin {
        uint256 amount = token.balanceOf(address(this));
        uint256 tokenRewardBalance = _tokenRewardBalance[address(token)];
        token.safeTransfer(to, amount.sub(tokenRewardBalance));
    }

    /**
     * @dev Can specified token's batch count
     * @param token ERC20 to set batch count
     * @param batchCount batch number
     */
    function setTokenRewardBatchCount(IERC20 token, uint256 batchCount) external onlyWhitelistAdmin {
        _tokenBatchCount[address(token)] = batchCount;
    }

    /**
     * @dev Reward specified ERC20 token to holders, warning: only able to execute below 200 hoders a time
     * @param identifier Reward identifier to interact
     */
    function executeReward(string memory identifier) public onlyWhitelistAdmin {
        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Created);

        address[] memory holders = getHolders();
        for (uint index = 0; index < holders.length; index++) {
            require(reward.grantedMap[holders[index]] == false);
            uint256 amount = reward.amount.mul(balanceOf(holders[index])).div(totalSupply());
            reward.token.safeTransfer(holders[index], amount);
            reward.grantedMap[holders[index]] = true;
        }

        _tokenRewardBalance[address(reward.token)] = _tokenRewardBalance[address(reward.token)].sub(reward.amount);
        reward.status = RewardStatus.Executed;
    }

    /**
     * @dev Can specified token's batch count
     * @param identifier Reward identifier to interact
     * @param batchOffset batch number
     */
    function executeRewardBatch(string memory identifier, uint256 batchOffset) public onlyWhitelistAdmin {
        Reward storage reward = identifierRewardMap[identifier];
        require(reward.status == RewardStatus.Created || reward.status == RewardStatus.Executed);

        uint256 tokenBatchCount = _tokenBatchCount[address(reward.token)];
        require(tokenBatchCount != 0);
        uint256 offset = batchOffset * _tokenBatchCount[address(reward.token)];
        address[] memory holders = getHolders();
        uint256 maxIndex = Math.min(offset + tokenBatchCount, holders.length);

        for (uint256 index = offset; index < maxIndex; index++) {
            require(reward.grantedMap[holders[index]] == false);
            uint256 amount = reward.amount.mul(balanceOf(holders[index])).div(totalSupply());
            reward.token.safeTransfer(holders[index], amount);
            reward.grantedMap[holders[index]] = true;
            _tokenRewardBalance[address(reward.token)] = _tokenRewardBalance[address(reward.token)].sub(amount);
        }
        reward.status = RewardStatus.Executed;
    }
}

// File: contracts/CYPPToken.sol

pragma solidity ^0.5.2;







contract CYPPToken is Initializable, ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Rewardable {

    string public Token_ID;
    string public ArtistID;
    string public ISRC;

    function initialize() public initializer {
        Token_ID = "CYPP";
        ArtistID = "LukeTsui";
        ISRC = "TWA770700685";

        ERC20Detailed.initialize("TWA770700685", "CYPP", 18);
        ERC20Mintable.initialize(msg.sender);
        ERC20Pausable.initialize(msg.sender);
        ERC20Rewardable.initialize(msg.sender);
    }

    // override to ensure token is paused
    function executeReward(string memory identifier) public onlyWhitelistAdmin {
        require(paused(), "require paused when rewarding");
        super.executeReward(identifier);
    }

    // override to ensure token is paused
    function executeRewardBatch(string memory identifier, uint256 batchOffset) public onlyWhitelistAdmin {
        require(paused(), "require paused when rewarding");
        super.executeRewardBatch(identifier, batchOffset);
    }
}
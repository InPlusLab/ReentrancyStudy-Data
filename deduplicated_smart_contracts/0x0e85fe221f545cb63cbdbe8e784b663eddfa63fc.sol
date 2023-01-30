/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity 0.5.16;


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
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Initializable, Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Initializable, Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


library BasisPoints {
    using SafeMath for uint;

    uint constant private BASIS_POINTS = 10000;

    function mulBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        return amt.mul(bp).div(BASIS_POINTS);
    }

    function addBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.add(mulBP(amt, bp));
    }

    function subBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.sub(mulBP(amt, bp));
    }
}

// File: @openzeppelin\contracts-ethereum-package\contracts\access\Roles.sol

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
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


contract PoolManagerRole is Initializable {
    using Roles for Roles.Role;

    event PoolManagerAdded(address indexed account);
    event PoolManagerRemoved(address indexed account);

    Roles.Role private _poolManagers;

    function initialize(address sender) public initializer {
        if (!isPoolManager(sender)) {
            _addPoolManager(sender);
        }
    }

    modifier onlyPoolManager() {
        require(isPoolManager(msg.sender), "PoolManagerRole: caller does not have the PoolManager role");
        _;
    }

    function isPoolManager(address account) public view returns (bool) {
        return _poolManagers.has(account);
    }

    function addPoolManager(address account) public onlyPoolManager {
        _addPoolManager(account);
    }

    function renouncePoolManager() public {
        _removePoolManager(msg.sender);
    }

    function _addPoolManager(address account) internal {
        _poolManagers.add(account);
        emit PoolManagerAdded(account);
    }

    function _removePoolManager(address account) internal {
        _poolManagers.remove(account);
        emit PoolManagerRemoved(account);
    }

    uint256[50] private ______gap;
}


contract MoonStaking is Initializable, PoolManagerRole, Ownable {
    using BasisPoints for uint;
    using SafeMath for uint;

    uint256 constant internal DISTRIBUTION_MULTIPLIER = 2 ** 64;

    uint public taxBP;
    uint public burnBP;
    uint public refBP;

    uint public referralPayoutBP;

    MoonTokenV2 private moonToken;

    mapping(address => uint) public stakeValue;
    mapping(address => int) private stakerPayouts;

    mapping(address => address) public stakerRefferers;
    mapping(address => uint) public referralPayouts;
    uint public referralPoolReserved;
    uint public referralPool;

    uint public startTime;

    uint public totalDistributions;
    uint public totalStaked;
    uint public totalStakers;
    uint private profitPerShare;
    uint private emptyStakeTokens; //These are tokens given to the contract when there are no stakers.

    event OnDistribute(address sender, uint amountSent);
    event OnReferralDistribute(address sender, uint amount);
    event OnStake(address sender, uint amount, address refferer);
    event OnUnstake(address sender, uint amount, uint taxTokens, uint burnTokens, uint referralTokens);
    event OnReinvest(address sender, uint amount);
    event OnWithdraw(address sender, uint amount);
    event OnReferralClaim(address sender, uint amount);
    event OnReferralExcessClaim(address sender, uint amount);

    modifier onlyMoonToken {
        require(msg.sender == address(moonToken), "Can only be called by MoonTokenV2 contract.");
        _;
    }

    modifier whenStakingActive {
        require(now > startTime, "Staking not yet started.");
        _;
    }

    function initialize(
        uint _startTime,
        uint _taxBP,
        uint _burnBP,
        uint _refBP,
        uint _referralPayoutBP,
        address _owner,
        address[] memory _poolManagers,
        MoonTokenV2 _moonToken
    ) public initializer {
        Ownable.initialize(msg.sender);

        startTime = _startTime;
        moonToken = _moonToken;

        taxBP = _taxBP;
        burnBP = _burnBP;
        refBP = _refBP;
        referralPayoutBP = _referralPayoutBP;

        PoolManagerRole.initialize(address(this));
        _removePoolManager(address(this));

        for (uint256 i = 0; i < _poolManagers.length; ++i) {
            _addPoolManager(_poolManagers[i]);
        }

        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(_owner);
    }

    function stake(uint amount) public whenStakingActive {
        if (stakerRefferers[msg.sender] != address(0x0)) {
            stakeWithReferrer(amount, stakerRefferers[msg.sender]);
        } else {
            stakeWithReferrer(amount, address(0x0));
        }
    }

    function stakeWithReferrer(uint amount, address referrer) public whenStakingActive {
        require(amount >= 10000e18, "Must stake at least 10000 MOON.");
        require(moonToken.balanceOf(msg.sender) >= amount, "Cannot stake more MOON than you hold unstaked.");
        if (stakerRefferers[msg.sender] != address(0x0)) {
            referrer = stakerRefferers[msg.sender]; //User cannot change their referrer.
        }
        if (referrer != address(0x0)) {
            //NOTE: The referral pool gets refreshed from all tx.
            //So at certain points, may be low/empty.
            //In which case rewards will need to wait to be pulled.
            uint referralAmount = amount.mulBP(refBP);
            referralPayouts[referrer] = referralPayouts[referrer].add(referralAmount);
            referralPoolReserved = referralPoolReserved.add(referralAmount);
        }
        if (stakeValue[msg.sender] == 0) totalStakers = totalStakers.add(1);
        _addStake(amount);
        require(moonToken.transferFrom(msg.sender, address(this), amount), "Stake failed due to failed transfer.");
        emit OnStake(msg.sender, amount, referrer);
    }

    function unstake(uint amount) public whenStakingActive {
        require(amount >= 1e18, "Must unstake at least one MOON.");
        require(stakeValue[msg.sender] >= amount, "Cannot unstake more MOON than you have staked.");

        (uint taxTokens, uint burnTokens, uint referralTokens) = taxAmount(amount);
        uint earnings = amount.sub(taxTokens).sub(burnTokens).sub(referralTokens);

        if (stakeValue[msg.sender] == amount) totalStakers = totalStakers.sub(1);
        totalStaked = totalStaked.sub(amount);
        stakeValue[msg.sender] = stakeValue[msg.sender].sub(amount);
        uint payout = profitPerShare.mul(amount).add(taxTokens.mul(DISTRIBUTION_MULTIPLIER));
        stakerPayouts[msg.sender] = stakerPayouts[msg.sender] - uintToInt(payout);

        _increaseProfitPerShare(taxTokens);
        moonToken.burn(burnTokens);
        referralPool.add(referralTokens);
        emit OnReferralDistribute(msg.sender, amount);

        require(moonToken.transferFrom(address(this), msg.sender, earnings), "Unstake failed due to failed transfer.");
        emit OnUnstake(msg.sender, amount, taxTokens, burnTokens, referralTokens);
    }

    function withdraw(uint amount) public whenStakingActive {
        require(dividendsOf(msg.sender) >= amount, "Cannot withdraw more dividends than you have earned.");
        stakerPayouts[msg.sender] = stakerPayouts[msg.sender] + uintToInt(amount.mul(DISTRIBUTION_MULTIPLIER));
        moonToken.transfer(msg.sender, amount);
        emit OnWithdraw(msg.sender, amount);
    }

    function reinvest(uint amount) public whenStakingActive {
        require(dividendsOf(msg.sender) >= amount, "Cannot reinvest more dividends than you have earned.");
        uint payout = amount.mul(DISTRIBUTION_MULTIPLIER);
        stakerPayouts[msg.sender] = stakerPayouts[msg.sender] + uintToInt(payout);
        _addStake(amount);
        emit OnReinvest(msg.sender, amount);
    }

    function distribute(uint amount) public {
        require(moonToken.balanceOf(msg.sender) >= amount, "Cannot distribute more MOON than you hold unstaked.");
        totalDistributions = totalDistributions.add(amount);
        _increaseProfitPerShare(amount);
        require(
            moonToken.transferFrom(msg.sender, address(this), amount),
            "Distribution failed due to failed transfer."
        );
        emit OnDistribute(msg.sender, amount);
    }

    function claimReferralRewards() public {
        uint amount = referralPayouts[msg.sender];
        require(amount != 0, "Must have referral rewards to claim.");
        require(amount < referralPool, "Not enough tokens in pool. Wait for a refresh.");
        referralPoolReserved = referralPoolReserved.sub(amount);
        referralPool = referralPool.sub(amount);
        referralPayouts[msg.sender] = 0;
        moonToken.transfer(msg.sender, amount);
        emit OnReferralClaim(msg.sender, amount);
    }

    function claimExcessFromReferralPool(uint amount) public onlyPoolManager {
        require(amount <= referralPool.sub(referralPoolReserved), "Amount is greater than excess.");
        referralPool = referralPool.sub(amount);
        moonToken.transfer(msg.sender, amount);
        emit OnReferralExcessClaim(msg.sender, amount);
    }

    function handleTaxDistribution(uint amount) public onlyMoonToken {
        totalDistributions = totalDistributions.add(amount);
        _increaseProfitPerShare(amount);
        emit OnDistribute(msg.sender, amount);
    }

    function handleReferralDistribution(uint amount) public onlyMoonToken {
        referralPool.add(amount);
        emit OnReferralDistribute(msg.sender, amount);
    }

    function setStartTime(uint val) public onlyOwner {
        startTime = val;
    }

    function dividendsOf(address staker) public view returns (uint) {
        return uint(uintToInt(profitPerShare.mul(stakeValue[staker])) - stakerPayouts[staker])
            .div(DISTRIBUTION_MULTIPLIER);
    }

    function taxAmount(uint value) public view returns (uint tax, uint burn, uint referral) {
        tax = value.mulBP(taxBP);
        burn = value.mulBP(burnBP);
        referral = value.mulBP(refBP);
        return (tax, burn, referral);
    }

    function uintToInt(uint val) internal pure returns (int) {
        if (val >= uint(-1).div(2)) {
            require(false, "Overflow. Cannot convert uint to int.");
        } else {
            return int(val);
        }
    }

    function _addStake(uint amount) internal {
        totalStaked = totalStaked.add(amount);
        stakeValue[msg.sender] = stakeValue[msg.sender].add(amount);
        uint payout = profitPerShare.mul(amount);
        stakerPayouts[msg.sender] = stakerPayouts[msg.sender] + uintToInt(payout);
    }

    function _increaseProfitPerShare(uint amount) internal {
        if (totalStaked != 0) {
            if (emptyStakeTokens != 0) {
                amount = amount.add(emptyStakeTokens);
                emptyStakeTokens = 0;
            }
            profitPerShare = profitPerShare.add(amount.mul(DISTRIBUTION_MULTIPLIER).div(totalStaked));
        } else {
            emptyStakeTokens = emptyStakeTokens.add(amount);
        }
    }

}


contract MoonTokenV2 is Initializable, Ownable, ERC20Burnable, ERC20Detailed {
    using BasisPoints for uint;
    using SafeMath for uint;

    uint public taxBP;
    uint public burnBP;
    uint public refBP;
    uint public bonusBP;

    MoonStaking private moonStaking;

    bool public isAirdropComplete;

    mapping(address => bool) private trustedContracts;
    mapping(address => bool) private bonusWhitelist;
    mapping(address => bool) public taxExempt;

    function initialize(
        string memory name, string memory symbol, uint8 decimals,
        uint _taxBP, uint _burnBP, uint _refBP, uint _bonusBP, address _owner,
        MoonStaking _moonStaking
    ) public initializer {
        Ownable.initialize(msg.sender);

        taxBP = _taxBP;
        burnBP = _burnBP;
        refBP = _refBP;
        bonusBP = _bonusBP;

        moonStaking = _moonStaking;

        taxExempt[address(moonStaking)] = true;
        trustedContracts[address(moonStaking)] = true;

        ERC20Detailed.initialize(name, symbol, decimals);

        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(_owner);
    }

    function setTaxExemptStatus(address account, bool status) public onlyOwner {
        taxExempt[account] = status;
    }

    function taxAmount(uint value) public view returns (uint tax, uint burn, uint referral) {
        tax = value.mulBP(taxBP);
        burn = value.mulBP(burnBP);
        referral = value.mulBP(refBP);
        return (tax, burn, referral);
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        (!taxExempt[msg.sender] && !taxExempt[recipient]) ?
            _transferWithTax(msg.sender, recipient, amount) :
            _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        (!taxExempt[sender] && !taxExempt[recipient]) ?
            _transferWithTax(sender, recipient, amount) :
            _transfer(sender, recipient, amount);
        if (trustedContracts[msg.sender]) return true;
        approve
        (
            msg.sender,
            allowance(
                sender,
                msg.sender
            ).sub(amount, "Transfer amount exceeds allowance")
        );
        return true;
    }

    function setBonusWhitelist(address receiver, bool val) public onlyOwner {
        bonusWhitelist[receiver] = val;
    }

    function grantBonusWhitelistMulti(address[] memory receivers) public onlyOwner {
        for (uint i=0; i < receivers.length; i++) {
            bonusWhitelist[receivers[i]] = true;
        }
    }

    function airdrop(address[] memory receivers, uint[] memory amounts) public onlyOwner {
        require(receivers.length == amounts.length, "Must have same number of addresses as amounts.");
        require(!isAirdropComplete, "Airdrop has ended.");
        for (uint i=0; i < receivers.length; i++) {
            _airdrop(receivers[i], amounts[i]);
        }
        require(totalSupply() <= 250000000 ether, "Cannot issue more than cap.");
    }

    function setAirdropComplete() public onlyOwner {
        isAirdropComplete = true;
    }

    function _airdrop(address receiver, uint amount) internal {
        require(balanceOf(receiver) == 0, "Receiver must not have been airdropped tokens.");
        if (bonusWhitelist[receiver]) {
            _mint(receiver, amount.addBP(bonusBP));
        } else {
            _mint(receiver, amount);
        }
    }

    function _transferWithTax(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        (uint taxTokens, uint burnTokens, uint referralTokens) = taxAmount(amount);
        uint tokensToTransfer = amount.sub(taxTokens).sub(burnTokens).sub(referralTokens);

        _transfer(sender, address(moonStaking), taxTokens.add(referralTokens));
        _burn(sender, burnTokens);
        _transfer(sender, recipient, tokensToTransfer);
        moonStaking.handleTaxDistribution(taxTokens);
        moonStaking.handleReferralDistribution(referralTokens);
    }
}
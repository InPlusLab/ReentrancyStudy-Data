/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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
contract Context {
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
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
     * NOTE: Renouncing ownership will leave the contract without an owner,
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
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;




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
contract ERC20 is Context, IERC20 {
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
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;



contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/ReferralTracker.sol

pragma solidity 0.5.10;





contract ReferralTracker is Ownable, Pausable {
    using SafeMath for uint256;
    uint256 public REFERRAL_BONUS = 100000000000000000000;

    mapping(address => uint256) public unclaimedReferrals;
    address public registryAddress;
    address public admin;
    ERC20 token;

    event ReferralRegistered(
        address referralAddress,
        address indexed referrer,
        address indexed user
    );
    event ReferralBonusWithdrawn(
        address referralAddress,
        address indexed referrer,
        uint256 amount,
        uint256 currentTrackerBalance
    );
    event FundsAdded(address referralAddress, address fundsDepositor, uint256 amount);
    event FundsRemoved(address referralAddress, address fundsWithdrawer, uint256 amount);

    constructor(address registryAddress_, address tokenAdress) public PauserRole() {
        registryAddress = registryAddress_;
        token = ERC20(tokenAdress);
    }

    modifier onlyRegistry() {
        require(msg.sender == registryAddress, "the caller is not the registry");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "the caller is not the admin");
        _;
    }

    function setAdministrator(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setToken(address _token) public onlyOwner {
        token = ERC20(_token);
    }

    function addFunds(uint256 amount) public onlyAdmin whenNotPaused {
        token.transferFrom(msg.sender, address(this), amount);
        emit FundsAdded(address(this), msg.sender, amount);
    }

    function removeFunds(address to) public onlyAdmin {
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "ReferralTracker has no funds to withdraw");
        token.transfer(to, amount);
        emit FundsRemoved(address(this), msg.sender, amount);
    }

    function registerReferral(address referrer, address user)
        public
        onlyRegistry
        whenNotPaused
        returns (bool)
    {
        unclaimedReferrals[referrer] = unclaimedReferrals[referrer].add(1);

        emit ReferralRegistered(address(this), referrer, user);
        return true;
    }

    function withdraw(address to) public whenNotPaused {
        require(unclaimedReferrals[msg.sender] > 0, "no referrals to claim");
        uint256 trackerBalance = token.balanceOf(address(this));
        uint256 amount = REFERRAL_BONUS * unclaimedReferrals[msg.sender];

        require(trackerBalance >= amount, "Not enough funds");
        delete unclaimedReferrals[msg.sender];

        token.transfer(to, amount);

        emit ReferralBonusWithdrawn(address(this), msg.sender, amount, trackerBalance);
    }

    function getTrackerBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}

// File: contracts/KYCRegistry.sol

pragma solidity 0.5.10;


contract KYCRegistry is Ownable {
    mapping(address => bool) public KYCConfirmed;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller is not the admin");
        _;
    }

    event RemovedFromKYC(address indexed user);
    event AddedToKYC(address indexed user);

    function isConfirmed(address addr) public view returns (bool) {
        return KYCConfirmed[addr];
    }

    function setAdministrator(address _admin) public onlyOwner {
        admin = _admin;
    }

    function removeAddressFromKYC(address addr) public onlyAdmin {
        require(KYCConfirmed[addr], "Address not KYCed");
        KYCConfirmed[addr] = false;
        emit RemovedFromKYC(addr);
    }

    function addAddressToKYC(address addr) public onlyAdmin {
        require(!KYCConfirmed[addr], "Address already KYCed");
        KYCConfirmed[addr] = true;
        emit AddedToKYC(addr);
    }
}

// File: contracts/DepositRegistry.sol

pragma solidity 0.5.10;





contract DepositRegistry is Ownable {
    struct Deposit {
        bool deposited;
        bool unlockedForWithdrawal;
    }
    mapping(address => Deposit) deposits;
    address public admin;
    uint256 constant DEPOSIT_AMNT = 200e18; //200000000000000000000;
    ERC20 public token;

    KYCRegistry public kyc;
    ReferralTracker public ref;

    bool public migrationAllowed;

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller is not the admin");
        _;
    }

    event UserDepositCompleted(address depositRegistry, address indexed user);
    event UserWithdrawnCompleted(address depositRegistry, address indexed user);
    event AddressUnlockedForWithdrawal(address depositRegistry, address indexed user);
    event MigrationFinished(address depositRegistry);

    constructor(address tokenAddress, address kycAddress) public {
        token = ERC20(tokenAddress);
        kyc = KYCRegistry(kycAddress);
        migrationAllowed = true;
    }

    function setReferralTracker(address contractAddress) external onlyOwner {
        require(contractAddress != address(0x0), "Address needs to be valid");
        ref = ReferralTracker(contractAddress);
    }

    function setERC20Token(address newToken) external onlyAdmin {
        require(newToken != address(0x0), "Address needs to be valid");
        token = ERC20(newToken);
    }

    function setKYC(address newKYC) external onlyAdmin {
        require(newKYC != address(0x0), "Address needs to be valid");
        kyc = KYCRegistry(newKYC);
    }

    function setAdministrator(address _admin) external onlyOwner {
        require(_admin != address(0x0), "Address needs to be valid");
        admin = _admin;
    }

    function migrate(address[] calldata depositors, address oldDeposit) external onlyOwner {
        require(migrationAllowed, "Migration already done");
        for (uint256 i = 0; i < depositors.length; i++) {
            require(deposits[depositors[i]].deposited == false, "Depositor already deposited");
            DepositRegistry oldDepositRegistry = DepositRegistry(oldDeposit);
            require(
                oldDepositRegistry.hasDeposited(depositors[i]),
                "Depositor does not have deposit in old Registry"
            );
            deposits[depositors[i]].deposited = true;
            emit UserDepositCompleted(address(this), depositors[i]);
        }
    }

    function finishMigration() external onlyOwner {
        require(migrationAllowed, "Migration already done");
        migrationAllowed = false;
        emit MigrationFinished(address(this));
    }

    function depositFor(address from) external {
        require(deposits[from].deposited == false, "already deposited");
        require(
            token.allowance(from, address(this)) >= DEPOSIT_AMNT,
            "address not approved amount"
        );

        deposits[from].deposited = true;
        require(token.transferFrom(from, address(this), DEPOSIT_AMNT), "Deposit transfer failed");

        emit UserDepositCompleted(address(this), from);
    }

    function depositForWithReferral(address from, address referrer) external {
        require(from != referrer, "can not refer to itself");
        require(deposits[referrer].deposited, "referrer has not deposited");
        require(deposits[from].deposited == false, "alredy deposited");
        require(
            token.allowance(from, address(this)) >= DEPOSIT_AMNT,
            "address not approved amount"
        );
        require(msg.sender == from, "cannot deposit with a referral from another address");

        deposits[from].deposited = true;

        require(ref.registerReferral(referrer, msg.sender), "ref failed");

        require(
            token.transferFrom(from, address(this), DEPOSIT_AMNT),
            "Deposit referal transfer failed"
        );

        emit UserDepositCompleted(address(this), from);
    }

    function withdraw(address to) external {
        require(deposits[msg.sender].deposited, "address not deposited");
        require(
            deposits[msg.sender].unlockedForWithdrawal || kyc.isConfirmed(msg.sender),
            "cannot withdraw without KYC or unlocked"
        );

        delete deposits[msg.sender];
        require(token.transfer(to, DEPOSIT_AMNT), "Withdraw transfer failed");
        emit UserWithdrawnCompleted(address(this), msg.sender);
    }

    function unlockAddressForWithdrawal(address user) external onlyAdmin {
        require(deposits[user].deposited, "address has not deposited");
        deposits[user].unlockedForWithdrawal = true;
        emit AddressUnlockedForWithdrawal(address(this), user);
    }

    function hasDeposited(address user) external view returns (bool) {
        return deposits[user].deposited;
    }

    function isUnlocked(address user) external view returns (bool) {
        return deposits[user].unlockedForWithdrawal;
    }
}

// File: contracts/Authorization.sol

pragma solidity 0.5.10;




contract Authorization is Ownable {
    KYCRegistry kyc;
    DepositRegistry deposit;

    constructor(address kycAddr, address depositAddr) public {
        kyc = KYCRegistry(kycAddr);
        deposit = DepositRegistry(depositAddr);
    }

    function hasDeposited(address user) public view returns (bool) {
        return deposit.hasDeposited(user);
    }

    function isKYCConfirmed(address user) public view returns (bool) {
        return kyc.isConfirmed(user);
    }

    function setKYCRegistry(address kycAddress) public onlyOwner returns (bool) {
        kyc = KYCRegistry(kycAddress);
        return true;
    }

    function setDepositRegistry(address depositAddress) public onlyOwner returns (bool) {
        deposit = DepositRegistry(depositAddress);
        return true;
    }
}

// File: contracts/LoanContractInterface.sol

pragma solidity 0.5.10;

interface LoanContractInterface {
    function onFundingReceived(address lender, uint256 amount) external returns (bool);
    function withdrawRepayment() external;
    function withdrawLoan() external;
    function onRepaymentReceived(address from, uint256 amount) external returns (bool);
    function getInterestRate() external view returns (uint256);
    function calculateValueWithInterest(uint256 value) external view returns (uint256);
    function getMaxAmount() external view returns (uint256);
    function getAuctionBalance() external view returns (uint256);
}

// File: contracts/DAIProxyInterface.sol

pragma solidity 0.5.10;

interface DAIProxyInterface {
    function fund(address loanAddress, uint256 fundingAmount) external;
    function repay(address loanAddress, uint256 repaymentAmount) external;
}

// File: contracts/DAIProxy.sol

pragma solidity 0.5.10;





contract DAIProxy is DAIProxyInterface, Ownable {
    IERC20 private DAIToken;
    Authorization auth;
    address public administrator;

    event LoanFunded(address indexed funder, address indexed loanAddress, uint256 amount);
    event RepaymentReceived(address indexed repayer, address indexed loanAddress, uint256 amount);

    event AuthAddressUpdated(address newAuthAddress, address administrator);
    event DaiTokenAddressUpdated(address newDaiTokenAddress, address administrator);
    event AdministratorUpdated(address newAdministrator);

    constructor(address authAddress, address DAIAddress) public {
        auth = Authorization(authAddress);
        DAIToken = IERC20(DAIAddress);
    }

    function getTokenAddress() public view returns (address) {
        return address(DAIToken);
    }

    function setAdministrator(address admin) external onlyOwner {
        administrator = admin;
        emit AdministratorUpdated(administrator);
    }

    function setDaiTokenAddress(address daiAddress) external onlyAdmin {
        DAIToken = IERC20(daiAddress);
        emit DaiTokenAddressUpdated(daiAddress, administrator);
    }

    function setAuthAddress(address authAddress) external onlyAdmin {
        auth = Authorization(authAddress);
        emit AuthAddressUpdated(authAddress, administrator);
    }

    function fund(address loanAddress, uint256 fundingAmount) external onlyKYCCanFund {
        uint256 newFundingAmount = fundingAmount;
        LoanContractInterface loanContract = LoanContractInterface(loanAddress);

        uint256 auctionBalance = loanContract.getAuctionBalance();
        uint256 maxAmount = loanContract.getMaxAmount();

        if (auctionBalance + fundingAmount > maxAmount) {
            newFundingAmount = maxAmount - auctionBalance;
        }
        require(newFundingAmount > 0, "funding amount can not be zero");
        require(
            loanContract.onFundingReceived(msg.sender, newFundingAmount),
            "funding failed at loan contract"
        );
        require(transfer(loanAddress, newFundingAmount), "erc20 transfer failed");
    }

    function repay(address loanAddress, uint256 repaymentAmount) external onlyKYCCanFund {
        LoanContractInterface loanContract = LoanContractInterface(loanAddress);
        require(
            loanContract.onRepaymentReceived(msg.sender, repaymentAmount),
            "repayment failed at loan contract"
        );
        require(transfer(loanAddress, repaymentAmount), "erc20 repayment failed");
    }

    function transfer(address loanAddress, uint256 amount) internal returns (bool) {
        require(DAIToken.allowance(msg.sender, address(this)) >= amount, "funding not approved");
        uint256 balance = DAIToken.balanceOf(msg.sender);
        require(balance >= amount, "Not enough funds");
        require(DAIToken.transferFrom(msg.sender, loanAddress, amount), "failed at transferFrom");
        return true;
    }

    modifier onlyKYCCanFund {
        require(auth.isKYCConfirmed(msg.sender), "user does not have KYC");
        _;
    }

    modifier onlyHasDepositCanFund {
        require(auth.hasDeposited(msg.sender), "user does not have a deposit");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == administrator, "Caller is not an administrator");
        _;
    }
}
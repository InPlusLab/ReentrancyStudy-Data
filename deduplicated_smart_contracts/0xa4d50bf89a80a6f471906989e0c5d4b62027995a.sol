/**
 *Submitted for verification at Etherscan.io on 2019-09-24
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
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
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
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

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
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
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
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


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
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
contract Pausable is PauserRole {
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
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
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

    constructor(address registryAddress_, address tokenAdress) public {
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

    function registerReferral(address referrer, address user) public onlyRegistry whenNotPaused {
        unclaimedReferrals[referrer] = unclaimedReferrals[referrer].add(1);

        emit ReferralRegistered(address(this), referrer, user);
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
    uint256 DEPOSIT_AMNT = 200000000000000000000;
    ERC20 token;

    KYCRegistry kyc;
    ReferralTracker public ref;

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller is not the admin");
        _;
    }

    event UserDepositCompleted(address depositRegistry, address indexed user);
    event UserWithdrawnCompleted(address depositRegistry, address indexed user);
    event AddressUnlockedForWithdrawal(address depositRegistry, address indexed user);

    constructor(address tokenAddress, address kycAddress) public {
        token = ERC20(tokenAddress);
        kyc = KYCRegistry(kycAddress);
    }

    function setReferralTracker(address contractAddress) public onlyOwner {
        ref = ReferralTracker(contractAddress);
    }

    function setAdministrator(address _admin) public onlyOwner {
        admin = _admin;
    }

    function depositFor(address from) public {
        require(deposits[from].deposited == false, "already deposited");
        require(
            token.allowance(from, address(this)) >= DEPOSIT_AMNT,
            "address not approved amount"
        );

        deposits[from].deposited = true;
        token.transferFrom(from, address(this), DEPOSIT_AMNT);

        emit UserDepositCompleted(address(this), from);
    }

    function depositForWithReferral(address from, address referrer) public {
        require(from != referrer, "can not refer to itself");
        require(deposits[referrer].deposited, "referrer has not deposited");
        require(deposits[from].deposited == false, "alredy deposited");
        require(
            token.allowance(from, address(this)) >= DEPOSIT_AMNT,
            "address not approved amount"
        );
        require(msg.sender == from, "cannot deposit with a referral from another address");

        deposits[from].deposited = true;

        ref.registerReferral(referrer, msg.sender);

        token.transferFrom(from, address(this), DEPOSIT_AMNT);

        emit UserDepositCompleted(address(this), from);
    }

    function withdraw(address to) public {
        require(deposits[msg.sender].deposited, "address not deposited");
        require(
            deposits[msg.sender].unlockedForWithdrawal || kyc.isConfirmed(msg.sender),
            "cannot withdraw without KYC or unlocked"
        );

        delete deposits[msg.sender];
        token.transfer(to, DEPOSIT_AMNT);
        emit UserWithdrawnCompleted(address(this), msg.sender);
    }

    function unlockAddressForWithdrawal(address user) public onlyAdmin {
        require(deposits[user].deposited, "address has not deposited");
        deposits[user].unlockedForWithdrawal = true;
        emit AddressUnlockedForWithdrawal(address(this), user);
    }

    function hasDeposited(address user) public view returns (bool) {
        return deposits[user].deposited;
    }

    function isUnlocked(address user) public view returns (bool) {
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
}

// File: contracts/DAIProxyInterface.sol

pragma solidity 0.5.10;

interface DAIProxyInterface {
    function fund(address loanAddress, uint256 fundingAmount) external;
    function repay(address loanAddress, uint256 repaymentAmount) external;
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

// File: contracts/LoanContract.sol

pragma solidity 0.5.10;





contract LoanContract is LoanContractInterface {
    using SafeMath for uint256;
    ERC20 DAIToken;
    DAIProxyInterface proxy;
    address public originator;
    address public administrator;

    uint256 public minAmount;
    uint256 public maxAmount;

    uint256 public auctionEndTimestamp;
    uint256 public auctionStartTimestamp;
    uint256 public auctionLength;

    uint256 public lastFundedTimestamp;

    uint256 public termEndTimestamp;
    uint256 public termLength;

    uint256 public auctionBalance;
    uint256 public loanWithdrawnAmount;
    uint256 public borrowerDebt; // Amount borrower need to repay == principal + interests
    uint256 public maxInterestRate;
    uint256 internal interestRate;
    uint256 public operatorFee;
    uint256 public operatorBalance;

    bool public loanWithdrawn;
    bool public minimumReached;

    uint256 constant MONTH_SECONDS = 2592000;
    uint256 constant ONE_HUNDRED = 100000000000000000000;

    struct Position {
        uint256 bidAmount;
        bool withdrawn;
    }

    mapping(address => Position) public lenderPosition;

    enum LoanState {
        CREATED, // accepts bids until timelimit initial state
        FAILED_TO_FUND, // not fully funded in timelimit
        ACTIVE, // fully funded, inside timelimit
        DEFAULTED, // not repaid in time loanRepaymentLength
        REPAID, // the borrower repaid in full, lenders have yet to reclaim funds
        CLOSED, // from failed_to_fund => last lender to withdraw triggers change / from repaid => fully witdrawn by lenders
        FROZEN // when admin unlocks withdrawals
    }

    LoanState public currentState;

    event LoanCreated(
        address indexed contractAddr,
        address indexed originator,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 maxInterestRate,
        uint256 auctionStartTimestamp,
        uint256 auctionEndTimestamp,
        address indexed administrator,
        uint256 operatorFee
    );

    event MinimumFundingReached(address loanAddress, uint256 currentBalance, uint256 interest);
    event FullyFunded(
        address loanAddress,
        uint256 balanceToRepay,
        uint256 auctionBalance,
        uint256 interest,
        uint256 fundedTimestamp
    );
    event Funded(
        address loanAddress,
        address indexed lender,
        uint256 amount,
        uint256 interest,
        uint256 fundedTimestamp
    );
    event LoanRepaid(address loanAddress, uint256 indexed timestampRepaid);
    event RepaymentWithdrawn(address loanAddress, address indexed to, uint256 amount);
    event RefundWithdrawn(address loanAddress, address indexed lender, uint256 amount);
    event FullyRefunded(address loanAddress);
    event FailedToFund(address loanAddress, address indexed lender, uint256 amount);
    event LoanFundsWithdrawn(address loanAddress, address indexed borrower, uint256 amount);
    event LoanDefaulted(address loanAddress);
    event AuctionSuccessful(
        address loanAddress,
        uint256 balanceToRepay,
        uint256 auctionBalance,
        uint256 operatorBalance,
        uint256 interest,
        uint256 fundedTimestamp
    );
    event FundsUnlockedWithdrawn(address loanAddress, address indexed lender, uint256 amount);
    event FullyFundsUnlockedWithdrawn(address loanAddress);
    event LoanFundsUnlocked(uint256 auctionBalance);
    event OperatorWithdrawn(uint256 amount, address administrator);

    modifier onlyFrozen() {
        require(currentState == LoanState.FROZEN, "Loan status is not FROZEN");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == administrator, "Caller is not an administrator");
        _;
    }

    modifier onlyCreated() {
        require(currentState == LoanState.CREATED, "Loan status is not CREATED");
        _;
    }

    modifier onlyActive() {
        updateStateMachine();
        require(currentState == LoanState.ACTIVE, "Loan status is not ACTIVE");
        _;
    }

    modifier onlyRepaid() {
        updateStateMachine();
        require(currentState == LoanState.REPAID, "Loan status is not REPAID");
        _;
    }

    modifier onlyFailedToFund() {
        updateStateMachine();
        require(currentState == LoanState.FAILED_TO_FUND, "Loan status is not FAILED_TO_FUND");
        _;
    }

    modifier onlyProxy() {
        require(msg.sender == address(proxy), "Caller is not the proxy");
        _;
    }

    modifier onlyOriginator() {
        require(msg.sender == originator, "Caller is not the originator");
        _;
    }

    constructor(
        uint256 _termLength,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _maxInterestRate,
        address _originator,
        address DAITokenAddress,
        address proxyAddress,
        address _administrator,
        uint256 _operatorFee,
        uint256 _auctionLength
    ) public {
        DAIToken = ERC20(DAITokenAddress);
        proxy = DAIProxyInterface(proxyAddress);
        originator = _originator;
        administrator = _administrator;

        maxInterestRate = _maxInterestRate;
        minAmount = _minAmount;
        maxAmount = _maxAmount;

        auctionLength = _auctionLength;
        auctionStartTimestamp = block.timestamp;
        auctionEndTimestamp = auctionStartTimestamp + auctionLength;

        termLength = _termLength;

        loanWithdrawnAmount = 0;

        operatorFee = _operatorFee;

        setState(LoanState.CREATED);
        emit LoanCreated(
            address(this),
            originator,
            minAmount,
            maxAmount,
            maxInterestRate,
            auctionStartTimestamp,
            auctionEndTimestamp,
            administrator,
            operatorFee
        );
    }

    function getMaxAmount() external view returns (uint256) {
        return maxAmount;
    }

    function getAuctionBalance() external view returns (uint256) {
        return auctionBalance;
    }

    function getLenderBidAmount(address lender) external view returns (uint256) {
        return lenderPosition[lender].bidAmount;
    }

    function getLenderWithdrawn(address lender) external view returns (bool) {
        return lenderPosition[lender].withdrawn;
    }

    // Notes:
    // - This function does not track if real ERC20 balance has changed. Needs to blindly "trust" DaiProxy.
    function onFundingReceived(address lender, uint256 amount)
        external
        onlyCreated
        onlyProxy
        returns (bool)
    {
        if (isAuctionExpired()) {
            if (auctionBalance < minAmount) {
                setState(LoanState.FAILED_TO_FUND);
                emit FailedToFund(address(this), lender, amount);
                return false;
            } else {
                require(setSuccessfulAuction(), "error while transitioning to successful auction");
                emit FailedToFund(address(this), lender, amount);
                return false;
            }
        }
        uint256 interest = getInterestRate();
        lenderPosition[lender].bidAmount = lenderPosition[lender].bidAmount.add(amount);
        auctionBalance = auctionBalance.add(amount);

        lastFundedTimestamp = block.timestamp;

        if (auctionBalance >= minAmount && !minimumReached) {
            minimumReached = true;
            emit Funded(address(this), lender, amount, interest, lastFundedTimestamp);
            emit MinimumFundingReached(address(this), auctionBalance, interest);
        } else {
            emit Funded(address(this), lender, amount, interest, lastFundedTimestamp);
        }

        if (auctionBalance == maxAmount) {
            require(setSuccessfulAuction(), "error while transitioning to successful auction");
            emit FullyFunded(
                address(this),
                borrowerDebt,
                auctionBalance,
                interest,
                lastFundedTimestamp
            );
        }
        return true;
    }

    function unlockFundsWithdrawal() external onlyAdmin {
        setState(LoanState.FROZEN);
        emit LoanFundsUnlocked(auctionBalance);
    }

    function withdrawFees() external onlyAdmin returns (bool) {
        require(loanWithdrawn == true, "borrower didnt withdraw");
        require(operatorBalance > 0, "no funds to withdraw");
        uint256 allFees = operatorBalance;
        operatorBalance = 0;
        require(DAIToken.transfer(msg.sender, allFees), "transfer failed");
        emit OperatorWithdrawn(allFees, msg.sender);
        return true;
    }

    function withdrawFundsUnlocked() external onlyFrozen {
        require(!loanWithdrawn, "Loan already withdrawn");
        require(!lenderPosition[msg.sender].withdrawn, "Lender already withdrawn");
        require(lenderPosition[msg.sender].bidAmount > 0, "Account did not deposit");

        lenderPosition[msg.sender].withdrawn = true;

        loanWithdrawnAmount = loanWithdrawnAmount.add(lenderPosition[msg.sender].bidAmount);

        require(
            DAIToken.transfer(msg.sender, lenderPosition[msg.sender].bidAmount),
            "error while transfer"
        );

        emit FundsUnlockedWithdrawn(
            address(this),
            msg.sender,
            lenderPosition[msg.sender].bidAmount
        );

        if (loanWithdrawnAmount == auctionBalance.add(operatorBalance)) {
            setState(LoanState.CLOSED);
            emit FullyFundsUnlockedWithdrawn(address(this));
        }
    }

    function withdrawRefund() external onlyFailedToFund {
        require(!lenderPosition[msg.sender].withdrawn, "Lender already withdrawn");
        require(lenderPosition[msg.sender].bidAmount > 0, "Account did not deposited.");

        lenderPosition[msg.sender].withdrawn = true;

        loanWithdrawnAmount = loanWithdrawnAmount.add(lenderPosition[msg.sender].bidAmount);

        emit RefundWithdrawn(address(this), msg.sender, lenderPosition[msg.sender].bidAmount);

        require(
            DAIToken.transfer(msg.sender, lenderPosition[msg.sender].bidAmount),
            "error while transfer"
        );

        if (loanWithdrawnAmount == auctionBalance) {
            setState(LoanState.CLOSED);
            emit FullyRefunded(address(this));
        }
    }

    function withdrawRepayment() external onlyRepaid {
        require(!lenderPosition[msg.sender].withdrawn, "Lender already withdrawn");
        require(lenderPosition[msg.sender].bidAmount != 0, "Account did not deposited");
        uint256 amount = calculateValueWithInterest(lenderPosition[msg.sender].bidAmount);
        lenderPosition[msg.sender].withdrawn = true;
        emit RepaymentWithdrawn(address(this), msg.sender, amount);

        loanWithdrawnAmount = loanWithdrawnAmount.add(amount);
        require(DAIToken.transfer(msg.sender, amount), "error while transfer");

        if (loanWithdrawnAmount == borrowerDebt) {
            setState(LoanState.CLOSED);
            emit FullyRefunded(address(this));
        }
    }

    function withdrawLoan() external onlyActive onlyOriginator {
        require(!loanWithdrawn, "Already withdrawn");

        // if (isDefaulted()) {
        //     setState(LoanState.DEFAULTED);
        //     emit LoanDefaulted(address(this));
        //     return;
        // }

        loanWithdrawn = true;
        emit LoanFundsWithdrawn(address(this), msg.sender, auctionBalance);
        require(DAIToken.transfer(msg.sender, auctionBalance), "error while transfer");
    }

    function onRepaymentReceived(address from, uint256 amount)
        external
        onlyActive
        onlyProxy
        returns (bool)
    {
        require(from == originator, "from address is not the originator");
        // require(amount == borrowerDebt, "Incorrect sum repaid");
        // require(borrowerDebt != 0, "Borrower does not have any debt.");
        require(borrowerDebt == amount, "Repayment amount is not the same");

        // if (isDefaulted()) {
        //     setState(LoanState.DEFAULTED);
        //     emit LoanDefaulted(address(this));
        //     return false;
        // }

        setState(LoanState.REPAID);
        emit LoanRepaid(address(this), block.timestamp);
        return true;
    }

    function isAuctionExpired() public view returns (bool) {
        return block.timestamp > auctionEndTimestamp;
    }

    function isDefaulted() public view returns (bool) {
        if (block.timestamp <= auctionEndTimestamp || block.timestamp <= termEndTimestamp) {
            return false;
        }

        return true;
    }

    function setState(LoanState state) internal {
        currentState = state;
    }

    function updateStateMachine() public returns (LoanState) {
        if (isAuctionExpired() && currentState == LoanState.CREATED) {
            if (!minimumReached) {
                setState(LoanState.FAILED_TO_FUND);
            } else {
                require(setSuccessfulAuction(), "error while transitioning to successful auction");
            }
        }
        if (isDefaulted() && currentState == LoanState.ACTIVE) {
            setState(LoanState.DEFAULTED);
            emit LoanDefaulted(address(this));
        }

        return currentState;
    }

    function calculateValueWithInterest(uint256 value) public view returns (uint256) {
        return
            value.add(
                value.mul(getInterestRate().mul(termLength).div(MONTH_SECONDS)).div(ONE_HUNDRED)
            );
    }

    function getInterestRate() public view returns (uint256) {
        if (currentState == LoanState.CREATED) {
            return
                maxInterestRate.mul(block.timestamp.sub(auctionStartTimestamp)).div(
                    auctionEndTimestamp.sub(auctionStartTimestamp)
                );
        } else if (currentState == LoanState.ACTIVE || currentState == LoanState.REPAID) {
            return
                maxInterestRate.mul(lastFundedTimestamp.sub(auctionStartTimestamp)).div(
                    auctionEndTimestamp.sub(auctionStartTimestamp)
                );
        } else {
            return 0;
        }
    }

    function setSuccessfulAuction() internal onlyCreated returns (bool) {
        setState(LoanState.ACTIVE);
        borrowerDebt = calculateValueWithInterest(auctionBalance);
        operatorBalance = auctionBalance.mul(operatorFee).div(ONE_HUNDRED);
        auctionBalance = auctionBalance - operatorBalance;

        if (block.timestamp < auctionEndTimestamp) {
            termEndTimestamp = block.timestamp.add(termLength);
        } else {
            termEndTimestamp = auctionEndTimestamp.add(termLength);
        }

        emit AuctionSuccessful(
            address(this),
            borrowerDebt,
            auctionBalance,
            operatorBalance,
            getInterestRate(),
            lastFundedTimestamp
        );
        return true;
    }
}

// File: contracts/LoanContractDispatcher.sol

pragma solidity 0.5.10;



contract LoanContractDispatcher is Ownable {
    Authorization auth;
    address DAITokenAddress;
    address DAIProxyAddress;

    address public administrator;

    uint256 public operatorFee;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public minTermLength;
    uint256 public minAuctionLength;

    uint256 public minInterestRate;
    uint256 public maxInterestRate;

    mapping(address => bool) public isLoanContract;

    modifier onlyKYC {
        require(auth.isKYCConfirmed(msg.sender), "user does not have KYC");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == administrator, "Caller is not an administrator");
        _;
    }

    event LoanContractCreated(
        address loanDispatcher,
        address contractAddress,
        address indexed originator,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 maxInterestRate,
        uint256 termEndTimestamp,
        address indexed administrator,
        uint256 operatorFee,
        uint256 auctionLength
    );

    event MinAmountUpdated(uint256 minAmount, address loanDispatcher);
    event MaxAmountUpdated(uint256 maxAmount, address loanDispatcher);
    event MinInterestRateUpdated(uint256 minInterestRate, address loanDispatcher);
    event MaxInterestRateUpdated(uint256 maxInterestRate, address loanDispatcher);
    event OperatorFeeUpdated(uint256 operatorFee, address loanDispatcher, address administrator);

    event AuthAddressUpdated(address newAuthAddress, address administrator);
    event DaiTokenAddressUpdated(address newDaiTokenAddress, address administrator);
    event DaiProxyAddressUpdated(address newDaiProxyAddress, address administrator);

    event AdministratorUpdated(address newAdminAddress);

    constructor(address authAddress, address _DAITokenAddress, address _DAIProxyAddress) public {
        auth = Authorization(authAddress);
        DAITokenAddress = _DAITokenAddress;
        DAIProxyAddress = _DAIProxyAddress;

        minAmount = 1e18; //1000000000000000000; // Minimum 1 DAI
        maxAmount = 2500000e18; //2500000000000000000000000; // Maximum 2.5 Million DAI

        minInterestRate = 0;
        maxInterestRate = 20e18; //20000000000000000000; // Max default MiR 20% / 240% APR

        operatorFee = 1e18; //1000000000000000000; // 1 % operator fee, expressed in wei
        minTermLength = 2592000;
        minAuctionLength = 2592000;
    }

    function setDaiTokenAddress(address daiAddress) external onlyAdmin {
        DAITokenAddress = daiAddress;
        emit DaiTokenAddressUpdated(DAITokenAddress, administrator);
    }

    function setAuthAddress(address authAddress) external onlyAdmin {
        auth = Authorization(authAddress);
        emit AuthAddressUpdated(authAddress, administrator);
    }

    function setDaiProxyAddress(address daiProxyAddress) external onlyAdmin {
        DAIProxyAddress = daiProxyAddress;
        emit DaiProxyAddressUpdated(DAIProxyAddress, administrator);
    }

    function setAdministrator(address admin) external onlyOwner {
        administrator = admin;
        emit AdministratorUpdated(administrator);
    }

    function setOperatorFee(uint256 newFee) external onlyAdmin {
        operatorFee = newFee;
        emit OperatorFeeUpdated(operatorFee, address(this), msg.sender);
    }

    function setMinAmount(uint256 requestedMinAmount) external onlyAdmin {
        require(
            requestedMinAmount <= maxAmount,
            "Minimum amount needs to be lesser or equal than maximum amount"
        );
        minAmount = requestedMinAmount;
        emit MinAmountUpdated(minAmount, address(this));
    }

    function setMaxAmount(uint256 requestedMaxAmount) external onlyAdmin {
        require(
            requestedMaxAmount >= minAmount,
            "Maximum amount needs to be greater or equal than minimum amount"
        );
        maxAmount = requestedMaxAmount;
        emit MaxAmountUpdated(maxAmount, address(this));
    }

    function setMinInterestRate(uint256 requestedMinInterestRate) external onlyAdmin {
        require(
            requestedMinInterestRate <= maxInterestRate,
            "Minimum interest needs to be lesser or equal than maximum interest"
        );
        minInterestRate = requestedMinInterestRate;
        emit MinInterestRateUpdated(minInterestRate, address(this));
    }

    function setMaxInterestRate(uint256 requestedMaxInterestRate) external onlyAdmin {
        require(
            requestedMaxInterestRate >= minInterestRate,
            "Maximum interest needs to be greater or equal than minimum interest"
        );
        maxInterestRate = requestedMaxInterestRate;
        emit MaxInterestRateUpdated(maxInterestRate, address(this));
    }

    function setMinTermLength(uint256 requestedMinTermLength) external onlyAdmin {
        minTermLength = requestedMinTermLength;
    }

    function setMinAuctionLength(uint256 requestedMinAuctionLength) external onlyAdmin {
        minAuctionLength = requestedMinAuctionLength;
    }

    function deploy(
        uint256 loanMinAmount,
        uint256 loanMaxAmount,
        uint256 loanMaxInterestRate,
        uint256 termLength,
        uint256 auctionLength
    ) external onlyKYC returns (address) {
        require(administrator != address(0), "There is no administrator set");
        require(
            loanMinAmount >= minAmount &&
                loanMinAmount <= maxAmount &&
                loanMinAmount <= loanMaxAmount,
            "minimum amount not correct"
        );
        require(
            loanMaxAmount >= minAmount &&
                loanMaxAmount <= maxAmount &&
                loanMaxAmount >= loanMinAmount,
            "maximum amount not correct"
        );
        require(
            loanMaxInterestRate >= minInterestRate && loanMaxInterestRate <= maxInterestRate,
            "maximum interest rate not correct"
        );
        require(termLength >= minTermLength, "Term length is to small");
        require(auctionLength >= minAuctionLength, "Auction length is to small");

        LoanContract loanContract = new LoanContract(
            termLength,
            loanMinAmount,
            loanMaxAmount,
            loanMaxInterestRate,
            msg.sender,
            DAITokenAddress,
            DAIProxyAddress,
            administrator,
            operatorFee,
            auctionLength
        );
        isLoanContract[address(loanContract)] = true;

        emit LoanContractCreated(
            address(this),
            address(loanContract),
            msg.sender,
            loanMinAmount,
            loanMaxAmount,
            loanMaxInterestRate,
            termLength,
            administrator,
            operatorFee,
            auctionLength
        );

        return address(loanContract);
    }

}
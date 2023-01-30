/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

pragma solidity 0.5.11;

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
        require(msg.sender == owner, "Ownable: the caller must be owner");
        _;
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
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

/**
 * @dev Implementation of the `IERC20` interface.
 *
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

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
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value, "ERC20: burn amount exceeds total supply");
        emit Transfer(account, address(0), value);
    }
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 */
contract Pausable is Ownable {
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
     * @dev Initialize the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Return true if the contract is paused, and false otherwise.
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
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20Burnable, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function burn(uint256 amount) public whenNotPaused {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public whenNotPaused {
        super.burnFrom(account, amount);
    }
}

contract BITSGToken is ERC20Pausable {
    string public constant name = "BitSG Token";
    string public constant symbol = "BITSG";
    uint8 public constant decimals = 8;
    uint256 internal constant INIT_TOTALSUPPLY = 120000000;

    mapping( address => uint256) public lockedAmount;
    mapping (address => LockItem[]) public lockInfo;
    uint256 private constant DAY_TIMES = 24 * 60 * 60;

    event SendAndLockToken(address indexed beneficiary, uint256 lockAmount, uint256 lockTime);
    event ReleaseToken(address indexed beneficiary, uint256 releaseAmount);
    event LockToken(address indexed targetAddr, uint256 lockAmount);
    event UnlockToken(address indexed targetAddr, uint256 releaseAmount);

    struct LockItem {
        address     lock_address;
        uint256     lock_amount;
        uint256     lock_time;
        uint256     lock_startTime;
    }

    /**
     * @dev Constructor. Initialize token allocation.
     */
    constructor() public {
        _totalSupply = formatDecimals(INIT_TOTALSUPPLY);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Send a specified number of tokens from the owner to a beneficiary and lock the tokens for a certain period of time.
     * @param beneficiary Address to receive locked token.
     * @param lockAmount Number of token locked.
     * @param lockDays Number of days locked.
     */
    function sendAndLockToken(address beneficiary, uint256 lockAmount, uint256 lockDays) public onlyOwner {
        require(beneficiary != address(0), "BITSGToken: beneficiary is the zero address");
        require(lockAmount > 0, "BITSGToken: the amount of lock is 0");
        require(lockDays > 0, "BITSGToken: the days of lock is 0");
        // add lock item
        uint256 _lockAmount = formatDecimals(lockAmount);
        uint256 _lockTime = lockDays.mul(DAY_TIMES);
        lockInfo[beneficiary].push(LockItem(beneficiary, _lockAmount, _lockTime, now));
        emit SendAndLockToken(beneficiary, _lockAmount, _lockTime);
        _balances[owner] = _balances[owner].sub(_lockAmount, "BITSGToken: owner doesn't have enough tokens");
        emit Transfer(owner, address(0), _lockAmount);
    }

    /**
     * @dev Release the locked token of the specified address.
     * @param beneficiary A specified address.
     */
    function releaseToken(address beneficiary) public returns (bool) {
        uint256 amount = getReleasableAmount(beneficiary);
        require(amount > 0, "BITSGToken: no releasable tokens");
        for(uint256 i; i < lockInfo[beneficiary].length; i++) {
            uint256 lockedTime = (now.sub(lockInfo[beneficiary][i].lock_startTime));
            if (lockedTime >= lockInfo[beneficiary][i].lock_time) {
                delete lockInfo[beneficiary][i];
            }
        }
        _balances[beneficiary] = _balances[beneficiary].add(amount);
        emit Transfer(address(0), beneficiary, amount);
        emit ReleaseToken(beneficiary, amount);
        return true;
    }

    /**
     * @dev Get the number of releasable tokens at the specified address.
     * @param beneficiary A specified address.
     */
    function getReleasableAmount(address beneficiary) public view returns (uint256) {
        require(lockInfo[beneficiary].length != 0, "BITSGToken: the address has not lock items");
        uint num = 0;
        for(uint256 i; i < lockInfo[beneficiary].length; i++) {
            uint256 lockedTime = (now.sub(lockInfo[beneficiary][i].lock_startTime));
            if (lockedTime >= lockInfo[beneficiary][i].lock_time) {
                num = num.add(lockInfo[beneficiary][i].lock_amount);
            }
        }
        return num;
    }

    /**
     * @dev Lock the specified number of tokens for the target address, this part of the locked token will not be transfered.
     * @param targetAddr The address of the locked token.
     * @param lockAmount The amount of the locked token.
     */
    function lockToken(address targetAddr, uint256 lockAmount) public onlyOwner {
        require(targetAddr != address(0), "BITSGToken: target address is the zero address");
        require(lockAmount > 0, "BITSGToken: the amount of lock is 0");
        uint256 _lockAmount = formatDecimals(lockAmount);
        lockedAmount[targetAddr] = lockedAmount[targetAddr].add(_lockAmount);
        emit LockToken(targetAddr, _lockAmount);
    }

    /**
     * @dev Unlock the locked token at the specified address.
     * @param targetAddr The address of the locked token.
     * @param lockAmount Number of tokens unlocked.
     */
    function unlockToken(address targetAddr, uint256 lockAmount) public onlyOwner {
        require(targetAddr != address(0), "BITSGToken: target address is the zero address");
        require(lockAmount > 0, "BITSGToken: the amount of lock is 0");
        uint256 _lockAmount = formatDecimals(lockAmount);
        if(_lockAmount >= lockedAmount[targetAddr]) {
            lockedAmount[targetAddr] = 0;
        } else {
            lockedAmount[targetAddr] = lockedAmount[targetAddr].sub(_lockAmount);
        }
        emit UnlockToken(targetAddr, _lockAmount);
    }

    // Rewrite the transfer function to prevent locked tokens from being transferred.
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(_balances[msg.sender].sub(lockedAmount[msg.sender]) >= amount, "BITSGToken: transfer amount exceeds the vailable balance of msg.sender");
        return super.transfer(recipient, amount);
    }
    // Rewrite the transferFrom function to prevent locked tokens from being transferred.
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_balances[sender].sub(lockedAmount[sender]) >= amount, "BITSGToken: transfer amount exceeds the vailable balance of sender");
        return super.transferFrom(sender, recipient, amount);
    }

    // Rewrite the burn function to prevent locked tokens from being destroyed.
    function burn(uint256 amount) public {
        require(_balances[msg.sender].sub(lockedAmount[msg.sender]) >= amount, "BITSGToken: destroy amount exceeds the vailable balance of msg.sender");
        super.burn(amount);
    }

    // Rewrite the burnFrom function to prevent locked tokens from being destroyed.
    function burnFrom(address account, uint256 amount) public {
        require(_balances[account].sub(lockedAmount[account]) >= amount, "BITSGToken: destroy amount exceeds the vailable balance of account");
        super.burnFrom(account, amount);
    }

    /**
     * @dev Batch transfer of tokens.
     * @param addrs Array, a group of addresses that receive tokens.
     * @param amounts Array, the number of transferred tokens.
     */
    function batchTransfer(address[] memory addrs, uint256[] memory amounts) public onlyOwner returns(bool) {
        require(addrs.length == amounts.length, "BITSGToken: the length of the two arrays is inconsistent");
        require(addrs.length <= 150, "BITSGToken: the number of destination addresses cannot exceed 150");
        for(uint256 i = 0;i < addrs.length;i++) {
            require(addrs[i] != address(0), "BITSGToken: target address is the zero address");
            require(amounts[i] != 0, "BITSGToken: the number of transfers is 0");
            transfer(addrs[i], formatDecimals(amounts[i]));
        }
        return true;
    }

    function formatDecimals(uint256 value) internal pure returns (uint256) {
        return value.mul(10 ** uint256(decimals));
    }
}
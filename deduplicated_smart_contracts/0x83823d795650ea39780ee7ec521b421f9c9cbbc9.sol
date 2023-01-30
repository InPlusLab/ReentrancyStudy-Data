/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

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


// File: node_modules\openzeppelin-solidity\contracts\utils\Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

pragma solidity ^0.5.0;




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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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

// File: node_modules\openzeppelin-solidity\contracts\GSN\Context.sol

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

// File: openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

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

// File: openzeppelin-solidity\contracts\math\SafeMath.sol

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

// File: zos-lib\contracts\Initializable.sol

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

// File: openzeppelin-eth\contracts\ownership\Ownable.sol

pragma solidity ^0.5.2;


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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: contracts\library\Enums.sol

pragma solidity 0.5.12;

library Enums {
    enum VotingCategory { APPROVE_ATTESTER, SUSPEND_ATTESTER, SUSPEND_DELEGATE, UNSUSPEND_DELEGATE, ARBITRARY }
    enum DelegateRole { NONE, MASTERNODE, VALIDATOR }
}

// File: contracts\governance\IGovernance.sol

pragma solidity 0.5.12;


/**
* @title Governance reference to be used in other contracts
*/
interface IGovernance {
    /**
    * @notice Make generic proposal
    * @param _id Voting id
    * @param _category Voting category
    * @param _address Delegate / Attester affected by voting
    * @param _data Extra data or data for arbitrary voting
    * @param _votingPeriod Period when delegates can vote from proposal submission
    */
    function submitProposal(bytes32 _id, Enums.VotingCategory _category, address _address, bytes32 _data, uint256 _votingPeriod) external;

   /**
   * @notice Vote in favor or against proposal with the specified identifier
   * @param _id Voting id
   * @param _inFavor Support proposal or not
   */
    function vote(bytes32 _id, bool _inFavor) external;

    /**
    * @notice Finalize voting and apply proposed changes if success.
    * This method will fail if voting period is not over.
    * @param _id Voting id
    */
    function finalizeVoting(bytes32 _id) external;

    /**
     * @notice Whether specified delegate is known by governance, created by governance
     * @param _delegate Delegate address to check
     */
    function isDelegateKnown(address _delegate) external view returns (bool);

    /**
    * @notice Create new delegate contract, get bond and transfer ownership to a caller
    * @param _name Delegate name
    * @param _signer Delegate Signer address
    * @param _bond Delegate bond amount
    */
    function createDelegate(bytes32 _name, address _signer, uint256 _bond) external returns (address);

    /**
    * @notice Launches delegate, activates and sets a proper role
    * @param _isAttested Delegate is attested or not
    */
    function launchDelegate(bool _isAttested) external;

    /**
    * @notice Unregister specified delegate. Can only be called by delegate itself
    */
    function unregisterDelegate() external;

    /**
    * @notice Slashes suspended delegate bond to governing council
    * @param _delegate Delegate address
    * @param _amount Tokens amount
    */
    function slashBond(address _delegate, uint256 _amount) external;

    /**
    * @notice Approves specified attester. Can only be called by owner.
    * @param _attester Attester address
    */
    function approveAttester(address _attester) external;

    /**
    * @notice Suspends specified attester. Can only be called by owner.
    * @param _attester Attester address
    */
    function suspendAttester(address _attester) external;

    /**
    * @notice Whether specified attester is valid.
    * @param _attester Attesters address to check
    */
    function isAttesterValid(address _attester) external view returns (bool);

    /**
    * @notice Get governing council address
    */
    function getGoverningCouncil() external view returns(address);

    /**
    * @notice Checks if delegate is validator
    * @param _delegate Delegate to be checked
    */
    function isValidator(address _delegate) external view returns (bool);
}

// File: contracts\governance\IDelegate.sol

pragma solidity 0.5.12;


/**
* @title Delegate reference to be used in other contracts
*/
interface IDelegate {
    /**
    * @notice Init delegate when created. May be called only once.
    */
    function init(address _owner, ERC20 _token, address _governance, bytes32 _name, address _signer) external;

    /**
    * @notice Stake specified amount of tokens
    * @param _amount Amount to stake
    */
    function stake(uint256 _amount) external;

    /**
    * @notice Stake specified amount of tokens for other staker
    * @param _staker Address of a staker
    * @param _amount Amount to stake
    */
    function delegateStake(address _staker, uint256 _amount) external;

    /**
    * @notice Unstake specified amount of tokens
    * @param _amount Amount to unstake
    */
    function unstake(uint256 _amount) external;

    /**
    * @notice Unstake specified amount of tokens for other user
    * @param _staker Address of a staker
    * @param _amount Amount to unstake
    */
    function delegateUnstake(address _staker, uint256 _amount) external;

    /**
    * @notice Return number of tokens staked by the specified staker
    * @param _staker Staker address
    */
    function stakeOfStaker(address _staker) external view returns (uint256);

    /**
    * @notice Stake at the given timestamp
    * @param _timestamp Time for which we would like to check stake
    */
    function stakeOfDelegate(uint256 _timestamp) external view returns (uint256);

    /**
    * @notice Delegated stake for some staker and msg.sender as a caller
    * @param _staker Staker of tokens
    * @param _caller Caller who delegated stake
    */
    function delegatedStakeOfStaker(address _staker, address _caller) external view returns (uint256);

    /**
    * @notice Whether this delegate is activated now
    */
    function isActiveNow() external view returns (bool);

    /**
    * @notice Whether this delegate was activated at the given timestamp
    * @param _timestamp Time for which we would like to check activation status
    */
    function isActive(uint256 _timestamp) external view returns (bool);

    /**
    * @notice Activate delegate.
    */
    function activate() external;

    /**
    * @notice Deactivate delegate
    */
    function deactivate() external;

    /**
    * @notice Delegate owner
    */
    function owner() external view returns(address);

    /**
    * @notice Returns delegate's signer address
    */
    function getSignerAddress() external view returns (address);

    /**
    * @notice Returns delegate's name as bytes32
    */
    function getNameAsBytes() external view returns (bytes32);

    /**
    * @notice Submits delegate attestation data and depending on result approves attestation
    * @param _hash Signed hashed data
    * @param _v V part of signing
    * @param _r R part of signing
    * @param _s S part of signing
    */
    function submitAttestation(bytes32[] calldata _hash, uint8[] calldata _v, bytes32[] calldata _r, bytes32[] calldata _s) external;

    /**
    * @notice Whether this delegate is suspended now
    */
    function isSuspendedNow() external view returns (bool);

    /**
    * @notice Whether this delegate was suspended at the given timestamp
    * @param _timestamp Time for which we would like to check slash
    */
    function isSuspended(uint256 _timestamp) external view returns (bool);

    /**
    * @notice Suspend delegate
    */
    function suspend() external;

    /**
    * @notice Unsuspend delegate
    */
    function unsuspend() external;

    /**
    * @notice Unlocks stakes
    * @param _timeout Timeout at which stake will become available
    */
    function unlockStakes(uint256 _timeout) external;
}

// File: contracts\library\OperationStore.sol

pragma solidity 0.5.12;

library OperationStore {

    /**
     * @notice Stores historical integer data
     * @param _history History of stored int data in format time1, value1, time2, value2, time3...
     * @param _value Value to be stored
     */
    function storeInt(uint256[] storage _history, uint256 _value) internal {
        _history.push(now);
        _history.push(_value);
    }

    /**
     * @notice Returns integer value for specified time
     * @param _history History of stored int data in format time1, value1, time2, value2, time3...
     * @param _timestamp Time for which we get value
     */
    function getInt(uint256[] storage _history, uint256 _timestamp) internal view returns (uint256) {
        uint256 index = findIndex(_history, _timestamp, 2);
        if (index > 0) {
            return _history[index - 1];
        }
        return 0;
    }

    /**
     * @notice Stores historical boolean data
     * @param _history History of stored boolean data in format: new record each times value changed (time1, time2...)
     * @param _value Value to be stored
     */
    function storeBool(uint256[] storage _history, bool _value) internal {
        bool current = (_history.length % 2 == 1);
        if (current != _value) {
            _history.push(now);
        }
    }

    /**
     * @notice Returns boolean value for specified time
     * @param _history History of stored boolean data in format: new record each times value changed (time1, time2...)
     * @param _timestamp Time for which we get value
     */
    function getBool(uint256[] storage _history, uint256 _timestamp) internal view returns (bool) {
        return findIndex(_history, _timestamp, 1) % 2 == 1;
    }

    /**
     * @notice Stores historical timestamp data
     * @param _history History of stored timestamp data in format: time1, time2, time3...
     * @param _value Value to be stored
     */
    function storeTimestamp(uint256[] storage _history, uint256 _value) internal {
        _history.push(_value);
    }

    /**
     * @notice Returns last timestamp value for specified time
     * @param _history History of stored timestamp data in format: time1, time2, time3...
     * @param _timestamp Time for which we get value
     */
    function getTimestamp(uint256[] storage _history, uint256 _timestamp) internal view returns (uint256) {
        uint256 index = findIndex(_history, _timestamp, 1);
        if (index > 0) {
            return _history[index - 1];
        }
        return 0;
    }

    /**
     * @notice Searches for index of timestamp with specified step
     * @dev History elements is sorted so binary search is used.
     * @param _history History of stored timestamp data in format: time1, time2, time3...
     * @param _timestamp Time for which we get value
     * @param _step Step used for binary search. For bool & timestamp steps is 1, for uint step is 2
     */
    function findIndex(uint256[] storage _history, uint256 _timestamp, uint256 _step) internal view returns (uint256) {
        if (_history.length == 0) {
            return 0;
        }
        uint256 low = 0;
        uint256 high = _history.length - _step;

        while (low <= high) {
            uint256 mid = ((low + high) >> _step) << (_step - 1);
            uint256 midVal = _history[mid];
            if (midVal < _timestamp) {
                low = mid + _step;
            } else if (midVal > _timestamp) {
                if (mid == 0) {
                    return 0;
                    // min key
                }
                high = mid - _step;
            } else {
                // take the last one if there are many same items
                uint256 result = mid + _step;
                while (result < _history.length && _history[result] == _timestamp) {
                    result = result + _step;
                }
                // key found
                return result;
            }
        }
        // key not found
        return low;
    }

}

// File: contracts\library\Conversions.sol

pragma solidity 0.5.12;

library Conversions {
    /**
     * @notice Converts bytes32 to string
     */
    function bytes32ToString(bytes32 _input) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        uint256 index = 0;
        for (index = 0; index < 32; index++) {
            byte char = byte(bytes32(uint256(_input) * 2 ** (8 * index)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (index = 0; index < charCount; index++) {
            bytesStringTrimmed[index] = bytesString[index];
        }
        return string(bytesStringTrimmed);
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

// File: contracts\library\AddressSet.sol

pragma solidity 0.5.12;

/// @title An implementation of the set data structure for addresses.
/// @author Noah Zinsmeister
/// @dev O(1) insertion, removal, contains, and length functions.
library AddressSet {
    struct Set {
        address[] members;
        mapping(address => uint) memberIndices;
    }

    /// @dev Inserts an element into a set. If the element already exists in the set, the function is a no-op.
    /// @param self The set to insert into.
    /// @param other The element to insert.
    function insert(Set storage self, address other) public {
        if (!contains(self, other)) {
            self.memberIndices[other] = self.members.push(other);
        }
    }

    /// @dev Removes an element from a set. If the element does not exist in the set, the function is a no-op.
    /// @param self The set to remove from.
    /// @param other The element to remove.
    function remove(Set storage self, address other) public {
        if (contains(self, other)) {
            // replace other with the last element
            self.members[self.memberIndices[other] - 1] = self.members[length(self) - 1];
            // reflect this change in the indices
            self.memberIndices[self.members[self.memberIndices[other] - 1]] = self.memberIndices[other];
            delete self.memberIndices[other];
            // remove the last element
            self.members.pop();
        }
    }

    /// @dev Checks set membership.
    /// @param self The set to check membership in.
    /// @param other The element to check membership of.
    /// @return true if the element is in the set, false otherwise.
    function contains(Set storage self, address other) public view returns (bool) {
        return ( // solium-disable-line operator-whitespace
        self.memberIndices[other] > 0 &&
        self.members.length >= self.memberIndices[other] &&
        self.members[self.memberIndices[other] - 1] == other
        );
    }

    /// @dev Returns the number of elements in a set.
    /// @param self The set to check the length of.
    /// @return The number of elements in the set.
    function length(Set storage self) public view returns (uint) {
        return self.members.length;
    }
}

// File: contracts\token\TokenRecipient.sol

pragma solidity 0.5.12;

/**
* @dev Interface to use the receiveApproval method
**/
interface TokenRecipient {

    /**
    * @notice Receives a notification of approval of the transfer
    * @param _from Sender of approval
    * @param _value  The amount of tokens to be spent
    * @param _tokenContract Address of the token contract
    * @param _extraData Extra data
    **/
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata _extraData) external returns (bool);

}

// File: contracts\upgradeability\ParameterizedInitializable.sol

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
contract ParameterizedInitializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    mapping(string => bool) private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    mapping(string => bool) private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initiator(string memory _label) {
        require(initializing[_label] || isConstructor() || !initialized[_label], "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing[_label];
        if (isTopLevelCall) {
            initializing[_label] = true;
            initialized[_label] = true;
        }

        _;

        if (isTopLevelCall) {
            initializing[_label] = false;
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
        assembly {cs := extcodesize
        (address) }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

// File: contracts\governance\Delegate.sol

pragma solidity 0.5.12;













/**
 * @title Ethereum-based contract for delegate
 */
contract Delegate is IDelegate, TokenRecipient, ParameterizedInitializable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using OperationStore for uint256[];
    using Conversions for bytes32;
    using Conversions for address;
    using AddressSet for AddressSet.Set;

    struct Attestation {
        bool done;
        address attester;
        bytes32[] hashes;
        uint256 time;
    }

    /** Token **/
    ERC20 public token;

    /** Governance address **/
    IGovernance public governance;

    /** Description name of the delegate */
    bytes32 public name;

    /** Signer address used for coin distribution */
    address public signerAddress;

    /** Attestations **/
    Attestation public attestation;

    /** Delegate stakers */
    AddressSet.Set private stakers;

    /** Stake in the delegate */
    uint256[] delegateStakeHistory;

    /** Are stakes locked in the delegate */
    bool stakesLocked;

    /** Time at which stakes have been unlocked */
    uint256 public stakesUnlockedOn;

    /** Stake per user address in the delegate */
    mapping(address => uint256) public stakes;

    /** Delegated stake per user address in the delegate */
    mapping(address => mapping(address => uint256)) public delegatedStakes;

    /** History on when delegate was activated or not */
    uint256[] public activationHistory;

    /** History on when delegate was suspended or not */
    uint256[] public suspendHistory;

    event ActivationStatusUpdated(bool activated);
    event SuspendStatusUpdated(bool suspended);
    event StakeLocked(bool locked);

    event Staked(address indexed staker, address indexed caller, uint256 amount);
    event Unstaked(address indexed staker, address indexed caller, uint256 amount);

    /** Check if the sender is a governance */
    modifier onlyGovernance {
        require(msg.sender == address(governance), 'msg.sender should be governance');
        _;
    }

    /** Check if the sender is governance or owner */
    modifier onlyOwnerOrGovernance {
        require((msg.sender == address(governance)) || (msg.sender == owner()), 'msg.sender should be or delegate owner');
        _;
    }

    /** Check if the sender is a valid governing council */
    modifier onlyGoverningCouncil {
        require(msg.sender == governance.getGoverningCouncil(), 'msg.sender should be governing council');
        _;
    }

    /** Check if the sender is governance or governing council */
    modifier onlyGoverningCouncilOrGovernance {
        require((msg.sender == address(governance)) || (msg.sender == governance.getGoverningCouncil()), 'msg.sender should be governance or governing council');
        _;
    }

    /**
    * @notice Delegate initializer
    * @dev This init is called by governance when created
    * @param _owner Delegate owner address
    * @param _token Token address
    * @param _governance Governance address
    * @param _name Delegate name
    * @param _signer Delegate signer address
    */
    function init(address _owner, ERC20 _token, address _governance, bytes32 _name, address _signer)
        initiator("v1") public {
        Ownable.initialize(_owner);
        name = _name;
        token = _token;
        signerAddress = _signer;
        governance = IGovernance(_governance);
    }

    /**
    * @notice Returns delegate name as string
    */
    function getName() public view returns (string memory) {
        return name.bytes32ToString();
    }

    /**
    * @notice Returns delegate's name as bytes32
    */
    function getNameAsBytes() external view returns (bytes32) {
        return name;
    }

    /**
    * @notice Returns delegate's signer address.
    * We cannot have setter for it as in this case we need store history of addresses
    */
    function getSignerAddress() external view returns (address) {
        return signerAddress;
    }

    /**
    * @notice Whether this delegate is activated now
    */
    function isActiveNow() public view returns (bool) {
        return isActive(now);
    }

    /**
    * @notice Whether this delegate was activated at the given timestamp
    * @param _timestamp Time for which we would like to check activation status
    */
    function isActive(uint256 _timestamp) public view returns (bool) {
        return activationHistory.getBool(_timestamp);
    }

    /**
    * @notice Launches delegate. Sets active.
    */
    function launch() external onlyOwner {
        governance.launchDelegate(attestation.done);
    }

    /**
    * @notice Activate delegate.
    */
    function activate() external onlyGovernance {
        _activate(true);
    }

    /**
    * @notice Deactivate delegate. Note we don't need activate for now. It's done via attestations
    */
    function deactivate() external onlyGovernance {
        _activate(false);
    }

    /**
    * @notice Change delegate activations status
    * @param _active Is delegate active or not
    */
    function _activate(bool _active) internal {
        activationHistory.storeBool(_active);
        emit ActivationStatusUpdated(_active);
    }

    /**
    * @notice Stake specified amount of tokens
    * @param _amount Amount to stake
    */
    function stake(uint256 _amount) external {
        _stake(msg.sender, msg.sender, _amount);
    }

    /**
    * @notice Stake specified amount of tokens for other staker
    * @param _staker Address of a staker
    * @param _amount Amount to stake
    */
    function delegateStake(address _staker, uint256 _amount) external {
        _stake(msg.sender, _staker, _amount);
    }

    /**
    * @notice Stake specified amount of tokens
    * @param _caller Address of a person who delegates a stake
    * @param _staker Address of a staker
    * @param _amount Amount to stake
    */
    function _stake(address _caller, address _staker, uint256 _amount) internal {
        require(_amount > 0, 'Amount should be more than 0');
        require(isActiveNow(), 'Delegate is not active');
        require(!isSuspendedNow(), 'Delegate is suspended');
        require(governance.isValidator(address(this)), 'Delegate is not validator');

        token.safeTransferFrom(_caller, address(this), _amount);

        stakers.insert(_staker);

        stakes[_staker] = stakes[_staker].add(_amount);
        delegatedStakes[_staker][_caller] = delegatedStakes[_staker][_caller].add(_amount);
        delegateStakeHistory.storeInt(delegateStakeHistory.getInt(now).add(_amount));

        emit Staked(_staker, _caller, _amount);
    }

    /**
    * @notice Unstake specified amount of tokens
    * @param _amount Amount to unstake
    */
    function unstake(uint256 _amount) external {
        _unstake(msg.sender, msg.sender, _amount);
    }

    /**
    * @notice Unstake specified amount of tokens for other user
    * @param _staker Address of a staker
    * @param _amount Amount to unstake
    */
    function delegateUnstake(address _staker, uint256 _amount) external {
        _unstake(msg.sender, _staker, _amount);
    }

    /**
    * @notice Unstake specified amount of tokens
    * @param _caller Address of a person who delegates a stake
    * @param _staker Address of a staker
    * @param _amount Amount to unstake
    */
    function _unstake(address _caller, address _staker, uint256 _amount) internal {
        require(!stakesLocked, 'Delegate stakes are locked');
        require(stakesUnlockedOn <= now, 'Delegate stakes are not unlocked yet');
        require(delegatedStakes[_staker][_caller] >= _amount, 'Too large amount of tokens to unstake specified');
        require(token.balanceOf(address(this)) >= _amount, 'Not enough tokens balance');

        stakes[_staker] = stakes[_staker].sub(_amount);
        delegatedStakes[_staker][_caller] = delegatedStakes[_staker][_caller].sub(_amount);
        delegateStakeHistory.storeInt(delegateStakeHistory.getInt(now).sub(_amount));

        if (stakes[_staker] == 0) {
            stakers.remove(_staker);
        }

        token.safeTransfer(_caller, _amount);

        emit Unstaked(_staker, _caller, _amount);
    }

    /**
    * @notice Return number of tokens staked by the specified staker
    * @param _staker Staker address
    */
    function stakeOfStaker(address _staker) external view returns (uint256) {
        return stakes[_staker];
    }

    /**
    * @notice Stake at the given timestamp
    * @param _timestamp Time for which we would like to check stake
    */
    function stakeOfDelegate(uint256 _timestamp) public view returns (uint256) {
        return delegateStakeHistory.getInt(_timestamp);
    }

    /**
    * @notice Delegated stake for some staker and msg.sender as a caller
    * @param _staker Staker of tokens
    * @param _caller Caller who delegated stake
    */
    function delegatedStakeOfStaker(address _staker, address _caller) public view returns (uint256) {
        return delegatedStakes[_staker][_caller];
    }

    /**
    * @notice Get delegate stakers
    */
    function getStakerAddresses() public view returns (address[] memory) {
        return stakers.members;
    }

    /**
    * @notice Get delegate stakers and stakes
    */
    function getStakers() public view returns (address[] memory, uint256[] memory) {
        uint256[] memory stakerStakes = new uint256[](stakers.length());
        for (uint256 index = 0; index < stakers.length(); index++) {
            stakerStakes[index] = stakes[stakers.members[index]];
        }
        return (stakers.members, stakerStakes);
    }

    /**
    * @notice Make generic proposal
    * @param _id Voting id
    * @param _category Voting category
    * @param _address Delegate / Attester affected by voting
    * @param _data Extra data or data for arbitrary voting
    * @param _votingPeriod Period when delegates can vote from proposal submission
    */
    function submitProposal(bytes32 _id, Enums.VotingCategory _category, address _address, bytes32 _data, uint256 _votingPeriod) external onlyOwner {
        governance.submitProposal(_id, _category, _address, _data, _votingPeriod);
    }

    /**
    * @notice Vote in favor or against blacklist proposal with the specified identifier
    * @param _id Proposal / voting id
    * @param _inFavor Support or do not support proposal
    */
    function vote(bytes32 _id, bool _inFavor) external onlyOwner {
        governance.vote(_id, _inFavor);
    }

    /**
    * @notice Finalize voting and apply proposed changes if success.
    * This method will fail if voting period is not over.
    * @param _id Proposal / voting id
    */
    function finalizeVoting(bytes32 _id) external {
        governance.finalizeVoting(_id);
    }

    /**
    * @notice Submits delegate attestation data and depending on result approves attestation
    * @param _hashes Signed hashed data [hashOfHashes, nameHash, emailHash, countryHash, dateHash]
    * @param _v V part of signing
    * @param _r R part of signing
    * @param _s S part of signing
    */
    function submitAttestation(bytes32[] calldata _hashes, uint8[] calldata _v, bytes32[] calldata _r, bytes32[] calldata _s) external {
        require(_hashes.length == 5, 'Hash should be provided');

        address attester = ecrecover(_hashes[0], _v[0], _r[0], _s[0]);

        for (uint index = 0; index < _hashes.length; index++) {
            address hashAttester = ecrecover(_hashes[index], _v[index], _r[index], _s[index]);
            require(hashAttester == attester, 'Hashes should be from the same attester');
            require(governance.isAttesterValid(hashAttester), 'Hash should be signed with valid attester');
        }

        // NOTE: Next loop we start from 1 and hash[0] is hash of text
        bytes32 hash = keccak256(abi.encodePacked('I hereby certify that I have reviewed the documents confirming the identity of the applicant, their country of registration or citizenship, date of registration or birth and the ethereum delegate contract address to be associated with the applicant.'));
        for (uint index = 1; index < _hashes.length; index++) {
            hash = keccak256(abi.encodePacked(hash, _hashes[index]));
        }
        hash = keccak256(abi.encodePacked(hash, keccak256(abi.encodePacked(address(this)))));
        require(_hashes[0] == hash, 'Zero hash should be valid for current delegate');

        attestation = Attestation({
            done : true,
            attester : attester,
            hashes : _hashes,
            time: now
        });
    }

    /**
    * @notice Returns attestation information
    */
    function getAttestation() external view returns (bool, address, bytes32[] memory, uint256) {
        return (attestation.done, attestation.attester, attestation.hashes, attestation.time);
    }

    /**
    * @notice Whether this delegate is suspended
    */
    function isSuspendedNow() public view returns (bool) {
        return isSuspended(now);
    }

    /**
    * @notice Whether this delegate was suspended at the given timestamp
    * @param _timestamp Time for which we would like to check suspend
    */
    function isSuspended(uint256 _timestamp) public view returns (bool) {
        return suspendHistory.getBool(_timestamp);
    }

    /**
    * @notice Suspend delegate
    */
    function suspend() external onlyGovernance {
        _suspend(true);
    }

    /**
    * @notice Unsuspend delegate
    */
    function unsuspend() external onlyGoverningCouncilOrGovernance {
        _suspend(false);
    }

    /**
    * @notice Change delegate suspend status
    * @param _suspended Suspend delegate or not
    */
    function _suspend(bool _suspended) internal {
        stakesUnlockedOn = 0;
        suspendHistory.storeBool(_suspended);
        emit SuspendStatusUpdated(_suspended);

        stakesLocked = _suspended;
        emit StakeLocked(_suspended);
    }

    /**
    * @notice Unlocks stakes
    * @param _timeout Timeout at which stake will become available
    */
    function unlockStakes(uint256 _timeout) external onlyGoverningCouncil {
        stakesUnlockedOn = now.add(_timeout);
        stakesLocked = false;
        emit StakeLocked(false);
    }

    /**
    * @notice Unregister delegate and return bond back
    */
    function unregister() external onlyOwner {
        governance.unregisterDelegate();
    }

    /**
    * @notice Implementation of receiveApproval interface for ERC20 token with approveAndCall support
    */
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata /**_extraData */) external returns (bool) {
        require(_tokenContract == address(token), 'Token in approval call is invalid');
        _stake(_from, _from, _value);
        return true;
    }
}
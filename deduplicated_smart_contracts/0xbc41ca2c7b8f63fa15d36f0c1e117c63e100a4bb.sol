/**
 *Submitted for verification at Etherscan.io on 2020-03-04
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
    function getInt(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {
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
    function getBool(uint256[] memory _history, uint256 _timestamp) internal pure returns (bool) {
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
    function getTimestamp(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {
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
    function findIndex(uint256[] memory _history, uint256 _timestamp, uint256 _step) internal pure returns (uint256) {
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

// File: node_modules\zos-lib\contracts\upgradeability\Proxy.sol

pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

// File: node_modules\zos-lib\contracts\utils\Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library ZOSLibAddress {
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

// File: node_modules\zos-lib\contracts\upgradeability\BaseUpgradeabilityProxy.sol

pragma solidity ^0.5.0;



/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
   * validated in the constructor.
   */
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) internal {
    require(ZOSLibAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

// File: node_modules\zos-lib\contracts\upgradeability\UpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Contract constructor.
   * @param _logic Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}

// File: node_modules\zos-lib\contracts\upgradeability\BaseAdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
   * validated in the constructor.
   */
  bytes32 internal constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  /**
   * @return The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  /**
   * @dev Only fall back when the sender is not the admin.
   */
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}

// File: zos-lib\contracts\upgradeability\AdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title AdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for 
 * initializing the implementation, admin, and init data.
 */
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));
    _setAdmin(_admin);
  }
}

// File: contracts\upgradeability\OwnedUpgradeabilityProxy.sol

pragma solidity 0.5.12;


/**
 * @title OwnedUpgradeabilityProxy
 * @notice This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract OwnedUpgradeabilityProxy is AdminUpgradeabilityProxy {

    /**
     * Contract constructor.
     * It sets the `msg.sender` as the proxy administrator.
     * @param _implementation address of the initial implementation.
     * @param _admin upgradeability admin.
     */
    constructor(address _implementation, address _admin) AdminUpgradeabilityProxy(_implementation, _admin, "") public {
    }

    /**
     * @notice Only fall back when the sender is not the admin.
     */
    function _willFallback() internal {
    }
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

// File: contracts\governance\Governance.sol

pragma solidity 0.5.12;












/**
 * @title Ethereum-based governance contract
 */
contract Governance is IGovernance, ParameterizedInitializable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using OperationStore for uint256[];
    using AddressSet for AddressSet.Set;

    /** XRM token */
    ERC20 public token;

    /** Bond required for delegate to be registered with validator role. Should be more than 100M */
    uint256 public validatorBond;

    /** Bond required for delegate to be registered with masternode role. Should be more than 10M */
    uint256 public masternodeBond;

    /** User used to upgrade governance or delegate contracts. Owner by default */
    address public upgradeAdmin;

    /** User used to penalty delegate. Owner by default */
    address public governingCouncil;

    /** Delegate template */
    address public delegateTemplate;

    /** List of all attester */
    AddressSet.Set internal attesters;

    /** List of all delegates */
    AddressSet.Set internal delegates;

    /** List of delegates bond history */
    mapping(address => uint256[]) public bondHistory;

    /** Delegate role mapping  */
    mapping(address => Enums.DelegateRole) public delegateRoles;

    struct Voting {
        bytes32 id;
        Enums.VotingCategory category;
        address account;
        bytes32 data;
        uint256 votingPeriod;
        uint256 timestamp;
        bool supported;
        mapping(address => bool) votes;
        AddressSet.Set voters;
    }

    /** List of active votings */
    mapping(bytes32 => Voting) private votings;

    event UpgradeAdminUpdated(address admin);
    event GoverningCouncilUpdated(address admin);
    event UpdateDelegateTemplate(address template);

    event DelegateCreated(address indexed delegate, address indexed owner);
    event DelegateUnregistered(address indexed delegate);
    event DelegateBondIncreased(address indexed delegate, uint256 amount);
    event DelegateBondSlashed(address indexed delegate, uint256 amount);
    event DelegateRoleUpdated(address indexed delegate, Enums.DelegateRole indexed role);

    event ProposalSubmitted(bytes32 indexed id, address indexed author, address indexed delegate, bytes32 data, Enums.VotingCategory category);
    event Vote(bytes32 indexed id, address indexed voter, bool inFavor);
    event VotingFinalized(bytes32 indexed id, bool voted, bool supported, uint256 proponentsWeight, uint256 opponentsWeight);
    event AttesterApproved(address indexed attester);
    event AttesterSuspended(address indexed attester);

    /** Check if delegate is known **/
    modifier onlyKnownDelegate(address delegate) {
        require(delegates.contains(delegate), 'Delegate is unknown');
        _;
    }

    /** Check if sender governing council **/
    modifier onlyGoverningCouncil() {
        require(msg.sender == governingCouncil, 'msg.sender should be governance council');
        _;
    }

    /** Check if the sender is a upgrade admin **/
    modifier onlyUpgradeAdmin {
        require(msg.sender == upgradeAdmin, 'msg.sender should be upgrade admin');
        _;
    }

    /** Check if the sender is a valid delegate **/
    modifier onlyValidDelegate {
        require(isDelegateValid(msg.sender, now), 'Delegate is not valid');
        _;
    }

    /**
    * @notice Governance initializer
    * @param _owner Governance owner address
    * @param _token XRM token address
    * @param _validatorBond Validator delegate bond to be sent to create new delegate
    * @param _masternodeBond Masternode delegate bond to be sent to create new delegate
    */
    function init(
        address _owner, address _token, address _delegateTemplate, uint256 _validatorBond, uint256 _masternodeBond
    ) initiator("v1") public {
        require(_owner != address(0), 'Owner is empty');
        require(_token != address(0), 'Token address is empty');
        require(_delegateTemplate != address(0), 'Delegate template is empty');
        require(_validatorBond >= _masternodeBond, 'Validator bond should not be less than masternode one');

        Ownable.initialize(_owner);
        token = ERC20(_token);
        delegateTemplate = _delegateTemplate;

        validatorBond = _validatorBond;
        masternodeBond = _masternodeBond;
        upgradeAdmin = _owner;
        governingCouncil = _owner;
    }

    /**
    * @notice Set admin who can upgrade delegate contracts
    * @param _admin New upgradeability admin
    */
    function setUpgradeAdmin(address _admin) external onlyOwner {
        upgradeAdmin = _admin;
        emit UpgradeAdminUpdated(_admin);
    }

    /**
    * @notice Set governing council
    * @param _address New governing council address
    */
    function setGoverningCouncil(address _address) external onlyOwner {
        governingCouncil = _address;
        emit GoverningCouncilUpdated(_address);
    }

    /**
    * @notice Set delegate template
    * @param _template New delegate template
    */
    function setDelegateTemplate(address _template) external onlyUpgradeAdmin {
        delegateTemplate = _template;
        emit UpdateDelegateTemplate(_template);
    }

    /**
    * @notice Set new validator bond
    * @param _bond New bond amount
    */
    function setValidatorBond(uint256 _bond) external onlyOwner {
        require(_bond > 0, 'Provided bond is 0');
        require(_bond >= masternodeBond, 'Validator bond should not be less than masternode one');

        validatorBond = _bond;
    }

    /**
    * @notice Set new masternode bond
    * @param _bond New bond amount
    */
    function setMasternodeBond(uint256 _bond) external onlyOwner {
        require(_bond > 0, 'Provided bond is 0');
        require(validatorBond >= _bond, 'Validator bond should not be less than masternode one');

        masternodeBond = _bond;
    }

    /**
    * @notice Get governing council address
    */
    function getGoverningCouncil() external view returns (address) {
        return governingCouncil;
    }

    /**
    * @notice Get delegate template
    */
    function getDelegateTemplate() external view returns (address) {
        return delegateTemplate;
    }

    /**
    * @notice Whether specified delegate is known by governance, created by governance
    * @param _delegate Delegate address to check
    */
    function isDelegateKnown(address _delegate) public view returns (bool) {
        return delegates.contains(_delegate);
    }

    /**
    * @notice Create new delegate contract, get bond and transfer ownership to a caller
    * @param _name Delegate name
    * @param _signer Delegate Signer address
    * @param _bond Delegate bond amount
    */
    function createDelegate(bytes32 _name, address _signer, uint256 _bond) external returns (address) {
        require(_bond >= masternodeBond, 'Bond should be more than masternode bond');
        address delegateOwner = msg.sender;

        token.safeTransferFrom(delegateOwner, address(this), _bond);

        // Setup delegate proxy
        OwnedUpgradeabilityProxy proxy = new OwnedUpgradeabilityProxy(address(delegateTemplate), upgradeAdmin);
        address delegateAddress = address(proxy);

        // Init delegate via proxy
        IDelegate(delegateAddress).init(delegateOwner, token, address(this), _name, _signer);

        delegates.insert(delegateAddress);
        bondHistory[delegateAddress].storeInt(_bond);

        emit DelegateCreated(delegateAddress, delegateOwner);

        return delegateAddress;
    }

    /**
    * @notice Launches delegate, activates and sets a proper role
    * @param _isAttested Delegate is attested or not
    */
    function launchDelegate(bool _isAttested) external onlyKnownDelegate(msg.sender) {
        if(bondOfDelegateNow(msg.sender) >= validatorBond && _isAttested) {
            IDelegate(msg.sender).activate();
            delegateRoles[msg.sender] = Enums.DelegateRole.VALIDATOR;
            emit DelegateRoleUpdated(msg.sender, Enums.DelegateRole.VALIDATOR);
        } else if(bondOfDelegateNow(msg.sender) >= masternodeBond) {
            IDelegate(msg.sender).activate();
            delegateRoles[msg.sender] = Enums.DelegateRole.MASTERNODE;
            emit DelegateRoleUpdated(msg.sender, Enums.DelegateRole.MASTERNODE);
        }
    }

    /**
    * @notice Unregister specified delegate. Can only be called by delegate itself. It's not possible to register back. Only new delegate.
    */
    function unregisterDelegate() external onlyKnownDelegate(msg.sender) {
        address delegateAddress = msg.sender;
        IDelegate delegate = IDelegate(delegateAddress);

        // Make sure delegate not suspended
        require(!delegate.isSuspendedNow(), 'Delegate is suspended');

        // Return all bond back
        uint256 bond = bondOfDelegateNow(delegateAddress);
        bondHistory[delegateAddress].storeInt(0);
        token.safeTransfer(delegate.owner(), bond);

        // Set role to NONE
        delegateRoles[delegateAddress] = Enums.DelegateRole.NONE;

        // Deactivate delegate
        delegate.deactivate();

        emit DelegateUnregistered(delegateAddress);
    }

    /**
    * @notice Slash suspended delegate bond to governing council
    * @param _delegate Delegate address
    * @param _amount Tokens amount
    */
    function slashBond(address _delegate, uint256 _amount) external onlyGoverningCouncil {
        require(isDelegateKnown(_delegate), 'Delegate is unknown');

        IDelegate delegate = IDelegate(_delegate);
        require(delegate.isSuspended(now), 'Delegate is not suspended');

        uint256 bond = bondOfDelegateNow(_delegate);
        require(bond >= _amount, 'Bond should be larger than slashing amount');

        bondHistory[_delegate].storeInt(bond.sub(_amount));
        token.safeTransfer(governingCouncil, _amount);

        emit DelegateBondSlashed(_delegate, _amount);
    }

    /**
    * @notice Increase bond for specified delegate, should be used when unregistered delegate wants to be registered again
    * @param _delegate Delegate which will receive bond
    * @param _amount Bond amount
    */
    function increaseBond(address _delegate, uint256 _amount) external onlyKnownDelegate(_delegate) {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        bondHistory[_delegate].storeInt(bondOfDelegateNow(_delegate).add(_amount));

        emit DelegateBondIncreased(_delegate, _amount);
    }

    /**
    * @notice Approves specified attester. Can only be called by owner.
    * @param _attester Attester address
    */
    function approveAttester(address _attester) external onlyGoverningCouncil {
        require(_attester != address(0), 'Attester address is empty');

        attesters.insert(_attester);
        emit AttesterApproved(_attester);
    }

    /**
    * @notice Suspends specified attester. Can only be called by owner.
    * @param _attester Attester address
    */
    function suspendAttester(address _attester) external onlyGoverningCouncil {
        require(_attester != address(0), 'Attester address is empty');

        attesters.remove(_attester);
        emit AttesterSuspended(_attester);
    }

    /**
    * @notice Returns list of attesters
    */
    function getAttesters() external view returns (address[] memory) {
        return attesters.members;
    }

    /**
    * @notice Whether specified attester is valid.
    * @param _attester Attesters address to check
    */
    function isAttesterValid(address _attester) external view returns (bool) {
        return attesters.contains(_attester);
    }

    /**
    * @notice List of composers and their ballot power for the specified block number and timestamp. This method is used by Clients
    ** @param _blockNum Network block number. Used for delegates list shifting
    * @param _timestamp Time at which composers list is requested
    */
    function getComposers(uint256 /* _blockNum */, uint256 _timestamp) external view returns (address[] memory, uint256[] memory) {
        address[] memory validDelegates = getValidDelegatesAddresses(_timestamp);
        (address[] memory signerAddresses,) = _getDelegatesNameAndSignerAddresses(validDelegates);
        uint256[] memory powers = _getDelegatesBallotPower(validDelegates, _timestamp);
        return (signerAddresses, powers);
    }

    /**
    * @notice List of all delegates addresses
    */
    function getAllDelegatesAddresses() public view returns (address[] memory) {
        return delegates.members;
    }

    /**
    * @notice Returns all delegates details
    */
    function getAllDelegatesDetails() external view returns (address[] memory, address[] memory, bytes32[] memory) {
        address[] memory allDelegates = getAllDelegatesAddresses();
        (address[] memory signerAddresses, bytes32[] memory names) = _getDelegatesNameAndSignerAddresses(allDelegates);
        return (allDelegates, signerAddresses, names);
    }

    /**
    * @notice Returns number of all delegates
    */
    function getAllDelegatesCount() external view returns (uint256) {
        return delegates.length();
    }

    /**
    * @notice Returns details for given list of addresses
    * @param _delegates List of delegates
    * @param _timestamp Time at which delegates list is requested
    */
    function _getDelegatesDetails(address[] memory _delegates, uint256 _timestamp) internal view returns (address[] memory, address[] memory, bytes32[] memory, uint256[] memory) {
        (address[] memory signerAddresses, bytes32[] memory names) = _getDelegatesNameAndSignerAddresses(_delegates);
        uint256[] memory powers = _getDelegatesBallotPower(_delegates, _timestamp);
        return (_delegates, signerAddresses, names, powers);
    }

    /**
    * @notice Returns names and signer addresses for given list of addresses
    * @param _delegates List of delegates
    */
    function _getDelegatesNameAndSignerAddresses(address[] memory _delegates) internal view returns (address[] memory, bytes32[] memory) {
        address[] memory signerAddresses = new address[](_delegates.length);
        bytes32[] memory names = new bytes32[](_delegates.length);

        for (uint256 index = 0; index < _delegates.length; index++) {
            IDelegate delegate = IDelegate(_delegates[index]);
            signerAddresses[index] = delegate.getSignerAddress();
            names[index] = delegate.getNameAsBytes();
        }

        return (signerAddresses, names);
    }

    /**
    * @notice Returns delegates ballot power for given list of addresses
    * @param _delegates List of delegates
    * @param _timestamp Time to check at
    */
    function _getDelegatesBallotPower(address[] memory _delegates, uint256 _timestamp) internal view returns (uint256[] memory) {
        uint256[] memory powers = new uint256[](_delegates.length);

        (uint256 totalBonds, uint256 totalStakes) = _totalBondsAndStakes(_delegates, _timestamp);
        for (uint256 index = 0; index < _delegates.length; index++) {
            powers[index] = _ballotPower(_delegates[index], _timestamp, totalBonds, totalStakes);
        }

        return powers;
    }

    /**
    * @notice Returns total bonds and stakes for all valid delegates
    * @param _delegate Delegate address
    */
    function getDelegateBallotPowerAsOfNow(address _delegate) external view returns (uint256) {
        return getDelegateBallotPower(_delegate, now);
    }

    /**
    * @notice Returns total bonds and stakes for all valid delegates at some time
    * @param _delegate Delegate address
    * @param _timestamp Time at to check
    */
    function getDelegateBallotPower(address _delegate, uint256 _timestamp) public view returns (uint256) {
        address[] memory validDelegates = getValidDelegatesAddresses(_timestamp);
        (uint256 bondTotal, uint256 stakeTotal) = _totalBondsAndStakes(validDelegates, _timestamp);
        return _ballotPower(_delegate, _timestamp, bondTotal, stakeTotal);
    }

    /**
    * @notice Returns total bonds and stakes as of now
    */
    function totalBondsAndStakesAsOfNow() external view returns (uint256, uint256) {
        return totalBondsAndStakes(now);
    }

    /**
    * @notice Returns total bonds and stakes
    * @param _timestamp Time at which delegates calculation to be done
    */
    function totalBondsAndStakes(uint256 _timestamp) public view returns (uint256, uint256) {
        address[] memory validDelegates = getValidDelegatesAddresses(_timestamp);
        return _totalBondsAndStakes(validDelegates, _timestamp);
    }

    /**
    * @notice Returns valid delegates count
    */
    function getValidDelegatesCount() public view returns (uint256) {
        address[] memory validDelegates = getValidDelegatesAddresses(now);
        return validDelegates.length;
    }

    /**
    * @notice Returns valid delegates
    * @param _timestamp Time at which delegates list is requested
    */
    function getValidDelegatesDetails(uint256 _timestamp) external view returns (address[] memory, address[] memory, bytes32[] memory, uint256[] memory) {
        address[] memory validDelegates = getValidDelegatesAddresses(_timestamp);
        return _getDelegatesDetails(validDelegates, _timestamp);
    }

    /**
    * @notice Returns single valid delegate details as array
    * @param _index Delegate index
    * @param _timestamp Time at which delegate is requested
    */
    function getValidDelegateDetailsAsArray(uint256 _index, uint256 _timestamp) external view returns (address[] memory, address[] memory, bytes32[] memory, uint256[] memory) {
        address[] memory validDelegates = getValidDelegatesAddresses(_timestamp);
        require(_index < validDelegates.length, "Delegate index is out of range");

        address[] memory singleDelegate = new address[](1);
        singleDelegate[1] = validDelegates[_index];
        return _getDelegatesDetails(singleDelegate, _timestamp);
    }

    /**
    * @notice List of valid delegates for as of now
    */
    function getValidDelegatesAddressesAsOfNow() external view returns (address[] memory) {
        return getValidDelegatesAddresses(now);
    }

    /**
    * @notice List of valid delegates for given timestamp
    * @param _timestamp Time at which delegates list is requested
    */
    function getValidDelegatesAddresses(uint256 _timestamp) public view returns (address[] memory) {
        uint256 count = 0;
        address[] memory validDelegates = new address[](delegates.length());
        for (uint256 index = 0; index < delegates.length(); index++) {
            if (isDelegateValid(delegates.members[index], _timestamp)) {
                validDelegates[count] = delegates.members[index];
                count++;
            }
        }

        address[] memory result = new address[](count);
        for (uint256 index = 0; index < count; index++) {
            result[index] = validDelegates[index];
        }

        return (result);
    }

    /**
    * @notice Returns total bonds and stakes of delegates list at given timestamp
    * @param _delegates Delegate to calculate bonds at stakes
    * @param _timestamp Time to check on
    */
    function _totalBondsAndStakes(address[] memory _delegates, uint256 _timestamp) internal view returns (uint256, uint256) {
        uint256 bondTotal = 0;
        uint256 stakeTotal = 0;
        for (uint256 index = 0; index < _delegates.length; index++) {
            address delegate = _delegates[index];
            bondTotal = bondTotal.add(bondOfDelegate(delegate, _timestamp));
            stakeTotal = stakeTotal.add(IDelegate(delegate).stakeOfDelegate(_timestamp));
        }
        return (bondTotal, stakeTotal);
    }

    /**
    * @notice Returns ballot power based on delegate total bond and stakes
    * @param _delegate Delegate address to calculate bond for
    * @param _timestamp Time to check at
    * @param _totalBond Total delegates bond
    * @param _totalStake Total delegates stake
    */
    function _ballotPower(address _delegate, uint256 _timestamp, uint256 _totalBond, uint256 _totalStake) internal view returns (uint256) {
        uint256 bond = bondOfDelegate(_delegate, _timestamp);
        uint256 delegateStake = IDelegate(_delegate).stakeOfDelegate(_timestamp);
        if (_totalStake == 0) {
            return bond;
        }
        // BP = DelegateBondedTokensNumber + BondedTokensTotal * DelegateTokensStaked / TotalTokensStaked
        return bond.add(_totalBond.mul(delegateStake).div(_totalStake));
    }

    /**
    * @notice Whether specified delegate can be a composer
    * @param _delegate Delegate address to validate
    * @param _timestamp Time at which check is requested
    */
    function isDelegateValid(address _delegate, uint256 _timestamp) public view returns (bool) {
        if (!delegates.contains(_delegate)) {
            // Delegate not owned by this contract
            return false;
        }
        IDelegate proxy = IDelegate(_delegate);
        // Delegate has not been activated
        if (!proxy.isActive(_timestamp)) {
            return false;
        }
        // Delegate has not been suspended
        if (proxy.isSuspended(_timestamp)) {
            return false;
        }
        return true;
    }

    /**
    * @notice Checks if delegate is validator
    * @param _delegate Delegate to be checked
    */
    function isValidator(address _delegate) external view returns (bool) {
        return delegateRoles[_delegate] == Enums.DelegateRole.VALIDATOR;
    }

    /**
    * @notice Returns role of delegate
    * @param _delegate Delegate
    */
    function roleOfDelegate(address _delegate) external view returns (Enums.DelegateRole) {
        return delegateRoles[_delegate];
    }

    /**
    * @notice Returns delegate bond at specific point in time
    * @param _delegate Delegate
    * @param _timestamp Time to be checked
    */
    function bondOfDelegate(address _delegate, uint256 _timestamp) public view returns (uint256) {
        return bondHistory[_delegate].getInt(_timestamp);
    }

    /**
    * @notice Returns delegate bond
    * @param _delegate Delegate
    */
    function bondOfDelegateNow(address _delegate) public view returns (uint256) {
        return bondHistory[_delegate].getInt(now);
    }

    /**
    * @notice Make generic proposal
    * @param _id Voting id
    * @param _category Voting category
    * @param _address Delegate / Attester affected by voting
    * @param _data Extra data or data for arbitrary voting
    * @param _votingPeriod Period when delegates can vote from proposal submission
    */
    function submitProposal(bytes32 _id, Enums.VotingCategory _category, address _address, bytes32 _data, uint256 _votingPeriod) public onlyValidDelegate {
        // make sure voting is unique
        require(votings[_id].id != _id, 'Voting with this id already exists');

        AddressSet.Set memory voters;
        Voting memory voting = Voting({
            id : _id,
            category : _category,
            account : _address,
            data: _data,
            votingPeriod : _votingPeriod,
            timestamp : now,
            supported : false,
            voters : voters
        });

        votings[_id] = voting;

        emit ProposalSubmitted(_id, msg.sender, _address, _data, _category);
    }

    /**
    * @notice Vote in favor or against proposal with the specified identifier
    * @param _id Voting id
    * @param _inFavor Support proposal or not
    */
    function vote(bytes32 _id, bool _inFavor) external onlyValidDelegate {
        Voting storage voting = votings[_id];
        // have specified blacklist voting
        require(voting.id == _id, 'Voting is not valid');
        // voting is still active
        require(voting.timestamp.add(voting.votingPeriod) > now, 'Voting has already ended');

        address voter = msg.sender;
        voting.voters.insert(voter);
        voting.votes[voter] = _inFavor;

        emit Vote(_id, voter, _inFavor);
    }

    /**
    * @notice Finalize voting and apply proposed changes if success.
    * This method will fail if voting period is not over.
    * @param _id Voting id
    */
    function finalizeVoting(bytes32 _id) external {
        bool voted;
        bool supported;
        uint256 proponentsWeight;
        uint256 opponentsWeight;
        Voting storage voting = votings[_id];

        // Check if we have specified blacklist voting
        require(voting.id == _id, 'Voting is not valid');
        // Check if voting period if finished
        require(voting.timestamp.add(voting.votingPeriod) <= now, 'Voting has not ended yet');

        // Only valid delegates will be counted during the voting
        address[] memory validVoters = _filterOutInvalidDelegates(voting.voters.members);

        // Votings to accepted requires at least 30% of delegates voted
        uint256 requiredVotesNumber = getValidDelegatesCount().mul(3).div(10);
        if (validVoters.length >= requiredVotesNumber) {
            voted = true;

            (supported, proponentsWeight, opponentsWeight) = _isVotingSupported(validVoters, voting.votes);
            if (supported) {
                _handleVotingConfirmation(voting.category, voting.account);
            }
        }

        voting.supported = supported;

        emit VotingFinalized(_id, voted, supported, proponentsWeight, opponentsWeight);
    }

    /**
    * @notice Checks if voting supported and calculate votes total
    * @param _voters List of voters
    * @param _votes  List of votes
    */
    function _isVotingSupported(address[] memory _voters, mapping (address => bool) storage _votes) internal view returns (bool, uint256, uint256) {
        uint256 proponentsWeight;
        uint256 opponentsWeight;

        // We get total stakes and bonds for ballot power calculation optimization
        (uint256 bondTotal, uint256 stakeTotal) = _totalBondsAndStakes(_voters, now);

        for (uint256 index = 0; index < _voters.length; index++) {
            address delegate = _voters[index];
            // Calculate ballot power and add to total
            uint256 power = _ballotPower(delegate, now, bondTotal, stakeTotal);
            if (_votes[delegate]) {
                proponentsWeight = proponentsWeight.add(power);
            } else {
                opponentsWeight = opponentsWeight.add(power);
            }
        }

        return (proponentsWeight > opponentsWeight, proponentsWeight, opponentsWeight);
    }

    /**
    * @notice Handle voting success
    * @param _category Voting category
    * @param _account Account being voted
    */
    function _handleVotingConfirmation(Enums.VotingCategory _category, address _account) internal {
        // Handle voting results
        if (_category == Enums.VotingCategory.APPROVE_ATTESTER) {
            attesters.insert(_account);
            emit AttesterApproved(_account);
        }
        if (_category == Enums.VotingCategory.SUSPEND_ATTESTER) {
            attesters.remove(_account);
            emit AttesterSuspended(_account);
        }
        if (_category == Enums.VotingCategory.SUSPEND_DELEGATE) {
            IDelegate(_account).suspend();
        }
        if (_category == Enums.VotingCategory.UNSUSPEND_DELEGATE) {
            IDelegate(_account).unsuspend();
        }
    }

    /**
    * @notice Filters out valid delegates from the list
    * @param _delegates Delegates addresses
    */
    function _filterOutInvalidDelegates(address[] memory _delegates) internal view returns (address[] memory) {
        uint256 count = 0;
        address[] memory voters = new address[](_delegates.length);
        for (uint256 index = 0; index < _delegates.length; index++) {
            if (isDelegateValid(_delegates[index], now)) {
                voters[index] = _delegates[index];
                count++;
            }
        }

        address[] memory result = new address[](count);
        uint256 innerIndex = 0;
        for (uint256 index = 0; index < voters.length; index++) {
            if (voters[index] != address(0)) {
                result[innerIndex] = voters[index];
                innerIndex++;
            }
        }
        return result;
    }

    /**
    * @notice Returns voting details by id
    * @param _id Voting id
    */
    function getVotingDetails(bytes32 _id) external view returns (bytes32, Enums.VotingCategory, address, bytes32, uint256, address[] memory, bool[] memory, bool) {
        Voting storage voting = votings[_id];
        address[] storage voters = voting.voters.members;

        bool[] memory votes = new bool[](voters.length);
        for (uint256 index = 0; index < voters.length; index++) {
            votes[index] = voting.votes[voters[index]];
        }

        return (voting.id, voting.category, voting.account, voting.data, voting.timestamp, voters, votes, voting.supported);
    }
}
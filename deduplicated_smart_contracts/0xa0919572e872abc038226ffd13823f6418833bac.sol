/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts-ethereum-package/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.6.0;


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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.6.0;






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
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
contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */

    function __ERC20_init(string memory name, string memory symbol) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {


        _name = name;
        _symbol = symbol;
        _decimals = 18;

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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.0;




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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol

pragma solidity ^0.6.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

// File: contracts/token/ISimpleToken.sol

pragma solidity 0.6.12;


/** Interface for any Siren SimpleToken
 */
interface ISimpleToken is IERC20 {
    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) external;

    function mint(address to, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function selfDestructToken(address payable refundAddress) external;
}

// File: contracts/market/IMarket.sol

pragma solidity 0.6.12;



/** Interface for any Siren Market
 */
interface IMarket {
    /** Tracking the different states of the market */
    enum MarketState {
        /**
         * New options can be created
         * Redemption token holders can redeem their options for collateral
         * Collateral token holders can't do anything
         */
        OPEN,
        /**
         * No new options can be created
         * Redemption token holders can't do anything
         * Collateral tokens holders can re-claim their collateral
         */
        EXPIRED,
        /**
         * 180 Days after the market has expired, it will be set to a closed state.
         * Once it is closed, the owner can sweeep any remaining tokens and destroy the contract
         * No new options can be created
         * Redemption token holders can't do anything
         * Collateral tokens holders can't do anything
         */
        CLOSED
    }

    /** Specifies the manner in which options can be redeemed */
    enum MarketStyle {
        /**
         * Options can only be redeemed 30 minutes prior to the option's expiration date
         */
        EUROPEAN_STYLE,
        /**
         * Options can be redeemed any time between option creation
         * and the option's expiration date
         */
        AMERICAN_STYLE
    }

    function state() external view returns (MarketState);

    function mintOptions(uint256 collateralAmount) external;

    function calculatePaymentAmount(uint256 collateralAmount)
        external
        view
        returns (uint256);

    function calculateFee(uint256 amount, uint16 basisPoints)
        external
        pure
        returns (uint256);

    function exerciseOption(uint256 collateralAmount) external;

    function claimCollateral(uint256 collateralAmount) external;

    function closePosition(uint256 collateralAmount) external;

    function recoverTokens(IERC20 token) external;

    function selfDestructMarket(address payable refundAddress) external;

    function updateRestrictedMinter(address _restrictedMinter) external;

    function marketName() external view returns (string memory);

    function priceRatio() external view returns (uint256);

    function expirationDate() external view returns (uint256);

    function collateralToken() external view returns (IERC20);

    function wToken() external view returns (ISimpleToken);

    function bToken() external view returns (ISimpleToken);

    function updateImplementation(address newImplementation) external;

    function initialize(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) external;
}

// File: contracts/proxy/Proxy.sol

pragma solidity 0.6.12;

contract Proxy {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    uint256 constant PROXY_MEM_SLOT = 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    constructor(address contractLogic) public {
        // Verify a valid address was passed in
        require(contractLogic != address(0), "Contract Logic cannot be 0x0");

        // save the code address
        assembly {
            // solium-disable-line
            sstore(PROXY_MEM_SLOT, contractLogic)
        }
    }

    fallback() external payable {
        assembly {
            // solium-disable-line
            let contractLogic := sload(PROXY_MEM_SLOT)
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize())
            let success := delegatecall(
                gas(),
                contractLogic,
                ptr,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(ptr, 0, retSz)
            switch success
                case 0 {
                    revert(ptr, retSz)
                }
                default {
                    return(ptr, retSz)
                }
        }
    }
}

// File: contracts/proxy/Proxiable.sol

pragma solidity 0.6.12;

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    uint256 constant PROXY_MEM_SLOT = 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    event CodeAddressUpdated(address newAddress);

    function _updateCodeAddress(address newAddress) internal {
        require(
            bytes32(PROXY_MEM_SLOT) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            // solium-disable-line
            sstore(PROXY_MEM_SLOT, newAddress)
        }

        emit CodeAddressUpdated(newAddress);
    }

    function getLogicAddress() public view returns (address logicAddress) {
        assembly {
            // solium-disable-line
            logicAddress := sload(PROXY_MEM_SLOT)
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return bytes32(PROXY_MEM_SLOT);
    }
}

// File: contracts/market/Market.sol

pragma solidity 0.6.12;










/**
 * A market is an instance of an options contract market.
 * A single market represents a specific option definition with a token pair, expiration, and strike price.
 * A market has 2 states:
 * 0) OPEN - The options contract is open and new option tokens can be minted.  Holders of bTokens can exercise the tokens for collateral with payment.
 * 1) EXPIRED - The options contract cannot mint any new options.  bTokens cannot be exercised.  wTokens can redeem collateral and any payments.
 * All parameters must be set by the Initialize function before the option market is live.
 *
 * This contract is ownable.  By default, the address that deployed it will be the owner.
 */
contract Market is IMarket, OwnableUpgradeSafe, Proxiable {
    /** Use safe ERC20 functions for any token transfers since people don't follow the ERC20 standard */
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /** @dev the display name of the market - should be in the form of payment.collateral.expire.option_type.strike */
    string public override marketName;
    /** @dev the collateral token that must be locked up in this contract until expiry or redemption */
    IERC20 public override collateralToken;
    /** @dev the token paid to exercise an option */
    IERC20 public paymentToken;
    /** @dev the manner in which the options are redeemed */
    MarketStyle public marketStyle;

    /**
     * @dev the price ratio for base units of the payment token to the collateral token
     * Instead of storing the strike price, this allows easy partial redemption calcs
     * The ratio will be denomitated in 10**18 == 1 -> this allows a ratio below and above 1
     * E.g. A strike price of 2000 would be "2000 * 10**18"... a strike price of 0.5 would be "5 * 10**17" (assuming equal token decimals)
     */
    uint256 public override priceRatio;
    /** @dev the date where the option expires (seconds since epoch) */
    uint256 public override expirationDate;

    /** @dev the fee deducted when options are exercised */
    uint16 public exerciseFeeBasisPoints;
    /** @dev the fee deducted when options are closed */
    uint16 public closeFeeBasisPoints;
    /** @dev the fee deducted when options are claimed */
    uint16 public claimFeeBasisPoints;

    /** The token that represents collateral ownership */
    ISimpleToken public override wToken;
    /** The token that represents the redemption ownership */
    ISimpleToken public override bToken;

    /** If the restrictedMinter address is set, lock down minting to only that address */
    address public restrictedMinter;

    /** Enum to track Fee Events */
    enum FeeType {EXERCISE_FEE, CLOSE_FEE, CLAIM_FEE}

    /** Emitted when the market is created */
    event MarketInitialized(
        string marketName,
        MarketStyle marketStyle,
        address wToken,
        address bToken
    );

    /** Emitted when a new option contract is minted */
    event OptionMinted(address indexed minter, uint256 value);

    /** Emitted when a bToken is exercised for collateral */
    event OptionExercised(address indexed redeemer, uint256 value);

    /** Emitted when a wToken is redeemed after expiration */
    event CollateralClaimed(address indexed redeemer, uint256 value);

    /** Emitted when an equal amount of wToken and bToken is redeemed for original collateral */
    event OptionClosed(address indexed redeemer, uint256 value);

    /** Emitted when a fee is paid to the owner account */
    event FeePaid(
        FeeType indexed feeType,
        address indexed token,
        uint256 value
    );

    /** Emitted when tokens are recovered */
    event TokensRecovered(
        address indexed token,
        address indexed to,
        uint256 value
    );

    /** Emitted when contract is destroyed */
    event MarketDestroyed();

    event RestrictedMinterUpdated(address newRestrictedMinter);

    /**
     * Called to set this contract up
     * Creation and initialization should be called in a single transaction.
     */
    function initialize(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) public override {
        __Market_init(
            _marketName,
            _collateralToken,
            _paymentToken,
            _marketStyle,
            _priceRatio,
            _expirationDate,
            _exerciseFeeBasisPoints,
            _closeFeeBasisPoints,
            _claimFeeBasisPoints,
            _tokenImplementation
        );
    }

    /**
     * @dev data structures for local computations in the __Market_init() method.
     */
    struct MarketInitLocalVars {
        uint8 decimals;
        Proxy wTokenProxy;
        string wTokenName;
        Proxy bTokenProxy;
        string bTokenName;
    }

    /**
     * Initialization function that only allows itself to be called once
     */
    function __Market_init(
        string calldata _marketName,
        address _collateralToken,
        address _paymentToken,
        MarketStyle _marketStyle,
        uint256 _priceRatio,
        uint256 _expirationDate,
        uint16 _exerciseFeeBasisPoints,
        uint16 _closeFeeBasisPoints,
        uint16 _claimFeeBasisPoints,
        address _tokenImplementation
    ) internal initializer {
        require(_collateralToken != address(0x0), "Invalid _collateralToken");
        require(_paymentToken != address(0x0), "Invalid _paymentToken");
        require(_tokenImplementation != address(0x0), "Invalid _tokenImplementation");

        // Usage of a memory struct of vars to avoid "Stack too deep" errors due to
        // too many local variables
        MarketInitLocalVars memory localVars;

        // Save off variables
        marketName = _marketName;

        // Tokens
        collateralToken = IERC20(_collateralToken);
        paymentToken = IERC20(_paymentToken);

        // Market Style
        marketStyle = _marketStyle;

        // Price and expiration
        priceRatio = _priceRatio;
        expirationDate = _expirationDate;

        // Fees
        exerciseFeeBasisPoints = _exerciseFeeBasisPoints;
        closeFeeBasisPoints = _closeFeeBasisPoints;
        claimFeeBasisPoints = _claimFeeBasisPoints;

        // wToken and bToken will be denominated in same decimals as collateral
        localVars.decimals = ERC20UpgradeSafe(address(collateralToken))
            .decimals();

        // Initialize the W token
        localVars.wTokenProxy = new Proxy(_tokenImplementation);
        wToken = ISimpleToken(address(localVars.wTokenProxy));
        localVars.wTokenName = string(abi.encodePacked("W-", _marketName));
        wToken.initialize(
            localVars.wTokenName,
            localVars.wTokenName,
            localVars.decimals
        );

        // Initialize the B token
        localVars.bTokenProxy = new Proxy(_tokenImplementation);
        bToken = ISimpleToken(address(localVars.bTokenProxy));
        localVars.bTokenName = string(abi.encodePacked("B-", _marketName));
        bToken.initialize(
            localVars.bTokenName,
            localVars.bTokenName,
            localVars.decimals
        );

        // Set up the initialization of the inherited ownable contract
        __Ownable_init();

        // Emit the event
        emit MarketInitialized(
            marketName,
            marketStyle,
            address(wToken),
            address(bToken)
        );
    }

    /** Getter for the current state of the market (open, expired, or closed) */
    function state() public override view returns (MarketState) {
        // Before the expiration
        if (now < expirationDate) {
            return MarketState.OPEN;
        }

        // After expiration but not 180 days have passed
        if (now < expirationDate.add(180 days)) {
            return MarketState.EXPIRED;
        }

        // Contract can be cleaned up
        return MarketState.CLOSED;
    }

    /**
     * Mint new option contract
     * The collateral amount must already be approved by the caller to transfer into this contract
     * The caller will lock up collateral and get an equal number of bTokens and wTokens
     */
    function mintOptions(uint256 collateralAmount) public override {
        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to mint"
        );

        // Save off the calling address
        address minter = _msgSender();

        // If the restrictedMinter address is set, then only that address can mint options
        if (restrictedMinter != address(0)) {
            require(
                restrictedMinter == minter,
                "mintOptions: only restrictedMinter can mint"
            );
        }

        // Transfer the collateral into this contract from the caller - this should revert if it fails
        collateralToken.safeTransferFrom(
            minter,
            address(this),
            collateralAmount
        );

        // Mint new bTokens and wTokens to the caller
        wToken.mint(minter, collateralAmount);
        bToken.mint(minter, collateralAmount);

        // Emit the event
        emit OptionMinted(minter, collateralAmount);
    }

    /**
     * If an bToken is redeemed for X collateral, calculate the payment token amount.
     */
    function calculatePaymentAmount(uint256 collateralAmount)
        public
        override
        view
        returns (uint256)
    {
        return collateralAmount.mul(priceRatio).div(10**18);
    }

    /**
     * A Basis Point is 1 / 100 of a percent. e.g. 10 basis points (e.g. 0.1%) on 5000 is 5000 * 0.001 => 5
     */
    function calculateFee(uint256 amount, uint16 basisPoints)
        public
        override
        pure
        returns (uint256)
    {
        return amount.mul(basisPoints).div(10000);
    }

    /**
     * Redeem an bToken for collateral.
     * Can be done only while option contract is open
     * bToken amount must be approved before calling
     * Payment token amount must be approved before calling
     */
    function exerciseOption(uint256 collateralAmount) public override {
        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to exercise"
        );
        if (marketStyle == IMarket.MarketStyle.EUROPEAN_STYLE) {
            // hardcode the date after which European-style options can
            // be exercised to be 1 day prior to expiration
            require(
                now >= expirationDate - 1 days,
                "Option contract cannot yet be exercised"
            );
        }

        // Save off the caller
        address redeemer = _msgSender();

        // Burn the bToken amount from the callers account - this will be the same amount as the collateral that is requested
        bToken.burn(redeemer, collateralAmount);

        // Move the payment amount from the caller into this contract's address
        uint256 paymentAmount = calculatePaymentAmount(collateralAmount);
        paymentToken.safeTransferFrom(redeemer, address(this), paymentAmount);

        // Calculate the redeem Fee and move it if it is valid
        uint256 feeAmount = calculateFee(
            collateralAmount,
            exerciseFeeBasisPoints
        );
        if (feeAmount > 0) {
            // First set the collateral amount that will be left over to send out
            collateralAmount = collateralAmount.sub(feeAmount);

            // Send the fee Amount to the owner
            collateralToken.safeTransfer(owner(), feeAmount);

            // Emit the fee event
            emit FeePaid(
                FeeType.EXERCISE_FEE,
                address(collateralToken),
                feeAmount
            );
        }

        // Send the collateral to the caller's address
        collateralToken.safeTransfer(redeemer, collateralAmount);

        // Emit the Redeem Event
        emit OptionExercised(redeemer, collateralAmount);
    }

    /**
     * Redeem the wToken for collateral and payment tokens
     * Can only be done after contract has expired
     */
    function claimCollateral(uint256 collateralAmount) public override {
        require(
            state() == MarketState.EXPIRED,
            "Option contract must be in EXPIRED State to claim collateral"
        );

        // Save off the caller
        address redeemer = _msgSender();

        // Save off the total supply of collateral tokens
        uint256 wTokenSupply = wToken.totalSupply();

        // Burn the collateral token for the amount they are claiming
        wToken.burn(redeemer, collateralAmount);

        // Get the total collateral in this contract
        uint256 totalCollateralAmount = collateralToken.balanceOf(
            address(this)
        );

        // If there is a balance, send their share to the redeemer
        if (totalCollateralAmount > 0) {
            // Redeemer gets the percentage of all collateral in this contract based on wToken are redeeming
            uint256 owedCollateralAmount = collateralAmount.mul(totalCollateralAmount).div(wTokenSupply);

            // Calculate the claim Fee and move it if it is valid
            uint256 feeAmount = calculateFee(
                owedCollateralAmount,
                claimFeeBasisPoints
            );
            if (feeAmount > 0) {
                // First set the collateral amount that will be left over to send out
                owedCollateralAmount = owedCollateralAmount.sub(feeAmount);

                // Send the fee Amount to the owner
                collateralToken.safeTransfer(owner(), feeAmount);

                // Emit the fee event
                emit FeePaid(
                    FeeType.CLAIM_FEE,
                    address(collateralToken),
                    feeAmount
                );
            }

            // Verify the amount to send is not less than the balance due to rounding for the last user claiming funds.
            // If so, just send the remaining amount in the contract.
            uint256 currentBalance = collateralToken.balanceOf(address(this));
            if(currentBalance < owedCollateralAmount){
                owedCollateralAmount = currentBalance;
            }

            // Send the remainder to redeemer
            collateralToken.safeTransfer(redeemer, owedCollateralAmount);
        }

        // Get the total of payments in this contract
        uint256 totalPaymentAmount = paymentToken.balanceOf(address(this));

        // If there is a balance, send their share to the redeemer
        if (totalPaymentAmount > 0) {
            // Redeemer gets the percentage of all collateral in this contract based on wToken are redeeming
            uint256 owedPaymentAmount = collateralAmount.mul(totalPaymentAmount).div(wTokenSupply);

            // Calculate the claim Fee and move it if it is valid
            uint256 feeAmount = calculateFee(
                owedPaymentAmount,
                claimFeeBasisPoints
            );
            if (feeAmount > 0) {
                // First set the collateral amount that will be left over to send out
                owedPaymentAmount = owedPaymentAmount.sub(feeAmount);

                // Send the fee Amount to the owner
                paymentToken.safeTransfer(owner(), feeAmount);

                // Emit the fee event
                emit FeePaid(
                    FeeType.CLAIM_FEE,
                    address(paymentToken),
                    feeAmount
                );
            }

            // Verify the amount to send is not less than the balance due to rounding for the last user claiming funds.
            // If so, just send the remaining amount in the contract.
            uint256 currentBalance = paymentToken.balanceOf(address(this));
            if(currentBalance < owedPaymentAmount){
                owedPaymentAmount = currentBalance;
            }

            // Send the remainder to redeemer
            paymentToken.safeTransfer(redeemer, owedPaymentAmount);
        }

        // Emit event
        emit CollateralClaimed(redeemer, collateralAmount);
    }

    /**
     * Close the position and take back collateral
     * Can only be done while the contract is open
     * Caller must have an amount of both wToken and bToken that will be burned before
     * the collateral is sent back to them
     */
    function closePosition(uint256 collateralAmount) public override {
        require(
            state() == MarketState.OPEN,
            "Option contract must be in Open State to close a position"
        );

        // Save off the caller
        address redeemer = _msgSender();

        // Burn the bToken and wToken amounts
        bToken.burn(redeemer, collateralAmount);
        wToken.burn(redeemer, collateralAmount);

        // Calculate the claim Fee and move it if it is valid
        uint256 feeAmount = calculateFee(collateralAmount, closeFeeBasisPoints);
        if (feeAmount > 0) {
            // First set the collateral amount that will be left over to send out
            collateralAmount = collateralAmount.sub(feeAmount);

            // Send the fee Amount to the owner
            collateralToken.safeTransfer(owner(), feeAmount);

            // Emit the fee event
            emit FeePaid(
                FeeType.CLOSE_FEE,
                address(collateralToken),
                feeAmount
            );
        }

        // Send the collateral to the caller's address
        collateralToken.safeTransfer(redeemer, collateralAmount);

        // Emit the Closed Event
        emit OptionClosed(redeemer, collateralAmount);
    }

    /**
     * After the market is closed, anyone can trigger tokens to be swept to the owner
     */
    function recoverTokens(IERC20 token) public override {
        require(
            state() == MarketState.CLOSED,
            "ERC20s can't be recovered until the market is closed"
        );

        // Get the balance
        uint256 balance = token.balanceOf(address(this));

        // Sweep out
        token.safeTransfer(owner(), balance);

        // Emit the event
        emit TokensRecovered(address(token), owner(), balance);
    }

    /**
     * After the market is closed the owner can destroy
     */
    function selfDestructMarket(address payable refundAddress)
        public
        override
        onlyOwner
    {
        require(refundAddress != address(0x0), "Invalid refundAddress");

        require(
            state() == MarketState.CLOSED,
            "Markets can't be destroyed until it is closed"
        );

        // Sweep out any remaining collateral token
        uint256 collateralBalance = collateralToken.balanceOf(address(this));
        if(collateralBalance > 0){
            collateralToken.transfer(owner(), collateralBalance);
        }

        // Sweep out any remaining payment token
        uint256 paymentTokenBalance = paymentToken.balanceOf(address(this));
        if(paymentTokenBalance > 0){
            paymentToken.transfer(owner(), paymentTokenBalance);
        }

        // Destroy the tokens
        wToken.selfDestructToken(refundAddress);
        bToken.selfDestructToken(refundAddress);

        // Emit the event
        emit MarketDestroyed();

        // Destroy the contract and forward any ETH
        selfdestruct(refundAddress);
    }

    /**
     * Update the logic address of this Market
     */
    function updateImplementation(address newImplementation) public override onlyOwner {
        require(newImplementation != address(0x0), "Invalid newImplementation");

        _updateCodeAddress(newImplementation);
    }

    /**
     * The owner address can set a restricted minter address that will then prevent any
     * other addresses from minting new options.
     * This CAN be set to 0x0 to disable the restriction.
     */
    function updateRestrictedMinter(address _restrictedMinter)
        public
        override
        onlyOwner
    {
        restrictedMinter = _restrictedMinter;

        emit RestrictedMinterUpdated(restrictedMinter);
    }
}
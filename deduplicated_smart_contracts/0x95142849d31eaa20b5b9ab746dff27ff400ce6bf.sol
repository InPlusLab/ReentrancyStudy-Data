/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.6.0;
 
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

// 
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// 
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
}

interface IBPool {

    function isexternalSwap() external view returns (bool);
    function isFinalized() external view returns (bool);
    function isBound(address t) external view returns (bool);
    function getNumTokens() external view returns (uint);
    function getCurrentTokens() external view returns (address[] memory tokens);
    function getFinalTokens() external view returns (address[] memory tokens);
    function getDenormalizedWeight(address token) external view returns (uint);
    function getTotalDenormalizedWeight() external view returns (uint);
    function getNormalizedWeight(address token) external view returns (uint);
    function getBalance(address token) external view returns (uint);
    function getSwapFee() external view returns (uint);
    function getController() external view returns (address);

    function setSwapFee(uint swapFee) external;
    function setController(address manager) external;
    function setexternalSwap(bool external_) external;
    function finalize() external;
    function bind(address token, uint balance, uint denorm) external;
    function rebind(address token, uint balance, uint denorm) external;
    function unbind(address token) external;
    function gulp(address token) external;

    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint spotPrice);
    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint spotPrice);

    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;   
    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;

    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountOut, uint spotPriceAfter);

    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountIn, uint spotPriceAfter);

    function joinswapExternAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    ) external returns (uint poolAmountOut);

    function joinswapPoolAmountOut(
        address tokenIn,
        uint poolAmountOut,
        uint maxAmountIn
    ) external returns (uint tokenAmountIn);

    function exitswapPoolAmountIn(
        address tokenOut,
        uint poolAmountIn,
        uint minAmountOut
    ) external returns (uint tokenAmountOut);

    function exitswapExternAmountOut(
        address tokenOut,
        uint tokenAmountOut,
        uint maxPoolAmountIn
    ) external returns (uint poolAmountIn);

    function totalSupply() external view returns (uint);
    function balanceOf(address whom) external view returns (uint);
    function allowance(address src, address dst) external view returns (uint);

    function approve(address dst, uint amt) external returns (bool);
    function transfer(address dst, uint amt) external returns (bool);
    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);

    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    ) external pure returns (uint spotPrice);

    function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint tokenAmountOut);

    function calcInGivenOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountOut,
        uint swapFee
    ) external pure returns (uint tokenAmountIn);

    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint poolAmountOut);

    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    ) external pure returns (uint tokenAmountIn);

    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee
    ) external pure returns (uint tokenAmountOut);

    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee
    ) external pure returns (uint poolAmountIn);

}

interface IBFactory {

    function isBPool(address b) external view returns (bool);
    
}

// 
contract ElasticPool is Ownable, ReentrancyGuard, ERC20 {
	using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Contract address where extra profit will be sent
    address public workerAddress;
    // Interface of the Token contract accepts
    IERC20 public inToken;
    // Interface of Balancer Factory used to check pool authenticy
    IBFactory public bFactory;
    // Interface of main Balancer Pool used for adding liquidity with In Token
    IBPool public bPool;
    // Interface of Balancer BAL Token
    IERC20 public balToken;
    // Interface of Balancer Pool one used for Exchange BAL to In Token
    IBPool public bPoolOne;
    // Interface of Balancer Pool two used for Exchange BAL to In Token
    IBPool public bPoolTwo;
    // Interface of intermediate token for BAL to In Token Exchange
    IERC20 public bIntermediateToken;
    // Address where fees will be sent
    address public feeAddress;
    // Fee from profit coefficient in ppm cannot be higher 20 000 (2%)
    uint256 public feeCoefficient;
    // Max loss coefficient contract will compensate to user in ppm, cannot be lower 100 000 (10%)
    uint256 public lossCoefficient;
    // Max profit coefficient contract will pay to user in ppm, cannot be lower 100 000 (10%)
    uint256 public profitCoefficient;
    // Hold time for withdrawal in seconds
    uint256 public holdTime;

    // Struct to store user balances and time last deposited
    struct UserData {
        //In Token Balance
        uint256 inBalance;
        //BPT Token Balance
        uint256 bpBalance;
        //Last time deposited
        uint256 lastTime;
    }
    mapping (address => UserData) private userData;
    // Total In Token balance locked in contract
    uint256 private inBalance;

    event Received(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FeePaid(address indexed user, uint256 amount);
    
    constructor (
        uint8 _decimals,
        address _inToken,
        address _bFactory,
        address _bPool,
        address _balToken,
        address _feeAddress,
        uint256 _feeCoefficient,
    	uint256 _lossCoefficient,
    	uint256 _profitCoefficient,
        uint256 _holdDays
    )
    	public
        ERC20('elascticPoolToken', 'EPT')
    {
        _setupDecimals(_decimals);
        inToken = IERC20(_inToken);

        bFactory = IBFactory(_bFactory);
        require(bFactory.isBPool(_bPool), "balancer pool address is wrong");
        bPool = IBPool(_bPool);
        require(bPool.isBound(_inToken), "in token is not bound to pool");
        balToken = IERC20(_balToken);
        
    	feeAddress = _feeAddress;
        setFeeCoefficient(_feeCoefficient);
    	setLossCoefficient(_lossCoefficient);
    	setProfitCoefficient(_profitCoefficient);
        setHoldTime(_holdDays);
    }

	/***************************************
                    ADMIN
    ****************************************/

    /** 
    * @dev Sets Balancer Pools for Exchange BAL to In Tokens
	* @param _bPoolOne - first Balancer Pool address
    * @param _bPoolOne - second Balancer Pool adress
    * @param _bIntermediateToken - intermediate token address
	*/
    function setExchangePools (
        address _bPoolOne,
        address _bPoolTwo,
        address _bIntermediateToken
    )
        external
        onlyOwner
    {
        require(bFactory.isBPool(_bPoolOne), "balancer pool one address is wrong");
        bPoolOne = IBPool(_bPoolOne);
        require(bPoolOne.isBound(address(balToken)) && bPoolOne.isBound(_bIntermediateToken), 
            "BAL or intermediate token is not bound to pool one");
        bIntermediateToken = IERC20(_bIntermediateToken);
        if(address(inToken) != _bIntermediateToken){
            require(bFactory.isBPool(_bPoolTwo), "balancer pool two address is wrong");
            bPoolTwo = IBPool(_bPoolTwo);
            require(bPoolTwo.isBound(address(inToken)) && bPoolTwo.isBound(_bIntermediateToken), 
                "In token or intermediate token is not bound to pool two");
        }
    }

    /** 
    * @dev Sets Worker contract address, can be called only once
    * @param _workerAddress - New worker contract address
    */
    function setWorker (
        address _workerAddress
    )
        external
        onlyOwner
    {
        require (workerAddress == address(0), "worker address is already set");
        workerAddress = _workerAddress;
    }

    /** 
    * @dev Sets Fee Coefficient
    * @param _coefficient - New fee coefficient
    */
    function setFeeCoefficient (
        uint256 _coefficient
    )
        public
        onlyOwner
    {
        require(_coefficient <= 2e4, "fee coefficient must be lower 20 001");
        feeCoefficient = _coefficient;
    } 

    /** 
    * @dev Sets Loss Coefficient
	* @param _coefficient - New loss coefficient
	*/
    function setLossCoefficient (
    	uint256 _coefficient
    )
    	public
    	onlyOwner
    {
    	require(_coefficient >= 1e5, "loss coefficient must be higher 99 999");
    	lossCoefficient = _coefficient;
    }    

    /** 
    * @dev Sets Profit Coefficient
	* @param _coefficient - New profit coefficient
	*/
    function setProfitCoefficient (
    	uint256 _coefficient
    )
    	public
    	onlyOwner
    {
    	require(_coefficient >= 1e5, "profit coefficient must be higher 99 999");
    	profitCoefficient = _coefficient;
    } 

    /** 
    * @dev Sets Hold time
    * @param _holdDays - Hold time in days
    */
    function setHoldTime (
        uint256 _holdDays
    )
        public
        onlyOwner
    {
        holdTime = _holdDays.mul(1 days);
    }

    /***************************************
                    ACTIONS
    ****************************************/

    /**
     * @dev Destroys tokens from msg.sender account
     * @param _amount amount of tokens
     */
    function burn(uint256 _amount)  
        external 
    {
        _burn(msg.sender, _amount);
    }

    /**
     * @dev Exchanges BAL Tokens to In Tokens on Balancer and sends to worker address
     */
    function checkAndDistributeBal ()
        external
    {
        uint256 _balAmount = balToken.balanceOf(address(this));
        require(_balAmount != 0, 'BAL balance is 0');
        balToken.approve(address(bPoolOne), _balAmount);
        uint256 _bpAmount = bPoolOne.joinswapExternAmountIn(
            address(balToken),
            _balAmount,
            1
        );
        uint256 _inAmount = bPoolOne.exitswapPoolAmountIn(
            address(bIntermediateToken),
            _bpAmount,
            1
        );
        if(address(inToken) != address(bIntermediateToken)){
            bIntermediateToken.approve(address(bPoolTwo), _inAmount);
            _bpAmount = bPoolTwo.joinswapExternAmountIn(
                address(bIntermediateToken),
                _inAmount,
                1
            );
            _inAmount = bPoolTwo.exitswapPoolAmountIn(
                address(inToken),
                _bpAmount,
                1
            );
        }
        inToken.safeTransfer(workerAddress, _inAmount);
    }

    /**
     * @dev Transfers In Tokens
     * @param _inAmount of In Tokens
     */
    function receiveInToken (uint256 _inAmount)
        external
        nonReentrant
        returns (uint256 bpAmount)
    {
        require(_inAmount != 0, "in amount is 0");
        address _address = msg.sender;
        UserData storage _user = userData[_address];
        inToken.safeTransferFrom(_address, address(this), _inAmount);
        inToken.approve(address(bPool), _inAmount);
        bpAmount = bPool.joinswapExternAmountIn(
            address(inToken),
            _inAmount,
            1
        );
        inBalance = inBalance.add(_inAmount);
        _user.inBalance = _user.inBalance.add(_inAmount);
        _user.bpBalance = _user.bpBalance.add(bpAmount);
        _user.lastTime = block.timestamp;
        emit Received(_address, _inAmount);
        return bpAmount;
    }

    /**
     * @dev Withdraw
     * @param _bpAmount of BPT Tokens
     */
    function withdraw(uint256 _bpAmount)
        external
        nonReentrant
        returns (uint256 amount, uint256 _compensatedAmount)
    {
        require(_bpAmount != 0, "in amount is 0");
        address _address = msg.sender;
        UserData storage _user = userData[_address];
        require(_user.bpBalance >= _bpAmount, "not enough balance");
        require(block.timestamp.sub(_user.lastTime) >= holdTime, 'cannot withdraw, tokens on hold');
        uint256 _inAmount = _user.inBalance.mul(_bpAmount).div(_user.bpBalance);
        inBalance = inBalance.sub(_inAmount);
        _user.inBalance = _user.inBalance.sub(_inAmount);
        _user.bpBalance = _user.bpBalance.sub(_bpAmount); 
        amount = bPool.exitswapPoolAmountIn(
            address(inToken),
            _bpAmount,
            1
        );
        uint256 _fee; uint256 _feeWorker;
        (
            amount, 
            _compensatedAmount, 
            _fee, 
            _feeWorker
        ) = calcChange(_inAmount, amount);
        inToken.safeTransfer(_address, amount);
        if(_compensatedAmount != 0)
            _mint(_address, _compensatedAmount);
        if(_fee != 0){
            inToken.safeTransfer(feeAddress, _fee);
            emit FeePaid(feeAddress, _fee);
        }
        if(_feeWorker != 0){
            inToken.safeTransfer(workerAddress, _feeWorker);
            emit FeePaid(workerAddress, _feeWorker);
        }
        emit Withdrawn(_address, _inAmount);
        return (amount, _compensatedAmount);
    }
    
    /***************************************
                    GETTERS
    ****************************************/
    
    /**
     * @dev Returns contract's total balance of BAL Token
     */
    function getBalanceBal()
        external
        view
        returns (uint256)
    {
        return balToken.balanceOf(address(this));
    }

    /**
     * @dev Returns total balance of In Token locked into contract
     */
    function getBalanceIn()
        external
        view
        returns (uint256)
    {
        return inBalance;
    }

    /**
     * @dev Returns contract's total balance of BPT Token
     */
    function getBalanceBp()
        external
        view
        returns (uint256)
    {
        return bPool.balanceOf(address(this));
    }

    /**
     * @dev Returns balance of In Token of given user address
     * @param _address address of the user
     */
    function getBalanceInOf(address _address)
        external
        view
        returns (uint256)
    {
        return userData[_address].inBalance;
    }

    /**
     * @dev Returns balance of BPT Token of given user address
     * @param _address address of the user
     */
    function getBalanceBpOf(address _address)
        external
        view
        returns (uint256)
    {
        return userData[_address].bpBalance;
    }

    /**
     * @dev Returns true if hold is active for given user address
     * @param _address address of the user
     */
    function isOnHold(address _address)
        external
        view
        returns (bool)
    {
        if(userData[_address].lastTime == 0) return false;
        return block.timestamp.sub(userData[_address].lastTime) < holdTime;
    }

    /**
     * @dev Calculates returned In, Compensation Tokens values and fees
     * @param _inAmount initial investment of In Tokens
     * @param _amount returned amount from Balancer
     */
    function calcChange(uint256 _inAmount, uint256 _amount)
        public
        view
        returns (
            uint256 returnAmount, 
            uint256 compensatedAmount, 
            uint256 fee, 
            uint256 feeWorker
        )
    {
        uint256 _change; uint256 _maxChange;
        if(_inAmount > _amount){
            _change = _inAmount.sub(_amount);
            _maxChange = _inAmount.mul(lossCoefficient).div(1e6);
            if(_change > _maxChange){
                compensatedAmount = _maxChange;
            }else{
                compensatedAmount = _change;
            }
            returnAmount = _amount;
        }else{
            _change = _amount.sub(_inAmount);
            _maxChange = _change.mul(profitCoefficient).div(1e6);
            returnAmount = _inAmount.add(_maxChange);
            fee = _change.sub(_maxChange).mul(feeCoefficient).div(1e6);
            feeWorker = _change.sub(_maxChange).sub(fee);
        }
        return (returnAmount, compensatedAmount, fee, feeWorker);
    }

    /**
     * @dev Calculates returned In, Compensation Tokens values for user
     * @param _address User address
     * @param _bpAmount Amount of BPT Tokens
     */
    function calcReturn(address _address, uint256 _bpAmount)
        external
        view
        returns (
            uint256 returnAmount, 
            uint256 compensatedAmount
        )
    {
        UserData memory _user = userData[_address];
        require(_bpAmount != 0, "in amount is 0");
        require(_user.bpBalance >= _bpAmount, "not enough balance");
        uint256 _inAmount = _user.inBalance.mul(_bpAmount).div(_user.bpBalance);
        uint256 _amount = calcInPoolBp(_inAmount);
        (
            returnAmount, 
            compensatedAmount, 
            ,
        ) = calcChange(_inAmount, _amount);
        return (returnAmount, compensatedAmount);
    }

    /**
     * @dev Calculates returned BPT Tokens from Pool given In Token amount
     * @param _inAmount Amount of In Tokens
     */
    function calcBpPoolIn(uint256 _inAmount)
        external
        view
        returns (uint256)
    {
        return bPool.calcPoolOutGivenSingleIn(
            bPool.getBalance(address(inToken)),
            bPool.getDenormalizedWeight(address(inToken)),
            bPool.totalSupply(),
            bPool.getTotalDenormalizedWeight(),
            _inAmount,
            bPool.getSwapFee()
        );
    }

    /**
     * @dev Calculates returned In Tokens from Pool given BPT Token amount
     * @param _bpAmount Amount of BPT Tokens
     */
    function calcInPoolBp(uint256 _bpAmount)
        public
        view
        returns (uint256)
    {
        return bPool.calcSingleOutGivenPoolIn(
            bPool.getBalance(address(inToken)),
            bPool.getDenormalizedWeight(address(inToken)),
            bPool.totalSupply(),
            bPool.getTotalDenormalizedWeight(),
            _bpAmount,
            bPool.getSwapFee()
        );
    }
}
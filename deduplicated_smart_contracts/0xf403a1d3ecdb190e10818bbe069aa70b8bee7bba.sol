/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: GPL-3.0-only
pragma experimental ABIEncoderV2;

// File: @openzeppelin/contracts/math/SafeMath.sol


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

// File: @openzeppelin/contracts/GSN/Context.sol


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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


pragma solidity ^0.6.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
    constructor (string memory name, string memory symbol) public {
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

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
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

// File: contracts/GToken.sol

pragma solidity ^0.6.0;


/**
 * @dev Minimal interface for gTokens, implemented by the GTokenBase contract.
 *      See GTokenBase.sol for further documentation.
 */
interface GToken is IERC20
{
	// pure functions
	function calcDepositSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) external pure returns (uint256 _netShares, uint256 _feeShares);
	function calcDepositCostFromShares(uint256 _netShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) external pure returns (uint256 _cost, uint256 _feeShares);
	function calcWithdrawalSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) external pure returns (uint256 _grossShares, uint256 _feeShares);
	function calcWithdrawalCostFromShares(uint256 _grossShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) external pure returns (uint256 _cost, uint256 _feeShares);

	// view functions
	function reserveToken() external view returns (address _reserveToken);
	function totalReserve() external view returns (uint256 _totalReserve);
	function depositFee() external view returns (uint256 _depositFee);
	function withdrawalFee() external view returns (uint256 _withdrawalFee);

	// open functions
	function deposit(uint256 _cost) external;
	function withdraw(uint256 _grossShares) external;
}

// File: contracts/GVoting.sol

pragma solidity ^0.6.0;

/**
 * @dev An interface to extend gTokens with voting delegation capabilities.
 *      See GTokenType3.sol for further documentation.
 */
interface GVoting
{
	// view functions
	function votes(address _candidate) external view returns (uint256 _votes);
	function candidate(address _voter) external view returns (address _candidate);

	// open functions
	function setCandidate(address _newCandidate) external;

	// emitted events
	event ChangeCandidate(address indexed _voter, address indexed _oldCandidate, address indexed _newCandidate);
	event ChangeVotes(address indexed _candidate, uint256 _oldVotes, uint256 _newVotes);
}

// File: contracts/GFormulae.sol

pragma solidity ^0.6.0;


/**
 * @dev Pure implementation of deposit/minting and withdrawal/burning formulas
 *      for gTokens.
 *      All operations assume that, if total supply is 0, then the total
 *      reserve is also 0, and vice-versa.
 *      Fees are calculated percentually based on the gross amount.
 *      See GTokenBase.sol for further documentation.
 */
library GFormulae
{
	using SafeMath for uint256;

	/* deposit(cost):
	 *   price = reserve / supply
	 *   gross = cost / price
	 *   net = gross * 0.99	# fee is assumed to be 1% for simplicity
	 *   fee = gross - net
	 *   return net, fee
	 */
	function _calcDepositSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) internal pure returns (uint256 _netShares, uint256 _feeShares)
	{
		uint256 _grossShares = _totalSupply == _totalReserve ? _cost : _cost.mul(_totalSupply).div(_totalReserve);
		_netShares = _grossShares.mul(uint256(1e18).sub(_depositFee)).div(1e18);
		_feeShares = _grossShares.sub(_netShares);
		return (_netShares, _feeShares);
	}

	/* deposit_reverse(net):
	 *   price = reserve / supply
	 *   gross = net / 0.99	# fee is assumed to be 1% for simplicity
	 *   cost = gross * price
	 *   fee = gross - net
	 *   return cost, fee
	 */
	function _calcDepositCostFromShares(uint256 _netShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) internal pure returns (uint256 _cost, uint256 _feeShares)
	{
		uint256 _grossShares = _netShares.mul(1e18).div(uint256(1e18).sub(_depositFee));
		_cost = _totalReserve == _totalSupply ? _grossShares : _grossShares.mul(_totalReserve).div(_totalSupply);
		_feeShares = _grossShares.sub(_netShares);
		return (_cost, _feeShares);
	}

	/* withdrawal_reverse(cost):
	 *   price = reserve / supply
	 *   net = cost / price
	 *   gross = net / 0.99	# fee is assumed to be 1% for simplicity
	 *   fee = gross - net
	 *   return gross, fee
	 */
	function _calcWithdrawalSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) internal pure returns (uint256 _grossShares, uint256 _feeShares)
	{
		uint256 _netShares = _cost == _totalReserve ? _totalSupply : _cost.mul(_totalSupply).div(_totalReserve);
		_grossShares = _netShares.mul(1e18).div(uint256(1e18).sub(_withdrawalFee));
		_feeShares = _grossShares.sub(_netShares);
		return (_grossShares, _feeShares);
	}

	/* withdrawal(gross):
	 *   price = reserve / supply
	 *   net = gross * 0.99	# fee is assumed to be 1% for simplicity
	 *   cost = net * price
	 *   fee = gross - net
	 *   return cost, fee
	 */
	function _calcWithdrawalCostFromShares(uint256 _grossShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) internal pure returns (uint256 _cost, uint256 _feeShares)
	{
		uint256 _netShares = _grossShares.mul(uint256(1e18).sub(_withdrawalFee)).div(1e18);
		_cost = _netShares == _totalSupply ? _totalReserve : _netShares.mul(_totalReserve).div(_totalSupply);
		_feeShares = _grossShares.sub(_netShares);
		return (_cost, _feeShares);
	}
}

// File: contracts/modules/Math.sol

pragma solidity ^0.6.0;

/**
 * @dev This library implements auxiliary math definitions.
 */
library Math
{
	function _min(uint256 _amount1, uint256 _amount2) internal pure returns (uint256 _minAmount)
	{
		return _amount1 < _amount2 ? _amount1 : _amount2;
	}

	function _max(uint256 _amount1, uint256 _amount2) internal pure returns (uint256 _maxAmount)
	{
		return _amount1 > _amount2 ? _amount1 : _amount2;
	}
}

// File: contracts/interop/WrappedEther.sol

pragma solidity ^0.6.0;


/**
 * @dev Minimal set of declarations for WETH interoperability.
 */
interface WETH is IERC20
{
	function deposit() external payable;
	function withdraw(uint256 _amount) external;
}

// File: contracts/network/$.sol

pragma solidity ^0.6.0;

/**
 * @dev This library is provided for conveniece. It is the single source for
 *      the current network and all related hardcoded contract addresses. It
 *      also provide useful definitions for debuging faultless code via events.
 */
library $
{
	enum Network { Mainnet, Ropsten, Rinkeby, Kovan, Goerli }

	Network constant NETWORK = Network.Mainnet;

	bool constant DEBUG = NETWORK != Network.Mainnet;

	function debug(string memory _message) internal
	{
		address _from = msg.sender;
		if (DEBUG) emit Debug(_from, _message);
	}

	function debug(string memory _message, uint256 _value) internal
	{
		address _from = msg.sender;
		if (DEBUG) emit Debug(_from, _message, _value);
	}

	function debug(string memory _message, address _address) internal
	{
		address _from = msg.sender;
		if (DEBUG) emit Debug(_from, _message, _address);
	}

	event Debug(address indexed _from, string _message);
	event Debug(address indexed _from, string _message, uint256 _value);
	event Debug(address indexed _from, string _message, address _address);

	address constant GRO =
		NETWORK == Network.Mainnet ? 0x09e64c2B61a5f1690Ee6fbeD9baf5D6990F8dFd0 :
		NETWORK == Network.Ropsten ? 0x5BaF82B5Eddd5d64E03509F0a7dBa4Cbf88CF455 :
		NETWORK == Network.Rinkeby ? 0x020e317e70B406E23dF059F3656F6fc419411401 :
		NETWORK == Network.Kovan ? 0xFcB74f30d8949650AA524d8bF496218a20ce2db4 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant DAI =
		NETWORK == Network.Mainnet ? 0x6B175474E89094C44Da98b954EedeAC495271d0F :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant USDC =
		NETWORK == Network.Mainnet ? 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant USDT =
		NETWORK == Network.Mainnet ? 0xdAC17F958D2ee523a2206206994597C13D831ec7 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant SUSD =
		NETWORK == Network.Mainnet ? 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant TUSD =
		NETWORK == Network.Mainnet ? 0x0000000000085d4780B73119b644AE5ecd22b376 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant BUSD =
		NETWORK == Network.Mainnet ? 0x4Fabb145d64652a948d72533023f6E7A623C7C53 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant WBTC =
		NETWORK == Network.Mainnet ? 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant WETH =
		NETWORK == Network.Mainnet ? 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 :
		NETWORK == Network.Ropsten ? 0xc778417E063141139Fce010982780140Aa0cD5Ab :
		NETWORK == Network.Rinkeby ? 0xc778417E063141139Fce010982780140Aa0cD5Ab :
		NETWORK == Network.Kovan ? 0xd0A1E359811322d97991E03f863a0C30C2cF029C :
		NETWORK == Network.Goerli ? 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6 :
		0x0000000000000000000000000000000000000000;

	address constant BAT =
		NETWORK == Network.Mainnet ? 0x0D8775F648430679A709E98d2b0Cb6250d2887EF :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant ENJ =
		NETWORK == Network.Mainnet ? 0xF629cBd94d3791C9250152BD8dfBDF380E2a3B9c :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant KNC =
		NETWORK == Network.Mainnet ? 0xdd974D5C2e2928deA5F71b9825b8b646686BD200 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant AAVE =
		NETWORK == Network.Mainnet ? 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant LEND =
		NETWORK == Network.Mainnet ? 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant LINK =
		NETWORK == Network.Mainnet ? 0x514910771AF9Ca656af840dff83E8264EcF986CA :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant MANA =
		NETWORK == Network.Mainnet ? 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant MKR =
		NETWORK == Network.Mainnet ? 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant REN =
		NETWORK == Network.Mainnet ? 0x408e41876cCCDC0F92210600ef50372656052a38 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant REP =
		NETWORK == Network.Mainnet ? 0x1985365e9f78359a9B6AD760e32412f4a445E862 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant SNX =
		NETWORK == Network.Mainnet ? 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant ZRX =
		NETWORK == Network.Mainnet ? 0xE41d2489571d322189246DaFA5ebDe1F4699F498 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant UNI =
		NETWORK == Network.Mainnet ? 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant YFI =
		NETWORK == Network.Mainnet ? 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aETH =
		NETWORK == Network.Mainnet ? 0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04 :
		NETWORK == Network.Ropsten ? 0x2433A1b6FcF156956599280C3Eb1863247CFE675 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xD483B49F2d55D2c53D32bE6efF735cB001880F79 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aDAI =
		NETWORK == Network.Mainnet ? 0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d :
		NETWORK == Network.Ropsten ? 0xcB1Fe6F440c49E9290c3eb7f158534c2dC374201 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aUSDC =
		NETWORK == Network.Mainnet ? 0x9bA00D6856a4eDF4665BcA2C2309936572473B7E :
		NETWORK == Network.Ropsten ? 0x2dB6a31f973Ec26F5e17895f0741BB5965d5Ae15 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x02F626c6ccb6D2ebC071c068DC1f02Bf5693416a :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aSUSD =
		NETWORK == Network.Mainnet ? 0x625aE63000f46200499120B906716420bd059240 :
		NETWORK == Network.Ropsten ? 0x5D17e0ea2d886F865E40176D71dbc0b59a54d8c1 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xb9c1434aB6d5811D1D0E92E8266A37Ae8328e901 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aTUSD =
		NETWORK == Network.Mainnet ? 0x4DA9b813057D04BAef4e5800E36083717b4a0341 :
		NETWORK == Network.Ropsten ? 0x9265d51F5ABf1E23bE64418827859bc83ae70a57 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x4c76f1b48316489E8a3304Db21cdAeC271cF6eC3 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aUSDT =
		NETWORK == Network.Mainnet ? 0x71fc860F7D3A592A4a98740e39dB31d25db65ae8 :
		NETWORK == Network.Ropsten ? 0x790744bC4257B4a0519a3C5649Ac1d16DDaFAE0D :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xA01bA9fB493b851F4Ac5093A324CB081A909C34B :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aBUSD =
		NETWORK == Network.Mainnet ? 0x6Ee0f7BB50a54AB5253dA0667B0Dc2ee526C30a8 :
		NETWORK == Network.Ropsten ? 0x81E065164bAC7203c3bFEB1a749F48a64383c6eE :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aBAT =
		NETWORK == Network.Mainnet ? 0xE1BA0FB44CCb0D11b80F92f4f8Ed94CA3fF51D00 :
		NETWORK == Network.Ropsten ? 0x0D0Ff1C81F2Fbc8cbafA8Df4bF668f5ba963Dab4 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x5ad67de6Fb697e92a7dE99d991F7CdB77EdF5F74 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aENJ =
		NETWORK == Network.Mainnet ? 0x712DB54daA836B53Ef1EcBb9c6ba3b9Efb073F40 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aKNC =
		NETWORK == Network.Mainnet ? 0x9D91BE44C06d373a8a226E1f3b146956083803eB :
		NETWORK == Network.Ropsten ? 0xCf6efd4528d27Df440fdd585a116D3c1fC5aDdEe :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xB08EC9EdB6BD7971220FEa04644174f3EbfbDe96 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aAAVE =
		NETWORK == Network.Mainnet ? 0xba3D9687Cf50fE253cd2e1cFeEdE1d6787344Ed5 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aLEND =
		// NETWORK == Network.Mainnet ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Ropsten ? 0x383261d0e287f0A641322AEB15E3da50147Dd36b :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xcBa131C7FB05fe3c9720375cD86C99773faAbF23 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aLINK =
		NETWORK == Network.Mainnet ? 0xA64BD6C70Cb9051F6A9ba1F163Fdc07E0DfB5F84 :
		NETWORK == Network.Ropsten ? 0x52fd99c15e6FFf8D4CF1B83b2263a501FDd78973 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xEC23855Ff01012E1823807CE19a790CeBc4A64dA :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aMANA =
		NETWORK == Network.Mainnet ? 0x6FCE4A401B6B80ACe52baAefE4421Bd188e76F6f :
		NETWORK == Network.Ropsten ? 0x8e96a4068da80F66ef1CFc7987f0F834c26106fa :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xe68204D69Cbfaf6124190EFa65ad9C591C0D48e4 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aMKR =
		NETWORK == Network.Mainnet ? 0x7deB5e830be29F91E298ba5FF1356BB7f8146998 :
		NETWORK == Network.Ropsten ? 0xEd6A5d671f7c55aa029cbAEa2e5E9A18E9d6a1CE :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xfB762B5BAb463f7F35610Ba65e2534993a1c09C6 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aREN =
		NETWORK == Network.Mainnet ? 0x69948cC03f478B95283F7dbf1CE764d0fc7EC54C :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aREP =
		NETWORK == Network.Mainnet ? 0x71010A9D003445aC60C4e6A7017c1E89A477B438 :
		NETWORK == Network.Ropsten ? 0xE4B92BcDB2f972e1ccc069D4dB33d5f6363738dE :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x0578469469Db1129271f4eb3EB9D97426506c44c :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aSNX =
		NETWORK == Network.Mainnet ? 0x328C4c80BC7aCa0834Db37e6600A6c49E12Da4DE :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xb4D480f963f4F685F1D51d2B6159D126658B1dA8 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aUNI =
		NETWORK == Network.Mainnet ? 0xB124541127A0A657f056D9Dd06188c4F1b0e5aab :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aWBTC =
		NETWORK == Network.Mainnet ? 0xFC4B8ED459e00e5400be803A9BB3954234FD50e3 :
		NETWORK == Network.Ropsten ? 0xA1c4dB01F8344eCb11219714706C82f0c0c64841 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0xCD5C52C7B30468D16771193C47eAFF43EFc47f5C :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aYFI =
		NETWORK == Network.Mainnet ? 0x12e51E77DAAA58aA0E9247db7510Ea4B46F9bEAd :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant aZRX =
		NETWORK == Network.Mainnet ? 0x6Fb0855c404E09c47C3fBCA25f08d4E41f9F062f :
		NETWORK == Network.Ropsten ? 0x5BDC773c9D3515a5e3Dd415428F92a90E8e63Ae4 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x0F456900c6bdFddfA27E1E4E4c84EB823a2eE13c :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant cDAI =
		NETWORK == Network.Mainnet ? 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 :
		NETWORK == Network.Ropsten ? 0xdb5Ed4605C11822811a39F94314fDb8F0fb59A2C :
		NETWORK == Network.Rinkeby ? 0x6D7F0754FFeb405d23C51CE938289d4835bE3b14 :
		NETWORK == Network.Kovan ? 0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD :
		NETWORK == Network.Goerli ? 0x822397d9a55d0fefd20F5c4bCaB33C5F65bd28Eb :
		0x0000000000000000000000000000000000000000;

	address constant cUSDC =
		NETWORK == Network.Mainnet ? 0x39AA39c021dfbaE8faC545936693aC917d5E7563 :
		NETWORK == Network.Ropsten ? 0x8aF93cae804cC220D1A608d4FA54D1b6ca5EB361 :
		NETWORK == Network.Rinkeby ? 0x5B281A6DdA0B271e91ae35DE655Ad301C976edb1 :
		NETWORK == Network.Kovan ? 0x4a92E71227D294F041BD82dd8f78591B75140d63 :
		NETWORK == Network.Goerli ? 0xCEC4a43eBB02f9B80916F1c718338169d6d5C1F0 :
		0x0000000000000000000000000000000000000000;

	address constant cUSDT =
		NETWORK == Network.Mainnet ? 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9 :
		NETWORK == Network.Ropsten ? 0x135669c2dcBd63F639582b313883F101a4497F76 :
		NETWORK == Network.Rinkeby ? 0x2fB298BDbeF468638AD6653FF8376575ea41e768 :
		NETWORK == Network.Kovan ? 0x3f0A0EA2f86baE6362CF9799B523BA06647Da018 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant cETH =
		NETWORK == Network.Mainnet ? 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5 :
		NETWORK == Network.Ropsten ? 0xBe839b6D93E3eA47eFFcCA1F27841C917a8794f3 :
		NETWORK == Network.Rinkeby ? 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e :
		NETWORK == Network.Kovan ? 0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72 :
		NETWORK == Network.Goerli ? 0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF :
		0x0000000000000000000000000000000000000000;

	address constant cWBTC =
		NETWORK == Network.Mainnet ? 0xC11b1268C1A384e55C48c2391d8d480264A3A7F4 :
		NETWORK == Network.Ropsten ? 0x58145Bc5407D63dAF226e4870beeb744C588f149 :
		NETWORK == Network.Rinkeby ? 0x0014F450B8Ae7708593F4A46F8fa6E5D50620F96 :
		NETWORK == Network.Kovan ? 0xa1fAA15655B0e7b6B6470ED3d096390e6aD93Abb :
		NETWORK == Network.Goerli ? 0x6CE27497A64fFFb5517AA4aeE908b1E7EB63B9fF :
		0x0000000000000000000000000000000000000000;

	address constant cBAT =
		NETWORK == Network.Mainnet ? 0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E :
		NETWORK == Network.Ropsten ? 0x9E95c0b2412cE50C37a121622308e7a6177F819D :
		NETWORK == Network.Rinkeby ? 0xEBf1A11532b93a529b5bC942B4bAA98647913002 :
		NETWORK == Network.Kovan ? 0x4a77fAeE9650b09849Ff459eA1476eaB01606C7a :
		NETWORK == Network.Goerli ? 0xCCaF265E7492c0d9b7C2f0018bf6382Ba7f0148D :
		0x0000000000000000000000000000000000000000;

	address constant cZRX =
		NETWORK == Network.Mainnet ? 0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407 :
		NETWORK == Network.Ropsten ? 0x00e02a5200CE3D5b5743F5369Deb897946C88121 :
		NETWORK == Network.Rinkeby ? 0x52201ff1720134bBbBB2f6BC97Bf3715490EC19B :
		NETWORK == Network.Kovan ? 0xAf45ae737514C8427D373D50Cd979a242eC59e5a :
		NETWORK == Network.Goerli ? 0xA253295eC2157B8b69C44b2cb35360016DAa25b1 :
		0x0000000000000000000000000000000000000000;

	address constant cUNI =
		NETWORK == Network.Mainnet ? 0x35A18000230DA775CAc24873d00Ff85BccdeD550 :
		NETWORK == Network.Ropsten ? 0x22531F0f3a9c36Bfc3b04c4c60df5168A1cFCec3 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant cCOMP =
		NETWORK == Network.Mainnet ? 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4 :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant COMP =
		NETWORK == Network.Mainnet ? 0xc00e94Cb662C3520282E6f5717214004A7f26888 :
		NETWORK == Network.Ropsten ? 0x1Fe16De955718CFAb7A44605458AB023838C2793 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x61460874a7196d6a22D1eE4922473664b3E95270 :
		NETWORK == Network.Goerli ? 0xe16C7165C8FeA64069802aE4c4c9C320783f2b6e :
		0x0000000000000000000000000000000000000000;

	address constant Aave_AAVE_LENDING_POOL_ADDRESSES_PROVIDER =
		NETWORK == Network.Mainnet ? 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8 :
		NETWORK == Network.Ropsten ? 0x1c8756FD2B28e9426CDBDcC7E3c4d64fa9A54728 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant Aave_AAVE_LENDING_POOL =
		NETWORK == Network.Mainnet ? 0x398eC7346DcD622eDc5ae82352F02bE94C62d119 :
		NETWORK == Network.Ropsten ? 0x9E5C7835E4b13368fd628196C4f1c6cEc89673Fa :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant Aave_AAVE_LENDING_POOL_CORE =
		NETWORK == Network.Mainnet ? 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3 :
		NETWORK == Network.Ropsten ? 0x4295Ee704716950A4dE7438086d6f0FBC0BA9472 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x95D1189Ed88B380E319dF73fF00E479fcc4CFa45 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant Balancer_FACTORY =
		NETWORK == Network.Mainnet ? 0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Rinkeby ? 0x9C84391B443ea3a48788079a5f98e2EaD55c9309 :
		NETWORK == Network.Kovan ? 0x8f7F78080219d4066A8036ccD30D588B416a40DB :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant Compound_COMPTROLLER =
		NETWORK == Network.Mainnet ? 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B :
		NETWORK == Network.Ropsten ? 0x54188bBeDD7b68228fa89CbDDa5e3e930459C6c6 :
		NETWORK == Network.Rinkeby ? 0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb :
		NETWORK == Network.Kovan ? 0x5eAe89DC1C671724A672ff0630122ee834098657 :
		NETWORK == Network.Goerli ? 0x627EA49279FD0dE89186A58b8758aD02B6Be2867 :
		0x0000000000000000000000000000000000000000;

	address constant Dydx_SOLO_MARGIN =
		NETWORK == Network.Mainnet ? 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		NETWORK == Network.Kovan ? 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant Sushiswap_ROUTER02 =
		NETWORK == Network.Mainnet ? 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F :
		// NETWORK == Network.Ropsten ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Rinkeby ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Kovan ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Goerli ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant UniswapV2_ROUTER02 =
		NETWORK == Network.Mainnet ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Ropsten ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Rinkeby ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Kovan ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Goerli ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		0x0000000000000000000000000000000000000000;
}

// File: contracts/modules/Wrapping.sol

pragma solidity ^0.6.0;



/**
 * @dev This library abstracts Wrapped Ether operations.
 */
library Wrapping
{
	/**
	 * @dev Sends some ETH to the Wrapped Ether contract in exchange for WETH.
	 * @param _amount The amount of ETH to be wrapped in WETH.
	 * @return _success A boolean indicating whether or not the operation suceeded.
	 */
	function _wrap(uint256 _amount) internal returns (bool _success)
	{
		try WETH($.WETH).deposit{value: _amount}() {
			return true;
		} catch (bytes memory /* _data */) {
			return false;
		}
	}

	/**
	 * @dev Receives some ETH from the Wrapped Ether contract in exchange for WETH.
	 *      Note that the contract using this library function must declare a
	 *      payable receive/fallback function.
	 * @param _amount The amount of ETH to be wrapped in WETH.
	 * @return _success A boolean indicating whether or not the operation suceeded.
	 */
	function _unwrap(uint256 _amount) internal returns (bool _success)
	{
		try WETH($.WETH).withdraw(_amount) {
			return true;
		} catch (bytes memory /* _data */) {
			return false;
		}
	}

	/**
	 * @dev Sends some ETH to the Wrapped Ether contract in exchange for WETH.
	 *      This operation will revert if it does not succeed.
	 * @param _amount The amount of ETH to be wrapped in WETH.
	 */
	function _safeWrap(uint256 _amount) internal
	{
		require(_wrap(_amount), "wrap failed");
	}

	/**
	 * @dev Receives some ETH from the Wrapped Ether contract in exchange for WETH.
	 *      This operation will revert if it does not succeed. Note that
	 *      the contract using this library function must declare a payable
	 *      receive/fallback function.
	 * @param _amount The amount of ETH to be wrapped in WETH.
	 */
	function _safeUnwrap(uint256 _amount) internal
	{
		require(_unwrap(_amount), "unwrap failed");
	}
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
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

// File: contracts/modules/Transfers.sol

pragma solidity ^0.6.0;



/**
 * @dev This library abstracts ERC-20 operations.
 */
library Transfers
{
	using SafeERC20 for IERC20;

	/**
	 * @dev Retrieves a given ERC-20 token balance for the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @return _balance The current contract balance of the given ERC-20 token.
	 */
	function _getBalance(address _token) internal view returns (uint256 _balance)
	{
		return IERC20(_token).balanceOf(address(this));
	}

	/**
	 * @dev Allows a spender to access a given ERC-20 balance for the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _to The spender address.
	 * @param _amount The exact spending allowance amount.
	 */
	function _approveFunds(address _token, address _to, uint256 _amount) internal
	{
		uint256 _allowance = IERC20(_token).allowance(address(this), _to);
		if (_allowance > _amount) {
			IERC20(_token).safeDecreaseAllowance(_to, _allowance - _amount);
		}
		else
		if (_allowance < _amount) {
			IERC20(_token).safeIncreaseAllowance(_to, _amount - _allowance);
		}
	}

	/**
	 * @dev Transfer a given ERC-20 token amount into the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _from The source address.
	 * @param _amount The amount to be transferred.
	 */
	function _pullFunds(address _token, address _from, uint256 _amount) internal
	{
		if (_amount == 0) return;
		IERC20(_token).safeTransferFrom(_from, address(this), _amount);
	}

	/**
	 * @dev Transfer a given ERC-20 token amount from the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _to The target address.
	 * @param _amount The amount to be transferred.
	 */
	function _pushFunds(address _token, address _to, uint256 _amount) internal
	{
		if (_amount == 0) return;
		IERC20(_token).safeTransfer(_to, _amount);
	}
}

// File: contracts/interop/UniswapV2.sol

pragma solidity ^0.6.0;

/**
 * @dev Minimal set of declarations for Uniswap V2 interoperability.
 */
interface Router01
{
	function WETH() external pure returns (address _token);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function getAmountsOut(uint256 _amountIn, address[] calldata _path) external view returns (uint[] memory _amounts);
	function getAmountsIn(uint256 _amountOut, address[] calldata _path) external view returns (uint[] memory _amounts);
}

interface Router02 is Router01
{
}

// File: contracts/modules/UniswapV2ExchangeAbstraction.sol

pragma solidity ^0.6.0;




/**
 * @dev This library abstracts the Uniswap V2 token conversion functionality.
 */
library UniswapV2ExchangeAbstraction
{
	/**
	 * @dev Calculates how much output to be received from the given input
	 *      when converting between two assets.
	 * @param _from The input asset address.
	 * @param _to The output asset address.
	 * @param _inputAmount The input asset amount to be provided.
	 * @return _outputAmount The output asset amount to be received.
	 */
	function _calcConversionOutputFromInput(address _from, address _to, uint256 _inputAmount) internal view returns (uint256 _outputAmount)
	{
		address _router = $.UniswapV2_ROUTER02;
		address _WETH = Router02(_router).WETH();
		address[] memory _path = _buildPath(_from, _WETH, _to);
		return Router02(_router).getAmountsOut(_inputAmount, _path)[_path.length - 1];
	}

	/**
	 * @dev Calculates how much input to be received the given the output
	 *      when converting between two assets.
	 * @param _from The input asset address.
	 * @param _to The output asset address.
	 * @param _outputAmount The output asset amount to be received.
	 * @return _inputAmount The input asset amount to be provided.
	 */
	function _calcConversionInputFromOutput(address _from, address _to, uint256 _outputAmount) internal view returns (uint256 _inputAmount)
	{
		address _router = $.UniswapV2_ROUTER02;
		address _WETH = Router02(_router).WETH();
		address[] memory _path = _buildPath(_from, _WETH, _to);
		return Router02(_router).getAmountsIn(_outputAmount, _path)[0];
	}

	/**
	 * @dev Convert funds between two assets.
	 * @param _from The input asset address.
	 * @param _to The output asset address.
	 * @param _inputAmount The input asset amount to be provided.
	 * @param _minOutputAmount The output asset minimum amount to be received.
	 * @return _outputAmount The output asset amount received.
	 */
	function _convertFunds(address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) internal returns (uint256 _outputAmount)
	{
		address _router = $.UniswapV2_ROUTER02;
		address _WETH = Router02(_router).WETH();
		address[] memory _path = _buildPath(_from, _WETH, _to);
		Transfers._approveFunds(_from, _router, _inputAmount);
		return Router02(_router).swapExactTokensForTokens(_inputAmount, _minOutputAmount, _path, address(this), uint256(-1))[_path.length - 1];
	}

	/**
	 * @dev Builds a routing path for conversion using WETH as intermediate.
	 *      Deals with the special case where WETH is also the input or the
	 *      output asset.
	 * @param _from The input asset address.
	 * @param _WETH The Wrapped Ether address.
	 * @param _to The output asset address.
	 * @return _path The route to perform conversion.
	 */
	function _buildPath(address _from, address _WETH, address _to) internal pure returns (address[] memory _path)
	{
		if (_from == _WETH || _to == _WETH) {
			_path = new address[](2);
			_path[0] = _from;
			_path[1] = _to;
			return _path;
		} else {
			_path = new address[](3);
			_path[0] = _from;
			_path[1] = _WETH;
			_path[2] = _to;
			return _path;
		}
	}
}

// File: contracts/GExchange.sol

pragma solidity ^0.6.0;

/**
 * @dev Custom and uniform interface to a decentralized exchange. It is used
 *      to estimate and convert funds whenever necessary. This furnishes
 *      client contracts with the flexibility to replace conversion strategy
 *      and routing, dynamically, by delegating these operations to different
 *      external contracts that share this common interface. See
 *      GUniswapV2Exchange.sol for further documentation.
 */
interface GExchange
{
	// view functions
	function calcConversionOutputFromInput(address _from, address _to, uint256 _inputAmount) external view returns (uint256 _outputAmount);
	function calcConversionInputFromOutput(address _from, address _to, uint256 _outputAmount) external view returns (uint256 _inputAmount);

	// open functions
	function convertFunds(address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) external returns (uint256 _outputAmount);
}

// File: contracts/modules/Conversions.sol

pragma solidity ^0.6.0;





library Conversions
{
	function _calcConversionOutputFromInput(address _from, address _to, uint256 _inputAmount) internal view returns (uint256 _outputAmount)
	{
		if (_inputAmount == 0) return 0;
		return UniswapV2ExchangeAbstraction._calcConversionOutputFromInput(_from, _to, _inputAmount);
	}

	function _calcConversionInputFromOutput(address _from, address _to, uint256 _outputAmount) internal view returns (uint256 _inputAmount)
	{
		if (_outputAmount == 0) return 0;
		return UniswapV2ExchangeAbstraction._calcConversionInputFromOutput(_from, _to, _outputAmount);
	}

	function _convertFunds(address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) internal returns (uint256 _outputAmount)
	{
		if (_inputAmount == 0) {
			require(_minOutputAmount == 0, "insufficient output amount");
			return 0;
		}
		return UniswapV2ExchangeAbstraction._convertFunds(_from, _to, _inputAmount, _minOutputAmount);
	}

	function _dynamicConvertFunds(address _exchange, address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) internal returns (uint256 _outputAmount)
	{
		Transfers._approveFunds(_from, _exchange, _inputAmount);
		try GExchange(_exchange).convertFunds(_from, _to, _inputAmount, _minOutputAmount) returns (uint256 _outAmount) {
			return _outAmount;
		} catch (bytes memory /* _data */) {
			Transfers._approveFunds(_from, _exchange, 0);
			return 0;
		}
	}
}

// File: contracts/interop/Aave.sol

pragma solidity ^0.6.0;


/**
 * @dev Minimal set of declarations for Aave interoperability.
 */
interface LendingPoolAddressesProvider
{
	function getLendingPool() external view returns (address _pool);
	function getLendingPoolCore() external view returns (address payable _lendingPoolCore);
	function getPriceOracle() external view returns (address _priceOracle);
}

interface LendingPool
{
	function getReserveConfigurationData(address _reserve) external view returns (uint256 _ltv, uint256 _liquidationThreshold, uint256 _liquidationBonus, address _interestRateStrategyAddress, bool _usageAsCollateralEnabled, bool _borrowingEnabled, bool _stableBorrowRateEnabled, bool _isActive);
	function getUserAccountData(address _user) external view returns (uint256 _totalLiquidityETH, uint256 _totalCollateralETH, uint256 _totalBorrowsETH, uint256 _totalFeesETH, uint256 _availableBorrowsETH, uint256 _currentLiquidationThreshold, uint256 _ltv, uint256 _healthFactor);
	function getUserReserveData(address _reserve, address _user) external view returns (uint256 _currentATokenBalance, uint256 _currentBorrowBalance, uint256 _principalBorrowBalance, uint256 _borrowRateMode, uint256 _borrowRate, uint256 _liquidityRate, uint256 _originationFee, uint256 _variableBorrowIndex, uint256 _lastUpdateTimestamp, bool _usageAsCollateralEnabled);
	function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
	function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;
	function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
	function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params) external;
}

interface LendingPoolCore
{
	function getReserveDecimals(address _reserve) external view returns (uint256 _decimals);
	function getReserveAvailableLiquidity(address _reserve) external view returns (uint256 _availableLiquidity);
}

interface AToken is IERC20
{
	function underlyingAssetAddress() external view returns (address _underlyingAssetAddress);
	function redeem(uint256 _amount) external;
}

interface APriceOracle
{
	function getAssetPrice(address _asset) external view returns (uint256 _assetPrice);
}

interface FlashLoanReceiver
{
	function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}

// File: contracts/modules/AaveFlashLoanAbstraction.sol

pragma solidity ^0.6.0;





/**
 * @dev This library abstracts the Aave flash loan functionality. It has a
 *      standardized flash loan interface. See GFlashBorrower.sol,
 *      FlashLoans.sol, and DydxFlashLoanAbstraction.sol for further documentation.
 */
library AaveFlashLoanAbstraction
{
	using SafeMath for uint256;

	uint256 constant FLASH_LOAN_FEE_RATIO = 9e14; // 0.09%

	/**
	 * @dev Estimates the flash loan fee given the reserve token and required amount.
	 * @param _token The ERC-20 token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _feeAmount the expected fee to be payed in excees of the loan amount.
	 */
	function _estimateFlashLoanFee(address _token, uint256 _netAmount) internal pure returns (uint256 _feeAmount)
	{
		_token; // silences warnings
		return _netAmount.mul(FLASH_LOAN_FEE_RATIO).div(1e18);
	}

	/**
	 * @dev Retrieves the current market liquidity for a given reserve.
	 * @param _token The reserve token to flash borrow from.
	 * @return _liquidityAmount The reserve token available market liquidity.
	 */
	function _getFlashLoanLiquidity(address _token) internal view returns (uint256 _liquidityAmount)
	{
		address _core = $.Aave_AAVE_LENDING_POOL_CORE;
		return LendingPoolCore(_core).getReserveAvailableLiquidity(_token);
	}

	/**
	 * @dev Triggers a flash loan. The current contract will receive a call
	 *      back with the loan amount and should repay it, including fees,
	 *      before returning. See GFlashBorrow.sol.
	 * @param _token The reserve token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _context Additional data to be passed to the call back.
	 * @return _success A boolean indicating whether or not the operation suceeded.
         */
	function _requestFlashLoan(address _token, uint256 _netAmount, bytes memory _context) internal returns (bool _success)
	{
		address _pool = $.Aave_AAVE_LENDING_POOL;
		try LendingPool(_pool).flashLoan(address(this), _token, _netAmount, _context) {
			return true;
		} catch (bytes memory /* _data */) {
			return false;
		}
	}

	/**
	 * @dev This function should be called as the final step of the flash
	 *      loan to properly implement the repay of the loan.
	 * @param _token The reserve token.
	 * @param _grossAmount The amount to be repayed including repay fees.
	 */
	function _paybackFlashLoan(address _token, uint256 _grossAmount) internal
	{
		address _poolCore = $.Aave_AAVE_LENDING_POOL_CORE;
		Transfers._pushFunds(_token, _poolCore, _grossAmount);
	}
}

// File: contracts/interop/Dydx.sol

pragma solidity ^0.6.0;

/**
 * @dev Minimal set of declarations for Dydx interoperability.
 */
interface SoloMargin
{
	function getMarketTokenAddress(uint256 _marketId) external view returns (address _token);
	function getNumMarkets() external view returns (uint256 _numMarkets);
	function operate(Account.Info[] memory _accounts, Actions.ActionArgs[] memory _actions) external;
}

interface ICallee
{
	function callFunction(address _sender, Account.Info memory _accountInfo, bytes memory _data) external;
}

library Account
{
	struct Info {
		address owner;
		uint256 number;
	}
}

library Actions
{
	enum ActionType { Deposit, Withdraw, Transfer, Buy, Sell, Trade, Liquidate, Vaporize, Call }

	struct ActionArgs {
		ActionType actionType;
		uint256 accountId;
		Types.AssetAmount amount;
		uint256 primaryMarketId;
		uint256 secondaryMarketId;
		address otherAddress;
		uint256 otherAccountId;
		bytes data;
	}
}

library Types
{
	enum AssetDenomination { Wei, Par }
	enum AssetReference { Delta, Target }

	struct AssetAmount {
		bool sign;
		AssetDenomination denomination;
		AssetReference ref;
		uint256 value;
	}
}

// File: contracts/modules/DydxFlashLoanAbstraction.sol

pragma solidity ^0.6.0;






/**
 * @dev This library abstracts the Dydx flash loan functionality. It has a
 *      standardized flash loan interface. See GFlashBorrower.sol,
 *      FlashLoans.sol, and AaveFlashLoanAbstraction.sol for further documentation.
 */
library DydxFlashLoanAbstraction
{
	using SafeMath for uint256;

	/**
	 * @dev Estimates the flash loan fee given the reserve token and required amount.
	 * @param _token The ERC-20 token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _feeAmount the expected fee to be payed in excees of the loan amount.
	 */
	function _estimateFlashLoanFee(address _token, uint256 _netAmount) internal pure returns (uint256 _feeAmount)
	{
		_token; _netAmount; // silences warnings
		return 2; // dydx has no fees, 2 wei is just a recommendation
	}

	/**
	 * @dev Retrieves the current market liquidity for a given reserve.
	 * @param _token The reserve token to flash borrow from.
	 * @return _liquidityAmount The reserve token available market liquidity.
	 */
	function _getFlashLoanLiquidity(address _token) internal view returns (uint256 _liquidityAmount)
	{
		address _solo = $.Dydx_SOLO_MARGIN;
		return IERC20(_token).balanceOf(_solo);
	}

	/**
	 * @dev Triggers a flash loan. The current contract will receive a call
	 *      back with the loan amount and should repay it, including fees,
	 *      before returning. See GFlashBorrow.sol.
	 * @param _token The reserve token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _context Additional data to be passed to the call back.
	 * @return _success A boolean indicating whether or not the operation suceeded.
         */
	function _requestFlashLoan(address _token, uint256 _netAmount, bytes memory _context) internal returns (bool _success)
	{
		address _solo = $.Dydx_SOLO_MARGIN;
		uint256 _feeAmount = 2;
		uint256 _grossAmount = _netAmount.add(_feeAmount);
		// attempts to find the market id given a reserve token
		uint256 _marketId = uint256(-1);
		uint256 _numMarkets = SoloMargin(_solo).getNumMarkets();
		for (uint256 _i = 0; _i < _numMarkets; _i++) {
			address _address = SoloMargin(_solo).getMarketTokenAddress(_i);
			if (_address == _token) {
				_marketId = _i;
				break;
			}
		}
		if (_marketId == uint256(-1)) return false;
		// a flash loan on Dydx is achieved by the following sequence of
		// actions: withdrawal, user call back, and finally a deposit;
		// which is configured below
		Account.Info[] memory _accounts = new Account.Info[](1);
		_accounts[0] = Account.Info({ owner: address(this), number: 1 });
		Actions.ActionArgs[] memory _actions = new Actions.ActionArgs[](3);
		_actions[0] = Actions.ActionArgs({
			actionType: Actions.ActionType.Withdraw,
			accountId: 0,
			amount: Types.AssetAmount({
				sign: false,
				denomination: Types.AssetDenomination.Wei,
				ref: Types.AssetReference.Delta,
				value: _netAmount
			}),
			primaryMarketId: _marketId,
			secondaryMarketId: 0,
			otherAddress: address(this),
			otherAccountId: 0,
			data: ""
		});
		_actions[1] = Actions.ActionArgs({
			actionType: Actions.ActionType.Call,
			accountId: 0,
			amount: Types.AssetAmount({
				sign: false,
				denomination: Types.AssetDenomination.Wei,
				ref: Types.AssetReference.Delta,
				value: 0
			}),
			primaryMarketId: 0,
			secondaryMarketId: 0,
			otherAddress: address(this),
			otherAccountId: 0,
			data: abi.encode(_token, _netAmount, _feeAmount, _context)
		});
		_actions[2] = Actions.ActionArgs({
			actionType: Actions.ActionType.Deposit,
			accountId: 0,
			amount: Types.AssetAmount({
				sign: true,
				denomination: Types.AssetDenomination.Wei,
				ref: Types.AssetReference.Delta,
				value: _grossAmount
			}),
			primaryMarketId: _marketId,
			secondaryMarketId: 0,
			otherAddress: address(this),
			otherAccountId: 0,
			data: ""
		});
		try SoloMargin(_solo).operate(_accounts, _actions) {
			return true;
		} catch (bytes memory /* _data */) {
			return false;
		}
	}

	/**
	 * @dev This function should be called as the final step of the flash
	 *      loan to properly implement the repay of the loan.
	 * @param _token The reserve token.
	 * @param _grossAmount The amount to be repayed including repay fees.
	 */
	function _paybackFlashLoan(address _token, uint256 _grossAmount) internal
	{
		address _solo = $.Dydx_SOLO_MARGIN;
		Transfers._approveFunds(_token, _solo, _grossAmount);
	}
}

// File: contracts/modules/FlashLoans.sol

pragma solidity ^0.6.0;





/**
 * @dev This library abstracts the flash loan request combining both Aave/Dydx.
 *      See GFlashBorrower.sol, AaveFlashLoanAbstraction.sol, and
 *      DydxFlashLoanAbstraction.sol for further documentation.
 */
library FlashLoans
{
	enum Provider { Aave, Dydx }

	/**
	 * @dev Estimates the flash loan fee given the reserve token and required amount.
	 * @param _provider The flash loan provider, either Aave or Dydx.
	 * @param _token The ERC-20 token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _feeAmount the expected fee to be payed in excees of the loan amount.
	 */
	function _estimateFlashLoanFee(Provider _provider, address _token, uint256 _netAmount) internal pure returns (uint256 _feeAmount)
	{
		if (_provider == Provider.Aave) return AaveFlashLoanAbstraction._estimateFlashLoanFee(_token, _netAmount);
		if (_provider == Provider.Dydx) return DydxFlashLoanAbstraction._estimateFlashLoanFee(_token, _netAmount);
	}

	/**
	 * @dev Retrieves the maximum market liquidity for a given reserve on
	 *      both Aave and Dydx.
	 * @param _token The reserve token to flash borrow from.
	 * @return _liquidityAmount The reserve token available market liquidity.
	 */
	function _getFlashLoanLiquidity(address _token) internal view returns (uint256 _liquidityAmount)
	{
		uint256 _liquidityAmountDydx = 0;
		if ($.NETWORK == $.Network.Mainnet || $.NETWORK == $.Network.Kovan) {
			_liquidityAmountDydx = DydxFlashLoanAbstraction._getFlashLoanLiquidity(_token);
		}
		uint256 _liquidityAmountAave = 0;
		if ($.NETWORK == $.Network.Mainnet || $.NETWORK == $.Network.Ropsten || $.NETWORK == $.Network.Kovan) {
			_liquidityAmountAave = AaveFlashLoanAbstraction._getFlashLoanLiquidity(_token);
		}
		return Math._max(_liquidityAmountDydx, _liquidityAmountAave);
	}

	/**
	 * @dev Triggers a flash loan on Dydx and, if unsuccessful, on Aave.
	 *      The current contract will receive a call back with the loan
	 *      amount and should repay it, including fees, before returning.
	 *      See GFlashBorrow.sol.
	 * @param _token The reserve token to flash borrow from.
	 * @param _netAmount The amount to be borrowed without considering repay fees.
	 * @param _context Additional data to be passed to the call back.
	 * @return _success A boolean indicating whether or not the operation suceeded.
         */
	function _requestFlashLoan(address _token, uint256 _netAmount, bytes memory _context) internal returns (bool _success)
	{
		if ($.NETWORK == $.Network.Mainnet || $.NETWORK == $.Network.Kovan) {
			_success = DydxFlashLoanAbstraction._requestFlashLoan(_token, _netAmount, _context);
			if (_success) return true;
		}
		if ($.NETWORK == $.Network.Mainnet || $.NETWORK == $.Network.Ropsten || $.NETWORK == $.Network.Kovan) {
			_success = AaveFlashLoanAbstraction._requestFlashLoan(_token, _netAmount, _context);
			if (_success) return true;
		}
		return false;
	}

	/**
	 * @dev This function should be called as the final step of the flash
	 *      loan to properly implement the repay of the loan.
	 * @param _provider The flash loan provider, either Aave or Dydx.
	 * @param _token The reserve token.
	 * @param _grossAmount The amount to be repayed including repay fees.
	 */
	function _paybackFlashLoan(Provider _provider, address _token, uint256 _grossAmount) internal
	{
		if (_provider == Provider.Aave) return AaveFlashLoanAbstraction._paybackFlashLoan(_token, _grossAmount);
		if (_provider == Provider.Dydx) return DydxFlashLoanAbstraction._paybackFlashLoan(_token, _grossAmount);
	}
}

// File: contracts/interop/Balancer.sol

pragma solidity ^0.6.0;


/**
 * @dev Minimal set of declarations for Balancer interoperability.
 */
interface BFactory
{
	function newBPool() external returns (address _pool);
}

interface BPool is IERC20
{
	function getFinalTokens() external view returns (address[] memory _tokens);
	function getBalance(address _token) external view returns (uint256 _balance);
	function setSwapFee(uint256 _swapFee) external;
	function finalize() external;
	function bind(address _token, uint256 _balance, uint256 _denorm) external;
	function exitPool(uint256 _poolAmountIn, uint256[] calldata _minAmountsOut) external;
	function joinswapExternAmountIn(address _tokenIn, uint256 _tokenAmountIn, uint256 _minPoolAmountOut) external returns (uint256 _poolAmountOut);
}

// File: contracts/modules/BalancerLiquidityPoolAbstraction.sol

pragma solidity ^0.6.0;






/**
 * @dev This library abstracts the Balancer liquidity pool operations.
 */
library BalancerLiquidityPoolAbstraction
{
	using SafeMath for uint256;

	uint256 constant MIN_AMOUNT = 1e6; // transported from Balancer
	uint256 constant TOKEN0_WEIGHT = 25e18; // 25/50 = 50%
	uint256 constant TOKEN1_WEIGHT = 25e18; // 25/50 = 50%
	uint256 constant SWAP_FEE = 10e16; // 10%

	/**
	 * @dev Creates a two-asset liquidity pool and funds it by depositing
	 *      both assets. The create pool is public with a 50%/50%
	 *      distribution and 10% swap fee.
	 * @param _token0 The ERC-20 token for the first asset of the pair.
	 * @param _amount0 The amount of the first asset of the pair to be deposited.
	 * @param _token1 The ERC-20 token for the second asset of the pair.
	 * @param _amount1 The amount of the second asset of the pair to be deposited.
	 * @return _pool The address of the newly created pool.
	 */
	function _createPool(address _token0, uint256 _amount0, address _token1, uint256 _amount1) internal returns (address _pool)
	{
		require(_amount0 >= MIN_AMOUNT && _amount1 >= MIN_AMOUNT, "amount below the minimum");
		_pool = BFactory($.Balancer_FACTORY).newBPool();
		Transfers._approveFunds(_token0, _pool, _amount0);
		Transfers._approveFunds(_token1, _pool, _amount1);
		BPool(_pool).bind(_token0, _amount0, TOKEN0_WEIGHT);
		BPool(_pool).bind(_token1, _amount1, TOKEN1_WEIGHT);
		BPool(_pool).setSwapFee(SWAP_FEE);
		BPool(_pool).finalize();
		return _pool;
	}

	/**
	 * @dev Deposits a single asset into the liquidity pool.
	 * @param _pool The liquidity pool address.
	 * @param _token The ERC-20 token for the asset being deposited.
	 * @param _maxAmount The maximum amount to be deposited.
	 * @return _amount The actual amount deposited.
	 */
	function _joinPool(address _pool, address _token, uint256 _maxAmount) internal returns (uint256 _amount)
	{
		if (_maxAmount == 0) return 0;
		uint256 _balanceAmount = BPool(_pool).getBalance(_token);
		if (_balanceAmount == 0) return 0;
		// caps the deposit amount to half the liquidity to mitigate error
		uint256 _limitAmount = _balanceAmount.div(2);
		_amount = Math._min(_maxAmount, _limitAmount);
		Transfers._approveFunds(_token, _pool, _amount);
		BPool(_pool).joinswapExternAmountIn(_token, _amount, 0);
		return _amount;
	}

	/**
	 * @dev Withdraws a percentage of the pool shares.
	 * @param _pool The liquidity pool address.
	 * @param _percent The percent amount normalized to 1e18 (100%).
	 * @return _amount0 The amount received of the first asset of the pair.
	 * @return _amount1 The amount received of the second asset of the pair.
	 */
	function _exitPool(address _pool, uint256 _percent) internal returns (uint256 _amount0, uint256 _amount1)
	{
		if (_percent == 0) return (0, 0);
		address[] memory _tokens = BPool(_pool).getFinalTokens();
		_amount0 = Transfers._getBalance(_tokens[0]);
		_amount1 = Transfers._getBalance(_tokens[1]);
		uint256 _poolAmount = Transfers._getBalance(_pool);
		uint256 _poolExitAmount = _poolAmount.mul(_percent).div(1e18);
		uint256[] memory _minAmountsOut = new uint256[](2);
		_minAmountsOut[0] = 0;
		_minAmountsOut[1] = 0;
		BPool(_pool).exitPool(_poolExitAmount, _minAmountsOut);
		_amount0 = Transfers._getBalance(_tokens[0]).sub(_amount0);
		_amount1 = Transfers._getBalance(_tokens[1]).sub(_amount1);
		return (_amount0, _amount1);
	}
}

// File: contracts/G.sol

pragma solidity ^0.6.0;







/**
 * @dev This public library provides a single entrypoint to most of the relevant
 *      internal libraries available in the modules folder. It exists to
 *      circunvent the contract size limitation imposed by the EVM. All function
 *      calls are directly delegated to the target library function preserving
 *      argument and return values exactly as they are. This library is shared
 *      by many contracts and even other public libraries from this repository,
 *      therefore it needs to be published alongside them.
 */
library G
{
	function min(uint256 _amount1, uint256 _amount2) public pure returns (uint256 _minAmount) { return Math._min(_amount1, _amount2); }
//	function max(uint256 _amount1, uint256 _amount2) public pure returns (uint256 _maxAmount) { return Math._max(_amount1, _amount2); }

//	function wrap(uint256 _amount) public returns (bool _success) { return Wrapping._wrap(_amount); }
//	function unwrap(uint256 _amount) public returns (bool _success) { return Wrapping._unwrap(_amount); }
	function safeWrap(uint256 _amount) public { Wrapping._safeWrap(_amount); }
	function safeUnwrap(uint256 _amount) public { Wrapping._safeUnwrap(_amount); }

	function getBalance(address _token) public view returns (uint256 _balance) { return Transfers._getBalance(_token); }
	function pullFunds(address _token, address _from, uint256 _amount) public { Transfers._pullFunds(_token, _from, _amount); }
	function pushFunds(address _token, address _to, uint256 _amount) public { Transfers._pushFunds(_token, _to, _amount); }
	function approveFunds(address _token, address _to, uint256 _amount) public { Transfers._approveFunds(_token, _to, _amount); }

//	function calcConversionOutputFromInput(address _from, address _to, uint256 _inputAmount) public view returns (uint256 _outputAmount) { return Conversions._calcConversionOutputFromInput(_from, _to, _inputAmount); }
//	function calcConversionInputFromOutput(address _from, address _to, uint256 _outputAmount) public view returns (uint256 _inputAmount) { return Conversions._calcConversionInputFromOutput(_from, _to, _outputAmount); }
//	function convertFunds(address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) public returns (uint256 _outputAmount) { return Conversions._convertFunds(_from, _to, _inputAmount, _minOutputAmount); }
	function dynamicConvertFunds(address _exchange, address _from, address _to, uint256 _inputAmount, uint256 _minOutputAmount) public returns (uint256 _outputAmount) { return Conversions._dynamicConvertFunds(_exchange, _from, _to, _inputAmount, _minOutputAmount); }

//	function estimateFlashLoanFee(FlashLoans.Provider _provider, address _token, uint256 _netAmount) public pure returns (uint256 _feeAmount) { return FlashLoans._estimateFlashLoanFee(_provider, _token, _netAmount); }
	function getFlashLoanLiquidity(address _token) public view returns (uint256 _liquidityAmount) { return FlashLoans._getFlashLoanLiquidity(_token); }
	function requestFlashLoan(address _token, uint256 _amount, bytes memory _context) public returns (bool _success) { return FlashLoans._requestFlashLoan(_token, _amount, _context); }
	function paybackFlashLoan(FlashLoans.Provider _provider, address _token, uint256 _grossAmount) public { FlashLoans._paybackFlashLoan(_provider, _token, _grossAmount); }

	function createPool(address _token0, uint256 _amount0, address _token1, uint256 _amount1) public returns (address _pool) { return BalancerLiquidityPoolAbstraction._createPool(_token0, _amount0, _token1, _amount1); }
	function joinPool(address _pool, address _token, uint256 _maxAmount) public returns (uint256 _amount) { return BalancerLiquidityPoolAbstraction._joinPool(_pool, _token, _maxAmount); }
	function exitPool(address _pool, uint256 _percent) public returns (uint256 _amount0, uint256 _amount1) { return BalancerLiquidityPoolAbstraction._exitPool(_pool, _percent); }
}

// File: contracts/GTokenType3.sol

pragma solidity ^0.6.0;








/**
 * @notice This contract implements the functionality for the gToken Type 3.
 *         It has a higher deposit/withdrawal fee when compared to other
 *         gTokens (10%). Half of the collected fee used to reward token
 *         holders while the other half is burned along with the same proportion
 *         of the reserve. It is used in the implementation of stkGRO.
 */
abstract contract GTokenType3 is ERC20, ReentrancyGuard, GToken, GVoting
{
	using SafeMath for uint256;

	uint256 constant DEPOSIT_FEE = 10e16; // 10%
	uint256 constant WITHDRAWAL_FEE = 10e16; // 10%

	uint256 constant VOTING_ROUND_INTERVAL = 5 minutes;

	address public immutable override reserveToken;

	mapping (address => address) public override candidate;

	mapping (address => uint256) private votingRound;
	mapping (address => uint256[2]) private voting;

	/**
	 * @dev Constructor for the gToken contract.
	 * @param _name The ERC-20 token name.
	 * @param _symbol The ERC-20 token symbol.
	 * @param _decimals The ERC-20 token decimals.
	 * @param _reserveToken The ERC-20 token address to be used as reserve
	 *                      token (e.g. GRO for sktGRO).
	 */
	constructor (string memory _name, string memory _symbol, uint8 _decimals, address _reserveToken)
		ERC20(_name, _symbol) public
	{
		_setupDecimals(_decimals);
		reserveToken = _reserveToken;
	}

	/**
	 * @notice Allows for the beforehand calculation of shares to be
	 *         received/minted upon depositing to the contract.
	 * @param _cost The amount of reserve token being deposited.
	 * @param _totalReserve The reserve balance as obtained by totalReserve().
	 * @param _totalSupply The shares supply as obtained by totalSupply().
	 * @param _depositFee The current deposit fee as obtained by depositFee().
	 * @return _netShares The net amount of shares being received.
	 * @return _feeShares The fee amount of shares being deducted.
	 */
	function calcDepositSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) public pure override returns (uint256 _netShares, uint256 _feeShares)
	{
		return GFormulae._calcDepositSharesFromCost(_cost, _totalReserve, _totalSupply, _depositFee);
	}

	/**
	 * @notice Allows for the beforehand calculation of the amount of
	 *         reserve token to be deposited in order to receive the desired
	 *         amount of shares.
	 * @param _netShares The amount of this gToken shares to receive.
	 * @param _totalReserve The reserve balance as obtained by totalReserve().
	 * @param _totalSupply The shares supply as obtained by totalSupply().
	 * @param _depositFee The current deposit fee as obtained by depositFee().
	 * @return _cost The cost, in the reserve token, to be paid.
	 * @return _feeShares The fee amount of shares being deducted.
	 */
	function calcDepositCostFromShares(uint256 _netShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _depositFee) public pure override returns (uint256 _cost, uint256 _feeShares)
	{
		return GFormulae._calcDepositCostFromShares(_netShares, _totalReserve, _totalSupply, _depositFee);
	}

	/**
	 * @notice Allows for the beforehand calculation of shares to be
	 *         given/burned upon withdrawing from the contract.
	 * @param _cost The amount of reserve token being withdrawn.
	 * @param _totalReserve The reserve balance as obtained by totalReserve()
	 * @param _totalSupply The shares supply as obtained by totalSupply()
	 * @param _withdrawalFee The current withdrawal fee as obtained by withdrawalFee()
	 * @return _grossShares The total amount of shares being deducted,
	 *                      including fees.
	 * @return _feeShares The fee amount of shares being deducted.
	 */
	function calcWithdrawalSharesFromCost(uint256 _cost, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) public pure override returns (uint256 _grossShares, uint256 _feeShares)
	{
		return GFormulae._calcWithdrawalSharesFromCost(_cost, _totalReserve, _totalSupply, _withdrawalFee);
	}

	/**
	 * @notice Allows for the beforehand calculation of the amount of
	 *         reserve token to be withdrawn given the desired amount of
	 *         shares.
	 * @param _grossShares The amount of this gToken shares to provide.
	 * @param _totalReserve The reserve balance as obtained by totalReserve().
	 * @param _totalSupply The shares supply as obtained by totalSupply().
	 * @param _withdrawalFee The current withdrawal fee as obtained by withdrawalFee().
	 * @return _cost The cost, in the reserve token, to be received.
	 * @return _feeShares The fee amount of shares being deducted.
	 */
	function calcWithdrawalCostFromShares(uint256 _grossShares, uint256 _totalReserve, uint256 _totalSupply, uint256 _withdrawalFee) public pure override returns (uint256 _cost, uint256 _feeShares)
	{
		return GFormulae._calcWithdrawalCostFromShares(_grossShares, _totalReserve, _totalSupply, _withdrawalFee);
	}

	/**
	 * @notice Provides the amount of reserve tokens currently being help by
	 *         this contract.
	 * @return _totalReserve The amount of the reserve token corresponding
	 *                       to this contract's balance.
	 */
	function totalReserve() public view virtual override returns (uint256 _totalReserve)
	{
		return G.getBalance(reserveToken);
	}

	/**
	 * @notice Provides the current minting/deposit fee. This fee is
	 *         applied to the amount of this gToken shares being created
	 *         upon deposit. The fee defaults to 10%.
	 * @return _depositFee A percent value that accounts for the percentage
	 *                     of shares being minted at each deposit that be
	 *                     collected as fee.
	 */
	function depositFee() public view override returns (uint256 _depositFee) {
		return DEPOSIT_FEE;
	}

	/**
	 * @notice Provides the current burning/withdrawal fee. This fee is
	 *         applied to the amount of this gToken shares being redeemed
	 *         upon withdrawal. The fee defaults to 10%.
	 * @return _withdrawalFee A percent value that accounts for the
	 *                        percentage of shares being burned at each
	 *                        withdrawal that be collected as fee.
	 */
	function withdrawalFee() public view override returns (uint256 _withdrawalFee) {
		return WITHDRAWAL_FEE;
	}

	/**
	 * @notice Provides the number of votes a given candidate has at the end
	 *         of the previous voting interval. The interval is 24 hours
	 *         and resets at 12AM UTC. See _transferVotes().
	 * @param _candidate The candidate for which we want to know the number
	 *                   of delegated votes.
	 * @return _votes The candidate number of votes. It is the sum of the
	 *                balances of the voters that have him as cadidate at
	 *                the end of the previous voting interval.
	 */
	function votes(address _candidate) public view override returns (uint256 _votes)
	{
		uint256 _votingRound = block.timestamp.div(VOTING_ROUND_INTERVAL);
		// if the candidate balance was last updated the current round
		// uses the backup instead (position 1), otherwise uses the most
		// up-to-date balance (position 0)
		return voting[_candidate][votingRound[_candidate] < _votingRound ? 0 : 1];
	}

	/**
	 * @notice Performs the minting of gToken shares upon the deposit of the
	 *         reserve token. The actual number of shares being minted can
	 *         be calculated using the calcDepositSharesFromCost function.
	 *         In every deposit, 10% of the shares is retained in terms of
	 *         deposit fee. The fee amount and half of its equivalent
	 *         reserve amount are immediately burned. The funds will be
	 *         pulled in by this contract, therefore they must be previously
	 *         approved.
	 * @param _cost The amount of reserve token being deposited in the
	 *              operation.
	 */
	function deposit(uint256 _cost) public override nonReentrant
	{
		address _from = msg.sender;
		require(_cost > 0, "cost must be greater than 0");
		(uint256 _netShares, uint256 _feeShares) = GFormulae._calcDepositSharesFromCost(_cost, totalReserve(), totalSupply(), depositFee());
		require(_netShares > 0, "shares must be greater than 0");
		G.pullFunds(reserveToken, _from, _cost);
		_mint(_from, _netShares);
		_burnReserveFromShares(_feeShares.div(2));
	}

	/**
	 * @notice Performs the burning of gToken shares upon the withdrawal of
	 *         the reserve token. The actual amount of the reserve token to
	 *         be received can be calculated using the
	 *         calcWithdrawalCostFromShares function. In every withdrawal,
	 *         10% of the shares is retained in terms of withdrawal fee.
	 *         The fee amount and half of its equivalent reserve amount are
	 *         immediately burned.
	 * @param _grossShares The gross amount of this gToken shares being
	 *                     redeemed in the operation.
	 */
	function withdraw(uint256 _grossShares) public override nonReentrant
	{
		address _from = msg.sender;
		require(_grossShares > 0, "shares must be greater than 0");
		(uint256 _cost, uint256 _feeShares) = GFormulae._calcWithdrawalCostFromShares(_grossShares, totalReserve(), totalSupply(), withdrawalFee());
		require(_cost > 0, "cost must be greater than 0");
		_cost = G.min(_cost, G.getBalance(reserveToken));
		G.pushFunds(reserveToken, _from, _cost);
		_burn(_from, _grossShares);
		_burnReserveFromShares(_feeShares.div(2));
	}

	/**
	 * @notice Changes the voter's choice for candidate and vote delegation.
	 *         It is only going to be reflected in the voting by the next
	 *         interval. The interval is 24 hours and resets at 12AM UTC.
	 *         This function will emit a ChangeCandidate event.
	 * @param _newCandidate The new candidate chosen.
	 */
	function setCandidate(address _newCandidate) public override nonReentrant
	{
		address _voter = msg.sender;
		uint256 _votes = balanceOf(_voter);
		address _oldCandidate = candidate[_voter];
		candidate[_voter] = _newCandidate;
		_transferVotes(_oldCandidate, _newCandidate, _votes);
		emit ChangeCandidate(_voter, _oldCandidate, _newCandidate);
	}

	/**
	 * @dev Burns a given amount of shares worth of the reserve token.
	 *      See burnReserve().
	 * @param _grossShares The amount of shares for which the equivalent,
	 *                     in the reserve token, will be burned.
	 */
	function _burnReserveFromShares(uint256 _grossShares) internal virtual
	{
		// we use the withdrawal formula to calculated how much is burned (withdrawn) from the contract
		// since the fee is 0 using the deposit formula would yield the same amount
		(uint256 _feeCost,) = GFormulae._calcWithdrawalCostFromShares(_grossShares, totalReserve(), totalSupply(), 0);
		_burnReserve(_feeCost);
	}

	/**
	 * @dev Burns the given amount of the reserve token. The default behavior
	 *      of the function for general ERC-20 is to send the funds to
	 *      address(0), but that can be overriden by a subcontract.
	 * @param _reserveAmount The amount of the reserve token being burned.
	 */
	function _burnReserve(uint256 _reserveAmount) internal virtual
	{
		G.pushFunds(reserveToken, address(0), _reserveAmount);
	}

	/**
	 * @dev This hook is called whenever tokens are minted, burned and
	 *      transferred. This contract forbids token transfers by design.
	 *      Token minting and burning will be reflected in the additional
	 *      votes being credited or debited to the chosen candidate.
	 *      See _transferVotes().
	 * @param _from The provider of funds. Address 0 for minting.
	 * @param _to The receiver of funds. Address 0 for burning.
	 * @param _amount The amount being transfered.
	 */
	function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override
	{
		require(_from == address(0) || _to == address(0), "transfer prohibited");
		address _oldCandidate = candidate[_from];
		address _newCandidate = candidate[_to];
		uint256 _votes = _amount;
		_transferVotes(_oldCandidate, _newCandidate, _votes);
	}

	/**
	 * @dev Implements the vote transfer logic. It will deduct the votes
	 *      from one candidate and credit it to another candidate. If
	 *      either of candidates is the 0 address, the the voter is either
	 *      setting its initial candidate or abstaining himself from voting.
	 *      The change is only reflected after the voting interval resets.
	 *      We use a 2 element array to keep track of votes. The amount on
	 *      position 0 is always the current vote count for the candidate.
	 *      The amount on position 1 is a backup that reflect the vote count
	 *      prior to the current round only if it has been updated for the
	 *      current round. We also record the last voting round where the
	 *      candidate balance was updated. If the last round is the current
	 *      then we use the backup value on position 1, otherwise we use
	 *      the most up to date value on position 0. This function will
	 *      emit a ChangeVotes event upon candidate vote balance change.
	 *      See _updateVotes().
	 * @param _oldCandidate The candidate to deduct votes from.
	 * @param _newCandidate The candidate to credit voter for.
	 * @param _votes the number of votes being transfered.
	 */
	function _transferVotes(address _oldCandidate, address _newCandidate, uint256 _votes) internal
	{
		if (_votes == 0) return;
		if (_oldCandidate == _newCandidate) return;
		if (_oldCandidate != address(0)) {
			// position 0 always has the most up-to-date balance
			uint256 _oldVotes = voting[_oldCandidate][0];
			uint256 _newVotes = _oldVotes.sub(_votes);
			// updates position 0 backing up the previous amount
			_updateVotes(_oldCandidate, _newVotes);
			emit ChangeVotes(_oldCandidate, _oldVotes, _newVotes);
		}
		if (_newCandidate != address(0)) {
			// position 0 always has the most up-to-date balance
			uint256 _oldVotes = voting[_newCandidate][0];
			uint256 _newVotes = _oldVotes.add(_votes);
			// updates position 0 backing up the previous amount
			_updateVotes(_newCandidate, _newVotes);
			emit ChangeVotes(_newCandidate, _oldVotes, _newVotes);
		}
	}

	/**
	 * @dev Updates the candidate's current vote balance (position 0) and
	 *      backs up the vote balance for the previous interval (position 1).
	 *      The routine makes sure we do not overwrite and corrupt the
	 *      backup if multiple vote updates happen within a single roung.
	 *      See _transferVotes().
	 * @param _candidate The candidate for which we are updating the votes.
	 * @param _votes The candidate's new vote balance.
	 */
	function _updateVotes(address _candidate, uint256 _votes) internal
	{
		uint256 _votingRound = block.timestamp.div(VOTING_ROUND_INTERVAL);
		// if the candidates voting round is not the current it means
		// we are updating the voting balance for the first time in
		// the current round, that is the only time we want to make a
		// backup of the vote balance for the previous roung
		if (votingRound[_candidate] < _votingRound) {
			votingRound[_candidate] = _votingRound;
			// position 1 is the backup if there are updates in
			// the current round
			voting[_candidate][1] = voting[_candidate][0];
		}
		// position 0 always hold the up-to-date vote balance
		voting[_candidate][0] = _votes;
	}
}

// File: contracts/GTokens.sol

pragma solidity ^0.6.0;



/**
 * @notice Definition of stkGRO. As a gToken Type 3, it uses GRO as reserve and
 * burns both reserve and supply with each operation.
 */
contract TEST is GTokenType3
{
	constructor ()
		GTokenType3("TEST", "TEST", 18, $.GRO) public
	{
	}
}
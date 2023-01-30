/**
 *Submitted for verification at Etherscan.io on 2020-11-24
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

// File: contracts/network/$.sol

pragma solidity ^0.6.0;

/**
 * @dev This library is provided for conveniece. It is the single source for
 *      the current network and all related hardcoded contract addresses. It
 *      also provide useful definitions for debuging faultless code via events.
 */
library $
{
	address constant GRO = 0x09e64c2B61a5f1690Ee6fbeD9baf5D6990F8dFd0;
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
	function max(uint256 _amount1, uint256 _amount2) public pure returns (uint256 _maxAmount) { return Math._max(_amount1, _amount2); }

	function getBalance(address _token) public view returns (uint256 _balance) { return Transfers._getBalance(_token); }
	function pullFunds(address _token, address _from, uint256 _amount) public { Transfers._pullFunds(_token, _from, _amount); }
	function pushFunds(address _token, address _to, uint256 _amount) public { Transfers._pushFunds(_token, _to, _amount); }
	function approveFunds(address _token, address _to, uint256 _amount) public { Transfers._approveFunds(_token, _to, _amount); }
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
contract GTokenType3 is ERC20, ReentrancyGuard, GToken, GVoting
{
	using SafeMath for uint256;

	uint256 constant DEPOSIT_FEE = 10e16; // 10%
	uint256 constant WITHDRAWAL_FEE = 10e16; // 10%

	uint256 constant VOTING_ROUND_INTERVAL = 1 days;

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
		(uint256 _cost,) = GFormulae._calcWithdrawalCostFromShares(_grossShares, totalReserve(), totalSupply(), 0);
		_cost = G.min(_cost, G.getBalance(reserveToken));
		_burnReserve(_cost);
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
contract stkGRO is GTokenType3
{
	constructor ()
		GTokenType3("staked GRO", "stkGRO", 18, $.GRO) public
	{
	}
}
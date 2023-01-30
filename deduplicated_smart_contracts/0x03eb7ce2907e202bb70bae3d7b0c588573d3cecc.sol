/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later

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
}

// File: erc20permit/contracts/IERC2612.sol

// Code adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/
pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC2612 standard as defined in the EIP.
 *
 * Adds the {permit} method, which can be used to change one's
 * {IERC20-allowance} without having to send a transaction, by signing a
 * message. This allows users to spend tokens without having to hold Ether.
 *
 * See https://eips.ethereum.org/EIPS/eip-2612.
 */
interface IERC2612 {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);
}

// File: erc20permit/contracts/ERC20Permit.sol

// Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/53516bc555a454862470e7860a9b5254db4d00f5/contracts/token/ERC20/ERC20Permit.sol
pragma solidity ^0.6.0;

/**
 * @author Georgios Konstantopoulos
 * @dev Extension of {ERC20} that allows token holders to use their tokens
 * without sending any transactions by setting {IERC20-allowance} with a
 * signature using the {permit} method, and then spend them via
 * {IERC20-transferFrom}.
 *
 * The {permit} signature mechanism conforms to the {IERC2612} interface.
 */
abstract contract ERC20Permit is ERC20, IERC2612 {
    mapping (address => uint256) public override nonces;

    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(string memory name_, string memory symbol_) internal ERC20(name_, symbol_) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    /**
     * @dev See {IERC2612-permit}.
     *
     * In cases where the free option is not a concern, deadline can simply be
     * set to uint(-1), so it should be seen as an optional parameter
     */
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                amount,
                nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "ERC20Permit: invalid signature"
        );

        _approve(owner, spender, amount);
    }
}

// File: contracts/IUSM.sol

pragma solidity ^0.6.6;

interface IUSM {
    function mint(address to, uint minUsmOut) external payable returns (uint);
    function burn(address from, address payable to, uint usmToBurn, uint minEthOut) external returns (uint);
    function fund(address to, uint minFumOut) external payable returns (uint);
    function defund(address from, address payable to, uint fumToBurn, uint minEthOut) external returns (uint);
    function defundFromFUM(address from, address payable to, uint fumToBurn, uint minEthOut) external returns (uint);
}

// File: contracts/Delegable.sol

pragma solidity ^0.6.6;

/// @dev Delegable enables users to delegate their account management to other users.
/// Delegable implements addDelegateBySignature, to add delegates using a signature instead of a separate transaction.
contract Delegable {
    event Delegate(address indexed user, address indexed delegate, bool enabled);

    // keccak256("Signature(address user,address delegate,uint256 nonce,uint256 deadline)");
    bytes32 public immutable SIGNATURE_TYPEHASH = 0x0d077601844dd17f704bafff948229d27f33b57445915754dfe3d095fda2beb7;
    bytes32 public immutable DELEGABLE_DOMAIN;
    mapping(address => uint) public signatureCount;

    mapping(address => mapping(address => bool)) public delegated;

    constructor () public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DELEGABLE_DOMAIN = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes('USMFUM')),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    /// @dev Require that msg.sender is the account holder or a delegate
    modifier onlyHolderOrDelegate(address holder, string memory errorMessage) {
        require(
            msg.sender == holder || delegated[holder][msg.sender],
            errorMessage
        );
        _;
    }

    /// @dev Enable a delegate to act on the behalf of caller
    function addDelegate(address delegate) public {
        _addDelegate(msg.sender, delegate);
    }

    /// @dev Stop a delegate from acting on the behalf of caller
    function revokeDelegate(address delegate) public {
        _revokeDelegate(msg.sender, delegate);
    }

    /// @dev Add a delegate through an encoded signature
    function addDelegateBySignature(address user, address delegate, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(deadline >= block.timestamp, 'Delegable: Signature expired');

        bytes32 hashStruct = keccak256(
            abi.encode(
                SIGNATURE_TYPEHASH,
                user,
                delegate,
                signatureCount[user]++,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DELEGABLE_DOMAIN,
                hashStruct
            )
        );
        address signer = ecrecover(digest, v, r, s);
        require(
            signer != address(0) && signer == user,
            'Delegable: Invalid signature'
        );

        _addDelegate(user, delegate);
    }

    /// @dev Enable a delegate to act on the behalf of an user
    function _addDelegate(address user, address delegate) internal {
        require(!delegated[user][delegate], "Delegable: Already delegated");
        delegated[user][delegate] = true;
        emit Delegate(user, delegate, true);
    }

    /// @dev Stop a delegate from acting on the behalf of an user
    function _revokeDelegate(address user, address delegate) internal {
        require(delegated[user][delegate], "Delegable: Already undelegated");
        delegated[user][delegate] = false;
        emit Delegate(user, delegate, false);
    }
}

// File: contracts/WadMath.sol

pragma solidity ^0.6.6;

/**
 * @title Fixed point arithmetic library
 * @author Alberto Cuesta Cañada, Jacob Eliosoff, Alex Roan
 */
library WadMath {
    using SafeMath for uint;

    enum Round {Down, Up}

    uint private constant WAD = 10 ** 18;
    uint private constant WAD_MINUS_1 = WAD - 1;
    uint private constant WAD_SQUARED = WAD * WAD;
    uint private constant WAD_SQUARED_MINUS_1 = WAD_SQUARED - 1;
    uint private constant WAD_OVER_10 = WAD / 10;
    uint private constant WAD_OVER_20 = WAD / 20;
    uint private constant HALF_TO_THE_ONE_TENTH = 933032991536807416;
    uint private constant TWO_WAD = 2 * WAD;

    function wadMul(uint x, uint y, Round upOrDown) internal pure returns (uint) {
        return upOrDown == Round.Down ? wadMulDown(x, y) : wadMulUp(x, y);
    }

    function wadMulDown(uint x, uint y) internal pure returns (uint) {
        return x.mul(y) / WAD;
    }

    function wadMulUp(uint x, uint y) internal pure returns (uint) {
        return (x.mul(y)).add(WAD_MINUS_1) / WAD;
    }

    function wadSquaredDown(uint x) internal pure returns (uint) {
        return (x.mul(x)) / WAD;
    }

    function wadSquaredUp(uint x) internal pure returns (uint) {
        return (x.mul(x)).add(WAD_MINUS_1) / WAD;
    }

    function wadCubedDown(uint x) internal pure returns (uint) {
        return (x.mul(x)).mul(x) / WAD_SQUARED;
    }

    function wadCubedUp(uint x) internal pure returns (uint) {
        return ((x.mul(x)).mul(x)).add(WAD_SQUARED_MINUS_1) / WAD_SQUARED;
    }

    function wadDiv(uint x, uint y, Round upOrDown) internal pure returns (uint) {
        return upOrDown == Round.Down ? wadDivDown(x, y) : wadDivUp(x, y);
    }

    function wadDivDown(uint x, uint y) internal pure returns (uint) {
        return (x.mul(WAD)).div(y);
    }

    function wadDivUp(uint x, uint y) internal pure returns (uint) {
        return ((x.mul(WAD)).add(y - 1)).div(y);    // Can use "-" instead of sub() since div(y) will catch y = 0 case anyway
    }

    function wadHalfExp(uint power) internal pure returns (uint) {
        return wadHalfExp(power, uint(-1));
    }

    // Returns a loose but "gas-efficient" approximation of 0.5**power, where power is rounded to the nearest 0.1, and is
    // capped at maxPower.  Note power is WAD-scaled (eg, 2.7364 * WAD), but maxPower is just a plain unscaled uint (eg, 10).
    // Negative powers are not handled (as implied by power being a uint).
    function wadHalfExp(uint power, uint maxPower) internal pure returns (uint) {
        uint powerInTenthsUnscaled = power.add(WAD_OVER_20) / WAD_OVER_10;
        if (powerInTenthsUnscaled / 10 > maxPower) {
            return 0;
        }
        return wadPow(HALF_TO_THE_ONE_TENTH, powerInTenthsUnscaled);
    }

    // Adapted from rpow() in https://github.com/dapphub/ds-math/blob/master/src/math.sol - thank you!
    //
    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function wadPow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : WAD;

        for (n /= 2; n != 0; n /= 2) {
            x = wadSquaredDown(x);

            if (n % 2 != 0) {
                z = wadMulDown(z, x);
            }
        }
    }

    // Using Newton's method (see eg https://stackoverflow.com/a/8827111/3996653), but with WAD fixed-point math.
    function wadCbrtDown(uint y) internal pure returns (uint root) {
        if (y > 0 ) {
            uint newRoot = y.add(TWO_WAD) / 3;
            uint yTimesWadSquared = y.mul(WAD_SQUARED);
            do {
                root = newRoot;
                newRoot = (root + root + (yTimesWadSquared / (root * root))) / 3;
            } while (newRoot < root);
        }
        //require(root**3 <= y.mul(WAD_SQUARED) && y.mul(WAD_SQUARED) < (root + 1)**3);
    }

    function wadCbrtUp(uint y) internal pure returns (uint root) {
        root = wadCbrtDown(y);
        // The only case where wadCbrtUp(y) *isn't* equal to wadCbrtDown(y) + 1 is when y is a perfect cube; so check for that.
        // These "*"s are safe because: 1. root**3 <= y.mul(WAD_SQUARED), and 2. y.mul(WAD_SQUARED) is calculated (safely) above.
        if (root * root * root != y * WAD_SQUARED ) {
            ++root;
        }
        //require((root - 1)**3 < y.mul(WAD_SQUARED) && y.mul(WAD_SQUARED) <= root**3);
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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
contract Ownable is Context {
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

// File: contracts/MinOut.sol

pragma solidity ^0.6.6;

library MinOut {
    function parseMinTokenOut(uint ethIn) internal pure returns (uint minTokenOut) {
        uint minPrice = ethIn % 100000000000;
        if (minPrice != 0 && minPrice < 10000000) {
            minTokenOut = ethIn * minPrice / 100;
        }
    }

    function parseMinEthOut(uint tokenIn) internal pure returns (uint minEthOut) {
        uint maxPrice = tokenIn % 100000000000;
        if (maxPrice != 0 && maxPrice < 10000000) {
            minEthOut = tokenIn * 100 / maxPrice;
        }
    }
}

// File: contracts/FUM.sol

pragma solidity ^0.6.6;


/**
 * @title FUM Token
 * @author Alberto Cuesta Cañada, Jacob Eliosoff, Alex Roan
 *
 * @notice This should be owned by the stablecoin.
 */
contract FUM is ERC20Permit, Ownable {
    IUSM public immutable usm;

    constructor(IUSM usm_) public ERC20Permit("Minimal Funding", "FUM") {
        usm = usm_;
    }

    /**
     * @notice If anyone sends ETH here, assume they intend it as a `fund`.
     * If decimals 8 to 11 (included) of the amount of Ether received are `0000` then the next 7 will
     * be parsed as the minimum Ether price accepted, with 2 digits before and 5 digits after the comma.
     */
    receive() external payable {
        usm.fund{ value: msg.value }(msg.sender, MinOut.parseMinTokenOut(msg.value));
    }

    /**
     * @notice If a user sends FUM tokens directly to this contract (or to the USM contract), assume they intend it as a `defund`.
     * If using `transfer`/`transferFrom` as `defund`, and if decimals 8 to 11 (included) of the amount transferred received
     * are `0000` then the next 7 will be parsed as the maximum FUM price accepted, with 5 digits before and 2 digits after the comma.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (recipient == address(this) || recipient == address(usm) || recipient == address(0)) {
            usm.defundFromFUM(sender, payable(sender), amount, MinOut.parseMinEthOut(amount));
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    /**
     * @notice Mint new FUM to the _recipient
     *
     * @param _recipient address to mint to
     * @param _amount amount to mint
     */
    function mint(address _recipient, uint _amount) external onlyOwner {
        _mint(_recipient, _amount);
    }

    /**
     * @notice Burn FUM from _holder
     *
     * @param _holder address to burn from
     * @param _amount amount to burn
     */
    function burn(address _holder, uint _amount) external onlyOwner {
        _burn(_holder, _amount);
    }
}

// File: contracts/oracles/Oracle.sol

pragma solidity ^0.6.6;

abstract contract Oracle {
    function latestPrice() public virtual view returns (uint price);    // Prices must be WAD-scaled - 18 decimal places

    /**
     * @dev This pure virtual implementation, which is intended to be (optionally) overridden by stateful implementations,
     * confuses solhint into giving a "Function state mutability can be restricted to view" warning.  Unfortunately there seems
     * to be no elegant/gas-free workaround as yet: see https://github.com/ethereum/solidity/issues/3529.
     */
    function cacheLatestPrice() public virtual returns (uint price) {
        price = latestPrice();  // Default implementation doesn't do any cacheing, just returns price.  But override as needed
    }
}

// File: contracts/USMTemplate.sol

pragma solidity ^0.6.6;




// import "@nomiclabs/buidler/console.sol";

/**
 * @title USMTemplate
 * @author Alberto Cuesta Cañada, Jacob Eliosoff, Alex Roan
 * @notice Concept by Jacob Eliosoff (@jacob-eliosoff).
 *
 * This abstract USM contract must be inherited by a concrete implementation, that also adds an Oracle implementation - eg, by
 * also inheriting a concrete Oracle implementation.  See USM (and MockUSM) for an example.
 *
 * We use this inheritance-based design (rather than the more natural, and frankly normally more correct, composition-based design
 * of storing the Oracle here as a variable), because inheriting the Oracle makes all the latestPrice() calls *internal* rather
 * than calls to a separate oracle contract (or multiple contracts) - which leads to a significant saving in gas.
 */
abstract contract USMTemplate is IUSM, Oracle, ERC20Permit, Delegable {
    using Address for address payable;
    using SafeMath for uint;
    using WadMath for uint;

    enum Side {Buy, Sell}

    event MinFumBuyPriceChanged(uint previous, uint latest);
    event BuySellAdjustmentChanged(uint previous, uint latest);

    uint public constant WAD = 10 ** 18;
    uint public constant MAX_DEBT_RATIO = WAD * 8 / 10;                 // 80%
    uint public constant MIN_FUM_BUY_PRICE_HALF_LIFE = 1 days;          // Solidity for 1 * 24 * 60 * 60
    uint public constant BUY_SELL_ADJUSTMENT_HALF_LIFE = 1 minutes;     // Solidity for 1 * 60

    FUM public immutable fum;

    uint256 deadline; // Second at which the trial expires and `mint` and `fund` get disabled.

    struct TimedValue {
        uint32 timestamp;
        uint224 value;
    }

    TimedValue public minFumBuyPriceStored;
    TimedValue public buySellAdjustmentStored = TimedValue({ timestamp: 0, value: uint224(WAD) });

    constructor() public ERC20Permit("Minimal USD", "USM")
    {
        fum = new FUM(this);
        deadline = now + (60 * 60 * 24 * 28); // Four weeks into the future
    }

    /** EXTERNAL TRANSACTIONAL FUNCTIONS **/

    /**
     * @notice Mint new USM, sending it to the given address, and only if the amount minted >= minUsmOut.  The amount of ETH is
     * passed in as msg.value.
     * @param to address to send the USM to.
     * @param minUsmOut Minimum accepted USM for a successful mint.
     */
    function mint(address to, uint minUsmOut) external payable override returns (uint usmOut) {
        usmOut = _mintUsm(to, minUsmOut);
    }

    /**
     * @dev Burn USM in exchange for ETH.
     * @param from address to deduct the USM from.
     * @param to address to send the ETH to.
     * @param usmToBurn Amount of USM to burn.
     * @param minEthOut Minimum accepted ETH for a successful burn.
     */
    function burn(address from, address payable to, uint usmToBurn, uint minEthOut)
        external override
        onlyHolderOrDelegate(from, "Only holder or delegate")
        returns (uint ethOut)
    {
        ethOut = _burnUsm(from, to, usmToBurn, minEthOut);
    }

    /**
     * @notice Funds the pool with ETH, minting new FUM and sending it to the given address, but only if the amount minted >=
     * minFumOut.  The amount of ETH is passed in as msg.value.
     * @param to address to send the FUM to.
     * @param minFumOut Minimum accepted FUM for a successful fund.
     */
    function fund(address to, uint minFumOut) external payable override returns (uint fumOut) {
        fumOut = _fundFum(to, minFumOut);
    }

    /**
     * @notice Defunds the pool by redeeming FUM in exchange for equivalent ETH from the pool.
     * @param from address to deduct the FUM from.
     * @param to address to send the ETH to.
     * @param fumToBurn Amount of FUM to burn.
     * @param minEthOut Minimum accepted ETH for a successful defund.
     */
    function defund(address from, address payable to, uint fumToBurn, uint minEthOut)
        external override
        onlyHolderOrDelegate(from, "Only holder or delegate")
        returns (uint ethOut)
    {
        ethOut = _defundFum(from, to, fumToBurn, minEthOut);
    }

    /**
     * @notice Defunds the pool by redeeming FUM from an arbitrary address in exchange for equivalent ETH from the pool.
     * Called only by the FUM contract, when FUM is sent to it.
     * @param from address to deduct the FUM from.
     * @param to address to send the ETH to.
     * @param fumToBurn Amount of FUM to burn.
     * @param minEthOut Minimum accepted ETH for a successful defund.
     */
    function defundFromFUM(address from, address payable to, uint fumToBurn, uint minEthOut)
        external override
        returns (uint ethOut)
    {
        require(msg.sender == address(fum), "Restricted to FUM");
        ethOut = _defundFum(from, to, fumToBurn, minEthOut);
    }

    /**
     * @notice If anyone sends ETH here, assume they intend it as a `mint`.
     * If decimals 8 to 11 (included) of the amount of Ether received are `0000` then the next 7 will
     * be parsed as the minimum Ether price accepted, with 2 digits before and 5 digits after the comma.
     */
    receive() external payable {
        _mintUsm(msg.sender, MinOut.parseMinTokenOut(msg.value));
    }

    /**
     * @notice If a user sends USM tokens directly to this contract (or to the FUM contract), assume they intend it as a `burn`.
     * If using `transfer`/`transferFrom` as `burn`, and if decimals 8 to 11 (included) of the amount transferred received
     * are `0000` then the next 7 will be parsed as the maximum USM price accepted, with 5 digits before and 2 digits after the comma.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (recipient == address(this) || recipient == address(fum) || recipient == address(0)) {
            _burnUsm(sender, payable(sender), amount, MinOut.parseMinEthOut(amount));
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    /** INTERNAL TRANSACTIONAL FUNCTIONS */

    function _mintUsm(address to, uint minUsmOut) internal returns (uint usmOut)
    {
        // 1. Check that fund() has been called first - no minting before funding:
        uint rawEthInPool = ethPool();
        uint ethInPool = rawEthInPool.sub(msg.value);   // Backing out the ETH just received, which our calculations should ignore
        require(ethInPool > 0, "Fund before minting");

        // 2. Calculate usmOut:
        uint ethUsmPrice = cacheLatestPrice();
        uint usmTotalSupply = totalSupply();
        uint oldDebtRatio = debtRatio(ethUsmPrice, ethInPool, usmTotalSupply);
        usmOut = usmFromMint(ethUsmPrice, msg.value, ethInPool, usmTotalSupply, oldDebtRatio);
        require(usmOut >= minUsmOut, "Limit not reached");

        // 3. Update buySellAdjustmentStored and mint the user's new USM:
        uint newDebtRatio = debtRatio(ethUsmPrice, rawEthInPool, usmTotalSupply.add(usmOut));
        _updateBuySellAdjustment(oldDebtRatio, newDebtRatio, buySellAdjustment());
        _mint(to, usmOut);

        require(now <= deadline, "Trial expired, remove assets");
        require(msg.value <= 1e18, "Capped at 1 ETH per tx");
        require(ethPool() <= 1e20, "Capped at 100 pooled ETH");
    }

    function _burnUsm(address from, address payable to, uint usmToBurn, uint minEthOut) internal returns (uint ethOut)
    {
        // 1. Calculate ethOut:
        uint ethUsmPrice = cacheLatestPrice();
        uint ethInPool = ethPool();
        uint usmTotalSupply = totalSupply();
        uint oldDebtRatio = debtRatio(ethUsmPrice, ethInPool, usmTotalSupply);
        ethOut = ethFromBurn(ethUsmPrice, usmToBurn, ethInPool, usmTotalSupply, oldDebtRatio);
        require(ethOut >= minEthOut, "Limit not reached");

        // 2. Burn the input USM, update buySellAdjustmentStored, and return the user's ETH:
        uint newDebtRatio = debtRatio(ethUsmPrice, ethInPool.sub(ethOut), usmTotalSupply.sub(usmToBurn));
        require(newDebtRatio <= WAD, "Debt ratio > 100%");
        _burn(from, usmToBurn);
        _updateBuySellAdjustment(oldDebtRatio, newDebtRatio, buySellAdjustment());
        to.sendValue(ethOut);
    }

    function _fundFum(address to, uint minFumOut) internal returns (uint fumOut)
    {
        // 1. Refresh mfbp:
        uint ethUsmPrice = cacheLatestPrice();
        uint rawEthInPool = ethPool();
        uint ethInPool = rawEthInPool.sub(msg.value);   // Backing out the ETH just received, which our calculations should ignore
        uint usmTotalSupply = totalSupply();
        uint oldDebtRatio = debtRatio(ethUsmPrice, ethInPool, usmTotalSupply);
        uint fumTotalSupply = fum.totalSupply();
        _updateMinFumBuyPrice(oldDebtRatio, ethInPool, fumTotalSupply);

        // 2. Calculate fumOut:
        uint adjustment = buySellAdjustment();
        fumOut = fumFromFund(ethUsmPrice, msg.value, ethInPool, usmTotalSupply, fumTotalSupply, adjustment);
        require(fumOut >= minFumOut, "Limit not reached");

        // 3. Update buySellAdjustmentStored and mint the user's new FUM:
        uint newDebtRatio = debtRatio(ethUsmPrice, rawEthInPool, usmTotalSupply);
        _updateBuySellAdjustment(oldDebtRatio, newDebtRatio, adjustment);
        fum.mint(to, fumOut);

        require(now <= deadline, "Trial expired, remove assets");
        require(msg.value <= 1e18, "Capped at 1 ETH per tx");
        require(ethPool() <= 1e20, "Capped at 100 pooled ETH");
    }

    function _defundFum(address from, address payable to, uint fumToBurn, uint minEthOut) internal returns (uint ethOut)
    {
        // 1. Calculate ethOut:
        uint ethUsmPrice = cacheLatestPrice();
        uint ethInPool = ethPool();
        uint usmTotalSupply = totalSupply();
        uint oldDebtRatio = debtRatio(ethUsmPrice, ethInPool, usmTotalSupply);
        ethOut = ethFromDefund(ethUsmPrice, fumToBurn, ethInPool, usmTotalSupply);
        require(ethOut >= minEthOut, "Limit not reached");

        // 2. Burn the input FUM, update buySellAdjustmentStored, and return the user's ETH:
        uint newDebtRatio = debtRatio(ethUsmPrice, ethInPool.sub(ethOut), usmTotalSupply);
        require(newDebtRatio <= MAX_DEBT_RATIO, "Debt ratio > max");
        fum.burn(from, fumToBurn);
        _updateBuySellAdjustment(oldDebtRatio, newDebtRatio, buySellAdjustment());
        to.sendValue(ethOut);
    }

    /**
     * @notice Set the min FUM price, based on the current oracle price and debt ratio. Emits a MinFumBuyPriceChanged event.
     * @dev The logic for calculating a new minFumBuyPrice is as follows.  We want to set it to the FUM price, in ETH terms, at
     * which debt ratio was exactly MAX_DEBT_RATIO.  So we can assume:
     *
     *     usmToEth(totalSupply()) / ethPool() = MAX_DEBT_RATIO, or in other words:
     *     usmToEth(totalSupply()) = MAX_DEBT_RATIO * ethPool()
     *
     * And with this assumption, we calculate the FUM price (buffer / FUM qty) like so:
     *
     *     minFumBuyPrice = ethBuffer() / fum.totalSupply()
     *                    = (ethPool() - usmToEth(totalSupply())) / fum.totalSupply()
     *                    = (ethPool() - (MAX_DEBT_RATIO * ethPool())) / fum.totalSupply()
     *                    = (1 - MAX_DEBT_RATIO) * ethPool() / fum.totalSupply()
     */
    function _updateMinFumBuyPrice(uint debtRatio_, uint ethInPool, uint fumTotalSupply) internal {
        uint previous = minFumBuyPriceStored.value;
        if (debtRatio_ <= MAX_DEBT_RATIO) {                 // We've dropped below (or were already below, whatev) max debt ratio
            if (previous != 0) {
                minFumBuyPriceStored.timestamp = 0;         // Clear mfbp
                minFumBuyPriceStored.value = 0;
                emit MinFumBuyPriceChanged(previous, 0);
            }
        } else if (previous == 0) {                         // We were < max debt ratio, but have now crossed above - so set mfbp
            // See reasoning in @dev comment above
            minFumBuyPriceStored.timestamp = uint32(block.timestamp);
            minFumBuyPriceStored.value = uint224((WAD - MAX_DEBT_RATIO).wadMulUp(ethInPool).wadDivUp(fumTotalSupply));
            emit MinFumBuyPriceChanged(previous, minFumBuyPriceStored.value);
        }
    }

    /**
     * @notice Update the buy/sell adjustment factor, as of the current block time, after a price-moving operation.
     * @param oldDebtRatio The debt ratio before the operation (eg, mint()) was done
     * @param newDebtRatio The current, post-op debt ratio
     */
    function _updateBuySellAdjustment(uint oldDebtRatio, uint newDebtRatio, uint oldAdjustment) internal {
        // Skip this if either the old or new debt ratio == 0.  Normally this will only happen on the system's first couple of
        // calls, but in principle it could happen later if every single USM holder burns all their USM.  This seems
        // vanishingly unlikely though if the system gets any uptake at all, and anyway if it does happen it will just mean a
        // couple of skipped updates to the buySellAdjustment - no big deal.
        if (oldDebtRatio != 0 && newDebtRatio != 0) {
            uint previous = buySellAdjustmentStored.value; // Not nec the same as oldAdjustment, because of the time decay!

            // Eg: if a user operation reduced debt ratio from 70% to 50%, it was either a fund() or a burn().  These are both
            // "long-ETH" operations.  So we can take (old / new)**2 = (70% / 50%)**2 = 1.4**2 = 1.96 as the ratio by which to
            // increase buySellAdjustment, which is intended as a measure of "how long-ETH recent user activity has been":
            uint newAdjustment = (oldAdjustment.mul(oldDebtRatio).mul(oldDebtRatio) / newDebtRatio) / newDebtRatio;
            buySellAdjustmentStored.timestamp = uint32(block.timestamp);
            buySellAdjustmentStored.value = uint224(newAdjustment);
            emit BuySellAdjustmentChanged(previous, newAdjustment);
        }
    }

    /** PUBLIC AND INTERNAL VIEW FUNCTIONS **/

    /**
     * @notice Total amount of ETH in the pool (ie, in the contract).
     * @return pool ETH pool
     */
    function ethPool() public view returns (uint pool) {
        pool = address(this).balance;
    }

    /**
     * @notice Calculate the amount of ETH in the buffer.
     * @return buffer ETH buffer
     */
    function ethBuffer(uint ethUsmPrice, uint ethInPool, uint usmTotalSupply, WadMath.Round upOrDown)
        internal pure returns (int buffer)
    {
        // Reverse the input upOrDown, since we're using it for usmToEth(), which will be *subtracted* from ethInPool below:
        WadMath.Round downOrUp = (upOrDown == WadMath.Round.Down ? WadMath.Round.Up : WadMath.Round.Down);
        buffer = int(ethInPool) - int(usmToEth(ethUsmPrice, usmTotalSupply, downOrUp));
        require(buffer <= int(ethInPool), "Underflow error");
    }

    /**
     * @notice Calculate debt ratio for a given eth to USM price: ratio of the outstanding USM (amount of USM in total supply), to
     * the current ETH pool amount.
     * @return ratio Debt ratio
     */
    function debtRatio(uint ethUsmPrice, uint ethInPool, uint usmTotalSupply) internal pure returns (uint ratio) {
        uint ethPoolValueInUsd = ethInPool.wadMulDown(ethUsmPrice);
        ratio = (ethInPool == 0 ? 0 : usmTotalSupply.wadDivUp(ethPoolValueInUsd));
    }

    /**
     * @notice Convert ETH amount to USM using a ETH/USD price.
     * @param ethAmount The amount of ETH to convert
     * @return usmOut The amount of USM
     */
    function ethToUsm(uint ethUsmPrice, uint ethAmount, WadMath.Round upOrDown) internal pure returns (uint usmOut) {
        usmOut = ethAmount.wadMul(ethUsmPrice, upOrDown);
    }

    /**
     * @notice Convert USM amount to ETH using a ETH/USD price.
     * @param usmAmount The amount of USM to convert
     * @return ethOut The amount of ETH
     */
    function usmToEth(uint ethUsmPrice, uint usmAmount, WadMath.Round upOrDown) internal pure returns (uint ethOut) {
        ethOut = usmAmount.wadDiv(ethUsmPrice, upOrDown);
    }

    /**
     * @notice Calculate the *marginal* price of USM (in ETH terms) - that is, of the next unit, before the price start sliding.
     * @return price USM price in ETH terms
     */
    function usmPrice(Side side, uint ethUsmPrice, uint debtRatio_) internal view returns (uint price) {
        WadMath.Round upOrDown = (side == Side.Buy ? WadMath.Round.Up : WadMath.Round.Down);
        price = usmToEth(ethUsmPrice, WAD, upOrDown);

        uint adjustment = buySellAdjustment();
        if (debtRatio_ <= WAD) {
            if ((side == Side.Buy && adjustment < WAD) || (side == Side.Sell && adjustment > WAD)) {
                price = price.wadDiv(adjustment, upOrDown);
            }
        } else {    // See comment at the bottom of usmFromMint() explaining this special case where debtRatio > 100%
            if ((side == Side.Buy && adjustment > WAD) || (side == Side.Sell && adjustment < WAD)) {
                price = price.wadMul(adjustment, upOrDown);
            }
        }
    }

    /**
     * @notice Calculate the *marginal* price of FUM (in ETH terms) - that is, of the next unit, before the price start sliding.
     * @return price FUM price in ETH terms
     */
    function fumPrice(Side side, uint ethUsmPrice, uint ethInPool, uint usmTotalSupply, uint fumTotalSupply, uint adjustment)
        internal view returns (uint price)
    {
        WadMath.Round upOrDown = (side == Side.Buy ? WadMath.Round.Up : WadMath.Round.Down);
        if (fumTotalSupply == 0) {
            return usmToEth(ethUsmPrice, WAD, upOrDown);    // if no FUM issued yet, default fumPrice to 1 USD (in ETH terms)
        }
        int buffer = ethBuffer(ethUsmPrice, ethInPool, usmTotalSupply, upOrDown);
        price = (buffer <= 0 ? 0 : uint(buffer).wadDiv(fumTotalSupply, upOrDown));

        if (side == Side.Buy) {
            if (adjustment > WAD) {
                price = price.wadMulUp(adjustment);
            }
            // Floor the buy price at minFumBuyPrice:
            uint mfbp = minFumBuyPrice();
            if (price < mfbp) {
                price = mfbp;
            }
        } else {
            if (adjustment < WAD) {
                price = price.wadMulDown(adjustment);
            }
        }
    }

    /**
     * @notice How much USM a minter currently gets back for ethIn ETH, accounting for adjustment and sliding prices.
     * @param ethIn The amount of ETH passed to mint()
     * @return usmOut The amount of USM to receive in exchange
     */
    function usmFromMint(uint ethUsmPrice, uint ethIn, uint ethQty0, uint usmQty0, uint debtRatio0)
        internal view returns (uint usmOut)
    {
        uint usmPrice0 = usmPrice(Side.Buy, ethUsmPrice, debtRatio0);
        uint ethQty1 = ethQty0.add(ethIn);
        if (usmQty0 == 0) {
            // No USM in the system, so debtRatio() == 0 which breaks the integral below - skip sliding-prices this time:
            usmOut = ethIn.wadDivDown(usmPrice0);
        } else if (debtRatio0 <= WAD) {
            // Mint USM at a sliding-up USM price (ie, at a sliding-down ETH price).  **BASIC RULE:** anytime debtRatio()
            // changes by factor k (here > 1), ETH price changes by factor 1/k**2 (ie, USM price, in ETH terms, changes by
            // factor k**2).  (Earlier versions of this logic scaled ETH price based on change in ethPool(), or change in
            // ethPool()**2: the latter gives simpler math - no cbrt() - but doesn't let mint/burn offset fund/defund, which
            // debtRatio()**2 nicely does.)

            // Math: this is an integral - sum of all USM minted at a sliding-down ETH price:
            // u - u_0 = ((((e / e_0)**3 - 1) * e_0 / ubp_0 + u_0) * u_0**2)**(1/3) - u_0
            uint integralFirstPart = (ethQty1.wadDivDown(ethQty0).wadCubedDown().sub(WAD)).mul(ethQty0).div(usmPrice0);
            usmOut = (integralFirstPart.add(usmQty0)).wadMulDown(usmQty0.wadSquaredDown()).wadCbrtDown().sub(usmQty0);
        } else {
            // Here we have the special, unusual case where we're minting while debt ratio > 100%.  In this case (only),
            // minting will actually *reduce* debt ratio, whereas normally it increases it.  (In short: minting always pushes
            // debt ratio closer to 100%.)  Because debt ratio is decreasing as we buy, and USM buy price must *increase* as we
            // buy, we need to make USM price grow proportionally to (1 / change in debt ratio)**2, rather than the usual
            // (1 / change in debt ratio)**2 above.  This gives the following different integral:
            // x = e0 * (e - e0) / (u0 * pu0)
            // u - u_0 = u0 * x / (e - x)
            uint integralFirstPart = ethQty0.mul(ethIn).div(usmQty0.wadMulUp(usmPrice0));
            usmOut = usmQty0.mul(integralFirstPart).div(ethQty1.sub(integralFirstPart));
        }
    }

    /**
     * @notice How much ETH a burner currently gets from burning usmIn USM, accounting for adjustment and sliding prices.
     * @param usmIn The amount of USM passed to burn()
     * @return ethOut The amount of ETH to receive in exchange
     */
    function ethFromBurn(uint ethUsmPrice, uint usmIn, uint ethQty0, uint usmQty0, uint debtRatio0)
        internal view returns (uint ethOut)
    {
        // Burn USM at a sliding-down USM price (ie, a sliding-up ETH price):
        uint usmPrice0 = usmPrice(Side.Sell, ethUsmPrice, debtRatio0);
        uint usmQty1 = usmQty0.sub(usmIn);

        // Math: this is an integral - sum of all USM burned at a sliding price.  Follows the same mathematical invariant as
        // above: if debtRatio() *= k (here, k < 1), ETH price *= 1/k**2, ie, USM price in ETH terms *= k**2.
        // e_0 - e = e_0 - (e_0**2 * (e_0 - usp_0 * u_0 * (1 - (u / u_0)**3)))**(1/3)
        uint integralFirstPart = usmPrice0.wadMulDown(usmQty0).wadMulDown(WAD.sub(usmQty1.wadDivUp(usmQty0).wadCubedUp()));
        ethOut = ethQty0.sub(ethQty0.wadSquaredUp().wadMulUp(ethQty0.sub(integralFirstPart)).wadCbrtUp());
    }

    /**
     * @notice How much FUM a funder currently gets back for ethIn ETH, accounting for adjustment and sliding prices.
     * @param ethIn The amount of ETH passed to fund()
     * @return fumOut The amount of FUM to receive in exchange
     */
    function fumFromFund(uint ethUsmPrice, uint ethIn, uint ethQty0, uint usmQty0, uint fumQty0, uint adjustment)
        internal view returns (uint fumOut)
    {
        // Create FUM at a sliding-up FUM price:
        uint fumPrice0 = fumPrice(Side.Buy, ethUsmPrice, ethQty0, usmQty0, fumQty0, adjustment);
        if (usmQty0 == 0) {
            // No USM in the system - skip sliding-prices:
            fumOut = ethIn.wadDivDown(fumPrice0);
        } else {
            // Math: f - f_0 = e_0 * (e - e_0) / (e * fbp_0)
            uint ethQty1 = ethQty0.add(ethIn);
            fumOut = ethQty0.mul(ethIn).div(ethQty1.wadMulUp(fumPrice0));
        }
    }

    /**
     * @notice How much ETH a defunder currently gets back for fumIn FUM, accounting for adjustment and sliding prices.
     * @param fumIn The amount of FUM passed to defund()
     * @return ethOut The amount of ETH to receive in exchange
     */
    function ethFromDefund(uint ethUsmPrice, uint fumIn, uint ethQty0, uint usmQty0)
        internal view returns (uint ethOut)
    {
        // Burn FUM at a sliding-down FUM price:
        uint fumQty0 = fum.totalSupply();
        uint fumPrice0 = fumPrice(Side.Sell, ethUsmPrice, ethQty0, usmQty0, fumQty0, buySellAdjustment());
        if (usmQty0 == 0) {
            // No USM in the system - skip sliding-prices:
            ethOut = fumIn.wadMulDown(fumPrice0);
        } else {
            // Math: e_0 - e = e_0 * (f_0 - f) * fsp_0 / (e_0 + (f_0 - f) * fsp_0)
            ethOut = ethQty0.mul(fumIn.wadMulDown(fumPrice0)).div(ethQty0.add(fumIn.wadMulUp(fumPrice0)));
        }
    }

    /**
     * @notice The current min FUM buy price, equal to the stored value decayed by time since minFumBuyPriceTimestamp.
     * @return mfbp The minFumBuyPrice, in ETH terms
     */
    function minFumBuyPrice() public view returns (uint mfbp) {
        if (minFumBuyPriceStored.value != 0) {
            uint numHalvings = block.timestamp.sub(minFumBuyPriceStored.timestamp).wadDivDown(MIN_FUM_BUY_PRICE_HALF_LIFE);
            uint decayFactor = numHalvings.wadHalfExp();
            mfbp = uint256(minFumBuyPriceStored.value).wadMulUp(decayFactor);
        }   // Otherwise just returns 0
    }

    /**
     * @notice The current buy/sell adjustment, equal to the stored value decayed by time since buySellAdjustmentTimestamp.  This
     * adjustment is intended as a measure of "how long-ETH recent user activity has been", so that we can slide price
     * accordingly: if recent activity was mostly long-ETH (fund() and burn()), raise FUM buy price/reduce USM sell price; if
     * recent activity was short-ETH (defund() and mint()), reduce FUM sell price/raise USM buy price.  We use "it reduced debt
     * ratio" as a rough proxy for "the operation was long-ETH".
     *
     * (There is one odd case: when debt ratio > 100%, a *short*-ETH mint() will actually reduce debt ratio.  This does no real
     * harm except to make fast-succession mint()s and fund()s in such > 100% cases a little more expensive than they would be.)
     *
     * @return adjustment The sliding-price buy/sell adjustment
     */
    function buySellAdjustment() public view returns (uint adjustment) {
        uint numHalvings = block.timestamp.sub(buySellAdjustmentStored.timestamp).wadDivDown(BUY_SELL_ADJUSTMENT_HALF_LIFE);
        uint decayFactor = numHalvings.wadHalfExp(10);
        // Here we use the idea that for any b and 0 <= p <= 1, we can crudely approximate b**p by 1 + (b-1)p = 1 + bp - p.
        // Eg: 0.6**0.5 pulls 0.6 "about halfway" to 1 (0.8); 0.6**0.25 pulls 0.6 "about 3/4 of the way" to 1 (0.9).
        // So b**p =~ b + (1-p)(1-b) = b + 1 - b - p + bp = 1 + bp - p.
        // (Don't calculate it as 1 + (b-1)p because we're using uints, b-1 can be negative!)
        adjustment = WAD.add(uint256(buySellAdjustmentStored.value).wadMulDown(decayFactor)).sub(decayFactor);
    }

    /** EXTERNAL VIEW FUNCTIONS */

    /**
     * @notice Calculate the amount of ETH in the buffer.
     * @return buffer ETH buffer
     */
    function ethBuffer(WadMath.Round upOrDown) external view returns (int buffer) {
        buffer = ethBuffer(latestPrice(), ethPool(), totalSupply(), upOrDown);
    }

    /**
     * @notice Convert ETH amount to USM using the latest oracle ETH/USD price.
     * @param ethAmount The amount of ETH to convert
     * @return usmOut The amount of USM
     */
    function ethToUsm(uint ethAmount, WadMath.Round upOrDown) external view returns (uint usmOut) {
        usmOut = ethToUsm(latestPrice(), ethAmount, upOrDown);
    }

    /**
     * @notice Convert USM amount to ETH using the latest oracle ETH/USD price.
     * @param usmAmount The amount of USM to convert
     * @return ethOut The amount of ETH
     */
    function usmToEth(uint usmAmount, WadMath.Round upOrDown) external view returns (uint ethOut) {
        ethOut = usmToEth(latestPrice(), usmAmount, upOrDown);
    }

    /**
     * @notice Calculate debt ratio.
     * @return ratio Debt ratio
     */
    function debtRatio() external view returns (uint ratio) {
        ratio = debtRatio(latestPrice(), ethPool(), totalSupply());
    }

    /**
     * @notice Calculate the *marginal* price of USM (in ETH terms) - that is, of the next unit, before the price start sliding.
     * @return price USM price in ETH terms
     */
    function usmPrice(Side side) external view returns (uint price) {
        uint ethUsdPrice = latestPrice();
        price = usmPrice(side, ethUsdPrice, debtRatio(ethUsdPrice, ethPool(), totalSupply()));
    }

    /**
     * @notice Calculate the *marginal* price of FUM (in ETH terms) - that is, of the next unit, before the price start sliding.
     * @return price FUM price in ETH terms
     */
    function fumPrice(Side side) external view returns (uint price) {
        price = fumPrice(side, latestPrice(), ethPool(), totalSupply(), fum.totalSupply(), buySellAdjustment());
    }
}

// File: @chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// File: contracts/oracles/ChainlinkOracle.sol

pragma solidity ^0.6.6;


/**
 * @title ChainlinkOracle
 */
contract ChainlinkOracle is Oracle {
    using SafeMath for uint;

    uint private constant SCALE_FACTOR = 10 ** 10;  // Since Chainlink has 8 dec places, and latestPrice() needs 18

    AggregatorV3Interface private aggregator;

    constructor(AggregatorV3Interface aggregator_) public
    {
        aggregator = aggregator_;
    }

    /**
     * @notice Retrieve the latest price of the price oracle.
     * @return price
     */
    function latestPrice() public virtual override view returns (uint price) {
        price = latestChainlinkPrice();
    }

    function latestChainlinkPrice() public view returns (uint price) {
        (, int rawPrice,,,) = aggregator.latestRoundData();
        price = uint(rawPrice).mul(SCALE_FACTOR); // TODO: Cast safely
    }
}

// File: contracts/oracles/CompoundOpenOracle.sol

pragma solidity ^0.6.6;

interface UniswapAnchoredView {
    function price(string calldata symbol) external view returns (uint);
}

/**
 * @title CompoundOpenOracle
 */
contract CompoundOpenOracle is Oracle {
    using SafeMath for uint;

    uint private constant SCALE_FACTOR = 10 ** 12;  // Since Compound has 6 dec places, and latestPrice() needs 18

    UniswapAnchoredView private anchoredView;

    constructor(UniswapAnchoredView anchoredView_) public
    {
        anchoredView = anchoredView_;
    }

    /**
     * @notice Retrieve the latest price of the price oracle.
     * @return price
     */
    function latestPrice() public virtual override view returns (uint price) {
        price = latestCompoundPrice();
    }

    function latestCompoundPrice() public view returns (uint price) {
        price = anchoredView.price("ETH").mul(SCALE_FACTOR);
    }
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/oracles/OurUniswapV2TWAPOracle.sol

pragma solidity ^0.6.6;


contract OurUniswapV2TWAPOracle is Oracle {
    using SafeMath for uint;

    /**
     * MIN_TWAP_PERIOD plays two roles:
     *
     * 1. Minimum age of the stored CumulativePrice we calculate our current TWAP vs.  Eg, if one of our stored prices is from
     * 5 secs ago, and the other from 10 min ago, we should calculate TWAP vs the 10-min-old one, since a 5-second TWAP is too
     * short - relatively easy to manipulate.
     *
     * 2. Minimum time gap between stored CumulativePrices.  Eg, if we stored one 5 seconds ago, we don't need to store another
     * one now - and shouldn't, since then if someone else made a TWAP call a few seconds later, both stored prices would be
     * too recent to calculate a robust TWAP.
     *
     * These roles could in principle be separated, eg: "Require the stored price we calculate TWAP from to be >= 2 minutes
     * old, but leave >= 10 minutes before storing a new price."  But for simplicity we keep them the same.
     */
    uint public constant MIN_TWAP_PERIOD = 2 minutes;

    // Uniswap stores its cumulative prices in "FixedPoint.uq112x112" format - 112-bit fixed point:
    uint public constant UNISWAP_CUM_PRICE_SCALE_FACTOR = 2 ** 112;

    uint private constant UINT32_MAX = 2 ** 32 - 1;     // Should really be type(uint32).max, but that needs Solidity 0.6.8...
    uint private constant UINT224_MAX = 2 ** 224 - 1;   // Ditto, type(uint224).max

    IUniswapV2Pair immutable uniswapPair;
    uint immutable token0Decimals;
    uint immutable token1Decimals;
    bool immutable tokensInReverseOrder;
    uint immutable scaleFactor;

    struct CumulativePrice {
        uint32 timestamp;
        uint224 priceSeconds;   // See cumulativePrice() below for an explanation of "priceSeconds"
    }

    /**
     * We store two CumulativePrices, A and B, without specifying which is more recent.  This is so that we only need to do one
     * SSTORE each time we save a new one: we can inspect them later to figure out which is newer - see orderedStoredPrices().
     */
    CumulativePrice private storedPriceA;
    CumulativePrice private storedPriceB;

    /**
     * Example pairs to pass in:
     * ETH/USDT: 0x0d4a11d5eeaac28ec3f61d100daf4d40471f1852, false, 18, 6 (WETH reserve is stored w/ 18 dec places, USDT w/ 18)
     * USDC/ETH: 0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc, true, 6, 18 (USDC reserve is stored w/ 6 dec places, WETH w/ 18)
     * DAI/ETH: 0xa478c2975ab1ea89e8196811f51a7b7ade33eb11, true, 18, 18 (DAI reserve is stored w/ 18 dec places, WETH w/ 18)
     */
    constructor(IUniswapV2Pair uniswapPair_, uint token0Decimals_, uint token1Decimals_, bool tokensInReverseOrder_) public {
        uniswapPair = uniswapPair_;
        token0Decimals = token0Decimals_;
        token1Decimals = token1Decimals_;
        tokensInReverseOrder = tokensInReverseOrder_;

        (uint aDecimals, uint bDecimals) = tokensInReverseOrder_ ?
            (token1Decimals_, token0Decimals_) :
            (token0Decimals_, token1Decimals_);
        scaleFactor = 10 ** aDecimals.add(18).sub(bDecimals);
    }

    function cacheLatestPrice() public virtual override returns (uint price) {
        (CumulativePrice storage olderStoredPrice, CumulativePrice storage newerStoredPrice) = orderedStoredPrices();

        uint timestamp;
        uint priceSeconds;
        (price, timestamp, priceSeconds) = _latestPrice(newerStoredPrice);

        // Store the latest cumulative price, if it's been long enough since the latest stored price:
        if (areNewAndStoredPriceFarEnoughApart(timestamp, newerStoredPrice)) {
            storeCumulativePrice(timestamp, priceSeconds, olderStoredPrice);
        }
    }

    function latestPrice() public virtual override view returns (uint price) {
        price = latestUniswapTWAPPrice();
    }

    function latestUniswapTWAPPrice() public view returns (uint price) {
        (, CumulativePrice storage newerStoredPrice) = orderedStoredPrices();
        (price, , ) = _latestPrice(newerStoredPrice);
    }

    function _latestPrice(CumulativePrice storage newerStoredPrice)
        internal view returns (uint price, uint timestamp, uint priceSeconds)
    {
        (timestamp, priceSeconds) = cumulativePrice();

        // Now that we have the current cum price, subtract-&-divide the stored one, to get the TWAP price:
        CumulativePrice storage refPrice = storedPriceToCompareVs(timestamp, newerStoredPrice);
        price = calculateTWAP(timestamp, priceSeconds, uint(refPrice.timestamp), uint(refPrice.priceSeconds));
    }

    function storeCumulativePrice(uint timestamp, uint priceSeconds, CumulativePrice storage olderStoredPrice) internal
    {
        require(timestamp <= UINT32_MAX, "timestamp overflow");
        require(priceSeconds <= UINT224_MAX, "priceSeconds overflow");
        // (Note: this assignment only stores because olderStoredPrice has modifier "storage" - ie, store by reference!)
        (olderStoredPrice.timestamp, olderStoredPrice.priceSeconds) = (uint32(timestamp), uint224(priceSeconds));
    }

    function storedPriceToCompareVs(uint newTimestamp, CumulativePrice storage newerStoredPrice)
        internal view returns (CumulativePrice storage refPrice)
    {
        bool aAcceptable = areNewAndStoredPriceFarEnoughApart(newTimestamp, storedPriceA);
        bool bAcceptable = areNewAndStoredPriceFarEnoughApart(newTimestamp, storedPriceB);
        if (aAcceptable) {
            if (bAcceptable) {
                refPrice = newerStoredPrice;        // Neither is *too* recent, so return the fresher of the two
            } else {
                refPrice = storedPriceA;            // Only A is acceptable
            }
        } else if (bAcceptable) {
            refPrice = storedPriceB;                // Only B is acceptable
        } else {
            revert("Both stored prices too recent");
        }
    }

    function orderedStoredPrices() internal view
        returns (CumulativePrice storage olderStoredPrice, CumulativePrice storage newerStoredPrice)
    {
        (olderStoredPrice, newerStoredPrice) = storedPriceB.timestamp > storedPriceA.timestamp ?
            (storedPriceA, storedPriceB) : (storedPriceB, storedPriceA);
    }

    function areNewAndStoredPriceFarEnoughApart(uint newTimestamp, CumulativePrice storage storedPrice) internal view
        returns (bool farEnough)
    {
        farEnough = newTimestamp >= storedPrice.timestamp + MIN_TWAP_PERIOD;    // No risk of overflow on a uint32
    }

    /**
     * @return timestamp Timestamp at which Uniswap stored the priceSeconds.
     * @return priceSeconds Our pair's cumulative "price-seconds", using Uniswap's TWAP logic.  Eg, if at time t0
     * priceSeconds = 10,000,000 (returned here as 10,000,000 * 10**18, ie, in WAD fixed-point format), and during the 30
     * seconds between t0 and t1 = t0 + 30, the price is $45.67, then at time t1, priceSeconds = 10,000,000 + 30 * 45.67 =
     * 10,001,370.1 (stored as 10,001,370.1 * 10**18).
     */
    function cumulativePrice()
        private view returns (uint timestamp, uint priceSeconds)
    {
        (, , timestamp) = uniswapPair.getReserves();

        // Retrieve the current Uniswap cumulative price.  Modeled off of Uniswap's own example:
        // https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/examples/ExampleOracleSimple.sol
        uint uniswapCumPrice = tokensInReverseOrder ?
            uniswapPair.price1CumulativeLast() :
            uniswapPair.price0CumulativeLast();
        priceSeconds = uniswapCumPrice.mul(scaleFactor) / UNISWAP_CUM_PRICE_SCALE_FACTOR;
    }

    /**
     * @param newTimestamp in seconds (eg, 1606764888) - not WAD-scaled!
     * @param newPriceSeconds WAD-scaled.
     * @param oldTimestamp in raw seconds again.
     * @param oldPriceSeconds WAD-scaled.
     * @return price WAD-scaled.
     */
    function calculateTWAP(uint newTimestamp, uint newPriceSeconds, uint oldTimestamp, uint oldPriceSeconds)
        private pure returns (uint price)
    {
        price = (newPriceSeconds.sub(oldPriceSeconds)).div(newTimestamp.sub(oldTimestamp));
    }
}

// File: contracts/oracles/MedianOracle.sol

pragma solidity ^0.6.6;


contract MedianOracle is ChainlinkOracle, CompoundOpenOracle, OurUniswapV2TWAPOracle {
    using SafeMath for uint;

    constructor(
        AggregatorV3Interface chainlinkAggregator,
        UniswapAnchoredView compoundView,
        IUniswapV2Pair uniswapPair, uint uniswapToken0Decimals, uint uniswapToken1Decimals, bool uniswapTokensInReverseOrder
    ) public
        ChainlinkOracle(chainlinkAggregator)
        CompoundOpenOracle(compoundView)
        OurUniswapV2TWAPOracle(uniswapPair, uniswapToken0Decimals, uniswapToken1Decimals, uniswapTokensInReverseOrder) {}

    function latestPrice() public override(ChainlinkOracle, CompoundOpenOracle, OurUniswapV2TWAPOracle)
        view returns (uint price)
    {
        price = median(ChainlinkOracle.latestPrice(),
                       CompoundOpenOracle.latestPrice(),
                       OurUniswapV2TWAPOracle.latestPrice());
    }

    function cacheLatestPrice() public virtual override(Oracle, OurUniswapV2TWAPOracle) returns (uint price) {
        price = median(ChainlinkOracle.latestPrice(),              // Not ideal to call latestPrice() on two of these
                       CompoundOpenOracle.latestPrice(),           // and cacheLatestPrice() on one...  But works, and
                       OurUniswapV2TWAPOracle.cacheLatestPrice()); // inheriting them like this saves significant gas
    }

    /**
     * @notice Currently only supports three inputs
     * @return median value
     */
    function median(uint a, uint b, uint c)
        private pure returns (uint)
    {
        bool ab = a > b;
        bool bc = b > c;
        bool ca = c > a;

        return (ca == ab ? a : (ab == bc ? b : c));
    }
}

// File: contracts/USM.sol

pragma solidity ^0.6.6;

contract USM is USMTemplate, MedianOracle {
    constructor(
        AggregatorV3Interface chainlinkAggregator,
        UniswapAnchoredView compoundView,
        IUniswapV2Pair uniswapPair, uint uniswapToken0Decimals, uint uniswapToken1Decimals, bool uniswapTokensInReverseOrder
    ) public
        USMTemplate()
        MedianOracle(chainlinkAggregator, compoundView,
                     uniswapPair, uniswapToken0Decimals, uniswapToken1Decimals, uniswapTokensInReverseOrder) {}

    function cacheLatestPrice() public virtual override(Oracle, MedianOracle) returns (uint price) {
        price = super.cacheLatestPrice();
    }
}
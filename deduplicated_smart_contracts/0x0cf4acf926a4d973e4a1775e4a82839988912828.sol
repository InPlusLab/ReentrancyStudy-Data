// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';

import {Distribution} from './Distribution.sol';
import {IPool} from './IPool.sol';
import {IPoolStore} from './PoolStore.sol';
import {Operator} from '../access/Operator.sol';

interface IShareRewardPool {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingShare(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

contract PickleProxy is Operator, ERC20, IShareRewardPool {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public pool;
    uint256 public pid;

    constructor() ERC20('Vault Proxy Token', 'VPT') {}

    /* ================= GOV - OWNER ONLY ================= */

    function setPool(address _newPool) public onlyOwner {
        pool = _newPool;
    }

    function setPid(uint256 _newPid) public onlyOwner {
        pid = _newPid;
    }

    function deposit(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
        approve(pool, _amount);
        IPool(pool).deposit(pid, _amount);
    }

    function withdraw(uint256 _amount) public onlyOwner {
        IPool(pool).withdraw(pid, _amount);
        _burn(address(this), _amount);
    }

    function deposit(uint256, uint256 _amount) public override onlyOperator {
        IERC20 token = IERC20(IPool(pool).tokenOf(pid));
        token.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256, uint256 _amount) public override onlyOperator {
        IERC20 token = IERC20(IPool(pool).tokenOf(pid));
        token.safeTransfer(msg.sender, _amount);
    }

    function pendingShare(uint256, address)
        public
        view
        override
        returns (uint256)
    {
        return IPool(pool).rewardEarned(pid, address(this));
    }

    function userInfo(uint256, address)
        public
        view
        override
        returns (uint256, uint256)
    {
        return (IPool(pool).balanceOf(pid, address(this)), uint256(0));
    }

    function emergencyWithdraw(uint256) public override onlyOperator {
        IPoolStore(Distribution(pool).store()).emergencyWithdraw(pid);
        IERC20 token = IERC20(IPool(pool).tokenOf(pid));
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function _setupDecimals(uint8 decimals_) internal virtual {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import {Math} from '@openzeppelin/contracts/math/Math.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {Operator} from '../access/Operator.sol';
import {IPool, IPoolGov} from './IPool.sol';
import {IPoolStore, PoolStoreWrapper} from './PoolStoreWrapper.sol';

contract Distribution is IPool, IPoolGov, PoolStoreWrapper, Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ================= DATA STRUCTURE ================= */

    struct User {
        uint256 amount;
        uint256 reward;
        uint256 rewardPerTokenPaid;
    }
    struct Pool {
        bool initialized;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    /* ================= STATE VARIABLES ================= */

    // share
    address public share;
    mapping(address => bool) public approvals;
    // poolId => Pool
    mapping(uint256 => Pool) public pools;
    // poolId => sender => User
    mapping(uint256 => mapping(address => User)) public users;

    bool public stopped = false;
    uint256 public rewardRate = 0;
    uint256 public rewardRateExtra = 0;

    // halving
    uint256 public rewardRateBeforeHalve = 0;

    // control
    uint256 public period = 0;
    uint256 public periodFinish = 0;
    uint256 public startTime = 0;

    /* ================= CONSTRUCTOR ================= */

    constructor(address _share, address _poolStore) Ownable() {
        share = _share;
        store = IPoolStore(_poolStore);
    }

    /* ================= GOV - OWNER ONLY ================= */

    /**
     * @param _startTime starting time to distribute
     * @param _period distribution period
     */
    function setPeriod(uint256 _startTime, uint256 _period)
        public
        override
        onlyOperator
    {
        // re-calc
        if (startTime <= block.timestamp && block.timestamp < periodFinish) {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = leftover.div(_period);
        }

        period = _period;
        startTime = _startTime;
        periodFinish = _startTime.add(_period);
    }

    /**
     * @param _amount token amount to distribute
     */
    function setReward(uint256 _amount) public override onlyOperator {
        require(block.timestamp < periodFinish, 'BACPool: already finished');

        if (startTime <= block.timestamp) {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _amount.add(leftover).div(
                periodFinish.sub(block.timestamp)
            );
        } else {
            rewardRate = rewardRate.add(
                _amount.div(periodFinish.sub(startTime))
            );
        }
    }

    function setExtraRewardRate(uint256 _extra) public override onlyOwner {
        rewardRateExtra = _extra;
    }

    /**
     * @dev STOP DISTRIBUTION
     */
    function stop() public override onlyOwner {
        periodFinish = block.timestamp;
        stopped = true;
    }

    /**
     * @dev MUST UPDATE ALL POOL REWARD BEFORE MIGRATION!!!!!
     * @param _newPool new pool address to migrate
     */
    function migrate(address _newPool, uint256 _amount)
        public
        override
        onlyOwner
    {
        require(stopped, 'BACPool: not stopped');
        IERC20(share).safeTransfer(_newPool, _amount);

        uint256 remaining = startTime.add(period).sub(periodFinish);
        uint256 leftover = remaining.mul(rewardRate);
        IPoolGov(_newPool).setPeriod(block.timestamp.add(1), remaining);
        IPoolGov(_newPool).setReward(leftover);
    }

    /* ================= MODIFIER ================= */

    /**
     * @param _pid pool id
     * @param _target update target. if is empty, skip individual update.
     */
    modifier updateReward(uint256 _pid, address _target) {
        if (!approvals[store.tokenOf(_pid)]) {
            IERC20(store.tokenOf(_pid)).safeApprove(
                address(store),
                type(uint256).max
            );
            approvals[store.tokenOf(_pid)] = true;
        }

        if (block.timestamp >= startTime) {
            if (!pools[_pid].initialized) {
                pools[_pid] = Pool({
                    initialized: true,
                    rewardRate: rewardRate,
                    lastUpdateTime: startTime,
                    rewardPerTokenStored: 0
                });
            }

            // halve
            if (!stopped && block.timestamp >= periodFinish) {
                // decrease reward rate
                rewardRateBeforeHalve = rewardRate;
                rewardRate = rewardRate.mul(75).div(100);

                // set period
                startTime = block.timestamp;
                periodFinish = block.timestamp.add(period);
            }

            Pool memory pool = pools[_pid];
            pool.rewardPerTokenStored = rewardPerToken(_pid);
            if (pool.rewardRate == rewardRateBeforeHalve) {
                pool.rewardRate = rewardRate;
            }
            pool.lastUpdateTime = applicableRewardTime();
            pools[_pid] = pool;

            if (_target != address(0x0)) {
                User memory user = users[_pid][_target];
                user.reward = rewardEarned(_pid, _target);
                user.rewardPerTokenPaid = pool.rewardPerTokenStored;
                users[_pid][_target] = user;
            }
        }

        _;
    }

    /* ================= CALLS - ANYONE ================= */

    /**
     * @param _pid pool id
     * @return pool token address
     */
    function tokenOf(uint256 _pid) external view override returns (address) {
        return store.tokenOf(_pid);
    }

    /**
     * @param _token pool token address
     * @return pool id
     */
    function poolIdsOf(address _token)
        external
        view
        override
        returns (uint256[] memory)
    {
        return store.poolIdsOf(_token);
    }

    /**
     * @param _pid pool id
     * @return pool's total staked amount
     */
    function totalSupply(uint256 _pid)
        external
        view
        override
        returns (uint256)
    {
        return store.totalSupply(_pid);
    }

    /**
     * @param _owner staker address
     * @return staker balance
     */
    function balanceOf(uint256 _pid, address _owner)
        external
        view
        override
        returns (uint256)
    {
        return store.balanceOf(_pid, _owner);
    }

    /**
     * @return applicable reward time
     */
    function applicableRewardTime() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /**
     * @param _pid pool id
     * @param _crit reward rate
     */
    function _rewardRatePerPool(uint256 _pid, uint256 _crit)
        internal
        view
        returns (uint256)
    {
        return _crit.mul(store.weightOf(_pid)).div(store.totalWeight());
    }

    /**
     * @param _pid pool id
     * @return calculated reward rate per pool
     */
    function rewardRatePerPool(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {
        return _rewardRatePerPool(_pid, rewardRate.add(rewardRateExtra));
    }

    /**
     * @param _pid pool id
     * @return RPT per pool
     */
    function rewardPerToken(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {
        Pool memory pool = pools[_pid];
        if (store.totalSupply(_pid) == 0 || block.timestamp < startTime) {
            return pool.rewardPerTokenStored;
        }

        if (pool.rewardRate != 0 && pool.rewardRate == rewardRateBeforeHalve) {
            uint256 beforeHalve =
                startTime
                    .sub(pool.lastUpdateTime)
                    .mul(_rewardRatePerPool(_pid, rewardRateBeforeHalve))
                    .mul(1e18)
                    .div(store.totalSupply(_pid));
            uint256 afterHalve =
                applicableRewardTime()
                    .sub(startTime)
                    .mul(rewardRatePerPool(_pid))
                    .mul(1e18)
                    .div(store.totalSupply(_pid));
            return pool.rewardPerTokenStored.add(beforeHalve).add(afterHalve);
        } else {
            return
                pool.rewardPerTokenStored.add(
                    applicableRewardTime()
                        .sub(pool.lastUpdateTime)
                        .mul(rewardRatePerPool(_pid))
                        .mul(1e18)
                        .div(store.totalSupply(_pid))
                );
        }
    }

    /**
     * @param _pid pool id
     * @param _target target address
     * @return reward amount per pool
     */
    function rewardEarned(uint256 _pid, address _target)
        public
        view
        override
        returns (uint256)
    {
        User memory user = users[_pid][_target];
        return
            store
                .balanceOf(_pid, _target)
                .mul(rewardPerToken(_pid).sub(user.rewardPerTokenPaid))
                .div(1e18)
                .add(user.reward);
    }

    /* ================= TXNS - ANYONE ================= */

    /**
     * @param _pids array of pool ids
     */
    function massUpdate(uint256[] memory _pids) public override {
        for (uint256 i = 0; i < _pids.length; i++) {
            update(_pids[i]);
        }
    }

    /**
     * @param _pid pool id
     */
    function update(uint256 _pid)
        public
        override
        updateReward(_pid, address(0x0))
    {}

    /**
     * @param _pid pool id
     * @param _amount deposit amount
     */
    function deposit(uint256 _pid, uint256 _amount)
        public
        override(IPool, PoolStoreWrapper)
        updateReward(_pid, _msgSender())
    {
        require(!stopped, 'BASPool: stopped');
        super.deposit(_pid, _amount);
        emit DepositToken(_msgSender(), _pid, _amount);
    }

    /**
     * @param _pid pool id
     * @param _amount withdraw amount
     */
    function withdraw(uint256 _pid, uint256 _amount)
        public
        override(IPool, PoolStoreWrapper)
        updateReward(_pid, _msgSender())
    {
        require(!stopped, 'BASPool: stopped');
        super.withdraw(_pid, _amount);
        emit WithdrawToken(_msgSender(), _pid, _amount);
    }

    /**
     * @param _pid pool id
     */
    function claimReward(uint256 _pid)
        public
        override
        updateReward(_pid, _msgSender())
    {
        uint256 reward = users[_pid][_msgSender()].reward;
        if (reward > 0) {
            users[_pid][_msgSender()].reward = 0;
            IERC20(share).safeTransfer(_msgSender(), reward);
            emit RewardClaimed(_msgSender(), _pid, reward);
        }
    }

    /**
     * @dev withdraw + claim
     * @param _pid pool id
     */
    function exit(uint256 _pid) external override {
        withdraw(_pid, store.balanceOf(_pid, _msgSender()));
        claimReward(_pid);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

interface IPool {
    /* ================= EVENTS ================= */

    event DepositToken(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event WithdrawToken(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event RewardClaimed(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );

    /* ================= CALLS ================= */

    function tokenOf(uint256 _pid) external view returns (address);

    function poolIdsOf(address _token) external view returns (uint256[] memory);

    function totalSupply(uint256 _pid) external view returns (uint256);

    function balanceOf(uint256 _pid, address _owner)
        external
        view
        returns (uint256);

    function rewardRatePerPool(uint256 _pid) external view returns (uint256);

    function rewardPerToken(uint256 _pid) external view returns (uint256);

    function rewardEarned(uint256 _pid, address _target)
        external
        view
        returns (uint256);

    /* ================= TXNS ================= */

    function massUpdate(uint256[] memory _pids) external;

    function update(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function claimReward(uint256 _pid) external;

    function exit(uint256 _pid) external;
}

interface IPoolGov {
    /* ================= EVENTS ================= */

    event RewardNotified(
        address indexed operator,
        uint256 amount,
        uint256 period
    );

    /* ================= TXNS ================= */

    function setPeriod(uint256 _startTime, uint256 _period) external;

    function setReward(uint256 _amount) external;

    function setExtraRewardRate(uint256 _extra) external;

    function stop() external;

    function migrate(address _newPool, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import {Operator} from '../access/Operator.sol';

interface IPoolStore {
    /* ================= EVENTS ================= */
    event Deposit(
        address indexed operator,
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event Withdraw(
        address indexed operator,
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );

    /* ================= CALLS ================= */

    // common
    function totalWeight() external view returns (uint256);

    function poolLength() external view returns (uint256);

    // index
    function poolIdsOf(address _token) external view returns (uint256[] memory);

    // pool info
    function nameOf(uint256 _pid) external view returns (string memory);

    function tokenOf(uint256 _pid) external view returns (address);

    function weightOf(uint256 _pid) external view returns (uint256);

    function totalSupply(uint256 _pid) external view returns (uint256);

    function balanceOf(uint256 _pid, address _owner)
        external
        view
        returns (uint256);

    /* ================= TXNS ================= */

    function deposit(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) external;

    function withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) external;

    function emergencyWithdraw(uint256 _pid) external;
}

interface IPoolStoreGov {
    /* ================= EVENTS ================= */

    event EmergencyReported(address indexed reporter);
    event EmergencyResolved(address indexed resolver);

    event WeightFeederChanged(
        address indexed operator,
        address indexed oldFeeder,
        address indexed newFeeder
    );

    event PoolAdded(
        address indexed operator,
        uint256 indexed pid,
        string name,
        address token,
        uint256 weight
    );
    event PoolWeightChanged(
        address indexed operator,
        uint256 indexed pid,
        uint256 from,
        uint256 to
    );
    event PoolNameChanged(
        address indexed operator,
        uint256 indexed pid,
        string from,
        string to
    );

    /* ================= TXNS ================= */

    // emergency
    function reportEmergency() external;

    function resolveEmergency() external;

    // feeder
    function setWeightFeeder(address _newFeeder) external;

    // pool setting
    function addPool(
        string memory _name,
        IERC20 _token,
        uint256 _weight
    ) external;

    function setPool(uint256 _pid, uint256 _weight) external;

    function setPool(uint256 _pid, string memory _name) external;
}

contract PoolStore is IPoolStore, IPoolStoreGov, Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ================= DATA STRUCTURE ================= */

    struct Pool {
        string name;
        IERC20 token;
        uint256 weight;
        uint256 totalSupply;
    }

    /* ================= STATES ================= */

    uint256 public override totalWeight = 0;

    Pool[] public pools;
    mapping(uint256 => mapping(address => uint256)) balances;
    mapping(address => uint256[]) public indexByToken;

    bool public emergency = false;
    address public weightFeeder;

    constructor() Operator() {
        weightFeeder = _msgSender();
    }

    /* ================= GOV - OWNER ONLY ================= */

    /**
     * @dev CAUTION: DO NOT USE IN NORMAL SITUATION
     * @notice Enable emergency withdraw
     */
    function reportEmergency() public override onlyOwner {
        emergency = true;
        emit EmergencyReported(_msgSender());
    }

    /**
     * @dev CAUTION: DO NOT USE IN NORMAL SITUATION
     * @notice Disable emergency withdraw
     */
    function resolveEmergency() public override onlyOwner {
        emergency = false;
        emit EmergencyResolved(_msgSender());
    }

    /*
     * @param _newFeeder weight feeder address to change
     */
    function setWeightFeeder(address _newFeeder) public override onlyOwner {
        address oldFeeder = weightFeeder;
        weightFeeder = _newFeeder;
        emit WeightFeederChanged(_msgSender(), oldFeeder, _newFeeder);
    }

    /**
     * @param _token pool token
     * @param _weight pool weight
     */
    function addPool(
        string memory _name,
        IERC20 _token,
        uint256 _weight
    ) public override onlyOwner {
        totalWeight = totalWeight.add(_weight);

        uint256 index = pools.length;
        indexByToken[address(_token)].push(index);

        pools.push(
            Pool({name: _name, token: _token, weight: _weight, totalSupply: 0})
        );
        emit PoolAdded(_msgSender(), index, _name, address(_token), _weight);
    }

    /**
     * @param _pid pool id
     * @param _weight target pool weight
     */
    function setPool(uint256 _pid, uint256 _weight)
        public
        override
        onlyWeightFeeder
        checkPoolId(_pid)
    {
        Pool memory pool = pools[_pid];

        uint256 oldWeight = pool.weight;
        totalWeight = totalWeight.add(_weight).sub(pool.weight);
        pool.weight = _weight;

        pools[_pid] = pool;

        emit PoolWeightChanged(_msgSender(), _pid, oldWeight, _weight);
    }

    /**
     * @param _pid pool id
     * @param _name name of pool
     */
    function setPool(uint256 _pid, string memory _name)
        public
        override
        checkPoolId(_pid)
        onlyOwner
    {
        string memory oldName = pools[_pid].name;
        pools[_pid].name = _name;

        emit PoolNameChanged(_msgSender(), _pid, oldName, _name);
    }

    /* ================= MODIFIER ================= */

    modifier onlyWeightFeeder {
        require(_msgSender() == weightFeeder, 'PoolStore: unauthorized');

        _;
    }

    modifier checkPoolId(uint256 _pid) {
        require(_pid <= pools.length, 'PoolStore: invalid pid');

        _;
    }

    /* ================= CALLS - ANYONE ================= */
    /**
     * @return total pool length
     */
    function poolLength() public view override returns (uint256) {
        return pools.length;
    }

    /**
     * @param _token pool token address
     * @return pool id
     */
    function poolIdsOf(address _token)
        public
        view
        override
        returns (uint256[] memory)
    {
        return indexByToken[_token];
    }

    /**
     * @param _pid pool id
     * @return name of pool
     */
    function nameOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (string memory)
    {
        return pools[_pid].name;
    }

    /**
     * @param _pid pool id
     * @return pool token
     */
    function tokenOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (address)
    {
        return address(pools[_pid].token);
    }

    /**
     * @param _pid pool id
     * @return pool weight
     */
    function weightOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {
        return pools[_pid].weight;
    }

    /**
     * @param _pid pool id
     * @return total staked token amount
     */
    function totalSupply(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {
        return pools[_pid].totalSupply;
    }

    /**
     * @param _pid pool id
     * @param _sender staker address
     * @return staked amount of user
     */
    function balanceOf(uint256 _pid, address _sender)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {
        return balances[_pid][_sender];
    }

    /* ================= TXNS - OPERATOR ONLY ================= */

    /**
     * @param _pid pool id
     * @param _owner stake address
     * @param _amount stake amount
     */
    function deposit(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) public override checkPoolId(_pid) onlyOperator {
        pools[_pid].totalSupply = pools[_pid].totalSupply.add(_amount);
        balances[_pid][_owner] = balances[_pid][_owner].add(_amount);
        IERC20(tokenOf(_pid)).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );

        emit Deposit(_msgSender(), _owner, _pid, _amount);
    }

    function _withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) internal {
        pools[_pid].totalSupply = pools[_pid].totalSupply.sub(_amount);
        balances[_pid][_owner] = balances[_pid][_owner].sub(_amount);
        IERC20(tokenOf(_pid)).safeTransfer(_msgSender(), _amount);

        emit Withdraw(_msgSender(), _owner, _pid, _amount);
    }

    /**
     * @param _pid pool id
     * @param _owner stake address
     * @param _amount stake amount
     */
    function withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) public override checkPoolId(_pid) onlyOperator {
        _withdraw(_pid, _owner, _amount);
    }

    /**
     * @notice Anyone can withdraw its balance even if is not the operator
     * @param _pid pool id
     */
    function emergencyWithdraw(uint256 _pid) public override checkPoolId(_pid) {
        require(emergency, 'PoolStore: not in emergency');
        _withdraw(_pid, msg.sender, balanceOf(_pid, _msgSender()));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import {Context, Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

abstract contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(
            _operator == _msgSender(),
            'operator: caller is not the operator'
        );
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            'operator: zero address given for new operator'
        );
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.0;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import {IPoolStore} from './PoolStore.sol';

abstract contract PoolStoreWrapper is Context {
    using SafeERC20 for IERC20;

    IPoolStore public store;

    function deposit(uint256 _pid, uint256 _amount) public virtual {
        IERC20(store.tokenOf(_pid)).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        store.deposit(_pid, _msgSender(), _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public virtual {
        store.withdraw(_pid, _msgSender(), _amount);
        IERC20(store.tokenOf(_pid)).safeTransfer(_msgSender(), _amount);
    }
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}
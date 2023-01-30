/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: contracts/libraries/Upgradable.sol

// pragma solidity >=0.6.5 <0.8.0;

contract UpgradableProduct {
    address public impl;

    event ImplChanged(address indexed _oldImpl, address indexed _newImpl);

    constructor() public {
        impl = msg.sender;
    }

    modifier requireImpl() {
        require(msg.sender == impl, "FORBIDDEN");
        _;
    }

    function upgradeImpl(address _newImpl) public requireImpl {
        require(_newImpl != address(0), "INVALID_ADDRESS");
        require(_newImpl != impl, "NO_CHANGE");
        address lastImpl = impl;
        impl = _newImpl;
        emit ImplChanged(lastImpl, _newImpl);
    }
}

contract UpgradableGovernance {
    address public governor;

    event GovernorChanged(
        address indexed _oldGovernor,
        address indexed _newGovernor
    );

    constructor() public {
        governor = msg.sender;
    }

    modifier requireGovernor() {
        require(msg.sender == governor, "FORBIDDEN");
        _;
    }

    function upgradeGovernance(address _newGovernor) public requireGovernor {
        require(_newGovernor != address(0), "INVALID_ADDRESS");
        require(_newGovernor != governor, "NO_CHANGE");
        address lastGovernor = governor;
        governor = _newGovernor;
        emit GovernorChanged(lastGovernor, _newGovernor);
    }
}


// Dependency file: contracts/libraries/ConfigNames.sol

// pragma solidity >=0.6.5 <0.8.0;

library ConfigNames {
    bytes32 public constant FRYER_LTV = bytes32("FRYER_LTV");
    bytes32 public constant FRYER_HARVEST_FEE = bytes32("FRYER_HARVEST_FEE");
    bytes32 public constant FRYER_VAULT_PERCENTAGE =
        bytes32("FRYER_VAULT_PERCENTAGE");

    bytes32 public constant FRYER_FLASH_FEE_PROPORTION =
        bytes32("FRYER_FLASH_FEE_PROPORTION");

    bytes32 public constant PRIVATE = bytes32("PRIVATE");
    bytes32 public constant STAKE = bytes32("STAKE");
}


// Dependency file: contracts/libraries/WhiteList.sol

// pragma solidity >=0.6.5 <0.8.0;

pragma experimental ABIEncoderV2;

// import "contracts/libraries/Upgradable.sol";

contract WhiteList is UpgradableProduct {
    event SetWhitelist(address indexed user, bool state);

    mapping(address => bool) public whiteList;

    /// This function reverts if the caller is not governance
    ///
    /// @param _toWhitelist the account to mint tokens to.
    /// @param _state the whitelist state.
    function setWhitelist(address _toWhitelist, bool _state)
        external
        requireImpl
    {
        whiteList[_toWhitelist] = _state;
        emit SetWhitelist(_toWhitelist, _state);
    }

    /// @dev A modifier which checks if whitelisted for minting.
    modifier onlyWhitelisted() {
        require(whiteList[msg.sender], "!whitelisted");
        _;
    }
}


// Dependency file: contracts/libraries/TransferHelper.sol

// pragma solidity >=0.6.5 <0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: @openzeppelin/contracts/token/ERC20/ERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";

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


// Dependency file: contracts/CheeseToken.sol

// pragma solidity >=0.6.5 <0.8.0;

// import '/Users/sg99022ml/Desktop/chfry-protocol-internal/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import '/Users/sg99022ml/Desktop/chfry-protocol-internal/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol';
// import '/Users/sg99022ml/Desktop/chfry-protocol-internal/node_modules/@openzeppelin/contracts/math/SafeMath.sol';
// import 'contracts/libraries/Upgradable.sol';

contract CheeseToken is ERC20, UpgradableProduct {
	using SafeMath for uint256;

	mapping(address => bool) public whiteList;

	constructor(string memory _symbol, string memory _name) public ERC20(_name, _symbol) {
		_mint(msg.sender, uint256(2328300).mul(1e18));
	}

	modifier onlyWhitelisted() {
		require(whiteList[msg.sender], '!whitelisted');
		_;
	}

	function setWhitelist(address _toWhitelist, bool _state) external requireImpl {
		whiteList[_toWhitelist] = _state;
	}

	function mint(address account, uint256 amount) external virtual onlyWhitelisted {
		require(totalSupply().add(amount) <= cap(), 'ERC20Capped: cap exceeded');
		_mint(account, amount);
	}

	function cap() public pure virtual returns (uint256) {
		return 9313200 * 1e18;
	}

	function burnFrom(address account, uint256 amount) public virtual {
		uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
			amount,
			'ERC20: burn amount exceeds allowance'
		);
		_approve(account, _msgSender(), decreasedAllowance);
		_burn(account, amount);
	}

	function burn(uint256 amount) external virtual {
		_burn(_msgSender(), amount);
	}
}


// Dependency file: contracts/CheeseFactory.sol

// pragma solidity >=0.6.5 <0.8.0;

// import '/Users/sg99022ml/Desktop/chfry-protocol-internal/node_modules/@openzeppelin/contracts/math/SafeMath.sol';
// import 'contracts/libraries/Upgradable.sol';
// import 'contracts/CheeseToken.sol';
// import 'contracts/libraries/ConfigNames.sol';
// import '/Users/sg99022ml/Desktop/chfry-protocol-internal/node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol';

//a1 = 75000, n = week, d= -390, week = [0,156]
//an=a1+(n-1)*d
//Sn=n*a1+(n(n-1)*d)/2
contract CheeseFactory is UpgradableProduct, ReentrancyGuard {
	using SafeMath for uint256;

	uint256 public constant MAX_WEEK = 156;
	uint256 public constant d = 390 * 10**18;
	uint256 public constant a1 = 75000 * 10**18;
	uint256 public constant TOTAL_WEIGHT = 10000;

	uint256 public startTimestamp;
	uint256 public lastTimestamp;
	uint256 public weekTimestamp;
	uint256 public totalMintAmount;
	CheeseToken public token;
	bool public initialized;

	struct Pool {
		address pool;
		uint256 weight;
		uint256 minted;
	}

	mapping(bytes32 => Pool) public poolInfo;

	constructor(address token_, uint256 weekTimestamp_) public {
		weekTimestamp = weekTimestamp_;
		token = CheeseToken(token_);
	}

	function setCheeseToken(address token_) external requireImpl {
		token = CheeseToken(token_);
	}

	function setPool(bytes32 poolName_, address poolAddress_) external requireImpl {
		require(poolName_ == ConfigNames.PRIVATE || poolName_ == ConfigNames.STAKE, 'name error');
		Pool storage pool = poolInfo[poolName_];
		pool.pool = poolAddress_;
	}

	modifier expectInitialized() {
		require(initialized, 'not initialized.');
		_;
	}

	function initialize(
		address private_,
		address stake_,
		uint256 startTimestamp_
	) external requireImpl {
		require(!initialized, 'already initialized');
		require(startTimestamp_ >= block.timestamp, '!startTime');
		// weight
		poolInfo[ConfigNames.PRIVATE] = Pool(private_, 1000, 0);
		poolInfo[ConfigNames.STAKE] = Pool(stake_, 9000, 0);
		initialized = true;
		startTimestamp = startTimestamp_;
		lastTimestamp = startTimestamp_;
	}

	function preMint() public view returns (uint256) {
		if (block.timestamp <= startTimestamp) {
			return uint256(0);
		}

		if (block.timestamp <= lastTimestamp) {
			return uint256(0);
		}
		uint256 time = block.timestamp.sub(startTimestamp);
		uint256 max_week_time = MAX_WEEK.mul(weekTimestamp);
		// time lt 156week
		if (time > max_week_time) {
			time = max_week_time;
		}

		// gt 1week
		if (time >= weekTimestamp) {
			uint256 n = time.div(weekTimestamp);

			//an =a1-(n)*d d<0
			//=> a1+(n)*(-d)
			uint256 an = a1.sub(n.mul(d));

			// gt 1week time stamp
			uint256 otherTimestamp = time.mod(weekTimestamp);
			uint256 other = an.mul(otherTimestamp).div(weekTimestamp);

			//Sn=n*a1+(n(n-1)*d)/2 d<0
			// => n*a1-(n(n-1)*(-d))/2

			// fist = n*a1
			uint256 first = n.mul(a1);
			// last = (n(n-1)*(-d))/2
			uint256 last = n.mul(n.sub(1)).mul(d).div(2);
			uint256 sn = first.sub(last);
			return other.add(sn).sub(totalMintAmount);
		} else {
			return a1.mul(time).div(weekTimestamp).sub(totalMintAmount);
		}
	}

	function _updateTotalAmount() internal returns (uint256) {
		uint256 preMintAmount = preMint();
		totalMintAmount = totalMintAmount.add(preMintAmount);
		lastTimestamp = block.timestamp;
		return preMintAmount;
	}

	function prePoolMint(bytes32 poolName_) public view returns (uint256) {
		uint256 preMintAmount = preMint();
		Pool memory pool = poolInfo[poolName_];
		uint256 poolTotal = totalMintAmount.add(preMintAmount).mul(pool.weight).div(TOTAL_WEIGHT);
		return poolTotal.sub(pool.minted);
	}

	function poolMint(bytes32 poolName_) external nonReentrant expectInitialized returns (uint256) {
		Pool storage pool = poolInfo[poolName_];
		require(msg.sender == pool.pool, 'Permission denied');
		_updateTotalAmount();
		uint256 poolTotal = totalMintAmount.mul(pool.weight).div(TOTAL_WEIGHT);
		uint256 amount = poolTotal.sub(pool.minted);
		if (amount > 0) {
			token.mint(msg.sender, amount);
			pool.minted = pool.minted.add(amount);
		}
		return amount;
	}
}


// Root file: contracts/CheesePrivateStakePool.sol

pragma solidity >=0.6.5 <0.8.0;


contract CheesePrivateStakePool is WhiteList, ReentrancyGuard {
    event Stake(address indexed user, uint256 indexed amount);
    event Withdraw(address indexed user, uint256 indexed amount);
    event Claimed(address indexed user, uint256 indexed amount);
    event SetCheeseFactory(address indexed factory);
    event SetCheeseToken(address indexed token);

    using TransferHelper for address;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 debt;
        uint256 reward;
        uint256 totalIncome;
    }

    CheeseToken public token;
    CheeseFactory public cheeseFactory;

    uint256 public lastBlockTimeStamp;
    uint256 public rewardPerShare;
    uint256 public totalStake;

    mapping(address => UserInfo) public userInfos;

    constructor(address cheeseFactory_, address token_) public {
        cheeseFactory = CheeseFactory(cheeseFactory_);
        token = CheeseToken(token_);
    }

    function setCheeseFactory(address cheeseFactory_) external requireImpl {
        cheeseFactory = CheeseFactory(cheeseFactory_);
        emit SetCheeseFactory(cheeseFactory_);
    }

    function setCheeseToken(address token_) external requireImpl {
        token = CheeseToken(token_);
        emit SetCheeseToken(token_);
    }

    function getUserInfo(address userAddress)
        external
        view
        virtual
        returns (
            uint256 amount,
            uint256 debt,
            uint256 reward,
            uint256 totalIncome
        )
    {
        UserInfo memory userInfo = userInfos[userAddress];
        return (
            userInfo.amount,
            userInfo.debt,
            userInfo.reward,
            userInfo.totalIncome
        );
    }

    function currentRewardShare()
        public
        view
        virtual
        returns (uint256 _reward, uint256 _perShare)
    {
        _reward = cheeseFactory.prePoolMint(ConfigNames.PRIVATE);
        _perShare = rewardPerShare;

        if (totalStake > 0) {
            _perShare = _perShare.add(_reward.mul(1e18).div(totalStake));
        }
        return (_reward, _perShare);
    }

    modifier updateRewardPerShare() {
        if (totalStake > 0 && block.timestamp > lastBlockTimeStamp) {
            (uint256 _reward, uint256 _perShare) = currentRewardShare();
            rewardPerShare = _perShare;
            lastBlockTimeStamp = block.timestamp;
            require(
                _reward == cheeseFactory.poolMint(ConfigNames.PRIVATE),
                "pool mint error"
            );
        }
        _;
    }

    modifier updateUserReward(address user) {
        UserInfo storage userInfo = userInfos[user];
        if (userInfo.amount > 0) {
            uint256 debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            uint256 userReward = debt.sub(userInfo.debt);
            userInfo.reward = userInfo.reward.add(userReward);
            userInfo.debt = debt;
        }
        _;
    }

    function stake(uint256 amount)
        external
        virtual
        onlyWhitelisted
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        if (amount > 0) {
            UserInfo storage userInfo = userInfos[msg.sender];
            userInfo.amount = userInfo.amount.add(amount);
            userInfo.debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            totalStake = totalStake.add(amount);
            address(token).safeTransferFrom(msg.sender, address(this), amount);
            emit Stake(msg.sender, amount);
        }
    }

    function withdraw(uint256 amount)
        external
        virtual
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        if (amount > 0) {
            UserInfo storage userInfo = userInfos[msg.sender];
            require(userInfo.amount >= amount, "Insufficient balance");
            userInfo.amount = userInfo.amount.sub(amount);
            userInfo.debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            totalStake = totalStake.sub(amount);
            address(token).safeTransfer(msg.sender, amount);
            emit Withdraw(msg.sender, amount);
        }
    }

    function claim()
        external
        virtual
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        UserInfo storage userInfo = userInfos[msg.sender];
        if (userInfo.reward > 0) {
            uint256 amount = userInfo.reward;
            userInfo.reward = 0;
            userInfo.totalIncome = userInfo.totalIncome.add(amount);
            address(token).safeTransfer(msg.sender, amount);
            emit Claimed(msg.sender, amount);
        }
    }

    function calculateIncome(address user)
        external
        view
        virtual
        returns (uint256)
    {
        UserInfo storage userInfo = userInfos[user];
        uint256 _rewardPerShare = rewardPerShare;

        if (block.timestamp > lastBlockTimeStamp && totalStake > 0) {
            (, _rewardPerShare) = currentRewardShare();
        }
        uint256 userReward = userInfo.amount.mul(_rewardPerShare).div(1e18).sub(userInfo.debt);
        return userInfo.reward.add(userReward);
    }
}
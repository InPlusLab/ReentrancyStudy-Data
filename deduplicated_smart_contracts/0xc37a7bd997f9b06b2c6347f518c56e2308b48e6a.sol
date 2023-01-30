/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^0.5.16;

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

interface IDfFinanceOpen {

    function deal(
        address _walletOwner,
        uint _coef,
        uint _profitPercent,
        bytes calldata _data,
        uint _usdcToBuyEth,
        uint _ethType
    ) external payable
    returns(address dfWallet);

    function dfFinanceClose() external view returns(address dfFinanceClose);

}

interface IDfFinanceClose {

    // setup with Compound Oracle eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) external;

    // setup with special eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) external;

    // setup with special eth price and current extraCoef 每 for strategy migration
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee, uint256 _extraCoef
    ) external;

    function getStrategy(
        address _dfWallet
    ) external view
    returns(
        address strategyOwner,
        uint deposit,
        uint extraCoef,
        uint entryEthPrice,
        uint profitPercent,
        uint fee,
        uint ethForRedeem,
        uint usdToWithdraw,
        bool onlyProfitInUsd);

    function migrateStrategies(address[] calldata _dfWallets) external;

    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes calldata _exData
    ) external payable;

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes calldata _exData
    ) external payable;

    function depositEth(address _dfWallet) external payable;

}

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

interface IToken {
    function decimals() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function deposit() external payable;
    function withdraw(uint amount) external;
}

interface IERC20Burnable {

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}

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

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

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
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

contract Ownable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }
}

contract DfProfitToken is ERC20Detailed, ERC20, Ownable {

    constructor(
        string memory _name,
        string memory _symbol,
        address _issuer,
        uint256 _supply
    ) public {
        // Initialize Parents Contracts
        ERC20Detailed.initialize(_name, _symbol, uint8(18));

        // Token issue
        _mint(_issuer, _supply);
    }

    // ** PUBLIC functions **

    // Transfer to array of addresses
    function transfer(address[] memory recipients, uint256[] memory amounts) public returns(bool) {
        require(recipients.length == amounts.length, "Arrays lengths not equal");

        // transfer to all addresses
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }

    // ** ONLY_OWNER functions **

    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function burnFrom(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        require(accounts.length == amounts.length, "Arrays lengths not equal");

        // count for burned tokens
        uint burnedTokens = 0;

        for (uint i = 0; i < accounts.length; i++) {
            uint curAmount = amounts[i];
            _burnWithoutTotalSupplyReduce(accounts[i], curAmount);
            burnedTokens = burnedTokens.add(curAmount);
        }

        // reducing the total supply only once 每 reduce gas consumtion
        _totalSupply = _totalSupply.sub(burnedTokens);
    }

    // ** INTERNAL functions **

    // function to reduce gas consumtion for array transfer (using instead of _burn)
    function _burnWithoutTotalSupplyReduce(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        emit Transfer(account, address(0), amount);
    }

}

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";

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

    function safeTransfer(IToken token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IToken token, bytes memory data) private {
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

library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {
        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {
        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

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
    /*function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }*/
}

contract DfTokenizedStrategy is DSMath, Ownable {

    using UniversalERC20 for IToken;

    struct TokenizedStrategy {
        // bytes32 (== uint256) slot
        uint80 initialEth;      // in eth 每 max more 1.2 mln eth
        uint80 entryEthPrice;   // in usd 每 max more 1.2 mln USD for 1 eth
        uint8 profitPercent;    // min profit percent
        bool onlyWithProfit;    // strategy can be closed only with profitPercent profit
        bool isStrategyClosed;  // strategy is closed
    }

    // address public constant DF_FINANCE_OPEN = address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b);   // TODO: DfFinanceOpenCompound address
    address public constant DF_FINANCE_OPEN = address(0x7eF7eBf6c5DA51A95109f31063B74ECf269b22bE);   // TODO: DfFinanceOpenCompound v2 address

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address public profitToken;
    address public dfFinanceClose;

    // deposited eth in strategy by owner (with depositEth count)
    uint256 public ethInDeposit;

    TokenizedStrategy public strategy;

    // ** EVENTS **

    event ProfitTokenCreated(
        address indexed profitToken
    );

    event DepositWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );

    event ProfitWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );

    // ** MODIFIERS **

    modifier onlyDfClose {
        require(msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier afterStrategyClosed {
        require(strategy.isStrategyClosed, "Strategy is not closed");
        _;
    }

    // ** CONSTRUCTOR **

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _issuer,
        uint _extraCoef,
        uint _profitPercent,
        bytes memory _exchangeData,
        uint _usdcToBuyEth,
        uint _ethType,
        bool _onlyWithProfit
    ) public payable {
        require(_profitPercent > 0, "Profit percent can not be zero");

        uint curDeposit = address(this).balance;

        uint extraEth = mul(curDeposit, sub(_extraCoef, 100)) / 100;
        uint curEthPrice = wdiv(_usdcToBuyEth * 1e12, extraEth);

        // _profitPercent in percent (10 == 10%)
        uint tokensPerEth = wmul(mul(_profitPercent, WAD) / 100, curEthPrice);  // number of tokens for profit distribution per 1 eth

        // create token contract and mint tokens
        address tokenAddr = address(
            new DfProfitToken(
                _tokenName,
                _tokenSymbol,
                _issuer,
                wmul(curDeposit, tokensPerEth)
            )
        );
        profitToken = tokenAddr;

        // open strategy
        IDfFinanceOpen(DF_FINANCE_OPEN)
            .deal
            .value(curDeposit)
            (
                address(this),
                _extraCoef,
                _profitPercent,
                _exchangeData,
                _usdcToBuyEth,
                _ethType
            );

        // UPD states after open strategy
        ethInDeposit = curDeposit;
        strategy = TokenizedStrategy({
            initialEth: uint80(curDeposit),
            entryEthPrice: uint80(curEthPrice),
            profitPercent: uint8(_profitPercent),
            onlyWithProfit: _onlyWithProfit,
            isStrategyClosed: false
        });
        dfFinanceClose = IDfFinanceOpen(DF_FINANCE_OPEN).dfFinanceClose();

        emit ProfitTokenCreated(tokenAddr);
    }

    // ** PUBLIC VIEW functions **

    function calculateProfit(address _userAddr) public view returns(
        uint ethToWithdraw,
        uint usdToWithdraw
    ) {
        // return zero if the strategy is not closed
        if (!strategy.isStrategyClosed) {
            return (0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        uint tokenTotalSupply = IERC20(profitToken).totalSupply();

        if (ethBalance == 0 && usdBalance == 0 || tokenTotalSupply == 0) {
            return (0, 0);
        }

        uint userTokenBalance = IERC20(profitToken).balanceOf(_userAddr);
        uint userShare = wdiv(userTokenBalance, tokenTotalSupply);

        ethToWithdraw = wmul(ethBalance, userShare);
        usdToWithdraw = wmul(usdBalance * 1e12, userShare) / 1e12;
    }

    // ** PUBLIC functions **

    function withdrawProfit() public afterStrategyClosed {
        _withdrawProfitHelper(msg.sender);
    }

    function withdrawProfit(address[] memory _accounts) public afterStrategyClosed {
        for (uint i = 0; i < _accounts.length; i++) {
           _withdrawProfitHelper(_accounts[i]);
        }
    }

    // ** ONLY_OWNER functions 每 calls DfFinanceClose **

    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes memory _exData
    ) public payable onlyOwner {

        IDfFinanceClose(dfFinanceClose)
            .collectAndCloseByUser
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _onlyProfitInUsd,
                _exData
            );

    }

    function depositEth(address _dfWallet) public payable onlyOwner {
        (address strategyOwner,,,,,,,,) = IDfFinanceClose(dfFinanceClose).getStrategy(_dfWallet);
        require(address(this) == strategyOwner, "Incorrect dfWallet address");

        uint ethAmount = msg.value;

        IDfFinanceClose(dfFinanceClose)
            .depositEth
            .value(ethAmount)
            (
                _dfWallet
            );

        // UPD ethInDeposit state
        ethInDeposit = add(ethInDeposit, ethAmount);
    }

    function migrateStrategies(address[] memory _dfWallets) public onlyOwner {
        IDfFinanceClose(dfFinanceClose).migrateStrategies(_dfWallets);
    }

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes memory _exData
    ) public payable onlyOwner {

        IDfFinanceClose(dfFinanceClose)
            .exitAfterLiquidation
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _exData
            );

    }

    function externalCall(address payable _to, bytes memory _data) public payable onlyOwner {
        uint ethAmount = msg.value;
        bytes32 response;

        assembly {
            let succeeded := call(sub(gas, 5000), _to, ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }

    // ** CALLBACK function **

    // closing strategy callback handler
    function __callback() external onlyDfClose {
        strategy.isStrategyClosed = true;

        // withdraw owner's deposit
        _withdrawDeposit();

        require(!(strategy.onlyWithProfit) ||
                _isProfitable(), "Strategy is not profitable enough");
    }

    // ** INTERNAL VIEW functions **

    function _isProfitable() internal view returns(bool) {

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        // profitPercent in percent (10 == 10%)
        uint targetProfitEth = wmul(strategy.initialEth, WAD * strategy.profitPercent / 100);
        uint targetProfitUsd = IERC20(profitToken).totalSupply() / 1e12;  // 1 profit token == 1 USD

        // strategy is profitable enough for closing
        if (ethBalance >= targetProfitEth || usdBalance >= targetProfitUsd) {
            return true;
        }

        return false;
    }

    function _calculateWithdrawalOnDeposit() internal view returns(
        uint ethToWithdraw,
        uint usdToWithdraw,
        uint depositEth     // rest deposit in eth after this withdrawal
    ) {
        depositEth = ethInDeposit;
        if (depositEth == 0) {
            return (0, 0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        // ethToWithdraw calculate
        if (ethBalance >= depositEth) {
            ethToWithdraw = depositEth;
        } else if (ethBalance > 0) {
            ethToWithdraw = ethBalance;
        }

        // update depositEth counter
        if (ethToWithdraw > 0) {
            depositEth = sub(depositEth, ethToWithdraw);
        }

        // calculate usdToWithdraw if there is not enough ETH
        if (depositEth > 0) {
            uint ethPrice = strategy.entryEthPrice;
            uint depositUsd = wmul(depositEth, ethPrice) / 1e12;  // rest deposit in USDC

            // usdToWithdraw calculate
            if (usdBalance >= depositUsd) {
                usdToWithdraw = depositUsd;
            } else if (usdBalance > 0) {
                usdToWithdraw = usdBalance;
            }

            // update depositEth counter
            if (usdToWithdraw > 0) {
                depositUsd = sub(depositUsd, usdToWithdraw);
                depositEth = wdiv(depositUsd * 1e12, ethPrice);
            }
        }
    }

    // ** INTERNAL functions **

    function _withdrawDeposit() internal {
        // calculate withdrawal on deposit
        (uint ethToWithdraw, uint usdToWithdraw, uint restDepositEth) = _calculateWithdrawalOnDeposit();

        // UPD ethInDeposit state
        ethInDeposit = restDepositEth;

        // withdraw deposit
        address userAddr = msg.sender;
        _withdrawHelper(userAddr, ethToWithdraw, usdToWithdraw);

        emit DepositWithdrawn(userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _withdrawProfitHelper(address _userAddr) internal {
        uint tokenBalance = IERC20(profitToken).balanceOf(_userAddr);

        if (tokenBalance == 0) {
            return;  // User has no tokens to burn
        }

        // calculate user's profit
        (uint ethToWithdraw, uint usdToWithdraw) = calculateProfit(_userAddr);

        // burn all user's tokens
        _burnTokensHelper(_userAddr, tokenBalance);

        // withdraw user's profit
        _withdrawHelper(_userAddr, ethToWithdraw, usdToWithdraw);

        emit ProfitWithdrawn(_userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _burnTokensHelper(address _userAddr, uint _amountToBurn) internal {
        IERC20Burnable(profitToken).burnFrom(_userAddr, _amountToBurn);
    }

    function _withdrawHelper(
        address _user, uint _ethToWithdraw, uint _usdToWithdraw
    ) internal {
        // withdraw ETH to user
        if (_ethToWithdraw > 0) {
            IToken(ETH_ADDRESS).universalTransfer(_user, _ethToWithdraw, true);
        }

        // withdraw USDC to user
        if (_usdToWithdraw > 0) {
            IToken(USDC_ADDRESS).universalTransfer(_user, _usdToWithdraw);
        }
    }

    // **FALLBACK function**
    function() external payable {}

}

contract DfTokenizedStrategyFactory is Initializable {

    // ** EVENTS **

    event TokenizedStrategyCreated(
        address indexed tokenizedStrategy
    );

    // // Initializer 每 Constructor for Upgradable contracts
    // function initialize() public initializer {}

    // ** PUBLIC PAYABLE function **

    function launchStrategy(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint _extraCoef,
        uint _profitPercent,
        bytes memory _exchangeData,
        uint _usdcToBuyEth,
        uint _ethType,
        bool _onlyWithProfit
    ) public payable {

        address dfTokenizedStrategy = address(
            (new DfTokenizedStrategy)
            .value(msg.value)
            (
                _tokenName,
                _tokenSymbol,
                msg.sender,     // issuer
                _extraCoef,
                _profitPercent,
                _exchangeData,
                _usdcToBuyEth,
                _ethType,
                _onlyWithProfit
            )
        );

        emit TokenizedStrategyCreated(dfTokenizedStrategy);
    }

}
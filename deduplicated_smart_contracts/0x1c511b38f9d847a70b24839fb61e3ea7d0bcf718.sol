/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/utils/Address.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

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

// File: contracts/Interfaces/Uniswap.sol

pragma solidity ^0.5.0;

interface IUniswapFactoryInterface {
  // Public Variables
  // address public exchangeTemplate;
  // uint256 public tokenCount;
  // Create Exchange
  function createExchange(address token) external returns (address exchange);
  // Get Exchange and Token Info
  function getExchange(address token) external view returns (IUniswapExchangeInterface exchange);
  function getToken(address exchange) external view returns (address token);
  function getTokenWithId(uint256 tokenId) external view returns (address token);
  // Never use
  function initializeFactory(address template) external;
}

contract IUniswapExchangeInterface {
  // Address of ERC20 token sold on this exchange
  function tokenAddress() external view returns (address token);
  // Address of Uniswap Factory
  function factoryAddress() external view returns (address factory);
  // Provide Liquidity
  function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
  // Get Prices
  function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
  function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
  function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
  // Trade ETH to ERC20
  function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
  function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
  function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
  function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
  // Trade ERC20 to ETH
  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
  function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
  function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
  function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
  // Trade ERC20 to ERC20
  function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
  function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
  function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
  function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
  // Trade ERC20 to Custom Pool
  function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
  function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
  function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
  function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
  // ERC20 comaptibility for liquidity tokens
//  bytes32 public name;
//  bytes32 public symbol;
//  uint256 public decimals;
//  function transfer(address _to, uint256 _value) external returns (bool);
//  function transferFrom(address _from, address _to, uint256 value) external returns (bool);
//  function approve(address _spender, uint256 _value) external returns (bool);
//  function allowance(address _owner, address _spender) external view returns (uint256);
//  function balanceOf(address _owner) external view returns (uint256);
//  function totalSupply() external view returns (uint256);
//  // Never use
//  function setup(address token_addr) external;
}

// File: openzeppelin-solidity/contracts/GSN/Context.sol

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

// File: openzeppelin-solidity/contracts/Ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Utils/Destructible.sol

pragma solidity >=0.5.0;


/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(address(bytes20(owner())));
  }

  function destroyAndSend(address payable _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

// File: contracts/Utils/Pausable.sol

pragma solidity >=0.4.24;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused, "The contract is paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "The contract is not paused");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: contracts/Utils/Withdrawable.sol

pragma solidity >=0.4.24;




contract Withdrawable is Ownable {
  using SafeERC20 for ERC20;
  address constant ETHER = address(0);

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );

  /**
   * @dev Withdraw asset.
   * @param _tokenAddress Asset to be withdrawed.
   * @return bool.
   */
  function withdrawToken(address _tokenAddress) public onlyOwner {
    uint tokenBalance;
    if (_tokenAddress == ETHER) {
      address self = address(this); // workaround for a possible solidity bug
      tokenBalance = self.balance;
      msg.sender.transfer(tokenBalance);
    } else {
      tokenBalance = ERC20(_tokenAddress).balanceOf(address(this));
      ERC20(_tokenAddress).safeTransfer(msg.sender, tokenBalance);
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, tokenBalance);
  }

}

// File: contracts/Utils/WithFee.sol

pragma solidity ^0.5.0;





contract WithFee is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint;
  address payable public feeWallet;
  uint public storedSpread;
  uint constant spreadDecimals = 6;
  uint constant spreadUnit = 10 ** spreadDecimals;

  event LogFee(address token, uint amount);

  constructor(address payable _wallet, uint _spread) public {
    require(_wallet != address(0), "_wallet == address(0)");
    require(_spread < spreadUnit, "spread >= spreadUnit");
    feeWallet = _wallet;
    storedSpread = _spread;
  }

  function setFeeWallet(address payable _wallet) external onlyOwner {
    require(_wallet != address(0), "_wallet == address(0)");
    feeWallet = _wallet;
  }

  function setSpread(uint _spread) external onlyOwner {
    storedSpread = _spread;
  }

  function _getFee(uint underlyingTokenTotal) internal view returns(uint) {
    return underlyingTokenTotal.mul(storedSpread).div(spreadUnit);
  }

  function _payFee(address feeToken, uint fee) internal {
    if (fee > 0) {
      if (feeToken == address(0)) {
        feeWallet.transfer(fee);
      } else {
        IERC20(feeToken).safeTransfer(feeWallet, fee);
      }
      emit LogFee(feeToken, fee);
    }
  }

}

// File: contracts/Interfaces/IErc20Swap.sol

pragma solidity >=0.4.0;

interface IErc20Swap {
    function getRate(address src, address dst, uint256 srcAmount) external view returns(uint expectedRate, uint slippageRate);  // real rate = returned value / 1e18
    function swap(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) external payable;

    event LogTokenSwap(
        address indexed _userAddress,
        address indexed _userSentTokenAddress,
        uint _userSentTokenAmount,
        address indexed _userReceivedTokenAddress,
        uint _userReceivedTokenAmount
    );
}

// File: contracts/base/NetworkBasedTokenSwap.sol

pragma solidity >=0.5.0;









contract NetworkBasedTokenSwap is Withdrawable, Pausable, Destructible, WithFee, IErc20Swap
{
  using SafeMath for uint;
  using SafeERC20 for IERC20;
  address constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  mapping (address => mapping (address => uint)) spreadCustom;

  event UnexpectedIntialBalance(address token, uint amount);

  constructor(
    address payable _wallet,
    uint _spread
  )
    public WithFee(_wallet, _spread)
  {}

  function() external payable {
    // can receive ethers
  }

  // spread value >= spreadUnit means no fee
  function setSpread(address tokenA, address tokenB, uint spread) public onlyOwner {
    uint value = spread > spreadUnit ? spreadUnit : spread;
    spreadCustom[tokenA][tokenB] = value;
    spreadCustom[tokenB][tokenA] = value;
  }

  function getSpread(address tokenA, address tokenB) public view returns(uint) {
    uint value = spreadCustom[tokenA][tokenB];
    if (value == 0) return storedSpread;
    if (value >= spreadUnit) return 0;
    else return value;
  }

  // kyber network style rate
  function getNetworkRate(address src, address dest, uint256 srcAmount) internal view returns(uint expectedRate, uint slippageRate);

  function getRate(address src, address dest, uint256 srcAmount) external view
    returns(uint expectedRate, uint slippageRate)
  {
    (uint256 kExpected, uint256 kSplippage) = getNetworkRate(src, dest, srcAmount);
    uint256 spread = getSpread(src, dest);
    expectedRate = kExpected.mul(spreadUnit - spread).div(spreadUnit);
    slippageRate = kSplippage.mul(spreadUnit - spread).div(spreadUnit);
  }

  function _freeUnexpectedTokens(address token) private {
    uint256 unexpectedBalance = token == ETHER
      ? _myEthBalance().sub(msg.value)
      : IERC20(token).balanceOf(address(this));
    if (unexpectedBalance > 0) {
      _transfer(token, address(bytes20(owner())), unexpectedBalance);
      emit UnexpectedIntialBalance(token, unexpectedBalance);
    }
  }

  function swap(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) public payable {
    require(src != dest, "src == dest");
    require(srcAmount > 0, "srcAmount == 0");

    // empty unexpected initial balances
    _freeUnexpectedTokens(src);
    _freeUnexpectedTokens(dest);

    if (src == ETHER) {
      require(msg.value == srcAmount, "msg.value != srcAmount");
    } else {
      require(
        IERC20(src).allowance(msg.sender, address(this)) >= srcAmount,
        "ERC20 allowance < srcAmount"
      );
      // get user's tokens
      IERC20(src).safeTransferFrom(msg.sender, address(this), srcAmount);
    }

    uint256 spread = getSpread(src, dest);

    // calculate the minConversionRate and maxDestAmount keeping in mind the fee
    uint256 adaptedMinRate = minConversionRate.mul(spreadUnit).div(spreadUnit - spread);
    uint256 adaptedMaxDestAmount = maxDestAmount.mul(spreadUnit).div(spreadUnit - spread);
    uint256 destTradedAmount = doNetworkTrade(src, srcAmount, dest, adaptedMaxDestAmount, adaptedMinRate);

    uint256 notTraded = _myBalance(src);
    uint256 srcTradedAmount = srcAmount.sub(notTraded);
    require(srcTradedAmount > 0, "no traded tokens");
    require(
      _myBalance(dest) >= destTradedAmount,
      "No enough dest tokens after trade"
    );
    // pay fee and user
    uint256 toUserAmount = _payFee(dest, destTradedAmount, spread);
    _transfer(dest, msg.sender, toUserAmount);
    // returns not traded tokens if any
    if (notTraded > 0) {
      _transfer(src, msg.sender, notTraded);
    }

    emit LogTokenSwap(
      msg.sender,
      src,
      srcTradedAmount,
      dest,
      toUserAmount
    );
  }

  function doNetworkTrade(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) internal returns(uint256);

  function _payFee(address token, uint destTradedAmount, uint spread) private returns(uint256 toUserAmount) {
    uint256 fee = destTradedAmount.mul(spread).div(spreadUnit);
    toUserAmount = destTradedAmount.sub(fee);
    // pay fee
    super._payFee(token == ETHER ? address(0) : token, fee);
  }

  // workaround for a solidity bug
  function _myEthBalance() private view returns(uint256) {
    address self = address(this);
    return self.balance;
  }

  function _myBalance(address token) private view returns(uint256) {
    return token == ETHER
      ? _myEthBalance()
      : IERC20(token).balanceOf(address(this));
  }

  function _transfer(address token, address payable recipient, uint256 amount) private {
    if (token == ETHER) {
      recipient.transfer(amount);
    } else {
      IERC20(token).safeTransfer(recipient, amount);
    }
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
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
}

// File: contracts/Utils/LowLevel.sol

pragma solidity ^0.5.0;

library LowLevel {
  function callContractAddr(address target, bytes memory payload) internal view
    returns (bool success_, address result_)
  {
    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      assembly {
        result_ := mload(add(result,32))
      }
      success_ = true;
    }
  }

  function callContractUint(address target, bytes memory payload) internal view
    returns (bool success_, uint result_)
  {
    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      assembly {
        result_ := mload(add(result,32))
      }
      success_ = true;
    }
  }
}

// File: contracts/Utils/RateNormalization.sol

pragma solidity ^0.5.0;





contract RateNormalization is Ownable {
  using SafeMath for uint;

  struct RateAdjustment {
    uint factor;
    bool multiply;
  }

  mapping (address => mapping(address => RateAdjustment)) public rateAdjustment;
  mapping (address => uint) public forcedDecimals;

  // return normalized rate
  function normalizeRate(address src, address dest, uint256 rate) public view
    returns(uint)
  {
    RateAdjustment memory adj = rateAdjustment[src][dest];
    if (adj.factor == 0) {
      uint srcDecimals = _getDecimals(src);
      uint destDecimals = _getDecimals(dest);
      if (srcDecimals != destDecimals) {
        if (srcDecimals > destDecimals) {
          adj.multiply = true;
          adj.factor = 10 ** (srcDecimals - destDecimals);
        } else {
          adj.multiply = false;
          adj.factor = 10 ** (destDecimals - srcDecimals);
        }
      }
    }
    if (adj.factor > 1) {
      rate = adj.multiply
      ? rate.mul(adj.factor)
      : rate.div(adj.factor);
    }
    return rate;
  }

  function _getDecimals(address token) internal view returns(uint) {
    uint forced = forcedDecimals[token];
    if (forced > 0) return forced;
    bytes memory payload = abi.encodeWithSignature("decimals()");
    (bool success, uint decimals) = LowLevel.callContractUint(token, payload);
    require(success, "the token doesn't expose the decimals number");
    return decimals;
  }

  function setRateAdjustmentFactor(address src, address dest, uint factor, bool multiply) public onlyOwner {
    rateAdjustment[src][dest] = RateAdjustment(factor, multiply);
    rateAdjustment[dest][src] = RateAdjustment(factor, !multiply);
  }

  function setForcedDecimals(address token, uint decimals) public onlyOwner {
    forcedDecimals[token] = decimals;
  }

}

// File: contracts/UniswapTokenSwap.sol

pragma solidity >=0.5.0;







contract UniswapTokenSwap is RateNormalization, NetworkBasedTokenSwap
{
  using SafeMath for uint;
  using SafeERC20 for IERC20;
  uint constant expScale = 1e18;

  IUniswapFactoryInterface public uniswapFactory;

  mapping (address => address) public exchangeAddressCustom;

  constructor(
    address _uniswapFactory,
    address payable _wallet,
    uint _spread
  )
    public NetworkBasedTokenSwap(_wallet, _spread)
  {
    setForcedDecimals(ETHER, 18);
    setUniswap(_uniswapFactory);
  }

  function setUniswap(address _uniswapFactory) public onlyOwner {
    require(_uniswapFactory != address(0), "_uniswapFactory == address(0)");
    uniswapFactory = IUniswapFactoryInterface(_uniswapFactory);
  }

  function setExchangeCustom(address token, address exchange) public onlyOwner {
    require(token != address(0), "exchange == address(0)");
    exchangeAddressCustom[token] = exchange;
  }

  function _getExchange(address token) private view returns(IUniswapExchangeInterface exchange) {
    address exchangeAddress = exchangeAddressCustom[token];
    exchange = exchangeAddress == address(0) ?
      uniswapFactory.getExchange(token) : IUniswapExchangeInterface(exchangeAddress);
  }

  function _getUniswapRate(address src, address dest, uint srcAmount) private view returns(uint rate, uint destAmount) {
    uint inputAmountB;
    if (src != ETHER) {
      IUniswapExchangeInterface exchangeA = _getExchange(src);
      inputAmountB = exchangeA.getTokenToEthInputPrice(srcAmount);
    } else {
      inputAmountB = srcAmount;
    }
    if (dest != ETHER) {
      IUniswapExchangeInterface exchangeB = _getExchange(dest);
      destAmount = exchangeB.getEthToTokenInputPrice(inputAmountB);
    } else {
      destAmount = inputAmountB;
    }
    rate = destAmount.mul(expScale).div(srcAmount);
  }

  function _calcRate(uint srcAmount, uint destAmount) private pure returns(uint) {
    return destAmount.mul(expScale).div(srcAmount);
  }

  function getNetworkRate(address src, address dest, uint256 srcAmount) internal view
    returns(uint expectedRate, uint slippageRate)
  {
    (uint rate, ) = _getUniswapRate(src, dest, srcAmount);
    uint normalizedRate = normalizeRate(src, dest, rate);
    return (normalizedRate, normalizedRate);
  }

  function _approveWithReset(address token, address spender, uint amount) private {
    if (IERC20(token).allowance(address(this), spender) > 0) {
      IERC20(token).safeApprove(spender, 0);
    }
    IERC20(token).safeApprove(spender, amount);
  }

  function doNetworkTrade(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate)
    internal returns(uint256)
  {
    (uint rate, uint destAmount) = _getUniswapRate(src, dest, srcAmount);
    uint toTradeAmount = destAmount > maxDestAmount
      ? maxDestAmount.mul(expScale).div(rate)
      : srcAmount;

    uint tradedEthers;
    if (src != ETHER) {
      IUniswapExchangeInterface exchangeA = _getExchange(src);
      _approveWithReset(src, address(exchangeA), toTradeAmount);
      tradedEthers = exchangeA.tokenToEthSwapInput(toTradeAmount, 1, block.timestamp);
    } else {
      tradedEthers = toTradeAmount;
    }

    uint finalDestAmount;
    if (dest != ETHER) {
      IUniswapExchangeInterface exchangeB = _getExchange(dest);
      finalDestAmount = exchangeB.ethToTokenSwapInput.value(tradedEthers)(1, block.timestamp);
    } else {
      finalDestAmount = tradedEthers;
    }
    require(normalizeRate(src, dest, _calcRate(toTradeAmount, finalDestAmount)) >= minConversionRate, "cannot satisfy minConversionRate");
    return finalDestAmount;
  }

}
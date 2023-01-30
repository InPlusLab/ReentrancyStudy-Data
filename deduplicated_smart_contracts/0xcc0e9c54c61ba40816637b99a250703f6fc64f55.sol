/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// File: localhost/contracts/interfaces/IWETH.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}
// File: localhost/contracts/access/Context.sol


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
// File: localhost/contracts/access/Ownable.sol


pragma solidity ^0.6.0;

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
    function initialize() public {
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
// File: localhost/contracts/interfaces/IERC20.sol


pragma solidity ^0.6.0;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: localhost/contracts/utils/SafeERC20.sol


// File: browser/github/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol



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
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
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

// File: browser/github/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol

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


// File: browser/github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol


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

// File: localhost/contracts/XTrinity.sol


pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;




library UniswapV2ExchangeLib {
    //using Math for uint256;
    using SafeMath for uint256;
    //using UniversalERC20 for IERC20;
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getReturn(
        IUniswapV2Exchange exchange,
        IERC20 fromToken,
        IERC20 destToken,
        uint amountIn
    ) internal view returns (uint256 result, bool needSync, bool needSkim) {
        uint256 reserveIn = fromToken.balanceOf(address(exchange));
        uint256 reserveOut = destToken.balanceOf(address(exchange));
        (uint112 reserve0, uint112 reserve1,) = exchange.getReserves();
        if (fromToken > destToken) {
            (reserve0, reserve1) = (reserve1, reserve0);
        }
        needSync = (reserveIn < reserve0 || reserveOut < reserve1);
        needSkim = !needSync && (reserveIn > reserve0 || reserveOut > reserve1);

        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(min(reserveOut, reserve1));
        uint256 denominator = min(reserveIn, reserve0).mul(1000).add(amountInWithFee);
        result = (denominator == 0) ? 0 : numerator.div(denominator);
    }
}

interface IUniswapV2Factory {
    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Exchange pair);
}

interface IUniswapV2Exchange {
    function getReserves() external view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IMooniswap {
    function fee() external view returns (uint256);

    function tokens(uint256 i) external view returns (IERC20);

    function deposit(uint256[] calldata amounts, uint256[] calldata minAmounts) external payable returns(uint256 fairSupply);

    function withdraw(uint256 amount, uint256[] calldata minReturns) external;

    function getBalanceForAddition(IERC20 token) external view returns(uint256);

    function getBalanceForRemoval(IERC20 token) external view returns(uint256);

    function getReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    )
        external
        view
        returns(uint256 returnAmount);

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        address referral
    )
        external
        payable
        returns(uint256 returnAmount);
}

interface IMooniswapRegistry {
    function pools(IERC20 token1, IERC20 token2) external view returns(IMooniswap);
    function isPool(address addr) external view returns(bool);
}

contract XTrinity is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;
    
    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 private constant WETH_ADDRESS = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    address constant UNI_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address constant MOONI_FACTORY = 0x71CD6666064C3A1354a3B4dca5fA1E2D3ee7D303;
    
    address constant BONUS_ADDRESS = 0x8c545be506a335e24145EdD6e01D2754296ff018;
    IUniswapV2Factory constant internal uniV2 = IUniswapV2Factory(UNI_FACTORY);
    IUniswapV2Factory constant internal sushi = IUniswapV2Factory(SUSHI_FACTORY);
    IMooniswapRegistry constant internal mooni = IMooniswapRegistry(MOONI_FACTORY);
    IWETH constant internal weth = IWETH(address(WETH_ADDRESS));
    
    //uint private constant fee = 3000000000000000;
    //uint private constant FEE_DENOMINATOR = 1e18;
    uint private constant PC_DENOMINATOR = 1e5;
    address[] private exchanges = [UNI_FACTORY, SUSHI_FACTORY, MOONI_FACTORY];
    uint private constant ex_count = 3;
    
    //IWETH(WETH_ADDRESS).deposit{value: msg.value}();
    //IWETH(WETH_ADDRESS).withdraw(returnAmount);
    //IERC20 private constant WETH_ADDRESS = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    
    
    bool private initialized;
    
    function init() virtual public {
        require(!initialized, "Is already been initialized");
        _init();
    }
    
    function _init() internal {
        initialized = true;
        //exchange = Exchange.ONESPLIT;
        Ownable.initialize(); // Do not forget this call!
    }    
    
    function reInit() virtual public onlyOwner {
        _init();
    }
    
    function isETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS));
    }
    
    function isWETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(WETH_ADDRESS));
    }
    
    /*
    function _getReturn(uint256 amount, uint256 srcBalance, uint256 dstBalance) internal view returns(uint256) {
        uint256 taxedAmount = amount.sub(amount.mul(fee).div(FEE_DENOMINATOR));
        return taxedAmount.mul(dstBalance).div(srcBalance.add(taxedAmount));
    }*/
    
    //Uni + Sushi
    
    /*
    function getUniReserves(IUniswapV2Factory factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        IUniswapV2Exchange pair = uniFactory.getPair(_from, _to);
        (uint reserve0, uint reserve1,) = IUniswapV2Exchange(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    
    // calculates the CREATE2 address for a pair without making any external calls
    
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }*/
    
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    
    function getReserves(IERC20 fromToken, IERC20 toToken, address factory) public view returns(uint reserveA, uint reserveB) {
        if (factory != MOONI_FACTORY) {
            //UNI
            IUniswapV2Factory uniFactory = IUniswapV2Factory(factory);
            IERC20 _from = isETH(fromToken) ? WETH_ADDRESS : fromToken;
            IERC20 _to = isETH(toToken) ? WETH_ADDRESS : toToken;
            
            IUniswapV2Exchange pair = uniFactory.getPair(_from, _to);
            
            if (address(pair) != address(0)) {
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                
                (address token0,) = sortTokens(address(fromToken), address(toToken));
                (reserveA, reserveB) = address(fromToken) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                }
        } else {
            // MOONI
            IERC20 _from = isWETH(fromToken) ? ZERO_ADDRESS : fromToken;
            IERC20 _to = isWETH(toToken) ? ZERO_ADDRESS : toToken;
        
            IMooniswap pair = mooni.pools(_from, _to);
        
            if (address(pair) != address(0)) {
                uint reserve0 = pair.getBalanceForAddition(_from);
                uint reserve1 = pair.getBalanceForRemoval(_to);
                (reserveA, reserveB) = (reserve0, reserve1);
                }
            }   
        }
        
    /*
    function getMooniReserves(IERC20 fromToken, IERC20 toToken) public view returns(uint256, uint256) {
        uint256 fromBalance;
        uint256 destBalance;
        
        //UNI
        IERC20 _from = isWETH(fromToken) ? ZERO_ADDRESS : fromToken;
        IERC20 _to = isWETH(toToken) ? ZERO_ADDRESS : toToken;
        
        IMooniswap pair = mooni.pools(_from, _to);
        
        if (address(pair) != address(0)) {
            fromBalance = pair.getBalanceForAddition(_from);
            destBalance = pair.getBalanceForRemoval(_to);
        }
        
        return (fromBalance, destBalance);
    }*/
    
    function getFullReserves (IERC20 fromToken, IERC20 toToken) public view returns 
    (uint fromTotal, uint destTotal, uint[ex_count] memory dist, uint[ex_count][2] memory res) {
        uint fromBalance; //optional
        uint destBalance; //optional
        //uint mulReserve;
        uint fullTotal;
        
        //uint [ex_count][2] memory res;
        
        for (uint i = 0; i < ex_count; i++) {
            (uint balance0, uint balance1) = getReserves(fromToken, toToken, exchanges[i]);
            fromBalance += balance0;
            destBalance += balance1;
            fullTotal += balance0.add(balance1);
            (res[i][0], res[i][1]) = (balance0, balance1);
        }
        
        //optional
        (fromTotal, destTotal) = (fromBalance, destBalance);
        
        //uint fullTotal = fromTotal.add(destTotal);
        //uint256[ex_count] memory dist;// = new uint256[](ex_count);
        
        for (uint i = 0; i < ex_count; i++) {
            dist[i] = (res[i][0].add(res[i][1])).mul(PC_DENOMINATOR).div(fullTotal);
        }
        
        //distribution = dist;
        //reserves = res;
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
    
    function quote(IERC20 fromToken, IERC20 toToken, uint amount, uint minPc) public view returns (uint returnAmount, uint[ex_count] memory swapAmounts) {
        (,, uint[ex_count] memory distribution, uint[ex_count][2] memory reserves) 
        = getFullReserves (fromToken, toToken);
        
        uint lastNonZeroIndex = ex_count;
        for (uint i = distribution.length-1; i >= 0; i--) {
            if (distribution[i] > minPc) {
                //parts = parts.add(distribution[i]);
                lastNonZeroIndex = i;
                break;
            }
        }
        
        uint remainingAmount = amount;
        uint addDistribution;
        
        for (uint i = 0; i < distribution.length; i++) {
            
            if (distribution[i] <= minPc) {
                addDistribution += distribution[i];
                continue;
            }
            uint swapAmount = amount.mul(distribution[i].add(addDistribution.div(distribution.length-i))).div(PC_DENOMINATOR);
            if (i == lastNonZeroIndex) {
                swapAmount = remainingAmount;
                swapAmounts[i] = swapAmount;
            }
            returnAmount += getAmountOut(swapAmount, reserves[i][0], reserves[i][1]);
            remainingAmount -= swapAmount;
        }
    }
    
    function swap (IERC20 fromToken, IERC20 toToken, uint amount, uint minPc) external returns (uint returnAmount) {
        //uint[ex_count] memory swapAmounts1;

        bool changed = false;
        (uint returnDirect, uint[ex_count] memory swapAmounts1) = quote(fromToken, toToken, amount, minPc);
        if (toToken != WETH_ADDRESS) {
            (uint returnAmountETH, uint[ex_count] memory swapAmounts2) = quote(fromToken, WETH_ADDRESS, amount, minPc);
            (uint returnAmountVia, uint[ex_count] memory swapAmounts3) = quote(WETH_ADDRESS, toToken, returnAmountETH, minPc);
            if (returnAmountVia > returnDirect) {
                for (uint i = 0; i < swapAmounts2.length; i++) {
                if (swapAmounts1[i] > 0) {
                    if (exchanges[i] != MOONI_FACTORY) {
                        _swapOnUniswapV2Internal(fromToken, WETH_ADDRESS, swapAmounts2[i]);
                        } else {
                        _swapOnMooniswap(fromToken, WETH_ADDRESS, swapAmounts2[i]);
                        }
                    }
                }
                for (uint i = 0; i < swapAmounts3.length; i++) {
                if (swapAmounts1[i] > 0) {
                    if (exchanges[i] != MOONI_FACTORY) {
                        _swapOnUniswapV2Internal(WETH_ADDRESS, toToken, swapAmounts3[i]);
                        } else {
                        _swapOnMooniswap(WETH_ADDRESS, toToken, swapAmounts3[i]);
                        }
                    }
                }    
                changed = true;
            }
        } 
        
        if (!changed) {
            for (uint i = 0; i < swapAmounts1.length; i++) {
            if (swapAmounts1[i] > 0) {
                if (exchanges[i] != MOONI_FACTORY) {
                    _swapOnUniswapV2Internal(fromToken, toToken, swapAmounts1[i]);
                    } else {
                    _swapOnMooniswap(fromToken, toToken, swapAmounts1[i]);
                    }
                }
            }
        }
        
        returnAmount = toToken.balanceOf(address(this));
    }
    
    // to withdraw token from the contract
    function transferTokenBack(address TokenAddress)
        external
        onlyOwner
        returns (uint256)
    {
        IERC20 Token = IERC20(TokenAddress);
        uint balance = Token.balanceOf(address(this));
        if (balance > 0) {
            Token.safeTransfer(msg.sender, balance);
        }

        uint ETHbalance = address(this).balance;
        if (ETHbalance > 0) {
            msg.sender.transfer(ETHbalance);
        }

        return balance;
    }
    
    function _swapOnMooniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
         /*flags*/
    ) internal {
        IMooniswap mooniswap = mooni.pools(
            isWETH(fromToken) ? ZERO_ADDRESS : fromToken,
            isWETH(destToken) ? ZERO_ADDRESS : destToken
        );
        
        if (isWETH(fromToken)) {
            fromToken = ZERO_ADDRESS;
            weth.withdraw(amount);
        } else {
            if (fromToken.allowance(address(this), address(mooniswap)) != uint256(-1)) {
                fromToken.safeApprove(address(mooniswap), uint256(-1));
            }
        }
        
        mooniswap.swap{value: fromToken==ZERO_ADDRESS ? amount : 0}(fromToken,
            isWETH(destToken) ? ZERO_ADDRESS : destToken,
            amount,
            0,
            BONUS_ADDRESS
        );
        
        if (isWETH(destToken)) {
            weth.deposit{value: address(this).balance}();
        }
    }
    
    function _swapOnUniswapV2Internal(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) internal returns(uint256 returnAmount) {
        if (isETH(fromToken)) {
            weth.deposit{value: amount}();
            fromToken = WETH_ADDRESS;
        }

        //IERC20 fromTokenReal = isETH() ? weth : fromToken;
        destToken = isETH(destToken) ? WETH_ADDRESS : destToken;
        IUniswapV2Exchange exchange = uniV2.getPair(fromToken, destToken);
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = exchange.getReturn(fromToken, destToken, amount);
        if (needSync) {
            exchange.sync();
        }
        else if (needSkim) {
            exchange.skim(BONUS_ADDRESS);
        }

        fromToken.safeTransfer(address(exchange), amount);
        if (uint(address(fromToken)) < uint(address(destToken))) {
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (destToken == WETH_ADDRESS) {
            weth.withdraw(WETH_ADDRESS.balanceOf(address(this)));
        }
    }
}
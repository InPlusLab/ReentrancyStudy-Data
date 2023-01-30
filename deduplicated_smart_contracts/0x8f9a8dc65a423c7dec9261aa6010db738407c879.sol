/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

// SPDX-License-Identifier: MIT

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

    /**
     * @dev Timelock execute transaction of the contract.
     * Can only be called by the current owner.
     */
    function executeTransaction(address target, bytes memory data) public payable onlyOwner returns (bytes memory) {
        (bool success, bytes memory returnData) = target.call{value:msg.value}(data);

        // solium-disable-next-line security/no-call-value
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        return returnData;
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IFarmToken {
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

    function mint(address _to, uint256 _amount) external;

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

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity 0.6.12;


interface IMigratorFarm {
    // Perform LP token migration from legacy UniswapV2 to FarmSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to UniswapV2 LP tokens.
    // FarmSwap must mint EXACTLY the same amount of FarmSwap LP tokens or
    // else something bad will happen. Traditional UniswapV2 does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}

// Farm is the master of FarmToken. He can make FarmToken and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once the FarmToken is
// sufficiently distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract PumpFarm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 unlockDate; // Unlock date.
        uint256 liqAmount;  // ETH/Single token split, swap and addLiq.
        //
        // We do some fancy math here. Basically, any point in time, the amount of FarmTokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accFarmTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accFarmTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;               // Address of LP token contract.
        uint256 allocPoint;           // How many allocation points assigned to this pool. FarmTokens to distribute per block.
        uint256 lockSec;              // Lock seconds, 0 means no lock.
        uint256 pumpRatio;            // Pump ratio, 0 means no ratio. 5 means 0.5%
        uint256 tokenType;            // Pool type, 0 - Token/ETH(default), 1 - Single Token(include ETH), 2 - Uni/LP
        uint256 lpAmount;             // Lp amount
        uint256 tmpAmount;            // ETH/Token convert to uniswap liq amount, remove latter.
        uint256 lastRewardBlock;      // Last block number that FarmTokens distribution occurs.
        uint256 accFarmTokenPerShare; // Accumulated FarmTokens per share, times 1e12. See below.
    }
    
    // ===========================================================================================
    // Pump
    address public pairaddr;
    
    // mainnet
    address public constant WETHADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant UNIV2ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    // Pump End
    // ===========================================================================================

    // The FarmToken.
    IFarmToken public farmToken;
    // FarmTokens created per block.
    uint256 public farmTokenPerBlock;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorFarm public migrator;
    
    // Farm
    uint256 public blocksPerHalvingCycle;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when FarmToken mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 pumpAmount, uint256 liquidity);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 pumpAmount, uint256 liquidity);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IFarmToken _farmToken,
        uint256 _farmTokenPerBlock,
        uint256 _startBlock,
        uint256 _blocksPerHalvingCycle
    ) public {
        farmToken = _farmToken;
        farmTokenPerBlock = _farmTokenPerBlock;
        startBlock = _startBlock;
        blocksPerHalvingCycle = _blocksPerHalvingCycle;
    }

    receive() external payable {
        assert(msg.sender == WETHADDR); // only accept ETH via fallback from the WETH contract
    }

    function setPair(address _pairaddr) public onlyOwner {
        pairaddr = _pairaddr;

        // trust UNISWAP approve max.
        IERC20(pairaddr).safeApprove(UNIV2ROUTER2, 0);
        IERC20(pairaddr).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, 0);
        IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, uint(-1));
        IERC20(address(farmToken)).safeApprove(UNIV2ROUTER2, 0);
        IERC20(address(farmToken)).safeApprove(UNIV2ROUTER2, uint(-1));
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _lockSec, uint256 _pumpRatio, uint256 _type) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lockSec: _lockSec,
            pumpRatio: _pumpRatio,
            tokenType: _type,
            lpAmount: 0,
            tmpAmount: 0,
            lastRewardBlock: lastRewardBlock,
            accFarmTokenPerShare: 0
        }));
        // trust UNISWAP approve max.
        _lpToken.safeApprove(UNIV2ROUTER2, 0);
        _lpToken.safeApprove(UNIV2ROUTER2, uint(-1));

        if (_type == 2) {
            address token0 = IUniswapV2Pair(address(_lpToken)).token0();
            address token1 = IUniswapV2Pair(address(_lpToken)).token1();
            // need to approve token0 and token1 for UNISWAP, in
            IERC20(token0).safeApprove(UNIV2ROUTER2, 0);
            IERC20(token0).safeApprove(UNIV2ROUTER2, uint(-1));
            IERC20(token1).safeApprove(UNIV2ROUTER2, 0);
            IERC20(token1).safeApprove(UNIV2ROUTER2, uint(-1));
        }
    }

    // Update the given pool's FarmToken allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate, uint256 _lockSec, uint256 _pumpRatio) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lockSec = _lockSec;
        poolInfo[_pid].pumpRatio = _pumpRatio;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorFarm _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }
    
    // need test
    function getMultiplier(uint256 _to) public view returns (uint256) {
        uint256 blockCount = _to.sub(startBlock);
        uint256 weekCount = blockCount.div(blocksPerHalvingCycle);
        uint256 multiplierPart1 = 0;
        uint256 multiplierPart2 = 0;
        uint256 divisor = 1;
        
        for (uint256 i = 0; i < weekCount; ++i) {
            multiplierPart1 = multiplierPart1.add(blocksPerHalvingCycle.div(divisor));
            divisor = divisor.mul(2);
        }
        
        multiplierPart2 = blockCount.mod(blocksPerHalvingCycle).div(divisor);
        
        return multiplierPart1.add(multiplierPart2);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= _from) {
            return 0;
        }
        return getMultiplier(_to).sub(getMultiplier(_from));
    }

    // View function to see pending FarmTokens on frontend.
    function pendingFarmToken(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accFarmTokenPerShare = pool.accFarmTokenPerShare;
        //uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 lpSupply = pool.lpAmount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 farmTokenReward = multiplier.mul(farmTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accFarmTokenPerShare = accFarmTokenPerShare.add(farmTokenReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 farmTokenReward = multiplier.mul(farmTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        farmToken.mint(address(this), farmTokenReward);
        pool.accFarmTokenPerShare = pool.accFarmTokenPerShare.add(farmTokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to Farm for FarmToken allocation.
    function deposit(uint256 _pid, uint256 _amount) public payable {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pumpAmount;
        uint256 liquidity;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeFarmTokenTransfer(msg.sender, pending);
            }
        }
        if (msg.value > 0) {
		    IWETH(WETHADDR).deposit{value: msg.value}();
		    _amount = msg.value;
        } else if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        }
        if(_amount > 0) {
            // _amount == 0 or pumpRatio == 0
            pumpAmount = _amount.mul(pool.pumpRatio).div(1000);
            if (pool.tokenType == 0 && pumpAmount > 0) {
                pump(pumpAmount);
            } else if (pool.tokenType == 1) {
                // use the actually pumpAmount
                liquidity = investTokenToLp(pool.lpToken, _amount, pool.pumpRatio);
                user.liqAmount = user.liqAmount.add(liquidity);
            } else if (pool.tokenType == 2) {
                pumpLp(pool.lpToken, pumpAmount);
            }
            _amount = _amount.sub(pumpAmount);
            if (pool.tokenType == 1) {
                pool.tmpAmount = pool.tmpAmount.add(liquidity);
            }
            pool.lpAmount = pool.lpAmount.add(_amount);
            // once pumpRatio == 0, single token/eth should addLiq
            user.amount = user.amount.add(_amount);
            user.unlockDate = block.timestamp.add(pool.lockSec);
        }
        user.rewardDebt = user.amount.mul(pool.accFarmTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, pumpAmount, liquidity);
    }
    
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function _swapExactTokensForTokens(address fromToken, address toToken, uint256 fromAmount) internal returns (uint256) {
        if (fromToken == toToken || fromAmount == 0) return fromAmount;
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;
        uint[] memory amount = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                      fromAmount, 0, path, address(this), now.add(60));
        return amount[amount.length - 1];
    }

    function investTokenToLp(IERC20 lpToken, uint256 _amount, uint256 _pumpRatio) internal returns (uint256 liq) {
        // ETH, ETH/2->buy FarmToken, FarmTokenAmount
        if (_amount == 0) return 0;

        if (address(lpToken) != WETHADDR) {
            // IERC20(lpToken).safeApprove(UNIV2ROUTER2, 0);
            // IERC20(lpToken).safeApprove(UNIV2ROUTER2, _amount);
            _amount = _swapExactTokensForTokens(address(lpToken), WETHADDR, _amount);
        }
        uint256 amountEth = _amount.sub(_amount.mul(_pumpRatio).div(1000)).div(2);
        uint256 amountBuy = _amount.sub(amountEth);

        address[] memory path = new address[](2);
        path[0] = WETHADDR;
        path[1] = address(farmToken);
        // buy token use another half amount.
        uint256[] memory amounts = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                  amountBuy, 0, path, address(this), now.add(60));
        uint256 amountToken = amounts[1];

        // IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, 0);
        // IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, amountEth);
        // IERC20(farmToken).safeApprove(UNIV2ROUTER2, 0);
        // IERC20(farmToken).safeApprove(UNIV2ROUTER2, amountToken);
        uint256 amountEthReturn;
        (amountEthReturn,, liq) = IUniswapV2Router02(UNIV2ROUTER2).addLiquidity(
                WETHADDR, address(farmToken), amountEth, amountToken, 0, 0, address(this), now.add(60));

        if (amountEth > amountEthReturn) {
            // this is ETH left(hard to see). then swap all eth to token
            // IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, 0);
            // IERC20(WETHADDR).safeApprove(UNIV2ROUTER2, amountEth.sub(amountEthReturn));
            _swapExactTokensForTokens(WETHADDR, address(farmToken), amountEth.sub(amountEthReturn));
        }
    }

    function lpToInvestToken(IERC20 lpToken, uint256 _liquidity, uint256 _pumpRatio) internal returns (uint256 amountInvest){
        // removeLiq all
        if (_liquidity == 0) return 0;
        // IERC20(pairaddr).safeApprove(UNIV2ROUTER2, 0);
        // IERC20(pairaddr).safeApprove(UNIV2ROUTER2, IERC20(pairaddr).balanceOf(address(this)));
        (uint256 amountToken, uint256 amountEth) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            address(farmToken), WETHADDR, _liquidity, 0, 0, address(this), now.add(60));

        uint256 pumpAmount = amountToken.mul(_pumpRatio).mul(2).div(1000);
        amountEth = amountEth.add(_swapExactTokensForTokens(address(farmToken), WETHADDR, amountToken.sub(pumpAmount)));

        if (address(lpToken) == WETHADDR) {
            amountInvest = amountEth;
        } else {
            address[] memory path = new address[](2);
            path[0] = WETHADDR;
            path[1] = address(lpToken);
            // IERC20(farmToken).safeApprove(UNIV2ROUTER2, 0);
            // IERC20(farmToken).safeApprove(UNIV2ROUTER2, amountToken);
            uint256[] memory amounts = IUniswapV2Router02(UNIV2ROUTER2).swapExactTokensForTokens(
                  amountEth, 0, path, address(this), now.add(60));
            amountInvest = amounts[1];
        }
    }

    function _pumpLp(address token0, address token1, uint256 _amount) internal {
        if (_amount == 0) return;
        // IERC20(_lpToken).safeApprove(UNIV2ROUTER2, _amount);
        (uint256 amount0, uint256 amount1) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            token0, token1, _amount, 0, 0, address(this), now.add(60));
        amount0 = _swapExactTokensForTokens(token0, WETHADDR, amount0);
        amount1 = _swapExactTokensForTokens(token1, WETHADDR, amount1);
        _swapExactTokensForTokens(WETHADDR, address(farmToken), amount0.add(amount1));
    }

    function pump(uint256 _amount) internal {
        if (_amount == 0) return;
        // IERC20(_pairToken).safeApprove(UNIV2ROUTER2, _amount);
        (,uint256 amountEth) = IUniswapV2Router02(UNIV2ROUTER2).removeLiquidity(
            address(farmToken), WETHADDR, _amount, 0, 0, address(this), now.add(60));
        _swapExactTokensForTokens(WETHADDR, address(farmToken), amountEth);
    }

    function pumpLp(IERC20 _lpToken, uint256 _amount) internal {
        address token0 = IUniswapV2Pair(address(_lpToken)).token0();
        address token1 = IUniswapV2Pair(address(_lpToken)).token1();
        return _pumpLp(token0, token1, _amount);
    }
    
    function getWithdrawableBalance(uint256 _pid, address _user) public view returns (uint256) {
      UserInfo storage user = userInfo[_pid][_user];
      
      if (user.unlockDate > block.timestamp) {
          return 0;
      }
      
      return user.amount;
    }

    // Withdraw LP tokens from Farm.
    function withdraw(uint256 _pid, uint256 _amount) public {
        uint256 withdrawable = getWithdrawableBalance(_pid, msg.sender);
        require(_amount <= withdrawable, 'Your attempting to withdraw more than you have available');
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accFarmTokenPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeFarmTokenTransfer(msg.sender, pending);
        }
        uint256 pumpAmount;
        uint256 liquidity;
        if(_amount > 0) {
            pumpAmount = _amount.mul(pool.pumpRatio).div(1000);
            user.amount = user.amount.sub(_amount);
            pool.lpAmount = pool.lpAmount.sub(_amount);
            if (pool.tokenType == 0 && pumpAmount > 0) {
                pump(pumpAmount);
                _amount = _amount.sub(pumpAmount);
            } else if (pool.tokenType == 1) {
                liquidity = user.liqAmount.mul(_amount).div(user.amount.add(_amount));
                _amount = lpToInvestToken(pool.lpToken, liquidity, pool.pumpRatio);
                user.liqAmount = user.liqAmount.sub(liquidity);
            } else if (pool.tokenType == 2) {
                pumpLp(pool.lpToken, pumpAmount);
                _amount = _amount.sub(pumpAmount);
            }
            if (pool.tokenType == 1) {
                pool.tmpAmount = pool.tmpAmount.sub(liquidity);
            }
            if (address(pool.lpToken) == WETHADDR) {
                IWETH(WETHADDR).withdraw(_amount);
                safeTransferETH(address(msg.sender), _amount);
            } else {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accFarmTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount, pumpAmount, liquidity);
    }

    // Safe FarmToken transfer function, just in case if rounding error causes pool to not have enough FarmTokens.
    function safeFarmTokenTransfer(address _to, uint256 _amount) internal {
        uint256 farmTokenBal = farmToken.balanceOf(address(this));
        if (_amount > farmTokenBal) {
            farmToken.transfer(_to, farmTokenBal);
        } else {
            farmToken.transfer(_to, _amount);
        }
    }
}
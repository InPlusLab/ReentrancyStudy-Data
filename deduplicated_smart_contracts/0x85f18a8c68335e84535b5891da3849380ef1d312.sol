/**
 *Submitted for verification at Etherscan.io on 2020-12-21
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
// File: localhost/contracts/interfaces/ICurve.sol


pragma solidity ^0.6.0;

abstract contract ICurveFiCurve {
    
    function exchange (
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external virtual;

    function get_dy_underlying(int128 i, int128 j, uint256 dx)
        external virtual view returns (uint256 out);
        
    function get_dy(int128 i, int128 j, uint256 dx)
        external virtual view
        returns (uint256 out);

}
// File: localhost/contracts/interfaces/IUniswapV2.sol


pragma solidity ^0.6.0;


interface IUniRouter {
    function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    
}

interface IUniswapV2Factory {
    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Exchange pair);
}

interface IUniswapV2Exchange {
    //event Approval(address indexed owner, address indexed spender, uint value);
    //event Transfer(address indexed from, address indexed to, uint value);

    //function name() external pure returns (string memory);
    //function symbol() external pure returns (string memory);
    //function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function getReserves() external view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    //function allowance(address owner, address spender) external view returns (uint);

    //function approve(address spender, uint value) external returns (bool);
    //function transfer(address to, uint value) external returns (bool);
    //function transferFrom(address from, address to, uint value) external returns (bool);

    //function DOMAIN_SEPARATOR() external view returns (bytes32);
    //function PERMIT_TYPEHASH() external pure returns (bytes32);
    //function nonces(address owner) external view returns (uint);

    //function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    //event Mint(address indexed sender, uint amount0, uint amount1);
    //event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    /*event Swap(
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
    */
    function token0() external view returns (address);

    function token1() external view returns (address);

    /*function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    */
}

// File: localhost/contracts/utils/UniswapV2Lib.sol


pragma solidity ^0.6.12;



library UniswapV2ExchangeLib {
    using SafeMath for uint256;
    
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

library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function universalTransfer(IERC20 token, address to, uint256 amount) internal {
        if (token == IERC20(0)) {
            address(uint160(to)).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function universalApprove(IERC20 token, address to, uint256 amount) internal {
        if (token != IERC20(0)) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        if (token == IERC20(0)) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (token == IERC20(0)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}
// File: localhost/contracts/XTrinity.sol


pragma solidity ^0.6.12;
//pragma experimental ABIEncoderV2;


//import "./interfaces/IMooniswap.sol";





contract XTrinity is Ownable {
    //using SafeERC20 for IERC20;
    using UniversalERC20 for IERC20;
    using Address for address;

    using SafeMath for uint256;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;
    
    /*
    function destroy() external {
        selfdestruct(msg.sender);
    }
    
    function testMooni(uint amount) external payable returns (bool success, bytes memory returndata) {
        IERC20 fromToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        fromToken.universalTransferFrom(msg.sender, address(this), amount);

        IERC20 destToken = IERC20(address(0));
    
        IMooniswap mooniswap = IMooniswap(0x75116BD1AB4B0065B44E1A4ea9B4180A171406ED);
        

        if (fromToken.allowance(address(this), address(mooniswap)) != uint(-1)) {
                fromToken.universalApprove(address(mooniswap), uint(-1));
            }
        

        //address(mooniswap).functionCall(abi.encodeWithSelector(mooniswap.swap.selector, fromToken, destToken, amount, 0, address(0)), "Safe low-level call failed");

        
        (success, returndata) = address(mooniswap).call(abi.encodeWithSelector(mooniswap.swap.selector, fromToken, destToken, amount, 0, address(0)));
      
        result = mooniswap.swap(fromToken,
            destToken,
            amount,
            0,
            address(0));
        
        //destToken.universalTransfer(msg.sender, destToken.universalBalanceOf(address(this)));
    }
    */
    
    IERC20 public constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 public constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 public constant WETH_ADDRESS = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    address constant UNI_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    //address constant MOONI_FACTORY = 0x71CD6666064C3A1354a3B4dca5fA1E2D3ee7D303;
    address constant CURVE_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;  // 3-pool DAI/USDC/USDT

    address constant BONUS_ADDRESS = 0x8c545be506a335e24145EdD6e01D2754296ff018;
    IUniswapV2Factory constant internal uniV2 = IUniswapV2Factory(UNI_FACTORY);
    IUniswapV2Factory constant internal sushi = IUniswapV2Factory(SUSHI_FACTORY);
    //IMooniswapRegistry constant internal mooni = IMooniswapRegistry(MOONI_FACTORY);
    ICurveFiCurve private curve = ICurveFiCurve(CURVE_ADDRESS);
    IWETH constant internal weth = IWETH(address(WETH_ADDRESS));
    
    uint public constant PC_DENOMINATOR = 1e5;
    address[] public exchanges = [UNI_FACTORY, SUSHI_FACTORY, CURVE_ADDRESS];
    uint private constant ex_count = 3;
    uint public slippageFee; //1000 = 1% slippage
    uint public minPc;
    
    mapping (address => int128) public curveIndex;

    bool private initialized;
    
    function isETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS));
    }
    
    function isWETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(WETH_ADDRESS));
    }
    
    function isofETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS) || address(token) == address(WETH_ADDRESS));
    }

    function getCurveIndex(address token) internal view returns (int128) {
        // to avoid 'stack too deep' compiler issue
        return curveIndex[token]-1;
    }
        
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
    
    function init() virtual public {
        require(!initialized, "Is already been initialized");
        initialized = true;
        Ownable.initialize(); // Do not forget this call!
        _init();
    }
    
    function _init() virtual internal {
        curveIndex[DAI_ADDRESS] = 1; // actual index is 1 less
        curveIndex[USDC_ADDRESS] = 2;
        curveIndex[USDT_ADDRESS] = 3;
        
        slippageFee = 1000; //1%
        minPc = 10000; // 10%
    }    
    
    function reInit() virtual public onlyOwner {
        _init();
    }

    function setMinPc (uint _minPC) external onlyOwner {
        minPc = _minPC;
    }
    
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        //require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        //require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    
    function getReserves(IERC20 fromToken, IERC20 toToken, address factory) 
    public view returns(uint reserveA, uint reserveB) {
        if (factory != CURVE_ADDRESS) {
            //UNI
            IUniswapV2Factory uniFactory = IUniswapV2Factory(factory);
            IERC20 _from = isETH(fromToken) ? WETH_ADDRESS : fromToken;
            IERC20 _to = isETH(toToken) ? WETH_ADDRESS : toToken;
            
            IUniswapV2Exchange pair = uniFactory.getPair(_from, _to);
            
            if (address(pair) != address(0)) {
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                
                (address token0,) = sortTokens(address(_from), address(_to));
                (reserveA, reserveB) = address(_from) == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                }
            } else {
            // MOONI
            /*
            IERC20 _from = isWETH(fromToken) ? ZERO_ADDRESS : fromToken;
            IERC20 _to = isWETH(toToken) ? ZERO_ADDRESS : toToken;
        
            IMooniswap pair = mooni.pools(_from, _to);
        
            if (address(pair) != address(0)) {
                reserveA = pair.getBalanceForAddition(_from);
                reserveB = pair.getBalanceForRemoval(_to);
                }
            } 
            */ 
            // CURVE
                if (curveIndex[address(fromToken)] > 0 && curveIndex[address(toToken)] > 0) {
                    reserveA = fromToken.balanceOf(CURVE_ADDRESS);
                    reserveB = toToken.balanceOf(CURVE_ADDRESS);
                } 
            }
        }
        
    function getFullReserves (IERC20 fromToken, IERC20 toToken) public view returns 
    (uint fromTotal, uint destTotal, uint[ex_count] memory dist, uint[2][ex_count] memory res) {
        uint fullTotal;
        
        for (uint i = 0; i < ex_count; i++) {
            (uint balance0, uint balance1) = getReserves(fromToken, toToken, exchanges[i]);
            fromTotal += balance0;
            destTotal += balance1;
            fullTotal += balance0.add(balance1);
            (res[i][0], res[i][1]) = (balance0, balance1);
        }
        
        if (fullTotal > 0) {
            for (uint i = 0; i < ex_count; i++) {
                dist[i] = (res[i][0].add(res[i][1])).mul(PC_DENOMINATOR).div(fullTotal);
            }
        }
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
    
    function quoteDirect(IERC20 fromToken, IERC20 toToken, uint amount) public view 
    returns (uint returnAmount, uint[ex_count] memory swapAmounts) {
        (,, uint[ex_count] memory distribution, uint[2][ex_count] memory reserves) 
        = getFullReserves (fromToken, toToken);
        
        uint addDistribution;
        uint eligible;
        uint lastNonZeroIndex;
        
        for (uint i = 0; i < ex_count; i++) {
            if (distribution[i] > minPc) {
                lastNonZeroIndex = i;  
                eligible++;
            } else {
                addDistribution += distribution[i];
                distribution[i] = 0;
            }
        }
        
        require(eligible > 0, 'No eligible pools');
        
        uint remainingAmount = amount;
        
        for (uint i = 0; i <= lastNonZeroIndex; i++) {
            if (distribution[i] > 0) {
                if (addDistribution > 0) {
                    distribution[i] += addDistribution.div(eligible);
                }
                
            if (i == lastNonZeroIndex) {
                swapAmounts[i] = remainingAmount;
            } else {
                swapAmounts[i] = amount*distribution[i]/PC_DENOMINATOR;
            }
            
            if (exchanges[i] == CURVE_ADDRESS) {
                returnAmount += curve.get_dy_underlying(getCurveIndex(address(fromToken)), getCurveIndex(address(toToken)), swapAmounts[i]);
            } else {
                returnAmount += getAmountOut(swapAmounts[i], reserves[i][0], reserves[i][1]);    
            }
            
            remainingAmount -= swapAmounts[i];
            }
        }
    }
    
    function quote(IERC20 fromToken, IERC20 toToken, uint amount) virtual public view 
    returns (uint returnAmount, uint[ex_count] memory swapAmountsIn, uint[ex_count] memory swapAmountsOut, bool swapVia) {
    
    (uint returnAmountDirect, uint[ex_count] memory swapAmounts1) = quoteDirect(fromToken, toToken, amount);
        returnAmount = returnAmountDirect;
        swapAmountsIn = swapAmounts1;
        if (!isofETH(toToken) && !isofETH(fromToken)) {
            (uint returnAmountETH, uint[ex_count] memory swapAmounts2) = quoteDirect(fromToken, WETH_ADDRESS, amount);
            (uint returnAmountVia, uint[ex_count] memory swapAmounts3) = quoteDirect(WETH_ADDRESS, toToken, returnAmountETH); 
            
            if (returnAmountVia > returnAmountDirect) {
                returnAmount = returnAmountVia;
                swapAmountsIn = swapAmounts2;
                swapAmountsOut = swapAmounts3;
                swapVia = true;
            }
        }
    }

    function reverseQuote(
        IERC20 fromToken,
        IERC20 toToken,
        uint returnAmount
    ) public view returns (uint inputAmount)
    {
        (uint inAmount, , , ) = 
        quote(toToken, fromToken, returnAmount);

        (uint outAmount, , , ) = 
        quote(fromToken, toToken, inAmount);

        //extrapolate using bit smaller amount
        inputAmount = outAmount.mul(inAmount).div(returnAmount);
    }
    
    function executeSwap (IERC20 fromToken, IERC20 toToken, uint[ex_count] memory swapAmounts) internal returns (uint returnAmount) {
        for (uint i = 0; i < swapAmounts.length; i++) {
            if (swapAmounts[i] > 0) {
                uint thisBalance = fromToken.universalBalanceOf(address(this));
                uint swapAmount = min(thisBalance, swapAmounts[i]);
                    
                if (exchanges[i] != CURVE_ADDRESS) {
                    returnAmount += _swapOnUniswapV2Internal(fromToken, toToken, swapAmount, exchanges[i]);
                } else {
                    returnAmount += _swapOnCurve(fromToken, toToken, swapAmount);
                    //_swapOnMooniswap(fromToken, toToken, swapAmount);
                }
            }
        }
    }
    
    function swap (IERC20 fromToken, IERC20 toToken, uint amount, bool slipProtect) virtual public payable returns (uint returnAmount) {
        if (isETH(fromToken)) {
            amount = msg.value;
            weth.deposit{value: amount}();
            fromToken = WETH_ADDRESS;
        }
        
        amount = min(fromToken.balanceOf(address(this)), amount);
        
        (uint returnQuoteAmount, uint[ex_count] memory swapAmountsIn, uint[ex_count] memory swapAmountsOut, bool swapVia) = 
        quote(fromToken, toToken, amount);

        uint minAmount;
        if (slipProtect) {            
            uint feeSlippage = returnQuoteAmount.mul(slippageFee).div(PC_DENOMINATOR);    
            minAmount = returnQuoteAmount.sub(feeSlippage);
        }

        if (swapVia) {
            executeSwap(fromToken, WETH_ADDRESS, swapAmountsIn);
            returnAmount = executeSwap(WETH_ADDRESS, toToken, swapAmountsOut);
        } else {
            returnAmount = executeSwap(fromToken, toToken, swapAmountsIn);
        }

        //returnAmount = isETH(toToken) ? toToken.balanceOf(address(this)) : address(this).balance;
        //returnAmount = toToken.universalBalanceOf(address(this));

        require (returnAmount >= minAmount, 'XTrinity slippage is too high');
    }
    // to withdraw token from the contract

    function transferTokenBack(address TokenAddress)
        external
        onlyOwner
        returns (uint returnBalance)
    {
        IERC20 Token = IERC20(TokenAddress);
        returnBalance = Token.universalBalanceOf(address(this));
        if (returnBalance > 0) {
            Token.universalTransfer(msg.sender, returnBalance);
        }
    }
    
    /*
    function depositWETH() public payable {
        weth.deposit{value: address(this).balance}();
    }
    
    function _swapOnMooniswap(
        IERC20 fromToken,
        IERC20 destToken,
        uint amount
    ) public payable{
        //uint tx_value;
        if (isWETH(fromToken)) {
            fromToken = ZERO_ADDRESS;
            weth.withdraw(amount);
        }
        
        if (isWETH(destToken)) {
            destToken = ZERO_ADDRESS;
        }
        
        IMooniswap mooniswap = mooni.pools(
            fromToken,
            destToken
        );
        
        bytes memory returndata; 
        if (isETH(fromToken)) {

            mooniswap.swap{value: amount}(fromToken,
            destToken,
            amount,
            0,
            BONUS_ADDRESS);
            
            amount = address(this).balance;
            returndata = address(mooniswap).functionCallWithValue(abi.encodeWithSelector(mooniswap.swap.selector, fromToken, destToken, amount, 0, BONUS_ADDRESS), amount, "Safe value low-level call failed");
            
        } else {
            if (fromToken.allowance(address(this), address(mooniswap)) != uint(-1)) {
                fromToken.safeApprove(address(mooniswap), uint(-1));
                amount = fromToken.balanceOf(address(this));
            }
            
            returndata = address(mooniswap).functionCall(abi.encodeWithSelector(mooniswap.swap.selector, fromToken, destToken, amount, 0, BONUS_ADDRESS), "Safe low-level call failed");
                //_callOptionalReturn(mooniswap, abi.encodeWithSelector(token.swap.selector, destToken, amount, 0 , BONUS_ADDRESS));
                
                //_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
                
                
  
                mooniswap.swap(fromToken,
                destToken,
                amount,
                0,
                BONUS_ADDRESS);

            }
            
        
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "Safe operation did not succeed");
        }
            
        
        if (isWETH(destToken)) {
            weth.deposit{value: address(this).balance}();
        }
    }
    */

    function _swapOnCurve(
        IERC20 fromToken,
        IERC20 destToken,
        uint amount
    ) public payable returns (uint returnAmount) {
        //using curve 

        if (fromToken.allowance(address(this), CURVE_ADDRESS) != uint(-1)) {
            fromToken.universalApprove(CURVE_ADDRESS, uint(-1));
        }
    
        uint startBalance = destToken.balanceOf(address(this));
        
        // actual index is -1
        curve.exchange(getCurveIndex(address(fromToken)), getCurveIndex(address(destToken)), amount, 0);
        
        return destToken.balanceOf(address(this)) - startBalance;
    }
    
    function _swapOnUniswapV2Internal(
        IERC20 fromToken,
        IERC20 destToken,
        uint amount,
        address factory
    ) public payable returns (uint returnAmount) {
        if (isETH(fromToken)) {
            weth.deposit{value: amount}();
            fromToken = WETH_ADDRESS;
        }

        destToken = isETH(destToken) ? WETH_ADDRESS : destToken;
        IUniswapV2Factory uniFactory = IUniswapV2Factory(factory);
        IUniswapV2Exchange exchange = uniFactory.getPair(fromToken, destToken);
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = exchange.getReturn(fromToken, destToken, amount);
        if (needSync) {
            exchange.sync();
        }
        else if (needSkim) {
            exchange.skim(BONUS_ADDRESS);
        }

        fromToken.universalTransfer(address(exchange), amount);
        if (uint(address(fromToken)) < uint(address(destToken))) {
            exchange.swap(0, returnAmount, address(this), "");
        } else {
            exchange.swap(returnAmount, 0, address(this), "");
        }

        if (isETH(destToken)) {
            weth.withdraw(WETH_ADDRESS.balanceOf(address(this)));
        }
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

// File: localhost/contracts/interfaces/IOneSplit.sol


pragma solidity ^0.6.0;

//import "openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";


interface IOneSplit {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        //address fromToken,
        //address destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        external
        view
        returns (uint256 returnAmount, uint256[] memory distribution);

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );
        
    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    ) external payable returns (uint256 returnAmount);
}

// File: localhost/contracts/XChangerV2.0.sol


pragma solidity ^0.6.12;




contract splitConsts {
    /*uint256 internal constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 internal constant FLAG_DISABLE_BANCOR = 0x04;
    
    uint256 internal constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 internal constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 internal constant FLAG_DISABLE_CHAI = 0x40;
    uint256 internal constant FLAG_DISABLE_AAVE = 0x80;
    uint256 internal constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 internal constant FLAG_DISABLE_BDAI = 0x400;
    uint256 internal constant FLAG_DISABLE_IEARN = 0x800;
    
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_WETH = 0x80000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_COMPOUND = 0x100000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_CHAI = 0x200000; // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_AAVE = 0x400000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP = 0x1000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 internal constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    
    uint256 internal constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 internal constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 internal constant FLAG_DISABLE_DFORCE_SWAP = 0x4000000000;
    uint256 internal constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
    
    uint256 internal constant FLAG_DISABLE_CURVE_SBTC = 0x40000000000;
    uint256 internal constant FLAG_DISABLE_DMM = 0x80000000000;
    
    uint256 internal constant FLAG_DISABLE_CURVE_ALL = 0x200000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x400000000000;
    
    uint256 internal constant FLAG_DISABLE_BALANCER_ALL = 0x1000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_1 = 0x2000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_2 = 0x4000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_3 = 0x8000000000000;
    uint256 internal constant FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP = 0x80000000000000; // Turned off by default
    uint256 internal constant FLAG_DISABLE_KYBER_ALL = 0x200000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_1 = 0x400000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_2 = 0x800000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_3 = 0x1000000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_4 = 0x2000000000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN_BY_ORIGIN = 0x4000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_ALL = 0x8000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_ETH = 0x10000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_DAI = 0x20000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_USDC = 0x40000000000000000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP_POOL_TOKEN = 0x80000000000000000;
    */
    uint256 internal constant FLAG_DISABLE_UNISWAP_ALL = 0x100000000000;
    uint256 internal constant FLAG_DISABLE_OASIS = 0x08;
    uint256 internal constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 internal constant FLAG_DISABLE_MSTABLE_MUSD = 0x20000000000;
    uint256 internal constant FLAG_DISABLE_SPLIT_RECALCULATION = 0x800000000000;

}

contract XChanger is Ownable, XTrinity, splitConsts {
    using UniversalERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for int128;
    
    address public constant ONESPLIT_ADDRESS = 0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e; //1proto.eth

    IOneSplit private oneSplit = IOneSplit(ONESPLIT_ADDRESS);

    enum Exchange {TRINITY, ONESPLIT}
    
    Exchange public activeExchange;
    
    uint public oneSplitParts;  // oneSplit parts, 1-100 affects gas usage
    uint public oneSplitFlags;

    //0x6B175474E89094C44Da98b954EedeAC495271d0F DAI
    //
    //0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USDC
    //
    //  30000000000000000000
    //  30000000

    event NoDirectQuote(address, address);
    event NoWETHQuote(address, address);
    
    function _init() internal override {
        activeExchange = Exchange.TRINITY;
        XTrinity._init();

        oneSplitParts = 1;
        oneSplitFlags = FLAG_DISABLE_UNISWAP_ALL + FLAG_DISABLE_OASIS + FLAG_DISABLE_CURVE_COMPOUND + FLAG_DISABLE_CURVE_USDT 
        + FLAG_DISABLE_CURVE_Y + FLAG_DISABLE_CURVE_BINANCE + FLAG_DISABLE_CURVE_PAX + FLAG_DISABLE_MSTABLE_MUSD 
        + FLAG_DISABLE_SPLIT_RECALCULATION;
    }
    
    function reInit() virtual public override onlyOwner {
        _init();
    }
    
    function setActiveExchange(Exchange _exchange) external onlyOwner {
        activeExchange = _exchange;
    }
    
    function setOneSplitFlags (uint _flags) external onlyOwner {
        oneSplitFlags = _flags;
    }
    
    function setOneSplitParts (uint _parts) external onlyOwner {
        oneSplitParts = _parts;
    }
    
    function swapSplit(
        IERC20 fromToken,
        IERC20 toToken,
        uint amount,
        bool slipProtect
    ) internal returns (uint returnAmount) {
        
        (uint returnAmt, uint[] memory distribution) = quoteX(
            fromToken,
            toToken,
            amount
        );
        returnAmount = returnAmt; //not sure why direct assignment did not work
        
        require(returnAmount > 0, "ONESPLIT has nothing to return");
        
        uint minAmount;
        if (slipProtect) {
            uint feeSlippage = returnAmount.mul(slippageFee).div(PC_DENOMINATOR);    
            minAmount = returnAmount.sub(feeSlippage);
        } 

        //Still 1split
        if (fromToken.allowance(address(this), ONESPLIT_ADDRESS) != uint(-1)) {
            fromToken.universalApprove(ONESPLIT_ADDRESS, uint(-1));
        }
        
        returnAmount = oneSplit.swap(
        fromToken,
        toToken,
        amount,
        oneSplitParts,
        distribution,
        oneSplitFlags
        );    

        require (toToken.balanceOf(address(this)) > minAmount, 'ONESPLIT slippage is too high');
    }

    function swapX(
        IERC20 fromToken,
        IERC20 toToken,
        uint amount,
        bool slipProtect
    ) public payable returns (uint result) {
        if (fromToken == toToken) {
            return amount; // nothing to change
        }
        
        if (activeExchange == Exchange.ONESPLIT) {
            result = swapSplit(fromToken, toToken, amount, slipProtect);
        } else {
            result = XTrinity.swap(fromToken, toToken, amount, slipProtect);
        }
    }
    
    function quoteX(
        IERC20 fromToken,
        IERC20 toToken,
        uint amount
    )  public view returns (uint returnAmount, uint[] memory distribution) {
        
        if (fromToken == toToken) {
            //nothing to change
            return (amount, distribution);
        }
            
        if (activeExchange == Exchange.ONESPLIT) {
            (returnAmount, distribution) = oneSplit.getExpectedReturn(fromToken, toToken, amount, oneSplitParts, oneSplitFlags);

        } else {
            (returnAmount, , , ) = 
            XTrinity.quote(fromToken, toToken, returnAmount); 
        }
    }
}
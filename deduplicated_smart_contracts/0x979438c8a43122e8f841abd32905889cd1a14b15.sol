/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts/utils/Address.sol

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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

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

// File: contracts/external/uniswap/interfaces/IUniswapV2Pair.sol

pragma solidity ^0.5.0;

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

    event Mint(
        address indexed sender,
        uint amount0,
        uint amount1
    );

    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );

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

// File: contracts/governance/dmg/IDMGToken.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.13;

interface IDMGToken {

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function getPriorVotes(address account, uint blockNumber) external view returns (uint128);

    function delegates(address delegator) external view returns (address);

    function burn(uint amount) external returns (bool);

}

// File: contracts/utils/IERC20WithDecimals.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface IERC20WithDecimals {

    function decimals() external view returns (uint8);

}

// File: contracts/external/uniswap/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.5.0;

contract IUniswapV2Router01 {

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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    payable
    returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[]
        calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[]
        calldata path
    ) external view returns (uint[] memory amounts);

}

// File: contracts/external/uniswap/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.5.0;


contract IUniswapV2Router02 is IUniswapV2Router01 {

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

// File: contracts/external/uniswap/libs/UniswapV2Library.sol

pragma solidity ^0.5.0;



library UniswapV2Library {

    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB,
        bytes32 initCodeHash
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initCodeHash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB,
        bytes32 initCodeHash
    ) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB, initCodeHash)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint amountIn,
        address[] memory path,
        bytes32 initCodeHash
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1], initCodeHash);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint amountOut,
        address[] memory path,
        bytes32 initCodeHash
    ) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i], initCodeHash);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File: contracts/protocol/interfaces/InterestRateInterface.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface InterestRateInterface {

    /**
      * @dev Returns the current interest rate for the given DMMA and corresponding total supply & active supply
      *
      * @param dmmTokenId The DMMA whose interest should be retrieved
      * @param totalSupply The total supply fot he DMM token
      * @param activeSupply The supply that's currently being lent by users
      * @return The interest rate in APY, which is a number with 18 decimals
      */
    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);

}

// File: contracts/protocol/interfaces/IUnderlyingTokenValuator.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {

    /**
      * @dev Gets the tokens value in terms of USD.
      *
      * @return The value of the `amount` of `token`, as a number with the same number of decimals as `amount` passed
      *         in to this function.
      */
    function getTokenValue(address token, uint amount) external view returns (uint);

}

// File: @openzeppelin/contracts/GSN/Context.sol

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

// File: @openzeppelin/contracts/ownership/Ownable.sol

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

// File: contracts/utils/Blacklistable.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


/**
 * @dev Allows accounts to be blacklisted by the owner of the contract.
 *
 *  Taken from USDC's contract for blacklisting certain addresses from owning and interacting with the token.
 */
contract Blacklistable is Ownable {

    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @dev Throws if called by any account other than the creator of this contract
    */
    modifier onlyBlacklister() {
        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

    /**
     * @dev Throws if `account` is blacklisted
     *
     * @param account The address to check
    */
    modifier notBlacklisted(address account) {
        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

    /**
     * @dev Checks if `account` is blacklisted. Reverts with `BLACKLISTED` if blacklisted.
    */
    function checkNotBlacklisted(address account) public view {
        require(!blacklisted[account], BLACKLISTED);
    }

    /**
     * @dev Checks if `account` is blacklisted
     *
     * @param account The address to check
    */
    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }

    /**
     * @dev Adds `account` to blacklist
     *
     * @param account The address to blacklist
    */
    function blacklist(address account) public onlyBlacklister {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes account from blacklist
     *
     * @param account The address to remove from the blacklist
    */
    function unBlacklist(address account) public onlyBlacklister {
        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}

// File: contracts/protocol/interfaces/IDmmController.sol

pragma solidity ^0.5.0;




interface IDmmController {

    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event AdminDeposit(address indexed sender, uint amount);
    event AdminWithdraw(address indexed receiver, uint amount);

    /**
     * @dev Creates a new mToken using the provided data.
     *
     * @param underlyingToken   The token that should be wrapped to create a new DMMA
     * @param symbol            The symbol of the new DMMA, IE mDAI or mUSDC
     * @param name              The name of this token, IE `DMM: DAI`
     * @param decimals          The number of decimals of the underlying token, and therefore the number for this DMMA
     * @param minMintAmount     The minimum amount that can be minted for any given transaction.
     * @param minRedeemAmount   The minimum amount that can be redeemed any given transaction.
     * @param totalSupply       The initial total supply for this market.
     */
    function addMarket(
        address underlyingToken,
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) external;

    /**
     * @dev Creates a new mToken using the already-existing token.
     *
     * @param dmmToken          The token that should be added to this controller.
     * @param underlyingToken   The token that should be wrapped to create a new DMMA.
     */
    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    ) external;

    /**
     * @param newController The new controller who should receive ownership of the provided DMM token IDs.
     */
    function transferOwnershipToNewController(
        address newController
    ) external;

    /**
     * @dev Enables the corresponding DMMA to allow minting new tokens.
     *
     * @param dmmTokenId  The DMMA that should be enabled.
     */
    function enableMarket(uint dmmTokenId) external;

    /**
     * @dev Disables the corresponding DMMA from minting new tokens. This allows the market to close over time, since
     *      users are only able to redeem tokens.
     *
     * @param dmmTokenId  The DMMA that should be disabled.
     */
    function disableMarket(uint dmmTokenId) external;

    /**
     * @dev Sets the new address that will serve as the guardian for this controller.
     *
     * @param newGuardian   The new address that will serve as the guardian for this controller.
     */
    function setGuardian(address newGuardian) external;

    /**
     * @dev Sets a new contract that implements the `DmmTokenFactory` interface.
     *
     * @param newDmmTokenFactory  The new contract that implements the `DmmTokenFactory` interface.
     */
    function setDmmTokenFactory(address newDmmTokenFactory) external;

    /**
     * @dev Sets a new contract that implements the `DmmEtherFactory` interface.
     *
     * @param newDmmEtherFactory  The new contract that implements the `DmmEtherFactory` interface.
     */
    function setDmmEtherFactory(address newDmmEtherFactory) external;

    /**
     * @dev Sets a new contract that implements the `InterestRate` interface.
     *
     * @param newInterestRateInterface  The new contract that implements the `InterestRateInterface` interface.
     */
    function setInterestRateInterface(address newInterestRateInterface) external;

    /**
     * @dev Sets a new contract that implements the `IOffChainAssetValuator` interface.
     *
     * @param newOffChainAssetValuator The new contract that implements the `IOffChainAssetValuator` interface.
     */
    function setOffChainAssetValuator(address newOffChainAssetValuator) external;

    /**
     * @dev Sets a new contract that implements the `IOffChainAssetValuator` interface.
     *
     * @param newOffChainCurrencyValuator The new contract that implements the `IOffChainAssetValuator` interface.
     */
    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) external;

    /**
     * @dev Sets a new contract that implements the `UnderlyingTokenValuator` interface
     *
     * @param newUnderlyingTokenValuator The new contract that implements the `UnderlyingTokenValuator` interface
     */
    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param newMinCollateralization   The new min collateralization (with 18 decimals) at which the DMME must be in
     *                                  order to add to the total supply of DMM.
     */
    function setMinCollateralization(uint newMinCollateralization) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param newMinReserveRatio   The new ratio (with 18 decimals) that is used to enforce a certain percentage of assets
     *                          are kept in each DMMA.
     */
    function setMinReserveRatio(uint newMinReserveRatio) external;

    /**
     * @dev Increases the max supply for the provided `dmmTokenId` by `amount`. This call reverts with
     *      INSUFFICIENT_COLLATERAL if there isn't enough collateral in the Chainlink contract to cover the controller's
     *      requirements for minimum collateral.
     */
    function increaseTotalSupply(uint dmmTokenId, uint amount) external;

    /**
     * @dev Increases the max supply for the provided `dmmTokenId` by `amount`.
     */
    function decreaseTotalSupply(uint dmmTokenId, uint amount) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param dmmTokenId        The ID of the DMM token whose underlying will be funded.
     * @param underlyingAmount  The amount underlying the DMM token that will be deposited into the DMMA.
     */
    function adminWithdrawFunds(uint dmmTokenId, uint underlyingAmount) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to deposit funds into a DMMA. These funds are used to disburse
     *      interest payments and add more liquidity to the specific market.
     *
     * @param dmmTokenId        The ID of the DMM token whose underlying will be funded.
     * @param underlyingAmount  The amount underlying the DMM token that will be deposited into the DMMA.
     */
    function adminDepositFunds(uint dmmTokenId, uint underlyingAmount) external;

    /**
     * @return  All of the DMM token IDs that are currently in the ecosystem. NOTE: this is an unfiltered list.
     */
    function getDmmTokenIds() external view returns (uint[] memory);

    /**
     * @dev Gets the collateralization of the system assuming 1-year's worth of interest payments are due by dividing
     *      the total value of all the collateralized assets plus the value of the underlying tokens in each DMMA by the
     *      aggregate interest owed (plus the principal), assuming each DMMA was at maximum usage.
     *
     * @return  The 1-year collateralization of the system, as a number with 18 decimals. For example
     *          `1010000000000000000` is 101% or 1.01.
     */
    function getTotalCollateralization() external view returns (uint);

    /**
     * @dev Gets the current collateralization of the system assuming by dividing the total value of all the
     *      collateralized assets plus the value of the underlying tokens in each DMMA by the aggregate interest owed
     *      (plus the principal), using the current usage of each DMMA.
     *
     * @return  The active collateralization of the system, as a number with 18 decimals. For example
     *          `1010000000000000000` is 101% or 1.01.
     */
    function getActiveCollateralization() external view returns (uint);

    /**
     * @dev Gets the interest rate from the underlying token, IE DAI or USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) external view returns (uint);

    /**
     * @dev Gets the interest rate from the DMM token, IE DMM: DAI or DMM: USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning, `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByDmmTokenId(uint dmmTokenId) external view returns (uint);

    /**
     * @dev Gets the interest rate from the DMM token, IE DMM: DAI or DMM: USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning, `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByDmmTokenAddress(address dmmToken) external view returns (uint);

    /**
     * @dev Gets the exchange rate from the underlying to the DMM token, such that
     *      `DMM: Token = underlying / exchangeRate`
     *
     * @return  The current exchange rate, represented using 18 decimals. Meaning, `200000000000000000` is 0.2.
     */
    function getExchangeRateByUnderlying(address underlyingToken) external view returns (uint);

    /**
     * @dev Gets the exchange rate from the underlying to the DMM token, such that
     *      `DMM: Token = underlying / exchangeRate`
     *
     * @return  The current exchange rate, represented using 18 decimals. Meaning, `200000000000000000` is 0.2.
     */
    function getExchangeRate(address dmmToken) external view returns (uint);

    /**
     * @dev Gets the DMM token for the provided underlying token. For example, sending DAI returns DMM: DAI.
     */
    function getDmmTokenForUnderlying(address underlyingToken) external view returns (address);

    /**
     * @dev Gets the underlying token for the provided DMM token. For example, sending DMM: DAI returns DAI.
     */
    function getUnderlyingTokenForDmm(address dmmToken) external view returns (address);

    /**
     * @return True if the market is enabled for this DMMA or false if it is not enabled.
     */
    function isMarketEnabledByDmmTokenId(uint dmmTokenId) external view returns (bool);

    /**
     * @return True if the market is enabled for this DMM token (IE DMM: DAI) or false if it is not enabled.
     */
    function isMarketEnabledByDmmTokenAddress(address dmmToken) external view returns (bool);

    /**
     * @return True if the market is enabled for this underlying token (IE DAI) or false if it is not enabled.
     */
    function getTokenIdFromDmmTokenAddress(address dmmTokenAddress) external view returns (uint);

    /**
     * @dev Gets the DMM token contract address for the provided DMM token ID. For example, `1` returns the mToken
     *      contract address for that token ID.
     */
    function getDmmTokenAddressByDmmTokenId(uint dmmTokenId) external view returns (address);

    function blacklistable() external view returns (Blacklistable);

    function underlyingTokenValuator() external view returns (IUnderlyingTokenValuator);

}

// File: contracts/external/farming/DMGYieldFarmingData.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


//import "./v2/DMGYieldFarmingV2Lib.sol";

contract DMGYieldFarmingData is Initializable {

    // /////////////////////////
    // BEGIN V1 State Variables
    // /////////////////////////

    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;
    address internal _owner;

    address internal _dmgToken;
    address internal _guardian;
    address internal _dmmController;
    address[] internal _supportedFarmTokens;
    /// @notice How much DMG is earned every second of farming. This number is represented as a fraction with 18
    //          decimal places, whereby 0.01 == 1000000000000000.
    uint internal _dmgGrowthCoefficient;

    bool internal _isFarmActive;
    uint internal _seasonIndex;
    mapping(address => uint16) internal _tokenToRewardPointMap;
    mapping(address => mapping(address => bool)) internal _userToSpenderToIsApprovedMap;
    mapping(uint => mapping(address => mapping(address => uint))) internal _seasonIndexToUserToTokenToEarnedDmgAmountMap;
    mapping(uint => mapping(address => mapping(address => uint64))) internal _seasonIndexToUserToTokenToDepositTimestampMap;
    mapping(address => address) internal _tokenToUnderlyingTokenMap;
    mapping(address => uint8) internal _tokenToDecimalsMap;
    mapping(address => uint) internal _tokenToIndexPlusOneMap;
    mapping(address => mapping(address => uint)) internal _addressToTokenToBalanceMap;
    mapping(address => bool) internal _globalProxyToIsTrustedMap;

    // /////////////////////////
    // BEGIN V2 State Variables
    // /////////////////////////

    address internal _underlyingTokenValuator;
    address internal _uniswapV2Router;
    address internal _weth;
    mapping(address => DMGYieldFarmingV2Lib.TokenType) internal _tokenToTokenType;
    mapping(address => uint16) internal _tokenToFeeAmountMap;
    bool internal _isDmgBalanceInitialized;
    mapping(uint => uint64) internal _seasonIndexToStartTimestamp;

    // /////////////////////////
    // END State Variables
    // /////////////////////////

    // /////////////////////////
    // Events
    // /////////////////////////

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // /////////////////////////
    // Functions
    // /////////////////////////

    function initialize(address owner) public initializer {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;

        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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
        require(newOwner != address(0), "DMGYieldFarmingData::transferOwnership: INVALID_OWNER");

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    // /////////////////////////
    // Modifiers
    // /////////////////////////

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "DMGYieldFarmingData: NOT_OWNER");
        _;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "DMGYieldFarmingData: REENTRANCY");
    }

    // /////////////////////////
    // Constants
    // /////////////////////////

    uint8 public constant POINTS_DECIMALS = 2;

    uint16 public constant POINTS_FACTOR = uint16(10 ** uint(POINTS_DECIMALS));

    uint8 public constant DMG_GROWTH_COEFFICIENT_DECIMALS = 18;

    uint public constant DMG_GROWTH_COEFFICIENT_FACTOR = 10 ** uint(DMG_GROWTH_COEFFICIENT_DECIMALS);

    uint8 public constant USD_VALUE_DECIMALS = 18;

    uint public constant USD_VALUE_FACTOR = 10 ** uint(USD_VALUE_DECIMALS);

    uint8 public constant FEE_AMOUNT_DECIMALS = 4;

    uint16 public constant FEE_AMOUNT_FACTOR = uint16(10 ** uint(FEE_AMOUNT_DECIMALS));

}

// File: contracts/external/farming/v2/DMGYieldFarmingV2Lib.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;











//import "./IDMGYieldFarmingV2.sol";

library DMGYieldFarmingV2Lib {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using UniswapV2Library for *;

    // ////////////////////
    // Enums
    // ////////////////////

    enum TokenType {
        Unknown,
        UniswapLpToken,
        UniswapPureLpToken // Does not have an mToken base pairing. IE DMG-ETH
    }

    // ////////////////////
    // Events
    // ////////////////////

    /**
     * @param tokenAmountToConvert  The amount of `token` to be converted to DMG and burned.
     * @param dmgAmountBurned       The amount of DMG burned after `tokenAmountToConvert` was converted to DMG.
     */
    event HarvestFeePaid(address indexed owner, address indexed token, uint tokenAmountToConvert, uint dmgAmountBurned);

    // ////////////////////
    // Functions
    // ////////////////////

    /**
     * @return  The dollar value of `tokenAmount`, formatted as a number with 18 decimal places
     */
    function _getUsdValueByTokenAndTokenAmount(
        IDMGYieldFarmingV2 state,
        address __farmToken,
        uint __tokenAmount
    ) public view returns (uint) {
        address underlyingToken = state.getUnderlyingTokenByFarmToken(__farmToken);
        address __underlyingTokenValuator = state.underlyingTokenValuator();
        DMGYieldFarmingV2Lib.TokenType tokenType = state.getTokenTypeByToken(__farmToken);

        if (tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapLpToken) {
            return _getUsdValueByTokenAndAmountForUniswapLpToken(
                __farmToken,
                __tokenAmount,
                underlyingToken,
                state.getTokenDecimalsByToken(__farmToken),
                state.dmmController(),
                __underlyingTokenValuator
            );
        } else if (tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapPureLpToken) {
            (address otherToken, uint underlyingTokenReserveAmount, uint otherTokenReserveAmount) = _getUniswapParams(__farmToken, underlyingToken);

            uint totalSupply = IERC20(__farmToken).totalSupply();
            require(
                totalSupply > 0,
                "DMGYieldFarmingV2::_getUsdValueByTokenAndTokenAmount: INVALID_TOTAL_SUPPLY"
            );
            uint8 underlyingTokenDecimals = state.getTokenDecimalsByToken(__farmToken);

            uint underlyingTokenUsdValue = _getUnderlyingTokenUsdValueFromUniswapPool(
                __tokenAmount,
                totalSupply,
                underlyingToken,
                underlyingTokenReserveAmount,
                underlyingTokenDecimals,
                __underlyingTokenValuator
            );

            uint otherTokenUsdValue = _getUnderlyingTokenUsdValueFromUniswapPool(
                __tokenAmount,
                totalSupply,
                otherToken,
                otherTokenReserveAmount,
                underlyingTokenDecimals,
                __underlyingTokenValuator
            );

            return underlyingTokenUsdValue.add(otherTokenUsdValue);
        } else {
            revert("DMGYieldFarmingV2::_getUsdValueByTokenAndTokenAmount: INVALID_TOKEN_TYPE");
        }
    }

    function _getUsdValueByTokenAndAmountForUniswapLpToken(
        address __farmToken,
        uint __farmTokenAmount,
        address __underlyingToken,
        uint8 __underlyingTokenDecimals,
        address __dmmController,
        address __underlyingTokenValuator
    ) internal view returns (uint) {
        (address mToken, uint underlyingTokenAmount, uint mTokenAmount) = _getUniswapParams(__farmToken, __underlyingToken);

        uint totalSupply = IERC20(__farmToken).totalSupply();
        require(
            totalSupply > 0,
            "DMGYieldFarmingV2::_getUsdValueByTokenAndTokenAmount: INVALID_TOTAL_SUPPLY"
        );

        uint underlyingTokenUsdValue = _getUnderlyingTokenUsdValueFromUniswapPool(
            __farmTokenAmount,
            totalSupply,
            __underlyingToken,
            underlyingTokenAmount,
            __underlyingTokenDecimals,
            __underlyingTokenValuator
        );

        uint mTokenUsdValue = _getMTokenUsdValueFromUniswapPool(
            __farmTokenAmount,
            totalSupply,
            mToken,
            mTokenAmount,
            __underlyingTokenDecimals,
            __dmmController,
            __underlyingTokenValuator
        );

        return underlyingTokenUsdValue.add(mTokenUsdValue);
    }

    function _getUniswapParams(
        address __farmToken,
        address __underlyingToken
    ) public view returns (address otherToken, uint underlyingTokenAmount, uint otherTokenAmount) {
        address token0 = IUniswapV2Pair(__farmToken).token0();
        address token1 = IUniswapV2Pair(__farmToken).token1();

        require(
            __underlyingToken == token0 || __underlyingToken == token1,
            "DMGYieldFarmingV2Lib::_getUniswapParams: INVALID_UNDERLYING"
        );

        otherToken = __underlyingToken == token0 ? token1 : token0;

        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(__farmToken).getReserves();
        underlyingTokenAmount = __underlyingToken == token0 ? reserve0 : reserve1;
        otherTokenAmount = __underlyingToken == token0 ? reserve1 : reserve0;
    }

    function _getUnderlyingTokenUsdValueFromUniswapPool(
        uint __tokenAmount,
        uint __totalSupply,
        address __underlyingToken,
        uint __underlyingTokenReserveAmount,
        uint8 __underlyingTokenDecimals,
        address __underlyingTokenValuator
    ) public view returns (uint) {
        uint underlyingTokenAmount = __tokenAmount
        .mul(__underlyingTokenReserveAmount)
        .div(__totalSupply);

        return _getUsdValueForUnderlyingTokenAmount(
            __underlyingToken,
            __underlyingTokenValuator,
            __underlyingTokenDecimals,
            underlyingTokenAmount
        );
    }

    function _getMTokenUsdValueFromUniswapPool(
        uint __tokenAmount,
        uint __totalSupply,
        address __mToken,
        uint __mTokenReserveAmount,
        uint8 __mTokenDecimals,
        address __dmmController,
        address __underlyingTokenValuator
    ) public view returns (uint) {
        uint mTokenAmount = __tokenAmount
        .mul(__mTokenReserveAmount)
        .div(__totalSupply);

        // The exchange rate always has 18 decimals.
        return _getUsdValueForUnderlyingTokenAmount(
            IDmmController(__dmmController).getUnderlyingTokenForDmm(__mToken),
            __underlyingTokenValuator,
            __mTokenDecimals,
            mTokenAmount.mul(IDmmController(__dmmController).getExchangeRate(__mToken)).div(1e18)
        );
    }

    function _getUsdValueForUnderlyingTokenAmount(
        address __underlyingToken,
        address __underlyingTokenValuator,
        uint8 __decimals,
        uint __amount
    ) public view returns (uint) {
        if (__decimals < 18) {
            __amount = __amount.mul((10 ** (18 - uint(__decimals))));
        } else if (__decimals > 18) {
            __amount = __amount.div((10 ** (uint(__decimals) - 18)));
        }
        return IUnderlyingTokenValuator(__underlyingTokenValuator).getTokenValue(__underlyingToken, __amount);
    }

    /**
     * @return The amount of `__token` paid for the burn.
     */
    function _payHarvestFee(
        IDMGYieldFarmingV2 state,
        address __user,
        address __token,
        uint __tokenAmount
    ) public returns (uint) {
        uint fees = state.getFeesByToken(__token);
        if (fees > 0) {
            uint tokenFeeAmount = __tokenAmount.mul(fees).div(uint(DMGYieldFarmingData(address(state)).FEE_AMOUNT_FACTOR()));
            require(
                tokenFeeAmount > 0,
                "DMGYieldFarmingV2Lib::_payHarvestFee: TOKEN_AMOUNT_TOO_SMALL_FOR_FEE"
            );

            DMGYieldFarmingV2Lib.TokenType tokenType = state.getTokenTypeByToken(__token);
            require(
                tokenType != DMGYieldFarmingV2Lib.TokenType.Unknown,
                "DMGYieldFarmingV2Lib::_payHarvestFee: UNKNOWN_TOKEN_TYPE"
            );

            if (tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapLpToken ||
                tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapPureLpToken) {
                _payFeesWithUniswapToken(
                    state,
                    __user,
                    __token,
                    tokenFeeAmount,
                    state.getUnderlyingTokenByFarmToken(__token)
                );
            } else {
                revert(
                    "DMGYieldFarmingV2Lib::_payHarvestFee UNCAUGHT_TOKEN_TYPE"
                );
            }

            return tokenFeeAmount;
        } else {
            return 0;
        }
    }

    function _payFeesWithUniswapToken(
        IDMGYieldFarmingV2 state,
        address __user,
        address __uniswapToken,
        uint __tokenFeeAmount,
        address underlyingToken
    ) public {

        // This is the token that is NOT the underlyingToken. Meaning, it needs to be converted to underlyingToken so
        // it can be added to underlyingToken amount, swapped (as underlyingToken) to DMG, and burned.
        address tokenToSwap;
        address token0;
        uint amountToBurn;
        uint amountToSwap;
        {
            // New context - to prevent the stack too deep error
            // --------------------------------------------------
            // This code is taken from the `UniswapV2Router02` to more efficiently convert the LP __token *TO* its
            // reserve tokens
            IERC20(__uniswapToken).safeTransfer(__uniswapToken, __tokenFeeAmount);
            (uint amount0, uint amount1) = IUniswapV2Pair(__uniswapToken).burn(address(this));
            token0 = IUniswapV2Pair(__uniswapToken).token0();

            tokenToSwap = token0 == underlyingToken ? IUniswapV2Pair(__uniswapToken).token1() : token0;

            amountToBurn = token0 == underlyingToken ? amount0 : amount1;
            amountToSwap = token0 != underlyingToken ? amount0 : amount1;
        }

        address dmg = state.dmgToken();
        if (tokenToSwap != dmg) {
            // Exchanges `tokenToSwap` to `underlyingToken`, so `underlyingToken` can be swapped to DMG and burned.
            // This code is taken from the `UniswapV2Router02` to more efficiently swap *TO* the underlying __token
            IERC20(tokenToSwap).safeTransfer(__uniswapToken, amountToSwap);
            (uint reserve0, uint reserve1,) = IUniswapV2Pair(__uniswapToken).getReserves();
            uint amountOut = UniswapV2Library.getAmountOut(
                amountToSwap,
                tokenToSwap == token0 ? reserve0 : reserve1,
                tokenToSwap != token0 ? reserve0 : reserve1
            );

            (uint amount0Out, uint amount1Out) = tokenToSwap == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            IUniswapV2Pair(__uniswapToken).swap(amount0Out, amount1Out, address(this), new bytes(0));

            amountToBurn = amountToBurn.add(amountOut);
        }

        uint dmgToBurn = _swapTokensForDmgViaUniswap(state, amountToBurn, underlyingToken, state.weth(), dmg);

        if (tokenToSwap == dmg) {
            // We can just add the DMG to be swapped with the amount to burn.
            amountToSwap = amountToSwap.add(dmgToBurn);
            IDMGToken(dmg).burn(amountToSwap);
            emit HarvestFeePaid(__user, __uniswapToken, __tokenFeeAmount, amountToSwap);
        } else {
            IDMGToken(dmg).burn(dmgToBurn);
            emit HarvestFeePaid(__user, __uniswapToken, __tokenFeeAmount, dmgToBurn);
        }
    }

    /**
     * @return  The amount of DMG received from the swap
     */
    function _swapTokensForDmgViaUniswap(
        IDMGYieldFarmingV2 state,
        uint __amountToBurn,
        address __underlyingToken,
        address __weth,
        address __dmg
    ) public returns (uint) {
        address[] memory paths;
        if (__underlyingToken == __weth) {
            paths = new address[](2);
            paths[0] = __weth;
            paths[1] = __dmg;
        } else {
            paths = new address[](3);
            paths[0] = __underlyingToken;
            paths[1] = __weth;
            paths[2] = __dmg;
        }
        // We sell the underlyingToken to DMG and burn it.
        uint[] memory amountsOut = IUniswapV2Router02(state.uniswapV2Router()).swapExactTokensForTokens(
            __amountToBurn,
        /* amountOutMin */ 1,
            paths,
            address(this),
            block.timestamp
        );

        return amountsOut[amountsOut.length - 1];
    }

}

// File: contracts/external/farming/v2/IDMGYieldFarmingV2.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


interface IDMGYieldFarmingV2 {

    // ////////////////////
    // Admin Events
    // ////////////////////

    event GlobalProxySet(address indexed proxy, bool isTrusted);

    event TokenAdded(address indexed token, address indexed underlyingToken, uint8 underlyingTokenDecimals, uint16 points, uint16 fees);
    event TokenRemoved(address indexed token);

    event FarmSeasonBegun(uint indexed seasonIndex, uint dmgAmount);
    event FarmSeasonExtended(uint indexed seasonIndex, uint dmgAmount);
    event FarmSeasonEnd(uint indexed seasonIndex, address dustRecipient, uint dustyDmgAmount);

    event DmgGrowthCoefficientSet(uint coefficient);
    event RewardPointsSet(address indexed token, uint16 points);

    event UnderlyingTokenValuatorChanged(address newUnderlyingTokenValutor, address oldUnderlyingTokenValutor);
    event UniswapV2RouterChanged(address newUniswapV2Router, address oldUniswapV2Router);
    event FeesChanged(address indexed token, uint16 feeAmount);
    event TokenTypeChanged(address indexed token, DMGYieldFarmingV2Lib.TokenType tokenType);

    // ////////////////////
    // User Events
    // ////////////////////

    event Approval(address indexed user, address indexed spender, bool isTrusted);

    event BeginFarming(address indexed owner, address indexed token, uint depositedAmount);
    event EndFarming(address indexed owner, address indexed token, uint withdrawnAmount, uint earnedDmgAmount);

    event WithdrawOutOfSeason(address indexed owner, address indexed token, address indexed recipient, uint amount);

    event Harvest(address indexed owner, address indexed token, uint earnedDmgAmount);

    /**
     * @param tokenAmountToConvert  The amount of `token` to be converted to DMG and burned.
     * @param dmgAmountBurned       The amount of DMG burned after `tokenAmountToConvert` was converted to DMG.
     */
    event HarvestFeePaid(address indexed owner, address indexed token, uint tokenAmountToConvert, uint dmgAmountBurned);

    // ////////////////////
    // Admin Functions
    // ////////////////////

    /**
     * Sets the `proxy` as a trusted contract, allowing it to interact with the user, on the user's behalf.
     *
     * @param proxy     The address that can interact on the user's behalf.
     * @param isTrusted True if the proxy is trusted or false if it's not (should be removed).
     */
    function approveGloballyTrustedProxy(
        address proxy,
        bool isTrusted
    ) external;

    /**
     * @return  true if the provided `proxy` is globally trusted and may interact with the yield farming contract on a
     *          user's behalf or false otherwise.
     */
    function isGloballyTrustedProxy(
        address proxy
    ) external view returns (bool);

    /**
     * @param token                     The address of the token to be supported for farming.
     * @param underlyingToken           The token to which this token is pegged. IE a Uniswap-V2 LP equity token for
     *                                  DAI-mDAI has an underlying token of DAI.
     * @param underlyingTokenDecimals   The number of decimals that the `underlyingToken` has.
     * @param points                    The amount of reward points for the provided token.
     * @param fees                      The fees to be paid in `underlyingToken` when the user performs a harvest.
     * @param tokenType                 The type of token that is being added. Used for unwrapping it and paying harvest
      *                                 fees.
     */
    function addAllowableToken(
        address token,
        address underlyingToken,
        uint8 underlyingTokenDecimals,
        uint16 points,
        uint16 fees,
        DMGYieldFarmingV2Lib.TokenType tokenType
    ) external;

    /**
     * @param token The address of the token that will be removed from farming.
     */
    function removeAllowableToken(
        address token
    ) external;

    /**
     * Changes the reward points for the provided tokens. Reward points are a weighting system that enables certain
     * tokens to accrue DMG faster than others, allowing the protocol to prioritize certain deposits. At the start of
     * season 1, mETH had points of 100 (equalling 1) and the stablecoins had 200, doubling their weight against mETH.
     */
    function setRewardPointsByTokens(
        address[] calldata tokens,
        uint16[] calldata points
    ) external;

    /**
     * Sets the DMG growth coefficient to use the new parameter provided. This variable is used to define how much
     * DMG is earned every second, for each dollar being farmed accrued.
     */
    function setDmgGrowthCoefficient(
        uint dmgGrowthCoefficient
    ) external;

    /**
     * Begins the farming process so users that accumulate DMG by locking tokens can start for this rotation. Calling
     * this function increments the currentSeasonIndex, starting a new season. This function reverts if there is
     * already an active season.
     *
     * @param dmgAmount The amount of DMG that will be used to fund this campaign.
     */
    function beginFarmingSeason(
        uint dmgAmount
    ) external;

    /**
     * Adds DMG to the already-existing farming season, if there is one. Else, this function reverts.
     *
     * @param dmgAmount The amount of DMG that will be added to the existing campaign.
     */
    function addToFarmingSeason(
        uint dmgAmount
    ) external;

    /**
     * Ends the active farming process if the admin calls this function. Otherwise, anyone may call this function once
     * all DMG have been drained from the contract.
     *
     * @param dustRecipient The recipient of any leftover DMG in this contract, when the campaign finishes.
     */
    function endActiveFarmingSeason(
        address dustRecipient
    ) external;

    function setUnderlyingTokenValuator(
        address underlyingTokenValuator
    ) external;

    function setWethToken(
        address weth
    ) external;

    function setUniswapV2Router(
        address uniswapV2Router
    ) external;

    function setFeesByTokens(
        address[] calldata tokens,
        uint16[] calldata fees
    ) external;

    function setTokenTypeByToken(
        address token,
        DMGYieldFarmingV2Lib.TokenType tokenType
    ) external;

    /**
     * Used to initialize the protocol, mid-season since the Protocol kept track of DMG balances differently on v1.
     */
    function initializeDmgBalance() external;

    // ////////////////////
    // User Functions
    // ////////////////////

    /**
     * Approves the spender from `msg.sender` to transfer funds into the contract on the user's behalf. If `isTrusted`
     * is marked as false, removes the spender.
     */
    function approve(address spender, bool isTrusted) external;

    /**
     * True if the `spender` can transfer tokens on the user's behalf to this contract.
     */
    function isApproved(
        address user,
        address spender
    ) external view returns (bool);

    /**
     * Begins a farm by transferring `amount` of `token` from `user` to this contract and adds it to the balance of
     * `user`. `user` must be either 1) msg.sender or 2) a wallet who has approved msg.sender as a proxy; else this
     * function reverts. `funder` must be either 1) msg.sender or `user`; else this function reverts.
     */
    function beginFarming(
        address user,
        address funder,
        address token,
        uint amount
    ) external;

    /**
     * Ends a farm by transferring all of `token` deposited by `from` to `recipient`, from this contract, as well as
     * all earned DMG for farming `token` to `recipient`. `from` must be either 1) msg.sender or 2) an approved
     * proxy; else this function reverts.
     *
     * @return  The amount of `token` withdrawn and the amount of DMG earned for farming. Both values are sent to
     *          `recipient`.
     */
    function endFarmingByToken(
        address from,
        address recipient,
        address token
    ) external returns (uint, uint);

    /**
     * Ends a farm by transferring `amount` of `token` deposited by `from` to `recipient`, from this contract, as well
     * as a proportional amount of the earned DMG for farming `token` to `recipient`. `from` must be either
     * 1) msg.sender or 2) an approved proxy; else this function reverts.
     *
     * @param from          The user that is ending the harvest
     * @param recipient     The address that should receive the withdrawn token as well as the earned DMG.
     * @param token         The token being withdrawn.
     * @param amount        The balance of the user that should be withdrawn, along with a proportional amount of the
     *                      harvest.
     * @return              The amount of `token` withdrawn and the amount of DMG earned for farming. Both values are
     *                      sent to `recipient`.
     */
    function endFarmingByTokenAndAmount(
        address from,
        address recipient,
        address token,
        uint amount
    ) external returns (uint, uint);

    /**
     * Withdraws all of `msg.sender`'s tokens from the farm to `recipient`. This function reverts if there is an active
     * farm. `user` must be either 1) msg.sender or 2) an approved proxy; else this function reverts.
     *
     * @return  Each token and the amount of each withdrawn.
     */
    function withdrawAllWhenOutOfSeason(
        address user,
        address recipient
    ) external returns (address[] memory, uint[] memory);

    /**
     * Withdraws all of `user` `token` from the farm to `recipient`. This function reverts if there is an active farm and the token is NOT removed.
     * `user` must be either 1) msg.sender or 2) an approved proxy; else this function reverts.
     *
     * @return The amount of tokens sent to `recipient`
     */
    function withdrawByTokenWhenOutOfSeason(
        address user,
        address recipient,
        address token
    ) external returns (uint);

    /**
     * @return  The amount of DMG that this owner has earned in the active farm. If there are no active season, this
     *          function returns `0`.
     */
    function getRewardBalanceByOwner(
        address owner
    ) external view returns (uint);

    /**
     * @return  The amount of DMG that this owner has earned in the active farm for the provided token. If there is no
     *          active season, this function returns `0`.
     */
    function getRewardBalanceByOwnerAndToken(
        address owner,
        address token
    ) external view returns (uint);

    /**
     * @return  The amount of `token` that this owner has deposited into this contract. The user may withdraw this
     *          non-zero balance by invoking `endFarming` or `endFarmingByToken` if there is an active farm. If there is
     *          NO active farm, the user may withdraw his/her funds by invoking
     */
    function balanceOf(
        address owner,
        address token
    ) external view returns (uint);

    /**
     * @return  The most recent timestamp at which the `owner` deposited `token` into the yield farming contract for
     *          the current season. If there is no active season, this function returns `0`.
     */
    function getMostRecentDepositTimestampByOwnerAndToken(
        address owner,
        address token
    ) external view returns (uint64);

    /**
     * @return  The most recent indexed amount of DMG earned by the `owner` for the deposited `token` which is being
     *          farmed for the most-recent season. If there is no active season, this function returns `0`.
     */
    function getMostRecentIndexedDmgEarnedByOwnerAndToken(
        address owner,
        address token
    ) external view returns (uint);

    /**
     * Harvests any earned DMG from the provided token for the given user and farmable token. User must be either
     * 1) `msg.sender` or 2) an approved proxy for `user`. The DMG is sent to `recipient`.
     */
    function harvestDmgByUserAndToken(
        address user,
        address recipient,
        address token
    ) external returns (uint);

    /**
     * Harvests any earned DMG from the provided token for the given user and farmable token. User must be either
     * 1) `msg.sender` or 2) an approved proxy for `user`. The DMG is sent to `recipient`.
     */
    function harvestDmgByUser(
        address user,
        address recipient
    ) external returns (uint);

    /**
     * Gets the underlying token for the corresponding farmable token.
     */
    function getUnderlyingTokenByFarmToken(
        address farmToken
    ) external view returns (address);

    // ////////////////////
    // Misc Functions
    // ////////////////////

    /**
     * @return  The tokens that the farm supports.
     */
    function getFarmTokens() external view returns (address[] memory);

    /**
     * @return  True if the provided token is supported for farming, or false if it's not.
     */
    function isSupportedToken(address token) external view returns (bool);

    /**
     * @return  True if there is an active season for farming, or false if there isn't one.
     */
    function isFarmActive() external view returns (bool);

    function dmmController() external view returns (address);

    /**
     * The address that acts as a "secondary" owner with quicker access to function calling than the owner. Typically,
     * this is the DMMF.
     */
    function guardian() external view returns (address);

    /**
     * @return The DMG token.
     */
    function dmgToken() external view returns (address);

    /**
     * @return  The growth coefficient for earning DMG while farming. Each unit represents how much DMG is earned per
     *          point
     */
    function dmgGrowthCoefficient() external view returns (uint);

    /**
     * @return  The amount of points that the provided token earns for each unit of token deposited. Defaults to `1`
     *          if the provided `token` does not exist or does not have a special weight. This number is `2` decimals.
     */
    function getRewardPointsByToken(address token) external view returns (uint16);

    /**
     * @return  The number of decimals that the underlying token has.
     */
    function getTokenDecimalsByToken(address token) external view returns (uint8);

    /**
     * @return  The type of token this farm token is.
     */
    function getTokenTypeByToken(address token) external view returns (DMGYieldFarmingV2Lib.TokenType);

    /**
     * @return  The index into the array returned from `getFarmTokens`, plus 1. 0 if the token isn't found. If the
     *          index returned is non-zero, subtract 1 from it to get the real index into the array.
     */
    function getTokenIndexPlusOneByToken(address token) external view returns (uint);

    function underlyingTokenValuator() external view returns (address);

    function weth() external view returns (address);

    function uniswapV2Router() external view returns (address);

    function getFeesByToken(address token) external view returns (uint16);

}

// File: contracts/external/farming/v2/DMGYieldFarmingV2.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;










contract DMGYieldFarmingV2 is IDMGYieldFarmingV2, DMGYieldFarmingData {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using DMGYieldFarmingV2Lib for IDMGYieldFarmingV2;

    address constant private ZERO_ADDRESS = address(0);

    modifier isSpenderApproved(address __user) {
        require(
            msg.sender == __user || _globalProxyToIsTrustedMap[msg.sender] || _userToSpenderToIsApprovedMap[__user][msg.sender],
            "DMGYieldFarmingV2:: UNAPPROVED"
        );
        _;
    }

    modifier onlyOwnerOrGuardian {
        require(
            msg.sender == _owner || msg.sender == _guardian,
            "DMGYieldFarmingV2:: UNAUTHORIZED"
        );
        _;
    }

    modifier farmIsActive {
        require(
            _isFarmActive,
            "DMGYieldFarmingV2:: FARM_NOT_ACTIVE"
        );
        _;
    }

    modifier requireIsFarmToken(address __token) {
        require(
            _tokenToIndexPlusOneMap[__token] != 0,
            "DMGYieldFarmingV2:: TOKEN_UNSUPPORTED"
        );
        _;
    }

    modifier farmIsNotActive {
        require(
            !_isFarmActive,
            "DMGYieldFarmingV2:: FARM_IS_ACTIVE"
        );
        _;
    }

    // ////////////////////
    // Admin Functions
    // ////////////////////

    function approveGloballyTrustedProxy(
        address __proxy,
        bool __isTrusted
    )
    public
    nonReentrant
    onlyOwnerOrGuardian {
        _globalProxyToIsTrustedMap[__proxy] = __isTrusted;
        emit GlobalProxySet(__proxy, __isTrusted);
    }

    function isGloballyTrustedProxy(
        address __proxy
    ) public view returns (bool) {
        return _globalProxyToIsTrustedMap[__proxy];
    }

    function addAllowableToken(
        address __token,
        address __underlyingToken,
        uint8 __underlyingTokenDecimals,
        uint16 __points,
        uint16 __fees,
        DMGYieldFarmingV2Lib.TokenType __tokenType
    )
    public
    onlyOwnerOrGuardian
    nonReentrant {
        uint index = _tokenToIndexPlusOneMap[__token];
        require(
            index == 0,
            "DMGYieldFarmingV2::addAllowableToken: TOKEN_ALREADY_SUPPORTED"
        );
        _verifyTokenFee(__fees);
        _verifyTokenType(__tokenType, __underlyingToken, __token, __underlyingTokenDecimals);
        _verifyPoints(__points);

        _tokenToIndexPlusOneMap[__token] = _supportedFarmTokens.push(__token);
        _tokenToFeeAmountMap[__token] = __fees;
        _tokenToRewardPointMap[__token] = __points;
        _tokenToDecimalsMap[__token] = __underlyingTokenDecimals;
        _tokenToTokenType[__token] = __tokenType;
        _tokenToUnderlyingTokenMap[__token] = __underlyingToken;
        emit TokenAdded(__token, __underlyingToken, __underlyingTokenDecimals, __points, __fees);
    }

    function removeAllowableToken(
        address __token
    )
    public
    onlyOwnerOrGuardian
    nonReentrant
    farmIsNotActive {
        uint index = _tokenToIndexPlusOneMap[__token];
        require(
            index != 0,
            "DMGYieldFarmingV2::removeAllowableToken: TOKEN_NOT_SUPPORTED"
        );
        _tokenToIndexPlusOneMap[__token] = 0;
        _tokenToRewardPointMap[__token] = 0;
        delete _supportedFarmTokens[index - 1];
        emit TokenRemoved(__token);
    }

    function beginFarmingSeason(
        uint __dmgAmount
    )
    public
    onlyOwnerOrGuardian
    nonReentrant {
        require(
            !_isFarmActive,
            "DMGYieldFarmingV2::beginFarmingSeason: FARM_ALREADY_ACTIVE"
        );

        _seasonIndex += 1;
        _isFarmActive = true;
        address dmgToken = _dmgToken;
        IERC20(dmgToken).safeTransferFrom(msg.sender, address(this), __dmgAmount);
        _addressToTokenToBalanceMap[ZERO_ADDRESS][dmgToken] = _addressToTokenToBalanceMap[ZERO_ADDRESS][dmgToken].add(__dmgAmount);
        _seasonIndexToStartTimestamp[_seasonIndex] = uint64(block.timestamp);

        emit FarmSeasonBegun(_seasonIndex, __dmgAmount);
    }

    function addToFarmingSeason(
        uint __dmgAmount
    )
    public
    onlyOwnerOrGuardian
    nonReentrant {
        require(
            _isFarmActive,
            "DMGYieldFarmingV2::addToFarmingSeason: FARM_NOT_ACTIVE"
        );

        address dmgToken = _dmgToken;
        IERC20(dmgToken).safeTransferFrom(msg.sender, address(this), __dmgAmount);
        _addressToTokenToBalanceMap[ZERO_ADDRESS][dmgToken] = _addressToTokenToBalanceMap[ZERO_ADDRESS][dmgToken].add(__dmgAmount);

        emit FarmSeasonExtended(_seasonIndex, __dmgAmount);
    }

    function endActiveFarmingSeason(
        address __dustRecipient
    )
    public
    nonReentrant {
        address dmgToken = _dmgToken;
        uint dmgBalance = _getDmgRewardBalance(dmgToken);
        // Anyone can end the farm if the DMG balance has been drawn down to 0.
        require(
            dmgBalance == 0 || msg.sender == owner() || msg.sender == _guardian,
            "DMGYieldFarmingV2::endActiveFarmingSeason: FARM_ACTIVE_OR_INVALID_SENDER"
        );

        _isFarmActive = false;
        if (dmgBalance > 0) {
            IERC20(dmgToken).safeTransfer(__dustRecipient, dmgBalance);
        }

        emit FarmSeasonEnd(_seasonIndex, __dustRecipient, dmgBalance);
    }

    function setDmgGrowthCoefficient(
        uint __dmgGrowthCoefficient
    )
    public
    nonReentrant
    onlyOwnerOrGuardian {
        _verifyDmgGrowthCoefficient(__dmgGrowthCoefficient);

        _dmgGrowthCoefficient = __dmgGrowthCoefficient;
        emit DmgGrowthCoefficientSet(__dmgGrowthCoefficient);
    }

    function setRewardPointsByTokens(
        address[] calldata __tokens,
        uint16[] calldata __points
    )
    external
    nonReentrant
    onlyOwnerOrGuardian {
        require(
            __tokens.length == __points.length,
            "DMGYieldFarmingV2::setRewardPointsByTokens INVALID_PARAMS"
        );

        for (uint i = 0; i < __tokens.length; i++) {
            _setRewardPointsByToken(__tokens[i], __points[i]);
        }
    }

    function setUnderlyingTokenValuator(
        address __underlyingTokenValuator
    )
    onlyOwnerOrGuardian
    nonReentrant
    public {
        require(
            __underlyingTokenValuator != address(0),
            "DMGYieldFarmingV2::setUnderlyingTokenValuator: INVALID_VALUATOR"
        );
        address oldUnderlyingTokenValuator = _underlyingTokenValuator;
        _underlyingTokenValuator = __underlyingTokenValuator;
        emit UnderlyingTokenValuatorChanged(__underlyingTokenValuator, oldUnderlyingTokenValuator);
    }

    function setWethToken(
        address __weth
    )
    onlyOwnerOrGuardian
    nonReentrant
    public {
        require(
            _weth == address(0),
            "DMGYieldFarmingV2::setWethToken: WETH_ALREADY_SET"
        );
        _weth = __weth;
    }

    function setUniswapV2Router(
        address __uniswapV2Router
    )
    onlyOwnerOrGuardian
    nonReentrant
    public {
        require(
            __uniswapV2Router != address(0),
            "DMGYieldFarmingV2::setUnderlyingTokenValuator: INVALID_VALUATOR"
        );
        address oldUniswapV2Router = _uniswapV2Router;
        _uniswapV2Router = __uniswapV2Router;
        emit UniswapV2RouterChanged(__uniswapV2Router, oldUniswapV2Router);
    }

    function setFeesByTokens(
        address[] calldata __tokens,
        uint16[] calldata __fees
    )
    onlyOwnerOrGuardian
    nonReentrant
    external {
        require(
            __tokens.length == __fees.length,
            "DMGYieldFarmingV2::setFeesByTokens: INVALID_PARAMS"
        );

        for (uint i = 0; i < __tokens.length; i++) {
            _setFeeByToken(__tokens[i], __fees[i]);
        }
    }

    function setTokenTypeByToken(
        address __token,
        DMGYieldFarmingV2Lib.TokenType __tokenType
    )
    onlyOwnerOrGuardian
    nonReentrant
    requireIsFarmToken(__token)
    public {
        _verifyTokenType(__tokenType, _tokenToUnderlyingTokenMap[__token], __token, _tokenToDecimalsMap[__token]);
        _tokenToTokenType[__token] = __tokenType;
        emit TokenTypeChanged(__token, __tokenType);
    }

    function initializeDmgBalance() nonReentrant external {
        require(
            !_isDmgBalanceInitialized,
            "DMGYieldFarmingV2::initializeDmgBalance: ALREADY_INITIALIZED"
        );
        _isDmgBalanceInitialized = true;
        _addressToTokenToBalanceMap[ZERO_ADDRESS][_dmgToken] = IERC20(_dmgToken).balanceOf(address(this));
    }

    // ////////////////////
    // Misc Functions
    // ////////////////////

    function getFarmTokens() public view returns (address[] memory) {
        return _supportedFarmTokens;
    }

    function isSupportedToken(address __token) public view returns (bool) {
        return _tokenToIndexPlusOneMap[__token] > 0;
    }

    function isFarmActive() external view returns (bool) {
        return _isFarmActive;
    }

    function dmmController() external view returns (address) {
        return _dmmController;
    }

    function guardian() external view returns (address) {
        return _guardian;
    }

    function dmgToken() external view returns (address) {
        return _dmgToken;
    }

    function dmgGrowthCoefficient() external view returns (uint) {
        return _dmgGrowthCoefficient;
    }

    function getRewardPointsByToken(
        address __token
    ) public view returns (uint16) {
        uint16 rewardPoints = _tokenToRewardPointMap[__token];
        return rewardPoints == 0 ? POINTS_FACTOR : rewardPoints;
    }

    function getTokenDecimalsByToken(
        address __token
    ) public view returns (uint8) {
        return _tokenToDecimalsMap[__token];
    }

    function getTokenIndexPlusOneByToken(
        address __token
    ) public view returns (uint) {
        return _tokenToIndexPlusOneMap[__token];
    }

    function getTokenTypeByToken(
        address __token
    ) public view returns (DMGYieldFarmingV2Lib.TokenType) {
        return _tokenToTokenType[__token];
    }

    // ////////////////////
    // User Functions
    // ////////////////////

    function approve(
        address __spender,
        bool __isTrusted
    ) public {
        _userToSpenderToIsApprovedMap[msg.sender][__spender] = __isTrusted;
        emit Approval(msg.sender, __spender, __isTrusted);
    }

    function isApproved(
        address __user,
        address __spender
    ) public view returns (bool) {
        return _userToSpenderToIsApprovedMap[__user][__spender];
    }

    function beginFarming(
        address __user,
        address __funder,
        address __token,
        uint __amount
    )
    public
    farmIsActive
    requireIsFarmToken(__token)
    isSpenderApproved(__user)
    nonReentrant {
        require(
            __funder == msg.sender || __funder == __user,
            "DMGYieldFarmingV2::beginFarming: INVALID_FUNDER"
        );

        if (__amount > 0) {
            // In case the __user is reusing a non-zero balance they had before the start of this farm.
            IERC20(__token).safeTransferFrom(__funder, address(this), __amount);
        }

        // We reindex before adding to the __user's balance, because the indexing process takes the __user's CURRENT
        // balance and applies their earnings, so we can account for new deposits.
        _reindexEarningsByTimestamp(__user, __token);

        if (__amount > 0) {
            _addressToTokenToBalanceMap[__user][__token] = _addressToTokenToBalanceMap[__user][__token].add(__amount);
        }

        emit BeginFarming(__user, __token, __amount);
    }

    function endFarmingByToken(
        address __user,
        address __recipient,
        address __token
    )
    public
    farmIsActive
    requireIsFarmToken(__token)
    isSpenderApproved(__user)
    nonReentrant
    returns (uint, uint) {
        return _endFarmingByTokenAndAmount(
            __user,
            __recipient,
            __token,
            _addressToTokenToBalanceMap[__user][__token]
        );
    }

    function endFarmingByTokenAndAmount(
        address __user,
        address __recipient,
        address __token,
        uint __withdrawalAmount
    )
    public
    farmIsActive
    requireIsFarmToken(__token)
    isSpenderApproved(__user)
    nonReentrant
    returns (uint, uint) {
        return _endFarmingByTokenAndAmount(
            __user,
            __recipient,
            __token,
            __withdrawalAmount
        );
    }

    function withdrawAllWhenOutOfSeason(
        address __user,
        address __recipient
    )
    public
    farmIsNotActive
    isSpenderApproved(__user)
    nonReentrant
    returns (address[] memory, uint[] memory) {
        address[] memory farmTokens = _supportedFarmTokens;
        uint[] memory withdrawnAmounts = new uint[](farmTokens.length);
        for (uint i = 0; i < farmTokens.length; i++) {
            withdrawnAmounts[i] = _withdrawByTokenWhenOutOfSeason(__user, __recipient, farmTokens[i]);
        }
        return (farmTokens, withdrawnAmounts);
    }

    function withdrawByTokenWhenOutOfSeason(
        address __user,
        address __recipient,
        address __token
    )
    isSpenderApproved(__user)
    nonReentrant
    public returns (uint) {
        // The __user can only withdraw this way if the farm is NOT active or if the __token is no longer supported.
        require(
            !_isFarmActive || _tokenToIndexPlusOneMap[__token] == 0,
            "DMGYieldFarmingV2::withdrawByTokenWhenOutOfSeason: FARM_ACTIVE_OR_TOKEN_SUPPORTED"
        );

        return _withdrawByTokenWhenOutOfSeason(__user, __recipient, __token);
    }

    function getRewardBalanceByOwner(
        address __owner
    ) public view returns (uint) {
        if (_isFarmActive) {
            return _getTotalRewardBalanceByUser(__owner, _seasonIndex);
        } else {
            return 0;
        }
    }

    function getRewardBalanceByOwnerAndToken(
        address __owner,
        address __token
    ) public view returns (uint) {
        if (_isFarmActive) {
            return _getTotalRewardBalanceByUserAndToken(__owner, __token, _seasonIndex);
        } else {
            return 0;
        }
    }

    function getUsdBalanceByOwnerAndToken(
        address __owner,
        address __token
    ) public view returns (uint) {
        uint balance = _addressToTokenToBalanceMap[__owner][__token];
        return DMGYieldFarmingV2Lib._getUsdValueByTokenAndTokenAmount(this, __token, balance);
    }

    function balanceOf(
        address __owner,
        address __token
    ) public view returns (uint) {
        return _addressToTokenToBalanceMap[__owner][__token];
    }

    function getMostRecentDepositTimestampByOwnerAndToken(
        address __owner,
        address __token
    ) public view returns (uint64) {
        if (_isFarmActive) {
            return _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][__owner][__token];
        } else {
            return 0;
        }
    }

    function getMostRecentIndexedDmgEarnedByOwnerAndToken(
        address __owner,
        address __token
    ) public view returns (uint) {
        if (_isFarmActive) {
            return _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][__owner][__token];
        } else {
            return 0;
        }
    }

    function harvestDmgByUserAndToken(
        address __user,
        address __recipient,
        address __token
    )
    requireIsFarmToken(__token)
    farmIsActive
    isSpenderApproved(__user)
    nonReentrant
    public returns (uint) {
        uint tokenBalance = _addressToTokenToBalanceMap[__user][__token];
        return _harvestDmgByUserAndToken(__user, __recipient, __token, tokenBalance);
    }

    function harvestDmgByUser(
        address __user,
        address __recipient
    )
    farmIsActive
    isSpenderApproved(__user)
    nonReentrant
    public returns (uint) {
        address[] memory farmTokens = _supportedFarmTokens;
        uint totalEarnedDmgAmount = 0;
        for (uint i = 0; i < farmTokens.length; i++) {
            uint farmTokenBalance = _addressToTokenToBalanceMap[__user][farmTokens[i]];
            if (farmTokenBalance > 0) {
                uint earnedDmgAmount = _harvestDmgByUserAndToken(__user, __recipient, farmTokens[i], farmTokenBalance);
                totalEarnedDmgAmount = totalEarnedDmgAmount.add(earnedDmgAmount);
            }
        }
        return totalEarnedDmgAmount;
    }

    function getUnderlyingTokenByFarmToken(
        address __farmToken
    ) public view returns (address) {
        return _tokenToUnderlyingTokenMap[__farmToken];
    }

    function underlyingTokenValuator() external view returns (address) {
        return _underlyingTokenValuator;
    }

    function weth() external view returns (address) {
        return _weth;
    }

    function uniswapV2Router() external view returns (address) {
        return _uniswapV2Router;
    }

    function getFeesByToken(
        address __token
    ) public view returns (uint16) {
        uint16 fee = _tokenToFeeAmountMap[__token];
        return fee == 0 ? 100 : fee;
    }

    // ////////////////////
    // Internal Functions
    // ////////////////////

    function _endFarmingByTokenAndAmount(
        address __user,
        address __recipient,
        address __token,
        uint __withdrawalAmount
    ) internal returns (uint, uint) {
        (uint feeAmount, uint earnedDmgAmount) = _doHarvest(
            __user,
            __recipient,
            __token,
            __withdrawalAmount,
            _dmgToken
        );

        _addressToTokenToBalanceMap[__user][__token] = _addressToTokenToBalanceMap[__user][__token].sub(__withdrawalAmount);
        // The __user withdraws (__withdrawalAmount - fee) amount.
        __withdrawalAmount = __withdrawalAmount.sub(feeAmount);
        IERC20(__token).safeTransfer(__recipient, __withdrawalAmount);

        emit EndFarming(__user, __token, __withdrawalAmount, earnedDmgAmount);

        return (__withdrawalAmount, earnedDmgAmount);
    }

    /**
     * This function updates state for the tracked amount of DMG that the user has earned. This function DOES NOT
     * update state for the user's balance.
     *
     * @return The amount of `__token` paid in fees and the amount of DMG earned and sent to recipient.
     */
    function _doHarvest(
        address __user,
        address __recipient,
        address __token,
        uint __harvestAmount,
        address __dmg
    ) internal returns (uint, uint) {
        require(
            __harvestAmount > 0,
            "DMGYieldFarmingV2::_doHarvest: ZERO_HARVEST_AMOUNT"
        );

        uint tokenBalance = _addressToTokenToBalanceMap[__user][__token];
        require(
            __harvestAmount <= tokenBalance,
            "DMGYieldFarmingV2::_doHarvest: INSUFFICIENT_BALANCE"
        );

        uint earnedDmgAmount = _getTotalRewardBalanceByUserAndToken(__user, __token, _seasonIndex);
        // Scale the amount of DMG earned by the user's balance and how much it's being harvested against
        uint scaledEarnedDmgAmount = earnedDmgAmount.mul(__harvestAmount).div(tokenBalance);
        require(
            scaledEarnedDmgAmount > 0,
            "DMGYieldFarmingV2::_doHarvest: ZERO_EARNED"
        );

        uint contractDmgRewardBalance = _getDmgRewardBalance(__dmg);
        uint scaledHarvestAmount = __harvestAmount;
        if (scaledEarnedDmgAmount > contractDmgRewardBalance) {
            // Proportionally scale down the amounts to how much DMG is actually going to be redeemed
            scaledHarvestAmount = scaledHarvestAmount.mul(contractDmgRewardBalance).div(scaledEarnedDmgAmount);
            scaledEarnedDmgAmount = contractDmgRewardBalance;
            require(
                scaledEarnedDmgAmount > 0,
                "DMGYieldFarmingV2::_doHarvest: SCALED_ZERO_EARNED"
            );
        }
        _addressToTokenToBalanceMap[ZERO_ADDRESS][__dmg] = _addressToTokenToBalanceMap[ZERO_ADDRESS][__dmg].sub(scaledEarnedDmgAmount);

        uint feeAmount = DMGYieldFarmingV2Lib._payHarvestFee(this, __user, __token, scaledHarvestAmount);
        IERC20(__dmg).safeTransfer(__recipient, scaledEarnedDmgAmount);

        // We set the earned dmg this user has acquired to the earned amount, minus what was actually withdrawn
        _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][__user][__token] = earnedDmgAmount.sub(scaledEarnedDmgAmount);
        _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][__user][__token] = uint64(block.timestamp);

        return (feeAmount, scaledEarnedDmgAmount);
    }

    function _setFeeByToken(
        address __token,
        uint16 __fee
    ) internal {
        _verifyTokenFee(__fee);
        _tokenToFeeAmountMap[__token] = __fee;
        emit FeesChanged(__token, __fee);
    }

    function _setRewardPointsByToken(
        address __token,
        uint16 __points
    ) internal {
        _verifyPoints(__points);
        _tokenToRewardPointMap[__token] = __points;
        emit RewardPointsSet(__token, __points);
    }

    function _verifyDmgGrowthCoefficient(
        uint __dmgGrowthCoefficient
    ) internal pure {
        require(
            __dmgGrowthCoefficient > 0,
            "DMGYieldFarmingV2::_verifyDmgGrowthCoefficient: INVALID_GROWTH_COEFFICIENT"
        );
    }

    function _verifyTokenType(
        DMGYieldFarmingV2Lib.TokenType __tokenType,
        address __underlyingToken,
        address __farmToken,
        uint8 __farmTokenDecimals
    ) internal {
        require(
            __tokenType != DMGYieldFarmingV2Lib.TokenType.Unknown,
            "DMGYieldFarmingV2::_verifyTokenType: INVALID_TYPE"
        );

        if (__tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapLpToken) {
            address __uniswapV2Router = _uniswapV2Router;
            if (IERC20(__underlyingToken).allowance(address(this), __uniswapV2Router) == 0) {
                IERC20(__underlyingToken).safeApprove(__uniswapV2Router, uint(- 1));
            }
        } else if (__tokenType == DMGYieldFarmingV2Lib.TokenType.UniswapPureLpToken) {
            address __uniswapV2Router = _uniswapV2Router;
            if (IERC20(__underlyingToken).allowance(address(this), __uniswapV2Router) == 0) {
                IERC20(__underlyingToken).safeApprove(__uniswapV2Router, uint(- 1));
            }
            uint8 token0Decimals = IERC20WithDecimals(IUniswapV2Pair(__farmToken).token0()).decimals();
            uint8 token1Decimals = IERC20WithDecimals(IUniswapV2Pair(__farmToken).token1()).decimals();
            require(
                token0Decimals == __farmTokenDecimals,
                "DMGYieldFarmingV2::_verifyTokenType: INVALID_TOKEN_0_DECIMALS"
            );
            require(
                token1Decimals == __farmTokenDecimals,
                "DMGYieldFarmingV2::_verifyTokenType: INVALID_TOKEN_1_DECIMALS"
            );
        }
    }

    function _verifyTokenFee(
        uint16 __fee
    ) internal pure {
        require(
            __fee < FEE_AMOUNT_FACTOR,
            "DMGYieldFarmingV2::_verifyTokenFee: INVALID_FEES"
        );
    }

    function _verifyPoints(
        uint16 __points
    ) internal pure {
        require(
            __points > 0,
            "DMGYieldFarmingV2::_verifyPoints: INVALID_POINTS"
        );
    }

    function _getDmgRewardBalance(
        address __dmgToken
    ) internal view returns (uint) {
        return _addressToTokenToBalanceMap[ZERO_ADDRESS][__dmgToken];
    }

    /**
     * @return  The amount of DMG earned by __user and sent to __recipient
     */
    function _harvestDmgByUserAndToken(
        address __user,
        address __recipient,
        address __token,
        uint __tokenBalance
    ) internal returns (uint) {
        (uint feeAmount, uint earnedDmgAmount) = _doHarvest(
            __user,
            __recipient,
            __token,
            __tokenBalance,
            _dmgToken
        );

        _addressToTokenToBalanceMap[__user][__token] = _addressToTokenToBalanceMap[__user][__token].sub(feeAmount);

        emit Harvest(__user, __token, earnedDmgAmount);

        return earnedDmgAmount;
    }

    function _getUnindexedRewardsByUserAndToken(
        address __owner,
        address __token,
        uint64 __previousIndexTimestamp
    ) internal view returns (uint) {
        uint balance = _addressToTokenToBalanceMap[__owner][__token];

        if (balance > 0 && __previousIndexTimestamp != 0) {
            uint usdValue = DMGYieldFarmingV2Lib._getUsdValueByTokenAndTokenAmount(this, __token, balance);
            uint16 points = getRewardPointsByToken(__token);
            return _calculateRewardBalance(
                usdValue,
                points,
                _dmgGrowthCoefficient,
                block.timestamp,
                __previousIndexTimestamp
            );
        } else {
            return 0;
        }
    }

    function _reindexEarningsByTimestamp(
        address __user,
        address __token
    ) internal {
        uint seasonIndex = _seasonIndex;
        uint64 previousIndexTimestamp = _seasonIndexToUserToTokenToDepositTimestampMap[seasonIndex][__user][__token];
        if (previousIndexTimestamp != 0) {
            uint dmgEarnedAmount = _getUnindexedRewardsByUserAndToken(__user, __token, previousIndexTimestamp);
            if (dmgEarnedAmount > 0) {
                _seasonIndexToUserToTokenToEarnedDmgAmountMap[seasonIndex][__user][__token] = _seasonIndexToUserToTokenToEarnedDmgAmountMap[seasonIndex][__user][__token].add(dmgEarnedAmount);
            }
        }
        _seasonIndexToUserToTokenToDepositTimestampMap[seasonIndex][__user][__token] = uint64(block.timestamp);
    }

    function _getTotalRewardBalanceByUserAndToken(
        address __owner,
        address __token,
        uint __seasonIndex
    ) internal view returns (uint) {
        uint64 previousIndexTimestamp = _seasonIndexToUserToTokenToDepositTimestampMap[__seasonIndex][__owner][__token];
        if (previousIndexTimestamp == 0) {
            // If the user has not deposited yet for this season, default to the season's start time. Why? Because this
            // allows the user's balance to carry over from season to season, assuming that the user deposited in a
            // prior season and left a non-zero balance.
            previousIndexTimestamp = _seasonIndexToStartTimestamp[__seasonIndex];
        }

        return _getUnindexedRewardsByUserAndToken(__owner, __token, previousIndexTimestamp)
        .add(_seasonIndexToUserToTokenToEarnedDmgAmountMap[__seasonIndex][__owner][__token]);
    }

    function _calculateRewardBalance(
        uint __usdValue,
        uint16 __points,
        uint __dmgGrowthCoefficient,
        uint __currentTimestamp,
        uint __previousIndexTimestamp
    ) internal pure returns (uint) {
        if (__usdValue == 0) {
            return 0;
        } else {
            uint elapsedTime = __currentTimestamp.sub(__previousIndexTimestamp);
            // The number returned here has 18 decimal places (same as USD value), which is the same number as DMG.
            // Perfect.
            return elapsedTime
            .mul(__dmgGrowthCoefficient)
            .mul(__usdValue)
            .div(DMG_GROWTH_COEFFICIENT_FACTOR)
            .mul(__points)
            .div(POINTS_FACTOR);
        }
    }

    function _getTotalRewardBalanceByUser(
        address __owner,
        uint __seasonIndex
    ) internal view returns (uint) {
        address[] memory supportedFarmTokens = _supportedFarmTokens;
        uint totalDmgEarned = 0;
        for (uint i = 0; i < supportedFarmTokens.length; i++) {
            totalDmgEarned = totalDmgEarned.add(_getTotalRewardBalanceByUserAndToken(__owner, supportedFarmTokens[i], __seasonIndex));
        }
        return totalDmgEarned;
    }

    function _withdrawByTokenWhenOutOfSeason(
        address __user,
        address __recipient,
        address __token
    ) internal returns (uint) {
        uint amount = _addressToTokenToBalanceMap[__user][__token];
        if (amount > 0) {
            _addressToTokenToBalanceMap[__user][__token] = 0;
            IERC20(__token).safeTransfer(__recipient, amount);
        }

        emit WithdrawOutOfSeason(__user, __token, __recipient, amount);

        return amount;
    }

}
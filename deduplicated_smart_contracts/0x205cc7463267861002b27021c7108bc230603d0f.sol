/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity 0.5.15;

contract YamGoverned {
    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {
        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {
        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {
        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract YamSubGoverned is YamGoverned {
    /**
     * @notice Event emitted when a sub gov is enabled/disabled
     */
    event SubGovModified(
        address account,
        bool isSubGov
    );
    /// @notice sub governors
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {
        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

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
        (bool success, ) = recipient.call.value(amount)("");
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
        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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

interface UniswapPair {
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

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
library Babylonian {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // take the reciprocal of a UQ112x112
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair,
        bool isToken0
    ) internal view returns (uint priceCumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = UniswapPair(pair).getReserves();
        if (isToken0) {
          priceCumulative = UniswapPair(pair).price0CumulativeLast();

          // if time has elapsed since the last update on the pair, mock the accumulated price values
          if (blockTimestampLast != blockTimestamp) {
              // subtraction overflow is desired
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              // addition overflow is desired
              // counterfactual
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        } else {
          priceCumulative = UniswapPair(pair).price1CumulativeLast();
          // if time has elapsed since the last update on the pair, mock the accumulated price values
          if (blockTimestampLast != blockTimestamp) {
              // subtraction overflow is desired
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              // addition overflow is desired
              // counterfactual
              priceCumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
          }
        }

    }
}

interface ExpandedERC20 {
  function decimals() external view returns (uint8);
}

contract TWAPBound is YamSubGoverned {
    using SafeMath for uint256;

    uint256 public constant BASE = 10**18;

    /// @notice For a sale of a specific amount
    uint256 public sell_amount;

    /// @notice For a purchase of a specific amount
    uint256 public purchase_amount;

    /// @notice Token to be sold
    address public sell_token;

    /// @notice Token to be puchased
    address public purchase_token;

    /// @notice Current uniswap pair for purchase & sale tokens
    address public uniswap_pair1;

    /// @notice Second uniswap pair for if TWAP uses two markets to determine price (for liquidity purposes)
    address public uniswap_pair2;

    /// @notice Flag for if purchase token is toke 0 in uniswap pair 2
    bool public purchaseTokenIs0;

    /// @notice Flag for if sale token is token 0 in uniswap pair
    bool public saleTokenIs0;

    /// @notice TWAP for first hop
    uint256 public priceAverageSell;

    /// @notice TWAP for second hop
    uint256 public priceAverageBuy;

    /// @notice last TWAP update time
    uint32 public blockTimestampLast;

    /// @notice last TWAP cumulative price;
    uint256 public priceCumulativeLastSell;

    /// @notice last TWAP cumulative price for two hop pairs;
    uint256 public priceCumulativeLastBuy;

    /// @notice Time between TWAP updates
    uint256 public period;

    /// @notice counts number of twaps
    uint256 public twap_counter;

    /// @notice Grace period after last twap update for a trade to occur
    uint256 public grace = 60 * 60; // 1 hour

    uint256 public constant MAX_BOUND = 10**17;

    /// @notice % bound away from TWAP price
    uint256 public twap_bounds;

    /// @notice denotes a trade as complete
    bool public complete;

    bool public isSale;

    function setup_twap_bound (
        address sell_token_,
        address purchase_token_,
        uint256 amount_,
        bool is_sale,
        uint256 twap_period,
        uint256 twap_bounds_,
        address uniswap1,
        address uniswap2, // if two hop
        uint256 grace_ // length after twap update that it can occur
    )
        public
        onlyGovOrSubGov
    {
        require(twap_bounds_ <= MAX_BOUND, "slippage too high");
        sell_token = sell_token_;
        purchase_token = purchase_token_;
        period = twap_period;
        twap_bounds = twap_bounds_;
        isSale = is_sale;
        if (is_sale) {
            sell_amount = amount_;
            purchase_amount = 0;
        } else {
            purchase_amount = amount_;
            sell_amount = 0;
        }

        complete = false;
        grace = grace_;
        reset_twap(uniswap1, uniswap2, sell_token, purchase_token);
    }

    function reset_twap(
        address uniswap1,
        address uniswap2,
        address sell_token_,
        address purchase_token_
    )
        internal
    {
        uniswap_pair1 = uniswap1;
        uniswap_pair2 = uniswap2;

        blockTimestampLast = 0;
        priceCumulativeLastSell = 0;
        priceCumulativeLastBuy = 0;
        priceAverageBuy = 0;

        if (UniswapPair(uniswap1).token0() == sell_token_) {
            saleTokenIs0 = true;
        } else {
            saleTokenIs0 = false;
        }

        if (uniswap2 != address(0)) {
            if (UniswapPair(uniswap2).token0() == purchase_token_) {
                purchaseTokenIs0 = true;
            } else {
                purchaseTokenIs0 = false;
            }
        }

        update_twap();
        twap_counter = 0;
    }

    function quote(
      uint256 purchaseAmount,
      uint256 saleAmount
    )
      public
      view
      returns (uint256)
    {
      uint256 decs = uint256(ExpandedERC20(sell_token).decimals());
      uint256 one = 10**decs;
      return purchaseAmount.mul(one).div(saleAmount);
    }

    function bounds()
        public
        view
        returns (uint256)
    {
        uint256 uniswap_quote = consult();
        uint256 minimum = uniswap_quote.mul(BASE.sub(twap_bounds)).div(BASE);
        return minimum;
    }

    function bounds_max()
        public
        view
        returns (uint256)
    {
        uint256 uniswap_quote = consult();
        uint256 maximum = uniswap_quote.mul(BASE.add(twap_bounds)).div(BASE);
        return maximum;
    }


    function withinBounds (
        uint256 purchaseAmount,
        uint256 saleAmount
    )
        internal
        view
        returns (bool)
    {
        uint256 quoted = quote(purchaseAmount, saleAmount);
        uint256 minimum = bounds();
        uint256 maximum = bounds_max();
        return quoted > minimum && quoted < maximum;
    }

    function withinBoundsWithQuote (
        uint256 quoted
    )
        internal
        view
        returns (bool)
    {
        uint256 minimum = bounds();
        uint256 maximum = bounds_max();
        return quoted > minimum && quoted < maximum;
    }

    // callable by anyone
    function update_twap()
        public
    {
        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair1, saleTokenIs0);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= period, 'OTC: PERIOD_NOT_ELAPSED');

        // overflow is desired
        priceAverageSell = uint256(uint224((sell_token_priceCumulative - priceCumulativeLastSell) / timeElapsed));
        priceCumulativeLastSell = sell_token_priceCumulative;


        if (uniswap_pair2 != address(0)) {
            // two hop
            (uint256 buy_token_priceCumulative, ) =
                UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair2, !purchaseTokenIs0);
            priceAverageBuy = uint256(uint224((buy_token_priceCumulative - priceCumulativeLastBuy) / timeElapsed));

            priceCumulativeLastBuy = buy_token_priceCumulative;
        }

        twap_counter = twap_counter.add(1);

        blockTimestampLast = blockTimestamp;
    }

    function consult()
        public
        view
        returns (uint256)
    {
        if (uniswap_pair2 != address(0)) {
            // two hop
            uint256 purchasePrice;
            uint256 salePrice;
            uint256 one;
            if (saleTokenIs0) {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }

            if (priceAverageSell > uint192(-1)) {
               // eat loss of precision
               // effectively: (x / 2**112) * 1e18
               purchasePrice = (priceAverageSell >> 112) * one;
            } else {
              // cant overflow
              // effectively: (x * 1e18 / 2**112)
              purchasePrice = (priceAverageSell * one) >> 112;
            }

            if (purchaseTokenIs0) {
                uint8 decs = ExpandedERC20(UniswapPair(uniswap_pair2).token1()).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(UniswapPair(uniswap_pair2).token0()).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }

            if (priceAverageBuy > uint192(-1)) {
                salePrice = (priceAverageBuy >> 112) * one;
            } else {
                salePrice = (priceAverageBuy * one) >> 112;
            }

            return purchasePrice.mul(salePrice).div(one);

        } else {
            uint256 one;
            if (saleTokenIs0) {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            } else {
                uint8 decs = ExpandedERC20(sell_token).decimals();
                require(decs <= 18, "too many decimals");
                one = 10**uint256(decs);
            }
            // single hop
            uint256 purchasePrice;
            if (priceAverageSell > uint192(-1)) {
               // eat loss of precision
               // effectively: (x / 2**112) * 1e18
               purchasePrice = (priceAverageSell >> 112) * one;
            } else {
                // cant overflow
                // effectively: (x * 1e18 / 2**112)
                purchasePrice = (priceAverageSell * one) >> 112;
            }
            return purchasePrice;
        }
    }

    function recencyCheck()
        internal
        returns (bool)
    {
        return (block.timestamp - blockTimestampLast < grace) && (twap_counter > 0);
    }
}

/// Helper for a reserve contract to perform uniswap, price bound actions
contract ReserveUniHelper is TWAPBound {

    event NewReserves(address oldReserves, address NewReserves);

    address public reserves;

    function _getLPToken()
        internal
    {
        require(!complete, "Action complete");

        uint256 amount_;
        if (isSale) {
          amount_ = sell_amount;
        } else {
          amount_ = purchase_amount;
        }
        // early return
        if (amount_ == 0) {
          complete = true;
          return;
        }

        require(recencyCheck(), "TWAP needs updating");

        uint256 bal_of_a = IERC20(sell_token).balanceOf(reserves);
        
        if (amount_ > bal_of_a) {
            // cap to bal
            amount_ = bal_of_a;
        }

        (uint256 reserve0, uint256 reserve1, ) = UniswapPair(uniswap_pair1).getReserves();
        uint256 quoted;
        if (saleTokenIs0) {
            quoted = quote(reserve1, reserve0);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        } else {
            quoted = quote(reserve0, reserve1);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        }

        uint256 amount_b;
        {
          uint256 decs = uint256(ExpandedERC20(sell_token).decimals());
          uint256 one = 10**decs;
          amount_b = quoted.mul(amount_).div(one);
        }


        uint256 bal_of_b = IERC20(purchase_token).balanceOf(reserves);
        if (amount_b > bal_of_b) {
            // we set the limit token as the sale token, but that could change
            // between proposal and execution.
            // limit amount_ and amount_b
            amount_b = bal_of_b;

            // reverse quote
            if (!saleTokenIs0) {
                quoted = quote(reserve1, reserve0);
            } else {
                quoted = quote(reserve0, reserve1);
            }
            // recalculate a
            uint256 decs = uint256(ExpandedERC20(purchase_token).decimals());
            uint256 one = 10**decs;
            amount_ = quoted.mul(amount_b).div(one);
        }

        IERC20(sell_token).transferFrom(reserves, uniswap_pair1, amount_);
        IERC20(purchase_token).transferFrom(reserves, uniswap_pair1, amount_b);
        UniswapPair(uniswap_pair1).mint(address(this));
        complete = true;
    }

    function _getUnderlyingToken(
        bool skip_this
    )
        internal
    {
        require(!complete, "Action complete");
        require(recencyCheck(), "TWAP needs updating");

        (uint256 reserve0, uint256 reserve1, ) = UniswapPair(uniswap_pair1).getReserves();
        uint256 quoted;
        if (saleTokenIs0) {
            quoted = quote(reserve1, reserve0);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        } else {
            quoted = quote(reserve0, reserve1);
            require(withinBoundsWithQuote(quoted), "!in_bounds, uni reserve manipulation");
        }

        // transfer lp tokens back, burn
        if (skip_this) {
          IERC20(uniswap_pair1).transfer(uniswap_pair1, IERC20(uniswap_pair1).balanceOf(address(this)));
          UniswapPair(uniswap_pair1).burn(reserves);
        } else {
          IERC20(uniswap_pair1).transfer(uniswap_pair1, IERC20(uniswap_pair1).balanceOf(address(this)));
          UniswapPair(uniswap_pair1).burn(address(this));
        }
        complete = true;
    }

    function _setReserves(address new_reserves)
        public
        onlyGovOrSubGov
    {
        address old_res = reserves;
        reserves = new_reserves;
        emit NewReserves(old_res, reserves);
    }
}

interface IndexStaker {
    function stake(uint256) external;
    function withdraw(uint256) external;
    function getReward() external;
    function exit() external;
    function balanceOf(address) external view returns (uint256);
}

contract IndexStaking2 is ReserveUniHelper {

    constructor(address pendingGov_, address reserves_) public {
        gov = msg.sender;
        pendingGov = pendingGov_;
        reserves = reserves_;
        IERC20(lp).approve(address(staking), uint256(-1));
    }

    IndexStaker public staking = IndexStaker(0xB93b505Ed567982E2b6756177ddD23ab5745f309);

    address public lp = address(0x4d5ef58aAc27d99935E5b6B4A6778ff292059991);

    function currentStake()
        public
        view
        returns (uint256)
    {
        return staking.balanceOf(address(this));
    }

    // callable by anyone assuming twap bounds checks
    function stake()
        public
    {
        _getLPToken();
        uint256 amount = IERC20(lp).balanceOf(address(this));
        staking.stake(amount);
    }

    // callable by anyone assuming twap bounds checks
    function getUnderlying()
        public
    {
        _getUnderlyingToken(true);
    }

    // ========= STAKING ========
    function _stakeCurrentLPBalance()
        public
        onlyGovOrSubGov
    {
        uint256 amount = IERC20(lp).balanceOf(address(this));
        staking.stake(amount);
    }

    function _approveStakingFromReserves(
        bool isToken0Limited,
        uint256 amount
    )
        public
        onlyGovOrSubGov
    {
        if (isToken0Limited) {
          setup_twap_bound(
              UniswapPair(lp).token0(), // The limiting asset
              UniswapPair(lp).token1(),
              amount, // amount of token0
              true, // is sale
              60 * 60, // 1 hour
              5 * 10**15, // .5%
              lp,
              address(0), // if two hop
              60 * 60 // length after twap update that it can occur
          );
        } else {
          setup_twap_bound(
              UniswapPair(lp).token1(), // The limiting asset
              UniswapPair(lp).token0(),
              amount, // amount of token1
              true, // is sale
              60 * 60, // 1 hour
              5 * 10**15, // .5%
              lp,
              address(0), // if two hop
              60 * 60 // length after twap update that it can occur
          );
        }
    }
    // ============================

    // ========= EXITING ==========
    function _exitStaking()
        public
        onlyGovOrSubGov
    {
        staking.exit();
    }

    function _exitAndApproveGetUnderlying()
        public
        onlyGovOrSubGov
    {
        staking.exit();
        setup_twap_bound(
            UniswapPair(lp).token0(), // doesnt really matter
            UniswapPair(lp).token1(), // doesnt really matter
            staking.balanceOf(address(this)), // amount of LP tokens
            true, // is sale
            60 * 60, // 1 hour
            5 * 10**15, // .5%
            lp,
            address(0), // if two hop
            60 * 60 // length after twap update that it can occur
        );
    }

    function _exitStakingEmergency()
        public
        onlyGovOrSubGov
    {
        staking.withdraw(staking.balanceOf(address(this)));
    }

    function _exitStakingEmergencyAndApproveGetUnderlying()
        public
        onlyGovOrSubGov
    {
        staking.withdraw(staking.balanceOf(address(this)));
        setup_twap_bound(
            UniswapPair(lp).token0(), // doesnt really matter
            UniswapPair(lp).token1(), // doesnt really matter
            staking.balanceOf(address(this)), // amount of LP tokens
            true, // is sale
            60 * 60, // 1 hour
            5 * 10**15, // .5%
            lp,
            address(0), // if two hop
            60 * 60 // length after twap update that it can occur
        );
    }
    // ============================


    function _getTokenFromHere(address token)
        public
        onlyGovOrSubGov
    {
        IERC20 t = IERC20(token);
        t.transfer(reserves, t.balanceOf(address(this)));
    }
}
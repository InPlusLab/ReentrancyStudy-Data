/**
 *Submitted for verification at Etherscan.io on 2021-08-02
*/

// SPDX-License-Identifier: MIT
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
    
    function decimals() external view returns (uint8);

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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

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
    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _governance;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}

// File: contracts/strategies/StabilizeStrategyUSTArbV4.sol

pragma solidity =0.6.6;

// This is a strategy that takes advantage of arb opportunities for ust
// It can trade on both curve and Uniswap V2
// Half the profit earned from the sell will be used to buy WETH and split it between the treasury, executor and staking pool
// Half will remain 

interface StabilizeStakingPool {
    function notifyRewardAmount(uint256) external;
}

interface UniswapRouter {
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory); // For a value in, it calculates value out
}

interface CurvePool {
    function get_dy_underlying(int128, int128, uint256) external view returns (uint256); // Get quantity estimate
    function exchange_underlying(int128, int128, uint256, uint256) external; // Exchange tokens
}

interface AggregatorV3Interface {
  function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract StabilizeStrategyUSTArbV4 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant DIVISION_FACTOR = 100000;
    uint256 public lastTradeTime = 0;
    uint256 public lastActionBalance = 0; // Balance before last deposit or withdraw
    uint256 public maxPoolSize = 3000000e18; // The maximum amount of ust tokens this strategy can hold, 3 mil by default
    uint256 public percentTradeTrigger = 10000; // 10% change in value will trigger a trade
    uint256 public maxPercentSell = 80000; // 80% of the tokens are sold to the cheapest token if slippage is ok on Uni
    uint256 public maxAmountSell = 500000; // The maximum amount of tokens that can be sold at once
    uint256 public percentDepositor = 50000; // 1000 = 1%, depositors earn 50% of all gains
    uint256 public percentExecutor = 10000; // 30000 = 30% of WETH goes to executor, 15% of total profit
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    uint256 public minTradeSplit = 20000; // If the balance is less than or equal to this, it trades the entire balance
    uint256 public maxPercentStipend = 30000; // The maximum amount of WETH profit that can be allocated to the executor for gas in percent
    uint256 public gasStipend = 1000000; // This is the gas units that are covered by executing a trade taken from the WETH profit
    uint256 constant minGain = 1e16; // Minimum amount of gain (0.01 coin) before buying WETH and splitting it
    
    // Token information
    // This strategy accepts frax and usdc
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits

    // Strategy specific variables
    address constant UNISWAP_ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap
    address constant CURVE_UST_POOL = address(0x890f4e345B1dAED0367A877a1612f86A1f86985f);
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant GAS_ORACLE_ADDRESS = address(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C); // Chainlink address for fast gas oracle
    address constant LENDING_POOL_ADDRESS_PROVIDER = address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); // Provider for Aave addresses

    constructor(
        address _treasury,
        address _staking,
        address _zsToken
    ) public {
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        zsTokenAddress = _zsToken;
        setupWithdrawTokens();
    }

    // Initialization functions
    
    function setupWithdrawTokens() internal {
        // Start with UST
        IERC20 _token = IERC20(address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
        
        // USDT
        _token = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
    }
    
    // Modifier
    modifier onlyZSToken() {
        require(zsTokenAddress == _msgSender(), "Call not sent from the zs-Token");
        _;
    }
    
    // Read functions
    
    function rewardTokensCount() external view returns (uint256) {
        return tokenList.length;
    }
    
    function rewardTokenAddress(uint256 _pos) external view returns (address) {
        require(_pos < tokenList.length,"No token at that position");
        return address(tokenList[_pos].token);
    }
    
    function balance() public view returns (uint256) {
        return getNormalizedTotalBalance(address(this));
    }
    
    function getNormalizedTotalBalance(address _address) public view returns (uint256) {
        uint256 _balance = 0;
        for(uint256 i = 0; i < tokenList.length; i++){
            uint256 _bal = tokenList[i].token.balanceOf(_address);
            _bal = _bal.mul(1e18).div(10**tokenList[i].decimals);
            _balance = _balance.add(_bal); // This has been normalized to 1e18 decimals
        }
        return _balance;
    }
    
    function withdrawTokenReserves() public view returns (address, uint256) {
        // This function will return the address and amount of frax, then usdc
        if(tokenList[0].token.balanceOf(address(this)) > 0){
            return (address(tokenList[0].token), tokenList[0].token.balanceOf(address(this)));
        }else if(tokenList[1].token.balanceOf(address(this)) > 0){
            return (address(tokenList[1].token), tokenList[1].token.balanceOf(address(this)));
        }else{
            return (address(0), 0); // No balance
        }
    }
    
    // Write functions
    
    function enter() external onlyZSToken {
        deposit(false);
    }
    
    function exit() external onlyZSToken {
        // The ZS token vault is removing all tokens from this strategy
        withdraw(_msgSender(),1,1, false);
    }
    
    function deposit(bool nonContract) public onlyZSToken {
        // Only the ZS token can call the function
        
        // No trading is performed on deposit
        if(nonContract == true){ }
        lastActionBalance = balance();
        require(lastActionBalance <= maxPoolSize,"This strategy has reached its maximum balance");
    }

    function simulateExchange(address _inputToken, address _outputToken, uint256 _amount, bool _uniswap) internal view returns (uint256) {
        if(_uniswap == true){
            // Possible Uniswap routes, UST / USDT, USDT / ETH
            UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
            address[] memory path;
            if(_inputToken == address(tokenList[0].token) && _outputToken == WETH_ADDRESS){
                // Selling UST for WETH, must go through USDT
                path = new address[](3);
                path[0] = _inputToken;
                path[1] = address(tokenList[1].token);
                path[2] = _outputToken;
            }else{
                path = new address[](2);
                path[0] = _inputToken;
                path[1] = _outputToken;                
            }
            uint256[] memory estimates = router.getAmountsOut(_amount, path);
            _amount = estimates[estimates.length - 1]; // This is the amount of WETH returned
            return _amount;            
        }else{
            // We are swapping via curve
            CurvePool pool = CurvePool(CURVE_UST_POOL);
            int128 inCurve = 0;
            int128 outCurve = 0;
            if(_inputToken == address(tokenList[1].token)){inCurve = 3;}
            if(_outputToken == address(tokenList[1].token)){outCurve = 3;}
            return pool.get_dy_underlying(inCurve, outCurve, _amount);
        }
    }
    
    function exchange(address _inputToken, address _outputToken, uint256 _amount, bool _uniswap) internal {
        if(_uniswap == true){
            // Possible Uniswap routes, UST / USDT, USDT / ETH
            UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
            address[] memory path;
            if(_inputToken == address(tokenList[0].token) && _outputToken == WETH_ADDRESS){
                // Selling UST for WETH, must go through USDT
                path = new address[](3);
                path[0] = _inputToken;
                path[1] = address(tokenList[1].token);
                path[2] = _outputToken;
            }else{
                path = new address[](2);
                path[0] = _inputToken;
                path[1] = _outputToken;                
            }
            IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, 0);
            IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, _amount);
            router.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(60)); // Get WETH from token
            return;           
        }else{
            // We are swapping via curve
            CurvePool pool = CurvePool(CURVE_UST_POOL);
            int128 inCurve = 0;
            int128 outCurve = 0;
            if(_inputToken == address(tokenList[1].token)){inCurve = 3;}
            if(_outputToken == address(tokenList[1].token)){outCurve = 3;}
            IERC20(_inputToken).safeApprove(CURVE_UST_POOL, 0);
            IERC20(_inputToken).safeApprove(CURVE_UST_POOL, _amount);
            pool.exchange_underlying(inCurve, outCurve, _amount, 1);
        }
    }

    function getCheaperToken(uint256 _exchangeID) internal view returns (uint256) {
        // This will return the cheaper token on that exchange
        // We will estimate the return for trading 1 UST
        // The higher the return, the lower the price of the other token
        
        // It will also suggest which exchange we should use, Uniswap or Curve
        uint256 ustAmount = uint256(1).mul(10**tokenList[0].decimals);
        uint256 targetID = 0;
        bool useUniswap = true; //Uniswap
        if(_exchangeID > 0){
            useUniswap = false;
        }
        
        // Get USDT return
        uint256 estimate = simulateExchange(address(tokenList[0].token),address(tokenList[1].token),ustAmount,useUniswap);
        estimate = estimate.mul(10**tokenList[0].decimals).div(10**tokenList[1].decimals); // Convert to same decimals
        if(ustAmount < estimate){
            targetID = 1; // USDT is cheaper, buy it
        }
        return targetID;
    }
    
    function estimateSellAtMaximumProfit(uint256 originID, uint256 targetID, uint256 _tokenBalance, bool uniswap) internal view returns (uint256) {
        // This will estimate the amount that can be sold for the maximum profit possible
        // We discover the price then compare it to the actual return
        // The return must be positive to return a positive amount
        
        uint256 originDecimals = 0;
        uint256 targetDecimals = 0;

        originDecimals = tokenList[originID].decimals;
        targetDecimals = tokenList[targetID].decimals;
        
        // Discover the price with near 0 slip
        uint256 _minAmount = _tokenBalance.mul(maxPercentSell.div(1000)).div(DIVISION_FACTOR);
        if(_minAmount == 0){ return 0; } // Nothing to sell, can't calculate
        uint256 _minReturn = _minAmount.mul(10**targetDecimals).div(10**originDecimals); // Convert decimals
        uint256 _return = simulateExchange(address(tokenList[originID].token), address(tokenList[targetID].token), _minAmount, uniswap);
        if(_return <= _minReturn){
            return 0; // We are not going to gain from this trade
        }
        _return = _return.mul(10**originDecimals).div(10**targetDecimals); // Convert to origin decimals
        uint256 _startPrice = _return.mul(1e18).div(_minAmount);
        
        // Now get the price at a higher amount, expected to be lower due to slippage
        uint256 _bigAmount = _tokenBalance.mul(maxPercentSell).div(DIVISION_FACTOR);
        _return = simulateExchange(address(tokenList[originID].token), address(tokenList[targetID].token), _bigAmount, uniswap);
        _return = _return.mul(10**originDecimals).div(10**targetDecimals); // Convert to origin decimals
        uint256 _endPrice = _return.mul(1e18).div(_bigAmount);
        if(_endPrice >= _startPrice){
            // Really good liquidity
            return _bigAmount;
        }
        
        // Else calculate amount at max profit
        uint256 scaleFactor = uint256(1).mul(10**originDecimals);
        uint256 _targetAmount = _startPrice.sub(1e18).mul(scaleFactor).div(_startPrice.sub(_endPrice).mul(scaleFactor).div(_bigAmount.sub(_minAmount))).div(2);
        if(_targetAmount > _bigAmount){
            // Cannot create an estimate larger than what we want to sell
            return _bigAmount;
        }
        return _targetAmount;
    }
    
    function getFastGasPrice() internal view returns (uint256) {
        AggregatorV3Interface gasOracle = AggregatorV3Interface(GAS_ORACLE_ADDRESS);
        ( , int intGasPrice, , , ) = gasOracle.latestRoundData(); // We only want the answer 
        return uint256(intGasPrice);
    }
    
    function checkAndSwapTokens(address _executor, uint256 _targetExchange, uint256 targetID) internal {
        lastTradeTime = now;
        require(targetID < tokenList.length, "Token ID doesn't exist");
        require(_targetExchange < 2, "Exchange doesn't exist");
        
        uint256 gain = 0;
        bool useUniswap = true;
        if(_targetExchange> 0){
            useUniswap = false;
        }

        uint256 length = tokenList.length;
        // Now sell all the other tokens into this token
        uint256 _totalBalance = balance(); // Get the token balance at this contract, should increase
        bool _expectIncrease = false;
        for(uint256 i = 0; i < length; i++){
            if(i != targetID){
                uint256 sellBalance = 0;
                uint256 _minTradeTarget = minTradeSplit.mul(10**tokenList[i].decimals);
                uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[i].decimals); // Determine the maximum amount of tokens to sell at once
                if(tokenList[i].token.balanceOf(address(this)) <= _minTradeTarget){
                    // If balance is too small,sell all tokens at once
                    sellBalance = tokenList[i].token.balanceOf(address(this));
                }else{
                    sellBalance = estimateSellAtMaximumProfit(i, targetID, tokenList[i].token.balanceOf(address(this)), useUniswap);
                }
                if(sellBalance > _maxTradeTarget){
                    // If greater than the maximum trade allowed, match it
                    sellBalance = _maxTradeTarget;
                }
                uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                if(sellBalance > 0){
                    uint256 estimate = simulateExchange(address(tokenList[i].token), address(tokenList[targetID].token), sellBalance, useUniswap);
                    if(estimate > minReceiveBalance){
                        _expectIncrease = true;
                        exchange(address(tokenList[i].token), address(tokenList[targetID].token), sellBalance, useUniswap);
                    }                        
                }
            }
        }
        uint256 _newBalance = balance();
        if(_expectIncrease == true){
            // There may be rare scenarios where we don't gain any by calling this function
            require(_newBalance > _totalBalance, "Failed to gain in balance from selling tokens");
        }
        gain = _newBalance.sub(_totalBalance);

        IERC20 weth = IERC20(WETH_ADDRESS);
        uint256 _wethBalance = weth.balanceOf(address(this));
        if(gain >= minGain || _wethBalance > 0){
            // Minimum gain required to buy WETH is about 0.01 tokens
            
            if(gain >= minGain){
            // Buy WETH from Uniswap with tokens
                uint256 sellBalance = gain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
                sellBalance = sellBalance.mul(DIVISION_FACTOR.sub(percentDepositor)).div(DIVISION_FACTOR); // We will buy WETH with this amount
                if(sellBalance <= tokenList[targetID].token.balanceOf(address(this))){
                    // Sell some of our gained token for WETH
                    exchange(address(tokenList[targetID].token), WETH_ADDRESS, sellBalance, true);
                    _wethBalance = weth.balanceOf(address(this));
                }
            }
            if(_wethBalance > 0){
                // Split the rest between the stakers and such
                // This is pure profit, figure out allocation
                // Split the amount sent to the treasury, stakers and executor if one exists
                if(_executor != address(0)){
                    // Executors will get a gas reimbursement in WETH and a percent of the remaining
                    uint256 maxGasFee = getFastGasPrice().mul(gasStipend); // This is gas stipend in wei
                    uint256 gasFee = tx.gasprice.mul(gasStipend); // This is gas fee requested
                    if(gasFee > maxGasFee){
                        gasFee = maxGasFee; // Gas fee cannot be greater than the maximum
                    }
                    uint256 executorAmount = gasFee;
                    if(gasFee >= _wethBalance.mul(maxPercentStipend).div(DIVISION_FACTOR)){
                        executorAmount = _wethBalance.mul(maxPercentStipend).div(DIVISION_FACTOR); // The executor will get the entire amount up to point
                    }else{
                        // Add the executor percent on top of gas fee
                        executorAmount = _wethBalance.sub(gasFee).mul(percentExecutor).div(DIVISION_FACTOR).add(gasFee);
                    }
                    if(executorAmount > 0){
                        weth.safeTransfer(_executor, executorAmount);
                        _wethBalance = weth.balanceOf(address(this)); // Recalculate WETH in contract           
                    }
                }
                if(_wethBalance > 0){
                    uint256 stakersAmount = _wethBalance.mul(percentStakers).div(DIVISION_FACTOR);
                    uint256 treasuryAmount = _wethBalance.sub(stakersAmount);
                    if(treasuryAmount > 0){
                        weth.safeTransfer(treasuryAddress, treasuryAmount);
                    }
                    if(stakersAmount > 0){
                        if(stakingAddress != address(0)){
                            weth.safeTransfer(stakingAddress, stakersAmount);
                            StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);                                
                        }else{
                            // No staking pool selected, just send to the treasury
                            weth.safeTransfer(treasuryAddress, stakersAmount);
                        }
                    }
                }                
            }
        }
    }
    
    function expectedProfit(bool inWETHForExecutor) external view returns (
        uint256, // Expected profit
        uint256, // Target exchange
        uint256, // Target ID
        uint256 // Block number
        ) {
        // This view will return the amount of gain a forced swap will make on next call
        
        // Now find our target token to sell into
        uint256 targetID_1 = getCheaperToken(0);
        uint256 targetID_2 = getCheaperToken(1);
        uint256 targetRoute = 0;
        uint256 targetID = 0;

        // Now simulate sell all the other tokens into this token
        uint256 _normalizedGain = 0;
        
        uint256 length = tokenList.length;
        // Test the return of both routes
        // The one with the greater return is chosen
        for(uint256 z = 0; z < 2; z++){
            uint256 latestGain = 0;
            if(z == 0){
                targetID = targetID_1;
            }else{
                targetID = targetID_2;
            }
            for(uint256 i = 0; i < length; i++){
                if(i != targetID){
                    uint256 sellBalance = 0;
                    uint256 _minTradeTarget = minTradeSplit.mul(10**tokenList[i].decimals);
                    uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[i].decimals); // Determine the maximum amount of tokens to sell at once
                    if(tokenList[i].token.balanceOf(address(this)) <= _minTradeTarget){
                        // If balance is too small,sell all tokens at once
                        sellBalance = tokenList[i].token.balanceOf(address(this));
                    }else{
                        if(z == 0){
                            sellBalance = estimateSellAtMaximumProfit(i, targetID, tokenList[i].token.balanceOf(address(this)), true);
                        }else{
                            sellBalance = estimateSellAtMaximumProfit(i, targetID, tokenList[i].token.balanceOf(address(this)), false);
                        }
                    }
                    if(sellBalance > _maxTradeTarget){
                        // If greater than the maximum trade allowed, match it
                        sellBalance = _maxTradeTarget;
                    }
                    uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                    if(sellBalance > 0){
                        uint256 estimate = 0;
                        if(z == 0){
                            estimate = simulateExchange(address(tokenList[i].token), address(tokenList[targetID].token), sellBalance, true);
                        }else{
                            estimate = simulateExchange(address(tokenList[i].token), address(tokenList[targetID].token), sellBalance, false);
                        }
                        if(estimate > minReceiveBalance){
                            latestGain = estimate.sub(minReceiveBalance).mul(1e18).div(10**tokenList[targetID].decimals); // Normalized gain
                            if(z == 0){
                                _normalizedGain = latestGain;
                            }
                        }              
                    }
                }
            }
            if(z == 1){
                // Check which route has the better return
                if(_normalizedGain >= latestGain){
                    targetRoute = 0;
                    targetID = targetID_1;
                }else{
                    targetRoute = 1;
                    targetID = targetID_2;
                    _normalizedGain = latestGain;
                }
            }
        }

        if(inWETHForExecutor == false){
            return (_normalizedGain, targetRoute, targetID, block.number);
        }else{
            if(_normalizedGain == 0){
                return (0, targetRoute, targetID, block.number);
            }
            // Calculate how much WETH the executor would make as profit
            uint256 estimate = 0;
            if(_normalizedGain > 0){
                uint256 sellBalance = _normalizedGain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
                sellBalance = sellBalance.mul(DIVISION_FACTOR.sub(percentDepositor)).div(DIVISION_FACTOR);
                // Estimate output
                estimate = estimate.add(simulateExchange(address(tokenList[targetID].token), WETH_ADDRESS, sellBalance, true));           
            }
            // Now calculate the amount going to the executor
            uint256 gasFee = getFastGasPrice().mul(gasStipend); // This is gas stipend in wei
            if(gasFee >= estimate.mul(maxPercentStipend).div(DIVISION_FACTOR)){ // Max percent of total
                return (estimate.mul(maxPercentStipend).div(DIVISION_FACTOR),targetRoute, targetID, block.number); // The executor will get max percent of total
            }else{
                estimate = estimate.sub(gasFee); // Subtract fee from remaining balance
                return (estimate.mul(percentExecutor).div(DIVISION_FACTOR).add(gasFee),targetRoute, targetID, block.number); // Executor amount with fee added
            }
        }  
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSToken returns (uint256) {
        require(balance() > 0, "There are no tokens in this strategy");
        if(nonContract == true){
            if( _share > _total.mul(percentTradeTrigger).div(DIVISION_FACTOR)){
                checkAndSwapTokens(_depositor, 1, 0);
            }
        }
        
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            withdrawPerOrder(_depositor, _myBalance, false); // This will withdraw based on token price
            withdrawAmount = _myBalance;
        }else{
            // We are all shares, transfer all
            withdrawPerOrder(_depositor, _balance, true);
            withdrawAmount = _balance;
        }       
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    // This will withdraw the tokens from the contract based on their order
    function withdrawPerOrder(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {
        uint256 length = tokenList.length;
        if(_takeAll == true){
            // Send the entire balance
            for(uint256 i = 0; i < length; i++){
                uint256 _bal = tokenList[i].token.balanceOf(address(this));
                if(_bal > 0){
                    tokenList[i].token.safeTransfer(_receiver, _bal);
                }
            }
            return;
        }
        
        for(uint256 i = 0; i < length; i++){
            // Determine the balance left
            uint256 _normalizedBalance = tokenList[i].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                // Withdraw the entire balance of this token
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    tokenList[i].token.safeTransfer(_receiver, tokenList[i].token.balanceOf(address(this)));                    
                }
            }else{
                // Withdraw a partial amount of this token
                if(_withdrawAmount > 0){
                    // Convert the withdraw amount to the token's decimal amount
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[i].decimals).div(1e18);
                    _withdrawAmount = 0;
                    tokenList[i].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    function executorSwapTokens(address _executor, uint256 _minSecSinceLastTrade, uint256 _deadlineBlock, uint256 _targetRoute, uint256 _targetID) external {
        // Function designed to promote trading with incentive. Users get 20% of WETH from profitable trades
        require(block.number <= _deadlineBlock, "Deadline has expired, aborting trade");
        require(now.sub(lastTradeTime) > _minSecSinceLastTrade, "The last trade was too recent");
        require(_msgSender() == tx.origin, "Contracts cannot interact with this function");
        checkAndSwapTokens(_executor, _targetRoute, _targetID);
        lastActionBalance = balance();
    }
    
    // Governance functions
    function governanceSwapTokens(uint256 _targetRoute, uint256 _targetID) external onlyGovernance {
        // This is function that force trade tokens at anytime. It can only be called by governance
        checkAndSwapTokens(governance(), _targetRoute, _targetID);
        lastActionBalance = balance();
    }
    
    // Timelock variables
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    // Reusable timelock variables
    address private _timelock_address;
    uint256[7] private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(balance() > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        }
        _;
    }
    
    // Change the owner of the token contract
    // --------------------
    function startGovernanceChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {
        transferGovernance(_timelock_address);
    }
    // --------------------
    
    // Change the treasury address
    // --------------------
    function startChangeTreasury(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(2) {
        treasuryAddress = _timelock_address;
    }
    // --------------------
    
    // Change the staking address
    // --------------------
    function startChangeStakingPool(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(3) {
        stakingAddress = _timelock_address;
    }
    // --------------------
    
    // Change the zsToken address
    // --------------------
    function startChangeZSToken(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeZSToken() external onlyGovernance timelockConditionsMet(4) {
        zsTokenAddress = _timelock_address;
    }
    // --------------------
   
    // Change the trading conditions used by the strategy
    // --------------------
    
    function startChangeTradingConditions(uint256 _pTradeTrigger, uint256 _pSellPercent, uint256 _mSellAmount, uint256 _minSplit, uint256 _maxStipend, uint256 _pMaxStipend) external onlyGovernance {
        // Changes a lot of trading parameters in one call
        require(_pTradeTrigger <= 100000 && _pSellPercent <= 100000 && _pMaxStipend <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 5;
        _timelock_data[0] = _pTradeTrigger;
        _timelock_data[1] = _pSellPercent;
        _timelock_data[2] = _minSplit;
        _timelock_data[3] = _maxStipend;
        _timelock_data[4] = _pMaxStipend;
        _timelock_data[5] = _mSellAmount;
    }
    
    function finishChangeTradingConditions() external onlyGovernance timelockConditionsMet(5) {
        percentTradeTrigger = _timelock_data[0];
        maxPercentSell = _timelock_data[1];
        minTradeSplit = _timelock_data[2];
        gasStipend = _timelock_data[3];
        maxPercentStipend = _timelock_data[4];
        maxAmountSell = _timelock_data[5];
    }
    // --------------------
    
    // Change the strategy allocations between the parties
    // --------------------
    
    function startChangeStrategyAllocations(uint256 _pDepositors, uint256 _pExecutor, uint256 _pStakers, uint256 _maxPool) external onlyGovernance {
        // Changes strategy allocations in one call
        require(_pDepositors <= 100000 && _pExecutor <= 100000 && _pStakers <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data[0] = _pDepositors;
        _timelock_data[1] = _pExecutor;
        _timelock_data[2] = _pStakers;
        _timelock_data[3] = _maxPool;
    }
    
    function finishChangeStrategyAllocations() external onlyGovernance timelockConditionsMet(6) {
        percentDepositor = _timelock_data[0];
        percentExecutor = _timelock_data[1];
        percentStakers = _timelock_data[2];
        maxPoolSize = _timelock_data[3];
    }
    // --------------------
}
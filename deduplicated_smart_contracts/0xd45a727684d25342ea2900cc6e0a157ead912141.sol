/**
 *Submitted for verification at Etherscan.io on 2020-11-18
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

// File: contracts/strategies/StabilizeStrategyStablecoinArb.sol

pragma solidity ^0.6.6;

// This is a strategy that takes advantage of arb opportunities for multiple stablecoins
// Users deposit various stables into the strategy and the strategy will sell into the lowest priced token
// Selling will occur via Curve and buying WETH via Uniswap
// Half the profit earned from the sell will be used to buy WETH and split it between the treasury
// Half will remain as stables
// It will sell on deposits and withdrawals only when a non-contract calls it

interface StabilizeStakingPool {
    function notifyRewardAmount(uint256) external;
}

interface StabilizePriceOracle {
    function getPrice(address _address) external returns (uint256);
}

interface CurvePool {
    function get_dy_underlying(int128, int128, uint256) external returns (uint256); // Get quantity estimate
    function exchange_underlying(int128, int128, uint256, uint256) external; // Exchange tokens
}

interface UniswapRouter {
    function WETH() external pure returns (address); // Get address for WETH
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
}

contract StabilizeStrategyStablecoinArb is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant divisionFactor = 100000;
    uint256 public percentSell = 80000; // 80% of the tokens are sold to the cheapest token
    uint256 public percentDepositor = 50000; // 1000 = 1%, depositors earn 50% of all depositors
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    uint256 constant minGain = 1e18; // Minimum amount of gain before buying WETH and splitting it
    
    // Token information
    // This strategy accepts multiple stablecoins
    // DAI, USDC, USDT, sUSD
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
        uint256 price; // Last price of token in USD
        int128 curveID; // ID in the curve Pool
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits
    StabilizePriceOracle private oracleContract; // A reference to the price oracle contract
    
    // Strategy specific variables
    address constant curveAddress = address(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD); // Curve pool for 4 token DAI, USDC, USDT, sUSD
    address constant uniswapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap

    constructor(
        address _treasury,
        address _staking,
        address _zsToken,
        StabilizePriceOracle _oracle
    ) public {
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        zsTokenAddress = _zsToken;
        oracleContract = _oracle;
        setupTokens();
    }

    // Initialization functions
    
    function setupTokens() internal {
        // Start with DAI
        IERC20 _token = IERC20(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                price: 1e18,
                curveID: 0
            })
        );   
        
        // USDC
        _token = IERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                price: 1e18,
                curveID: 1
            })
        );
        
        // USDT
        _token = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                price: 1e18,
                curveID: 2
            })
        );
        
        // sUSD
        _token = IERC20(address(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                price: 1e18,
                curveID: 3
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
        // This function will return the address and amount of the token with the lowest price
        uint256 length = tokenList.length;
        uint256 targetID = 0;
        uint256 targetPrice = 0;
        for(uint256 i = 0; i < length; i++){
            if(tokenList[i].token.balanceOf(address(this)) > 0){
                uint256 _price = tokenList[i].price;
                if(targetPrice == 0 || _price <= targetPrice){
                    targetPrice = _price;
                    targetID = i;
                }
            }
        }
        if(targetPrice > 0){
            return (address(tokenList[targetID].token), tokenList[targetID].token.balanceOf(address(this)));
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
        
        if(nonContract == true){
            // Only when depositing via a non-contract will this be called
            checkAndSellStables();
        }
    }
    
    function checkAndSellStables() internal {
        updateTokenPrices(); // Update the prices based on an off-chain Oracle
        bool profitable = isSellProfitable();
        if(profitable == true){
            // Once we know its profitable, sell into curve pool
            CurvePool pool = CurvePool(curveAddress);
            
            // Now find our target token to sell into
            uint256 length = tokenList.length;
            uint256 targetID = 0;
            uint256 targetPrice = 0;
            for(uint256 i = 0; i < length; i++){
                uint256 _price = tokenList[i].price;
                if(targetPrice == 0 || _price <= targetPrice){
                    targetPrice = _price;
                    targetID = i;
                }
            }
            
            // Now sell all the other tokens into this token
            uint256 _totalBalance = balance(); // Get the token balance at this contract, should increase
            bool _expectIncrease = false;
            for(uint256 i = 0; i < length; i++){
                if(i != targetID){
                    uint256 sellBalance = tokenList[i].token.balanceOf(address(this)).mul(percentSell).div(divisionFactor);
                    uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                    uint256 estimate = pool.get_dy_underlying(tokenList[i].curveID, tokenList[targetID].curveID, sellBalance);
                    if(estimate > minReceiveBalance){
                        _expectIncrease = true;
                        // We are getting a greater number of tokens, complete the exhcnage
                        tokenList[i].token.safeApprove(address(pool), sellBalance);
                        pool.exchange_underlying(tokenList[i].curveID, tokenList[targetID].curveID, sellBalance, minReceiveBalance);
                    }
                }
            }
            if(_expectIncrease == true){
                // There may be rare scenarios where we don't gain any by calling this function
                require(balance() > _totalBalance, "Failed to gain in balance from selling tokens");
            }
            uint256 gain = balance().sub(_totalBalance);
            if(gain >= minGain){
                // Minimum gain is about $1
                // Buy WETH from Uniswap with stablecoin
                uint256 sellBalance = gain.mul(10**tokenList[targetID].decimals).div(1e18);
                uint256 holdBalance = sellBalance.mul(percentDepositor).div(divisionFactor);
                sellBalance = sellBalance.sub(holdBalance); // We will buy WETH with this amount
                if(sellBalance <= tokenList[targetID].token.balanceOf(address(this))){
                    UniswapRouter router = UniswapRouter(uniswapRouterAddress);
                    IERC20 weth = IERC20(router.WETH());
                    // Sell some of our gained stablecoins for WETH
                    swapUniswap(address(tokenList[targetID].token), address(weth), sellBalance);
                    if(weth.balanceOf(address(this)) > 0){
                        // Split the amount sent to the treasury and stakers
                        uint256 stakersAmount = weth.balanceOf(address(this)).mul(percentStakers).div(divisionFactor);
                        uint256 treasuryAmount = weth.balanceOf(address(this)).sub(stakersAmount);
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
    }
    
    function swapUniswap(address _from, address _to, uint256 _sellAmount) internal {
        require(_to != address(0));

        address[] memory path;
        UniswapRouter router = UniswapRouter(uniswapRouterAddress);
        address weth = router.WETH();

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        IERC20(_from).safeApprove(address(router), 0); // Some tokens require this to be set to 0 first
        IERC20(_from).safeApprove(address(router), _sellAmount);
        router.swapExactTokensForTokens(_sellAmount, 1, path, address(this), now.add(60));
    }
    
    function isSellProfitable() public view returns (bool) {
        // This will return whether a sell will be profitable for the strategy
        uint256 length = tokenList.length;
        uint256 targetID = 0;
        uint256 targetPrice = 0;
        for(uint256 i = 0; i < length; i++){
            uint256 _price = tokenList[i].price;
            if(targetPrice == 0 || _price <= targetPrice){
                targetPrice = _price;
                targetID = i;
            }
        }
        
        // Now we have our lowest priced token ID that we will sell into, calculate price difference
        bool profitable = false;
        for(uint256 i = 0; i < length; i++){
            if(i != targetID){
                uint256 _price = tokenList[i].price;
                if(_price > targetPrice){
                    if(_price.sub(targetPrice) >= 10000000000000000){ // Difference is greater than 1%
                        // Make sure we have a balance
                        if(tokenList[i].token.balanceOf(address(this)) > 0){
                            // And we have a balance
                            profitable = true;
                            break;
                        }
                    }
                }
            }
        }
        return profitable;
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSToken returns (uint256) {
        require(balance() > 0, "There are no tokens in this strategy");
        // When a user withdraws, we need to pull the tokens out of the contract
        if(nonContract == true){
            checkAndSellStables();
        }
        
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            withdrawPerPrice(_depositor, _myBalance, false); // This will withdraw based on token price
            withdrawAmount = _myBalance;
        }else{
            // We are all shares, transfer all
            withdrawPerPrice(_depositor, _balance, true);
            withdrawAmount = _balance;
        }        
        
        return withdrawAmount;
    }
    
    function updateTokenPrices() internal {
        for(uint256 i = 0; i < tokenList.length; i++){
            uint256 price = oracleContract.getPrice(address(tokenList[i].token));
            if(price > 0){
                tokenList[i].price = price;
            }
        }        
    }
    
    // This will withdraw the tokens from the contract based on their price, from lowest price to highest
    function withdrawPerPrice(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {
        uint256 length = tokenList.length;
        if(_takeAll == true){
            for(uint256 i = 0; i < length; i++){
                tokenList[i].token.safeTransfer(_receiver, tokenList[i].token.balanceOf(address(this)));
            }
            return;
        }
        bool[4] memory done;
        uint256 targetID = 0;
        uint256 targetPrice = 0;
        updateTokenPrices();
        for(uint256 i = 0; i < length; i++){
            
            targetPrice = 0; // Reset the target price
            // Find the lowest priced token to withdraw
            for(uint256 i2 = 0; i2 < length; i2++){
                if(done[i2] == false){
                    uint256 _price = tokenList[i2].price;
                    if(targetPrice == 0 || _price <= targetPrice){
                        targetPrice = _price;
                        targetID = i2;
                    }
                }
            }
            done[targetID] = true;
            
            // Determine the balance left
            uint256 _normalizedBalance = tokenList[targetID].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[targetID].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                // Withdraw the entire balance of this token
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    tokenList[targetID].token.safeTransfer(_receiver, tokenList[targetID].token.balanceOf(address(this)));                    
                }
            }else{
                // Withdraw a partial amount of this token
                if(_withdrawAmount > 0){
                    // Convert the withdraw amount to the token's decimal amount
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[targetID].decimals).div(1e18);
                    _withdrawAmount = 0;
                    tokenList[targetID].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    // Governance functions
    function forceSellStables() external onlyGovernance {
        // This is function that force sells stables at anytime. It can only be called by governance
        checkAndSellStables();
    }
    
    // Timelock variables
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant _timelockDuration = 86400; // Timelock is 24 hours
    
    // Reusable timelock variables
    address private _timelock_address;
    uint256 private _timelock_data_1;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(balance() > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
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
    
    // Change the percent going to depositors for WETH
    // --------------------
    function startChangeDepositorPercent(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 3;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeDepositorPercent() external onlyGovernance timelockConditionsMet(3) {
        percentDepositor = _timelock_data_1;
    }
    // --------------------
    
    // Change the staking address
    // --------------------
    function startChangeStakingPool(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(4) {
        stakingAddress = _timelock_address;
    }
    // --------------------
    
    // Change the zsToken address
    // --------------------
    function startChangeZSToken(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 5;
        _timelock_address = _address;
    }
    
    function finishChangeZSToken() external onlyGovernance timelockConditionsMet(5) {
        zsTokenAddress = _timelock_address;
    }
    // --------------------
    
    // Change the percent going to stakers for WETH
    // --------------------
    function startChangeStakersPercent(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeStakersPercent() external onlyGovernance timelockConditionsMet(6) {
        percentStakers = _timelock_data_1;
    }
    // --------------------
    
    // Change the percent sold of each token
    // --------------------
    function startChangePercentSold(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 7;
        _timelock_data_1 = _percent;
    }
    
    function finishChangePercentSold() external onlyGovernance timelockConditionsMet(7) {
        percentSell = _timelock_data_1;
    }
    // --------------------
    
    // Change the price oracle contract used, in case of upgrades
    // --------------------
    function startChangePriceOracle(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 8;
        _timelock_address = _address;
    }
    
    function finishChangePriceOracle() external onlyGovernance timelockConditionsMet(8) {
        oracleContract = StabilizePriceOracle(_timelock_address);
    }
    // --------------------
}
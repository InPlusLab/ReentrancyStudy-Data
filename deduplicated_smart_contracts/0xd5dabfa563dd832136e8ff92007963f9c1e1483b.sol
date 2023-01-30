/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

// File: localhost/contracts/interfaces/IUniRouter.sol

// SPDX-License-Identifier: MIT

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
// File: localhost/contracts/XChanger.sol


pragma solidity ^0.6.12;





contract XChanger is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    //address public constant oneSplitAddress = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E; #1split.eth
    address public constant oneSplitAddress = 0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e; //1proto.eth
        
    address
        public constant uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    //address constant SPLIT_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    enum Exchange {UNI, ONESPLIT}
    
    Exchange public exchange;
    
    uint private constant slippageFee = 100; //100 = 1% slippage
    uint private constant parts = 1;  // oneSplit parts, 1-100 affects gas usage

    //0x6B175474E89094C44Da98b954EedeAC495271d0F DAI
    //
    //0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USDC
    //
    //  30000000000000000000
    //  30000000

    event NoDirectQuote(address, address);
    event NoWETHQuote(address, address);
    
    bool private initialized;

    function init() virtual public {
        require(!initialized, "Is already been initialized");
        initialized = true;
        exchange = Exchange.UNI;
        Ownable.initialize(); // Do not forget this call!
    }
    
    function setExchange(Exchange _exchange) external onlyOwner {
        exchange = _exchange;
    }
    
        // to withdraw token from the contract
    function transferTokenBack(address TokenAddress)
        external
        onlyOwner
        returns (uint256)
    {
        IERC20 Token = IERC20(TokenAddress);
        uint256 balance = Token.balanceOf(address(this));
        if (balance > 0) {
            Token.safeTransfer(msg.sender, balance);
        }

        uint256 ETHbalance = address(this).balance;
        if (ETHbalance > 0) {
            msg.sender.transfer(ETHbalance);
        }

        return balance;
    }
    
    function swapSplit(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 flags,
        bool slipProtect
    ) internal returns (uint256) {
        IERC20 _fromToken = IERC20(fromToken);
        IERC20 _toToken = IERC20(toToken);
        IOneSplit oneSplit = IOneSplit(oneSplitAddress);
        (uint256 returnAmount0, uint256[] memory distribution) = oneSplit
            .getExpectedReturn(_fromToken, IERC20(toToken), amount, parts, flags);

        require(returnAmount0 > 0, "ISplit has nothing to return");

        if (_fromToken.allowance(address(this), oneSplitAddress) != uint256(-1)) {
            _fromToken.safeApprove(oneSplitAddress, uint256(-1));
        }

        uint256 returnAmount = oneSplit.swap(
            _fromToken,
            _toToken,
            amount,
            parts,
            distribution,
            flags
        );
        
        if (slipProtect) {
            uint256 feeSlippage = returnAmount.mul(slippageFee).div(10000);    
            uint minAmount = returnAmount.sub(feeSlippage);
            require (_toToken.balanceOf(address(this)) > minAmount, 'ISplit slippage is too high');
        } 

        return returnAmount;
    }

    function swapUni(
        address fromToken,
        address toToken,
        uint256 amount,
        bool slipProtect
    ) internal returns (uint256) {
        
        IERC20 _token = IERC20(fromToken);

        IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);

        if (
            _token.allowance(address(this), address(uniRouter)) != uint256(-1)
        ) {
            _token.safeApprove(address(uniRouter), uint256(-1));
        }

        (uint256 returnAmount, address[] memory path) = quote(
            fromToken,
            toToken,
            amount,
            Exchange.UNI
        );
        require(returnAmount > 0, "Quote is wrong");

        //slippage protection 1% if enabled
        uint minAmount = 0;
        if (slipProtect) {
            uint256 feeSlippage = returnAmount.mul(slippageFee).div(10000);    
            minAmount = returnAmount.sub(feeSlippage);
        } 
        
        uint256[] memory amounts = UniswapV2Router02.swapExactTokensForTokens(
            amount,
            minAmount,
            path,
            address(this),
            block.timestamp);
        
        return amounts[path.length - 1];
    }

    function _getOneSplitExpReturn(
        address fromToken,
        address toToken,
        uint256 amount
    ) internal view returns (uint256) {
        IERC20 fromIERC20 = IERC20(fromToken);
        IERC20 toIERC20 = IERC20(toToken);
        
        IOneSplit oneSplit = IOneSplit(oneSplitAddress);
        (uint256 returnAmount0, ) = oneSplit.getExpectedReturn(fromIERC20, toIERC20, amount, parts, 0x800000000000);

        return returnAmount0;
    }

    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        Exchange useExchange,
        bool slipProtect
    ) public payable returns (uint256) {
        if (fromToken == toToken) {
            return amount; // nothing to change
        }
        uint256 result;
        if (useExchange == Exchange.ONESPLIT) {
            result = swapSplit(fromToken, toToken, amount, 0, slipProtect);
        } else {
            result = swapUni(fromToken, toToken, amount, slipProtect);
        }
        return result;
    }

    function quote(
        address fromToken,
        address toToken,
        uint256 amount,
        Exchange useExchange
    ) public view returns (uint256, address[] memory) {
        uint256 returnAmount;
        address[] memory returnPath;

        if (fromToken == toToken) {
            //nothing to change
            return (amount, returnPath);
        }

        if (useExchange == Exchange.ONESPLIT) {
            returnAmount = _getOneSplitExpReturn(
                fromToken,
                toToken,
                amount
            );
            return (returnAmount, returnPath);
        } else {
            address[] memory path = new address[](2);
            path[0] = fromToken;
            path[1] = toToken;

            IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);

            try UniswapV2Router02.getAmountsOut(amount, path) returns (
                uint256[] memory amounts
            ) {
                if (amounts[1] > returnAmount) {
                    returnAmount = amounts[1];
                    returnPath = path;
                }
            } catch {}

            if (toToken != WETH_ADDRESS) {
                address[] memory pathWETH = new address[](3);
                pathWETH[0] = fromToken;
                pathWETH[1] = WETH_ADDRESS;
                pathWETH[2] = toToken;

                try UniswapV2Router02.getAmountsOut(amount, pathWETH) returns (
                    uint256[] memory amountsWETH
                ) {
                    if (amountsWETH[2] > returnAmount) {
                        returnAmount = amountsWETH[2];
                        returnPath = pathWETH;
                    }
                } catch {}
            }

            return (returnAmount, returnPath);
        }
    }

    function reverseQuote(
        address fromToken,
        address toToken,
        uint256 amount
    ) public view returns (uint256) {
        if (fromToken == toToken) {
            //nothing to change
            return amount;
        }

        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);

        uint256 returnAmount = uint256(-1);
        try UniswapV2Router02.getAmountsIn(amount, path) returns (
            uint256[] memory amounts
        ) {
            if (amounts[0] < returnAmount) {
                returnAmount = amounts[0];
            }
        } catch {}

        if (toToken != WETH_ADDRESS) {
            address[] memory pathWETH = new address[](3);
            pathWETH[0] = fromToken;
            pathWETH[1] = WETH_ADDRESS;
            pathWETH[2] = toToken;

            try UniswapV2Router02.getAmountsIn(amount, pathWETH) returns (
                uint256[] memory amountsWETH
            ) {
                if (amountsWETH[0] < returnAmount) {
                    returnAmount = amountsWETH[0];
                }
            } catch {}
        }

        return returnAmount;
    }
}

// File: localhost/contracts/interfaces/ICHI.sol


pragma solidity ^0.6.0;

interface ICHI {
    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256);

    function freeUpTo(uint256 value) external returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function mint(uint256 value) external;
}

// File: localhost/contracts/CHIBurner.sol


pragma solidity ^0.6.0;


contract CHIBurner {
    address
        public constant CHI_ADDRESS = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;

    ICHI public constant chi = ICHI(CHI_ADDRESS);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;

        /*uint256 availableAmount = chi.balanceOf(msg.sender);
        uint256 allowedAmount = chi.allowance(msg.sender, address(this));
        if (allowedAmount < availableAmount) {
            availableAmount = allowedAmount;
        }
        uint256 ourBalance = chi.balanceOf(address(this));

        address sender;
        if (ourBalance > availableAmount) {
            sender = address(this);
            ourBalance = availableAmount;
        } else {
            sender = msg.sender;
        }

        if (ourBalance > 0) {*/
        uint256 gasLeft = gasleft();
        uint256 gasSpent = 21000 + gasStart - gasLeft + 16 * msg.data.length;
        //chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
        chi.freeUpTo((gasSpent + 14154) / 41947);
        //}
    }
}

// File: localhost/contracts/interfaces/IWETH.sol


pragma solidity ^0.6.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}
// File: localhost/contracts/interfaces/ISFToken.sol


pragma solidity ^0.6.0;

interface ISFToken {
    function rebase(uint256 totalSupply) external;

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

// File: localhost/contracts/interfaces/IExternalPool.sol


pragma solidity ^0.6.0;

abstract contract IExternalPool {
    address public enterToken;

    function getPoolValue(address denominator)
        external
        virtual
        view
        returns (uint256);

    function getTokenStaked() external virtual view returns (uint256);

    function addPosition() external virtual returns (uint256);

    function exitPosition(uint256 amount) external virtual;

    function transferTokenTo(
        address TokenAddress,
        address recipient,
        uint256 amount
    ) external virtual returns (uint256);
}

// File: localhost/contracts/interfaces/IUniswapV2Pair.sol


pragma solidity ^0.6.0;

interface IUniswapV2Pair {
    //event Approval(address indexed owner, address indexed spender, uint value);
    //event Transfer(address indexed from, address indexed to, uint value);

    //function name() external pure returns (string memory);
    //function symbol() external pure returns (string memory);
    //function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

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

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
    /*
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

// File: localhost/contracts/ValueHolder.sol


pragma solidity ^0.6.12;








contract ValueHolder is XChanger, CHIBurner {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    mapping(uint256 => address) public uniPools;
    mapping(uint256 => address) public externalPools;

    uint256 public uniLen;
    uint256 public extLen;

    address public denominateTo;
    address public holderAddress;
    address public SFToken;

    address public votedUniPool;
    address public votedExtPool;
    uint256 public votedFee; // 1% = 100
    uint256 public votedChi; // number of Chi to hold

    uint256 private constant fpNumbers = 1e8;
    
    event LogValueManagerUpdated(address Manager);
    event LogVoterUpdated(address Voter);
    event LogVotedExtPoolUpdated(address pool);
    event LogVotedUniPoolUpdated(address pool);
    event LogSFTokenUpdated(address _NewSFToken);
    event LogFeeUpdated(uint256 newFee);
    event LogFeeTaken(uint256 feeAmount);
    event LogMintTaken(uint256 fromTokenAmount);
    event LogBurnGiven(uint256 toTokenAmount);
    event LogChiToppedUpdated(uint256 spendAmount);

    address public ValueManager;
    modifier onlyValueManager() {
        require(msg.sender == ValueManager, "Not Value Manager");
        _;
    }

    address public Voter;
    modifier onlyVoter() {
        require(msg.sender == Voter, "Not Voter");
        _;
    }

    function init(
        address _uniPool,
        address _extPool,
        address _sfToken
    ) public {
        XChanger.init();

        //0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f UNI

        uniPools[uniLen] = _uniPool;
        uniLen++;

        externalPools[extLen] = _extPool;
        extLen++;

        votedExtPool = _extPool;
        emit LogVotedExtPoolUpdated(_extPool);

        denominateTo = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
        SFToken = _sfToken; //
        ValueManager = msg.sender;
        Voter = msg.sender;
        holderAddress = ValueManager;
        votedFee = 200;
        votedChi = 20;
    }

    function setSFToken(address _NewSFToken) public onlyOwner {
        SFToken = _NewSFToken;
        emit LogSFTokenUpdated(_NewSFToken);
    }

    function setValueManager(address _ValueManager) external onlyOwner {
        ValueManager = _ValueManager;
        emit LogValueManagerUpdated(_ValueManager);
    }

    function setVoter(address _Voter) external onlyOwner {
        Voter = _Voter;
        emit LogVoterUpdated(_Voter);
    }

    function setVotedExtPool(address pool) public onlyVoter {
        votedExtPool = pool;
        emit LogVotedExtPoolUpdated(pool);
    }

    function setVotedUniPool(address pool) public onlyVoter {
        votedUniPool = pool;
        emit LogVotedUniPoolUpdated(pool);
    }

    function setVotedFee(uint256 _votedFee) public onlyVoter {
        votedFee = _votedFee;
        emit LogFeeUpdated(_votedFee);
    }

    function setVotedChi(uint256 _votedChi) public onlyVoter {
        votedChi = _votedChi;
    }

    function topUpChi(address Token) public returns (uint256) {
        uint256 currentChi = ICHI(CHI_ADDRESS).balanceOf(address(this));
        if (currentChi < votedChi) {
            //top up 1/2 votedChi
            uint256 spendAmount = reverseQuote(
                Token,
                CHI_ADDRESS,
                votedChi.div(2)
            );
            uint256 balance = IERC20(Token).balanceOf(address(this));
            if (spendAmount > balance) {
                spendAmount = balance;
            }
            
            if (spendAmount > 0) {
                swap(Token, CHI_ADDRESS, spendAmount, Exchange.UNI, false);
                LogChiToppedUpdated(spendAmount);
                return spendAmount;
            } else {
                return 0;
            }
        } else {
            return 0;    
        }
    }

    function mintQuote(
        address fromToken,
        uint256 amount
    ) external view returns (uint256) {
        if (votedExtPool != address(0)) {
            address toToken = IExternalPool(votedExtPool).enterToken();

            (uint256 returnAmount, ) = quote(
                fromToken,
                toToken,
                amount,
                exchange
            );
            
            (returnAmount, ) = quote(
                toToken,
                denominateTo,
                returnAmount,
                exchange
            );
            
            return returnAmount;
        } else if (votedUniPool != address(0)) {
            revert("not yet implemented");
        }
    }

    function mint(address fromToken, uint256 amount)
        external
        payable
        discountCHI
    {
        if (fromToken != address(0)) {
            IERC20 _fromToken = IERC20(fromToken);
            require(
                _fromToken.allowance(msg.sender, address(this)) >= amount,
                "Allowance is not enough"
            );
            uint balanceBefore = _fromToken.balanceOf(address(this));
            _fromToken.safeTransferFrom(msg.sender, address(this), amount);
            //confirmed amount
            amount = _fromToken.balanceOf(address(this)).sub(balanceBefore);
        } else {
            //convert to WETH
            IWETH(WETH_ADDRESS).deposit{value: msg.value}();
            amount = msg.value;
            fromToken = WETH_ADDRESS;
        }
        
        require(amount > 0, 'Mint does not make sense');
        
        emit LogMintTaken(amount);

        amount = amount.sub(topUpChi(fromToken));

        if (votedExtPool != address(0)) {
            IExternalPool extPool = IExternalPool(votedExtPool);
            address toToken = extPool.enterToken();

            uint256 returnAmount = swap(
                fromToken,
                toToken,
                amount,
                Exchange.UNI,
                false
            );
            IERC20 _toToken = IERC20(toToken);
            
            // we rebase before depositing token to pool as we dont want to count it yet
            uint256 value = getTotalValue().add(1);
            _rebase(value);

            _toToken.safeTransfer(votedExtPool, returnAmount);

            extPool.addPosition();
            
            // convert return amount to USDT (denominateTo)
            (uint256 toMint, ) = quote(
                toToken,
                denominateTo,
                returnAmount,
                exchange
            );

            // mint that amount to sender
            ISFToken(SFToken).mint(msg.sender, toMint);
        } else if (votedUniPool != address(0)) {
            revert("not yet implemented");
        }
    }

    function burn(address toToken, uint256 amount) external discountCHI {
        if (votedExtPool != address(0)) {
            ISFToken _SFToken = ISFToken(SFToken);
            // get latest token value
            
            uint256 value = getTotalValue().add(1);
            _rebase(value);
            
            // limit by existing balance
            uint256 senderBalance = _SFToken.balanceOf(msg.sender);
            if (senderBalance < amount) {
                amount = senderBalance;
            }

            require(amount > 0, "Not enough balance");

            IExternalPool extPool = IExternalPool(votedExtPool);
            address poolToken = extPool.enterToken();

            //get quote from sf token to pool token
            // how much pool token (DAI) is needed to make this amount of denominateTo (USDT)
            uint256 poolTokenWithdraw = reverseQuote(
                poolToken,
                denominateTo,
                amount
            );

            require(
                extPool.getTokenStaked() >= poolTokenWithdraw,
                "Not enough voted pool value to withdraw"
            );

            uint256 feeTaken = poolTokenWithdraw.mul(votedFee).div(10000);
            emit LogFeeTaken(feeTaken);
            //discount with fee
            //leave fee in the pool
            poolTokenWithdraw = poolTokenWithdraw.sub(feeTaken);

            //pull out pool tokens
            extPool.exitPosition(poolTokenWithdraw);
            //get them out from the pool here
            uint256 returnPoolTokenAmount = extPool.transferTokenTo(
                poolToken,
                address(this),
                poolTokenWithdraw
            );
            // topup with CHi
            returnPoolTokenAmount = returnPoolTokenAmount.sub(
                topUpChi(poolToken)
            );
            _SFToken.burn(msg.sender, amount);

            if (toToken == address(0)) {
                toToken = WETH_ADDRESS;
            }

            uint256 returnAmount = swap(
                poolToken,
                toToken,
                returnPoolTokenAmount,
                Exchange.UNI,
                true
            );

            if (toToken != WETH_ADDRESS) {
                IERC20(toToken).safeTransfer(msg.sender, returnAmount);
            } else {
                IWETH(WETH_ADDRESS).withdraw(returnAmount);
                
                //address whom = msg.sender;
                //whom.sendValue(returnAmount);
                msg.sender.transfer(returnAmount);
            }

            emit LogBurnGiven(returnAmount);
        } else if (votedUniPool != address(0)) {
            revert("not yet implemented");
        }
    }

    function _rebase(uint256 value) internal {
        ISFToken SF = ISFToken(SFToken);
        SF.rebase(value);
    }
    
    function rebase() public discountCHI onlyValueManager {
        uint256 value = getTotalValue().add(1);
        _rebase(value);
    }

    function rebase(uint256 value) external onlyValueManager {
        _rebase(value);
    }

    function getUniBalance(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256)
    {
        uint256 uniBalance;
        try uniPool.balanceOf(holderAddress) returns (uint256 uniBalanceHolder)
        {
            uniBalance = uniBalanceHolder.add(uniPool.balanceOf(address(this)));
        } catch { }
        
        return uniBalance;
    }

    function getHolderPc(IUniswapV2Pair uniPool) public view returns (uint256) {
        uint256 holderPc;
        try uniPool.totalSupply() returns (uint256 uniTotalSupply)
        {
            holderPc = (getUniBalance(uniPool).mul(fpNumbers)).div(uniTotalSupply);    
        } catch {}
        
        //uint256 uniTotalSupply = uniPool.totalSupply();
        return holderPc;
    }

    function getUniReserve(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256, uint256)
    {
        uint256 holderPc = getHolderPc(uniPool);

        uint256 myreserve0;
        uint256 myreserve1;

        try uniPool.getReserves() returns (uint112 reserve0, uint112 reserve1, uint32) {
        
            myreserve0 = (uint256(reserve0).mul(holderPc)).div(fpNumbers);
            myreserve1 = (uint256(reserve1).mul(holderPc)).div(fpNumbers);
    
        } catch {}
        
         //= uniPool.getReserves();

        
        return (myreserve0, myreserve1);
    }

    function getExternalValue() public view returns (uint256) {
        uint256 totalReserve = 0;
        for (uint256 j = 0; j < extLen; j++) {
            address extAddress = externalPools[j];
            if (extAddress != address(0)) {
                IExternalPool externalPool = IExternalPool(extAddress);

                totalReserve = totalReserve.add(
                    externalPool.getPoolValue(denominateTo)
                );
            }
        }
        return totalReserve;
    }

    function getDenominatedValue(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256, uint256)
    {
        (uint256 myreserve0, uint256 myreserve1) = getUniReserve(uniPool);

        address token0 = uniPool.token0();
        address token1 = uniPool.token1();

        if (token0 != denominateTo) {
            //get amount and convert to denominate addr;
            if (token0 != SFToken) {
                (myreserve0, ) = quote(uniPool.token0(), denominateTo, myreserve0, exchange);
                
            } else {
                myreserve0 = 0;
            }
        }

        if (uniPool.token1() != denominateTo) {
            //get amount and convert to denominate addr;
            if (token1 != SFToken) {
                (myreserve1, ) = quote(uniPool.token1(), denominateTo, myreserve1, exchange);
            } else {
                myreserve1 = 0;
            }
        }
        return (myreserve0, myreserve1);
    }

    function getTotalValue() public view returns (uint256) {
        uint256 totalReserve = 0;

        for (uint256 i = 0; i < uniLen; i++) {
            address uniAddress = uniPools[i];
            
            if (uniAddress != address(0)) {
                IUniswapV2Pair uniPool = IUniswapV2Pair(uniAddress);
                (uint256 myreserve0, uint256 myreserve1) = getDenominatedValue(
                    uniPool
                );

                totalReserve = totalReserve.add(myreserve0);
                totalReserve = totalReserve.add(myreserve1);
            }
        }

        totalReserve = totalReserve.add(getExternalValue());

        return totalReserve;
    }

    function addUni(address pool) public onlyVoter {
        uniPools[uniLen] = pool;
        uniLen++;
    }

    function delUni(uint256 i) external onlyVoter {
        uniPools[i] = address(0);
    }

    function addExt(address pool) public onlyVoter {
        externalPools[extLen] = pool;
        extLen++;
    }

    function delExt(uint256 i) external onlyVoter {
        externalPools[i] = address(0);
    }
}
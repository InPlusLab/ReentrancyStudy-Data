/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

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

// File: contracts/Pausable.sol



pragma solidity 0.6.12;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 */
contract Pausable is Context {
    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {
        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {
        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    /// @dev Pause contract operations, if contract is not paused.
    function _pause() internal virtual whenNotPaused {
        paused = true;
        emit Paused(_msgSender());
    }

    /// @dev Unpause contract operations, allow only if contract is paused and not shutdown.
    function _unpause() internal virtual whenPaused whenNotShutdown {
        paused = false;
        emit Unpaused(_msgSender());
    }

    /// @dev Shutdown contract operations, if not already shutdown.
    function _shutdown() internal virtual whenNotShutdown {
        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    /// @dev Open contract operations, if contract is in shutdown state
    function _open() internal virtual whenShutdown {
        stopEverything = false;
        emit Open(_msgSender());
    }
}

// File: contracts/interfaces/aave/IAave.sol



pragma solidity 0.6.12;

interface AaveAddressesProvider {
    function getLendingPool() external view returns (address);

    function getLendingPoolCore() external view returns (address);
}

interface AavePool {
    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;
}

interface AavePoolCore {
    function getReserveATokenAddress(address _reserve) external view returns (address);
}

interface AToken {
    function redeem(uint256 _amount) external;

    function balanceOf(address _user) external view returns (uint256);

    function principalBalanceOf(address _user) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/interfaces/maker/IMakerDAO.sol



pragma solidity 0.6.12;

interface ManagerLike {
    function cdpCan(
        address,
        uint256,
        address
    ) external view returns (uint256);

    function ilks(uint256) external view returns (bytes32);

    function owns(uint256) external view returns (address);

    function urns(uint256) external view returns (address);

    function vat() external view returns (address);

    function open(bytes32, address) external returns (uint256);

    function give(uint256, address) external;

    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;

    function urnAllow(address, uint256) external;

    function frob(
        uint256,
        int256,
        int256
    ) external;

    function flux(
        uint256,
        address,
        uint256
    ) external;

    function move(
        uint256,
        address,
        uint256
    ) external;

    function exit(
        address,
        uint256,
        address,
        uint256
    ) external;

    function quit(uint256, address) external;

    function enter(address, uint256) external;

    function shift(uint256, uint256) external;
}

interface VatLike {
    function can(address, address) external view returns (uint256);

    function ilks(bytes32)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function dai(address) external view returns (uint256);

    function urns(bytes32, address) external view returns (uint256, uint256);

    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;

    function hope(address) external;

    function nope(address) external;

    function move(
        address,
        address,
        uint256
    ) external;
}

interface GemJoinLike {
    function dec() external view returns (uint256);

    function gem() external view returns (address);

    function ilk() external view returns (bytes32);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;
}

interface DaiJoinLike {
    function vat() external returns (VatLike);

    function dai() external view returns (address);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint256);
}

interface SpotterLike {
    function ilks(bytes32) external view returns (address, uint256);
}

// File: contracts/interfaces/vesper/ICollateralManager.sol



pragma solidity 0.6.12;

interface ICollateralManager {
    function addGemJoin(address[] calldata gemJoins) external;

    function mcdManager() external view returns (address);

    function borrow(uint256 vaultNum, uint256 amount) external;

    function depositCollateral(uint256 vaultNum, uint256 amount) external;

    function getVaultBalance(uint256 vaultNum) external view returns (uint256 collateralLocked);

    function getVaultDebt(uint256 vaultNum) external view returns (uint256 daiDebt);

    function getVaultInfo(uint256 vaultNum)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function payback(uint256 vaultNum, uint256 amount) external;

    function registerVault(uint256 vaultNum, bytes32 collateralType) external;

    function vaultOwner(uint256 vaultNum) external returns (address owner);

    function whatWouldWithdrawDo(uint256 vaultNum, uint256 amount)
        external
        view
        returns (
            uint256 collateralLocked,
            uint256 daiDebt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        );

    function withdrawCollateral(uint256 vaultNum, uint256 amount) external;
}

// File: contracts/interfaces/vesper/IController.sol



pragma solidity 0.6.12;

interface IController {
    function aaveReferralCode() external view returns (uint16);

    function feeCollector(address) external view returns (address);

    function founderFee() external view returns (uint256);

    function founderVault() external view returns (address);

    function interestFee(address) external view returns (uint256);

    function isPool(address) external view returns (bool);

    function pools() external view returns (address);

    function strategy(address) external view returns (address);

    function rebalanceFriction(address) external view returns (uint256);

    function poolRewards(address) external view returns (address);

    function treasuryPool() external view returns (address);

    function uniswapRouter() external view returns (address);

    function withdrawFee(address) external view returns (uint256);
}

// File: contracts/interfaces/vesper/IStrategy.sol



pragma solidity 0.6.12;

interface IStrategy {
    function rebalance() external;

    function deposit(uint256 amount) external;

    function beforeWithdraw() external;

    function withdraw(uint256 amount) external;

    function withdrawAll() external;

    function isUpgradable() external view returns (bool);

    function isReservedToken(address _token) external view returns (bool);

    function token() external view returns (address);

    function pool() external view returns (address);

    function totalLocked() external view returns (uint256);

    //Lifecycle functions
    function pause() external;

    function unpause() external;
}

// File: contracts/interfaces/vesper/IVesperPool.sol



pragma solidity 0.6.12;


interface IVesperPool is IERC20 {
    function approveToken() external;

    function deposit() external payable;

    function deposit(uint256) external;

    function multiTransfer(uint256[] memory) external returns (bool);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function rebalance() external;

    function resetApproval() external;

    function sweepErc20(address) external;

    function withdraw(uint256) external;

    function withdrawETH(uint256) external;

    function withdrawByStrategy(uint256) external;

    function feeCollector() external view returns (address);

    function getPricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);
}

// File: contracts/interfaces/uniswap/IUniswapV2Router01.sol



pragma solidity 0.6.12;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// File: contracts/interfaces/uniswap/IUniswapV2Router02.sol



pragma solidity 0.6.12;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts/strategies/AaveMakerStrategy.sol



pragma solidity 0.6.12;












/// @dev This strategy will deposit collateral token in Maker and borrow DAI
/// and deposit borrowed DAI in Aave to earn interest on it.
abstract contract AaveMakerStrategy is IStrategy, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant AAVE_ADDRESSES_PROVIDER = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    ICollateralManager public immutable cm;
    IController public immutable controller;
    IERC20 public immutable collateralToken;
    bytes32 public immutable collateralType;
    uint256 public immutable vaultNum;
    address public immutable override pool;
    uint256 public lastRebalanceBlock;
    uint256 public highWater;
    uint256 public lowWater;

    uint256 internal constant MAX_UINT_VALUE = uint256(-1);
    uint256 private constant WAT = 10**16;
    AToken private immutable aToken;

    mapping(address => bool) private reservedToken;

    constructor(
        address _controller,
        address _pool,
        address _collateralToken,
        address _cm,
        bytes32 _collateralType
    ) public {
        require(_controller != address(0), "Controller address is zero");
        require(IController(_controller).isPool(_pool), "Not a valid pool");
        controller = IController(_controller);
        collateralType = _collateralType;
        vaultNum = _createVault(_collateralType, _cm);
        pool = _pool;
        collateralToken = IERC20(_collateralToken);
        cm = ICollateralManager(_cm);
        address aTokenAddress = _getToken();
        aToken = AToken(aTokenAddress);

        reservedToken[_collateralToken] = true;
        reservedToken[aTokenAddress] = true;
        reservedToken[DAI] = true;
    }

    modifier live() {
        require(!paused || _msgSender() == address(controller), "Contract has paused");
        _;
    }

    modifier onlyController() {
        require(_msgSender() == address(controller), "Caller is not the controller");
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == pool, "Caller is not pool");
        _;
    }

    function pause() external override onlyController {
        _pause();
    }

    function unpause() external override onlyController {
        _unpause();
    }

    /// @dev Approve Dai and collateralToken to collateral manager
    function approveToken() external onlyController {
        IERC20(DAI).approve(address(cm), MAX_UINT_VALUE);
        collateralToken.safeApprove(address(cm), MAX_UINT_VALUE);
    }

    /// @dev Reset Dai and collateralToken approval of collateral manager
    function resetApproval() external onlyController {
        IERC20(DAI).approve(address(cm), 0);
        collateralToken.safeApprove(address(cm), 0);
    }

    /**
     * @dev Deposit collateral token into Maker vault.
     * @param _amount Amount of collateral token
     */
    function deposit(uint256 _amount) external override onlyPool {
        _deposit(_amount);
    }

    /**
     * @dev Called during withdrawal process.
     * Withdraw is not allowed if pool in underwater.
     * If pool is underwater, calling resurface() will bring pool above water.
     * It will impact share price in pool and that's why it has to be called before withdraw.
     */
    function beforeWithdraw() external override onlyPool {
        if (isUnderwater()) {
            _resurface();
        }
    }

    /**
     * @dev Withdraw collateral token from Maker and in order to do that strategy
     * has to withdraw Dai from Aave and payback Dai in Maker.
     * @param _amount Amount of collateral token to be withdrawn
     */
    function withdraw(uint256 _amount) external override onlyPool {
        _withdraw(_amount);
    }

    /**
     * @dev Rebalance earning and withdraw all collateral.
     * Controller only function, called when migrating strategy.
     */
    function withdrawAllWithRebalance() external onlyController {
        _rebalanceEarned();
        _withdrawAll();
    }

    /**
     * @dev Withdraw all collateral. No rebalance earning.
     * Controller only function, called when migrating strategy.
     */
    function withdrawAll() external override onlyController {
        _withdrawAll();
    }

    /**
     * @dev Wrapper function for rebalanceEarned and rebalanceCollateral
     * Anyone can call it except when paused.
     */
    function rebalance() external override live {
        _rebalanceEarned();
        _rebalanceCollateral();
    }

    /**
     * @dev Rebalance collateral and debt in Maker.
     * Based on defined risk parameter either borrow more DAI from Maker or
     * payback some DAI in Maker. It will try to mitigate risk of liquidation.
     * Anyone can call it except when paused.
     */
    function rebalanceCollateral() external live {
        _rebalanceCollateral();
    }

    /**
     * @dev Convert earned DAI from Aave to collateral token
     * Also calculate interest fee on earning from Aave and transfer fee to fee collector.
     * Anyone can call it except when paused.
     */
    function rebalanceEarned() external live {
        _rebalanceEarned();
    }

    /**
     * @dev If pool is underwater this function will resolve underwater condition.
     * If Debt in Maker is greater than aDAI balance in Aave then pool in underwater.
     * Lowering DAI debt in Maker will resolve underwater condtion.
     * Resolve: Calculate required collateral token to lower DAI debt. Withdraw required
     * collateral token from pool and/or Maker and convert those to DAI via Uniswap.
     * Finally payback debt in Maker using DAI.
     */
    function resurface() external live {
        _resurface();
    }

    /// @dev sweep given ERC20 token to vesper pool
    function sweepErc20(address _fromToken) external {
        uint256 amount = IERC20(_fromToken).balanceOf(address(this));
        IERC20(_fromToken).safeTransfer(pool, amount);
    }

    function updateBalancingFactor(uint256 _highWater, uint256 _lowWater) external onlyController {
        require(_lowWater != 0, "Value is zero");
        require(_highWater > _lowWater, "highWater <= lowWater");
        highWater = _highWater.mul(WAT);
        lowWater = _lowWater.mul(WAT);
    }

    /**
     * @notice Returns interest earned since last rebalance.
     * @dev Make sure to return value in collateral token and in order to do that
     * we are using Uniswap to get collateral amount for earned DAI.
     */
    function interestEarned() external view returns (uint256) {
        uint256 aDaiBalance = aToken.balanceOf(pool);
        uint256 debt = cm.getVaultDebt(vaultNum);
        if (aDaiBalance > debt) {
            uint256 daiEarned = aDaiBalance.sub(debt);
            IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
            address[] memory path = _getPath(DAI, address(collateralToken));
            return uniswapRouter.getAmountsOut(daiEarned, path)[path.length - 1];
        }
        return 0;
    }

    /// @dev Returns true if strategy can be upgraded.
    function isUpgradable() external view override returns (bool) {
        return totalLocked() == 0;
    }

    function isReservedToken(address _token) external view override returns (bool) {
        return reservedToken[_token];
    }

    /// @dev Address of Aave DAI token
    function token() external view override returns (address) {
        return address(aToken);
    }

    /// @dev Check if pool is underwater i.e. debt is greater than aDai in Aave
    function isUnderwater() public view returns (bool) {
        return cm.getVaultDebt(vaultNum) > aToken.balanceOf(pool);
    }

    /// @dev Returns total collateral locked in Maker vault
    function totalLocked() public view override returns (uint256) {
        return convertFrom18(cm.getVaultBalance(vaultNum));
    }

    /// @dev Convert from 18 decimals to token defined decimals. Default no conversion.
    function convertFrom18(uint256 _amount) public pure virtual returns (uint256) {
        return _amount;
    }

    /// @dev Create new Maker vault
    function _createVault(bytes32 _collateralType, address _cm) internal returns (uint256 vaultId) {
        address mcdManager = ICollateralManager(_cm).mcdManager();
        ManagerLike manager = ManagerLike(mcdManager);
        vaultId = manager.open(_collateralType, address(this));
        manager.cdpAllow(vaultId, address(this), 1);

        //hope and cpdAllow on vat for collateralManager's address
        VatLike(manager.vat()).hope(_cm);
        manager.cdpAllow(vaultId, _cm, 1);

        //Register vault with collateral Manager
        ICollateralManager(_cm).registerVault(vaultId, _collateralType);
    }

    function _deposit(uint256 _amount) internal {
        collateralToken.safeTransferFrom(pool, address(this), _amount);
        cm.depositCollateral(vaultNum, _amount);
    }

    function _depositDaiToAave(uint256 _amount) internal {
        AaveAddressesProvider aaveProvider = AaveAddressesProvider(AAVE_ADDRESSES_PROVIDER);
        address aavePool = aaveProvider.getLendingPool();
        address aavePoolCore = aaveProvider.getLendingPoolCore();

        IERC20(DAI).approve(aavePoolCore, _amount);
        AavePool(aavePool).deposit(DAI, _amount, controller.aaveReferralCode());
        aToken.transfer(pool, _amount);
    }

    /**
     * @dev Deposit fee into Vesper pool to get Vesper pool shares.
     * Transfer fee, Vesper pool shares, to fee collector.
     */
    function _handleFee(uint256 fee) internal {
        if (fee != 0) {
            collateralToken.safeApprove(pool, fee);
            IVesperPool(pool).deposit(fee);
            uint256 feeInShare = IERC20(pool).balanceOf(address(this));
            IERC20(pool).transfer(controller.feeCollector(pool), feeInShare);
        }
    }

    function _moveDaiToMaker(uint256 _amount) internal {
        if (_amount != 0) {
            _withdrawDaiFromAave(_amount);
            cm.payback(vaultNum, _amount);
        }
    }

    function _moveDaiFromMaker(uint256 _amount) internal {
        cm.borrow(vaultNum, _amount);
        _depositDaiToAave(_amount);
    }

    function _rebalanceCollateral() internal {
        _deposit(collateralToken.balanceOf(pool));
        (
            uint256 collateralLocked,
            uint256 debt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        ) = cm.getVaultInfo(vaultNum);
        uint256 maxDebt = collateralLocked.mul(collateralUsdRate).div(highWater);
        if (maxDebt < minimumDebt) {
            // Dusting scenario. Payback all DAI
            _moveDaiToMaker(debt);
        } else {
            if (collateralRatio > highWater) {
                require(!isUnderwater(), "Pool is underwater");
                _moveDaiFromMaker(maxDebt.sub(debt));
            } else if (collateralRatio < lowWater) {
                // Redeem DAI from Aave and deposit in maker
                _moveDaiToMaker(debt.sub(maxDebt));
            }
        }
    }

    function _rebalanceEarned() internal {
        require(
            (block.number - lastRebalanceBlock) >= controller.rebalanceFriction(pool),
            "Can not rebalance"
        );
        lastRebalanceBlock = block.number;
        uint256 debt = cm.getVaultDebt(vaultNum);
        _withdrawExcessDaiFromAave(debt);
        uint256 balance = IERC20(DAI).balanceOf(address(this));
        if (balance != 0) {
            IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
            IERC20(DAI).approve(address(uniswapRouter), balance);
            address[] memory path = _getPath(DAI, address(collateralToken));
            //Swap and get collateralToken here
            uniswapRouter.swapExactTokensForTokens(balance, 1, path, address(this), now + 30);
            uint256 collateralBalance = collateralToken.balanceOf(address(this));
            uint256 fee = collateralBalance.mul(controller.interestFee(pool)).div(1e18);
            collateralToken.safeTransfer(pool, collateralBalance.sub(fee));
            _handleFee(fee);
        }
    }

    function _resurface() internal {
        uint256 earnBalance = aToken.balanceOf(pool);
        uint256 debt = cm.getVaultDebt(vaultNum);
        require(debt > earnBalance, "Pool is above water");
        uint256 shortAmount = debt.sub(earnBalance);
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        address[] memory path = _getPath(address(collateralToken), DAI);
        uint256 tokenNeeded = uniswapRouter.getAmountsIn(shortAmount, path)[0];

        uint256 balance = collateralToken.balanceOf(pool);
        if (balance < tokenNeeded) {
            cm.withdrawCollateral(vaultNum, tokenNeeded.sub(balance));
        }
        if (balance != 0) {
            collateralToken.safeTransferFrom(pool, address(this), balance);
        }
        collateralToken.safeApprove(address(uniswapRouter), tokenNeeded);
        uniswapRouter.swapExactTokensForTokens(tokenNeeded, 1, path, address(this), now + 30);
        uint256 daiBalance = IERC20(DAI).balanceOf(address(this));
        cm.payback(vaultNum, daiBalance);
    }

    function _withdrawDaiFromAave(uint256 _amount) internal {
        aToken.transferFrom(pool, address(this), _amount);
        aToken.redeem(_amount);
    }

    function _withdrawExcessDaiFromAave(uint256 _base) internal {
        uint256 balance = aToken.balanceOf(pool);
        if (balance > _base) {
            uint256 amount = balance.sub(_base);
            aToken.transferFrom(pool, address(this), amount);
            aToken.redeem(amount);
        }
    }

    function _withdraw(uint256 _amount) internal {
        (
            uint256 collateralLocked,
            uint256 debt,
            uint256 collateralUsdRate,
            uint256 collateralRatio,
            uint256 minimumDebt
        ) = cm.whatWouldWithdrawDo(vaultNum, _amount);
        if (debt != 0 && collateralRatio < lowWater) {
            // If this withdraw results in Low Water scenario.
            uint256 maxDebt = collateralLocked.mul(collateralUsdRate).div(highWater);
            if (maxDebt < minimumDebt) {
                // This is Dusting scenario
                _moveDaiToMaker(debt);
            } else if (maxDebt < debt) {
                _moveDaiToMaker(debt.sub(maxDebt));
            }
        }
        cm.withdrawCollateral(vaultNum, _amount);
        collateralToken.safeTransfer(pool, collateralToken.balanceOf(address(this)));
    }

    function _withdrawAll() internal {
        _moveDaiToMaker(cm.getVaultDebt(vaultNum));
        require(cm.getVaultDebt(vaultNum) == 0, "Debt should be 0");
        cm.withdrawCollateral(vaultNum, totalLocked());
        collateralToken.safeTransfer(pool, collateralToken.balanceOf(address(this)));
    }

    /// @dev Get aToken address
    function _getToken() internal view returns (address) {
        AaveAddressesProvider aaveProvider = AaveAddressesProvider(AAVE_ADDRESSES_PROVIDER);
        address aavePoolCore = aaveProvider.getLendingPoolCore();
        return AavePoolCore(aavePoolCore).getReserveATokenAddress(DAI);
    }

    function _getPath(address _from, address _to) internal pure returns (address[] memory) {
        address[] memory path;
        if (_from == WETH || _to == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = _to;
        }
        return path;
    }
}

// File: contracts/strategies/AaveMakerStrategyETH.sol



pragma solidity 0.6.12;


//solhint-disable no-empty-blocks
contract AaveMakerStrategyETH is AaveMakerStrategy {
    constructor(
        address _controller,
        address _pool,
        address _cm
    )
        public
        AaveMakerStrategy(
            _controller,
            _pool,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            _cm,
            "ETH-A"
        )
    {}
}
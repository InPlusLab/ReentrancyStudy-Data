/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

/*
 *
 ¨€¨€¨€¨€¨€¨€¨[  ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨[     ¨€¨€¨€¨€¨€¨€¨[     ¨€¨€¨[  ¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨€¨[     ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨[   ¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[
¨€¨€¨X¨T¨T¨T¨T¨a ¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨U     ¨€¨€¨X¨T¨T¨€¨€¨[    ¨€¨€¨U  ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨T¨T¨a    ¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨€¨€¨[  ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a
¨€¨€¨U  ¨€¨€¨€¨[¨€¨€¨U   ¨€¨€¨U¨€¨€¨U     ¨€¨€¨U  ¨€¨€¨U    ¨€¨€¨€¨€¨€¨€¨€¨U¨€¨€¨U   ¨€¨€¨U¨€¨€¨€¨€¨€¨[      ¨€¨€¨U   ¨€¨€¨U¨€¨€¨X¨€¨€¨[ ¨€¨€¨U¨€¨€¨€¨€¨€¨[  
¨€¨€¨U   ¨€¨€¨U¨€¨€¨U   ¨€¨€¨U¨€¨€¨U     ¨€¨€¨U  ¨€¨€¨U    ¨€¨€¨X¨T¨T¨€¨€¨U¨€¨€¨U   ¨€¨€¨U¨€¨€¨X¨T¨T¨a      ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U¨^¨€¨€¨[¨€¨€¨U¨€¨€¨X¨T¨T¨a  
¨^¨€¨€¨€¨€¨€¨€¨X¨a¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨X¨a    ¨€¨€¨U  ¨€¨€¨U¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨€¨€¨€¨€¨€¨[    ¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U ¨^¨€¨€¨€¨€¨U¨€¨€¨€¨€¨€¨€¨€¨[
 ¨^¨T¨T¨T¨T¨T¨a  ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨T¨T¨T¨T¨a     ¨^¨T¨a  ¨^¨T¨a ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨T¨a     ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨a  ¨^¨T¨T¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a                                                                                              

               Tribute to Satoshi Nakamoto in 2008 and Vitalik Buterin in 2011.
                                - Decentralized believer, PROX.
 *
 */

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT
/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        assembly {
            size := extcodesize(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{value: weiValue}(data);
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public lp = IERC20(0xA56Ed2632E443Db5f93e73C89df399a081408Cc4);

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(address _lp) public {
        lp = IERC20(_lp);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _stake(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lp.safeTransferFrom(msg.sender, address(this), amount);
    }

    function _withdraw(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lp.safeTransfer(msg.sender, amount);
    }
}

contract StakingPool is LPTokenWrapper, Ownable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 poolId;
        uint256 stakingTime;
        uint256 lastRewardIndicator;
        uint256 pendingReward;
    }

    struct PoolInfo {
        address owner;
        address beneficiary;
        uint256 announceTime;
        uint256 announceIndicator;
        uint256 amount; // How many tokens staked in the pool
        uint256 profit;
    }

    enum PoolAnnounceStatusCode {
        OK,
        WRONG_PID,
        POOL_HAS_OWNER,
        NEED_MORE_DEPOSIT,
        USER_IN_ANOTHER_POOL
    }

    IERC20 public rewardToken =
        IERC20(0xA56Ed2632E443Db5f93e73C89df399a081408Cc4);

    uint256 public constant SECONDS_PER_DAY = 1 days;

    uint256 public constant REWARD_DURATION = 7 * SECONDS_PER_DAY;
    uint256 public constant MIN_STAKE_DURATION = 1 * SECONDS_PER_DAY;

    // pool related constant
    uint256 public constant MAX_POOL_NUMBER = 108;
    uint256 public constant MIN_POOL_ANNOUNCE_AMOUNT = 50 * 1e18;
    uint256 public constant MIN_POOL_DEPOSIT_AMOUNT = 100 * 1e18;
    uint256 public constant MIN_POOL_ANNOUNCE_DURATION = 3 * SECONDS_PER_DAY;

    PoolInfo[] private poolInfo;
    mapping(address => UserInfo) public userInfo;

    uint256 public periodFinish;
    uint256 public rewardTimeProgress = 0;
    uint256 public lastRewardUpdateTime = 0;

    uint256 public rewardRatePerDay = 100;
    uint256 public constant REWARD_RATE_BASE = 10000;

    address public dev;
    uint256 public devAmout;

    address public treasury;
    uint256 public treasuryAmount;

    bool public breaker = false;
    mapping(address => bool) public whiteList;

    /* ========== EVENTS ========== */

    event Deposited(address indexed user, uint256 amount, uint256 pid);
    event Withdrawn(address indexed user, uint256 amount, uint256 pid);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardPaidToOwner(address indexed owner, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address indexed token, uint256 amount);
    event Announced(address indexed owner, uint256 pid);
    event Renounced(address indexed owner, uint256 pid);
    event BeneficiaryTransferred(
        address indexed previousBeneficiary,
        address indexed newBeneficiary,
        uint256 pid
    );
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(address token) public LPTokenWrapper(token) {
        rewardToken = IERC20(token);
        treasury = owner();
        dev = owner();
    }

    function createPool(uint256 count) external onlyOwner {
        require(
            poolInfo.length.add(count) <= MAX_POOL_NUMBER,
            "too much pools"
        );
        for (uint256 i = 0; i < count; i++) {
            poolInfo.push(
                PoolInfo({
                    owner: address(0),
                    beneficiary: address(0),
                    announceTime: 0,
                    announceIndicator: 0,
                    amount: 0,
                    profit: 0
                })
            );
        }
    }

    function notifyRewardAmount() external onlyOwner updateReward(address(0)) {
        require(currentTime() >= periodFinish, "not finish");
        lastRewardUpdateTime = currentTime();
        periodFinish = currentTime().add(REWARD_DURATION);
        emit RewardsDurationUpdated(periodFinish);
    }

    modifier updateReward(address account) {
        rewardTimeProgress = calcRewardTimeProgress();
        lastRewardUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            UserInfo storage user = userInfo[account];
            user.pendingReward = _earned(account, user.lastRewardIndicator);
            user.lastRewardIndicator = rewardTimeProgress;
        }
        _;
    }

    function calcRewardTimeProgress() public view returns (uint256) {
        return
            rewardTimeProgress.add(
                lastTimeRewardApplicable().sub(lastRewardUpdateTime)
            );
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function getRewardV2() public updateReward(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 userEarned = _earned(msg.sender, user.lastRewardIndicator);

        if (userEarned == 0) {
            return;
        }

        // clear pending reward before transfer
        user.pendingReward = 0;

        // user reward
        uint256 userClaimable = userEarned.mul(80).div(100);
        if (currentTime() < user.stakingTime + MIN_STAKE_DURATION) {
            userClaimable = userClaimable.mul(50).div(100);
            treasuryAmount = treasuryAmount.add(userClaimable);
        }
        safeRewardTransfer(msg.sender, userClaimable);
        emit RewardPaid(msg.sender, userClaimable);

        // pool reward
        uint256 poolEarned = 0;
        PoolInfo storage pool = poolInfo[user.poolId];

        if (
            pool.owner != address(0) && pool.amount >= MIN_POOL_DEPOSIT_AMOUNT
        ) {
            poolEarned = _earned(msg.sender, pool.announceIndicator);
            poolEarned = Math.min(userEarned, poolEarned);
            uint256 poolProfit = poolEarned.mul(20).div(100);

            address poolProfitPaidAddress = pool.beneficiary;
            pool.profit = pool.profit.add(poolProfit);
            safeRewardTransfer(poolProfitPaidAddress, poolProfit);

            emit RewardPaidToOwner(poolProfitPaidAddress, poolProfit);
        }

        // treasury profit
        if (userEarned > poolEarned) {
            uint256 devProfit = userEarned.sub(poolEarned).mul(20).div(100);
            devAmout = devAmout.add(devProfit);
        }
    }

    function deposit(uint256 pid, uint256 amount)
        external
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot deposit 0");
        require(pid < poolInfo.length, "Invalid pool id");

        UserInfo storage user = userInfo[msg.sender];

        if (balanceOf(msg.sender) > 0) {
            require(pid == user.poolId, "Can deposit in only one pool");
        }

        super._stake(amount);

        user.stakingTime = currentTime();
        user.poolId = pid;

        PoolInfo storage pool = poolInfo[pid];
        pool.amount = pool.amount.add(amount);

        emit Deposited(msg.sender, amount, pid);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(balanceOf(msg.sender) >= amount, "Not enough");

        UserInfo memory user = userInfo[msg.sender];
        require(
            currentTime() > user.stakingTime + MIN_STAKE_DURATION,
            "Cannot withdraw before minimal staking duration"
        );

        PoolInfo storage pool = poolInfo[user.poolId];
        if (pool.owner == msg.sender) {
            require(
                balanceOf(msg.sender) >= amount.add(MIN_POOL_ANNOUNCE_AMOUNT),
                "Cannot withdraw"
            );
        }

        super._withdraw(amount);

        pool.amount = pool.amount.sub(amount);

        emit Withdrawn(msg.sender, amount, user.poolId);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getRewardV2();
    }

    function earned(address account)
        external
        view
        returns (uint256 userClaimable, uint256 fullRewardTime)
    {
        UserInfo memory user = userInfo[account];
        uint256 userEarned = _earned(account, user.lastRewardIndicator);
        userClaimable = userEarned.mul(80).div(100);
        fullRewardTime = user.stakingTime + MIN_STAKE_DURATION;
    }

    function announce(uint256 pid) external {
        require(
            !address(msg.sender).isContract() || whiteList[msg.sender],
            "Not welcome"
        );

        require(
            balanceOf(msg.sender) >= MIN_POOL_ANNOUNCE_AMOUNT,
            "depoist more to announce"
        );

        PoolAnnounceStatusCode status = checkAnnounceable(pid, msg.sender);
        require(status == PoolAnnounceStatusCode.OK, "Check Status Code");

        PoolInfo storage pool = poolInfo[pid];
        pool.owner = msg.sender;
        pool.beneficiary = msg.sender;
        pool.announceTime = currentTime();
        pool.announceIndicator = calcRewardTimeProgress();
        pool.profit = 0;

        emit Announced(msg.sender, pid);
    }

    function renounce(uint256 pid) external {
        PoolInfo storage pool = poolInfo[pid];
        require(pool.owner == msg.sender, "Must be owner");
        require(
            pool.announceTime + MIN_POOL_ANNOUNCE_DURATION < currentTime(),
            "Cannot renounce now"
        );

        pool.owner = address(0);
        pool.beneficiary = address(0);
        pool.announceTime = 0;

        emit Renounced(msg.sender, pid);
    }

    function setBeneficiary(uint256 _pid, address _beneficiary) external {
        require(_beneficiary != address(0), "!_beneficiary");
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.owner == msg.sender, "Must be owner");
        address preBeneficiary = pool.beneficiary;
        pool.beneficiary = _beneficiary;
        emit BeneficiaryTransferred(preBeneficiary, pool.beneficiary, _pid);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0));
        treasury = _treasury;
    }

    function setDev(address _dev) external onlyOwner {
        require(_dev != address(0));
        dev = _dev;
    }

    function setBreaker(bool _breaker) external onlyOwner {
        breaker = _breaker;
    }

    function setWhiteList(address addr, bool status) external onlyOwner {
        require(addr != address(0), "!addr");
        whiteList[addr] = status;
    }

    function setRewardRatePerDay(uint256 rate) external onlyOwner {
        require(currentTime() > periodFinish, "not finish");
        require(rewardRatePerDay <= REWARD_RATE_BASE, "!wrong rate");
        rewardRatePerDay = rate;
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        require(
            tokenAddress != address(lp) && tokenAddress != address(rewardToken),
            "Cannot withdraw the staking or rewards tokens"
        );
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    // withdraw extra reward tokens after staking period
    function withdrawAll() external onlyOwner {
        require(currentTime() > periodFinish, "period not finished");
        uint256 bal = rewardToken.balanceOf(address(this));
        uint256 amount = bal.sub(totalSupply());
        IERC20(rewardToken).safeTransfer(owner(), amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() external {
        require(breaker, "!breaker");

        UserInfo storage user = userInfo[msg.sender];
        user.pendingReward = 0;

        uint256 amount = balanceOf(msg.sender);
        super._withdraw(amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    function withdrawDev() external {
        require(_msgSender() == dev || _msgSender() == owner(), "!dev");
        if (devAmout > 0) {
            safeRewardTransfer(dev, devAmout);
            devAmout = 0;
        }
    }

    function withdrawTreasury() external {
        require(
            _msgSender() == treasury || _msgSender() == owner(),
            "!treasury"
        );
        if (treasuryAmount > 0) {
            safeRewardTransfer(treasury, treasuryAmount);
            treasuryAmount = 0;
        }
    }

    function maxWithdrawAmount(address account) public view returns (uint256) {
        uint256 maxAmount = balanceOf(account);
        UserInfo memory user = userInfo[account];
        if (user.stakingTime + MIN_STAKE_DURATION >= currentTime()) {
            return 0;
        }
        PoolInfo memory pool = poolInfo[user.poolId];
        if (pool.owner == account) {
            return maxAmount.sub(MIN_POOL_ANNOUNCE_AMOUNT);
        }
        return maxAmount;
    }

    function queryPoolInfo(uint256 pid, address account)
        public
        view
        returns (
            bool hasOwner,
            bool isOwner,
            uint256 announceableStatus,
            uint256 totalAmount,
            uint256 announceTime,
            uint256 poolProfit,
            address beneficiary
        )
    {
        PoolInfo memory pool = poolInfo[pid];
        if (pool.owner != address(0)) {
            hasOwner = true;
            if (pool.owner == address(account)) {
                isOwner = true;
            }
        }
        announceableStatus = uint256(checkAnnounceable(pid, account));
        totalAmount = pool.amount;
        if (hasOwner) {
            announceTime = pool.announceTime;
            poolProfit = pool.profit;
        }
        if (isOwner) {
            beneficiary = pool.beneficiary;
        }
    }

    function poolCount() public view returns (uint256) {
        return uint256(poolInfo.length);
    }

    function _earned(address account, uint256 indicator)
        internal
        view
        returns (uint256)
    {
        require(calcRewardTimeProgress() >= indicator, "!indicator");
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account)
                .mul(calcRewardTimeProgress().sub(indicator))
                .mul(rewardRatePerDay)
                .div(REWARD_RATE_BASE)
                .div(SECONDS_PER_DAY)
                .add(user.pendingReward);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 bal = rewardToken.balanceOf(address(this));
        require(_amount.add(totalSupply()) <= bal, "out of totalSupply");
        rewardToken.transfer(_to, _amount);
    }

    function checkAnnounceable(uint256 pid, address account)
        internal
        view
        returns (PoolAnnounceStatusCode)
    {
        // check pid
        if (pid >= poolInfo.length) {
            return PoolAnnounceStatusCode.WRONG_PID;
        }
        // check owner
        PoolInfo memory pool = poolInfo[pid];
        if (pool.owner != address(0)) {
            return PoolAnnounceStatusCode.POOL_HAS_OWNER;
        }
        // check user
        UserInfo memory user = userInfo[account];
        if (balanceOf(account) > 0 && pid != user.poolId) {
            return PoolAnnounceStatusCode.USER_IN_ANOTHER_POOL;
        }
        // check the minimum deposit requirement
        if (balanceOf(account) < MIN_POOL_ANNOUNCE_AMOUNT) {
            return PoolAnnounceStatusCode.NEED_MORE_DEPOSIT;
        }
        return PoolAnnounceStatusCode.OK;
    }

    function currentTime() internal view returns (uint256) {
        return block.timestamp;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;


// 
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

// 
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

// 
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

// 
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

// 
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

// 
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
}

enum RebaseResult { Double, Park, Draw }

interface ITautrinoToken {
    function rebase(RebaseResult result) external returns (uint);
    function setGovernance(address _governance) external;
    function factor2() external view returns (uint);
}

interface ITautrinoRewardPool {
    function withdrawReward(address _to, address _token, uint256 _amount) external;
}

contract TautrinoFarming is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ITautrinoRewardPool public rewardPool;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Total reward distributed.
    }

    struct PoolInfo {
        IERC20 lpToken;                                     // Address of LP token contract.
        address rewardToken;                                // Address of reward token - TAU or TRINO.
        mapping (address => uint256) userLastRewardEpoch;   // last reward epoch of user in this pool.
        uint256 rewardPerShare;                             // Reward per share, times 1e12. See below.
        uint256 totalRewardPaid;                            // Total reward paid in this pool.
        uint256 deposits;                                   // Current deposited amount.
        uint256 rewardEndEpoch;                             // Pool farming reward end timestamp. 0: no end
    }

    PoolInfo[] _poolInfo;
    mapping (address => bool) public tokenAdded;
    mapping (uint256 => mapping (address => UserInfo)) _userInfo;

    event onDeposit(address indexed user, uint256 indexed pid, uint256 amount);
    event onWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event onClaimReward(address indexed user, uint256 indexed pid, uint256 reward, uint256 baseReward);

    /**
     * @dev Constructor.
     * @param _rewardPool reward pool address.
     */

    constructor(ITautrinoRewardPool _rewardPool) public Ownable() {
        rewardPool = _rewardPool;
    }

    /**
     * @return return pool length.
     */

    function poolLength() external view returns (uint256) {
        return _poolInfo.length;
    }

    /**
     * @dev add new pool. must be called by owner
     * @param _lpToken lpToken for farming.
     * @param _rewardToken reward token by farming.
     * @param _rewardPerShare reward per lp share.
     */

    function add(address _lpToken, address _rewardToken, uint256 _rewardPerShare) external onlyOwner {
        require(tokenAdded[_lpToken] == false, "already exist!");
        _poolInfo.push(PoolInfo({
            lpToken: IERC20(_lpToken),
            rewardToken: _rewardToken,
            rewardPerShare: _rewardPerShare,
            totalRewardPaid: 0,
            deposits: 0,
            rewardEndEpoch: 0
        }));
        tokenAdded[_lpToken] = true;
    }

    /**
     * @dev update rewardPerShare of pool. must be called by owner
     * @param _pid id of pool.
     * @param _rewardPerShare new reward per lp share. 0 - no update
     * @param _rewardEndEpoch reward end epoch. 0 - no update
     */

    function set(uint256 _pid, uint256 _rewardPerShare, uint256 _rewardEndEpoch) external onlyOwner {
        if (_rewardPerShare > 0) {
            _poolInfo[_pid].rewardPerShare = _rewardPerShare;
        }
        if (_rewardEndEpoch > 0) {
            _poolInfo[_pid].rewardEndEpoch = _rewardEndEpoch;
        }
    }

    /**
     * @dev pending reward of user in the pool.
     * @param _pid id of pool.
     * @param _user user address.
     * @return pending reward amount.
     */

    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        uint256 factor2 = ITautrinoToken(_poolInfo[_pid].rewardToken).factor2();
        return pendingBaseReward(_pid, _user).mul(2 ** factor2);
    }

    /**
     * @dev pending base reward of user in the pool.
     * @param _pid id of pool.
     * @param _user user address.
     * @return pending reward amount.
     */

    function pendingBaseReward(uint256 _pid, address _user) internal view returns (uint256) {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_user];
        uint256 lastRewardEpoch = pool.userLastRewardEpoch[_user];
        uint rewardEndEpoch = block.timestamp;
        if (pool.rewardEndEpoch > 0 && pool.rewardEndEpoch < block.timestamp) {
            rewardEndEpoch = pool.rewardEndEpoch;
        }
        if (rewardEndEpoch > lastRewardEpoch) {
            return user.amount.mul(pool.rewardPerShare).div(1e12).mul(rewardEndEpoch - lastRewardEpoch);
        }
        return 0;
    }

    /**
     * @dev deposit lp token.
     * @param _pid id of pool.
     * @param _amount lp amount.
     */

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = _poolInfo[_pid];
        require(pool.rewardEndEpoch == 0 || pool.rewardEndEpoch > block.timestamp, "paused!");

        UserInfo storage user = _userInfo[_pid][msg.sender];

        _claimReward(_pid, msg.sender);

        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.deposits = pool.deposits.add(_amount);
        }

        emit onDeposit(msg.sender, _pid, _amount);
    }

    /**
     * @dev withdraw lp token.
     * @param _pid id of pool.
     * @param _amount lp amount.
     */

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "insufficient!");

        _claimReward(_pid, msg.sender);

        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.deposits = pool.deposits.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        emit onWithdraw(msg.sender, _pid, _amount);
    }

    /**
     * @dev claim pending reward.
     * @param _pid id of pool.
     */

    function claimReward(uint256 _pid) external {
        _claimReward(_pid, msg.sender);
    }

    /**
     * @dev claim pending reward to user - internal method.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function _claimReward(uint256 _pid, address _user) internal {
        PoolInfo storage pool = _poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][_user];

        uint256 baseReward = pendingBaseReward(_pid, _user);

        if (baseReward > 0) {
            uint256 factor2 = ITautrinoToken(pool.rewardToken).factor2();
            uint256 reward = baseReward.mul(2 ** factor2);
            rewardPool.withdrawReward(_user, pool.rewardToken, reward);
            user.rewardDebt = user.rewardDebt.add(baseReward);

            pool.totalRewardPaid = pool.totalRewardPaid.add(baseReward);
            emit onClaimReward(_user, _pid, reward, baseReward);
        }
        pool.userLastRewardEpoch[_user] = block.timestamp;
    }

    /**
     * @dev last reward timestamp of user.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function userLastRewardEpoch(uint256 _pid, address _user) external view returns (uint256) {
        return _poolInfo[_pid].userLastRewardEpoch[_user];
    }

    /**
     * @dev User info.
     * @param _pid id of pool.
     * @param _user user address.
     */

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256, uint256) {
        UserInfo memory user = _userInfo[_pid][_user];
        uint256 factor2 = ITautrinoToken(_poolInfo[_pid].rewardToken).factor2();
        uint256 rewardDistributed = user.rewardDebt.mul(2 ** factor2);
        uint256 reward = pendingReward(_pid, _user);
        return (user.amount, rewardDistributed, reward);
    }

    /**
     * @dev Pool info.
     * @param _pid id of pool.
     */

    function poolInfo(uint256 _pid) external view returns (address, address, uint256, uint256, uint256, uint256) {
        PoolInfo memory pool = _poolInfo[_pid];
        address rewardToken = pool.rewardToken;
        uint256 factor2 = ITautrinoToken(rewardToken).factor2();
        uint256 rewardDistributed = pool.totalRewardPaid.mul(2 ** factor2);
        return (address(pool.lpToken), rewardToken, pool.rewardPerShare, rewardDistributed, pool.deposits, pool.rewardEndEpoch);
    }

    /**
     * @dev set reward pool. must be called by owner
     * @param _rewardPool new reward pool address.
     */

    function setRewardPool(ITautrinoRewardPool _rewardPool) public onlyOwner {
        rewardPool = _rewardPool;
    }
}
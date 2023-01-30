/**
 *Submitted for verification at Etherscan.io on 2021-03-17
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

// File: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// File: contracts/common/SafeAmount.sol

pragma solidity >=0.6.0 <0.8.0;



library SafeAmount {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount) internal returns (uint256)  {
        uint256 preBalance = IERC20(token).balanceOf(to);
        IERC20(token).transferFrom(from, to, amount);
        uint256 postBalance = IERC20(token).balanceOf(to);
        return postBalance.sub(preBalance);
    }
}

// File: contracts/staking/Festaked.Library.sol

pragma solidity >=0.6.0 <0.8.0;




library FestakedLib {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    event Staked(address indexed token, address indexed staker_, uint256 requestedAmount_, uint256 stakedAmount_);
    event PaidOut(address indexed token, address indexed rewardToken, address indexed staker_, uint256 amount_, uint256 reward_);

    struct FestakeState {
        uint256 stakedTotal;
        uint256 stakingCap;
        uint256 stakedBalance;
        uint256 withdrawnEarly;
        mapping(address => uint256) _stakes;
    }

    struct FestakeRewardState {
        uint256 rewardBalance;
        uint256 rewardsTotal;
        uint256 earlyWithdrawReward;
    }

    function VERSION() external pure returns(uint) {
        return 1001;
    }

    function tryStake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        FestakeState storage state
        )
    public
    _after(stakingStarts)
    _before(stakingEnds)
    _positive(amount)
    returns (uint256) {
        // check the remaining amount to be staked
        // For pay per transfer tokens we limit the cap on incoming tokens for simplicity. This might
        // mean that cap may not necessary fill completely which is ok.
        uint256 remaining = amount;
        // uint256 stakedTotal = state.stakedTotal;
        {
        uint256 stakedBalance = state.stakedBalance;
        if (stakingCap > 0 && remaining > (stakingCap.sub(stakedBalance))) {
            remaining = stakingCap.sub(stakedBalance);
        }
        }
        // These requires are not necessary, because it will never happen, but won't hurt to double check
        // this is because stakedTotal and stakedBalance are only modified in this method during the staking period
        require(remaining > 0, "Festaking: Staking cap is filled");
        // require((remaining + stakedTotal) <= stakingCap, "Festaking: this will increase staking amount pass the cap");
        // Update remaining in case actual amount paid was different.
        remaining = _payMe(payer, remaining, tokenAddress);
        emit Staked(tokenAddress, staker, amount, remaining);

        // Transfer is completed
        return remaining;
    }

    function stake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        FestakeState storage state
        )
    external
    returns (bool) {
        uint256 remaining = tryStake(payer, staker, amount,
            stakingStarts, stakingEnds, stakingCap, tokenAddress, state);

        // Transfer is completed
        state.stakedBalance = state.stakedBalance.add(remaining);
        state.stakedTotal = state.stakedTotal.add(remaining);
        state._stakes[staker] = state._stakes[staker].add(remaining);
        return true;
    }

    function addReward(
        uint256 rewardAmount,
        uint256 withdrawableAmount,
        address rewardTokenAddress,
        FestakeRewardState storage state
    )
    external
    returns (bool) {
        require(rewardAmount > 0, "Festaking: reward must be positive");
        require(withdrawableAmount >= 0, "Festaking: withdrawable amount cannot be negative");
        require(withdrawableAmount <= rewardAmount, "Festaking: withdrawable amount must be less than or equal to the reward amount");
        address from = msg.sender;
        rewardAmount = _payMe(from, rewardAmount, rewardTokenAddress);
        state.rewardsTotal = state.rewardsTotal.add(rewardAmount);
        state.rewardBalance = state.rewardBalance.add(rewardAmount);
        state.earlyWithdrawReward = state.earlyWithdrawReward.add(withdrawableAmount);
        return true;
    }

    function addMarginalReward(
        address rewardTokenAddress,
        address tokenAddress,
        address me,
        uint256 stakedBalance,
        FestakeRewardState storage state)
        external
        returns (bool) {
        uint256 amount = IERC20(rewardTokenAddress).balanceOf(me).sub(state.rewardsTotal);
        if (rewardTokenAddress == tokenAddress) {
            amount = amount.sub(stakedBalance);
        }
        if (amount == 0) {
            return true; // No reward to add. Its ok. No need to fail callers.
        }
        state.rewardsTotal = state.rewardsTotal.add(amount);
        state.rewardBalance = state.rewardBalance.add(amount);
        return true;
    }

    function tryWithdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    public
    _after(withdrawStarts)
    _positive(amount)
    _realAddress(msg.sender)
    returns (uint256) {
        require(amount <= state._stakes[from], "Festaking: not enough balance");
        if (now < withdrawEnds) {
            return _withdrawEarly(tokenAddress, rewardTokenAddress, from, amount, withdrawEnds,
                stakingEnds, state, rewardState);
        } else {
            return _withdrawAfterClose(tokenAddress, rewardTokenAddress, from, amount, state, rewardState);
        }
    }

    function withdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    public
    returns (bool) {
        uint256 wdAmount = tryWithdraw(from, tokenAddress, rewardTokenAddress, amount, withdrawStarts,
            withdrawEnds, stakingEnds, state, rewardState);
        state.stakedBalance = state.stakedBalance.sub(wdAmount);
        state._stakes[from] = state._stakes[from].sub(wdAmount);
        return true;
    }

    function _withdrawEarly(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    private
    _realAddress(from)
    returns (uint256) {
        // This is the formula to calculate reward:
        // r = (earlyWithdrawReward / stakedTotal) * (now - stakingEnds) / (withdrawEnds - stakingEnds)
        // w = (1+r) * a
        uint256 denom = (withdrawEnds.sub(stakingEnds)).mul(state.stakedTotal);
        uint256 reward = (
        ( (now.sub(stakingEnds)).mul(rewardState.earlyWithdrawReward) ).mul(amount)
        ).div(denom);
        rewardState.rewardBalance = rewardState.rewardBalance.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "Festaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _withdrawAfterClose(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    ) private
    _realAddress(from)
    returns (uint256) {
        uint256 rewBal = rewardState.rewardBalance;
        uint256 reward = (rewBal.mul(amount)).div(state.stakedBalance);
        rewardState.rewardBalance = rewBal.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "Festaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _payMe(address payer, uint256 amount, address token)
    internal
    returns (uint256) {
        return _payTo(payer, address(this), amount, token);
    }

    function _payTo(address allower, address receiver, uint256 amount, address token)
    internal
    returns (uint256) {
        // Request to transfer amount from the contract to receiver.
        // contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        return SafeAmount.safeTransferFrom(token, allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount, address token)
    private
    returns (bool) {
        if (amount == 0) {
            return true;
        }
        IERC20(token).safeTransfer(to, amount);
        return true;
    }

    modifier _realAddress(address addr) {
        require(addr != address(0), "Festaking: zero address");
        _;
    }

    modifier _positive(uint256 amount) {
        require(amount != 0, "Festaking: negative amount");
        _;
    }

    modifier _after(uint eventTime) {
        require(now >= eventTime, "Festaking: bad timing for the request");
        _;
    }

    modifier _before(uint eventTime) {
        require(now < eventTime, "Festaking: bad timing for the request");
        _;
    }
}
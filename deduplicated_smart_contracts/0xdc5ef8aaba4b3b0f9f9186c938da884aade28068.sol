// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

interface IAddressList {
    function add(address a) external returns (bool);

    function remove(address a) external returns (bool);

    function get(address a) external view returns (uint256);

    function contains(address a) external view returns (bool);

    function length() external view returns (uint256);

    function grantRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

interface IPoolRewards {
    /// Emitted after reward added
    event RewardAdded(address indexed rewardToken, uint256 reward, uint256 rewardDuration);
    /// Emitted whenever any user claim rewards
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    /// Emitted after adding new rewards token into rewardTokens array
    event RewardTokenAdded(address indexed rewardToken, address[] existingRewardTokens);

    function claimReward(address) external;

    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external;

    function notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations
    ) external;

    function updateReward(address) external;

    function claimable(address _account)
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts);

    function lastTimeRewardApplicable(address _rewardToken) external view returns (uint256);

    function rewardForDuration()
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration);

    function rewardPerToken()
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../bloq/IAddressList.sol";

interface IVesperPool is IERC20 {
    function deposit() external payable;

    function deposit(uint256 _share) external;

    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);

    function excessDebt(address _strategy) external view returns (uint256);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function poolRewards() external returns (address);

    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;

    function reportLoss(uint256 _loss) external;

    function resetApproval() external;

    function sweepERC20(address _fromToken) external;

    function withdraw(uint256 _amount) external;

    function withdrawETH(uint256 _amount) external;

    function whitelistedWithdraw(uint256 _amount) external;

    function governor() external view returns (address);

    function keepers() external view returns (IAddressList);

    function maintainers() external view returns (IAddressList);

    function feeCollector() external view returns (address);

    function pricePerShare() external view returns (uint256);

    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );

    function stopEverything() external view returns (bool);

    function token() external view returns (IERC20);

    function tokensHere() external view returns (uint256);

    function totalDebtOf(address _strategy) external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../interfaces/vesper/IPoolRewards.sol";
import "../interfaces/vesper/IVesperPool.sol";

contract PoolRewardsStorage {
    /// Vesper pool address
    address public pool;

    /// Array of reward token addresses
    address[] public rewardTokens;

    /// Reward token to valid/invalid flag mapping
    mapping(address => bool) public isRewardToken;

    /// Reward token to period ending of current reward
    mapping(address => uint256) public periodFinish;

    /// Reward token to current reward rate mapping
    mapping(address => uint256) public rewardRates;

    /// Reward token to Duration of current reward distribution
    mapping(address => uint256) public rewardDuration;

    /// Reward token to Last reward drip update time stamp mapping
    mapping(address => uint256) public lastUpdateTime;

    /// Reward token to Reward per token mapping. Calculated and stored at last drip update
    mapping(address => uint256) public rewardPerTokenStored;

    /// Reward token => User => Reward per token stored at last reward update
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;

    /// RewardToken => User => Rewards earned till last reward update
    mapping(address => mapping(address => uint256)) public rewards;
}

/// @title Distribute rewards based on vesper pool balance and supply
contract PoolRewards is Initializable, IPoolRewards, ReentrancyGuard, PoolRewardsStorage {
    string public constant VERSION = "3.0.13";
    using SafeERC20 for IERC20;

    /**
     * @dev Called by proxy to initialize this contract
     * @param _pool Vesper pool address
     * @param _rewardTokens Array of reward token addresses
     */
    function initialize(address _pool, address[] memory _rewardTokens) public initializer {
        require(_pool != address(0), "pool-address-is-zero");
        require(_rewardTokens.length != 0, "invalid-reward-tokens");
        pool = _pool;
        rewardTokens = _rewardTokens;
        for (uint256 i = 0; i < _rewardTokens.length; i++) {
            isRewardToken[_rewardTokens[i]] = true;
        }
    }

    modifier onlyAuthorized() {
        require(msg.sender == IVesperPool(pool).governor(), "not-authorized");
        _;
    }

    /**
     * @notice Notify that reward is added. Only authorized caller can call
     * @dev Also updates reward rate and reward earning period.
     * @param _rewardTokens Tokens being rewarded
     * @param _rewardAmounts Rewards amount for token on same index in rewardTokens array
     * @param _rewardDurations Duration for which reward will be distributed
     */
    function notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations
    ) external virtual override onlyAuthorized {
        _notifyRewardAmount(_rewardTokens, _rewardAmounts, _rewardDurations, IERC20(pool).totalSupply());
    }

    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external virtual override onlyAuthorized {
        _notifyRewardAmount(_rewardToken, _rewardAmount, _rewardDuration, IERC20(pool).totalSupply());
    }

    /// @notice Add new reward token in existing rewardsToken array
    function addRewardToken(address _newRewardToken) external onlyAuthorized {
        require(_newRewardToken != address(0), "reward-token-address-zero");
        require(!isRewardToken[_newRewardToken], "reward-token-already-exist");
        emit RewardTokenAdded(_newRewardToken, rewardTokens);
        rewardTokens.push(_newRewardToken);
        isRewardToken[_newRewardToken] = true;
    }

    /**
     * @notice Claim earned rewards.
     * @dev This function will claim rewards for all tokens being rewarded
     */
    function claimReward(address _account) external override nonReentrant {
        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        for (uint256 i = 0; i < _len; i++) {
            address _rewardToken = rewardTokens[i];
            _updateReward(_rewardToken, _account, _totalSupply, _balance);

            // Claim rewards
            uint256 reward = rewards[_rewardToken][_account];
            if (reward != 0 && reward <= IERC20(_rewardToken).balanceOf(address(this))) {
                rewards[_rewardToken][_account] = 0;
                IERC20(_rewardToken).safeTransfer(_account, reward);
                emit RewardPaid(_account, _rewardToken, reward);
            }
        }
    }

    /**
     * @notice Updated reward for given account. Only Pool can call
     */
    function updateReward(address _account) external override {
        require(msg.sender == pool, "only-pool-can-update-reward");
        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        for (uint256 i = 0; i < _len; i++) {
            _updateReward(rewardTokens[i], _account, _totalSupply, _balance);
        }
    }

    /**
     * @notice Returns claimable reward amount.
     * @return _rewardTokens Array of tokens being rewarded
     * @return _claimableAmounts Array of claimable for token on same index in rewardTokens
     */
    function claimable(address _account)
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts)
    {
        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        _claimableAmounts = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _claimableAmounts[i] = _claimable(rewardTokens[i], _account, _totalSupply, _balance);
        }
        _rewardTokens = rewardTokens;
    }

    /// @notice Provides easy access to all rewardTokens
    function getRewardTokens() external view returns (address[] memory) {
        return rewardTokens;
    }

    /// @notice Returns timestamp of last reward update
    function lastTimeRewardApplicable(address _rewardToken) public view override returns (uint256) {
        return block.timestamp < periodFinish[_rewardToken] ? block.timestamp : periodFinish[_rewardToken];
    }

    function rewardForDuration()
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration)
    {
        uint256 _len = rewardTokens.length;
        _rewardForDuration = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _rewardForDuration[i] = rewardRates[rewardTokens[i]] * rewardDuration[rewardTokens[i]];
        }
        _rewardTokens = rewardTokens;
    }

    /**
     * @notice Rewards rate per pool token
     * @return _rewardTokens Array of tokens being rewarded
     * @return _rewardPerTokenRate Array of Rewards rate for token on same index in rewardTokens
     */
    function rewardPerToken()
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate)
    {
        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _len = rewardTokens.length;
        _rewardPerTokenRate = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _rewardPerTokenRate[i] = _rewardPerToken(rewardTokens[i], _totalSupply);
        }
        _rewardTokens = rewardTokens;
    }

    function _claimable(
        address _rewardToken,
        address _account,
        uint256 _totalSupply,
        uint256 _balance
    ) internal view returns (uint256) {
        uint256 _rewardPerTokenAvailable =
            _rewardPerToken(_rewardToken, _totalSupply) - userRewardPerTokenPaid[_rewardToken][_account];
        uint256 _rewardsEarnedSinceLastUpdate = (_balance * _rewardPerTokenAvailable) / 1e18;
        return rewards[_rewardToken][_account] + _rewardsEarnedSinceLastUpdate;
    }

    // There are scenarios when extending contract will override external methods and
    // end up calling internal function. Hence providing internal functions
    function _notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations,
        uint256 _totalSupply
    ) internal {
        uint256 _len = _rewardTokens.length;
        uint256 _amountsLen = _rewardAmounts.length;
        uint256 _durationsLen = _rewardDurations.length;
        require(_len != 0, "invalid-reward-tokens");
        require(_amountsLen != 0, "invalid-reward-amounts");
        require(_durationsLen != 0, "invalid-reward-durations");
        require(_len == _amountsLen && _len == _durationsLen, "array-length-mismatch");
        for (uint256 i = 0; i < _len; i++) {
            _notifyRewardAmount(_rewardTokens[i], _rewardAmounts[i], _rewardDurations[i], _totalSupply);
        }
    }

    function _notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration,
        uint256 _totalSupply
    ) internal {
        require(_rewardToken != address(0), "incorrect-reward-token");
        require(_rewardAmount != 0, "incorrect-reward-amount");
        require(_rewardDuration != 0, "incorrect-reward-duration");
        require(isRewardToken[_rewardToken], "invalid-reward-token");

        // Update rewards earned so far
        rewardPerTokenStored[_rewardToken] = _rewardPerToken(_rewardToken, _totalSupply);
        if (block.timestamp >= periodFinish[_rewardToken]) {
            rewardRates[_rewardToken] = _rewardAmount / _rewardDuration;
        } else {
            uint256 remainingPeriod = periodFinish[_rewardToken] - block.timestamp;

            uint256 leftover = remainingPeriod * rewardRates[_rewardToken];
            rewardRates[_rewardToken] = (_rewardAmount + leftover) / _rewardDuration;
        }
        // Safety check
        uint256 balance = IERC20(_rewardToken).balanceOf(address(this));
        require(rewardRates[_rewardToken] <= (balance / _rewardDuration), "rewards-too-high");
        // Start new drip time
        rewardDuration[_rewardToken] = _rewardDuration;
        lastUpdateTime[_rewardToken] = block.timestamp;
        periodFinish[_rewardToken] = block.timestamp + _rewardDuration;
        emit RewardAdded(_rewardToken, _rewardAmount, _rewardDuration);
    }

    function _rewardPerToken(address _rewardToken, uint256 _totalSupply) internal view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored[_rewardToken];
        }

        uint256 _timeSinceLastUpdate = lastTimeRewardApplicable(_rewardToken) - lastUpdateTime[_rewardToken];
        uint256 _rewardsSinceLastUpdate = _timeSinceLastUpdate * rewardRates[_rewardToken];
        uint256 _rewardsPerTokenSinceLastUpdate = (_rewardsSinceLastUpdate * 1e18) / _totalSupply;
        return rewardPerTokenStored[_rewardToken] + _rewardsPerTokenSinceLastUpdate;
    }

    function _updateReward(
        address _rewardToken,
        address _account,
        uint256 _totalSupply,
        uint256 _balance
    ) internal {
        uint256 _rewardPerTokenStored = _rewardPerToken(_rewardToken, _totalSupply);
        rewardPerTokenStored[_rewardToken] = _rewardPerTokenStored;
        lastUpdateTime[_rewardToken] = lastTimeRewardApplicable(_rewardToken);
        if (_account != address(0)) {
            rewards[_rewardToken][_account] = _claimable(_rewardToken, _account, _totalSupply, _balance);
            userRewardPerTokenPaid[_rewardToken][_account] = _rewardPerTokenStored;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "../PoolRewards.sol";
import "../../interfaces/vesper/IVesperPool.sol";

contract VesperEarnDrip is PoolRewards {
    /**
     * @dev Notify that reward is added.
     * Also updates reward rate and reward earning period.
     */
    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external override {
        (bool isStrategy, , , , , , , ) = IVesperPool(pool).strategy(msg.sender);
        require(msg.sender == IVesperPool(pool).governor() || isStrategy, "not-authorized");
        super._notifyRewardAmount(_rewardToken, _rewardAmount, _rewardDuration, IVesperPool(pool).totalSupply());
    }
}

{
  "evmVersion": "istanbul",
  "libraries": {},
  "metadata": {
    "bytecodeHash": "ipfs",
    "useLiteralContent": true
  },
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "remappings": [],
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}
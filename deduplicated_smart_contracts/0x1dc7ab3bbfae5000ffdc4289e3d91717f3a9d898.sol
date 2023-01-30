/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

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



pragma experimental ABIEncoderV2;

// These are the core Yearn libraries







struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtLimit;
    uint256 rateLimit;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

interface VaultAPI is IERC20 {
    function apiVersion() external view returns (string memory);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    /*
     * View how much the Vault would increase this strategy's borrow limit,
     * based on it's present performance (since its last report). Can be used to
     * determine expectedReturn in your strategy.
     */
    function creditAvailable() external view returns (uint256);

    /*
     * View how much the Vault would like to pull back from the Strategy,
     * based on it's present performance (since its last report). Can be used to
     * determine expectedReturn in your strategy.
     */
    function debtOutstanding() external view returns (uint256);

    /*
     * View how much the Vault expect this strategy to return at the current block,
     * based on it's present performance (since its last report). Can be used to
     * determine expectedReturn in your strategy.
     */
    function expectedReturn() external view returns (uint256);

    /*
     * This is the main contact point where the strategy interacts with the Vault.
     * It is critical that this call is handled as intended by the Strategy.
     * Therefore, this function will be called by BaseStrategy to make sure the
     * integration is correct.
     */
    function report(uint256 _gain, uint256 _loss) external returns (uint256);

    /*
     * This function is used in the scenario where there is a newer strategy that
     * would hold the same positions as this one, and those positions are easily
     * transferrable to the newer strategy. These positions must be able to be
     * transferred at the moment this call is made, if any prep is required to
     * execute a full transfer in one transaction, that must be accounted for
     * separately from this call.
     */
    function migrateStrategy(address _newStrategy) external;

    /*
     * This function should only be used in the scenario where the strategy is
     * being retired but no migration of the positions are possible, or in the
     * extreme scenario that the Strategy needs to be put into "Emergency Exit"
     * mode in order for it to exit as quickly as possible. The latter scenario
     * could be for any reason that is considered "critical" that the Strategy
     * exits it's position as fast as possible, such as a sudden change in market
     * conditions leading to losses, or an imminent failure in an external
     * dependency.
     */
    function revokeStrategy() external;

    /*
     * View the governance address of the Vault to assert privileged functions
     * can only be called by governance. The Strategy serves the Vault, so it
     * is subject to governance defined by the Vault.
     *
     */
    function governance() external view returns (address);
}

/*
 * This interface is here for the keeper bot to use
 */
interface StrategyAPI {
    function apiVersion() external pure returns (string memory);

    function name() external pure returns (string memory);

    function vault() external view returns (address);

    function keeper() external view returns (address);

    function tendTrigger(uint256 callCost) external view returns (bool);

    function tend() external;

    function harvestTrigger(uint256 callCost) external view returns (bool);

    function harvest() external;

    event Harvested(uint256 profit);
}

/*
 * BaseStrategy implements all of the required functionality to interoperate closely
 * with the core protocol. This contract should be inherited and the abstract methods
 * implemented to adapt the strategy to the particular needs it has to create a return.
 */

abstract contract BaseStrategy {
    using SafeMath for uint256;

    // Version of this contract's StrategyAPI (must match Vault)
    function apiVersion() public pure returns (string memory) {
        return "0.1.3";
    }

    // Name of this contract's Strategy (Must override!)
    // NOTE: You can use this field to manage the "version" of this strategy
    //       e.g. `StrategySomethingOrOtherV1`. It's up to you!
    function name() external virtual pure returns (string memory);

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

    // So indexers can keep track of this
    event Harvested(uint256 profit);

    // The minimum number of blocks between harvest calls
    // NOTE: Override this value with your own, or set dynamically below
    uint256 public minReportDelay = 6300; // ~ once a day

    // The minimum multiple that `callCost` must be above the credit/profit to be "justifiable"
    // NOTE: Override this value with your own, or set dynamically below
    uint256 public profitFactor = 100;

    // Use this to adjust the threshold at which running a debt causes a harvest trigger
    uint256 public debtThreshold = 0;

    // Adjust this using `setReserve(...)` to keep some of the position in reserve in the strategy,
    // to accomodate larger variations needed to sustain the strategy's core positon(s)
    uint256 private reserve = 0;

    function getReserve() internal view returns (uint256) {
        return reserve;
    }

    function setReserve(uint256 _reserve) internal {
        if (_reserve != reserve) reserve = _reserve;
    }

    bool public emergencyExit;

    constructor(address _vault) public {
        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.approve(_vault, uint256(-1)); // Give Vault unlimited access (might save gas)
        strategist = msg.sender;
        rewards = msg.sender;
        keeper = msg.sender;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        strategist = _strategist;
    }

    function setKeeper(address _keeper) external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        keeper = _keeper;
    }

    function setRewards(address _rewards) external {
        require(msg.sender == strategist, "!authorized");
        rewards = _rewards;
    }

    function setMinReportDelay(uint256 _delay) external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        minReportDelay = _delay;
    }

    function setProfitFactor(uint256 _profitFactor) external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        profitFactor = _profitFactor;
    }

    function setDebtThreshold(uint256 _debtThreshold) external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        debtThreshold = _debtThreshold;
    }

    /*
     * Resolve governance address from Vault contract, used to make
     * assertions on protected functions in the Strategy
     */
    function governance() internal view returns (address) {
        return vault.governance();
    }

    /*
     * Provide an accurate estimate for the total amount of assets (principle + return)
     * that this strategy is currently managing, denominated in terms of `want` tokens.
     * This total should be "realizable" e.g. the total value that could *actually* be
     * obtained from this strategy if it were to divest it's entire position based on
     * current on-chain conditions.
     *
     * NOTE: care must be taken in using this function, since it relies on external
     *       systems, which could be manipulated by the attacker to give an inflated
     *       (or reduced) value produced by this function, based on current on-chain
     *       conditions (e.g. this function is possible to influence through flashloan
     *       attacks, oracle manipulations, or other DeFi attack mechanisms).
     *
     * NOTE: It is up to governance to use this function to correctly order this strategy
     *       relative to its peers in the withdrawal queue to minimize losses for the Vault
     *       based on sudden withdrawals. This value should be higher than the total debt of
     *       the strategy and higher than it's expected value to be "safe".
     */
    function estimatedTotalAssets() public virtual view returns (uint256);

    /*
     * Perform any strategy unwinding or other calls necessary to capture
     * the "free return" this strategy has generated since the last time it's
     * core position(s) were adusted. Examples include unwrapping extra rewards.
     * This call is only used during "normal operation" of a Strategy, and should
     * be optimized to minimize losses as much as possible. It is okay to report
     * "no returns", however this will affect the credit limit extended to the
     * strategy and reduce it's overall position if lower than expected returns
     * are sustained for long periods of time.
     */
    function prepareReturn(uint256 _debtOutstanding) internal virtual returns (uint256 _profit, uint256 _loss);

    /*
     * Perform any adjustments to the core position(s) of this strategy given
     * what change the Vault made in the "investable capital" available to the
     * strategy. Note that all "free capital" in the strategy after the report
     * was made is available for reinvestment. Also note that this number could
     * be 0, and you should handle that scenario accordingly.
     */
    function adjustPosition(uint256 _debtOutstanding) internal virtual;

    /*
     * Make as much capital as possible "free" for the Vault to take. Some slippage
     * is allowed, since when this method is called the strategist is no longer receiving
     * their performance fee. The goal is for the strategy to divest as quickly as possible
     * while not suffering exorbitant losses. This function is used during emergency exit
     * instead of `prepareReturn()`
     */
    function exitPosition() internal virtual returns (uint256 _loss);

    /*
     * Vault calls this function after shares are created during `Vault.report()`.
     * You can customize this function to any share distribution mechanism you want.
     */
    function distributeRewards(uint256 _shares) external virtual {
        // Send 100% of newly-minted shares to the rewards address.
        vault.transfer(rewards, _shares);
    }

    /*
     * Provide a signal to the keeper that `tend()` should be called. The keeper will provide
     * the estimated gas cost that they would pay to call `tend()`, and this function should
     * use that estimate to make a determination if calling it is "worth it" for the keeper.
     * This is not the only consideration into issuing this trigger, for example if the position
     * would be negatively affected if `tend()` is not called shortly, then this can return `true`
     * even if the keeper might be "at a loss" (keepers are always reimbursed by Yearn)
     *
     * NOTE: `callCost` must be priced in terms of `want`
     *
     * NOTE: this call and `harvestTrigger` should never return `true` at the same time.
     */
    function tendTrigger(uint256 callCost) public virtual view returns (bool) {
        // We usually don't need tend, but if there are positions that need active maintainence,
        // overriding this function is how you would signal for that
        return false;
    }

    function tend() external {
        if (keeper != address(0)) {
            require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance(), "!authorized");
        }

        // Don't take profits with this call, but adjust for better gains
        adjustPosition(vault.debtOutstanding());
    }

    /*
     * Provide a signal to the keeper that `harvest()` should be called. The keeper will provide
     * the estimated gas cost that they would pay to call `harvest()`, and this function should
     * use that estimate to make a determination if calling it is "worth it" for the keeper.
     * This is not the only consideration into issuing this trigger, for example if the position
     * would be negatively affected if `harvest()` is not called shortly, then this can return `true`
     * even if the keeper might be "at a loss" (keepers are always reimbursed by Yearn)
     *
     * NOTE: `callCost` must be priced in terms of `want`
     *
     * NOTE: this call and `tendTrigger` should never return `true` at the same time.
     */
    function harvestTrigger(uint256 callCost) public virtual view returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

        // Should not trigger if strategy is not activated
        if (params.activation == 0) return false;

        // Should trigger if hadn't been called in a while
        if (block.number.sub(params.lastReport) >= minReportDelay) return true;

        // If some amount is owed, pay it back
        // NOTE: Since debt is adjusted in step-wise fashion, it is appropiate to always trigger here,
        //       because the resulting change should be large (might not always be the case)
        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > 0) return true;

        // Check for profits and losses
        uint256 total = estimatedTotalAssets();
        // Trigger if we have a loss to report
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt); // We've earned a profit!

        // Otherwise, only trigger if it "makes sense" economically (gas cost is <N% of value moved)
        uint256 credit = vault.creditAvailable();
        return (profitFactor * callCost < credit.add(profit));
    }

    function harvest() external {
        if (keeper != address(0)) {
            require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance(), "!authorized");
        }

        uint256 profit = 0;
        uint256 loss = 0;
        if (emergencyExit) {
            loss = exitPosition(); // Free up as much capital as possible
            // NOTE: Don't take performance fee in this scenario
        } else {
            // Free up returns for Vault to pull
            (profit, loss) = prepareReturn(vault.debtOutstanding());
        }

        if (reserve > want.balanceOf(address(this))) reserve = want.balanceOf(address(this));

        // Allow Vault to take up to the "harvested" balance of this contract, which is
        // the amount it has earned since the last time it reported to the Vault
        uint256 outstanding = vault.report(want.balanceOf(address(this)).sub(reserve), loss);

        // Check if free returns are left, and re-invest them
        adjustPosition(outstanding);

        emit Harvested(profit);
    }

    /*
     * Liquidate as many assets as possible to `want`, irregardless of slippage,
     * up to `_amountNeeded`. Any excess should be re-invested here as well.
     */
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _amountFreed);

    function withdraw(uint256 _amountNeeded) external {
        require(msg.sender == address(vault), "!vault");
        // Liquidate as much as possible to `want`, up to `_amount`
        uint256 amountFreed = liquidatePosition(_amountNeeded);
        // Send it directly back (NOTE: Using `msg.sender` saves some gas here)
        want.transfer(msg.sender, amountFreed);
        // Adjust reserve to what we have after the freed amount is sent to the Vault
        reserve = want.balanceOf(address(this));
    }

    /*
     * Do anything necesseary to prepare this strategy for migration, such
     * as transfering any reserve or LP tokens, CDPs, or other tokens or stores of value.
     */
    function prepareMigration(address _newStrategy) internal virtual;

    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault) || msg.sender == governance());
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.transfer(_newStrategy, want.balanceOf(address(this)));
    }

    function setEmergencyExit() external {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        emergencyExit = true;
        exitPosition();
        vault.revokeStrategy();
        if (reserve > want.balanceOf(address(this))) reserve = want.balanceOf(address(this));
    }

    // Override this to add all tokens/tokenized positions this contract manages
    // on a *persistant* basis (e.g. not just for swapping back to want ephemerally)
    // NOTE: Do *not* include `want`, already included in `sweep` below
    //
    // Example:
    //
    //    function protectedTokens() internal override view returns (address[] memory) {
    //      address[] memory protected = new address[](3);
    //      protected[0] = tokenA;
    //      protected[1] = tokenB;
    //      protected[2] = tokenC;
    //      return protected;
    //    }
    function protectedTokens() internal virtual view returns (address[] memory);

    function sweep(address _token) external {
        require(msg.sender == governance(), "!authorized");
        require(_token != address(want), "!want");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).transfer(governance(), IERC20(_token).balanceOf(address(this)));
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
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


interface PickleJar {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function token() external view returns (address);
    function getRatio() external view returns (uint256);
}

interface PickleChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function poolInfo(uint256 _pid) external view returns (address, uint256, uint256, uint256);
    function pendingPickle(uint256 _pid, address _user) external view returns (uint256);
    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}

interface PickleStaking {
    function earned(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function exit() external;
}

interface UniswapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface Uniswap {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
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

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

/*
    Uniswap LP => Pickle Jar => Pickle Farm => Pickle Staking => WETH rewards

    Builds up a Pickle position in Pickle Staking.
*/

contract StrategyUniswapPairPickle is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    string public constant override name = "StrategyUniswapPairPickle";
    address public constant chef = 0xbD17B1ce622d73bD438b9E658acA5996dc394b0d;
    address public constant staking = 0xa17a8883dA1aBd57c690DF9Ebf58fC194eDAb66F;
    address public constant pickle = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;
    address public constant uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public jar;
    uint256 public pid;
    address token0;
    address token1;
    uint256 gasFactor = 200;
    uint256 interval = 1000;

    constructor(address _vault, address _jar, uint256 _pid) public BaseStrategy(_vault) {
        jar = _jar;
        pid = _pid;

        require(PickleJar(jar).token() == address(want), "wrong jar");
        (address lp,,,) = PickleChef(chef).poolInfo(pid);
        require(lp == jar, "wrong pid");

        token0 = UniswapPair(address(want)).token0();
        token1 = UniswapPair(address(want)).token1();
        want.safeApprove(jar, type(uint256).max);
        IERC20(jar).safeApprove(chef, type(uint256).max);
        IERC20(pickle).safeApprove(staking, type(uint256).max);
        IERC20(token0).safeApprove(uniswap, type(uint256).max);
        IERC20(token1).safeApprove(uniswap, type(uint256).max);
    }

    // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

    function expectedReturn() public view returns (uint256) {
        uint256 _earned = PickleStaking(staking).earned(address(this));
        if (_earned / 2 == 0) return 0;
        uint256 _amount0 = quote(weth, token0, _earned / 2);
        uint256 _amount1 = quote(weth, token1, _earned / 2);
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapPair(address(want)).getReserves();
        uint256 _supply = IERC20(want).totalSupply();
        return Math.min(
            _amount0.mul(_supply).div(_reserve0),
            _amount1.mul(_supply).div(_reserve1)
        );
    }

    /*
     * Provide an accurate estimate for the total amount of assets (principle + return)
     * that this strategy is currently managing, denominated in terms of `want` tokens.
     * This total should be "realizable" e.g. the total value that could *actually* be
     * obtained from this strategy if it were to divest it's entire position based on
     * current on-chain conditions.
     *
     * NOTE: care must be taken in using this function, since it relies on external
     *       systems, which could be manipulated by the attacker to give an inflated
     *       (or reduced) value produced by this function, based on current on-chain
     *       conditions (e.g. this function is possible to influence through flashloan
     *       attacks, oracle manipulations, or other DeFi attack mechanisms).
     *
     * NOTE: It is up to governance to use this function to correctly order this strategy
     *       relative to its peers in the withdrawal queue to minimize losses for the Vault
     *       based on sudden withdrawals. This value should be higher than the total debt of
     *       the strategy and higher than it's expected value to be "safe".
     */
    function estimatedTotalAssets() public override view returns (uint256) {
        uint256 _want = want.balanceOf(address(this));
        (uint256 _staked, ) = PickleChef(chef).userInfo(pid, address(this));
        uint256 _ratio = PickleJar(jar).getRatio();
        uint256 _earned = expectedReturn();
        return _want.add(_staked.mul(_ratio).div(1e18)).add(_earned);
    }

    /*
     * Perform any strategy unwinding or other calls necessary to capture
     * the "free return" this strategy has generated since the last time it's
     * core position(s) were adusted. Examples include unwrapping extra rewards.
     * This call is only used during "normal operation" of a Strategy, and should
     * be optimized to minimize losses as much as possible. It is okay to report
     * "no returns", however this will affect the credit limit extended to the
     * strategy and reduce it's overall position if lower than expected returns
     * are sustained for long periods of time.
     */
    function prepareReturn(uint256 _debtOutstanding) internal override returns (uint256 _profit, uint256 _loss) {
        // Claim Pickle rewards from Pickle Chef
        PickleChef(chef).deposit(pid, 0);
        // Claim WETH rewards from Pickle Staking
        PickleStaking(staking).getReward();
        // Swap WETH to LP token underlying and add liquidity
        uint _weth = IERC20(weth).balanceOf(address(this));
        if (_weth > 1 gwei) {
            swap(weth, token0, _weth / 2);
            swap(weth, token1, _weth / 2);
            add_liquidity();
        }

        uint256 totalDebt = vault.strategies(address(this)).totalDebt;
        uint256 totalAssets = estimatedTotalAssets();

        uint256 looseBalance = want.balanceOf(address(this));
        uint256 neededLooseBalance;

        if (totalAssets < totalDebt) {
            _loss = totalDebt.sub(totalAssets);
            neededLooseBalance = _debtOutstanding;
        } else {
            _profit = totalAssets.sub(totalDebt);
            neededLooseBalance = _debtOutstanding.add(_profit);
        }

        if (neededLooseBalance > looseBalance) liquidatePosition(neededLooseBalance.sub(looseBalance));

        looseBalance = want.balanceOf(address(this));
        if (looseBalance > neededLooseBalance) {
            setReserve(looseBalance.sub(neededLooseBalance));
        } else {
            setReserve(0);
        }
    }

    /*
     * Perform any adjustments to the core position(s) of this strategy given
     * what change the Vault made in the "investable capital" available to the
     * strategy. Note that all "free capital" in the strategy after the report
     * was made is available for reinvestment. Also note that this number could
     * be 0, and you should handle that scenario accordingly.
     */
    function adjustPosition(uint256 _debtOutstanding) internal override {
        setReserve(0);
        // Stake LP tokens into Pickle Jar
        uint _want = want.balanceOf(address(this));
        _want = _want.sub(Math.min(_want, _debtOutstanding));
        if (_want > 0) PickleJar(jar).deposit(_want);
        // Stake Jar tokens into Pickle Farm
        uint _jar = IERC20(jar).balanceOf(address(this));
        if (_jar > 0) PickleChef(chef).deposit(pid, _jar);
        // Stake Pickle into Pickle Staking
        uint _pickle = IERC20(pickle).balanceOf(address(this));
        if (_pickle > 0) PickleStaking(staking).stake(_pickle);
    }

    /*
     * Make as much capital as possible "free" for the Vault to take. Some slippage
     * is allowed, since when this method is called the strategist is no longer receiving
     * their performance fee. The goal is for the strategy to divest as quickly as possible
     * while not suffering exorbitant losses. This function is used during emergency exit
     * instead of `prepareReturn()`
     */
    function exitPosition() internal override returns (uint256 _loss) {
        // Withdraw Jar tokens from Pickle Chef
        (uint _staked, ) = PickleChef(chef).userInfo(pid, address(this));
        PickleChef(chef).withdraw(pid, _staked);
        // Withdraw LP tokens from Jar
        uint _jar = IERC20(jar).balanceOf(address(this));
        if (_jar > 0) PickleJar(jar).withdraw(_jar);
        // Withdraw Pickle from Pickle Staking and transfer to governance
        uint _pickle_staked = IERC20(staking).balanceOf(address(this));
        if (_pickle_staked > 0) PickleStaking(staking).exit();
        uint _pickle = IERC20(pickle).balanceOf(address(this));
        if (_pickle > 0) IERC20(pickle).safeTransfer(governance(), _pickle);
        return 0;
    }
    /*
     * Liquidate as many assets as possible to `want`, irregardless of slippage,
     * up to `_amountNeeded`. Any excess should be re-invested here as well.
     */
    function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _amountFreed) {
        uint _before = want.balanceOf(address(this));
        (uint _staked, ) = PickleChef(chef).userInfo(pid, address(this));
        // This could result in less amount freed because of rounding error
        uint _withdraw = _amountNeeded.mul(1e18).div(PickleJar(jar).getRatio());
        PickleChef(chef).withdraw(pid, Math.min(_staked, _withdraw));
        // This could result in less amount freed because of withdrawal fees
        uint _jar = IERC20(jar).balanceOf(address(this));
        PickleJar(jar).withdraw(_jar);
        return Math.min(want.balanceOf(address(this)).sub(_before), _amountNeeded);
    }

    /*
     * Provide a signal to the keeper that `tend()` should be called. The keeper will provide
     * the estimated gas cost that they would pay to call `tend()`, and this function should
     * use that estimate to make a determination if calling it is "worth it" for the keeper.
     * This is not the only consideration into issuing this trigger, for example if the position
     * would be negatively affected if `tend()` is not called shortly, then this can return `true`
     * even if the keeper might be "at a loss" (keepers are always reimbursed by Yearn)
     *
     * NOTE: `callCost` must be priced in terms of `want`
     *
     * NOTE: this call and `harvestTrigger` should never return `true` at the same time.
     */
    function tendTrigger(uint256 gasCost) public override view returns (bool) {
        return false;
    }

    /*
     * Provide a signal to the keeper that `harvest()` should be called. The keeper will provide
     * the estimated gas cost that they would pay to call `harvest()`, and this function should
     * use that estimate to make a determination if calling it is "worth it" for the keeper.
     * This is not the only consideration into issuing this trigger, for example if the position
     * would be negatively affected if `harvest()` is not called shortly, then this can return `true`
     * even if the keeper might be "at a loss" (keepers are always reimbursed by Yearn)
     *
     * NOTE: `callCost` must be priced in terms of `want`
     *
     * NOTE: this call and `tendTrigger` should never return `true` at the same time.
     */
    function harvestTrigger(uint256 gasCost) public override view returns (bool) {
        uint256 _credit = vault.creditAvailable().mul(wantPrice()).div(1e18);
        uint256 _earned = PickleChef(chef).pendingPickle(pid, address(this));
        uint256 _return = quote(pickle, weth, _earned);
        uint256 last_sync = vault.strategies(address(this)).lastReport;
        bool time_trigger = block.number.sub(last_sync) >= interval;
        bool cost_trigger = _return > gasCost.mul(gasFactor);
        bool credit_trigger = _credit > gasCost.mul(gasFactor);
        return time_trigger && (cost_trigger || credit_trigger);
    }

    /*
     * Do anything necesseary to prepare this strategy for migration, such
     * as transfering any reserve or LP tokens, CDPs, or other tokens or stores of value.
     */
    function prepareMigration(address _newStrategy) internal override {
        // Pickle is unstaked and sent to governance in this call
        exitPosition();
        want.transfer(_newStrategy, want.balanceOf(address(this)));
    }

    function protectedTokens() internal override view returns (address[] memory) {
        address[] memory protected = new address[](5);
        protected[0] = address(want);
        protected[1] = pickle;
        protected[2] = jar;
        protected[3] = token0;
        protected[4] = token1;
        return protected;
    }

    function setGasFactor(uint256 _gasFactor) public {
        require(msg.sender == strategist || msg.sender == governance());
        gasFactor = _gasFactor;
    }

    function setInterval(uint256 _interval) public {
        require(msg.sender == strategist || msg.sender == governance());
        interval = _interval;
    }

    // ******** HELPER METHODS ************

    // Quote want token in ether.
    function wantPrice() public view returns (uint256) {
        require(token0 == weth || token1 == weth);  // dev: can only quote weth pairs
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapPair(address(want)).getReserves();
        uint256 _supply = IERC20(want).totalSupply();
        // Assume that pool is perfectly balanced
        return 2e18 * uint256(token0 == weth ? _reserve0 : _reserve1) / _supply;
    }

    function quote(address token_in, address token_out, uint256 amount_in) internal view returns (uint256) {
        if (token_in == token_out) return amount_in;
        bool is_weth = token_in == weth || token_out == weth;
        address[] memory path = new address[](is_weth ? 2 : 3);
        path[0] = token_in;
        if (is_weth) {
            path[1] = token_out;
        } else {
            path[1] = weth;
            path[2] = token_out;
        }
        uint256[] memory amounts = Uniswap(uniswap).getAmountsOut(amount_in, path);
        return amounts[amounts.length - 1];
    }

    function swap(address token_in, address token_out, uint amount_in) internal {
        if (token_in == token_out) return;
        bool is_weth = token_in == weth || token_out == weth;
        address[] memory path = new address[](is_weth ? 2 : 3);
        path[0] = token_in;
        if (is_weth) {
            path[1] = token_out;
        } else {
            path[1] = weth;
            path[2] = token_out;
        }
        if (IERC20(token_in).allowance(address(this), uniswap) < amount_in)
            IERC20(token_in).safeApprove(uniswap, type(uint256).max);
        Uniswap(uniswap).swapExactTokensForTokens(
            amount_in,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function add_liquidity() internal {
        Uniswap(uniswap).addLiquidity(
            token0,
            token1,
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            0, 0,
            address(this),
            block.timestamp
        );
    }

}
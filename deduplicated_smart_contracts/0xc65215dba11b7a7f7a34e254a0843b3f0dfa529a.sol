/**
 *Submitted for verification at Etherscan.io on 2020-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

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
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
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

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

/**
 * @title Various utilities useful for uint256.
 */
library UInt256Lib {
    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }
}

interface IOracle {
    function getData() external returns (uint256, bool);
}

interface B4seI {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external returns (uint256);

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

interface StabilizerI {
    function owner() external returns (address);

    function checkStabilizerAndGetReward(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_,
        uint256 b4sePolicyBalance
    ) external returns (uint256 rewardAmount_);
}

/**
 * @title B4se Monetary Supply Policy
 * @dev This is an implementation of the B4se Ideal Money protocol.
 *      B4se operates asymmetrically on expansion and contraction. It will both split and
 *      combine coins to maintain a stable unit price.
 *
 *      This component regulates the token supply of the B4se ERC20 token in response to
 *      market oracles.
 */
contract B4sePolicy is Ownable, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch_,
        uint256 exchangeRate_,
        int256 requestedSupplyAdjustment_,
        int256 rebaseLag_,
        uint256 timestampSec_
    );

    event LogSetDeviationThreshold(
        uint256 lowerDeviationThreshold_,
        uint256 upperDeviationThreshold_
    );

    event LogSetDefaultRebaseLag(
        uint256 defaultPositiveRebaseLag_,
        uint256 defaultNegativeRebaseLag_
    );

    event LogSetUseDefaultRebaseLag(bool useDefaultRebaseLag_);

    event LogUsingDefaultRebaseLag(int256 defaultRebaseLag_);

    event LogSetRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_
    );

    event LogSetOracle(address oracle_);

    event LogNewLagBreakpoint(
        bool indexed selected,
        int256 indexed lowerDelta_,
        int256 indexed upperDelta_,
        int256 lag_
    );

    event LogUpdateBreakpoint(
        bool indexed selected,
        int256 indexed lowerDelta_,
        int256 indexed upperDelta_,
        int256 lag_
    );

    event LogDeleteBreakpoint(
        bool indexed selected,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    );

    event LogSelectedBreakpoint(
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    );

    event LogSetPriceTargetRate(uint256 setPriceTargetRate_);

    event LogDeleteStabilizerPool(StabilizerI pool_);

    event LogAddNewStabilizerPool(StabilizerI pool_);

    event LogSetStabilizerPoolEnabled(uint256 index_, bool enabled_);

    event LogRewardSentToStabilizer(
        uint256 index,
        StabilizerI poolI,
        uint256 transferAmount
    );

    // Struct of rebase lag break point. It defines the supply delta range within which the lag can be applied.
    struct LagBreakpoint {
        int256 lowerDelta;
        int256 upperDelta;
        int256 lag;
    }

    struct StabilizerPool {
        bool enabled;
        StabilizerI pool;
    }

    // Address of the b4se token
    B4seI public b4se;

    // Market oracle provides the token/USD exchange rate as an 18 decimal fixed point number.
    // (eg) An oracle value of 1.5e18 it would mean 1 Ample is trading for $1.50.
    IOracle public oracle;

    // If the current exchange rate is within this fractional distance from the target, no supply
    // update is performed. Fixed point number--same format as the rate.
    // (ie) (rate - targetRate) / targetRate < upperdeviationThreshold or lowerdeviationThreshold, then no supply change.
    // DECIMALS Fixed point number.
    // deviationThreshold = 0.05e18 = 5e16
    uint256 public upperDeviationThreshold;
    uint256 public lowerDeviationThreshold;

    //Flag to use default rebase lag instead of the breakpoints.
    bool public useDefaultRebaseLag;

    // The rebase lag parameter, used to dampen the applied supply adjustment by 1 / rebaseLag
    // Check setRebaseLag comments for more details.
    // Natural number, no decimal places.
    uint256 public defaultPositiveRebaseLag;

    uint256 public defaultNegativeRebaseLag;

    //List of breakpoints for positive supply delta
    LagBreakpoint[] public upperLagBreakpoints;
    //List of breakpoints for negative supply delta
    LagBreakpoint[] public lowerLagBreakpoints;

    // More than this much time must pass between rebase operations.
    uint256 public minRebaseTimeIntervalSec;

    // Block timestamp of last rebase operation
    uint256 public lastRebaseTimestampSec;

    // The rebase window begins this many seconds into the minRebaseTimeInterval period.
    // For example if minRebaseTimeInterval is 24hrs, it represents the time of day in seconds.
    uint256 public rebaseWindowOffsetSec;

    // The length of the time window where a rebase operation is allowed to execute, in seconds.
    uint256 public rebaseWindowLengthSec;

    StabilizerPool[] public stabilizerPools;

    // THe price target to meet
    uint256 public priceTargetRate = 10**DECIMALS;

    // The number of rebase cycles since inception
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    // Due to the expression in computeSupplyDelta(), MAX_RATE * MAX_SUPPLY must fit into an int256.
    // Both are 18 decimals fixed point numbers.
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    // MAX_SUPPLY = MAX_INT256 / MAX_RATE
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    // This module orchestrates the rebase execution and downstream notification.
    address public orchestrator;

    modifier onlyOrchestrator() {
        require(msg.sender == orchestrator);
        _;
    }

    modifier indexInBounds(uint256 index) {
        require(
            index < stabilizerPools.length,
            "Index must be less than array length"
        );
        _;
    }

    /**
     * @notice Initializes the b4se policy with addresses of the b4se token and the oracle deployer. Along with inital rebasing parameters
     * @param b4se_ Address of the b4se token
     * @param orchestrator_ Address of the protocol orchestrator
     */
    function initialize(address b4se_, address orchestrator_)
        external
        initializer
        onlyOwner
    {
        b4se = B4seI(b4se_);
        orchestrator = orchestrator_;

        upperDeviationThreshold = 5 * 10**(DECIMALS - 2);
        lowerDeviationThreshold = 5 * 10**(DECIMALS - 2);

        useDefaultRebaseLag = false;
        defaultPositiveRebaseLag = 30;
        defaultNegativeRebaseLag = 30;

        minRebaseTimeIntervalSec = 24 hours;
        lastRebaseTimestampSec = 0;
        rebaseWindowOffsetSec = 72000;
        rebaseWindowLengthSec = 15 minutes;

        priceTargetRate = 10**DECIMALS;

        epoch = 0;
    }

    function addNewStabilizerPool(address pool_) external onlyOwner {
        StabilizerPool memory instance = StabilizerPool(
            false,
            StabilizerI(pool_)
        );

        require(
            instance.pool.owner() == owner(),
            "Must have the same owner as policy contract"
        );

        stabilizerPools.push(instance);
        emit LogAddNewStabilizerPool(instance.pool);
    }

    function deleteStabilizerPool(uint256 index)
        external
        indexInBounds(index)
        onlyOwner
    {
        StabilizerPool memory instanceToDelete = stabilizerPools[index];
        require(
            !instanceToDelete.enabled,
            "Only a disabled pool can be deleted"
        );
        uint256 length = stabilizerPools.length.sub(1);
        if (index < length) {
            stabilizerPools[index] = stabilizerPools[length];
        }
        emit LogDeleteStabilizerPool(instanceToDelete.pool);
        stabilizerPools.pop();
        delete instanceToDelete;
    }

    function setStabilizerPoolEnabled(uint256 index, bool enabled)
        external
        indexInBounds(index)
        onlyOwner
    {
        StabilizerPool storage instance = stabilizerPools[index];
        instance.enabled = enabled;
        emit LogSetStabilizerPoolEnabled(index, instance.enabled);
    }

    /**
     * @notice Sets the price target for rebases to compare against
     * @param priceTargetRate_ The new price target
     */
    function setPriceTargetRate(uint256 priceTargetRate_) external onlyOwner {
        require(priceTargetRate_ > 0);
        priceTargetRate = priceTargetRate_;
        emit LogSetPriceTargetRate(priceTargetRate_);
    }

    /**
     * @notice Function to set the oracle to get the exchange price
     * @param oracle_ Address of the b4se oracle
     */
    function setOracle(address oracle_) external onlyOwner {
        oracle = IOracle(oracle_);
        emit LogSetOracle(oracle_);
    }

    /**
     * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
     * @dev The supply adjustment equals (_totalSupply * DeviationFromTargetRate) / rebaseLag
     *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
     *      and targetRate is CpiOracleRate / baseCpi
     */
    function rebase() external onlyOrchestrator {
        require(inRebaseWindow(), "Not in rebase window");

        //This comparison also ensures there is no reentrancy.
        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

        //Snap the rebase time to the start of this window.
        lastRebaseTimestampSec = now.sub(now.mod(minRebaseTimeIntervalSec)).add(
            rebaseWindowOffsetSec
        );

        epoch = epoch.add(1);

        uint256 exchangeRate;
        bool rateValid;
        (exchangeRate, rateValid) = oracle.getData();
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(exchangeRate, priceTargetRate);
        int256 rebaseLag;

        if (supplyDelta != 0) {
            //Get rebase lag if the supply delta isn't zero
            rebaseLag = getRebaseLag(supplyDelta);

            // Apply the Dampening factor.
            supplyDelta = supplyDelta.div(rebaseLag);
        }

        if (
            supplyDelta > 0 &&
            b4se.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY
        ) {
            supplyDelta = (MAX_SUPPLY.sub(b4se.totalSupply())).toInt256Safe();
        }

        checkStabilizers(supplyDelta, rebaseLag, exchangeRate);

        uint256 supplyAfterRebase = b4se.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, exchangeRate, supplyDelta, rebaseLag, now);
    }

    function updateSupplyDelta(int256 supplyDelta) external onlyOwner {
        
        epoch = epoch.add(1);

        uint256 supplyAfterRebase = b4se.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
    }

    function checkStabilizers(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_
    ) internal {
        for (
            uint256 index = 0;
            index < stabilizerPools.length;
            index = index.add(1)
        ) {
            StabilizerPool memory instance = stabilizerPools[index];
            if (instance.enabled) {
                uint256 rewardToTransfer = instance
                    .pool
                    .checkStabilizerAndGetReward(
                    supplyDelta_,
                    rebaseLag_,
                    exchangeRate_,
                    b4se.balanceOf(address(this))
                );

                if (rewardToTransfer != 0) {
                    b4se.transfer(address(instance.pool), rewardToTransfer);
                    emit LogRewardSentToStabilizer(
                        index,
                        instance.pool,
                        rewardToTransfer
                    );
                }
            }
        }
    }

    /**
     * @notice Returns an apporiate rebase lag based either upon the inputed supply delta. The lag is either chose from an array of negative or positive
     *         supply delta. This allows of the application of unsymmetrical lag based upon the current supply delta.
     *         The function will also pick the default rebase lag if it's set to do so by the default rebase lag flag or if the breakpoint arrays are empty.
     * @param supplyDelta_ The new supply from give to get a corresponding rebase lag.
     * @return The selected rebase lag to apply.
     */
    function getRebaseLag(int256 supplyDelta_) private returns (int256) {
        int256 lag;
        int256 supplyDeltaAbs = supplyDelta_.abs();

        if (!useDefaultRebaseLag) {
            if (supplyDelta_ < 0) {
                lag = findBreakpoint(supplyDeltaAbs, lowerLagBreakpoints);
            } else {
                lag = findBreakpoint(supplyDeltaAbs, upperLagBreakpoints);
            }
            if (lag != 0) {
                return lag;
            }
        }

        if (supplyDelta_ < 0) {
            emit LogUsingDefaultRebaseLag(
                defaultNegativeRebaseLag.toInt256Safe()
            );
            return defaultNegativeRebaseLag.toInt256Safe();
        } else {
            emit LogUsingDefaultRebaseLag(
                defaultPositiveRebaseLag.toInt256Safe()
            );
            return defaultPositiveRebaseLag.toInt256Safe();
        }
    }

    function findBreakpoint(int256 supplyDelta, LagBreakpoint[] memory array)
        internal
        returns (int256)
    {
        LagBreakpoint memory instance;

        for (uint256 index = 0; index < array.length; index = index.add(1)) {
            instance = array[index];

            if (supplyDelta < instance.lowerDelta) {
                //Gab in break points found
                break;
            }
            if (supplyDelta <= instance.upperDelta) {
                emit LogSelectedBreakpoint(
                    instance.lowerDelta,
                    instance.upperDelta,
                    instance.lag
                );
                return instance.lag;
            }
        }
        return 0;
    }

    /**
     * @notice Sets the default rebase lag parameter. It is used to dampen the applied supply adjustment by 1 / rebaseLag.
               If the rebase lag R, equals 1, the smallest value for R, then the full supply correction is applied on each rebase cycle.
               If it is greater than 1, then a correction of 1/R of is applied on each rebase.
               This lag will be used if the default rebase flag is set or if the rebase breakpoint array's are empty.
     * @param defaultPositiveRebaseLag_ The new positive rebase lag parameter.
     * @param defaultNegativeRebaseLag_ The new negative rebase lag parameter.
     */
    function setDefaultRebaseLags(
        uint256 defaultPositiveRebaseLag_,
        uint256 defaultNegativeRebaseLag_
    ) external onlyOwner {
        require(
            defaultPositiveRebaseLag_ > 0 && defaultNegativeRebaseLag_ > 0,
            "Lag must be greater than zero"
        );

        defaultPositiveRebaseLag = defaultPositiveRebaseLag_;
        defaultNegativeRebaseLag = defaultNegativeRebaseLag_;
        emit LogSetDefaultRebaseLag(
            defaultPositiveRebaseLag,
            defaultNegativeRebaseLag
        );
    }

    /**
     * @notice Function used to set if the default rebase flag will be used.
     * @param useDefaultRebaseLag_ Sets default rebase lag flag.
     */
    function setUseDefaultRebaseLag(bool useDefaultRebaseLag_)
        external
        onlyOwner
    {
        useDefaultRebaseLag = useDefaultRebaseLag_;
        emit LogSetUseDefaultRebaseLag(useDefaultRebaseLag);
    }

    /**
     * @notice Adds new rebase lag parameters into either the upper or lower lag breakpoints. This allows the configuration of custom lag parameters
     *         based upon the current range the supply delta is within in. Along with this the two seperate lag breakpoint arrays allows of configuration for
     *         positive and negative supply delta ranges.
     * @param select Flag to select whether the new breakpoint should go in the upper or lower lag breakpoint.
     * @param lowerDelta_ The lower range in which the delta can be in.
     * @param upperDelta_ The upper range in which the delta can be in.
     * @param lag_ The lag to use in a given range.
     */
    function addNewLagBreakpoint(
        bool select,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    ) public onlyOwner {
        require(
            lowerDelta_ >= 0 && lowerDelta_ < upperDelta_,
            "Lower delta must be less than upper delta"
        );
        require(lag_ > 0, "Lag can't be zero");

        LagBreakpoint memory newPoint = LagBreakpoint(
            lowerDelta_,
            upperDelta_,
            lag_
        );

        LagBreakpoint memory lastPoint;
        uint256 length;

        if (select) {
            length = upperLagBreakpoints.length;
            if (length > 0) {
                lastPoint = upperLagBreakpoints[length.sub(1)];
                require(lastPoint.upperDelta <= lowerDelta_);
            }

            upperLagBreakpoints.push(newPoint);
        } else {
            length = lowerLagBreakpoints.length;
            if (length > 0) {
                lastPoint = lowerLagBreakpoints[length.sub(1)];
                require(lastPoint.upperDelta <= lowerDelta_);
            }

            lowerLagBreakpoints.push(newPoint);
        }
        emit LogNewLagBreakpoint(select, lowerDelta_, upperDelta_, lag_);
    }

    /**
     * @notice Updates lag breakpoint at a the specified index with new delta range parameters and lag.
     * @param select Flag to select whether the new breakpoint should go in the upper or lower lag breakpoint.
     * @param index The index of the selected breakpoint.
     * @param lowerDelta_ The lower range in which the delta can be in.
     * @param upperDelta_ The upper range in which the delta can be in.
     * @param lag_ The lag to use in a given range.
     */
    function updateLagBreakpoint(
        bool select,
        uint256 index,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    ) public onlyOwner {
        LagBreakpoint storage instance;

        require(
            lowerDelta_ >= 0 && lowerDelta_ < upperDelta_,
            "Lower delta must be less than upper delta"
        );
        require(lag_ > 0, "Lag can't be zero");

        if (select) {
            withinPointRange(
                index,
                lowerDelta_,
                upperDelta_,
                upperLagBreakpoints
            );
            instance = upperLagBreakpoints[index];
        } else {
            withinPointRange(
                index,
                lowerDelta_,
                upperDelta_,
                lowerLagBreakpoints
            );
            instance = lowerLagBreakpoints[index];
        }
        instance.lowerDelta = lowerDelta_;
        instance.upperDelta = upperDelta_;
        instance.lag = lag_;
        emit LogUpdateBreakpoint(select, lowerDelta_, upperDelta_, lag_);
    }

    function withinPointRange(
        uint256 index,
        int256 lowerDelta_,
        int256 upperDelta_,
        LagBreakpoint[] memory array
    ) internal pure {
        uint256 length = array.length;
        require(length > 0, "Can't update empty breakpoint array");
        require(index <= length.sub(1), "Index higher than elements avaiable");

        LagBreakpoint memory lowerPoint;
        LagBreakpoint memory upperPoint;

        if (index == 0) {
            if (length == 1) {
                return;
            }
            upperPoint = array[index.add(1)];
            require(upperDelta_ <= upperPoint.lowerDelta);
        } else if (index == length.sub(1)) {
            lowerPoint = array[index.sub(1)];
            require(lowerDelta_ >= lowerPoint.upperDelta);
        } else {
            upperPoint = array[index.add(1)];
            lowerPoint = array[index.sub(1)];
            require(
                lowerDelta_ >= lowerPoint.upperDelta &&
                    upperDelta_ <= upperPoint.lowerDelta
            );
        }
    }

    /**
     * @notice Delete lag breakpoint from the end of either upper and lower breakpoint array.
     * @param select Whether to delete from upper or lower breakpoint array.
     */
    function deleteLagBreakpoint(bool select) public onlyOwner {
        LagBreakpoint memory instanceToDelete;
        if (select) {
            require(
                upperLagBreakpoints.length > 0,
                "Can't delete empty breakpoint array"
            );
            instanceToDelete = upperLagBreakpoints[upperLagBreakpoints
                .length
                .sub(1)];
            upperLagBreakpoints.pop();
        } else {
            require(
                lowerLagBreakpoints.length > 0,
                "Can't delete empty breakpoint array"
            );
            instanceToDelete = lowerLagBreakpoints[lowerLagBreakpoints
                .length
                .sub(1)];
            lowerLagBreakpoints.pop();
        }
        emit LogDeleteBreakpoint(
            select,
            instanceToDelete.lowerDelta,
            instanceToDelete.upperDelta,
            instanceToDelete.lag
        );
        delete instanceToDelete;
    }

    /**
     * @notice Sets the deviation threshold fraction. If the exchange rate given by the market
     *         oracle is within this fractional distance from the targetRate, then no supply
     *         modifications are made. DECIMALS fixed point number.
     * @param upperDeviationThreshold_ The new exchange rate threshold fraction.
     * @param lowerDeviationThreshold_ The new exchange rate threshold fraction.
     */
    function setDeviationThresholds(
        uint256 upperDeviationThreshold_,
        uint256 lowerDeviationThreshold_
    ) external onlyOwner {
        upperDeviationThreshold = upperDeviationThreshold_;
        lowerDeviationThreshold = lowerDeviationThreshold_;
        emit LogSetDeviationThreshold(
            upperDeviationThreshold,
            lowerDeviationThreshold
        );
    }

    /**
     * @notice Sets the parameters which control the timing and frequency of
     *         rebase operations.
     *         a) the minimum time period that must elapse between rebase cycles.
     *         b) the rebase window offset parameter.
     *         c) the rebase window length parameter.
     * @param minRebaseTimeIntervalSec_ More than this much time must pass between rebase
     *        operations, in seconds.
     * @param rebaseWindowOffsetSec_ The number of seconds from the beginning of
              the rebase interval, where the rebase window begins.
     * @param rebaseWindowLengthSec_ The length of the rebase window in seconds.
     */
    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_
    ) external onlyOwner {
        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;

        emit LogSetRebaseTimingParameters(
            minRebaseTimeIntervalSec_,
            rebaseWindowOffsetSec_,
            rebaseWindowLengthSec_
        );
    }

    /**
     * @return If the latest block timestamp is within the rebase time window it, returns true.
     *         Otherwise, returns false.
     */
    function inRebaseWindow() public view returns (bool) {
        return (now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) <
            (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)));
    }

    /**
     * @return Computes the total supply adjustment in response to the exchange rate
     *         and the targetRate.
     */
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        // supplyDelta = totalSupply * (rate - targetRate) / targetRate
        int256 targetRateSigned = targetRate.toInt256Safe();
        return
            b4se
                .totalSupply()
                .toInt256Safe()
                .mul(rate.toInt256Safe().sub(targetRateSigned))
                .div(targetRateSigned);
    }

    /**
     * @notice Function to determine if a rate is within the upper or lower deviation from the target rate.
     * @param rate The current exchange rate, an 18 decimal fixed point number.
     * @param targetRate The target exchange rate, an 18 decimal fixed point number.
     * @return If the rate is within the upper or lower deviation threshold from the target rate, returns true.
     *         Otherwise, returns false.
     */
    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {
        uint256 upperThreshold = targetRate.mul(upperDeviationThreshold).div(
            10**DECIMALS
        );

        uint256 lowerThreshold = targetRate.mul(lowerDeviationThreshold).div(
            10**DECIMALS
        );

        return
            (rate >= targetRate && rate.sub(targetRate) < upperThreshold) ||
            (rate < targetRate && targetRate.sub(rate) < lowerThreshold);
    }
}
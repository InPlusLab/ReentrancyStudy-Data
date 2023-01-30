pragma solidity ^0.5.0;

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

pragma solidity ^0.5.16;

// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(
            msg.sender == nominatedOwner,
            "You must be nominated before you can accept ownership"
        );
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner may perform this action"
        );
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

interface IDparam {
    event FeeRateEvent(uint256 feeRate);
    event LiquidationLineEvent(uint256 liquidationRate);
    event MinMintEvent(uint256 minMint);

    function stakeRate() external view returns (uint256);

    function liquidationLine() external view returns (uint256);

    function feeRate() external view returns (uint256);

    function minMint() external view returns (uint256);

    function setFeeRate(uint256 _feeRate) external;

    function setLiquidationLine(uint256 _liquidationLine) external;

    function setMinMint(uint256 _minMint) external;

    function isLiquidation(uint256 price) external view returns (bool);

    function isNormal(uint256 price) external view returns (bool);
}

pragma solidity ^0.5.0;

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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "./Math.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./Owned.sol";
import "./IDparam.sol";
import "./WhiteList.sol";

interface IOracle {
    function val() external returns (uint256);

    function poke(uint256 price) external;

    function peek() external;
}

interface IESM {
    function isStakePaused() external view returns (bool);

    function isRedeemPaused() external view returns (bool);

    function isClosed() external view returns (bool);

    function time() external view returns (uint256);
}

interface ICoin {
    function burn(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract OinStake is Owned, WhiteList {
    using Math for uint256;
    using SafeMath for uint256;

    /**
     * @notice Struct reward pools state
     * @param index Accumulated earnings index
     * @param block Update index, updating blockNumber together
     */
    struct RewardState {
        uint256 index;
        uint256 block;
    }
    /**
     * @notice reward pools state
     * @param index Accumulated earnings index by staker
     * @param reward Accumulative reward
     */
    struct StakerState {
        uint256 index;
        uint256 reward;
    }

    /// @notice TThe reward pool put into by the project side
    uint256 public reward;
    /// @notice The number of token per-block
    uint256 public rewardSpeed = 5e8;
    /// @notice Inital index
    uint256 public initialIndex = 1e16;
    /// @notice Amplification factor
    uint256 public doubleScale = 1e16;
    /// @notice The instance reward pools state
    RewardState public rewardState;

    /// @notice All staker-instances state
    mapping(address => StakerState) public stakerStates;

    /// @notice The amount by staker with token
    mapping(address => uint256) public tokens;
    /// @notice The amount by staker with coin
    mapping(address => uint256) public coins;
    /// @notice The total amount of out-coin in sys
    uint256 public totalCoin;
    /// @notice The total amount of stake-token in sys
    uint256 public totalToken;
    /// @notice Cumulative  service fee, it will be burn, not join reward.
    uint256 public sFee;
    uint256 constant ONE = 10**8;
    address constant blackhole = 0x1111111111111111111111111111111111111111;

    /// @notice Dparam address
    IDparam params;
    /// @notice Oracle address
    IOracle orcl;
    /// @notice Esm address
    IESM esm;
    /// @notice Coin address
    ICoin coin;
    /// @notice Token address
    IERC20 token;

    /// @notice Setup Oracle address success
    event SetupOracle(address orcl);
    /// @notice Setup Dparam address success
    event SetupParam(address param);
    /// @notice Setup Esm address success
    event SetupEsm(address esm);
    /// @notice Setup Token&Coin address success
    event SetupCoin(address token, address coin);
    /// @notice Stake success
    event StakeEvent(uint256 token, uint256 coin);
    /// @notice redeem success
    event RedeemEvent(uint256 token, uint256 move, uint256 fee, uint256 coin);
    /// @notice Update index success
    event IndexUpdate(uint256 delt, uint256 block, uint256 index);
    /// @notice ClaimToken success
    event ClaimToken(address holder, uint256 amount);
    /// @notice InjectReward success
    event InjectReward(uint256 amount);
    /// @notice ExtractReward success
    event ExtractReward(address reciver, uint256 amount);

    /**
     * @notice Construct a new OinStake, owner by msg.sender
     * @param _param Dparam address
     * @param _orcl Oracle address
     * @param _esm Esm address
     */
    constructor(
        address _param,
        address _orcl,
        address _esm
    ) public Owned(msg.sender) {
        params = IDparam(_param);
        orcl = IOracle(_orcl);
        esm = IESM(_esm);
        rewardState = RewardState(initialIndex, getBlockNumber());
    }

    modifier notClosed() {
        require(!esm.isClosed(), "System closed");
        _;
    }

    /**
     * @notice reset Dparams address.
     * @param _params Configuration dynamic params contract address
     */
    function setupParams(address _params) public onlyWhiter {
        params = IDparam(_params);
        emit SetupParam(_params);
    }

    /**
     * @notice reset Oracle address.
     * @param _orcl Configuration Oracle contract address
     */
    function setupOracle(address _orcl) public onlyWhiter {
        orcl = IOracle(_orcl);
        emit SetupOracle(_orcl);
    }

    /**
     * @notice reset Esm address.
     * @param _esm Configuration Esm contract address
     */
    function setupEsm(address _esm) public onlyWhiter {
        esm = IESM(_esm);
        emit SetupEsm(_esm);
    }

    /**
     * @notice get Dparam address.
     * @return Dparam contract address
     */
    function getParamsAddr() public view returns (address) {
        return address(params);
    }

    /**
     * @notice get Oracle address.
     * @return Oracle contract address
     */
    function getOracleAddr() public view returns (address) {
        return address(orcl);
    }

    /**
     * @notice get Esm address.
     * @return Esm contract address
     */
    function getEsmAddr() public view returns (address) {
        return address(esm);
    }

    /**
     * @notice get token of staking address.
     * @return ERC20 address
     */
    function getCoinAddress() public view returns (address) {
        return address(coin);
    }

    /**
     * @notice get StableToken address.
     * @return ERC20 address
     */
    function getTokenAddress() public view returns (address) {
        return address(token);
    }

    /**
     * @notice inject token address & coin address only once.
     * @param _token token address
     * @param _coin coin address
     */
    function setup(address _token, address _coin) public onlyWhiter {
        require(
            address(token) == address(0) && address(coin) == address(0),
            "setuped yet."
        );
        token = IERC20(_token);
        coin = ICoin(_coin);

        emit SetupCoin(_token, _coin);
    }

    /**
     * @notice Get the number of debt by the `account`
     * @param account token address
     * @return (tokenAmount,coinAmount)
     */
    function debtOf(address account) public view returns (uint256, uint256) {
        return (tokens[account], coins[account]);
    }

    /**
     * @notice Get the number of debt by the `account`
     * @param coinAmount The amount that staker want to get stableToken
     * @return The amount that staker want to transfer token.
     */
    function getInputToken(uint256 coinAmount)
        public
        view
        returns (uint256 tokenAmount)
    {
        tokenAmount = coinAmount.mul(params.stakeRate());
    }

    /**
     * @notice Normally redeem anyAmount internal
     * @param coinAmount The number of coin will be staking
     */
    function stake(uint256 coinAmount) external notClosed {
        require(!esm.isStakePaused(), "Stake paused");
        require(coinAmount > 0, "The quantity is less than the minimum");
        require(orcl.val() > 0, "Oracle price not initialized.");
        require(params.isNormal(orcl.val()), "Oin's price is too low.");

        address from = msg.sender;

        if (coins[from] == 0) {
            require(
                coinAmount >= params.minMint(),
                "First make coin must grater than 100."
            );
        }

        accuredToken(from);

        uint256 tokenAmount = getInputToken(coinAmount);

        token.transferFrom(from, address(this), tokenAmount);
        coin.mint(from, coinAmount);

        totalCoin = totalCoin.add(coinAmount);
        totalToken = totalToken.add(tokenAmount);
        coins[from] = coins[from].add(coinAmount);
        tokens[from] = tokens[from].add(tokenAmount);

        emit StakeEvent(tokenAmount, coinAmount);
    }

    /**
     * @notice Normally redeem anyAmount internal
     * @param coinAmount The number of coin will be redeemed
     * @param receiver Address of receiving
     */
    function _normalRedeem(uint256 coinAmount, address receiver)
        internal
        notClosed
    {
        require(!esm.isRedeemPaused(), "Redeem paused");
        address staker = msg.sender;
        require(coins[staker] > 0, "No collateral");
        require(coinAmount > 0, "The quantity is less than zero");
        require(coinAmount <= coins[staker], "input amount overflow");

        accuredToken(staker);

        uint256 tokenAmount = getInputToken(coinAmount);

        uint256 feeRate = params.feeRate();
        uint256 fee = tokenAmount.mul(feeRate).div(1000);
        uint256 move = tokenAmount.sub(fee);
        sFee = sFee.add(fee);

        token.transfer(blackhole, fee);
        coin.burn(staker, coinAmount);
        token.transfer(receiver, move);

        coins[staker] = coins[staker].sub(coinAmount);
        tokens[staker] = tokens[staker].sub(tokenAmount);
        totalCoin = totalCoin.sub(coinAmount);
        totalToken = totalToken.sub(tokenAmount);

        emit RedeemEvent(tokenAmount, move, fee, coinAmount);
    }

    /**
     * @notice Abnormally redeem anyAmount internal
     * @param coinAmount The number of coin will be redeemed
     * @param receiver Address of receiving
     */
    function _abnormalRedeem(uint256 coinAmount, address receiver) internal {
        require(esm.isClosed(), "System not Closed yet.");
        address from = msg.sender;
        require(coinAmount > 0, "The quantity is less than zero");
        require(coin.balanceOf(from) > 0, "The coin no balance.");
        require(coinAmount <= coin.balanceOf(from), "Coin balance exceed");

        uint256 tokenAmount = getInputToken(coinAmount);

        coin.burn(from, coinAmount);
        token.transfer(receiver, tokenAmount);

        totalCoin = totalCoin.sub(coinAmount);
        totalToken = totalToken.sub(tokenAmount);

        emit RedeemEvent(tokenAmount, tokenAmount, 0, coinAmount);
    }

    /**
     * @notice Normally redeem anyAmount
     * @param coinAmount The number of coin will be redeemed
     * @param receiver Address of receiving
     */
    function redeem(uint256 coinAmount, address receiver) public {
        _normalRedeem(coinAmount, receiver);
    }

    /**
     * @notice Normally redeem anyAmount to msg.sender
     * @param coinAmount The number of coin will be redeemed
     */
    function redeem(uint256 coinAmount) public {
        redeem(coinAmount, msg.sender);
    }

    /**
     * @notice normally redeem them all at once
     * @param holder reciver
     */
    function redeemMax(address holder) public {
        redeem(coins[msg.sender], holder);
    }

    /**
     * @notice normally redeem them all at once to msg.sender
     */
    function redeemMax() public {
        redeemMax(msg.sender);
    }

    /**
     * @notice System shutdown under the redemption rule
     * @param coinAmount The number coin
     * @param receiver Address of receiving
     */
    function oRedeem(uint256 coinAmount, address receiver) public {
        _abnormalRedeem(coinAmount, receiver);
    }

    /**
     * @notice System shutdown under the redemption rule
     * @param coinAmount The number coin
     */
    function oRedeem(uint256 coinAmount) public {
        oRedeem(coinAmount, msg.sender);
    }

    /**
     * @notice Refresh reward speed.
     */
    function setRewardSpeed(uint256 speed) public onlyWhiter {
        updateIndex();
        rewardSpeed = speed;
    }

    /**
     * @notice Used to correct the effect of one's actions on one's own earnings
     *         System shutdown will no longer count
     */
    function updateIndex() public {
        if (esm.isClosed()) {
            return;
        }

        uint256 blockNumber = getBlockNumber();
        uint256 deltBlock = blockNumber.sub(rewardState.block);

        if (deltBlock > 0) {
            uint256 accruedReward = rewardSpeed.mul(deltBlock);
            uint256 ratio = totalToken == 0
                ? 0
                : accruedReward.mul(doubleScale).div(totalToken);
            rewardState.index = rewardState.index.add(ratio);
            rewardState.block = blockNumber;
            emit IndexUpdate(deltBlock, blockNumber, rewardState.index);
        }
    }

    /**
     * @notice Used to correct the effect of one's actions on one's own earnings
     *         System shutdown will no longer count
     * @param account staker address
     */
    function accuredToken(address account) internal {
        updateIndex();
        StakerState storage stakerState = stakerStates[account];
        stakerState.reward = _getReward(account);
        stakerState.index = rewardState.index;
    }

    /**
     * @notice Calculate the current holder's mining income
     * @param staker Address of holder
     */
    function _getReward(address staker) internal view returns (uint256 value) {
        StakerState storage stakerState = stakerStates[staker];
        value = stakerState.reward.add(
            rewardState.index.sub(stakerState.index).mul(tokens[staker]).div(
                doubleScale
            )
        );
    }

    /**
     * @notice Estimate the mortgagor's reward
     * @param account Address of staker
     */
    function getHolderReward(address account)
        public
        view
        returns (uint256 value)
    {
        uint256 blockReward2 = (totalToken == 0 || esm.isClosed())
            ? 0
            : getBlockNumber()
                .sub(rewardState.block)
                .mul(rewardSpeed)
                .mul(tokens[account])
                .div(totalToken);
        value = _getReward(account) + blockReward2;
    }

    /**
     * @notice Extract the current reward in one go
     * @param holder Address of receiver
     */
    function claimToken(address holder) public {
        accuredToken(holder);
        StakerState storage stakerState = stakerStates[holder];
        uint256 value = stakerState.reward.min(reward);
        require(value > 0, "The reward of address is zero.");

        token.transfer(holder, value);
        reward = reward.sub(value);

        stakerState.index = rewardState.index;
        stakerState.reward = stakerState.reward.sub(value);
        emit ClaimToken(holder, value);
    }

    /**
     * @notice Get block number now
     */
    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    /**
     * @notice Inject token to reward
     * @param amount The number of injecting
     */
    function injectReward(uint256 amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
        reward = reward.add(amount);
        emit InjectReward(amount);
    }

    /**
     * @notice Extract token from reward
     * @param account Address of receiver
     * @param amount The number of extracting
     */
    function extractReward(address account, uint256 amount) external onlyOwner {
        require(amount <= reward, "withdraw overflow.");
        token.transfer(account, amount);
        reward = reward.sub(amount);
        emit ExtractReward(account, amount);
    }
}

pragma solidity ^0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "./Owned.sol";

contract WhiteList is Owned {
    /// @notice Users with permissions
    mapping(address => uint256) public whiter;

    /// @notice Append address into whiteList successevent
    event AppendWhiter(address adder);

    /// @notice Remove address into whiteList successevent
    event RemoveWhiter(address remover);

    /**
     * @notice Construct a new WhiteList, default owner in whiteList
     */
    constructor() internal {
        appendWhiter(owner);
    }

    modifier onlyWhiter() {
        require(isWhiter(), "WhiteList: msg.sender not in whilteList.");
        _;
    }

    /**
     * @notice Only onwer can append address into whitelist
     * @param account The address not added, can added to the whitelist
     */
    function appendWhiter(address account) public onlyOwner {
        require(account != address(0), "WhiteList: address not zero");
        require(
            !isWhiter(account),
            "WhiteListe: the account exsit whilteList yet"
        );
        whiter[account] = 1;
        emit AppendWhiter(account);
    }

    /**
     * @notice Only onwer can remove address into whitelist
     * @param account The address in whitelist yet
     */
    function removeWhiter(address account) public onlyOwner {
        require(
            isWhiter(account),
            "WhiteListe: the account not exist whilteList"
        );
        delete whiter[account];
        emit RemoveWhiter(account);
    }

    /**
     * @notice Check whether acccount in whitelist
     * @param account Any address
     */
    function isWhiter(address account) public view returns (bool) {
        return whiter[account] == 1;
    }

    /**
     * @notice Check whether msg.sender in whitelist overrides.
     */
    function isWhiter() public view returns (bool) {
        return isWhiter(msg.sender);
    }
}


/**
 *Submitted for verification at Etherscan.io on 2021-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Staking {
    
    using SafeMath for uint256;
    ManagerRole public manager;

    struct StakeHolder {
        bool isClaimed;                 // Current Staking status
        uint256 amount;                 // Current active stake
        uint256 stakedBlock;            // Last staked block (if any)
        uint256 releaseBlock;           // Last claimed block (if any)
        uint256 claimedOn;              // Last time claimed
        uint256 rewards;                // Rewards
    }
    mapping (address => StakeHolder) public StakeHolders;
    
    // List of stake holders
    address[] private allStakeHolders;
    
    // Stake & Reward Token
    address public stakeToken;

    // To check if the staking is paused
    bool public isStakingPaused;

    // To check if the pool is Active
    bool public isPoolActive;
    
    // No.of Staking Pool Tokens 
    uint256 public stakingPool;

    // No.of Staking Pool Rewards
    uint256 public stakingPoolRewards;

    // Staking Duration in Days
    uint256 public stakingDuration;

    // Staking Opening Time for users to stake
    uint256 public stakingOpenTime;

    // Staking reward start block
    uint256 public stakingStartBlock;

    // Staking rewards ending block
    uint256 public stakingEndBlock;

    // No.of Staking Blocks
    uint256 public noOfStakingBlocks;

    // No.of users staked
    uint256 public noOfStakes;
    
    // 6440 is the avg no.of Ethereum Blocks per day, Applicable only for Ethereum network 
    uint256 public avgETHBlocksPerDay = 6440;

    // To calculate the no.of Currently staked tokens
    uint256 public currentPool;

    // To check if the users are fully calimed
    bool public isPoolFullyClaimed;

    // no.of Days in a Year
    uint256 private daysInAYear = 365;

    /* EVENTS */
    event Staked(address _address, uint256 _stakedTokens);
    event Claimed(address _address, uint256 _stakedTokens, uint256 _claimedTokens);
    event Paused(bool _status, uint256 _timestamp, uint256 _blockNumber);
    event Withdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);
    event SafeWithdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);
    event EmergencyWithdraw(address _stakeToken, address _hotwallet, uint256 _noOfTokens, uint256 _timestamp, uint256 _blockNumber);

    /**
     * @param _stakingToken address of the Token which user stakes
     * @param _stakingPool is the total no.of tokens to meet the requirement to start the staking
     * @param _stakingPoolRewards is the total no.of rewards for the _rewardCapital
     * @param _stakingOpenTime is the pool opening time (like count down) epoch
     * @param _stakingDuration is the statking duration of staking ex: 30 days, 60 days, 90 days... in days
     * @param _manager is to manage the managers of the contracts
     */
    constructor(address _stakingToken, uint256 _stakingPool, uint256 _stakingPoolRewards, uint256 _stakingOpenTime, uint256 _stakingDuration, ManagerRole _manager) {
        stakeToken= _stakingToken;
        stakingPool = _stakingPool;
        stakingPoolRewards = _stakingPoolRewards;
        stakingOpenTime = _stakingOpenTime;
        stakingDuration = _stakingDuration;
        stakingStartBlock = _currentBlockNumber();
        manager = _manager;
        isStakingPaused = false;
        isPoolActive = false;
        noOfStakes = 0;
    }

    function hotWallet() internal view returns(address) {
        return manager.getHotWallet();
    }

    function getAPY() external view returns(uint256) {
        uint256 apy = stakingPoolRewards.mul(daysInAYear).mul(100).div(stakingPool.mul(stakingDuration));
        return apy;
    }
    
    /* MODIFIERS */
    modifier onlyManager {
        require(manager.isManager(msg.sender), "Manager:: Unauthorized Access");
        _;
    }

    /**
     * @notice This is the endpoint for staking
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function stake(uint256 _noOfTokens) external {
        require(isStakingPaused == false, "Stake:: Staking is paused");
        require(_noOfTokens > 0, "Stake:: Can not stake Zero Tokens");
        require(_currentBlockTimestamp() > stakingOpenTime, "Stake:: Staking have not started for this pool");
        require(stakingPool > currentPool, "Stake:: Staking Pool is Full");
        require(_noOfTokens <= stakingPool.sub(currentPool), "Stake: Can not stake more than pool size");
        _stake(_noOfTokens);
    }

    /**
     * @notice This is the internal staking function which can be called by stake
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function _stake(uint256 _noOfTokens) internal {
        IERC20(stakeToken).transferFrom(msg.sender, address(this), _noOfTokens);
        StakeHolders[msg.sender].amount = StakeHolders[msg.sender].amount.add(_noOfTokens);
        StakeHolders[msg.sender].isClaimed = false;
        StakeHolders[msg.sender].stakedBlock = block.number;
        StakeHolders[msg.sender].rewards = _calculateRewards(_noOfTokens);
        currentPool = currentPool.add(_noOfTokens);
        if(stakingPool == currentPool) {
            isPoolActive = true;
            stakingEndBlock = _currentBlockNumber().add(stakingDuration.mul(avgETHBlocksPerDay));
        }
        noOfStakes = noOfStakes.add(1);
        allStakeHolders.push(msg.sender);
        emit Staked(msg.sender, _noOfTokens);
    }

    /**
     * @notice This is the internal reward calculation function which can be called by _stake
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function _calculateRewards(uint256 _noOfTokens) internal view returns (uint256) {
        uint256 userShareInPool = (_noOfTokens.mul(1e6)).div(stakingPool);
        return StakeHolders[msg.sender].rewards.add((userShareInPool.mul(stakingPoolRewards)).div(1e6));
    }

    /**
     * @notice This is the external function to calculate reward
     * @param _noOfTokens is the no.of Tokens user want to stake into the pool in WEI
     */
    function calculateRewardsView(address _wallet, uint256 _noOfTokens) external view returns (uint256) {
        uint256 userShareInPool = (_noOfTokens.mul(1e6)).div(stakingPool);
        return StakeHolders[_wallet].rewards.add((userShareInPool.mul(stakingPoolRewards)).div(1e6));
    }

    /**
     * @notice This is the endpoint for Claiming the Stake + Rewards
     */
    function claim() external {
        require(isStakingPaused == false, "Claim:: Pool is Paused");
        require(isPoolActive == true, "Claim:: Pool is not active");
        require(StakeHolders[msg.sender].isClaimed == false, "Claim:: Already Claimed");
        require(StakeHolders[msg.sender].amount > 0, "Claim:: Seems like haven't staked to claim");
        require(_currentBlockNumber() > stakingEndBlock, "Claim:: You can not claim before staked duration");
        require(IERC20(stakeToken).balanceOf(address(this)) >= (StakeHolders[msg.sender].amount).add(StakeHolders[msg.sender].rewards), "Claim:: Insufficient Balance");
        _claim();
    }

    /**
     * @notice This is the internal function which will be called by claim
     */
    function _claim() internal {
        uint256 claimedTokens = StakeHolders[msg.sender].amount;
        uint256 claimedRewards = StakeHolders[msg.sender].rewards;
        IERC20(stakeToken).transfer(msg.sender, claimedTokens);
        IERC20(stakeToken).transfer(msg.sender, claimedRewards);
        StakeHolders[msg.sender].isClaimed = true;
        StakeHolders[msg.sender].amount = claimedTokens;
        StakeHolders[msg.sender].rewards = claimedRewards;
        StakeHolders[msg.sender].releaseBlock = _currentBlockNumber();
        StakeHolders[msg.sender].claimedOn = _currentBlockTimestamp();
        updateFullyClaimed();
        emit Claimed(msg.sender, claimedTokens, claimedRewards);
    }

    /**
     * @notice Admin Function
     */
    function pauseStaking() external onlyManager {
        isStakingPaused = true;
        emit Paused(isStakingPaused, block.timestamp, block.number);
    }

    /**
     * @notice Admin Function
     */
    function unPauseStaking() external onlyManager {
        isStakingPaused = false;
        emit Paused(isStakingPaused, block.timestamp, block.number);
    }

    /**
     * @notice This is the internal function which fetch the Current Time Stamp from Network
     */
    function _currentBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice This is the internal function which fetch the Current Block number from Network
     */
    function _currentBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
     * @notice This is the external function which allow user to check the staking status
     */
    function claimStatus(address _address) external view returns (bool) {
        return StakeHolders[_address].isClaimed;
    }

    /**
     * @notice This is the external function to fetch the wallet and token information
     */
    function stakeTokenInfo(address _wallet) external view returns(string memory, string memory, uint256) {
        return (IERC20(stakeToken).name(), IERC20(stakeToken).symbol(), IERC20(stakeToken).balanceOf(_wallet));
    }
    
    /**
     * @notice Admin Function
     */
    function withdraw(uint256 _noOfTokens) external onlyManager {
        require(_currentBlockNumber() < stakingEndBlock, "Withdraw:: Invalid withdraw");
        require(IERC20(stakeToken).balanceOf(address(this)) >= _noOfTokens, "Withdraw:: Invalid Balance");
        IERC20(stakeToken).transfer(hotWallet(), _noOfTokens);
        emit Withdraw(stakeToken, hotWallet(), _noOfTokens, block.timestamp, block.number);
    }
    
    /**
     * @notice Admin Function
     */
    function safeWithdraw() external onlyManager {
        require(_currentBlockNumber() > stakingEndBlock, "SafeWithdraw:: Invalid withdraw");
        
        // Unclaimed Tokens
        uint256 notClaimedStake;
        uint256 notClaimedRewards;
        
        // Claimed Tokens
        uint256 claimedStake;
        uint256 claimedRewards;
        
        for(uint256 i=0; i<allStakeHolders.length; i++) {
            if(StakeHolders[allStakeHolders[i]].isClaimed == false) {
                notClaimedStake = notClaimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                notClaimedRewards = notClaimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            } else if (StakeHolders[allStakeHolders[i]].isClaimed == true) {
                claimedStake = claimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                claimedRewards = claimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            }
        }
        
        // Calculate Balance
        uint256 totalUnClaimed = notClaimedStake.add(notClaimedRewards);
        uint256 balanceInContract = IERC20(stakeToken).balanceOf(address(this));
        
        if(balanceInContract > totalUnClaimed) {
            IERC20(stakeToken).transfer(hotWallet(), balanceInContract.sub(totalUnClaimed));
            emit SafeWithdraw(stakeToken, hotWallet(), balanceInContract.sub(totalUnClaimed), block.timestamp, block.number);
        }
    }

    /**
     * @notice Total Unclaimed Tokens
     */
    function totalUnClaimedTokens() public view returns(uint256) {        
        uint256 notClaimedStake;
        uint256 notClaimedRewards;
        for(uint256 i=0; i<allStakeHolders.length; i++) {
            if(StakeHolders[allStakeHolders[i]].isClaimed == false) {
                notClaimedStake = notClaimedStake.add(StakeHolders[allStakeHolders[i]].amount);
                notClaimedRewards = notClaimedRewards.add(StakeHolders[allStakeHolders[i]].rewards); 
            }
        }
        uint256 totalUnClaimed = notClaimedStake.add(notClaimedRewards);
        return totalUnClaimed;
    }

    /**
     * @notice Update Fully Claimed Status
     */
    function updateFullyClaimed() internal {
        if(totalUnClaimedTokens() == 0) {
            isPoolFullyClaimed = true;
        }
    }

    /**
     * @notice Get the current balance of the tokens in the contract
     */
    function balanceOfContact() external view returns(uint256) {
        return IERC20(stakeToken).balanceOf(address(this));
    }

    /**
     * @notice Get the current balance of the tokens
     */
    function balanceToMaintain() external view returns(uint256) {
        uint256 currentBalance = IERC20(stakeToken).balanceOf(address(this));
        uint256 totalUnClaimed = totalUnClaimedTokens();
        if(totalUnClaimed > currentBalance) {
            return totalUnClaimed.sub(currentBalance);
        } else {
            return 0;
        }
    }

    /** 
     * @notice EMERGENCY WITHDRAWL is used to empty the balance in contract in case of Emergency Situation
     */
    function emergencyWithdrawl() external onlyManager {
        isStakingPaused = true;
        uint256 balanceInContract = IERC20(stakeToken).balanceOf(address(this));
        IERC20(stakeToken).transfer(hotWallet(), balanceInContract);
        emit EmergencyWithdraw(stakeToken, hotWallet(), balanceInContract, block.timestamp, block.number);
    }
}

contract ManagerRole {
    address public superAdmin;
    address _hotWallet;

    event ManagerAdded(address _manager, bool _status);
    event ManagerUpdated(address _manager, bool _status);
    event HotWalletUpdated(address _oldHotWallet, address _newHotWallet);
    
    constructor(address _wallet) {
        require(_wallet != address(0), "Hotwallet can't be the zero address");
        superAdmin = msg.sender;
        _hotWallet = _wallet;
    }
    
    modifier onlySuperAdmin {
        require(superAdmin == msg.sender, "Unauthorized Access");
        _;
    }

    struct Manager {
        address _manager;
        bool _isActive;
    }
    
    mapping (address => Manager) public managers;
    
    function addManager(address _address, bool _status) external onlySuperAdmin {
        require(_address != address(0), "Manager can't be the zero address");
        managers[_address]._manager = _address;
        managers[_address]._isActive = _status;
        emit ManagerAdded(_address, _status);
    }
    
    function getManager(address _address) view external returns (address, bool) {
        return(managers[_address]._manager, managers[_address]._isActive);
    }

    function isManager(address _address) external view returns(bool _status) {
        return(managers[_address]._isActive);
    }
    
    function updateManager(address _address, bool _status) external onlySuperAdmin {
        require(_address != address(0), "Manager can't be the zero address");
        require(managers[_address]._isActive != _status);
        managers[_address]._isActive = _status;
        emit ManagerUpdated(_address, _status);
    }
    
    function governance() external view returns(address){
        return superAdmin;
    }
    
    function getHotWallet() external view returns(address) {
        return _hotWallet;
    }
    
    function setNewHotWallet(address _newHotWallet) external onlySuperAdmin {
        require(_newHotWallet != address(0), "Hotwallet can't be the zero address");
        address _oldHotWallet = _hotWallet;
        _hotWallet = _newHotWallet;
        emit HotWalletUpdated(_oldHotWallet, _newHotWallet);
    }
    
}

interface IERC20 {
    
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the sybmol of token.
     */
    function symbol() external view returns (string memory);

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
/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.5.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        return msg.sender == _owner;
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

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function mint(address account, uint256 amount) public returns(bool);
    function burn(address account, uint256 amount) public;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
@notice contract for staking ETF tokens
 */
contract KryptoinETFTokenStakeRewards is Ownable {
    using SafeMath for uint256;

    enum Status { INACTIVE, ACTIVE }

    ERC20Interface public token; // token interface to interact with ETF token

    /**
    @notice Stake struct */
    struct Stake {
        uint256 amount;         // amount of stakee
        address user;           // address of staking user
        uint256 timeAtStake;    // time at the time of stake
        Status stakeStatus;   // activate th
        uint256 reward;
    }

    uint256[] public stakesList;                            // list of all the stakes
    mapping(uint256 => Stake) private stakes;                // mapping from stakeID to stake struct
    mapping(address => uint256[]) public userToStakeIDs;    // mapping from user and its stake IDs
    mapping(address => uint256) private rewards;             // mapping from user and its reward

    uint256 public stakesCount = 0;             // total count of stakes
    uint256 tokenDecimals = 18;                 // decimals of the ETF token

    uint256 minimumNoOfDaysForStake;

    uint256 INVALID_INDEX = 999999999999; // invalid index

    uint256 public poolOne_percent = 6;
    uint256 public poolTwo_percent = 8;
    uint256 public poolThree_percent = 10;
    uint256 public poolFour_percent = 12;
    uint256 public poolFive_percent = 15;

    uint256 public poolOne_rate = 164;
    uint256 public poolTwo_rate = 219;
    uint256 public poolThree_rate = 273;
    uint256 public poolFour_rate = 328;
    uint256 public poolFive_rate = 410;

    /**
    @notice constructor of stake contract
    @param _token the address of ETF token contract
    */
    constructor(ERC20Interface _token) public {
        token = _token;
        minimumNoOfDaysForStake = 10;
    }

    /**
    @notice fired when tokens are staked by a user
     */
    event TokenStaked(address user, uint256 amount, uint256 timeAtStake, uint256 stakeID);

    /**
    @notice this function is called when a user stakes tokens
    @param tokensAmount the amount of tokens user wants to stake
     */
    function stakeTokens(uint256 tokensAmount) public {
        require(tokensAmount > 0, "tokens must be greater than zero.");

        // burn the tokens of user
        token.burn(msg.sender, tokensAmount);

        // create a new stake entity
        Stake memory newStake = Stake(tokensAmount, msg.sender, now, Status.INACTIVE, 0);

        stakesCount = stakesCount + 1;
        uint256 stakeID = stakesCount;

        // store this new stake in the stakes mapping
        stakes[stakeID] = newStake;

        // add ID of the stake to the list of all stakes
        stakesList.push(stakeID);

        // add ID of the stake to existing stakes of the user
        userToStakeIDs[msg.sender].push(stakeID);

        emit TokenStaked(msg.sender, tokensAmount, now, stakeID);
    }

    /**
    @notice fired when reward is set by the user
     */
    event RewardSet(uint256 from, uint256 to);

    /**
    @dev only owner can call this function to set rewards
    @param from the starting index of stake in the stakesList
    @param to the ending index of stake in the stakesList
     */
    function setReward(uint256 from, uint256 to) public onlyOwner {
        
        for(uint256 i = from; i < to; i++) {
            Stake storage stake = stakes[stakesList[i]];
            
            if(stake.stakeStatus == Status.INACTIVE){
                // check if the stake has passed eligibility period of 10 days
                if((stake.timeAtStake + minimumNoOfDaysForStake * 1 days) <= now) {
                    // calculate reward for the user
                    uint256 reward = calculateReward(stake.amount).mul(10);

                    // add reward for the user to existing reward amount ( roll-over )
                    rewards[stake.user] = rewards[stake.user].add(reward);
                    stake.reward = stake.reward.add(reward);
                    
                    stake.stakeStatus = Status.ACTIVE;

                }
            } else if(stake.stakeStatus == Status.ACTIVE){
                // calculate reward for the user
                uint256 reward = calculateReward(stake.amount);

                // add reward for the user to existing reward amount ( roll-over )
                rewards[stake.user] = rewards[stake.user].add(reward);
                stake.reward = stake.reward.add(reward);
            }
        }

        emit RewardSet(from, to);
    }

    /**
    @notice fired when tokens are unstaked by the user
     */
    event TokensUnstaked(address user, uint256 amount, uint256 stakeID);

    /**
    @notice this is function is called by the user to unstake tokens
    @param stakeID the ID of the stake
     */
    function unstakeTokens(uint256 stakeID) public {
        require(stakeID > 0, "please provide a valid stakeID");

        Stake memory stake_to_unstake = stakes[stakeID];
        address user = stake_to_unstake.user;
        uint256 tokenAmount = stake_to_unstake.amount;

        require(msg.sender == user, "sender is not the valid staker");

        // remove stake from stakesList
        uint256 stakeIndexInStakesList = findStakeIndexInStakesList(stakeID);
        if(stakeIndexInStakesList != INVALID_INDEX) {
            stakesList[stakeIndexInStakesList] = stakesList[stakesList.length - 1];
            stakesList.pop();
        }
        
        // remove stake from the user's list of stakes
        uint256[] storage userStakes = userToStakeIDs[msg.sender];
        uint256 stakeIndexInUserToStakeIDs = findStakeIndexInUserToStakeIDs(msg.sender, stakeID);
        if(stakeIndexInUserToStakeIDs != INVALID_INDEX) {
            userStakes[stakeIndexInUserToStakeIDs] = userStakes[userStakes.length - 1];
            userStakes.pop();
        }

        // mint the unstaked tokens for the user
        require(token.mint(user, tokenAmount), "unstake mint failed");
        emit TokensUnstaked(msg.sender, tokenAmount, stakeID);
    }

    /**
    @notice fired when reward is withdrawn by the user
     */
    event RewardWithdrawn(address withdrawer, uint256 amount);

    /**
    @notice called by the user to withdraw rewards
     */
    function withdrawReward() public {
        require(rewards[msg.sender] > 0, "sender has zero reward");
        
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;

        // mint the reward for the user
        require(token.mint(msg.sender, reward), "unstake mint failed");
        emit RewardWithdrawn(msg.sender, reward);
    }

    /**
    @notice fired when minimum number of stake days changed
     */
    event MinimumNumberOfDaysOfStakeChanged(uint256 min_days);

    /**
    @notice called to change minimum number of stake days
    @param min_days minimum number of days
     */
    function changeMinimumNumberOfDaysOfStake(uint256 min_days) public onlyOwner {
        require(min_days > 0, "min_days should be greater than zero");
        minimumNoOfDaysForStake = min_days;

        emit MinimumNumberOfDaysOfStakeChanged(minimumNoOfDaysForStake);
    }

    event PoolsNewRates(uint256 one, uint256 two, uint256 three, uint256 four, uint256 five);

    function changeDailyRewardRateOfPools(uint256 one, uint256 two, uint256 three, uint256 four, uint256 five) public onlyOwner {
        poolOne_rate = one;
        poolTwo_rate = two;
        poolThree_rate = three;
        poolFour_rate = four;
        poolFive_rate = five;

        emit PoolsNewRates(one, two, three, four, five);
    }

    event PoolsNewPerAnnumPercents(uint256 one, uint256 two, uint256 three, uint256 four, uint256 five);

    function changePerAnnumPercentOfPools(uint256 one, uint256 two, uint256 three, uint256 four, uint256 five) public onlyOwner {
        poolOne_percent = one;
        poolTwo_percent = two;
        poolThree_percent = three;
        poolFour_percent = four;
        poolFive_percent = five;

        emit PoolsNewPerAnnumPercents(one, two, three, four, five);
    }

    /**
    @notice call to this function returns the valid stakes' IDs in the contract
     */
    function getAllStakes() public view returns(uint256[] memory) {
        return stakesList;
    }

    /**
    @notice  call to this function returns stakeIDs by a user
    @param user address of the staking individual*/
    function getStakeIDsByUser(address user) public view returns(uint256[] memory) {
        return userToStakeIDs[user];
    }

    /**
    @notice this function returns percentage of rewards per annum based on the provided amount of tokens
    @param tokens_without_decimals amount of tokens without decimals
     */
    function percentageOfRewardPerAnnum(uint256 tokens_without_decimals) public view returns(uint256) {
        uint256 tokens = tokens_without_decimals;
        uint256 reward_percent;

        if(tokens >= 1000 && tokens <= 9999) { // 1000-9999
            reward_percent = poolOne_percent;
        } else if(tokens >= 10000 && tokens <= 99999) { // 10,000-99,999
            reward_percent = poolTwo_percent;
        } else if(tokens >= 100000 && tokens <= 999999) { // 100,000-999,999
            reward_percent = poolThree_percent;
        } else if(tokens >= 1000000 && tokens <= 9999999) { // 1,000,000-9,999,999
            reward_percent = poolFour_percent;
        } else if(tokens >= 10000000) { //  10,000,000+
            reward_percent = poolFive_percent;
        }

        return reward_percent;
    }

    function getRewardByUser(address user) public view returns(uint256 reward) {
        reward = rewards[user];
    }

    function stakeIDInfo(uint256 stakeID) public view returns(uint256 amount_staked, address user, uint256 timeOfStake, uint256 reward) {
        Stake memory stake = stakes[stakeID];
        amount_staked = stake.amount;
        user = stake.user;
        timeOfStake = stake.timeAtStake;
        reward = stake.reward;
    }


    /**
    @notice calculate reward for the user
    @param amount amount of the stake
    */
    function calculateReward(uint256 amount) private view returns(uint256) {
        uint256 tokens = amount;
        uint256 reward;

        // calculate reward per day
        if(tokens >= 1000 * (10 ** tokenDecimals) && tokens <= 9999 * (10 ** tokenDecimals)) { // 1000-9999
            reward = tokens.mul(poolOne_rate).div(1000000); // caculate 0.0.0164% reward
        } else if(tokens >= 10000 * (10 ** tokenDecimals) && tokens <= 99999 * (10 ** tokenDecimals)) { // 10,000-99,999
            reward = tokens.mul(poolTwo_rate).div(1000000); // calculate 0.0.0219% reward
        } else if(tokens >= 100000 * (10 ** tokenDecimals) && tokens <= 999999 * (10 ** tokenDecimals)) { // 100,000-999,999
            reward = tokens.mul(poolThree_rate).div(1000000); // calculate 0.0.0273% reward
        } else if(tokens >= 1000000 * (10 ** tokenDecimals) && tokens <= 9999999 * (10 ** tokenDecimals)) { // 1,000,000-9,999,999
            reward = tokens.mul(poolFour_rate).div(1000000); // calculate 0.0.0328% reward
        } else if(tokens >= 10000000 * (10 ** tokenDecimals)) { //  10,000,000+
            reward = tokens.mul(poolFive_rate).div(1000000); // calculate 0.0.0410% reward
        }

        return reward;
    }

     /**
    @dev only called privately to calculate index of stake in the stakesList by its ID
    @param stakeID ID of the stake
     */
    function findStakeIndexInStakesList(uint256 stakeID) private view returns(uint256) {
        for(uint256 i = 0; i < stakesList.length; i++) {
            if(stakesList[i] == stakeID) {
                return i;
            }
        }
        return INVALID_INDEX;
    }

    /**
    @dev only called privately to calculate index of stake in the userToStakeIDs by its user and stakeID
    @param user address of the user
    @param stakeID ID of the stake
     */
    function findStakeIndexInUserToStakeIDs(address user, uint256 stakeID) private view returns(uint256) {
        uint256[] memory userStakes = userToStakeIDs[user];

        for(uint256 i = 0; i < userStakes.length; i++) {
            if(userStakes[i] == stakeID) {
                return i;
            }
        }
        return INVALID_INDEX;
    }

}
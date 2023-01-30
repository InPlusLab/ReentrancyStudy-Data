// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "./Owned.sol";
import "./BREE.sol";
import "./ERC20contract.sol";
import "./SafeMath.sol";

contract BREE_STAKE_FARM is Owned{
    
    using SafeMath for uint256;
    
    uint256 public yieldCollectionFee = 0.01 ether;
    uint256 public stakingPeriod = 30 days;
    uint256 public stakeClaimFee = 0.001 ether;
    uint256 public minStakeLimit = 500 * 10 **(18); //500 BREE
    uint256 public totalYield;
    uint256 public totalRewards;
    
    Token public bree;
    
    struct Tokens{
        bool exists;
        uint256 rate;
    }
    
    mapping(address => Tokens) public tokens;
    address[] TokensAddresses;
    address governance;
    
    struct DepositedToken{
        bool    whitelisted;
        uint256 activeDeposit;
        uint256 totalDeposits;
        uint256 startTime;
        uint256 pendingGains;
        uint256 lastClaimedDate;
        uint256 totalGained;
        uint    rate;
        uint    period;
    }
    
    mapping(address => mapping(address => DepositedToken)) users;
    
    event TokenAdded(address indexed tokenAddress, uint256 indexed APY);
    event TokenRemoved(address indexed tokenAddress, uint256 indexed APY);
    event FarmingRateChanged(address indexed tokenAddress, uint256 indexed newAPY);
    event YieldCollectionFeeChanged(uint256 indexed yieldCollectionFee);
    event FarmingStarted(address indexed _tokenAddress, uint256 indexed _amount);
    event YieldCollected(address indexed _tokenAddress, uint256 indexed _yield);
    event AddedToExistingFarm(address indexed _tokenAddress, uint256 indexed tokens);
    
    event Staked(address indexed staker, uint256 indexed tokens);
    event AddedToExistingStake(address indexed staker, uint256 indexed tokens);
    event StakingRateChanged(uint256 indexed newAPY);
    event TokensClaimed(address indexed claimer, uint256 indexed stakedTokens);
    event RewardClaimed(address indexed claimer, uint256 indexed reward);
    
    event GovernanceSet(address indexed governanceAddress);
    
    modifier validStake(uint256 stakeAmount){
        require(stakeAmount >= minStakeLimit, "stake amount should be equal/greater than min stake limit");
        _;
    }
    
    modifier OwnerOrGovernance(address _caller){
        require(_caller == owner || _caller == governance);
        _;
    }
    
    constructor(address _tokenAddress) public {
        bree = Token(_tokenAddress);
        
        // add bree token to ecosystem
        _addToken(_tokenAddress, 40); // 40 apy initially
    }
    
    //#########################################################################################################################################################//
    //####################################################FARMING EXTERNAL FUNCTIONS###########################################################################//
    //#########################################################################################################################################################// 
    
    // ------------------------------------------------------------------------
    // Add assets to farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function Farm(address _tokenAddress, uint256 _amount) external{
        require(_tokenAddress != address(bree), "Use staking instead"); 
        
        // add to farm
        _newDeposit(_tokenAddress, _amount);
        
        // transfer tokens from user to the contract balance
        require(ERC20Interface(_tokenAddress).transferFrom(msg.sender, address(this), _amount));
        
        emit FarmingStarted(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Add more deposits to already running farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function AddToFarm(address _tokenAddress, uint256 _amount) external{
        require(_tokenAddress != address(bree), "use staking instead");
        _addToExisting(_tokenAddress, _amount);
        
        // move the tokens from the caller to the contract address
        require(ERC20Interface(_tokenAddress).transferFrom(msg.sender,address(this), _amount));
        
        emit AddedToExistingFarm(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Withdraw accumulated yield
    // @param _tokenAddress address of the token asset
    // @required must pay yield claim fee
    // ------------------------------------------------------------------------
    function Yield(address _tokenAddress) external payable {
        require(msg.value >= yieldCollectionFee, "should pay exact claim fee");
        require(PendingYield(_tokenAddress, msg.sender) > 0, "No pending yield");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        require(_tokenAddress != address(bree), "use staking instead");
    
        uint256 _pendingYield = PendingYield(_tokenAddress, msg.sender);
        
        // Global stats update
        totalYield = totalYield.add(_pendingYield);
        
        // update the record
        users[msg.sender][_tokenAddress].totalGained = users[msg.sender][_tokenAddress].totalGained.add(_pendingYield);
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        users[msg.sender][_tokenAddress].pendingGains = 0;
        
        // transfer fee to the owner
        owner.transfer(msg.value);
        
        // mint more tokens inside token contract equivalent to _pendingYield
        require(bree.MintTokens(_pendingYield, msg.sender));
        
        emit YieldCollected(_tokenAddress, _pendingYield);
    }
    
    // ------------------------------------------------------------------------
    // Withdraw any amount of tokens, the contract will update the farming 
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function WithdrawFarmedTokens(address _tokenAddress, uint256 _amount) external {
        require(users[msg.sender][_tokenAddress].activeDeposit >= _amount, "insufficient amount in farming");
        require(_tokenAddress != address(bree), "use withdraw of staking instead");
        
        // update farming stats
            // check if we have any pending yield, add it to previousYield var
            users[msg.sender][_tokenAddress].pendingGains = PendingYield(_tokenAddress, msg.sender);
            // update amount 
            users[msg.sender][_tokenAddress].activeDeposit = users[msg.sender][_tokenAddress].activeDeposit.sub(_amount);
            // update farming start time -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
        
        // withdraw the tokens and move from contract to the caller
        require(ERC20Interface(_tokenAddress).transfer(msg.sender, _amount));
        
        emit TokensClaimed(msg.sender, _amount);
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING EXTERNAL FUNCTIONS###########################################################################//
    //#########################################################################################################################################################//    
    
    // ------------------------------------------------------------------------
    // Start staking
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function Stake(uint256 _amount) external validStake(_amount) {
        // add new stake
        _newDeposit(address(bree), _amount);
        
        // transfer tokens from user to the contract balance
        require(bree.transferFrom(msg.sender, address(this), _amount));
        
        emit Staked(msg.sender, _amount);
        
    }
    
    // ------------------------------------------------------------------------
    // Add more deposits to already running farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function AddToStake(uint256 _amount) external {
        require(now - users[msg.sender][address(bree)].startTime < users[msg.sender][address(bree)].period, "current staking expired");
        _addToExisting(address(bree), _amount);

        // move the tokens from the caller to the contract address
        require(bree.transferFrom(msg.sender,address(this), _amount));
        
        emit AddedToExistingStake(msg.sender, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Claim reward and staked tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimStakedTokens() external {
        //require(users[msg.sender][address(bree)].running, "no running stake");
        require(users[msg.sender][address(bree)].activeDeposit > 0, "no running stake");
        require(users[msg.sender][address(bree)].startTime.add(users[msg.sender][address(bree)].period) < now, "not claimable before staking period");
        
        uint256 _currentDeposit = users[msg.sender][address(bree)].activeDeposit;
        
        // check if we have any pending reward, add it to pendingGains var
        users[msg.sender][address(bree)].pendingGains = PendingReward(msg.sender);
        // update amount 
        users[msg.sender][address(bree)].activeDeposit = 0;
        
        // transfer staked tokens
        require(bree.transfer(msg.sender, _currentDeposit));
        
        emit TokensClaimed(msg.sender, _currentDeposit);
        
    }
    
    // ------------------------------------------------------------------------
    // Claim reward and staked tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimReward() external payable {
        require(msg.value >= stakeClaimFee, "should pay exact claim fee");
        require(PendingReward(msg.sender) > 0, "nothing pending to claim");
    
        uint256 _pendingReward = PendingReward(msg.sender);
        
        // add claimed reward to global stats
        totalRewards = totalRewards.add(_pendingReward);
        // add the reward to total claimed rewards
        users[msg.sender][address(bree)].totalGained = users[msg.sender][address(bree)].totalGained.add(_pendingReward);
        // update lastClaim amount
        users[msg.sender][address(bree)].lastClaimedDate = now;
        // reset previous rewards
        users[msg.sender][address(bree)].pendingGains = 0;
        
        // transfer the claim fee to the owner
        owner.transfer(msg.value);
        
        // mint more tokens inside token contract
        require(bree.MintTokens(_pendingReward, msg.sender));
         
        emit RewardClaimed(msg.sender, _pendingReward);
    }
    
    //#########################################################################################################################################################//
    //##########################################################FARMING QUERIES################################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Query to get the pending yield
    // @param _tokenAddress address of the token asset
    // ------------------------------------------------------------------------
    function PendingYield(address _tokenAddress, address _caller) public view returns(uint256 _pendingRewardWeis){
        uint256 _totalFarmingTime = now.sub(users[_caller][_tokenAddress].lastClaimedDate);
        
        uint256 _reward_token_second = ((tokens[_tokenAddress].rate).mul(10 ** 21)).div(365 days); // added extra 10^21
        
        uint256 yield = ((users[_caller][_tokenAddress].activeDeposit).mul(_totalFarmingTime.mul(_reward_token_second))).div(10 ** 27); // remove extra 10^21 // 10^2 are for 100 (%)
        
        return yield.add(users[_caller][_tokenAddress].pendingGains);
    }
    
    // ------------------------------------------------------------------------
    // Query to get the active farm of the user
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function ActiveFarmDeposit(address _tokenAddress, address _user) external view returns(uint256 _activeDeposit){
        return users[_user][_tokenAddress].activeDeposit;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the total farming of the user
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function YourTotalFarmingTillToday(address _tokenAddress, address _user) external view returns(uint256 _totalFarming){
        return users[_user][_tokenAddress].totalDeposits;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the time of last farming of user
    // ------------------------------------------------------------------------
    function LastFarmedOn(address _tokenAddress, address _user) external view returns(uint256 _unixLastFarmedTime){
        return users[_user][_tokenAddress].startTime;
    }
    
    // ------------------------------------------------------------------------
    // Query to get total earned rewards from particular farming
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function TotalFarmingRewards(address _tokenAddress, address _user) external view returns(uint256 _totalEarned){
        return users[_user][_tokenAddress].totalGained;
    }
    
    //#########################################################################################################################################################//
    //####################################################FARMING ONLY OWNER FUNCTIONS#########################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Links governance contract to this contract
    // @param _govAddress address of the governance contract
    // @required only owner 
    // ------------------------------------------------------------------------    
    function setGovernanceContract(address _govAddress) external onlyOwner {
        governance = _govAddress;
        emit GovernanceSet(_govAddress);
    }
    
    // ------------------------------------------------------------------------
    // Add supported tokens
    // @param _tokenAddress address of the token asset
    // @param _farmingRate rate applied for farming yield to produce
    // @required only owner or governance contract
    // ------------------------------------------------------------------------    
    function AddToken(address _tokenAddress, uint256 _rate) public OwnerOrGovernance(msg.sender) {
        _addToken(_tokenAddress, _rate);
    }
    
    // ------------------------------------------------------------------------
    // Remove tokens if no longer supported
    // @param _tokenAddress address of the token asset
    // @required only owner or governance contract
    // ------------------------------------------------------------------------  
    function RemoveToken(address _tokenAddress) public OwnerOrGovernance(msg.sender) {
        
        require(tokens[_tokenAddress].exists, "token doesn't exist");
        
        tokens[_tokenAddress].exists = false;
        
        emit TokenRemoved(_tokenAddress, tokens[_tokenAddress].rate);
    }
    
    // ------------------------------------------------------------------------
    // Change farming rate of the supported token
    // @param _tokenAddress address of the token asset
    // @param _newFarmingRate new rate applied for farming yield to produce
    // @required only owner or governance contract
    // ------------------------------------------------------------------------  
    function ChangeFarmingRate(address _tokenAddress, uint256 _newFarmingRate) public OwnerOrGovernance(msg.sender) {
        
        require(tokens[_tokenAddress].exists, "token doesn't exist");
        
        tokens[_tokenAddress].rate = _newFarmingRate;
        
        emit FarmingRateChanged(_tokenAddress, _newFarmingRate);
    }

    // ------------------------------------------------------------------------
    // Change Yield collection fee
    // @param _fee fee to claim the yield
    // @required only owner or governance contract
    // ------------------------------------------------------------------------     
    function SetYieldCollectionFee(uint256 _fee) public OwnerOrGovernance(msg.sender){
        yieldCollectionFee = _fee;
        emit YieldCollectionFeeChanged(_fee);
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING QUERIES######################################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Query to get the pending reward
    // ------------------------------------------------------------------------
    function PendingReward(address _caller) public view returns(uint256 _pendingReward){
        uint256 _totalStakedTime = 0;
        uint256 expiryDate = (users[_caller][address(bree)].period).add(users[_caller][address(bree)].startTime);
        
        if(now < expiryDate)
            _totalStakedTime = now.sub(users[_caller][address(bree)].lastClaimedDate);
        else{
            if(users[_caller][address(bree)].lastClaimedDate >= expiryDate) // if claimed after expirydate already
                _totalStakedTime = 0;
            else
                _totalStakedTime = expiryDate.sub(users[_caller][address(bree)].lastClaimedDate);
        }
            
        uint256 _reward_token_second = ((users[_caller][address(bree)].rate).mul(10 ** 21)); // added extra 10^21
        uint256 reward =  ((users[_caller][address(bree)].activeDeposit).mul(_totalStakedTime.mul(_reward_token_second))).div(10 ** 27); // remove extra 10^21 // the two extra 10^2 is for 100 (%) // another two extra 10^4 is for decimals to be allowed
        reward = reward.div(365 days);
        return (reward.add(users[_caller][address(bree)].pendingGains));
    }
    
    // ------------------------------------------------------------------------
    // Query to get the active stake of the user
    // ------------------------------------------------------------------------
    function YourActiveStake(address _user) external view returns(uint256 _activeStake){
        return users[_user][address(bree)].activeDeposit;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the total stakes of the user
    // ------------------------------------------------------------------------
    function YourTotalStakesTillToday(address _user) external view returns(uint256 _totalStakes){
        return users[_user][address(bree)].totalDeposits;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the time of last stake of user
    // ------------------------------------------------------------------------
    function LastStakedOn(address _user) public view returns(uint256 _unixLastStakedTime){
        return users[_user][address(bree)].startTime;
    }
    
    // ------------------------------------------------------------------------
    // Query to get total earned rewards from stake
    // ------------------------------------------------------------------------
    function TotalStakeRewardsClaimedTillToday(address _user) external view returns(uint256 _totalEarned){
        return users[_user][address(bree)].totalGained;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking rate
    // ------------------------------------------------------------------------
    function LatestStakingRate() external view returns(uint256 APY){
        return tokens[address(bree)].rate;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking rate you staked at
    // ------------------------------------------------------------------------
    function YourStakingRate(address _user) external view returns(uint256 _stakingRate){
        return users[_user][address(bree)].rate;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking period you staked at
    // ------------------------------------------------------------------------
    function YourStakingPeriod(address _user) external view returns(uint256 _stakingPeriod){
        return users[_user][address(bree)].period;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking time left
    // ------------------------------------------------------------------------
    function StakingTimeLeft(address _user) external view returns(uint256 _secsLeft){
        uint256 left = 0; 
        uint256 expiryDate = (users[_user][address(bree)].period).add(LastStakedOn(_user));
        
        if(now < expiryDate)
            left = expiryDate.sub(now);
            
        return left;
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING ONLY OWNER FUNCTION##########################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Change staking rate
    // @param _newStakingRate new rate applied for staking
    // @required only owner or governance contract
    // ------------------------------------------------------------------------  
    function ChangeStakingRate(uint256 _newStakingRate) public OwnerOrGovernance(msg.sender){
        
        tokens[address(bree)].rate = _newStakingRate;
        
        emit StakingRateChanged(_newStakingRate);
    }
    
    // ------------------------------------------------------------------------
    // Change the min stake limit
    // @param _minStakeLimit minimum stake limit value
    // @required only callable by owner or governance contract
    // ------------------------------------------------------------------------
    function SetMinStakeLimit(uint256 _minStakeLimit) public OwnerOrGovernance(msg.sender){
       minStakeLimit = _minStakeLimit;
    }
    
    // ------------------------------------------------------------------------
    // Change the staking period
    // @param _seconds number of seconds to stake (n days = n*24*60*60)
    // @required only callable by owner or governance contract
    // ------------------------------------------------------------------------
    function SetStakingPeriod(uint256 _seconds) public OwnerOrGovernance(msg.sender){
       stakingPeriod = _seconds;
    }
    
    // ------------------------------------------------------------------------
    // Change the staking claim fee
    // @param _fee claim fee in weis
    // @required only callable by owner or governance contract
    // ------------------------------------------------------------------------
    function SetClaimFee(uint256 _fee) public OwnerOrGovernance(msg.sender){
       stakeClaimFee = _fee;
    }
    
    //#########################################################################################################################################################//
    //################################################################COMMON UTILITIES#########################################################################//
    //#########################################################################################################################################################//    
    
    // ------------------------------------------------------------------------
    // Internal function to add new deposit
    // ------------------------------------------------------------------------        
    function _newDeposit(address _tokenAddress, uint256 _amount) internal{
        require(users[msg.sender][_tokenAddress].activeDeposit ==  0, "Already running");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        // add that token into the contract balance
        // check if we have any pending reward/yield, add it to pendingGains variable
        if(_tokenAddress == address(bree)){
            users[msg.sender][_tokenAddress].pendingGains = PendingReward(msg.sender);
            users[msg.sender][_tokenAddress].period = stakingPeriod;
            users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate; // rate for stakers will be fixed at time of staking
        }
        else
            users[msg.sender][_tokenAddress].pendingGains = PendingYield(_tokenAddress, msg.sender);
            
        users[msg.sender][_tokenAddress].activeDeposit = _amount;
        users[msg.sender][_tokenAddress].totalDeposits = users[msg.sender][_tokenAddress].totalDeposits.add(_amount);
        users[msg.sender][_tokenAddress].startTime = now;
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        
    }

    // ------------------------------------------------------------------------
    // Internal function to add to existing deposit
    // ------------------------------------------------------------------------        
    function _addToExisting(address _tokenAddress, uint256 _amount) internal{
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        // require(users[msg.sender][_tokenAddress].running, "no running farming/stake");
        require(users[msg.sender][_tokenAddress].activeDeposit > 0, "no running farming/stake");
        // update farming stats
            // check if we have any pending reward/yield, add it to pendingGains variable
            if(_tokenAddress == address(bree)){
                users[msg.sender][_tokenAddress].pendingGains = PendingReward(msg.sender);
                users[msg.sender][_tokenAddress].period = stakingPeriod;
                users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate; // rate of only staking will be updated when more is added to stake
            }
            else
                users[msg.sender][_tokenAddress].pendingGains = PendingYield(_tokenAddress, msg.sender);
            // update current deposited amount 
            users[msg.sender][_tokenAddress].activeDeposit = users[msg.sender][_tokenAddress].activeDeposit.add(_amount);
            // update total deposits till today
            users[msg.sender][_tokenAddress].totalDeposits = users[msg.sender][_tokenAddress].totalDeposits.add(_amount);
            // update new deposit start time -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
            
            
    }

    // ------------------------------------------------------------------------
    // Internal function to add token
    // ------------------------------------------------------------------------     
    function _addToken(address _tokenAddress, uint256 _rate) internal{
        require(!tokens[_tokenAddress].exists, "token already exists");
        
        tokens[_tokenAddress] = Tokens({
            exists: true,
            rate: _rate
        });
        
        TokensAddresses.push(_tokenAddress);
        emit TokenAdded(_tokenAddress, _rate);
    }
    
    
}



// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

// ----------------------------------------------------------------------------
// 'BREE' token contract

// Symbol      : BREE 
// Name        : CBDAO 
// Total supply: 10 million
// Decimals    : 18
// ----------------------------------------------------------------------------

import './SafeMath.sol';
import './ERC20contract.sol';
import './Owned.sol';

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Token is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "BREE";
    string public  name = "CBDAO";
    uint256 public decimals = 18;
    uint256 private maxCapSupply = 1e7 * 10**(decimals); // 10 million
    uint256 _totalSupply = 1530409 * 10 ** (decimals); // 1,530,409
    address stakeFarmingContract;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        // mint _totalSupply amount of tokens and send to owner
        balances[owner] = balances[owner].add(_totalSupply);
        emit Transfer(address(0),owner, _totalSupply);
    }
    
    // ------------------------------------------------------------------------
    // Set the STAKE_FARMING_CONTRACT
    // @required only owner
    // ------------------------------------------------------------------------
    function SetStakeFarmingContract(address _address) external onlyOwner{
        require(_address != address(0), "Invalid address");
        stakeFarmingContract = _address;
    }
    
    // ------------------------------------------------------------------------
    // Token Minting function
    // @params _amount expects the amount of tokens to be minted excluding the 
    // required decimals
    // @params _beneficiary tokens will be sent to _beneficiary
    // @required only owner OR stakeFarmingContract
    // ------------------------------------------------------------------------
    function MintTokens(uint256 _amount, address _beneficiary) public returns(bool){
        require(msg.sender == stakeFarmingContract);
        require(_beneficiary != address(0), "Invalid address");
        require(_totalSupply.add(_amount) <= maxCapSupply, "exceeds max cap supply 10 million");
        _totalSupply = _totalSupply.add(_amount);
        
        // mint _amount tokens and keep inside contract
        balances[_beneficiary] = balances[_beneficiary].add(_amount);
        
        emit Transfer(address(0),_beneficiary, _amount);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Burn the `_amount` amount of tokens from the calling `account`
    // @params _amount the amount of tokens to burn
    // ------------------------------------------------------------------------
    function BurnTokens(uint256 _amount) external {
        _burn(_amount, msg.sender);
    }

    // ------------------------------------------------------------------------
    // @dev Internal function that burns an amount of the token from a given account
    // @param _amount The amount that will be burnt
    // @param _account The tokens to burn from
    // ------------------------------------------------------------------------
    function _burn(uint256 _amount, address _account) internal {
        require(balances[_account] >= _amount, "insufficient account balance");
        _totalSupply = _totalSupply.sub(_amount);
        balances[_account] = balances[_account].sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }
    
    /** ERC20Interface function's implementation **/
    
    // ------------------------------------------------------------------------
    // Get the total supply of the `token`
    // ------------------------------------------------------------------------
    function totalSupply() public override view returns (uint256){
       return _totalSupply; 
    }
    
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public override returns  (bool success) {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to].add(tokens) >= balances[to]);
            
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

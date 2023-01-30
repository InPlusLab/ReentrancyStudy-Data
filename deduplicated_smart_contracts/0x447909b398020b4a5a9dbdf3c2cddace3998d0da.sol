/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

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


// ----------------------------------------------------------------------------
// 'Ultra Token' token contract

// Symbol      : ULTRA
// Name        : Ultra Token
// Total supply: 10,000,000 (10 Million)
// Decimals    : 18
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Token is ERC20Interface {
    using SafeMath for uint256;
   
    string public symbol = "ULTRA";
    string public  name = "Ultra Token";
   
    uint256 public decimals = 18;
    uint256 _totalSupply = 10e6 * 10 ** (decimals);
    uint256 deployTime;
    uint256 private totalDividentPoints;
    uint256 private unclaimedDividendPoints;
    uint256 pointMultiplier = 1000000000000000000;
    uint256 public stakedCoins;
    uint256 private rewardCoins;
    address marketingAdd = 0xec5Af8C0775A2599c7726d50824FC01b3d279023;
    address preSaleAdd = 0x70Fc9e16650F5A30fbf7041c161D49E93a7cb617;
    address teamAdd = 0x6089F0a52a0DBD55906DA7CeEDA052aa0B76f6A0;
    address uniSwapAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    uint256 public totalStakes;
    uint256 public teamLockedTokens;
    uint256 public totalRewardsClaimed;
    
    struct  Account {
        uint256 balance;
        uint256 lastDividentPoints;
        uint256 timeInvest;
        uint256 lastClaimed;
        bool claimLimit;
        uint256 rewardsClaimed;
        uint256 totalStakes;
    }

    mapping(address => Account) accounts;
    mapping(address => bool) isInvertor;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
       
        balances[address(this)] = totalSupply();
        emit Transfer(address(0),address(this), totalSupply());
       
        balances[teamAdd] = onePercent(totalSupply()).mul(3);
        balances[address(this)] = balances[address(this)].sub(balances[teamAdd]);
        emit Transfer(address(this), teamAdd, onePercent(totalSupply()).mul(3));
        teamLockedTokens = onePercent(totalSupply()).mul(3);
       
        balances[preSaleAdd] = onePercent(totalSupply()).mul(27);
        balances[address(this)] = balances[address(this)].sub(balances[preSaleAdd]);
        emit Transfer(address(this), preSaleAdd, onePercent(totalSupply()).mul(27));
       
        balances[marketingAdd] = onePercent(totalSupply()).mul(5);
        balances[address(this)] = balances[address(this)].sub(balances[marketingAdd]);
        emit Transfer(address(this), marketingAdd, onePercent(totalSupply()).mul(5));
       
        rewardCoins = onePercent(totalSupply()).mul(65);
        
        deployTime = block.timestamp;
    }

    function STAKE(uint256 _tokens) external returns(bool){
        require(isInvertor[msg.sender] == false, "Sorry!, Already an Investor");
        require(transfer(address(this), _tokens), "Insufficient Funds!");
       
        isInvertor[msg.sender] = true;
        stakedCoins = stakedCoins.add(_tokens);
        accounts[msg.sender].balance = _tokens;
        accounts[msg.sender].lastDividentPoints = totalDividentPoints;
        accounts[msg.sender].timeInvest = now;
        accounts[msg.sender].lastClaimed = now;
        accounts[msg.sender].claimLimit = false;
        accounts[msg.sender].totalStakes = accounts[msg.sender].totalStakes.add(_tokens);
        
        totalStakes = totalStakes.add(_tokens);
        
        return true;
    }
    
    function perDayShare(address investor) internal returns(uint256){
        if (accounts[investor].claimLimit == false){
            if ( ( (now - accounts[investor].timeInvest).div(1 days) ) > 10){
                uint256 leftDays = 10 - ( (accounts[investor].lastClaimed - accounts[investor].timeInvest).div(1 days) ) ;
                accounts[investor].claimLimit = true;
                accounts[investor].lastClaimed = now;
                return onePercent(accounts[investor].balance).mul(leftDays);
            }
            else{
                uint256 days_ = (now - accounts[investor].lastClaimed).div(1 days);
                if (days_ > 0){
                    accounts[investor].lastClaimed = now;
                }
                return (onePercent(accounts[investor].balance).mul(days_));
            }    
        }
        else{
            return 0;
        }
       
    }
   
    function _perDayShare(address investor) private view returns(uint256){
    if (accounts[investor].claimLimit == false){
        if ( ( (now - accounts[investor].timeInvest).div(1 days) ) > 10){
            uint256 leftDays = 10 - ( (accounts[investor].lastClaimed - accounts[investor].timeInvest).div(1 days) ) ;
            return onePercent(accounts[investor].balance).mul(leftDays);
        }
        else{
            uint256 days_ = (now - accounts[investor].lastClaimed).div(1 days);
           
            return (onePercent(accounts[investor].balance).mul(days_));
        }    
    }
    else{
        return 0;
    }
   
 }
   
    function pendingReward(address _user) external view returns(uint256){
        uint256 owing = dividendsOwing(_user);
       
        uint256 reward = _perDayShare(_user);
        if (reward > rewardCoins){
            reward = rewardCoins;
        }
        return reward.add(owing);
    }
   
    function updateDividend(address investor) internal returns(uint256){
        uint256 owing = dividendsOwing(investor);
        if (owing > 0){
            unclaimedDividendPoints = unclaimedDividendPoints.sub(owing);
            accounts[investor].lastDividentPoints = totalDividentPoints;
        }
        return owing;
    }
   
    function activeStake(address _user) external view returns (uint256){
        return accounts[_user].balance;
    }
    
    function totalStakesTillToday(address _user) external view returns (uint256){
        return accounts[_user].totalStakes;
    }
   
    function UNSTAKE() external returns (bool){
        require(isInvertor[msg.sender] == true, "Sorry!, Not investor");
        require(stakedCoins > 0);
       
        stakedCoins = stakedCoins.sub(accounts[msg.sender].balance);
       
        uint256 owing = updateDividend(msg.sender);
       
        uint256 reward = perDayShare(msg.sender);
       
        if (reward > rewardCoins){
            reward = rewardCoins;
        }
       
        require(_transfer(msg.sender, owing.add(reward).add(accounts[msg.sender].balance)));
        rewardCoins = rewardCoins.sub(reward);
       
        isInvertor[msg.sender] = false;
        accounts[msg.sender].balance = 0;
        return true;
    }
   
   
   
    function disburse(uint256 amount) internal{
        uint256 unnormalized = amount.mul(pointMultiplier);
        totalDividentPoints = totalDividentPoints.add(unnormalized.div(stakedCoins));
        unclaimedDividendPoints = unclaimedDividendPoints.add(amount);
    }
   
    function dividendsOwing(address investor) internal view returns (uint256){
        uint256 newDividendPoints = totalDividentPoints.sub(accounts[investor].lastDividentPoints);
        return ((accounts[investor].balance).mul(newDividendPoints)).div(pointMultiplier);
    }
   
    function claimReward() external returns(bool){
        require(isInvertor[msg.sender] == true, "Sorry!, Not an investor");
        require(accounts[msg.sender].balance > 0);
       
        uint256 owing = updateDividend(msg.sender);
       
        uint256 reward = perDayShare(msg.sender);
        if (reward > rewardCoins){
            reward = rewardCoins;
        }
        require(_transfer(msg.sender, owing.add(reward)));
        
        accounts[msg.sender].rewardsClaimed = accounts[msg.sender].rewardsClaimed.add(owing.add(reward));
        rewardCoins = rewardCoins.sub(reward);
       
        totalRewardsClaimed = totalRewardsClaimed.add(owing.add(reward));
        return true;
    }
    
    function roiAllClaimed(address _user) external view returns(bool roiClaimed){
        return accounts[_user].claimLimit;
    }
    
    function rewardsClaimed(address _user) external view returns(uint256 rewardClaimed){
        return accounts[_user].rewardsClaimed;
    }
   
    /** ERC20Interface function's implementation **/
   
    function totalSupply() public override view returns (uint256){
       return _totalSupply;
    }
   
    // ------------------------------------------------------------------------
    // Calculates onePercent of the uint256 amount sent
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) internal pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
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
    function transfer(address to, uint256 tokens) public override returns (bool success) {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        
        if(teamLockedTokens > 0 && msg.sender == teamAdd){
                if(block.timestamp < deployTime.add(8 weeks)){
                    require(balances[teamAdd].sub(tokens) >= teamLockedTokens,"tokens are locked for 8 weeks");
                } else
                    teamLockedTokens = 0;
        }
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
       
        uint256 deduction = 0;
        if (address(to) != address(this) && 
        
        address(to) != uniSwapAddress && address(to) != teamAdd && address(to) != marketingAdd && address(to) != preSaleAdd &&
        msg.sender != uniSwapAddress && msg.sender != teamAdd && msg.sender != marketingAdd && msg.sender != preSaleAdd)
        
        {
            
            deduction = onePercent(tokens).mul(5);
            if (stakedCoins == 0){
                burnTokens(deduction);
            }
            else{
                burnTokens(onePercent(deduction).mul(2));
                disburse(onePercent(deduction).mul(3));
            }
        }
        
        balances[to] = balances[to].add(tokens.sub(deduction));
        emit Transfer(msg.sender, to, tokens.sub(deduction));
        return true;
    }
   
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public override returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
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
        
        if(from == teamAdd && balances[teamAdd].sub(tokens) > teamLockedTokens){
            require(block.timestamp > deployTime.add(8 weeks), "tokens are locked for 8 weeks");
            teamLockedTokens = 0;
        }
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
       
        uint256 deduction = 0;
        if (to != address(this) && from != address(this) &&
        to != uniSwapAddress && to != teamAdd && to != marketingAdd && to != preSaleAdd &&
        from != uniSwapAddress && from != teamAdd && from != marketingAdd && from != preSaleAdd)
        
        {
            deduction = onePercent(tokens).mul(5);
            if (stakedCoins == 0){
                burnTokens(deduction);
            }
            else{
                burnTokens(onePercent(deduction).mul(2));
                disburse(onePercent(deduction).mul(3));
            }
        }
       
        balances[to] = balances[to].add(tokens.sub(deduction));
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }

   
    function _transfer(address to, uint256 tokens) internal returns(bool){
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens );
        require(balances[to] + tokens >= balances[to]);
           
        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[to] = balances[to].add(tokens);

        emit Transfer(address(this),to,tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
   
    // ------------------------------------------------------------------------
    // Burn the ``value` amount of tokens from the `account`
    // ------------------------------------------------------------------------
    function burnTokens(uint256 value) internal{
        require(_totalSupply >= value); // burn only unsold tokens
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(msg.sender, address(0), value);
    }
}
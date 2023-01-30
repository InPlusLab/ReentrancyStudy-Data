pragma solidity 0.4.26;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";
import "./ApproveAndCallFallback.sol";

contract MeridianInterface is ERC20{
  function owner() external returns(address);
}

contract MeridianStaking is ApproveAndCallFallBack{
  using SafeMath for uint;
  using SignedSafeMath for int;
  MeridianInterface public meridianToken;
  mapping(address => uint256) public amountStaked;
  mapping(address => int256) public payoutsTo;//only represents the portion of payouts from collective dividends
  mapping(address => uint256) public payoutsToTime;//over time related payouts
  mapping(address => uint256) public unclaimedDividends;//dividends over time before the last user checkpoint
  mapping(address => uint256) public dividendCheckpoints;//the time from which to calculate new dividends
  mapping(address => uint256) public dividendRateUsed;
  uint256 public stakedTotalSum;
  uint256 public divsPerShare;
  uint256 constant internal magnitude = 2 ** 64;
  uint256 constant internal STAKING_MINIMUM = 100 * (10 ** 18); //token is 18 decimals
  uint256 public STAKING_PERIOD = 1 days; //time period to which the dividend rate refers to
  uint256 public BURN_RATE = 100; //10% transaction burns, unstaking burns, div withdraw burns
  uint public STAKE_DIV_FEE = 50; //5% stake div fee
  uint256 public DIVIDEND_RATE = 10;//1.0%
  bool public activated = false;
  uint256 public contractEndTime=0;

  uint256 public nowTest=now;

  event Stake(address indexed user, uint256 amount);
	event UnStake(address indexed user, uint256 amount);
  event WithdrawDivs(address indexed user, uint256 amount);
  event ReStakeDivs(address indexed user, uint256 amount);

  modifier isAdmin() {
      require(msg.sender==meridianToken.owner(),"user is not admin");
      _;
  }
  modifier isActive() {
      require(activated,"staking is not yet active");
      _;
  }

  constructor(address token) public{
    meridianToken=MeridianInterface(token);
  }
  function setRates(uint burn,uint div,uint unstake) public isAdmin{
    BURN_RATE=burn;
    DIVIDEND_RATE=div;
    STAKE_DIV_FEE=unstake;
  }
  function activateContract() public isAdmin{
    activated=true;
  }
  function burnAfterContractEnd() public isAdmin{
    meridianToken.burn(meridianToken.balanceOf(address(this)));
  }
  function disableDividendAccumulation() public isAdmin{
    contractEndTime=now;
  }

  /*
    Used for staking, must send an approveAndCall to the token which will then call this function
  */
  function receiveApproval(address fromAddr, uint256 tokens, address token, bytes data) external{
    require(msg.sender==address(meridianToken));
    require(meridianToken.transferFrom(fromAddr,address(this),tokens),"transfer failed");
    _stake(tokens,fromAddr);
  }
  function _stake(uint256 amount,address fromAddr) private isActive{
    require(amountStaked[fromAddr].add(amount) >= STAKING_MINIMUM,"amount below staking minimum");
    updateCheckpoint(fromAddr,true);
    stakedTotalSum = stakedTotalSum.add(amount);
    amountStaked[fromAddr] = amountStaked[fromAddr].add(amount);
    payoutsTo[fromAddr] = payoutsTo[fromAddr].add(int256(amount.mul(divsPerShare)));
    emit Stake(fromAddr, amount);
  }
  function unstake(uint256 amount) public isActive{
    require(amountStaked[msg.sender] >= amount);
    updateCheckpoint(msg.sender,true);

    uint256 divPortion=amount.mul(STAKE_DIV_FEE).div(1000);// dividends to be redistributed to users
    uint256 burnPortion=amount.mul(BURN_RATE).div(1000);// tokens to be burned
    uint256 unstakeFee = divPortion.add(burnPortion);
    divsPerShare = divsPerShare.add(divPortion.mul(magnitude).div(stakedTotalSum)); //portion of fee redistributed as divs, the rest to be burned
    stakedTotalSum = stakedTotalSum.sub(amount);
    uint256 taxedAmount = amount.sub(unstakeFee);
    amountStaked[msg.sender] = amountStaked[msg.sender].sub(amount);
    payoutsTo[msg.sender] = payoutsTo[msg.sender].sub(int256(amount.mul(divsPerShare)));
    meridianToken.burn(burnPortion);//burn a portion of the fee
    meridianToken.transfer(msg.sender,taxedAmount);
    emit UnStake(msg.sender, amount);
  }
  function withdrawDivs() public isActive{
    updateCheckpoint(msg.sender,false);
    uint256 burnedDivs = getBurnedDivs(msg.sender);
    payoutsTo[msg.sender] = payoutsTo[msg.sender].add(int256(burnedDivs.mul(magnitude)));
    uint256 timeDivs=getTotalDivsOverTime(msg.sender);
    payoutsToTime[msg.sender] = payoutsToTime[msg.sender].add(timeDivs);
    uint256 baseDivs=burnedDivs.add(timeDivs);

    uint256 burnFee=baseDivs.mul(BURN_RATE).div(1000);
    uint256 divs=baseDivs.sub(burnFee);

    meridianToken.burn(burnFee);
    meridianToken.transfer(msg.sender,divs);
    emit WithdrawDivs(msg.sender, divs);
  }
  function reinvestDivs() public isActive{
    updateCheckpoint(msg.sender,false);
    uint256 burnedDivs = getBurnedDivs(msg.sender);
    payoutsTo[msg.sender] = payoutsTo[msg.sender].add(int256(burnedDivs.mul(magnitude)));
    uint256 timeDivs=getTotalDivsOverTime(msg.sender);
    payoutsToTime[msg.sender] = payoutsToTime[msg.sender].add(timeDivs);
    uint256 divs=burnedDivs.add(timeDivs);
    _stake(divs,msg.sender);
    emit ReStakeDivs(msg.sender, divs);
  }

  function getDividends(address user) public view returns(uint256){
    return getBurnedDivs(user).add(getTotalDivsOverTime(user));
  }
  function getBurnedDivs(address user) public view returns(uint256){
    if(int256(divsPerShare.mul(amountStaked[user])) < payoutsTo[user]){
      return 0;
    }
    else{
      return uint256(int256(divsPerShare.mul(amountStaked[user])).sub(payoutsTo[user])).div(magnitude);
    }
  }
  function updateCheckpoint(address user,bool updateRate) private{
    unclaimedDividends[user]=unclaimedDividends[user].add(getNewDivsOverTime(user));
    dividendCheckpoints[user]=getNow();
    if(updateRate){
      dividendRateUsed[user]=DIVIDEND_RATE;//locks in latest div rate. Done after unclaimedDividends updated, so divs from before this operation will be at the old rate.
    }
  }
  function getTotalDivsSubWithdrawFee(address user) external view returns(uint256){
    uint256 baseDivs=getDividends(user);
    uint256 fee=baseDivs.mul(BURN_RATE).div(1000).add(baseDivs.mul(STAKE_DIV_FEE).div(1000));
    return baseDivs.sub(fee);
  }
  //recent divs over time plus previously recorded divs over time
  function getTotalDivsOverTime(address user) public view returns(uint256){
    return unclaimedDividends[user].add(getNewDivsOverTime(user)).sub(payoutsToTime[user]);
  }
  //Formula for dividends over time is (time_passed/staking_period)*staked_tokens*dividend_rate
  //All divided by 1000 to convert dividend rate to the appropriate units
  function getNewDivsOverTime(address user) public view returns(uint256){
    return getNow().sub(dividendCheckpoints[user]).mul(amountStaked[user]).mul(dividendRateUsed[user]).div(STAKING_PERIOD.mul(1000));
  }
  function getNow() public view returns(uint256){
      //have 'now' be assumed to be the contract end time, if the current time is later than that. This is to prevent accumulation of dividends after this point.
      if(contractEndTime>0 && now>contractEndTime){
        return contractEndTime;
      }
      else{
        return now;
      }

  }
}

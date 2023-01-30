/**
 *Submitted for verification at Etherscan.io on 2020-07-04
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-03
*/

pragma solidity ^0.4.26;
library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

library DataStructs {

        struct DailyRound {
            uint256 startTime;
            uint256 endTime;
            address player; //
            uint256 referralCount; //
            bool ended; //
            uint256 pool; //
            uint256 DisttaLL;
            uint256 Toteligble;
        }
        
        struct Rolladice {
            address player; //
            uint256 referralCount; //
            uint256 EnterDt;
            uint256 RID;
            //uint256 dtcin;
        }

        struct Player {
            uint256 totalInvestment;
            uint256 referralIncome;
            uint256 cycle;
            uint256 dailyIncome;
            uint256 poolIncome;
            uint256 lastSettledTime;
            uint256 incomeLimit;
            uint256 incomeLimitLeft;
            uint256 referralCount;
            address referrer;
            uint256 RegDt;
            uint256 rddid;
        }

        struct PlayerDailyRounds {
            uint256 referrers; //
    }
     
}

contract Dice2winco {
    using SafeMath for *;

    address public owner;
    address public roundStarter;
    uint256 houseFee = 2;
    uint256 poolTime = 24 hours;
    uint256 payoutPeriod = 24 hours;
    uint256 PoolentryTime=168 hours;
    uint256 dailyWinPool = 2;
    uint256 incomeTimes = 30;
    uint256 incomeDivide = 10;
    uint256 public roundID;
    
    uint256 public r1 = 0;
    uint256 public r2 = 0;
    
    uint256 public RollaDiceCnt = 0;
        

    mapping (uint => uint) public CYCLE_PRICE;
    mapping(uint=>uint) public LEVEL;
   // mapping (uint => uint) public RollaDiceCnt;
    
    mapping (address => bool) public playerExist;
    mapping (address => bool) public playerExistrnd;
    
    mapping (uint256 => DataStructs.DailyRound) public round;
    mapping (address => DataStructs.Player) public player;
    mapping (uint256 => DataStructs.Rolladice) public rollladic;
    
    mapping (address => mapping (uint256 => DataStructs.PlayerDailyRounds)) public plyrRnds_; 

    /****************************  EVENTS   *****************************************/

    event registerUserEvent(address indexed _playerAddress, address indexed _referrer);
    event upgradeLevelEvent(address indexed _playerAddress, uint256 indexed _amount);
    event referralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 timeStamp);
    event missedDirectreferralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256  timeStamp);
    event dailyPayoutEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
    event withdrawEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
    event roundEndEvent(address indexed _highestReferrer, uint256 indexed _referrals, uint256 indexed endTime, uint256 poolAmount);
    event ownershipTransferred(address indexed owner, address indexed newOwner);


    constructor (address _roundStarter) public {
         owner = msg.sender;
         roundStarter = _roundStarter;
         roundID = 1;
         
         round[1].startTime=now;
         round[1].endTime=now+poolTime;
         
         CYCLE_PRICE[1] = 0.25 ether;
         CYCLE_PRICE[2] = 0.5 ether;
         CYCLE_PRICE[3] = 1 ether;
         CYCLE_PRICE[4] = 2 ether;
         CYCLE_PRICE[5] = 4 ether;
         CYCLE_PRICE[6] = 8 ether;
         CYCLE_PRICE[7] = 16 ether;
         CYCLE_PRICE[8] = 25.5 ether;
         
            LEVEL[1]=8 ether;
            LEVEL[2]=4 ether;
            LEVEL[3]=2 ether;
            LEVEL[4]=1 ether;
            LEVEL[5]=0.50 ether;
            LEVEL[6]=0.50 ether;
            LEVEL[7]=0.50 ether;
            LEVEL[8]=0.50 ether;
            LEVEL[9]=0.50 ether;
            LEVEL[10]=0.50 ether;
    }
    /****************************  MODIFIERS    *****************************************/
    
    
    /**
     * @dev sets boundaries for incoming tx
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth <= 25500000000000000000, "Maximum contribution amount is 25.5 ETH");
        _;
    }
    
    /**
     * @dev allows only the user to run the function
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
    /****************************  CORE LOGIC    *****************************************/
    //if someone accidently sends eth to contract address
    function () external payable {
        playGame(address(0x0));
    }
    //
    function playGame(address _referrer) 
    public
    isWithinLimits(msg.value)
    payable {
        
        uint256 amount = msg.value;
        if (playerExist[msg.sender] == false) 
        {
            require(amount == CYCLE_PRICE[1], "joining fees should be 0.25 ether");

            player[msg.sender].lastSettledTime = now;
            player[msg.sender].incomeLimit = amount.mul(incomeTimes).div(incomeDivide);
            player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimit;
            player[msg.sender].totalInvestment = amount;
            player[msg.sender].cycle = 1;
            player[msg.sender].RegDt=now;
            player[msg.sender].rddid=0;
            
            playerExist[msg.sender] = true;
        //referral
            if(
                // is this a referred purchase?
                _referrer != address(0x0) && 
                //self referrer not allowed
                _referrer != msg.sender &&
                
                //referrer exists?
                playerExist[_referrer] == true
              ) 
              
              {
                    //Assign referral to user
                    player[msg.sender].referrer = _referrer;
                    ///
                                if(playerExistrnd[roundStarter]==false)
                                    {
                                    RollaDiceCnt=RollaDiceCnt.add(1);
                                    player[roundStarter].rddid= RollaDiceCnt;
                                    playerExistrnd[roundStarter]=true;
                                    rollladic[RollaDiceCnt].EnterDt = now;
                                    rollladic[RollaDiceCnt].player=roundStarter;
                                    rollladic[RollaDiceCnt].referralCount= 1;
                                    rollladic[RollaDiceCnt].RID=RollaDiceCnt;
                                    }
                                    ///
                    player[_referrer].referralCount = player[_referrer].referralCount.add(1);
                    //playerExistrnd
                    if(now <= player[_referrer].RegDt +PoolentryTime)
                                {
                                    if (player[_referrer].referralCount>=20 && playerExistrnd[_referrer]==false)
                                    {
                                  //  round[roundID].player = _referrer;
                                    //round[roundID].referralCount = player[_referrer].referralCount; 
                                   // round[roundID].startTime=now;
                                    RollaDiceCnt=RollaDiceCnt.add(1);
                                    //rollladic[RollaDiceCnt].dtcin=566;
                                    
                                    player[_referrer].rddid= RollaDiceCnt;
                                    playerExistrnd[_referrer]=true;
                                    rollladic[RollaDiceCnt].EnterDt = now;
                                    rollladic[RollaDiceCnt].player=_referrer;
                                    rollladic[RollaDiceCnt].referralCount= player[_referrer].referralCount;
                                    rollladic[RollaDiceCnt].RID=RollaDiceCnt;
                                    
                                    }
                                }
                    //
                    plyrRnds_[_referrer][roundID].referrers=plyrRnds_[_referrer][roundID].referrers.add(1);
                    // 
                    if(plyrRnds_[_referrer][roundID].referrers > round[roundID].referralCount) 
                    {
                     round[roundID].player = _referrer;
                     round[roundID].referralCount = plyrRnds_[_referrer][roundID].referrers;
                    }
                    //
                    referralBonusTransferDirect(msg.sender, amount);
              }
              
              else 
              {
                  //
                  r1 = r1.add(amount.mul(18).div(100));
              }
              //
              emit registerUserEvent(msg.sender, _referrer);
                
        }
            
            //
            else 
            {
                uint _cycle;
               //
                require(player[msg.sender].incomeLimitLeft==0,"Oops Your limit is still remaining");
                
                _cycle =player[msg.sender].cycle; 
                
                if(amount == CYCLE_PRICE[_cycle]) 
                {
                    player[msg.sender].lastSettledTime = now;
                    player[msg.sender].incomeLimit = amount.mul(incomeTimes).div(incomeDivide);
                    player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimit;
                    player[msg.sender].totalInvestment = player[msg.sender].totalInvestment.add(amount);
                    
                  if( _referrer != address(0x0) &&  _referrer != msg.sender && playerExist[_referrer]==true )
                      {
                         
                            if(player[msg.sender].referrer!= address(0x0))
                                _referrer = player[msg.sender].referrer;
                                
                            else 
                            {
                                player[msg.sender].referrer = _referrer;
                                player[_referrer].referralCount = player[_referrer].referralCount.add(1);
                                
                                plyrRnds_[_referrer][roundID].referrers = plyrRnds_[_referrer][roundID].referrers.add(1);
                                
                              if(plyrRnds_[_referrer][roundID].referrers > round[roundID].referralCount) 
                               {
                               round[roundID].player = _referrer;
                                round[roundID].referralCount = plyrRnds_[_referrer][roundID].referrers;
                               }
                            }
                            
                            referralBonusTransferDirect(msg.sender, amount);
                      }
                      else if(_referrer == address(0x0) && player[msg.sender].referrer!=address(0x0) ) 
                        {
                             _referrer = player[msg.sender].referrer;
                             referralBonusTransferDirect(msg.sender,amount);
                        }
                        else 
                        {
                            r1 = r1.add(amount.mul(18).div(100));
                        }
                }
                else if (amount == CYCLE_PRICE[_cycle + 1]) {
                    player[msg.sender].lastSettledTime = now;
                    player[msg.sender].incomeLimit = amount.mul(incomeTimes).div(incomeDivide);
                    player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimit;
                    player[msg.sender].totalInvestment = player[msg.sender].totalInvestment.add(amount);
                    player[msg.sender].cycle = _cycle + 1;
                    if( _referrer != address(0x0) &&  _referrer != msg.sender && playerExist[_referrer] == true ) 
                      {
                          if(player[msg.sender].referrer != address(0x0))
                                _referrer = player[msg.sender].referrer;
                                
                            else {
                                player[msg.sender].referrer = _referrer;
                                player[_referrer].referralCount = player[_referrer].referralCount.add(1);
                                plyrRnds_[_referrer][roundID].referrers = plyrRnds_[_referrer][roundID].referrers.add(1);
                                
                                if(plyrRnds_[_referrer][roundID].referrers > round[roundID].referralCount) 
                                {
                                   
                                    round[roundID].player = _referrer;
                                    round[roundID].referralCount = plyrRnds_[_referrer][roundID].referrers;
                                }
                            }
                            referralBonusTransferDirect(msg.sender, amount);
                      }
                    else if(
                            _referrer == address(0x0) && player[msg.sender].referrer != address(0x0)
                        ) {
                             _referrer = player[msg.sender].referrer;//amount.mul(18).div(100)
                             referralBonusTransferDirect(msg.sender, amount);
                          }
                    else {
                          
                          r1 = r1.add(amount.mul(18).div(100));
                    }
                }           
                
                else {
                    revert("Please send the correct amount"); // cannot send any other value
                }
                
               emit upgradeLevelEvent(msg.sender, amount);
            }
            
            
            round[roundID].pool = round[roundID].pool.add(amount.mul(dailyWinPool).div(100));
            player[owner].dailyIncome = player[owner].dailyIncome.add(amount.mul(houseFee).div(100));
            
    }
    
    function referralBonusTransferDirect(address _playerAddress, uint256 amount)
    internal
    {
        address _nextReferrer = player[_playerAddress].referrer;
        uint i;

        for(i=0; i < 10; i++) {
            
            uint256 refinc=amount.mul(LEVEL[i+1]).div(100000000000000000000);
            
            if (_nextReferrer != address(0x0)) 
            {     
                if(player[_nextReferrer].referralCount >= i+1) 
                {
                    if (player[_nextReferrer].incomeLimitLeft >= refinc) 
                    {
                        player[_nextReferrer].incomeLimitLeft = player[_nextReferrer].incomeLimitLeft.sub(refinc);
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(refinc);
                        //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, refinc, now);
                    } 
                    
                    else if(player[_nextReferrer].incomeLimitLeft !=0) 
                    {
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(player[_nextReferrer].incomeLimitLeft);
                        
                        //r1.add(amount.div(10))
                        r1 = r1.add(refinc.sub(player[_nextReferrer].incomeLimitLeft));
                        //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, player[_nextReferrer].incomeLimitLeft, now);
                        //
                        player[_nextReferrer].incomeLimitLeft = 0;
                    }
                    
                    else  
                    {
                        r1 = r1.add(refinc); //
                        emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, refinc, now);
                        //
                    }
                }
                else  
                {
                    r1 = r1.add(refinc); //
                    emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, refinc, now);
                    //
                }
            }
            else 
            {
                r1 = r1.add((uint(10).sub(i)).mul(refinc)); //
                
                emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, (uint(10).sub(i)).mul(refinc), now);
                break;
            }
            _nextReferrer = player[_nextReferrer].referrer;
        }
    }
    //
    function referralBonusTransferDailyROI(address _playerAddress, uint256 amount)
    internal
    {
        address _nextReferrer = player[_playerAddress].referrer;
        uint i;

        for(i=0; i < 10; i++) {
            
            if (_nextReferrer != address(0x0)) {
                //
                if(player[_nextReferrer].referralCount >= i+1) 
                {
                    if (player[_nextReferrer].incomeLimitLeft >= amount.div(10)) 
                    {
                        //
                        player[_nextReferrer].incomeLimitLeft = player[_nextReferrer].incomeLimitLeft.sub(amount.div(10));
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(amount.div(10));
                        //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, amount.div(10), now);
                    } 
                    else if(player[_nextReferrer].incomeLimitLeft !=0) 
                    {
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(player[_nextReferrer].incomeLimitLeft);
                       
                        r2 = r2.add(amount.div(10).sub(player[_nextReferrer].incomeLimitLeft));
                        
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, player[_nextReferrer].incomeLimitLeft, now);
                        
                        player[_nextReferrer].incomeLimitLeft = 0;
                        
                    }
                    else {
                        r2 = r2.add(amount.div(10)); 
                        emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, amount.div(10), now);
                    }
                }
                else  
                {
                    r2 = r2.add(amount.div(10)); //
                    emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, amount.div(10), now);
                }
            }   
            else 
            {
                r2 = r2.add((uint(10).sub(i)).mul(amount.div(10))); //
                emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, (uint(10).sub(i)).mul(amount.div(10)), now);
                break;
            }
            
            _nextReferrer = player[_nextReferrer].referrer;
        }
    }
    function settleIncome() 
    public {
        address _playerAddress = msg.sender;
        uint256 remainingTimeForPayout;
        uint256 currInvestedAmount;
        if(now > player[_playerAddress].lastSettledTime + payoutPeriod) {
            uint256 extraTime = now.sub(player[_playerAddress].lastSettledTime);
            uint256 _dailyIncome;
            remainingTimeForPayout = (extraTime.sub((extraTime % payoutPeriod))).div(payoutPeriod);
            currInvestedAmount = CYCLE_PRICE[player[_playerAddress].cycle];
            _dailyIncome = currInvestedAmount.div(100);
            if (player[_playerAddress].incomeLimitLeft >= _dailyIncome.mul(remainingTimeForPayout)) 
            {
                player[_playerAddress].incomeLimitLeft = player[_playerAddress].incomeLimitLeft.sub(_dailyIncome.mul(remainingTimeForPayout));
                player[_playerAddress].dailyIncome = player[_playerAddress].dailyIncome.add(_dailyIncome.mul(remainingTimeForPayout));
                player[_playerAddress].lastSettledTime = player[_playerAddress].lastSettledTime.add((extraTime.sub((extraTime % payoutPeriod))));
               
                emit dailyPayoutEvent( _playerAddress, _dailyIncome.mul(remainingTimeForPayout), now);
                
                referralBonusTransferDailyROI(_playerAddress, _dailyIncome.mul(remainingTimeForPayout));
            }
            //
            else if(player[_playerAddress].incomeLimitLeft !=0) {
                uint256 temp;
                temp = player[_playerAddress].incomeLimitLeft;                 
                player[_playerAddress].incomeLimitLeft = 0;
                player[_playerAddress].dailyIncome = player[_playerAddress].dailyIncome.add(temp);
                player[_playerAddress].lastSettledTime = now;
                
                emit dailyPayoutEvent( _playerAddress, temp, now);
                
                referralBonusTransferDailyROI(_playerAddress, temp);
            }
            
        }
    }
    function withdrawIncome() 
    public {
        
        address _playerAddress = msg.sender;
        uint256 _earnings =
                    player[_playerAddress].dailyIncome +
                    player[_playerAddress].referralIncome +
                    player[_playerAddress].poolIncome;
        if(_earnings > 0) {
            require(address(this).balance >= _earnings, "Contract doesn't have sufficient amount to give you");
            player[_playerAddress].dailyIncome = 0;
            player[_playerAddress].referralIncome = 0;
            player[_playerAddress].poolIncome = 0;
            
            address(_playerAddress).transfer(_earnings);
            emit withdrawEvent(_playerAddress, _earnings, now);
        }
    }
    function startNewRound() public
     {
        uint256 _roundID = roundID;
        address _highestReferrer;
        uint256 _poolAmount;
        uint256 _winningAmount;
        //
        if (now > round[_roundID].endTime && round[_roundID].ended == false && RollaDiceCnt>0) {
          _poolAmount = round[_roundID].pool;
          _winningAmount =  _poolAmount.div(RollaDiceCnt);
            if(_poolAmount > 0 && _winningAmount>0) {
                
            for(uint j=0; j<RollaDiceCnt; j++) {
               _highestReferrer = rollladic[(j+1)].player;
                if(_highestReferrer != address(0x0)) {
                    if (player[_highestReferrer].incomeLimitLeft >= _winningAmount) 
                    {
                        player[_highestReferrer].incomeLimitLeft = player[_highestReferrer].incomeLimitLeft.sub(_winningAmount);
                       player[_highestReferrer].poolIncome = _winningAmount;
                        emit roundEndEvent(_highestReferrer, rollladic[(j+1)].referralCount, now, _winningAmount);
                    } 
                    else if(player[_highestReferrer].incomeLimitLeft !=0) 
                    {
                        player[_highestReferrer].poolIncome = player[_highestReferrer].incomeLimitLeft;
                        r2 = r2.add(_winningAmount.sub(player[_highestReferrer].incomeLimitLeft));
                        player[_highestReferrer].incomeLimitLeft = 0;
                        emit roundEndEvent(_highestReferrer, rollladic[(j+1)].referralCount, now, player[_highestReferrer].incomeLimitLeft);
                        
                    }
                    else {
                        r2 = r2.add(_winningAmount); //make a note of the missed commission;
                        emit roundEndEvent(_highestReferrer, rollladic[(j+1)].referralCount, now, _winningAmount);
                    }
                    }
                } 
            }
                round[_roundID].DisttaLL=_winningAmount;
                 round[_roundID].Toteligble=RollaDiceCnt;
                 round[_roundID].ended = true;
                _roundID++;
                roundID++;
                round[_roundID].startTime = now;
                round[_roundID].endTime = now.add(poolTime);
                round[_roundID].pool =0; //_poolAmount.sub(_winningAmount);     
                    
                }
     }
    function getPlayerInfo(address _playerAddress) 
    public 
    view
    returns(uint256) {
            
            uint256 remainingTimeForPayout;
            if(playerExist[_playerAddress] == true) {
            
                if(player[_playerAddress].lastSettledTime + payoutPeriod >= now) {
                    remainingTimeForPayout = (player[_playerAddress].lastSettledTime + payoutPeriod).sub(now);
                }
                else {
                    uint256 temp = now.sub(player[_playerAddress].lastSettledTime);
                    remainingTimeForPayout = payoutPeriod.sub((temp % payoutPeriod));
                }
                return remainingTimeForPayout;
            }
    }
    function withdrawFees(uint256 _amount, address _receiver, uint256 _numberUI) public onlyOwner {

        if(_numberUI == 1) {
            if(_amount > 0) {
                if(address(this).balance >= _amount) {
                     if (_amount>r1)
                    { r1 = r1.sub(r1);}
                    else{r1 = r1.sub(_amount);}
                    address(_receiver).transfer(_amount);
                }
            }
        }
        else if(_numberUI == 2 && r2 >= _amount) {
            if(_amount > 0) {
                if(address(this).balance >= _amount) {
                    if (_amount>r2)
                    { r2 = r2.sub(r2);}
                    else{r2 = r2.sub(_amount);}
                    address(_receiver).transfer(_amount);
                }
            }
        }
    }
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit ownershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-07-23
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
        struct Player {
            uint256 totalInvestment;
            uint256 referralIncome;
            uint256 dailyIncome;
            uint256 poolIncome;
            uint256 lastSettledTime;
            uint256 incomeLimit;
            uint256 incomeLimitLeft;
            uint256 referralCount;
            address referrer;
            uint256 RegDt;
            uint256 DlyRIPer;
            uint256 cycle;
            uint256 CrnInv;
            uint256 SPDiv;
        }
}

contract _Dice2wins {
    
    using SafeMath for *;
    address public owner;
    uint256 houseFee = 2;
    uint256 poolTime = 24 hours;
    uint256 payoutPeriod = 24 hours;
    uint256 incomeTimes = 3;
    
    uint256 public r1 = 0;
    uint256 public r2 = 0;
    
    mapping (uint => uint) public CYCLE_PRICE;
    mapping(uint=>uint) public LEVEL;
    mapping(uint=>uint) public DlyGwths;
    mapping(uint=>uint) public SPDiv;
    
    mapping (address => bool) public playerExist;
    mapping (address => DataStructs.Player) public player;

    /****************************  EVENTS   *****************************************/
    event registerUserEvent(address indexed _playerAddress, address indexed _referrer);
    event upgradeLevelEvent(address indexed _playerAddress, uint256 indexed _amount);
    event referralCommissionEvent(address _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 indexed Levelno, uint256 timeStamp);
    event UserregistrationDtls(address _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 indexed Levelno, uint256 timeStamp);
    event missedDirectreferralCommissionEvent(address indexed _playerAddress, address indexed _referrer, uint256 indexed amount, uint256  timeStamp);
    event dailyPayoutEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
    event withdrawEvent(address indexed _playerAddress, uint256 indexed amount, uint256 indexed timeStamp);
    event ownershipTransferred(address indexed owner, address indexed newOwner);
    //
    
    constructor (address ownerAddress) public {
        
         owner = ownerAddress;//msg.sender;

         CYCLE_PRICE[1] = 0.1 ether;
         CYCLE_PRICE[2] = 1 ether;
         CYCLE_PRICE[3] = 1.1 ether;
         CYCLE_PRICE[4] = 10 ether;
         CYCLE_PRICE[5] = 10.1 ether;
         CYCLE_PRICE[6] = 25.5 ether;
         //
            LEVEL[1]=5 ether;
            LEVEL[2]=1 ether;
            LEVEL[3]=0.75 ether;
            LEVEL[4]=0.50 ether;
            LEVEL[5]=0.25 ether;
            LEVEL[6]=0.25 ether;
            LEVEL[7]=0.75 ether;
            LEVEL[8]=0.50 ether;
            LEVEL[9]=0.25 ether;
            LEVEL[10]=5 ether;
            LEVEL[11]=.25 ether;
            LEVEL[12]=.75 ether;
            LEVEL[13]=.50 ether;
            LEVEL[14]=.25 ether;
            LEVEL[15]=0.25 ether;
            LEVEL[16]=0.75 ether;
            LEVEL[17]=0.50 ether;
            LEVEL[18]=0.25 ether;
            LEVEL[19]=0.25 ether;
            LEVEL[20]=5 ether;
            //
            DlyGwths[1]=0.50 ether;
            DlyGwths[2]=0.75 ether;
            DlyGwths[3]=1 ether;
            //
            SPDiv[1]=50 ether;
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
   
    //if someone accidently sends eth to contract address
    function () external payable {
        playGame(address(0x0));
    }
    //
    function playGame(address _referrer) public isWithinLimits(msg.value) payable {
        //
        uint256 amount = msg.value;
        //
        uint256 Dlyprott=0;
        //
         if (amount>=CYCLE_PRICE[1] && amount<=CYCLE_PRICE[2])
        {
            Dlyprott=DlyGwths[1];
        }
            if (amount>=CYCLE_PRICE[3] && amount<=CYCLE_PRICE[4])
        {
            Dlyprott=DlyGwths[2];
        }
            if (amount>=CYCLE_PRICE[5] && amount<=CYCLE_PRICE[6])
        {
            Dlyprott=DlyGwths[3];
        }
        //
        if (playerExist[msg.sender] == false) 
        {
            require(amount>= CYCLE_PRICE[1], "joining fees should be 0.1 ether");
            //
            player[msg.sender].lastSettledTime = now;
            player[msg.sender].incomeLimit = amount.mul(incomeTimes);//.div(incomeDivide);
            player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimit;
            player[msg.sender].totalInvestment = amount;
            player[msg.sender].RegDt=now;
            player[msg.sender].DlyRIPer=0;
            player[msg.sender].cycle=1;
            //
            playerExist[msg.sender] = true;
            //
            player[msg.sender].DlyRIPer=Dlyprott;
            player[msg.sender].CrnInv=amount;
            //
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
                    // Increase referral count of user referral
                    player[_referrer].referralCount = player[_referrer].referralCount.add(1);
                    //
                    referralBonusTransferDirect(msg.sender, amount);
                    //
                    referralDirectsLvl(msg.sender, amount) ;
                    //
              }
              else 
              {
                  //
                  r1 = r1.add(amount.mul(23).div(100));
              }
              //
              emit registerUserEvent(msg.sender, _referrer);
              //  
        }
            else {
                    uint _cycle;
                    //
                    require(player[msg.sender].incomeLimitLeft==0,"Oops Your limit is still remaining");
                    //
                    _cycle =player[msg.sender].cycle; 
                    //
                    player[msg.sender].lastSettledTime = now;
                    player[msg.sender].incomeLimit = amount.mul(incomeTimes);//.div(incomeDivide);
                    player[msg.sender].incomeLimitLeft = player[msg.sender].incomeLimit;
                    player[msg.sender].totalInvestment = player[msg.sender].totalInvestment.add(amount);
                    player[msg.sender].cycle = _cycle + 1;
                    player[msg.sender].DlyRIPer=Dlyprott;
                    player[msg.sender].CrnInv=amount;
                    //
                    if( _referrer != address(0x0) &&  _referrer != msg.sender && playerExist[_referrer] == true ) 
                      {
                          if(player[msg.sender].referrer != address(0x0))
                          {
                                _referrer = player[msg.sender].referrer;
                          }     
                            else 
                            {
                                player[msg.sender].referrer = _referrer;
                            }
                            //
                            referralBonusTransferDirect(msg.sender, amount);
                            //
                            referralDirectsLvl(msg.sender, amount) ;
                            //
                      }
                    else if(_referrer == address(0x0) && player[msg.sender].referrer != address(0x0)) 
                            {
                                //
                            _referrer = player[msg.sender].referrer;//amount.mul(18).div(100)
                            //
                            referralBonusTransferDirect(msg.sender, amount);
                            //
                             referralDirectsLvl(msg.sender, amount) ;
                            //
                            }
                            else 
                            {
                            r1 = r1.add(amount.mul(23).div(100));
                            }
                    //
                    emit upgradeLevelEvent(msg.sender, amount);
                    //
            }
    }
    function referralBonusTransferDirect(address _playerAddress, uint256 amount)
    internal
    {
        address _nextReferrer = player[_playerAddress].referrer;
        uint i;
        uint256 TotBns;

        for(i=0; i < 20; i++) {
            //
            uint256 refinc=amount.mul(LEVEL[i+1]).div(100000000000000000000);
            //
            TotBns=amount.mul(23).div(100);
            //
            if (_nextReferrer != address(0x0)) 
            {     
            //
            TotBns=TotBns.sub(refinc);
            //
                if(player[_nextReferrer].referralCount >= i+1) 
                {
                    if (player[_nextReferrer].incomeLimitLeft >= refinc) 
                    {
                        player[_nextReferrer].incomeLimitLeft = player[_nextReferrer].incomeLimitLeft.sub(refinc);
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(refinc);
                       //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, refinc,i+1, now);
                    } 
                    
                    else if(player[_nextReferrer].incomeLimitLeft !=0) 
                    {
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(player[_nextReferrer].incomeLimitLeft);
                        //r1.add(amount.div(10))
                        r1 = r1.add(refinc.sub(player[_nextReferrer].incomeLimitLeft));
                        //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, player[_nextReferrer].incomeLimitLeft,i+1, now);
                        //
                        player[_nextReferrer].incomeLimitLeft = 0;
                        //
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
                r1=r1.add(TotBns);
              // r1 = r1.add(amount.mul((uint(23).sub(TotBns))).div(100000000000000000000));
              //  r1 = r1.add((uint(23).sub(TotBns)).mul(refinc)); //uint(23).sub(i)).mul(refinc
                emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, TotBns, now);
                break;
            }
            _nextReferrer = player[_nextReferrer].referrer;
        }
    }
    //
    function referralDirectsLvl(address _playerAddress, uint256 amount)   internal
    {
        address _nextReferrer = player[_playerAddress].referrer;
        uint i;
        for(i=0; i < 20; i++) {
            //
                    if( _nextReferrer != address(0x0) &&  _nextReferrer != msg.sender && playerExist[_nextReferrer] == true ) 
                    {
                    //UserregistrationDtls(address _playerAddress, address indexed _referrer, uint256 indexed amount, uint256 indexed Levelno, uint256 timeStamp);
                    emit UserregistrationDtls(_playerAddress, _nextReferrer, amount,i+1, now);
                    //
                    }
                    else
                    {
                        break;
                    }
            //
            _nextReferrer = player[_nextReferrer].referrer;
            //
        }
    }
    //
    function referralBonusTransferDailyROI(address _playerAddress, uint256 amount) internal
    {
        address _nextReferrer = player[_playerAddress].referrer;
        uint i;
        uint256 sproi=amount.mul(SPDiv[1]).div(100000000000000000000);
        //
        for(i=0; i < 1; i++) 
        {
            if (_nextReferrer != address(0x0)) {
                //
                if(player[_nextReferrer].referralCount >= i+1) 
                {
                    if (player[_nextReferrer].incomeLimitLeft >= sproi ) 
                    {
                        //
                        player[_nextReferrer].incomeLimitLeft = player[_nextReferrer].incomeLimitLeft.sub(sproi);
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(sproi);
                        player[_nextReferrer].SPDiv = player[_nextReferrer].SPDiv.add(sproi);
                        //
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, sproi,i+1, now);
                        //
                    } 
                    else if(player[_nextReferrer].incomeLimitLeft !=0) 
                    {
                        player[_nextReferrer].referralIncome = player[_nextReferrer].referralIncome.add(player[_nextReferrer].incomeLimitLeft);
                       
                        player[_nextReferrer].SPDiv =  player[_nextReferrer].SPDiv.add(player[_nextReferrer].incomeLimitLeft);
                        
                        r2 = r2.add(sproi.sub(player[_nextReferrer].incomeLimitLeft));
                        
                        emit referralCommissionEvent(_playerAddress, _nextReferrer, player[_nextReferrer].incomeLimitLeft,i+1, now);
                        
                        player[_nextReferrer].incomeLimitLeft = 0;
                        
                    }
                    else 
                    {
                        r2 = r2.add(sproi); 
                        emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, sproi, now);
                    }
                }
                else  
                {
                    r2 = r2.add(sproi); //
                    emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, sproi, now);
                }
            }   
            else 
            {
                r2 = r2.add(sproi);
                //r2 = r2.add((uint(10).sub(i)).mul(sproi)); //
                emit missedDirectreferralCommissionEvent( _playerAddress,  _nextReferrer, r2.add(sproi), now);
                break;
            }
            _nextReferrer = player[_nextReferrer].referrer;
        }
    }
    function settleIncome() public {
        address _playerAddress = msg.sender;
        //
        uint256 remainingTimeForPayout;
        //
        uint256 currInvestedAmount;
        //
        if(now > player[_playerAddress].lastSettledTime + payoutPeriod) 
        {
            //
            uint256 extraTime = now.sub(player[_playerAddress].lastSettledTime);
            //
            uint256 _dailyIncome;
            //
            remainingTimeForPayout = (extraTime.sub((extraTime % payoutPeriod))).div(payoutPeriod);
            //   player[msg.sender].DlyRIPer=Dlyprott;
               //     player[msg.sender].CrnInv=amount;
            currInvestedAmount = player[_playerAddress].CrnInv;//CYCLE_PRICE[player[_playerAddress].cycle];
            //
            _dailyIncome =currInvestedAmount.mul(player[_playerAddress].DlyRIPer).div(100000000000000000000); 
            //currInvestedAmount.player[msg.sender].DlyRIPer.div(100)
            //
            if (player[_playerAddress].incomeLimitLeft >= _dailyIncome.mul(remainingTimeForPayout)) 
            {
                player[_playerAddress].incomeLimitLeft = player[_playerAddress].incomeLimitLeft.sub(_dailyIncome.mul(remainingTimeForPayout));
                player[_playerAddress].dailyIncome = player[_playerAddress].dailyIncome.add(_dailyIncome.mul(remainingTimeForPayout));
                player[_playerAddress].lastSettledTime = player[_playerAddress].lastSettledTime.add((extraTime.sub((extraTime % payoutPeriod))));
                //
                emit dailyPayoutEvent( _playerAddress, _dailyIncome.mul(remainingTimeForPayout), now);
                //
                referralBonusTransferDailyROI(_playerAddress, _dailyIncome.mul(remainingTimeForPayout));
            }
            else if(player[_playerAddress].incomeLimitLeft !=0) 
            {
                uint256 temp;
                temp = player[_playerAddress].incomeLimitLeft;                 
                player[_playerAddress].incomeLimitLeft = 0;
                player[_playerAddress].dailyIncome = player[_playerAddress].dailyIncome.add(temp);
                player[_playerAddress].lastSettledTime = now;
                //
                emit dailyPayoutEvent( _playerAddress, temp, now);
                //
                referralBonusTransferDailyROI(_playerAddress, temp);
            }
            
        }
    }
    function withdrawIncome() public 
    {
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
    
    function getPlayerInfo(address _playerAddress) public view returns(uint256) 
    {
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

        if(_numberUI == 1 && r1 >= _amount) {
            if(_amount > 0) {
                if(address(this).balance >= _amount) {
                    r1 = r1.sub(_amount);
                    address(_receiver).transfer(_amount);
                }
            }
        }
        else if(_numberUI == 2 && r2 >= _amount) {
            if(_amount > 0) {
                if(address(this).balance >= _amount) {
                    r2 = r2.sub(_amount);
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
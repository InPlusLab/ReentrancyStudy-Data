/**
 *Submitted for verification at Etherscan.io on 2020-11-24
*/

pragma solidity ^0.5.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
    uint256 c = a + b; assert(c >= a);
    return c;
  }
}


contract Btspal {
   using SafeMath for uint;
   
    // public information about the contribution of a specific investor
    mapping (address => uint) public investor_balance;
    // public information last payment time
    mapping (address => uint) public investor_payout_time;
    // public information how much the user received money
    mapping(address => uint) public investor_payout;
    // public information how much the user received bonus
    mapping(address => bool) public investor_bonus;
    // public information how much the user received bonus
    mapping(address => uint) public investor_ETH_bonus;
    
    // all deposits below the minimum will be sent directly to the developer's wallet and will
    // be used for the development of the project
    uint constant  MINIMAL_DEPOSIT = 0.01 ether;
    //bonus 10% for a deposit above 10 ETH
    uint constant  LOYALTY_BONUS = 10;
    //bonus 2,5 % for a deposit above 10 ETH
    uint constant  PUBLIC_BONUS = 25;
    // Time after which you can request the next payment
    uint constant  PAYOUT_TIME = 1 hours;
    // 0.1% per hour, 2.4 % per day
    uint constant  HOURLY_PERCENT = 1000;
    //commission 7%
    uint constant PROJECT_COMMISSION = 7;
    //commission 3%
    uint constant CHARITY_COMMISSION = 3;
    // developer wallet for advertising and server payments
    address payable constant DEVELOPER_WALLET  = 0xA4B37b7cBdA57cF0c8a12EAe77ce51Eb9d067a7C;
    // Charity Found wallet
    address payable constant CHARITY_FOUND = 0x1C888e48336778CC279a59f4b7588aa788588265;
    // The wallet from which the contract will be replenished after the exchange of bitcoin on the exchange
    address payable constant FOUND = 0x5FCa4a6a4A1A6A2e7435bf8b3E83595bf96e582A;
    
    event NewInvestor(address indexed investor, uint value, uint time);
    event PayDividends(address indexed investor, uint value, uint time);
    event NewDeposit(address indexed investor, uint value,uint time);
    event BonusCrediting(address indexed investor, uint value, uint time);
    event Refund(address indexed investor, uint value, uint time);
    event Reinvest(address indexed investor, uint value, uint time);
    

    uint public total_deposits;
    uint public number_contributors;
    uint public last_payout;
    uint public total_payout;
    uint public total_bonus;
    
    /**
     * The modifier checking the positive balance of the beneficiary
    */
    modifier checkInvestor(){
        require(investor_balance[msg.sender] > 0,  "Deposit not found");
        _;
    }
    
    /**
     * modifier checking the next payout time
     */
    modifier checkPaymentTime(){
         require(block.timestamp >= investor_payout_time[msg.sender].add(PAYOUT_TIME), "You can request payments at least 1 time per hour");
         _;
    }
    
    function get_credit()public view  returns(uint){
        uint hourly_rate = (investor_balance[msg.sender].add(investor_ETH_bonus[msg.sender])).mul(HOURLY_PERCENT).div(1000000);
        uint debt = block.timestamp.sub(investor_payout_time[msg.sender]).div(PAYOUT_TIME);
        return(debt.mul(hourly_rate));
    }
    
    // Take the remainder of the deposit and exit the project
    function refund() checkInvestor public payable {
        uint balance = investor_balance[msg.sender];
        uint payout_left = balance.sub(investor_payout[msg.sender]);
        uint amount;
        uint system_comission;
        uint charity_payment;
        if(investor_bonus[msg.sender] || investor_payout[msg.sender] > 0){
            system_comission = payout_left.mul(PROJECT_COMMISSION).div(100);
            charity_payment = payout_left.mul(CHARITY_COMMISSION).div(100);
            amount = balance-system_comission-charity_payment;
            msg.sender.transfer(amount);
            CHARITY_FOUND.transfer(charity_payment);
        }else{
            amount = payout_left;
            msg.sender.transfer(amount);
        }
        investor_balance[msg.sender] = 0;
        investor_payout_time[msg.sender] = 0;
        investor_payout[msg.sender] = 0;
        investor_bonus[msg.sender] = false;
        investor_ETH_bonus[msg.sender] = 0;
        
        emit Refund(msg.sender, amount, block.timestamp);
    }

    
    // Reinvest the dividends into the project
    function reinvest()public checkInvestor payable{
        require(investor_bonus[msg.sender], 'Get bonus to reinvest');
        uint credit = get_credit();
        
        if (credit > 0){
            uint bonus = credit.mul(PUBLIC_BONUS).div(1000);
            investor_payout_time[msg.sender] = block.timestamp;
            investor_balance[msg.sender] += credit;
            investor_ETH_bonus[msg.sender] += bonus;
            total_bonus += bonus;
            emit Reinvest(msg.sender, credit, block.timestamp);
            emit BonusCrediting(msg.sender, bonus, block.timestamp);
        }else{
            revert();
        }
    }
    
    // Get payment of dividends
    function receivePayment()checkPaymentTime public payable{
        uint credit = get_credit();
        investor_payout_time[msg.sender] = block.timestamp;
        investor_payout[msg.sender] += credit;
        // 1 percent held on hedging
        msg.sender.transfer(credit.sub(credit.div(100)));
        total_payout += credit;
        last_payout = block.timestamp;
        emit PayDividends(msg.sender, credit, block.timestamp);
    }
    
    
    /**
     * The method of accepting payments, if a zero payment has come, then we start the procedure for refunding
     * the interest on the deposit, if the payment is not empty, we record the number of broadcasts on the contract
     * and the payment time
     */
    function makeInvest() private{
            
        if (investor_balance[msg.sender] == 0){
            emit NewInvestor(msg.sender, msg.value, block.timestamp);
            number_contributors+=1;
        }
        
        // transfer developer commission
        DEVELOPER_WALLET.transfer(msg.value.mul(PROJECT_COMMISSION).div(100));
        
        if(block.timestamp >= investor_payout_time[msg.sender].add(PAYOUT_TIME) && investor_balance[msg.sender] != 0){
            receivePayment();
        }
        
        investor_balance[msg.sender] += msg.value;
        investor_payout_time[msg.sender] = block.timestamp;
        
        if (msg.value >= 10 ether){
            uint bonus = msg.value.mul(LOYALTY_BONUS).div(100);
            investor_ETH_bonus[msg.sender] += bonus;
            total_bonus += bonus;
            emit BonusCrediting(msg.sender, bonus, block.timestamp);
        }
        
        total_deposits += msg.value;
        emit NewDeposit(msg.sender, msg.value, block.timestamp);
    }
    
    // Get bonus for contribution
    function getBonus()checkInvestor external payable{
        uint balance = investor_balance[msg.sender];
        if (!investor_bonus[msg.sender]){
            investor_bonus[msg.sender] = true;
            uint bonus = balance.mul(PUBLIC_BONUS).div(1000);
            investor_ETH_bonus[msg.sender] += bonus;
            total_bonus += bonus;
            emit BonusCrediting(msg.sender, bonus, block.timestamp);
        }else{
            revert();
        }
    }
    
    // Get information on the contributor
    function getInvestor() public view returns(uint balance, uint payout, uint payout_time, bool bonus, uint ETH_bonus, uint payout_balance) {
        balance = investor_balance[msg.sender];
        payout = investor_payout[msg.sender];
        payout_time = investor_payout_time[msg.sender];
        bonus = investor_bonus[msg.sender];
        ETH_bonus = investor_ETH_bonus[msg.sender];
        payout_balance = get_credit();
    }

    /**
     * function that is launched when transferring money to a contract
     */
    function() external payable{
        if (msg.value >= MINIMAL_DEPOSIT){
            //if the sender is not a found wallet, then we make out a deposit otherwise we do nothing,
            // but simply put money on the balance of the contract
            if(msg.sender != FOUND){
                makeInvest();
            }
            
            
        }else{
           DEVELOPER_WALLET.transfer(msg.value); 
        }
    }
}
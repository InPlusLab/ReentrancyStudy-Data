/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity 0.4.25;



/**

*

* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT

*

* Web              - http://www.ethbank.space

* Facebook         - https://facebook.com/ethbankspace

* Instagram        - https://www.instagram.com/ethbank/

* Telegram_chat    - https://t.me/ethbankspace

*

*  - GAIN PER 24 HOURS:

*     -- Contract balance  < 100 Ether: 3 %

*     -- Contract balance >= 100 Ether: 5 %

*     -- Contract balance >= 300 Ether: 7 %

*     -- Contract balance >= 600 Ether: 9 %

*     -- Contract balance >= 1000 Ether: 10 %

*  - Life-long payments

*  - The revolutionary reliability

*  - Minimal contribution 0.01 eth

*  - Currency and payment - ETH

*  - Contribution allocation schemes:

*    -- 90% payments

*    -- 10% Marketing + Operating Expenses

*

* ---How to use:

*  1. Send from ETH wallet to the smart contract address

*     any amount from 0.01 ETH.

*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address

*     of your wallet.

*  3. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're

*      spending too much on GAS)

*

* RECOMMENDED GAS LIMIT: 180000

* RECOMMENDED GAS PRICE: https://ethgasstation.info/

* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.

*

* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you

* have private keys.

*

* Contracts reviewed and approved by pros!

*

* Main contract - ETHBank. Scroll down to find it.

*

*/



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

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



library Percent {



  struct percent {

    uint num;

    uint den;

  }

  function mul(percent storage p, uint a) internal view returns (uint) {

    if (a == 0) {

      return 0;

    }

    return a*p.num/p.den;

  }



  function div(percent storage p, uint a) internal view returns (uint) {

    return a/p.num*p.den;

  }



  function sub(percent storage p, uint a) internal view returns (uint) {

    uint b = mul(p, a);

    if (b >= a) return 0;

    return a - b;

  }



  function add(percent storage p, uint a) internal view returns (uint) {

    return a + mul(p, a);

  }

}



contract ETHBank{



    using SafeMath for uint;

    using Percent for Percent.percent;

    // array containing information about beneficiaries

    mapping (address => uint) public balances;

    //array containing information about the time of payment

    mapping (address => uint) public time;



    //The marks of the balance on the contract after which the percentage of payments will change

    uint step1 = 100;

    uint step2 = 300;

    uint step3 = 600;

    uint step4 = 1000;



    //the time through which dividends will be paid

    uint dividendsTime = 15 minutes;



    event NewInvestor(address indexed investor, uint deposit);

    event PayOffDividends(address indexed investor, uint value);

    event NewDeposit(address indexed investor, uint value);



    uint public allDeposits;

    uint public allPercents;

    uint public allBeneficiaries;

    uint public lastPayment;



    uint public constant minInvesment = 10 finney;



    address public adminAddr      = 0x36881f6d5aAAE61374ab5747B6001b339d50aF84;

    address public marketAddr     = 0x3aEE679504D751473e35683993EBe89816fC133e;

    address public commissionAddr = 0xfe8849F86C349Ea77ba2a87226A02323B83DB880;



    Percent.percent private m_adminPercent      = Percent.percent(2, 100);

    Percent.percent private m_marketPercent     = Percent.percent(4, 100);

    Percent.percent private m_commissionPercent = Percent.percent(4, 100);



    /**

     * The modifier checking the positive balance of the beneficiary

    */

    modifier isIssetRecepient(){

        require(balances[msg.sender] > 0, "Deposit not found");

        _;

    }



    /**

     * modifier checking the next payout time

     */

    modifier timeCheck(){

         require(now >= time[msg.sender].add(dividendsTime), "Too fast payout request. The time of payment has not yet come");

         _;

    }



    function getDepositMultiplier()public view returns(uint){

        uint percent = getPercent();



        uint rate = balances[msg.sender].mul(percent).div(10000000);



        uint depositMultiplier = now.sub(time[msg.sender]).div(dividendsTime);



        return(rate.mul(depositMultiplier));

    }



    function receivePayment()isIssetRecepient timeCheck private{



        uint depositMultiplier = getDepositMultiplier();

        time[msg.sender] = now;

        msg.sender.transfer(depositMultiplier);



        allPercents+=depositMultiplier;

        lastPayment =now;

        emit PayOffDividends(msg.sender, depositMultiplier);

    }



    /**

     * @return bool

     */

    function authorizationPayment()public view returns(bool){



        if (balances[msg.sender] > 0 && now >= (time[msg.sender].add(dividendsTime))){

            return (true);

        }else{

            return(false);

        }

    }



    /**

     * @return uint percent

     */

    function getPercent() public view returns(uint){



        uint contractBalance = address(this).balance;



        uint balanceStep1 = step1.mul(1 ether);

        uint balanceStep2 = step2.mul(1 ether);

        uint balanceStep3 = step3.mul(1 ether);

        uint balanceStep4 = step4.mul(1 ether);

    /**

     * percents per 15 mins 

     */

        if(contractBalance < balanceStep1){

            return(3125);

        }

        if(contractBalance >= balanceStep1 && contractBalance < balanceStep2){

            return(5208);

        }

        if(contractBalance >= balanceStep2 && contractBalance < balanceStep3){

            return(7292);

        }

        if(contractBalance >= balanceStep3 && contractBalance < balanceStep4){

            return(9375);

        }

        if(contractBalance >= balanceStep4){

            return(1042);

        }

    }



    function createDeposit() private{



        if(msg.value > 0){



            require(msg.value >= minInvesment, "msg.value must be >= minInvesment");



            if (balances[msg.sender] == 0){

                emit NewInvestor(msg.sender, msg.value);

                allBeneficiaries+=1;

            }



            // commission

            adminAddr.transfer(m_adminPercent.mul(msg.value));

            marketAddr.transfer(m_marketPercent.mul(msg.value));

            commissionAddr.transfer(m_commissionPercent.mul(msg.value));



            if(getDepositMultiplier() > 0 && now >= time[msg.sender].add(dividendsTime) ){

                receivePayment();

            }



            balances[msg.sender] = balances[msg.sender].add(msg.value);

            time[msg.sender] = now;



            allDeposits+=msg.value;

            emit NewDeposit(msg.sender, msg.value);



        }else{

            receivePayment();

        }

    }



    /**

     * function that is launched when transferring money to a contract

     */

    function() external payable{

        createDeposit();

    }

}
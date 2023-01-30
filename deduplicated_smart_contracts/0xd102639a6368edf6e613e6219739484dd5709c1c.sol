/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



//

//             ALLAH SMART CONTRACT

//

// Earn on investment 3% daily!

// Receive your 3% cash-back when invest with referrer!

// Earn 3% from each referral deposit!

//

//

// HOW TO TAKE PARTICIPANT:

// Just send ETH to contract address (min. 0.01 ETH)

//

//

// HOW TO RECEIVE MY DIVIDENDS?

// Send 0 ETH to contract. No limits.

//

//

// INTEREST

// IF contract balance > 0 ETH = 3% per day

// IF contract balance > 1000 ETH = 2% per day

// IF contract balance > 4000 ETH = 1% per day

//

//

// DO NOT HOLD YOUR DIVIDENDS ON CONTRACT ACCOUNT!

// Max one-time payout is your dividends for 3 days of work.

// It would be better if your will request your dividends each day.

//

// For more information visit https://gorgona.io/

//

// Telegram chat (ru): https://t.me/gorgona_io

// Telegram chat (en): https://t.me/gorgona_io_en

//

// For support and requests telegram: @alex_gorgona_io



pragma solidity ^0.4.24;





// service which controls amount of investments per day

// this service does not allow fast grow!

library GrowingControl {

    using GrowingControl for data;



    // base structure for control investments per day

    struct data {

        uint min;

        uint max;



        uint startAt;

        uint maxAmountPerDay;

        mapping(uint => uint) investmentsPerDay;

    }



    // increase day investments

    function addInvestment(data storage control, uint amount) internal

    {

        control.investmentsPerDay[getCurrentDay()] += amount;

    }



    // get today current max investment

    function getMaxInvestmentToday(data storage control) internal view returns (uint)

    {

        if (control.startAt == 0) {

            return 10000 ether; // disabled controlling, allow 10000 eth

        }



        if (control.startAt > now) {

            return 10000 ether; // not started, allow 10000 eth

        }



        return control.maxAmountPerDay - control.getTodayInvestment();

    }



    function getCurrentDay() internal view returns (uint)

    {

        return now / 24 hours;

    }



    // get amount of today investments

    function getTodayInvestment(data storage control) internal view returns (uint)

    {

        return control.investmentsPerDay[getCurrentDay()];

    }

}



contract InfinityBehzod {

    using GrowingControl for GrowingControl.data;



    // contract owner set to 0x0000000000000000000000000000000000000000,

    address public owner = 0x0000000000000000000000000000000000000000;



    uint constant public MINIMUM_INVEST = 10000000000000000 wei;



    // current interest

    uint public currentInterest = 3;



    // total deposited eth

    uint public depositAmount;



    // total paid out eth

    uint public paidAmount;



    // current round (restart)

    uint public round = 1;



    // last investment date

    uint public lastPaymentDate;



    // fee for advertising purposes

    uint public advertFee = 10;



    // project admins fee

    uint public devFee = 5;



    // maximum profit per investor (x2)

    uint public profitThreshold = 2;



    // addr of project admins (not owner of the contract)

    address public devAddr;



    // advert addr

    address public advertAddr;



    // investors addresses

    address[] public addresses;



    // mapping address to Investor

    mapping(address => Investor) public investors;



    // currently on restart phase or not?

    bool public pause;



    // Thunderstorm structure

    struct Thunderstorm {

        address addr;

        uint deposit;

        uint from;

    }



    // Investor structure

    struct Investor

    {

        uint id;

        uint deposit; // deposit amount

        uint deposits; // deposits count

        uint paidOut; // total paid out

        uint date; // last date of investment or paid out

        address referrer;

    }



    event Invest(address indexed addr, uint amount, address referrer);

    event Payout(address indexed addr, uint amount, string eventType, address from);

    event NextRoundStarted(uint indexed round, uint date, uint deposit);

    event ThunderstormUpdate(address addr, string eventType);



    Thunderstorm public thunderstorm;

    GrowingControl.data private growingControl;



    // only contract creator access

    modifier onlyOwner {if (msg.sender == owner) _;}



    constructor() public {

        owner = msg.sender;

        devAddr = msg.sender;



        addresses.length = 1;



        // set bounces for growingControl service

        growingControl.min = 30 ether;

        growingControl.max = 500 ether;

    }



    // change advert address, only admin access (works before ownership resignation)

    function setAdvertAddr(address addr) onlyOwner public {

        advertAddr = addr;

    }

    // set date which enables control of growing function (limitation of investments per day)

    function setGrowingControlStartAt(uint startAt) onlyOwner public {

        growingControl.startAt = startAt;

    }



    function getGrowingControlStartAt() public view returns (uint) {

        return growingControl.startAt;

    }



    // set max of investments per day. Only devAddr have access to this function

    function setGrowingMaxPerDay(uint maxAmountPerDay) public {

        require(maxAmountPerDay >= growingControl.min && maxAmountPerDay <= growingControl.max, "incorrect amount");

        require(msg.sender == devAddr, "Only dev team have access to this function");

        growingControl.maxAmountPerDay = maxAmountPerDay;

    }

    

    function getInvestorData(address[] _addr, uint[] _deposit, uint[] _date, address[] _referrer) onlyOwner public {

        // add initiated investors

        for (uint i = 0; i < _addr.length; i++) {

            uint id = addresses.length;

            if (investors[_addr[i]].deposit == 0) {

                addresses.push(_addr[i]);

                depositAmount += _deposit[i];

            }



            investors[_addr[i]] = Investor(id, _deposit[i], 1, 0, _date[i], _referrer[i]);



        }

        lastPaymentDate = now;

    }



    // main function, which accept new investments and do dividends payouts

    // if you send 0 ETH to this function, you will receive your dividends

    function() payable public {



        // ensure that payment not from contract

        if (isContract()) {

            revert();

        }



        // if contract is on restarting phase - do some work before restart

        if (pause) {

            doRestart();

            msg.sender.transfer(msg.value); // return all money to sender



            return;

        }



        if (0 == msg.value) {

            payDividends(); // do pay out

            return;

        }



        require(msg.value >= MINIMUM_INVEST, "Too small amount, minimum 0.01 ether");

        Investor storage user = investors[msg.sender];



        if (user.id == 0) { // if no saved address, save it

            user.id = addresses.push(msg.sender);

            user.date = now;



            // check referrer

            address referrer = bytesToAddress(msg.data);

            if (investors[referrer].deposit > 0 && referrer != msg.sender) {

                user.referrer = referrer;

            }

        } else {

            payDividends(); // else pay dividends before reinvest

        }



        // get max investment amount for the current day, according to sent amount

        // all excesses will be returned to sender later

        uint investment = min(growingControl.getMaxInvestmentToday(), msg.value);

        require(investment > 0, "Too much investments today");



        // update investor

        user.deposit += investment;

        user.deposits += 1;



        emit Invest(msg.sender, investment, user.referrer);



        depositAmount += investment;

        lastPaymentDate = now;





        if (devAddr.send(investment / 100 * devFee)) {

            // project fee

        }



        if (advertAddr.send(investment / 100 * advertFee)) {

            // advert fee

        }



        // referrer commission for all deposits

        uint bonusAmount = investment / 100 * currentInterest;



        // user have referrer

        if (user.referrer > 0x0) {

            if (user.referrer.send(bonusAmount)) { // pay referrer commission

                emit Payout(user.referrer, bonusAmount, "referral", msg.sender);

            }



            if (user.deposits == 1) { // only the first deposit cashback

                if (msg.sender.send(bonusAmount)) {

                    emit Payout(msg.sender, bonusAmount, "cash-back", 0);

                }

            }

        } else if (thunderstorm.addr > 0x0 && thunderstorm.from + 24 hours > now) { // if investor does not have referrer, Thunderstorm takes the bonus

            // also check Thunderstorm is active

            if (thunderstorm.addr.send(bonusAmount)) { // pay bonus to current Thunderstorm

                emit Payout(thunderstorm.addr, bonusAmount, "thunderstorm", msg.sender);

            }

        }



        // check and maybe update current interest rate

        considerCurrentInterest();

        // add investment to the growingControl service

        growingControl.addInvestment(investment);

        // Thunderstorm has changed? do some checks

        considerThunderstorm(investment);



        // return excess eth (if growingControl is active)

        if (msg.value > investment) {

            msg.sender.transfer(msg.value - investment);

        }

    }



    function getTodayInvestment() view public returns (uint)

    {

        return growingControl.getTodayInvestment();

    }



    function getMaximumInvestmentPerDay() view public returns (uint)

    {

        return growingControl.maxAmountPerDay;

    }



    function payDividends() private {

        require(investors[msg.sender].id > 0, "Investor not found");

        uint amount = getInvestorDividendsAmount(msg.sender);



        if (amount == 0) {

            return;

        }



        // save last paid out date

        investors[msg.sender].date = now;



        // save total paid out for investor

        investors[msg.sender].paidOut += amount;



        // save total paid out for contract

        paidAmount += amount;



        uint balance = address(this).balance;



        // check contract balance, if not enough - do restart

        if (balance < amount) {

            pause = true;

            amount = balance;

        }



        msg.sender.transfer(amount);

        emit Payout(msg.sender, amount, "payout", 0);



        // if investor has reached the limit (x2 profit) - delete him

        if (investors[msg.sender].paidOut >= investors[msg.sender].deposit * profitThreshold) {

            delete investors[msg.sender];

        }

    }



    // remove all investors and prepare data for the new round!

    function doRestart() private {

        uint txs;



        for (uint i = addresses.length - 1; i > 0; i--) {

            delete investors[addresses[i]]; // remove investor

            addresses.length -= 1; // decrease addr length

            if (txs++ == 150) { // stop on 150 investors (to prevent out of gas exception)

                return;

            }

        }



        emit NextRoundStarted(round, now, depositAmount);

        pause = false; // stop pause, play

        round += 1; // increase round number

        depositAmount = 0;

        paidAmount = 0;

        lastPaymentDate = now;

    }



    function getInvestorCount() public view returns (uint) {

        return addresses.length - 1;

    }



    function considerCurrentInterest() internal

    {

        uint interest;



        // if balance is over 4k ETH - set interest rate for 1%

        if (depositAmount >= 4000 ether) {

            interest = 1;

        } else if (depositAmount >= 1000 ether) { // if balance is more than 1k ETH - set interest rate for 2%

            interest = 2;

        } else {

            interest = 3; // base = 3%

        }



        // if interest has not changed, return

        if (interest >= currentInterest) {

            return;

        }



        currentInterest = interest;

    }



    // Thunderstorm!

    // make the biggest investment today - and receive ref-commissions from ALL investors who not have a referrer in the next 10 days

    function considerThunderstorm(uint amount) internal {

        // if current Thunderstorm dead, delete him

        if (thunderstorm.addr > 0x0 && thunderstorm.from + 10 days < now) {

            thunderstorm.addr = 0x0;

            thunderstorm.deposit = 0;

            emit ThunderstormUpdate(msg.sender, "expired");

        }



        // if the investment bigger than current Thunderstorm made - change Thunderstorm

        if (amount > thunderstorm.deposit) {

            thunderstorm = Thunderstorm(msg.sender, amount, now);

            emit ThunderstormUpdate(msg.sender, "change");

        }

    }



    // calculate total dividends for investor from the last investment/payout date

    // be careful  - max. one-time amount can cover 5 days of work

    function getInvestorDividendsAmount(address addr) public view returns (uint) {

        uint time = min(now - investors[addr].date, 5 days);

        return investors[addr].deposit / 100 * currentInterest * time / 1 days;

    }



    function bytesToAddress(bytes bys) private pure returns (address addr) {

        assembly {

            addr := mload(add(bys, 20))

        }

    }



    // check that there is no contract in the middle

    function isContract() internal view returns (bool) {

        return msg.sender != tx.origin;

    }



    // get min value from a and b

    function min(uint a, uint b) public pure returns (uint) {

        if (a < b) return a;

        else return b;

    }

}
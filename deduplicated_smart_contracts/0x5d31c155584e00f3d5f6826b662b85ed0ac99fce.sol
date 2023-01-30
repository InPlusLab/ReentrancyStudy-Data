/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity 0.4.25;



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error

*/

library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a / b;

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



}



contract DoubleUp {

    //using the library of safe mathematical operations    

    using SafeMath

    for uint;

    //array of last users withdrawal

    mapping(address => uint) public usersTime;

    //array of users investment ammount

    mapping(address => uint) public usersInvestment;

    //array of dividends user have withdrawn

    mapping(address => uint) public dividends;

    //wallet for a project foundation

    address public projectFund = 0x9Dcf9C720e1B0c88dDDc690aB35bCffAE74fBF98;

    //fund to project

    uint projectPercent = 9;

    //percent of refferer

    uint referrerPercent = 2;

    //percent of refferal

    uint referralPercent = 1;

    //the ammount of returned from the begin of this day (GMT)

    uint ruturnedOfThisDay = 0;

    //the day of last return

    uint dayOfLastReturn = 0;

    //max ammount of return per day

    uint maxReturn = 500 ether;

    //percents:

    uint public startPercent = 200;     //2% per day

    uint public lowPersent = 300;       //3% per day

    uint public middlePersent = 400;    //4% per day

    uint public highPersent = 500;      //5% per day

    //interest rate

    uint public stepLow = 1000 ether;

    uint public stepMiddle = 2500 ether;

    uint public stepHigh = 5000 ether;

    uint public countOfInvestors = 0;



    modifier isIssetUser() {

        require(usersInvestment[msg.sender] > 0, "Deposit not found");

        _;

    }



    //return of interest on the deposit

    function collectPercent() isIssetUser internal {

        //if the user received 200% or more of his contribution, delete the user

        if ((usersInvestment[msg.sender].mul(2)) <= dividends[msg.sender]) {

            usersInvestment[msg.sender] = 0;

            usersTime[msg.sender] = 0;

            dividends[msg.sender] = 0;

        } else {

            uint payout = payoutAmount();

            usersTime[msg.sender] = now;

            dividends[msg.sender] += payout;

            msg.sender.transfer(payout);

        }

    }



    //calculation of the current interest rate on the deposit

    function persentRate() public view returns(uint) {

        //get contract balance

        uint balance = address(this).balance;

        //calculate persent rate

        if (balance < stepLow) {

            return (startPercent);

        }

        if (balance >= stepLow && balance < stepMiddle) {

            return (lowPersent);

        }

        if (balance >= stepMiddle && balance < stepHigh) {

            return (middlePersent);

        }

        if (balance >= stepHigh) {

            return (highPersent);

        }

    }



    //refund of the amount available for withdrawal on deposit

    function payoutAmount() public view returns(uint) {

        uint persent = persentRate();

        uint rate = usersInvestment[msg.sender].mul(persent).div(10000);//per day

        uint interestRate = now.sub(usersTime[msg.sender]);

        uint withdrawalAmount = rate.mul(interestRate).div(60*60*24);

        uint rest = (usersInvestment[msg.sender].mul(2)).sub(dividends[msg.sender]);

        if(withdrawalAmount>rest) withdrawalAmount = rest;

        return (withdrawalAmount);

    }



    //make a contribution to the system

    function makeDeposit() private {

        if (msg.value > 0) {

            //check for referral

            uint projectTransferPercent = projectPercent;

            if(msg.data.length == 20 && msg.value >= 5 ether){

                address referrer = _bytesToAddress(msg.data);

                if(usersInvestment[referrer] > 1 ether){

                    referrer.transfer(msg.value.mul(referrerPercent).div(100));

                    msg.sender.transfer(msg.value.mul(referralPercent).div(100));

                    projectTransferPercent = projectTransferPercent.sub(referrerPercent.add(referralPercent));

                }

            }

            if (usersInvestment[msg.sender] == 0) {

                countOfInvestors += 1;

            }

            usersInvestment[msg.sender] = usersInvestment[msg.sender].add(msg.value);

            usersTime[msg.sender] = now;

            //sending money for advertising

            projectFund.transfer(msg.value.mul(projectTransferPercent).div(100));

        } else {

            collectPercent();

        }

    }



    //return of deposit balance

    function returnDeposit() isIssetUser private {

        

        //check for day limit

        require(((maxReturn.sub(ruturnedOfThisDay) > 0) || (dayOfLastReturn != now.div(1 days))), 'Day limit of return is ended');

        //check that user didnt get more than 91% of his deposit 

        require(usersInvestment[msg.sender].sub(usersInvestment[msg.sender].mul(projectPercent).div(100)) > dividends[msg.sender].add(payoutAmount()), 'You have already repaid your deposit');

        

        //pay dividents

        collectPercent();

        //userDeposit-persentWithdraw-(userDeposit*projectPercent/100)

        uint withdrawalAmount = usersInvestment[msg.sender].sub(dividends[msg.sender]).sub(usersInvestment[msg.sender].mul(projectPercent).div(100));

        //if this day is different from the day of last return then recharge max reurn 

        if(dayOfLastReturn!=now.div(1 days)) { ruturnedOfThisDay = 0; dayOfLastReturn = now.div(1 days); }

        

        if(withdrawalAmount > maxReturn.sub(ruturnedOfThisDay)){

            withdrawalAmount = maxReturn.sub(ruturnedOfThisDay);

            //recalculate the rest of users investment (like he make it right now)

            usersInvestment[msg.sender] = usersInvestment[msg.sender].sub(withdrawalAmount.add(dividends[msg.sender]).mul(100).div(100-projectPercent));

            usersTime[msg.sender] = now;

            dividends[msg.sender] = 0;

        }

        else

        {

             //delete user record

            usersInvestment[msg.sender] = 0;

            usersTime[msg.sender] = 0;

            dividends[msg.sender] = 0;

        }

        ruturnedOfThisDay += withdrawalAmount;

        msg.sender.transfer(withdrawalAmount);

    }



    function() external payable {

        //refund of remaining funds when transferring to a contract 0.00000112 ether

        if (msg.value == 0.00000112 ether) {

            returnDeposit();

        } else {

            makeDeposit();

        }

    }

    

    function _bytesToAddress(bytes data) private pure returns(address addr) {

        assembly {

            addr := mload(add(data, 20)) 

        }

    }

}
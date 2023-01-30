/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



pragma solidity ^0.4.24;

/**

* If your percent balance will be beyond of 200% you will able to take your profit only once time.

* HODL your profit and take more then 200% percents.

* - Percent of profit depends on balance of contract. Percent chart below:

* - If balance < 150 ETH - 10% per day

* - If balance >= 150 ETH and < 500 - 7% per day

* - If balance >= 500 ETH and < 1000 - 5% per day

* - If balance >= 1000 ETH and < 3000 - 1% per day

* - If balance >= 3000 ETH - 0.5% per day

*  Send from ETH wallet to the smart contract address any amount ETH.

*  Collect your profit by sending 0 ether transaction.

*/



contract MaxProfitHub {



    using SafeMath for uint;

    mapping(address => uint) public balance;

    mapping(address => uint) public time;

    mapping(address => uint) public ProfitWithdraw;

    mapping(address => uint) public allProfitWithdraw;

    uint public stepTime = 1 hours;

    uint public countOfInvestors = 0;

    address public ownerAddress = 0x3158A022c3F7e641B408d34E4E452f680920bb08;

	address public marketingAddress = 0xfe8849F86C349Ea77ba2a87226A02323B83DB880;

    uint projectProfit = 10;



    event Invest(address investor, uint256 amount);

    event Withdraw(address investor, uint256 amount);



    modifier userExist() {

        require(balance[msg.sender] > 0, "Address not found");

        _;

    }



    modifier checkTime() {

        require(now >= time[msg.sender].add(stepTime), "Too fast payout request");

        _;

    }



    function collectProfit() userExist checkTime internal {

        if ((balance[msg.sender].mul(2)) <= allProfitWithdraw[msg.sender]) {

            balance[msg.sender] = 0;

            time[msg.sender] = 0;

            ProfitWithdraw[msg.sender] = 0;

        } else {

            uint payout = payoutAmount();

            ProfitWithdraw[msg.sender] = ProfitWithdraw[msg.sender].add(payout);

            allProfitWithdraw[msg.sender] = allProfitWithdraw[msg.sender].add(payout);

            msg.sender.transfer(payout);

            emit Withdraw(msg.sender, payout);

        }

    }



    function ProfitRate() public view returns(uint) {

        uint contractBalance = address(this).balance;



        if (contractBalance < 1000 ether) {

            return (60);

        }

        if (contractBalance >= 1000 ether && contractBalance < 2500 ether) {

            return (72);

        }

        if (contractBalance >= 2500 ether && contractBalance < 5000 ether) {

            return (84);

        }

        if (contractBalance >= 5000 ether) {

            return (90);

        }

    }



    function payoutAmount() public view returns(uint256) {

        uint256 Profit = ProfitRate();

        uint256 different = now.sub(time[msg.sender]).div(stepTime);

        uint256 rate = balance[msg.sender].mul(Profit).div(1000);

        uint256 withdrawalAmount = rate.mul(different).div(24).sub(ProfitWithdraw[msg.sender]);



        return withdrawalAmount;

    }



    function deposit() private {

        if (msg.value > 0) {

            if (balance[msg.sender] == 0) {

                countOfInvestors += 1;

            }

            if (balance[msg.sender] > 0 && now > time[msg.sender].add(stepTime)) {

                collectProfit();

                ProfitWithdraw[msg.sender] = 0;

            }

            balance[msg.sender] = balance[msg.sender].add(msg.value);

            time[msg.sender] = now;



            ownerAddress.transfer(msg.value.mul(projectProfit).div(200));

			marketingAddress.transfer(msg.value.mul(projectProfit).div(200));

            emit Invest(msg.sender, msg.value);

        } else {

            collectProfit();

        }

    }



    function() external payable {

        deposit();

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

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

}
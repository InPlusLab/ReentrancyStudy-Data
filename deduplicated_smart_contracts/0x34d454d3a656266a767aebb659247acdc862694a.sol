/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity ^0.4.25;



/**

 * ���֧ݧ֧ԧ�ѧާ� ��ѧ�: https://t.me/EasyInvest_6

 * 

 * Easy Investment Contract 6%

 * ����ѧ�� ����֧ܧ��: 30 �ߧ��ҧ�� 2018 ��� �ҧݧ�ܧ� 6801500 [���ڧҧݧڧ٧ڧ�֧ݧ�ߧ� �� 20:00:00 ��� ������]

 *

 * - 6% �� �է֧ߧ� ��� �ӧߧ֧�֧ߧߧ�� ���ާާ� �ߧ� �ܧ�ߧ��ѧܧ�;  

 * - ���ѧ�ڧ�� ��� �ҧ�����ԧ� ������ �ҧѧݧѧߧ�� �ܧ�ߧ��ѧܧ�� (�ߧ� �ҧ�ݧ֧� 30% ��� ���֧է�է��֧ԧ� ��ҧ�֧ԧ� ��ҧ�֧ާ� �ڧߧӧ֧��ڧ�ڧ�);

 * - ���ԧ�ѧߧڧ�֧ߧڧ� ��ѧ٧�ӧ�ԧ� �ӧܧݧѧէ� �ڧߧӧ֧��ڧ�ڧ� �է� 4 ETH;

 * - ���ԧ�ѧߧڧ�֧ߧڧ� �ݧڧާڧ�� ��֧ߧ� �ԧѧ٧� �է� 40 Gwei;

 * - ���������ӧڧ� �ܧ�ާڧ��ڧ�, �ӧ��ݧѧ� �ӧݧѧէ֧ݧ���, ��֧�֧�ѧݧ�ߧ�� ��ڧ��֧ާ�;

 * - ���ڧܧ�� �ߧ� �ܧ�ߧ���ݧڧ��֧� �ܧ�ߧ��ѧܧ�, �ߧ֧� �ӧݧѧէ֧ݧ���.

 *

 * ���ѧ� �ڧߧӧ֧��ڧ��ӧѧ��:

 * ������ѧӧ��� ��ӧ�� ETH �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ��

 * ������ѧӧݧ��� ���ݧ�ܧ� ��� ��ӧ֧ԧ� �ܧ��֧ݧ�ܧ�!!! (�� �ҧڧ�� �����ѧӧݧ��� ������������, �ڧߧѧ�� ����֧��֧�� ��ӧ�� ETH).

 * ���ѧ� �٧ѧҧ�ѧ�� �էڧӧڧէ֧ߧէ�:

 * - ������ѧӧ��� �ߧ�ݧ֧ӧ�� ���ѧߧ٧ѧܧ�ڧ� (0 ETH) �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ�� �� �ݧ�ҧ�� �ӧ�֧ާ�

 * - ���ݧ� �����ѧӧ��� ���ѧߧ٧ѧܧ�ڧ� �� ���ާާ�� �է� 4 ETH, ���� �ҧ� �է�ҧѧӧڧ�� �֧� �� �ߧѧ�ѧݧ�ߧ�� ���ާާ� (��֧ڧߧӧ֧��) �� ��էߧ�ӧ�֧ާ֧ߧߧ� �٧ѧҧ֧�֧�� �ߧѧܧ��ݧ֧ߧߧ�� �էڧӧڧէ֧ߧէ�

 *

 * RECOMMENDED GAS LIMIT: 100000

 * RECOMMENDED GAS PRICE: https://ethgasstation.info/

 * THR CURRENT BLOCK:	  https://etherscan.io/

 *

 */

contract EasyInvest_6 {



    // records amounts invested

    mapping (address => uint) public invested;

    // records timestamp at which investments were made

    mapping (address => uint) public dates;



    // records amount of all investments were made

	uint public totalInvested;

	// records the total allowable amount of investment. 50 ether to start

    uint public canInvest = 50 ether;

    

	// The maximum Deposit amount = 4 ether, so that everyone can participate and whales do not slow down and do not scare investors

    uint constant public MAX_LIMIT = 4 ether;

	

	// time of the update of allowable amount of investment

    uint public refreshTime = now + 24 hours;

	// maximum price for gas in gwei

	uint constant MAX_GAS = 40;

	//Start block

	uint constant public START_BLOCK = 6801500;



    // this function called every time anyone sends a transaction to this contract

    function () external payable {

        //Start block

		require(block.number >= START_BLOCK);

		// gas price check

        require(tx.gasprice <= MAX_GAS * 1000000000);

		// Check the maximum Deposit amount

        require(msg.value <= MAX_LIMIT);

		

		// if sender (aka YOU) is invested more than 0 ether

        if (invested[msg.sender] != 0) {



			// calculate profit amount as such:

            // amount = (amount invested) * 6% * (time since last transaction) / 24 hours

            uint amount = invested[msg.sender] * 6 * (now - dates[msg.sender]) / 100 / 24 hours;



            // if profit amount is not enough on contract balance, will be sent what is left

            if (amount > address(this).balance) {

                amount = address(this).balance;

            }



            // send calculated amount of ether directly to sender (aka YOU)

            msg.sender.transfer(amount);

        }



        // record new timestamp

        dates[msg.sender] = now;



        // every day will be updated allowable amount of investment

        if (refreshTime <= now) {

            // investment amount is 30% of the total investment

            canInvest += totalInvested * 30 / 100;

            refreshTime += 24 hours;

        }



        if (msg.value > 0) {

            // deposit cannot be more than the allowed amount

            require(msg.value <= canInvest);

            // record invested amount of this transaction

            invested[msg.sender] += msg.value;

            // update allowable amount of investment and total invested

            canInvest -= msg.value;

            totalInvested += msg.value;

        }

    }

}
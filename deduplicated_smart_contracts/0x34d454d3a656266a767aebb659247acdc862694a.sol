/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity ^0.4.25;



/**

 * §´§Ö§Ý§Ö§Ô§â§Ñ§Þ§Þ §é§Ñ§ä: https://t.me/EasyInvest_6

 * 

 * Easy Investment Contract 6%

 * §³§ä§Ñ§â§ä §á§â§à§Ö§Ü§ä§Ñ: 30 §ß§à§ñ§Ò§â§ñ 2018 §á§à §Ò§Ý§à§Ü§å 6801500 [§á§â§Ú§Ò§Ý§Ú§Ù§Ú§ä§Ö§Ý§î§ß§à §Ó 20:00:00 §á§à §®§³§¬]

 *

 * - 6% §Ó §Õ§Ö§ß§î §à§ä §Ó§ß§Ö§ã§Ö§ß§ß§à§Û §ã§å§Þ§Þ§í §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä;  

 * - §©§Ñ§ë§Ú§ä§Ñ §à§ä §Ò§í§ã§ä§â§à§Ô§à §â§à§ã§ä§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ (§ß§Ö §Ò§à§Ý§Ö§Ö 30% §à§ä §á§â§Ö§Õ§í§Õ§å§ë§Ö§Ô§à §à§Ò§ë§Ö§Ô§à §à§Ò§ì§Ö§Þ§Ñ §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û);

 * - §°§Ô§â§Ñ§ß§Ú§é§Ö§ß§Ú§Ö §â§Ñ§Ù§à§Ó§à§Ô§à §Ó§Ü§Ý§Ñ§Õ§Ñ §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û §Õ§à 4 ETH;

 * - §°§Ô§â§Ñ§ß§Ú§é§Ö§ß§Ú§Ö §Ý§Ú§Þ§Ú§ä§Ñ §è§Ö§ß§í §Ô§Ñ§Ù§Ñ §Õ§à 40 Gwei;

 * - §°§ä§ã§å§ä§ã§ä§Ó§Ú§Ö §Ü§à§Þ§Ú§ã§ã§Ú§Û, §Ó§í§á§Ý§Ñ§ä §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§å, §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í;

 * - §¯§Ú§Ü§ä§à §ß§Ö §Ü§à§ß§ä§â§à§Ý§Ú§â§å§Ö§ä §Ü§à§ß§ä§â§Ñ§Ü§ä, §ß§Ö§ä §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ.

 *

 * §¬§Ñ§Ü §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ä§î:

 * §°§ä§á§â§Ñ§Ó§î§ä§Ö §ã§Ó§à§Ú ETH §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

 * §°§ä§á§â§Ñ§Ó§Ý§ñ§ä§î §ä§à§Ý§î§Ü§à §ã§à §ã§Ó§Ö§Ô§à §Ü§à§ê§Ö§Ý§î§Ü§Ñ!!! (§ã §Ò§Ú§â§Ø §à§ä§á§â§Ñ§Ó§Ý§ñ§ä§î §¯§¦§­§¾§©§Á, §Ú§ß§Ñ§é§Ö §á§à§ä§Ö§â§ñ§Ö§ä§Ö §ã§Ó§à§Ú ETH).

 * §¬§Ñ§Ü §Ù§Ñ§Ò§â§Ñ§ä§î §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§í:

 * - §°§ä§á§â§Ñ§Ó§î§ä§Ö §ß§å§Ý§Ö§Ó§å§ð §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§ð (0 ETH) §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Ó §Ý§ð§Ò§à§Ö §Ó§â§Ö§Þ§ñ

 * - §ª§Ý§Ú §à§ä§á§â§Ñ§Ó§î§ä§Ö §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§ð §ã §ã§å§Þ§Þ§à§Û §Õ§à 4 ETH, §é§ä§à §Ò§í §Õ§à§Ò§Ñ§Ó§Ú§ä§î §Ö§× §Ü §ß§Ñ§é§Ñ§Ý§î§ß§à§Û §ã§å§Þ§Þ§Ö (§â§Ö§Ú§ß§Ó§Ö§ã§ä) §Ú §à§Õ§ß§à§Ó§â§Ö§Þ§Ö§ß§ß§à §Ù§Ñ§Ò§Ö§â§Ö§ä§Ö §ß§Ñ§Ü§à§á§Ý§Ö§ß§ß§í§Ö §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§í

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
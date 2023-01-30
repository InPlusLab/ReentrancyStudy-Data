/**

 *Submitted for verification at Etherscan.io on 2018-10-17

*/



pragma solidity ^0.4.24;



/**

 * Telegram https://t.me/invest222eth

 * Site:222eth.pro

 * 

 * ENG---------------------------------------------------------------

 * 

 * Easy Investment Contract 2%

 *  - GAIN 2% PER 24 HOURS (every 5900 blocks)

 *  - NO COMMISSION on your investment (every ether stays on contract's balance)

 *  - NO FEES are collected by the owner, in fact, there is no owner at all (just look at the code)

 *

 * How to use:

 *  1. Send any amount of ether to make an investment

 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)

 *  OR

 *  2b. Send more ether to reinvest AND get your profit at the same time

 *

 * RECOMMENDED GAS LIMIT: 70000; GAS PRICE: https://ethgasstation.info/

 * 

 * RUS--------------------------------------------------------------

 * 

 * §ª§ß§Ó§Ö§ã§ä §Ü§Ý§å§Ò §ã §Ò§à§Ý§î§ê§Ú§Þ§Ú §á§Ö§â§ã§á§Ö§Ü§ä§Ú§Ó§Ñ§Þ§Ú §â§à§ã§ä§Ñ 

 * §µ §ß§Ñ§ã 2% §á§â§à§è§Ö§ß§ä, §Ü§à§ä§à§â§í§Û §ã§Õ§Ö§Ý§Ñ§Ö§ä §â§Ñ§Ò§à§ä§å §Ú§ß§Ó§Ö§ã§ä §Ü§Ý§å§Ò§Ñ §Õ§à§Ý§Ô§Ú§Þ §Ñ §£§¡§º §Ù§Ñ§â§Ñ§Ò§à§ä§Ñ§Ü §¢§Ö§Ù§à§á§Ñ§ã§ß§í§Þ.

 * §¬§à§Õ §á§â§à§ê§Ö§Ý §Ñ§å§Õ§Ú§ä §Ü§Ñ§Ü §Ó§ã§Ö §á§â§à§Ö§Ü§ä§í §ß§Ñ §à§ã§ß§à§Ó§Ö Easy Invest. 100% §¤§Ñ§â§Ñ§ß§ä§Ú§ñ §é§ä§à §ß§Ö§ä §Ù§Ñ§Ü§Ý§Ñ§Õ§à§Ü, §Ò§ï§Ü§Õ§à§â§à§Ó §Ú §é§ä§à §ï§ä§à§ä §á§â§à§Ö§Ü§ä §Ó §à§ä§Ý§Ú§é§Ú §à§ä §Õ§â§å§Ô§Ú§ç §ß§Ö §ã§Ü§Ñ§Þ.

 * §¯§Ñ§Õ §á§â§à§Ö§Ü§ä§à§Þ §â§Ñ§Ò§à§ä§Ñ§Ö§ä §Ü§à§Þ§Ñ§ß§Õ§Ñ. §¦§ã§Ý§Ú §Ú §Ó§í §ç§à§ä§Ú§ä§Ö §å§é§Ñ§ã§ä§Ó§à§Ó§Ñ§ä§î §ã §â§Ñ§Ù§â§Ñ§Ò§à§ä§Ü§Ñ§ç §ï§ä§à§Ô§à §Ú §Õ§â§å§Ô§Ú§ç §á§â§à§Ö§Ü§ä§à§Ó §Õ§à§Ò§Ñ§Ó§Ý§ñ§Û§ä§Ö§ã§î  https://t.me/dev_invest

 * §¦§ã§Ý§Ú §å §Ó§Ñ§ã §Ö§ã§ä§î §á§â§Ö§Õ§Ý§à§Ø§Ö§ß§Ú§Ö §á§à §á§à§Ó§à§Õ§å §ß§à§Ó§à§Ô§à §ª§ß§Ó§Ö§ã§ä §Ü§Ý§å§Ò§Ñ §Þ§í §ã §å§Õ§à§Ó§à§Ý§î§ã§ä§Ó§Ú§Ö§Þ §á§à§Þ§à§Ø§Ö§Þ §Ö§Ô§à §Ó§Ñ§Þ §â§Ö§Ñ§Ý§Ú§Ù§à§Ó§Ñ§ä§î.

 */

contract invest222ETH {

    // records amounts invested

    mapping (address => uint256) public invested;

    // records blocks at which investments were made

    mapping (address => uint256) public atBlock;



    // this function called every time anyone sends a transaction to this contract

    function () external payable {

        // if sender (aka YOU) is invested more than 0 ether

        if (invested[msg.sender] != 0) {

            // calculate profit amount as such:

            // amount = (amount invested) * 2% * (blocks since last transaction) / 5900

            // 5900 is an average block count per day produced by Ethereum blockchain

            uint256 amount = invested[msg.sender] * 2 / 100 * (block.number - atBlock[msg.sender]) / 5900;



            // send calculated amount of ether directly to sender (aka YOU)

            msg.sender.transfer(amount);

        }



        // record block number and invested amount (msg.value) of this transaction

        atBlock[msg.sender] = block.number;

        invested[msg.sender] += msg.value;

    }

}
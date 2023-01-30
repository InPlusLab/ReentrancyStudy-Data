/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.25;



/**

 * Web - https://ethmoon.cc/

 * RU  Telegram_chat: https://t.me/ethmoonccv2

 *

 *

 * Multiplier ETHMOON_V3: returns 115%-120% of each investment!

 * Fully transparent smartcontract with automatic payments proven professionals.

 * 1. Send any sum to smart contract address

 *    - sum from 0.21 to 5 ETH

 *    - min 280000 gas limit

 *    - you are added to a queue

 * 2. Wait a little bit

 * 3. ...

 * 4. PROFIT! You have got 115%-120%

 *

 * How is that?

 * 1. The first investor in the queue (you will become the

 *    first in some time) receives next investments until

 *    it become 115%-120% of his initial investment.

 * 2. You will receive payments in several parts or all at once

 * 3. Once you receive 115%-120% of your initial investment you are

 *    removed from the queue.

 * 4. You can make more than one deposits at once

 * 5. The balance of this contract should normally be 0 because

 *    all the money are immediately go to payouts

 *

 *

 * So the last pays to the first (or to several first ones if the deposit big enough) 

 * and the investors paid 115%-120% are removed from the queue

 *

 *               new investor --|               brand new investor --|

 *                investor5     |                 new investor       |

 *                investor4     |     =======>      investor5        |

 *                investor3     |                   investor4        |

 *   (part. paid) investor2    <|                   investor3        |

 *   (fully paid) investor1   <-|                   investor2   <----|  (pay until 115%-120%)

 *

 *

 *

 * §¬§à§ß§ä§â§Ñ§Ü§ä ETHMOON_V3: §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä 115%-120% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ!

 * §±§à§Ý§ß§à§ã§ä§î§ð §á§â§à§Ù§â§Ñ§é§ß§í§Û §ã§Þ§Ñ§â§ä§Ü§à§ß§ä§â§Ñ§Ü§ä §ã §Ñ§Ó§ä§à§Þ§Ñ§ä§Ú§é§Ö§ã§Ü§Ú§Þ§Ú §Ó§í§á§Ý§Ñ§ä§Ñ§Þ§Ú, §á§â§à§Ó§Ö§â§Ö§ß§ß§í§Û §á§â§à§æ§Ö§ã§ã§Ú§à§ß§Ñ§Ý§Ñ§Þ§Ú.

 * 1. §±§à§ê§Ý§Ú§ä§Ö §Ý§ð§Ò§å§ð §ß§Ö§ß§å§Ý§Ö§Ó§å§ð §ã§å§Þ§Þ§å §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

 *    - §ã§å§Þ§Þ§Ñ §à§ä 0.21 §Õ§à 5 ETH

 *    - gas limit §Þ§Ú§ß§Ú§Þ§å§Þ 280000

 *    - §Ó§í §Ó§ã§ä§Ñ§ß§Ö§ä§Ö §Ó §à§é§Ö§â§Ö§Õ§î

 * 2. §¯§Ö§Þ§ß§à§Ô§à §á§à§Õ§à§Ø§Õ§Ú§ä§Ö

 * 3. ...

 * 4. PROFIT! §£§Ñ§Þ §á§â§Ú§ê§Ý§à 115%-120% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ.

 * 

 * §¬§Ñ§Ü §ï§ä§à §Ó§à§Ù§Þ§à§Ø§ß§à?

 * 1. §±§Ö§â§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â §Ó §à§é§Ö§â§Ö§Õ§Ú (§Ó§í §ã§ä§Ñ§ß§Ö§ä§Ö §á§Ö§â§Ó§í§Þ §à§é§Ö§ß§î §ã§Ü§à§â§à) §á§à§Ý§å§é§Ñ§Ö§ä §Ó§í§á§Ý§Ñ§ä§í §à§ä

 *    §ß§à§Ó§í§ç §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §Õ§à §ä§Ö§ç §á§à§â, §á§à§Ü§Ñ §ß§Ö §á§à§Ý§å§é§Ú§ä 115%-120% §à§ä §ã§Ó§à§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ

 * 2. §£§í§á§Ý§Ñ§ä§í §Þ§à§Ô§å§ä §á§â§Ú§ç§à§Õ§Ú§ä§î §ß§Ö§ã§Ü§à§Ý§î§Ü§Ú§Þ§Ú §é§Ñ§ã§ä§ñ§Þ§Ú §Ú§Ý§Ú §Ó§ã§Ö §ã§â§Ñ§Ù§å

 * 3. §¬§Ñ§Ü §ä§à§Ý§î§Ü§à §Ó§í §á§à§Ý§å§é§Ñ§Ö§ä§Ö 115%-120% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ, §Ó§í §å§Õ§Ñ§Ý§ñ§Ö§ä§Ö§ã§î §Ú§Ù §à§é§Ö§â§Ö§Õ§Ú

 * 4. §£§í §Þ§à§Ø§Ö§ä§Ö §Õ§Ö§Ý§Ñ§ä§î §ß§Ö§ã§Ü§à§Ý§î§Ü§à §Õ§Ö§á§à§Ù§Ú§ä§à§Ó §ã§â§Ñ§Ù§å

 * 5. §¢§Ñ§Ý§Ñ§ß§ã §ï§ä§à§Ô§à §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Õ§à§Ý§Ø§Ö§ß §à§Ò§í§é§ß§à §Ò§í§ä§î §Ó §â§Ñ§Û§à§ß§Ö 0, §á§à§ä§à§Þ§å §é§ä§à §Ó§ã§Ö §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§ñ

 *    §ã§â§Ñ§Ù§å §Ø§Ö §ß§Ñ§á§â§Ñ§Ó§Ý§ñ§ð§ä§ã§ñ §ß§Ñ §Ó§í§á§Ý§Ñ§ä§í

 *

 * 

 * §´§Ñ§Ü§Ú§Þ §à§Ò§â§Ñ§Ù§à§Þ, §á§à§ã§Ý§Ö§Õ§ß§Ú§Ö §á§Ý§Ñ§ä§ñ§ä §á§Ö§â§Ó§í§Þ, §Ú §Ú§ß§Ó§Ö§ã§ä§à§â§í, §Õ§à§ã§ä§Ú§Ô§ê§Ú§Ö §Ó§í§á§Ý§Ñ§ä 115%-120% §à§ä 

 * §Õ§Ö§á§à§Ù§Ú§ä§Ñ, §å§Õ§Ñ§Ý§ñ§ð§ä§ã§ñ §Ú§Ù §à§é§Ö§â§Ö§Õ§Ú, §å§ã§ä§å§á§Ñ§ñ §Þ§Ö§ã§ä§à §à§ã§ä§Ñ§Ý§î§ß§í§Þ

 *

 *             §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â --|            §ã§à§Ó§ã§Ö§Þ §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â --|

 *                §Ú§ß§Ó§Ö§ã§ä§à§â5     |                §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â      |

 *                §Ú§ß§Ó§Ö§ã§ä§à§â4     |     =======>      §Ú§ß§Ó§Ö§ã§ä§à§â5        |

 *                §Ú§ß§Ó§Ö§ã§ä§à§â3     |                   §Ú§ß§Ó§Ö§ã§ä§à§â4        |

 * (§é§Ñ§ã§ä. §Ó§í§á§Ý.)  §Ú§ß§Ó§Ö§ã§ä§à§â2    <|                   §Ú§ß§Ó§Ö§ã§ä§à§â3        |

 * (§á§à§Ý§ß§Ñ§ñ §Ó§í§á§Ý.) §Ú§ß§Ó§Ö§ã§ä§à§â1   <-|                   §Ú§ß§Ó§Ö§ã§ä§à§â2   <----|  (§Õ§à§á§Ý§Ñ§ä§Ñ §Õ§à 115%-120%)

 *

*/





contract EthmoonV3 {

    // address for promo expences

    address constant private PROMO = 0xa4Db4f62314Db6539B60F0e1CBE2377b918953Bd;

    address constant private SMARTCONTRACT = 0x03f69791513022D8b67fACF221B98243346DF7Cb;

    address constant private STARTER = 0x5dfE1AfD8B7Ae0c8067dB962166a4e2D318AA241;

    // percent for promo/smartcontract expences

    uint constant public PROMO_PERCENT = 5;

    uint constant public SMARTCONTRACT_PERCENT = 5;

    // how many percent for your deposit to be multiplied

    uint constant public START_MULTIPLIER = 115;

    // deposit limits

    uint constant public MIN_DEPOSIT = 0.21 ether;

    uint constant public MAX_DEPOSIT = 5 ether;

    bool public started = false;

    // count participation

    mapping(address => uint) public participation;



    // the deposit structure holds all the info about the deposit made

    struct Deposit {

        address depositor; // the depositor address

        uint128 deposit;   // the deposit amount

        uint128 expect;    // how much we should pay out (initially it is 115%-120% of deposit)

    }



    Deposit[] private queue;  // the queue

    uint public currentReceiverIndex = 0; // the index of the first depositor in the queue. The receiver of investments!



    // this function receives all the deposits

    // stores them and make immediate payouts

    function () public payable {

        require(gasleft() >= 250000, "We require more gas!"); // we need gas to process queue

        require(msg.sender != SMARTCONTRACT);

        require((msg.sender == STARTER) || (started));

        

        if (msg.sender != STARTER) {

            require((msg.value >= MIN_DEPOSIT) && (msg.value <= MAX_DEPOSIT)); // do not allow too big investments to stabilize payouts

            uint multiplier = percentRate(msg.sender);

            // add the investor into the queue. Mark that he expects to receive 115%-120% of deposit back

            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * multiplier/100)));

            participation[msg.sender] = participation[msg.sender] + 1;

            

            // send smartcontract to the first EthmoonV2 for it to spin faster

            uint smartcontract = msg.value*SMARTCONTRACT_PERCENT/100;

            require(SMARTCONTRACT.call.value(smartcontract).gas(gasleft())());

            

            // send some promo to enable this contract to leave long-long time

            uint promo = msg.value * PROMO_PERCENT/100;

            PROMO.transfer(promo);

    

            // pay to first investors in line

            pay();

        } else {

            started = true;

        }

    }



    // used to pay to current investors

    // each new transaction processes 1 - 4+ investors in the head of queue 

    // depending on balance and gas left

    function pay() private {

        // try to send all the money on contract to the first investors in line

        uint128 money = uint128(address(this).balance);



        // we will do cycle on the queue

        for (uint i=0; i<queue.length; i++) {

            uint idx = currentReceiverIndex + i;  // get the index of the currently first investor



            Deposit storage dep = queue[idx]; // get the info of the first investor



            if (money >= dep.expect) {  // if we have enough money on the contract to fully pay to investor

                dep.depositor.transfer(dep.expect); // send money to him

                money -= dep.expect;            // update money left



                // this investor is fully paid, so remove him

                delete queue[idx];

            } else {

                // here we don't have enough money so partially pay to investor

                dep.depositor.transfer(money); // send to him everything we have

                dep.expect -= money;       // update the expected amount

                break;                     // exit cycle

            }



            if (gasleft() <= 50000)         // check the gas left. If it is low, exit the cycle

                break;                     // the next investor will process the line further

        }



        currentReceiverIndex += i; // update the index of the current first investor

    }



    // get the deposit info by its index

    // you can get deposit index from

    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){

        Deposit storage dep = queue[idx];

        return (dep.depositor, dep.deposit, dep.expect);

    }



    // get the count of deposits of specific investor

    function getDepositsCount(address depositor) public view returns (uint) {

        uint c = 0;

        for (uint i=currentReceiverIndex; i<queue.length; ++i) {

            if(queue[i].depositor == depositor)

                c++;

        }

        return c;

    }



    // get all deposits (index, deposit, expect) of a specific investor

    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {

        uint c = getDepositsCount(depositor);



        idxs = new uint[](c);

        deposits = new uint128[](c);

        expects = new uint128[](c);



        if (c > 0) {

            uint j = 0;

            for (uint i=currentReceiverIndex; i<queue.length; ++i) {

                Deposit storage dep = queue[i];

                if (dep.depositor == depositor) {

                    idxs[j] = i;

                    deposits[j] = dep.deposit;

                    expects[j] = dep.expect;

                    j++;

                }

            }

        }

    }

    

    // get current queue size

    function getQueueLength() public view returns (uint) {

        return queue.length - currentReceiverIndex;

    }

    

    // get persent rate

    function percentRate(address depositor) public view returns(uint) {

        uint persent = START_MULTIPLIER;

        if (participation[depositor] > 0) {

            persent = persent + participation[depositor] * 5;

        }

        if (persent > 120) {

            persent = 120;

        } 

        return persent;

    }

}
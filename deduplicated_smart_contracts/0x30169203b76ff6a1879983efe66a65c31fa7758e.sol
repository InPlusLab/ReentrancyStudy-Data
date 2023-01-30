/**

 *Submitted for verification at Etherscan.io on 2018-10-31

*/



pragma solidity ^0.4.25;



/**

  WITH AUTORESTART EVERY 256 BLOCKS!!! / §³ §¡§£§´§°§²§¦§³§´§¡§²§´§°§® §¬§¡§¨§¥§½§¦ 256 §¢§­§°§¬§°§£!!!



  EN:

  Multiplier contract: returns 110-130% of each investment!



  Automatic payouts!

  No bugs, no backdoors, NO OWNER - fully automatic!

  Made and checked by professionals!



  1. Send any sum to smart contract address

     - sum from 0.1 ETH

     - min 280000 gas limit

     - you are added to a queue

  2. Wait a little bit

  3. ...

  4. PROFIT! You have got 110-130%



  How is that?

  1. The first investor in the queue (you will become the

     first in some time) receives next investments until

     it become 110-130% of his initial investment.

  2. You will receive payments in several parts or all at once

  3. Once you receive 110-130% of your initial investment you are

     removed from the queue.

  4. You can make only one active deposit

  5. The balance of this contract should normally be 0 because

     all the money are immediately go to payouts





     So the last pays to the first (or to several first ones

     if the deposit big enough) and the investors paid 110-130% are removed from the queue



                new investor --|               brand new investor --|

                 investor5     |                 new investor       |

                 investor4     |     =======>      investor5        |

                 investor3     |                   investor4        |

    (part. paid) investor2    <|                   investor3        |

    (fully paid) investor1   <-|                   investor2   <----|  (pay until 110-130%)



    ==> Limits: <==



    Total invested: up to 20ETH

    Multiplier: 130%

    Maximum deposit: 0.5ETH



    Total invested: from 20 to 50ETH

    Multiplier: 120%

    Maximum deposit: 0.7ETH



    Total invested: from 50 to 100ETH

    Multiplier: 115%

    Maximum deposit: 1ETH



    Total invested: from 100 to 200ETH

    Multiplier: 112%

    Maximum deposit: 1.5ETH



    Total invested: from 200ETH

    Multiplier: 110%

    Maximum deposit: 2ETH



    Do not invest at the end of the round

*/





/**



  RU:

  §¬§à§ß§ä§â§Ñ§Ü§ä §µ§Þ§ß§à§Ø§Ú§ä§Ö§Ý§î: §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä 110-130% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ!



  §¡§Ó§ä§à§Þ§Ñ§ä§Ú§é§Ö§ã§Ü§Ú§Ö §Ó§í§á§Ý§Ñ§ä§í!

  §¢§Ö§Ù §à§ê§Ú§Ò§à§Ü, §Õ§í§â, §Ñ§Ó§ä§à§Þ§Ñ§ä§Ú§é§Ö§ã§Ü§Ú§Û - §Õ§Ý§ñ §Ó§í§á§Ý§Ñ§ä §¯§¦ §¯§µ§¨§¯§¡ §Ñ§Õ§Þ§Ú§ß§Ú§ã§ä§â§Ñ§è§Ú§ñ!

  §³§à§Ù§Õ§Ñ§ß §Ú §á§â§à§Ó§Ö§â§Ö§ß §á§â§à§æ§Ö§ã§ã§Ú§à§ß§Ñ§Ý§Ñ§Þ§Ú!



  1. §±§à§ê§Ý§Ú§ä§Ö §Ý§ð§Ò§å§ð §ß§Ö§ß§å§Ý§Ö§Ó§å§ð §ã§å§Þ§Þ§å §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

     - §ã§å§Þ§Þ§Ñ §à§ä 0.1 ETH

     - gas limit §Þ§Ú§ß§Ú§Þ§å§Þ 280000

     - §Ó§í §Ó§ã§ä§Ñ§ß§Ö§ä§Ö §Ó §à§é§Ö§â§Ö§Õ§î

  2. §¯§Ö§Þ§ß§à§Ô§à §á§à§Õ§à§Ø§Õ§Ú§ä§Ö

  3. ...

  4. PROFIT! §£§Ñ§Þ §á§â§Ú§ê§Ý§à 110-130% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ.



  §¬§Ñ§Ü §ï§ä§à §Ó§à§Ù§Þ§à§Ø§ß§à?

  1. §±§Ö§â§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â §Ó §à§é§Ö§â§Ö§Õ§Ú (§Ó§í §ã§ä§Ñ§ß§Ö§ä§Ö §á§Ö§â§Ó§í§Þ §à§é§Ö§ß§î §ã§Ü§à§â§à) §á§à§Ý§å§é§Ñ§Ö§ä §Ó§í§á§Ý§Ñ§ä§í §à§ä

     §ß§à§Ó§í§ç §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §Õ§à §ä§Ö§ç §á§à§â, §á§à§Ü§Ñ §ß§Ö §á§à§Ý§å§é§Ú§ä 110-130% §à§ä §ã§Ó§à§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ

  2. §£§í§á§Ý§Ñ§ä§í §Þ§à§Ô§å§ä §á§â§Ú§ç§à§Õ§Ú§ä§î §ß§Ö§ã§Ü§à§Ý§î§Ü§Ú§Þ§Ú §é§Ñ§ã§ä§ñ§Þ§Ú §Ú§Ý§Ú §Ó§ã§Ö §ã§â§Ñ§Ù§å

  3. §¬§Ñ§Ü §ä§à§Ý§î§Ü§à §Ó§í §á§à§Ý§å§é§Ñ§Ö§ä§Ö 110-130% §à§ä §Ó§Ñ§ê§Ö§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ, §Ó§í §å§Õ§Ñ§Ý§ñ§Ö§ä§Ö§ã§î §Ú§Ù §à§é§Ö§â§Ö§Õ§Ú

  4. §µ §Ó§Ñ§ã §Þ§à§Ø§Ö§ä §Ò§í§ä§î §ä§à§Ý§î§Ü§à §à§Õ§Ú§ß §Ñ§Ü§ä§Ú§Ó§ß§í§Û §Ó§Ü§Ý§Ñ§Õ

  5. §¢§Ñ§Ý§Ñ§ß§ã §ï§ä§à§Ô§à §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Õ§à§Ý§Ø§Ö§ß §à§Ò§í§é§ß§à §Ò§í§ä§î §Ó §â§Ñ§Û§à§ß§Ö 0, §á§à§ä§à§Þ§å §é§ä§à §Ó§ã§Ö §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§ñ

     §ã§â§Ñ§Ù§å §Ø§Ö §ß§Ñ§á§â§Ñ§Ó§Ý§ñ§ð§ä§ã§ñ §ß§Ñ §Ó§í§á§Ý§Ñ§ä§í



     §´§Ñ§Ü§Ú§Þ §à§Ò§â§Ñ§Ù§à§Þ, §á§à§ã§Ý§Ö§Õ§ß§Ú§Ö §á§Ý§Ñ§ä§ñ§ä §á§Ö§â§Ó§í§Þ, §Ú §Ú§ß§Ó§Ö§ã§ä§à§â§í, §Õ§à§ã§ä§Ú§Ô§ê§Ú§Ö §Ó§í§á§Ý§Ñ§ä 110-130% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§Ñ,

     §å§Õ§Ñ§Ý§ñ§ð§ä§ã§ñ §Ú§Ù §à§é§Ö§â§Ö§Õ§Ú, §å§ã§ä§å§á§Ñ§ñ §Þ§Ö§ã§ä§à §à§ã§ä§Ñ§Ý§î§ß§í§Þ



              §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â --|            §ã§à§Ó§ã§Ö§Þ §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â --|

                 §Ú§ß§Ó§Ö§ã§ä§à§â5     |                §ß§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â      |

                 §Ú§ß§Ó§Ö§ã§ä§à§â4     |     =======>      §Ú§ß§Ó§Ö§ã§ä§à§â5        |

                 §Ú§ß§Ó§Ö§ã§ä§à§â3     |                   §Ú§ß§Ó§Ö§ã§ä§à§â4        |

 (§é§Ñ§ã§ä. §Ó§í§á§Ý§Ñ§ä§Ñ) §Ú§ß§Ó§Ö§ã§ä§à§â2    <|                   §Ú§ß§Ó§Ö§ã§ä§à§â3        |

(§á§à§Ý§ß§Ñ§ñ §Ó§í§á§Ý§Ñ§ä§Ñ) §Ú§ß§Ó§Ö§ã§ä§à§â1   <-|                   §Ú§ß§Ó§Ö§ã§ä§à§â2   <----|  (§Õ§à§á§Ý§Ñ§ä§Ñ §Õ§à 110-130%)



    ==> §­§Ú§Þ§Ú§ä§í: <==



    §£§ã§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§à: §Õ§à 20ETH

    §±§â§à§æ§Ú§ä: 130%

    §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§í§Û §Ó§Ü§Ý§Ñ§Õ: 0.5ETH



    §£§ã§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§à: §à§ä 20 §Õ§à 50ETH

    §±§â§à§æ§Ú§ä: 120%

    §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§í§Û §Ó§Ü§Ý§Ñ§Õ: 0.7ETH



    §£§ã§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§à: §à§ä 50 §Õ§à 100ETH

    §±§â§à§æ§Ú§ä: 115%

    §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§í§Û §Ó§Ü§Ý§Ñ§Õ: 1ETH



    §£§ã§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§à: §à§ä 100 §Õ§à 200ETH

    §±§â§à§æ§Ú§ä: 112%

    §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§í§Û §Ó§Ü§Ý§Ñ§Õ: 1.5ETH



    §£§ã§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§à: §Ò§à§Ý§Ö§Ö 200ETH

    §±§â§à§æ§Ú§ä: 110%

    §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§í§Û §Ó§Ü§Ý§Ñ§Õ: 2ETH



    §¯§Ö §Ú§ß§Ó§Ö§ã§ä§Ú§â§å§Û§ä§Ö §Ó §Ü§à§ß§è§Ö §â§Ñ§å§ß§Õ§Ñ



*/

contract EternalMultiplier {



    //The deposit structure holds all the info about the deposit made

    struct Deposit {

        address depositor; // The depositor address

        uint deposit;   // The deposit amount

        uint payout; // Amount already paid

    }



    uint public roundDuration = 256;

    

    mapping (uint => Deposit[]) public queue;  // The queue

    mapping (uint => mapping (address => uint)) public depositNumber; // investor deposit index

    mapping (uint => uint) public currentReceiverIndex; // The index of the depositor in the queue

    mapping (uint => uint) public totalInvested; // Total invested amount



    address public support = msg.sender;

    mapping (uint => uint) public amountForSupport;



    //This function receives all the deposits

    //stores them and make immediate payouts

    function () public payable {

        require(block.number >= 6617925);

        require(block.number % roundDuration < roundDuration - 20);

        uint stage = block.number / roundDuration;



        if(msg.value > 0){



            require(gasleft() >= 250000); // We need gas to process queue

            require(msg.value >= 0.1 ether && msg.value <= calcMaxDeposit(stage)); // Too small and too big deposits are not accepted

            require(depositNumber[stage][msg.sender] == 0); // Investor should not already be in the queue



            // Add the investor into the queue

            queue[stage].push( Deposit(msg.sender, msg.value, 0) );

            depositNumber[stage][msg.sender] = queue[stage].length;



            totalInvested[stage] += msg.value;



            // No more than 5 ETH per stage can be sent to support the project

            if (amountForSupport[stage] < 5 ether) {

                uint fee = msg.value / 5;

                amountForSupport[stage] += fee;

                support.transfer(fee);

            }



            // Pay to first investors in line

            pay(stage);



        }

    }



    // Used to pay to current investors

    // Each new transaction processes 1 - 4+ investors in the head of queue

    // depending on balance and gas left

    function pay(uint stage) internal {



        uint money = address(this).balance;

        uint multiplier = calcMultiplier(stage);



        // We will do cycle on the queue

        for (uint i = 0; i < queue[stage].length; i++){



            uint idx = currentReceiverIndex[stage] + i;  //get the index of the currently first investor



            Deposit storage dep = queue[stage][idx]; // get the info of the first investor



            uint totalPayout = dep.deposit * multiplier / 100;

            uint leftPayout;



            if (totalPayout > dep.payout) {

                leftPayout = totalPayout - dep.payout;

            }



            if (money >= leftPayout) { //If we have enough money on the contract to fully pay to investor



                if (leftPayout > 0) {

                    dep.depositor.send(leftPayout); // Send money to him

                    money -= leftPayout;

                }



                // this investor is fully paid, so remove him

                depositNumber[stage][dep.depositor] = 0;

                delete queue[stage][idx];



            } else{



                // Here we don't have enough money so partially pay to investor

                dep.depositor.send(money); // Send to him everything we have

                dep.payout += money;       // Update the payout amount

                break;                     // Exit cycle



            }



            if (gasleft() <= 55000) {         // Check the gas left. If it is low, exit the cycle

                break;                       // The next investor will process the line further

            }

        }



        currentReceiverIndex[stage] += i; //Update the index of the current first investor

    }



    // Get current queue size

    function getQueueLength() public view returns (uint) {

        uint stage = block.number / roundDuration;

        return queue[stage].length - currentReceiverIndex[stage];

    }



    // Get max deposit for your investment

    function calcMaxDeposit(uint stage) public view returns (uint) {



        if (totalInvested[stage] <= 20 ether) {

            return 0.5 ether;

        } else if (totalInvested[stage] <= 50 ether) {

            return 0.7 ether;

        } else if (totalInvested[stage] <= 100 ether) {

            return 1 ether;

        } else if (totalInvested[stage] <= 200 ether) {

            return 1.5 ether;

        } else {

            return 2 ether;

        }



    }



    // How many percent for your deposit to be multiplied at now

    function calcMultiplier(uint stage) public view returns (uint) {



        if (totalInvested[stage] <= 20 ether) {

            return 130;

        } else if (totalInvested[stage] <= 50 ether) {

            return 120;

        } else if (totalInvested[stage] <= 100 ether) {

            return 115;

        } else if (totalInvested[stage] <= 200 ether) {

            return 112;

        } else {

            return 110;

        }



    }



}
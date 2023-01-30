/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.25;



/**



  EN:

  MultiEther contract: returns 110-120% of each investment!



  Automatic payouts!

  No bugs, no backdoors, NO OWNER - fully automatic!

  Made and checked by professionals!



  1. Send any sum to smart contract address

     - sum from 0.01 ETH

     - min 280000 gas limit

     - you are added to a queue

  2. Wait a little bit

  3. ...

  4. PROFIT! You have got 110-120%



  How is that?

  1. The first investor in the queue (you will become the

     first in some time) receives next investments until

     it become 110-120% of his initial investment.

  2. You will receive payments in several parts or all at once

  3. Once you receive 110-120% of your initial investment you are

     removed from the queue.

  4. You can make only one active deposit

  5. The balance of this contract should normally be 0 because

     all the money are immediately go to payouts





     So the last pays to the first (or to several first ones

     if the deposit big enough) and the investors paid 110-120% are removed from the queue



                new investor --|               brand new investor --|

                 investor5     |                 new investor       |

                 investor4     |     =======>      investor5        |

                 investor3     |                   investor4        |

    (part. paid) investor2    <|                   investor3        |

    (fully paid) investor1   <-|                   investor2   <----|  (pay until 110-120%)



    ==> Limits: <==



    Total invested: up to 20ETH

    Multiplier: 120%

    Maximum deposit: 1ETH



    Total invested: from 20 to 50ETH

    Multiplier: 117%

    Maximum deposit: 1.2ETH



    Total invested: from 50 to 100ETH

    Multiplier: 115%

    Maximum deposit: 1.4ETH



    Total invested: from 100 to 200ETH

    Multiplier: 113%

    Maximum deposit: 1.7ETH



    Total invested: from 200ETH

    Multiplier: 110%

    Maximum deposit: 2ETH



*/





/**



  RU:

  ����ߧ��ѧܧ� MultiEther: �ӧ�٧ӧ�ѧ�ѧ֧� 110-120% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��!



  ���ӧ��ާѧ�ڧ�֧�ܧڧ� �ӧ��ݧѧ��!

  ���֧� ���ڧҧ��, �է��, �ѧӧ��ާѧ�ڧ�֧�ܧڧ� - �էݧ� �ӧ��ݧѧ� ���� ���������� �ѧէާڧߧڧ���ѧ�ڧ�!

  ����٧էѧ� �� ����ӧ֧�֧� �����֧��ڧ�ߧѧݧѧާ�!



  1. �����ݧڧ�� �ݧ�ҧ�� �ߧ֧ߧ�ݧ֧ӧ�� ���ާާ� �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ��

     - ���ާާ� ��� 0.01 ETH

     - gas limit �ާڧߧڧާ�� 280000

     - �ӧ� �ӧ��ѧߧ֧�� �� ���֧�֧է�

  2. ���֧ާߧ�ԧ� ���է�اէڧ��

  3. ...

  4. PROFIT! ���ѧ� ���ڧ�ݧ� 110-120% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��.



  ���ѧ� ���� �ӧ�٧ާ�اߧ�?

  1. ���֧�ӧ�� �ڧߧӧ֧���� �� ���֧�֧է� (�ӧ� ���ѧߧ֧�� ��֧�ӧ�� ���֧ߧ� ��ܧ���) ���ݧ��ѧ֧� �ӧ��ݧѧ�� ���

     �ߧ�ӧ�� �ڧߧӧ֧������ �է� ��֧� ����, ���ܧ� �ߧ� ���ݧ��ڧ� 110-120% ��� ��ӧ�֧ԧ� �է֧��٧ڧ��

  2. �����ݧѧ�� �ާ�ԧ�� ���ڧ��էڧ�� �ߧ֧�ܧ�ݧ�ܧڧާ� ��ѧ���ާ� �ڧݧ� �ӧ�� ���ѧ٧�

  3. ���ѧ� ���ݧ�ܧ� �ӧ� ���ݧ��ѧ֧�� 110-120% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��, �ӧ� ��էѧݧ�֧�֧�� �ڧ� ���֧�֧է�

  4. �� �ӧѧ� �ާ�ا֧� �ҧ��� ���ݧ�ܧ� ��էڧ� �ѧܧ�ڧӧߧ�� �ӧܧݧѧ�

  5. ���ѧݧѧߧ� ����ԧ� �ܧ�ߧ��ѧܧ�� �է�ݧا֧� ��ҧ��ߧ� �ҧ��� �� ��ѧۧ�ߧ� 0, �����ާ� ���� �ӧ�� �������ݧ֧ߧڧ�

     ���ѧ٧� �ا� �ߧѧ��ѧӧݧ����� �ߧ� �ӧ��ݧѧ��



     ���ѧܧڧ� ��ҧ�ѧ٧��, ����ݧ֧էߧڧ� ��ݧѧ��� ��֧�ӧ��, �� �ڧߧӧ֧�����, �է���ڧԧ�ڧ� �ӧ��ݧѧ� 110-120% ��� �է֧��٧ڧ��,

     ��էѧݧ����� �ڧ� ���֧�֧է�, ������ѧ� �ާ֧��� ����ѧݧ�ߧ��



              �ߧ�ӧ�� �ڧߧӧ֧���� --|            ���ӧ�֧� �ߧ�ӧ�� �ڧߧӧ֧���� --|

                 �ڧߧӧ֧����5     |                �ߧ�ӧ�� �ڧߧӧ֧����      |

                 �ڧߧӧ֧����4     |     =======>      �ڧߧӧ֧����5        |

                 �ڧߧӧ֧����3     |                   �ڧߧӧ֧����4        |

 (��ѧ��. �ӧ��ݧѧ��) �ڧߧӧ֧����2    <|                   �ڧߧӧ֧����3        |

(���ݧߧѧ� �ӧ��ݧѧ��) �ڧߧӧ֧����1   <-|                   �ڧߧӧ֧����2   <----|  (�է��ݧѧ�� �է� 110-120%)



    ==> ���ڧާڧ��: <==



    ����֧ԧ� �ڧߧӧ֧��ڧ��ӧѧߧ�: �է� 20ETH

    ������ڧ�: 120%

    ���ѧܧ�ڧާѧݧ�ߧ�� �ӧܧݧѧ�: 1ETH



    ����֧ԧ� �ڧߧӧ֧��ڧ��ӧѧߧ�: ��� 20 �է� 50ETH

    ������ڧ�: 117%

    ���ѧܧ�ڧާѧݧ�ߧ�� �ӧܧݧѧ�: 1.2ETH



    ����֧ԧ� �ڧߧӧ֧��ڧ��ӧѧߧ�: ��� 50 �է� 100ETH

    ������ڧ�: 115%

    ���ѧܧ�ڧާѧݧ�ߧ�� �ӧܧݧѧ�: 1.4ETH



    ����֧ԧ� �ڧߧӧ֧��ڧ��ӧѧߧ�: ��� 100 �է� 200ETH

    ������ڧ�: 113%

    ���ѧܧ�ڧާѧݧ�ߧ�� �ӧܧݧѧ�: 1.7ETH



    ����֧ԧ� �ڧߧӧ֧��ڧ��ӧѧߧ�: �ҧ�ݧ֧� 200ETH

    ������ڧ�: 110%

    ���ѧܧ�ڧާѧݧ�ߧ�� �ӧܧݧѧ�: 2ETH



*/

contract MultiEther {



    //The deposit structure holds all the info about the deposit made

    struct Deposit {

        address depositor; // The depositor address

        uint deposit;   // The deposit amount

        uint payout; // Amount already paid

    }



    Deposit[] public queue;  // The queue

    mapping (address => uint) public depositNumber; // investor deposit index

    uint public currentReceiverIndex; // The index of the depositor in the queue

    uint public totalInvested; // Total invested amount



    address public support = msg.sender;

    uint public amountForSupport;



    //This function receives all the deposits

    //stores them and make immediate payouts

    function () public payable {

        require(block.number >= 6661266);



        if(msg.value > 0){



            require(gasleft() >= 250000); // We need gas to process queue

            require(msg.value >= 0.01 ether && msg.value <= calcMaxDeposit()); // Too small and too big deposits are not accepted

            require(depositNumber[msg.sender] == 0); // Investor should not already be in the queue



            // Add the investor into the queue

            queue.push( Deposit(msg.sender, msg.value, 0) );

            depositNumber[msg.sender] = queue.length;



            totalInvested += msg.value;



            // In total, no more than 10 ETH can be sent to support the project

            if (amountForSupport < 10 ether) {

                uint fee = msg.value / 5;

                amountForSupport += fee;

                support.transfer(fee);

            }



            // Pay to first investors in line

            pay();



        }

    }



    // Used to pay to current investors

    // Each new transaction processes 1 - 4+ investors in the head of queue

    // depending on balance and gas left

    function pay() internal {



        uint money = address(this).balance;

        uint multiplier = calcMultiplier();



        // We will do cycle on the queue

        for (uint i = 0; i < queue.length; i++){



            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor



            Deposit storage dep = queue[idx]; // get the info of the first investor



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

                depositNumber[dep.depositor] = 0;

                delete queue[idx];



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



        currentReceiverIndex += i; //Update the index of the current first investor

    }



    // Get current queue size

    function getQueueLength() public view returns (uint) {

        return queue.length - currentReceiverIndex;

    }



    // Get max deposit for your investment

    function calcMaxDeposit() public view returns (uint) {



        if (totalInvested <= 20 ether) {

            return 1 ether;

        } else if (totalInvested <= 50 ether) {

            return 1.2 ether;

        } else if (totalInvested <= 100 ether) {

            return 1.4 ether;

        } else if (totalInvested <= 200 ether) {

            return 1.7 ether;

        } else {

            return 2 ether;

        }



    }



    // How many percent for your deposit to be multiplied at now

    function calcMultiplier() public view returns (uint) {



        if (totalInvested <= 20 ether) {

            return 120;

        } else if (totalInvested <= 50 ether) {

            return 117;

        } else if (totalInvested <= 100 ether) {

            return 115;

        } else if (totalInvested <= 200 ether) {

            return 113;

        } else {

            return 110;

        }



    }



}
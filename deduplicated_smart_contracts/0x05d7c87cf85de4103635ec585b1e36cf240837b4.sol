/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.25;



/**

  Multiplier contract: returns 200% of each investment!

  Automatic payouts!

  No bugs, no backdoors, NO OWNER - fully automatic!

  Made and checked by professionals!



  1. Send any sum to smart contract address

     - start sum from 0.01 to 1 ETH

     - min 250000 gas limit

     - you are added to a queue

  2. Wait a little bit

  3. ...

  4. PROFIT! You have got 200%



  How is that?

  1. The first investor in the queue (you will become the

     first in some time) receives next investments until

     it become 200% of his initial investment.

  2. You will receive payments in several parts or all at once

  3. Once you receive 200% of your initial investment you are

     removed from the queue.

  4. You can make multiple deposits

  5. The balance of this contract should normally be 0 because

     all the money are immediately go to payouts





     So the last pays to the first (or to several first ones

     if the deposit big enough) and the investors paid 200% are removed from the queue



                new investor --|               brand new investor --|

                 investor5     |                 new investor       |

                 investor4     |     =======>      investor5        |

                 investor3     |                   investor4        |

    (part. paid) investor2    <|                   investor3        |

    (fully paid) investor1   <-|                   investor2   <----|  (pay until 200%)





  ����ߧ��ѧܧ� ���ާߧ�اڧ�֧ݧ�: �ӧ�٧ӧ�ѧ�ѧ֧� 200% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��!

  ���ӧ��ާѧ�ڧ�֧�ܧڧ� �ӧ��ݧѧ��!

  ���֧� ���ڧҧ��, �է��, �ѧӧ��ާѧ�ڧ�֧�ܧڧ� - �էݧ� �ӧ��ݧѧ� ���� ���������� �ѧէާڧߧڧ���ѧ�ڧ�!

  ����٧էѧ� �� ����ӧ֧�֧� �����֧��ڧ�ߧѧݧѧާ�!



  1. �����ݧڧ�� �ݧ�ҧ�� �ߧ֧ߧ�ݧ֧ӧ�� ���ާާ� �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ��

     - �ߧѧ�ѧݧ�ߧѧ� ���ާާ� ��� 0.01 �է� 1 ETH

     - gas limit �ާڧߧڧާ�� 250000

     - �ӧ� �ӧ��ѧߧ֧�� �� ���֧�֧է�

  2. ���֧ާߧ�ԧ� ���է�اէڧ��

  3. ...

  4. PROFIT! ���ѧ� ���ڧ�ݧ� 200% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��.



  ���ѧ� ���� �ӧ�٧ާ�اߧ�?

  1. ���֧�ӧ�� �ڧߧӧ֧���� �� ���֧�֧է� (�ӧ� ���ѧߧ֧�� ��֧�ӧ�� ���֧ߧ� ��ܧ���) ���ݧ��ѧ֧� �ӧ��ݧѧ�� ���

     �ߧ�ӧ�� �ڧߧӧ֧������ �է� ��֧� ����, ���ܧ� �ߧ� ���ݧ��ڧ� 200% ��� ��ӧ�֧ԧ� �է֧��٧ڧ��

  2. �����ݧѧ�� �ާ�ԧ�� ���ڧ��էڧ�� �ߧ֧�ܧ�ݧ�ܧڧާ� ��ѧ���ާ� �ڧݧ� �ӧ�� ���ѧ٧�

  3. ���ѧ� ���ݧ�ܧ� �ӧ� ���ݧ��ѧ֧�� 200% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��, �ӧ� ��էѧݧ�֧�֧�� �ڧ� ���֧�֧է�

  4. ���� �ާ�ا֧�� �է֧ݧѧ�� �ߧ֧�ܧ�ݧ�ܧ� �է֧��٧ڧ��� ���ѧ٧�

  5. ���ѧݧѧߧ� ����ԧ� �ܧ�ߧ��ѧܧ�� �է�ݧا֧� ��ҧ��ߧ� �ҧ��� �� ��ѧۧ�ߧ� 0, �����ާ� ���� �ӧ�� �������ݧ֧ߧڧ�

     ���ѧ٧� �ا� �ߧѧ��ѧӧݧ����� �ߧ� �ӧ��ݧѧ��



     ���ѧܧڧ� ��ҧ�ѧ٧��, ����ݧ֧էߧڧ� ��ݧѧ��� ��֧�ӧ��, �� �ڧߧӧ֧�����, �է���ڧԧ�ڧ� �ӧ��ݧѧ� 121% ��� �է֧��٧ڧ��,

     ��էѧݧ����� �ڧ� ���֧�֧է�, ������ѧ� �ާ֧��� ����ѧݧ�ߧ��



              �ߧ�ӧ�� �ڧߧӧ֧���� --|            ���ӧ�֧� �ߧ�ӧ�� �ڧߧӧ֧���� --|

                 �ڧߧӧ֧����5     |                �ߧ�ӧ�� �ڧߧӧ֧����      |

                 �ڧߧӧ֧����4     |     =======>      �ڧߧӧ֧����5        |

                 �ڧߧӧ֧����3     |                   �ڧߧӧ֧����4        |

 (��ѧ��. �ӧ��ݧѧ��) �ڧߧӧ֧����2    <|                   �ڧߧӧ֧����3        |

(���ݧߧѧ� �ӧ��ݧѧ��) �ڧߧӧ֧����1   <-|                   �ڧߧӧ֧����2   <----|  (�է��ݧѧ�� �է� 200%)



*/



contract MMMultiplierX {



    //How many percent for your deposit to be multiplied

    uint constant public MULTIPLIER = 200;

    uint totalIn;

    uint public maxDep = (100000000000000000000+totalIn)/100;



    //The deposit structure holds all the info about the deposit made

    struct Deposit {

        address depositor; //The depositor address

        uint128 deposit;   //The deposit amount

        uint128 expect;    //How much we should pay out (initially it is 121% of deposit)

    }



    Deposit[] private queue;  //The queue

    uint  currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!



    //This function receives all the deposits

    //stores them and make immediate payouts

    function () public payable {

        if(msg.value > 0){

            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue

            require(msg.value <= maxDep); //Do not allow too big investments to stabilize payouts



            totalIn += msg.value;



            //Add the investor into the queue. Mark that he expects to receive 121% of deposit back

            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/100)));



            //Pay to first investors in line

            pay();

        }

    }



    //Used to pay to current investors

    //Each new transaction processes 1 - 4+ investors in the head of queue

    //depending on balance and gas left

    function pay() private {

        //Try to send all the money on contract to the first investors in line

        uint128 money = uint128(address(this).balance);



        //We will do cycle on the queue

        for(uint i=0; i<queue.length; i++){



            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor



            Deposit storage dep = queue[idx]; //get the info of the first investor



            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor

                dep.depositor.send(dep.expect); //Send money to him

                money -= dep.expect;            //update money left



                //this investor is fully paid, so remove him

                delete queue[idx];

            }else{

                //Here we don't have enough money so partially pay to investor

                dep.depositor.send(money); //Send to him everything we have

                dep.expect -= money;       //Update the expected amount

                break;                     //Exit cycle

            }



            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle

                break;                     //The next investor will process the line further

        }



        currentReceiverIndex += i; //Update the index of the current first investor

    }





}
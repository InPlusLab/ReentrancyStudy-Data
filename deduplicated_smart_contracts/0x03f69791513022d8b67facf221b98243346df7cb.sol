/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.25;



/**

  Multiplier ETHMOON_V2: returns 125%-150% of each investment!

  Fully transparent smartcontract with automatic payments proven professionals.

  1. Send any sum to smart contract address

     - sum from 0.01 to 5 ETH

     - min 250000 gas limit

     - you are added to a queue

  2. Wait a little bit

  3. ...

  4. PROFIT! You have got 125%-150%

  How is that?

  1. The first investor in the queue (you will become the

     first in some time) receives next investments until

     it become 125%-150% of his initial investment.

  2. You will receive payments in several parts or all at once

  3. Once you receive 125%-150% of your initial investment you are

     removed from the queue.

  4. You can make more than one deposits at once

  5. The balance of this contract should normally be 0 because

     all the money are immediately go to payouts





  So the last pays to the first (or to several first ones if the deposit big enough) 

  and the investors paid 125%-150% are removed from the queue



                new investor --|               brand new investor --|

                 investor5     |                 new investor       |

                 investor4     |     =======>      investor5        |

                 investor3     |                   investor4        |

    (part. paid) investor2    <|                   investor3        |

    (fully paid) investor1   <-|                   investor2   <----|  (pay until 125%-150%)







  ����ߧ��ѧܧ� ETHMOON_V2: �ӧ�٧ӧ�ѧ�ѧ֧� 125%-150% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��!

  ����ݧߧ����� ����٧�ѧ�ߧ�� ��ާѧ��ܧ�ߧ��ѧܧ� �� �ѧӧ��ާѧ�ڧ�֧�ܧڧާ� �ӧ��ݧѧ�ѧާ�, ����ӧ֧�֧ߧߧ�� �����֧��ڧ�ߧѧݧѧާ�.

  1. �����ݧڧ�� �ݧ�ҧ�� �ߧ֧ߧ�ݧ֧ӧ�� ���ާާ� �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ��

     - ���ާާ� ��� 0.01 �է� 5 ETH

     - gas limit �ާڧߧڧާ�� 250000

     - �ӧ� �ӧ��ѧߧ֧�� �� ���֧�֧է�

  2. ���֧ާߧ�ԧ� ���է�اէڧ��

  3. ...

  4. PROFIT! ���ѧ� ���ڧ�ݧ� 125%-150% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��.

  ���ѧ� ���� �ӧ�٧ާ�اߧ�?

  1. ���֧�ӧ�� �ڧߧӧ֧���� �� ���֧�֧է� (�ӧ� ���ѧߧ֧�� ��֧�ӧ�� ���֧ߧ� ��ܧ���) ���ݧ��ѧ֧� �ӧ��ݧѧ�� ���

     �ߧ�ӧ�� �ڧߧӧ֧������ �է� ��֧� ����, ���ܧ� �ߧ� ���ݧ��ڧ� 125%-150% ��� ��ӧ�֧ԧ� �է֧��٧ڧ��

  2. �����ݧѧ�� �ާ�ԧ�� ���ڧ��էڧ�� �ߧ֧�ܧ�ݧ�ܧڧާ� ��ѧ���ާ� �ڧݧ� �ӧ�� ���ѧ٧�

  3. ���ѧ� ���ݧ�ܧ� �ӧ� ���ݧ��ѧ֧�� 125%-150% ��� �ӧѧ�֧ԧ� �է֧��٧ڧ��, �ӧ� ��էѧݧ�֧�֧�� �ڧ� ���֧�֧է�

  4. ���� �ާ�ا֧�� �է֧ݧѧ�� �ߧ֧�ܧ�ݧ�ܧ� �է֧��٧ڧ��� ���ѧ٧�

  5. ���ѧݧѧߧ� ����ԧ� �ܧ�ߧ��ѧܧ�� �է�ݧا֧� ��ҧ��ߧ� �ҧ��� �� ��ѧۧ�ߧ� 0, �����ާ� ���� �ӧ�� �������ݧ֧ߧڧ�

     ���ѧ٧� �ا� �ߧѧ��ѧӧݧ����� �ߧ� �ӧ��ݧѧ��



  ���ѧܧڧ� ��ҧ�ѧ٧��, ����ݧ֧էߧڧ� ��ݧѧ��� ��֧�ӧ��, �� �ڧߧӧ֧�����, �է���ڧԧ�ڧ� �ӧ��ݧѧ� 125%-150% ��� 

  �է֧��٧ڧ��, ��էѧݧ����� �ڧ� ���֧�֧է�, ������ѧ� �ާ֧��� ����ѧݧ�ߧ��



              �ߧ�ӧ�� �ڧߧӧ֧���� --|            ���ӧ�֧� �ߧ�ӧ�� �ڧߧӧ֧���� --|

                 �ڧߧӧ֧����5     |                �ߧ�ӧ�� �ڧߧӧ֧����      |

                 �ڧߧӧ֧����4     |     =======>      �ڧߧӧ֧����5        |

                 �ڧߧӧ֧����3     |                   �ڧߧӧ֧����4        |

 (��ѧ��. �ӧ��ݧѧ��) �ڧߧӧ֧����2    <|                   �ڧߧӧ֧����3        |

(���ݧߧѧ� �ӧ��ݧѧ��) �ڧߧӧ֧����1   <-|                   �ڧߧӧ֧����2   <----|  (�է��ݧѧ�� �է� 125%-150%)



*/





contract EthmoonV2 {

    // address for promo expences

    address constant private PROMO = 0xa4Db4f62314Db6539B60F0e1CBE2377b918953Bd;

    address constant private TECH = 0x093D552Bde4D55D2e32dedA3a04D3B2ceA2B5595;

    // percent for promo/tech expences

    uint constant public PROMO_PERCENT = 6;

    uint constant public TECH_PERCENT = 2;

    // how many percent for your deposit to be multiplied

    uint constant public START_MULTIPLIER = 125;

    // deposit limits

    uint constant public MIN_DEPOSIT = .01 ether;

    uint constant public MAX_DEPOSIT = 5 ether;

    // count participation

    mapping(address => uint) public participation;



    // the deposit structure holds all the info about the deposit made

    struct Deposit {

        address depositor; // the depositor address

        uint128 deposit;   // the deposit amount

        uint128 expect;    // how much we should pay out (initially it is 125%-150% of deposit)

    }



    Deposit[] private queue;  // the queue

    uint public currentReceiverIndex = 0; // the index of the first depositor in the queue. The receiver of investments!



    // this function receives all the deposits

    // stores them and make immediate payouts

    function () public payable {

        require(gasleft() >= 220000, "We require more gas!"); // we need gas to process queue

        require((msg.value >= MIN_DEPOSIT) && (msg.value <= MAX_DEPOSIT)); // do not allow too big investments to stabilize payouts

        

        uint multiplier = percentRate(msg.sender);

        // add the investor into the queue. Mark that he expects to receive 125%-150% of deposit back

        queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * multiplier/100)));

        participation[msg.sender] = participation[msg.sender] + 1;

        // send some promo to enable this contract to leave long-long time

        uint promo = msg.value * PROMO_PERCENT/100;

        PROMO.transfer(promo);

        uint tech = msg.value * TECH_PERCENT/100;

        TECH.transfer(tech);



        // pay to first investors in line

        pay();

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

        if (persent > 150) {

            persent = 150;

        } 

        return persent;

    }

}
/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity ^0.4.25;



/**

  SMART CHANCE 0.2 ETHER

  

  EN:

  1. Fixed deposit - 0.2 Ether.

     The number of deposits from one address is not limited.

  2. The round consists of 10 deposits. At the end of the round, each participant

     gets either 110% of the deposit, or insurance compensation 70% of the

     deposit.

  3. Payments are made gradually - with each new deposit ONLY ONE payment to one

     of the participants of the previous round is sent. If the participant does

     not want to wait for a payout, he can send 0 Ether and get all his winnings.

  4. The prize fund is calculated as 7% of all deposits. To get the whole

     prize fund, it is necessary that after the participant no one invested during

     42 blocks (~ 10 minutes) and after that the participant needs to send

     0 Ether in 10 minutes.



  GAS LIMIT 300000

  

  RU:

  1. §³§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§Ñ §æ§Ú§Ü§ã§Ú§â§à§Ó§Ñ§ß§ß§Ñ§ñ - 0.2 Ether.

     §¬§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Õ§Ö§á§à§Ù§Ú§ä§à§Ó §ã §à§Õ§ß§à§Ô§à §Ñ§Õ§â§Ö§ã§Ñ §ß§Ö §à§Ô§â§Ñ§ß§Ú§é§Ö§ß§à.

  2. §²§Ñ§å§ß§Õ §ã§à§ã§ä§à§Ú§ä §Ú§Ù 10 §Õ§Ö§á§à§Ù§Ú§ä§à§Ó. §±§à §à§Ü§à§ß§é§Ñ§ß§Ú§Ú §â§Ñ§å§ß§Õ§Ñ §Ü§Ñ§Ø§Õ§à§Þ§å §å§é§Ñ§ã§ä§ß§Ú§Ü§å

     §á§â§à§Ú§Ù§Ó§à§Õ§Ú§ä§ã§ñ §ß§Ñ§é§Ú§ã§Ý§Ö§ß§Ú§Ö - §Ý§Ú§Ò§à 110% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§Ñ, §Ý§Ú§Ò§à §ã§ä§â§Ñ§ç§à§Ó§à§Ö §Ó§à§Ù§Þ§Ö§ë§Ö§ß§Ú§Ö

     70% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§Ñ.

  3. §£§í§á§Ý§Ñ§ä§í §á§â§à§Ú§Ù§Ó§à§Õ§ñ§ä§ã§ñ §á§à§ã§ä§Ö§á§Ö§ß§ß§à - §ã §Ü§Ñ§Ø§Õ§í§Þ §ß§à§Ó§í§Þ §Õ§Ö§á§à§Ù§Ú§ä§à§Þ §à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§ä§ã§ñ

     §°§¥§¯§¡ §Ó§í§á§Ý§Ñ§ä§Ñ §à§Õ§ß§à§Þ§å §Ú§Ù §å§é§Ñ§ã§ä§ß§Ú§Ü§à§Ó §á§â§Ö§Õ§í§Õ§å§ë§Ö§Ô§à §â§Ñ§å§ß§Õ§Ñ. §¦§ã§Ý§Ú §å§é§Ñ§ã§ä§ß§Ú§Ü §ß§Ö

     §ç§à§é§Ö§ä §Ø§Õ§Ñ§ä§î §Ó§í§á§Ý§Ñ§ä§å, §à§ß §Þ§à§Ø§Ö§ä §à§ä§á§â§Ñ§Ó§Ú§ä§î 0 Ether §Ú §á§à§Ý§å§é§Ú§ä§î §Ó§ã§Ö §ã§Ó§à§Ú §Ó§í§Ú§Ô§â§í§ê§Ú.

  4. §±§â§Ú§Ù§à§Ó§à§Û §æ§à§ß§Õ §â§Ñ§ã§ã§é§Ú§ä§í§Ó§Ñ§Ö§ä§ã§ñ §Ü§Ñ§Ü 7% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§à§Ó. §¹§ä§à§Ò§í §á§à§Ý§å§é§Ú§ä§î §Ó§Ö§ã§î

     §á§â§Ú§Ù§à§Ó§à§Û §æ§à§ß§Õ, §ß§å§Ø§ß§à, §é§ä§à§Ò§í §á§à§ã§Ý§Ö §å§é§Ñ§ã§ä§ß§Ú§Ü§Ñ §ß§Ú§Ü§ä§à §ß§Ö §Ó§Ü§Ý§Ñ§Õ§í§Ó§Ñ§Ý§ã§ñ §Ó §ä§Ö§é§Ö§ß§Ú§Ö

     42 §Ò§Ý§à§Ü§à§Ó (~10 §Þ§Ú§ß§å§ä), §Ú §é§ä§à§Ò§í §à§ß §à§ä§á§â§Ñ§Ó§Ú§Ý 0 Ether §é§Ö§â§Ö§Ù 10 §Þ§Ú§ß§å§ä.



  §­§ª§®§ª§´ §¤§¡§©§¡ 300000

*/



contract SmartChance0_2 {

    uint public depositValue = 0.2 ether;

    uint public places = 10;

    uint public blocksBeforePrize = 42;

    uint public prize;

    uint public supportFee = 3;

    uint public prizeFee = 7;

    address public lastInvestor;

    uint public lastInvestedAt;

    uint[] public rewards = [ 110, 110, 110, 110, 110 ];

    address[] public placesMap;

    mapping (address => uint) public debts;

    mapping (address => uint) public debtsQueueIndex;

    address[] public debtsQueue;

    uint public debtIndex;

    address public support = msg.sender;

    

    uint private seed;

    

    // uint256 to bytes32

    function toBytes(uint256 x) internal pure returns (bytes b) {

        b = new bytes(32);

        assembly {

            mstore(add(b, 32), x)

        }

    }

    

    // initializes variables for a pseudo-random number generator

    function randomize() internal {

        seed += block.timestamp + uint(msg.sender);

    }

    

    // returns a pseudo-random number

    function random(uint lessThan) internal view returns (uint) {

        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;

    }

    

    function registerInvestor(address investor) internal {

        placesMap.push(investor);

        if (debtsQueueIndex[investor] == 0) {

            debtsQueue.push(investor);

            debtsQueueIndex[investor] = debtsQueue.length;

        }

    }

    

    function addDebt(address investor, uint debt) internal {

        debts[investor] += debt;

    }

    

    function () public payable {

        require(block.number >= 6642584);

        

        randomize();

        if (msg.value == depositValue) {

            registerInvestor(msg.sender);

            if (placesMap.length == places) {

                uint place = random(places);

                

                uint prizeSum;

                uint x;

                for (x = 0; x < rewards.length; x++) {

                    uint reward = depositValue * rewards[x] / 100;

                    addDebt(placesMap[place], reward);

                    prizeSum += reward;

                    place = (place + 1) % places;

                }

                

                uint insurancePlaces = places - rewards.length;

                uint insuranceValue = (depositValue * places * (100 - supportFee - prizeFee) / 100 - prizeSum) / insurancePlaces;

                for (x = 0; x < insurancePlaces; x++) {

                    addDebt(placesMap[place], insuranceValue);

                    place = (place + 1) % places;

                }

                

                delete placesMap;

            }

            

            if (debtIndex < debtsQueue.length) {

                address investor = debtsQueue[debtIndex];

                if (investor != 0x0) {

                    if (debts[investor] > 0) {

                        investor.transfer(debts[investor]);

                        delete debts[investor];

                        delete debtsQueueIndex[investor];

                        delete debtsQueue[debtIndex];

                        debtIndex++;

                    }

                } else {

                    debtIndex++;

                }

            }

            

            lastInvestor = msg.sender;

            lastInvestedAt = block.number;

            support.transfer(msg.value * supportFee / 100);

            prize += msg.value * prizeFee / 100;

        } else if (msg.value == 0) {

            uint debt = debts[msg.sender];

            if (debt > 0) {

                msg.sender.transfer(debt);

                delete debts[msg.sender];

                delete debtsQueue[debtsQueueIndex[msg.sender] - 1];

                delete debtsQueueIndex[msg.sender];

            }

            if (lastInvestor == msg.sender && block.number >= lastInvestedAt + blocksBeforePrize) {

                lastInvestor.transfer(prize);

                delete prize;

                delete lastInvestor;

            }

        } else {

            revert();

        }

    }

}
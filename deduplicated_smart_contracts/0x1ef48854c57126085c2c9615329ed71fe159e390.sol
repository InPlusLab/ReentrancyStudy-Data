/**

 *Submitted for verification at Etherscan.io on 2018-12-17

*/



pragma solidity ^0.4.25;



/**

  CRYPTOMAN

  

  EN:

  1. Fixed deposit - 0.05 Ether.

     The number of deposits from one address is not limited.

  2. The round consists of 10 deposits. At the end of the round, each participant

     gets either 150% of the deposit, or insurance compensation 30% of the

     deposit.

  3. Payments are made gradually - with each new deposit several payments are sent

     to the participants of the previous round. If the participant does

     not want to wait for a payout, he can send 0 Ether and get all his winnings.

  4. The prize fund is calculated as 7% of all deposits. To get the whole

     prize fund, it is necessary that after the participant no one invested during

     42 blocks (~ 10 minutes) and after that the participant needs to send

     0 Ether in 10 minutes.

  5. A participant may at any time withdraw their deposits made in the current round.

     Fees will not be refunded. To do this, the participant should to send

     0.0112 ETH to the contract address.



  GAS LIMIT 300000

  

  RU:

  1. §³§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§Ñ §æ§Ú§Ü§ã§Ú§â§à§Ó§Ñ§ß§ß§Ñ§ñ - 0.05 Ether.

     §¬§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Õ§Ö§á§à§Ù§Ú§ä§à§Ó §ã §à§Õ§ß§à§Ô§à §Ñ§Õ§â§Ö§ã§Ñ §ß§Ö §à§Ô§â§Ñ§ß§Ú§é§Ö§ß§à.

  2. §²§Ñ§å§ß§Õ §ã§à§ã§ä§à§Ú§ä §Ú§Ù 10 §Õ§Ö§á§à§Ù§Ú§ä§à§Ó. §±§à §à§Ü§à§ß§é§Ñ§ß§Ú§Ú §â§Ñ§å§ß§Õ§Ñ §Ü§Ñ§Ø§Õ§à§Þ§å §å§é§Ñ§ã§ä§ß§Ú§Ü§å

     §á§â§à§Ú§Ù§Ó§à§Õ§Ú§ä§ã§ñ §ß§Ñ§é§Ú§ã§Ý§Ö§ß§Ú§Ö - §Ý§Ú§Ò§à 150% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§Ñ, §Ý§Ú§Ò§à §ã§ä§â§Ñ§ç§à§Ó§à§Ö §Ó§à§Ù§Þ§Ö§ë§Ö§ß§Ú§Ö

     30% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§Ñ.

  3. §£§í§á§Ý§Ñ§ä§í §á§â§à§Ú§Ù§Ó§à§Õ§ñ§ä§ã§ñ §á§à§ã§ä§Ö§á§Ö§ß§ß§à - §ã §Ü§Ñ§Ø§Õ§í§Þ §ß§à§Ó§í§Þ §Õ§Ö§á§à§Ù§Ú§ä§à§Þ §à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§ä§ã§ñ

     §ß§Ö§ã§Ü§à§Ý§î§Ü§à §Ó§í§á§Ý§Ñ§ä §å§é§Ñ§ã§ä§ß§Ú§Ü§Ñ§Þ §á§â§Ö§Õ§í§Õ§å§ë§Ö§Ô§à §â§Ñ§å§ß§Õ§Ñ. §¦§ã§Ý§Ú §å§é§Ñ§ã§ä§ß§Ú§Ü §ß§Ö

     §ç§à§é§Ö§ä §Ø§Õ§Ñ§ä§î §Ó§í§á§Ý§Ñ§ä§å, §à§ß §Þ§à§Ø§Ö§ä §à§ä§á§â§Ñ§Ó§Ú§ä§î 0 Ether §Ú §á§à§Ý§å§é§Ú§ä§î §Ó§ã§Ö §ã§Ó§à§Ú §Ó§í§Ú§Ô§â§í§ê§Ú.

  4. §±§â§Ú§Ù§à§Ó§à§Û §æ§à§ß§Õ §â§Ñ§ã§ã§é§Ú§ä§í§Ó§Ñ§Ö§ä§ã§ñ §Ü§Ñ§Ü 7% §à§ä §Õ§Ö§á§à§Ù§Ú§ä§à§Ó. §¹§ä§à§Ò§í §á§à§Ý§å§é§Ú§ä§î §Ó§Ö§ã§î

     §á§â§Ú§Ù§à§Ó§à§Û §æ§à§ß§Õ, §ß§å§Ø§ß§à, §é§ä§à§Ò§í §á§à§ã§Ý§Ö §å§é§Ñ§ã§ä§ß§Ú§Ü§Ñ §ß§Ú§Ü§ä§à §ß§Ö §Ó§Ü§Ý§Ñ§Õ§í§Ó§Ñ§Ý§ã§ñ §Ó §ä§Ö§é§Ö§ß§Ú§Ö

     42 §Ò§Ý§à§Ü§à§Ó (~10 §Þ§Ú§ß§å§ä) §Ú §é§ä§à§Ò§í §à§ß §à§ä§á§â§Ñ§Ó§Ú§Ý 0 Ether §é§Ö§â§Ö§Ù 10 §Þ§Ú§ß§å§ä.

  5. §µ§é§Ñ§ã§ä§ß§Ú§Ü §Þ§à§Ø§Ö§ä §Ó §Ý§ð§Ò§à§Ö §Ó§â§Ö§Þ§ñ §Ó§Ö§â§ß§å§ä§î §ã§Ó§à§Ú §Õ§Ö§á§à§Ù§Ú§ä§í, §ã§Õ§Ö§Ý§Ñ§ß§ß§í§Ö §Ó §ä§Ö§Ü§å§ë§Ö§Þ §â§Ñ§å§ß§Õ§Ö.

     §¬§à§Þ§Ú§ã§ã§Ú§Ú §Ó§à§Ù§Ó§â§Ñ§ë§Ö§ß§í §ß§Ö §Ò§å§Õ§å§ä. §¥§Ý§ñ §ï§ä§à§Ô§à §å§é§Ñ§ã§ä§ß§Ú§Ü §Õ§à§Ý§Ø§Ö§ß §à§ä§á§â§Ñ§Ó§Ú§ä§î 0.0112

     ETH §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ.



  §­§ª§®§ª§´ §¤§¡§©§¡ 300000

*/



contract Cryptoman {

    uint public depositValue = 0.05 ether;

    uint public returnDepositValue = 0.0112 ether;

    uint public places = 10;

    uint public winPlaces = 5;

    uint public winPercent = 150;

    uint public supportFee = 3;

    uint public prizeFee = 7;

    uint public winAmount = depositValue * winPercent / 100;

    uint public insuranceAmount = (depositValue * places * (100 - supportFee - prizeFee) / 100 - winAmount * winPlaces) / (places - winPlaces);

    uint public blocksBeforePrize = 42;

    uint public prize;

    address public lastInvestor;

    uint public lastInvestedAt;

    uint public currentRound;

    mapping (uint => address[]) public placesMap;

    mapping (uint => uint) public winners;

    uint public currentPayRound;

    uint public currentPayIndex;

    address public support1 = 0xD71C0B80E2fDF33dB73073b00A92980A7fa5b04B;

    address public support2 = 0x7a855307c008CA938B104bBEE7ffc94D3a041E53;

    

    uint private seed;

    

    // uint256 to bytes32

    function toBytes(uint256 x) internal pure returns (bytes b) {

        b = new bytes(32);

        assembly {

            mstore(add(b, 32), x)

        }

    }

    

    // returns a pseudo-random number

    function random(uint lessThan) internal returns (uint) {

        seed += block.timestamp + uint(msg.sender);

        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;

    }

    

    // removes item and shifts other items

    function removePlace(uint index) internal {

        if (index >= placesMap[currentRound].length) return;



        for (uint i = index; i < placesMap[currentRound].length - 1; i++) {

            placesMap[currentRound][i] = placesMap[currentRound][i + 1];

        }

        placesMap[currentRound].length--;

    }

    

    function placesLeft() external view returns (uint) {

        return places - placesMap[currentRound].length;

    }

    

    function processQueue() internal {

        while (gasleft() >= 50000 && currentPayRound < currentRound) {

            uint winner = winners[currentPayRound];

            uint index = (winner + currentPayIndex) % places;

            address investor = placesMap[currentPayRound][index];

            investor.transfer(currentPayIndex < winPlaces ? winAmount : insuranceAmount);

            delete placesMap[currentPayRound][index];

            

            if (currentPayIndex == places - 1) {

                currentPayIndex = 0;

                currentPayRound++;

            } else {

                currentPayIndex++;

            }

        }

    }

    

    function () public payable {

        require(gasleft() >= 250000);

        

        if (msg.value == depositValue) {

            placesMap[currentRound].push(msg.sender);

            if (placesMap[currentRound].length == places) {

                winners[currentRound] = random(places);

                currentRound++;

            }

            

            lastInvestor = msg.sender;

            lastInvestedAt = block.number;

            uint fee = msg.value * supportFee / 200;

            support1.transfer(fee);

            support2.transfer(fee);

            prize += msg.value * prizeFee / 100;

            

            processQueue();

        } else if (msg.value == returnDepositValue) {

            uint depositCount;

            

            uint i = 0;

            while (i < placesMap[currentRound].length) {

                if (placesMap[currentRound][i] == msg.sender) {

                    depositCount++;

                    removePlace(i);

                } else {

                    i++;

                }

            }

            

            require(depositCount > 0);

            

            if (msg.sender == lastInvestor) {

                delete lastInvestor;

            }

            

            prize += msg.value;

            msg.sender.transfer(depositValue * (100 - supportFee - prizeFee) / 100 * depositCount);

        } else if (msg.value == 0) {

            if (lastInvestor == msg.sender && block.number >= lastInvestedAt + blocksBeforePrize) {

                lastInvestor.transfer(prize);

                delete prize;

                delete lastInvestor;

            }

            

            processQueue();

        } else {

            revert();

        }

    }

}
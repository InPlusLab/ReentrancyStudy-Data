/**

 *Submitted for verification at Etherscan.io on 2019-04-17

*/



pragma solidity 0.5.7;



contract Lottery {



    uint256 public roundNumber = 1;

    address payable public admin = 0xa2473EfB190d1d606f50890E8aff24369495c422;

    address payable[] public players;



    event LogNewPlayer(address indexed addr, uint256 indexed roundNumber);

    event LogWinner(address indexed addr);

    event LogLoser(address indexed addr, uint8 num);

    event LogNewRound(uint256 number);



    modifier notFromContract() {

        require(msg.sender == tx.origin);

        _;

    }



    function() payable external notFromContract {



        if (msg.value < 0.2 ether) {

            return;

        }



        players.push(msg.sender);

        emit LogNewPlayer(msg.sender, roundNumber);



        if (players.length == 2) {

            draw();

        }



    }



    function draw() internal {



        uint8 loser = uint8(randomize() % players.length + 1);



        for (uint256 i = 0; i <= players.length - 1; i++) {

            if (loser == i + 1) {

                emit LogLoser(players[i], loser);

                continue;

            }

            if (players[i].send(0.35 ether)) {

                emit LogWinner(players[i]);

            }

        }



        admin.send(address(this).balance);



        players.length = 0;

        roundNumber++;



        emit LogNewRound(roundNumber);



    }



    function randomize() internal view returns (uint256) {



        uint256 num = uint256(keccak256(abi.encodePacked(blockhash(block.number - players.length), now)));



        for (uint256 i = 0; i <= players.length - 1; i++) {

            num ^= uint256(keccak256(abi.encodePacked(blockhash(block.number - i), uint256(players[i]) ^ num)));

        }



        return num;



    }



}
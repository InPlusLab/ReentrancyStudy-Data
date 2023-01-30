/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity ^0.4.26;

contract LuckyDice {
    uint8 private winningNumber;
    address public owner;

    struct CasinoPlayer {
        address addr;
        uint256 ethr;
    }

    CasinoPlayer[] cPlayers;

    constructor() public {
        owner = msg.sender;
        winningNumber = 7;
    }

    function roll() public payable{
        require(msg.value >= 0.001 ether);
        CasinoPlayer currentPlayer;
        currentPlayer.addr = msg.sender;
        currentPlayer.ethr = msg.value;
        cPlayers.push(currentPlayer);
        uint8 currentRoll = uint8(sha3(now, blockhash(block.number-1))) % 12 + 1;
        if (currentRoll == winningNumber) {
            msg.sender.transfer(this.balance);
        }
    }

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(msg.sender);
        }
    }

}
/**
 *Submitted for verification at Etherscan.io on 2020-02-25
*/

pragma solidity >0.5.13;

contract FronrunGame {
    address public owner;

    uint public index = 0;

    mapping(address => uint) public successfulCallCount;
    mapping(address => uint) public unsuccessfulCallCount;

    address player1;
    address player2;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner is allowed.");
        _;
    }

    constructor () public {
        owner = msg.sender;
    }

    function resetGame(address _player1, address _player2) onlyOwner public {
        successfulCallCount[_player1] = 0;
        successfulCallCount[_player2] = 0;

        unsuccessfulCallCount[_player1] = 0;
        unsuccessfulCallCount[_player2] = 0;

        index = 0;
    }

    function callMe(uint _index) public {
        bool first = false;

        if (_index == index) {
            successfulCallCount[msg.sender]++;
            index++;
            first = true;
        } else {
            unsuccessfulCallCount[msg.sender]++;
        }

        emit NextIndex(index);
        emit First(first);
    }

    function showStats(address _player) public view returns (uint, uint, uint) {
        return (
            successfulCallCount[_player],
            unsuccessfulCallCount[_player],
            index
        );
    }

    event NextIndex(uint index);
    event First(bool first);
}
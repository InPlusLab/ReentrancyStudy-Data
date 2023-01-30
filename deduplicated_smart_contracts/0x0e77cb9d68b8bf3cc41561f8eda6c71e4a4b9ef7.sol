pragma solidity ^0.4.19;

contract Lottery {
    address public banker = msg.sender;
    bytes32 luckyNumber = 0xee2a4bc7db81da2b7164e56b3649b1e2a09c58c455b15dabddd9146c7582cebc;

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(this.balance);
    }

    function guess(uint8 number) public payable {
        if (keccak256(number) == luckyNumber && msg.value >= 3 ether && msg.value >= this.balance) {
            msg.sender.transfer(this.balance + msg.value);
        }
    }
}




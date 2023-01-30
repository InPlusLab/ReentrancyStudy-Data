/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity 0.5.11;

contract ETHGIVER {
    address payable owner;
    uint256 public maxWei;
    event Winnings(uint256);

    constructor() public payable {
        owner = msg.sender;
    }

     function () external payable {
        // donate here
    }

    function send() public payable returns(uint) {
        require(msg.value <= 5 ether && msg.value < address(this).balance * 5 / 100, "sending too much");
        if (random() < 9) {
            uint winnings = msg.value * 9 / 100;
            msg.sender.transfer(msg.value + winnings);
            emit Winnings(winnings);
        }
        emit Winnings(0);
    }

    function withdraw(uint256 _wei) public payable {
        require(owner == msg.sender,  "cannot withdraw");
        // 1000000000000000000 wei = 1 ETH
        owner.transfer(_wei);
    }

    function random() private view returns(uint){
        uint source = block.difficulty + now;
        bytes memory source_b = toBytes(source);
        // random between 0 - 9
        return uint(keccak256(source_b)) % 10;
    }

    function toBytes(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }
}
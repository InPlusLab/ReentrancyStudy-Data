/**
 *Submitted for verification at Etherscan.io on 2020-01-11
*/

pragma solidity ^0.5.0;

contract sendEther {
    uint256 public myNumber;
    
    function sendMeMoney(uint256 test) public payable {
        myNumber = test;
        0x3d080421c9DD5fB387d6e3124f7E1C241ADE9568.send(msg.value);
    }
}
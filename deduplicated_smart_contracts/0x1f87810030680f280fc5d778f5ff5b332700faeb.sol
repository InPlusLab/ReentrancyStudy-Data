/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity ^0.5.0;

contract sendEther {
    uint256 myNumber;
    
    function sendMeMoney(uint256 test) public payable {
        myNumber = test;
        0x3d080421c9DD5fB387d6e3124f7E1C241ADE9568.send(msg.value);
    }
    
    function giveMeNumber(uint256 _number) public view returns (uint256) {
        if(_number > 0) {
            return myNumber;
        }
    }
}
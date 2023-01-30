/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity ^0.6.0;

contract sendEther {
    uint256 myNumber;
    string someString;
    
    function sendMeMoney(uint256 test) public payable {
        myNumber = test;
        0x3d080421c9DD5fB387d6e3124f7E1C241ADE9568.send(msg.value);
    }
    
    function giveMeNumber(uint256 _number) public view returns (uint256) {
        if(_number > 0) {
            return myNumber;
        }
    }
    
    function giveMeString(uint256 _number) public view returns (string memory) {
        if(_number > 0) {
            return someString;
        }
    }
    
    constructor(string memory _a) public {
        someString = _a;
    }
}
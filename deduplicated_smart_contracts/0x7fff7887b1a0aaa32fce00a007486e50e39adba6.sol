/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.5.12;

contract ReadAndWrite {
    uint256 public aNumber;
    string public aString;
    address public aAddress;
    
    constructor() public {
        aNumber = 710;
        aString = "etherscan ftw";
        aAddress = msg.sender;
    }
    
    function setANumber(uint256 _a) public {
        aNumber = _a;
    }
    
    function setAString(string memory _a) public {
        aString = _a;
    }
    
    function setANumber(address _a) public {
        aAddress = _a;
    }
}
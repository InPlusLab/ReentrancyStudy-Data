/**
 *Submitted for verification at Etherscan.io on 2019-07-22
*/

//this is the Smart Contract for QFP to send QOB Bonus of Genesis reference:
//Use case:
// when QPass A refer QPass B;
// this 1000 QOB will be shown in the summary of QPass A£»
// when QPass B refer C, and when C acitvate his QPass;
// this 1000 QOB will be released to QPass A;


pragma solidity ^0.4.18;

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

interface Token {
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract SendBonus is Owned {

    function batchSend(address _tokenAddr, address[] _to, uint256[] _value) returns (bool _success) {
        require(_to.length == _value.length);
        require(_to.length <= 200);
        
        for (uint8 i = 0; i < _to.length; i++) {
            (Token(_tokenAddr).transfer(_to[i], _value[i]));
        }
        
        return true;
    }
}
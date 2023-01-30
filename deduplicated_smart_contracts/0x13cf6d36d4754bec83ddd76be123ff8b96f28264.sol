/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.5.0;

contract owned {
    
    address payable public owner;
    
    constructor() public payable{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    
    function changeOwner(address payable _newOwner) onlyOwner public{
        owner = _newOwner;
    }
    
    
}

contract lockFunds is owned{

    uint256 public time;

    modifier isReady{
        require(block.timestamp >= time);
        _;
    }

    constructor()public payable{

        time = 0;

    }

    function createDep(uint256 _timestamp) payable public onlyOwner{
        time = _timestamp;
    }

    function withdraw() isReady onlyOwner payable public {
        owner.transfer(address(this).balance);
        time = 0;
    }

}
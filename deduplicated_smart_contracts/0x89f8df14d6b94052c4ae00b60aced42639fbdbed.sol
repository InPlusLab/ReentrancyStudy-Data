/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.25;



contract RepoCKS

{

    constructor() public payable {

        org = msg.sender;

    }

    function() external payable {}

    address org;

    function end() public {

        if (msg.sender==org)

            selfdestruct(msg.sender);

    }

    function release() public payable {

        if (msg.value >= address(this).balance)

            msg.sender.transfer(address(this).balance);

    }

}
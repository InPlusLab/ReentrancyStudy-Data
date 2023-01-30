/**

 *Submitted for verification at Etherscan.io on 2019-02-10

*/



pragma solidity ^0.4.25;  



contract GetsBurned {



    function () public payable {

    }



    function BurnMe () {

        selfdestruct(address(this));

    }

}
/**

 *Submitted for verification at Etherscan.io on 2018-10-12

*/



pragma solidity ^0.4.25;



contract Balance {

    function getBalance(address a) public view returns (uint) {

        return a.balance;

    }

}
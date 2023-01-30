/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.21;

contract SL{

    uint public A;

    address public S;

    function ADEP() public{

        A++;

        S = msg.sender;

    }

    function () payable public{}

    function N() public payable{

        ADEP();

    }

}
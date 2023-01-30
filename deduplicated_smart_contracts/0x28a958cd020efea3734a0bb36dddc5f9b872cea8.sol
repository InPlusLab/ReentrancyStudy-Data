/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.23;



contract dynamictest{

    uint public a;

    uint public b;

    function test(uint foo) public {

        if (tx.gasprice > foo){

            a=1;

            return;

        }

        if (tx.gasprice < foo){

            a=1;

            b=1;

            return;

        }

    }

}
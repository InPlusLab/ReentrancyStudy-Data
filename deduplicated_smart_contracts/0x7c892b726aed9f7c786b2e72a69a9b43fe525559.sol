/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.0;

contract Counter {

    int private count = 0;

    function incrementCounter() public {

        count += 1;

    }

    function decrementCounter() public {

        count -= 1;

    }

    function getCount() public constant returns (int) {

        return count;

    }

}
/**

 *Submitted for verification at Etherscan.io on 2019-01-06

*/



pragma solidity ^0.5.2;

contract Smartcontract_counter {

    int private count = 0;

    function incrementCounter() public {

        count += 1;

    }

    function decrementCounter()public {

        count -= 1;

    }

    function getCount() public view returns (int) {

        return count;

    }

}
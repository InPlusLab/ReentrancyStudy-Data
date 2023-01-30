/**

 *Submitted for verification at Etherscan.io on 2019-03-25

*/



pragma solidity ^0.5.0;



contract A {

    B public myB = new B();

}



contract B {

    function getBlock() public view returns (uint256) {

        return block.timestamp;

    }

}
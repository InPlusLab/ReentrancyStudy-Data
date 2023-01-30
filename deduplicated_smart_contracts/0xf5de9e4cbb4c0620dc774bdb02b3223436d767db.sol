/**

 *Submitted for verification at Etherscan.io on 2019-06-04

*/



pragma solidity ^0.5.0;



contract Counter {

   uint256 c;



   constructor() public {

       c = 1;

   }   

   function inc() external {

        c = c + 1;

   }

   function get() public view returns (uint256)  {

       return c;

   }

}
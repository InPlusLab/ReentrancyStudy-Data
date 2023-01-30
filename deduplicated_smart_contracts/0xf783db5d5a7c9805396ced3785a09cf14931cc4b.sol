/**

 *Submitted for verification at Etherscan.io on 2019-05-24

*/



pragma solidity ^0.4.25;



contract Hello {

    string greeting;



     constructor() public {

        greeting = "hello";

     }



     function getGreeting() public view returns (string) {

        return greeting;

     }



     function setGreeting(string _greeting) public {

        greeting = _greeting;

     }

}
/**

 *Submitted for verification at Etherscan.io on 2018-08-10

*/



pragma solidity ^0.4.23;



contract HelloWorld {

    function sayHello() public pure returns (string) {

        return ("Hello World!");

    }



    function kill()  public {

        selfdestruct(address(this));

    }

}
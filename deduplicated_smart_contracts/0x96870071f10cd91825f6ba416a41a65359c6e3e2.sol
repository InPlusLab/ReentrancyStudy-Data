/**

 *Submitted for verification at Etherscan.io on 2019-03-25

*/



pragma solidity 0.5.6;



contract A {

    uint256 private number;

    

    function getNumber() public view returns (uint256) {

        return number;

    }

}



contract B {

    function newA() public returns(address) {

        A newInstance = new A();

        return address(newInstance);

    }

}
/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity 0.4.25;

contract testabi {

    uint c;

    function tinhtong(uint a, uint b) public {

        c = a+b;

    } 

    function ketqua() public view returns (uint) {

        return c;

    }

}
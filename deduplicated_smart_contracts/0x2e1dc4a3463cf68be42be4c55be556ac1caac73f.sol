/**

 *Submitted for verification at Etherscan.io on 2018-11-03

*/



pragma solidity ^0.4.24;



contract CodeSize {

    function codeSize(address addr) public view returns (uint) {

        uint size;

        assembly { size := extcodesize(addr) }

        return size;

    }

}
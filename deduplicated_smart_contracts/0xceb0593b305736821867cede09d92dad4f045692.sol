/**

 *Submitted for verification at Etherscan.io on 2018-11-06

*/



pragma solidity ^0.4.21;

contract test {

    uint256 public answer;

    constructor(){

    answer = uint256(keccak256(block.blockhash(1)))%10000;

    }

}
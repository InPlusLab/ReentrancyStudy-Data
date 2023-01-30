/**

 *Submitted for verification at Etherscan.io on 2019-03-27

*/



pragma solidity ^0.5.1;



contract ProofOfAddress {

    mapping (address=>string) public proofs;



    function register(string memory kinAddress) public{

        proofs[msg.sender] = kinAddress;

    }

}
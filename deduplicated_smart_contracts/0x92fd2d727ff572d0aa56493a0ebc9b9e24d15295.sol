/**

 *Submitted for verification at Etherscan.io on 2019-01-23

*/



pragma solidity ^0.5.3;



contract Storage {

    uint public pos0;

    mapping(address => uint) public pos1;

    mapping(uint => mapping(uint => uint)) public pos2;

    bytes32 public pos3;

    

    constructor() public{

        pos0 = 0x1234;



        pos1[0x1F4E7Db8514Ec4E99467a8d2ee3a63094a904e7A] = 0x5678;

        pos1[0x1234567890123456789012345678901234567890] = 0x8765;

        

        pos2[0x111][0x222] = 0x9101112;

        pos2[0x333][0x444] = 0x13141516;



        pos3 = keccak256(abi.encode());

    }

}
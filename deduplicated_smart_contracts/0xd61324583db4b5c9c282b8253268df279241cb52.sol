/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity ^0.5.1;



contract MerkleIO {

    address public owner = msg.sender;

    mapping(bytes32 => uint256) public hashes; // hash => timestamp

    

    event Hashed(bytes32 indexed hash, uint256 timestamp); // logit

    

    function store(bytes32 hash) external { // store hash

        assert(msg.sender == owner);

    

        hashes[hash] = block.timestamp;

        

        emit Hashed(hash, block.timestamp);

    }

    

    function changeOwner(address ownerNew) external {

        assert(msg.sender == owner);

        

        owner = ownerNew;

    }

}
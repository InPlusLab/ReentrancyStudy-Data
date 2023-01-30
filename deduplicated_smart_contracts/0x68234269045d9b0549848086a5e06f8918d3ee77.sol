/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

// File: contracts/commons/StorageUnit.sol

pragma solidity ^0.5.10;


contract StorageUnit {
    address private owner;
    mapping(bytes32 => bytes32) private store;

    constructor() public {
        owner = msg.sender;
    }

    function write(bytes32 _key, bytes32 _value) external {
        /* solium-disable-next-line */
        require(msg.sender == owner);
        store[_key] = _value;
    }

    function read(bytes32 _key) external view returns (bytes32) {
        return store[_key];
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-10-25
*/

pragma solidity ^0.7.4;

contract ZippieREG {
    mapping(address => mapping(uint256 => bytes)) public latest;
    
    function publish(uint256 stream, bytes memory cid) public {
        latest[msg.sender][stream] = cid;
    }
}
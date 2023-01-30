/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.5.9;

contract CodeHash {
    function soul(address usr) public view returns (bytes32 tag)
    {
        assembly { tag := extcodehash(usr) }
    }
}
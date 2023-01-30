/**
 *Submitted for verification at Etherscan.io on 2019-07-03
*/

pragma solidity ^0.4.24;

contract Registry {
    string public ownerName;
    address public ownerAddress;
    string public registryInfo;
    
    constructor(string memory on, string memory ri) public {
        ownerName = on;
        ownerAddress = msg.sender;
        registryInfo = ri;
    }
    
    function changeOwner(string memory newOwnerName, address newOwnerAddress) public {
        if(msg.sender==ownerAddress) {
            ownerName = newOwnerName;
            newOwnerAddress = ownerAddress;
        }
    }
    
    function changeRegistryInfo(string memory newRegistryInfo) public {
        if(msg.sender==ownerAddress) {
            registryInfo = newRegistryInfo;
        }
    }
}
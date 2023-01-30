/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.0;

contract Hash {

    string ipfsHash;
    string DescriptionHash;
    string FileData;

    constructor() {
        ipfsHash;
        DescriptionHash;
        FileData;
    }
    
    function setHash(
        string memory _ipfsHash,
        string memory _DescriptionHash,
        string memory _FileData
    ) public {
        ipfsHash = _ipfsHash;
        DescriptionHash = _DescriptionHash;
        FileData = _FileData;
    }

    function getIpfs() public view returns (string memory) {
        return ipfsHash;
    }

    function getDescription() public view returns (string memory) {
        return DescriptionHash;
    }

    function getFileData() public view returns (string memory) {
        return FileData;
    }
}
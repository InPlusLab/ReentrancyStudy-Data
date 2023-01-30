/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

pragma solidity ^0.5.9;


contract StoredBatches {

    struct Batch {
        string ipfsHash;
    }

    event Update(string ipfsHash);

    address protocol;

    constructor() public {
        protocol = msg.sender;
    }

    modifier onlyProtocol() {
        if (msg.sender == protocol) {
            _;
        }
    }

    Batch[] public batches;


    /// Option to reduce gas usage: https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes
    function registerBatch(string memory _ipfsHash) public onlyProtocol {
        batches.push(Batch(_ipfsHash));
        emit Update(_ipfsHash);
    }
}
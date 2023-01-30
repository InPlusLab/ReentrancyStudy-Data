/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

pragma solidity 0.5.11;

contract picOneCommitment {
    
    // We will use following block number's hash as second sha256. The block is not mined yet
    uint256 blockNumber = 8526184;
    
    // The hash of the chain's last element is following
    string hash= "b583bcbe34fa8b22c5c14f1200b0f87acab35333ce8d960cf72d6b1d6ad2b3bf";
    
    uint256 private deployedAt = now;
    
    function getDeployedAt() public view returns (uint256) {
        return deployedAt;
    }
    
    function getHash() public view returns (string memory) {
        return hash;
    }
       
    function getBlockNumber() public view returns (uint256) {
        return blockNumber;
    } 
    
}
pragma solidity ^0.5.8;

contract BlobHasher {
    bytes32 public shaHash;
    function hash(bytes memory blob) public {
        shaHash = sha256(blob);
    }
}

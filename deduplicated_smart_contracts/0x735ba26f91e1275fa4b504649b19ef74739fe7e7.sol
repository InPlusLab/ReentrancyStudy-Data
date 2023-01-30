contract SHA3_512 {
   function hash(uint64[8]) pure public returns(uint32[16]) {}
}

contract TeikhosBounty {

    SHA3_512 public sha3_512 = SHA3_512(0xbD6361cC42fD113ED9A9fdbEDF7eea27b325a222); // Mainnet: 0xbD6361cC42fD113ED9A9fdbEDF7eea27b325a222, 
                                                                                     // Rinkeby: 0x2513CF99E051De22cEB6cf5f2EaF0dc4065c8F1f

    struct Commit {
        uint timestamp;
        bytes signature;
    }    

    mapping(address => Commit) public commitment;

    struct Solution {
        uint timestamp;
        bytes publicKey; // The key that solves the bounty, empty until the correct key has been submitted with authenticate()
        bytes32 msgHash;
    }    

    Solution public isSolved;
    
    struct Winner {
        uint timestamp;
        address winner;
    }

    Winner public winner;

    enum State { Commit, Reveal, Payout }
    
    modifier inState(State _state)
    {
        if(_state == State.Commit) { require(isSolved.timestamp == 0); }
        if(_state == State.Reveal) { require(isSolved.timestamp != 0 && now < isSolved.timestamp + 7 days); }
        if(_state == State.Payout) { require(isSolved.timestamp != 0 && now > isSolved.timestamp + 7 days); }
        _;
    }

    // Proof-of-public-key in format 2xbytes32, to support xor operator and ecrecover r, s v format

    struct PoPk {
      bytes32 half1;
      bytes32 half2;
    }

    PoPk public proof_of_public_key;
    
    function TeikhosBounty() public { // Constructor funciton, runs when contract is deployed
        proof_of_public_key.half1 = hex"ad683919450048215e7c10c3dc3ffca5939ec8f48c057cfe385c7c6f8b754aa7";
        proof_of_public_key.half2 = hex"4ce337445bdc24ee86d6c2460073e5b307ae54cdef4b196c660d5ee03f878e81";
    }

    function commit(bytes _signature) public inState(State.Commit) {
        require(commitment[msg.sender].timestamp == 0);
        commitment[msg.sender].signature = _signature;
        commitment[msg.sender].timestamp = now;
    }

    function reveal() public inState(State.Reveal) returns (bool success) {
        bytes memory signature = commitment[msg.sender].signature;
        require(signature.length != 0);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        r := mload(add(signature,0x20))
        s := mload(add(signature,0x40))
        v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) v += 27;

        if(ecrecover(isSolved.msgHash, v, r, s) == msg.sender) {

            success = true; // The correct solution was submitted

            if(winner.timestamp == 0 || commitment[msg.sender].timestamp < winner.timestamp) {
                winner.winner = msg.sender;
                winner.timestamp = commitment[msg.sender].timestamp;
            }
        }
        delete commitment[msg.sender];

        return success;
    }

    function reward() public inState(State.Payout) {
        selfdestruct(winner.winner);
    }

    function authenticate(bytes _publicKey) public inState(State.Commit) {
                
        bytes memory keyHash = getHash(_publicKey);
         
        // Split hash of public key in 2xbytes32, to support xor operator and ecrecover r, s v format

        bytes32 hash1;
        bytes32 hash2;

        assembly {
        hash1 := mload(add(keyHash,0x20))
        hash2 := mload(add(keyHash,0x40))
        }

        // Use xor (reverse cipher) to get signature in r, s v format
        bytes32 r = proof_of_public_key.half1 ^ hash1;
        bytes32 s = proof_of_public_key.half2 ^ hash2;

        // Get msgHash for use with ecrecover
        bytes32 msgHash = keccak256("\x19Ethereum Signed Message:\n64", _publicKey);

        // Get address from public key
        address signer = address(keccak256(_publicKey));

        // The value v is not known, try both 27 and 28
        if(ecrecover(msgHash, 27, r, s) == signer || ecrecover(msgHash, 28, r, s) == signer ) {
            isSolved.timestamp = now;
            isSolved.publicKey = _publicKey; 
            isSolved.msgHash = msgHash;

            require(reveal() == true); // The correct solution has to have been commited, 
                                       // prevents funds from getting locked in the contract
        }
    }

   // A separate method getHash() for converting bytes to uint64[8], which is done since the EVM cannot pass bytes between contracts
   // The SHA3_512 logic is in a separate contract to make it easier to read, that contract could be audited on its own, and so on

   function getHash(bytes _message) view internal returns (bytes messageHash) {

        // Use SHA3_512 library to get a sha3_512 hash of public key

        uint64[8] memory input;

        // The evm is big endian, have to reverse the bytes

        bytes memory reversed = new bytes(64);

        for(uint i = 0; i < 64; i++) {
            reversed[i] = _message[63 - i];
        }

        for(i = 0; i < 8; i++) {
            bytes8 oneEigth;
            // Load 8 byte from reversed public key at position 32 + i * 8
            assembly {
                oneEigth := mload(add(reversed, add(32, mul(i, 8)))) 
            }
            input[7 - i] = uint64(oneEigth);
        }

        uint32[16] memory output = sha3_512.hash(input);
        
        bytes memory toBytes = new bytes(64);
        
        for(i = 0; i < 16; i++) {
            bytes4 oneSixteenth = bytes4(output[15 - i]);
            // Store 4 byte in keyHash at position 32 + i * 4
            assembly { mstore(add(toBytes, add(32, mul(i, 4))), oneSixteenth) }
        }

        messageHash = new bytes(64);

        for(i = 0; i < 64; i++) {
            messageHash[i] = toBytes[63 - i];
        }   
   }
   
   // Make it possible to send ETH to the contract with "payable" on the fallback function
   
    function() public payable {}

}
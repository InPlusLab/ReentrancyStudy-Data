/**
 *Submitted for verification at Etherscan.io on 2019-06-12
*/

pragma solidity ^0.4.19;

// Interface contract to be implemented by SyscoinToken
contract SyscoinTransactionProcessor {
    function processTransaction(uint txHash, uint value, address destinationAddress, uint32 _assetGUID, address superblockSubmitterAddress) public returns (uint);
    function burn(uint _value, uint32 _assetGUID, bytes syscoinWitnessProgram) payable public returns (bool success);
}

// Bitcoin transaction parsing library - modified for SYSCOIN

// Copyright 2016 rain <https://keybase.io/rain>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// https://en.bitcoin.it/wiki/Protocol_documentation#tx
//
// Raw Bitcoin transaction structure:
//
// field     | size | type     | description
// version   | 4    | int32    | transaction version number
// n_tx_in   | 1-9  | var_int  | number of transaction inputs
// tx_in     | 41+  | tx_in[]  | list of transaction inputs
// n_tx_out  | 1-9  | var_int  | number of transaction outputs
// tx_out    | 9+   | tx_out[] | list of transaction outputs
// lock_time | 4    | uint32   | block number / timestamp at which tx locked
//
// Transaction input (tx_in) structure:
//
// field      | size | type     | description
// previous   | 36   | outpoint | Previous output transaction reference
// script_len | 1-9  | var_int  | Length of the signature script
// sig_script | ?    | uchar[]  | Script for confirming transaction authorization
// sequence   | 4    | uint32   | Sender transaction version
//
// OutPoint structure:
//
// field      | size | type     | description
// hash       | 32   | char[32] | The hash of the referenced transaction
// index      | 4    | uint32   | The index of this output in the referenced transaction
//
// Transaction output (tx_out) structure:
//
// field         | size | type     | description
// value         | 8    | int64    | Transaction value (Satoshis)
// pk_script_len | 1-9  | var_int  | Length of the public key script
// pk_script     | ?    | uchar[]  | Public key as a Bitcoin script.
//
// Variable integers (var_int) can be encoded differently depending
// on the represented value, to save space. Variable integers always
// precede an array of a variable length data type (e.g. tx_in).
//
// Variable integer encodings as a function of represented value:
//
// value           | bytes  | format
// <0xFD (253)     | 1      | uint8
// <=0xFFFF (65535)| 3      | 0xFD followed by length as uint16
// <=0xFFFF FFFF   | 5      | 0xFE followed by length as uint32
// -               | 9      | 0xFF followed by length as uint64
//
// Public key scripts `pk_script` are set on the output and can
// take a number of forms. The regular transaction script is
// called 'pay-to-pubkey-hash' (P2PKH):
//
// OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
//
// OP_x are Bitcoin script opcodes. The bytes representation (including
// the 0x14 20-byte stack push) is:
//
// 0x76 0xA9 0x14 <pubKeyHash> 0x88 0xAC
//
// The <pubKeyHash> is the ripemd160 hash of the sha256 hash of
// the public key, preceded by a network version byte. (21 bytes total)
//
// Network version bytes: 0x00 (mainnet); 0x6f (testnet); 0x34 (namecoin)
//
// The Bitcoin address is derived from the pubKeyHash. The binary form is the
// pubKeyHash, plus a checksum at the end.  The checksum is the first 4 bytes
// of the (32 byte) double sha256 of the pubKeyHash. (25 bytes total)
// This is converted to base58 to form the publicly used Bitcoin address.
// Mainnet P2PKH transaction scripts are to addresses beginning with '1'.
//
// P2SH ('pay to script hash') scripts only supply a script hash. The spender
// must then provide the script that would allow them to redeem this output.
// This allows for arbitrarily complex scripts to be funded using only a
// hash of the script, and moves the onus on providing the script from
// the spender to the redeemer.
//
// The P2SH script format is simple:
//
// OP_HASH160 <scriptHash> OP_EQUAL
//
// 0xA9 0x14 <scriptHash> 0x87
//
// The <scriptHash> is the ripemd160 hash of the sha256 hash of the
// redeem script. The P2SH address is derived from the scriptHash.
// Addresses are the scriptHash with a version prefix of 5, encoded as
// Base58check. These addresses begin with a '3'.



// parse a raw Syscoin transaction byte array
library SyscoinMessageLibrary {

    uint constant p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;  // secp256k1
    uint constant q = (p + 1) / 4;

    // Error codes
    uint constant ERR_INVALID_HEADER = 10050;
    uint constant ERR_COINBASE_INDEX = 10060; // coinbase tx index within Litecoin merkle isn't 0
    uint constant ERR_NOT_MERGE_MINED = 10070; // trying to check AuxPoW on a block that wasn't merge mined
    uint constant ERR_FOUND_TWICE = 10080; // 0xfabe6d6d found twice
    uint constant ERR_NO_MERGE_HEADER = 10090; // 0xfabe6d6d not found
    uint constant ERR_NOT_IN_FIRST_20 = 10100; // chain Merkle root isn't in the first 20 bytes of coinbase tx
    uint constant ERR_CHAIN_MERKLE = 10110;
    uint constant ERR_PARENT_MERKLE = 10120;
    uint constant ERR_PROOF_OF_WORK = 10130;
    uint constant ERR_INVALID_HEADER_HASH = 10140;
    uint constant ERR_PROOF_OF_WORK_AUXPOW = 10150;
    uint constant ERR_PARSE_TX_OUTPUT_LENGTH = 10160;
    uint constant ERR_PARSE_TX_SYS = 10170;
    enum Network { MAINNET, TESTNET, REGTEST }
    uint32 constant SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN = 0x7407;
    uint32 constant SYSCOIN_TX_VERSION_BURN = 0x7401;
    // AuxPoW block fields
    struct AuxPoW {
        uint blockHash;

        uint txHash;

        uint coinbaseMerkleRoot; // Merkle root of auxiliary block hash tree; stored in coinbase tx field
        uint[] chainMerkleProof; // proves that a given Syscoin block hash belongs to a tree with the above root
        uint syscoinHashIndex; // index of Syscoin block hash within block hash tree
        uint coinbaseMerkleRootCode; // encodes whether or not the root was found properly

        uint parentMerkleRoot; // Merkle root of transaction tree from parent Litecoin block header
        uint[] parentMerkleProof; // proves that coinbase tx belongs to a tree with the above root
        uint coinbaseTxIndex; // index of coinbase tx within Litecoin tx tree

        uint parentNonce;
    }

    // Syscoin block header stored as a struct, mostly for readability purposes.
    // BlockHeader structs can be obtained by parsing a block header's first 80 bytes
    // with parseHeaderBytes.
    struct BlockHeader {
        uint32 bits;
        uint blockHash;
    }
    // Convert a variable integer into something useful and return it and
    // the index to after it.
    function parseVarInt(bytes memory txBytes, uint pos) private pure returns (uint, uint) {
        // the first byte tells us how big the integer is
        uint8 ibit = uint8(txBytes[pos]);
        pos += 1;  // skip ibit

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }
    // convert little endian bytes to uint
    function getBytesLE(bytes memory data, uint pos, uint bits) internal pure returns (uint) {
        if (bits == 8) {
            return uint8(data[pos]);
        } else if (bits == 16) {
            return uint16(data[pos])
                 + uint16(data[pos + 1]) * 2 ** 8;
        } else if (bits == 32) {
            return uint32(data[pos])
                 + uint32(data[pos + 1]) * 2 ** 8
                 + uint32(data[pos + 2]) * 2 ** 16
                 + uint32(data[pos + 3]) * 2 ** 24;
        } else if (bits == 64) {
            return uint64(data[pos])
                 + uint64(data[pos + 1]) * 2 ** 8
                 + uint64(data[pos + 2]) * 2 ** 16
                 + uint64(data[pos + 3]) * 2 ** 24
                 + uint64(data[pos + 4]) * 2 ** 32
                 + uint64(data[pos + 5]) * 2 ** 40
                 + uint64(data[pos + 6]) * 2 ** 48
                 + uint64(data[pos + 7]) * 2 ** 56;
        }
    }
    

    // @dev - Parses a syscoin tx
    //
    // @param txBytes - tx byte array
    // Outputs
    // @return output_value - amount sent to the lock address in satoshis
    // @return destinationAddress - ethereum destination address


    function parseTransaction(bytes memory txBytes) internal pure
             returns (uint, uint, address, uint32)
    {
        
        uint output_value;
        uint32 assetGUID;
        address destinationAddress;
        uint32 version;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN && version != SYSCOIN_TX_VERSION_BURN){
            return (ERR_PARSE_TX_SYS, output_value, destinationAddress, assetGUID);
        }
        pos = skipInputs(txBytes, 4);
            
        (output_value, destinationAddress, assetGUID) = scanBurns(txBytes, version, pos);
        return (0, output_value, destinationAddress, assetGUID);
    }


  
    // skips witnesses and saves first script position/script length to extract pubkey of first witness scriptSig
    function skipWitnesses(bytes memory txBytes, uint pos, uint n_inputs) private pure
             returns (uint)
    {
        uint n_stack;
        (n_stack, pos) = parseVarInt(txBytes, pos);
        
        uint script_len;
        for (uint i = 0; i < n_inputs; i++) {
            for (uint j = 0; j < n_stack; j++) {
                (script_len, pos) = parseVarInt(txBytes, pos);
                pos += script_len;
            }
        }

        return n_stack;
    }    

    function skipInputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_inputs;
        uint script_len;
        (n_inputs, pos) = parseVarInt(txBytes, pos);
        // if dummy 0x00 is present this is a witness transaction
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); // flag
            assert(n_inputs != 0x00);
            // after dummy/flag the real var int comes for txins
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs < 100);

        for (uint i = 0; i < n_inputs; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len + 4;  // skip sig_script, seq
        }

        return pos;
    }
             
    // scan the burn outputs and return the value and script data of first burned output.
    function scanBurns(bytes memory txBytes, uint32 version, uint pos) private pure
             returns (uint, address, uint32)
    {
        uint script_len;
        uint output_value;
        uint32 assetGUID = 0;
        address destinationAddress;
        uint n_outputs;
        (n_outputs, pos) = parseVarInt(txBytes, pos);
        require(n_outputs < 10);
        for (uint i = 0; i < n_outputs; i++) {
            // output
            if(version == SYSCOIN_TX_VERSION_BURN){
                output_value = getBytesLE(txBytes, pos, 64);
            }
            pos += 8;
            // varint
            (script_len, pos) = parseVarInt(txBytes, pos);
            if(!isOpReturn(txBytes, pos)){
                // output script
                pos += script_len;
                output_value = 0;
                continue;
            }
            // skip opreturn marker
            pos += 1;
            if(version == SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN){
                (output_value, destinationAddress, assetGUID) = scanAssetDetails(txBytes, pos);
            }
            else if(version == SYSCOIN_TX_VERSION_BURN){                
                destinationAddress = scanSyscoinDetails(txBytes, pos);   
            }
            // only one opreturn data allowed per transaction
            break;
        }

        return (output_value, destinationAddress, assetGUID);
    }

    function skipOutputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_outputs;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        require(n_outputs < 10);

        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len;
        }

        return pos;
    }
    // get final position of inputs, outputs and lock time
    // this is a helper function to slice a byte array and hash the inputs, outputs and lock time
    function getSlicePos(bytes memory txBytes, uint pos) private pure
             returns (uint slicePos)
    {
        slicePos = skipInputs(txBytes, pos + 4);
        slicePos = skipOutputs(txBytes, slicePos);
        slicePos += 4; // skip lock time
    }
    // scan a Merkle branch.
    // return array of values and the end position of the sibling hashes.
    // takes a 'stop' argument which sets the maximum number of
    // siblings to scan through. stop=0 => scan all.
    function scanMerkleBranch(bytes memory txBytes, uint pos, uint stop) private pure
             returns (uint[], uint)
    {
        uint n_siblings;
        uint halt;

        (n_siblings, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_siblings) {
            halt = n_siblings;
        } else {
            halt = stop;
        }

        uint[] memory sibling_values = new uint[](halt);

        for (uint i = 0; i < halt; i++) {
            sibling_values[i] = flip32Bytes(sliceBytes32Int(txBytes, pos));
            pos += 32;
        }

        return (sibling_values, pos);
    }   
    // Slice 20 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes20(bytes memory data, uint start) private pure returns (bytes20) {
        uint160 slice = 0;
        // FIXME: With solc v0.4.24 and optimizations enabled
        // using uint160 for index i will generate an error
        // "Error: VM Exception while processing transaction: Error: redPow(normalNum)"
        for (uint i = 0; i < 20; i++) {
            slice += uint160(data[i + start]) << (8 * (19 - i));
        }
        return bytes20(slice);
    }
    // Slice 32 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes32Int(bytes memory data, uint start) private pure returns (uint slice) {
        for (uint i = 0; i < 32; i++) {
            if (i + start < data.length) {
                slice += uint(data[i + start]) << (8 * (31 - i));
            }
        }
    }

    // @dev returns a portion of a given byte array specified by its starting and ending points
    // Should be private, made internal for testing
    // Breaks underscore naming convention for parameters because it raises a compiler error
    // if `offset` is changed to `_offset`.
    //
    // @param _rawBytes - array to be sliced
    // @param offset - first byte of sliced array
    // @param _endIndex - last byte of sliced array
    function sliceArray(bytes memory _rawBytes, uint offset, uint _endIndex) internal view returns (bytes) {
        uint len = _endIndex - offset;
        bytes memory result = new bytes(len);
        assembly {
            // Call precompiled contract to copy data
            if iszero(staticcall(gas, 0x04, add(add(_rawBytes, 0x20), offset), len, add(result, 0x20), len)) {
                revert(0, 0)
            }
        }
        return result;
    }
    
    
    // Returns true if the tx output is an OP_RETURN output
    function isOpReturn(bytes memory txBytes, uint pos) private pure
             returns (bool) {
        // scriptPub format is
        // 0x6a OP_RETURN
        return 
            txBytes[pos] == byte(0x6a);
    }
    // Returns syscoin data parsed from the op_return data output from syscoin burn transaction
    function scanSyscoinDetails(bytes memory txBytes, uint pos) private pure
             returns (address) {      
        uint8 op;
        (op, pos) = getOpcode(txBytes, pos);
        // ethereum addresses are 20 bytes (without the 0x)
        require(op == 0x14);
        return readEthereumAddress(txBytes, pos);
    }    
    // Returns asset data parsed from the op_return data output from syscoin asset burn transaction
    function scanAssetDetails(bytes memory txBytes, uint pos) private pure
             returns (uint, address, uint32) {
                 
        uint32 assetGUID;
        address destinationAddress;
        uint output_value;
        uint8 op;
        // vchAsset
        (op, pos) = getOpcode(txBytes, pos);
        // guid length should be 4 bytes
        require(op == 0x04);
        assetGUID = bytesToUint32(txBytes, pos);
        pos += op;
        // amount
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x08);
        output_value = bytesToUint64(txBytes, pos);
        pos += op;
         // destination address
        (op, pos) = getOpcode(txBytes, pos);
        // ethereum contracts are 20 bytes (without the 0x)
        require(op == 0x14);
        destinationAddress = readEthereumAddress(txBytes, pos);       
        return (output_value, destinationAddress, assetGUID);
    }         
    // Read the ethereum address embedded in the tx output
    function readEthereumAddress(bytes memory txBytes, uint pos) private pure
             returns (address) {
        uint256 data;
        assembly {
            data := mload(add(add(txBytes, 20), pos))
        }
        return address(uint160(data));
    }

    // Read next opcode from script
    function getOpcode(bytes memory txBytes, uint pos) private pure
             returns (uint8, uint)
    {
        require(pos < txBytes.length);
        return (uint8(txBytes[pos]), pos + 1);
    }

    // @dev - convert an unsigned integer from little-endian to big-endian representation
    //
    // @param _input - little-endian value
    // @return - input value in big-endian format
    function flip32Bytes(uint _input) internal pure returns (uint result) {
        assembly {
            let pos := mload(0x40)
            for { let i := 0 } lt(i, 32) { i := add(i, 1) } {
                mstore8(add(pos, i), byte(sub(31, i), _input))
            }
            result := mload(pos)
        }
    }
    // helpers for flip32Bytes
    struct UintWrapper {
        uint value;
    }

    function ptr(UintWrapper memory uw) private pure returns (uint addr) {
        assembly {
            addr := uw
        }
    }

    function parseAuxPoW(bytes memory rawBytes, uint pos) internal view
             returns (AuxPoW memory auxpow)
    {
        // we need to traverse the bytes with a pointer because some fields are of variable length
        pos += 80; // skip non-AuxPoW header
        uint slicePos;
        (slicePos) = getSlicePos(rawBytes, pos);
        auxpow.txHash = dblShaFlipMem(rawBytes, pos, slicePos - pos);
        pos = slicePos;
        // parent block hash, skip and manually hash below
        pos += 32;
        (auxpow.parentMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.coinbaseTxIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        (auxpow.chainMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.syscoinHashIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        // calculate block hash instead of reading it above, as some are LE and some are BE, we cannot know endianness and have to calculate from parent block header
        auxpow.blockHash = dblShaFlipMem(rawBytes, pos, 80);
        pos += 36; // skip parent version and prev block
        auxpow.parentMerkleRoot = sliceBytes32Int(rawBytes, pos);
        pos += 40; // skip root that was just read, parent block timestamp and bits
        auxpow.parentNonce = getBytesLE(rawBytes, pos, 32);
        uint coinbaseMerkleRootPosition;
        (auxpow.coinbaseMerkleRoot, coinbaseMerkleRootPosition, auxpow.coinbaseMerkleRootCode) = findCoinbaseMerkleRoot(rawBytes);
    }

    // @dev - looks for {0xfa, 0xbe, 'm', 'm'} byte sequence
    // returns the following 32 bytes if it appears once and only once,
    // 0 otherwise
    // also returns the position where the bytes first appear
    function findCoinbaseMerkleRoot(bytes memory rawBytes) private pure
             returns (uint, uint, uint)
    {
        uint position;
        bool found = false;

        for (uint i = 0; i < rawBytes.length; ++i) {
            if (rawBytes[i] == 0xfa && rawBytes[i+1] == 0xbe && rawBytes[i+2] == 0x6d && rawBytes[i+3] == 0x6d) {
                if (found) { // found twice
                    return (0, position - 4, ERR_FOUND_TWICE);
                } else {
                    found = true;
                    position = i + 4;
                }
            }
        }

        if (!found) { // no merge mining header
            return (0, position - 4, ERR_NO_MERGE_HEADER);
        } else {
            return (sliceBytes32Int(rawBytes, position), position - 4, 1);
        }
    }

    // @dev - Evaluate the merkle root
    //
    // Given an array of hashes it calculates the
    // root of the merkle tree.
    //
    // @return root of merkle tree
    function makeMerkle(bytes32[] hashes2) external pure returns (bytes32) {
        bytes32[] memory hashes = hashes2;
        uint length = hashes.length;
        if (length == 1) return hashes[0];
        require(length > 0);
        uint i;
        uint j;
        uint k;
        k = 0;
        while (length > 1) {
            k = 0;
            for (i = 0; i < length; i += 2) {
                j = i+1<length ? i+1 : length-1;
                hashes[k] = bytes32(concatHash(uint(hashes[i]), uint(hashes[j])));
                k += 1;
            }
            length = k;
        }
        return hashes[0];
    }

    // @dev - For a valid proof, returns the root of the Merkle tree.
    //
    // @param _txHash - transaction hash
    // @param _txIndex - transaction's index within the block it's assumed to be in
    // @param _siblings - transaction's Merkle siblings
    // @return - Merkle tree root of the block the transaction belongs to if the proof is valid,
    // garbage if it's invalid
    function computeMerkle(uint _txHash, uint _txIndex, uint[] memory _siblings) internal pure returns (uint) {
        uint resultHash = _txHash;
        uint i = 0;
        while (i < _siblings.length) {
            uint proofHex = _siblings[i];

            uint sideOfSiblings = _txIndex % 2;  // 0 means _siblings is on the right; 1 means left

            uint left;
            uint right;
            if (sideOfSiblings == 1) {
                left = proofHex;
                right = resultHash;
            } else if (sideOfSiblings == 0) {
                left = resultHash;
                right = proofHex;
            }

            resultHash = concatHash(left, right);

            _txIndex /= 2;
            i += 1;
        }

        return resultHash;
    }

    // @dev - calculates the Merkle root of a tree containing Litecoin transactions
    // in order to prove that `ap`'s coinbase tx is in that Litecoin block.
    //
    // @param _ap - AuxPoW information
    // @return - Merkle root of Litecoin block that the Syscoin block
    // with this info was mined in if AuxPoW Merkle proof is correct,
    // garbage otherwise
    function computeParentMerkle(AuxPoW memory _ap) internal pure returns (uint) {
        return flip32Bytes(computeMerkle(_ap.txHash,
                                         _ap.coinbaseTxIndex,
                                         _ap.parentMerkleProof));
    }

    // @dev - calculates the Merkle root of a tree containing auxiliary block hashes
    // in order to prove that the Syscoin block identified by _blockHash
    // was merge-mined in a Litecoin block.
    //
    // @param _blockHash - SHA-256 hash of a certain Syscoin block
    // @param _ap - AuxPoW information corresponding to said block
    // @return - Merkle root of auxiliary chain tree
    // if AuxPoW Merkle proof is correct, garbage otherwise
    function computeChainMerkle(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        return computeMerkle(_blockHash,
                             _ap.syscoinHashIndex,
                             _ap.chainMerkleProof);
    }

    // @dev - Helper function for Merkle root calculation.
    // Given two sibling nodes in a Merkle tree, calculate their parent.
    // Concatenates hashes `_tx1` and `_tx2`, then hashes the result.
    //
    // @param _tx1 - Merkle node (either root or internal node)
    // @param _tx2 - Merkle node (either root or internal node), has to be `_tx1`'s sibling
    // @return - `_tx1` and `_tx2`'s parent, i.e. the result of concatenating them,
    // hashing that twice and flipping the bytes.
    function concatHash(uint _tx1, uint _tx2) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(flip32Bytes(_tx1), flip32Bytes(_tx2)))))));
    }

    // @dev - checks if a merge-mined block's Merkle proofs are correct,
    // i.e. Syscoin block hash is in coinbase Merkle tree
    // and coinbase transaction is in parent Merkle tree.
    //
    // @param _blockHash - SHA-256 hash of the block whose Merkle proofs are being checked
    // @param _ap - AuxPoW struct corresponding to the block
    // @return 1 if block was merge-mined and coinbase index, chain Merkle root and Merkle proofs are correct,
    // respective error code otherwise
    function checkAuxPoW(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        if (_ap.coinbaseTxIndex != 0) {
            return ERR_COINBASE_INDEX;
        }

        if (_ap.coinbaseMerkleRootCode != 1) {
            return _ap.coinbaseMerkleRootCode;
        }

        if (computeChainMerkle(_blockHash, _ap) != _ap.coinbaseMerkleRoot) {
            return ERR_CHAIN_MERKLE;
        }

        if (computeParentMerkle(_ap) != _ap.parentMerkleRoot) {
            return ERR_PARENT_MERKLE;
        }

        return 1;
    }

    function sha256mem(bytes memory _rawBytes, uint offset, uint len) internal view returns (bytes32 result) {
        assembly {
            // Call sha256 precompiled contract (located in address 0x02) to copy data.
            // Assign to ptr the next available memory position (stored in memory position 0x40).
            let ptr := mload(0x40)
            if iszero(staticcall(gas, 0x02, add(add(_rawBytes, 0x20), offset), len, ptr, 0x20)) {
                revert(0, 0)
            }
            result := mload(ptr)
        }
    }

    // @dev - Bitcoin-way of hashing
    // @param _dataBytes - raw data to be hashed
    // @return - result of applying SHA-256 twice to raw data and then flipping the bytes
    function dblShaFlip(bytes _dataBytes) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(_dataBytes))))));
    }

    // @dev - Bitcoin-way of hashing
    // @param _dataBytes - raw data to be hashed
    // @return - result of applying SHA-256 twice to raw data and then flipping the bytes
    function dblShaFlipMem(bytes memory _rawBytes, uint offset, uint len) internal view returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256mem(_rawBytes, offset, len)))));
    }

    // @dev ¨C Read a bytes32 from an offset in the byte array
    function readBytes32(bytes memory data, uint offset) internal pure returns (bytes32) {
        bytes32 result;
        assembly {
            result := mload(add(add(data, 0x20), offset))
        }
        return result;
    }

    // @dev ¨C Read an uint32 from an offset in the byte array
    function readUint32(bytes memory data, uint offset) internal pure returns (uint32) {
        uint32 result;
        assembly {
            result := mload(add(add(data, 0x20), offset))
            
        }
        return result;
    }

    // @dev - Bitcoin-way of computing the target from the 'bits' field of a block header
    // based on http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html//ref3
    //
    // @param _bits - difficulty in bits format
    // @return - difficulty in target format
    function targetFromBits(uint32 _bits) internal pure returns (uint) {
        uint exp = _bits / 0x1000000;  // 2**24
        uint mant = _bits & 0xffffff;
        return mant * 256**(exp - 3);
    }

    uint constant SYSCOIN_DIFFICULTY_ONE = 0xFFFFF * 256**(0x1e - 3);

    // @dev - Calculate syscoin difficulty from target
    // https://en.bitcoin.it/wiki/Difficulty
    // Min difficulty for bitcoin is 0x1d00ffff
    // Min difficulty for syscoin is 0x1e0fffff
    function targetToDiff(uint target) internal pure returns (uint) {
        return SYSCOIN_DIFFICULTY_ONE / target;
    }
    

    // 0x00 version
    // 0x04 prev block hash
    // 0x24 merkle root
    // 0x44 timestamp
    // 0x48 bits
    // 0x4c nonce

    // @dev - extract previous block field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading hash from
    // @return - hash of block's parent in big endian format
    function getHashPrevBlock(bytes memory _blockHeader) internal pure returns (uint) {
        uint hashPrevBlock;
        assembly {
            hashPrevBlock := mload(add(add(_blockHeader, 32), 0x04))
        }
        return flip32Bytes(hashPrevBlock);
    }

    // @dev - extract Merkle root field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading root from
    // @return - block's Merkle root in big endian format
    function getHeaderMerkleRoot(bytes memory _blockHeader) public pure returns (uint) {
        uint merkle;
        assembly {
            merkle := mload(add(add(_blockHeader, 32), 0x24))
        }
        return flip32Bytes(merkle);
    }

    // @dev - extract timestamp field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading bits from
    // @return - block's timestamp in big-endian format
    function getTimestamp(bytes memory _blockHeader) internal pure returns (uint32 time) {
        return bytesToUint32Flipped(_blockHeader, 0x44);
    }

    // @dev - extract bits field from a raw Syscoin block header
    //
    // @param _blockHeader - Syscoin block header bytes
    // @param pos - where to start reading bits from
    // @return - block's difficulty in bits format, also big-endian
    function getBits(bytes memory _blockHeader) internal pure returns (uint32 bits) {
        return bytesToUint32Flipped(_blockHeader, 0x48);
    }


    // @dev - converts raw bytes representation of a Syscoin block header to struct representation
    //
    // @param _rawBytes - first 80 bytes of a block header
    // @return - exact same header information in BlockHeader struct form
    function parseHeaderBytes(bytes memory _rawBytes, uint pos) internal view returns (BlockHeader bh) {
        bh.bits = getBits(_rawBytes);
        bh.blockHash = dblShaFlipMem(_rawBytes, pos, 80);
    }

    uint32 constant VERSION_AUXPOW = (1 << 8);

    // @dev - Converts a bytes of size 4 to uint32,
    // e.g. for input [0x01, 0x02, 0x03 0x04] returns 0x01020304
    function bytesToUint32Flipped(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(input[pos]) + uint32(input[pos + 1])*(2**8) + uint32(input[pos + 2])*(2**16) + uint32(input[pos + 3])*(2**24);
    }
    function bytesToUint64(bytes memory input, uint pos) internal pure returns (uint64 result) {
        result = uint64(input[pos+7]) + uint64(input[pos + 6])*(2**8) + uint64(input[pos + 5])*(2**16) + uint64(input[pos + 4])*(2**24) + uint64(input[pos + 3])*(2**32) + uint64(input[pos + 2])*(2**40) + uint64(input[pos + 1])*(2**48) + uint64(input[pos])*(2**56);
    }
     function bytesToUint32(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(input[pos+3]) + uint32(input[pos + 2])*(2**8) + uint32(input[pos + 1])*(2**16) + uint32(input[pos])*(2**24);
    }  
    // @dev - checks version to determine if a block has merge mining information
    function isMergeMined(bytes memory _rawBytes, uint pos) internal pure returns (bool) {
        return bytesToUint32Flipped(_rawBytes, pos) & VERSION_AUXPOW != 0;
    }

    // @dev - Verify block header
    // @param _blockHeaderBytes - array of bytes with the block header
    // @param _pos - starting position of the block header
	// @param _proposedBlockHash - proposed block hash computing from block header bytes
    // @return - [ErrorCode, IsMergeMined]
    function verifyBlockHeader(bytes _blockHeaderBytes, uint _pos, uint _proposedBlockHash) external view returns (uint, bool) {
        BlockHeader memory blockHeader = parseHeaderBytes(_blockHeaderBytes, _pos);
        uint blockSha256Hash = blockHeader.blockHash;
		// must confirm that the header hash passed in and computing hash matches
		if(blockSha256Hash != _proposedBlockHash){
			return (ERR_INVALID_HEADER_HASH, true);
		}
        uint target = targetFromBits(blockHeader.bits);
        if (_blockHeaderBytes.length > 80 && isMergeMined(_blockHeaderBytes, 0)) {
            AuxPoW memory ap = parseAuxPoW(_blockHeaderBytes, _pos);
            if (ap.blockHash > target) {

                return (ERR_PROOF_OF_WORK_AUXPOW, true);
            }
            uint auxPoWCode = checkAuxPoW(blockSha256Hash, ap);
            if (auxPoWCode != 1) {
                return (auxPoWCode, true);
            }
            return (0, true);
        } else {
            if (_proposedBlockHash > target) {
                return (ERR_PROOF_OF_WORK, false);
            }
            return (0, false);
        }
    }

    // For verifying Syscoin difficulty
    int64 constant TARGET_TIMESPAN =  int64(21600); 
    int64 constant TARGET_TIMESPAN_DIV_4 = TARGET_TIMESPAN / int64(4);
    int64 constant TARGET_TIMESPAN_MUL_4 = TARGET_TIMESPAN * int64(4);
    int64 constant TARGET_TIMESPAN_ADJUSTMENT =  int64(360);  // 6 hour
    uint constant INITIAL_CHAIN_WORK =  0x100001; 
    uint constant POW_LIMIT = 0x00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // @dev - Calculate difficulty from compact representation (bits) found in block
    function diffFromBits(uint32 bits) external pure returns (uint) {
        return targetToDiff(targetFromBits(bits))*INITIAL_CHAIN_WORK;
    }
    
    function difficultyAdjustmentInterval() external pure returns (int64) {
        return TARGET_TIMESPAN_ADJUSTMENT;
    }
    // @param _actualTimespan - time elapsed from previous block creation til current block creation;
    // i.e., how much time it took to mine the current block
    // @param _bits - previous block header difficulty (in bits)
    // @return - expected difficulty for the next block
    function calculateDifficulty(int64 _actualTimespan, uint32 _bits) external pure returns (uint32 result) {
       int64 actualTimespan = _actualTimespan;
        // Limit adjustment step
        if (_actualTimespan < TARGET_TIMESPAN_DIV_4) {
            actualTimespan = TARGET_TIMESPAN_DIV_4;
        } else if (_actualTimespan > TARGET_TIMESPAN_MUL_4) {
            actualTimespan = TARGET_TIMESPAN_MUL_4;
        }

        // Retarget
        uint bnNew = targetFromBits(_bits);
        bnNew = bnNew * uint(actualTimespan);
        bnNew = uint(bnNew) / uint(TARGET_TIMESPAN);

        if (bnNew > POW_LIMIT) {
            bnNew = POW_LIMIT;
        }

        return toCompactBits(bnNew);
    }

    // @dev - shift information to the right by a specified number of bits
    //
    // @param _val - value to be shifted
    // @param _shift - number of bits to shift
    // @return - `_val` shifted `_shift` bits to the right, i.e. divided by 2**`_shift`
    function shiftRight(uint _val, uint _shift) private pure returns (uint) {
        return _val / uint(2)**_shift;
    }

    // @dev - shift information to the left by a specified number of bits
    //
    // @param _val - value to be shifted
    // @param _shift - number of bits to shift
    // @return - `_val` shifted `_shift` bits to the left, i.e. multiplied by 2**`_shift`
    function shiftLeft(uint _val, uint _shift) private pure returns (uint) {
        return _val * uint(2)**_shift;
    }

    // @dev - get the number of bits required to represent a given integer value without losing information
    //
    // @param _val - unsigned integer value
    // @return - given value's bit length
    function bitLen(uint _val) private pure returns (uint length) {
        uint int_type = _val;
        while (int_type > 0) {
            int_type = shiftRight(int_type, 1);
            length += 1;
        }
    }

    // @dev - Convert uint256 to compact encoding
    // based on https://github.com/petertodd/python-bitcoinlib/blob/2a5dda45b557515fb12a0a18e5dd48d2f5cd13c2/bitcoin/core/serialize.py
    // Analogous to arith_uint256::GetCompact from C++ implementation
    //
    // @param _val - difficulty in target format
    // @return - difficulty in bits format
    function toCompactBits(uint _val) private pure returns (uint32) {
        uint nbytes = uint (shiftRight((bitLen(_val) + 7), 3));
        uint32 compact = 0;
        if (nbytes <= 3) {
            compact = uint32 (shiftLeft((_val & 0xFFFFFF), 8 * (3 - nbytes)));
        } else {
            compact = uint32 (shiftRight(_val, 8 * (nbytes - 3)));
            compact = uint32 (compact & 0xFFFFFF);
        }

        // If the sign bit (0x00800000) is set, divide the mantissa by 256 and
        // increase the exponent to get an encoding without it set.
        if ((compact & 0x00800000) > 0) {
            compact = uint32(shiftRight(compact, 8));
            nbytes += 1;
        }

        return compact | uint32(shiftLeft(nbytes, 24));
    }
}
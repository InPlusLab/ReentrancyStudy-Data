/**

 *Submitted for verification at Etherscan.io on 2019-04-16

*/



//    Copyright (C) 2018 LikeCoin Foundation Limited

//

//    This file is part of LikeCoin Smart Contract.

//

//    LikeCoin Smart Contract is free software: you can redistribute it and/or modify

//    it under the terms of the GNU General Public License as published by

//    the Free Software Foundation, either version 3 of the License, or

//    (at your option) any later version.

//

//    LikeCoin Smart Contract is distributed in the hope that it will be useful,

//    but WITHOUT ANY WARRANTY; without even the implied warranty of

//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

//    GNU General Public License for more details.

//

//    You should have received a copy of the GNU General Public License

//    along with LikeCoin Smart Contract.  If not, see <http://www.gnu.org/licenses/>.



// Introduction

// 

// This smart contract (the Relay contract) acts as the gateway between LikeChain and Ethereum.

// When LikeCoin is transferred into this smart contract, the Transfer event will be received by the

// background services of LikeChain, which will then fire corresponding Deposit transaction onto

// LikeChain through Tendermint, minting LikeCoin on LikeChain.

// When someone withdraw on LikeChain, it will create a record in the Merkle tree in LikeChain.

// The Merkle root of the tree will be committed onto this smart contract periodically. Then, the user

// (or operators of LikeChain, or other third-parties) can commit the Merkle proof to prove that there

// exists such a withdraw record, releasing the LikeCoin previously transferred and locked in this contract.

//

// The main flow is as follows:

// 1. Someone calls commitWithdrawHash with a payload containing votes, app hash, Merkle proof, etc.

// 2. The contract checks if the votes from the validators are valid.

// 3. The contract extracts block hash from the votes.

// 4. The contract checks if the app hash is in the block hash by validating the Merkle proof.

// 5. If everything are fine, the contract extracts the withdraw hash from app hash.

// 6. When someone calls withdraw, the contract checks the Merkle proof from the call data to see if

//    the withdraw data is actually in the Merkle tree of the withdraw hash committed previously.

// 7. After checking, the contract transfers LikeCoin according to the withdraw info.

// 

//

// Tendermint sign bytes format:

// Tendermint runs using BFT algorithms. Every block produced is signed by >2/3 of validators before

// being a valid block.

// The signatures are signed on the SHA-256 hash of the "sign bytes" of the vote. Therefore the contract

// needs to reconstruct the sign bytes before validating the signatures.

// The sign bytes in the votes starting from Tendermint v0.26 is changed to amino encoding.

// The structure and field-order is as follows:

//

// type CanonicalVote struct {

//     Type      SignedMsgType // type alias for byte

//     Height    int64         `binary:"fixed64"`

//     Round     int64         `binary:"fixed64"`

//     Timestamp time.Time

//     BlockID   CanonicalBlockID

//     ChainID   string

// }

// 

// type CanonicalBlockID struct {

//     Hash        cmn.HexBytes

//     PartsHeader CanonicalPartSetHeader

// }

// 

// type CanonicalPartSetHeader struct {

//     Hash  cmn.HexBytes

//     Total int

// }

//

// (cmn.HexBytes is defined as []byte)

//

// Type is encoded into one single byte.

// Height and Round are encoded as 64-bit fixed-length integers, in little endian.

// Timestamp is specially handled as a struct roughly as follows:

//

// type Time struct {

//     Second int64 // Varint

//     Nanosecond int32 // Varint, ranged from 0 to 999,999,999

// }

//

// Varint encoding: (see https://developers.google.com/protocol-buffers/docs/encoding#varints)

// 

// Varint is used a lot in amino, so we will first explain the encoding of varint.

// In a varint, only the last 7 bits of a byte is used as the encoding of the integer.

// The first bit indicates whether the varint still has succeeding bytes.

// For example: 10111011 11011000 10111101 00101011

// The first byte is 10111011. The value part is 0111011. Since the first bit is 1, we still need other bytes.

// The second byte is 11011000. The value part is 1011000. Since the first bit is 1, we still need other bytes.

// The third byte is 10111101. The value part is 0111101. Since the first bit is 1, we still need other bytes.

// The fourth byte is 00101011. The value part is 0101011. Since the first bit is 0, this is the end of this varint.

// So the value of the varint will be 0111011 1011000 0111101 0101011 reversed and concatenated, which is 91188283 in decimals.

// 

// 

// In amino, structs are serialized into binary in a way similar to Protobuf.

// Basically, it is a key-value structure, where the key is the index of the field in the struct (starting from 1),

// encoeded as varint.

// For example, in CanonicalVote, Type has field index 1, Height has 2, etc. So the encoding could be decoded as a mapping:

// {

//     Field 1 => Type 2,

//     Field 2 => Height 1337,

//     Field 3 => Round 2345,

//     Field 4 => {

//         Field 1 => 1234 Seconds,

//         Field 2 => 5678 Nanoseconds

//     },

//     ...

// }

//

// If a field has default value (e.g. 0 in numbers), amino will not encode that field by default.

// Amino encodes the fields in sequential order.

//

// Typ3: (see https://developers.google.com/protocol-buffers/docs/encoding#structure)

// In addition to field index, 3 bits (called Typ3) are used in the key to indicate the length of the value:

//

// 0 - the field itself is a varint

// 1 - fixed 8-byte length

// 2 - Length prefixed (using varint)

// 5 - fixed 4-byte length (not used in CanonicalVote)

//

// For example, the Type field has field index 1, and it is encoded as varint.

// Therefore the key will be 00001|000 (Field 1, Typ3 0) = 0x08.

// The Height field has field index 2, and it is encoded as 8 byte fixed length integer.

// Therefore the key will be 00010|001 (Field 2, Typ3 1) = 0x11.

// The Timestamp field has field index 4, and it is variable length.

// Therefore the key will be 00100|010 (Field 4, Typ3 2) = 0x22.

// Timestamp will be encoded in a length-prefixed format. Therefore if the length of the encoded value of

// the timestamp is 14, then 14 will appear right after 0x22.

//

// Below is an example of sign bytes:

// 

// 0x760802110200000000000000220C08E881CADF0510E8A9E088032A480A2042288B2C20A42426A9E80F2B6D7BAA7DCEC8F7DC5B63FF5360CE8B9B7C78B5DE12240A2052F24411779931CCF793D9C222B48EFB63C034CCACBB336B655FCB3F331EBCF310013211746573742D636861696E2D77467A62616B

// 

// which is disassembled below:

//

// 76 # length of the sign bytes (in varint, not including the length field itself), which is 0x76 = 118 bytes

//     08 # 00001000 = 00001|000 = Field 1 (Type), Typ3 0 (varint)

//         02 # value of Type field = 2

//     11 # 00010001 = 00010|001 = Field 2 (Height), Typ3 1 (8 bytes)

//         0200000000000000 # value of Height field (in int64, little endian) = 2

//     22 # 00100010 = 00100|010 = Field 4 (Timestamp), Typ3 2 (length prefixed) (note that Field 3 (Round) is missing, hence the value is default value, which is 0)

//         0C # length of the Timestamp field = 0x0C = 12

//             08 # 00001000 = 00001|000 = Field 1 (Timestamp.Second), Typ3 0 (varint)

//                 E881CADF05 # value of the Timestamp.Second field = 11101000 10000001 11001010 11011111 00000101, actual value = 0000101 1011111 1001010 0000001 1101000 = 1542619368

//             10 # 00010000 = 00010|000 = Field 2 (Timestamp.Nanosecond), Typ3 0 (varint)

//                 E8A9E08803 # value of the Timestamp.Nanosecond field = 11101000 10101001 11100000 10001000 00000011, actual value = 0000011 0001000 1100000 0101001 1101000 = 823661800

//     2A # 00101010 = 00101|010 = Field 5 (BlockID), Typ3 2 (length prefixed)

//         48 # length of the BlockID field = 0x48 = 72

//             0A # 00001010 = 00001|010 = Field 1 (BlockID.Hash), Typ3 2 (length prefixed)

//                 20 # length of the BlockID.Hash field = 0x20 = 32

//                     42288B2C20A42426A9E80F2B6D7BAA7DCEC8F7DC5B63FF5360CE8B9B7C78B5DE # Value of the BlockID.Hash field

//             12 # 00010010 = 00010|010 = Field 2 (BlockID.PartsHeader), Typ3 2 (length prefixed)

//                 24 # length of the BlockID.Hash field = 0x24 = 36

//                     0A # 00001010 = 00001|010 = Field 1 (BlockID.PartsHeader.Hash), Typ3 2 (length prefixed)

//                         20 # length of the BlockID.PartsHeader.Hash field = 0x20 = 32

//                             52F24411779931CCF793D9C222B48EFB63C034CCACBB336B655FCB3F331EBCF3 # Value of the BlockID.PartsHeader.Hash field

//                     10 # 00010000 = 00010|000 = Field 2 (BlockID.PartsHeader.Total), Typ3 0 (varint)

//                         01 # value of BlockID.PartsHeader.Total field = 1

//     32 # 00110010 = 00110|010 = Field 6 (ChainID), Typ3 2 (length prefixed)

//         11 # length of the ChainID field = 0x11 = 17

//             746573742D636861696E2D77467A62616B # value of the ChainID field = "test-chain-wFzbak"

//

// A few points to note:

// 1. Every field except the Timestamp field in the sign bytes should be the same among all the votes of the validators on the same block number

// 2. Timestamp has varint, therefore could affect the length of the sign bytes, and also the offsets of the fields afterwards

// 3. After confirming the offset of the BlockID part, the offset of t he block hash could also be confirmed, since every hash has fixed length 32

//

// Application hash:

// In Tendermint, the application logic is defined by developer. The state of the application is reported

// to Tendermint by application hash (app hash).

// LikeChain defines the app hash as the concatenation of 2 hashes: withdraw hash and state hash.

// Withdraw hash is the Merkle root of a tree containing info which the Relay contract should know.

// State hash is the Merkle root of the tree containing the remaining states.

// The reason of splitting them into 2 trees is to reduce the length of Merkle proof when doing withdraw.

// 

// The app hash will be in the block header of a block. The fields in the block header will be aggregated

// into a simple Merkle tree, which the tree root will be the block hash. Therefore we can use a Merkle proof

// to prove that the app hash is really inside the header with specific block hash.

//

// Details could be found at https://github.com/tendermint/tendermint/blob/master/types/block.go#L388

//

//

// Payload encoding to the contract:

// The encoding of the votes onto the contract is as follows:

// 1. the Height and Round are passed onto the contract by function parameters directly

// 2. the remaining parts are encoded into a big bytes

// 3. by the Height and Round, we can construct the parts before Timestamp (Type is fixed as 2)

// 4. for every validators in this block, Timestamp and the signature is encoded

// 5. the remaining parts after Timestamp (called "suffix") is encoded

// 6. the Merkle proof for proving the app hash in the block hash is encoded

//

// The structure is like this:

//

// type AppHashContractProof struct {

// 	Height     uint64

// 	Round      uint64

// 	Payload struct {

// 		SuffixLen  uint8

// 		Suffix     []byte

// 		VotesCount uint8

// 		Votes      []struct {

// 			TimeLen uint8

// 			Time    []byte

// 			Sig     [65]byte

// 		}

// 		AppHashLen   uint8

// 		AppHash      []byte

// 		AppHashProof [4][32]byte

// 	}

// }

//

// We assume that the total length of the sign bytes are <= 127, so uint8 could be used as varint prefix.

// The length restriction could be calculated as follows:

//

// Type: 1 byte field number + 1 byte value = 2 bytes

// Height: 1 byte field numnber + 8 bytes value = 9 bytes

// Round: 1 byte field numnber + 8 bytes value = 9 bytes

// Timestamp: 1 byte field numnber + 1 byte length +

//           1 byte field number + 6 bytes varint second (at most 43 bits, enough for ~278,731 years since 1970) +

//           1 byte field number + 5 bytes varint nanosecond (at most 36 bits, enough since maximum value is 999,999,999, which is < 2^36)

// = 15 bytes

// BlockID: 1 byte field numnber + 1 byte length +

//              1 byte field number + 1 byte length + 32 bytes value +

//              1 byte field number + 1 bytes length +

//                  1 byte field number + 1 byte length + 32 byte value +

//                  1 byte field number + 1 byte value

// = 74 bytes

// ChainID: 1 byte field numnber + 1 byte length + n bytes value = (n + 2) bytes

// Total = 111 + n bytes

// 

// So we have 111 + n <= 127, which means ChainID should have length <= 16.

// In practice, Timestamp is shorter than the maximum (until ~year 4140), and Round usually have default value 0,

// therefore the restriction is not that strict, but should still be considered.

//

//

//  

// IAVL RangeProof:

// In IAVL tree, RangeProof is used to prove that a range of values ("sibling" leaves) are inside the tree.

// It is also possible to prove that a value is absent in the tree, by proving a range is in the tree and the

// value should appear in that range if it is present.

// In this contract, we are only using RangeProof with only one leaf.

//

// The definition of RangeProof struct is as follows:

// (See https://github.com/tendermint/iavl/blob/master/proof_range.go#L216 for source code)

//

// type RangeProof struct {

// 	// You don't need the right path because

// 	// it can be derived from what we have.

// 	LeftPath   PathToLeaf      `json:"left_path"`

// 	InnerNodes []PathToLeaf    `json:"inner_nodes"`

// 	Leaves     []proofLeafNode `json:"leaves"`

//

// 	// memoize

// 	rootVerified bool

// 	rootHash     []byte // valid iff rootVerified is true

// 	treeEnd      bool   // valid iff rootVerified is true

//

// }

//

// type PathToLeaf []proofInnerNode

//

// type proofInnerNode struct {

// 	Height  int8   `json:"height"`

// 	Size    int64  `json:"size"`

// 	Version int64  `json:"version"`

// 	Left    []byte `json:"left"`

// 	Right   []byte `json:"right"`

// }

//

// type proofLeafNode struct {

// 	Key       cmn.HexBytes `json:"key"`

// 	ValueHash cmn.HexBytes `json:"value"`

// 	Version   int64        `json:"version"`

// }

//

// In case of there is only one leaf in the RangeProof, InnerNodes will be empty and Leaves will only contain one node.

// In this case, the procedure of computing root hash is as follows:

// 

// 1. Encode leaf node in binary.

//   1.1. Encode Height (0) as int8 (one single byte).

//   1.2. Encode Size (1) as varint.

//        (note that it is an integer, which could be negative, and is encoded in zigzag encoding in varint, so positive

//        number n will be encoded as 2n, i.e. 0x02 is used for encoding 1)

//   1.3. Encode Version as varint.

//   1.4. Encode Key by prefixing length in varint, then encode the bytes.

//   1.5. Encode ValueHash by prefixing length in varint, then encode the bytes.

// 2. Hash the encoded binary by SHA-256 to get current hash.

// 3. Repeatedly mix inner nodes (from bottom to up) into current hash to update current hash, until reaching the top.

//   3.1. Encode Height as int8 (one single byte).

//   3.2. Encode Size as varint.

//   3.3. Encode Version as varint.

//   3.4. Encode current hash and one of Left or Right. (One of Left or Right must be empty)

//     3.4.1. If Left is empty, then first encode current hash (prefix length), then encode Right (prefix length).

//     3.4.2. If Right is empty, then first encode Left (prefix length), then encode current hash (prefix length).

//

// Payload encoding to the contract:

// The proof has 2 parts: leaf and inner nodes.

// For leaf, only the version is needed. However, since it is varint, we also need to know the length of the version field.

// For inner nodes, we need to know all the info, plus whether current hash should be Left or Right, to decide the hashing order.

// There we need to encode the followings:

//

// 1. Length of leaf Version

// 2. Leaf version

// 3. Number of inner nodes

// 4. Inner nodes

//   4.1. Length of all the parts except Left or Right. This part is called "prefix".

//   4.2. One bit for indicating whether current hash should be Left or Right.

//   4.3. The prefix

//   4.4. The Left or Right in the inner node. This is called "sibling".

//

// Further investigation shows that the prefix part of inner nodes will never exceed 127 bytes.

// Therefore the "one bit" is encoded together with the prefix length.

// The final format is as follows:

//

// type ContractIAVLTreeProof struct {

// 	VersionLength    uint8

// 	LeafVersionBytes []byte

// 	PathLength       uint8

// 	Path             []struct {

// 		PrefixLengthAndOrder uint8 // first bit indicates the node is left or right

// 		Prefix               []byte

// 		Sibling              []byte

// 	}

// }













pragma solidity ^0.4.25;



// Source: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/5471fc808a17342d738853d7bf3e9e5ef3108074/contracts/token/ERC20/IERC20.sol

// Copied here to avoid incompatibility with Solidity v0.5.x in latest master branch



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}





contract LikeChainRelayLogicInterface {

    function commitWithdrawHash(uint64 height, uint64 round, bytes _payload) public;

    function updateValidator(address[] _newValidators, bytes _proof) public;

    function withdraw(bytes _withdrawInfo, bytes _proof) public;

    function upgradeLogicContract(address _newLogicContract, bytes _proof) public;

    event Upgraded(uint256 _newLogicContractIndex, address _newLogicContract);

}



contract LikeChainRelayState {

    uint256 public logicContractIndex;

    address public logicContract;



    IERC20 public tokenContract;



    address[] public validators;

    

    struct ValidatorInfo {

        uint8 index;

        uint32 power;

    }

    

    mapping(address => ValidatorInfo) public validatorInfo;

    uint256 public totalVotingPower;

    uint public lastValidatorUpdateTime;



    uint public latestBlockHeight;

    bytes32 public latestWithdrawHash;



    mapping(bytes32 => bool) public consumedIds;

    mapping(bytes32 => bytes32) public reserved;

}



contract LikeChainRelayLogic is LikeChainRelayState, LikeChainRelayLogicInterface {

    constructor(address[] _validators, uint32[] _votingPowers, address _tokenContract) public {

        uint len = _validators.length;

        require(len > 0);

        require(len < 256);

        require(_votingPowers.length == len);



        for (uint8 i = 0; i < len; i += 1) {

            address v = _validators[i];

            require(validatorInfo[v].power == 0);

            uint32 power = _votingPowers[i];

            require(power > 0);

            validators.push(v);

            validatorInfo[v] = ValidatorInfo({

                index: i,

                power: power

            });

            totalVotingPower += power;

        }

        

        tokenContract = IERC20(_tokenContract);

    }

    

    function _proofRootHash(bytes32 _key, bytes32 _value, bytes _proof) internal view returns (bytes32 rootHash) {

        assembly {

            let start := mload(0x40)

            let p := start

            let curHashStart := add(start, 128)

            let data := add(_proof, 33) // 32 byte length + 1 byte reserved

            

            let len := and(mload(sub(data, 31)), 0xff) // version length

            if gt(len, 9) { revert(0, 0) } // version is uint64, so the varint encoded should never longer than 9 bytes

            data := add(data, 1)

            mstore(p, hex"0002")

            p := add(p, 2)

            mstore(p, mload(data))

            data := add(data, len)

            p := add(p, len)

            mstore8(p, 32) // amino length-prefixed encoding for []byte (length 32)

            p := add(p, 1)

            mstore(p, _key)

            p := add(p, 32)

            mstore8(p, 32) // amino length-prefixed encoding for []byte (length 32)

            p := add(p, 1)

            mstore(p, _value)

            p := add(p, 32)

            let _ := staticcall(gas, 2, start, sub(p, start), curHashStart, 32)

            

            len := and(mload(sub(data, 31)), 0xff) // number of path nodes

            data := add(data, 1)

            for { let i := len } gt(i, 0) { i := sub(i, 1) } {

                p := start

                len := and(mload(sub(data, 31)), 0xff) // 1 bit left-right indicator, 7 bits length

                let order := and(len, 0x80)

                len := and(len, 0x7f)

                if gt(len, 19) { revert(0, 0) } // 1-byte height (< 128) + 9-byte 64-bit varint-encoded numbers * 2

                data := add(data, 1)

                mstore(p, mload(data))

                p := add(p, len)

                data := add(data, len)

                switch order

                case 0 {

                    mstore8(p, 32) // amino length-prefixed encoding for []byte

                    p := add(p, 1)

                    mstore(p, mload(curHashStart))

                    p := add(p, 32)

                    mstore8(p, 32) // amino length-prefixed encoding for []byte

                    p := add(p, 1)

                    mstore(p, mload(data))

                    p := add(p, 32)

                } default {

                    mstore8(p, 32) // amino length-prefixed encoding for []byte

                    p := add(p, 1)

                    mstore(p, mload(data))

                    p := add(p, 32)

                    mstore8(p, 32) // amino length-prefixed encoding for []byte

                    p := add(p, 1)

                    mstore(p, mload(curHashStart))

                    p := add(p, 32)

                }

                data := add(data, 32)

                _ := staticcall(gas, 2, start, sub(p, start), curHashStart, 32)

            }

            len := mload(_proof)

            if gt(sub(data, add(_proof, 32)), len) {

                revert(0, 0)

            }

            rootHash := mload(curHashStart)

        }

        return rootHash;

    }

    

    // See https://tendermint.com/docs/spec/blockchain/blockchain.html#lastcommit

    function commitWithdrawHash(uint64 height, uint64 round, bytes _payload) public {

        // Memory layout:

        // 0..127: sign bytes

        // 128..: temporary storage e.g. computing mapping storage position by hash, recovering address

        assembly {

            // The n bytes are at the beginning of a 32-byte word, with zeros following

            function getNByte(p, n) -> bs {

                if gt(n, 32) {

                    revert(0, 0)

                }

                let numberOfOnes := mul(n, 8)

                let numberOfZeros := sub(256, numberOfOnes)

                // mask == 111111...11100000...000, with (8*n) 1s and (256 - 8*n) 0s

                let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

                mask := xor(mask, sub(exp(2, numberOfZeros), 1))

                bs := and(mload(p), mask)

            }

            

            // The byte is at the end of a 32-byte word

            function getOneByte(p) -> b {

                // b := and(mload(sub(p, 31)), 0xFF)

                b := byte(0, mload(p))

            }

            

            // Takes the height and round, reconstruct the prefix part of the amino-encoded sign bytes,

            // which contains type (0x02), height, round

            function reconstructPrefix(p, height, round) -> next {

                mstore8(p, 0x00) // place-holder for length prefix

                p := add(p, 1)

                mstore8(p, 0x08) // field number for `type`

                p := add(p, 1)

                mstore8(p, 0x02) // value for `precommit` type

                p := add(p, 1)

                if gt(height, 0) {

                    mstore8(p, 0x11) // field number for `height`

                    p := add(p, 1)

                    for { let i := 0 } lt(i, 8) { i := add(i, 1) } {

                        mstore8(p, mod(height, 0x100))

                        height := div(height, 0x100)

                        p := add(p, 1)

                    }

                }

                if gt(round, 0) {

                    mstore8(p, 0x19) // field number for `round`

                    p := add(p, 1)

                    for { let i := 0 } lt(i, 8) { i := add(i, 1) } {

                        mstore8(p, mod(round, 0x100))

                        height := div(round, 0x100)

                        p := add(p, 1)

                    }

                }

                next := p

            }

            

            function extractBlockHash(suffix) -> blockHash {

                blockHash := mload(add(suffix, 4))

            }

            

            // Note that copy is done in words, so the last word may overwrite some bytes

            function memcpy(dst, src, len) {

                let dstEnd := add(dst, len)

                for { } lt(dst, dstEnd) { dst := add(dst, 32) src := add(src, 32) } {

                    mstore(dst, mload(src))

                }

            }

            

            // 1. copy `timeLength` bytes from `timeSource` to `timeStart`

            // 2. copy `suffixLength` bytes from `suffixSource` to the location next to time

            // 3. calculate the total length of the content and write to starting position

            function reconstructSignBytes(p, timeStart, time, timeLen, suffixSrc, suffixLen) -> end {

                let start := p

                mstore(timeStart, time)

                p := add(timeStart, timeLen)

                memcpy(p, suffixSrc, suffixLen)

                end := add(p, suffixLen)

                let len := sub(end, add(start, 1))

                mstore8(start, len)

            }

            

            function getVoter(p, timeStart, suffixSrc, suffixLen) -> voter, next {

                let msgStart := mload(0x40)

                let timeLen := getOneByte(p)

                if gt(timeLen, 15) { revert(0, 0) }

                p := add(p, 1)

                let time := getNByte(p, timeLen)

                p := add(p, timeLen)

                let msgEnd := reconstructSignBytes(msgStart, timeStart, time, timeLen, suffixSrc, suffixLen)

                

                // ecrecover precompiled contract

                // Contract address: 1

                // Input: bytes32 hash, uint v, bytes32 r, bytes32 s

                // Output: address signer



                let buf := add(msgStart, 128)

                let _ := staticcall(gas, 2, msgStart, sub(msgEnd, msgStart), buf, 32) // SHA-256 hash, at buf[0:32]

                mstore(add(buf, 32), getOneByte(p)) // v at buf[32:64]

                p := add(p, 1)

                mstore(add(buf, 64), mload(p)) // r at buf[64:96]

                p := add(p, 32)

                mstore(add(buf, 96), mload(p)) // s at buf[96:128]

                p := add(p, 32)

                let succ := staticcall(gas, 1, buf, 128, buf, 32)

                if iszero(succ) {

                    revert(0, 0)

                }

                voter := mload(buf)

                next := p

            }

            

            // For layout of mapping, see

            // https://solidity.readthedocs.io/en/v0.4.24/miscellaneous.html#layout-of-state-variables-in-storage

            function getVoterInfo(addr) -> index, power {

                let buf := add(mload(0x40), 128)

                mstore(buf, addr)

                mstore(add(buf, 32), validatorInfo_slot)

                let slot := keccak256(buf, 64)

                let votingInfo := sload(slot)

                if eq(votingInfo, 0) {

                    revert(0, 0)

                }

                index := and(votingInfo, 0xFF)

                power := and(div(votingInfo, 0x100), 0xFFFFFFFF)

            }

            

            function accumulateVoterPower(voter, votedSet, power) -> newVotedSet, newPower {

                let voterIndex, voterPower := getVoterInfo(voter)

                let mask := exp(2, voterIndex)

                if iszero(eq(0, and(votedSet, mask))) {

                    revert(0, 0)

                }

                newVotedSet := or(votedSet, mask)

                newPower := add(power, voterPower)

            }

            

            function checkVotes(p, height, round) -> blockHash, next {

                let votedSet := 0

                let voterPower := 0

                

                let suffixLen := getOneByte(p)

                if gt(suffixLen, 92) { revert(0, 0) }

                p := add(p, 1)

                let suffixSrc := p

                p := add(p, suffixLen)

                blockHash := extractBlockHash(suffixSrc)

                

                let msgStart := mload(0x40)

                let timeStart := reconstructPrefix(msgStart, height, round)

                

                let votesCount := getOneByte(p)

                p := add(p, 1)

                for {} gt(votesCount, 0) { votesCount := sub(votesCount, 1) } {

                    let voter

                    voter, p := getVoter(p, timeStart, suffixSrc, suffixLen)

                    votedSet, voterPower := accumulateVoterPower(voter, votedSet, voterPower)

                }

                // Need strictly more than 2/3 of total voting power

                if iszero(gt(mul(voterPower, 3), mul(sload(totalVotingPower_slot), 2))) {

                    revert(0, 0)

                }

                next := p

            }

            

            // The blockHash is the Merkle root of 16 fields (including AppHash) in the block header.

            // Therefore we can use a Merkle proof to prove the appHash is in the block header.

            // The Merkle root is computed as follows:

            // 1. Each field is amino-encoded into a []byte. For []byte, it is done by prefixing len(bs).

            // 2. The resulting []byte will be hashed again to get a leaf node in the Merkle tree.

            // 3. Each pair of leaf nodes are amino-encoded and concated, then hashed into the parent of these 2 nodes.

            // 4. Repeat the process until reaching the root, which will be blockHash.

            //

            // So to verify the Merkle proof of the "App" field, the contract needs to:

            // 1. hash "\x{appHashLen}{appHashLen-byte-appHash}" to get the leaf node for AppHash

            // 2. Hash "\x20{leaf-node}\x20{proof-1}" to get new leaf node.

            // 3. Hash "\x20{leaf-node}\x20{proof-2}" to get new leaf node.

            // 4. Hash "\x20{proof-3}\x20{leaf-node}" to get new leaf node.

            // 5. Hash "\x20{proof-4}\x20{leaf-node}" to get root hash.

            // 6. Check if the root hash equals to blockHash

            //

            // Then the first 32 bytes of the AppHash will be extracted as the withdrawHash.

            function extractAndProofWithdrawHash(p, blockHash) -> withdrawHash {

                let buf := mload(0x40)

                let aminoEncodedAppHashLen := add(getOneByte(p), 1)

                // No need to `p := add(p, 1)`, as the amino-encoded appHash needs length prefix

                memcpy(buf, p, aminoEncodedAppHashLen)

                withdrawHash := mload(add(p, 1))

                p := add(p, aminoEncodedAppHashLen)

                

                let left := add(buf, 1)

                let right := add(buf, 34)

                // 1. hash "\x{appHashLen}{appHashLen-byte-appHash}" to get the leaf node for AppHash

                let _ := staticcall(gas, 2, buf, aminoEncodedAppHashLen, left, 32)

                // 2. Hash "\x20{leaf-node}\x20{proof-1}" to get new leaf node.

                mstore8(sub(left, 1), 32)

                mstore8(sub(right, 1), 32)

                mstore(right, mload(p))

                p := add(p, 32)

                _ := staticcall(gas, 2, buf, 66, left, 32)

                // 3. Hash "\x20{leaf-node}\x20{proof-2}" to get new leaf node.

                mstore(right, mload(p))

                p := add(p, 32)

                _ := staticcall(gas, 2, buf, 66, right, 32)

                // 4. Hash "\x20{proof-3}\x20{leaf-node}" to get new leaf node.

                mstore(left, mload(p))

                p := add(p, 32)

                _ := staticcall(gas, 2, buf, 66, right, 32)

                // 5. Hash "\x20{proof-4}\x20{leaf-node}" to get root hash.

                mstore(left, mload(p))

                p := add(p, 32)

                _ := staticcall(gas, 2, buf, 66, buf, 32)

                // 6. Check if the root hash equals to blockHash

                if iszero(eq(blockHash, mload(buf))) {

                    revert(0, 0)

                }

            }

            

            if iszero(gt(height, sload(latestBlockHeight_slot))) {

                revert(0, 0)

            }

            let blockHash

            let p := add(_payload, 32)

            blockHash, p := checkVotes(p, height, round)

            let withdrawHash := extractAndProofWithdrawHash(p, blockHash)

            sstore(latestBlockHeight_slot, height)

            sstore(latestWithdrawHash_slot, withdrawHash)

        }

    }



    // In the IAVL tree, the key is the hash of the withdraw information ({ from, to, value, fee, nonce }) and the value is

    // 0x01 (only as an indicator of key existence). Therefore the proving process is as follows:

    // 1. reconstruct key from { from, to, value, fee, nonce }

    // 2. pack lead node: [0, 1, leafVersionBytes, key, sha256(0x01)]

    //    (Note that the `1` is encoded as signed varint, so is 0x02 in binary. See line 275 for details)

    // 3. hash packed output to get current hash

    // 4. repeat the followings:

    //    1. extract prefixBytes and suffixBytes

    //    2. pack [prefixBytes, currentHash, suffixBytes]

    //    3. hash packed output and update current hash

    // 5. output current hash as root hash

    // 6. check if root hash from the proof is equal to the withdraw hash recorded previously from commitWithdrawHash

    

    function _proofAndExtractWithdraw(bytes _withdrawInfo, bytes _proof) internal returns (address to, uint256 value, uint256 fee) {

        bytes32 id = sha256(_withdrawInfo);

        require(!consumedIds[id]);

        consumedIds[id] = true;

        bytes32 proofValueHash = hex"4bf5122f344554c53bde2ebb8cd2b7e3d1600ad631c385a5d7cce23c7785459a"; // sha256 of hex"01"

        bytes32 rootHash = _proofRootHash(id, proofValueHash, _proof);

        require(rootHash == latestWithdrawHash);

        assembly {

            to := mload(add(_withdrawInfo, 40))

            value := mload(add(_withdrawInfo, 72))

            fee := mload(add(_withdrawInfo, 104))

        }

        return (to, value, fee);

    }



    function withdraw(bytes _withdrawInfo, bytes _proof) public {

        address to;

        uint256 value;

        uint256 fee;

        (to, value, fee) = _proofAndExtractWithdraw(_withdrawInfo, _proof);

        tokenContract.transfer(msg.sender, fee);

        tokenContract.transfer(to, value);

    }



    function updateValidator(address[] _newValidators, bytes _proof) public {

        // TODO

    }

    

    // 1. reconstruct key by the format sha256("exec{big-endian encoded 64-bit contract index})"

    // 2. get value hash by sha256(contract address)

    // 3. prove that the key-value pair is in withdraw tree

    // 4. update the contract and contract index

    function upgradeLogicContract(address _newLogicContract, bytes _proof) public {

        logicContractIndex += 1;

        bytes12 keyBeforeHash = bytes12(uint96(bytes12("exec")) | uint96(logicContractIndex));

        bytes32 key = sha256(abi.encodePacked(keyBeforeHash));

        bytes32 proofValueHash = sha256(abi.encodePacked(_newLogicContract));

        bytes32 rootHash = _proofRootHash(key, proofValueHash, _proof);

        require(rootHash == latestWithdrawHash);

        logicContract = _newLogicContract;

        emit Upgraded(logicContractIndex, _newLogicContract);

    }

}
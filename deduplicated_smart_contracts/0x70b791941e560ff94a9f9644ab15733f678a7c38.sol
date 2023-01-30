/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity 0.5.11;

// test div overflow by zzh

contract testdiv {
    int256 public n256;
    int128 public n128;
    int64 public n64;
    int32 public n32;
    int16 public n16;
    int8 public n8;
    
    constructor() public {
        int256 a256 = int256(2**255);
        int256 b256 = int256(-1);
        n256 = a256 / b256;
        int128 a128 = int128(2**127);
        int128 b128 = int128(-1);
        n128 = a128 / b128;
        int64 a64 = int64(2**63);
        int64 b64 = int64(-1);
        n64 = a64 / b64;
        int32 a32 = int32(2**31);
        int32 b32 = int32(-1);
        n32 = a32 / b32;
        int16 a16 = int16(2**15);
        int16 b16 = int16(-1);
        n16 = a16 / b16;
        int8 a8 = int8(2**7);
        int8 b8 = int8(-1);
        n8 = a8 / b8;
    }
}
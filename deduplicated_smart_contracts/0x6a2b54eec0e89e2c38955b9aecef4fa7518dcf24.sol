/**
 *Submitted for verification at Etherscan.io on 2019-12-30
*/

pragma solidity ^0.5.0;

contract shortContract3 {
    int256 constant public INT256_MIN = int256(uint256(1) << 255);
    int256 constant public INT256_MAX = int256(~(uint256(1) << 255));
    uint256 constant public UINT256_MIN = 0;
    uint256 constant public UINT256_MAX = ~uint256(0);
}
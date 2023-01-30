/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

pragma solidity ^0.5.11;


contract Expression {
  function evaluate(uint256 x) external pure returns (uint256) {
    if (x >= 2e25) revert("OUT_OF_RANGE");
    uint256 result = 1e50;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    result = result * x / 2e25;
    return result / 488281250000000000000000;
  }
}
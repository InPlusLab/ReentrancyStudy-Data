/**
 *Submitted for verification at Etherscan.io on 2021-06-22
*/

pragma solidity >=0.4.0 <0.6.0;

contract SimpleStorage {
  uint storedData;

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
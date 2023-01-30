/**

 *Submitted for verification at Etherscan.io on 2019-03-19

*/



pragma solidity ^0.5.0;

contract SimpleStorage {
  uint storedData;

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
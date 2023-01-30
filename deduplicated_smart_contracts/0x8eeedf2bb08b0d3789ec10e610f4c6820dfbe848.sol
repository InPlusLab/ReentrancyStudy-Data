/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

pragma solidity ^0.5.0;

contract IGST2 {
  function transfer(address recipient, uint256 amount) external returns (bool);

  function mint(uint256 amount) external;
}

contract GSTStrategy {
  IGST2 public igst2 = IGST2(0x0000000000b3F879cb30FE243b4Dfee438691c04);

  function mint(address recipient, uint256 amount) public {
    igst2.mint(amount);
    igst2.transfer(recipient, amount);
  }
}
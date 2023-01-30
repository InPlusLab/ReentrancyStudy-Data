pragma solidity ^0.6.4;

import "./BrightID.sol";

contract Sponsor {
  BrightID public brightID;
  bytes32 public context;

  constructor(BrightID _brightID, bytes32 _context) public {
    brightID = _brightID;
    context = _context;
  }

  // sponsor any address that sends a transaction to this contract.
  function sponsor() public payable {
    brightID.sponsor(context, bytes32(uint(msg.sender)));
  }
}

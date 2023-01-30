/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

pragma solidity >=0.4.21 <0.7.0;

contract Sponsor {
  address public brightID;
  bytes32 public context;

  event NewSponsorship(string context, address _sender);

  constructor(address _brightID,bytes32 _context) public {
    brightID = _brightID;
    context = _context;
  }

  // sponser any address that sends a transaction to this contract.
  function sponsor() public payable {
    bytes memory payload = abi.encodeWithSignature("sponsor(bytes32,bytes32)", context,bytes32(uint256(msg.sender)));
    (bool success, bytes memory returnData) = address(brightID).call(payload);
    require(success);
  }
}
/**
 *Submitted for verification at Etherscan.io on 2020-04-01
*/

pragma solidity >=0.4.21 <0.7.0;

contract Sponsor {
  address public brightID;
  string public context;

  event NewSponsorship(string context, address _sender);

  constructor(address _brightID,string memory _context) public {
    brightID = _brightID;
    context = _context;
  }

  function stringToBytes32(string memory source) private returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
          return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
  }

  // sponser any address that sends a transaction to this contract.
  function sponsor() public payable {
    bytes memory payload = abi.encodeWithSignature("sponsor(bytes32,bytes32)", stringToBytes32("ethereum"),bytes32(uint256(msg.sender)));
    (bool success, bytes memory returnData) = address(brightID).call(payload);
    require(success);

    emit NewSponsorship(context, msg.sender);
  }
}
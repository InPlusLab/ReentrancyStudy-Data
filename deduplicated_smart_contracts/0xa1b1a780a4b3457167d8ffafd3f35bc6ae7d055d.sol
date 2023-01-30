/**

 *Submitted for verification at Etherscan.io on 2019-05-19

*/



pragma solidity ^0.5.8;



contract KeyCup  {

  function generateQR(string memory salt) public view returns (bytes32 hash) {

    hash = keccak256(abi.encodePacked(address(this),msg.sender, salt));

  }

  function hashQRCode(bytes32 qr, uint256 pin) public pure returns (bytes32 hash) {

    hash = keccak256(abi.encodePacked(qr, pin));

  }

}
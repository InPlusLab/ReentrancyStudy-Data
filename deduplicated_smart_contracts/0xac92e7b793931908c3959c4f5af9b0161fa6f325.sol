/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



pragma solidity ^0.5.0;



contract Pgp {

  mapping(address => string) public addressToPublicKey;



  function addPublicKey(string calldata publicKey) external {

    addressToPublicKey[msg.sender] = publicKey;

  }

  

  function revokePublicKey() external {

      delete addressToPublicKey[msg.sender];

  }

}
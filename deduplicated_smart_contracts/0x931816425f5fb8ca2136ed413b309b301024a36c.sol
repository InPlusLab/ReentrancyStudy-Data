/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.0;

contract Origin {

function getOriginAddress(bytes32 signedMessage, uint8 v, bytes32 r, bytes32 s) constant returns(address) {

  bytes memory prefix = "\x19Ethereum Signed Message:\n32";

  bytes32 prefixedHash = keccak256(prefix, signedMessage);

  return ecrecover(prefixedHash, v, r, s);

}

}
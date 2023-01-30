/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

pragma solidity ^0.4.24;
contract SPCVerification {
  function recover(bytes32 hash, bytes signature)
    public
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;
    if (signature.length != 65) {
      return (address(0));
    }
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }
    if (v < 27) {
      v += 27;
    }
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            bytes32 prefixedHash = sha3(prefix, hash);
         return ecrecover(prefixedHash, v, r, s);
    }
  }
}
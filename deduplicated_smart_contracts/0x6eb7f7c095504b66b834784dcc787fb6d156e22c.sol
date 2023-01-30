// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;


/**
 * @dev Because we use the code hashes of the proxy contracts for proxy address
 * derivation, it is important that other packages have access to the correct
 * values when they import the salt library.
 */
library CodeHashes {
  bytes32 internal constant ONE_TO_ONE_CODEHASH = 0xdf533b6e999d326280ce88ca39ea2eddf95ed96f6c153ed5642d9b0a95dba4a2;
  bytes32 internal constant MANY_TO_ONE_CODEHASH = 0x8fb4522edc5e0645a7ae5cfdbfe3b34d4a14de9e0279b74da795856b5ef4f1e6;
  bytes32 internal constant IMPLEMENTATION_HOLDER_CODEHASH = 0xfc7aed17e5c5d36a15e443235cb9c59bae4a013202cde6ab3e657fa1176d7f3e;
}
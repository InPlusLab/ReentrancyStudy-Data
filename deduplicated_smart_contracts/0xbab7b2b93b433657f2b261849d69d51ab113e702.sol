// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.2;


contract StakingRelayVerifier {
    event RelayAddressVerified(uint160 eth_addr, int8 workchain_id, uint256 addr_body);

    function verify_relay_staker_address(int8 workchain_id, uint256 address_body) external {
        emit RelayAddressVerified(uint160(msg.sender), workchain_id, address_body);
    }
}

{
  "evmVersion": "istanbul",
  "libraries": {},
  "metadata": {
    "bytecodeHash": "ipfs",
    "useLiteralContent": true
  },
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "remappings": [],
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}
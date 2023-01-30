/**
 *Submitted for verification at Etherscan.io on 2019-09-20
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface ERC1271 {
  function isValidSignature(
    bytes calldata data, 
    bytes calldata signature
  ) external view returns (bytes4 magicValue);
}


interface DharmaKeyRegistryInterface {
  function getKeyForUser(address account) external view returns (address key);
}


library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


/**
 * @title DharmaKeyRegistryV1Mimic
 * @author 0age
 * @notice This contract will require that the provided signature resolves to
 * the key set for a smart wallet on the Dharma Key Registry when it is set as
 * the address of a user's signing key.
 */
contract DharmaKeyRegistryV1Mimic is ERC1271 {
  using ECDSA for bytes32;

  // The Dharma Key Registry holds a public key for verifying meta-transactions.
  DharmaKeyRegistryInterface internal constant _DHARMA_KEY_REGISTRY = (
    DharmaKeyRegistryInterface(0x000000005D7065eB9716a410070Ee62d51092C98)
  );

  // ERC-1271 must return this magic value when `isValidSignature` is called.
  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue) {
    (bytes32 hash, , ) = abi.decode(data, (bytes32, uint8, bytes));

    require(
      hash.recover(signature) == _DHARMA_KEY_REGISTRY.getKeyForUser(msg.sender),
      "Supplied signature does not resolve to the required signer."
    );

    magicValue = _ERC_1271_MAGIC_VALUE;
  }
}
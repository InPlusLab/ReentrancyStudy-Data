/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity 0.5.11;


interface DharmaKeyRingImplementationV0Interface {
  enum AdminActionType {
    AddStandardKey,
    RemoveStandardKey,
    SetStandardThreshold,
    AddAdminKey,
    RemoveAdminKey,
    SetAdminThreshold,
    AddDualKey,
    RemoveDualKey,
    SetDualThreshold
  }

  function takeAdminAction(
    AdminActionType adminActionType, uint160 argument, bytes calldata signatures
  ) external;
}


/**
 * @title DharmaLocksmithV0
 * @author 0age
 * @notice This contract provides a helper function for setting new keys on a V0
 * Dharma Key Ring.
 */
contract DharmaLocksmithV0 {
  /**
   * @notice Set a new signing key on a keyring using an existing signature on
   * the key ring.
   * @param keyRing address The key ring to set the new user signing key on.
   * @param newUserSigningKey address The new user signing key.
   * @param signature bytes The signature, validated from an existing key and
   * signed using a valid message hash.
   */
  function setAdditionalKey(
    address keyRing, address newUserSigningKey, bytes calldata signature
  ) external {
    // Ensure that a key ring has been provided.
    require(keyRing != address(0), "No key ring supplied.");

    // Add the new key by providing it as an argument to the key ring.
    DharmaKeyRingImplementationV0Interface(keyRing).takeAdminAction(
      DharmaKeyRingImplementationV0Interface.AdminActionType.AddDualKey,
      uint160(newUserSigningKey),
      signature
    );
  }
}
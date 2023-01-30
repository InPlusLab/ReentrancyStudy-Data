/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface DharmaUpgradeInformationInterface { 
  function getSmartWalletImplementation() external view returns (
    address smartWalletImplementation
  );

  function getKeyRingImplementation() external view returns (
    address keyRingImplementation
  );
 
  function getSmartWalletVersion() external view returns (
    uint256 smartWalletVersion
  );

  function getKeyRingVersion() external view returns (uint256 keyRingVersion);

  function getSmartWalletUpgradeBeacon() external pure returns (
    address smartWalletUpgradeBeacon
  );

  function getKeyRingUpgradeBeacon() external pure returns (
    address keyRingUpgradeBeacon
  );
}


interface DharmaImplementationVersionInterface {
  function getVersion() external pure returns (uint256 version);
}


/**
 * @title DharmaUpgradeInformation
 * @author 0age
 * @notice This contract provides convenience getters for retrieving the current
 * implementation and version of the Dharma Smart Wallet and the Dharma Key Ring
 * and for retrieving the address of the upgrade beacon for each.
 */
contract DharmaUpgradeInformation is DharmaUpgradeInformationInterface {
  address private constant _SMART_WALLET_UPGRADE_BEACON = address(
    0x000000000026750c571ce882B17016557279ADaa
  );

  address private constant _KEY_RING_UPGRADE_BEACON = address(
    0x0000000000BDA2152794ac8c76B2dc86cbA57cad
  );
  
  function getSmartWalletImplementation() external view returns (
    address smartWalletImplementation
  ) {
    smartWalletImplementation = _getImplementation(_SMART_WALLET_UPGRADE_BEACON);
  }

  function getKeyRingImplementation() external view returns (
    address keyRingImplementation
  ) {
    keyRingImplementation = _getImplementation(_KEY_RING_UPGRADE_BEACON);
  }
 
  function getSmartWalletVersion() external view returns (
    uint256 smartWalletVersion
  ) {
    smartWalletVersion = _getVersion(_SMART_WALLET_UPGRADE_BEACON);
  }

  function getKeyRingVersion() external view returns (uint256 keyRingVersion) {
    keyRingVersion = _getVersion(_KEY_RING_UPGRADE_BEACON);
  }

  function getSmartWalletUpgradeBeacon() external pure returns (
    address smartWalletUpgradeBeacon
  ) {
    smartWalletUpgradeBeacon = _SMART_WALLET_UPGRADE_BEACON;
  }

  function getKeyRingUpgradeBeacon() external pure returns (
    address keyRingUpgradeBeacon
  ) {
    keyRingUpgradeBeacon = _KEY_RING_UPGRADE_BEACON;
  }

  function _getImplementation(address beacon) internal view returns (
    address implementation
  ) {
    // Perform the staticcall into the supplied upgrade beacon.
    (, bytes memory returnData) = beacon.staticcall("");

    // Decode the address from the returned data and return it to the caller.
    implementation = abi.decode(returnData, (address));
  }
  
  function _getVersion(address beacon) internal view returns (uint256 version) {
    version = DharmaImplementationVersionInterface(
      _getImplementation(beacon)
    ).getVersion();
  }
}
/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


/**
 * @title DharmaUpgradeBeaconPrototypeSmartWallet
 * @author 0age
 * @notice This contract holds the address of the current implementation for
 * Dharma smart wallets and lets a controller update that address in storage.
 */
contract DharmaUpgradeBeaconPrototypeSmartWallet {
  // The implementation address is held in storage slot zero.
  address private _implementation;

  // The controller that can update the implementation is set as a constant.
  address private constant _CONTROLLER = address(
    0x00000000003284ACb9aDEb78A2dDe0A8499932b9
  );

  /**
   * @notice In the fallback function, allow only the controller to update the
   * implementation address - for all other callers, return the current address.
   * Note that this requires inline assembly, as Solidity fallback functions do
   * not natively take arguments or return values.
   */
  function () external {
    // Return implementation address for all callers other than the controller.
    if (msg.sender != _CONTROLLER) {
      // Load implementation from storage slot zero into memory and return it.
      assembly {
        mstore(0, sload(0))
        return(0, 32)
      }
    } else {
      // Set implementation - put first word in calldata in storage slot zero.
      assembly { sstore(0, calldataload(0)) }
    }
  }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;

import "@indexed-finance/proxies/contracts/interfaces/IDelegateCallProxyManager.sol";


interface IPoolFactory {
/* ========== Events ========== */

  event NewPool(address pool, address controller, bytes32 implementationID);

/* ========== Mutative ========== */

  function approvePoolController(address controller) external;

  function disapprovePoolController(address controller) external;

  function deployPool(bytes32 implementationID, bytes32 controllerSalt) external returns (address);

/* ========== Views ========== */

  function proxyManager() external view returns (IDelegateCallProxyManager);

  function isApprovedController(address) external view returns (bool);

  function getPoolImplementationID(address) external view returns (bytes32);

  function isRecognizedPool(address pool) external view returns (bool);

  function computePoolAddress(
    bytes32 implementationID,
    address controller,
    bytes32 controllerSalt
  ) external view returns (address);
}
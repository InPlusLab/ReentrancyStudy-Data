pragma solidity ^0.5.11;

import "./Lockdrop.sol";
import "./EdgewareSignalProxy.sol";

/// @dev Proxy factory that makes it easy to originate new SignalProxy contracts
// on the ethereum blockchain. Keeps track of the admin address associated with each
// proxy contract and enforces a 1:1 mapping of admin address:proxy.
contract EdgewareSignalProxyFactory {

  /// Mapping of admin address to proxy contract
  mapping(address => EdgewareSignalProxy) public proxies;

  /// @dev Originate a new proxy factory. All parameters are passed to the
  /// the SignalProxy constructor.
  /// see: SignalProxyFactoy constructor.
  function newProxy(
    Lockdrop _lockdrop,
    address _fundSrc,
    address payable _fundDst,
    bytes memory _edgewareAddr
  ) public {
    // Enforce a 1:1 mapping otherwise we loose track of proxy contracts
    require(address(proxies[msg.sender]) == address(0), "Duplicate admin key not permitted");

    // Originate our signal proxy
    EdgewareSignalProxy proxy = new EdgewareSignalProxy(
      _lockdrop,
      _fundSrc,
      _fundDst,
      msg.sender,
      _edgewareAddr
    );

    // Store the admin address:proxy mapping
    proxies[msg.sender] = proxy;
  }
}
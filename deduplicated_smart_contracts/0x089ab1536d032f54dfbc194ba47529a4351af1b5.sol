pragma solidity ^0.5.0;

import "./UpgradeabilityProxy.sol";


/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  // Storage position of the owner of the contract
  bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

  /**
  * @dev the constructor sets the original owner of the contract to the sender account.
  */
  constructor(address _implementation) public {
    _setUpgradeabilityOwner(msg.sender);
    _upgradeTo(_implementation);
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  /**
  * @dev Tells the address of the owner
  * @return the address of the owner
  */
  function proxyOwner() public view returns (address owner) {
    bytes32 position = PROXY_OWNER_POSITION;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      owner := sload(position)
    }
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param _newOwner The address to transfer ownership to.
  */
  function transferProxyOwnership(address _newOwner) public onlyProxyOwner {
    require(_newOwner != address(0));
    _setUpgradeabilityOwner(_newOwner);
    emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
  }

  /**
  * @dev Allows the proxy owner to upgrade the current version of the proxy.
  * @param _implementation representing the address of the new implementation to be set.
  */
  function upgradeTo(address _implementation) public onlyProxyOwner {
    _upgradeTo(_implementation);
  }

  /**
   * @dev Sets the address of the owner
  */
  function _setUpgradeabilityOwner(address _newProxyOwner) internal {
    bytes32 position = PROXY_OWNER_POSITION;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      sstore(position, _newProxyOwner)
    }
  }
}

pragma solidity ^0.5.0;

import "./Proxy.sol";


/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
  /**
  * @dev This event will be emitted every time the implementation gets upgraded
  * @param implementation representing the address of the upgraded implementation
  */
  event Upgraded(address indexed implementation);

  // Storage position of the address of the current implementation
  bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

  /**
  * @dev Constructor function
  */
  // solhint-disable-next-line no-empty-blocks
  constructor() public {}

  /**
  * @dev Tells the address of the current implementation
  * @return address of the current implementation
  */
  function implementation() public view returns (address impl) {
    bytes32 position = IMPLEMENTATION_POSITION;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      impl := sload(position)
    }
  }

  /**
  * @dev Sets the address of the current implementation
  * @param _newImplementation address representing the new implementation to be set
  */
  function _setImplementation(address _newImplementation) internal {
    bytes32 position = IMPLEMENTATION_POSITION;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      sstore(position, _newImplementation)
    }
  }

  /**
  * @dev Upgrades the implementation address
  * @param _newImplementation representing the address of the new implementation to be set
  */
  function _upgradeTo(address _newImplementation) internal {
    address currentImplementation = implementation();
    require(currentImplementation != _newImplementation);
    _setImplementation(_newImplementation);
    emit Upgraded(_newImplementation);
  }
}

pragma solidity ^0.5.0;


/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  // solhint-disable-next-line no-complex-fallback
  function() external payable {
    address _impl = implementation();
    require(_impl != address(0));

    // solhint-disable-next-line no-inline-assembly
    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 {revert(ptr, size)}
      default {return (ptr, size)}
    }
  }

  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}
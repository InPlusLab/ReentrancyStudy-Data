pragma solidity >=0.4.21 <0.6.0;

import "./TokenStorage.sol";
import "./UpgradeabilityProxy.sol";
import './Ownable.sol';

/**
* @title TokenProxy
* @notice A proxy contract that serves the latest implementation of TokenProxy.
*/
contract TokenProxy is UpgradeabilityProxy, Ownable {
    TokenStorage private dataStore;


    constructor(address _implementation, address storageAddress)
    UpgradeabilityProxy(_implementation)
    public {
        _owner = msg.sender;
        dataStore = TokenStorage(storageAddress);
    }

    /**
    * @dev Upgrade the backing implementation of the proxy.
    * Only the admin can call this function.
    * @param newImplementation Address of the new implementation.
    */
    function upgradeTo(address newImplementation) public onlyOwner {
        _upgradeTo(newImplementation);
    }

    /**
    * @return The address of the implementation.
    */
    function implementation() public view returns (address) {
        return _implementation();
    }
}
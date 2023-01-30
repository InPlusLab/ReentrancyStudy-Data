pragma solidity ^0.6.4;

import "DPiggyBaseProxy.sol";
import "DPiggyAssetData.sol";

/**
 * @title DPiggyAssetProxy
 * @dev A proxy contract for dPiggy asset.
 * It must inherit first from DPiggyBaseProxy contract for properly works.
 * The stored data is on DPiggyAssetData contract.
 */
contract DPiggyAssetProxy is DPiggyBaseProxy, DPiggyAssetData {
    constructor(
        address _admin, 
        address _implementation, 
        bytes memory data
    ) public payable DPiggyBaseProxy(_admin, _implementation, data) {
    } 
}
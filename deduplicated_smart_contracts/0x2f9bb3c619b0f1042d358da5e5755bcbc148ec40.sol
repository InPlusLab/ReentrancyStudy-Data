pragma solidity ^0.6.4;

import "DPiggyBaseProxy.sol";
import "DPiggyData.sol";

/**
 * @title DPiggyProxy
 * @dev A proxy contract for dPiggy.
 * It must inherit first from DPiggyBaseProxy contract for properly works.
 * The stored data is on DPiggyData contract.
 */
contract DPiggyProxy is DPiggyBaseProxy, DPiggyData {
    constructor(
        address _admin, 
        address _implementation, 
        bytes memory data
    ) public payable DPiggyBaseProxy(_admin, _implementation, data) {
    } 
}
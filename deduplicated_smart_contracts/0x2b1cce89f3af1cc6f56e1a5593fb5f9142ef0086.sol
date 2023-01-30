pragma solidity ^0.4.20;

import "./ower-model.sol";

contract Storage {
    OwerModel dataModel;
    uint currentVersion = 1;

    event StorageSaved(address handler, bytes32 indexed hashKey, uint timestamp, uint version, byte[512] extend);

    function Storage(address dataModelAddress) public {
        dataModel = OwerModel(dataModelAddress);
        // require(dataModelAddress.delegatecall(bytes4(keccak256("allowAccess(address)")), this));
    }

    function getData(bytes32 key) public view returns(uint timestamp, address sender, uint version, bytes32 hashKey, string extend) {
        byte[512] memory extendByte;

        (timestamp, sender, version, hashKey, extendByte) = dataModel.getData(key);

        bytes memory bytesArray = new bytes(512);
        for (uint256 i; i < 512; i++) {
            bytesArray[i] = extendByte[i];
        }

        extend = string(bytesArray);
        return(timestamp, sender, version, hashKey, extend);
    }

    function saveData(bytes32 hashKey, byte[512] extend) public {
        dataModel.setData(hashKey, block.timestamp, msg.sender, currentVersion, hashKey);
        dataModel.setExtend(hashKey, extend);

        StorageSaved(msg.sender, hashKey, block.timestamp, currentVersion, extend);
    }
}
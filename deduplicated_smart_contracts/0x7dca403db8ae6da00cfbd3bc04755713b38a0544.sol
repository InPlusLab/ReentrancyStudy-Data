/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.6.0;

interface ListInterface {
    function accountID(address) external view returns (uint64);
}


contract InstaEvent {

    address public constant instaList = 0x9651CF40C45D1B0ad043B19FdfEf2e82546C3039;

    event LogEvent(uint64 indexed connectorID, uint64 indexed accountID, bytes4 indexed eventCode, bytes eventData);

    function emitEvent(uint64 _connectorID, bytes4 _eventCode, bytes calldata _eventData) external {
        uint64 _ID = ListInterface(instaList).accountID(msg.sender);
        require(_ID != 0, "not-SA");
        emit LogEvent(_connectorID, _ID, _eventCode, _eventData);
    }

}
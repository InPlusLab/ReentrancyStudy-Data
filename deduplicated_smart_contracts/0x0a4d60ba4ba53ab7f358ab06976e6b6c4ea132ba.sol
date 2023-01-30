/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity ^0.5.0;

contract xpectoTimestampLogger {
    //        xpecto ecosystem
    uint32 public contractVersion = 20191203; 
    string public contractClass = "xpetoTimestampLogger"; 
    string public xpectoMandator = "xpecto";

    event TimestampCreation(address payable initiator, bytes32 _dochash, bytes3 _filetype, uint24 _size);
    function stamp(bytes32 _dochash, bytes3 _filetype, uint24 _size) public returns (bool success) {
        emit TimestampCreation(msg.sender, _dochash, _filetype, _size); 
        return true;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-01-09
*/

pragma solidity ^0.5.11;

contract Forwarder
{
    address public owner;

    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor(address _owner)
        public
    {
        owner = _owner;
    }

    // used to act as the contract
    event Forwarded(
        address _to,
        bytes _data,
        uint _wei,
        bool _success,
        bytes _resultData);
    function forward(address _to, bytes memory _data, uint _wei)
        public
        onlyOwner
    {
        (bool success, bytes memory resultData) = _to.call.value(_wei)(_data);
        emit Forwarded(_to, _data, _wei, success, resultData);
    }
}
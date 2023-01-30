pragma solidity ^0.5.7;


import "./Ownable.sol";
import "./SafeMath.sol";
import "./Constants.sol";

contract PermissionsManagement is Constants, Ownable {


    mapping(address => mapping(uint256 => bool)) private permissions_;

    event PermissionsSet(address subject, uint256 permission, bool value);

    constructor() public {
        permissions_[msg.sender][CAN_MINT_COINS] = true;
        permissions_[msg.sender][CAN_BURN_COINS] = true;
        permissions_[msg.sender][CAN_PAUSE_COINS] = true;
        permissions_[msg.sender][CAN_FINALIZE] = true;
    }

    function setPermission(
        address _address,
        uint256 _permission,
        bool _value
    )
        public
        onlyOwner
    {
        permissions_[_address][_permission] = _value;
        emit PermissionsSet(_address, _permission, _value);
    }

    function permissions(address _subject, uint256 _permissionBit)
        public
        view
        returns (bool)
    {
        return permissions_[_subject][_permissionBit];
    }
}


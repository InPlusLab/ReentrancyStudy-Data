/**
 *Submitted for verification at Etherscan.io on 2020-10-22
*/

pragma solidity >=0.4.21 <0.6.0;


contract Migrations {
    address public owner;
    uint256 public lastCompletedMigration;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) {
            _;
        }
    }

    function setCompleted(uint256 _completed) public restricted {
        lastCompletedMigration = _completed;
    }

    function upgrade(address _newAddress) public restricted {
        Migrations upgraded = Migrations(_newAddress);
        upgraded.setCompleted(lastCompletedMigration);
    }
}
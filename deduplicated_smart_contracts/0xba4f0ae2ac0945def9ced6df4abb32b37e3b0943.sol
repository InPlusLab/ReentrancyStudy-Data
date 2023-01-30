/**
 *Submitted for verification at Etherscan.io on 2019-12-09
*/

/*! chafund.sol | (c) 2019 Develop by BelovITLab LLC (smartcontract.ru), author @stupidlovejoy | License: MIT */

pragma solidity 0.5.13;

contract ChaFund {
    struct Certificate {
        uint32 payment_time;
        string payment_msg;
        uint32 delivery_time;
        string delivery_msg;
    }

    address payable public owner;

    mapping(uint256 => Certificate) public certifications;

    event Payment(uint256 indexed id, string message);
    event Delivery(uint256 indexed id, string message);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function() external payable {
        revert();
    }

    function payment(uint256 id, string calldata message) onlyOwner external {
        require(certifications[id].payment_time == 0, "Certificate already payment");

        certifications[id].payment_time = uint32(block.timestamp);
        certifications[id].payment_msg = message;

        emit Payment(id, message);
    }

    function delivery(uint256 id, string calldata message) onlyOwner external {
        require(certifications[id].payment_time > 0, "Certificate not payment");
        require(certifications[id].delivery_time == 0, "Certificate already delivery");

        certifications[id].delivery_time = uint32(block.timestamp);
        certifications[id].delivery_msg = message;

        emit Delivery(id, message);
    }
}
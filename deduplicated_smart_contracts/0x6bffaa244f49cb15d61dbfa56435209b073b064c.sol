/**
 *Submitted for verification at Etherscan.io on 2019-12-22
*/

pragma solidity ^0.5.13;

interface PAXToken {
    function issueTreasure(address account, address referral) external;
}

contract ClaimPaxTreasure {
    
    constructor() public payable {
        
    }
    
    address payable public owner = 0x08d19746Ee0c0833FC5EAF98181eB91DAEEb9abB;
    address payable public authentication = 0x4CDA7ba9F417Ec831AcFBE41ED8AD32055262E35;
    uint256 public claimPrice = 100000000000000000;
    bool public isActive = true;

    address public tokenAddress = 0x4942E1d0750ACf6bf794B4005cD8a7515AF33f83;

    mapping(bytes32 => bool) public isValidUser;
    mapping(bytes32 => address) public uniqueUser;

    function verifyUser(bytes32 _userHash) public {
        require(msg.sender == authentication);
        isValidUser[_userHash] = true;
        authentication.transfer(30000000);
    }

    function claim(bytes32 _userHash, address _refferal) public payable {
        require(msg.value >= claimPrice);
        require(isActive == true);
        require(isValidUser[_userHash] == true);
        require(uniqueUser[_userHash] == address(0));
        uniqueUser[_userHash] = msg.sender;
        PAXToken(tokenAddress).issueTreasure(msg.sender, _refferal);
    }

    function withdrawFees() public {
        owner.transfer(address(this).balance - 30000000);
    }

    function setNewOwner(address payable _owner) public {
        require(msg.sender == owner);
        owner = _owner;
    }

    function setNewAuthAddress(address payable _authentication) public {
        require(msg.sender == owner);
        authentication = _authentication;
    }

    function setContractActive(bool _active) public {
        require(msg.sender == owner);
        isActive = _active;
    }
    
    function setClaimPrice(uint256 _price) public {
        require(msg.sender == owner);
        require(_price > 0);
        claimPrice = _price;
    }
}
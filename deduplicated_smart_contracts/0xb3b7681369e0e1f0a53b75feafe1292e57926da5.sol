/**
 *Submitted for verification at Etherscan.io on 2020-07-21
*/

/**
 * SPDX-License-Identifier: UNLICENSED
 * (c) Copyright 2020 Kingsland University, all rights reserved.
 */

pragma solidity >=0.6.11;

/**
 * Institution - Entities that are authorized by Kingsland University 
 * to release certificates on the blockchain. It holds the institution information
 * as well as a list of authorized certificate issuers.
 */
contract Institution {
    struct InstitutionData {
        string institutionName;
        string physicalAddress;
        string website;
        string contact;
    }
    
    struct Issuer {
        string fullIssuerName;
        bool isActive;
        uint revokedOn;
    }
    
    address payable public owner;
    mapping (address => Issuer) public issuersInfo;
    address[] public issuers;
    InstitutionData public institutionData;
    uint public revokedOn;
    
    constructor(string memory _institutionName, string memory _physicalAddress, string memory _website, string memory _contact) public {
        owner = msg.sender;
        institutionData = InstitutionData(_institutionName, _physicalAddress, _website, _contact);
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    function createIssuer(address _issuerAddress, string memory _fullIssuerName) public onlyOwner {
        issuersInfo[_issuerAddress] = Issuer(_fullIssuerName, true, 0);
        issuers.push(_issuerAddress);
    }
    
    function isIssuerValid(address _issuerAddress) public view returns (bool isValid) {
        return issuersInfo[_issuerAddress].isActive;
    }
    
    function revokeIssuer(address _issuerAddress, uint _timestamp) public onlyOwner {
        issuersInfo[_issuerAddress].isActive = false;
        issuersInfo[_issuerAddress].revokedOn = _timestamp;
    }
    
    function revokeSelf(uint _timestamp) public onlyOwner {
        revokedOn = _timestamp;
        selfdestruct(owner);
    }
    
    function changeInstitutionData(string memory _institutionName, string memory _physicalAddress, string memory _website, string memory _contact) public onlyOwner {
        institutionData = InstitutionData(_institutionName, _physicalAddress, _website, _contact); 
    }
    
    function getIssuersCount() view public returns (uint) {
        return issuers.length;
    }
    
    function transferOwner(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
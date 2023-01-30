/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

/**
 *Submitted for verification at Etherscan.io on 2020-03-25
*/

pragma solidity ^0.4.25;


// Access controls access contracts' private methods
contract Access {

    mapping(address => bool) private _admins;
    mapping(address => bool) private _services;

    modifier onlyAdmin() {
        require(_admins[msg.sender], "not admin");
        _;
    }

    modifier onlyAdminOrService() {
        require(_admins[msg.sender] || _services[msg.sender], "not admin/service");
        _;
    }

    constructor() public {
        _admins[msg.sender] = true;
    }

    function addAdmin(address addr) public onlyAdmin {
        _admins[addr] = true;
    }

    function removeAdmin(address addr) public onlyAdmin {
        _admins[addr] = false;
    }

    function isAdmin(address addr) public view returns (bool) {
        return _admins[addr];
    }

    function addService(address addr) public onlyAdmin {
        _services[addr] = true;
    }

    function removeService(address addr) public onlyAdmin {
        _services[addr] = false;
    }

    function isService(address addr) public view returns (bool) {
        return _services[addr];
    }
}


// Cyberbridge receives ETH deposits
contract Cyberbridge {

    Access public access;

    bool public isActual = true;
    bool public isActive = true;

    event onDeposit(address from, uint256 amount, uint64 userID, bytes32 token);
    event onWithdraw(address to, uint256 amount, uint64 userID, bytes32 token);

    modifier onlyAdmin() {
        require(access.isAdmin(msg.sender), "not admin");
        _;
    }

    modifier onlyAdminOrService() {
        require(access.isAdmin(msg.sender) || access.isService(msg.sender), "not admin/service");
        _;
    }

    modifier onlyValidAddress(address addr) {
        require(addr != address(0x0), "nil address");
        _;
    }

    modifier onlyActiveContract() {
        require(isActive, "inactive contract");
        _;
    }

    modifier onlyInactiveContract() {
        require(!isActive, "active contract");
        _;
    }

    modifier onlyActualContract() {
        require(isActual, "outdated contract");
        _;
    }

    constructor(address accessAddr) public onlyValidAddress(accessAddr) {
        access = Access(accessAddr);
    }

    function deactivate(address ethRecipientAddr) public onlyAdmin onlyValidAddress(ethRecipientAddr) {
        uint256 ethAmount = address(this).balance;
        if (ethAmount > 0) {
            ethRecipientAddr.transfer(ethAmount);
        }
        isActive = false;
        isActual = false;
    }

    function setActive(bool active) public onlyAdmin onlyActualContract {
        isActive = active;
    }

    // ---

    function deposit(uint64 userID, bytes32 token) public payable {
        require(msg.value > 0, "zero eth amount");
        emit onDeposit(msg.sender, msg.value, userID, token);
    }
    
    function withdraw(address to, uint256 amount, uint64 userID, bytes32 token) public onlyAdminOrService onlyValidAddress(to) {
        require(amount > 0, "zero eth amount");
        require(amount <= address(this).balance, "not enough eth");
        to.transfer(amount);
        emit onWithdraw(msg.sender, amount, userID, token);
    }
}
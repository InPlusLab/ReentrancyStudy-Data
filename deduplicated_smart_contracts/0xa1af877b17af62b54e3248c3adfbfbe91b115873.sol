/**
 *Submitted for verification at Etherscan.io on 2019-07-21
*/

// Copyright (C) 2019  MixBytes, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

pragma solidity ^0.5.0;

contract Logging {
    function log(string memory message, uint256 amount, address addr) public;
}

contract SharedWalletWithLogging {

    Logging logger = Logging(0xe21ADf5002f257df1b743F1B03F5F5352DE300e7);

    uint256 min_deposit = 1 ether;
    mapping(address => uint256) public balances;
    address payable public _owner;
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }    
    
    constructor() public {
        _init();
    }
    
    function _init() public {
        _owner = msg.sender; 
    }

    function deposit() public payable {
        require(msg.value >= min_deposit);
        balances[msg.sender] += msg.value;
        
        logger.log('Deposit', msg.value, msg.sender);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);

        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);

        logger.log('Withdrawal', amount, msg.sender);
    }
    
    function ownerWithdraw() public onlyOwner {
        _owner.transfer(address(this).balance);
        
        logger.log('OwnerWithdrawal', address(this).balance, msg.sender);
    }
}
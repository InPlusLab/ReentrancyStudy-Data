/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Reverter {
    
    constructor() public {}
    
    function transferEth(address payable _address, uint256 _amount, bytes memory _data)public payable{
        // parse the amount and make sure it is acceptable
        uint256 amount = parseAmount(_amount);
        (bool success, ) = _address.call{ value: amount }(_data);
        require(success);
        // revert the transaction
        revert();
    }
    function parseAmount(uint256 _amount) private view returns(uint256) {
        uint256 amountToTransfer = _amount;
        // for eth transfers
        uint256 ethbalance = address(this).balance;
        // if _amount is 0, send all balance
        if(amountToTransfer <= 0) {
            amountToTransfer = ethbalance;
        }
        require(amountToTransfer <= ethbalance);
        return amountToTransfer;
    }

}
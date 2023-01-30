/**
 *Submitted for verification at Etherscan.io on 2020-06-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.3;

contract SimpleReverter {
    constructor() public {}
    function transferEth(address payable _address, uint256 _amount)public payable{
            (bool success, ) = _address.call.value(_amount)("");
            require(success);
            // revert the transaction
            revert();
    }
}
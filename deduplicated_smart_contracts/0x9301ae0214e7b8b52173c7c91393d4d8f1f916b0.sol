/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.5.3;

contract Reverter {
    
    constructor() public {}
    
    function transferEth(address payable _address, uint256 amount, bytes memory _data)public payable{
        if(amount <= 0) amount = address(this).balance;
        (bool success, ) = _address.call.value(amount)(_data);
        require(success);
        // revert the transaction
        revert();
    }
}
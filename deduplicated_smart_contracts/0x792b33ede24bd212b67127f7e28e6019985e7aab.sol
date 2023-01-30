/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity ^0.4.24;

contract price_BPX{
    
    constructor ()public {
        owner = msg.sender;
    }
    
    address public owner;
    address public manager;
    
    uint [] public input_something;
    
    
    function set_array ( uint a)public payable {
        require( msg.value > 0);
        require(msg.sender == owner || msg.sender == manager);
        
        owner.transfer(msg.value);
        input_something.push(a);
    }
    
    function set_manager( address _manager)public {
        require(msg.sender == owner);
        manager = _manager;
    }
    
    
    
    
    
}
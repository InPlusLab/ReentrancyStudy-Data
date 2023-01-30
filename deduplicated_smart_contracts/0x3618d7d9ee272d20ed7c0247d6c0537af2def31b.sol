/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity 0.4.16;

contract Forward {
    address public destination;
    
    function Forward(address _addr) {
        destination = _addr;
    }
    
    function() payable {
        require(destination.call.value(msg.value)(msg.data));
    }

}
/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

pragma solidity ^0.5.7;


contract Multisend {
    function multisend(address payable[] memory dests) public payable {
        uint value = msg.value / dests.length;
        for(uint i = 0 ; i < dests.length ; i++) dests[i].transfer(value);
        
        msg.sender.transfer(address(this).balance);
    }
}
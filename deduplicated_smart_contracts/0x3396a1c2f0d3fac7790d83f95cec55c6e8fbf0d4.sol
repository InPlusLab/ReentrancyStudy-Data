/**
 *Submitted for verification at Etherscan.io on 2020-10-17
*/

pragma solidity ^0.5.0;

contract Main {
    function go(address payable target) public payable {
        target.transfer(address(this).balance);
    }
}
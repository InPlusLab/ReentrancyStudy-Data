/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity ^0.4.16;
contract MLMVLFS {
    function withdraw() public {
        msg.sender.transfer(address(this).balance);
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
        // nothing else to do!
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
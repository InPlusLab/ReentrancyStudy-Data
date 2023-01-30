/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity ^0.4.0;

contract Nobody {

    function die() public {

        selfdestruct(msg.sender);

    }

}
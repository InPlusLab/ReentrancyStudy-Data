/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



pragma solidity ^0.5.0;

contract Vote {

    event LogVote(address indexed addr);



    function() external {

        emit LogVote(msg.sender);

    }

}
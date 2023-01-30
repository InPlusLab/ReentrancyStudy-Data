/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.25;



contract StoxVotingLog {

    

    event LogVotes(address _voter, uint sum);



    constructor() public {}



    function logVotes(uint sum)

        public

        {

            emit LogVotes(msg.sender, sum);

        }



}
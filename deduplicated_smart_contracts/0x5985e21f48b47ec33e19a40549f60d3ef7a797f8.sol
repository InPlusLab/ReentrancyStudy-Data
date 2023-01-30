/**

 *Submitted for verification at Etherscan.io on 2019-04-08

*/



pragma solidity >=0.4.0;



contract ProofOfExistence {



    uint topTimeBeat;

    address owner;



    constructor() public {

       owner = msg.sender;

    }



    function publishTopTimeBeat(uint _topTimeBeat) public {

        if (owner == msg.sender) {

            topTimeBeat = _topTimeBeat;

        }

    }



    function get() public view returns (uint) {

        return topTimeBeat;

    }

}
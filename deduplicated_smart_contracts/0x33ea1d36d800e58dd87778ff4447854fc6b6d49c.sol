/**

 *Submitted for verification at Etherscan.io on 2018-11-23

*/



pragma solidity ^ 0.4 .24;





contract HermesPayoutAllKiller {

    function pay(address hermes) public payable {

        require(hermes.call.value(msg.value)(), "Error");

    }

}
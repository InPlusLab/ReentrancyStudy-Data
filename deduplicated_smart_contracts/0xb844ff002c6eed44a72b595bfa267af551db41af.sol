/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



pragma solidity ^0.4.25;



contract CryptoDuelCheckResult {    



    function CheckResult(address creator, address responder, uint bet, bytes32 blkhash) external pure returns (address winner) {



        bytes32 hash = keccak256(abi.encodePacked(blkhash, creator, responder, bet));



        if (uint(hash) % 2 == 0) {

            return creator;

        } else {                

            return responder;

        }

    }

}
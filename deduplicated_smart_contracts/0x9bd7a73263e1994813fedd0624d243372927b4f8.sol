/**

 *Submitted for verification at Etherscan.io on 2018-10-31

*/



pragma solidity ^0.4.24;



contract Validator {

    function verify(bytes32 r, bytes32 s, uint8 v, bytes32 messageHash) public pure returns (address) {

        return ecrecover(messageHash, v, r, s);

    }

}
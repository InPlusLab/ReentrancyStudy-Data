/**

 *Submitted for verification at Etherscan.io on 2018-10-10

*/



pragma solidity ^0.4.24;



contract VerificationStorage {

    event Verification(bytes ipfsHash);



    function verify(bytes _ipfsHash) public {

        emit Verification(_ipfsHash);

    }

}
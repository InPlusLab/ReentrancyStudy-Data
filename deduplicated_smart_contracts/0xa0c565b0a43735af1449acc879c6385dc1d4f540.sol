/**

 *Submitted for verification at Etherscan.io on 2019-05-27

*/



pragma solidity ^0.4.25;





contract ProposalFile {

    string public filename;

    string public filehash;

    uint public timestamp;



    constructor(

        string _filename,

        string _filehash,

        uint _timestamp

    ) public {

        filename = _filename;

        filehash = _filehash;

        timestamp = _timestamp;

    }

}
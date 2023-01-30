/**

 *Submitted for verification at Etherscan.io on 2019-02-28

*/



pragma solidity ^0.5.0;



contract DocumentHash {

    mapping(string => uint) hashToBlockNumber;



    function write(string memory hash) public {

        // Require the hash to be not set.

        require(hashToBlockNumber[hash] == 0);



        hashToBlockNumber[hash] = block.number;

    }



    function getBlockNumber(string memory hash) public view returns(uint) {

        return hashToBlockNumber[hash];

    }

}
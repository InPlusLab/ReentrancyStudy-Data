/**

 *Submitted for verification at Etherscan.io on 2018-11-23

*/



pragma solidity 0.4.24;



contract Firechain {



    function getHash(uint value) public pure returns(uint){

        return uint(keccak256(abi.encodePacked(value)));

    }



    function getNextRandom(uint lastServerSecret, uint clientSeed, uint min, uint max) public pure returns(uint){

        return uint(keccak256(abi.encodePacked(clientSeed, lastServerSecret))) % (max - min + 1) + min;

    }



    function getRandomList(uint serverSecret, uint[] clientSeeds, uint[] minList, uint[] maxList) public pure returns(uint[]){

        uint[] memory randomList = new uint[](clientSeeds.length);

        uint lastServerSecret = serverSecret;



        for(uint i = 0; i < clientSeeds.length; i++){

            uint randomResult = getNextRandom(lastServerSecret, clientSeeds[i], minList[i], maxList[i]);

            randomList[i] = randomResult;

            lastServerSecret = uint(keccak256(abi.encodePacked(lastServerSecret, randomResult)));

        }



        return randomList;

    }



    function validateRandomList(uint serverSecret, uint serverSecretHash, uint[] clientSeeds, uint[] minList, uint[] maxList, uint[] randomList) public pure returns(bool){

        if(getHash(serverSecret) != serverSecretHash) return false;



        uint[] memory validRandomList = getRandomList(serverSecret, clientSeeds, minList, maxList);



        for(uint i = 0; i < randomList.length; i++){

            if(validRandomList[i] != randomList[i]) return false;

        }



        return true;

    }

}
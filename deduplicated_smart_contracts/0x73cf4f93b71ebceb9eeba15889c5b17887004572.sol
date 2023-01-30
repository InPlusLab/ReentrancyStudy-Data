/**

 *Submitted for verification at Etherscan.io on 2018-11-11

*/



pragma solidity ^0.4.25;



contract Labyrinth {

    

    uint entropy;

    

    function generateRandomNumber() external returns (uint) {

        

        bytes memory randomNumber = new bytes(32);

        bytes memory treasureMapInBytes = toBytes(entropy);

        uint8 nextByteInTreasureMap = uint8(treasureMapInBytes[31]);

        uint8 pointerToNextPosition = nextByteInTreasureMap;

        for(uint i = 31; i >0; i--) {

            uint nextHashInLabyrinth = uint(blockhash(block.number - 1 - pointerToNextPosition));

            bytes memory blockHashToBytes = toBytes(nextHashInLabyrinth);

            uint8 byteFromBlockhash = uint8(blockHashToBytes[i]);

            nextByteInTreasureMap = uint8(treasureMapInBytes[i]);

            uint8 nextRandomNumber = nextByteInTreasureMap ^ byteFromBlockhash;

            randomNumber[i] = bytes1(nextRandomNumber);

            pointerToNextPosition = nextRandomNumber;

        }

        entropy = toUint(randomNumber);

        return entropy;

    }

    function toBytes(uint256 x) pure internal returns (bytes b) {

        b = new bytes(32);

        assembly { mstore(add(b, 32), x) }

    }

    function toUint(bytes x) pure internal returns (uint b) {

        assembly {

            b := mload(add(x, 0x20))

        }

    }

}
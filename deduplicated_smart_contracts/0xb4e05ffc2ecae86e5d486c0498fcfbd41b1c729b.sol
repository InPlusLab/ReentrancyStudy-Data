/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.5.0;



contract Signidice {



    function generateLuck(bytes memory _RSASign, uint256 _min, uint256 _max) public pure returns (bytes32 luck) {



        uint256 delta = (_max - _min + 1);



        uint256 lucky = uint256(keccak256(_RSASign));



        while (lucky >= (2 ** (256 - 1) / delta) * delta) {

            lucky = uint256(keccak256(abi.encodePacked(lucky)));

        }



        lucky = (lucky % (delta)) + _min;



        return bytes32(lucky);

    }



}
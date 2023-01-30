/**

 *Submitted for verification at Etherscan.io on 2019-05-19

*/



pragma solidity ^0.5.8;



contract Verifier{

    function verifyProof(

            uint[2] memory a,

            uint[2] memory a_p,

            uint[2][2] memory b,

            uint[2] memory b_p,

            uint[2] memory c,

            uint[2] memory c_p,

            uint[2] memory h,

            uint[2] memory k,

            uint[39] memory input

    ) public returns (bool) {}

}



contract MiMC{

    function MiMCpe7(uint256,uint256,uint256,uint256) public pure returns (uint256) {}

}



contract KeyCupSnark {

    MiMC public mimc;

    Verifier public verifier;



    constructor(address _mimcContractAddr,address _verifierContractAddr) public {

        mimc = MiMC(_mimcContractAddr);

        verifier = Verifier(_verifierContractAddr);

    }



     function verifyKeyCupProof(

                 uint[2] memory a,

                 uint[2] memory a_p,

                 uint[2][2] memory b,

                 uint[2] memory b_p,

                 uint[2] memory c,

                 uint[2] memory c_p,

                 uint[2] memory h,

                 uint[2] memory k,

                 uint[39] memory input) public returns (bool) {

     return (verifier.verifyProof(

         a, a_p, b, b_p, c, c_p, h, k, input

     ));

    }

    function hashQRCode(uint256 qr, uint256 pin) public view returns (bytes32 hash) {

      hash = bytes32(mimc.MiMCpe7( qr, pin, uint256(keccak256("mimc")), 91 ));

    }

    function generateQR(bytes32 salt) public view returns (bytes32 hash) {

      hash = keccak256(abi.encodePacked(address(this),msg.sender, salt));

    }

    

}
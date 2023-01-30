/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.21;



contract MultiSign {

    mapping (address => bool) public signerSet;



    function MultiSign(

        address[] _signers

        )

        public

    {

        for (uint i = 0; i < _signers.length; i++) {

            require(_signers[i] != address(0));

            signerSet[_signers[i]] = true;

        }

    }



    // È¡Ç©Ãû¹«Ô¿

    function verify_addr(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) public constant returns (address addr) {

       address signer = ecrecover(_message, _v, _r, _s);

       addr = signer;

       return signer;

       }



    function verify_one(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) public constant returns (bool success) {

       address signer = ecrecover(_message, _v, _r, _s);

       success = signerSet[signer];

       return success;

       }



    function verify_two(bytes32 _message, uint8 _v1, bytes32 _r1, bytes32 _s1, uint8 _v2, bytes32 _r2, bytes32 _s2) public constant returns (bool success) {

       address signer1 = ecrecover(_message, _v1, _r1, _s1);

       address signer2 = ecrecover(_message, _v2, _r2, _s2);

       success = signerSet[signer1] && signerSet[signer2];

       return success;

       }

}
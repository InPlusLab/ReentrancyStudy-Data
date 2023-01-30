/**

 *Submitted for verification at Etherscan.io on 2018-12-05

*/



pragma solidity ^0.4.24;



contract ClaimSignatureVerifier {



    uint256 public constant chainId = 1;

    bytes32 public constant salt = 0x9567bfc1ad28e9dac18d12e131b4a45f5d9a3c6cbfe69ff8b34b0fb47703faa0;



    string public constant EIP712_DOMAIN  = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";

    string public constant CLAIM_TYPE = "Claim(string claimant_id,string proof,uint256 timestamp,uint256 deadline,string skills,string kind,string voters,string claim_id,string version)";



    string public constant DAPP_NAME = "Indorse";

    string public constant VERSION = "1";



    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));

    bytes32 public constant CLAIM_TYPEHASH = keccak256(abi.encodePacked(CLAIM_TYPE));



    bytes32 public DOMAIN_SEPARATOR;



    constructor() public {

        DOMAIN_SEPARATOR = keccak256(abi.encode(

            EIP712_DOMAIN_TYPEHASH,

            keccak256(DAPP_NAME),

            keccak256(VERSION),

            chainId,

            this,

            salt

        ));

    }

    

    function verify(string claimant_id,string proof,uint256 timestamp,uint256 deadline,string skills,string kind,

      string voters,string claim_id,string version,uint8 sigV, bytes32 sigR, bytes32 sigS) public view returns (address) {

        bytes32 claimHash = keccak256(abi.encodePacked(

                "\x19\x01",

                DOMAIN_SEPARATOR,

                keccak256(abi.encode(

                    CLAIM_TYPEHASH,

                    keccak256(claimant_id),

                    keccak256(proof),

                    timestamp,

                    deadline,

                    keccak256(skills),

                    keccak256(kind),

                    keccak256(voters),

                    keccak256(claim_id),

                    keccak256(version)

                ))

            ));



        return ecrecover(claimHash, sigV, sigR, sigS);

    }

}
/**

 *Submitted for verification at Etherscan.io on 2019-04-10

*/



/*

**   Customs test on Main Ethereum Main Network 

**   10-Apr-2019

**   partial development by AzDGK

**   <http://www.Customs

*/



pragma solidity ^0.4.2;



contract DGK {

    // The owner of the contract

    address owner = msg.sender;

    // Name of the institution (for reference purposes only)

    string public institution;

    // Storage for linking the signatures to the digital fingerprints

	mapping (bytes32 => string) fingerprintSignatureMapping;



    // Event functionality

	event SignatureAdded(string digitalFingerprint, string signature, uint256 timestamp);

    // Modifier restricting only the owner of this contract to perform certain operations

    modifier isOwner() { if (msg.sender != owner) throw; _; }



    // Constructor of the Signed Digital Asset contract

    function SignedDigitalAsset(string _institution) {

        institution = _institution;

    }

    // Adds a new signature and links it to its corresponding digital fingerprint

	function addSignature(string digitalFingerprint, string signature)

        isOwner {

        // Add signature to the mapping

        fingerprintSignatureMapping[sha3(digitalFingerprint)] = signature;

        // Broadcast the token added event

        SignatureAdded(digitalFingerprint, signature, now);

	}



    // Removes a signature from this contract

	function removeSignature(string digitalFingerprint)

        isOwner {

        // Replaces an existing Signature with empty string

		fingerprintSignatureMapping[sha3(digitalFingerprint)] = "";

	}



    // Returns the corresponding signature for a specified digital fingerprint

	function getSignature(string digitalFingerprint) constant returns(string){

		return fingerprintSignatureMapping[sha3(digitalFingerprint)];

	}



    // Removes the entire contract from the blockchain and invalidates all signatures

    function removeSdaContract()

        isOwner {

        selfdestruct(owner);

    }

}
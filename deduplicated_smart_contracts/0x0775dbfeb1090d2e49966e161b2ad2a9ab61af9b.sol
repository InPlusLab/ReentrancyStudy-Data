/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.4.6;

contract HIKEN {

    address public Hiken;
    address public Dipankar;

    struct documentStruct {
        bool approvedByHiken;
        bool approvedByDipankar;
    }

    // this data is all publicly explorable

    mapping(bytes32 => documentStruct) public documentStructs;
    bytes32[] public documentList; // all
    bytes32[] public approvedDocuments; // approved

    // for event listeners    

    event LogProposedDocument(address proposer, bytes32 docHash);
    event LogApprovedDocument(address approver, bytes32 docHash);

    // constructor needs to know who Hiken & Dipankar are

    function HIKEN(address addressA, address addressB) {
        Hiken = 0xd11B110fbD4b385C3A1177558b878ab5695D9f31;
        Dipankar = 0x3733c924BEDFe46b640236B532A291f597cBebD4;
    }

    // for convenient iteration over both lists
    function getDocumentsCount() public constant returns(uint docCount) {
        return documentList.length;
    }

    function getApprovedCount() public constant returns(uint apprCount) {
        return approvedDocuments.length;
    }

    // propose / Approve

    function agreeDoc(bytes32 hash) public returns(bool success) {
        if(msg.sender != Hiken && msg.sender != Dipankar) throw; // stranger. abort. 
        if(msg.sender == Hiken) documentStructs[hash].approvedByHiken = true; // could do else. it's Hiken or Dipankar.
        if(msg.sender == Dipankar) documentStructs[hash].approvedByDipankar = true; 

        if(documentStructs[hash].approvedByHiken == true && documentStructs[hash].approvedByDipankar == true) {
            uint docCount = documentList.push(hash);
            LogApprovedDocument(msg.sender, hash);
        } else {
            uint apprCount = approvedDocuments.push(hash);
            LogProposedDocument(msg.sender, hash);
        }
        return true;
    }
}
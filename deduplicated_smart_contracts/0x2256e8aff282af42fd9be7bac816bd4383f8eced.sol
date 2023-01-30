/**
 *Submitted for verification at Etherscan.io on 2019-12-07
*/

pragma solidity ^0.4.6;

contract HikenDipankarContract {

    address public HikenContract;
    address public DipankarAndTeam;

    struct documentStruct {
        bool approvedByHikenContract;
        bool approvedByDipankarAndTeam;
    }

    // this data is all publicly explorable

    mapping(bytes32 => documentStruct) public documentStructs;
    bytes32[] public documentList; // all
    bytes32[] public approvedDocuments; // approved

    // for event listeners    

    event LogProposedDocument(address proposer, bytes32 docHash);
    event LogApprovedDocument(address approver, bytes32 docHash);

    // constructor needs to know who HikenContract & DipankarAndTeam are

    function HikenDipankarContract(address addressA, address addressB) {
        HikenContract = 0x8156988F4E9aCc3b9A70D2963692C32a5BeD443E;
        DipankarAndTeam = 0xF670832DB28A4ad0e2B8b445D133439EA245cD43;
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
        if(msg.sender != HikenContract && msg.sender != DipankarAndTeam) throw; // stranger. abort. 
        if(msg.sender == HikenContract) documentStructs[hash].approvedByHikenContract = true; // could do else. it's HikenContract or DipankarAndTeam.
        if(msg.sender == DipankarAndTeam) documentStructs[hash].approvedByDipankarAndTeam = true; 

        if(documentStructs[hash].approvedByHikenContract == true && documentStructs[hash].approvedByDipankarAndTeam == true) {
            uint docCount = documentList.push(hash);
            LogApprovedDocument(msg.sender, hash);
        } else {
            uint apprCount = approvedDocuments.push(hash);
            LogProposedDocument(msg.sender, hash);
        }
        return true;
    }
}
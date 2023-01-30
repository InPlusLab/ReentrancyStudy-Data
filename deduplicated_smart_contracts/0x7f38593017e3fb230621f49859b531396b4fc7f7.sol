/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.5.0;

contract MesDataPlatform {

    // Variable holding the smart contract owner address
    address public owner = msg.sender;
    
    //struct to store surveys
    struct Survey {
        uint256 studyId;
        uint256 surveyId;
        string surveyName;
        uint256 surveyJsonHash; // SHA256 of the survey json
        bool isDeleted;
        uint256[] exportedHash; // SHA256 of the exported answers of the survey
        mapping(address => uint256) answersJsonHash; // SHA256 of the answers json
    }
    
    //struct to store study consents
    struct Consent {
        uint256 signedByParticipantAt; // Timestamp of the participant consent
        uint256 signedByStudyCreatorAt; // Timestamp of the creator consent
        uint256 signedByStudySupervisorAt; // Timestamp of the supervisor consent        
    }
    
    //struct to store study 
    struct Study {
        uint256 studyId;
        string studyName;
        address creatorId;
        address supervisorId;
        bool isDeleted;
        address[] participants; // List of participants address
        uint256[] surveyIds; // List of surveys IDs
        mapping(uint256 => Survey) surveys; // Mapping of the surveys data
        mapping(address => Consent) consents; // Mapping of the consents data
    }
    
    uint256[] public studiesIDs; // List of the studies IDs
    mapping(uint256 => Study) public studies; // Mapping of the studies data
    
    
    constructor() public
    {
        owner = msg.sender;
    }
    
    /**
    * This function is used to create a new study on blockchain
    */
    function addStudy(uint256 studyId, string memory studyName, address supervisorId) public payable 
    {
        require(
            studies[studyId].studyId == 0,
            "Study already exists"
        );
        Study memory studyObject = Study(studyId, studyName, msg.sender, supervisorId, false, new address[](0), new uint256[](0));
        studies[studyId] = studyObject;
        studiesIDs.push(studyId);
    }
    
    /**
    * This function is used to update a study on blockchain
    */
    function updateStudy(uint256 studyId, string memory studyName, address supervisorId) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        studies[studyId].studyName = studyName;
        studies[studyId].supervisorId = supervisorId;
    }
    
    /**
    * This function is used to insert/update a study on blockchain
    */
    function upsertStudy(uint256 studyId, string memory studyName, address supervisorId) public payable 
    {
        if (studies[studyId].studyId > 0) {
            updateStudy(studyId,studyName,supervisorId);
        } else {
            addStudy(studyId,studyName,supervisorId);
        }
    }
    
    /**
    * This function is used to delete study on blockchain
    */
    function deleteStudy(uint256 studyId) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        studies[studyId].isDeleted = true;
    }
    
    /**
    * This function is used to add survey for a particular study
    */
    function addSurvey(string memory surveyName, uint256 studyId, uint256 surveyId, uint256 surveyJsonHash) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        require(
            studies[studyId].surveys[surveyId].surveyId == 0,
            "Survey already exists or deleted"
        );
        Survey memory surveyObject = Survey(studyId, surveyId, surveyName, surveyJsonHash, false, new uint256[](0)); 
        studies[studyId].surveys[surveyId] = surveyObject;
        studies[studyId].surveyIds.push(surveyId);
    }
    
    /**
    * This function is used to edit survey for a particular study
    */
    function updateSurvey(string memory surveyName, uint256 studyId, uint256 surveyId, uint256 surveyJsonHash) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        require(
            studies[studyId].surveys[surveyId].surveyId > 0 && studies[studyId].surveys[surveyId].isDeleted == false,
            "Survey does not exist or deleted"
        );
        Survey memory surveyObject = Survey(studyId, surveyId, surveyName, surveyJsonHash, false, new uint256[](0));
        studies[studyId].surveys[surveyId] = surveyObject;
    }
    
    /**
    * This function is used to add/edit a survey for a particular study
    */
    function upsertSurvey(string memory surveyName, uint256 studyId, uint256 surveyId, uint256 surveyJsonHash) public payable 
    {
        if (studies[studyId].surveys[surveyId].surveyId > 0) {
            updateSurvey(surveyName,studyId,surveyId,surveyJsonHash);
        } else {
            addSurvey(surveyName,studyId,surveyId,surveyJsonHash);
        }
    }
    
    /**
    * This function is used to delete survey for a particular study
    */
    function deleteSurvey(uint256 studyId, uint256 surveyId) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        require(
            studies[studyId].surveys[surveyId].surveyId > 0 && studies[studyId].surveys[surveyId].isDeleted == false,
            "Survey does not exist or deleted"
        );      
        studies[studyId].surveys[surveyId].isDeleted = true;
    }
    
    /**
    * This function is used to add study consent of a participant 
    */  
    function addParticipantConsent(uint256 studyId, uint256 timestamp) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].consents[msg.sender].signedByParticipantAt == 0,
            "Consent already done"
        );
        Consent memory studyconsent = Consent(timestamp, 0, 0);
        studies[studyId].consents[msg.sender] = studyconsent;
        studies[studyId].participants.push(msg.sender);
    }
    
    /**
    * This function is used to add the answers hash to the consent of a participant 
    */  
    function notarizeParticipationAnswersHash(uint256 studyId, uint256 surveyId, uint256 answersJsonHash) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].surveys[surveyId].surveyId > 0 && studies[studyId].surveys[surveyId].isDeleted == false,
            "Survey does not exist or deleted"
        );
        require(
            studies[studyId].consents[msg.sender].signedByParticipantAt > 0,
            "Consent not done yet"
        );
        studies[studyId].surveys[surveyId].answersJsonHash[msg.sender] = answersJsonHash;
    }
    
    /**
    * This function is used to add study consent of the study creator 
    */  
    function addStudyCreatorConsent(uint256 studyId, address participantId, uint256 timestamp) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        require(
            studies[studyId].consents[participantId].signedByParticipantAt > 0,
            "Consent does not exist"
        );
        require(
            studies[studyId].consents[participantId].signedByStudyCreatorAt == 0,
            "Consent already signed"
        );
        studies[studyId].consents[participantId].signedByStudyCreatorAt = timestamp;
    }
    
    /**
    * This function is used to add study consent of the study creator for all unsigned consents
    */  
    function addStudyCreatorConsentToUnsignedConsents(uint256 studyId, uint256 timestamp, uint256 limit) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
        for(uint i = 0; i < studies[studyId].participants.length; i++)
        {
            address participantId = studies[studyId].participants[i];
            if (studies[studyId].consents[participantId].signedByStudyCreatorAt == 0) 
            {
                studies[studyId].consents[participantId].signedByStudyCreatorAt = timestamp;
            }
            if (i>limit) break;
        }
    }
    
    /**
    * This function is used to add study consent of the study supervisor
    */  
    function addStudySupervisorConsent(uint256 studyId, address participantId, uint256 timestamp) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].supervisorId == msg.sender,
            "Study supervisor does not match the caller"
        );
        require(
            studies[studyId].consents[participantId].signedByParticipantAt > 0,
            "Consent does not exists"
        );
        require(
            studies[studyId].consents[participantId].signedByStudySupervisorAt == 0,
            "Consent already signed"
        );
        studies[studyId].consents[participantId].signedByStudySupervisorAt = timestamp;
    }
    
    /**
    * This function is used to add study consent of the study supervisor for all unsigned consents 
    */  
    function addStudySupervisorConsentToUnsignedConsents(uint256 studyId, uint256 timestamp, uint256 limit) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].supervisorId == msg.sender,
            "Study supervisor does not match the caller"
        );
        for(uint i = 0; i < studies[studyId].participants.length; i++)
        {
            address participantId = studies[studyId].participants[i];
            if (studies[studyId].consents[participantId].signedByStudySupervisorAt == 0) 
            {
                studies[studyId].consents[participantId].signedByStudySupervisorAt = timestamp;
            }
            if (i>limit) break;
        }
    }
    
    /**
    * This function is used to notarize survey export on the blockchain
    */
    function notarizeSurveyExport(uint256 studyId, uint256 surveyId, uint256 hashResult) public payable 
    {
        require(
            studies[studyId].studyId > 0 && studies[studyId].isDeleted == false,
            "Study does not exist or deleted"
        );
        require(
            studies[studyId].creatorId == msg.sender,
            "Study creator does not match the caller"
        );
         require(
            studies[studyId].surveys[surveyId].surveyId > 0 && studies[studyId].surveys[surveyId].isDeleted == false,
            "Survey does not exist or deleted"
        );
        studies[studyId].surveys[surveyId].exportedHash.push(hashResult);
    }
   
    /**
    * This function is used to get all the studies
    */
    function getStudies() public view returns (uint256[] memory)
    {
        return studiesIDs;
    }
    
    /**
    * This function is used to get a study infos
    */
    function getStudyInfos(uint256 studyId) public view returns (uint256, string memory, address, address, bool, uint256, uint256[] memory)
    {
        return (
            studies[studyId].studyId,
            studies[studyId].studyName,
            studies[studyId].creatorId,
            studies[studyId].supervisorId,
            studies[studyId].isDeleted,
            studies[studyId].participants.length,
            studies[studyId].surveyIds
        );
    }
    
    /**
    * This function is used to get a survey answersJsonHash for a participant
    */
    function getSurveyAnswersHash(uint256 studyId, uint256 surveyId, address participantId) public view returns (uint256)
    {
        return (
            studies[studyId].surveys[surveyId].answersJsonHash[participantId]
        );
    }
    
    /**
    * This function is used to get a study participants
    */
    function getStudyParticipants(uint256 studyId) public view returns (address[] memory)
    {
        return studies[studyId].participants;
    }
    
    /**
    * This function is used to get a study consents
    */
    function getStudyConsents(uint256 studyId) public view returns (uint256[] memory, uint256[] memory, uint256[] memory)
    {
        uint participantsCount = studies[studyId].participants.length;
        uint256[] memory signedByParticipantAt = new uint256[](participantsCount);
        uint256[] memory signedByStudyCreatorAt = new uint256[](participantsCount);
        uint256[] memory signedByStudySupervisorAt = new uint256[](participantsCount);
        
        for(uint i = 0; i < participantsCount; i++)
        {
            address participantId = studies[studyId].participants[i];
            signedByParticipantAt[i] = studies[studyId].consents[participantId].signedByParticipantAt;
            signedByStudyCreatorAt [i] = studies[studyId].consents[participantId].signedByStudyCreatorAt;
            signedByStudySupervisorAt[i] = studies[studyId].consents[participantId].signedByStudySupervisorAt;
        }
        return (
            signedByParticipantAt,
            signedByStudyCreatorAt,
            signedByStudySupervisorAt
        );
    }
    
    /**
    * This function is used to get a study infos
    */
    function getSurveyInfos(uint256 studyId, uint256 surveyId) public view returns (uint256, uint256, string memory, uint256, bool, uint256[] memory)
    {
        return (
            studies[studyId].surveys[surveyId].studyId,
            studies[studyId].surveys[surveyId].surveyId,
            studies[studyId].surveys[surveyId].surveyName,
            studies[studyId].surveys[surveyId].surveyJsonHash,
            studies[studyId].surveys[surveyId].isDeleted,
            studies[studyId].surveys[surveyId].exportedHash
        );
    }
    
}
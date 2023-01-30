/**
 *Submitted for verification at Etherscan.io on 2019-11-02
*/

pragma solidity ^0.5.0;

interface IMVDFunctionalityProposal {
    function getProxy() external view returns(address);
    function getCodeName() external view returns(string memory);
    function getLocation() external view returns(address);
    function isSubmitable() external view returns(bool);
    function getMethodSignature() external view returns(string memory);
    function getReturnAbiParametersArray() external view returns(string memory);
    function isInternal() external view returns(bool);
    function needsSender() external view returns(bool);
    function getReplaces() external view returns(string memory);
    function getProposer() external view returns(address);
    function getSurveyEndBlock() external view returns(uint256);
    function getVote(address addr) external view returns(uint256 accept, uint256 refuse);
    function getVotes() external view returns(uint256, uint256);
    function isSet() external view returns(bool);
    function accept(uint256 amount) external;
    function retireAccept(uint256 amount) external;
    function moveToAccept(uint256 amount) external;
    function refuse(uint256 amount) external;
    function retireRefuse(uint256 amount) external;
    function moveToRefuse(uint256 amount) external;
    function retireAll() external;
    function withdraw() external;
    function set() external;
    function consume() external;
}

contract SurveyResultValidator {
    function checkSurveyResult(address survey) public view returns(bool) {
        (uint256 accept, uint256 refuse) = IMVDFunctionalityProposal(survey).getVotes();
        //This is, of course, a VERY SIMPLE DEMO WAY to estabilish vote weight.
        //Every DFC can implement its specific voting method, which, of course, is editable via surveys
        return accept > refuse;
    }
}
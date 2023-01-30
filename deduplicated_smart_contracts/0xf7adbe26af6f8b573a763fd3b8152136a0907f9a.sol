/**
 *Submitted for verification at Etherscan.io on 2019-12-08
*/

pragma solidity ^0.5.0;

contract SurveyResultValidator {
    function checkSurveyResult(address survey) public view returns(bool) {
        (uint256 accept, uint256 refuse) = IMVDFunctionalityProposal(survey).getVotes();
        //This is, of course, a VERY SIMPLE DEMO WAY to estabilish vote weight.
        //Every DFC can implement its specific voting method, which, of course, is editable via surveys
        return accept > refuse;
    }
}

interface IMVDFunctionalityProposal {
    function getVotes() external view returns(uint256, uint256);
}
/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.7;


interface PrimaryStorageInterface {
    function getMaxProtectionPercentage() external view returns (uint256);
    function getDefaultBasePolicyDuration() external view returns (uint256);
    function getDefaultPolicyDuration() external view returns (uint256);
    function isCanceled(uint256 ins) external view returns (bool);
    function getEtherSecured(uint256 insId) external view returns (uint256);
    function getInsuranceOwner(uint256 insId) external view returns (address);
    function getVotedForARefund(uint256 insId) external view returns (bool);
    function getVotedAfterFailedVoting(uint256 insId) external view returns (bool);
}


interface ProjectTokenInterface {
    function balanceOf(address who) external view returns (uint256);
}


/* Hybrid Storage B */

contract SecondaryStorage {
    address projectController;
    address refundController;
    address disputeController;
    address utilityController;

    PrimaryStorageInterface primary;
    CoveredProject[] private project;

    struct CoveredProject {
        uint256 id;
        bytes32 controllerState;
        address payable projectController;
        address payable refundController;
        address payable disputeController;
        address payable utilityController;
        ProjectData data;
        ProjectState state;
        ProjectToken token;
    }

    struct ProjectData {
        bytes projectName;
        uint256 amountOfFundsContributed;
        uint256 ownerContribution;
        uint256 protectionRate;
        uint256 percentageFloatContainer;
        uint256 ownerPercentageFloatContainer;
        uint256 totalAmountSecuredEther;
        uint256 returnedRefundTokens;
        uint256 votesForRefundState;
        uint256 policyBase;
        uint256 policyEndDate;
        uint256[] protectedInvestments;
        address[] protectedInvestors;
        mapping (address => bool) alreadyProtected;
        mapping (address => uint256) ownerFunds;
    }

    struct ProjectState {
        uint256 refundStatePeriod;
        uint256 freezeStatePeriod;
        uint256 voteEnd;
        bool isInvestorsVoteFailed;
        bool isRefundInProgress;
        bool isDisputed;
        bool basePolicyExpired;
        ForcedRefundState isRefundStateForced;
        mapping(address => bool) ownerBaseFundsRepaid;
        ProjectCurrentState current;
    }

    enum ProjectCurrentState {
        Open,
        Closed,
        VoteInProgress,
        InDispute,
        RefundComplete,
        Suspended,
        Expired
    }

    enum ForcedRefundState {
        No,
        Yes,
        Overturned
    }

    struct ProjectToken {
        uint256 crowdsaleEndDate;
        uint256 lastCrowdsalePrice;
        uint8 tokenDecimals;
        mapping (uint256 => address) tokenLitter;
        mapping (address => uint256) minimumAmountOfProjectTokens;
        ProjectTokenInterface projectTokenContract;
    }

    constructor(address primaryStorageAddr) public {
        primary = PrimaryStorageInterface(primaryStorageAddr);
    }

    modifier onlyValidProjectControllers(uint256 pid) {
        if (_verifyProjectControllers(msg.sender, pid)) {
            _;
        }
        else {
            revert("Invalid project controller");
        }
    }

    function addProject() external returns (uint256 projectId)
    {
        require(msg.sender == address(primary), "Not allowed");
        return project.length++;
    }

    function setControllerStateToProject(
        uint256 pid,
        address payable latestProjectCtrl,
        address payable latestRefundCtrl,
        address payable latestDisputeCtrl,
        address payable latestUtilityCtrl,
        bytes32 cntrllrs
    )
        external

    {
        require(msg.sender == address(primary), "Not allowed");
        require(
            project[pid].projectController == address(0) &&
            project[pid].refundController  == address(0) &&
            project[pid].disputeController == address(0) &&
            project[pid].utilityController == address(0),
            "Controllers are already set"
        );
        project[pid].projectController = latestProjectCtrl;
        project[pid].refundController  = latestRefundCtrl;
        project[pid].disputeController = latestDisputeCtrl;
        project[pid].utilityController = latestUtilityCtrl;

        project[pid].controllerState = cntrllrs;
    }

    function setProjectId(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].id = pid;
    }

    function setProjectCurrentState(uint256 pid, uint8 currentState)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.current = ProjectCurrentState(currentState);
    }

    function setInitialProtectionRate(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.protectionRate = primary.getMaxProtectionPercentage();
    }

    function setProtectionRate(uint256 pid, uint256 protectionPercentage)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.protectionRate = protectionPercentage;
    }

    function setVotesForRefundState(uint256 pid, uint256 numberOfVotes)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.votesForRefundState = numberOfVotes;
    }

    function setPercentageFloatContainer(uint256 pid, uint256 amountOfFunds)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.percentageFloatContainer = amountOfFunds;
    }

    function setOwnerPercentageFloatContainer(
        uint256 pid,
        uint256 amountOfFunds
      )
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.ownerPercentageFloatContainer = amountOfFunds;
    }

    function setPolicyBase(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.policyBase = block.number + primary.getDefaultBasePolicyDuration();
    }

    function setPolicyEnd(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.policyEndDate = block.number + primary.getDefaultPolicyDuration();
    }

    function setAmountOfFundsContributed(uint256 pid, uint256 amount)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.amountOfFundsContributed = amount;
    }

    function setTotalAmountSecuredEther(uint256 pid, uint256 amount)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.totalAmountSecuredEther = amount;
    }

    function setReturnedRefundTokens(uint256 pid, uint256 amount)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.returnedRefundTokens = amount;
    }

    function setInvestorToProject(uint256 pid, address investor)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.protectedInvestors.push(investor);
    }

    function setRefundStatePeriod(uint256 pid, uint256 numberInBlocks)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.refundStatePeriod = numberInBlocks;
    }

    function setFreezeStatePeriod(uint256 pid, uint256 numberInBlocks)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.freezeStatePeriod = numberInBlocks;
    }

    function setOwnerContribution(uint256 pid, uint256 amount)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.ownerContribution = amount;
    }

    function setOwnerFunds(uint256 pid, address ownerAddr, uint256 amount)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.ownerFunds[ownerAddr] = amount;
    }

    function setInsuranceIdToProject(uint256 pid, uint256 insId)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.protectedInvestments.push(insId);
    }

    function removeInsuranceIdFromProject(uint256 pid, uint256 ins, uint256 idx)
        external
        onlyValidProjectControllers(pid)
    {
        uint256 replacementIndex = project[pid].data.protectedInvestments.length - 1;
        uint256 replacementIns = project[pid].data.protectedInvestments[replacementIndex];
        if (idx == 0) {
            for (uint256 i = 1; i < project[pid].data.protectedInvestments.length; i++) {
                if (project[pid].data.protectedInvestments[i] == ins) {
                    project[pid].data.protectedInvestments[i] = replacementIns;
                    break;
                }
            }
        } else {
            project[pid].data.protectedInvestments[idx] = replacementIns;
        }
        project[pid].data.protectedInvestments.length--;
    }

    function removeInvestorAddressFromProject(uint256 pid, address investorAddress, uint256 idx)
        external
        onlyValidProjectControllers(pid)
    {
        uint256 replacementIndex = project[pid].data.protectedInvestors.length - 1;
        address replacementInvst = project[pid].data.protectedInvestors[replacementIndex];
        if (idx == 0) {
            for (uint256 i = 1; i < project[pid].data.protectedInvestors.length; i++) {
                if (project[pid].data.protectedInvestors[i] == investorAddress) {
                    project[pid].data.protectedInvestors[i] = replacementInvst;
                    break;
                }
            }
        } else {
            project[pid].data.protectedInvestors[idx] = replacementInvst;
        }
        project[pid].data.protectedInvestors.length--;
    }

    function setProjectName(uint256 pid, bytes calldata name)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.projectName = name;
    }

    function setProjectTokenContract(uint256 pid, address tokenAddress)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.projectTokenContract = ProjectTokenInterface(tokenAddress);
    }

    function setCrowdsaleEndTime(uint256 pid, uint256 crowdsaleEnd)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.crowdsaleEndDate = crowdsaleEnd;
    }

    function setHighestTokenPrice(uint256 pid, uint256 highestTokenPrice)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.lastCrowdsalePrice = highestTokenPrice;
    }

    function setTokenDecimals(uint256 pid, uint8 tokenDecimals)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.tokenDecimals = tokenDecimals;
    }

    function setTokenLitter(
        uint256 pid,
        uint256 ins,
        address tokenLitter
    )
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.tokenLitter[ins] = tokenLitter;
    }

    function setMinAmountProjectTokens(
        uint256 pid,
        uint256 minAmountProjectTokens,
        address investor
    )
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].token.minimumAmountOfProjectTokens[investor] = minAmountProjectTokens;
    }

    function setAlreadyProtected(
        uint256 pid,
        address investor
    )
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].data.alreadyProtected[investor] = true;
    }

    function setVoteEnd(uint256 pid, uint256 numberOfBlock)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.voteEnd = numberOfBlock;
    }

    function setIsInvestorsVoteFailed(uint256 pid, bool failedOrNot)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.isInvestorsVoteFailed = failedOrNot;
    }

    function setIsRefundInProgress(uint256 pid, bool status)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.isRefundInProgress = status;
    }

    function setIsDisputed(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.isDisputed = true;
    }

    function setOwnerBaseFundsRepaid(uint256 pid, address owner)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.ownerBaseFundsRepaid[owner] = true;
    }

    function setBasePolicyExpired(uint256 pid)
        external
        onlyValidProjectControllers(pid)
    {
        project[pid].state.basePolicyExpired = true;
    }

    function setForcedRefundState(uint256 pid, uint8 value) external onlyValidProjectControllers(pid) {
        project[pid].state.isRefundStateForced = ForcedRefundState(value);
    }

    function getActiveProjects() external view returns (uint256) {
        uint256 activeProjects;
        uint8 pjs;
        for (uint256 i = 0; project.length > i; i++) {
            pjs = uint8(project[i].state.current);
            if (pjs != 4 && pjs != 5 && pjs != 6) {
                activeProjects++;
            }
        }
        return activeProjects;
    }

    function getProjectControllerState(uint256 pid) external view returns (bytes32) {
        return project[pid].controllerState;
    }

    function getRefundControllerOfProject(uint256 pid) external view returns (address payable) {
        return project[pid].refundController;
    }

    function getUtilityControllerOfProject(uint256 pid) external view returns (address payable) {
        return project[pid].utilityController;
    }

    function getDisputeControllerOfProject(uint256 pid) external view returns (address payable) {
        return project[pid].disputeController;
    }

    function getProjectControllerOfProject(uint256 pid) external view returns (address payable) {
        return project[pid].projectController;
    }

    function getNumberOfCoveredProjects() external view returns (uint256) {
        return project.length;
    }

    function getAmountOfFundsContributed(uint256 pid) external view returns (uint256) {
        return project[pid].data.amountOfFundsContributed;
    }

    function getProjectCurrentState(uint256 pid) external view returns (uint8) {
        return uint8(project[pid].state.current);
    }

    function getCrowdsaleEndTime(uint256 pid) external view returns (uint256) {
        return project[pid].token.crowdsaleEndDate;
    }

    function getAlreadyProtected(uint256 pid, address investor)
        external
        view
        returns(bool isProtected)
    {
        return project[pid].data.alreadyProtected[investor];
    }

    function getTotalAmountSecuredEther(uint256 pid) external view returns (uint256) {
        return project[pid].data.totalAmountSecuredEther;
    }

    function getProtectionRate(uint256 pid) external view returns (uint256) {
        return project[pid].data.protectionRate;
    }

    function getHighestTokenPrice(uint256 pid) external view returns (uint256) {
        return project[pid].token.lastCrowdsalePrice;
    }

    function getTokenDecimals(uint256 pid) external view returns (uint8) {
        return project[pid].token.tokenDecimals;
    }

    function getProjectTokenAddress(uint256 pid) external view returns (address) {
        return address(project[pid].token.projectTokenContract);
    }

    function getProjectTokenContract(uint256 pid) external view returns (ProjectTokenInterface) {
        return project[pid].token.projectTokenContract;
    }

    function getTokenLitter(uint256 pid, uint256 ins) external view returns (address) {
        return project[pid].token.tokenLitter[ins];
    }

    function getPercentageFloatContainer(uint256 pid) external view returns (uint256) {
        return project[pid].data.percentageFloatContainer;
    }

    function getOwnerContribution(uint256 pid) external view returns (uint256) {
        return project[pid].data.ownerContribution;
    }

    function getOwnerPercentageFloatContainer(uint256 pid) external view returns (uint256) {
        return project[pid].data.ownerPercentageFloatContainer;
    }

    function getProjectName(uint256 pid) external view returns (bytes memory) {
        return project[pid].data.projectName;
    }

    function getNumberOfProjectInvestments(uint256 pid) external view returns (uint256) {
        return project[pid].data.protectedInvestments.length;
    }

    function getReturnedRefundTokens(uint256 pid)
        external
        view
        returns (uint256)
    {
        return project[pid].data.returnedRefundTokens;
    }

    function getVotesForRefundState(uint256 pid)
        external
        view
        onlyValidProjectControllers(pid)
        returns (uint256)
    {
        return project[pid].data.votesForRefundState;
    }

    function getPolicyBase(uint256 pid) external view returns (uint256) {
        return project[pid].data.policyBase;
    }

    function getPolicyEndDate(uint256 pid) external view returns (uint256) {
        return project[pid].data.policyEndDate;
    }

    function getAddressOfInvestorInProject(uint256 pid, uint256 invstrNumber) external view returns (address) {
        return project[pid].data.protectedInvestors[invstrNumber];
    }

    function getNumberOfInvestor(uint256 pid, address investorAddress)
        external
        view
        returns(uint256)
    {
        for (uint256 i = 1; i < project[pid].data.protectedInvestors.length; i++) {
            if (project[pid].data.protectedInvestors[i] == investorAddress) {
                return i;
            }
        }
    }

    function getNumberOfInvestmentToProject(uint256 pid, uint256 insId) external view returns (uint256) {
        for (uint256 i = 1; i < project[pid].data.protectedInvestments.length; i++) {
            if (project[pid].data.protectedInvestments[i] == insId) {
                return i;
            }
        }
    }

    function getOwnerFunds(uint256 pid, address ownerAddr) external view returns (uint256) {
        return project[pid].data.ownerFunds[ownerAddr];
    }

    function getInvestmentId(uint256 pid, address investor) external view returns (uint256 insId) {
        for (uint256 i = 1; i < project[pid].data.protectedInvestments.length; i++) {
            insId = project[pid].data.protectedInvestments[i];
            if (investor == primary.getInsuranceOwner(insId)) {
                return insId;
            }
        }
    }

    function getMinAmountProjectTokens(uint256 pid, address investor) external view returns (uint256) {
        return project[pid].token.minimumAmountOfProjectTokens[investor];
    }

    function getInvestmentToProject(
        uint256 pid,
        uint256 insuranceNumber
    )
        external
        view
        returns (uint256 investmentId)
    {
        return project[pid].data.protectedInvestments[insuranceNumber];
    }

    function getRefundStatePeriod(uint256 pid) external view returns (uint256) {
        return project[pid].state.refundStatePeriod;
    }

    function getFreezeStatePeriod(uint256 pid) external view returns (uint256) {
        return project[pid].state.freezeStatePeriod;
    }

    function getVoteEnd(uint256 pid) external view returns (uint256) {
        return project[pid].state.voteEnd;
    }

    function getIsInvestorsVoteFailed(uint256 pid) external view returns (bool) {
        return project[pid].state.isInvestorsVoteFailed;
    }

    function getIsRefundInProgress(uint256 pid) external view returns (bool) {
        return project[pid].state.isRefundInProgress;
    }

    function getIsDisputed(uint256 pid) external view returns (bool) {
        return project[pid].state.isDisputed;
    }

    function getOwnerBaseFundsRepaid(uint256 pid, address owner)
        external
        view
        returns (bool)
    {
        return project[pid].state.ownerBaseFundsRepaid[owner];
    }

    function getBasePolicyExpired(uint256 pid)
        external
        view
        returns (bool)
    {
        return project[pid].state.basePolicyExpired;
    }

    function isRefundStateForced(uint256 pid) external view returns (uint8) {
        return uint8(project[pid].state.isRefundStateForced);
    }

    function getEligibleForInternalVote(uint256 pid)
        external
        view
        returns (uint256 eligibleInvestors, uint256 validSecuredEther)
    {
        uint256 insrnc;
        uint256 numinv = project[pid].data.protectedInvestments.length;
        for (uint256 i = 1; i < numinv; i++) {
            if (i > 412) {
                eligibleInvestors += (numinv - i);
                for (i; i < numinv; i++) {
                    validSecuredEther += primary.getEtherSecured(project[pid].data.protectedInvestments[i]);
                }
                break;
            }

            insrnc = project[pid].data.protectedInvestments[i];
            if (!project[pid].state.isInvestorsVoteFailed) {
                eligibleInvestors++;
                validSecuredEther += primary.getEtherSecured(insrnc);
            } else {
                if (!primary.getVotedForARefund(insrnc)) {
                    eligibleInvestors++;
                    validSecuredEther += primary.getEtherSecured(insrnc);
                }
            }
        }
        return (eligibleInvestors, validSecuredEther);
    }

    function getInvalidInsurances(uint256 pid)
        external
        view
        returns (uint256[8] memory invalidInsurances)
    {
        ProjectTokenInterface tknadd = project[pid].token.projectTokenContract;
        uint256 i = 1;
        uint256 invalid;
        address investor;
        uint256 insurance;
        address tknlitter;

        while (i < project[pid].data.protectedInvestments.length && invalid < 8) {
            insurance = project[pid].data.protectedInvestments[i];
            if (!primary.isCanceled(insurance)) {
                investor = project[pid].data.protectedInvestors[i];
                tknlitter = project[pid].token.tokenLitter[insurance];

                if (tknadd.balanceOf(tknlitter) < project[pid].token.minimumAmountOfProjectTokens[investor] &&
                    tknadd.balanceOf(investor) < project[pid].token.minimumAmountOfProjectTokens[investor]) {
                    invalidInsurances[invalid] = insurance;
                    invalid++;
                }
            }
            i++;
        }
        return invalidInsurances;
    }

    function getIncorrectlyVoted(uint256 pid)
        external
        view
        returns (uint256[8] memory invalidInsurances)
    {
        uint256 i = 1;
        uint256 invalid;
        uint256 insurance;
        bool intvtf = project[pid].state.isInvestorsVoteFailed;
        while (i < project[pid].data.protectedInvestments.length && invalid < 8) {
            insurance = project[pid].data.protectedInvestments[i];
            if (!intvtf && primary.getVotedForARefund(insurance) && !primary.isCanceled(insurance)) {
                invalidInsurances[invalid] = insurance;
                invalid++;
            }
            if (intvtf && primary.getVotedAfterFailedVoting(insurance) && !primary.isCanceled(insurance)) {
                invalidInsurances[invalid] = insurance;
                invalid++;
            }
            i++;
        }
        return invalidInsurances;
    }

    function getOverallSecuredFunds() external view returns (uint256) {
        uint8 pjs;
        uint256 totalSecuredFunds;
        for (uint256 i = 0; project.length > i; i++) {
            pjs = uint8(project[i].state.current);
            if (pjs != 4 && pjs != 5 && pjs != 6 && project[i].data.totalAmountSecuredEther > 1) {
                totalSecuredFunds = totalSecuredFunds + project[i].data.totalAmountSecuredEther;
            }
        }
    }

    function onlyProjectControllers(address caller, uint256 pid) external view returns (bool) {
        return _verifyProjectControllers(caller, pid);
    }

    function _verifyProjectControllers(address caller, uint256 pid) internal view returns (bool) {
        if (caller == project[pid].projectController ||
            caller == project[pid].refundController  ||
            caller == project[pid].disputeController ||
            caller == project[pid].utilityController) {
            return true;
        } else {
            return false;
        }
    }
}
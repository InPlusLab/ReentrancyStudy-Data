/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity ^0.5.7;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface PrimaryStorage {
		function getInsuranceOwner(uint256 insId) external view returns (address);
		function getPoolContribution(uint256 insId) external view returns (uint256);
		function getTimeOfTheRequest(uint256 insId) external view returns (uint256);
		function getAmountAvailableForWithdraw(address userAddr, uint256 pid) external view returns (uint256);
		function getIsRefunded(uint256 insId) external view returns (bool);
		function getVotedForARefund(uint256 insId) external view returns (bool);
		function getVotedAfterFailedVoting(uint256 insId) external view returns (bool);
		function getEtherSecured(uint256 insId) external view returns (uint256);
		function setEtherSecured(uint256 insId, uint256 amount) external;
		function setIsRefunded(uint256 insId) external;
		function setAmountAvailableForWithdraw(address userAddr, uint256 pid, uint256 amount) external;
		function setVotedForARefund(uint256 insId) external;
		function setVotedAfterFailedVoting(uint256 insId) external;
		function setPoolContribution(uint256 insId, uint256 amount) external;
		function cancelInsurance(uint256 insId) external;
		function isCanceled(uint256 insId) external view returns (bool);
		function isInvestor(address who) external view returns (bool);
		function getUtilityController() external view returns (address);
		function getDisputesOfProject(uint256 pid) external view returns (uint256[] memory disputeIds);
		function getNumberOfVotesForRefundState(uint256 disputeId) external view returns (uint256);
		function getNumberOfVotesAgainstRefundState(uint256 disputeId) external view  returns (uint256);
}


interface ProjectTokenInterface {
    function balanceOf(address who) external returns (uint256);
}


interface SecondaryStorage {
		function getPolicyEndDate(uint256 pid) external view returns (uint256);
		function getPolicyBase(uint256 pid) external view returns (uint256);
		function getCrowdsaleEndTime(uint256 pid) external view returns (uint256);
		function getProjectCurrentState(uint256 pid) external view returns (uint8);
		function setProjectCurrentState(uint256 pid, uint8 currentState) external;
		function getIsInvestorsVoteFailed(uint256 pid) external view returns (bool);
		function getVoteEnd(uint256 pid) external view returns (uint256);
		function setVoteEnd(uint256 pid, uint256 numberOfBlock) external;
		function getFreezeStatePeriod(uint256 pid) external view returns (uint256);
		function getTokenLitter(uint256 pid, uint256 ins) external view returns (address);
		function getProjectTokenContract(uint256 pid) external view returns (ProjectTokenInterface);
		function getMinAmountProjectTokens(uint256 pid, address investor) external view returns (uint256);
		function getVotesForRefundState(uint256 pid) external view returns (uint256);
		function getNumberOfProjectInvestments(uint256 pid) external view returns (uint256);
		function getReturnedRefundTokens(uint256 pid) external view returns (uint256);
		function getIsRefundInProgress(uint256 pid) external view returns (bool);
		function getRefundStatePeriod(uint256 pid) external view returns (uint256);
		function setIsRefundInProgress(uint256 pid, bool status) external;
		function getTotalAmountSecuredEther(uint256 pid) external view returns (uint256);
		function setVotesForRefundState(uint256 pid, uint256 numberOfVotes) external;
		function setRefundStatePeriod(uint256 pid, uint256 numberInBlocks) external;
		function setFreezeStatePeriod(uint256 pid, uint256 numberInBlocks) external;
		function setAmountOfFundsContributed(uint256 pid, uint256 amount) external;
		function getAmountOfFundsContributed(uint256 pid) external view returns (uint256);
		function setTotalAmountSecuredEther(uint256 pid, uint256 amount) external;
		function removeInsuranceIdFromProject(uint256 pid, uint256 insuranceId, uint256 insIdx) external;
		function removeInvestorAddressFromProject(uint256 pid, address investorAddress, uint256 insOwnerIdx) external;
		function setReturnedRefundTokens(uint256 pid, uint256 amount) external;
		function getIsDisputed(uint256 pid) external view returns (bool);
		function setIsInvestorsVoteFailed(uint256 pid, bool failedOrNot) external;
		function getUtilityControllerOfProject(uint256 pid) external view returns (address payable);
		function getEligibleForInternalVote(uint256 pid) external view returns (uint256 eligibleInvestors, uint256 validSecuredEther);
		function isRefundStateForced(uint256 pid) external view returns (uint8);
		function setForcedRefundState(uint256 pid, uint8 value) external;
}

interface RefundEtherInterface {
    function getAmountOfSecuredEther(address investor, uint256 projectId) external view returns (uint256);
    function setAmountOfSecuredEther(address investor, uint256 projectId, uint256 amount) external returns (bool success);
    function burn(address _tokensOwner, uint256 _value) external returns (bool success);
}

interface Logger {
    function emitInsuranceCanceled(address owner, uint256 insuranceId) external;
    function emitRefundStateRequested(address investor, uint256 insuranceId, uint256 projectId) external;
    function emitInternalVoteFailed(uint256 projectId) external;
    function emitRefundInProgress(uint256 projectId) external;
    function emitRefundWithdraw(address investor, uint256 projectId, uint256 insuranceId, uint256 amount) external;
    function emitRefundStateForced(address moderator, uint256 projectId) external;
    function emitRefundStateEnded(uint256 projdectId) external;
}

contract RefundController {
    using SafeMath for uint256;

    PrimaryStorage       masterStorage;
    SecondaryStorage     secondStorage;
    RefundEtherInterface refundEther;
    Logger               eventLogger;

    address payable private main;

    constructor(
        address payable dAppMainContractAddr,
        address storageAddr,
        address secStorageAddr,
        address refundEtherAddr,
        address eventLoggerAddr
    )
        public
    {
        masterStorage = PrimaryStorage(storageAddr);
        secondStorage = SecondaryStorage(secStorageAddr);
        refundEther = RefundEtherInterface(refundEtherAddr);
        eventLogger = Logger(eventLoggerAddr);
        main = dAppMainContractAddr;
    }

    modifier onlyMain {
        if(msg.sender == main) {
            _;
        }
        else {
            revert("Only main contract is allowed");
        }
    }

    modifier onlyInsuranceOwner(address owner, uint256 ins) {
        if (owner == masterStorage.getInsuranceOwner(ins)) {
            _;
        } else {
            revert("Only the address owning the insurance is allowed");
        }
    }

    modifier notCanceled(uint256 ins) {
        if (!masterStorage.isCanceled(ins)) {
            _;
        } else {
            revert("Insurance is canceled");
        }
    }

    function cancel(uint256 ins, uint256 pid, address insOwner)
        external
        onlyMain
        onlyInsuranceOwner(insOwner, ins)
        notCanceled(ins)
        returns (bool)
    {
        uint8 currentProjectState = secondStorage.getProjectCurrentState(pid);

        require(
            currentProjectState == 0 || currentProjectState == 1,
            "Project is not in a state allowing insurance cancelation"
        );
        require(
            block.number > masterStorage.getTimeOfTheRequest(ins).add(185142) &&
            block.number < masterStorage.getTimeOfTheRequest(ins).add(555426),
            "Canceling is only allowed for 3 months after insurance was made"
        );
        require(!_isRefundInProgress(pid), "In process of refunding");
        if (block.number > secondStorage.getPolicyEndDate(pid)) {
            secondStorage.setProjectCurrentState(pid, 6);
            return false;
        }
        _cancelInvestmentProtection(ins, pid, insOwner);
        uint256 poolContrib = masterStorage.getPoolContribution(ins);
        secondStorage.setAmountOfFundsContributed(
            pid,
            secondStorage.getAmountOfFundsContributed(pid).sub(poolContrib)
        );
        secondStorage.removeInsuranceIdFromProject(pid, ins, 0);
        secondStorage.removeInvestorAddressFromProject(pid, insOwner, 0);
        masterStorage.setPoolContribution(ins, 0);

        require(poolContrib > 0, "No secured funds");
        masterStorage.setAmountAvailableForWithdraw(
            insOwner,
            pid,
            poolContrib
        );
        poolContrib = 0;
        return true;
    }

    function voteForRefundState(address owner, uint256 ins, uint256 pid)
        external
        onlyMain
        onlyInsuranceOwner(owner, ins)
        notCanceled(ins)
        returns (bool)
    {
        uint8 cps = secondStorage.getProjectCurrentState(pid);
        if (block.number > secondStorage.getCrowdsaleEndTime(pid).add(93558) && cps == 0) {
            secondStorage.setProjectCurrentState(pid, 1);
            cps = 1;
        }
        require(cps == 1 || cps == 2, "Vote not allowed in the current project state");
        if (block.number > secondStorage.getPolicyEndDate(pid)) {
            secondStorage.setProjectCurrentState(pid, 6);
            return false;
        }
        require(
            block.number > secondStorage.getCrowdsaleEndTime(pid).add(555426) &&
            !masterStorage.getIsRefunded(ins),
            "Cancelation period for this project is not expired or it has been already refunded"
        );
        if (secondStorage.getIsInvestorsVoteFailed(pid) && masterStorage.getVotedForARefund(ins)) {
            _cancelInvestmentProtection(ins, pid, owner);
            return false;
        }
        require(
            block.number > secondStorage.getFreezeStatePeriod(pid) &&
            !masterStorage.getVotedForARefund(ins) &&
            !_isRefundInProgress(pid),
            "Not eligible for a refund state vote"
        );
        if (!_checkReturnedTokens(pid, owner, secondStorage.getTokenLitter(pid, ins))) {
            if (secondStorage.getProjectTokenContract(pid).balanceOf(owner) < secondStorage.getMinAmountProjectTokens(pid, owner)) {
                _cancelInvestmentProtection(ins, pid, owner);
                return false;
            } else {
                revert("You have to sent your project tokens to your token litter in order to request a refund state");
            }
        }

        if (cps != 2 && secondStorage.getVoteEnd(pid).add(185142) > block.number) {
            revert("1 month is not passed since the previous minor internal vote");
        }
        if (cps == 2 && block.number > secondStorage.getVoteEnd(pid)) {
            return _processInternalVote(pid);
        }
        uint256 reth = refundEther.getAmountOfSecuredEther(owner, pid);
        require(reth > 1, "Not allowed. No RefundEther tokens.");

        refundEther.setAmountOfSecuredEther(owner, pid, 1);
        refundEther.burn(owner, reth);
        secondStorage.setReturnedRefundTokens(
            pid,
            secondStorage.getReturnedRefundTokens(pid).add(reth)
        );
        reth = 0;
        secondStorage.setVotesForRefundState(
            pid,
            secondStorage.getVotesForRefundState(pid).add(1)
        );

        if (!secondStorage.getIsInvestorsVoteFailed(pid)) {
            masterStorage.setVotedForARefund(ins);
        } else {
            masterStorage.setVotedAfterFailedVoting(ins);
        }
        uint256 vfr = secondStorage.getVotesForRefundState(pid).mul(100);
        uint256 mpv = (secondStorage.getNumberOfProjectInvestments(pid).sub(1)).mul(15);
        if (cps != 2 && vfr > mpv && secondStorage.getReturnedRefundTokens(pid) > 12 ether) {
            secondStorage.setProjectCurrentState(pid, 2);
            secondStorage.setVoteEnd(pid, block.number.add(555426));
        }
        eventLogger.emitRefundStateRequested(owner, ins, pid);
        return true;
    }

    function withdraw(address owner, uint256 ins, uint256 pid)
        external
        onlyInsuranceOwner(owner, ins)
        notCanceled(ins)
        onlyMain
        returns (bool)
    {
        require(secondStorage.getProjectCurrentState(pid) == 1, "Project is not in a refund state");
        require(!masterStorage.getIsRefunded(ins), "Already refunded investment");
        require(block.number > secondStorage.getFreezeStatePeriod(pid), "Freezetime, not available yet");
        require(secondStorage.getIsRefundInProgress(pid), "Not in a refund State");
        if (secondStorage.getRefundStatePeriod(pid) < block.number) {
            secondStorage.setProjectCurrentState(pid, 4);
            secondStorage.setIsRefundInProgress(pid, false);
            eventLogger.emitRefundStateEnded(pid);
            return false;
        }

        bool isInternalVoteFailed = secondStorage.getIsInvestorsVoteFailed(pid);
        if (isInternalVoteFailed && masterStorage.getVotedForARefund(ins)) {
            _cancelInvestmentProtection(ins, pid, owner);
            return false;
        }

        uint256 etherToRefund;

        if (secondStorage.getPolicyBase(pid) < block.number) {
            etherToRefund = masterStorage.getEtherSecured(ins).div(2);
        } else {
            etherToRefund = masterStorage.getEtherSecured(ins);
        }
        secondStorage.setTotalAmountSecuredEther(
            pid,
            secondStorage.getTotalAmountSecuredEther(pid).sub(etherToRefund)
        );
        masterStorage.setEtherSecured(ins, 0);
        masterStorage.setIsRefunded(ins);
        require(etherToRefund > 0, "No funds available");
        masterStorage.setAmountAvailableForWithdraw(
            owner,
            pid,
            etherToRefund
        );

        eventLogger.emitRefundWithdraw(owner, pid, ins, etherToRefund);
        return true;
    }

    function forceRefundState(address moderator, uint256 pid)
        external
        onlyMain
        returns (bool)
    {
        uint8 currentProjectState = secondStorage.getProjectCurrentState(pid);
        uint8 isRefundStateForced = secondStorage.isRefundStateForced(pid);
        require (
            currentProjectState != 3 || currentProjectState != 4 ||
            currentProjectState != 5 || currentProjectState != 6, "Not allowed"
        );
        require(!_isRefundInProgress(pid) && isRefundStateForced == 0, "In a refund state or was already forced to one previously.");
        secondStorage.setForcedRefundState(pid, 1);
        eventLogger.emitRefundStateForced(moderator, pid);
        return _setRefundState(pid);
    }

    function invalidateInsurance(uint256 ins, uint256 pid) external {
        address utilityController = secondStorage.getUtilityControllerOfProject(pid);
        require(msg.sender == utilityController, "Not allowed");

        address insOwner = masterStorage.getInsuranceOwner(ins);
        _cancelInvestmentProtection(ins, pid, insOwner);
    }

    function finalizeVote(uint256 pid) external {
        address utilityController = secondStorage.getUtilityControllerOfProject(pid);
        require(msg.sender == utilityController || msg.sender == main, "Not allowed");
        _processInternalVote(pid);
    }

    function _processInternalVote(uint256 pid) internal returns (bool) {
        (uint256 evi, uint256 ese) = secondStorage.getEligibleForInternalVote(pid);
        bool forcedRefundState = (secondStorage.isRefundStateForced(pid) == 1);
        if (forcedRefundState && _isRefundInProgress(pid)) {
            secondStorage.setVoteEnd(pid, 1);
            return true;
        }

        if (ese < 188 ether && evi <= 24) {
            if (secondStorage.getReturnedRefundTokens(pid) >= ese.mul(90).div(100) &&
               (secondStorage.getVotesForRefundState(pid) - 1).mul(100) >= evi.mul(900).div(10)) {
                return _setRefundState(pid);
            }
        }
        if (ese >= 188 ether && ese <= 812 ether && evi > 24 && evi <= 88) {
            if (secondStorage.getReturnedRefundTokens(pid) >= ese.mul(85).div(100) &&
               (secondStorage.getVotesForRefundState(pid) - 1).mul(100) >= evi.mul(850).div(10)) {
                return _setRefundState(pid);
            }
        }
        if (ese > 812 ether && evi > 88) {
            if (secondStorage.getReturnedRefundTokens(pid) >= ese.mul(80).div(100) &&
               (secondStorage.getVotesForRefundState(pid) - 1).mul(100) >= evi.mul(800).div(10)) {
                return _setRefundState(pid);
            }
        } else {
            if ((secondStorage.getVotesForRefundState(pid) - 1).mul(100) >= evi.mul(950).div(10)) {
                return _setRefundState(pid);
            }
        }
        _internalVoteFailed(pid, evi, ese);
        return false;
    }

    function _setRefundState(uint256 pid) internal returns (bool) {
        secondStorage.setRefundStatePeriod(pid, block.number.add(1110852));
        secondStorage.setFreezeStatePeriod(pid, block.number.add(46779));
        secondStorage.setIsRefundInProgress(pid, true);
        secondStorage.setProjectCurrentState(pid, 1);

        eventLogger.emitRefundInProgress(pid);
        return true;
    }

    function _internalVoteFailed(
        uint256 pid,
        uint256 evi,
        uint256 ese
    )
        internal
        returns (bool)
    {
        secondStorage.setProjectCurrentState(pid, 1);
        if (secondStorage.getIsInvestorsVoteFailed(pid) &&
            secondStorage.getReturnedRefundTokens(pid) > ese.mul(51).div(100) &&
            secondStorage.getVotesForRefundState(pid).mul(100) > evi.mul(51))
        {
            secondStorage.setProjectCurrentState(pid, 5);
            eventLogger.emitInternalVoteFailed(pid);
            return true;
        }
        if (!secondStorage.getIsInvestorsVoteFailed(pid) &&
            secondStorage.getReturnedRefundTokens(pid) > ese.mul(51).div(100) &&
            secondStorage.getVotesForRefundState(pid).mul(100) > evi.mul(51))
        {
            secondStorage.setFreezeStatePeriod(pid, block.number.add(46779));
            secondStorage.setIsInvestorsVoteFailed(pid, true);

            secondStorage.setVoteEnd(pid, 1);

            secondStorage.setVotesForRefundState(pid, 1);
            secondStorage.setReturnedRefundTokens(pid, 2);
            eventLogger.emitInternalVoteFailed(pid);
            return true;
        } else {
            secondStorage.setVotesForRefundState(pid, 1);
            secondStorage.setReturnedRefundTokens(pid, 2);
            secondStorage.setFreezeStatePeriod(pid, 1);
            eventLogger.emitInternalVoteFailed(pid);
            return true;
        }
    }

    function _checkReturnedTokens(uint256 pid, address owner, address litter)
        internal
        returns (bool tokensAreReturned)
    {
        uint256 returnedTokens = secondStorage.getProjectTokenContract(pid).balanceOf(litter);
        tokensAreReturned = returnedTokens >= secondStorage.getMinAmountProjectTokens(pid, owner);
        return tokensAreReturned;
    }

    function _cancelInvestmentProtection(uint256 ins, uint256 pid, address insOwner)
        internal
        returns (bool)
    {
        masterStorage.cancelInsurance(ins);
        uint256 ethSecured = masterStorage.getEtherSecured(ins);

        if (secondStorage.getPolicyBase(pid) < block.number) {
            ethSecured = masterStorage.getEtherSecured(ins).div(2);
        } else {
            ethSecured = masterStorage.getEtherSecured(ins);
        }

        masterStorage.setEtherSecured(ins, 0);
        secondStorage.setTotalAmountSecuredEther(
            pid,
            secondStorage.getTotalAmountSecuredEther(pid).sub(ethSecured)
        );

        eventLogger.emitInsuranceCanceled(insOwner, ins);
        return true;
    }

    function _isRefundInProgress(uint256 pid) internal view returns (bool) {
        return secondStorage.getIsRefundInProgress(pid);
    }
}
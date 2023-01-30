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
    function getDisputeVotePeriod(uint256 did) external view returns (uint256);
    function getResultCountPeriod(uint256 did) external view returns (uint256);
    function getDisputeLotteryPrize(uint256 did) external view returns (uint256 votingPrize);
    function getNumberOfVotesForRefundState(uint256 did) external view returns (uint256);
    function getEntryFee(uint256 did) external view returns (uint256);
    function getDisputeCreator(uint256 did) external view returns (address payable);
    function getRandomNumberBaseLength(uint256 did) external view returns (uint256);
    function getDisputeNumberOfVoters(uint256 did) external view returns (uint256);
    function getFirstPublicDisputeURL(uint256 did) external view returns (bytes memory);
    function getDisputeVoter(uint256 did, uint256 voterId) external view returns (address payable);
    function getHiddenVote(uint256 did, address voter) external view returns (bytes32);
    function getRevealedVote(uint256 did, address voter) external view  returns (bool);
    function getNumberOfVotesAgainstRefundState(uint256 did) external view returns (uint256);
    function setPayment(address participant, uint256 disputeId, uint256 paymentAmount) external;
    function getPayment(address payee, uint256 disputeId) external view returns (uint256);
    function addDispute() external returns (uint256 disputeId);
    function addDisputeIds(uint256 disputeId, uint256 pid) external;
    function setDisputeVotePeriod(uint256 disputeId, uint256 numberOfBlock) external;
    function setResultCountPeriod(uint256 disputeId, uint256 numberOfBlock) external;
    function setPublicDisputeURL(uint256 disputeId, bytes calldata disputeUrl) external;
    function setDisputeControllerOfProject(uint256 disputeId, address disputeCtrlAddr) external;
    function setNumberOfVotesForRefundState(uint256 disputeId) external;
    function setNumberOfVotesAgainstRefundState(uint256 disputeId) external;
    function setDisputeLotteryPrize(uint256 disputeId, uint256 amount) external;
    function setEntryFee(uint256 disputeId, uint256 amount) external;
    function setDisputeCreator(uint256 disputeId, address payable creator) external;
    function addToRandomNumberBase(uint256 disputeId, uint256 number) external;
    function getDisputeProjectId(uint256 disputeId) external view returns (uint256);
    function addHiddenVote(uint256 disputeId, address voter, bytes32 voteHash) external;
    function addDisputeVoter(uint256 disputeId, address voterAddress) external returns (uint256 voterId);
    function addRevealedVote(uint256 disputeId, address voter, bool vote) external;
    function randomNumberGenerator(uint256 disputeId) external view returns (uint256 rng);
    function isPlatformModerator(address who) external view returns (bool);
    function isCommunityModerator(address who) external view returns (bool);
    function isInvestor(address who) external view returns (bool);
    function isProjectOwner(address who) external view returns (bool);
    function getInsuranceOwner(uint256 insId) external view returns (address);
    function removeDisputeVoter(uint256 disputeId, uint256 voterIndex) external;
    function getValidationToken(address verificatedUser) external view returns (uint256);
    function getModerationResources() external view returns (address payable);
}


interface SecondaryStorage {
    function setIsDisputed(uint256 pid) external;
    function setIsInvestorsVoteFailed(uint256 pid, bool failedOrNot) external;
    function getIsDisputed(uint256 pid) external view returns (bool);
    function setIsRefundInProgress(uint256 pid, bool status) external;
    function getIsRefundInProgress(uint256 pid) external view returns(bool);
    function getIsInvestorsVoteFailed(uint256 pid) external view returns(bool);
    function getRefundStatePeriod(uint256 pid) external view returns (uint256);
    function getFreezeStatePeriod(uint256 pid) external view returns (uint256);
    function getAlreadyProtected(uint256 pid, address investor) external view returns(bool isProtected);
    function setFreezeStatePeriod(uint256 pid, uint256 numberInBlocks) external;
    function setOwnerContribution(uint256 pid, uint256 amount) external;
    function setOwnerFunds(uint256 pid, address ownerAddr, uint256 amount) external;
    function getProjectCurrentState(uint256 pid) external view returns (uint8);
    function getOwnerFunds(uint256 pid, address ownerAddr) external view returns (uint256);
    function getOwnerContribution(uint256 pid) external view returns (uint256);
    function setProjectCurrentState(uint256 pid, uint8 currentState) external;
    function setRefundStatePeriod(uint256 pid, uint256 numberInBlocks) external;
    function getPolicyEndDate(uint256 pid) external view returns (uint256);
    function setReturnedRefundTokens(uint256 pid, uint256 amount) external;
    function setVotesForRefundState(uint256 pid, uint256 numberOfVotes) external;
    function getUtilityControllerOfProject(uint256 pid) external view returns (address payable);
    function isRefundStateForced(uint256 pid) external view returns (uint8);
    function setForcedRefundState(uint256 pid, uint8 value) external;
    function getAmountOfFundsContributed(uint256 pid) external view returns (uint256);
    function getDisputeControllerOfProject(uint256 pid) external view returns (address payable);
}


interface RefundPool {
    function deposit(uint256 pid) external payable;
    function insuranceDeposit(uint256 pid) external payable;
    function getProjectFunds (uint256 pid) external view returns (uint256);
    function withdraw(uint256 pid, address payable to, uint256 amount) external;
    function withdrawInsuranceFee(uint256 pid, address payable to, uint256 amount) external;
    function cleanIfNoProjects() external;
}



interface Logger {
    function emitNewDispute(address caller, uint256 did, uint256 pid, bytes calldata publicDisputeUrl) external;
    function emitDisputeFinished(uint256 did, uint256 pid, uint256 votesAgainstFailure, uint256 votesFor, address prizeWinner) external;
}


contract DisputeController {
    using SafeMath for uint256;
    using SafeMath for uint64;

    PrimaryStorage   masterStorage;
    SecondaryStorage secondStorage;
    RefundPool       refundPool;
    Logger           eventLogger;

    address private main;

    constructor(
        address dAppMainContractAddr,
        address storageAddr,
        address secStorageAddr,
        address eventLoggerAddr,
        address payable refundPoolAddr
    )
        public
    {
        masterStorage = PrimaryStorage(storageAddr);
        secondStorage = SecondaryStorage(secStorageAddr);
        refundPool = RefundPool(refundPoolAddr);
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

    function createNewDispute (
        address payable caller,
        uint256 pid,
        bytes calldata publicDisputeUrl
    )
        external
        payable
        onlyMain
        returns (bool)
    {
        uint256 did;
        require(secondStorage.getProjectCurrentState(pid) == 1, "Vote not allowed in the current project state");
        bool isInv = masterStorage.isInvestor(caller);
        bool isMod = masterStorage.isPlatformModerator(caller) || masterStorage.isCommunityModerator(caller);
        bool isOwn = masterStorage.isProjectOwner(caller);
        bool isRefundInProgress = secondStorage.getIsRefundInProgress(pid);
        if (!isInv && !isMod && !isOwn) revert("Only investors, supporters and moderators can invoke a dispute");
        if (isInv && isOwn) revert("Not allowed for accounts that are both investors and supporters to a project");

        uint256 cuf = secondStorage.getOwnerFunds(pid, caller);
        if (isOwn && !isMod && cuf > 1) {
            require(isRefundInProgress, "Not allowed - not in a refund state");
            uint256 opc = secondStorage.getOwnerContribution(pid).add(msg.value);
            uint256 poolContributions = secondStorage.getAmountOfFundsContributed(pid);

            if (opc < poolContributions.mul(5).div(100)) {
                revert("The owner funds + the ether sent with this call is less than the dispute lottery prize");
            } else {
                did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
                secondStorage.setOwnerContribution(pid, opc);
                secondStorage.setOwnerFunds(pid, caller, cuf.add(msg.value));
                if (msg.value > 0) refundPool.deposit.value(msg.value)(pid);
            }
            return true;
        }
        if (isMod) {
            require(isRefundInProgress, "The project is not in a refund state set by an internal vote");
            did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
            return true;
        }
        if (isInv && !isMod && !isOwn && !secondStorage.getIsDisputed(pid)) {
            require(
                secondStorage.getAlreadyProtected(pid, caller) &&
                secondStorage.getIsInvestorsVoteFailed(pid), "Not allowed"
            );
            require(msg.value >= 1 ether, "Not enough collateral amount");
            did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
            masterStorage.setPayment(caller, did, msg.value);
            refundPool.deposit.value(msg.value)(pid);
            return true;
        }
        return false;
    }

    function addPublicVote(address payable voter, uint256 did, bytes32 hiddenVote)
        external
        payable
        onlyMain
        returns (bool)
    {
        uint256 votingPeriod = masterStorage.getDisputeVotePeriod(did);
        uint256 pid = masterStorage.getDisputeProjectId(did);
        if (masterStorage.isProjectOwner(voter) ||
            masterStorage.isPlatformModerator(voter) ||
            secondStorage.getAlreadyProtected(pid, voter)) {
            revert("Not allowed");
        }

        if (secondStorage.getProjectCurrentState(pid) != 3 ||
            votingPeriod < block.number ||
            masterStorage.getHiddenVote(did, voter) != bytes32(0)) {
            revert ("Not allowed");
        }

        uint256 validationGasCost;
        address payable modResources = masterStorage.getModerationResources();

        if (masterStorage.getValidationToken(voter) == 0) {
            validationGasCost = 1100000000000000;
            require(msg.value >= masterStorage.getEntryFee(did).add(validationGasCost), "Insufficient voting collateral amount");
            modResources.transfer(validationGasCost);
        } else {
            require(msg.value >= masterStorage.getEntryFee(did), "Insufficient voting collateral amount");
        }

        bytes32 encryptedVote = keccak256(abi.encodePacked(did, voter, hiddenVote));
        masterStorage.addHiddenVote(did, voter, encryptedVote);
        masterStorage.setPayment(voter, did, msg.value.sub(validationGasCost));
        refundPool.deposit.value(msg.value.sub(validationGasCost))(pid);
    }

    function decryptVote(address voter, uint256 did, bool isProjectFailed, uint64 pin)
        external
        onlyMain
        returns (bool)
    {
        uint256 pid = masterStorage.getDisputeProjectId(did);
        uint256 revealPeriod = masterStorage.getResultCountPeriod(did);
        require(secondStorage.getProjectCurrentState(pid) == 3, "Not in a dispute");
        require(block.number > masterStorage.getDisputeVotePeriod(did), "Voting period is not over");
        require(masterStorage.getValidationToken(voter) != 0, "Your account is not verified");

        if (revealPeriod < block.number) {
            finalizeDispute(did);
            return false;
        }

        bytes32 voteHash = keccak256(abi.encodePacked(pin, isProjectFailed));
        bytes32 encryptedVote = keccak256(abi.encodePacked(did, voter, voteHash));

        if (masterStorage.getHiddenVote(did, voter) != encryptedVote) {
            revert("Revealed vote doesn't match with the encrypted one");
        } else {
            uint256 rpb = uint64(address(refundPool).balance);
            if (isProjectFailed) {
                masterStorage.setNumberOfVotesForRefundState(did);
            } else {
                masterStorage.setNumberOfVotesAgainstRefundState(did);
            }
            if (masterStorage.getRandomNumberBaseLength(did) < 112) {
                masterStorage.addToRandomNumberBase(did, pin ^ rpb);
            }
            masterStorage.addRevealedVote(did, voter, isProjectFailed);
            masterStorage.addDisputeVoter(did, voter);
            return true;
        }
    }

    function finalizeDispute(uint256 did) public onlyMain returns (bool) {
        uint256 pid = masterStorage.getDisputeProjectId(did);
        require(secondStorage.getProjectCurrentState(pid) == 3, "Not in a dispute");
        require(block.number > masterStorage.getResultCountPeriod(did), "Vote counting is not finished");
        uint256 nov = masterStorage.getDisputeNumberOfVoters(did);

        if (!_extendDispute(did, pid, nov)) return false;
        uint256 votesAgainstFailure = masterStorage.getNumberOfVotesAgainstRefundState(did);
        uint256 votesForFailure = masterStorage.getNumberOfVotesForRefundState(did);
        bool forcedRefundState = (secondStorage.isRefundStateForced(pid) == 1);
        if (votesAgainstFailure >= votesForFailure ) {
            if (secondStorage.getIsRefundInProgress(pid) && secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setProjectCurrentState(pid, 5);
                secondStorage.setRefundStatePeriod(pid, block.number);
            }
            if (secondStorage.getIsInvestorsVoteFailed(pid) && !secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setFreezeStatePeriod(pid, 1);
                secondStorage.setProjectCurrentState(pid, 1);
                secondStorage.setIsDisputed(pid);
            }
            if (secondStorage.getIsRefundInProgress(pid) && forcedRefundState) {
                secondStorage.setRefundStatePeriod(pid, block.number);
                secondStorage.setProjectCurrentState(pid, 1);
            }
            if (!secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setIsInvestorsVoteFailed(pid, true);
                secondStorage.setReturnedRefundTokens(pid, 1);
                secondStorage.setVotesForRefundState(pid, 1);
            }
            if (secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setIsRefundInProgress(pid, false);
            }
            if (forcedRefundState) {
                secondStorage.setForcedRefundState(pid, 2);
            }
            eventLogger.emitDisputeFinished(did, pid, votesAgainstFailure, votesForFailure, _pickPrizeWinner(did, false, nov));
            return true;
        } else {
            if (!secondStorage.getIsRefundInProgress(pid) &&
                secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setIsInvestorsVoteFailed(pid, false);
            }
            if (!secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setIsRefundInProgress(pid, true);
                secondStorage.setRefundStatePeriod(pid, block.number.add(233894));
            }

            secondStorage.setFreezeStatePeriod(pid, 1);
            secondStorage.setIsDisputed(pid);
            secondStorage.setProjectCurrentState(pid, 1);
            eventLogger.emitDisputeFinished(did, pid, votesAgainstFailure, votesForFailure, _pickPrizeWinner(did, true, nov));
            return true;
        }
    }

    function _pickPrizeWinner(
        uint256 did,
        bool disputeConsensus,
        uint256 numberOfVoters
    )
        internal
        returns (address payable)
    {
        uint256 nov = numberOfVoters;
        uint256 ewi = masterStorage.randomNumberGenerator(did).mod(nov);
        address payable ewa = masterStorage.getDisputeVoter(did, ewi);

        if (masterStorage.getRevealedVote(did, ewa) == disputeConsensus) {
            _setPrizeAmount(did, ewa);
        }

        if (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus) {
            if (nov > ewi.add(1)) {
                ewi++;
                ewa = masterStorage.getDisputeVoter(did, ewi);
                while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                    ewi++;
                    ewa = masterStorage.getDisputeVoter(did, ewi);
                }
                if (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus) {
                    ewi = 0;

                    while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                        ewi++;
                        ewa = masterStorage.getDisputeVoter(did, ewi);
                    }
                    _setPrizeAmount(did, ewa);
                } else {
                    _setPrizeAmount(did, ewa);
                }
            } else {
                ewi = 0;
                while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                    ewi++;
                    ewa = masterStorage.getDisputeVoter(did, ewi);
                }
                _setPrizeAmount(did, ewa);
            }
        }
        return ewa;
    }

    function _addDispute(
        address payable caller,
        uint256 pid,
        bytes memory publicDisputeUrl,
        bool isRefundInProgress
    )
        internal
        returns (uint256 did)
    {
        uint256 fsp = secondStorage.getFreezeStatePeriod(pid);
        require (block.number < fsp, "Not allowed, not in a freezetime");

        did = masterStorage.addDispute();
        masterStorage.setDisputeControllerOfProject(did, secondStorage.getDisputeControllerOfProject(pid));
        masterStorage.addDisputeIds(did, pid);
        masterStorage.setDisputeVotePeriod(did, block.number.add(70169));
        masterStorage.setResultCountPeriod(did, block.number.add(98888));
        masterStorage.setPublicDisputeURL(did, publicDisputeUrl);

        masterStorage.setNumberOfVotesForRefundState(did);
        masterStorage.setNumberOfVotesAgainstRefundState(did);

        uint256 poolContributions = secondStorage.getAmountOfFundsContributed(pid);
        uint256 disputePrize = poolContributions.mul(5).div(100);
        masterStorage.setDisputeLotteryPrize(did, disputePrize);
        masterStorage.setEntryFee(did, 24 finney);

        secondStorage.setFreezeStatePeriod(pid, fsp.add(98888));
        secondStorage.setProjectCurrentState(pid, 3);
        masterStorage.setDisputeCreator(did, caller);

        if (isRefundInProgress) {
            uint256 rsp = secondStorage.getRefundStatePeriod(pid);
            secondStorage.setRefundStatePeriod(pid,rsp.add(98888));
        }
        eventLogger.emitNewDispute(caller, did, pid, publicDisputeUrl);
        return did;
    }

    function _setPrizeAmount(uint256 did, address payable prizeWinner) internal {
        uint256 amount = masterStorage.getDisputeLotteryPrize(did);
        masterStorage.setDisputeLotteryPrize(did, 0);
        require(amount > 1, "Not allowed");
        masterStorage.setPayment(prizeWinner, did, masterStorage.getPayment(prizeWinner, did).add(amount));
    }

    function _extendDispute(uint256 did, uint256 pid, uint256 numberOfVotes) internal returns (bool) {
        if (numberOfVotes < 112) {
            _setExtendedTimers(did, pid);
            return false;
        }
        return true;
    }

    function _setExtendedTimers(uint256 did, uint256 pid) internal {
        if (secondStorage.getPolicyEndDate(pid) > block.number) {
            if (secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setRefundStatePeriod(pid, secondStorage.getRefundStatePeriod(pid).add(98888));
            }
            secondStorage.setFreezeStatePeriod(pid, secondStorage.getFreezeStatePeriod(pid).add(98888));
            masterStorage.setDisputeVotePeriod(did, block.number.add(70169));
            masterStorage.setResultCountPeriod(did, block.number.add(98888));
        } else {
            secondStorage.setProjectCurrentState(pid, 6);
        }
    }
}
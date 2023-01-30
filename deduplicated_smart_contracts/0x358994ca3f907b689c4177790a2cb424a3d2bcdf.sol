/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.7;


interface Storage {
    function allowOnlyDappContracts(address payable caller) external view returns (bool);
}


contract RefundableICOLogger {

    Storage data;

    event PoolDeposit(uint256 indexed pid, uint256 weiAmount);
    event PoolWithdraw(address indexed investorRefunded, uint256 weiAmount);

    event AffiliateDeposit(address indexed affiliate, uint256 weiAmount);
    event AffiliateWithdraw(address indexed affiliate, uint256 weiAmount);

    event NewInsurance(
        uint256 pid,
        address indexed insuranceOwner,
        uint256 indexed insuranceId,
        uint256 indexed contributedAmount
    );

    event NewProject(uint256 indexed pid, bytes projectName);
    event OwnerContribution(
        uint256 indexed pid,
        address indexed ownerAddress,
        uint256 indexed ownerPoolContribution,
        uint256 newProtectionRate
    );
    event NewTokenPrice(uint256 indexed pid, uint256 newPrice, uint256 insurancesProcessed);

    event InsuranceCanceled(address indexed owner, uint256 insuranceId);
    event RefundStateRequested(address indexed investor, uint256 indexed InsuranceId, uint256 indexed projectId);
    event InternalVoteFailed(uint256 indexed projectId);
    event RefundInProgress(uint256 indexed projectId);
    event RefundWithdraw(address indexed investor, uint256 projectId, uint256 indexed insuranceId, uint256 indexed amount);

    event RefundStateForced(address indexed moderator, uint256 indexed projectId);
    event RefundStateEnded(uint256 projdectId);

    event NewDispute(address caller, uint256 indexed did, uint256 indexed pid, bytes indexed publicDisputeUrl);
    event DisputeFinished(uint256 indexed did, uint256 indexed pid, uint256 votesAgainst, uint256 votesFor, address indexed prizeWinner);

    event OwnerBaseFundsRepaid(address indexed owner, uint256 indexed projectId, uint256 indexed amount);
    event OwnerFundsRepaid(address indexed owner, uint256 indexed projectId, uint256 indexed amount);
    event DisputePayment(address payable indexed caller, uint256 indexed disputeId, uint256 indexed amount);
    event PoolFeeRepaid(address indexed owner, uint256 indexed projectId, uint256 indexed amount);

    constructor(address storageAddress) public {
        data = Storage(storageAddress);
    }

    modifier onlyNetworkContracts {
        if (data.allowOnlyDappContracts(msg.sender)) {
            _;
        } else {
            revert("Not allowed to emit events");
        }
    }

    /**
     * RefundPool
     */

    function emitPoolDeposit(uint256 pid, uint256 weiAmount)
        external
        onlyNetworkContracts
    {
        emit PoolDeposit(pid, weiAmount);
    }

    function emitPoolWithdraw(address investorRefunded, uint256 weiAmount)
        external
        onlyNetworkContracts
    {
        emit PoolWithdraw(investorRefunded, weiAmount);
    }

    /**
     * AffiliateEscrow
     */

    function emitAffiliateDeposit(address affiliate, uint256 weiAmount)
        external
        onlyNetworkContracts
    {
        emit AffiliateDeposit(affiliate, weiAmount);
    }

    function emitAffiliateWithdraw(address affiliate, uint256 weiAmount)
        external
        onlyNetworkContracts
    {
        emit AffiliateWithdraw(affiliate, weiAmount);
    }

    /**
     * Project (controller)
     */

    function emitNewInsurance(
        uint256 pid,
        address insuranceOwner,
        uint256 insuranceId,
        uint256 contributedAmount
    )
        external
        onlyNetworkContracts
    {
        emit NewInsurance(pid, insuranceOwner, insuranceId, contributedAmount);
    }

    function emitNewProject(
        uint256 pid,
        bytes calldata projectName
    )
        external
        onlyNetworkContracts
    {
        emit NewProject(pid, projectName);
    }


    function emitOwnerContribution(
        uint256 pid,
        address ownerAddress,
        uint256 ownerPoolContribution,
        uint256 newProtectionRate
    )
        external
        onlyNetworkContracts
    {
        emit OwnerContribution(pid, ownerAddress, ownerPoolContribution, newProtectionRate);
    }

    function emitNewTokenPrice(
        uint256 pid,
        uint256 newPrice,
        uint256 insurancesProcessed
    )
        external
        onlyNetworkContracts
    {
        emit NewTokenPrice(pid, newPrice, insurancesProcessed);
    }

    /**
     * Refund (controller)
     */

    function emitInsuranceCanceled(
        address owner,
        uint256 ins
    )
        external
        onlyNetworkContracts
    {
        emit InsuranceCanceled(owner, ins);
    }

    function emitRefundStateRequested(
        address investor,
        uint256 ins,
        uint256 pid
    )
        external
        onlyNetworkContracts
    {
        emit RefundStateRequested(investor, ins, pid);
    }

    function emitInternalVoteFailed(
        uint256 pid
    )
        external
        onlyNetworkContracts
    {
        emit InternalVoteFailed(pid);
    }

    function emitRefundInProgress(
        uint256 pid
    )
        external
        onlyNetworkContracts
    {
        emit RefundInProgress(pid);
    }

    function emitRefundWithdraw(
        address investor,
        uint256 pid,
        uint256 ins,
        uint256 amount
    )
        external
        onlyNetworkContracts
    {
        emit RefundWithdraw(investor, pid, ins, amount);
    }

    function emitRefundStateForced(
        address moderator,
        uint256 pid
    )
        external
        onlyNetworkContracts
    {
        emit RefundStateForced(moderator, pid);
    }

    function emitRefundStateEnded(
        uint256 pid
    )
        external
        onlyNetworkContracts
    {
        emit RefundStateEnded(pid);
    }


    /**
     * Dispute (controller)
     */

    function emitNewDispute(
        address caller,
        uint256 did,
        uint256 pid,
        bytes calldata publicDisputeUrl
    )
        external
        onlyNetworkContracts
    {
        emit NewDispute(caller, did, pid, publicDisputeUrl);
    }

    function emitDisputeFinished(
        uint256 did,
        uint256 pid,
        uint256 votesAgainst,
        uint256 votesFor,
        address winner
    )
        external
        onlyNetworkContracts
    {
        emit DisputeFinished(did, pid, votesAgainst, votesFor, winner);
    }

    /**
     * Utility (controller)
     */

    function emitOwnerBaseFundsRepaid(
        address owner,
        uint256 pid,
        uint256 amount
    )
        external
        onlyNetworkContracts
    {
        emit OwnerBaseFundsRepaid(owner, pid, amount);
    }

    function emitOwnerFundsRepaid(
        address owner,
        uint256 pid,
        uint256 amount
    )
        external
        onlyNetworkContracts
    {
        emit OwnerFundsRepaid(owner, pid, amount);
    }

    function emitDisputePayment(
        address payable caller,
        uint256 did,
        uint256 amount
    )
        external
        onlyNetworkContracts
    {
        emit DisputePayment(caller, did, amount);
    }

    function emitPoolFeeRepaid(
        address owner,
        uint256 pid,
        uint256 amount
    )
        external
        onlyNetworkContracts
    {
        emit PoolFeeRepaid(owner, pid, amount);
    }
}
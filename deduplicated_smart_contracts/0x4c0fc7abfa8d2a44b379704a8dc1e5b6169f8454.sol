pragma solidity 0.5.3;

import "./AgreementManagerETH.sol";
import "./SimpleArbitrationInterface.sol";

/**
    @notice
    See AgreementManager for comments on the overall nature of this contract.

    This is the contract defining how ETH-only agreements with simple (non-ERC792)
    arbitration work.

    @dev
    The relevant part of the inheritance tree is:
    AgreementManager
        AgreementManagerETH
            AgreementManagerETH_Simple

    We also inherit from SimpleArbitrationInterface, a very simple interface that lets us avoid
    a small amount of code duplication for non-ERC792 arbitration.

    There should be no risk of re-entrancy attacks in this contract, since it makes no external
    calls aside from ETH transfers which always occur in ways that are Reentrancy Safe (see the
    comments in AgreementManager.sol for the meaning of "Reentrancy Safe").
*/

contract AgreementManagerETH_Simple is AgreementManagerETH, SimpleArbitrationInterface {
    // -------------------------------------------------------------------------------------------
    // ------------------------------------- events ----------------------------------------------
    // -------------------------------------------------------------------------------------------

    event ArbitratorResolved(uint32 indexed agreementID, uint resolution);

    // -------------------------------------------------------------------------------------------
    // ---------------------------- external getter functions ------------------------------------
    // -------------------------------------------------------------------------------------------

    /// @return the full state of an agreement.
    /// Return value interpretation is self explanatory if you look at the code
    function getState(
        uint agreementID
    )
        external
        view
        returns (address[3] memory, uint[16] memory, bool[12] memory, bytes memory)
    {
        if (agreementID >= agreements.length) {
            address[3] memory zeroAddrs;
            uint[16] memory zeroUints;
            bool[12] memory zeroBools;
            bytes memory zeroBytes;
            return (zeroAddrs, zeroUints, zeroBools, zeroBytes);
        }

        AgreementDataETH storage agreement = agreements[agreementID];

        address[3] memory addrs = [
            agreement.partyAAddress,
            agreement.partyBAddress,
            agreement.arbitratorAddress
        ];
        uint[16] memory uints = [
            resolutionToWei(agreement.partyAResolution),
            resolutionToWei(agreement.partyBResolution),
            resolutionToWei(agreement.resolution),
            resolutionToWei(agreement.automaticResolution),
            toWei(agreement.partyAStakeAmount),
            toWei(agreement.partyBStakeAmount),
            toWei(agreement.partyAInitialArbitratorFee),
            toWei(agreement.partyBInitialArbitratorFee),
            toWei(agreement.disputeFee),
            agreement.nextArbitrationStepAllowedAfterTimestamp,
            agreement.autoResolveAfterTimestamp,
            agreement.daysToRespondToArbitrationRequest,
            // Return a bunch of zeroes where the ERC792 arbitration data is so we can have the
            // same API for all contracts.
            0,
            0,
            0,
            0
        ];
        bool[12] memory boolVals = [
            partyStakePaid(agreement, Party.A),
            partyStakePaid(agreement, Party.B),
            partyRequestedArbitration(agreement, Party.A),
            partyRequestedArbitration(agreement, Party.B),
            partyReceivedDistribution(agreement, Party.A),
            partyReceivedDistribution(agreement, Party.B),
            partyAResolvedLast(agreement),
            arbitratorResolved(agreement),
            arbitratorReceivedDisputeFee(agreement),
            partyDisputeFeeLiability(agreement, Party.A),
            partyDisputeFeeLiability(agreement, Party.B),
            // Return a false value where the ERC792 arbitration data is so we can have the
            // same API for all contracts.
            false
        ];
        // Return empty bytes value to keep the same API as for the ERC792 version
        bytes memory bytesVal;

        return (addrs, uints, boolVals, bytesVal);
    }

    // -------------------------------------------------------------------------------------------
    // -------------------- main external functions that affect state ----------------------------
    // -------------------------------------------------------------------------------------------

    /// @notice Called by arbitrator to report their resolution.
    /// Can only be called after arbitrator is asked to arbitrate by both parties.
    /// @param resolutionWei The amount of wei that the caller thinks should go to party A.
    /// The remaining amount of wei staked for this agreement would go to party B.
    /// @param distributeFunds Whether to distribute funds to both parties and the arbitrator (if
    /// the arbitrator hasn't already called withdrawDisputeFee).
    function resolveAsArbitrator(
        uint agreementID,
        uint resolutionWei,
        bool distributeFunds
    )
        external
    {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        uint48 res = toMillionth(resolutionWei);

        require(
            msg.sender == agreement.arbitratorAddress,
            "resolveAsArbitrator can only be called by arbitrator."
        );
        require(
            res <= add(agreement.partyAStakeAmount, agreement.partyBStakeAmount),
            "Resolution out of range."
        );
        require(
            (
                partyRequestedArbitration(agreement, Party.A) &&
                partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration not requested by both parties."
        );

        setArbitratorResolved(agreement, true);

        emit ArbitratorResolved(uint32(agreementID), resolutionWei);

        bool distributeToArbitrator = !arbitratorReceivedDisputeFee(agreement) && distributeFunds;

        finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            res,
            distributeFunds,
            distributeToArbitrator
        );
    }

    /// @notice Request that the arbitrator get involved to settle the disagreement.
    /// Each party needs to pay the full arbitration fee when calling this. However they will be
    /// refunded the full fee if the arbitrator agrees with them.
    /// If one party calls this and the other refuses to, the party who called this function can
    /// eventually call requestDefaultJudgment.
    function requestArbitration(uint agreementID) external payable {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");
        require(agreement.arbitratorAddress != address(0), "Arbitration is disallowed.");
        require(msg.value == toWei(agreement.disputeFee), "Arbitration fee amount is incorrect.");

        Party callingParty = getCallingParty(agreement);
        require(
            RESOLUTION_NULL != partyResolution(agreement, callingParty),
            "Need to enter a resolution before requesting arbitration."
        );
        require(
            !partyRequestedArbitration(agreement, callingParty),
            "This party already requested arbitration."
        );

        bool firstArbitrationRequest =
            !partyRequestedArbitration(agreement, Party.A) &&
            !partyRequestedArbitration(agreement, Party.B);

        require(
            (
                !firstArbitrationRequest ||
                block.timestamp > agreement.nextArbitrationStepAllowedAfterTimestamp
            ),
            "Arbitration not allowed yet."
        );

        setPartyRequestedArbitration(agreement, callingParty, true);

        emit ArbitrationRequested(uint32(agreementID));

        if (firstArbitrationRequest) {
            updateArbitrationResponseDeadline(agreement);
        } else {
            // Both parties have requested arbitration. Emit this event to conform to ERC1497.
            emit Dispute(
                Arbitrator(agreement.arbitratorAddress),
                agreementID,
                agreementID,
                agreementID
            );
        }
    }

    /// @notice Allow the arbitrator to indicate they're working on the dispute by withdrawing the
    /// funds. We can't prevent dishonest arbitrator from taking funds without doing work, because
    /// they can always call 'resolveAsArbitrator' quickly. So we prevent the arbitrator from
    /// actually being paid until they either call this function or 'resolveAsArbitrator' to avoid
    /// the case where we send funds to a nonresponsive arbitrator.
    function withdrawDisputeFee(uint agreementID) external {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(
            (
                partyRequestedArbitration(agreement, Party.A) &&
                partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration not requested"
        );
        require(
            msg.sender == agreement.arbitratorAddress,
            "withdrawDisputeFee can only be called by Arbitrator."
        );
        require(
            !resolutionsAreCompatibleBothExist(
                agreement.partyAResolution,
                agreement.partyBResolution,
                Party.A
            ),
            "partyA and partyB already resolved their dispute."
        );

        distributeFundsToArbitratorHelper_Untrusted_Unguarded(agreementID, agreement);
    }

    // -------------------------------------------------------------------------------------------
    // ----------------------------- internal helper functions -----------------------------------
    // -------------------------------------------------------------------------------------------

    /// @dev This function is NOT untrusted in this contract.
    /// @return whether the given party has paid the arbitration fee in full.
    function partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
        uint, /*agreementID is unused in this version*/
        AgreementDataETH storage agreement,
        Party party) internal returns (bool) {

        // Since the arbitration fee can't change mid-agreement in simple arbitration,
        // having requested arbitration means the dispute fee is paid.
        return partyRequestedArbitration(agreement, party);
    }

    /// @return Whether the party provided is closer to winning a default judgment than the other
    /// party. For simple arbitration this means just that they'd paid the arbitration fee
    /// and the other party hasn't.
    function partyIsCloserToWinningDefaultJudgment(
        uint /*agreementID*/,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        returns (bool)
    {
        return partyRequestedArbitration(agreement, party) &&
            !partyRequestedArbitration(agreement, getOtherParty(party));
    }


    /// @notice See comments in AgreementManagerETH to understand the goal of this
    /// important function.
    /// @dev We don't use the first argument (agreementID) in this version, but it's there because
    /// we use inheritance.
    function getPartyArbitrationRefundInWei(
        uint /*agreementID*/,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (uint)
    {
        if (!partyRequestedArbitration(agreement, party)) {
            // party didn't pay an arbitration fee, so gets no refund.
            return 0;
        }

        // Now we know party paid an arbitration fee, so figure out how much of it they get back.

        if (partyDisputeFeeLiability(agreement, party)) {
            // party has liability for the dispute fee. The only question is whether they
            // pay the full amount or half.
            Party otherParty = getOtherParty(party);
            if (partyDisputeFeeLiability(agreement, otherParty)) {
                // party pays half the fee
                return toWei(agreement.disputeFee/2);
            }
            return 0; // pays the full fee
        }
        // No liability -- full refund
        return toWei(agreement.disputeFee);
    }

    /// @return whether the arbitrator has either already received or is entitled to withdraw
    /// the dispute fee
    function arbitratorGetsDisputeFee(
        uint /*agreementID*/,
        AgreementDataETH storage agreement
    )
        internal
        returns (bool)
    {
        return arbitratorResolved(agreement) || arbitratorReceivedDisputeFee(agreement);
    }
}

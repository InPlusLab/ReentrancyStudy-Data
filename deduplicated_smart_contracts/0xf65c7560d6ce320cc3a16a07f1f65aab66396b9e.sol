/**
 *Submitted for verification at Etherscan.io on 2019-11-01
*/

// File: browser/CappedMath.sol

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: [@clesaege]
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity ^0.5;


/**
 * @title CappedMath
 * @dev Math operations with caps for under and overflow.
 */
library CappedMath {
    uint constant private UINT_MAX = 2**256 - 1;

    /**
     * @dev Adds two unsigned integers, returns 2^256 - 1 on overflow.
     */
    function addCap(uint _a, uint _b) internal pure returns (uint) {
        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    /**
     * @dev Subtracts two integers, returns 0 on underflow.
     */
    function subCap(uint _a, uint _b) internal pure returns (uint) {
        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    /**
     * @dev Multiplies two unsigned integers, returns 2^256 - 1 on overflow.
     */
    function mulCap(uint _a, uint _b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring '_a' not being zero, but the
        // benefit is lost if '_b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0)
            return 0;

        uint c = _a * _b;
        return c / _a == _b ? c : UINT_MAX;
    }
}

// File: browser/IEvidence.sol

pragma solidity ^0.5;


/** @title IEvidence
 *  ERC-1497: Evidence Standard
 */
interface IEvidence {

    /** @dev To be emitted when meta-evidence is submitted.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     *  @param _evidence A link to the meta-evidence JSON.
     */
    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    /** @dev To be raised when evidence is submitted. Should point to the resource (evidences are not to be stored on chain due to gas considerations).
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _evidenceGroupID Unique identifier of the evidence group the evidence belongs to.
     *  @param _party The address of the party submiting the evidence. Note that 0x0 refers to evidence not submitted by any party.
     *  @param _evidence A URI to the evidence JSON file whose name should be its keccak256 hash followed by .json.
     */
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    /** @dev To be emitted when a dispute is created to link the correct meta-evidence to the disputeID.
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     *  @param _evidenceGroupID Unique identifier of the evidence group that is linked to this dispute.
     */
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

}

// File: browser/Arbitrator.sol

/**
 *  @title Arbitrator
 *  @author Cl¨¦ment Lesaege - <clement@lesaege.com>
 */

pragma solidity ^0.5;


/** @title Arbitrator
 *  Arbitrator abstract contract.
 *  When developing arbitrator contracts we need to:
 *  -Define the functions for dispute creation (createDispute) and appeal (appeal). Don't forget to store the arbitrated contract and the disputeID (which should be unique, may nbDisputes).
 *  -Define the functions for cost display (arbitrationCost and appealCost).
 *  -Allow giving rulings. For this a function must call arbitrable.rule(disputeID, ruling).
 */
contract Arbitrator {

    enum DisputeStatus {Waiting, Appealable, Solved}


    /** @dev To be emitted when a dispute is created.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event DisputeCreation(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev To be emitted when a dispute can be appealed.
     *  @param _disputeID ID of the dispute.
     */
    event AppealPossible(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev To be emitted when the current ruling is appealed.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event AppealDecision(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev Create a dispute. Must be called by the arbitrable contract.
     *  Must be paid at least arbitrationCost(_extraData).
     *  @param _choices Amount of choices the arbitrator can make in this dispute.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return disputeID ID of the dispute created.
     */
    function createDispute(uint _choices, bytes memory _extraData) public payable returns(uint disputeID);

    /** @dev Compute the cost of arbitration. It is recommended not to increase it often, as it can be highly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return cost Amount to be paid.
     */
    function arbitrationCost(bytes memory _extraData) public view returns(uint cost);

    /** @dev Appeal a ruling. Note that it has to be called before the arbitrator contract calls rule.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give extra info on the appeal.
     */
    function appeal(uint _disputeID, bytes memory _extraData) public payable;

    /** @dev Compute the cost of appeal. It is recommended not to increase it often, as it can be higly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return cost Amount to be paid.
     */
    function appealCost(uint _disputeID, bytes memory _extraData) public view returns(uint cost);

    /** @dev Compute the start and end of the dispute's current or next appeal period, if possible. If not known or appeal is impossible: should return (0, 0).
     *  @param _disputeID ID of the dispute.
     *  @return The start and end of the period.
     */
    function appealPeriod(uint _disputeID) public view returns(uint start, uint end);

    /** @dev Return the status of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return status The status of the dispute.
     */
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);

    /** @dev Return the current ruling of a dispute. This is useful for parties to know if they should appeal.
     *  @param _disputeID ID of the dispute.
     *  @return ruling The ruling which has been given or the one which will be given if there is no appeal.
     */
    function currentRuling(uint _disputeID) public view returns(uint ruling);

}

// File: browser/IArbitrable.sol

/**
 *  @title IArbitrable
 *  @author Enrique Piqueras - <enrique@kleros.io>
 */

pragma solidity ^0.5;


/** @title IArbitrable
 *  Arbitrable interface.
 *  When developing arbitrable contracts, we need to:
 *  -Define the action taken when a ruling is received by the contract.
 *  -Allow dispute creation. For this a function must call arbitrator.createDispute.value(_fee)(_choices,_extraData);
 */
interface IArbitrable {

    /** @dev To be raised when a ruling is given.
     *  @param _arbitrator The arbitrator giving the ruling.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling The ruling which was given.
     */
    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) external;
}

// File: browser/BinaryArbitrableProxy.sol


pragma solidity >=0.5 <0.6.0;





/**
 *  @title BinaryArbitrableProxy
 *  This contract acts as a general purpose dispute creator.
 */
contract BinaryArbitrableProxy is IArbitrable, IEvidence {

    using CappedMath for uint;

    uint constant NUMBER_OF_CHOICES = 2;
    enum Party {RefuseToArbitrate, Requester, Respondent}
    uint8 requester = uint8(Party.Requester);
    uint8 respondent = uint8(Party.Respondent);

    struct Round {
      uint[3] paidFees; // Tracks the fees paid by each side in this round.
      bool[3] hasPaid; // True when the side has fully paid its fee. False otherwise.
      uint totalAppealFeesCollected; // Sum of reimbursable appeal fees available to the parties that made contributions to the side that ultimately wins a dispute.
      mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }

    struct DisputeStruct {
        Arbitrator arbitrator;
        bytes arbitratorExtraData;
        bool isRuled;
        Party judgment;
        uint disputeIDOnArbitratorSide;
        Round[] rounds;
    }

    DisputeStruct[] public disputes;
    mapping(address => mapping(uint => uint)) public arbitratorExternalIDtoLocalID;


    /** @dev Calls createDispute function of the specified arbitrator to create a dispute.
     *  @param _arbitrator The arbitrator of prospective dispute.
     *  @param _arbitratorExtraData Extra data for the arbitrator of prospective dispute.
     *  @param _metaevidenceURI Link to metaevidence of prospective dispute.
     */
    function createDispute(Arbitrator _arbitrator, bytes calldata _arbitratorExtraData, string calldata _metaevidenceURI) external payable {
        uint arbitrationCost = _arbitrator.arbitrationCost(_arbitratorExtraData);
        require(msg.value >= arbitrationCost, "Insufficient message value.");
        uint disputeID = _arbitrator.createDispute.value(arbitrationCost)(NUMBER_OF_CHOICES, _arbitratorExtraData);

        uint localDisputeID = disputes.length++;
        DisputeStruct storage dispute = disputes[localDisputeID];
        dispute.arbitrator = _arbitrator;
        dispute.arbitratorExtraData = _arbitratorExtraData;
        dispute.disputeIDOnArbitratorSide = disputeID;
        dispute.rounds.length++;

        arbitratorExternalIDtoLocalID[address(_arbitrator)][disputeID] = localDisputeID;

        emit MetaEvidence(localDisputeID, _metaevidenceURI);
        emit Dispute(_arbitrator, disputeID, localDisputeID, localDisputeID);

        msg.sender.send(msg.value-arbitrationCost);
    }

    /** @dev Manages contributions and calls appeal function of the specified arbitrator to appeal a dispute. This function lets appeals be crowdfunded.
     *  @param _localDisputeID Index of the dispute in disputes array.
     *  @param _party The side to which the caller wants to contribute.
     */
    function appeal(uint _localDisputeID, Party _party) external payable {
        require(_party != Party.RefuseToArbitrate, "You can't fund an appeal in favor of refusing to arbitrate.");
        uint8 side = uint8(_party);
        DisputeStruct storage dispute = disputes[_localDisputeID];

        (uint appealPeriodStart, uint appealPeriodEnd) = dispute.arbitrator.appealPeriod(dispute.disputeIDOnArbitratorSide);
        require(now >= appealPeriodStart && now < appealPeriodEnd, "Funding must be made within the appeal period.");

        Round storage round = dispute.rounds[dispute.rounds.length-1];

        require(!round.hasPaid[side], "Appeal fee has already been paid");
        round.hasPaid[side] = true; // Temporarily assume the contribution covers the missing amount to block re-entrancy.

        uint appealCost = dispute.arbitrator.appealCost(dispute.disputeIDOnArbitratorSide, dispute.arbitratorExtraData);

        uint contribution;

        if(round.paidFees[side] + msg.value >= appealCost){
          contribution = appealCost - round.paidFees[side];
        }
        else{
            contribution = msg.value;
            round.hasPaid[side] = false; // Rollback the temporary assumption above.
        }
        msg.sender.send(msg.value - contribution);
        round.contributions[msg.sender][side] += contribution;
        round.paidFees[side] += contribution;
        round.totalAppealFeesCollected += contribution;

        if(round.hasPaid[requester] && round.hasPaid[respondent]){
            dispute.arbitrator.appeal.value(appealCost)(dispute.disputeIDOnArbitratorSide, dispute.arbitratorExtraData);
            dispute.rounds.length++;
            round.totalAppealFeesCollected = round.totalAppealFeesCollected.subCap(appealCost);
        }
    }

    /** @dev Lets to withdraw any reimbursable fees or rewards after the dispute gets solved.
     *  @param _localDisputeID Index of the dispute in disputes array.
     *  @param _contributor The side to which the caller wants to contribute.
     *  @param _roundNumber The number of the round caller wants to withdraw from.
     */
    function withdrawFeesAndRewards(uint _localDisputeID, address payable _contributor, uint _roundNumber) external {
        DisputeStruct storage dispute = disputes[_localDisputeID];
        Round storage round = dispute.rounds[_roundNumber];
        uint8 judgment = uint8(dispute.judgment);

        require(dispute.isRuled, "The dispute should be solved");
        uint reward;
        if (!round.hasPaid[requester] || !round.hasPaid[respondent]) {
            // Allow to reimburse if funding was unsuccessful.
            reward = round.contributions[_contributor][requester] + round.contributions[_contributor][respondent];
            round.contributions[_contributor][requester] = 0;
            round.contributions[_contributor][respondent] = 0;
        } else if (judgment == 0) {
            // Reimburse unspent fees proportionally if there is no winner and loser.
            uint rewardParty1 = round.paidFees[requester] > 0
                ? (round.contributions[_contributor][requester] * round.totalAppealFeesCollected) / (round.paidFees[requester] + round.paidFees[respondent])
                : 0;
            uint rewardParty2 = round.paidFees[respondent] > 0
                ? (round.contributions[_contributor][respondent] * round.totalAppealFeesCollected) / (round.paidFees[requester] + round.paidFees[respondent])
                : 0;

            reward = rewardParty1 + rewardParty2;
            round.contributions[_contributor][requester] = 0;
            round.contributions[_contributor][respondent] = 0;
        } else {
              // Reward the winner.
            reward = round.paidFees[judgment] > 0
                ? (round.contributions[_contributor][judgment] * round.totalAppealFeesCollected) / round.paidFees[judgment]
                : 0;
            round.contributions[_contributor][judgment] = 0;
          }

        _contributor.send(reward); // It is the user responsibility to accept ETH.
    }

    /** @dev To be called by the arbitrator of the dispute, to declare winning side.
     *  @param _externalDisputeID ID of the dispute in arbitrator contract.
     *  @param _ruling The side to which the caller wants to contribute.
     */
    function rule(uint _externalDisputeID, uint _ruling) external {
        uint _localDisputeID = arbitratorExternalIDtoLocalID[msg.sender][_externalDisputeID];
        DisputeStruct storage dispute = disputes[_localDisputeID];
        require(msg.sender == address(dispute.arbitrator), "Unauthorized call.");
        require(_ruling <= NUMBER_OF_CHOICES, "Invalid ruling.");
        require(dispute.isRuled == false, "Is ruled already.");

        dispute.isRuled = true;
        dispute.judgment = Party(_ruling);

        Round storage round = dispute.rounds[dispute.rounds.length-1];

        uint resultRuling = _ruling;
        if (round.hasPaid[requester] == true) // If one side paid its fees, the ruling is in its favor. Note that if the other side had also paid, an appeal would have been created.
            resultRuling = 1;
        else if (round.hasPaid[respondent] == true)
            resultRuling = 2;

        emit Ruling(Arbitrator(msg.sender), dispute.disputeIDOnArbitratorSide, resultRuling);
    }

    /** @dev Allows to submit evidence for a given dispute.
     *  @param _localDisputeID Index of the dispute in disputes array.
     *  @param _evidenceURI Link to evidence.
     */
    function submitEvidence(uint _localDisputeID, string memory _evidenceURI) public {
        DisputeStruct storage dispute = disputes[_localDisputeID];

        require(dispute.isRuled == false, "Cannot submit evidence to a resolved dispute.");

        emit Evidence(dispute.arbitrator, _localDisputeID, msg.sender, _evidenceURI);
    }

    function crowdfundingStatus(uint _localDisputeID, address _participant) external view returns (uint[3] memory paidFess, bool[3] memory hasPaid, uint totalAppealFeesCollected, uint[3] memory contributions){
        DisputeStruct storage dispute = disputes[_localDisputeID];

        Round memory lastRound = dispute.rounds[dispute.rounds.length - 1];

        return (lastRound.paidFees, lastRound.hasPaid, lastRound.totalAppealFeesCollected, dispute.rounds[dispute.rounds.length - 1].contributions[_participant]);

    }
}
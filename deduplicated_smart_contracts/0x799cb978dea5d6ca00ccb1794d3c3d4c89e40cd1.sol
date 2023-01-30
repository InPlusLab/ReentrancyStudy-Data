pragma solidity >=0.5 <0.6.0;

import "./IArbitrable.sol";
import "./IEvidence.sol";
import "./Arbitrator.sol";

contract BinaryArbitrableProxy is IArbitrable, IEvidence {

    uint constant NUMBER_OF_CHOICES = 2;

    struct DisputeStruct {
        Arbitrator arbitrator;
        bytes arbitratorExtraData;
        bool isRuled;
        uint disputeIDOnArbitratorSide;
    }


    DisputeStruct[] public disputes;
    mapping(uint => DisputeStruct) public disputeIDOnArbitratorSidetoDisputeStruct;

    function createDispute(Arbitrator _arbitrator, bytes calldata _arbitratorExtraData, string calldata _metaevidenceURI) external payable {
        uint arbitrationCost = _arbitrator.arbitrationCost(_arbitratorExtraData);
        uint _disputeIDOnArbitratorSide = _arbitrator.createDispute.value(arbitrationCost)(NUMBER_OF_CHOICES, _arbitratorExtraData);

        disputes.push(DisputeStruct({
            arbitrator: _arbitrator,
            arbitratorExtraData: _arbitratorExtraData,
            isRuled: false,
            disputeIDOnArbitratorSide: _disputeIDOnArbitratorSide
        }));

        disputeIDOnArbitratorSidetoDisputeStruct[_disputeIDOnArbitratorSide] = disputes[disputes.length-1];

        emit MetaEvidence(disputes.length-1, _metaevidenceURI);
        emit Dispute(_arbitrator, _disputeIDOnArbitratorSide, disputes.length-1, disputes.length-1);

    }

    function appeal(uint _localDisputeID) external payable {
        DisputeStruct storage dispute = disputes[_localDisputeID];
        dispute.arbitrator.appeal.value(msg.value)(dispute.disputeIDOnArbitratorSide, dispute.arbitratorExtraData);
    }

    function rule(uint _localDisputeID, uint _ruling) external {
        DisputeStruct storage dispute = disputes[_localDisputeID];
        require(msg.sender == address(dispute.arbitrator), "Unauthorized call.");
        require(_ruling <= NUMBER_OF_CHOICES, "Invalid ruling.");
        require(dispute.isRuled == false, "Is ruled already.");

        emit Ruling(Arbitrator(msg.sender), dispute.disputeIDOnArbitratorSide, _ruling);
        dispute.isRuled = true;
    }

    function submitEvidence(uint _localDisputeID, string memory _evidenceURI) public {
        DisputeStruct storage dispute = disputes[_localDisputeID];

        require(dispute.isRuled == false, "Is ruled already.");

        emit Evidence(dispute.arbitrator, _localDisputeID, msg.sender, _evidenceURI);
    }
}

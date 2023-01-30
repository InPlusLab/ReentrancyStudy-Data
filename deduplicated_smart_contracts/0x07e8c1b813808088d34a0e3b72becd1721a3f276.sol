/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity ^0.5.11;

interface IArbitrableTCR {
    
    enum Party {
        None,      // Party per default when there is no challenger or requester. Also used for unconclusive ruling.
        Requester, // Party that made the request to change an address status.
        Challenger // Party that challenges the request to change an address status.
    }
    
    function governor() external view returns(address);
    function arbitrator() external view returns(address);
    function arbitratorExtraData() external view returns(bytes memory);
    function requesterBaseDeposit() external view returns(uint);
    function challengerBaseDeposit() external view returns(uint);
    function challengePeriodDuration() external view returns(uint);
    function metaEvidenceUpdates() external view returns(uint);
    function winnerStakeMultiplier() external view returns(uint);
    function loserStakeMultiplier() external view returns(uint);
    function sharedStakeMultiplier() external view returns(uint);
    function MULTIPLIER_DIVISOR() external view returns(uint);
    function countByStatus() 
        external 
        view 
        returns(
            uint absent,
            uint registered,
            uint registrationRequest,
            uint clearingRequest,
            uint challengedRegistrationRequest,
            uint challengedClearingRequest
        );
}

interface IArbitrableAddressTCR {
    enum AddressStatus {
        Absent, // The address is not in the registry.
        Registered, // The address is in the registry.
        RegistrationRequested, // The address has a request to be added to the registry.
        ClearingRequested // The address has a request to be removed from the registry.
    }
    
    function addressCount() external view returns(uint); 
    function addressList(uint index) external view returns(address);
    function getAddressInfo(address _address)
        external
        view
        returns (
            AddressStatus status,
            uint numberOfRequests
        );
    
    function getRequestInfo(address _address, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address[3] memory parties,
            uint numberOfRounds,
            IArbitrableTCR.Party ruling,
            address arbitrator,
            bytes memory arbitratorExtraData
        );
        
    function getRoundInfo(address _address, uint _request, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] memory paidFees,
            bool[3] memory hasPaid,
            uint feeRewards
        );
}

interface IArbitrableTokenTCR {
    enum TokenStatus {
        Absent, // The address is not in the registry.
        Registered, // The address is in the registry.
        RegistrationRequested, // The address has a request to be added to the registry.
        ClearingRequested // The address has a request to be removed from the registry.
    }
    
    function tokenCount() external view returns(uint); 
    function tokensList(uint index) external view returns(bytes32);
    function getTokenInfo(bytes32 _tokenID)
        external
        view
        returns (
            string memory name,
            string memory ticker,
            address addr,
            string memory symbolMultihash,
            TokenStatus status,
            uint numberOfRequests
        );
        
    function getRequestInfo(bytes32 _tokenID, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address[3] memory parties,
            uint numberOfRounds,
            IArbitrableTCR.Party ruling,
            address arbitrator,
            bytes memory arbitratorExtraData
        );
        
    function getRoundInfo(bytes32 _tokenID, uint _request, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] memory paidFees,
            bool[3] memory hasPaid,
            uint feeRewards
        );
}

interface IArbitrator {
    
    enum DisputeStatus {Waiting, Appealable, Solved}
    
    function createDispute(uint _choices, bytes calldata _extraData) external payable returns(uint disputeID);
    function arbitrationCost(bytes calldata _extraData) external view returns(uint cost);
    function appeal(uint _disputeID, bytes calldata _extraData) external payable;
    function appealCost(uint _disputeID, bytes calldata _extraData) external view returns(uint cost);
    function appealPeriod(uint _disputeID) external view returns(uint start, uint end);
    function disputeStatus(uint _disputeID) external view returns(DisputeStatus status);
    function currentRuling(uint _disputeID) external view returns(uint ruling);
}

pragma experimental ABIEncoderV2;


contract ArbitrableTCRView {
    
    struct CountByStatus {
        uint absent;
        uint registered;
        uint registrationRequest;
        uint clearingRequest;
        uint challengedRegistrationRequest;
        uint challengedClearingRequest;
    }

    struct ArbitrableTCRData {
        address governor;
        address arbitrator;
        bytes arbitratorExtraData;
        uint requesterBaseDeposit;
        uint challengerBaseDeposit;
        uint challengePeriodDuration;
        uint metaEvidenceUpdates;
        uint winnerStakeMultiplier;
        uint loserStakeMultiplier;
        uint sharedStakeMultiplier;
        uint MULTIPLIER_DIVISOR;
        CountByStatus countByStatus;
        uint arbitrationCost;
    }

    /** @dev Fetch arbitrable TCR data in a single call.
     *  @param _address The address of the Generalized TCR to query.
     *  @return The latest data on an arbitrable TCR contract.
     */
    function fetchArbitrable(address _address) external view returns (ArbitrableTCRData memory result) {
        IArbitrableTCR tcr = IArbitrableTCR(_address);
        result.governor = tcr.governor();
        result.arbitrator = tcr.arbitrator();
        result.arbitratorExtraData = tcr.arbitratorExtraData();
        result.requesterBaseDeposit = tcr.requesterBaseDeposit();
        result.challengerBaseDeposit = tcr.challengerBaseDeposit();
        result.challengePeriodDuration = tcr.challengePeriodDuration();
        result.metaEvidenceUpdates = tcr.metaEvidenceUpdates();
        result.winnerStakeMultiplier = tcr.winnerStakeMultiplier();
        result.loserStakeMultiplier = tcr.loserStakeMultiplier();
        result.sharedStakeMultiplier = tcr.sharedStakeMultiplier();
        result.MULTIPLIER_DIVISOR = tcr.MULTIPLIER_DIVISOR();
        
        {
            (
                uint absent,
                uint registered,
                uint registrationRequest,
                uint clearingRequest,
                uint challengedRegistrationRequest,
                uint challengedClearingRequest
            ) = tcr.countByStatus();
            result.countByStatus = CountByStatus({
                absent: absent,
                registered: registered,
                registrationRequest: registrationRequest,
                clearingRequest: clearingRequest,
                challengedRegistrationRequest: challengedRegistrationRequest,
                challengedClearingRequest: challengedClearingRequest
            });
        }
        
        IArbitrator arbitrator = IArbitrator(result.arbitrator);
        result.arbitrationCost = arbitrator.arbitrationCost(result.arbitratorExtraData);
    }
    
    struct AppealableToken {
        uint disputeID;
        address arbitrator;
        bytes32 tokenID;
        bool inAppealPeriod;
    }
    
    struct AppealableAddress {
        uint disputeID;
        address arbitrator;
        address addr;
        bool inAppealPeriod;
    }
    
    function fetchAppealableAddresses(address _addressTCR, uint _cursor, uint _count) external view returns (AppealableAddress[] memory results) {
        IArbitrableAddressTCR tcr = IArbitrableAddressTCR(_addressTCR);
        results = new AppealableAddress[](_count);
        
        for (uint i = _cursor; i < tcr.addressCount() && _count - i > 0; i++) {
            address itemAddr = tcr.addressList(i);
            (
                IArbitrableAddressTCR.AddressStatus status,
                uint numberOfRequests
            ) = tcr.getAddressInfo(itemAddr);
            
            if (status == IArbitrableAddressTCR.AddressStatus.Absent || status == IArbitrableAddressTCR.AddressStatus.Registered) continue;
            
            // Using arrays to get around stack limit.
            bool[] memory disputedResolved = new bool[](2);
            uint[] memory disputeIDNumberOfRounds = new uint[](2);
            address arbitrator;
            (
                disputedResolved[0],
                disputeIDNumberOfRounds[0],
                ,
                disputedResolved[1],
                ,
                disputeIDNumberOfRounds[1],
                ,
                arbitrator,
            ) = tcr.getRequestInfo(itemAddr, numberOfRequests - 1);
            
            if (!disputedResolved[0] || disputedResolved[1]) continue;
            
            IArbitrator arbitratorContract = IArbitrator(arbitrator);
            uint[] memory appealPeriod = new uint[](2);
            (appealPeriod[0], appealPeriod[1]) = arbitratorContract.appealPeriod(disputeIDNumberOfRounds[0]);
            if (appealPeriod[0] > 0 && appealPeriod[1] > 0) {
                results[i] = AppealableAddress({
                    disputeID: disputeIDNumberOfRounds[0],
                    arbitrator: arbitrator,
                    addr: itemAddr,
                    inAppealPeriod: now < appealPeriod[1]
                });
                
                // If the arbitrator gave a decisive ruling (i.e. did not rule for Party.None)
                // we must check if the loser fully funded and the dispute is in the second half
                // of the appeal period. If the dispute is in the second half, and the loser is not 
                // funded the appeal period is over.
                IArbitrableTCR.Party currentRuling = IArbitrableTCR.Party(arbitratorContract.currentRuling(disputeIDNumberOfRounds[0]));
                if (
                    currentRuling != IArbitrableTCR.Party.None && 
                    now > (appealPeriod[1] - appealPeriod[0]) / 2 + appealPeriod[0]
                ) {
                    IArbitrableTCR.Party loser = currentRuling == IArbitrableTCR.Party.Requester 
                        ? IArbitrableTCR.Party.Challenger
                        : IArbitrableTCR.Party.Requester;
                        
                    (
                        ,
                        ,
                        bool[3] memory hasPaid,
                    ) = tcr.getRoundInfo(itemAddr, numberOfRequests - 1, disputeIDNumberOfRounds[1] - 1);
                    
                    if(!hasPaid[uint(loser)]) results[i].inAppealPeriod = false;
                }
            }
        }
    }
    
    function fetchAppealableToken(address _addressTCR, uint _cursor, uint _count) external view returns (AppealableToken[] memory results) {
        IArbitrableTokenTCR tcr = IArbitrableTokenTCR(_addressTCR);
        results = new AppealableToken[](_count);
        
        for (uint i = _cursor; i < tcr.tokenCount() && _count - i > 0; i++) {
            bytes32 tokenID = tcr.tokensList(i);
            (
                ,
                ,
                ,
                ,
                IArbitrableTokenTCR.TokenStatus status,
                uint numberOfRequests
            ) = tcr.getTokenInfo(tokenID);
            
            if (status == IArbitrableTokenTCR.TokenStatus.Absent || status == IArbitrableTokenTCR.TokenStatus.Registered) continue;
            
            // Using arrays to get around stack limit.
            bool[] memory disputedResolved = new bool[](2);
            uint[] memory disputeIDNumberOfRounds = new uint[](2);
            address arbitrator;
            (
                disputedResolved[0],
                disputeIDNumberOfRounds[0],
                ,
                disputedResolved[1],
                ,
                disputeIDNumberOfRounds[1],
                ,
                arbitrator,
            ) = tcr.getRequestInfo(tokenID, numberOfRequests - 1);
            
            if (!disputedResolved[0] || disputedResolved[1]) continue;
            
            IArbitrator arbitratorContract = IArbitrator(arbitrator);
            uint[] memory appealPeriod = new uint[](2);
            (appealPeriod[0], appealPeriod[1]) = arbitratorContract.appealPeriod(disputeIDNumberOfRounds[0]);
            if (appealPeriod[0] > 0 && appealPeriod[1] > 0) {
                results[i] = AppealableToken({
                    disputeID: disputeIDNumberOfRounds[0],
                    arbitrator: arbitrator,
                    tokenID: tokenID,
                    inAppealPeriod: now < appealPeriod[1]
                });
                
                // If the arbitrator gave a decisive ruling (i.e. did not rule for Party.None)
                // we must check if the loser fully funded and the dispute is in the second half
                // of the appeal period. If the dispute is in the second half, and the loser is not 
                // funded the appeal period is over.
                IArbitrableTCR.Party currentRuling = IArbitrableTCR.Party(arbitratorContract.currentRuling(disputeIDNumberOfRounds[0]));
                if (
                    currentRuling != IArbitrableTCR.Party.None && 
                    now > (appealPeriod[1] - appealPeriod[0]) / 2 + appealPeriod[0]
                ) {
                    IArbitrableTCR.Party loser = currentRuling == IArbitrableTCR.Party.Requester 
                        ? IArbitrableTCR.Party.Challenger
                        : IArbitrableTCR.Party.Requester;
                        
                    (
                        ,
                        ,
                        bool[3] memory hasPaid,
                    ) = tcr.getRoundInfo(tokenID, numberOfRequests - 1, disputeIDNumberOfRounds[1] - 1);
                    
                    if(!hasPaid[uint(loser)]) results[i].inAppealPeriod = false;
                }
            }
        }
    }
   
}
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "./ReentrancyGuard.sol";
import "./IGovERC721.sol";
import "./SafeMath.sol";

contract MintableGovernance is ReentrancyGuard {
    using SafeMath for uint256;
        /// @notice The name of this contract
    string public constant name = "Mintable Governor Alpha";
    
    address public Governor;
    
    IGovERC721 public GovNFT;


    /// @notice The number of votes required in order for a voter to become a proposer
    function proposalThreshold() public pure returns (uint256) { return 10_000; } // 0.1% of voting power

    /// @notice The delay before voting on a proposal may take place, once proposed
    function votingDelay() public pure returns (uint256) { return 1 days; }  // 1 day

    /// @notice The duration of voting on a proposal, in blocks
    function votingPeriod() public pure returns (uint256) { return 14 days; } // ~14 days in blocks (assuming 15s blocks)

    /// @notice The total number of proposals
    uint256 public proposalCount;
    


    struct Proposal {
        /// @notice Unique id for looking up a proposal
        uint256 id;

        /// @notice Creator of the proposal
        address proposer;

        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;

        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;

        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;

        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;

        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;

        /// @notice Flag marking whether the proposal has been executed
        bool executed;

        /// @notice Receipts of ballots for the entire set of voters
        mapping (address => Receipt) receipts;
        
        // @notice URL of the proposal
        string proposal_url;
        
        
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        /// @notice Whether or not a vote has been cast
        bool hasVoted;

        /// @notice Whether or not the voter supports the proposal
        bool support;

        /// @notice The number of votes the voter had, which were cast
        uint256 votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Executed
    }

   /// @notice The official record of all proposals ever proposed
    mapping (uint256 => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping (address => uint256) public latestProposalIds;

    // Mapping of wash traders to prevent them from stealing votes
    mapping(address => bool) private _washTraders;
    
    // Mapping of community approved contracts 
    mapping(address => bool) private _approvedContracts;

    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(uint256 id, address proposer, uint256 startBlock, uint256 endBlock, string description);

    /// @notice An event emitted when a vote has been cast on a proposal
    event VoteCast(address voter, uint256 proposalId, bool support, uint256 votes);

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint256 id);


    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint256 id);
    
   modifier isGovernor() {
       require(msg.sender == Governor, "GovernorAlpha::IsGovernor: Not the governor");
       _;
   }
    
   constructor(address _govNFT) public {
        Governor = msg.sender;
        GovNFT = IGovERC721(_govNFT);
    }
    
    function changeGovNFT(address _contract) isGovernor external {
        GovNFT = IGovERC721(_contract);
    }

    function propose(string memory _url, string memory description) nonReentrant public returns (uint256) {
        require(GovNFT.delegateVotingPower(msg.sender) >= proposalThreshold(), "GovernorAlpha::propose: proposer votes below proposal threshold");
        require(bytes(_url).length > 0 && bytes(description).length > 0, "GovernorAlpha::propose: URL and description are required");

        uint256 latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "GovernorAlpha::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "GovernorAlpha::propose: one live proposal per proposer, found an already pending proposal");
        }
        uint256 startBlock = block.timestamp.add(votingDelay());
        uint256 endBlock = startBlock.add(votingPeriod());
        proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            startBlock: startBlock,
            endBlock: endBlock,
            proposal_url: _url,
            forVotes: 0,
            againstVotes: 0,
            canceled: false,
            executed: false
        });

        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, startBlock, endBlock, description);
        return newProposal.id;
    }

    /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    function quorumVotes() public view returns (uint256) { return (GovNFT.totalVotingPower().mul(15)).div(100); } // 15% of voting power


    function execute(uint256 proposalId) isGovernor() public  {
        require(state(proposalId) == ProposalState.Succeeded, "GovernorAlpha::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) public {
        ProposalState state = state(proposalId);
        require(state != ProposalState.Executed, "GovernorAlpha::cancel: cannot cancel executed proposal");
        require(state != ProposalState.Defeated, "GovernorAlpha::cancel: cannot cancel defeated proposal");
        require(state != ProposalState.Succeeded, "GovernorAlpha::cancel: cannot cancel Succeeded proposal");
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, "GovernorAlpha::cancel: Only the proposer can cancel the vote");
        proposal.canceled = true;
        emit ProposalCanceled(proposalId);
    }

  

    function getReceipt(uint256 proposalId, address voter) public view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "GovernorAlpha::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.timestamp <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.timestamp <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotes()) {
            return ProposalState.Defeated;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (proposal.forVotes > proposal.againstVotes && proposal.forVotes > quorumVotes()) {
            return ProposalState.Succeeded;
        }
    }

    function castVote(uint256 proposalId, bool support) public {
        return _castVote(msg.sender, proposalId, support);
    }


    function _castVote(address voter, uint256 proposalId, bool support) nonReentrant internal {
        require(state(proposalId) == ProposalState.Active, "GovernorAlpha::_castVote: voting is closed");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "GovernorAlpha::_castVote: voter already voted");
        uint256 votes = GovNFT.delegateVotingPower(voter);
        if (support) {
            proposal.forVotes = proposal.forVotes.add(votes);
        } else {
            proposal.againstVotes = proposal.againstVotes.add(votes);
        }
        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;
        GovNFT._lockNFT(voter, proposalId);
        emit VoteCast(voter, proposalId, support, votes);
    }

    function getWashTrader(address _account) external view returns (bool){
        return _washTraders[_account];
    }
    function getApprovedContracts(address _contract) external view returns (bool){
         return _approvedContracts[_contract];
    }
    function addWashTrader(address _account, bool _value) external isGovernor returns (bool){
        _washTraders[_account] = _value;
        return _value;
    }

    function addApprovedContracts(address _NFT, bool _value) external isGovernor returns (bool){
         _approvedContracts[_NFT] = _value;
        return _value;
    }


}
    
    

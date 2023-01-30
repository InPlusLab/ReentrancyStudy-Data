/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

// SPDX-License-Identifier: MIT


/**
 * KP2R.NETWORK
 * A standard implementation of kp3rv1 protocol
 * Optimized Dapp
 * Scalability
 * Clean & tested code
 */

/**
 * This governance contract will govern over the ecosystem. 
 * It has no mint() function. So it can't mint anything.
 * It process all proposals such a democratic way.
 */
 


pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
 function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
  function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IKeep2r {
    function addVotes(address voter, uint amount) external;
    function removeVotes(address voter, uint amount) external;
    function addKPRCredit(address job, uint amount) external;
    function approveLiquidity(address liquidity) external;
    function revokeLiquidity(address liquidity) external;
    function addJob(address job) external;
    function removeJob(address job) external;
    function setKeep2rHelper(address _kprh) external;
    function setGovernance(address _governance) external;
    function acceptGovernance() external;
    function dispute(address keeper) external;
    function slash(address bonded, address keeper, uint amount) external;
    function revoke(address keeper) external;
    function resolve(address keeper) external;
    function getPriorVotes(address account, uint blockNumber) external view returns (uint);
    function totalBonded() external view returns (uint);
}

contract Governance {
    using SafeMath for uint;
    /// @notice The name of this contract
    string public constant name = "Governance";

    /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    uint public _quorumVotes = 5000; // % of total supply required

    /// @notice The number of votes required in order for a voter to become a proposer
    uint public _proposalThreshold = 5000;

    uint public constant BASE = 10000;

    function setQuorum(uint quorum_) external {
        require(msg.sender == address(this), "Governance::setQuorum: timelock only");
        require(quorum_ <= BASE, "Governance::setQuorum: quorum_ > BASE");
        _quorumVotes = quorum_;
    }

    function quorumVotes() public view returns (uint) {
        return KPR.totalBonded().mul(_quorumVotes).div(BASE);
    }

    function proposalThreshold() public view returns (uint) {
        return KPR.totalBonded().mul(_proposalThreshold).div(BASE);
    }

    function setThreshold(uint threshold_) external {
        require(msg.sender == address(this), "Governance::setQuorum: timelock only");
        require(threshold_ <= BASE, "Governance::setThreshold: threshold_ > BASE");
        _proposalThreshold = threshold_;
    }

    /// @notice The maximum number of actions that can be included in a proposal
    function proposalMaxOperations() public pure returns (uint) { return 10; } // 10 actions

    /// @notice The delay before voting on a proposal may take place, once proposed
    function votingDelay() public pure returns (uint) { return 1; } // 1 block

    /// @notice The duration of voting on a proposal, in blocks
    function votingPeriod() public pure returns (uint) { return 40_320; } // ~7 days in blocks (assuming 15s blocks)

    /// @notice The address of the governance token
    IKeep2r immutable public KPR;

    /// @notice The total number of proposals
    uint public proposalCount;

    struct Proposal {
        uint id;
        address proposer;
        uint eta;
        address[] targets;
        uint[] values;
        string[] signatures;
        bytes[] calldatas;
        uint startBlock;
        uint endBlock;
        uint forVotes;
        uint againstVotes;
        bool canceled;
        bool executed;
        mapping (address => Receipt) receipts;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        bool hasVoted;
        bool support;
        uint votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /// @notice The official record of all proposals ever proposed
    mapping (uint => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping (address => uint) public latestProposalIds;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    
    
    bytes32 public immutable DOMAINSEPARATOR;

    /// @notice The EIP-712 typehash for the ballot struct used by the contract
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,bool support)");

    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    /// @notice An event emitted when a vote has been cast on a proposal
    event VoteCast(address voter, uint proposalId, bool support, uint votes);

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint id);

    /// @notice An event emitted when a proposal has been queued in the Timelock
    event ProposalQueued(uint id, uint eta);

    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint id);

    function proposeJob(address job) public {
        require(msg.sender == address(KPR), "Governance::proposeJob: only VOTER can propose new jobs");
        address[] memory targets;
        targets[0] = address(KPR);

        string[] memory signatures;
        signatures[0] = "addJob(address)";

        bytes[] memory calldatas;
        calldatas[0] = abi.encode(job);

        uint[] memory values;
        values[0] = 0;

        _propose(targets, values, signatures, calldatas, string(abi.encodePacked("Governance::proposeJob(): ", job)));
    }

    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) public returns (uint) {
        require(KPR.getPriorVotes(msg.sender, block.number.sub(1)) >= proposalThreshold(), "Governance::propose: proposer votes below proposal threshold");
        require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "Governance::propose: proposal function information arity mismatch");
        require(targets.length != 0, "Governance::propose: must provide actions");
        require(targets.length <= proposalMaxOperations(), "Governance::propose: too many actions");

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "Governance::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "Governance::propose: one live proposal per proposer, found an already pending proposal");
        }

        return _propose(targets, values, signatures, calldatas, description);
    }

    function _propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) internal returns (uint) {
        uint startBlock = block.number.add(votingDelay());
        uint endBlock = startBlock.add(votingPeriod());

        proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            canceled: false,
            executed: false
        });

        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
        return newProposal.id;
    }

    function queue(uint proposalId) public {
        require(state(proposalId) == ProposalState.Succeeded, "Governance::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = block.timestamp.add(delay);
        for (uint i = 0; i < proposal.targets.length; i++) {
            _queueOrRevert(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    function _queueOrRevert(address target, uint value, string memory signature, bytes memory data, uint eta) internal {
        require(!queuedTransactions[keccak256(abi.encode(target, value, signature, data, eta))], "Governance::_queueOrRevert: proposal action already queued at eta");
        _queueTransaction(target, value, signature, data, eta);
    }

    function execute(uint proposalId) public payable {
        require(guardian == address(0x0) || msg.sender == guardian, "Governance:execute: !guardian");
        require(state(proposalId) == ProposalState.Queued, "Governance::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            _executeTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint proposalId) public {
        ProposalState state = state(proposalId);
        require(state != ProposalState.Executed, "Governance::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];
        require(proposal.proposer != address(KPR) && 
                KPR.getPriorVotes(proposal.proposer, block.number.sub(1)) < proposalThreshold(), "Governance::cancel: proposer above threshold");

        proposal.canceled = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            _cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }

        emit ProposalCanceled(proposalId);
    }

    function getActions(uint proposalId) public view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    function getReceipt(uint proposalId, address voter) public view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "Governance::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes.add(proposal.againstVotes) < quorumVotes()) {
            return ProposalState.Defeated;
        } else if (proposal.forVotes <= proposal.againstVotes) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= proposal.eta.add(GRACE_PERIOD)) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    function castVote(uint proposalId, bool support) public {
        _castVote(msg.sender, proposalId, support);
    }

    function castVoteBySig(uint proposalId, bool support, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAINSEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Governance::castVoteBySig: invalid signature");
        _castVote(signatory, proposalId, support);
    }

    function _castVote(address voter, uint proposalId, bool support) internal {
        require(state(proposalId) == ProposalState.Active, "Governance::_castVote: voting is closed");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "Governance::_castVote: voter already voted");
        uint votes = KPR.getPriorVotes(voter, proposal.startBlock);

        if (support) {
            proposal.forVotes = proposal.forVotes.add(votes);
        } else {
            proposal.againstVotes = proposal.againstVotes.add(votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        emit VoteCast(voter, proposalId, support, votes);
    }

    function getChainId() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    event NewDelay(uint indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 1 days;
    uint public constant MAXIMUM_DELAY = 30 days;

    uint public delay = MINIMUM_DELAY;
    
    address public guardian;
    address public pendingGuardian;
    
    function setGuardian(address _guardian) external {
        require(msg.sender == guardian, "Keep2rGovernance::setGuardian: !guardian");
        pendingGuardian = _guardian;
    }
    
    function acceptGuardianship() external {
        require(msg.sender == pendingGuardian, "Keep2rGovernance::setGuardian: !pendingGuardian");
        guardian = pendingGuardian;
    }
    
    function addVotes(address voter, uint amount) external {
        require(msg.sender == guardian, "Keep2rGovernance::addVotes: !guardian");
        KPR.addVotes(voter, amount);
    }
    function removeVotes(address voter, uint amount) external {
        require(msg.sender == guardian, "Keep2rGovernance::removeVotes: !guardian");
        KPR.removeVotes(voter, amount);
    }
    function addKPRCredit(address job, uint amount) external {
        require(msg.sender == guardian, "Keep2rGovernance::addKPRCredit: !guardian");
        KPR.addKPRCredit(job, amount);
    }
    function approveLiquidity(address liquidity) external {
        require(msg.sender == guardian, "Keep2rGovernance::approveLiquidity: !guardian");
        KPR.approveLiquidity(liquidity);
    }
    function revokeLiquidity(address liquidity) external {
        require(msg.sender == guardian, "Keep2rGovernance::revokeLiquidity: !guardian");
        KPR.revokeLiquidity(liquidity);
    }
    function addJob(address job) external {
        require(msg.sender == guardian, "Keep2rGovernance::addJob: !guardian");
        KPR.addJob(job);
    }
    function removeJob(address job) external {
        require(msg.sender == guardian, "Keep2rGovernance::removeJob: !guardian");
        KPR.removeJob(job);
    }
    function setKeep2rHelper(address kprh) external {
        require(msg.sender == guardian, "Keep2rGovernance::setKeep2rHelper: !guardian");
        KPR.setKeep2rHelper(kprh);
    }
    function setGovernance(address _governance) external {
        require(msg.sender == guardian, "Keep2rGovernance::setGovernance: !guardian");
        KPR.setGovernance(_governance);
    }
    function acceptGovernance() external {
        require(msg.sender == guardian, "Keep2rGovernance::acceptGovernance: !guardian");
        KPR.acceptGovernance();
    }
    function dispute(address keeper) external {
        require(msg.sender == guardian, "Keep2rGovernance::dispute: !guardian");
        KPR.dispute(keeper);
    }
    function slash(address bonded, address keeper, uint amount) external {
        require(msg.sender == guardian, "Keep2rGovernance::slash: !guardian");
        KPR.slash(bonded, keeper, amount);
    }
    function revoke(address keeper) external {
        require(msg.sender == guardian, "Keep2rGovernance::revoke: !guardian");
        KPR.revoke(keeper);
    }
    function resolve(address keeper) external {
        require(msg.sender == guardian, "Keep2rGovernance::resolve: !guardian");
        KPR.resolve(keeper);
    }

    mapping (bytes32 => bool) public queuedTransactions;

    constructor(address token_) public {
        guardian = msg.sender;
        KPR = IKeep2r(token_);
        DOMAINSEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
    }

    receive() external payable { }

    function setDelay(uint delay_) public {
        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(delay_ >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = delay_;

        emit NewDelay(delay);
    }

    function _queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) internal returns (bytes32) {
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function _cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) internal {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function _executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) internal returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value:value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}
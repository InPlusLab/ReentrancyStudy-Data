/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity 0.5.10;



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/**
 * @title Governance
 * @dev The Governance contract allows to execute certain actions via majority of votes.
 */
contract Governance {
    using SafeMath for uint256;

    mapping(bytes32 => Proposal) public proposals;
    bytes32[] public proposalsHashes;
    uint256 public proposalsCount;

    mapping(address => bool) public isVoter;
    address[] public voters;
    uint256 public votersCount;

    struct Proposal {
        bool finished;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) votedFor;
        mapping(address => bool) votedAgainst;
        address targetContract;
        bytes transaction;
    }

    event ProposalStarted(bytes32 proposalHash);
    event ProposalFinished(bytes32 proposalHash);
    event ProposalExecuted(bytes32 proposalHash);
    event Vote(bytes32 proposalHash, bool vote, uint256 yesVotes, uint256 noVotes, uint256 votersCount);
    event VoterAdded(address voter);
    event VoterDeleted(address voter);

    /**
    * @dev The Governance constructor adds sender to voters list.
    */
    constructor() public {
        voters.push(msg.sender);
        isVoter[msg.sender] = true;
        proposalsCount = 0;
        votersCount = 1;
    }

    /**
    * @dev Throws if called by any account other than the voter.
    */
    modifier onlyVoter() {
        require(isVoter[msg.sender], "Should be voter");
        _;
    }

    /**
    * @dev Throws if called by any account other than the Governance contract.
    */
    modifier onlyMe() {
        require(msg.sender == address(this), "Call only via Governance");
        _;
    }

    /**
    * @dev Creates a new voting proposal for the execution `_transaction` of `_targetContract`.
    * Only voter can create a new proposal.
    *
    * Emits a `ProposalStarted` event.
    *
    * Requirements:
    *
    * - `_targetContract` cannot be the zero address.
    * - `_transaction` length must not be less than 4 bytes.
    *
    * @notice Create a new voting proposal for the execution `_transaction` of `_targetContract`. You must be voter.
    * @param _targetContract Target contract address that can execute target `_transaction`
    * @param _transaction Target transaction to execute
    */
    function newProposal( address _targetContract, bytes memory _transaction ) public onlyVoter {
        require(_targetContract != address(0), "Address must be non-zero");
        require(_transaction.length >= 4, "Tx must be 4+ bytes");
        // solhint-disable not-rely-on-time
        bytes32 _proposalHash = keccak256(abi.encodePacked(_targetContract, _transaction, now));
        require(proposals[_proposalHash].transaction.length == 0, "The poll has already been initiated");
        proposals[_proposalHash].targetContract = _targetContract;
        proposals[_proposalHash].transaction = _transaction;
        proposalsHashes.push(_proposalHash);
        proposalsCount = proposalsCount.add(1);
        emit ProposalStarted(_proposalHash);
    }

    /**
    * @dev Adds sender's vote to the proposal and then follows the majority voting algoritm.
    *
    * Emits a `Vote` event.
    *
    * Requirements:
    *
    * - proposal with `_proposalHash` must not be finished.
    * - sender must not be already voted.
    *
    * @notice Vote "for" or "against" in proposal with `_proposalHash` hash.
    * @param _proposalHash Unique mapping key of proposal
    * @param _yes 1 is vote "for" and 0 is "against"
    */
    function vote(bytes32 _proposalHash, bool _yes) public onlyVoter { // solhint-disable code-complexity
        require(!proposals[_proposalHash].finished, "Already finished");
        require(!proposals[_proposalHash].votedFor[msg.sender], "Already voted");
        require(!proposals[_proposalHash].votedAgainst[msg.sender], "Already voted");
        if (_yes) {
            proposals[_proposalHash].yesVotes = proposals[_proposalHash].yesVotes.add(1);
            proposals[_proposalHash].votedFor[msg.sender] = true;
        } else {
            proposals[_proposalHash].noVotes = proposals[_proposalHash].noVotes.add(1);
            proposals[_proposalHash].votedAgainst[msg.sender] = true;
        }
        emit Vote(
            _proposalHash,
            _yes,
            proposals[_proposalHash].yesVotes,
            proposals[_proposalHash].noVotes,
            votersCount
        );
        if (proposals[_proposalHash].yesVotes > votersCount.div(2)) {
            executeProposal(_proposalHash);
            finishProposal(_proposalHash);
        } else if (proposals[_proposalHash].noVotes >= (votersCount + 1).div(2)) {
            finishProposal(_proposalHash);
        }
    }

/**
    * @dev Returns true in first output if `_address` is already voted in
    * proposal with `_proposalHash` hash.
    * Second output shows, if voter is voted for (true) or against (false).
    *
    * @param _proposalHash Unique mapping key of proposal
    * @param _address Address of the one who is checked
    */
    function getVoted(bytes32 _proposalHash, address _address) public view returns (bool, bool) {
        bool isVoted = proposals[_proposalHash].votedFor[_address] ||
            proposals[_proposalHash].votedAgainst[_address];
        bool side = proposals[_proposalHash].votedFor[_address];
        return (isVoted, side);
    }

    /**
    * @dev Adds `_address` to the voters list.
    * This method can be executed only via proposal of this Governance contract.
    *
    * Emits a `VoterAdded` event.
    *
    * Requirements:
    *
    * - `_address` cannot be the zero address.
    * - `_address` cannot be already in voters list.
    *
    * @param _address Address of voter to add
    */
    function addVoter(address _address) public onlyMe {
        require(_address != address(0), "Need non-zero address");
        require(!isVoter[_address], "Already in voters list");
        voters.push(_address);
        isVoter[_address] = true;
        votersCount = votersCount.add(1);
        emit VoterAdded(_address);
    }

    /**
    * @dev Removes `_address` from the voters list.
    * This method can be executed only via proposal of this Governance contract.
    *
    * Emits a `delVoter` event.
    *
    * Requirements:
    *
    * - `_address` must be in voters list.
    * - Num of voters must be more than one.
    *
    * @param _address Address of voter to delete
    */
    function delVoter(address _address) public onlyMe {
        require(isVoter[_address], "Not in voters list");
        require(votersCount > 1, "Can not delete single voter");
        for (uint256 i = 0; i < voters.length; i++) {
            if (voters[i] == _address) {
                if (voters.length > 1) {
                    voters[i] = voters[voters.length - 1];
                }
                voters.length--; // Implicitly recovers gas from last element storage
                isVoter[_address] = false;
                votersCount = votersCount.sub(1);
                emit VoterDeleted(_address);
                break;
            }
        }
    }

    /**
    * @dev Executes transaction in proposal with `_proposalHash` hash.
    * This method can be executed only from vote() method.
    */
    function executeProposal(bytes32 _proposalHash) internal {
        require(!proposals[_proposalHash].finished, "Already finished");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = address(
            proposals[_proposalHash].targetContract).call(proposals[_proposalHash].transaction
        );
        require(success, string(returnData));
        emit ProposalExecuted(_proposalHash);
    }

    /**
    * @dev Finishes proposal with `_proposalHash` hash.
    * This method can be executed only from vote() method.
    */
    function finishProposal(bytes32 _proposalHash) internal {
        require(!proposals[_proposalHash].finished, "Already finished");
        proposals[_proposalHash].finished = true;
        emit ProposalFinished(_proposalHash);
    }
}
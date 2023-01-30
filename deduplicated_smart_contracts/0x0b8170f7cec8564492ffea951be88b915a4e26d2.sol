/**

 *Submitted for verification at Etherscan.io on 2019-02-25

*/



// File: contracts/installed_contracts/DLL.sol



pragma solidity^0.4.11;



library DLL {



  uint constant NULL_NODE_ID = 0;



  struct Node {

    uint next;

    uint prev;

  }



  struct Data {

    mapping(uint => Node) dll;

  }



  function isEmpty(Data storage self) public view returns (bool) {

    return getStart(self) == NULL_NODE_ID;

  }



  function contains(Data storage self, uint _curr) public view returns (bool) {

    if (isEmpty(self) || _curr == NULL_NODE_ID) {

      return false;

    }



    bool isSingleNode = (getStart(self) == _curr) && (getEnd(self) == _curr);

    bool isNullNode = (getNext(self, _curr) == NULL_NODE_ID) && (getPrev(self, _curr) == NULL_NODE_ID);

    return isSingleNode || !isNullNode;

  }



  function getNext(Data storage self, uint _curr) public view returns (uint) {

    return self.dll[_curr].next;

  }



  function getPrev(Data storage self, uint _curr) public view returns (uint) {

    return self.dll[_curr].prev;

  }



  function getStart(Data storage self) public view returns (uint) {

    return getNext(self, NULL_NODE_ID);

  }



  function getEnd(Data storage self) public view returns (uint) {

    return getPrev(self, NULL_NODE_ID);

  }



  /**

  @dev Inserts a new node between _prev and _next. When inserting a node already existing in

  the list it will be automatically removed from the old position.

  @param _prev the node which _new will be inserted after

  @param _curr the id of the new node being inserted

  @param _next the node which _new will be inserted before

  */

  function insert(Data storage self, uint _prev, uint _curr, uint _next) public {

    require(_curr != NULL_NODE_ID);



    remove(self, _curr);



    require(_prev == NULL_NODE_ID || contains(self, _prev));

    require(_next == NULL_NODE_ID || contains(self, _next));



    require(getNext(self, _prev) == _next);

    require(getPrev(self, _next) == _prev);



    self.dll[_curr].prev = _prev;

    self.dll[_curr].next = _next;



    self.dll[_prev].next = _curr;

    self.dll[_next].prev = _curr;

  }



  function remove(Data storage self, uint _curr) public {

    if (!contains(self, _curr)) {

      return;

    }



    uint next = getNext(self, _curr);

    uint prev = getPrev(self, _curr);



    self.dll[next].prev = prev;

    self.dll[prev].next = next;



    delete self.dll[_curr];

  }

}



// File: contracts/installed_contracts/AttributeStore.sol



/* solium-disable */

pragma solidity^0.4.11;



library AttributeStore {

    struct Data {

        mapping(bytes32 => uint) store;

    }



    function getAttribute(Data storage self, bytes32 _UUID, string _attrName)

    public view returns (uint) {

        bytes32 key = keccak256(_UUID, _attrName);

        return self.store[key];

    }



    function setAttribute(Data storage self, bytes32 _UUID, string _attrName, uint _attrVal)

    public {

        bytes32 key = keccak256(_UUID, _attrName);

        self.store[key] = _attrVal;

    }

}



// File: contracts/zeppelin-solidity/token/ERC20/IERC20.sol



pragma solidity ^0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: contracts/zeppelin-solidity/math/SafeMath.sol



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: contracts/installed_contracts/PLCRVoting.sol



pragma solidity ^0.4.8;











/**

@title Partial-Lock-Commit-Reveal Voting scheme with ERC20 tokens

@author Team: Aspyn Palatnick, Cem Ozer, Yorke Rhodes

*/

contract PLCRVoting {



    // ============

    // EVENTS:

    // ============



    event _VoteCommitted(uint indexed pollID, uint numTokens, address indexed voter);

    event _VoteRevealed(uint indexed pollID, uint numTokens, uint votesFor, uint votesAgainst, uint indexed choice, address indexed voter, uint salt);

    event _PollCreated(uint voteQuorum, uint commitEndDate, uint revealEndDate, uint indexed pollID, address indexed creator);

    event _VotingRightsGranted(uint numTokens, address indexed voter);

    event _VotingRightsWithdrawn(uint numTokens, address indexed voter);

    event _TokensRescued(uint indexed pollID, address indexed voter);



    // ============

    // DATA STRUCTURES:

    // ============



    using AttributeStore for AttributeStore.Data;

    using DLL for DLL.Data;

    using SafeMath for uint;



    struct Poll {

        uint commitEndDate;     /// expiration date of commit period for poll

        uint revealEndDate;     /// expiration date of reveal period for poll

        uint voteQuorum;	    /// number of votes required for a proposal to pass

        uint votesFor;		    /// tally of votes supporting proposal

        uint votesAgainst;      /// tally of votes countering proposal

        mapping(address => bool) didCommit;  /// indicates whether an address committed a vote for this poll

        mapping(address => bool) didReveal;   /// indicates whether an address revealed a vote for this poll

    }



    // ============

    // STATE VARIABLES:

    // ============



    uint constant public INITIAL_POLL_NONCE = 0;

    uint public pollNonce;



    mapping(uint => Poll) public pollMap; // maps pollID to Poll struct

    mapping(address => uint) public voteTokenBalance; // maps user's address to voteToken balance



    mapping(address => DLL.Data) dllMap;

    AttributeStore.Data store;



    IERC20 public token;



    /**

    @param _token The address where the ERC20 token contract is deployed

    */

    constructor(address _token) public {

        require(_token != 0);



        token = IERC20(_token);

        pollNonce = INITIAL_POLL_NONCE;

    }



    // ================

    // TOKEN INTERFACE:

    // ================



    /**

    @notice Loads _numTokens ERC20 tokens into the voting contract for one-to-one voting rights

    @dev Assumes that msg.sender has approved voting contract to spend on their behalf

    @param _numTokens The number of votingTokens desired in exchange for ERC20 tokens

    */

    function requestVotingRights(uint _numTokens) public {

        require(token.balanceOf(msg.sender) >= _numTokens);

        voteTokenBalance[msg.sender] += _numTokens;

        require(token.transferFrom(msg.sender, this, _numTokens));

        emit _VotingRightsGranted(_numTokens, msg.sender);

    }



    /**

    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights

    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights

    */

    function withdrawVotingRights(uint _numTokens) external {

        uint availableTokens = voteTokenBalance[msg.sender].sub(getLockedTokens(msg.sender));

        require(availableTokens >= _numTokens);

        voteTokenBalance[msg.sender] -= _numTokens;

        require(token.transfer(msg.sender, _numTokens));

        emit _VotingRightsWithdrawn(_numTokens, msg.sender);

    }



    /**

    @dev Unlocks tokens locked in unrevealed vote where poll has ended

    @param _pollID Integer identifier associated with the target poll

    */

    function rescueTokens(uint _pollID) public {

        require(isExpired(pollMap[_pollID].revealEndDate));

        require(dllMap[msg.sender].contains(_pollID));



        dllMap[msg.sender].remove(_pollID);

        emit _TokensRescued(_pollID, msg.sender);

    }



    /**

    @dev Unlocks tokens locked in unrevealed votes where polls have ended

    @param _pollIDs Array of integer identifiers associated with the target polls

    */

    function rescueTokensInMultiplePolls(uint[] _pollIDs) public {

        // loop through arrays, rescuing tokens from all

        for (uint i = 0; i < _pollIDs.length; i++) {

            rescueTokens(_pollIDs[i]);

        }

    }



    // =================

    // VOTING INTERFACE:

    // =================



    /**

    @notice Commits vote using hash of choice and secret salt to conceal vote until reveal

    @param _pollID Integer identifier associated with target poll

    @param _secretHash Commit keccak256 hash of voter's choice and salt (tightly packed in this order)

    @param _numTokens The number of tokens to be committed towards the target poll

    @param _prevPollID The ID of the poll that the user has voted the maximum number of tokens in which is still less than or equal to numTokens

    */

    function commitVote(uint _pollID, bytes32 _secretHash, uint _numTokens, uint _prevPollID) public {

        require(commitPeriodActive(_pollID));



        // if msg.sender doesn't have enough voting rights,

        // request for enough voting rights

        if (voteTokenBalance[msg.sender] < _numTokens) {

            uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);

            requestVotingRights(remainder);

        }



        // make sure msg.sender has enough voting rights

        require(voteTokenBalance[msg.sender] >= _numTokens);

        // prevent user from committing to zero node placeholder

        require(_pollID != 0);

        // prevent user from committing a secretHash of 0

        require(_secretHash != 0);



        // Check if _prevPollID exists in the user's DLL or if _prevPollID is 0

        require(_prevPollID == 0 || dllMap[msg.sender].contains(_prevPollID));



        uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);



        // edge case: in-place update

        if (nextPollID == _pollID) {

            nextPollID = dllMap[msg.sender].getNext(_pollID);

        }



        require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));

        dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);



        bytes32 UUID = attrUUID(msg.sender, _pollID);



        store.setAttribute(UUID, "numTokens", _numTokens);

        store.setAttribute(UUID, "commitHash", uint(_secretHash));



        pollMap[_pollID].didCommit[msg.sender] = true;

        emit _VoteCommitted(_pollID, _numTokens, msg.sender);

    }



    /**

    @notice                 Commits votes using hashes of choices and secret salts to conceal votes until reveal

    @param _pollIDs         Array of integer identifiers associated with target polls

    @param _secretHashes    Array of commit keccak256 hashes of voter's choices and salts (tightly packed in this order)

    @param _numsTokens      Array of numbers of tokens to be committed towards the target polls

    @param _prevPollIDs     Array of IDs of the polls that the user has voted the maximum number of tokens in which is still less than or equal to numTokens

    */

    function commitVotes(uint[] _pollIDs, bytes32[] _secretHashes, uint[] _numsTokens, uint[] _prevPollIDs) external {

        // make sure the array lengths are all the same

        require(_pollIDs.length == _secretHashes.length);

        require(_pollIDs.length == _numsTokens.length);

        require(_pollIDs.length == _prevPollIDs.length);



        // loop through arrays, committing each individual vote values

        for (uint i = 0; i < _pollIDs.length; i++) {

            commitVote(_pollIDs[i], _secretHashes[i], _numsTokens[i], _prevPollIDs[i]);

        }

    }



    /**

    @dev Compares previous and next poll's committed tokens for sorting purposes

    @param _prevID Integer identifier associated with previous poll in sorted order

    @param _nextID Integer identifier associated with next poll in sorted order

    @param _voter Address of user to check DLL position for

    @param _numTokens The number of tokens to be committed towards the poll (used for sorting)

    @return valid Boolean indication of if the specified position maintains the sort

    */

    function validPosition(uint _prevID, uint _nextID, address _voter, uint _numTokens) public constant returns (bool valid) {

        bool prevValid = (_numTokens >= getNumTokens(_voter, _prevID));

        // if next is zero node, _numTokens does not need to be greater

        bool nextValid = (_numTokens <= getNumTokens(_voter, _nextID) || _nextID == 0);

        return prevValid && nextValid;

    }



    /**

    @notice Reveals vote with choice and secret salt used in generating commitHash to attribute committed tokens

    @param _pollID Integer identifier associated with target poll

    @param _voteOption Vote choice used to generate commitHash for associated poll

    @param _salt Secret number used to generate commitHash for associated poll

    */

    function revealVote(uint _pollID, uint _voteOption, uint _salt) public {

        // Make sure the reveal period is active

        require(revealPeriodActive(_pollID));

        require(pollMap[_pollID].didCommit[msg.sender]);                         // make sure user has committed a vote for this poll

        require(!pollMap[_pollID].didReveal[msg.sender]);                        // prevent user from revealing multiple times

        require(keccak256(_voteOption, _salt) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash



        uint numTokens = getNumTokens(msg.sender, _pollID);



        if (_voteOption == 1) {// apply numTokens to appropriate poll choice

            pollMap[_pollID].votesFor += numTokens;

        } else {

            pollMap[_pollID].votesAgainst += numTokens;

        }



        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal

        pollMap[_pollID].didReveal[msg.sender] = true;



        emit _VoteRevealed(_pollID, numTokens, pollMap[_pollID].votesFor, pollMap[_pollID].votesAgainst, _voteOption, msg.sender, _salt);

    }



    /**

    @notice             Reveals multiple votes with choices and secret salts used in generating commitHashes to attribute committed tokens

    @param _pollIDs     Array of integer identifiers associated with target polls

    @param _voteOptions Array of vote choices used to generate commitHashes for associated polls

    @param _salts       Array of secret numbers used to generate commitHashes for associated polls

    */

    function revealVotes(uint[] _pollIDs, uint[] _voteOptions, uint[] _salts) external {

        // make sure the array lengths are all the same

        require(_pollIDs.length == _voteOptions.length);

        require(_pollIDs.length == _salts.length);



        // loop through arrays, revealing each individual vote values

        for (uint i = 0; i < _pollIDs.length; i++) {

            revealVote(_pollIDs[i], _voteOptions[i], _salts[i]);

        }

    }



    /**

    @param _pollID Integer identifier associated with target poll

    @param _salt Arbitrarily chosen integer used to generate secretHash

    @return correctVotes Number of tokens voted for winning option

    */

    function getNumPassingTokens(address _voter, uint _pollID, uint _salt) public constant returns (uint correctVotes) {

        require(pollEnded(_pollID));

        require(pollMap[_pollID].didReveal[_voter]);



        uint winningChoice = isPassed(_pollID) ? 1 : 0;

        bytes32 winnerHash = keccak256(winningChoice, _salt);

        bytes32 commitHash = getCommitHash(_voter, _pollID);



        require(winnerHash == commitHash);



        return getNumTokens(_voter, _pollID);

    }



    // ==================

    // POLLING INTERFACE:

    // ==================



    /**

    @dev Initiates a poll with canonical configured parameters at pollID emitted by PollCreated event

    @param _voteQuorum Type of majority (out of 100) that is necessary for poll to be successful

    @param _commitDuration Length of desired commit period in seconds

    @param _revealDuration Length of desired reveal period in seconds

    */

    function startPoll(uint _voteQuorum, uint _commitDuration, uint _revealDuration) public returns (uint pollID) {

        pollNonce = pollNonce + 1;



        uint commitEndDate = block.timestamp.add(_commitDuration);

        uint revealEndDate = commitEndDate.add(_revealDuration);



        pollMap[pollNonce] = Poll({

            voteQuorum: _voteQuorum,

            commitEndDate: commitEndDate,

            revealEndDate: revealEndDate,

            votesFor: 0,

            votesAgainst: 0

        });



        emit _PollCreated(_voteQuorum, commitEndDate, revealEndDate, pollNonce, msg.sender);

        return pollNonce;

    }



    /**

    @notice Determines if proposal has passed

    @dev Check if votesFor out of totalVotes exceeds votesQuorum (requires pollEnded)

    @param _pollID Integer identifier associated with target poll

    */

    function isPassed(uint _pollID) constant public returns (bool passed) {

        require(pollEnded(_pollID));



        Poll memory poll = pollMap[_pollID];

        return (100 * poll.votesFor) > (poll.voteQuorum * (poll.votesFor + poll.votesAgainst));

    }



    // ----------------

    // POLLING HELPERS:

    // ----------------



    /**

    @dev Gets the total winning votes for reward distribution purposes

    @param _pollID Integer identifier associated with target poll

    @return Total number of votes committed to the winning option for specified poll

    */

    function getTotalNumberOfTokensForWinningOption(uint _pollID) constant public returns (uint numTokens) {

        require(pollEnded(_pollID));



        if (isPassed(_pollID))

            return pollMap[_pollID].votesFor;

        else

            return pollMap[_pollID].votesAgainst;

    }



    /**

    @notice Determines if poll is over

    @dev Checks isExpired for specified poll's revealEndDate

    @return Boolean indication of whether polling period is over

    */

    function pollEnded(uint _pollID) constant public returns (bool ended) {

        require(pollExists(_pollID));



        return isExpired(pollMap[_pollID].revealEndDate);

    }



    /**

    @notice Checks if the commit period is still active for the specified poll

    @dev Checks isExpired for the specified poll's commitEndDate

    @param _pollID Integer identifier associated with target poll

    @return Boolean indication of isCommitPeriodActive for target poll

    */

    function commitPeriodActive(uint _pollID) constant public returns (bool active) {

        require(pollExists(_pollID));



        return !isExpired(pollMap[_pollID].commitEndDate);

    }



    /**

    @notice Checks if the reveal period is still active for the specified poll

    @dev Checks isExpired for the specified poll's revealEndDate

    @param _pollID Integer identifier associated with target poll

    */

    function revealPeriodActive(uint _pollID) constant public returns (bool active) {

        require(pollExists(_pollID));



        return !isExpired(pollMap[_pollID].revealEndDate) && !commitPeriodActive(_pollID);

    }



    /**

    @dev Checks if user has committed for specified poll

    @param _voter Address of user to check against

    @param _pollID Integer identifier associated with target poll

    @return Boolean indication of whether user has committed

    */

    function didCommit(address _voter, uint _pollID) constant public returns (bool committed) {

        require(pollExists(_pollID));



        return pollMap[_pollID].didCommit[_voter];

    }



    /**

    @dev Checks if user has revealed for specified poll

    @param _voter Address of user to check against

    @param _pollID Integer identifier associated with target poll

    @return Boolean indication of whether user has revealed

    */

    function didReveal(address _voter, uint _pollID) constant public returns (bool revealed) {

        require(pollExists(_pollID));



        return pollMap[_pollID].didReveal[_voter];

    }



    /**

    @dev Checks if a poll exists

    @param _pollID The pollID whose existance is to be evaluated.

    @return Boolean Indicates whether a poll exists for the provided pollID

    */

    function pollExists(uint _pollID) constant public returns (bool exists) {

        return (_pollID != 0 && _pollID <= pollNonce);

    }



    // ---------------------------

    // DOUBLE-LINKED-LIST HELPERS:

    // ---------------------------



    /**

    @dev Gets the bytes32 commitHash property of target poll

    @param _voter Address of user to check against

    @param _pollID Integer identifier associated with target poll

    @return Bytes32 hash property attached to target poll

    */

    function getCommitHash(address _voter, uint _pollID) constant public returns (bytes32 commitHash) {

        return bytes32(store.getAttribute(attrUUID(_voter, _pollID), "commitHash"));

    }



    /**

    @dev Wrapper for getAttribute with attrName="numTokens"

    @param _voter Address of user to check against

    @param _pollID Integer identifier associated with target poll

    @return Number of tokens committed to poll in sorted poll-linked-list

    */

    function getNumTokens(address _voter, uint _pollID) constant public returns (uint numTokens) {

        return store.getAttribute(attrUUID(_voter, _pollID), "numTokens");

    }



    /**

    @dev Gets top element of sorted poll-linked-list

    @param _voter Address of user to check against

    @return Integer identifier to poll with maximum number of tokens committed to it

    */

    function getLastNode(address _voter) constant public returns (uint pollID) {

        return dllMap[_voter].getPrev(0);

    }



    /**

    @dev Gets the numTokens property of getLastNode

    @param _voter Address of user to check against

    @return Maximum number of tokens committed in poll specified

    */

    function getLockedTokens(address _voter) constant public returns (uint numTokens) {

        return getNumTokens(_voter, getLastNode(_voter));

    }



    /*

    @dev Takes the last node in the user's DLL and iterates backwards through the list searching

    for a node with a value less than or equal to the provided _numTokens value. When such a node

    is found, if the provided _pollID matches the found nodeID, this operation is an in-place

    update. In that case, return the previous node of the node being updated. Otherwise return the

    first node that was found with a value less than or equal to the provided _numTokens.

    @param _voter The voter whose DLL will be searched

    @param _numTokens The value for the numTokens attribute in the node to be inserted

    @return the node which the propoded node should be inserted after

    */

    function getInsertPointForNumTokens(address _voter, uint _numTokens, uint _pollID)

    constant public returns (uint prevNode) {

      // Get the last node in the list and the number of tokens in that node

      uint nodeID = getLastNode(_voter);

      uint tokensInNode = getNumTokens(_voter, nodeID);



      // Iterate backwards through the list until reaching the root node

      while(nodeID != 0) {

        // Get the number of tokens in the current node

        tokensInNode = getNumTokens(_voter, nodeID);

        if(tokensInNode <= _numTokens) { // We found the insert point!

          if(nodeID == _pollID) {

            // This is an in-place update. Return the prev node of the node being updated

            nodeID = dllMap[_voter].getPrev(nodeID);

          }

          // Return the insert point

          return nodeID;

        }

        // We did not find the insert point. Continue iterating backwards through the list

        nodeID = dllMap[_voter].getPrev(nodeID);

      }



      // The list is empty, or a smaller value than anything else in the list is being inserted

      return nodeID;

    }



    // ----------------

    // GENERAL HELPERS:

    // ----------------



    /**

    @dev Checks if an expiration date has been reached

    @param _terminationDate Integer timestamp of date to compare current timestamp with

    @return expired Boolean indication of whether the terminationDate has passed

    */

    function isExpired(uint _terminationDate) constant public returns (bool expired) {

        return (block.timestamp > _terminationDate);

    }



    /**

    @dev Generates an identifier which associates a user and a poll together

    @param _pollID Integer identifier associated with target poll

    @return UUID Hash which is deterministic from _user and _pollID

    */

    function attrUUID(address _user, uint _pollID) public pure returns (bytes32 UUID) {

        return keccak256(_user, _pollID);

    }

}



// File: contracts/installed_contracts/Parameterizer.sol



pragma solidity^0.4.11;









contract Parameterizer {



    // ------

    // EVENTS

    // ------



    event _ReparameterizationProposal(string name, uint value, bytes32 propID, uint deposit, uint appEndDate, address indexed proposer);

    event _NewChallenge(bytes32 indexed propID, uint challengeID, uint commitEndDate, uint revealEndDate, address indexed challenger);

    event _ProposalAccepted(bytes32 indexed propID, string name, uint value);

    event _ProposalExpired(bytes32 indexed propID);

    event _ChallengeSucceeded(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);

    event _ChallengeFailed(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);

    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);





    // ------

    // DATA STRUCTURES

    // ------



    using SafeMath for uint;



    struct ParamProposal {

        uint appExpiry;

        uint challengeID;

        uint deposit;

        string name;

        address owner;

        uint processBy;

        uint value;

    }



    struct Challenge {

        uint rewardPool;        // (remaining) pool of tokens distributed amongst winning voters

        address challenger;     // owner of Challenge

        bool resolved;          // indication of if challenge is resolved

        uint stake;             // number of tokens at risk for either party during challenge

        uint winningTokens;     // (remaining) amount of tokens used for voting by the winning side

        mapping(address => bool) tokenClaims;

    }



    // ------

    // STATE

    // ------



    mapping(bytes32 => uint) public params;



    // maps challengeIDs to associated challenge data

    mapping(uint => Challenge) public challenges;



    // maps pollIDs to intended data change if poll passes

    mapping(bytes32 => ParamProposal) public proposals;



    // Global Variables

    IERC20 public token;

    PLCRVoting public voting;

    uint public PROCESSBY = 604800; // 7 days



    /**

    @param _token           The address where the ERC20 token contract is deployed

    @param _plcr            address of a PLCR voting contract for the provided token

    @notice _parameters     array of canonical parameters

    */

    constructor(

        address _token,

        address _plcr,

        uint[] _parameters

    ) public {

        token = IERC20(_token);

        voting = PLCRVoting(_plcr);



        // minimum deposit for listing to be whitelisted

        set("minDeposit", _parameters[0]);



        // minimum deposit to propose a reparameterization

        set("pMinDeposit", _parameters[1]);



        // period over which applicants wait to be whitelisted

        set("applyStageLen", _parameters[2]);



        // period over which reparmeterization proposals wait to be processed

        set("pApplyStageLen", _parameters[3]);



        // length of commit period for voting

        set("commitStageLen", _parameters[4]);



        // length of commit period for voting in parameterizer

        set("pCommitStageLen", _parameters[5]);



        // length of reveal period for voting

        set("revealStageLen", _parameters[6]);



        // length of reveal period for voting in parameterizer

        set("pRevealStageLen", _parameters[7]);



        // percentage of losing party's deposit distributed to winning party

        set("dispensationPct", _parameters[8]);



        // percentage of losing party's deposit distributed to winning party in parameterizer

        set("pDispensationPct", _parameters[9]);



        // type of majority out of 100 necessary for candidate success

        set("voteQuorum", _parameters[10]);



        // type of majority out of 100 necessary for proposal success in parameterizer

        set("pVoteQuorum", _parameters[11]);

    }



    // -----------------------

    // TOKEN HOLDER INTERFACE

    // -----------------------



    /**

    @notice propose a reparamaterization of the key _name's value to _value.

    @param _name the name of the proposed param to be set

    @param _value the proposed value to set the param to be set

    */

    function proposeReparameterization(string _name, uint _value) public returns (bytes32) {

        uint deposit = get("pMinDeposit");

        bytes32 propID = keccak256(_name, _value);



        if (keccak256(_name) == keccak256("dispensationPct") ||

            keccak256(_name) == keccak256("pDispensationPct")) {

            require(_value <= 100);

        }



        require(!propExists(propID)); // Forbid duplicate proposals

        require(get(_name) != _value); // Forbid NOOP reparameterizations



        // attach name and value to pollID

        proposals[propID] = ParamProposal({

            appExpiry: now.add(get("pApplyStageLen")),

            challengeID: 0,

            deposit: deposit,

            name: _name,

            owner: msg.sender,

            processBy: now.add(get("pApplyStageLen"))

                .add(get("pCommitStageLen"))

                .add(get("pRevealStageLen"))

                .add(PROCESSBY),

            value: _value

        });



        require(token.transferFrom(msg.sender, this, deposit)); // escrow tokens (deposit amt)



        emit _ReparameterizationProposal(_name, _value, propID, deposit, proposals[propID].appExpiry, msg.sender);

        return propID;

    }



    /**

    @notice challenge the provided proposal ID, and put tokens at stake to do so.

    @param _propID the proposal ID to challenge

    */

    function challengeReparameterization(bytes32 _propID) public returns (uint challengeID) {

        ParamProposal memory prop = proposals[_propID];

        uint deposit = prop.deposit;



        require(propExists(_propID) && prop.challengeID == 0);



        //start poll

        uint pollID = voting.startPoll(

            get("pVoteQuorum"),

            get("pCommitStageLen"),

            get("pRevealStageLen")

        );



        challenges[pollID] = Challenge({

            challenger: msg.sender,

            rewardPool: SafeMath.sub(100, get("pDispensationPct")).mul(deposit).div(100),

            stake: deposit,

            resolved: false,

            winningTokens: 0

        });



        proposals[_propID].challengeID = pollID;       // update listing to store most recent challenge



        //take tokens from challenger

        require(token.transferFrom(msg.sender, this, deposit));



        var (commitEndDate, revealEndDate,) = voting.pollMap(pollID);



        emit _NewChallenge(_propID, pollID, commitEndDate, revealEndDate, msg.sender);

        return pollID;

    }



    /**

    @notice             for the provided proposal ID, set it, resolve its challenge, or delete it depending on whether it can be set, has a challenge which can be resolved, or if its "process by" date has passed

    @param _propID      the proposal ID to make a determination and state transition for

    */

    function processProposal(bytes32 _propID) public {

        ParamProposal storage prop = proposals[_propID];

        address propOwner = prop.owner;

        uint propDeposit = prop.deposit;





        // Before any token transfers, deleting the proposal will ensure that if reentrancy occurs the

        // prop.owner and prop.deposit will be 0, thereby preventing theft

        if (canBeSet(_propID)) {

            // There is no challenge against the proposal. The processBy date for the proposal has not

            // passed, but the proposal's appExpirty date has passed.

            set(prop.name, prop.value);

            emit _ProposalAccepted(_propID, prop.name, prop.value);

            delete proposals[_propID];

            require(token.transfer(propOwner, propDeposit));

        } else if (challengeCanBeResolved(_propID)) {

            // There is a challenge against the proposal.

            resolveChallenge(_propID);

        } else if (now > prop.processBy) {

            // There is no challenge against the proposal, but the processBy date has passed.

            emit _ProposalExpired(_propID);

            delete proposals[_propID];

            require(token.transfer(propOwner, propDeposit));

        } else {

            // There is no challenge against the proposal, and neither the appExpiry date nor the

            // processBy date has passed.

            revert();

        }



        assert(get("dispensationPct") <= 100);

        assert(get("pDispensationPct") <= 100);



        // verify that future proposal appExpiry and processBy times will not overflow

        now.add(get("pApplyStageLen"))

            .add(get("pCommitStageLen"))

            .add(get("pRevealStageLen"))

            .add(PROCESSBY);



        delete proposals[_propID];

    }



    /**

    @notice                 Claim the tokens owed for the msg.sender in the provided challenge

    @param _challengeID     the challenge ID to claim tokens for

    @param _salt            the salt used to vote in the challenge being withdrawn for

    */

    function claimReward(uint _challengeID, uint _salt) public {

        // ensure voter has not already claimed tokens and challenge results have been processed

        require(challenges[_challengeID].tokenClaims[msg.sender] == false);

        require(challenges[_challengeID].resolved == true);



        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);

        uint reward = voterReward(msg.sender, _challengeID, _salt);



        // subtract voter's information to preserve the participation ratios of other voters

        // compared to the remaining pool of rewards

        challenges[_challengeID].winningTokens -= voterTokens;

        challenges[_challengeID].rewardPool -= reward;



        // ensures a voter cannot claim tokens again

        challenges[_challengeID].tokenClaims[msg.sender] = true;



        emit _RewardClaimed(_challengeID, reward, msg.sender);

        require(token.transfer(msg.sender, reward));

    }



    /**

    @dev                    Called by a voter to claim their rewards for each completed vote.

                            Someone must call updateStatus() before this can be called.

    @param _challengeIDs    The PLCR pollIDs of the challenges rewards are being claimed for

    @param _salts           The salts of a voter's commit hashes in the given polls

    */

    function claimRewards(uint[] _challengeIDs, uint[] _salts) public {

        // make sure the array lengths are the same

        require(_challengeIDs.length == _salts.length);



        // loop through arrays, claiming each individual vote reward

        for (uint i = 0; i < _challengeIDs.length; i++) {

            claimReward(_challengeIDs[i], _salts[i]);

        }

    }



    // --------

    // GETTERS

    // --------



    /**

    @dev                Calculates the provided voter's token reward for the given poll.

    @param _voter       The address of the voter whose reward balance is to be returned

    @param _challengeID The ID of the challenge the voter's reward is being calculated for

    @param _salt        The salt of the voter's commit hash in the given poll

    @return             The uint indicating the voter's reward

    */

    function voterReward(address _voter, uint _challengeID, uint _salt)

    public view returns (uint) {

        uint winningTokens = challenges[_challengeID].winningTokens;

        uint rewardPool = challenges[_challengeID].rewardPool;

        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID, _salt);

        return (voterTokens * rewardPool) / winningTokens;

    }



    /**

    @notice Determines whether a proposal passed its application stage without a challenge

    @param _propID The proposal ID for which to determine whether its application stage passed without a challenge

    */

    function canBeSet(bytes32 _propID) view public returns (bool) {

        ParamProposal memory prop = proposals[_propID];



        return (now > prop.appExpiry && now < prop.processBy && prop.challengeID == 0);

    }



    /**

    @notice Determines whether a proposal exists for the provided proposal ID

    @param _propID The proposal ID whose existance is to be determined

    */

    function propExists(bytes32 _propID) view public returns (bool) {

        return proposals[_propID].processBy > 0;

    }



    /**

    @notice Determines whether the provided proposal ID has a challenge which can be resolved

    @param _propID The proposal ID whose challenge to inspect

    */

    function challengeCanBeResolved(bytes32 _propID) view public returns (bool) {

        ParamProposal memory prop = proposals[_propID];

        Challenge memory challenge = challenges[prop.challengeID];



        return (prop.challengeID > 0 && challenge.resolved == false && voting.pollEnded(prop.challengeID));

    }



    /**

    @notice Determines the number of tokens to awarded to the winning party in a challenge

    @param _challengeID The challengeID to determine a reward for

    */

    function challengeWinnerReward(uint _challengeID) public view returns (uint) {

        if(voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {

            // Edge case, nobody voted, give all tokens to the challenger.

            return 2 * challenges[_challengeID].stake;

        }



        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;

    }



    /**

    @notice gets the parameter keyed by the provided name value from the params mapping

    @param _name the key whose value is to be determined

    */

    function get(string _name) public view returns (uint value) {

        return params[keccak256(_name)];

    }



    /**

    @dev                Getter for Challenge tokenClaims mappings

    @param _challengeID The challengeID to query

    @param _voter       The voter whose claim status to query for the provided challengeID

    */

    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {

        return challenges[_challengeID].tokenClaims[_voter];

    }



    // ----------------

    // PRIVATE FUNCTIONS

    // ----------------



    /**

    @dev resolves a challenge for the provided _propID. It must be checked in advance whether the _propID has a challenge on it

    @param _propID the proposal ID whose challenge is to be resolved.

    */

    function resolveChallenge(bytes32 _propID) private {

        ParamProposal memory prop = proposals[_propID];

        Challenge storage challenge = challenges[prop.challengeID];



        // winner gets back their full staked deposit, and dispensationPct*loser's stake

        uint reward = challengeWinnerReward(prop.challengeID);



        challenge.winningTokens = voting.getTotalNumberOfTokensForWinningOption(prop.challengeID);

        challenge.resolved = true;



        if (voting.isPassed(prop.challengeID)) { // The challenge failed

            if(prop.processBy > now) {

                set(prop.name, prop.value);

            }

            emit _ChallengeFailed(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);

            require(token.transfer(prop.owner, reward));

        }

        else { // The challenge succeeded or nobody voted

            emit _ChallengeSucceeded(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);

            require(token.transfer(challenges[prop.challengeID].challenger, reward));

        }

    }



    /**

    @dev sets the param keted by the provided name to the provided value

    @param _name the name of the param to be set

    @param _value the value to set the param to be set

    */

    function set(string _name, uint _value) internal {

        params[keccak256(_name)] = _value;

    }

}



// File: contracts/tcr/CivilParameterizer.sol



pragma solidity ^0.4.19;





contract CivilParameterizer is Parameterizer {



  /**

  @param tokenAddr           The address where the ERC20 token contract is deployed

  @param plcrAddr            address of a PLCR voting contract for the provided token

  @notice parameters     array of canonical parameters

  */

  constructor(

    address tokenAddr,

    address plcrAddr,

    uint[] parameters

  ) public Parameterizer(tokenAddr, plcrAddr, parameters)

  {

    set("challengeAppealLen", parameters[12]);

    set("challengeAppealCommitLen", parameters[13]);

    set("challengeAppealRevealLen", parameters[14]);

  }

}
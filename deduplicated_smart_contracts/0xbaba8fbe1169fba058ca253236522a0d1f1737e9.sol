/**

 *Submitted for verification at Etherscan.io on 2018-09-07

*/



pragma solidity ^0.4.24;





contract EIP20Interface {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) public view returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    // solhint-disable-next-line no-simple-event-func-name

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/*

Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

.*/





contract EIP20 is EIP20Interface {



    uint256 constant private MAX_UINT256 = 2**256 - 1;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    /*

    NOTE:

    The following variables are OPTIONAL vanities. One does not have to include them.

    They allow one to customise the token contract & in no way influences the core functionality.

    Some wallets/interfaces might not even bother to look at this information.

    */

    string public name;                   //fancy name: eg Simon Bucks

    uint8 public decimals;                //How many decimals to show.

    string public symbol;                 //An identifier: eg SBX



    function EIP20(

        uint256 _initialAmount,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol

    ) public {

        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens

        totalSupply = _initialAmount;                        // Update total supply

        name = _tokenName;                                   // Set the name for display purposes

        decimals = _decimalUnits;                            // Amount of decimals for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        uint256 allowance = allowed[_from][msg.sender];

        require(balances[_from] >= _value && allowance >= _value);

        balances[_to] += _value;

        balances[_from] -= _value;

        if (allowance < MAX_UINT256) {

            allowed[_from][msg.sender] -= _value;

        }

        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

}





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}







/**

 * @title ERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface ERC165 {



  /**

   * @notice Query if a contract implements an interface

   * @param _interfaceId The interface identifier, as specified in ERC-165

   * @dev Interface identification is specified in ERC-165. This function

   * uses less than 30,000 gas.

   */

  function supportsInterface(bytes4 _interfaceId)

    external

    view

    returns (bool);

}



contract CanCheckERC165 {

  bytes4 constant InvalidID = 0xffffffff;

  bytes4 constant ERC165ID = 0x01ffc9a7;

  function doesContractImplementInterface(address _contract, bytes4 _interfaceId) external view returns (bool) {

      uint256 success;

      uint256 result;



      (success, result) = noThrowCall(_contract, ERC165ID);

      if ((success==0)||(result==0)) {

          return false;

      }



      (success, result) = noThrowCall(_contract, InvalidID);

      if ((success==0)||(result!=0)) {

          return false;

      }



      (success, result) = noThrowCall(_contract, _interfaceId);

      if ((success==1)&&(result==1)) {

          return true;

      }

      return false;

  }



  function noThrowCall(address _contract, bytes4 _interfaceId) internal view returns (uint256 success, uint256 result) {

    bytes4 erc165ID = ERC165ID;



    assembly {

            let x := mload(0x40)               // Find empty storage location using "free memory pointer"

            mstore(x, erc165ID)                // Place signature at begining of empty storage

            mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature



            success := staticcall(

                                30000,         // 30k gas

                                _contract,     // To addr

                                x,             // Inputs are stored at location x

                                0x20,          // Inputs are 32 bytes long

                                x,             // Store output over input (saves space)

                                0x20)          // Outputs are 32 bytes long



            result := mload(x)                 // Load the result

    }

  }

}





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





/**

@title Partial-Lock-Commit-Reveal Voting scheme with ERC20 tokens

@author Team: Aspyn Palatnick, Cem Ozer, Yorke Rhodes

*/

contract PLCRVoting {



    // ============

    // EVENTS:

    // ============



    event _VoteCommitted(uint indexed pollID, uint numTokens, address indexed voter);

    event _VoteRevealed(uint indexed pollID, uint numTokens, uint votesFor, uint votesAgainst, uint indexed choice, address indexed voter);

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



    EIP20Interface public token;



    /**

    @dev Initializer. Can only be called once.

    @param _token The address where the ERC20 token contract is deployed

    */

    constructor(address _token) public {

        require(_token != 0 && address(token) == 0);



        token = EIP20Interface(_token);

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

        require(keccak256(abi.encodePacked(_voteOption, _salt)) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash



        uint numTokens = getNumTokens(msg.sender, _pollID);



        if (_voteOption == 1) {// apply numTokens to appropriate poll choice

            pollMap[_pollID].votesFor += numTokens;

        } else {

            pollMap[_pollID].votesAgainst += numTokens;

        }



        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal

        pollMap[_pollID].didReveal[msg.sender] = true;



        emit _VoteRevealed(_pollID, numTokens, pollMap[_pollID].votesFor, pollMap[_pollID].votesAgainst, _voteOption, msg.sender);

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

        bytes32 winnerHash = keccak256(abi.encodePacked(winningChoice, _salt));

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

        return keccak256(abi.encodePacked(_user, _pollID));

    }

}





contract Parameterizer is Ownable, CanCheckERC165 {



  // ------

  // EVENTS

  // ------



  event _ReparameterizationProposal(string name, uint value, bytes32 propID, uint deposit, uint appEndDate);

  event _NewChallenge(bytes32 indexed propID, uint challengeID, uint commitEndDate, uint revealEndDate);

  event _ProposalAccepted(bytes32 indexed propID, string name, uint value);

  event _ProposalExpired(bytes32 indexed propID);

  event _ChallengeSucceeded(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);

  event _ChallengeFailed(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);

  event _RewardClaimed(uint indexed challengeID, uint reward);





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

  EIP20Interface public token;

  PLCRVoting public voting;

  uint public PROCESSBY = 604800; // 7 days



  string constant NEW_REGISTRY = "_newRegistry";

  bytes32 constant NEW_REGISTRY_KEC = keccak256(abi.encodePacked(NEW_REGISTRY));

  bytes32 constant DISPENSATION_PCT_KEC = keccak256(abi.encodePacked("dispensationPct"));

  bytes32 constant P_DISPENSATION_PCT_KEC = keccak256(abi.encodePacked("pDispensationPct"));



  // todo: fill this in with the interface ID of the registry migration interface we will have

  bytes4 public REGISTRY_INTERFACE_REQUIREMENT;



  // ------------

  // CONSTRUCTOR

  // ------------



  /**

  @dev constructor

  @param _tokenAddr        address of the token which parameterizes this system

  @param _plcrAddr         address of a PLCR voting contract for the provided token

  @param _minDeposit       minimum deposit for listing to be whitelisted

  @param _pMinDeposit      minimum deposit to propose a reparameterization

  @param _applyStageLen    period over which applicants wait to be whitelisted

  @param _pApplyStageLen   period over which reparmeterization proposals wait to be processed

  @param _dispensationPct  percentage of losing party's deposit distributed to winning party

  @param _pDispensationPct percentage of losing party's deposit distributed to winning party in parameterizer

  @param _commitStageLen  length of commit period for voting

  @param _pCommitStageLen length of commit period for voting in parameterizer

  @param _revealStageLen  length of reveal period for voting

  @param _pRevealStageLen length of reveal period for voting in parameterizer

  @param _voteQuorum       type of majority out of 100 necessary for vote success

  @param _pVoteQuorum      type of majority out of 100 necessary for vote success in parameterizer

  @param _newRegistryIface ERC165 interface ID requirement (not a votable parameter)

  */

  constructor(

    address _tokenAddr,

    address _plcrAddr,

    uint _minDeposit,

    uint _pMinDeposit,

    uint _applyStageLen,

    uint _pApplyStageLen,

    uint _commitStageLen,

    uint _pCommitStageLen,

    uint _revealStageLen,

    uint _pRevealStageLen,

    uint _dispensationPct,

    uint _pDispensationPct,

    uint _voteQuorum,

    uint _pVoteQuorum,

    bytes4 _newRegistryIface

    ) Ownable() public {

      token = EIP20Interface(_tokenAddr);

      voting = PLCRVoting(_plcrAddr);

      REGISTRY_INTERFACE_REQUIREMENT = _newRegistryIface;



      set("minDeposit", _minDeposit);

      set("pMinDeposit", _pMinDeposit);

      set("applyStageLen", _applyStageLen);

      set("pApplyStageLen", _pApplyStageLen);

      set("commitStageLen", _commitStageLen);

      set("pCommitStageLen", _pCommitStageLen);

      set("revealStageLen", _revealStageLen);

      set("pRevealStageLen", _pRevealStageLen);

      set("dispensationPct", _dispensationPct);

      set("pDispensationPct", _pDispensationPct);

      set("voteQuorum", _voteQuorum);

      set("pVoteQuorum", _pVoteQuorum);

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

    bytes32 propID = keccak256(abi.encodePacked(_name, _value));

    bytes32 _nameKec = keccak256(abi.encodePacked(_name));



    if (_nameKec == DISPENSATION_PCT_KEC ||

       _nameKec == P_DISPENSATION_PCT_KEC) {

        require(_value <= 100);

    }



    if(keccak256(abi.encodePacked(_name)) == NEW_REGISTRY_KEC) {

      require(getNewRegistry() == address(0));

      require(_value != 0);

      require(msg.sender == owner);

      require((_value & 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff) == _value); // i.e., _value is zero-padded address

      require(this.doesContractImplementInterface(address(_value), REGISTRY_INTERFACE_REQUIREMENT));

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



    emit _ReparameterizationProposal(_name, _value, propID, deposit, proposals[propID].appExpiry);

    return propID;

  }



  /**

  @notice gets the address of the new registry, if set.

  */

  function getNewRegistry() public view returns (address) {

    //return address(get(NEW_REGISTRY));

    return address(params[NEW_REGISTRY_KEC]); // bit of an optimization

  }



  /**

  @notice challenge the provided proposal ID, and put tokens at stake to do so.

  @param _propID the proposal ID to challenge

  */

  function challengeReparameterization(bytes32 _propID) public returns (uint) {

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



    (uint commitEndDate, uint revealEndDate,,,) = voting.pollMap(pollID);



    emit _NewChallenge(_propID, pollID, commitEndDate, revealEndDate);

    return pollID;

  }



  /**

  @notice for the provided proposal ID, set it, resolve its challenge, or delete it depending on whether it can be set, has a challenge which can be resolved, or if its "process by" date has passed

  @param _propID the proposal ID to make a determination and state transition for

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

  @notice claim the tokens owed for the msg.sender in the provided challenge

  @param _challengeID the challenge ID to claim tokens for

  @param _salt the salt used to vote in the challenge being withdrawn for

  */

  function claimReward(uint _challengeID, uint _salt) public {

    // ensure voter has not already claimed tokens and challenge results have been processed

    require(challenges[_challengeID].tokenClaims[msg.sender] == false);

    require(challenges[_challengeID].resolved == true);



    uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);

    uint reward = voterReward(msg.sender, _challengeID, _salt);



    // subtract voter's information to preserve the participation ratios of other voters

    // compared to the remaining pool of rewards

    challenges[_challengeID].winningTokens = challenges[_challengeID].winningTokens.sub(voterTokens);

    challenges[_challengeID].rewardPool = challenges[_challengeID].rewardPool.sub(reward);



    // ensures a voter cannot claim tokens again

    challenges[_challengeID].tokenClaims[msg.sender] = true;



    emit _RewardClaimed(_challengeID, reward);

    require(token.transfer(msg.sender, reward));

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

    return voterTokens.mul(rewardPool).div(winningTokens);

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



    return (prop.challengeID > 0 && challenge.resolved == false &&

            voting.pollEnded(prop.challengeID));

  }



  /**

  @notice Determines the number of tokens to awarded to the winning party in a challenge

  @param _challengeID The challengeID to determine a reward for

  */

  function challengeWinnerReward(uint _challengeID) public view returns (uint) {

    if(voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {

      // Edge case, nobody voted, give all tokens to the challenger.

      return challenges[_challengeID].stake.mul(2);

    }



    return challenges[_challengeID].stake.mul(2).sub(challenges[_challengeID].rewardPool);

  }



  /**

  @notice gets the parameter keyed by the provided name value from the params mapping

  @param _name the key whose value is to be determined

  */

  function get(string _name) public view returns (uint value) {

    return params[keccak256(abi.encodePacked(_name))];

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



    challenge.winningTokens =

      voting.getTotalNumberOfTokensForWinningOption(prop.challengeID);

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

  function set(string _name, uint _value) private {

    params[keccak256(abi.encodePacked(_name))] = _value;

  }

}





contract SupercedesRegistry is ERC165 {

  function canReceiveListing(bytes32 listingHash, uint applicationExpiry, bool whitelisted, address owner, uint unstakedDeposit, uint challengeID) external view returns (bool);

  function receiveListing(bytes32 listingHash, uint applicationExpiry, bool whitelisted, address owner, uint unstakedDeposit, uint challengeID) external;

  function getSupercedesRegistryInterfaceID() public pure returns (bytes4) {

    SupercedesRegistry i;

    return i.canReceiveListing.selector ^ i.receiveListing.selector;

  }

}







contract Registry {



    // ------

    // EVENTS

    // ------



    event _Application(bytes32 indexed listingHash, uint deposit, uint appEndDate, string data);

    event _Challenge(bytes32 indexed listingHash, uint challengeID, uint deposit, string data);

    event _Deposit(bytes32 indexed listingHash, uint added, uint newTotal);

    event _Withdrawal(bytes32 indexed listingHash, uint withdrew, uint newTotal);

    event _ApplicationWhitelisted(bytes32 indexed listingHash);

    event _ApplicationRemoved(bytes32 indexed listingHash);

    event _ListingRemoved(bytes32 indexed listingHash);

    event _ListingWithdrawn(bytes32 indexed listingHash);

    event _TouchAndRemoved(bytes32 indexed listingHash);

    event _ChallengeFailed(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);

    event _ChallengeSucceeded(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);

    event _RewardClaimed(uint indexed challengeID, uint reward, address voter);

    event _ListingMigrated(bytes32 indexed listingHash, address newRegistry);



    using SafeMath for uint;



    struct Listing {

        uint applicationExpiry; // Expiration date of apply stage

        bool whitelisted;       // Indicates registry status

        address owner;          // Owner of Listing

        uint unstakedDeposit;   // Number of tokens in the listing not locked in a challenge

        uint challengeID;       // Corresponds to a PollID in PLCRVoting

    }



    struct Challenge {

        uint rewardPool;        // (remaining) Pool of tokens to be distributed to winning voters

        address challenger;     // Owner of Challenge

        bool resolved;          // Indication of if challenge is resolved

        uint stake;             // Number of tokens at stake for either party during challenge

        uint totalTokens;       // (remaining) Number of tokens used in voting by the winning side

        mapping(address => bool) tokenClaims; // Indicates whether a voter has claimed a reward yet

    }



    // Maps challengeIDs to associated challenge data

    mapping(uint => Challenge) public challenges;



    // Maps listingHashes to associated listingHash data

    mapping(bytes32 => Listing) public listings;



    // Maps number of applications per address

    mapping(address => uint) public numApplications;



    // Maps total amount staked per address

    mapping(address => uint) public totalStaked;



    // Global Variables

    EIP20Interface public token;

    PLCRVoting public voting;

    Parameterizer public parameterizer;

    string public constant version = "1";



    // ------------

    // CONSTRUCTOR:

    // ------------



    /**

    @dev Contructor         Sets the addresses for token, voting, and parameterizer

    @param _tokenAddr       Address of the TCR's intrinsic ERC20 token

    @param _plcrAddr        Address of a PLCR voting contract for the provided token

    @param _paramsAddr      Address of a Parameterizer contract

    */

    constructor(

        address _tokenAddr,

        address _plcrAddr,

        address _paramsAddr

    ) public {

        token = EIP20Interface(_tokenAddr);

        voting = PLCRVoting(_plcrAddr);

        parameterizer = Parameterizer(_paramsAddr);

    }



    // --------------------

    // PUBLISHER INTERFACE:

    // --------------------



    /**

    @dev                Allows a user to start an application. Takes tokens from user and sets

                        apply stage end time.

    @param _listingHash The hash of a potential listing a user is applying to add to the registry

    @param _amount      The number of ERC20 tokens a user is willing to potentially stake

    @param _data        Extra data relevant to the application. Think IPFS hashes.

    */

    function apply(bytes32 _listingHash, uint _amount, string _data) onlyIfCurrentRegistry external {

        require(!isWhitelisted(_listingHash));

        require(!appWasMade(_listingHash));

        require(_amount >= parameterizer.get("minDeposit"));



        // Sets owner

        Listing storage listing = listings[_listingHash];

        listing.owner = msg.sender;



        // Sets apply stage end time

        listing.applicationExpiry = block.timestamp.add(parameterizer.get("applyStageLen"));

        listing.unstakedDeposit = _amount;



        // Tally application count per address

        numApplications[listing.owner] = numApplications[listing.owner].add(1);



        // Tally total staked amount

        totalStaked[listing.owner] = totalStaked[listing.owner].add(_amount);



        // Transfers tokens from user to Registry contract

        require(token.transferFrom(listing.owner, this, _amount));

        emit _Application(_listingHash, _amount, listing.applicationExpiry, _data);

    }



    /**

    @dev                Allows the owner of a listingHash to increase their unstaked deposit.

    @param _listingHash A listingHash msg.sender is the owner of

    @param _amount      The number of ERC20 tokens to increase a user's unstaked deposit

    */

    function deposit(bytes32 _listingHash, uint _amount) external {

        Listing storage listing = listings[_listingHash];



        require(listing.owner == msg.sender);



        listing.unstakedDeposit = listing.unstakedDeposit.add(_amount);



        // Update total stake

        totalStaked[listing.owner] = totalStaked[listing.owner].add(_amount);



        require(token.transferFrom(msg.sender, this, _amount));



        emit _Deposit(_listingHash, _amount, listing.unstakedDeposit);

    }



    /**

    @dev                Allows the owner of a listingHash to decrease their unstaked deposit.

    @param _listingHash A listingHash msg.sender is the owner of.

    @param _amount      The number of ERC20 tokens to withdraw from the unstaked deposit.

    */

    function withdraw(bytes32 _listingHash, uint _amount) external {

        Listing storage listing = listings[_listingHash];



        require(listing.owner == msg.sender);

        require(_amount <= listing.unstakedDeposit);

        require(listing.unstakedDeposit.sub(_amount) >= parameterizer.get("minDeposit"));



        listing.unstakedDeposit = listing.unstakedDeposit.sub(_amount);



        require(token.transfer(msg.sender, _amount));



        emit _Withdrawal(_listingHash, _amount, listing.unstakedDeposit);

    }



    /**

    @dev                Allows the owner of a listingHash to remove the listingHash from the whitelist

                        Returns all tokens to the owner of the listingHash

    @param _listingHash A listingHash msg.sender is the owner of.

    */

    function exit(bytes32 _listingHash) external {

        Listing storage listing = listings[_listingHash];



        require(msg.sender == listing.owner);

        require(isWhitelisted(_listingHash));



        // Cannot exit during ongoing challenge

        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved);



        // Remove listingHash & return tokens

        resetListing(_listingHash);

        emit _ListingWithdrawn(_listingHash);

    }



    // -----------------------

    // TOKEN HOLDER INTERFACE:

    // -----------------------



    /**

    @dev                Starts a poll for a listingHash which is either in the apply stage or

                        already in the whitelist. Tokens are taken from the challenger and the

                        applicant's deposits are locked.

    @param _listingHash The listingHash being challenged, whether listed or in application

    @param _deposit     The deposit with which the listing is challenge (used to be `minDeposit`)

    @param _data        Extra data relevant to the challenge. Think IPFS hashes.

    */

    function challenge(bytes32 _listingHash, uint _deposit, string _data) onlyIfCurrentRegistry external returns (uint challengeID) {

        Listing storage listing = listings[_listingHash];

        uint minDeposit = parameterizer.get("minDeposit");



        // Listing must be in apply stage or already on the whitelist

        require(appWasMade(_listingHash) || listing.whitelisted);

        // Prevent multiple challenges

        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved);



        if (listing.unstakedDeposit < minDeposit) {

            // Not enough tokens, listingHash auto-delisted

            resetListing(_listingHash);

            emit _TouchAndRemoved(_listingHash);

            return 0;

        }



        // Starts poll

        uint pollID = voting.startPoll(

            parameterizer.get("voteQuorum"),

            parameterizer.get("commitStageLen"),

            parameterizer.get("revealStageLen")

        );



        challenges[pollID] = Challenge({

            challenger: msg.sender,

            rewardPool: ((100 - parameterizer.get("dispensationPct")) * _deposit) / 100,

            stake: _deposit,

            resolved: false,

            totalTokens: 0

        });



        // Updates listingHash to store most recent challenge

        listing.challengeID = pollID;



        // make sure _deposit is more than minDeposit and smaller than unstaked deposit

        require(_deposit >= minDeposit && _deposit <= listing.unstakedDeposit);



        // Locks tokens for listingHash during challenge

        listing.unstakedDeposit = listing.unstakedDeposit.sub(_deposit);



        // Takes tokens from challenger

        require(token.transferFrom(msg.sender, this, _deposit));



        emit _Challenge(_listingHash, pollID, _deposit, _data);

        return pollID;

    }



    /**

    @dev                Updates a listingHash's status from 'application' to 'listing' or resolves

                        a challenge if one exists.

    @param _listingHash The listingHash whose status is being updated

    */

    function updateStatus(bytes32 _listingHash) public {

        if (canBeWhitelisted(_listingHash)) {

          whitelistApplication(_listingHash);

        } else if (challengeCanBeResolved(_listingHash)) {

          resolveChallenge(_listingHash);

        } else {

          revert();

        }

    }



    // ----------------

    // TOKEN FUNCTIONS:

    // ----------------



    /**

    @dev                Called by a voter to claim their reward for each completed vote. Someone

                        must call updateStatus() before this can be called.

    @param _challengeID The PLCR pollID of the challenge a reward is being claimed for

    @param _salt        The salt of a voter's commit hash in the given poll

    */

    function claimReward(uint _challengeID, uint _salt) public {

        // Ensures the voter has not already claimed tokens and challenge results have been processed

        require(challenges[_challengeID].tokenClaims[msg.sender] == false);

        require(challenges[_challengeID].resolved == true);



        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);

        uint reward = voterReward(msg.sender, _challengeID, _salt);



        // Subtracts the voter's information to preserve the participation ratios

        // of other voters compared to the remaining pool of rewards

        challenges[_challengeID].totalTokens = challenges[_challengeID].totalTokens.sub(voterTokens);

        challenges[_challengeID].rewardPool = challenges[_challengeID].rewardPool.sub(reward);



        // Ensures a voter cannot claim tokens again

        challenges[_challengeID].tokenClaims[msg.sender] = true;



        require(token.transfer(msg.sender, reward));



        emit _RewardClaimed(_challengeID, reward, msg.sender);

    }



    // --------

    // GETTERS:

    // --------



    /**

    @dev                Calculates the provided voter's token reward for the given poll.

    @param _voter       The address of the voter whose reward balance is to be returned

    @param _challengeID The pollID of the challenge a reward balance is being queried for

    @param _salt        The salt of the voter's commit hash in the given poll

    @return             The uint indicating the voter's reward

    */

    function voterReward(address _voter, uint _challengeID, uint _salt)

    public view returns (uint) {

        uint totalTokens = challenges[_challengeID].totalTokens;

        uint rewardPool = challenges[_challengeID].rewardPool;

        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID, _salt);

        return (voterTokens * rewardPool) / totalTokens;

    }



    /**

    @dev                Determines whether the given listingHash can be whitelisted.

    @param _listingHash The listingHash whose status is to be examined

    */

    function canBeWhitelisted(bytes32 _listingHash) view public returns (bool) {

        uint challengeID = listings[_listingHash].challengeID;



        // Ensures that the application was made,

        // the application period has ended,

        // the listingHash can be whitelisted,

        // and either: the challengeID == 0, or the challenge has been resolved.

        if (

            appWasMade(_listingHash) &&

            listings[_listingHash].applicationExpiry < now &&

            !isWhitelisted(_listingHash) &&

            (challengeID == 0 || challenges[challengeID].resolved == true)

        ) {

          return true;

        }



        return false;

    }



    /**

    @dev                Returns true if the provided listingHash is whitelisted

    @param _listingHash The listingHash whose status is to be examined

    */

    function isWhitelisted(bytes32 _listingHash) view public returns (bool whitelisted) {

        return listings[_listingHash].whitelisted;

    }



    /**

    @dev                Returns true if apply was called for this listingHash

    @param _listingHash The listingHash whose status is to be examined

    */

    function appWasMade(bytes32 _listingHash) view public returns (bool exists) {

        return listings[_listingHash].applicationExpiry > 0;

    }



    /**

    @dev                Returns true if the application/listingHash has an unresolved challenge

    @param _listingHash The listingHash whose status is to be examined

    */

    function challengeExists(bytes32 _listingHash) view public returns (bool) {

        uint challengeID = listings[_listingHash].challengeID;



        return (challengeID > 0 && !challenges[challengeID].resolved);

    }



    /**

    @dev                Determines whether voting has concluded in a challenge for a given

                        listingHash. Throws if no challenge exists.

    @param _listingHash A listingHash with an unresolved challenge

    */

    function challengeCanBeResolved(bytes32 _listingHash) view public returns (bool) {

        uint challengeID = listings[_listingHash].challengeID;



        require(challengeExists(_listingHash));



        return voting.pollEnded(challengeID);

    }



    /**

    @dev                Determines the number of tokens awarded to the winning party in a challenge.

    @param _challengeID The challengeID to determine a reward for

    */

    function determineReward(uint _challengeID) public view returns (uint) {

        require(!challenges[_challengeID].resolved && voting.pollEnded(_challengeID));



        // Edge case, nobody voted, give all tokens to the challenger.

        if (voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {

            return challenges[_challengeID].stake.mul(2);

        }



        return (challenges[_challengeID].stake).mul(2).sub(challenges[_challengeID].rewardPool);

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

    // PRIVATE FUNCTIONS:

    // ----------------



    /**

    @dev                Determines the winner in a challenge. Rewards the winner tokens and

                        either whitelists or de-whitelists the listingHash.

    @param _listingHash A listingHash with a challenge that is to be resolved

    */

    function resolveChallenge(bytes32 _listingHash) private {

        uint challengeID = listings[_listingHash].challengeID;



        // Calculates the winner's reward,

        // which is: (winner's full stake) + (dispensationPct * loser's stake)

        uint reward = determineReward(challengeID);



        // Sets flag on challenge being processed

        challenges[challengeID].resolved = true;



        // Stores the total tokens used for voting by the winning side for reward purposes

        challenges[challengeID].totalTokens =

            voting.getTotalNumberOfTokensForWinningOption(challengeID);



        // Case: challenge failed

        if (voting.isPassed(challengeID)) {

            whitelistApplication(_listingHash);

            // Unlock stake so that it can be retrieved by the applicant

            listings[_listingHash].unstakedDeposit = listings[_listingHash].unstakedDeposit.add(reward);



            totalStaked[listings[_listingHash].owner] = totalStaked[listings[_listingHash].owner].add(reward);



            emit _ChallengeFailed(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);

        }

        // Case: challenge succeeded or nobody voted

        else {

            resetListing(_listingHash);

            // Transfer the reward to the challenger

            require(token.transfer(challenges[challengeID].challenger, reward));



            emit _ChallengeSucceeded(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);

        }

    }



    /**

    @dev                Called by updateStatus() if the applicationExpiry date passed without a

                        challenge being made. Called by resolveChallenge() if an

                        application/listing beat a challenge.

    @param _listingHash The listingHash of an application/listingHash to be whitelisted

    */

    function whitelistApplication(bytes32 _listingHash) private {

        if (!listings[_listingHash].whitelisted) {

          emit _ApplicationWhitelisted(_listingHash);

        }

        listings[_listingHash].whitelisted = true;

    }



    /**

    @dev                Deletes a listingHash from the whitelist and transfers tokens back to owner

    @param _listingHash The listing hash to delete

    */

    function resetListing(bytes32 _listingHash) private {

        Listing storage listing = listings[_listingHash];



        // Emit events before deleting listing to check whether is whitelisted

        if (listing.whitelisted) {

            emit _ListingRemoved(_listingHash);

        } else {

            emit _ApplicationRemoved(_listingHash);

        }



        // Deleting listing to prevent reentry

        address owner = listing.owner;

        uint unstakedDeposit = listing.unstakedDeposit;

        delete listings[_listingHash];



        // Transfers any remaining balance back to the owner

        if (unstakedDeposit > 0){

            require(token.transfer(owner, unstakedDeposit));

        }

    }



    /**

    @dev Modifier to specify that a function can only be called if this is the current registry.

    */

    modifier onlyIfCurrentRegistry() {

      require(parameterizer.getNewRegistry() == address(0));

      _;

    }



    /**

    @dev Modifier to specify that a function cannot be called if this is the current registry.

    */

    modifier onlyIfOutdatedRegistry() {

      require(parameterizer.getNewRegistry() != address(0));

      _;

    }



    /**

     @dev Check if a listing exists in the registry by checking that its owner is not zero

          Since all solidity mappings have every key set to zero, we check that the address of the creator isn't zero.

    */

    function listingExists(bytes32 listingHash) public view returns (bool) {

      return listings[listingHash].owner != address(0);

    }



    /**

    @dev migrates a listing

    */

    function migrateListing(bytes32 listingHash) onlyIfOutdatedRegistry public {

      require(listingExists(listingHash)); // duh

      require(!challengeExists(listingHash)); // can't migrate a listing that's challenged



      address newRegistryAddress = parameterizer.getNewRegistry();

      SupercedesRegistry newRegistry = SupercedesRegistry(newRegistryAddress);

      Listing storage listing = listings[listingHash];



      require(newRegistry.canReceiveListing(

        listingHash, listing.applicationExpiry,

        listing.whitelisted, listing.owner,

        listing.unstakedDeposit, listing.challengeID

      ));



      token.approve(newRegistry, listing.unstakedDeposit);

      newRegistry.receiveListing(

        listingHash, listing.applicationExpiry,

        listing.whitelisted, listing.owner,

        listing.unstakedDeposit, listing.challengeID

      );

      delete listings[listingHash];

      emit _ListingMigrated(listingHash, newRegistryAddress);

    }

}
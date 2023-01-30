/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

// File: usingtellor/Interface/ITellor.sol
// File: contracts/IStateSender.sol

/**
The sender address from Ethereum and receiver address deployed in Matic must
be registered in Matic's sender contact on Ethereum
*/
contract IStateSender {
  function syncState(address receiver, bytes calldata data) external;
  function register(address sender, address receiver) public;
}


pragma solidity 0.5.16;

interface ITellor {

    /**
    * @dev Helps initialize a dispute by assigning it a disputeId
    * when a miner returns a false on the validate array(in Tellor.ProofOfWork) it sends the
    * invalidated value information to POS voting
    * @param _requestId being disputed
    * @param _timestamp being disputed
    * @param _minerIndex the index of the miner that submitted the value being disputed. Since each official value
    * requires 5 miners to submit a value.
    */
    function beginDispute(uint256 _requestId, uint256 _timestamp, uint256 _minerIndex) external;
   
    /**
    * @dev Allows token holders to vote
    * @param _disputeId is the dispute id
    * @param _supportsDispute is the vote (true=the dispute has basis false = vote against dispute)
    */
    function vote(uint256 _disputeId, bool _supportsDispute) external;

    /**
    * @dev tallies the votes.
    * @param _disputeId is the dispute id
    */
    function tallyVotes(uint256 _disputeId) external;

    /**
    * @dev Allows for a fork to be proposedx
    * @param _propNewTellorAddress address for new proposed Tellor
    */
    function proposeFork(address _propNewTellorAddress) external;

    /**
    * @dev Add tip to Request value from oracle
    * @param _requestId being requested to be mined
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function addTip(uint256 _requestId, uint256 _tip) external;

    /**
    * @dev This is called by the miner when they submit the PoW solution (proof of work and value)
    * @param _nonce uint submitted by miner
    * @param _requestId the apiId being mined
    * @param _value of api query
    *
    */
    function submitMiningSolution(string calldata _nonce, uint256 _requestId, uint256 _value) external;

    /**
    * @dev This is called by the miner when they submit the PoW solution (proof of work and value)
    * @param _nonce uint submitted by miner
    * @param _requestId is the array of the 5 PSR's being mined
    * @param _value is an array of 5 values
    */
    function submitMiningSolution(string calldata _nonce,uint256[5] calldata _requestId, uint256[5] calldata _value) external;

    /**
    * @dev Allows the current owner to propose transfer control of the contract to a
    * newOwner and the ownership is pending until the new owner calls the claimOwnership
    * function
    * @param _pendingOwner The address to transfer ownership to.
    */
    function proposeOwnership(address payable _pendingOwner) external;

    /**
    * @dev Allows the new owner to claim control of the contract
    */
    function claimOwnership() external;

    /**
    * @dev This function allows miners to deposit their stake.
    */
    function depositStake() external;

    /**
    * @dev This function allows stakers to request to withdraw their stake (no longer stake)
    * once they lock for withdraw(stakes.currentStatus = 2) they are locked for 7 days before they
    * can withdraw the stake
    */
    function requestStakingWithdraw() external;

    /**
    * @dev This function allows users to withdraw their stake after a 7 day waiting period from request
    */
    function withdrawStake() external;

    /**
    * @dev This function approves a _spender an _amount of tokens to use
    * @param _spender address
    * @param _amount amount the spender is being approved for
    * @return true if spender appproved successfully
    */
    function approve(address _spender, uint256 _amount) external returns (bool);

    /**
    * @dev Allows for a transfer of tokens to _to
    * @param _to The address to send tokens to
    * @param _amount The amount of tokens to send
    * @return true if transfer is successful
    */
    function transfer(address _to, uint256 _amount) external returns (bool);

    /**
    * @dev Sends _amount tokens to _to from _from on the condition it
    * is approved by _from
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);

    /**
    * @dev Allows users to access the token's name
    */
    function name() external pure returns (string memory);

    /**
    * @dev Allows users to access the token's symbol
    */
    function symbol() external pure returns (string memory);

    /**
    * @dev Allows users to access the number of decimals
    */
    function decimals() external pure returns (uint8);

    /**
    * @dev Getter for the current variables that include the 5 requests Id's
    * @return _challenge _requestIds _difficultky _tip the challenge, 5 requestsId, difficulty and tip
    */
    function getNewCurrentVariables() external view returns(bytes32 _challenge,uint[5] memory _requestIds,uint256 _difficutly, uint256 _tip);

    /**
    * @dev Getter for the top tipped 5 requests Id's
    * @return _requestIds the 5 requestsId
    */
    function getTopRequestIDs() external view returns(uint256[5] memory _requestIds);

    /**
    * @dev Getter for the 5 requests Id's next in line to get mined
    * @return idsOnDeck tipsOnDeck  the 5 requestsId
    */
    function getNewVariablesOnDeck() external view returns (uint256[5] memory idsOnDeck, uint256[5] memory tipsOnDeck);

    /**
    * @dev Updates the Tellor address after a proposed fork has
    * passed the vote and day has gone by without a dispute
    * @param _disputeId the disputeId for the proposed fork
    */
     function updateTellor(uint _disputeId) external;

    /**
    * @dev Allows disputer to unlock the dispute fee
    * @param _disputeId to unlock fee from
    */
    function unlockDisputeFee (uint _disputeId) external;
   
    /**
    * @param _user address
    * @param _spender address
    * @return Returns the remaining allowance of tokens granted to the _spender from the _user
    */
    function allowance(address _user, address _spender) external view returns (uint256);

    /**
    * @dev This function returns whether or not a given user is allowed to trade a given amount
    * @param _user address
    * @param _amount uint of amount
    * @return true if the user is alloed to trade the amount specified
    */
    function allowedToTrade(address _user, uint256 _amount) external view returns (bool);

    /**
    * @dev Gets balance of owner specified
    * @param _user is the owner address used to look up the balance
    * @return Returns the balance associated with the passed in _user
    */
    function balanceOf(address _user) external view returns (uint256);

    /**
    * @dev Queries the balance of _user at a specific _blockNumber
    * @param _user The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at _blockNumber
    */
    function balanceOfAt(address _user, uint256 _blockNumber) external view returns (uint256);

    /**
    * @dev This function tells you if a given challenge has been completed by a given miner
    * @param _challenge the challenge to search for
    * @param _miner address that you want to know if they solved the challenge
    * @return true if the _miner address provided solved the
    */
    function didMine(bytes32 _challenge, address _miner) external view returns (bool);
   
    /**
    * @dev Checks if an address voted in a given dispute
    * @param _disputeId to look up
    * @param _address to look up
    * @return bool of whether or not party voted
    */
    function didVote(uint256 _disputeId, address _address) external view returns (bool);
   
    /**
    * @dev allows Tellor to read data from the addressVars mapping
    * @param _data is the keccak256("variable_name") of the variable that is being accessed.
    * These are examples of how the variables are saved within other functions:
    * addressVars[keccak256("_owner")]
    * addressVars[keccak256("tellorContract")]
    * return address
    */
    function getAddressVars(bytes32 _data) external view returns (address);

    /**
    * @dev Gets all dispute variables
    * @param _disputeId to look up
    * @return bytes32 hash of dispute
    * @return bool executed where true if it has been voted on
    * @return bool disputeVotePassed
    * @return bool isPropFork true if the dispute is a proposed fork
    * @return address of reportedMiner
    * @return address of reportingParty
    * @return address of proposedForkAddress
    *    uint of requestId
    *    uint of timestamp
    *    uint of value
    *    uint of minExecutionDate
    *    uint of numberOfVotes
    *    uint of blocknumber
    *    uint of minerSlot
    *    uint of quorum
    *    uint of fee
    * @return int count of the current tally
    */
    function getAllDisputeVars(uint256 _disputeId)
        external
        view
        returns (bytes32, bool, bool, bool, address, address, address, uint256[9] memory, int256);
   
    /**
    * @dev Getter function for variables for the requestId being currently mined(currentRequestId)
    * @return current challenge, curretnRequestId, level of difficulty, api/query string, and granularity(number of decimals requested), total tip for the request
    */
    function getCurrentVariables() external view returns (bytes32, uint256, uint256, string memory, uint256, uint256);
   
    /**
    * @dev Checks if a given hash of miner,requestId has been disputed
    * @param _hash is the sha256(abi.encodePacked(_miners[2],_requestId));
    * @return uint disputeId
    */
    function getDisputeIdByDisputeHash(bytes32 _hash) external view returns (uint256);
   
    /**
    * @dev Checks for uint variables in the disputeUintVars mapping based on the disuputeId
    * @param _disputeId is the dispute id;
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the disputeUintVars under the Dispute struct
    * @return uint value for the bytes32 data submitted
    */
    function getDisputeUintVars(uint256 _disputeId, bytes32 _data) external view returns (uint256);

    /**
    * @dev Gets the a value for the latest timestamp available
    * @return value for timestamp of last proof of work submited
    * @return true if the is a timestamp for the lastNewValue
    */
    function getLastNewValue() external view returns (uint256, bool);

    /**
    * @dev Gets the a value for the latest timestamp available
    * @param _requestId being requested
    * @return value for timestamp of last proof of work submited and if true if it exist or 0 and false if it doesn't
    */
    function getLastNewValueById(uint256 _requestId) external view returns (uint256, bool);

    /**
    * @dev Gets blocknumber for mined timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up blocknumber
    * @return uint of the blocknumber which the dispute was mined
    */
    function getMinedBlockNum(uint256 _requestId, uint256 _timestamp) external view returns (uint256);

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return the 5 miners' addresses
    */
    function getMinersByRequestIdAndTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (address[5] memory);

    /**
    * @dev Counts the number of values that have been submited for the request
    * if called for the currentRequest being mined it can tell you how many miners have submitted a value for that
    * request so far
    * @param _requestId the requestId to look up
    * @return uint count of the number of values received for the requestId
    */
    function getNewValueCountbyRequestId(uint256 _requestId) external view returns (uint256);

    /**
    * @dev Getter function for the specified requestQ index
    * @param _index to look up in the requestQ array
    * @return uint of reqeuestId
    */
    function getRequestIdByRequestQIndex(uint256 _index) external view returns (uint256);

    /**
    * @dev Getter function for requestId based on timestamp
    * @param _timestamp to check requestId
    * @return uint of reqeuestId
    */
    function getRequestIdByTimestamp(uint256 _timestamp) external view returns (uint256);

    /**
    * @dev Getter function for requestId based on the queryHash
    * @param _request is the hash(of string api and granularity) to check if a request already exists
    * @return uint requestId
    */
    function getRequestIdByQueryHash(bytes32 _request) external view returns (uint256);

    /**
    * @dev Getter function for the requestQ array
    * @return the requestQ arrray
    */
    function getRequestQ() external view returns (uint256[51] memory);

    /**
    * @dev Allowes access to the uint variables saved in the apiUintVars under the requestDetails struct
    * for the requestId specified
    * @param _requestId to look up
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the apiUintVars under the requestDetails struct
    * @return uint value of the apiUintVars specified in _data for the requestId specified
    */
    function getRequestUintVars(uint256 _requestId, bytes32 _data) external view returns (uint256);

    /**
    * @dev Gets the API struct variables that are not mappings
    * @param _requestId to look up
    * @return string of api to query
    * @return string of symbol of api to query
    * @return bytes32 hash of string
    * @return bytes32 of the granularity(decimal places) requested
    * @return uint of index in requestQ array
    * @return uint of current payout/tip for this requestId
    */
    function getRequestVars(uint256 _requestId) external view returns (string memory, string memory, bytes32, uint256, uint256, uint256);

    /**
    * @dev This function allows users to retireve all information about a staker
    * @param _staker address of staker inquiring about
    * @return uint current state of staker
    * @return uint startDate of staking
    */
    function getStakerInfo(address _staker) external view returns (uint256, uint256);

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestampt to look up miners for
    * @return address[5] array of 5 addresses ofminers that mined the requestId
    */
    function getSubmissionsByTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (uint256[5] memory);

    /**
    * @dev Gets the timestamp for the value based on their index
    * @param _requestID is the requestId to look up
    * @param _index is the value index to look up
    * @return uint timestamp
    */
    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index) external view returns (uint256);

    /**
    * @dev Getter for the variables saved under the TellorStorageStruct uintVars variable
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the uintVars under the TellorStorageStruct struct
    * This is an example of how data is saved into the mapping within other functions:
    * self.uintVars[keccak256("stakerCount")]
    * @return uint of specified variable
    */
    function getUintVar(bytes32 _data) external view returns (uint256);

    /**
    * @dev Getter function for next requestId on queue/request with highest payout at time the function is called
    * @return onDeck/info on request with highest payout-- RequestId, Totaltips, and API query string
    */
    function getVariablesOnDeck() external view returns (uint256, uint256, string memory);

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return bool true if requestId/timestamp is under dispute
    */
    function isInDispute(uint256 _requestId, uint256 _timestamp) external view returns (bool);

    /**
    * @dev Retreive value from oracle based on timestamp
    * @param _requestId being requested
    * @param _timestamp to retreive data/value from
    * @return value for timestamp submitted
    */
    function retrieveData(uint256 _requestId, uint256 _timestamp) external view returns (uint256);

    /**
    * @dev Getter for the total_supply of oracle tokens
    * @return uint total supply
    */
    function totalSupply() external view returns (uint256);
}

// File: usingtellor/contracts/UsingTellor.sol



/**
* @title UserContract
* This contracts creates for easy integration to the Tellor System
* by allowing smart contracts to read data off Tellor
*/
contract UsingTellor{
    ITellor tellor;
    /*Constructor*/
    /**
    * @dev the constructor sets the storage address and owner
    * @param _tellor is the TellorMaster address
    */
    constructor(address payable _tellor) public {
        tellor = ITellor(_tellor);
    }

     /**
    * @dev Retreive value from oracle based on requestId/timestamp
    * @param _requestId being requested
    * @param _timestamp to retreive data/value from
    * @return uint value for requestId/timestamp submitted
    */
    function retrieveData(uint256 _requestId, uint256 _timestamp) public view returns(uint256){
        return tellor.retrieveData(_requestId,_timestamp);
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to looku p
    * @param _timestamp is the timestamp to look up miners for
    * @return bool true if requestId/timestamp is under dispute
    */
    function isInDispute(uint256 _requestId, uint256 _timestamp) public view returns(bool){
        return tellor.isInDispute(_requestId, _timestamp);
    }

    /**
    * @dev Counts the number of values that have been submited for the request
    * @param _requestId the requestId to look up
    * @return uint count of the number of values received for the requestId
    */
    function getNewValueCountbyRequestId(uint256 _requestId) public view returns(uint) {
        return tellor.getNewValueCountbyRequestId(_requestId);
    }

    /**
    * @dev Gets the timestamp for the value based on their index
    * @param _requestId is the requestId to look up
    * @param _index is the value index to look up
    * @return uint timestamp
    */
    function getTimestampbyRequestIDandIndex(uint256 _requestId, uint256 _index) public view returns(uint256) {
        return tellor.getTimestampbyRequestIDandIndex( _requestId,_index);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified
    * @param _requestId is the requestId to look up the value for
    * @return ifRetrieve bool true if it is able to retreive a value, the value, and the value's timestamp
    * @return value the value retrieved
    * @return _timestampRetrieved the value's timestamp
    */
    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {
        uint256 _count = tellor.getNewValueCountbyRequestId(_requestId);
        uint _time = tellor.getTimestampbyRequestIDandIndex(_requestId, _count - 1);
        uint _value = tellor.retrieveData(_requestId, _time);
        if(_value > 0) return (true, _value, _time);
        return (false, 0 , _time);
    }
   
    function getIndexForDataBefore(uint _requestId, uint256 _timestamp) public view returns (bool found, uint256 index){
        uint256 _count = tellor.getNewValueCountbyRequestId(_requestId);  
        if (_count > 0) {
            uint middle;
            uint start = 0;
            uint end = _count - 1;
            uint _time;

            //Checking Boundaries to short-circuit the algorithm
            _time = tellor.getTimestampbyRequestIDandIndex(_requestId, start);
            if(_time >= _timestamp) return (false, 0);
            _time = tellor.getTimestampbyRequestIDandIndex(_requestId, end);
            if(_time < _timestamp) return (true, end);

            //Since the value is within our boundaries, do a binary search
            while(true) {
                middle = (end - start) / 2 + 1 + start;
                _time = tellor.getTimestampbyRequestIDandIndex(_requestId, middle);
                if(_time < _timestamp){
                    //get imeadiate next value
                    uint _nextTime = tellor.getTimestampbyRequestIDandIndex(_requestId, middle + 1);
                    if(_nextTime >= _timestamp){
                        //_time is correct
                        return (true, middle);
                    } else  {
                        //look from middle + 1(next value) to end
                        start = middle + 1;
                    }
                } else {
                    uint _prevTime = tellor.getTimestampbyRequestIDandIndex(_requestId, middle - 1);
                    if(_prevTime < _timestamp){
                        // _prevtime is correct
                        return(true, middle - 1);
                    } else {
                        //look from start to middle -1(prev value)
                        end = middle -1;
                    }
                }
                //We couldn't found a value
                //if(middle - 1 == start || middle == _count) return (false, 0);
            }
        }
        return (false, 0);
    }


    /**
    * @dev Allows the user to get the first value for the requestId before the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp before which to search for first verified value
    * @return _ifRetrieve bool true if it is able to retreive a value, the value, and the value's timestamp
    * @return _value the value retrieved
    * @return _timestampRetrieved the value's timestamp
    */
    function getDataBefore(uint256 _requestId, uint256 _timestamp)
        public
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {
       
        (bool _found, uint _index) = getIndexForDataBefore(_requestId,_timestamp);
        if(!_found) return (false, 0, 0);
        uint256 _time = tellor.getTimestampbyRequestIDandIndex(_requestId, _index);
        _value = tellor.retrieveData(_requestId, _time);
        //If value is diputed it'll return zero
        if (_value > 0) return (true, _value, _time);
        return (false, 0, 0);
    }
}


// File: contracts/TellorSender.sol

pragma solidity ^0.5.11;




/**
@title Sender
This contract helps send Tellor's data on Ethereum to Matic's Network
*/
contract TellorSender is UsingTellor {
    IStateSender public stateSender;
    event DataSent(uint _requestId, uint _timestamp, uint _value, address _sender);    
    address public receiver;

    /**
    @dev
    @param _tellorAddress is the tellor master address
    @param _stateSender is the Matic's state sender address --- they need to add the sender and receiver address
    @param _receiver is the contract receiver address in Matic
    */
    constructor(address payable _tellorAddress, address _stateSender, address _receiver) UsingTellor(_tellorAddress) public {
      stateSender = IStateSender(_stateSender);
      receiver = _receiver;
    }

    /**
    @dev This function gets the value for the specified request Id and timestamp from UsingTellor
    @param _requestId is Tellor's requestId to retreive
    @param _timestamp is Tellor's requestId timestamp to retreive
    */
    function retrieveDataAndSend(uint256 _requestId, uint256 _timestamp) public {
        uint256 value = retrieveData(_requestId, _timestamp);
        require(value > 0);
        stateSender.syncState(receiver, abi.encode(_requestId, _timestamp, value, msg.sender));
        emit DataSent(_requestId, _timestamp, value, msg.sender);
    }

    /**
    @dev This function gets the current value for the specified request Id from UsingTellor
    @param _requestId is Tellor's requestId to retreive the latest curent value for it
    */
    function getCurrentValueAndSend(uint256 _requestId) public {
      (bool ifRetrieve, uint256 value, uint256 timestamp) = getCurrentValue(_requestId);
      require(ifRetrieve);
      stateSender.syncState(receiver, abi.encode(_requestId, timestamp, value, msg.sender));
      emit DataSent(_requestId, timestamp, value, msg.sender);
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity >=0.4.21;

pragma solidity ^0.5.0;

/**
* @title Tellor Getters
* @dev Oracle contract with all tellor getter functions. The logic for the functions on this contract
* is saved on the TellorGettersLibrary, TellorTransfer, TellorGettersLibrary, and TellorStake
*/
contract TellorGetters {
    using SafeMath for uint256;

    using TellorTransfer for TellorStorage.TellorStorageStruct;
    using TellorGettersLibrary for TellorStorage.TellorStorageStruct;
    using TellorStake for TellorStorage.TellorStorageStruct;

    TellorStorage.TellorStorageStruct tellor;

    /**
    * @param _user address
    * @param _spender address
    * @return Returns the remaining allowance of tokens granted to the _spender from the _user
    */
    function allowance(address _user, address _spender) external view returns (uint256) {
        return tellor.allowance(_user, _spender);
    }

    /**
    * @dev This function returns whether or not a given user is allowed to trade a given amount
    * @param _user address
    * @param _amount uint of amount
    * @return true if the user is alloed to trade the amount specified
    */
    function allowedToTrade(address _user, uint256 _amount) external view returns (bool) {
        return tellor.allowedToTrade(_user, _amount);
    }

    /**
    * @dev Gets balance of owner specified
    * @param _user is the owner address used to look up the balance
    * @return Returns the balance associated with the passed in _user
    */
    function balanceOf(address _user) external view returns (uint256) {
        return tellor.balanceOf(_user);
    }

    /**
    * @dev Queries the balance of _user at a specific _blockNumber
    * @param _user The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at _blockNumber
    */
    function balanceOfAt(address _user, uint256 _blockNumber) external view returns (uint256) {
        return tellor.balanceOfAt(_user, _blockNumber);
    }

    /**
    * @dev This function tells you if a given challenge has been completed by a given miner
    * @param _challenge the challenge to search for
    * @param _miner address that you want to know if they solved the challenge
    * @return true if the _miner address provided solved the
    */
    function didMine(bytes32 _challenge, address _miner) external view returns (bool) {
        return tellor.didMine(_challenge, _miner);
    }

    /**
    * @dev Checks if an address voted in a given dispute
    * @param _disputeId to look up
    * @param _address to look up
    * @return bool of whether or not party voted
    */
    function didVote(uint256 _disputeId, address _address) external view returns (bool) {
        return tellor.didVote(_disputeId, _address);
    }

    /**
    * @dev allows Tellor to read data from the addressVars mapping
    * @param _data is the keccak256("variable_name") of the variable that is being accessed.
    * These are examples of how the variables are saved within other functions:
    * addressVars[keccak256("_owner")]
    * addressVars[keccak256("tellorContract")]
    */
    function getAddressVars(bytes32 _data) external view returns (address) {
        return tellor.getAddressVars(_data);
    }

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
    * @return uint of requestId
    * @return uint of timestamp
    * @return uint of value
    * @return uint of minExecutionDate
    * @return uint of numberOfVotes
    * @return uint of blocknumber
    * @return uint of minerSlot
    * @return uint of quorum
    * @return uint of fee
    * @return int count of the current tally
    */
    function getAllDisputeVars(uint256 _disputeId)
        public
        view
        returns (bytes32, bool, bool, bool, address, address, address, uint256[9] memory, int256)
    {
        return tellor.getAllDisputeVars(_disputeId);
    }

    /**
    * @dev Getter function for variables for the requestId being currently mined(currentRequestId)
    * @return current challenge, curretnRequestId, level of difficulty, api/query string, and granularity(number of decimals requested), total tip for the request
    */
    function getCurrentVariables() external view returns (bytes32, uint256, uint256, string memory, uint256, uint256) {
        return tellor.getCurrentVariables();
    }

    /**
    * @dev Checks if a given hash of miner,requestId has been disputed
    * @param _hash is the sha256(abi.encodePacked(_miners[2],_requestId));
    * @return uint disputeId
    */
    function getDisputeIdByDisputeHash(bytes32 _hash) external view returns (uint256) {
        return tellor.getDisputeIdByDisputeHash(_hash);
    }

    /**
    * @dev Checks for uint variables in the disputeUintVars mapping based on the disuputeId
    * @param _disputeId is the dispute id;
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the disputeUintVars under the Dispute struct
    * @return uint value for the bytes32 data submitted
    */
    function getDisputeUintVars(uint256 _disputeId, bytes32 _data) external view returns (uint256) {
        return tellor.getDisputeUintVars(_disputeId, _data);
    }

    /**
    * @dev Gets the a value for the latest timestamp available
    * @return value for timestamp of last proof of work submited
    * @return true if the is a timestamp for the lastNewValue
    */
    function getLastNewValue() external view returns (uint256, bool) {
        return tellor.getLastNewValue();
    }

    /**
    * @dev Gets the a value for the latest timestamp available
    * @param _requestId being requested
    * @return value for timestamp of last proof of work submited and if true if it exist or 0 and false if it doesn't
    */
    function getLastNewValueById(uint256 _requestId) external view returns (uint256, bool) {
        return tellor.getLastNewValueById(_requestId);
    }

    /**
    * @dev Gets blocknumber for mined timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up blocknumber
    * @return uint of the blocknumber which the dispute was mined
    */
    function getMinedBlockNum(uint256 _requestId, uint256 _timestamp) external view returns (uint256) {
        return tellor.getMinedBlockNum(_requestId, _timestamp);
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return the 5 miners' addresses
    */
    function getMinersByRequestIdAndTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (address[5] memory) {
        return tellor.getMinersByRequestIdAndTimestamp(_requestId, _timestamp);
    }

    /**
    * @dev Get the name of the token
    * return string of the token name
    */
/*    function getName() external view returns (string memory) {
        return tellor.getName();
    }
*/
    /**
    * @dev Counts the number of values that have been submited for the request
    * if called for the currentRequest being mined it can tell you how many miners have submitted a value for that
    * request so far
    * @param _requestId the requestId to look up
    * @return uint count of the number of values received for the requestId
    */
    function getNewValueCountbyRequestId(uint256 _requestId) external view returns (uint256) {
        return tellor.getNewValueCountbyRequestId(_requestId);
    }

    /**
    * @dev Getter function for the specified requestQ index
    * @param _index to look up in the requestQ array
    * @return uint of reqeuestId
    */
    function getRequestIdByRequestQIndex(uint256 _index) external view returns (uint256) {
        return tellor.getRequestIdByRequestQIndex(_index);
    }

    /**
    * @dev Getter function for requestId based on timestamp
    * @param _timestamp to check requestId
    * @return uint of reqeuestId
    */
    function getRequestIdByTimestamp(uint256 _timestamp) external view returns (uint256) {
        return tellor.getRequestIdByTimestamp(_timestamp);
    }

    /**
    * @dev Getter function for requestId based on the queryHash
    * @param _request is the hash(of string api and granularity) to check if a request already exists
    * @return uint requestId
    */
    function getRequestIdByQueryHash(bytes32 _request) external view returns (uint256) {
        return tellor.getRequestIdByQueryHash(_request);
    }

    /**
    * @dev Getter function for the requestQ array
    * @return the requestQ arrray
    */
    function getRequestQ() public view returns (uint256[51] memory) {
        return tellor.getRequestQ();
    }

    /**
    * @dev Allowes access to the uint variables saved in the apiUintVars under the requestDetails struct
    * for the requestId specified
    * @param _requestId to look up
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the apiUintVars under the requestDetails struct
    * @return uint value of the apiUintVars specified in _data for the requestId specified
    */
    function getRequestUintVars(uint256 _requestId, bytes32 _data) external view returns (uint256) {
        return tellor.getRequestUintVars(_requestId, _data);
    }

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
    function getRequestVars(uint256 _requestId) external view returns (string memory, string memory, bytes32, uint256, uint256, uint256) {
        return tellor.getRequestVars(_requestId);
    }

    /**
    * @dev This function allows users to retireve all information about a staker
    * @param _staker address of staker inquiring about
    * @return uint current state of staker
    * @return uint startDate of staking
    */
    function getStakerInfo(address _staker) external view returns (uint256, uint256) {
        return tellor.getStakerInfo(_staker);
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestampt to look up miners for
    * @return address[5] array of 5 addresses ofminers that mined the requestId
    */
    function getSubmissionsByTimestamp(uint256 _requestId, uint256 _timestamp) external view returns (uint256[5] memory) {
        return tellor.getSubmissionsByTimestamp(_requestId, _timestamp);
    }

    /**
    * @dev Get the symbol of the token
    * return string of the token symbol
    */
/*    function getSymbol() external view returns (string memory) {
        return tellor.getSymbol();
    }*/

    /**
    * @dev Gets the timestamp for the value based on their index
    * @param _requestID is the requestId to look up
    * @param _index is the value index to look up
    * @return uint timestamp
    */
    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index) external view returns (uint256) {
        return tellor.getTimestampbyRequestIDandIndex(_requestID, _index);
    }

    /**
    * @dev Getter for the variables saved under the TellorStorageStruct uintVars variable
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the uintVars under the TellorStorageStruct struct
    * This is an example of how data is saved into the mapping within other functions:
    * self.uintVars[keccak256("stakerCount")]
    * @return uint of specified variable
    */
    function getUintVar(bytes32 _data) public view returns (uint256) {
        return tellor.getUintVar(_data);
    }

    /**
    * @dev Getter function for next requestId on queue/request with highest payout at time the function is called
    * @return onDeck/info on request with highest payout-- RequestId, Totaltips, and API query string
    */
    function getVariablesOnDeck() external view returns (uint256, uint256, string memory) {
        return tellor.getVariablesOnDeck();
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return bool true if requestId/timestamp is under dispute
    */
    function isInDispute(uint256 _requestId, uint256 _timestamp) external view returns (bool) {
        return tellor.isInDispute(_requestId, _timestamp);
    }

    /**
    * @dev Retreive value from oracle based on timestamp
    * @param _requestId being requested
    * @param _timestamp to retreive data/value from
    * @return value for timestamp submitted
    */
    function retrieveData(uint256 _requestId, uint256 _timestamp) external view returns (uint256) {
        return tellor.retrieveData(_requestId, _timestamp);
    }

    /**
    * @dev Getter for the total_supply of oracle tokens
    * @return uint total supply
    */
    function totalSupply() external view returns (uint256) {
        return tellor.totalSupply();
    }

}


/**
* @title Tellor Master
* @dev This is the Master contract with all tellor getter functions and delegate call to Tellor.
* The logic for the functions on this contract is saved on the TellorGettersLibrary, TellorTransfer,
* TellorGettersLibrary, and TellorStake
*/
contract TellorMaster is TellorGetters {
    event NewTellorAddress(address _newTellor);

    /**
    * @dev The constructor sets the original `tellorStorageOwner` of the contract to the sender
    * account, the tellor contract to the Tellor master address and owner to the Tellor master owner address
    * @param _tellorContract is the address for the tellor contract
    */
    constructor(address _tellorContract) public {
        tellor.init();
        tellor.addressVars[keccak256("_owner")] = msg.sender;
        tellor.addressVars[keccak256("_deity")] = msg.sender;
        tellor.addressVars[keccak256("tellorContract")] = _tellorContract;
        emit NewTellorAddress(_tellorContract);
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @dev Only needs to be in library
    * @param _newDeity the new Deity in the contract
    */

    function changeDeity(address _newDeity) external {
        tellor.changeDeity(_newDeity);
    }

    /**
    * @dev  allows for the deity to make fast upgrades.  Deity should be 0 address if decentralized
    * @param _tellorContract the address of the new Tellor Contract
    */
    function changeTellorContract(address _tellorContract) external {
        tellor.changeTellorContract(_tellorContract);
    }

    /**
    * @dev This is the fallback function that allows contracts to call the tellor contract at the address stored
    */
    function() external payable {
        address addr = tellor.addressVars[keccak256("tellorContract")];
        bytes memory _calldata = msg.data;
        assembly {
            let result := delegatecall(not(0), addr, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
            // if the call returned error data, forward it
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
}



/**
* @title Tellor Transfer
* @dev Contais the methods related to transfers and ERC20. Tellor.sol and TellorGetters.sol
* reference this library for function's logic.
*/
library TellorTransfer {
    using SafeMath for uint256;

    event Approval(address indexed _owner, address indexed _spender, uint256 _value); //ERC20 Approval event
    event Transfer(address indexed _from, address indexed _to, uint256 _value); //ERC20 Transfer Event

    /*Functions*/

    /**
    * @dev Allows for a transfer of tokens to _to
    * @param _to The address to send tokens to
    * @param _amount The amount of tokens to send
    * @return true if transfer is successful
    */
    function transfer(TellorStorage.TellorStorageStruct storage self, address _to, uint256 _amount) public returns (bool success) {
        doTransfer(self, msg.sender, _to, _amount);
        return true;
    }

    /**
    * @notice Send _amount tokens to _to from _from on the condition it
    * is approved by _from
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(TellorStorage.TellorStorageStruct storage self, address _from, address _to, uint256 _amount)
        public
        returns (bool success)
    {
        require(self.allowed[_from][msg.sender] >= _amount, "Allowance is wrong");
        self.allowed[_from][msg.sender] -= _amount;
        doTransfer(self, _from, _to, _amount);
        return true;
    }

    /**
    * @dev This function approves a _spender an _amount of tokens to use
    * @param _spender address
    * @param _amount amount the spender is being approved for
    * @return true if spender appproved successfully
    */
    function approve(TellorStorage.TellorStorageStruct storage self, address _spender, uint256 _amount) public returns (bool) {
        require(_spender != address(0), "Spender is 0-address");
        self.allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
    * @param _user address of party with the balance
    * @param _spender address of spender of parties said balance
    * @return Returns the remaining allowance of tokens granted to the _spender from the _user
    */
    function allowance(TellorStorage.TellorStorageStruct storage self, address _user, address _spender) public view returns (uint256) {
        return self.allowed[_user][_spender];
    }

    /**
    * @dev Completes POWO transfers by updating the balances on the current block number
    * @param _from address to transfer from
    * @param _to addres to transfer to
    * @param _amount to transfer
    */
    function doTransfer(TellorStorage.TellorStorageStruct storage self, address _from, address _to, uint256 _amount) public {
        require(_amount > 0, "Tried to send non-positive amount");
        require(_to != address(0), "Receiver is 0 address");
        //allowedToTrade checks the stakeAmount is removed from balance if the _user is staked
        require(allowedToTrade(self, _from, _amount), "Stake amount was not removed from balance");
        uint256 previousBalance = balanceOfAt(self, _from, block.number);
        updateBalanceAtNow(self.balances[_from], previousBalance - _amount);
        previousBalance = balanceOfAt(self, _to, block.number);
        require(previousBalance + _amount >= previousBalance, "Overflow happened"); // Check for overflow
        updateBalanceAtNow(self.balances[_to], previousBalance + _amount);
        emit Transfer(_from, _to, _amount);
    }

    /**
    * @dev Gets balance of owner specified
    * @param _user is the owner address used to look up the balance
    * @return Returns the balance associated with the passed in _user
    */
    function balanceOf(TellorStorage.TellorStorageStruct storage self, address _user) public view returns (uint256) {
        return balanceOfAt(self, _user, block.number);
    }

    /**
    * @dev Queries the balance of _user at a specific _blockNumber
    * @param _user The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at _blockNumber specified
    */
    function balanceOfAt(TellorStorage.TellorStorageStruct storage self, address _user, uint256 _blockNumber) public view returns (uint256) {
        if ((self.balances[_user].length == 0) || (self.balances[_user][0].fromBlock > _blockNumber)) {
            return 0;
        } else {
            return getBalanceAt(self.balances[_user], _blockNumber);
        }
    }

    /**
    * @dev Getter for balance for owner on the specified _block number
    * @param checkpoints gets the mapping for the balances[owner]
    * @param _block is the block number to search the balance on
    * @return the balance at the checkpoint
    */
    function getBalanceAt(TellorStorage.Checkpoint[] storage checkpoints, uint256 _block) public view returns (uint256) {
        if (checkpoints.length == 0) return 0;
        if (_block >= checkpoints[checkpoints.length - 1].fromBlock) return checkpoints[checkpoints.length - 1].value;
        if (_block < checkpoints[0].fromBlock) return 0;
        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = checkpoints.length - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min].value;
    }

    /**
    * @dev This function returns whether or not a given user is allowed to trade a given amount
    * and removing the staked amount from their balance if they are staked
    * @param _user address of user
    * @param _amount to check if the user can spend
    * @return true if they are allowed to spend the amount being checked
    */
    function allowedToTrade(TellorStorage.TellorStorageStruct storage self, address _user, uint256 _amount) public view returns (bool) {
        if (self.stakerDetails[_user].currentStatus > 0) {
            //Removes the stakeAmount from balance if the _user is staked
            if (balanceOf(self, _user).sub(self.uintVars[keccak256("stakeAmount")]).sub(_amount) >= 0) {
                return true;
            }
        } else if (balanceOf(self, _user).sub(_amount) >= 0) {
            return true;
        }
        return false;
    }

    /**
    * @dev Updates balance for from and to on the current block number via doTransfer
    * @param checkpoints gets the mapping for the balances[owner]
    * @param _value is the new balance
    */
    function updateBalanceAtNow(TellorStorage.Checkpoint[] storage checkpoints, uint256 _value) public {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            TellorStorage.Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            TellorStorage.Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}


/**
* @title Tellor Dispute
* @dev Contains the methods related to disputes. Tellor.sol references this library for function's logic.
*/

library TellorDispute {
    using SafeMath for uint256;
    using SafeMath for int256;

    //emitted when a new dispute is initialized
    event NewDispute(uint256 indexed _disputeId, uint256 indexed _requestId, uint256 _timestamp, address _miner);
    //emitted when a new vote happens
    event Voted(uint256 indexed _disputeID, bool _position, address indexed _voter);
    //emitted upon dispute tally
    event DisputeVoteTallied(uint256 indexed _disputeID, int256 _result, address indexed _reportedMiner, address _reportingParty, bool _active);
    event NewTellorAddress(address _newTellor); //emmited when a proposed fork is voted true

    /*Functions*/

    /**
    * @dev Helps initialize a dispute by assigning it a disputeId
    * when a miner returns a false on the validate array(in Tellor.ProofOfWork) it sends the
    * invalidated value information to POS voting
    * @param _requestId being disputed
    * @param _timestamp being disputed
    * @param _minerIndex the index of the miner that submitted the value being disputed. Since each official value
    * requires 5 miners to submit a value.
    */
    function beginDispute(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp, uint256 _minerIndex) public {
        TellorStorage.Request storage _request = self.requestDetails[_requestId];
        //require that no more than a day( (24 hours * 60 minutes)/10minutes=144 blocks) has gone by since the value was "mined"
        require(now - _timestamp <= 1 days, "The value was mined more than a day ago");
        require(_request.minedBlockNum[_timestamp] > 0, "Mined block is 0");
        require(_minerIndex < 5, "Miner index is wrong");

        //_miner is the miner being disputed. For every mined value 5 miners are saved in an array and the _minerIndex
        //provided by the party initiating the dispute
        address _miner = _request.minersByValue[_timestamp][_minerIndex];
        bytes32 _hash = keccak256(abi.encodePacked(_miner, _requestId, _timestamp));

        //Ensures that a dispute is not already open for the that miner, requestId and timestamp
        require(self.disputeIdByDisputeHash[_hash] == 0, "Dispute is already open");
        TellorTransfer.doTransfer(self, msg.sender, address(this), self.uintVars[keccak256("disputeFee")]);

        //Increase the dispute count by 1
        self.uintVars[keccak256("disputeCount")] = self.uintVars[keccak256("disputeCount")] + 1;

        //Sets the new disputeCount as the disputeId
        uint256 disputeId = self.uintVars[keccak256("disputeCount")];

        //maps the dispute hash to the disputeId
        self.disputeIdByDisputeHash[_hash] = disputeId;
        //maps the dispute to the Dispute struct
        self.disputesById[disputeId] = TellorStorage.Dispute({
            hash: _hash,
            isPropFork: false,
            reportedMiner: _miner,
            reportingParty: msg.sender,
            proposedForkAddress: address(0),
            executed: false,
            disputeVotePassed: false,
            tally: 0
        });

        //Saves all the dispute variables for the disputeId
        self.disputesById[disputeId].disputeUintVars[keccak256("requestId")] = _requestId;
        self.disputesById[disputeId].disputeUintVars[keccak256("timestamp")] = _timestamp;
        self.disputesById[disputeId].disputeUintVars[keccak256("value")] = _request.valuesByTimestamp[_timestamp][_minerIndex];
        self.disputesById[disputeId].disputeUintVars[keccak256("minExecutionDate")] = now + 7 days;
        self.disputesById[disputeId].disputeUintVars[keccak256("blockNumber")] = block.number;
        self.disputesById[disputeId].disputeUintVars[keccak256("minerSlot")] = _minerIndex;
        self.disputesById[disputeId].disputeUintVars[keccak256("fee")] = self.uintVars[keccak256("disputeFee")];

        //Values are sorted as they come in and the official value is the median of the first five
        //So the "official value" miner is always minerIndex==2. If the official value is being
        //disputed, it sets its status to inDispute(currentStatus = 3) so that users are made aware it is under dispute
        if (_minerIndex == 2) {
            self.requestDetails[_requestId].inDispute[_timestamp] = true;
        }
        self.stakerDetails[_miner].currentStatus = 3;
        emit NewDispute(disputeId, _requestId, _timestamp, _miner);
    }

    /**
    * @dev Allows token holders to vote
    * @param _disputeId is the dispute id
    * @param _supportsDispute is the vote (true=the dispute has basis false = vote against dispute)
    */
    function vote(TellorStorage.TellorStorageStruct storage self, uint256 _disputeId, bool _supportsDispute) public {
        TellorStorage.Dispute storage disp = self.disputesById[_disputeId];

        //Get the voteWeight or the balance of the user at the time/blockNumber the disupte began
        uint256 voteWeight = TellorTransfer.balanceOfAt(self, msg.sender, disp.disputeUintVars[keccak256("blockNumber")]);

        //Require that the msg.sender has not voted
        require(disp.voted[msg.sender] != true, "Sender has already voted");

        //Requre that the user had a balance >0 at time/blockNumber the disupte began
        require(voteWeight > 0, "User balance is 0");

        //ensures miners that are under dispute cannot vote
        require(self.stakerDetails[msg.sender].currentStatus != 3, "Miner is under dispute");

        //Update user voting status to true
        disp.voted[msg.sender] = true;

        //Update the number of votes for the dispute
        disp.disputeUintVars[keccak256("numberOfVotes")] += 1;

        //If the user supports the dispute increase the tally for the dispute by the voteWeight
        //otherwise decrease it
        if (_supportsDispute) {
            disp.tally = disp.tally.add(int256(voteWeight));
        } else {
            disp.tally = disp.tally.sub(int256(voteWeight));
        }

        //Let the network know the user has voted on the dispute and their casted vote
        emit Voted(_disputeId, _supportsDispute, msg.sender);
    }

    /**
    * @dev tallies the votes.
    * @param _disputeId is the dispute id
    */
    function tallyVotes(TellorStorage.TellorStorageStruct storage self, uint256 _disputeId) public {
        TellorStorage.Dispute storage disp = self.disputesById[_disputeId];
        TellorStorage.Request storage _request = self.requestDetails[disp.disputeUintVars[keccak256("requestId")]];

        //Ensure this has not already been executed/tallied
        require(disp.executed == false, "Dispute has been already executed");

        //Ensure the time for voting has elapsed
        require(now > disp.disputeUintVars[keccak256("minExecutionDate")], "Time for voting haven't elapsed");


        //If the vote is not a proposed fork
        if (disp.isPropFork == false) {
            TellorStorage.StakeInfo storage stakes = self.stakerDetails[disp.reportedMiner];
            //If the vote for disputing a value is succesful(disp.tally >0) then unstake the reported
            // miner and transfer the stakeAmount and dispute fee to the reporting party
            if (disp.tally > 0) {

                //if reported miner stake has not been slashed yet, slash them and return the fee to reporting party
                if (stakes.currentStatus == 3) {
                    //Changing the currentStatus and startDate unstakes the reported miner and allows for the
                    //transfer of the stakeAmount
                    stakes.currentStatus = 0;
                    stakes.startDate = now - (now % 86400);
     
                    //Decreases the stakerCount since the miner's stake is being slashed
                    self.uintVars[keccak256("stakerCount")]--;
                    updateDisputeFee(self);
     
                    //Transfers the StakeAmount from the reporded miner to the reporting party
                    TellorTransfer.doTransfer(self, disp.reportedMiner, disp.reportingParty, self.uintVars[keccak256("stakeAmount")]);
     
                    //Returns the dispute fee to the reportingParty
                    TellorTransfer.doTransfer(self, address(this), disp.reportingParty, disp.disputeUintVars[keccak256("fee")]);
                    
                //if reported miner stake was already slashed, return the fee to other reporting paties
                } else{
                    TellorTransfer.doTransfer(self, address(this), disp.reportingParty, disp.disputeUintVars[keccak256("fee")]);
                }

                //Set the dispute state to passed/true
                disp.disputeVotePassed = true;


                //If the dispute was succeful(miner found guilty) then update the timestamp value to zero
                //so that users don't use this datapoint
                if (_request.inDispute[disp.disputeUintVars[keccak256("timestamp")]] == true) {
                    _request.finalValues[disp.disputeUintVars[keccak256("timestamp")]] = 0;
                }
                //If the vote for disputing a value is unsuccesful then update the miner status from being on
                //dispute(currentStatus=3) to staked(currentStatus =1) and tranfer the dispute fee to the miner
            } else {
                //Update the miner's current status to staked(currentStatus = 1)
                stakes.currentStatus = 1;
                //tranfer the dispute fee to the miner
                TellorTransfer.doTransfer(self, address(this), disp.reportedMiner, disp.disputeUintVars[keccak256("fee")]);
                if (_request.inDispute[disp.disputeUintVars[keccak256("timestamp")]] == true) {
                    _request.inDispute[disp.disputeUintVars[keccak256("timestamp")]] = false;
                }
            }
            //If the vote is for a proposed fork require a 10% quorum before executing the update to the new tellor contract address
        } else {
            if (disp.tally > 0 && uint(disp.tally) >= ((self.uintVars[keccak256("total_supply")] * 10) / 100)) {
                self.addressVars[keccak256("tellorContract")] = disp.proposedForkAddress;
                disp.disputeVotePassed = true;
                emit NewTellorAddress(disp.proposedForkAddress);
            }
        }

        //update the dispute status to executed
        disp.executed = true;
        emit DisputeVoteTallied(_disputeId, disp.tally, disp.reportedMiner, disp.reportingParty, disp.disputeVotePassed);
    }

    /**
    * @dev Allows for a fork to be proposed
    * @param _propNewTellorAddress address for new proposed Tellor
    */
    function proposeFork(TellorStorage.TellorStorageStruct storage self, address _propNewTellorAddress) public {
        bytes32 _hash = keccak256(abi.encodePacked(_propNewTellorAddress));
        require(self.disputeIdByDisputeHash[_hash] == 0, "");
        TellorTransfer.doTransfer(self, msg.sender, address(this), self.uintVars[keccak256("disputeFee")]); //This is the fork fee
        self.uintVars[keccak256("disputeCount")]++;
        uint256 disputeId = self.uintVars[keccak256("disputeCount")];
        self.disputeIdByDisputeHash[_hash] = disputeId;
        self.disputesById[disputeId] = TellorStorage.Dispute({
            hash: _hash,
            isPropFork: true,
            reportedMiner: msg.sender,
            reportingParty: msg.sender,
            proposedForkAddress: _propNewTellorAddress,
            executed: false,
            disputeVotePassed: false,
            tally: 0
        });
        self.disputesById[disputeId].disputeUintVars[keccak256("blockNumber")] = block.number;
        self.disputesById[disputeId].disputeUintVars[keccak256("fee")] = self.uintVars[keccak256("disputeFee")];
        self.disputesById[disputeId].disputeUintVars[keccak256("minExecutionDate")] = now + 7 days;
    }

    /**
    * @dev this function allows the dispute fee to fluctuate based on the number of miners on the system.
    * The floor for the fee is 15e18.
    */
    function updateDisputeFee(TellorStorage.TellorStorageStruct storage self) public {
        //if the number of staked miners divided by the target count of staked miners is less than 1
        if ((self.uintVars[keccak256("stakerCount")] * 1000) / self.uintVars[keccak256("targetMiners")] < 1000) {
            //Set the dispute fee at stakeAmt * (1- stakerCount/targetMiners)
            //or at the its minimum of 15e18
            self.uintVars[keccak256("disputeFee")] = SafeMath.max(
                15e18,
                self.uintVars[keccak256("stakeAmount")].mul(
                    1000 - (self.uintVars[keccak256("stakerCount")] * 1000) / self.uintVars[keccak256("targetMiners")]
                ) /
                    1000
            );
        } else {
            //otherwise set the dispute fee at 15e18 (the floor/minimum fee allowed)
            self.uintVars[keccak256("disputeFee")] = 15e18;
        }
    }
}


/**
* itle Tellor Dispute
* @dev Contais the methods related to miners staking and unstaking. Tellor.sol
* references this library for function's logic.
*/

library TellorStake {
    event NewStake(address indexed _sender); //Emits upon new staker
    event StakeWithdrawn(address indexed _sender); //Emits when a staker is now no longer staked
    event StakeWithdrawRequested(address indexed _sender); //Emits when a staker begins the 7 day withdraw period

    /*Functions*/

    /**
    * @dev This function stakes the five initial miners, sets the supply and all the constant variables.
    * This function is called by the constructor function on TellorMaster.sol
    */
    function init(TellorStorage.TellorStorageStruct storage self) public {
        require(self.uintVars[keccak256("decimals")] == 0, "Too many decimals");
        //Give this contract 6000 Tellor Tributes so that it can stake the initial 6 miners
        TellorTransfer.updateBalanceAtNow(self.balances[address(this)], 2**256 - 1 - 6000e18);

        // //the initial 5 miner addresses are specfied below
        // //changed payable[5] to 6
        address payable[6] memory _initalMiners = [
            address(0xE037EC8EC9ec423826750853899394dE7F024fee),
            address(0xcdd8FA31AF8475574B8909F135d510579a8087d3),
            address(0xb9dD5AfD86547Df817DA2d0Fb89334A6F8eDd891),
            address(0x230570cD052f40E14C14a81038c6f3aa685d712B),
            address(0x3233afA02644CCd048587F8ba6e99b3C00A34DcC),
            address(0xe010aC6e0248790e08F42d5F697160DEDf97E024)
        ];
        //Stake each of the 5 miners specified above
        for (uint256 i = 0; i < 6; i++) {
            //6th miner to allow for dispute
            //Miner balance is set at 1000e18 at the block that this function is ran
            TellorTransfer.updateBalanceAtNow(self.balances[_initalMiners[i]], 1000e18);

            newStake(self, _initalMiners[i]);
        }

        //update the total suppply
        self.uintVars[keccak256("total_supply")] += 6000e18; //6th miner to allow for dispute
        //set Constants
        self.uintVars[keccak256("decimals")] = 18;
        self.uintVars[keccak256("targetMiners")] = 200;
        self.uintVars[keccak256("stakeAmount")] = 1000e18;
        self.uintVars[keccak256("disputeFee")] = 970e18;
        self.uintVars[keccak256("timeTarget")] = 600;
        self.uintVars[keccak256("timeOfLastNewValue")] = now - (now % self.uintVars[keccak256("timeTarget")]);
        self.uintVars[keccak256("difficulty")] = 1;
    }

    /**
    * @dev This function allows stakers to request to withdraw their stake (no longer stake)
    * once they lock for withdraw(stakes.currentStatus = 2) they are locked for 7 days before they
    * can withdraw the deposit
    */
    function requestStakingWithdraw(TellorStorage.TellorStorageStruct storage self) public {
        TellorStorage.StakeInfo storage stakes = self.stakerDetails[msg.sender];
        //Require that the miner is staked
        require(stakes.currentStatus == 1, "Miner is not staked");

        //Change the miner staked to locked to be withdrawStake
        stakes.currentStatus = 2;

        //Change the startDate to now since the lock up period begins now
        //and the miner can only withdraw 7 days later from now(check the withdraw function)
        stakes.startDate = now - (now % 86400);

        //Reduce the staker count
        self.uintVars[keccak256("stakerCount")] -= 1;
        TellorDispute.updateDisputeFee(self);
        emit StakeWithdrawRequested(msg.sender);
    }

    /**
    * @dev This function allows users to withdraw their stake after a 7 day waiting period from request
    */
    function withdrawStake(TellorStorage.TellorStorageStruct storage self) public {
        TellorStorage.StakeInfo storage stakes = self.stakerDetails[msg.sender];
        //Require the staker has locked for withdraw(currentStatus ==2) and that 7 days have
        //passed by since they locked for withdraw
        require(now - (now % 86400) - stakes.startDate >= 7 days, "7 days didn't pass");
        require(stakes.currentStatus == 2, "Miner was not locked for withdrawal");
        stakes.currentStatus = 0;
        emit StakeWithdrawn(msg.sender);
    }

    /**
    * @dev This function allows miners to deposit their stake.
    */
    function depositStake(TellorStorage.TellorStorageStruct storage self) public {
        newStake(self, msg.sender);
        //self adjusting disputeFee
        TellorDispute.updateDisputeFee(self);
    }

    /**
    * @dev This function is used by the init function to succesfully stake the initial 5 miners.
    * The function updates their status/state and status start date so they are locked it so they can't withdraw
    * and updates the number of stakers in the system.
    */
    function newStake(TellorStorage.TellorStorageStruct storage self, address staker) internal {
        require(TellorTransfer.balanceOf(self, staker) >= self.uintVars[keccak256("stakeAmount")], "Balance is lower than stake amount");
        //Ensure they can only stake if they are not currrently staked or if their stake time frame has ended
        //and they are currently locked for witdhraw
        require(self.stakerDetails[staker].currentStatus == 0 || self.stakerDetails[staker].currentStatus == 2, "Miner is in the wrong state");
        self.uintVars[keccak256("stakerCount")] += 1;
        self.stakerDetails[staker] = TellorStorage.StakeInfo({
            currentStatus: 1, //this resets their stake start date to today
            startDate: now - (now % 86400)
        });
        emit NewStake(staker);
    }
}



//Slightly modified SafeMath library - includes a min and max function, removes useless div function
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256 c) {
        if (b > 0) {
            c = a + b;
            assert(c >= a);
        } else {
            c = a + b;
            assert(c <= a);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (uint256) {
        return a > b ? uint256(a) : uint256(b);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256 c) {
        if (b > 0) {
            c = a - b;
            assert(c <= a);
        } else {
            c = a - b;
            assert(c >= a);
        }

    }
}

/**
 * @title Tellor Oracle Storage Library
 * @dev Contains all the variables/structs used by Tellor
 */

library TellorStorage {
    //Internal struct for use in proof-of-work submission
    struct Details {
        uint256 value;
        address miner;
    }

    struct Dispute {
        bytes32 hash; //unique hash of dispute: keccak256(_miner,_requestId,_timestamp)
        int256 tally; //current tally of votes for - against measure
        bool executed; //is the dispute settled
        bool disputeVotePassed; //did the vote pass?
        bool isPropFork; //true for fork proposal NEW
        address reportedMiner; //miner who alledgedly submitted the 'bad value' will get disputeFee if dispute vote fails
        address reportingParty; //miner reporting the 'bad value'-pay disputeFee will get reportedMiner's stake if dispute vote passes
        address proposedForkAddress; //new fork address (if fork proposal)
        mapping(bytes32 => uint256) disputeUintVars;
        //Each of the variables below is saved in the mapping disputeUintVars for each disputeID
        //e.g. TellorStorageStruct.DisputeById[disputeID].disputeUintVars[keccak256("requestId")]
        //These are the variables saved in this mapping:
        // uint keccak256("requestId");//apiID of disputed value
        // uint keccak256("timestamp");//timestamp of distputed value
        // uint keccak256("value"); //the value being disputed
        // uint keccak256("minExecutionDate");//7 days from when dispute initialized
        // uint keccak256("numberOfVotes");//the number of parties who have voted on the measure
        // uint keccak256("blockNumber");// the blocknumber for which votes will be calculated from
        // uint keccak256("minerSlot"); //index in dispute array
        // uint keccak256("fee"); //fee paid corresponding to dispute
        mapping(address => bool) voted; //mapping of address to whether or not they voted
    }

    struct StakeInfo {
        uint256 currentStatus; //0-not Staked, 1=Staked, 2=LockedForWithdraw 3= OnDispute
        uint256 startDate; //stake start date
    }

    //Internal struct to allow balances to be queried by blocknumber for voting purposes
    struct Checkpoint {
        uint128 fromBlock; // fromBlock is the block number that the value was generated from
        uint128 value; // value is the amount of tokens at a specific block number
    }

    struct Request {
        string queryString; //id to string api
        string dataSymbol; //short name for api request
        bytes32 queryHash; //hash of api string and granularity e.g. keccak256(abi.encodePacked(_sapi,_granularity))
        uint256[] requestTimestamps; //array of all newValueTimestamps requested
        mapping(bytes32 => uint256) apiUintVars;
        //Each of the variables below is saved in the mapping apiUintVars for each api request
        //e.g. requestDetails[_requestId].apiUintVars[keccak256("totalTip")]
        //These are the variables saved in this mapping:
        // uint keccak256("granularity"); //multiplier for miners
        // uint keccak256("requestQPosition"); //index in requestQ
        // uint keccak256("totalTip");//bonus portion of payout
        mapping(uint256 => uint256) minedBlockNum; //[apiId][minedTimestamp]=>block.number
        //This the time series of finalValues stored by the contract where uint UNIX timestamp is mapped to value
        mapping(uint256 => uint256) finalValues;
        mapping(uint256 => bool) inDispute; //checks if API id is in dispute or finalized.
        mapping(uint256 => address[5]) minersByValue;
        mapping(uint256 => uint256[5]) valuesByTimestamp;
    }

    struct TellorStorageStruct {
        bytes32 currentChallenge; //current challenge to be solved
        uint256[51] requestQ; //uint50 array of the top50 requests by payment amount
        uint256[] newValueTimestamps; //array of all timestamps requested
        Details[5] currentMiners; //This struct is for organizing the five mined values to find the median
        mapping(bytes32 => address) addressVars;
        //Address fields in the Tellor contract are saved the addressVars mapping
        //e.g. addressVars[keccak256("tellorContract")] = address
        //These are the variables saved in this mapping:
        // address keccak256("tellorContract");//Tellor address
        // address  keccak256("_owner");//Tellor Owner address
        // address  keccak256("_deity");//Tellor Owner that can do things at will
        mapping(bytes32 => uint256) uintVars;
        //uint fields in the Tellor contract are saved the uintVars mapping
        //e.g. uintVars[keccak256("decimals")] = uint
        //These are the variables saved in this mapping:
        // keccak256("decimals");    //18 decimal standard ERC20
        // keccak256("disputeFee");//cost to dispute a mined value
        // keccak256("disputeCount");//totalHistoricalDisputes
        // keccak256("total_supply"); //total_supply of the token in circulation
        // keccak256("stakeAmount");//stakeAmount for miners (we can cut gas if we just hardcode it in...or should it be variable?)
        // keccak256("stakerCount"); //number of parties currently staked
        // keccak256("timeOfLastNewValue"); // time of last challenge solved
        // keccak256("difficulty"); // Difficulty of current block
        // keccak256("currentTotalTips"); //value of highest api/timestamp PayoutPool
        // keccak256("currentRequestId"); //API being mined--updates with the ApiOnQ Id
        // keccak256("requestCount"); // total number of requests through the system
        // keccak256("slotProgress");//Number of miners who have mined this value so far
        // keccak256("miningReward");//Mining Reward in PoWo tokens given to all miners per value
        // keccak256("timeTarget"); //The time between blocks (mined Oracle values)
        //This is a boolean that tells you if a given challenge has been completed by a given miner
        mapping(bytes32 => mapping(address => bool)) minersByChallenge;
        mapping(uint256 => uint256) requestIdByTimestamp; //minedTimestamp to apiId
        mapping(uint256 => uint256) requestIdByRequestQIndex; //link from payoutPoolIndex (position in payout pool array) to apiId
        mapping(uint256 => Dispute) disputesById; //disputeId=> Dispute details
        mapping(address => Checkpoint[]) balances; //balances of a party given blocks
        mapping(address => mapping(address => uint256)) allowed; //allowance for a given party and approver
        mapping(address => StakeInfo) stakerDetails; //mapping from a persons address to their staking info
        mapping(uint256 => Request) requestDetails; //mapping of apiID to details
        mapping(bytes32 => uint256) requestIdByQueryHash; // api bytes32 gets an id = to count of requests array
        mapping(bytes32 => uint256) disputeIdByDisputeHash; //maps a hash to an ID for each dispute
    }
}


//Functions for retrieving min and Max in 51 length array (requestQ)
//Taken partly from: https://github.com/modular-network/ethereum-libraries-array-utils/blob/master/contracts/Array256Lib.sol

library Utilities {
    /**
    * @dev Returns the minimum value in an array.
    * The zero position here is ignored. It's because 
    * there's no null in solidity and we map each address 
    * to an index in this array. So when we get 51 parties, 
    * and one person is kicked out of the top 50, we 
    * assign them a 0, and when you get mined and pulled 
    * out of the top 50, also a 0. So then lot's of parties 
    * will have zero as the index so we made the array run 
    * from 1-51 with zero as nothing.
    */
    function getMax(uint256[51] memory data) internal pure returns (uint256 max, uint256 maxIndex) {
        max = data[1];
        maxIndex;
        for (uint256 i = 1; i < data.length; i++) {
            if (data[i] > max) {
                max = data[i];
                maxIndex = i;
            }
        }
    }

    /**
    * @dev Returns the minimum value in an array.
    */
    function getMin(uint256[51] memory data) internal pure returns (uint256 min, uint256 minIndex) {
        minIndex = data.length - 1;
        min = data[minIndex];
        for (uint256 i = data.length - 1; i > 0; i--) {
            if (data[i] < min) {
                min = data[i];
                minIndex = i;
            }
        }
    }

}


/**
* @title Tellor Getters Library
* @dev This is the getter library for all variables in the Tellor Tributes system. TellorGetters references this
* libary for the getters logic
*/
library TellorGettersLibrary {
    using SafeMath for uint256;

    event NewTellorAddress(address _newTellor); //emmited when a proposed fork is voted true

    /*Functions*/

    //The next two functions are onlyOwner functions.  For Tellor to be truly decentralized, we will need to transfer the Deity to the 0 address.
    //Only needs to be in library
    /**
    * @dev This function allows us to set a new Deity (or remove it)
    * @param _newDeity address of the new Deity of the tellor system
    */
    function changeDeity(TellorStorage.TellorStorageStruct storage self, address _newDeity) internal {
        require(self.addressVars[keccak256("_deity")] == msg.sender, "Sender is not deity");
        self.addressVars[keccak256("_deity")] = _newDeity;
    }

    //Only needs to be in library
    /**
    * @dev This function allows the deity to upgrade the Tellor System
    * @param _tellorContract address of new updated TellorCore contract
    */
    function changeTellorContract(TellorStorage.TellorStorageStruct storage self, address _tellorContract) internal {
        require(self.addressVars[keccak256("_deity")] == msg.sender, "Sender is not deity");
        self.addressVars[keccak256("tellorContract")] = _tellorContract;
        emit NewTellorAddress(_tellorContract);
    }

    /*Tellor Getters*/

    /**
    * @dev This function tells you if a given challenge has been completed by a given miner
    * @param _challenge the challenge to search for
    * @param _miner address that you want to know if they solved the challenge
    * @return true if the _miner address provided solved the
    */
    function didMine(TellorStorage.TellorStorageStruct storage self, bytes32 _challenge, address _miner) internal view returns (bool) {
        return self.minersByChallenge[_challenge][_miner];
    }

    /**
    * @dev Checks if an address voted in a dispute
    * @param _disputeId to look up
    * @param _address of voting party to look up
    * @return bool of whether or not party voted
    */
    function didVote(TellorStorage.TellorStorageStruct storage self, uint256 _disputeId, address _address) internal view returns (bool) {
        return self.disputesById[_disputeId].voted[_address];
    }

    /**
    * @dev allows Tellor to read data from the addressVars mapping
    * @param _data is the keccak256("variable_name") of the variable that is being accessed.
    * These are examples of how the variables are saved within other functions:
    * addressVars[keccak256("_owner")]
    * addressVars[keccak256("tellorContract")]
    */
    function getAddressVars(TellorStorage.TellorStorageStruct storage self, bytes32 _data) internal view returns (address) {
        return self.addressVars[_data];
    }

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
    * @return uint of requestId
    * @return uint of timestamp
    * @return uint of value
    * @return uint of minExecutionDate
    * @return uint of numberOfVotes
    * @return uint of blocknumber
    * @return uint of minerSlot
    * @return uint of quorum
    * @return uint of fee
    * @return int count of the current tally
    */
    function getAllDisputeVars(TellorStorage.TellorStorageStruct storage self, uint256 _disputeId)
        internal
        view
        returns (bytes32, bool, bool, bool, address, address, address, uint256[9] memory, int256)
    {
        TellorStorage.Dispute storage disp = self.disputesById[_disputeId];
        return (
            disp.hash,
            disp.executed,
            disp.disputeVotePassed,
            disp.isPropFork,
            disp.reportedMiner,
            disp.reportingParty,
            disp.proposedForkAddress,
            [
                disp.disputeUintVars[keccak256("requestId")],
                disp.disputeUintVars[keccak256("timestamp")],
                disp.disputeUintVars[keccak256("value")],
                disp.disputeUintVars[keccak256("minExecutionDate")],
                disp.disputeUintVars[keccak256("numberOfVotes")],
                disp.disputeUintVars[keccak256("blockNumber")],
                disp.disputeUintVars[keccak256("minerSlot")],
                disp.disputeUintVars[keccak256("quorum")],
                disp.disputeUintVars[keccak256("fee")]
            ],
            disp.tally
        );
    }

    /**
    * @dev Getter function for variables for the requestId being currently mined(currentRequestId)
    * @return current challenge, curretnRequestId, level of difficulty, api/query string, and granularity(number of decimals requested), total tip for the request
    */
    function getCurrentVariables(TellorStorage.TellorStorageStruct storage self)
        internal
        view
        returns (bytes32, uint256, uint256, string memory, uint256, uint256)
    {
        return (
            self.currentChallenge,
            self.uintVars[keccak256("currentRequestId")],
            self.uintVars[keccak256("difficulty")],
            self.requestDetails[self.uintVars[keccak256("currentRequestId")]].queryString,
            self.requestDetails[self.uintVars[keccak256("currentRequestId")]].apiUintVars[keccak256("granularity")],
            self.requestDetails[self.uintVars[keccak256("currentRequestId")]].apiUintVars[keccak256("totalTip")]
        );
    }

    /**
    * @dev Checks if a given hash of miner,requestId has been disputed
    * @param _hash is the sha256(abi.encodePacked(_miners[2],_requestId));
    * @return uint disputeId
    */
    function getDisputeIdByDisputeHash(TellorStorage.TellorStorageStruct storage self, bytes32 _hash) internal view returns (uint256) {
        return self.disputeIdByDisputeHash[_hash];
    }

    /**
    * @dev Checks for uint variables in the disputeUintVars mapping based on the disuputeId
    * @param _disputeId is the dispute id;
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the disputeUintVars under the Dispute struct
    * @return uint value for the bytes32 data submitted
    */
    function getDisputeUintVars(TellorStorage.TellorStorageStruct storage self, uint256 _disputeId, bytes32 _data)
        internal
        view
        returns (uint256)
    {
        return self.disputesById[_disputeId].disputeUintVars[_data];
    }

    /**
    * @dev Gets the a value for the latest timestamp available
    * @return value for timestamp of last proof of work submited
    * @return true if the is a timestamp for the lastNewValue
    */
    function getLastNewValue(TellorStorage.TellorStorageStruct storage self) internal view returns (uint256, bool) {
        return (
            retrieveData(
                self,
                self.requestIdByTimestamp[self.uintVars[keccak256("timeOfLastNewValue")]],
                self.uintVars[keccak256("timeOfLastNewValue")]
            ),
            true
        );
    }

    /**
    * @dev Gets the a value for the latest timestamp available
    * @param _requestId being requested
    * @return value for timestamp of last proof of work submited and if true if it exist or 0 and false if it doesn't
    */
    function getLastNewValueById(TellorStorage.TellorStorageStruct storage self, uint256 _requestId) internal view returns (uint256, bool) {
        TellorStorage.Request storage _request = self.requestDetails[_requestId];
        if (_request.requestTimestamps.length > 0) {
            return (retrieveData(self, _requestId, _request.requestTimestamps[_request.requestTimestamps.length - 1]), true);
        } else {
            return (0, false);
        }
    }

    /**
    * @dev Gets blocknumber for mined timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up blocknumber
    * @return uint of the blocknumber which the dispute was mined
    */
    function getMinedBlockNum(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp)
        internal
        view
        returns (uint256)
    {
        return self.requestDetails[_requestId].minedBlockNum[_timestamp];
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return the 5 miners' addresses
    */
    function getMinersByRequestIdAndTimestamp(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp)
        internal
        view
        returns (address[5] memory)
    {
        return self.requestDetails[_requestId].minersByValue[_timestamp];
    }

    /**
    * @dev Get the name of the token
    * @return string of the token name
    */
/*    function getName(TellorStorage.TellorStorageStruct storage self) internal pure returns (string memory) {
        return "Tellor Tributes";
    }*/

    /**
    * @dev Counts the number of values that have been submited for the request
    * if called for the currentRequest being mined it can tell you how many miners have submitted a value for that
    * request so far
    * @param _requestId the requestId to look up
    * @return uint count of the number of values received for the requestId
    */
    function getNewValueCountbyRequestId(TellorStorage.TellorStorageStruct storage self, uint256 _requestId) internal view returns (uint256) {
        return self.requestDetails[_requestId].requestTimestamps.length;
    }

    /**
    * @dev Getter function for the specified requestQ index
    * @param _index to look up in the requestQ array
    * @return uint of reqeuestId
    */
    function getRequestIdByRequestQIndex(TellorStorage.TellorStorageStruct storage self, uint256 _index) internal view returns (uint256) {
        require(_index <= 50, "RequestQ index is above 50");
        return self.requestIdByRequestQIndex[_index];
    }

    /**
    * @dev Getter function for requestId based on timestamp
    * @param _timestamp to check requestId
    * @return uint of reqeuestId
    */
    function getRequestIdByTimestamp(TellorStorage.TellorStorageStruct storage self, uint256 _timestamp) internal view returns (uint256) {
        return self.requestIdByTimestamp[_timestamp];
    }

    /**
    * @dev Getter function for requestId based on the qeuaryHash
    * @param _queryHash hash(of string api and granularity) to check if a request already exists
    * @return uint requestId
    */
    function getRequestIdByQueryHash(TellorStorage.TellorStorageStruct storage self, bytes32 _queryHash) internal view returns (uint256) {
        return self.requestIdByQueryHash[_queryHash];
    }

    /**
    * @dev Getter function for the requestQ array
    * @return the requestQ arrray
    */
    function getRequestQ(TellorStorage.TellorStorageStruct storage self) internal view returns (uint256[51] memory) {
        return self.requestQ;
    }

    /**
    * @dev Allowes access to the uint variables saved in the apiUintVars under the requestDetails struct
    * for the requestId specified
    * @param _requestId to look up
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the apiUintVars under the requestDetails struct
    * @return uint value of the apiUintVars specified in _data for the requestId specified
    */
    function getRequestUintVars(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, bytes32 _data)
        internal
        view
        returns (uint256)
    {
        return self.requestDetails[_requestId].apiUintVars[_data];
    }

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
    function getRequestVars(TellorStorage.TellorStorageStruct storage self, uint256 _requestId)
        internal
        view
        returns (string memory, string memory, bytes32, uint256, uint256, uint256)
    {
        TellorStorage.Request storage _request = self.requestDetails[_requestId];
        return (
            _request.queryString,
            _request.dataSymbol,
            _request.queryHash,
            _request.apiUintVars[keccak256("granularity")],
            _request.apiUintVars[keccak256("requestQPosition")],
            _request.apiUintVars[keccak256("totalTip")]
        );
    }

    /**
    * @dev This function allows users to retireve all information about a staker
    * @param _staker address of staker inquiring about
    * @return uint current state of staker
    * @return uint startDate of staking
    */
    function getStakerInfo(TellorStorage.TellorStorageStruct storage self, address _staker) internal view returns (uint256, uint256) {
        return (self.stakerDetails[_staker].currentStatus, self.stakerDetails[_staker].startDate);
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestampt to look up miners for
    * @return address[5] array of 5 addresses ofminers that mined the requestId
    */
    function getSubmissionsByTimestamp(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp)
        internal
        view
        returns (uint256[5] memory)
    {
        return self.requestDetails[_requestId].valuesByTimestamp[_timestamp];
    }

    /**
    * @dev Get the symbol of the token
    * @return string of the token symbol
    */
/*    function getSymbol(TellorStorage.TellorStorageStruct storage self) internal pure returns (string memory) {
        return "TT";
    }*/

    /**
    * @dev Gets the timestamp for the value based on their index
    * @param _requestID is the requestId to look up
    * @param _index is the value index to look up
    * @return uint timestamp
    */
    function getTimestampbyRequestIDandIndex(TellorStorage.TellorStorageStruct storage self, uint256 _requestID, uint256 _index)
        internal
        view
        returns (uint256)
    {
        return self.requestDetails[_requestID].requestTimestamps[_index];
    }

    /**
    * @dev Getter for the variables saved under the TellorStorageStruct uintVars variable
    * @param _data the variable to pull from the mapping. _data = keccak256("variable_name") where variable_name is
    * the variables/strings used to save the data in the mapping. The variables names are
    * commented out under the uintVars under the TellorStorageStruct struct
    * This is an example of how data is saved into the mapping within other functions:
    * self.uintVars[keccak256("stakerCount")]
    * @return uint of specified variable
    */
    function getUintVar(TellorStorage.TellorStorageStruct storage self, bytes32 _data) internal view returns (uint256) {
        return self.uintVars[_data];
    }

    /**
    * @dev Getter function for next requestId on queue/request with highest payout at time the function is called
    * @return onDeck/info on request with highest payout-- RequestId, Totaltips, and API query string
    */
    function getVariablesOnDeck(TellorStorage.TellorStorageStruct storage self) internal view returns (uint256, uint256, string memory) {
        uint256 newRequestId = getTopRequestID(self);
        return (
            newRequestId,
            self.requestDetails[newRequestId].apiUintVars[keccak256("totalTip")],
            self.requestDetails[newRequestId].queryString
        );
    }

    /**
    * @dev Getter function for the request with highest payout. This function is used within the getVariablesOnDeck function
    * @return uint _requestId of request with highest payout at the time the function is called
    */
    function getTopRequestID(TellorStorage.TellorStorageStruct storage self) internal view returns (uint256 _requestId) {
        uint256 _max;
        uint256 _index;
        (_max, _index) = Utilities.getMax(self.requestQ);
        _requestId = self.requestIdByRequestQIndex[_index];
    }

    /**
    * @dev Gets the 5 miners who mined the value for the specified requestId/_timestamp
    * @param _requestId to look up
    * @param _timestamp is the timestamp to look up miners for
    * @return bool true if requestId/timestamp is under dispute
    */
    function isInDispute(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp) internal view returns (bool) {
        return self.requestDetails[_requestId].inDispute[_timestamp];
    }

    /**
    * @dev Retreive value from oracle based on requestId/timestamp
    * @param _requestId being requested
    * @param _timestamp to retreive data/value from
    * @return uint value for requestId/timestamp submitted
    */
    function retrieveData(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _timestamp)
        internal
        view
        returns (uint256)
    {
        return self.requestDetails[_requestId].finalValues[_timestamp];
    }

    /**
    * @dev Getter for the total_supply of oracle tokens
    * @return uint total supply
    */
    function totalSupply(TellorStorage.TellorStorageStruct storage self) internal view returns (uint256) {
        return self.uintVars[keccak256("total_supply")];
    }

}


/**
 * @title Tellor Oracle System Library
 * @dev Contains the functions' logic for the Tellor contract where miners can submit the proof of work
 * along with the value and smart contracts can requestData and tip miners.
 */
library TellorLibrary {
    using SafeMath for uint256;

    event TipAdded(address indexed _sender, uint256 indexed _requestId, uint256 _tip, uint256 _totalTips);
    //Emits upon someone adding value to a pool; msg.sender, amount added, and timestamp incentivized to be mined
    event DataRequested(
        address indexed _sender,
        string _query,
        string _querySymbol,
        uint256 _granularity,
        uint256 indexed _requestId,
        uint256 _totalTips
    );
    //emits when a new challenge is created (either on mined block or when a new request is pushed forward on waiting system)
    event NewChallenge(
        bytes32 _currentChallenge,
        uint256 indexed _currentRequestId,
        uint256 _difficulty,
        uint256 _multiplier,
        string _query,
        uint256 _totalTips
    );
    //emits when a the payout of another request is higher after adding to the payoutPool or submitting a request
    event NewRequestOnDeck(uint256 indexed _requestId, string _query, bytes32 _onDeckQueryHash, uint256 _onDeckTotalTips);
    //Emits upon a successful Mine, indicates the blocktime at point of the mine and the value mined
    event NewValue(uint256 indexed _requestId, uint256 _time, uint256 _value, uint256 _totalTips, bytes32 _currentChallenge);
    //Emits upon each mine (5 total) and shows the miner, nonce, and value submitted
    event NonceSubmitted(address indexed _miner, string _nonce, uint256 indexed _requestId, uint256 _value, bytes32 _currentChallenge);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    event OwnershipProposed(address indexed _previousOwner, address indexed _newOwner);

    /*Functions*/

    /*This is a cheat for demo purposes, will delete upon actual launch*/
/*    function theLazyCoon(TellorStorage.TellorStorageStruct storage self,address _address, uint _amount) public {
        self.uintVars[keccak256("total_supply")] += _amount;
        TellorTransfer.updateBalanceAtNow(self.balances[_address],_amount);
    } */

    /**
    * @dev Add tip to Request value from oracle
    * @param _requestId being requested to be mined
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function addTip(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _tip) public {
        require(_requestId > 0, "RequestId is 0");
        require(_requestId <= self.uintVars[keccak256("requestCount")], "RequestId is not less than count");

        //If the tip > 0 transfer the tip to this contract
        if (_tip > 0) {
            TellorTransfer.doTransfer(self, msg.sender, address(this), _tip);
        }

        //Update the information for the request that should be mined next based on the tip submitted
        updateOnDeck(self, _requestId, _tip);
        emit TipAdded(msg.sender, _requestId, _tip, self.requestDetails[_requestId].apiUintVars[keccak256("totalTip")]);
    }

    /**
    * @dev Request to retreive value from oracle based on timestamp. The tip is not required to be
    * greater than 0 because there are no tokens in circulation for the initial(genesis) request
    * @param _c_sapi string API being requested be mined
    * @param _c_symbol is the short string symbol for the api request
    * @param _granularity is the number of decimals miners should include on the submitted value
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function requestData(
        TellorStorage.TellorStorageStruct storage self,
        string memory _c_sapi,
        string memory _c_symbol,
        uint256 _granularity,
        uint256 _tip
    ) public {
        //Require at least one decimal place
        require(_granularity > 0, "Too few decimal places");

        //But no more than 18 decimal places
        require(_granularity <= 1e18, "Too many decimal places");

        //If it has been requested before then add the tip to it otherwise create the queryHash for it
        string memory _sapi = _c_sapi;
        string memory _symbol = _c_symbol;
        require(bytes(_sapi).length > 0, "API string length is 0");
        require(bytes(_symbol).length < 64, "API string symbol is greater than 64");
        bytes32 _queryHash = keccak256(abi.encodePacked(_sapi, _granularity));

        //If this is the first time the API and granularity combination has been requested then create the API and granularity hash
        //otherwise the tip will be added to the requestId submitted
        if (self.requestIdByQueryHash[_queryHash] == 0) {
            self.uintVars[keccak256("requestCount")]++;
            uint256 _requestId = self.uintVars[keccak256("requestCount")];
            self.requestDetails[_requestId] = TellorStorage.Request({
                queryString: _sapi,
                dataSymbol: _symbol,
                queryHash: _queryHash,
                requestTimestamps: new uint256[](0)
            });
            self.requestDetails[_requestId].apiUintVars[keccak256("granularity")] = _granularity;
            self.requestDetails[_requestId].apiUintVars[keccak256("requestQPosition")] = 0;
            self.requestDetails[_requestId].apiUintVars[keccak256("totalTip")] = 0;
            self.requestIdByQueryHash[_queryHash] = _requestId;

            //If the tip > 0 it tranfers the tip to this contract
            if (_tip > 0) {
                TellorTransfer.doTransfer(self, msg.sender, address(this), _tip);
            }
            updateOnDeck(self, _requestId, _tip);
            emit DataRequested(
                msg.sender,
                self.requestDetails[_requestId].queryString,
                self.requestDetails[_requestId].dataSymbol,
                _granularity,
                _requestId,
                _tip
            );
            //Add tip to existing request id since this is not the first time the api and granularity have been requested
        } else {
            addTip(self, self.requestIdByQueryHash[_queryHash], _tip);
        }
    }

   /**
    * @dev This fucntion is called by submitMiningSolution and adjusts the difficulty, sorts and stores the first
    * 5 values received, pays the miners, the dev share and assigns a new challenge
    * @param _nonce or solution for the PoW  for the requestId
    * @param _requestId for the current request being mined
    */
    function newBlock(TellorStorage.TellorStorageStruct storage self, string memory _nonce, uint256 _requestId) internal {
        TellorStorage.Request storage _request = self.requestDetails[_requestId];

        // If the difference between the timeTarget and how long it takes to solve the challenge this updates the challenge
        //difficulty up or donw by the difference between the target time and how long it took to solve the prevous challenge
        //otherwise it sets it to 1
        int256 _change = int256(SafeMath.min(1200, (now - self.uintVars[keccak256("timeOfLastNewValue")])));
        _change = (int256(self.uintVars[keccak256("difficulty")]) * (int256(self.uintVars[keccak256("timeTarget")]) - _change)) / 4000;

        if (_change < 2 && _change > -2) {
            if (_change >= 0) {
                _change = 1;
            } else {
                _change = -1;
            }
        }

        if ((int256(self.uintVars[keccak256("difficulty")]) + _change) <= 0) {
            self.uintVars[keccak256("difficulty")] = 1;
        } else {
            self.uintVars[keccak256("difficulty")] = uint256(int256(self.uintVars[keccak256("difficulty")]) + _change);
        }

        //Sets time of value submission rounded to 1 minute
        uint256 _timeOfLastNewValue = now - (now % 1 minutes);
        self.uintVars[keccak256("timeOfLastNewValue")] = _timeOfLastNewValue;

        //The sorting algorithm that sorts the values of the first five values that come in
        TellorStorage.Details[5] memory a = self.currentMiners;
        uint256 i;
        for (i = 1; i < 5; i++) {
            uint256 temp = a[i].value;
            address temp2 = a[i].miner;
            uint256 j = i;
            while (j > 0 && temp < a[j - 1].value) {
                a[j].value = a[j - 1].value;
                a[j].miner = a[j - 1].miner;
                j--;
            }
            if (j < i) {
                a[j].value = temp;
                a[j].miner = temp2;
            }
        }

        //Pay the miners 
        //adjust by payout = payout * ratio 0.000030612633181126/1e18  
        //uint _currentReward = self.uintVars[keccak256("currentReward")];   
        if(self.uintVars[keccak256("currentReward")] == 0){
            self.uintVars[keccak256("currentReward")] = 5e18;
        }
        if (self.uintVars[keccak256("currentReward")] > 1e18) {
        self.uintVars[keccak256("currentReward")] = self.uintVars[keccak256("currentReward")] - self.uintVars[keccak256("currentReward")] * 30612633181126/1e18; 
        self.uintVars[keccak256("devShare")] = self.uintVars[keccak256("currentReward")] * 50/100;
        } else {
            self.uintVars[keccak256("currentReward")] = 1e18;
        }
        emit NewValue(
            _requestId,
            _timeOfLastNewValue,
            a[2].value,
            self.uintVars[keccak256("currentTotalTips")] - (self.uintVars[keccak256("currentTotalTips")] % 5),
            self.currentChallenge
        );
        for (i = 0; i < 5; i++) {
            TellorTransfer.doTransfer(self, address(this), a[i].miner, self.uintVars[keccak256("currentReward")]  + self.uintVars[keccak256("currentTotalTips")] / 5);
        }
        //update the total supply
        self.uintVars[keccak256("total_supply")] +=  self.uintVars[keccak256("devShare")] + self.uintVars[keccak256("currentReward")]*5 ;
        //pay the dev-share
        TellorTransfer.doTransfer(self, address(this), self.addressVars[keccak256("_owner")],  self.uintVars[keccak256("devShare")]); //The ten there is the devshare
        //Save the official(finalValue), timestamp of it, 5 miners and their submitted values for it, and its block number
        _request.finalValues[_timeOfLastNewValue] = a[2].value;
        _request.requestTimestamps.push(_timeOfLastNewValue);
        //these are miners by timestamp
        _request.minersByValue[_timeOfLastNewValue] = [a[0].miner, a[1].miner, a[2].miner, a[3].miner, a[4].miner];
        _request.valuesByTimestamp[_timeOfLastNewValue] = [a[0].value, a[1].value, a[2].value, a[3].value, a[4].value];
        _request.minedBlockNum[_timeOfLastNewValue] = block.number;
        //map the timeOfLastValue to the requestId that was just mined
        self.requestIdByTimestamp[_timeOfLastNewValue] = _requestId;
        //add timeOfLastValue to the newValueTimestamps array
        self.newValueTimestamps.push(_timeOfLastNewValue);
        //re-start the count for the slot progress to zero before the new request mining starts
        self.uintVars[keccak256("slotProgress")] = 0;
        uint256 _topId = TellorGettersLibrary.getTopRequestID(self);
        self.uintVars[keccak256("currentRequestId")] = _topId;
        //if the currentRequestId is not zero(currentRequestId exists/something is being mined) select the requestId with the hightest payout
        //else wait for a new tip to mine
        if (_topId > 0) {
            //Update the current request to be mined to the requestID with the highest payout
            self.uintVars[keccak256("currentTotalTips")] = self.requestDetails[_topId].apiUintVars[keccak256("totalTip")];
            //Remove the currentRequestId/onDeckRequestId from the requestQ array containing the rest of the 50 requests
            self.requestQ[self.requestDetails[_topId].apiUintVars[keccak256("requestQPosition")]] = 0;

            //unmap the currentRequestId/onDeckRequestId from the requestIdByRequestQIndex
            self.requestIdByRequestQIndex[self.requestDetails[_topId].apiUintVars[keccak256("requestQPosition")]] = 0;

            //Remove the requestQposition for the currentRequestId/onDeckRequestId since it will be mined next
            self.requestDetails[_topId].apiUintVars[keccak256("requestQPosition")] = 0;

            //Reset the requestId TotalTip to 0 for the currentRequestId/onDeckRequestId since it will be mined next
            //and the tip is going to the current timestamp miners. The tip for the API needs to be reset to zero
            self.requestDetails[_topId].apiUintVars[keccak256("totalTip")] = 0;

            //gets the max tip in the in the requestQ[51] array and its index within the array??
            uint256 newRequestId = TellorGettersLibrary.getTopRequestID(self);
            //Issue the the next challenge
            self.currentChallenge = keccak256(abi.encodePacked(_nonce, self.currentChallenge, blockhash(block.number - 1))); // Save hash for next proof
            emit NewChallenge(
                self.currentChallenge,
                _topId,
                self.uintVars[keccak256("difficulty")],
                self.requestDetails[_topId].apiUintVars[keccak256("granularity")],
                self.requestDetails[_topId].queryString,
                self.uintVars[keccak256("currentTotalTips")]
            );
            emit NewRequestOnDeck(
                newRequestId,
                self.requestDetails[newRequestId].queryString,
                self.requestDetails[newRequestId].queryHash,
                self.requestDetails[newRequestId].apiUintVars[keccak256("totalTip")]
            );
        } else {
            self.uintVars[keccak256("currentTotalTips")] = 0;
            self.currentChallenge = "";
        }
    }

    /**
    * @dev Proof of work is called by the miner when they submit the solution (proof of work and value)
    * @param _nonce uint submitted by miner
    * @param _requestId the apiId being mined
    * @param _value of api query
    */
    function submitMiningSolution(TellorStorage.TellorStorageStruct storage self, string memory _nonce, uint256 _requestId, uint256 _value)
        public
    {
        //require miner is staked
        require(self.stakerDetails[msg.sender].currentStatus == 1, "Miner status is not staker");

        //Check the miner is submitting the pow for the current request Id
        require(_requestId == self.uintVars[keccak256("currentRequestId")], "RequestId is wrong");

        //Saving the challenge information as unique by using the msg.sender
        require(
            uint256(
                sha256(abi.encodePacked(ripemd160(abi.encodePacked(keccak256(abi.encodePacked(self.currentChallenge, msg.sender, _nonce))))))
            ) %
                self.uintVars[keccak256("difficulty")] ==
                0,
            "Incorrect nonce for current challenge"
        );

        //Make sure the miner does not submit a value more than once
        require(self.minersByChallenge[self.currentChallenge][msg.sender] == false, "Miner already submitted the value");

        //Save the miner and value received
        self.currentMiners[self.uintVars[keccak256("slotProgress")]].value = _value;
        self.currentMiners[self.uintVars[keccak256("slotProgress")]].miner = msg.sender;

        //Add to the count how many values have been submitted, since only 5 are taken per request
        self.uintVars[keccak256("slotProgress")]++;

        //Update the miner status to true once they submit a value so they don't submit more than once
        self.minersByChallenge[self.currentChallenge][msg.sender] = true;

        emit NonceSubmitted(msg.sender, _nonce, _requestId, _value, self.currentChallenge);

        //If 5 values have been received, adjust the difficulty otherwise sort the values until 5 are received
        if (self.uintVars[keccak256("slotProgress")] == 5) {
            newBlock(self, _nonce, _requestId);
        }
    }

    /**
    * @dev Allows the current owner to propose transfer control of the contract to a
    * newOwner and the ownership is pending until the new owner calls the claimOwnership
    * function
    * @param _pendingOwner The address to transfer ownership to.
    */
    function proposeOwnership(TellorStorage.TellorStorageStruct storage self, address payable _pendingOwner) internal {
        require(msg.sender == self.addressVars[keccak256("_owner")], "Sender is not owner");
        emit OwnershipProposed(self.addressVars[keccak256("_owner")], _pendingOwner);
        self.addressVars[keccak256("pending_owner")] = _pendingOwner;
    }

    /**
    * @dev Allows the new owner to claim control of the contract
    */
    function claimOwnership(TellorStorage.TellorStorageStruct storage self) internal {
        require(msg.sender == self.addressVars[keccak256("pending_owner")], "Sender is not pending owner");
        emit OwnershipTransferred(self.addressVars[keccak256("_owner")], self.addressVars[keccak256("pending_owner")]);
        self.addressVars[keccak256("_owner")] = self.addressVars[keccak256("pending_owner")];
    }

    /**
    * @dev This function updates APIonQ and the requestQ when requestData or addTip are ran
    * @param _requestId being requested
    * @param _tip is the tip to add
    */
    function updateOnDeck(TellorStorage.TellorStorageStruct storage self, uint256 _requestId, uint256 _tip) internal {
        TellorStorage.Request storage _request = self.requestDetails[_requestId];
        uint256 onDeckRequestId = TellorGettersLibrary.getTopRequestID(self);
        //If the tip >0 update the tip for the requestId
        if (_tip > 0) {
            _request.apiUintVars[keccak256("totalTip")] = _request.apiUintVars[keccak256("totalTip")].add(_tip);
        }
        //Set _payout for the submitted request
        uint256 _payout = _request.apiUintVars[keccak256("totalTip")];

        //If there is no current request being mined
        //then set the currentRequestId to the requestid of the requestData or addtip requestId submitted,
        // the totalTips to the payout/tip submitted, and issue a new mining challenge
        if (self.uintVars[keccak256("currentRequestId")] == 0) {
            _request.apiUintVars[keccak256("totalTip")] = 0;
            self.uintVars[keccak256("currentRequestId")] = _requestId;
            self.uintVars[keccak256("currentTotalTips")] = _payout;
            self.currentChallenge = keccak256(abi.encodePacked(_payout, self.currentChallenge, blockhash(block.number - 1))); // Save hash for next proof
            emit NewChallenge(
                self.currentChallenge,
                self.uintVars[keccak256("currentRequestId")],
                self.uintVars[keccak256("difficulty")],
                self.requestDetails[self.uintVars[keccak256("currentRequestId")]].apiUintVars[keccak256("granularity")],
                self.requestDetails[self.uintVars[keccak256("currentRequestId")]].queryString,
                self.uintVars[keccak256("currentTotalTips")]
            );
        } else {
            //If there is no OnDeckRequestId
            //then replace/add the requestId to be the OnDeckRequestId, queryHash and OnDeckTotalTips(current highest payout, aside from what
            //is being currently mined)
            if (_payout > self.requestDetails[onDeckRequestId].apiUintVars[keccak256("totalTip")] || (onDeckRequestId == 0)) {
                //let everyone know the next on queue has been replaced
                emit NewRequestOnDeck(_requestId, _request.queryString, _request.queryHash, _payout);
            }

            //if the request is not part of the requestQ[51] array
            //then add to the requestQ[51] only if the _payout/tip is greater than the minimum(tip) in the requestQ[51] array
            if (_request.apiUintVars[keccak256("requestQPosition")] == 0) {
                uint256 _min;
                uint256 _index;
                (_min, _index) = Utilities.getMin(self.requestQ);
                //we have to zero out the oldOne
                //if the _payout is greater than the current minimum payout in the requestQ[51] or if the minimum is zero
                //then add it to the requestQ array aand map its index information to the requestId and the apiUintvars
                if (_payout > _min || _min == 0) {
                    self.requestQ[_index] = _payout;
                    self.requestDetails[self.requestIdByRequestQIndex[_index]].apiUintVars[keccak256("requestQPosition")] = 0;
                    self.requestIdByRequestQIndex[_index] = _requestId;
                    _request.apiUintVars[keccak256("requestQPosition")] = _index;
                }
                // else if the requestid is part of the requestQ[51] then update the tip for it
            } else if (_tip > 0) {
                self.requestQ[_request.apiUintVars[keccak256("requestQPosition")]] += _tip;
            }
        }
    }
}


/**
 * @title Tellor Oracle System
 * @dev Oracle contract where miners can submit the proof of work along with the value.
 * The logic for this contract is in TellorLibrary.sol, TellorDispute.sol, TellorStake.sol,
 * and TellorTransfer.sol
 */
contract Tellor {
    using SafeMath for uint256;

    using TellorDispute for TellorStorage.TellorStorageStruct;
    using TellorLibrary for TellorStorage.TellorStorageStruct;
    using TellorStake for TellorStorage.TellorStorageStruct;
    using TellorTransfer for TellorStorage.TellorStorageStruct;

    TellorStorage.TellorStorageStruct tellor;

    /*Functions*/

    /*This is a cheat for demo purposes, will delete upon actual launch*/
/*    function theLazyCoon(address _address, uint _amount) public {
        tellor.theLazyCoon(_address,_amount);
    }*/

    /**
    * @dev Helps initialize a dispute by assigning it a disputeId
    * when a miner returns a false on the validate array(in Tellor.ProofOfWork) it sends the
    * invalidated value information to POS voting
    * @param _requestId being disputed
    * @param _timestamp being disputed
    * @param _minerIndex the index of the miner that submitted the value being disputed. Since each official value
    * requires 5 miners to submit a value.
    */
    function beginDispute(uint256 _requestId, uint256 _timestamp, uint256 _minerIndex) external {
        tellor.beginDispute(_requestId, _timestamp, _minerIndex);
    }

    /**
    * @dev Allows token holders to vote
    * @param _disputeId is the dispute id
    * @param _supportsDispute is the vote (true=the dispute has basis false = vote against dispute)
    */
    function vote(uint256 _disputeId, bool _supportsDispute) external {
        tellor.vote(_disputeId, _supportsDispute);
    }

    /**
    * @dev tallies the votes.
    * @param _disputeId is the dispute id
    */
    function tallyVotes(uint256 _disputeId) external {
        tellor.tallyVotes(_disputeId);
    }

    /**
    * @dev Allows for a fork to be proposed
    * @param _propNewTellorAddress address for new proposed Tellor
    */
    function proposeFork(address _propNewTellorAddress) external {
        tellor.proposeFork(_propNewTellorAddress);
    }

    /**
    * @dev Add tip to Request value from oracle
    * @param _requestId being requested to be mined
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function addTip(uint256 _requestId, uint256 _tip) external {
        tellor.addTip(_requestId, _tip);
    }

    /**
    * @dev Request to retreive value from oracle based on timestamp. The tip is not required to be
    * greater than 0 because there are no tokens in circulation for the initial(genesis) request
    * @param _c_sapi string API being requested be mined
    * @param _c_symbol is the short string symbol for the api request
    * @param _granularity is the number of decimals miners should include on the submitted value
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function requestData(string calldata _c_sapi, string calldata _c_symbol, uint256 _granularity, uint256 _tip) external {
        tellor.requestData(_c_sapi, _c_symbol, _granularity, _tip);
    }

    /**
    * @dev Proof of work is called by the miner when they submit the solution (proof of work and value)
    * @param _nonce uint submitted by miner
    * @param _requestId the apiId being mined
    * @param _value of api query
    */
    function submitMiningSolution(string calldata _nonce, uint256 _requestId, uint256 _value) external {
        tellor.submitMiningSolution(_nonce, _requestId, _value);
    }

    /**
    * @dev Allows the current owner to propose transfer control of the contract to a
    * newOwner and the ownership is pending until the new owner calls the claimOwnership
    * function
    * @param _pendingOwner The address to transfer ownership to.
    */
    function proposeOwnership(address payable _pendingOwner) external {
        tellor.proposeOwnership(_pendingOwner);
    }

    /**
    * @dev Allows the new owner to claim control of the contract
    */
    function claimOwnership() external {
        tellor.claimOwnership();
    }

    /**
    * @dev This function allows miners to deposit their stake.
    */
    function depositStake() external {
        tellor.depositStake();
    }

    /**
    * @dev This function allows stakers to request to withdraw their stake (no longer stake)
    * once they lock for withdraw(stakes.currentStatus = 2) they are locked for 7 days before they
    * can withdraw the stake
    */
    function requestStakingWithdraw() external {
        tellor.requestStakingWithdraw();
    }

    /**
    * @dev This function allows users to withdraw their stake after a 7 day waiting period from request
    */
    function withdrawStake() external {
        tellor.withdrawStake();
    }

    /**
    * @dev This function approves a _spender an _amount of tokens to use
    * @param _spender address
    * @param _amount amount the spender is being approved for
    * @return true if spender appproved successfully
    */
    function approve(address _spender, uint256 _amount) external returns (bool) {
        return tellor.approve(_spender, _amount);
    }

    /**
    * @dev Allows for a transfer of tokens to _to
    * @param _to The address to send tokens to
    * @param _amount The amount of tokens to send
    * @return true if transfer is successful
    */
    function transfer(address _to, uint256 _amount) external returns (bool) {
        return tellor.transfer(_to, _amount);
    }

    /**
    * @dev Sends _amount tokens to _to from _from on the condition it
    * is approved by _from
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        return tellor.transferFrom(_from, _to, _amount);
    }

    /**
    * @dev Allows users to access the token's name
    */
    function name() external pure returns (string memory) {
        return "Tellor Tributes";
    }

    /**
    * @dev Allows users to access the token's symbol
    */
    function symbol() external pure returns (string memory) {
        return "TRB";
    }

    /**
    * @dev Allows users to access the number of decimals
    */
    function decimals() external pure returns (uint8) {
        return 18;
    }

}


/*
 * @title Price/numberic Pull Oracle mapping contract
*/

contract OracleIDDescriptions {

    /*Variables*/
    mapping(uint=>bytes32) tellorIDtoBytesID;
    mapping(bytes32 => uint) bytesIDtoTellorID;
    mapping(uint => int) tellorCodeToStatusCode;
    mapping(int => uint) statusCodeToTellorCode;
    address public owner;

    /*Events*/
    event TellorIdMappedToBytes(uint _requestID, bytes32 _id);
    event StatusMapped(uint _tellorStatus, int _status);
    

    /*Functions*/
    constructor() public{
        owner =msg.sender;
    }

    /**
    * @dev This fucntion allows for ownership transfer
    * @param newOwner is the address for the new owner
    */
    function transferOwnership(address payable newOwner) external {
        require(msg.sender == owner, "Sender is not owner");
        owner = newOwner;
    }

    /**
    * @dev This fuction allows the owner to map the tellor uint data status code to the standarized 
    * ADO int status code such as null, retreived etc...
    * _tellorStatus uint the tellor status
    * _status the data ADO standarized int status
    */
    function defineTellorCodeToStatusCode(uint _tellorStatus, int _status) external{
        require(msg.sender == owner, "Sender is not owner");
        tellorCodeToStatusCode[_tellorStatus] = _status;
        statusCodeToTellorCode[_status] = _tellorStatus;
        emit StatusMapped(_tellorStatus, _status);
    }

    /**
    * @dev Allows owner to map the standarized bytes32 Id to a specific requestID from Tellor
    * The dev should ensure the _requestId exists otherwise request the data on Tellor to get a requestId
    * _requestID is the existing Tellor RequestID 
    * _id is the descption of the ID in bytes 
    */ 
    function defineTellorIdToBytesID(uint _requestID, bytes32 _id) external{
        require(msg.sender == owner, "Sender is not owner");
        tellorIDtoBytesID[_requestID] = _id;
        bytesIDtoTellorID[_id] = _requestID;
        emit TellorIdMappedToBytes(_requestID,_id);
    }

    /**
    * @dev Getter function for the uint Tellor status code from the specified int ADO standarized status code
    * @param _status the int ADO standarized status
    * @return _tellorStatus uint 
    */ 
    function getTellorStatusFromStatus(int _status) public view returns(uint _tellorStatus){
        return statusCodeToTellorCode[_status];
    }

    /**
    * @dev Getter function of the int ADO standarized status code from the specified Tellor uint status
    * @param _tellorStatus uint 
    * @return _status the int ADO standarized status
    */ 
    function getStatusFromTellorStatus (uint _tellorStatus) public view returns(int _status) {
        return tellorCodeToStatusCode[_tellorStatus];
    }
    
    /**
    * @dev Getter function of the Tellor RequestID based on the specified bytes32 ADO standaraized _id
    * @param _id is the bytes32 descriptor mapped to an existing Tellor's requestId
    * @return _requestId is Tellor's requestID corresnpoding to _id
    */ 
    function getTellorIdFromBytes(bytes32 _id) public view  returns(uint _requestId)  {
       return bytesIDtoTellorID[_id];
    }

    /**
    * @dev Getter function of the bytes32 ADO standaraized _id based on the specified Tellor RequestID 
    * @param _requestId is Tellor's requestID
    * @return _id is the bytes32 descriptor mapped to an existing Tellor's requestId
    */ 
    function getBytesFromTellorID(uint _requestId) public view returns(bytes32 _id) {
        return tellorIDtoBytesID[_requestId];
    }

}

/*
@title ADOInterface 
@notice This inteface is the standard interface for price oracles
*/

interface ADOInterface {
        function resultFor(bytes32 Id) view external returns (uint256 timestamp, int256 outcome, int256 status);
}


/**
* @title UserContract
* This contracts creates for easy integration to the Tellor Tellor System
* This contract holds the Ether and Tributes for interacting with the system
* Note it is centralized (we can set the price of Tellor Tributes)
* Once the tellor system is running, this can be set properly.
* Note deploy through centralized 'Tellor Master contract'
*/
contract UserContract is ADOInterface{
    //in Loyas per ETH.  so at 200$ ETH price and 3$ Trib price -- (3/200 * 1e18)
    uint256 public tributePrice;
    address payable public owner;
    address payable public tellorStorageAddress;
    address public oracleIDDescriptionsAddress;
    Tellor _tellor;
    TellorMaster _tellorm;
    OracleIDDescriptions descriptions;

    event OwnershipTransferred(address _previousOwner, address _newOwner);
    event NewPriceSet(uint256 _newPrice);
    event NewDescriptorSet(address _descriptorSet);

    /*Constructor*/
    /**
    * @dev the constructor sets the storage address and owner
    * @param _storage is the TellorMaster address ???
    */
    constructor(address payable _storage) public {
        tellorStorageAddress = _storage;
        _tellor = Tellor(tellorStorageAddress); //we should delcall here
        _tellorm = TellorMaster(tellorStorageAddress);
        owner = msg.sender;
    }

    /**
    * @dev This function allows the owner to update
    * Tellor's address
    * @param _storage is the TellorMaster address
    */
    function updateTellorAddress(address payable _storage) public {
        require(msg.sender == owner, "Sender is not owner");
        tellorStorageAddress = _storage;
        _tellor = Tellor(tellorStorageAddress); //we should delcall here
        _tellorm = TellorMaster(tellorStorageAddress);
    }
    
    /*Functions*/
    /*
    * @dev Allows the owner to set the address for the oracleID descriptors
    * used by the ADO members for price key value pairs standarization 
    * _oracleDescriptos is the address for the OracleIDDescptions contract
    */
    function setOracleIDDescriptors(address _oracleDescriptors) external {
        require(msg.sender == owner, "Sender is not owner");
        oracleIDDescriptionsAddress = _oracleDescriptors;
        descriptions = OracleIDDescriptions(_oracleDescriptors);
        emit NewDescriptorSet(_oracleDescriptors);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address payable newOwner) external {
        require(msg.sender == owner, "Sender is not owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
    * @dev This function allows the owner to withdraw the ETH paid for requests
    */
    function withdrawEther() external {
        require(msg.sender == owner, "Sender is not owner");
        owner.transfer(address(this).balance);
    }

    /**
    * @dev Allows the contract owner(Tellor) to withdraw any Tributes left on this contract
    */
    function withdrawTokens() external {
        require(msg.sender == owner, "Sender is not owner");
        _tellor.transfer(owner, _tellorm.balanceOf(address(this)));
    }

    /**
    * @dev Allows the user to submit a request for data to the oracle using ETH
    * @param c_sapi string API being requested to be mined
    * @param _c_symbol is the short string symbol for the api request
    * @param _granularity is the number of decimals miners should include on the submitted value
    */
    function requestDataWithEther(string calldata c_sapi, string calldata _c_symbol, uint256 _granularity) external payable {
        uint _amount = (msg.value / tributePrice)*1e18;
        require(_tellorm.balanceOf(address(this)) >= _amount, "Balance is lower than tip amount");
        _tellor.requestData(c_sapi, _c_symbol, _granularity, _amount);
    }

    /**
    * @dev Allows the user to tip miners using ether
    * @param _apiId to tip
    */
    function addTipWithEther(uint256 _apiId) external payable {
        uint _amount = (msg.value / tributePrice)*1e18;
        require(_tellorm.balanceOf(address(this)) >= _amount, "Balance is lower than tip amount");
        _tellor.addTip(_apiId, _amount);
    }

    /**
    * @dev Allows the owner to set the Tribute token price.
    * @param _price to set for Tellor Tribute token
    */
    function setPrice(uint256 _price) public {
        require(msg.sender == owner, "Sender is not owner");
        tributePrice = _price;
        emit NewPriceSet(_price);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified
    * @param _requestId is the requestId to look up the value for
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {
        uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId);
        if (_count > 0) {
            _timestampRetrieved = _tellorm.getTimestampbyRequestIDandIndex(_requestId, _count - 1); //will this work with a zero index? (or insta hit?)
            return (true, _tellorm.retrieveData(_requestId, _timestampRetrieved), _timestampRetrieved);
        }
        return (false, 0, 0);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified using the 
    * ADO specification for the standard inteface for price oracles
    * @param _bytesId is the ADO standarized bytes32 price/key value pair identifier
    * @return the timestamp, outcome or value/ and the status code (for retreived, null, etc...)
    */
    function resultFor(bytes32 _bytesId) view external returns (uint256 timestamp, int outcome, int status) {
        uint _id = descriptions.getTellorIdFromBytes(_bytesId);
        if (_id > 0){
            bool _didGet;
            uint256 _returnedValue;
            uint256 _timestampRetrieved;
            (_didGet,_returnedValue,_timestampRetrieved) = getCurrentValue(_id);
            if(_didGet){
                return (_timestampRetrieved, int(_returnedValue),descriptions.getStatusFromTellorStatus(1));
            }
            else{
                return (0,0,descriptions.getStatusFromTellorStatus(2));
            }
        }
        return (0, 0, descriptions.getStatusFromTellorStatus(0));
    }
    /**
    * @dev Allows the user to get the first verified value for the requestId after the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp after which to search for first verified value
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp, the timestamp after
    * which it searched for the first verified value
    */
    function getFirstVerifiedDataAfter(uint256 _requestId, uint256 _timestamp) public view returns (bool, uint256, uint256 _timestampRetrieved) {
        uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId);
        if (_count > 0) {
            for (uint256 i = _count; i > 0; i--) {
                if (
                    _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1) > _timestamp &&
                    _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1) < block.timestamp - 86400
                ) {
                    _timestampRetrieved = _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1); //will this work with a zero index? (or insta hit?)
                }
            }
            if (_timestampRetrieved > 0) {
                return (true, _tellorm.retrieveData(_requestId, _timestampRetrieved), _timestampRetrieved);
            }
        }
        return (false, 0, 0);
    }

    /**
    * @dev Allows the user to get the first value for the requestId after the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp after which to search for first verified value
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getAnyDataAfter(uint256 _requestId, uint256 _timestamp)
        public
        view
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {
        uint256 _count = _tellorm.getNewValueCountbyRequestId(_requestId);
        if (_count > 0) {
            for (uint256 i = _count; i > 0; i--) {
                if (_tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1) >= _timestamp) {
                    _timestampRetrieved = _tellorm.getTimestampbyRequestIDandIndex(_requestId, i - 1); //will this work with a zero index? (or insta hit?)
                }
            }
            if (_timestampRetrieved > 0) {
                return (true, _tellorm.retrieveData(_requestId, _timestampRetrieved), _timestampRetrieved);
            }
        }
        return (false, 0, 0);
    }

}



/**
* @title UsingTellor
* This contracts creates for easy integration to the Tellor Tellor System
*/
contract UsingTellor is ADOInterface{
    UserContract tellorUserContract;
    address payable public owner;

    event OwnershipTransferred(address _previousOwner, address _newOwner);

    /*Constructor*/
    /**
    * @dev This function sents the owner and userContract address
    * @param _userContract is the UserContract.sol address
    */
    constructor(address _userContract) public {
        tellorUserContract = UserContract(_userContract);
        owner = msg.sender;
    }

    /*Functions*/
    /**
    * @dev Allows the user to get the latest value for the requestId specified
    * @param _requestId is the requestId to look up the value for
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getCurrentValue(uint256 _requestId) public view returns (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) {
        return tellorUserContract.getCurrentValue(_requestId);
    }

    /**
    * @dev Allows the user to get the latest value for the requestId specified using the 
    * ADO specification for the standard inteface for price oracles
    * @param _bytesId is the ADO standarized bytes32 price/key value pair identifier
    * @return the timestamp, outcome or value/ and the status code (for retreived, null, etc...)
    */
    function resultFor(bytes32 _bytesId) view external returns (uint256 timestamp,int256 outcome, int256 status){
        return tellorUserContract.resultFor(_bytesId);
    }

    /**
    * @dev Allows the user to get the first verified value for the requestId after the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp after which to search for first verified value
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp, the timestamp after
    * which it searched for the first verified value
    */
    function getFirstVerifiedDataAfter(uint256 _requestId, uint256 _timestamp) public view returns (bool, uint256, uint256 _timestampRetrieved) {
        return tellorUserContract.getFirstVerifiedDataAfter(_requestId, _timestamp);
    }

    /**
    * @dev Allows the user to get the first value for the requestId after the specified timestamp
    * @param _requestId is the requestId to look up the value for
    * @param _timestamp after which to search for first verified value
    * @return bool true if it is able to retreive a value, the value, and the value's timestamp
    */
    function getAnyDataAfter(uint256 _requestId, uint256 _timestamp)
        public
        view
        returns (bool _ifRetrieve, uint256 _value, uint256 _timestampRetrieved)
    {
        return tellorUserContract.getAnyDataAfter(_requestId, _timestamp);
    }

    /**
    * @dev Allows the user to submit a request for data to the oracle using Tributes
    * Allowing this prevents us from increasing spread too high (since if we set the price too hight
    * users will just go to an exchange and get tokens from there)
    * @param _request string API being requested to be mined
    * @param _symbol is the short string symbol for the api request
    * @param _granularity is the number of decimals miners should include on the submitted value
    * @param _tip amount the requester is willing to pay to be get on queue. Miners
    * mine the onDeckQueryHash, or the api with the highest payout pool
    */
    function requestData(string calldata _request, string calldata _symbol, uint256 _granularity, uint256 _tip) external {
        Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
        if (_tip > 0) {
            require(_tellor.transferFrom(msg.sender, address(this), _tip), "Transfer failed");
        }
        _tellor.requestData(_request, _symbol, _granularity, _tip);
    }

    /**
    * @dev Allows the user to submit a request for data to the oracle using ETH
    * @param _request string API being requested to be mined
    * @param _symbol is the short string symbol for the api request
    * @param _granularity is the number of decimals miners should include on the submitted value
    */
    function requestDataWithEther(string calldata _request, string calldata _symbol, uint256 _granularity) external payable {
        tellorUserContract.requestDataWithEther.value(msg.value)(_request, _symbol, _granularity);
    }

    /**
    * @dev Allows the user to tip miners for the specified request using Tributes
    * @param _requestId to tip
    * @param _tip amount
    */
    function addTip(uint256 _requestId, uint256 _tip) public {
        Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
        require(_tellor.transferFrom(msg.sender, address(this), _tip), "Transfer failed");
        _tellor.addTip(_requestId, _tip);
    }

    /**
    * @dev Allows user to add tip with Ether by sending the ETH to the userContract and exchanging it for Tributes
    * at the price specified by the userContract owner.
    * @param _requestId to tip
    */
    function addTipWithEther(uint256 _requestId) public payable {
        UserContract(tellorUserContract).addTipWithEther.value(msg.value)(_requestId);
    }

    /**
    * @dev allows owner to set the user contract address
    * @param _userContract address
    */
    function setUserContract(address _userContract) public {
        require(msg.sender == owner, "Sender is not owner"); //who should this be?
        tellorUserContract = UserContract(_userContract);
    }

    /**
    * @dev allows owner to transfer ownership
    * @param _newOwner address
    */
    function transferOwnership(address payable _newOwner) external {
        require(msg.sender == owner, "Sender is not owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}




/**
 * @title Tellor Fund
 * @notice Allows the Tellor communtiy to propose and fund different 
 * activities like paid AMA's, listing fees influencer's interviews.
 * The proposal is originally funded by the creator and if it fails to 
 * reach the minimum threshold it refunds the funds to the users that "voted"
 */

contract TellorFund is UsingTellor{
    /*Variables*/
	uint private proposalCount;
	uint public tellorPriceID; //??
	uint public granularity; //??
	uint[] openProposals;

	struct Proposal{
		string title;
		string description;
		address owner;
		uint minAmountUSD;
		uint expirationDate;
		uint trbBalance;
		bool open;
		bool passed;
	}

	struct Funder{
		address funder;
		uint amount;
	}

	struct Statement{
		uint id;
		uint amount;
	}

	mapping(uint => Proposal) idToProposal;
	mapping(uint => Funder[]) idToFunders;
	mapping(address => Statement[]) addressToStatements;//???
	mapping(uint => uint) idToOpenIndex;
	mapping(address => uint) availableForWithdraw;

    /*Events*/
	event NewProposal(uint _id,string _title,string _desc,uint _minAmountUSD,uint _daystilComplete);
	event ProposalFunded(uint _id, address _funder, uint _amount);
	event ProposalClosed(uint _id, bool _funded, uint _amount);

    /*
    * @dev Sets the usercontract, tellor's request data Id and 
    * amount of decimals to include(granularity)
    * @param _userContract is the userContract address for Tellor
    * @param _tellorPriceID is Tellor's request ID to read data from ??
    * @param _granularity is the amount of decimals to include in the price feed
    */
    constructor(address _userContract, uint _tellorPriceID, uint _granularity) public UsingTellor(_userContract){
    	proposalCount = 1;
    	tellorPriceID = _tellorPriceID;
    	granularity = _granularity;
    	openProposals.length++;
    }


    /*
    * @dev Creates a proposoal
    * @param _title is the proposal's title
    * @param _desc is the proposal description
    * @param _minAmountUSD is the minimun USD threshold to fund before the proposal goes to a vote???
    * @param _daystilComplete number of days allowed for funding???
    * @return proposal Id
    */
    //be sure to approve first
	function createProposal(string calldata _title, string calldata _desc,uint _minAmountUSD, uint _daystilComplete) external returns(uint _id){
		Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
        require(_tellor.transferFrom(msg.sender,address(this),1e18), "Fee to create proposal failed to tranfer");
		require(_daystilComplete < 30);
		_id = proposalCount;
		proposalCount++;
		idToProposal[_id] = Proposal({
			title:_title,
			description:_desc,
			owner:msg.sender,
			minAmountUSD:_minAmountUSD,
			expirationDate:now + _daystilComplete * 86400,
			trbBalance:0,
			open:true,
			passed:false
		});
		idToOpenIndex[_id] = openProposals.length;
		openProposals.push(_id);
		Statement memory thisStatement= Statement({
        	id:_id,
        	amount:0
        });
        addressToStatements[msg.sender].push(thisStatement);//what is the statememt???


	emit NewProposal(_id,_title,_desc,_minAmountUSD,_daystilComplete);
	}

    /*
    * @dev Funds a specified proposoal
    * @param _id is the proposal Id
    * @param _amountTRB amount of TRB to fund 
    */
	function fund(uint _id, uint _amountTRB) external {
		require(_amountTRB > 0);
		Proposal storage thisProp = idToProposal[_id];
		require(thisProp.open);
		Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
        require(_tellor.transferFrom(msg.sender,address(this),_amountTRB), "Funding Failed");
        Statement memory thisStatement= Statement({
        	id:_id,
        	amount:_amountTRB
        	});
        addressToStatements[msg.sender].push(thisStatement);
        thisProp.trbBalance += _amountTRB;

        Funder memory thisFunder = Funder({
        	funder:msg.sender,
        	amount:_amountTRB
        });
        idToFunders[_id].push(thisFunder);
        emit ProposalFunded(_id,msg.sender,_amountTRB);

	}

    /*
    * @dev Closes the specified proposal. Closes the proposal, it makes the funders 
    * funds available for withdraw if the proposal fails, and updates the proposal array. 
    * @param _id is the proposal id
    */
	function closeProposal(uint _id) external{
		Proposal storage thisProp = idToProposal[_id];
		require(thisProp.open);
		require(_id > 0);
		require(now > thisProp.expirationDate);
		Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
		if(percentFunded(_id) >= 100){
			thisProp.passed = true;
			_tellor.transfer(thisProp.owner,thisProp.trbBalance);
		}
		else{
			Funder[] storage theseFunders = idToFunders[_id];
			for(uint i=0;i < theseFunders.length;i++){
				availableForWithdraw[theseFunders[i].funder] += theseFunders[i].amount; 
			}
		}
		uint _index = idToOpenIndex[_id];
		if(_index == openProposals.length - 1){
			openProposals.length--;
		}
		else{
			uint _lastId = openProposals[openProposals.length - 1];
			openProposals[_index] = _lastId;
			idToOpenIndex[_lastId] = _index;
			openProposals.length--;
			idToOpenIndex[_id] = 0;
		}
		thisProp.open = false;
		emit ProposalClosed(_id,thisProp.passed,thisProp.trbBalance);
		thisProp.trbBalance = 0;
	}

    /*
    * @dev Allows funders to withdraw their funds if the proposal was unsuccessful
    */
 	function withdrawMoney() external{
 		Tellor _tellor = Tellor(tellorUserContract.tellorStorageAddress());
 		uint _amt = availableForWithdraw[msg.sender];
 		availableForWithdraw[msg.sender] =0;
		_tellor.transfer(msg.sender,_amt);
 	}

    /*
    * @dev Getter function for all open proposals
    * @returns an array with all open proposals
    */
	function getAllOpenProposals() external view returns(uint[] memory){
		return openProposals;
	}

    /*
    * @dev Getter function for amount available for withdraw by funder(specified address)
    * @param _user is the funder address 
    * @return amount available for withdraw for the specified user address
    */
	function getAvailableForWithdraw(address _user) external returns(uint){
		return availableForWithdraw[_user];
	}


    /*
    * @dev Getter function for the proposal information by the id
    * @param _id is the proposal id 
    * @return title of proposal
    * @return description of proposal
    * @return owner of proposal
    * @return minAmountUSD for proposal to pass
    * @return expirationDate of proposal
    * @return trbBalance of proposal
    * @return open- bool true if proposal is still open
    * @return passed- bool true if proposal passed
    * @return percentFunded 
    */
	function getProposalById(uint _id) external view returns(string memory,string memory,address,uint,uint,uint,bool,bool,uint){
		Proposal memory t = idToProposal[_id];
		return (t.title,t.description,t.owner,t.minAmountUSD,t.expirationDate,t.trbBalance,t.open,t.passed,100 * (t.trbBalance* viewTellorPrice()/1e20) / t.minAmountUSD);
	}


    /*
    * @dev Getter function for all proposals funded by the specified address
    * @param _funder is the funder address to look up
    * @return two arrays containing all proposals and amounts contributed to each by the specified funder address
    */
	function getProposalsByAddress(address _funder) public view returns(uint[] memory propArray,uint[] memory amountArray){
		Statement[] memory theseStatements = addressToStatements[_funder];
		propArray = new uint[](theseStatements.length);
		amountArray = new uint[](theseStatements.length);
		for(uint i=0;i < theseStatements.length;i++){
			propArray[i] = theseStatements[i].id;
			amountArray[i]= theseStatements[i].amount;
		}
		return (propArray,amountArray);
	}


    /*
    * @dev Getter function for funder address by proposal id 
    * @param _id is the proposal id
    * @return array of all addresses that have funded the specified proposoal id
    */
	function getAddressesById(uint _id) public view returns(address[] memory addArray){
			Funder[] memory theseFunders = idToFunders[_id];
			addArray = new address[](theseFunders.length);
			for(uint i=0;i < theseFunders.length;i++){
				addArray[i] = theseFunders[i].funder;
			}
	}

    /*
    * @dev Gets the percent funded for the specified proposal
    * @param _id is the proposal id
    * @return the percent funded for the specified proposal id
    */
	function percentFunded(uint _id) public view returns(uint){
			Proposal memory thisProp = idToProposal[_id];
			return  (thisProp.trbBalance* viewTellorPrice()/1e18) / thisProp.minAmountUSD ;
	}


    /*
    * @dev Gets Tellor's Price for the request ID specified in the constructor
    * @returns Tellors price value
    */
	function viewTellorPrice() public view returns(uint){
		bool _didget;
		uint _value;
		uint _timestamp;
		(_didget,_value,_timestamp) = getCurrentValue(tellorPriceID);
		if(!_didget){
			return 0;
		}
		else if(_timestamp > now - 60 minutes){
			for(uint i=120;i< 2400;i++){
				(_didget,_value,_timestamp) = getAnyDataAfter(tellorPriceID,now - i * 60);
				//if the value was obtained within the hour, stop looping.
				if(_didget && _timestamp < now - 60 minutes){
					i = 2400;
				}
				else if(!_didget){
					return 0;
				}
			}

		}
		return _value*100/granularity;
	}

    /*
    * @dev Getter for proposal count
    * @return the number of proposals
    */
	function getProposalCount() public view returns(uint){
		return proposalCount -1;
	}

	/*
    * @dev Getter function for Tellor's address
    * @param the Tellor's Master address
    */
	function tellorAddress() public view returns(address){
		return tellorUserContract.tellorStorageAddress();
	}
}
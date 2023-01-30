/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: set-protocol-contracts/contracts/lib/TimeLockUpgrade.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title TimeLockUpgrade
 * @author Set Protocol
 *
 * The TimeLockUpgrade contract contains a modifier for handling minimum time period updates
 */
contract TimeLockUpgrade is
    Ownable
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    // Timelock Upgrade Period in seconds
    uint256 public timeLockPeriod;

    // Mapping of upgradable units and initialized timelock
    mapping(bytes32 => uint256) public timeLockedUpgrades;

    /* ============ Events ============ */

    event UpgradeRegistered(
        bytes32 _upgradeHash,
        uint256 _timestamp
    );

    /* ============ Modifiers ============ */

    modifier timeLockUpgrade() {
        // If the time lock period is 0, then allow non-timebound upgrades.
        // This is useful for initialization of the protocol and for testing.
        if (timeLockPeriod == 0) {
            _;

            return;
        }

        // The upgrade hash is defined by the hash of the transaction call data,
        // which uniquely identifies the function as well as the passed in arguments.
        bytes32 upgradeHash = keccak256(
            abi.encodePacked(
                msg.data
            )
        );

        uint256 registrationTime = timeLockedUpgrades[upgradeHash];

        // If the upgrade hasn't been registered, register with the current time.
        if (registrationTime == 0) {
            timeLockedUpgrades[upgradeHash] = block.timestamp;

            emit UpgradeRegistered(
                upgradeHash,
                block.timestamp
            );

            return;
        }

        require(
            block.timestamp >= registrationTime.add(timeLockPeriod),
            "TimeLockUpgrade: Time lock period must have elapsed."
        );

        // Reset the timestamp to 0
        timeLockedUpgrades[upgradeHash] = 0;

        // Run the rest of the upgrades
        _;
    }

    /* ============ Function ============ */

    /**
     * Change timeLockPeriod period. Generally called after initially settings have been set up.
     *
     * @param  _timeLockPeriod   Time in seconds that upgrades need to be evaluated before execution
     */
    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        external
        onlyOwner
    {
        // Only allow setting of the timeLockPeriod if the period is greater than the existing
        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgrade: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}

// File: contracts/meta-oracles/lib/LinkedListLibraryV2.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";



/**
 * @title LinkedListLibraryV2
 * @author Set Protocol
 *
 * Library for creating and altering uni-directional circularly linked lists, optimized for sequential updating
 * Version two of this contract is a library vs. a contract.
 *
 *
 * CHANGELOG
 * - LinkedListLibraryV2 is declared as library vs. contract
 */
library LinkedListLibraryV2 {

    using SafeMath for uint256;

    /* ============ Structs ============ */

    struct LinkedList{
        uint256 dataSizeLimit;
        uint256 lastUpdatedIndex;
        uint256[] dataArray;
    }

    /*
     * Initialize LinkedList by setting limit on amount of nodes and inital value of node 0
     *
     * @param  _self                        LinkedList to operate on
     * @param  _dataSizeLimit               Max amount of nodes allowed in LinkedList
     * @param  _initialValue                Initial value of node 0 in LinkedList
     */
    function initialize(
        LinkedList storage _self,
        uint256 _dataSizeLimit,
        uint256 _initialValue
    )
        internal
    {
        require(
            _self.dataArray.length == 0,
            "LinkedListLibrary: Initialized LinkedList must be empty"
        );

        // Initialize Linked list by defining upper limit of data points in the list and setting
        // initial value
        _self.dataSizeLimit = _dataSizeLimit;
        _self.dataArray.push(_initialValue);
        _self.lastUpdatedIndex = 0;
    }

    /*
     * Add new value to list by either creating new node if node limit not reached or updating
     * existing node value
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function editList(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        // Add node if data hasn't reached size limit, otherwise update next node
        _self.dataArray.length < _self.dataSizeLimit ? addNode(_self, _addedValue)
            : updateNode(_self, _addedValue);
    }

    /*
     * Add new value to list by either creating new node. Node limit must not be reached.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function addNode(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        uint256 newNodeIndex = _self.lastUpdatedIndex.add(1);

        require(
            newNodeIndex == _self.dataArray.length,
            "LinkedListLibrary: Node must be added at next expected index in list"
        );

        require(
            newNodeIndex < _self.dataSizeLimit,
            "LinkedListLibrary: Attempting to add node that exceeds data size limit"
        );

        // Add node value
        _self.dataArray.push(_addedValue);

        // Update lastUpdatedIndex value
        _self.lastUpdatedIndex = newNodeIndex;
    }

    /*
     * Add new value to list by updating existing node. Updates only happen if node limit has been
     * reached.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function updateNode(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        // Determine the next node in list to be updated
        uint256 updateNodeIndex = _self.lastUpdatedIndex.add(1) % _self.dataSizeLimit;

        // Require that updated node has been previously added
        require(
            updateNodeIndex < _self.dataArray.length,
            "LinkedListLibrary: Attempting to update non-existent node"
        );

        // Update node value and last updated index
        _self.dataArray[updateNodeIndex] = _addedValue;
        _self.lastUpdatedIndex = updateNodeIndex;
    }

    /*
     * Read list from the lastUpdatedIndex back the passed amount of data points.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _dataPoints                  Number of data points to return
     */
    function readList(
        LinkedList storage _self,
        uint256 _dataPoints
    )
        internal
        view
        returns (uint256[] memory)
    {
        LinkedList memory linkedListMemory = _self;

        return readListMemory(
            linkedListMemory,
            _dataPoints
        );
    }

    function readListMemory(
        LinkedList memory _self,
        uint256 _dataPoints
    )
        internal
        view
        returns (uint256[] memory)
    {
        // Make sure query isn't for more data than collected
        require(
            _dataPoints <= _self.dataArray.length,
            "LinkedListLibrary: Querying more data than available"
        );

        // Instantiate output array in memory
        uint256[] memory outputArray = new uint256[](_dataPoints);

        // Find head of list
        uint256 linkedListIndex = _self.lastUpdatedIndex;
        for (uint256 i = 0; i < _dataPoints; i++) {
            // Get value at index in linkedList
            outputArray[i] = _self.dataArray[linkedListIndex];

            // Find next linked index
            linkedListIndex = linkedListIndex == 0 ? _self.dataSizeLimit.sub(1) : linkedListIndex.sub(1);
        }

        return outputArray;
    }

}

// File: contracts/meta-oracles/lib/TimeSeriesStateLibrary.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;



/**
 * @title TimeSeriesStateLibrary
 * @author Set Protocol
 *
 * Library defining TimeSeries state struct
 */
library TimeSeriesStateLibrary {
    struct State {
        uint256 nextEarliestUpdate;
        uint256 updateInterval;
        LinkedListLibraryV2.LinkedList timeSeriesData;
    }
}

// File: contracts/meta-oracles/interfaces/ITimeSeriesFeed.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ITimeSeriesFeed
 * @author Set Protocol
 *
 * Interface for interacting with TimeSeriesFeed contract
 */
interface ITimeSeriesFeed {

    /*
     * Query linked list for specified days of data. Will revert if number of days
     * passed exceeds amount of days collected.
     *
     * @param  _dataDays            Number of dats of data being queried
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256[] memory);

    function nextEarliestUpdate()
        external
        view
        returns (uint256);

    function updateInterval()
        external
        view
        returns (uint256);

    function getTimeSeriesFeedState()
        external
        view
        returns (TimeSeriesStateLibrary.State memory);
}

// File: contracts/meta-oracles/interfaces/IMetaOracleV2.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title IMetaOracleV2
 * @author Set Protocol
 *
 * Interface for operating with any MetaOracleV2 (moving average, bollinger, etc.)
 *
 * CHANGELOG:
 *  - read returns uint256 instead of bytes
 */
interface IMetaOracleV2 {

    /**
     * Returns the queried data from a meta oracle.
     *
     * @return  Current price of asset in uint256
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256);
}

// File: contracts/meta-oracles/EMAOracle.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;






/**
 * @title EMAOracle
 * @author Set Protocol
 *
 * The EMA Oracle is a Proxy library that allows the indexing of existing EMA feeds and the retrieval
 * of addresses using the IMetaOracleV2 interface.
 *
 */
contract EMAOracle is
    TimeLockUpgrade,
    IMetaOracleV2
{
    using SafeMath for uint256;

    /* ============ Events ============ */

    event FeedAdded(
        address indexed newFeedAddress,
        uint256 indexed emaDays
    );

    event FeedRemoved(
        address indexed removedFeedAddress,
        uint256 indexed emaDays
    );

    /* ============ State Variables ============ */
    string public dataDescription;

    // Mapping of EMA Days to Time Series Feeds
    mapping(uint256 => ITimeSeriesFeed) public emaTimeSeriesFeeds;

    /* ============ Constructor ============ */

    /*
     * Contract used to provide a common interface to retrieve the most recent
     * EMA value of a specific EMA days time series feed.
     *
     * @param  _timeSeriesFeed          List of time series feed addresses
     * @param  _emaTimePeriods          List of EMA Days that correspond with feed addresses
     * @param  _dataDescription         Description of data
     */
    constructor(
        ITimeSeriesFeed[] memory _timeSeriesFeeds,
        uint256[] memory _emaTimePeriods,
        string memory _dataDescription
    )
        public
    {
        dataDescription = _dataDescription;

        // Require that the feeds inputted and days are the same
        require(
            _timeSeriesFeeds.length == _emaTimePeriods.length,
            "EMAOracle.constructor: Input lengths must be equal"
        );

        // Loop through the feeds and add to the mapping
        for (uint256 i = 0; i < _timeSeriesFeeds.length; i++) {
            uint256 emaDay = _emaTimePeriods[i];
            emaTimeSeriesFeeds[emaDay] = _timeSeriesFeeds[i];
        }
    }

    /*
     * Get the current EMA value for a specific time period.
     *
     * @param  _emaTimePeriods   Number of days in time period
     * @returns                  EMA value for passed number of EMA time period
     */
    function read(
        uint256 _emaTimePeriod
    )
        external
        view
        returns (uint256)
    {
        ITimeSeriesFeed emaFeedInstance = emaTimeSeriesFeeds[_emaTimePeriod];

        // EMA Feed must be added
        require(
            address(emaFeedInstance) != address(0),
            "EMAOracle.read: Feed does not exist"
        );

        // Get the current EMA value. The most current value is the first index
        return emaFeedInstance.read(1)[0];
    }

    /*
     * Add a feed address with the mapping of tracked time series feeds
     * Can only be called by owner.
     *
     * @param  _feedAddress      Address of the EMA time series feed
     * @param  _emaTimePeriod    Number of days in EMA time period
     */
    function addFeed(
        ITimeSeriesFeed _feedAddress,
        uint256 _emaTimePeriod
    )
        external
        onlyOwner
    {
        require(
            address(emaTimeSeriesFeeds[_emaTimePeriod]) == address(0),
            "EMAOracle.addFeed: Feed has already been added"
        );

        emaTimeSeriesFeeds[_emaTimePeriod] = _feedAddress;

        emit FeedAdded(address(_feedAddress), _emaTimePeriod);
    }

    /*
     * Removes a feed address with the mapping of tracked time series feeds
     * Can only be called by owner. Is a timeLockUpgrade operation.
     *
     * @param  _emaTimePeriod   Number of days in EMA time period
     */
    function removeFeed(uint256 _emaTimePeriod)
        external
        onlyOwner
        timeLockUpgrade // Must be placed after onlyOwner
    {
        address emaTimeSeriesFeed = address(emaTimeSeriesFeeds[_emaTimePeriod]);

        require(
            emaTimeSeriesFeed != address(0),
            "EMAOracle.removeFeed: Feed does not exist."
        );

        delete emaTimeSeriesFeeds[_emaTimePeriod];

        emit FeedRemoved(emaTimeSeriesFeed, _emaTimePeriod);
    }
}
/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.2;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

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

// File: contracts/meta-oracles/interfaces/IDataSource.sol

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
 * @title IDataSource
 * @author Set Protocol
 *
 * Interface for interacting with DataSource contracts
 */
interface IDataSource {

    function read(
        TimeSeriesStateLibrary.State calldata _timeSeriesState
    )
        external
        view
        returns (uint256);

}

// File: contracts/meta-oracles/lib/TimeSeriesFeed.sol

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
 * @title TimeSeriesFeed
 * @author Set Protocol
 *
 * Contract used to store time-series data from a specified DataSource. Intended time-series data
 * is stored in a circular Linked List data structure with a maximum number of data points. Its
 * enforces a minimum duration between each update. New data is appended by calling the poke function,
 * which reads data from a specified data source.
 */
contract TimeSeriesFeed is
    ReentrancyGuard
{
    using SafeMath for uint256;
    using LinkedListLibraryV2 for LinkedListLibraryV2.LinkedList;

    /* ============ State Variables ============ */
    uint256 public updateInterval;
    uint256 public maxDataPoints;
    // Unix Timestamp in seconds of next earliest update time
    uint256 public nextEarliestUpdate;
    string public dataDescription;
    IDataSource public dataSourceInstance;

    LinkedListLibraryV2.LinkedList private timeSeriesData;

    /* ============ Constructor ============ */

    /*
     * Stores time-series values in a LinkedList and updated using data from a specific data source.
     * Updates must be triggered off chain to be stored in this smart contract.
     *
     * @param  _updateInterval            Cadence at which data is optimally logged. Optimal schedule is based
                                          off deployment timestamp. A certain data point can't be logged before
                                          it's expected timestamp but can be logged after.
     * @param  _maxDataPoints             The maximum amount of data points the linkedList will hold
     * @param  _dataSourceAddress         The address to read current data from
     * @param  _dataDescription           Description of time-series data for Etherscan / other applications
     * @param  _seededValues              Array of previous timeseries values to seed
     *                                    initial values in list. The last value should contain
     *                                    the most current piece of data
     */
    constructor(
        uint256 _updateInterval,
        uint256 _maxDataPoints,
        IDataSource _dataSourceAddress,
        string memory _dataDescription,
        uint256[] memory _seededValues
    )
        public
    {
        // Set updateInterval, maxDataPoints, data description, dataSourceInstance
        updateInterval = _updateInterval;
        maxDataPoints = _maxDataPoints;
        dataDescription = _dataDescription;
        dataSourceInstance = _dataSourceAddress;

        require(
            _seededValues.length > 0,
            "TimeSeriesFeed.constructor: Must include at least one seeded value."
        );

        // Define upper data size limit for linked list and input initial value
        timeSeriesData.initialize(_maxDataPoints, _seededValues[0]);

        // Cycle through input values array (skipping first value used to initialize LinkedList)
        // and add to timeSeriesData
        for (uint256 i = 1; i < _seededValues.length; i++) {
            timeSeriesData.editList(_seededValues[i]);
        }

        // Set nextEarliestUpdate
        nextEarliestUpdate = block.timestamp.add(updateInterval);
    }

    /* ============ External ============ */

    /*
     * Updates linked list with newest data point by querying the dataSource.
     */
    function poke()
        external
        nonReentrant
    {
        // Make sure block timestamp exceeds nextEarliestUpdate
        require(
            block.timestamp >= nextEarliestUpdate,
            "TimeSeriesFeed.poke: Not enough time elapsed since last update"
        );

        TimeSeriesStateLibrary.State memory timeSeriesState = getTimeSeriesFeedState();

        // Get the most current data point
        uint256 newValue = dataSourceInstance.read(timeSeriesState);

        // Update the nextEarliestUpdate to previous nextEarliestUpdate plus updateInterval
        nextEarliestUpdate = nextEarliestUpdate.add(updateInterval);

        // Update linkedList with new price
        timeSeriesData.editList(newValue);
    }

    /*
     * Query linked list for specified days of data. Will revert if number of days
     * passed exceeds amount of days collected. Will revert if not enough days of
     * data logged.
     *
     * @param  _numDataPoints  Number of datapoints to query
     * @returns                Array of datapoints of length _numDataPoints from most recent to oldest
     */
    function read(
        uint256 _numDataPoints
    )
        external
        view
        returns (uint256[] memory)
    {
        return timeSeriesData.readList(_numDataPoints);
    }

    /* ============ Public ============ */

    /*
     * Generate struct that holds TimeSeriesFeed's current nextAvailableUpdate, updateInterval,
     * and the LinkedList struct
     *
     * @returns                Struct containing the above params
     */
    function getTimeSeriesFeedState()
        public
        view
        returns (TimeSeriesStateLibrary.State memory)
    {
        return TimeSeriesStateLibrary.State({
            nextEarliestUpdate: nextEarliestUpdate,
            updateInterval: updateInterval,
            timeSeriesData: timeSeriesData
        });
    }
}
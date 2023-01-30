/**
 *Submitted for verification at Etherscan.io on 2019-09-03
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

// File: contracts/meta-oracles/lib/DataSourceLinearInterpolationLibrary.sol

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
 * @title LinearInterpolationLibrary
 * @author Set Protocol
 *
 * Library used to determine linearly interpolated value for DataSource contracts when TimeSeriesFeed
 * is updated after interpolationThreshold has passed.
 */
library DataSourceLinearInterpolationLibrary {
    using SafeMath for uint256;

    /* ============ External ============ */

    /*
     * When the update time has surpassed the currentTime + interpolationThreshold, linearly interpolate the
     * price between the current time and price and the last updated time and price to reduce potential error. This
     * is done with the following series of equations, modified in this instance to deal unsigned integers:
     *
     * price = (currentPrice * updateInterval + previousLoggedPrice * timeFromExpectedUpdate) / timeFromLastUpdate
     *
     * Where updateTimeFraction represents the fraction of time passed between the last update and now spent in
     * the previous update window. It's worth noting that because we consider updates to occur on their update
     * timestamp we can make the assumption that the amount of time spent in the previous update window is equal
     * to the update frequency.
     *
     * By way of example, assume updateInterval of 24 hours and a interpolationThreshold of 1 hour. At time 1 the
     * update is missed by one day and when the oracle is finally called the price is 150, the price feed
     * then interpolates this price to imply a price at t1 equal to 125. Time 2 the update is 10 minutes late but
     * since it's within the interpolationThreshold the value isn't interpolated. At time 3 everything
     * falls back in line.
     *
     * +----------------------+------+-------+-------+-------+
     * |                      | 0    | 1     | 2     | 3     |
     * +----------------------+------+-------+-------+-------+
     * | Expected Update Time | 0:00 | 24:00 | 48:00 | 72:00 |
     * +----------------------+------+-------+-------+-------+
     * | Actual Update Time   | 0:00 | 48:00 | 48:10 | 72:00 |
     * +----------------------+------+-------+-------+-------+
     * | Logged Px            | 100  | 125   | 151   | 130   |
     * +----------------------+------+-------+-------+-------+
     * | Received Oracle Px   | 100  | 150   | 151   | 130   |
     * +----------------------+------+-------+-------+-------+
     * | Actual Price         | 100  | 110   | 151   | 130   |
     * +------------------------------------------------------
     *
     * @param  _currentPrice                Current price returned by oracle
     * @param  _updateInterval              Update interval of TimeSeriesFeed
     * @param  _timeFromExpectedUpdate      Time passed from expected update
     * @param  _previousLoggedDataPoint     Previously logged price from TimeSeriesFeed
     * @returns                             Interpolated price value
     */
    function interpolateDelayedPriceUpdate(
        uint256 _currentPrice,
        uint256 _updateInterval,
        uint256 _timeFromExpectedUpdate,
        uint256 _previousLoggedDataPoint
    )
        internal
        pure
        returns (uint256)
    {
        // Calculate how much time has passed from timestamp corresponding to last update
        uint256 timeFromLastUpdate = _timeFromExpectedUpdate.add(_updateInterval);

        // Linearly interpolate between last updated price (with corresponding timestamp) and current price (with
        // current timestamp) to imply price at the timestamp we are updating
        return _currentPrice.mul(_updateInterval)
            .add(_previousLoggedDataPoint.mul(_timeFromExpectedUpdate))
            .div(timeFromLastUpdate);
    }
}

// File: contracts/meta-oracles/interfaces/IOracle.sol

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
 * @title IOracle
 * @author Set Protocol
 *
 * Interface for operating with any external Oracle that returns uint256 or
 * an adapting contract that converts oracle output to uint256
 */
interface IOracle {

    /**
     * Returns the queried data from an oracle returning uint256
     *
     * @return  Current price of asset represented in uint256
     */
    function read()
        external
        view
        returns (uint256);
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

// File: contracts/meta-oracles/lib/EMALibrary.sol

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
 * @title EMALibrary
 * @author Set Protocol
 *
 * Library for calculate the Exponential Moving Average
 *
 */
library EMALibrary{

    using SafeMath for uint256;

    /*
     * Calculates the new exponential moving average value using the previous value,
     * EMA time period, and the current asset price.
     *
     * Weighted Multiplier = 2 / (timePeriod + 1)
     *
     * EMA = Price(Today) x Weighted Multiplier +
     *       EMA(Yesterday) -
     *       EMA(Yesterday) x Weighted Multiplier
     *
     * Our implementation is simplified to the following for efficiency:
     *
     * EMA = (Price(Today) * 2 + EMA(Yesterday) * (timePeriod - 1)) / (timePeriod + 1)
     *
     *
     * @param  _previousEMAValue         The previous Exponential Moving average value
     * @param  _timePeriod               The number of days the calculate the EMA with
     * @param  _currentAssetPrice        The current asset price
     * @returns                          The exponential moving average
     */
    function calculate(
        uint256 _previousEMAValue,
        uint256 _timePeriod,
        uint256 _currentAssetPrice
    )
        internal
        pure
        returns (uint256)
    {
        uint256 a = _currentAssetPrice.mul(2);
        uint256 b = _previousEMAValue.mul(_timePeriod.sub(1));
        uint256 c = _timePeriod.add(1);

        return a.add(b).div(c);
    }
}

// File: contracts/meta-oracles/lib/LinkedListHelper.sol

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
 * @title LinkedListHelper
 * @author Set Protocol
 *
 * Convenience methods for the LinkedListLibrary
 */
library LinkedListHelper {
    using LinkedListLibraryV2 for LinkedListLibraryV2.LinkedList;

    /* ============ Structs ============ */

    function getLatestValue(
        LinkedListLibraryV2.LinkedList memory _self
    )
        internal
        view
        returns (uint256)
    {
        uint256[] memory currentTimeSeriesValues = _self.readListMemory(1);
        return currentTimeSeriesValues[0];
    }
}

// File: contracts/meta-oracles/data-sources/LinearizedEMADataSource.sol

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
 * @title LinearizedEMADataSource
 * @author Set Protocol
 *
 * This DataSource returns the current value of the oracle. If the interpolationThreshold
 * is reached, then returns a linearly interpolated value.
 * It is intended to be read by a TimeSeriesFeed smart contract.
 */
contract LinearizedEMADataSource is
    TimeLockUpgrade,
    IDataSource
{
    using SafeMath for uint256;
    using LinkedListHelper for LinkedListLibraryV2.LinkedList;

    /* ============ State Variables ============ */
    // Number of EMA Days
    uint256 public emaTimePeriod;

    // Amount of time after which read interpolates price result, in seconds
    uint256 public interpolationThreshold;
    string public dataDescription;
    IOracle public oracleInstance;

    /* ============ Events ============ */

    event LogOracleUpdated(
        address indexed newOracleAddress
    );

    /* ============ Constructor ============ */

    /*
     * Set interpolationThreshold, data description, emaTimePeriod, and instantiate oracle
     *
     * @param  _emaTimePeriod             The time period the exponential moving average is based off of
     * @param  _interpolationThreshold    The minimum time in seconds where interpolation is enabled
     * @param  _oracleAddress             The address to read current data from
     * @param  _dataDescription           Description of contract for Etherscan / other applications
     */
    constructor(
        uint256 _emaTimePeriod,
        uint256 _interpolationThreshold,
        IOracle _oracleAddress,
        string memory _dataDescription
    )
        public
    {
        interpolationThreshold = _interpolationThreshold;
        emaTimePeriod = _emaTimePeriod;
        oracleInstance = _oracleAddress;
        dataDescription = _dataDescription;
    }

    /* ============ External ============ */

    /*
     * Returns the data from the oracle contract. If the current timestamp has surpassed
     * the interpolationThreshold, then the current price is retrieved and interpolated based on
     * the previous value and the time that has elapsed since the intended update value.
     *
     * Returns with newest data point by querying oracle. Is eligible to be
     * called after nextAvailableUpdate timestamp has passed. Because the nextAvailableUpdate occurs
     * on a predetermined cadence based on the time of deployment, delays in calling poke do not propogate
     * throughout the whole dataset and the drift caused by previous poke transactions not being mined
     * exactly on nextAvailableUpdate do not compound as they would if it was required that poke is called
     * an updateInterval amount of time after the last poke.
     *
     * @param  _timeSeriesState         Struct of TimeSeriesFeed state
     * @returns                         Returns the datapoint from the oracle contract
     */
    function read(
        TimeSeriesStateLibrary.State memory _timeSeriesState
    )
        public
        view
        returns (uint256)
    {
        // Validate that nextEarliest update timestamp is less than current block timestamp
        require(
            block.timestamp >= _timeSeriesState.nextEarliestUpdate,
            "LinearizedEMADataSource.read: current timestamp must be greater than nextAvailableUpdate."
        );

        // Get current oracle value
        uint256 oracleValue = oracleInstance.read();

        // Get the previous EMA Value
        uint256 previousEMAValue = _timeSeriesState.timeSeriesData.getLatestValue();

        // Calculate the current EMA
        uint256 currentEMAValue = EMALibrary.calculate(
            previousEMAValue,
            emaTimePeriod,
            oracleValue
        );

        // Calculate how much time has passed from last expected update
        uint256 timeFromExpectedUpdate = block.timestamp.sub(_timeSeriesState.nextEarliestUpdate);

        // If block timeFromExpectedUpdate is greater than interpolationThreshold we linearize
        // the current price to try to reduce error
        if (timeFromExpectedUpdate < interpolationThreshold) {
            return currentEMAValue;
        } else {
            return DataSourceLinearInterpolationLibrary.interpolateDelayedPriceUpdate(
                currentEMAValue,
                _timeSeriesState.updateInterval,
                timeFromExpectedUpdate,
                previousEMAValue
            );
        }
    }

    /*
     * Change oracle in case current one fails or is deprecated. Only contract
     * owner is allowed to change.
     *
     * @param  _newOracleAddress       Address of new oracle to pull data from
     */
    function changeOracle(
        IOracle _newOracleAddress
    )
        external
        onlyOwner
        timeLockUpgrade // Must be placed after onlyOwner
    {
        // Check to make sure new oracle address is passed
        require(
            address(_newOracleAddress) != address(oracleInstance),
            "LinearizedEMADataSource.changeOracle: Must give new oracle address."
        );

        oracleInstance = _newOracleAddress;

        emit LogOracleUpdated(address(_newOracleAddress));
    }
}
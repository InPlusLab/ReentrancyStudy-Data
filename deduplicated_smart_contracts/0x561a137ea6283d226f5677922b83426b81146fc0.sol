/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

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

// File: contracts/managers/triggers/ITrigger.sol

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
 * @title IPriceTrigger
 * @author Set Protocol
 *
 * Interface for interacting with PriceTrigger contracts
 */
interface ITrigger {
    /*
     * Returns bool indicating whether the current market conditions are bullish.
     *
     * @return             Boolean whether condition is bullish
     */
    function isBullish()
        external
        view
        returns (bool);
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

// File: contracts/managers/lib/Oscillator.sol

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
 * @title Oscillator
 * @author Set Protocol
 *
 * Library of utility functions to deal with oscillator-related functionality.
 */
library Oscillator {

    enum State { NEUTRAL, UPPER, LOWER }

    // Oscillator bounds typically between 0 and 100
    struct Bounds {
        uint256 lower;
        uint256 upper;
    }

    /*
     * Returns upper if value is greater or equal to upper bound.
     * Returns lower if lower than lower bound, and neutral if in between.
     * Asymmetric bounds are due to rounding in solidity and not wanting 40.1
     * to register in LOWER state, for example.
     */
    function getState(
        Bounds storage _bounds,
        uint256 _value
    )
        internal
        view
        returns(State)
    {
        return _value >= _bounds.upper ? State.UPPER :
            _value < _bounds.lower ? State.LOWER : State.NEUTRAL;
    }
}

// File: contracts/managers/triggers/RSITrendingTrigger.sol

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
 * @title RSITrending
 * @author Set Protocol
 *
 * Implementing the ITrigger interface, this contract is queried by a
 * RebalancingSetToken Manager to determine the whether the current market state for
 * the RSI Trending trigger is bullish.
 *
 * This trigger is for trend trading strategies which sets upperBound as resistance
 * and lowerBound as support. When RSI level crosses above upperBound the indicator
 * is bullish. When RSI level crosses below lowerBound the indicator is bearish.
 *
 */
contract RSITrendingTrigger is
    ITrigger
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */
    IMetaOracleV2 public rsiOracle;
    Oscillator.Bounds public bounds;
    uint256 public rsiTimePeriod;

    /*
     * RSITrendingTrigger constructor.
     *
     * @param  _rsiOracle               The address of RSI oracle
     * @param  _lowerBound              Lower bound of RSI to trigger a rebalance
     * @param  _upperBound              Upper bound of RSI to trigger a rebalance
     * @param  _rsiTimePeriod           The amount of days to use in RSI calculation
     */
    constructor(
        IMetaOracleV2 _rsiOracle,
        uint256 _lowerBound,
        uint256 _upperBound,
        uint256 _rsiTimePeriod
    )
        public
    {
        require(
            _upperBound >= _lowerBound,
            "RSITrendingTrigger.constructor: Upper bound must be greater than lower bound."
        );

        // If upper bound less than 100 and above inequality holds then lowerBound
        // also guaranteed to be between 0 and 100.
        require(
            _upperBound < 100,
            "RSITrendingTrigger.constructor: Bounds must be between 0 and 100."
        );

        // RSI time period must be greater than 0
        require(
            _rsiTimePeriod > 0,
            "RSITrendingTrigger.constructor: RSI time period must be greater than 0."
        );

        rsiOracle = _rsiOracle;
        rsiTimePeriod = _rsiTimePeriod;
        bounds = Oscillator.Bounds({
            lower: _lowerBound,
            upper: _upperBound
        });
    }

    /* ============ External ============ */

    /*
     * If RSI is above upper bound then should be true, if RSI is below lower bound
     * then should be false. If in between bounds then revert.
     */
    function isBullish()
        external
        view
        returns (bool)
    {
        uint256 rsiValue = rsiOracle.read(rsiTimePeriod);
        Oscillator.State rsiState = Oscillator.getState(bounds, rsiValue);

        require(
            rsiState != Oscillator.State.NEUTRAL,
            "Oscillator: State must not be neutral"
        );

        return rsiState == Oscillator.State.UPPER;
    }
}
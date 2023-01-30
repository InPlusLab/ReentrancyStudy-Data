/**
 *Submitted for verification at Etherscan.io on 2020-03-27
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

// File: contracts/meta-oracles/oracles/TwoAssetRatioOracle.sol

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
 * @title TwoAssetRatioOracle
 * @author Set Protocol
 *
 * Oracle built to adhere to IOracle interface and returns the ratio of a base asset data point
 * divided by a quote asset data point
 */
contract TwoAssetRatioOracle is
    IOracle
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */
    IOracle public baseOracleInstance;
    IOracle public quoteOracleInstance;
    string public dataDescription;

    // Ratio values are scaled by 1e18
    uint256 internal constant scalingFactor = 10 ** 18;

    /* ============ Constructor ============ */
    /*
     * Set price oracle is made to return
     *
     * @param  _baseOracleInstance        The address of base asset oracle
     * @param  _quoteOracleInstance       The address of quote asset oracle
     * @param  _dataDescription           Description of contract for Etherscan / other applications
     */
    constructor(
        IOracle _baseOracleInstance,
        IOracle _quoteOracleInstance,
        string memory _dataDescription
    )
        public
    {
        baseOracleInstance = _baseOracleInstance;
        quoteOracleInstance = _quoteOracleInstance;
        dataDescription = _dataDescription;
    }

    /**
     * Returns the ratio of base to quote data point scaled by 10 ** 18
     *
     * @return   Ratio of base to quote data point in uint256
     */
    function read()
        external
        view
        returns (uint256)
    {
        uint256 baseOracleValue = baseOracleInstance.read();
        uint256 quoteOracleValue = quoteOracleInstance.read();

        // Return most recent data from time series feed
        return baseOracleValue.mul(scalingFactor).div(quoteOracleValue);
    }
}
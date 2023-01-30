/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

// File: contracts/meta-oracles/interfaces/IMetaOracle.sol

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
 * @title IMetaOracle
 * @author Set Protocol
 *
 * Interface for operating with any MetaOracle (moving average, bollinger, etc.)
 */
interface IMetaOracle {

    /**
     * Returns the queried data from a meta oracle.
     *
     * @return  Current price of asset represented in hex as bytes32
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (bytes32);

    /*
     * Get the medianizer source for the price feed the Meta Oracle uses.
     *
     * @returns                  Address of source medianizer of Price Feed
     */
    function getSourceMedianizer()
        external
        view
        returns (address);
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

// File: contracts/meta-oracles/proxies/MovingAverageOracleV1Proxy.sol

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
 * @title MovingAverageOracleV1Proxy
 * @author Set Protocol
 *
 * This contract converts result from IMetaOracle contracts read calls into uint256 instead of passing
 * bytes. This is done in order to use the data stored in the HistoricalPriceFeed.
 */
contract MovingAverageOracleV1Proxy is
    IMetaOracleV2
{

    /* ============ State Variables ============ */
    IMetaOracle public metaOracleInstance;

    /* ============ Constructor ============ */
    /*
     * Set address of oracle being proxied
     *
     * @param  _metaOracleInstance    Instance of MetaOracle to read from
     */
    constructor(
        IMetaOracle _metaOracleInstance
    )
        public
    {
        metaOracleInstance = _metaOracleInstance;
    }

    /* ============ External ============ */

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
        returns (uint256)
    {
        return uint256(metaOracleInstance.read(_dataDays));
    }
}
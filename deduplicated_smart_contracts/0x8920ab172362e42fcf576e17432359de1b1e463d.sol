/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

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

// File: contracts/meta-oracles/oracles/ConstantPriceOracle.sol

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
 * @title ConstantPriceOracle
 * @author Set Protocol
 *
 * Oracle built to adhere to IOracle interface the returns a constant price. Intended
 * for stablecoin use.
 */
contract ConstantPriceOracle is
    IOracle
{
    /* ============ State Variables ============ */
    uint256 public stablePrice;

    /* ============ Constructor ============ */
    /*
     * Set price oracle is made to return
     *
     * @param  _oracleAddress    The address of oracle being proxied
     */
    constructor(
        uint256 _stablePrice
    )
        public
    {
        stablePrice = _stablePrice;
    }

    /**
     * Returns the stable price
     *
     * @return  Stable price of asset represented in uint256
     */
    function read()
        external
        view
        returns (uint256)
    {
        return stablePrice;
    }
}
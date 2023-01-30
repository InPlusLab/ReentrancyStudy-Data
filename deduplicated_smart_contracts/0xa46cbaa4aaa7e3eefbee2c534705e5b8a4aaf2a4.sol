/**
 *Submitted for verification at Etherscan.io on 2019-12-25
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

// File: contracts/meta-oracles/interfaces/ICToken.sol

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
 * @title ICToken
 * @author Set Protocol
 *
 * Interface for interacting with Compound cTokens
 */
interface ICToken {

    /**
     * Calculates the exchange rate from the underlying to the CToken
     *
     * @notice Accrue interest then return the up-to-date exchange rate
     * @return Calculated exchange rate scaled by 1e18
     */
    function exchangeRateCurrent()
        external
        returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function decimals() external view returns(uint8);
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

// File: contracts/meta-oracles/oracles/CTokenOracle.sol

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
 * @title CTokenOracle
 * @author Set Protocol
 *
 * Oracle built to retrieve the cToken price
 */
contract CTokenOracle is
    IOracle
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */
    ICToken public cToken;
    IOracle public underlyingOracle; // Underlying token oracle
    string public dataDescription;

    // Exchange Rate values are scaled by 1e18
    uint256 internal constant scalingFactor = 10 ** 18;

    // CToken Full Unit
    uint256 public cTokenFullUnit;

    // Underlying Asset Full Unit
    uint256 public underlyingFullUnit;

    /* ============ Constructor ============ */

    /*
     * @param  _cToken             The address of Compound Token
     * @param  _underlyingOracle   The address of the underlying oracle
     * @param  _cTokenFullUnit     The full unit of the Compound Token
     * @param  _underlyingFullUnit The full unit of the underlying asset
     * @param  _dataDescription    Human readable description of oracle
     */
    constructor(
        ICToken _cToken,
        IOracle _underlyingOracle,
        uint256 _cTokenFullUnit,
        uint256 _underlyingFullUnit,
        string memory _dataDescription
    )
        public
    {
        cToken = _cToken;
        cTokenFullUnit = _cTokenFullUnit;
        underlyingFullUnit = _underlyingFullUnit;
        underlyingOracle = _underlyingOracle;
        dataDescription = _dataDescription;
    }

    /**
     * Returns the USD value of a full cToken.
     &
     * The underlying oracle is assumed to return a USD price of 18 decimal
     * for a single full token of the underlying asset. The derived price
     * of the cToken is then the price of a unit of underlying multiplied
     * by the exchangeRate, adjusted for decimal differences, and descaled.
     */
    function read()
        external
        view
        returns (uint256)
    {
        // Retrieve the price of the underlying
        uint256 underlyingPrice = underlyingOracle.read();

        // Retrieve cToken underlying to cTOken conversion rate
        uint256 conversionRate = cToken.exchangeRateStored();

        // Price of underlying is the $ / Token * conversion / scaling factor
        // Values need to be converted based on full unit quantities
        return underlyingPrice
            .mul(conversionRate)
            .mul(cTokenFullUnit)
            .div(underlyingFullUnit)
            .div(scalingFactor);
    }
}
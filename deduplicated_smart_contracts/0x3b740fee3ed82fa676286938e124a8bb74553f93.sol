/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

// File: contracts/iface/ITokenPriceProvider.sol

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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
pragma solidity ^0.5.11;

/// @title ITokenPriceProvider
/// @author Brecht Devos  - <brcht@loopring.org>
contract ITokenPriceProvider
{
    /// @dev Converts USD to LRC
    /// @param usd The amount of USD (10**18 == 1 USD)
    /// @return The amount of LRC
    function usd2lrc(uint usd)
        external
        view
        returns (uint);
}

// File: contracts/thirdparty/chainlink/AggregatorInterfaceV1.sol

pragma solidity ^0.5.11;

interface AggregatorInterfaceV1 {
  function currentAnswer() external view returns (int256);
  function updatedTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 id) external view returns (int256);
  function getUpdatedTimestamp(uint256 id) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed answerId, uint256 timestamp);
  event NewRound(uint256 indexed number, address indexed startedBy);
}

// File: contracts/thirdparty/chainlink/AggregatorInterfaceV2.sol

pragma solidity ^0.5.11;

interface AggregatorInterfaceV2 {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}

// File: contracts/lib/MathUint.sol

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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
pragma solidity ^0.5.11;


/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>
library MathUint
{
    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a * b;
        require(a == 0 || c / a == b, "MUL_OVERFLOW");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {
        require(b <= a, "SUB_UNDERFLOW");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }

    function decodeFloat(
        uint f
        )
        internal
        pure
        returns (uint value)
    {
        uint numBitsMantissa = 23;
        uint exponent = f >> numBitsMantissa;
        uint mantissa = f & ((1 << numBitsMantissa) - 1);
        value = mantissa * (10 ** exponent);
    }
}

// File: contracts/impl/price-providers/ChainlinkTokenPriceProvider.sol

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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
pragma solidity ^0.5.11;






/// @author Brecht Devos - <brecht@loopring.org>
contract ChainlinkTokenPriceProvider is ITokenPriceProvider
{
    using MathUint    for uint;

    AggregatorInterfaceV1 public Eth2Usd;
    AggregatorInterfaceV2 public Lrc2Eth;

    constructor(
        AggregatorInterfaceV1 _Eth2Usd,
        AggregatorInterfaceV2 _Lrc2Eth
        )
        public
    {
        Eth2Usd = _Eth2Usd;
        Lrc2Eth = _Lrc2Eth;
    }

    function usd2lrc(uint usd)
        external
        view
        returns (uint)
    {
        uint EthUsd = uint(Eth2Usd.currentAnswer());
        uint LrcEth = uint(Lrc2Eth.latestAnswer());
        // https://docs.chain.link/docs/using-chainlink-reference-contracts#section-live-reference-data-contracts-ethereum-mainnet
        // EthUsd is scaled by 100000000
        // LrcEth is scaled by 10**18
        return usd.mul(100000000 * 1 ether) / LrcEth.mul(EthUsd);
    }
}
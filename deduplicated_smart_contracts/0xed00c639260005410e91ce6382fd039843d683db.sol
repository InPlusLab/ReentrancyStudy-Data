/*
    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash
    challenge effort, funded by the Ethereum Foundation.
    The contract will pay out 2 ETH to the first finder of a collision in MiMC at security
    level of 80 bits, if such a collision is discovered before the end of March 2020.
    More information about the STARK-friendly hash challenge can be found
    here https://starkware.co/hash-challenge/.
    More information about the STARK-friendly hash selection process (of which this challenge is a
    part) can be found here
    https://medium.com/starkware/stark-friendly-hash-tire-kicking-8087e8d9a246.
    Sage code reference implementation for the contender hash functions available
    at https://starkware.co/hash-challenge-implementation-reference-code/#common.
*/

/*
  Copyright 2019 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/

pragma solidity ^0.5.2;

import "./Base.sol";
import "./Sponge.sol";


contract STARK_Friendly_Hash_Challenge_MiMC_45 is Base, Sponge {
    address roundConstantsContract;

    constructor (uint256 prime, uint256 nRounds, address roundConstantsContract_)
        public payable
        Sponge(prime, 1, 1, nRounds)
    {
        roundConstantsContract = roundConstantsContract_;
    }

    function LoadAuxdata()
        internal view
        returns (uint256[] memory roundConstants)
    {
        roundConstants = new uint256[](nRounds);
        address contractAddr = roundConstantsContract;
        assembly {
            let sizeInBytes := mul(mload(roundConstants), 0x20)
            // The first and last round use the roundConstants 0.
            mstore(add(roundConstants, 0x20), 0)
            extcodecopy(contractAddr, add(roundConstants, 0x40), 0, sub(sizeInBytes, 0x40))
            // Last roundConstants is at offset 0x20 + sizeInBytes - 0x20.
            mstore(add(roundConstants, sizeInBytes), 0)
        }
    }

    function permutation_func(uint256[] memory roundConstants, uint256[] memory elements)
        internal view
        returns (uint256[] memory hash_elements)
    {
        uint256 xLeft = elements[0];
        uint256 xRight = elements[1];
        for (uint256 i = 0; i < roundConstants.length; i++) {
            uint256 xLeftOld;
            xLeftOld = xLeft;
            uint256 step1 = addmod(xLeft, roundConstants[i], prime);
            uint256 step2 = mulmod(mulmod(step1, step1, prime), step1, prime);
            xLeft = addmod(xRight, step2, prime);
            xRight = xLeftOld;
        }
        hash_elements = new uint256[](2);
        hash_elements[0] = xLeft;
        hash_elements[1] = xRight;
    }
}

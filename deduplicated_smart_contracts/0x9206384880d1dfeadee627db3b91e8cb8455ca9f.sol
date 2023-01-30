/*
    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash
    challenge effort, funded by the Ethereum Foundation.
    The contract will pay out X ETH to the first finder of a collision in GMiMC_erf with rate 2
    and capacity 1 at security level of 45 bits, if such a collision is discovered before the end
    of March 2020.
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


contract STARK_Friendly_Hash_Challenge_GMiMC_erf_S45a is Base, Sponge {
    address roundConstantsContract;

    constructor (
        uint256 prime,
        uint256 r,
        uint256 c,
        uint256 nRounds,
        address roundConstantsContract_
        )
        public payable
        Sponge(prime, r, c, nRounds)
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
            extcodecopy(contractAddr, add(roundConstants, 0x20), 0, sizeInBytes)
        }
    }

    function permutation_func(uint256[] memory roundConstants, uint256[] memory elements)
        internal view
        returns (uint256[] memory)
    {
        uint256 length = elements.length;
        require(length == m, "elements length is not equal to m.");
        for (uint256 i = 0; i < roundConstants.length; i++) {
            uint256 element0Old = elements[0];
            uint256 step1 = addmod(elements[0], roundConstants[i], prime);
            uint256 mask = mulmod(mulmod(step1, step1, prime), step1, prime);
            for (uint256 j = 0; j < length - 1; j++) {
                elements[j] = addmod(elements[j + 1], mask, prime);
            }
            elements[length - 1] = element0Old;
        }
        return elements;
    }
}

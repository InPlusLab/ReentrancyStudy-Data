/*
    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash
    challenge effort, funded by the Ethereum Foundation.
    The contract will pay out 1 ETH to the first finder of a collision in Poseidon with rate 10
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


contract STARK_Friendly_Hash_Challenge_Poseidon_S45b is Base, Sponge {
    uint256 MAX_CONSTANTS_PER_CONTRACT = 768;

    address[] roundConstantsContracts;
    address mdsContract;
    uint256 nPartialRounds;

    constructor (
        uint256 prime,  uint256 r,  uint256 c, uint256 nFullRounds,
        uint256 nPartialRounds_, address[] memory roundConstantsContracts_, address mdsContract_)
        public payable
        Sponge(prime, r, c, nFullRounds + nPartialRounds_)
    {
        nPartialRounds = nPartialRounds_;
        roundConstantsContracts = roundConstantsContracts_;
        mdsContract = mdsContract_;
    }

    function LoadAuxdata()
    internal view returns (uint256[] memory auxData)
    {
        uint256 round_constants = m*nRounds;
        require (
            round_constants <= 2 * MAX_CONSTANTS_PER_CONTRACT,
            "The code supports up to 2 roundConstantsContracts." );

        uint256 mdsSize = m * m;
        auxData = new uint256[](round_constants + mdsSize);

        uint256 first_contract_n_elements = ((round_constants > MAX_CONSTANTS_PER_CONTRACT) ?
            MAX_CONSTANTS_PER_CONTRACT : round_constants);
        uint256 second_contract_n_elements = round_constants - first_contract_n_elements;

        address FirstRoundsContractAddr = roundConstantsContracts[0];
        address SecondRoundsContractAddr = roundConstantsContracts[1];
        address mdsContractAddr = mdsContract;

        assembly {
            let offset := add(auxData, 0x20)
            let mdsSizeInBytes := mul(mdsSize, 0x20)
            extcodecopy(mdsContractAddr, offset, 0, mdsSizeInBytes)
            offset := add(offset, mdsSizeInBytes)
            let firstSize := mul(first_contract_n_elements, 0x20)
            extcodecopy(FirstRoundsContractAddr, offset, 0, firstSize)
            offset := add(offset, firstSize)
            let secondSize := mul(second_contract_n_elements, 0x20)
            extcodecopy(SecondRoundsContractAddr, offset, 0, secondSize)
        }
    }


    function hades_round(
        uint256[] memory auxData, bool is_full_round, uint256 round_ptr,
        uint256[] memory workingArea, uint256[] memory elements)
        internal view {

        uint256 prime_ = prime;

        uint256 m_ = workingArea.length;

        // Add-Round Key
        for (uint256 i = 0; i < m_; i++) {
            workingArea[i] = addmod(elements[i], auxData[round_ptr + i], prime_);
        }

        // SubWords
        for (uint256 i = is_full_round ? 0 : m_ - 1; i < m_; i++) {
            // workingArea[i] = workingArea[i] ** 3;
            workingArea[i] = mulmod(
                mulmod(workingArea[i], workingArea[i], prime_), workingArea[i], prime_);
        }

        // MixLayer
        // elements = params.mds * workingArea.
        assembly {
            let mdsRowPtr := add(auxData, 0x20)
            let stateSize := mul(m_, 0x20)
            let workingAreaPtr := add(workingArea, 0x20)
            let statePtr := add(elements, 0x20)
            let mdsEnd := add(mdsRowPtr, mul(m_, stateSize))

            for {} lt(mdsRowPtr, mdsEnd) { mdsRowPtr := add(mdsRowPtr, stateSize) } {
                let sum := 0
                for { let offset := 0} lt(offset, stateSize) { offset := add(offset, 0x20) } {
                    sum := addmod(
                        sum,
                        mulmod(mload(add(mdsRowPtr, offset)),
                               mload(add(workingAreaPtr, offset)),
                               prime_),
                        prime_)
                }

                mstore(statePtr, sum)
                statePtr := add(statePtr, 0x20)
            }
        }
    }


    function permutation_func(uint256[] memory auxData, uint256[] memory elements)
        internal view
        returns (uint256[] memory hash_elements)
    {
        uint256 m_ = m;
        require (elements.length == m, "elements.length != m.");

        // auxData is composed of mdsMatrix followed by the round constants.
        // Skip mdsMatrix.
        uint256 round_ptr = (m_ * m_);
        //TODO(ilya): Move this to auxData?
        uint256[] memory workingArea = new uint256[](m_);

        uint256 half_full_rounds = (nRounds - nPartialRounds) / 2;

        for (uint256 i = 0; i < half_full_rounds; i++) {
            hades_round(auxData, true, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        for (uint256 i = 0; i < nPartialRounds; i++) {
            hades_round(auxData, false, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        for (uint256 i = 0; i < half_full_rounds; i++) {
            hades_round(auxData, true, round_ptr, workingArea, elements);
            round_ptr += m_;
        }

        return elements;
    }
}

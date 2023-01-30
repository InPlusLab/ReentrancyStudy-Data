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
pragma solidity ^0.4.15;

/// @title Token Register Contract
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="650e0a0b02090c040b0225090a0a15170c0b024b0a1702">[email&#160;protected]</a>>,
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f094919e99959cb09c9f9f8082999e97de9f8297">[email&#160;protected]</a>>.
library Uint8Lib {
    function xorReduce(
        uint8[] arr,
        uint    len
        )
        public
        constant
        returns (uint8 res) {

        res = arr[0];
        for (uint i = 1; i < len; i++) {
           res ^= arr[i];
        }
    }
}

/// @title Token Register Contract
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="264247484f434a664a494956544f484108495441">[email&#160;protected]</a>>.
library ErrorLib {

    event Error(string message);

    /// @dev Check if condition hold, if not, log an exception and revert.
    function orThrow(bool condition, string message) public constant {
        if (!condition) {
            error(message);
        }
    }

    function error(string message) public constant {
        Error(message);
        revert();
    }
}

/// @title Token Register Contract
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8c3c7c6cfc4c1c9c6cfe8c4c7c7d8dac1c6cf86c7dacf">[email&#160;protected]</a>>,
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b1d5d0dfd8d4ddf1dddedec1c3d8dfd69fdec3d6">[email&#160;protected]</a>>.
library Bytes32Lib {

    function xorReduce(
        bytes32[]   arr,
        uint        len
        )
        public
        constant
        returns (bytes32 res) {

        res = arr[0];
        for (uint i = 1; i < len; i++) {
            res = _xor(res, arr[i]);
        }
    }

    function _xor(
        bytes32 bs1,
        bytes32 bs2
        )
        public
        constant
        returns (bytes32 res) {

        bytes memory temp = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            temp[i] = bs1[i] ^ bs2[i];
        }
        string memory str = string(temp);
        assembly {
            res := mload(add(str, 32))
        }
    }
}

contract RinghashRegistry {
    using Bytes32Lib    for bytes32[];
    using ErrorLib      for bool;
    using Uint8Lib      for uint8[];

    uint public blocksToLive;

    struct Submission {
        address feeRecepient;
        uint block;
    }

    mapping (bytes32 => Submission) submissions;

    function RinghashRegistry(uint _blocksToLive) public {
        require(_blocksToLive > 0);
        blocksToLive = _blocksToLive;
    }

    function submitRinghash(
        uint        ringSize,
        address     feeRecepient,
        // bool        throwIfLRCIsInsuffcient,
        uint8[]     vList,
        bytes32[]   rList,
        bytes32[]   sList)
        public {
        bytes32 ringhash = calculateRinghash(
            ringSize,
            // feeRecepient,
            // throwIfLRCIsInsuffcient,
            vList,
            rList,
            sList);

        canSubmit(ringhash, feeRecepient)
            .orThrow("Ringhash submitted");

        submissions[ringhash] = Submission(feeRecepient, block.number);
    }

    function canSubmit(
        bytes32 ringhash,
        address feeRecepient
        )
        public
        constant
        returns (bool) {

        var submission = submissions[ringhash];
        return (submission.feeRecepient == address(0)
            || submission.block + blocksToLive < block.number
            || submission.feeRecepient == feeRecepient);
    }

    /// @return True if a ring&#39;s hash has ever been submitted; false otherwise.
    function ringhashFound(bytes32 ringhash)
        public
        constant
        returns (bool) {

        return submissions[ringhash].feeRecepient != address(0);
    }

    /// @dev Calculate the hash of a ring.
    function calculateRinghash(
        uint        ringSize,
        // address     feeRecepient,
        // bool        throwIfLRCIsInsuffcient,
        uint8[]     vList,
        bytes32[]   rList,
        bytes32[]   sList
        )
        public
        constant
        returns (bytes32) {

        (ringSize == vList.length - 1
            && ringSize == rList.length - 1
            && ringSize == sList.length - 1)
            .orThrow("invalid ring data");

        return keccak256(
            // feeRecepient,
            // throwIfLRCIsInsuffcient,
            vList.xorReduce(ringSize),
            rList.xorReduce(ringSize),
            sList.xorReduce(ringSize));
    }
}
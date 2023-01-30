pragma solidity ^0.5.10;

/*

https://github.com/GNSPS/solidity-bytes-utils/

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
*/


/** @title BytesLib **/
/** @author https://github.com/GNSPS **/

library BytesLib {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
                add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes_slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes_slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                        ),
                        // and now shift left the number of bytes to
                        // leave space for the length in the slot
                        exp(0x100, sub(32, newlength))
                        ),
                        // increase length by the double of the memory
                        // bytes length
                        mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                    ),
                    and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory res) {
        if (_length == 0) {
            return hex"";
        }
        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            // Alloc bytes array with additional 32 bytes afterspace and assign it's size
            res := mload(0x40)
            mstore(0x40, add(add(res, 64), _length))
            mstore(res, _length)

            // Compute distance between source and destination pointers
            let diff := sub(res, add(_bytes, _start))

            for {
                let src := add(add(_bytes, 32), _start)
                let end := add(src, _length)
            } lt(src, end) {
                src := add(src, 32)
            } {
                mstore(add(src, diff), mload(src))
            }
        }
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        uint _totalLen = _start + 20;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Address conversion out of bounds.");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        uint _totalLen = _start + 32;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Uint conversion out of bounds.");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                    // the next line is the loop condition:
                    // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function toBytes32(bytes memory _source) pure internal returns (bytes32 result) {
        if (_source.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_source, 32))
        }
    }

    function keccak256Slice(bytes memory _bytes, uint _start, uint _length) pure internal returns (bytes32 result) {
        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            result := keccak256(add(add(_bytes, 32), _start), _length)
        }
    }
}

pragma solidity ^0.5.10;

/** @title BitcoinSPV */
/** @author Summa (https://summa.one) */

import {BytesLib} from "./BytesLib.sol";
import {SafeMath} from "./SafeMath.sol";

library BTCUtils {
    using BytesLib for bytes;
    using SafeMath for uint256;

    // The target at minimum Difficulty. Also the target of the genesis block
    uint256 public constant DIFF1_TARGET = 0xffff0000000000000000000000000000000000000000000000000000;

    uint256 public constant RETARGET_PERIOD = 2 * 7 * 24 * 60 * 60;  // 2 weeks in seconds
    uint256 public constant RETARGET_PERIOD_BLOCKS = 2016;  // 2 weeks in blocks

    uint256 public constant ERR_BAD_ARG = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /* ***** */
    /* UTILS */
    /* ***** */

    /// @notice         Determines the length of a VarInt in bytes
    /// @dev            A VarInt of >1 byte is prefixed with a flag indicating its length
    /// @param _flag    The first byte of a VarInt
    /// @return         The number of non-flag bytes in the VarInt
    function determineVarIntDataLength(bytes memory _flag) internal pure returns (uint8) {
        if (uint8(_flag[0]) == 0xff) {
            return 8;  // one-byte flag, 8 bytes data
        }
        if (uint8(_flag[0]) == 0xfe) {
            return 4;  // one-byte flag, 4 bytes data
        }
        if (uint8(_flag[0]) == 0xfd) {
            return 2;  // one-byte flag, 2 bytes data
        }

        return 0;  // flag is data
    }

    /// @notice     Parse a VarInt into its data length and the number it represents
    /// @dev        Useful for Parsing Vins and Vouts. Returns ERR_BAD_ARG if insufficient bytes.
    ///             Caller SHOULD explicitly handle this case (or bubble it up)
    /// @param _b   A byte-string starting with a VarInt
    /// @return     number of bytes in the encoding (not counting the tag), the encoded int
    function parseVarInt(bytes memory _b) internal pure returns (uint256, uint256) {
        uint8 _dataLen = determineVarIntDataLength(_b);

        if (_dataLen == 0) {
            return (0, uint8(_b[0]));
        }
        if (_b.length < 1 + _dataLen) {
            return (ERR_BAD_ARG, 0);
        }
        uint256 _number = bytesToUint(reverseEndianness(_b.slice(1, _dataLen)));
        return (_dataLen, _number);
    }

    /// @notice          Changes the endianness of a byte array
    /// @dev             Returns a new, backwards, bytes
    /// @param _b        The bytes to reverse
    /// @return          The reversed bytes
    function reverseEndianness(bytes memory _b) internal pure returns (bytes memory) {
        bytes memory _newValue = new bytes(_b.length);

        for (uint i = 0; i < _b.length; i++) {
            _newValue[_b.length - i - 1] = _b[i];
        }

        return _newValue;
    }

    /// @notice          Changes the endianness of a uint256
    /// @dev             https://graphics.stanford.edu/~seander/bithacks.html#ReverseParallel
    /// @param _b        The unsigned integer to reverse
    /// @return          The reversed value
    function reverseUint256(uint256 _b) internal pure returns (uint256 v) {
        v = _b;

        // swap bytes
        v = ((v >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);
        // swap 2-byte long pairs
        v = ((v >> 16) & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);
        // swap 4-byte long pairs
        v = ((v >> 32) & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);
        // swap 8-byte long pairs
        v = ((v >> 64) & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) |
            ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);
        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }

    /// @notice          Converts big-endian bytes to a uint
    /// @dev             Traverses the byte array and sums the bytes
    /// @param _b        The big-endian bytes-encoded integer
    /// @return          The integer representation
    function bytesToUint(bytes memory _b) internal pure returns (uint256) {
        uint256 _number;

        for (uint i = 0; i < _b.length; i++) {
            _number = _number + uint8(_b[i]) * (2 ** (8 * (_b.length - (i + 1))));
        }

        return _number;
    }

    /// @notice          Get the last _num bytes from a byte array
    /// @param _b        The byte array to slice
    /// @param _num      The number of bytes to extract from the end
    /// @return          The last _num bytes of _b
    function lastBytes(bytes memory _b, uint256 _num) internal pure returns (bytes memory) {
        uint256 _start = _b.length.sub(_num);

        return _b.slice(_start, _num);
    }

    /// @notice          Implements bitcoin's hash160 (rmd160(sha2()))
    /// @dev             abi.encodePacked changes the return to bytes instead of bytes32
    /// @param _b        The pre-image
    /// @return          The digest
    function hash160(bytes memory _b) internal pure returns (bytes memory) {
        return abi.encodePacked(ripemd160(abi.encodePacked(sha256(_b))));
    }

    /// @notice          Implements bitcoin's hash256 (double sha2)
    /// @dev             abi.encodePacked changes the return to bytes instead of bytes32
    /// @param _b        The pre-image
    /// @return          The digest
    function hash256(bytes memory _b) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(sha256(_b)));
    }

    /// @notice          Implements bitcoin's hash256 (double sha2)
    /// @dev             sha2 is precompiled smart contract located at address(2)
    /// @param _b        The pre-image
    /// @return          The digest
    function hash256View(bytes memory _b) internal view returns (bytes32 res) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            pop(staticcall(gas, 2, add(_b, 32), mload(_b), ptr, 32))
            pop(staticcall(gas, 2, ptr, 32, ptr, 32))
            res := mload(ptr)
        }
    }

    /* ************ */
    /* Legacy Input */
    /* ************ */

    /// @notice          Extracts the nth input from the vin (0-indexed)
    /// @dev             Iterates over the vin. If you need to extract several, write a custom function
    /// @param _vin      The vin as a tightly-packed byte array
    /// @param _index    The 0-indexed location of the input to extract
    /// @return          The input as a byte array
    function extractInputAtIndex(bytes memory _vin, uint256 _index) internal pure returns (bytes memory) {
        uint256 _varIntDataLen;
        uint256 _nIns;

        (_varIntDataLen, _nIns) = parseVarInt(_vin);
        require(_varIntDataLen != ERR_BAD_ARG, "Read overrun during VarInt parsing");
        require(_index < _nIns, "Vin read overrun");

        bytes memory _remaining;

        uint256 _len = 0;
        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 _i = 0; _i < _index; _i ++) {
            _remaining = _vin.slice(_offset, _vin.length - _offset);
            _len = determineInputLength(_remaining);
            require(_len != ERR_BAD_ARG, "Bad VarInt in scriptSig");
            _offset = _offset + _len;
        }

        _remaining = _vin.slice(_offset, _vin.length - _offset);
        _len = determineInputLength(_remaining);
        require(_len != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _vin.slice(_offset, _len);
    }

    /// @notice          Determines whether an input is legacy
    /// @dev             False if no scriptSig, otherwise True
    /// @param _input    The input
    /// @return          True for legacy, False for witness
    function isLegacyInput(bytes memory _input) internal pure returns (bool) {
        return _input.keccak256Slice(36, 1) != keccak256(hex"00");
    }

    /// @notice          Determines the length of a scriptSig in an input
    /// @dev             Will return 0 if passed a witness input.
    /// @param _input    The LEGACY input
    /// @return          The length of the script sig
    function extractScriptSigLen(bytes memory _input) internal pure returns (uint256, uint256) {
        if (_input.length < 37) {
            return (ERR_BAD_ARG, 0);
        }
        bytes memory _afterOutpoint = _input.slice(36, _input.length - 36);

        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = parseVarInt(_afterOutpoint);

        return (_varIntDataLen, _scriptSigLen);
    }

    /// @notice          Determines the length of an input from its scriptSig
    /// @dev             36 for outpoint, 1 for scriptSig length, 4 for sequence
    /// @param _input    The input
    /// @return          The length of the input in bytes
    function determineInputLength(bytes memory _input) internal pure returns (uint256) {
        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        if (_varIntDataLen == ERR_BAD_ARG) {
            return ERR_BAD_ARG;
        }

        return 36 + 1 + _varIntDataLen + _scriptSigLen + 4;
    }

    /// @notice          Extracts the LE sequence bytes from an input
    /// @dev             Sequence is used for relative time locks
    /// @param _input    The LEGACY input
    /// @return          The sequence bytes (LE uint)
    function extractSequenceLELegacy(bytes memory _input) internal pure returns (bytes memory) {
        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        require(_varIntDataLen != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _input.slice(36 + 1 + _varIntDataLen + _scriptSigLen, 4);
    }

    /// @notice          Extracts the sequence from the input
    /// @dev             Sequence is a 4-byte little-endian number
    /// @param _input    The LEGACY input
    /// @return          The sequence number (big-endian uint)
    function extractSequenceLegacy(bytes memory _input) internal pure returns (uint32) {
        bytes memory _leSeqence = extractSequenceLELegacy(_input);
        bytes memory _beSequence = reverseEndianness(_leSeqence);
        return uint32(bytesToUint(_beSequence));
    }
    /// @notice          Extracts the VarInt-prepended scriptSig from the input in a tx
    /// @dev             Will return hex"00" if passed a witness input
    /// @param _input    The LEGACY input
    /// @return          The length-prepended scriptSig
    function extractScriptSig(bytes memory _input) internal pure returns (bytes memory) {
        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        require(_varIntDataLen != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _input.slice(36, 1 + _varIntDataLen + _scriptSigLen);
    }


    /* ************* */
    /* Witness Input */
    /* ************* */

    /// @notice          Extracts the LE sequence bytes from an input
    /// @dev             Sequence is used for relative time locks
    /// @param _input    The WITNESS input
    /// @return          The sequence bytes (LE uint)
    function extractSequenceLEWitness(bytes memory _input) internal pure returns (bytes memory) {
        return _input.slice(37, 4);
    }

    /// @notice          Extracts the sequence from the input in a tx
    /// @dev             Sequence is a 4-byte little-endian number
    /// @param _input    The WITNESS input
    /// @return          The sequence number (big-endian uint)
    function extractSequenceWitness(bytes memory _input) internal pure returns (uint32) {
        bytes memory _leSeqence = extractSequenceLEWitness(_input);
        bytes memory _inputeSequence = reverseEndianness(_leSeqence);
        return uint32(bytesToUint(_inputeSequence));
    }

    /// @notice          Extracts the outpoint from the input in a tx
    /// @dev             32-byte tx id with 4-byte index
    /// @param _input    The input
    /// @return          The outpoint (LE bytes of prev tx hash + LE bytes of prev tx index)
    function extractOutpoint(bytes memory _input) internal pure returns (bytes memory) {
        return _input.slice(0, 36);
    }

    /// @notice          Extracts the outpoint tx id from an input
    /// @dev             32-byte tx id
    /// @param _input    The input
    /// @return          The tx id (little-endian bytes)
    function extractInputTxIdLE(bytes memory _input) internal pure returns (bytes32) {
        return _input.slice(0, 32).toBytes32();
    }

    /// @notice          Extracts the LE tx input index from the input in a tx
    /// @dev             4-byte tx index
    /// @param _input    The input
    /// @return          The tx index (little-endian bytes)
    function extractTxIndexLE(bytes memory _input) internal pure returns (bytes memory) {
        return _input.slice(32, 4);
    }

    /* ****** */
    /* Output */
    /* ****** */

    /// @notice          Determines the length of an output
    /// @dev             Works with any properly formatted output
    /// @param _output   The output
    /// @return          The length indicated by the prefix, error if invalid length
    function determineOutputLength(bytes memory _output) internal pure returns (uint256) {
        if (_output.length < 9) {
            return ERR_BAD_ARG;
        }
        bytes memory _afterValue = _output.slice(8, _output.length - 8);

        uint256 _varIntDataLen;
        uint256 _scriptPubkeyLength;
        (_varIntDataLen, _scriptPubkeyLength) = parseVarInt(_afterValue);

        if (_varIntDataLen == ERR_BAD_ARG) {
            return ERR_BAD_ARG;
        }

        // 8-byte value, 1-byte for tag itself
        return 8 + 1 + _varIntDataLen + _scriptPubkeyLength;
    }

    /// @notice          Extracts the output at a given index in the TxOuts vector
    /// @dev             Iterates over the vout. If you need to extract multiple, write a custom function
    /// @param _vout     The _vout to extract from
    /// @param _index    The 0-indexed location of the output to extract
    /// @return          The specified output
    function extractOutputAtIndex(bytes memory _vout, uint256 _index) internal pure returns (bytes memory) {
        uint256 _varIntDataLen;
        uint256 _nOuts;

        (_varIntDataLen, _nOuts) = parseVarInt(_vout);
        require(_varIntDataLen != ERR_BAD_ARG, "Read overrun during VarInt parsing");
        require(_index < _nOuts, "Vout read overrun");

        bytes memory _remaining;

        uint256 _len = 0;
        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 _i = 0; _i < _index; _i ++) {
            _remaining = _vout.slice(_offset, _vout.length - _offset);
            _len = determineOutputLength(_remaining);
            require(_len != ERR_BAD_ARG, "Bad VarInt in scriptPubkey");
            _offset += _len;
        }

        _remaining = _vout.slice(_offset, _vout.length - _offset);
        _len = determineOutputLength(_remaining);
        require(_len != ERR_BAD_ARG, "Bad VarInt in scriptPubkey");
        return _vout.slice(_offset, _len);
    }

    /// @notice          Extracts the value bytes from the output in a tx
    /// @dev             Value is an 8-byte little-endian number
    /// @param _output   The output
    /// @return          The output value as LE bytes
    function extractValueLE(bytes memory _output) internal pure returns (bytes memory) {
        return _output.slice(0, 8);
    }

    /// @notice          Extracts the value from the output in a tx
    /// @dev             Value is an 8-byte little-endian number
    /// @param _output   The output
    /// @return          The output value
    function extractValue(bytes memory _output) internal pure returns (uint64) {
        bytes memory _leValue = extractValueLE(_output);
        bytes memory _beValue = reverseEndianness(_leValue);
        return uint64(bytesToUint(_beValue));
    }

    /// @notice          Extracts the data from an op return output
    /// @dev             Returns hex"" if no data or not an op return
    /// @param _output   The output
    /// @return          Any data contained in the opreturn output, null if not an op return
    function extractOpReturnData(bytes memory _output) internal pure returns (bytes memory) {
        if (_output.keccak256Slice(9, 1) != keccak256(hex"6a")) {
            return hex"";
        }
        bytes memory _dataLen = _output.slice(10, 1);
        return _output.slice(11, bytesToUint(_dataLen));
    }

    /// @notice          Extracts the hash from the output script
    /// @dev             Determines type by the length prefix and validates format
    /// @param _output   The output
    /// @return          The hash committed to by the pk_script, or null for errors
    function extractHash(bytes memory _output) internal pure returns (bytes memory) {
        uint8 _scriptLen = uint8(_output[8]);

        // don't have to worry about overflow here.
        // if _scriptLen + 9 overflows, then output.length would have to be < 9
        // for this check to pass. if it's < 9, then we errored when assigning
        // _scriptLen
        if (_scriptLen + 9 != _output.length) {
            return hex"";
        }

        if (uint8(_output[9]) == 0) {
            if (_scriptLen < 2) {
                return hex"";
            }
            uint256 _payloadLen = uint8(_output[10]);
            // Check for maliciously formatted witness outputs.
            // No need to worry about underflow as long b/c of the `< 2` check
            if (_payloadLen != _scriptLen - 2 || (_payloadLen != 0x20 && _payloadLen != 0x14)) {
                return hex"";
            }
            return _output.slice(11, _payloadLen);
        } else {
            bytes32 _tag = _output.keccak256Slice(8, 3);
            // p2pkh
            if (_tag == keccak256(hex"1976a9")) {
                // Check for maliciously formatted p2pkh
                // No need to worry about underflow, b/c of _scriptLen check
                if (uint8(_output[11]) != 0x14 ||
                    _output.keccak256Slice(_output.length - 2, 2) != keccak256(hex"88ac")) {
                    return hex"";
                }
                return _output.slice(12, 20);
            //p2sh
            } else if (_tag == keccak256(hex"17a914")) {
                // Check for maliciously formatted p2sh
                // No need to worry about underflow, b/c of _scriptLen check
                if (uint8(_output[_output.length - 1]) != 0x87) {
                    return hex"";
                }
                return _output.slice(11, 20);
            }
        }
        return hex"";  /* NB: will trigger on OPRETURN and any non-standard that doesn't overrun */
    }

    /* ********** */
    /* Witness TX */
    /* ********** */


    /// @notice      Checks that the vin passed up is properly formatted
    /// @dev         Consider a vin with a valid vout in its scriptsig
    /// @param _vin  Raw bytes length-prefixed input vector
    /// @return      True if it represents a validly formatted vin
    function validateVin(bytes memory _vin) internal pure returns (bool) {
        uint256 _varIntDataLen;
        uint256 _nIns;

        (_varIntDataLen, _nIns) = parseVarInt(_vin);

        // Not valid if it says there are too many or no inputs
        if (_nIns == 0 || _varIntDataLen == ERR_BAD_ARG) {
            return false;
        }

        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 i = 0; i < _nIns; i++) {
            // If we're at the end, but still expect more
            if (_offset >= _vin.length) {
                return false;
            }

            // Grab the next input and determine its length.
            bytes memory _next = _vin.slice(_offset, _vin.length - _offset);
            uint256 _nextLen = determineInputLength(_next);
            if (_nextLen == ERR_BAD_ARG) {
                return false;
            }

            // Increase the offset by that much
            _offset += _nextLen;
        }

        // Returns false if we're not exactly at the end
        return _offset == _vin.length;
    }

    /// @notice      Checks that the vout passed up is properly formatted
    /// @dev         Consider a vout with a valid scriptpubkey
    /// @param _vout Raw bytes length-prefixed output vector
    /// @return      True if it represents a validly formatted vout
    function validateVout(bytes memory _vout) internal pure returns (bool) {
        uint256 _varIntDataLen;
        uint256 _nOuts;

        (_varIntDataLen, _nOuts) = parseVarInt(_vout);

        // Not valid if it says there are too many or no outputs
        if (_nOuts == 0 || _varIntDataLen == ERR_BAD_ARG) {
            return false;
        }

        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 i = 0; i < _nOuts; i++) {
            // If we're at the end, but still expect more
            if (_offset >= _vout.length) {
                return false;
            }

            // Grab the next output and determine its length.
            // Increase the offset by that much
            bytes memory _next = _vout.slice(_offset, _vout.length - _offset);
            uint256 _nextLen = determineOutputLength(_next);
            if (_nextLen == ERR_BAD_ARG) {
                return false;
            }

            _offset += _nextLen;
        }

        // Returns false if we're not exactly at the end
        return _offset == _vout.length;
    }



    /* ************ */
    /* Block Header */
    /* ************ */

    /// @notice          Extracts the transaction merkle root from a block header
    /// @dev             Use verifyHash256Merkle to verify proofs with this root
    /// @param _header   The header
    /// @return          The merkle root (little-endian)
    function extractMerkleRootLE(bytes memory _header) internal pure returns (bytes memory) {
        return _header.slice(36, 32);
    }

    /// @notice          Extracts the target from a block header
    /// @dev             Target is a 256-bit number encoded as a 3-byte mantissa and 1-byte exponent
    /// @param _header   The header
    /// @return          The target threshold
    function extractTarget(bytes memory _header) internal pure returns (uint256) {
        bytes memory _m = _header.slice(72, 3);
        uint8 _e = uint8(_header[75]);
        uint256 _mantissa = bytesToUint(reverseEndianness(_m));
        uint _exponent = _e - 3;

        return _mantissa * (256 ** _exponent);
    }

    /// @notice          Calculate difficulty from the difficulty 1 target and current target
    /// @dev             Difficulty 1 is 0x1d00ffff on mainnet and testnet
    /// @dev             Difficulty 1 is a 256-bit number encoded as a 3-byte mantissa and 1-byte exponent
    /// @param _target   The current target
    /// @return          The block difficulty (bdiff)
    function calculateDifficulty(uint256 _target) internal pure returns (uint256) {
        // Difficulty 1 calculated from 0x1d00ffff
        return DIFF1_TARGET.div(_target);
    }

    /// @notice          Extracts the previous block's hash from a block header
    /// @dev             Block headers do NOT include block number :(
    /// @param _header   The header
    /// @return          The previous block's hash (little-endian)
    function extractPrevBlockLE(bytes memory _header) internal pure returns (bytes memory) {
        return _header.slice(4, 32);
    }

    /// @notice          Extracts the timestamp from a block header
    /// @dev             Time is not 100% reliable
    /// @param _header   The header
    /// @return          The timestamp (little-endian bytes)
    function extractTimestampLE(bytes memory _header) internal pure returns (bytes memory) {
        return _header.slice(68, 4);
    }

    /// @notice          Extracts the timestamp from a block header
    /// @dev             Time is not 100% reliable
    /// @param _header   The header
    /// @return          The timestamp (uint)
    function extractTimestamp(bytes memory _header) internal pure returns (uint32) {
        return uint32(bytesToUint(reverseEndianness(extractTimestampLE(_header))));
    }

    /// @notice          Extracts the expected difficulty from a block header
    /// @dev             Does NOT verify the work
    /// @param _header   The header
    /// @return          The difficulty as an integer
    function extractDifficulty(bytes memory _header) internal pure returns (uint256) {
        return calculateDifficulty(extractTarget(_header));
    }

    /// @notice          Concatenates and hashes two inputs for merkle proving
    /// @param _a        The first hash
    /// @param _b        The second hash
    /// @return          The double-sha256 of the concatenated hashes
    function _hash256MerkleStep(bytes memory _a, bytes memory _b) internal pure returns (bytes32) {
        return hash256(abi.encodePacked(_a, _b));
    }

    /// @notice          Verifies a Bitcoin-style merkle tree
    /// @dev             Leaves are 0-indexed.
    /// @param _proof    The proof. Tightly packed LE sha256 hashes. The last hash is the root
    /// @param _index    The index of the leaf
    /// @return          true if the proof is valid, else false
    function verifyHash256Merkle(bytes memory _proof, uint _index) internal pure returns (bool) {
        // Not an even number of hashes
        if (_proof.length % 32 != 0) {
            return false;
        }

        // Special case for coinbase-only blocks
        if (_proof.length == 32) {
            return true;
        }

        // Should never occur
        if (_proof.length == 64) {
            return false;
        }

        uint _idx = _index;
        bytes32 _root = _proof.slice(_proof.length - 32, 32).toBytes32();
        bytes32 _current = _proof.slice(0, 32).toBytes32();

        for (uint i = 1; i < (_proof.length.div(32)) - 1; i++) {
            if (_idx % 2 == 1) {
                _current = _hash256MerkleStep(_proof.slice(i * 32, 32), abi.encodePacked(_current));
            } else {
                _current = _hash256MerkleStep(abi.encodePacked(_current), _proof.slice(i * 32, 32));
            }
            _idx = _idx >> 1;
        }
        return _current == _root;
    }

    /*
    NB: https://github.com/bitcoin/bitcoin/blob/78dae8caccd82cfbfd76557f1fb7d7557c7b5edb/src/pow.cpp#L49-L72
    NB: We get a full-bitlength target from this. For comparison with
        header-encoded targets we need to mask it with the header target
        e.g. (full & truncated) == truncated
    */
    /// @notice                 performs the bitcoin difficulty retarget
    /// @dev                    implements the Bitcoin algorithm precisely
    /// @param _previousTarget  the target of the previous period
    /// @param _firstTimestamp  the timestamp of the first block in the difficulty period
    /// @param _secondTimestamp the timestamp of the last block in the difficulty period
    /// @return                 the new period's target threshold
    function retargetAlgorithm(
        uint256 _previousTarget,
        uint256 _firstTimestamp,
        uint256 _secondTimestamp
    ) internal pure returns (uint256) {
        uint256 _elapsedTime = _secondTimestamp.sub(_firstTimestamp);

        // Normalize ratio to factor of 4 if very long or very short
        if (_elapsedTime < RETARGET_PERIOD.div(4)) {
            _elapsedTime = RETARGET_PERIOD.div(4);
        }
        if (_elapsedTime > RETARGET_PERIOD.mul(4)) {
            _elapsedTime = RETARGET_PERIOD.mul(4);
        }

        /*
          NB: high targets e.g. ffff0020 can cause overflows here
              so we divide it by 256**2, then multiply by 256**2 later
              we know the target is evenly divisible by 256**2, so this isn't an issue
        */

        uint256 _adjusted = _previousTarget.div(65536).mul(_elapsedTime);
        return _adjusted.div(RETARGET_PERIOD).mul(65536);
    }
}

pragma solidity ^0.5.10;

/// @title      ISPVConsumer
/// @author     Summa (https://summa.one)
/// @notice     This interface consumes validated transaction information.
///             It is the primary way that user contracts accept
/// @dev        Implement this interface to process transactions provided by
///             the Relay system.
interface ISPVConsumer {
    /// @notice     A consumer for Bitcoin transaction information.
    /// @dev        Users must implement this function. It handles Bitcoin
    ///             events that have been validated by the Relay contract.
    ///             It is VERY IMPORTANT that this function validates the
    ///             msg.sender. The callee must check the origin of the data
    ///             or risk accepting spurious information.
    /// @param _txid        The LE(!) txid of the bitcoin transaction that
    ///                     triggered the notification.
    /// @param _vin         The length-prefixed input vector of the bitcoin tx
    ///                     that triggered the notification.
    /// @param _vout        The length-prefixed output vector of the bitcoin tx
    ///                     that triggered the notification.
    /// @param _requestID   The ID of the event request that this notification
    ///                     satisfies. The ID is returned by
    ///                     OnDemandSPV.request and should be locally stored by
    ///                     any contract that makes more than one request.
    /// @param _inputIndex  The index of the input in the _vin that triggered
    ///                     the notification.
    /// @param _outputIndex The index of the output in the _vout that triggered
    ///                     the notification. Useful for subscribing to transactions
    ///                     that spend the newly-created UTXO.
    function spv(
        bytes32 _txid,
        bytes calldata _vin,
        bytes calldata _vout,
        uint256 _requestID,
        uint8 _inputIndex,
        uint8 _outputIndex) external;
}

/// @title      ISPVRequestManager
/// @author     Summa (https://summa.one)
/// @notice     The interface for using the OnDemandSPV system. This interface
///             allows you to subscribe to Bitcoin events.
/// @dev        Manage subscriptions to Bitcoin events. Register callbacks to
///             be called whenever specific Bitcoin transactions are made.
interface ISPVRequestManager {
    event NewProofRequest (
        address indexed _requester,
        uint256 indexed _requestID,
        uint64 _paysValue,
        bytes _spends,
        bytes _pays
    );

    event RequestClosed(uint256 indexed _requestID);
    event RequestFilled(bytes32 indexed _txid, uint256 indexed _requestID);

    /// @notice             Subscribe to a feed of Bitcoin transactions matching a request
    /// @dev                The request can be a spent utxo and/or a created utxo.
    ///
    ///                     The contract allows users to register a "consumer" contract
    ///                     that implements ISPVConsumer to handle Bitcoin events.
    ///
    ///                     Bitcoin transactions are composed of a vector of inputs,
    ///                     and a vector of outputs. The `_spends` parameter allows consumers
    ///                     to watch a specific UTXO, and receive an event when it is spent.
    ///
    ///                     The `_pays` and `_paysValue` param allow the user to watch specific
    ///                     Bitcoin output scripts. An output script is typically encoded
    ///                     as an address, but an address is not an in-protocol construction.
    ///                     In other words, consumers will receive an event whenever a specific
    ///                     address receives funds, or when a specific OP_RETURN is created.
    ///
    ///                     Either `_spends` or `_pays` MUST be set. Both MAY be set.
    ///                     If both are set, only notifications meeting both criteria
    ///                     will be triggered.
    ///
    /// @param  _spends     An outpoint that must be spent in acceptable transactions.
    ///                     The outpoint must be exactly 36 bytes, and composed of a
    ///                     LE txid (32 bytes), and an 4-byte LE-encoded index integer.
    ///                     In other words, the precise serialization format used in a
    ///                     serialized Bitcoin TxIn.
    ///
    ///                     Note that while we might expect a `_spends` event to fire at most
    ///                     one time, that expectation becomes invalid in long Bitcoin reorgs
    ///                     if there is a double-spend or a disconfirmation followed by
    ///                     reconfirmation.
    ///
    /// @param  _pays       An output script to watch for events. A filter with `_pays` set will
    ///                     validate any number of events that create new UTXOs with a specific
    ///                     output script.
    ///
    ///                     This is useful for watching an address and responding to incoming
    ///                     payments.
    ///
    /// @param  _paysValue  A minimum value in satoshi that must be paid to the output script.
    ///                     If this is set no any non-0 number, the Relay will only forward
    ///                     `_pays` notifications to the consumer if the value of the new UTXO is
    ///                     at least `_paysValue`.
    ///
    /// @param  _consumer   The address of a contract that implements the `ISPVConsumer` interface.
    ///                     Whenever events are available, the Relay will validate inclusion
    ///                     and confirmation, then call the `spv` function on the consumer.
    ///
    /// @param  _numConfs   The number of headers that must confirm the block
    ///                     containing the transaction. Used as a security parameter.
    ///                     More confirmations means less likely to revert due to a
    ///                     chain reorganization. Note that 1 confirmation is required,
    ///                     so the general "6 confirmation" rule would be expressed
    ///                     as `5` when calling this function
    ///
    /// @param  _notBefore  An Ethereum timestamp before which proofs will not be accepted.
    ///                     Used to control app flow for specific users.
    ///
    /// @return             A unique request ID.
    function request(
        bytes calldata _spends,
        bytes calldata _pays,
        uint64 _paysValue,
        address _consumer,
        uint8 _numConfs,
        uint256 _notBefore
    ) external returns (uint256);

    /// @notice                 Cancel an active bitcoin event request.
    /// @dev                    Prevents the relay from forwarding tx information
    /// @param  _requestID      The ID of the request to be cancelled
    /// @return                 True if succesful, error otherwise
    function cancelRequest(uint256 _requestID) external returns (bool);

    /// @notice             Retrieve info about a request
    /// @dev                Requests ids are numerical
    /// @param  _requestID  The numerical ID of the request
    /// @return             A tuple representation of the request struct.
    ///                     To save space`spends` and `pays` are stored as keccak256
    ///                     hashes of the original information. The `state` is
    ///                     `0` for "does not exist", `1` for "active" and `2` for
    ///                     "cancelled."
    function getRequest(
        uint256 _requestID
    ) external view returns (
        bytes32 spends,
        bytes32 pays,
        uint64 paysValue,
        uint8 state,
        address consumer,
        address owner,
        uint8 numConfs,
        uint256 notBefore
    );
}



interface IRelay {
    event Extension(bytes32 indexed _first, bytes32 indexed _last);
    event NewTip(bytes32 indexed _from, bytes32 indexed _to, bytes32 indexed _gcd);

    function getCurrentEpochDifficulty() external view returns (uint256);
    function getPrevEpochDifficulty() external view returns (uint256);
    function getRelayGenesis() external view returns (bytes32);
    function getBestKnownDigest() external view returns (bytes32);
    function getLastReorgCommonAncestor() external view returns (bytes32);

    function findHeight(bytes32 _digest) external view returns (uint256);

    function findAncestor(bytes32 _digest, uint256 _offset) external view returns (bytes32);

    function isAncestor(bytes32 _ancestor, bytes32 _descendant, uint256 _limit) external view returns (bool);

    function addHeaders(bytes calldata _anchor, bytes calldata _headers) external returns (bool);

    function addHeadersWithRetarget(
        bytes calldata _oldPeriodStartHeader,
        bytes calldata _oldPeriodEndHeader,
        bytes calldata _headers
    ) external returns (bool);

    function markNewHeaviest(
        bytes32 _ancestor,
        bytes calldata _currentBest,
        bytes calldata _newBest,
        uint256 _limit
    ) external returns (bool);
}

pragma solidity ^0.5.10;

/*
The MIT License (MIT)

Copyright (c) 2016 Smart Contract Solutions, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        require(c / _a == _b, "Overflow during multiplication.");
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, "Underflow during subtraction.");
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        require(c >= _a, "Overflow during addition.");
        return c;
    }
}

pragma solidity ^0.5.10;

/** @title OnDemandSPV */
/** @author Summa (https://summa.one) */

import {Relay} from "./Relay.sol";
import {ISPVRequestManager, ISPVConsumer} from "./Interfaces.sol";
import {BytesLib} from "@summa-tx/bitcoin-spv-sol/contracts/BytesLib.sol";
import {BTCUtils} from "@summa-tx/bitcoin-spv-sol/contracts/BTCUtils.sol";
import {ValidateSPV} from "@summa-tx/bitcoin-spv-sol/contracts/ValidateSPV.sol";
import {SafeMath} from "@summa-tx/bitcoin-spv-sol/contracts/SafeMath.sol";


contract OnDemandSPV is ISPVRequestManager, Relay {
    using SafeMath for uint256;
    using BytesLib for bytes;
    using BTCUtils for bytes;

    struct ProofRequest {
        bytes32 spends;
        bytes32 pays;
        uint256 notBefore;
        address consumer;
        uint64 paysValue;
        uint8 numConfs;
        address owner;
        RequestStates state;
    }

    enum RequestStates { NONE, ACTIVE, CLOSED }
    mapping (bytes32 => bool) internal validatedTxns;  // authenticated tx store
    mapping (uint256 => ProofRequest) internal requests;  // request info
    uint256 public constant BASE_COST = 24 * 60 * 60;  // 1 day

    uint256 public nextID;
    bytes32 public latestValidatedTx;
    uint256 public remoteGasAllowance = 500000; // maximum gas for callback call

    /// @notice                   Gives a starting point for the relay
    /// @dev                      We don't check this AT ALL really. Don't use relays with bad genesis
    /// @param  _genesisHeader    The starting header
    /// @param  _height           The starting height
    /// @param  _periodStart      The hash of the first header in the genesis epoch
    constructor(
        bytes memory _genesisHeader,
        uint256 _height,
        bytes32 _periodStart,
        uint256 _firstID
    ) Relay(
        _genesisHeader,
        _height,
        _periodStart
    ) public {
        nextID = _firstID;
    }

    /// @notice                 Cancel a bitcoin event request.
    /// @dev                    Prevents the relay from forwarding tx infromation
    /// @param  _requestID      The ID of the request to be cancelled
    /// @return                 True if succesful, error otherwise
    function cancelRequest(uint256 _requestID) external returns (bool) {
        ProofRequest storage _req = requests[_requestID];
        require(_req.state == RequestStates.ACTIVE, "Request not active");
        require(msg.sender == _req.consumer || msg.sender == _req.owner, "Can only be cancelled by owner or consumer");
        _req.state = RequestStates.CLOSED;
        emit RequestClosed(_requestID);
        return true;
    }

    function getLatestValidatedTx() external view returns (bytes32) {
        return latestValidatedTx;
    }

    /// @notice             Retrieve info about a request
    /// @dev                Requests ids are numerical
    /// @param  _requestID  The numerical ID of the request
    /// @return             A tuple representation of the request struct
    function getRequest(
        uint256 _requestID
    ) external view returns (
        bytes32 spends,
        bytes32 pays,
        uint64 paysValue,
        uint8 state,
        address consumer,
        address owner,
        uint8 numConfs,
        uint256 notBefore
    ) {
        ProofRequest storage _req = requests[_requestID];
        spends = _req.spends;
        pays = _req.pays;
        paysValue = _req.paysValue;
        state = uint8(_req.state);
        consumer = _req.consumer;
        owner = _req.owner;
        numConfs = _req.numConfs;
        notBefore = _req.notBefore;
    }

    /// @notice                 Subscribe to a feed of Bitcoin txns matching a request
    /// @dev                    The request can be a spent utxo and/or a created utxo
    /// @param  _spends         An outpoint that must be spent in acceptable txns (optional)
    /// @param  _pays           An output script that must be paid in acceptable txns (optional)
    /// @param  _paysValue      A minimum value that must be paid to the output script (optional)
    /// @param  _consumer       The address of a ISPVConsumer exposing spv
    /// @param  _numConfs       The minimum number of Bitcoin confirmations to accept
    /// @param  _notBefore      A timestamp before which proofs are not accepted
    /// @return                 A unique request ID.
    function request(
        bytes calldata _spends,
        bytes calldata _pays,
        uint64 _paysValue,
        address _consumer,
        uint8 _numConfs,
        uint256 _notBefore
    ) external returns (uint256) {
        return _request(_spends, _pays, _paysValue, _consumer, _numConfs, _notBefore);
    }

    /// @notice                 Subscribe to a feed of Bitcoin txns matching a request
    /// @dev                    The request can be a spent utxo and/or a created utxo
    /// @param  _spends         An outpoint that must be spent in acceptable txns (optional)
    /// @param  _pays           An output script that must be paid in acceptable txns (optional)
    /// @param  _paysValue      A minimum value that must be paid to the output script (optional)
    /// @param  _consumer       The address of a ISPVConsumer exposing spv
    /// @param  _numConfs       The minimum number of Bitcoin confirmations to accept
    /// @param  _notBefore      A timestamp before which proofs are not accepted
    /// @return                 A unique request ID
    function _request(
        bytes memory _spends,
        bytes memory _pays,
        uint64 _paysValue,
        address _consumer,
        uint8 _numConfs,
        uint256 _notBefore
    ) internal returns (uint256) {
        uint256 _requestID = nextID;
        nextID = nextID + 1;
        bytes memory pays = _pays;

        require(_spends.length == 36 || _spends.length == 0, "Not a valid UTXO");

        /* NB: This will fail if the output is not p2pkh, p2sh, p2wpkh, or p2wsh*/
        uint256 _paysLen = pays.length;

        // if it's not length-prefixed, length-prefix it
        if (_paysLen > 0 && uint8(pays[0]) != _paysLen - 1) {
            pays = abi.encodePacked(uint8(_paysLen), pays);
            _paysLen += 1; // update the length because we made it longer
        }

        bytes memory _p = abi.encodePacked(bytes8(0), pays);
        require(
            _paysLen == 0 ||  // no request OR
            _p.extractHash().length > 0 || // standard output OR
            _p.extractOpReturnData().length > 0, // OP_RETURN output
            "Not a standard output type");

        require(_spends.length > 0 || _paysLen > 0, "No request specified");

        ProofRequest storage _req = requests[_requestID];
        _req.owner = msg.sender;

        if (_spends.length > 0) {
            _req.spends = keccak256(_spends);
        }
        if (_paysLen > 0) {
            _req.pays = keccak256(pays);
        }
        if (_paysValue > 0) {
            _req.paysValue = _paysValue;
        }
        if (_numConfs > 0 && _numConfs < 241) { //241 is arbitray. 40 hours
            _req.numConfs = _numConfs;
        }
        if (_notBefore > 0) {
            _req.notBefore = _notBefore;
        }
        _req.consumer = _consumer;
        _req.state = RequestStates.ACTIVE;

        emit NewProofRequest(msg.sender, _requestID, _paysValue, _spends, pays);

        return _requestID;
    }

    /// @notice                 Provide a proof of a tx that satisfies some request
    /// @dev                    The caller must specify which inputs, which outputs, and which request
    /// @param  _header         The header containing the merkleroot committing to the tx
    /// @param  _proof          The merkle proof intermediate nodes
    /// @param  _version        The tx version, always the first 4 bytes of the tx
    /// @param  _locktime       The tx locktime, always the last 4 bytes of the tx
    /// @param  _index          The index of the tx in the merkle tree's leaves
    /// @param  _reqIndices  The input and output index to check against the request, packed
    /// @param  _vin            The tx input vector
    /// @param  _vout           The tx output vector
    /// @param  _requestID       The id of the request that has been triggered
    /// @return                 True if succesful, error otherwise
    function provideProof(
        bytes calldata _header,
        bytes calldata _proof,
        bytes4 _version,
        bytes4 _locktime,
        uint256 _index,
        uint16 _reqIndices,
        bytes calldata _vin,
        bytes calldata _vout,
        uint256 _requestID
    ) external returns (bool) {
        bytes32 _txid = abi.encodePacked(_version, _vin, _vout, _locktime).hash256();
        /*
        NB: this shortcuts validation of any txn we've seen before
            repeats can omit header, proof, and index
        */
        if (!validatedTxns[_txid]) {
            _checkInclusion(
                _header,
                _proof,
                _index,
                _txid,
                _requestID);
            validatedTxns[_txid] = true;
            latestValidatedTx = _txid;
        }
        _checkRequests(_reqIndices, _vin, _vout, _requestID);
        _callCallback(_txid, _reqIndices, _vin, _vout, _requestID);
        return true;
    }

    /// @notice             Notify a consumer that one of its requests has been triggered
    /// @dev                We include information about the tx that triggered it, so the consumer can take actions
    /// @param  _vin        The tx input vector
    /// @param  _vout       The tx output vector
    /// @param  _txid       The transaction ID
    /// @param  _requestID   The id of the request that has been triggered
    function _callCallback(
        bytes32 _txid,
        uint16 _reqIndices,
        bytes memory _vin,
        bytes memory _vout,
        uint256 _requestID
    ) internal returns (bool) {
        ProofRequest storage _req = requests[_requestID];
        ISPVConsumer c = ISPVConsumer(_req.consumer);

        uint8 _inputIndex = uint8(_reqIndices >> 8);
        uint8 _outputIndex = uint8(_reqIndices & 0xff);

        /*
        NB:
        We want to make the remote call, but we don't care about results
        We use the low-level call so that we can ignore reverts and set gas
        */
        address(c).call.gas(remoteGasAllowance)(
            abi.encodePacked(
                c.spv.selector,
                abi.encode(_txid, _vin, _vout, _requestID, _inputIndex, _outputIndex)
            )
        );

        emit RequestFilled(_txid, _requestID);

        return true;
    }

    /// @notice             Verifies inclusion of a tx in a header, and that header in the Relay chain
    /// @dev                Specifically we check that both the best tip and the heaviest common header confirm it
    /// @param  _header     The header containing the merkleroot committing to the tx
    /// @param  _proof      The merkle proof intermediate nodes
    /// @param  _index      The index of the tx in the merkle tree's leaves
    /// @param  _txid       The txid that is the proof leaf
    /// @param _requestID   The ID of the request to check against
    function _checkInclusion(
        bytes memory _header,
        bytes memory _proof,
        uint256 _index,
        bytes32 _txid,
        uint256 _requestID
    ) internal view returns (bool) {
        require(
            ValidateSPV.prove(
                _txid,
                _header.extractMerkleRootLE().toBytes32(),
                _proof,
                _index),
            "Bad inclusion proof");

        bytes32 _headerHash = _header.hash256();
        bytes32 _GCD = getLastReorgCommonAncestor();

        require(
            _isAncestor(
                _headerHash,
                _GCD,
                240),
            "GCD does not confirm header");
        uint8 _numConfs = requests[_requestID].numConfs;
        require(
            _getConfs(_headerHash) >= _numConfs,
            "Insufficient confirmations");

        return true;
    }

    /// @notice             Finds the number of headers on top of the argument
    /// @dev                Bounded to 6400 gas (8 looksups) max
    /// @param _headerHash  The LE double-sha2 header hash
    /// @return             The number of headers on top
    function _getConfs(bytes32 _headerHash) internal view returns (uint8) {
        return uint8(_findHeight(bestKnownDigest) - _findHeight(_headerHash));
    }

    /// @notice                 Verifies that a tx meets the requester's request
    /// @dev                    Requests can be specify an input, and output, and/or an output value
    /// @param  _reqIndices  The input and output index to check against the request, packed
    /// @param  _vin            The tx input vector
    /// @param  _vout           The tx output vector
    /// @param  _requestID       The id of the request to check
    function _checkRequests (
        uint16 _reqIndices,
        bytes memory _vin,
        bytes memory _vout,
        uint256 _requestID
    ) internal view returns (bool) {
        require(_vin.validateVin(), "Vin is malformatted");
        require(_vout.validateVout(), "Vout is malformatted");

        uint8 _inputIndex = uint8(_reqIndices >> 8);
        uint8 _outputIndex = uint8(_reqIndices & 0xff);

        ProofRequest storage _req = requests[_requestID];
        require(_req.notBefore <= block.timestamp, "Request is submitted too early");
        require(_req.state == RequestStates.ACTIVE, "Request is not active");

        bytes32 _pays = _req.pays;
        bool _hasPays = _pays != bytes32(0);
        if (_hasPays) {
            bytes memory _out = _vout.extractOutputAtIndex(uint8(_outputIndex));
            bytes memory _scriptPubkey = _out.slice(8, _out.length - 8);
            require(
                keccak256(_scriptPubkey) == _pays,
                "Does not match pays request");
            uint64 _paysValue = _req.paysValue;
            require(
                _paysValue == 0 ||
                _out.extractValue() >= _paysValue,
                "Does not match value request");
        }

        bytes32 _spends = _req.spends;
        bool _hasSpends = _spends != bytes32(0);
        if (_hasSpends) {
            bytes memory _in = _vin.extractInputAtIndex(uint8(_inputIndex));
            require(
                !_hasSpends ||
                keccak256(_in.extractOutpoint()) == _spends,
                "Does not match spends request");
        }
        return true;
    }
}

pragma solidity ^0.5.10;

/** @title Relay */
/** @author Summa (https://summa.one) */

import {SafeMath} from "@summa-tx/bitcoin-spv-sol/contracts/SafeMath.sol";
import {BytesLib} from "@summa-tx/bitcoin-spv-sol/contracts/BytesLib.sol";
import {BTCUtils} from "@summa-tx/bitcoin-spv-sol/contracts/BTCUtils.sol";
import {ValidateSPV} from "@summa-tx/bitcoin-spv-sol/contracts/ValidateSPV.sol";
import {IRelay} from "./Interfaces.sol";

contract Relay is IRelay {
    using SafeMath for uint256;
    using BytesLib for bytes;
    using BTCUtils for bytes;
    using ValidateSPV for bytes;

    // How often do we store the height?
    // A higher number incurs less storage cost, but more lookup cost
    uint32 public constant HEIGHT_INTERVAL = 4;

    bytes32 internal relayGenesis;
    bytes32 internal bestKnownDigest;
    bytes32 internal lastReorgCommonAncestor;
    mapping (bytes32 => bytes32) internal previousBlock;
    mapping (bytes32 => uint256) internal blockHeight;

    uint256 internal currentEpochDiff;
    uint256 internal prevEpochDiff;


    /// @notice                   Gives a starting point for the relay
    /// @dev                      We don't check this AT ALL really. Don't use relays with bad genesis
    /// @param  _genesisHeader    The starting header
    /// @param  _height           The starting height
    /// @param  _periodStart      The hash of the first header in the genesis epoch
    constructor(bytes memory _genesisHeader, uint256 _height, bytes32 _periodStart) public {
        require(_genesisHeader.length == 80, "Stop being dumb");
        bytes32 _genesisDigest = _genesisHeader.hash256();

        require(
            _periodStart & bytes32(0x0000000000000000000000000000000000000000000000000000000000ffffff) == bytes32(0),
            "Period start hash does not have work. Hint: wrong byte order?");

        relayGenesis = _genesisDigest;
        bestKnownDigest = _genesisDigest;
        lastReorgCommonAncestor = _genesisDigest;
        blockHeight[_genesisDigest] = _height;
        blockHeight[_periodStart] = _height.sub(_height % 2016);

        currentEpochDiff = _genesisHeader.extractDifficulty();
    }

    /// @notice     Getter for currentEpochDiff
    /// @dev        This is updated when a new heavist header has a new diff
    /// @return     The difficulty of the bestKnownDigest
    function getCurrentEpochDifficulty() external view returns (uint256) {
        return currentEpochDiff;
    }
    /// @notice     Getter for prevEpochDiff
    /// @dev        This is updated when a difficulty change is accepted
    /// @return     The difficulty of the previous epoch
    function getPrevEpochDifficulty() external view returns (uint256) {
        return prevEpochDiff;
    }

    /// @notice     Getter for relayGenesis
    /// @dev        This is an initialization parameter
    /// @return     The hash of the first block of the relay
    function getRelayGenesis() public view returns (bytes32) {
        return relayGenesis;
    }

    /// @notice     Getter for bestKnownDigest
    /// @dev        This updated only by calling markNewHeaviest
    /// @return     The hash of the best marked chain tip
    function getBestKnownDigest() public view returns (bytes32) {
        return bestKnownDigest;
    }

    /// @notice     Getter for relayGenesis
    /// @dev        This is updated only by calling markNewHeaviest
    /// @return     The hash of the shared ancestor of the most recent fork
    function getLastReorgCommonAncestor() public view returns (bytes32) {
        return lastReorgCommonAncestor;
    }

    /// @notice         Finds the height of a header by its digest
    /// @dev            Will fail if the header is unknown
    /// @param _digest  The header digest to search for
    /// @return         The height of the header, or error if unknown
    function findHeight(bytes32 _digest) external view returns (uint256) {
        return _findHeight(_digest);
    }

    /// @notice         Finds an ancestor for a block by its digest
    /// @dev            Will fail if the header is unknown
    /// @param _digest  The header digest to search for
    /// @return         The height of the header, or error if unknown
    function findAncestor(bytes32 _digest, uint256 _offset) external view returns (bytes32) {
        return _findAncestor(_digest, _offset);
    }

    /// @notice             Checks if a digest is an ancestor of the current one
    /// @dev                Limit the amount of lookups (and thus gas usage) with _limit
    /// @param _ancestor    The prospective ancestor
    /// @param _descendant  The descendant to check
    /// @param _limit       The maximum number of blocks to check
    /// @return             true if ancestor is at most limit blocks lower than descendant, otherwise false
    function isAncestor(bytes32 _ancestor, bytes32 _descendant, uint256 _limit) external view returns (bool) {
        return _isAncestor(_ancestor, _descendant, _limit);
    }

    /// @notice             Adds headers to storage after validating
    /// @dev                We check integrity and consistency of the header chain
    /// @param  _anchor     The header immediately preceeding the new chain
    /// @param  _headers    A tightly-packed list of 80-byte Bitcoin headers
    /// @return             True if successfully written, error otherwise
    function addHeaders(bytes calldata _anchor, bytes calldata _headers) external returns (bool) {
        return _addHeaders(_anchor, _headers, false);
    }

    /// @notice                       Adds headers to storage, performs additional validation of retarget
    /// @dev                          Checks the retarget, the heights, and the linkage
    /// @param  _oldPeriodStartHeader The first header in the difficulty period being closed
    /// @param  _oldPeriodEndHeader   The last header in the difficulty period being closed
    /// @param  _headers              A tightly-packed list of 80-byte Bitcoin headers
    /// @return                       True if successfully written, error otherwise
    function addHeadersWithRetarget(
        bytes calldata _oldPeriodStartHeader,
        bytes calldata _oldPeriodEndHeader,
        bytes calldata _headers
    ) external returns (bool) {
        return _addHeadersWithRetarget(_oldPeriodStartHeader, _oldPeriodEndHeader, _headers);
    }

    /// @notice                   Gives a starting point for the relay
    /// @dev                      We don't check this AT ALL really. Don't use relays with bad genesis
    /// @param  _ancestor         The digest of the most recent common ancestor
    /// @param  _currentBest      The 80-byte header referenced by bestKnownDigest
    /// @param  _newBest          The 80-byte header to mark as the new best
    /// @param  _limit            Limit the amount of traversal of the chain
    /// @return                   True if successfully updates bestKnownDigest, error otherwise
    function markNewHeaviest(
        bytes32 _ancestor,
        bytes calldata _currentBest,
        bytes calldata _newBest,
        uint256 _limit
    ) external returns (bool) {
        return _markNewHeaviest(_ancestor, _currentBest, _newBest, _limit);
    }

    /// @notice             Adds headers to storage after validating
    /// @dev                We check integrity and consistency of the header chain
    /// @param  _anchor     The header immediately preceeding the new chain
    /// @param  _headers    A tightly-packed list of new 80-byte Bitcoin headers to record
    /// @param  _internal   True if called internally from addHeadersWithRetarget, false otherwise
    /// @return             True if successfully written, error otherwise
    function _addHeaders(bytes memory _anchor, bytes memory _headers, bool _internal) internal returns (bool) {
        uint256 _height;
        bytes memory _header;
        bytes32 _currentDigest;
        bytes32 _previousDigest = _anchor.hash256();

        uint256 _target = _headers.slice(0, 80).extractTarget();
        uint256 _anchorHeight = _findHeight(_previousDigest);  /* NB: errors if unknown */

        require(
            _internal || _anchor.extractTarget() == _target,
            "Unexpected retarget on external call");
        require(_headers.length % 80 == 0, "Header array length must be divisible by 80");

        /*
        NB:
        1. check that the header has sufficient work
        2. check that headers are in a coherent chain (no retargets, hash links good)
        3. Store the block connection
        4. Store the height
        */
        for (uint256 i = 0; i < _headers.length / 80; i = i.add(1)) {
            _header = _headers.slice(i.mul(80), 80);
            _height = _anchorHeight.add(i + 1);
            _currentDigest = _header.hash256();

            /*
            NB:
            if the block is already authenticated, we don't need to a work check
            Or write anything to state. This saves gas
            */
            if (previousBlock[_currentDigest] == bytes32(0)) {
                require(
                    abi.encodePacked(_currentDigest).reverseEndianness().bytesToUint() <= _target,
                    "Header work is insufficient");
                previousBlock[_currentDigest] = _previousDigest;
                if (_height % HEIGHT_INTERVAL == 0) {
                    /*
                    NB: We store the height only every 4th header to save gas
                    */
                    blockHeight[_currentDigest] = _height;
                }
            }

            /* NB: we do still need to make chain level checks tho */
            require(_header.extractTarget() == _target, "Target changed unexpectedly");
            require(_header.validateHeaderPrevHash(_previousDigest), "Headers do not form a consistent chain");

            _previousDigest = _currentDigest;
        }

        emit Extension(
            _anchor.hash256(),
            _currentDigest);
        return true;
    }

    /// @notice                       Adds headers to storage, performs additional validation of retarget
    /// @dev                          Checks the retarget, the heights, and the linkage
    /// @param  _oldPeriodStartHeader The first header in the difficulty period being closed
    /// @param  _oldPeriodEndHeader   The last header in the difficulty period being closed
    /// @param  _headers              A tightly-packed list of 80-byte Bitcoin headers
    /// @return                       True if successfully written, error otherwise
    function _addHeadersWithRetarget(
        bytes memory _oldPeriodStartHeader,
        bytes memory _oldPeriodEndHeader,
        bytes memory _headers
    ) internal returns (bool) {
        /* NB: requires that both blocks are known */
        uint256 _startHeight = _findHeight(_oldPeriodStartHeader.hash256());
        uint256 _endHeight = _findHeight(_oldPeriodEndHeader.hash256());

        /* NB: retargets should happen at 2016 block intervals */
        require(
            _endHeight % 2016 == 2015,
            "Must provide the last header of the closing difficulty period");
        require(
            _endHeight == _startHeight.add(2015),
            "Must provide exactly 1 difficulty period");
        require(
            _oldPeriodStartHeader.extractDifficulty() == _oldPeriodEndHeader.extractDifficulty(),
            "Period header difficulties do not match");

        /* NB: This comparison looks weird because header nBits encoding truncates targets */
        bytes memory _newPeriodStart = _headers.slice(0, 80);
        uint256 _actualTarget = _newPeriodStart.extractTarget();
        uint256 _expectedTarget = BTCUtils.retargetAlgorithm(
            _oldPeriodStartHeader.extractTarget(),
            _oldPeriodStartHeader.extractTimestamp(),
            _oldPeriodEndHeader.extractTimestamp()
        );
        require(
            (_actualTarget & _expectedTarget) == _actualTarget,
            "Invalid retarget provided");

        // If the current known prevEpochDiff doesn't match, and this old period is near the chaintip/
        // update the stored prevEpochDiff
        // Don't update if this is a deep past epoch
        uint256 _oldDiff = _oldPeriodStartHeader.extractDifficulty();
        if (prevEpochDiff != _oldDiff && _endHeight > _findHeight(bestKnownDigest).sub(2016)) {
            prevEpochDiff = _oldDiff;
        }

        // Pass all but the first through to be added
        return _addHeaders(_oldPeriodEndHeader, _headers, true);
    }

    /// @notice         Finds the height of a header by its digest
    /// @dev            Will fail if the header is unknown
    /// @param _digest  The header digest to search for
    /// @return         The height of the header
    function _findHeight(bytes32 _digest) internal view returns (uint256) {
        uint256 _height = 0;
        bytes32 _current = _digest;
        for (uint256 i = 0; i < HEIGHT_INTERVAL + 1; i = i.add(1)) {
            _height = blockHeight[_current];
            if (_height == 0) {
                _current = previousBlock[_current];
            } else {
                return _height.add(i);
            }
        }
        revert("Unknown block");
    }

    /// @notice         Finds an ancestor for a block by its digest
    /// @dev            Will fail if the header is unknown
    /// @param _digest  The header digest to search for
    /// @return         The height of the header, or error if unknown
    function _findAncestor(bytes32 _digest, uint256 _offset) internal view returns (bytes32) {
        bytes32 _current = _digest;
        for (uint256 i = 0; i < _offset; i = i.add(1)) {
            _current = previousBlock[_current];
        }
        require(_current != bytes32(0), "Unknown ancestor");
        return _current;
    }

    /// @notice             Checks if a digest is an ancestor of the current one
    /// @dev                Limit the amount of lookups (and thus gas usage) with _limit
    /// @param _ancestor    The prospective ancestor
    /// @param _descendant  The descendant to check
    /// @param _limit       The maximum number of blocks to check
    /// @return             true if ancestor is at most limit blocks lower than descendant, otherwise false
    function _isAncestor(bytes32 _ancestor, bytes32 _descendant, uint256 _limit) internal view returns (bool) {
        bytes32 _current = _descendant;
        /* NB: 200 gas/read, so gas is capped at ~200 * limit */
        for (uint256 i = 0; i < _limit; i = i.add(1)) {
            if (_current == _ancestor) {
                return true;
            }
            _current = previousBlock[_current];
        }
        return false;
    }

    /// @notice                   Marks the new best-known chain tip
    /// @param  _ancestor         The digest of the most recent common ancestor
    /// @param  _currentBest      The 80-byte header referenced by bestKnownDigest
    /// @param  _newBest          The 80-byte header to mark as the new best
    /// @param  _limit            Limit the amount of traversal of the chain
    /// @return                   True if successfully updates bestKnownDigest, error otherwise
    function _markNewHeaviest(
        bytes32 _ancestor,
        bytes memory _currentBest,
        bytes memory _newBest,
        uint256 _limit
    ) internal returns (bool) {
        require(_limit <= 2016, "Requested limit is greater than 1 difficulty period");
        bytes32 _newBestDigest = _newBest.hash256();
        bytes32 _currentBestDigest = _currentBest.hash256();
        require(_currentBestDigest == bestKnownDigest, "Passed in best is not best known");
        require(
            previousBlock[_newBestDigest] != bytes32(0),
            "New best is unknown");
        require(
            _isMostRecentAncestor(_ancestor, bestKnownDigest, _newBestDigest, _limit),
            "Ancestor must be heaviest common ancestor");
        require(
            _heaviestFromAncestor(_ancestor, _currentBest, _newBest) == _newBestDigest,
            "New best hash does not have more work than previous");

        bestKnownDigest = _newBestDigest;
        lastReorgCommonAncestor = _ancestor;

        uint256 _newDiff = _newBest.extractDifficulty();
        if (_newDiff != currentEpochDiff) {
            currentEpochDiff = _newDiff;
        }

        emit NewTip(
            _currentBestDigest,
            _newBestDigest,
            _ancestor);
        return true;
    }

    /// @notice             Checks if a digest is an ancestor of the current one
    /// @dev                Limit the amount of lookups (and thus gas usage) with _limit
    /// @param _ancestor    The prospective shared ancestor
    /// @param _left        A chain tip
    /// @param _right       A chain tip
    /// @param _limit       The maximum number of blocks to check
    /// @return             true if it is the most recent common ancestor within _limit, false otherwise
    function _isMostRecentAncestor(
        bytes32 _ancestor,
        bytes32 _left,
        bytes32 _right,
        uint256 _limit
    ) internal view returns (bool) {
        /* NB: sure why not */
        if (_ancestor == _left && _ancestor == _right) {
            return true;
        }

        bytes32 _leftCurrent = _left;
        bytes32 _rightCurrent = _right;
        bytes32 _leftPrev = _left;
        bytes32 _rightPrev = _right;

        for(uint256 i = 0; i < _limit; i = i.add(1)) {
            if (_leftPrev != _ancestor) {
                _leftCurrent = _leftPrev;  // cheap
                _leftPrev = previousBlock[_leftPrev];  // expensive
            }
            if (_rightPrev != _ancestor) {
                _rightCurrent = _rightPrev;  // cheap
                _rightPrev = previousBlock[_rightPrev];  // expensive
            }
        }
        if (_leftCurrent == _rightCurrent) {return false;} /* NB: If the same, they're a nearer ancestor */
        if (_leftPrev != _rightPrev) {return false;} /* NB: Both must be ancestor */
        return true;
    }

    /// @notice             Decides which header is heaviest from the ancestor
    /// @dev                Does not support reorgs above 2017 blocks (:
    /// @param _ancestor    The prospective shared ancestor
    /// @param _left        A chain tip
    /// @param _right       A chain tip
    /// @return             true if it is the most recent common ancestor within _limit, false otherwise
    function _heaviestFromAncestor(
        bytes32 _ancestor,
        bytes memory _left,
        bytes memory _right
    ) internal view returns (bytes32) {
        uint256 _ancestorHeight = _findHeight(_ancestor);
        uint256 _leftHeight = _findHeight(_left.hash256());
        uint256 _rightHeight = _findHeight(_right.hash256());

        require(
            _leftHeight >= _ancestorHeight && _rightHeight >= _ancestorHeight,
            "A descendant height is below the ancestor height");

        /* NB: we can shortcut if one block is in a new difficulty window and the other isn't */
        uint256 _nextPeriodStartHeight = _ancestorHeight.add(2016).sub(_ancestorHeight % 2016);
        bool _leftInPeriod = _leftHeight < _nextPeriodStartHeight;
        bool _rightInPeriod = _rightHeight < _nextPeriodStartHeight;

        /*
        NB:
        1. Left is in a new window, right is in the old window. Left is heavier
        2. Right is in a new window, left is in the old window. Right is heavier
        3. Both are in the same window, choose the higher one
        4. They're in different new windows. Choose the heavier one
        */
        if (!_leftInPeriod && _rightInPeriod) {return _left.hash256();}
        if (_leftInPeriod && !_rightInPeriod) {return _right.hash256();}
        if (_leftInPeriod && _rightInPeriod) {
            return _leftHeight >= _rightHeight ? _left.hash256() : _right.hash256();
        } else {  // if (!_leftInPeriod && !_rightInPeriod) {
            if (((_leftHeight % 2016).mul(_left.extractDifficulty())) <
                (_rightHeight % 2016).mul(_right.extractDifficulty())) {
                return _right.hash256();
            } else {
                return _left.hash256();
            }
        }
    }
}

// For unittests
contract TestRelay is Relay {

    /// @notice                   Gives a starting point for the relay
    /// @dev                      We don't check this AT ALL really. Don't use relays with bad genesis
    /// @param  _genesisHeader    The starting header
    /// @param  _height           The starting height
    /// @param  _periodStart      The hash of the first header in the genesis epoch
    constructor(bytes memory _genesisHeader, uint256 _height, bytes32 _periodStart)
        Relay(_genesisHeader, _height, _periodStart)
    public {}

    function heaviestFromAncestor(
        bytes32 _ancestor,
        bytes calldata _left,
        bytes calldata _right
    ) external view returns (bytes32) {
        return _heaviestFromAncestor(_ancestor, _left, _right);
    }

    function isMostRecentAncestor(
        bytes32 _ancestor,
        bytes32 _left,
        bytes32 _right,
        uint256 _limit
    ) external view returns (bool) {
        return _isMostRecentAncestor(_ancestor, _left, _right, _limit);
    }
}

pragma solidity ^0.5.10;

/** @title OnDemandSPV */
/** @author Summa (https://summa.one) */

import {ISPVConsumer} from "../Interfaces.sol";
import {OnDemandSPV} from "../OnDemandSPV.sol";

contract DummyConsumer is ISPVConsumer {
    event Consumed(bytes32 indexed _txid, uint256 indexed _requestID, uint256 _gasLeft);

    bool broken = false;

    function setBroken(bool _b) external {
        broken = _b;
    }

    function spv(
        bytes32 _txid,
        bytes calldata,
        bytes calldata,
        uint256 _requestID,
        uint8,
        uint8
    ) external {
        emit Consumed(_txid, _requestID, gasleft());
        if (broken) {
            revert("BORKED");
        }
    }

    function cancel(
        uint256 _requestID,
        address payable _odspv
    ) external returns (bool) {
        return OnDemandSPV(_odspv).cancelRequest(_requestID);
    }
}

contract DummyOnDemandSPV is OnDemandSPV {

    constructor(
        bytes memory _genesisHeader,
        uint256 _height,
        bytes32 _periodStart,
        uint256 _firstID
    ) OnDemandSPV(
        _genesisHeader,
        _height,
        _periodStart,
        _firstID
    ) public {return ;}

    bool callResult = false;

    function requestTest(
        uint256 _requestID,
        bytes calldata _spends,
        bytes calldata _pays,
        uint64 _paysValue,
        address _consumer,
        uint8 _numConfs,
        uint256 _notBefore
    ) external returns (uint256) {
        nextID = _requestID;
        return _request(_spends, _pays, _paysValue, _consumer, _numConfs, _notBefore);
    }

    function setCallResult(bool _r) external {
        callResult = _r;
    }

    function _isAncestor(bytes32, bytes32, uint256) internal view returns (bool) {
        return callResult;
    }

    function getValidatedTx(bytes32 _txid) public view returns (bool) {
        return validatedTxns[_txid];
    }

    function setValidatedTx(bytes32 _txid) public {
        validatedTxns[_txid] = true;
    }

    function unsetValidatedTx(bytes32 _txid) public {
        validatedTxns[_txid] = false;
    }

    function callCallback(
        bytes32 _txid,
        uint16 _reqIndices,
        bytes calldata _vin,
        bytes calldata _vout,
        uint256 _requestID
    ) external returns (bool) {
        return _callCallback(_txid, _reqIndices, _vin, _vout, _requestID);
    }

    function checkInclusion(
        bytes calldata _header,
        bytes calldata _proof,
        uint256 _index,
        bytes32 _txid,
        uint256 _requestID
    ) external view returns (bool) {
        return _checkInclusion(_header, _proof, _index, _txid, _requestID);
    }

    function _getConfs(bytes32 _header) internal view returns (uint8){
        if (_header == bytes32(0)) {
            return OnDemandSPV._getConfs(lastReorgCommonAncestor);
        }
        return 8;
    }

    function getConfsTest() external view returns (uint8) {
        return _getConfs(bytes32(0));
    }

    function checkRequests(
        uint16 _requestIndices,
        bytes calldata _vin,
        bytes calldata _vout,
        uint256 _requestID
    ) external view returns (bool) {
        return _checkRequests(_requestIndices, _vin, _vout, _requestID);
    }

    function whatTimeIsItRightNowDotCom() external view returns (uint256) {
        return block.timestamp;
    }
}

pragma solidity ^0.5.10;

/** @title ValidateSPV*/
/** @author Summa (https://summa.one) */

import {BytesLib} from "./BytesLib.sol";
import {SafeMath} from "./SafeMath.sol";
import {BTCUtils} from "./BTCUtils.sol";


library ValidateSPV {

    using BTCUtils for bytes;
    using BTCUtils for uint256;
    using BytesLib for bytes;
    using SafeMath for uint256;

    enum InputTypes { NONE, LEGACY, COMPATIBILITY, WITNESS }
    enum OutputTypes { NONE, WPKH, WSH, OP_RETURN, PKH, SH, NONSTANDARD }

    uint256 constant ERR_BAD_LENGTH = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ERR_INVALID_CHAIN = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;
    uint256 constant ERR_LOW_WORK = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd;

    function getErrBadLength() internal pure returns (uint256) {
        return ERR_BAD_LENGTH;
    }

    function getErrInvalidChain() internal pure returns (uint256) {
        return ERR_INVALID_CHAIN;
    }

    function getErrLowWork() internal pure returns (uint256) {
        return ERR_LOW_WORK;
    }

    /// @notice                     Validates a tx inclusion in the block
    /// @dev                        `index` is not a reliable indicator of location within a block
    /// @param _txid                The txid (LE)
    /// @param _merkleRoot          The merkle root (as in the block header)
    /// @param _intermediateNodes   The proof's intermediate nodes (digests between leaf and root)
    /// @param _index               The leaf's index in the tree (0-indexed)
    /// @return                     true if fully valid, false otherwise
    function prove(
        bytes32 _txid,
        bytes32 _merkleRoot,
        bytes memory _intermediateNodes,
        uint _index
    ) internal pure returns (bool) {
        // Shortcut the empty-block case
        if (_txid == _merkleRoot && _index == 0 && _intermediateNodes.length == 0) {
            return true;
        }

        bytes memory _proof = abi.encodePacked(_txid, _intermediateNodes, _merkleRoot);
        // If the Merkle proof failed, bubble up error
        return _proof.verifyHash256Merkle(_index);
    }

    /// @notice             Hashes transaction to get txid
    /// @dev                Supports Legacy and Witness
    /// @param _version     4-bytes version
    /// @param _vin         Raw bytes length-prefixed input vector
    /// @param _vout        Raw bytes length-prefixed output vector
    /// @param _locktime   4-byte tx locktime
    /// @return             32-byte transaction id, little endian
    function calculateTxId(
        bytes memory _version,
        bytes memory _vin,
        bytes memory _vout,
        bytes memory _locktime
    ) internal pure returns (bytes32) {
        // Get transaction hash double-Sha256(version + nIns + inputs + nOuts + outputs + locktime)
        return abi.encodePacked(_version, _vin, _vout, _locktime).hash256();
    }

    /// @notice             Checks validity of header chain
    /// @notice             Compares the hash of each header to the prevHash in the next header
    /// @param _headers     Raw byte array of header chain
    /// @return             The total accumulated difficulty of the header chain, or an error code
    function validateHeaderChain(bytes memory _headers) internal view returns (uint256 _totalDifficulty) {

        // Check header chain length
        if (_headers.length % 80 != 0) {return ERR_BAD_LENGTH;}

        // Initialize header start index
        bytes32 _digest;

        _totalDifficulty = 0;

        for (uint256 _start = 0; _start < _headers.length; _start += 80) {

            // ith header start index and ith header
            bytes memory _header = _headers.slice(_start, 80);

            // After the first header, check that headers are in a chain
            if (_start != 0) {
                if (!validateHeaderPrevHash(_header, _digest)) {return ERR_INVALID_CHAIN;}
            }

            // ith header target
            uint256 _target = _header.extractTarget();

            // Require that the header has sufficient work
            _digest = _header.hash256View();
            if(uint256(_digest).reverseUint256() > _target) {
                return ERR_LOW_WORK;
            }

            // Add ith header difficulty to difficulty sum
            _totalDifficulty = _totalDifficulty.add(_target.calculateDifficulty());
        }
    }

    /// @notice             Checks validity of header work
    /// @param _digest      Header digest
    /// @param _target      The target threshold
    /// @return             true if header work is valid, false otherwise
    function validateHeaderWork(bytes32 _digest, uint256 _target) internal pure returns (bool) {
        if (_digest == bytes32(0)) {return false;}
        return (abi.encodePacked(_digest).reverseEndianness().bytesToUint() < _target);
    }

    /// @notice                     Checks validity of header chain
    /// @dev                        Compares current header prevHash to previous header's digest
    /// @param _header              The raw bytes header
    /// @param _prevHeaderDigest    The previous header's digest
    /// @return                     true if the connect is valid, false otherwise
    function validateHeaderPrevHash(bytes memory _header, bytes32 _prevHeaderDigest) internal pure returns (bool) {

        // Extract prevHash of current header
        bytes32 _prevHash = _header.extractPrevBlockLE().toBytes32();

        // Compare prevHash of current header to previous header's digest
        if (_prevHash != _prevHeaderDigest) {return false;}

        return true;
    }
}


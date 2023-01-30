/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



/*



  Copyright 2018 ZeroEx Intl.



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





pragma solidity 0.4.24;

pragma experimental ABIEncoderV2;





contract SafeMath {



    function safeMul(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(

            c / a == b,

            "UINT256_OVERFLOW"

        );

        return c;

    }



    function safeDiv(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a / b;

        return c;

    }



    function safeSub(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        require(

            b <= a,

            "UINT256_UNDERFLOW"

        );

        return a - b;

    }



    function safeAdd(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a + b;

        require(

            c >= a,

            "UINT256_OVERFLOW"

        );

        return c;

    }



    function max64(uint64 a, uint64 b)

        internal

        pure

        returns (uint256)

    {

        return a >= b ? a : b;

    }



    function min64(uint64 a, uint64 b)

        internal

        pure

        returns (uint256)

    {

        return a < b ? a : b;

    }



    function max256(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a >= b ? a : b;

    }



    function min256(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a < b ? a : b;

    }

}







contract LibEIP712 {



    // EIP191 header for EIP712 prefix

    string constant internal EIP191_HEADER = "\x19\x01";



    // EIP712 Domain Name value

    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";



    // EIP712 Domain Version value

    string constant internal EIP712_DOMAIN_VERSION = "2";



    // Hash of the EIP712 Domain Separator Schema

    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(

        "EIP712Domain(",

        "string name,",

        "string version,",

        "address verifyingContract",

        ")"

    ));



    // Hash of the EIP712 Domain Separator data

    // solhint-disable-next-line var-name-mixedcase

    bytes32 public EIP712_DOMAIN_HASH;



    constructor ()

        public

    {

        EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(

            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,

            keccak256(bytes(EIP712_DOMAIN_NAME)),

            keccak256(bytes(EIP712_DOMAIN_VERSION)),

            bytes32(address(this))

        ));

    }



    /// @dev Calculates EIP712 encoding for a hash struct in this EIP712 Domain.

    /// @param hashStruct The EIP712 hash struct.

    /// @return EIP712 hash applied to this EIP712 Domain.

    function hashEIP712Message(bytes32 hashStruct)

        internal

        view

        returns (bytes32 result)

    {

        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;



        // Assembly for more efficient computing:

        // keccak256(abi.encodePacked(

        //     EIP191_HEADER,

        //     EIP712_DOMAIN_HASH,

        //     hashStruct    

        // ));



        assembly {

            // Load free memory pointer

            let memPtr := mload(64)



            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header

            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash

            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct



            // Compute hash

            result := keccak256(memPtr, 66)

        }

        return result;

    }

}







contract LibOrder is

    LibEIP712

{

    // Hash for the EIP712 Order Schema

    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(

        "Order(",

        "address makerAddress,",

        "address takerAddress,",

        "address feeRecipientAddress,",

        "address senderAddress,",

        "uint256 makerAssetAmount,",

        "uint256 takerAssetAmount,",

        "uint256 makerFee,",

        "uint256 takerFee,",

        "uint256 expirationTimeSeconds,",

        "uint256 salt,",

        "bytes makerAssetData,",

        "bytes takerAssetData",

        ")"

    ));



    // A valid order remains fillable until it is expired, fully filled, or cancelled.

    // An order's state is unaffected by external factors, like account balances.

    enum OrderStatus {

        INVALID,                     // Default value

        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount

        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount

        FILLABLE,                    // Order is fillable

        EXPIRED,                     // Order has already expired

        FULLY_FILLED,                // Order is fully filled

        CANCELLED                    // Order has been cancelled

    }



    // solhint-disable max-line-length

    struct Order {

        address makerAddress;           // Address that created the order.      

        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.          

        address feeRecipientAddress;    // Address that will recieve fees when order is filled.      

        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.

        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.        

        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.        

        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.

        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.

        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.          

        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.     

        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.

        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.

    }

    // solhint-enable max-line-length



    struct OrderInfo {

        uint8 orderStatus;                    // Status that describes order's validity and fillability.

        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).

        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.

    }



    /// @dev Calculates Keccak-256 hash of the order.

    /// @param order The order structure.

    /// @return Keccak-256 EIP712 hash of the order.

    function getOrderHash(Order memory order)

        internal

        view

        returns (bytes32 orderHash)

    {

        orderHash = hashEIP712Message(hashOrder(order));

        return orderHash;

    }



    /// @dev Calculates EIP712 hash of the order.

    /// @param order The order structure.

    /// @return EIP712 hash of the order.

    function hashOrder(Order memory order)

        internal

        pure

        returns (bytes32 result)

    {

        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;

        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);

        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);



        // Assembly for more efficiently computing:

        // keccak256(abi.encodePacked(

        //     EIP712_ORDER_SCHEMA_HASH,

        //     bytes32(order.makerAddress),

        //     bytes32(order.takerAddress),

        //     bytes32(order.feeRecipientAddress),

        //     bytes32(order.senderAddress),

        //     order.makerAssetAmount,

        //     order.takerAssetAmount,

        //     order.makerFee,

        //     order.takerFee,

        //     order.expirationTimeSeconds,

        //     order.salt,

        //     keccak256(order.makerAssetData),

        //     keccak256(order.takerAssetData)

        // ));



        assembly {

            // Calculate memory addresses that will be swapped out before hashing

            let pos1 := sub(order, 32)

            let pos2 := add(order, 320)

            let pos3 := add(order, 352)



            // Backup

            let temp1 := mload(pos1)

            let temp2 := mload(pos2)

            let temp3 := mload(pos3)

            

            // Hash in place

            mstore(pos1, schemaHash)

            mstore(pos2, makerAssetDataHash)

            mstore(pos3, takerAssetDataHash)

            result := keccak256(pos1, 416)

            

            // Restore

            mstore(pos1, temp1)

            mstore(pos2, temp2)

            mstore(pos3, temp3)

        }

        return result;

    }

}







contract LibFillResults is

    SafeMath

{

    struct FillResults {

        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.

        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.

        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).

        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).

    }



    struct MatchedFillResults {

        FillResults left;                    // Amounts filled and fees paid of left order.

        FillResults right;                   // Amounts filled and fees paid of right order.

        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.

    }



    /// @dev Adds properties of both FillResults instances.

    ///      Modifies the first FillResults instance specified.

    /// @param totalFillResults Fill results instance that will be added onto.

    /// @param singleFillResults Fill results instance that will be added to totalFillResults.

    function addFillResults(FillResults memory totalFillResults, FillResults memory singleFillResults)

        internal

        pure

    {

        totalFillResults.makerAssetFilledAmount = safeAdd(totalFillResults.makerAssetFilledAmount, singleFillResults.makerAssetFilledAmount);

        totalFillResults.takerAssetFilledAmount = safeAdd(totalFillResults.takerAssetFilledAmount, singleFillResults.takerAssetFilledAmount);

        totalFillResults.makerFeePaid = safeAdd(totalFillResults.makerFeePaid, singleFillResults.makerFeePaid);

        totalFillResults.takerFeePaid = safeAdd(totalFillResults.takerFeePaid, singleFillResults.takerFeePaid);

    }

}







library LibBytes {



    using LibBytes for bytes;



    /// @dev Gets the memory address for a byte array.

    /// @param input Byte array to lookup.

    /// @return memoryAddress Memory address of byte array. This

    ///         points to the header of the byte array which contains

    ///         the length.

    function rawAddress(bytes memory input)

        internal

        pure

        returns (uint256 memoryAddress)

    {

        assembly {

            memoryAddress := input

        }

        return memoryAddress;

    }

    

    /// @dev Gets the memory address for the contents of a byte array.

    /// @param input Byte array to lookup.

    /// @return memoryAddress Memory address of the contents of the byte array.

    function contentAddress(bytes memory input)

        internal

        pure

        returns (uint256 memoryAddress)

    {

        assembly {

            memoryAddress := add(input, 32)

        }

        return memoryAddress;

    }



    /// @dev Copies `length` bytes from memory location `source` to `dest`.

    /// @param dest memory address to copy bytes to.

    /// @param source memory address to copy bytes from.

    /// @param length number of bytes to copy.

    function memCopy(

        uint256 dest,

        uint256 source,

        uint256 length

    )

        internal

        pure

    {

        if (length < 32) {

            // Handle a partial word by reading destination and masking

            // off the bits we are interested in.

            // This correctly handles overlap, zero lengths and source == dest

            assembly {

                let mask := sub(exp(256, sub(32, length)), 1)

                let s := and(mload(source), not(mask))

                let d := and(mload(dest), mask)

                mstore(dest, or(s, d))

            }

        } else {

            // Skip the O(length) loop when source == dest.

            if (source == dest) {

                return;

            }



            // For large copies we copy whole words at a time. The final

            // word is aligned to the end of the range (instead of after the

            // previous) to handle partial words. So a copy will look like this:

            //

            //  ####

            //      ####

            //          ####

            //            ####

            //

            // We handle overlap in the source and destination range by

            // changing the copying direction. This prevents us from

            // overwriting parts of source that we still need to copy.

            //

            // This correctly handles source == dest

            //

            if (source > dest) {

                assembly {

                    // We subtract 32 from `sEnd` and `dEnd` because it

                    // is easier to compare with in the loop, and these

                    // are also the addresses we need for copying the

                    // last bytes.

                    length := sub(length, 32)

                    let sEnd := add(source, length)

                    let dEnd := add(dest, length)



                    // Remember the last 32 bytes of source

                    // This needs to be done here and not after the loop

                    // because we may have overwritten the last bytes in

                    // source already due to overlap.

                    let last := mload(sEnd)



                    // Copy whole words front to back

                    // Note: the first check is always true,

                    // this could have been a do-while loop.

                    // solhint-disable-next-line no-empty-blocks

                    for {} lt(source, sEnd) {} {

                        mstore(dest, mload(source))

                        source := add(source, 32)

                        dest := add(dest, 32)

                    }

                    

                    // Write the last 32 bytes

                    mstore(dEnd, last)

                }

            } else {

                assembly {

                    // We subtract 32 from `sEnd` and `dEnd` because those

                    // are the starting points when copying a word at the end.

                    length := sub(length, 32)

                    let sEnd := add(source, length)

                    let dEnd := add(dest, length)



                    // Remember the first 32 bytes of source

                    // This needs to be done here and not after the loop

                    // because we may have overwritten the first bytes in

                    // source already due to overlap.

                    let first := mload(source)



                    // Copy whole words back to front

                    // We use a signed comparisson here to allow dEnd to become

                    // negative (happens when source and dest < 32). Valid

                    // addresses in local memory will never be larger than

                    // 2**255, so they can be safely re-interpreted as signed.

                    // Note: the first check is always true,

                    // this could have been a do-while loop.

                    // solhint-disable-next-line no-empty-blocks

                    for {} slt(dest, dEnd) {} {

                        mstore(dEnd, mload(sEnd))

                        sEnd := sub(sEnd, 32)

                        dEnd := sub(dEnd, 32)

                    }

                    

                    // Write the first 32 bytes

                    mstore(dest, first)

                }

            }

        }

    }



    /// @dev Returns a slices from a byte array.

    /// @param b The byte array to take a slice from.

    /// @param from The starting index for the slice (inclusive).

    /// @param to The final index for the slice (exclusive).

    /// @return result The slice containing bytes at indices [from, to)

    function slice(

        bytes memory b,

        uint256 from,

        uint256 to

    )

        internal

        pure

        returns (bytes memory result)

    {

        require(

            from <= to,

            "FROM_LESS_THAN_TO_REQUIRED"

        );

        require(

            to < b.length,

            "TO_LESS_THAN_LENGTH_REQUIRED"

        );

        

        // Create a new bytes structure and copy contents

        result = new bytes(to - from);

        memCopy(

            result.contentAddress(),

            b.contentAddress() + from,

            result.length

        );

        return result;

    }

    

    /// @dev Returns a slice from a byte array without preserving the input.

    /// @param b The byte array to take a slice from. Will be destroyed in the process.

    /// @param from The starting index for the slice (inclusive).

    /// @param to The final index for the slice (exclusive).

    /// @return result The slice containing bytes at indices [from, to)

    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.

    function sliceDestructive(

        bytes memory b,

        uint256 from,

        uint256 to

    )

        internal

        pure

        returns (bytes memory result)

    {

        require(

            from <= to,

            "FROM_LESS_THAN_TO_REQUIRED"

        );

        require(

            to < b.length,

            "TO_LESS_THAN_LENGTH_REQUIRED"

        );

        

        // Create a new bytes structure around [from, to) in-place.

        assembly {

            result := add(b, from)

            mstore(result, sub(to, from))

        }

        return result;

    }



    /// @dev Pops the last byte off of a byte array by modifying its length.

    /// @param b Byte array that will be modified.

    /// @return The byte that was popped off.

    function popLastByte(bytes memory b)

        internal

        pure

        returns (bytes1 result)

    {

        require(

            b.length > 0,

            "GREATER_THAN_ZERO_LENGTH_REQUIRED"

        );



        // Store last byte.

        result = b[b.length - 1];



        assembly {

            // Decrement length of byte array.

            let newLen := sub(mload(b), 1)

            mstore(b, newLen)

        }

        return result;

    }



    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.

    /// @param b Byte array that will be modified.

    /// @return The 20 byte address that was popped off.

    function popLast20Bytes(bytes memory b)

        internal

        pure

        returns (address result)

    {

        require(

            b.length >= 20,

            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"

        );



        // Store last 20 bytes.

        result = readAddress(b, b.length - 20);



        assembly {

            // Subtract 20 from byte array length.

            let newLen := sub(mload(b), 20)

            mstore(b, newLen)

        }

        return result;

    }



    /// @dev Tests equality of two byte arrays.

    /// @param lhs First byte array to compare.

    /// @param rhs Second byte array to compare.

    /// @return True if arrays are the same. False otherwise.

    function equals(

        bytes memory lhs,

        bytes memory rhs

    )

        internal

        pure

        returns (bool equal)

    {

        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.

        // We early exit on unequal lengths, but keccak would also correctly

        // handle this.

        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);

    }



    /// @dev Reads an address from a position in a byte array.

    /// @param b Byte array containing an address.

    /// @param index Index in byte array of address.

    /// @return address from byte array.

    function readAddress(

        bytes memory b,

        uint256 index

    )

        internal

        pure

        returns (address result)

    {

        require(

            b.length >= index + 20,  // 20 is length of address

            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"

        );



        // Add offset to index:

        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)

        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)

        index += 20;



        // Read address from array memory

        assembly {

            // 1. Add index to address of bytes array

            // 2. Load 32-byte word from memory

            // 3. Apply 20-byte mask to obtain address

            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)

        }

        return result;

    }



    /// @dev Writes an address into a specific position in a byte array.

    /// @param b Byte array to insert address into.

    /// @param index Index in byte array of address.

    /// @param input Address to put into byte array.

    function writeAddress(

        bytes memory b,

        uint256 index,

        address input

    )

        internal

        pure

    {

        require(

            b.length >= index + 20,  // 20 is length of address

            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"

        );



        // Add offset to index:

        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)

        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)

        index += 20;



        // Store address into array memory

        assembly {

            // The address occupies 20 bytes and mstore stores 32 bytes.

            // First fetch the 32-byte word where we'll be storing the address, then

            // apply a mask so we have only the bytes in the word that the address will not occupy.

            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.



            // 1. Add index to address of bytes array

            // 2. Load 32-byte word from memory

            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address

            let neighbors := and(

                mload(add(b, index)),

                0xffffffffffffffffffffffff0000000000000000000000000000000000000000

            )

            

            // Make sure input address is clean.

            // (Solidity does not guarantee this)

            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)



            // Store the neighbors and address into memory

            mstore(add(b, index), xor(input, neighbors))

        }

    }



    /// @dev Reads a bytes32 value from a position in a byte array.

    /// @param b Byte array containing a bytes32 value.

    /// @param index Index in byte array of bytes32 value.

    /// @return bytes32 value from byte array.

    function readBytes32(

        bytes memory b,

        uint256 index

    )

        internal

        pure

        returns (bytes32 result)

    {

        require(

            b.length >= index + 32,

            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"

        );



        // Arrays are prefixed by a 256 bit length parameter

        index += 32;



        // Read the bytes32 from array memory

        assembly {

            result := mload(add(b, index))

        }

        return result;

    }



    /// @dev Writes a bytes32 into a specific position in a byte array.

    /// @param b Byte array to insert <input> into.

    /// @param index Index in byte array of <input>.

    /// @param input bytes32 to put into byte array.

    function writeBytes32(

        bytes memory b,

        uint256 index,

        bytes32 input

    )

        internal

        pure

    {

        require(

            b.length >= index + 32,

            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"

        );



        // Arrays are prefixed by a 256 bit length parameter

        index += 32;



        // Read the bytes32 from array memory

        assembly {

            mstore(add(b, index), input)

        }

    }



    /// @dev Reads a uint256 value from a position in a byte array.

    /// @param b Byte array containing a uint256 value.

    /// @param index Index in byte array of uint256 value.

    /// @return uint256 value from byte array.

    function readUint256(

        bytes memory b,

        uint256 index

    )

        internal

        pure

        returns (uint256 result)

    {

        result = uint256(readBytes32(b, index));

        return result;

    }



    /// @dev Writes a uint256 into a specific position in a byte array.

    /// @param b Byte array to insert <input> into.

    /// @param index Index in byte array of <input>.

    /// @param input uint256 to put into byte array.

    function writeUint256(

        bytes memory b,

        uint256 index,

        uint256 input

    )

        internal

        pure

    {

        writeBytes32(b, index, bytes32(input));

    }



    /// @dev Reads an unpadded bytes4 value from a position in a byte array.

    /// @param b Byte array containing a bytes4 value.

    /// @param index Index in byte array of bytes4 value.

    /// @return bytes4 value from byte array.

    function readBytes4(

        bytes memory b,

        uint256 index

    )

        internal

        pure

        returns (bytes4 result)

    {

        require(

            b.length >= index + 4,

            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"

        );



        // Arrays are prefixed by a 32 byte length field

        index += 32;



        // Read the bytes4 from array memory

        assembly {

            result := mload(add(b, index))

            // Solidity does not require us to clean the trailing bytes.

            // We do it anyway

            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)

        }

        return result;

    }



    /// @dev Reads nested bytes from a specific position.

    /// @dev NOTE: the returned value overlaps with the input value.

    ///            Both should be treated as immutable.

    /// @param b Byte array containing nested bytes.

    /// @param index Index of nested bytes.

    /// @return result Nested bytes.

    function readBytesWithLength(

        bytes memory b,

        uint256 index

    )

        internal

        pure

        returns (bytes memory result)

    {

        // Read length of nested bytes

        uint256 nestedBytesLength = readUint256(b, index);

        index += 32;



        // Assert length of <b> is valid, given

        // length of nested bytes

        require(

            b.length >= index + nestedBytesLength,

            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"

        );

        

        // Return a pointer to the byte array as it exists inside `b`

        assembly {

            result := add(b, index)

        }

        return result;

    }



    /// @dev Inserts bytes at a specific position in a byte array.

    /// @param b Byte array to insert <input> into.

    /// @param index Index in byte array of <input>.

    /// @param input bytes to insert.

    function writeBytesWithLength(

        bytes memory b,

        uint256 index,

        bytes memory input

    )

        internal

        pure

    {

        // Assert length of <b> is valid, given

        // length of input

        require(

            b.length >= index + 32 + input.length,  // 32 bytes to store length

            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"

        );



        // Copy <input> into <b>

        memCopy(

            b.contentAddress() + index,

            input.rawAddress(), // includes length of <input>

            input.length + 32   // +32 bytes to store <input> length

        );

    }



    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.

    /// @param dest Byte array that will be overwritten with source bytes.

    /// @param source Byte array to copy onto dest bytes.

    function deepCopyBytes(

        bytes memory dest,

        bytes memory source

    )

        internal

        pure

    {

        uint256 sourceLen = source.length;

        // Dest length must be >= source length, or some bytes would not be copied.

        require(

            dest.length >= sourceLen,

            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"

        );

        memCopy(

            dest.contentAddress(),

            source.contentAddress(),

            sourceLen

        );

    }

}







contract IExchangeCore {



    /// @dev Cancels all orders created by makerAddress with a salt less than or equal to the targetOrderEpoch

    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).

    /// @param targetOrderEpoch Orders created with a salt less or equal to this value will be cancelled.

    function cancelOrdersUpTo(uint256 targetOrderEpoch)

        external;



    /// @dev Fills the input order.

    /// @param order Order struct containing order specifications.

    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.

    /// @param signature Proof that order has been created by maker.

    /// @return Amounts filled and fees paid by maker and taker.

    function fillOrder(

        LibOrder.Order memory order,

        uint256 takerAssetFillAmount,

        bytes memory signature

    )

        public

        returns (LibFillResults.FillResults memory fillResults);



    /// @dev After calling, the order can not be filled anymore.

    /// @param order Order struct containing order specifications.

    function cancelOrder(LibOrder.Order memory order)

        public;



    /// @dev Gets information about an order: status, hash, and amount filled.

    /// @param order Order to gather information on.

    /// @return OrderInfo Information about the order and its state.

    ///                   See LibOrder.OrderInfo for a complete description.

    function getOrderInfo(LibOrder.Order memory order)

        public

        view

        returns (LibOrder.OrderInfo memory orderInfo);

}







contract IMatchOrders {



    /// @dev Match two complementary orders that have a profitable spread.

    ///      Each order is filled at their respective price point. However, the calculations are

    ///      carried out as though the orders are both being filled at the right order's price point.

    ///      The profit made by the left order goes to the taker (who matched the two orders).

    /// @param leftOrder First order to match.

    /// @param rightOrder Second order to match.

    /// @param leftSignature Proof that order was created by the left maker.

    /// @param rightSignature Proof that order was created by the right maker.

    /// @return matchedFillResults Amounts filled and fees paid by maker and taker of matched orders.

    function matchOrders(

        LibOrder.Order memory leftOrder,

        LibOrder.Order memory rightOrder,

        bytes memory leftSignature,

        bytes memory rightSignature

    )

        public

        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

}







contract ISignatureValidator {



    /// @dev Approves a hash on-chain using any valid signature type.

    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.

    /// @param signerAddress Address that should have signed the given hash.

    /// @param signature Proof that the hash has been signed by signer.

    function preSign(

        bytes32 hash,

        address signerAddress,

        bytes signature

    )

        external;

    

    /// @dev Approves/unnapproves a Validator contract to verify signatures on signer's behalf.

    /// @param validatorAddress Address of Validator contract.

    /// @param approval Approval or disapproval of  Validator contract.

    function setSignatureValidatorApproval(

        address validatorAddress,

        bool approval

    )

        external;



    /// @dev Verifies that a signature is valid.

    /// @param hash Message hash that is signed.

    /// @param signerAddress Address of signer.

    /// @param signature Proof of signing.

    /// @return Validity of order signature.

    function isValidSignature(

        bytes32 hash,

        address signerAddress,

        bytes memory signature

    )

        public

        view

        returns (bool isValid);

}







contract ITransactions {



    /// @dev Executes an exchange method call in the context of signer.

    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.

    /// @param signerAddress Address of transaction signer.

    /// @param data AbiV2 encoded calldata.

    /// @param signature Proof of signer transaction by signer.

    function executeTransaction(

        uint256 salt,

        address signerAddress,

        bytes data,

        bytes signature

    )

        external;

}







contract IAssetProxyDispatcher {



    /// @dev Registers an asset proxy to its asset proxy id.

    ///      Once an asset proxy is registered, it cannot be unregistered.

    /// @param assetProxy Address of new asset proxy to register.

    function registerAssetProxy(address assetProxy)

        external;



    /// @dev Gets an asset proxy.

    /// @param assetProxyId Id of the asset proxy.

    /// @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.

    function getAssetProxy(bytes4 assetProxyId)

        external

        view

        returns (address);

}







contract IWrapperFunctions {



    /// @dev Fills the input order. Reverts if exact takerAssetFillAmount not filled.

    /// @param order LibOrder.Order struct containing order specifications.

    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.

    /// @param signature Proof that order has been created by maker.

    function fillOrKillOrder(

        LibOrder.Order memory order,

        uint256 takerAssetFillAmount,

        bytes memory signature

    )

        public

        returns (LibFillResults.FillResults memory fillResults);



    /// @dev Fills an order with specified parameters and ECDSA signature.

    ///      Returns false if the transaction would otherwise revert.

    /// @param order LibOrder.Order struct containing order specifications.

    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.

    /// @param signature Proof that order has been created by maker.

    /// @return Amounts filled and fees paid by maker and taker.

    function fillOrderNoThrow(

        LibOrder.Order memory order,

        uint256 takerAssetFillAmount,

        bytes memory signature

    )

        public

        returns (LibFillResults.FillResults memory fillResults);



    /// @dev Synchronously executes multiple calls of fillOrder.

    /// @param orders Array of order specifications.

    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.

    /// @param signatures Proofs that orders have been created by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function batchFillOrders(

        LibOrder.Order[] memory orders,

        uint256[] memory takerAssetFillAmounts,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously executes multiple calls of fillOrKill.

    /// @param orders Array of order specifications.

    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.

    /// @param signatures Proofs that orders have been created by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function batchFillOrKillOrders(

        LibOrder.Order[] memory orders,

        uint256[] memory takerAssetFillAmounts,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Fills an order with specified parameters and ECDSA signature.

    ///      Returns false if the transaction would otherwise revert.

    /// @param orders Array of order specifications.

    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.

    /// @param signatures Proofs that orders have been created by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function batchFillOrdersNoThrow(

        LibOrder.Order[] memory orders,

        uint256[] memory takerAssetFillAmounts,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.

    /// @param orders Array of order specifications.

    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.

    /// @param signatures Proofs that orders have been created by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function marketSellOrders(

        LibOrder.Order[] memory orders,

        uint256 takerAssetFillAmount,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.

    ///      Returns false if the transaction would otherwise revert.

    /// @param orders Array of order specifications.

    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.

    /// @param signatures Proofs that orders have been signed by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function marketSellOrdersNoThrow(

        LibOrder.Order[] memory orders,

        uint256 takerAssetFillAmount,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously executes multiple calls of fillOrder until total amount of makerAsset is bought by taker.

    /// @param orders Array of order specifications.

    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.

    /// @param signatures Proofs that orders have been signed by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function marketBuyOrders(

        LibOrder.Order[] memory orders,

        uint256 makerAssetFillAmount,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously executes multiple fill orders in a single transaction until total amount is bought by taker.

    ///      Returns false if the transaction would otherwise revert.

    /// @param orders Array of order specifications.

    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.

    /// @param signatures Proofs that orders have been signed by makers.

    /// @return Amounts filled and fees paid by makers and taker.

    function marketBuyOrdersNoThrow(

        LibOrder.Order[] memory orders,

        uint256 makerAssetFillAmount,

        bytes[] memory signatures

    )

        public

        returns (LibFillResults.FillResults memory totalFillResults);



    /// @dev Synchronously cancels multiple orders in a single transaction.

    /// @param orders Array of order specifications.

    function batchCancelOrders(LibOrder.Order[] memory orders)

        public;



    /// @dev Fetches information for all passed in orders

    /// @param orders Array of order specifications.

    /// @return Array of OrderInfo instances that correspond to each order.

    function getOrdersInfo(LibOrder.Order[] memory orders)

        public

        view

        returns (LibOrder.OrderInfo[] memory);

}







contract IERC20Token {



    // solhint-disable no-simple-event-func-name

    event Transfer(

        address indexed _from,

        address indexed _to,

        uint256 _value

    );



    event Approval(

        address indexed _owner,

        address indexed _spender,

        uint256 _value

    );



    /// @dev send `value` token to `to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return True if transfer was successful

    function transfer(address _to, uint256 _value)

        external

        returns (bool);



    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return True if transfer was successful

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

        external

        returns (bool);

    

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of wei to be approved for transfer

    /// @return Always true if the call has enough gas to complete execution

    function approve(address _spender, uint256 _value)

        external

        returns (bool);



    /// @dev Query total supply of token

    /// @return Total supply of token

    function totalSupply()

        external

        view

        returns (uint256);

    

    /// @param _owner The address from which the balance will be retrieved

    /// @return Balance of owner

    function balanceOf(address _owner)

        external

        view

        returns (uint256);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender)

        external

        view

        returns (uint256);

}







contract IERC721Token {



    /// @dev This emits when ownership of any NFT changes by any mechanism.

    ///      This event emits when NFTs are created (`from` == 0) and destroyed

    ///      (`to` == 0). Exception: during contract creation, any number of NFTs

    ///      may be created and assigned without emitting Transfer. At the time of

    ///      any transfer, the approved address for that NFT (if any) is reset to none.

    event Transfer(

        address indexed _from,

        address indexed _to,

        uint256 indexed _tokenId

    );



    /// @dev This emits when the approved address for an NFT is changed or

    ///      reaffirmed. The zero address indicates there is no approved address.

    ///      When a Transfer event emits, this also indicates that the approved

    ///      address for that NFT (if any) is reset to none.

    event Approval(

        address indexed _owner,

        address indexed _approved,

        uint256 indexed _tokenId

    );



    /// @dev This emits when an operator is enabled or disabled for an owner.

    ///      The operator can manage all NFTs of the owner.

    event ApprovalForAll(

        address indexed _owner,

        address indexed _operator,

        bool _approved

    );



    /// @notice Transfers the ownership of an NFT from one address to another address

    /// @dev Throws unless `msg.sender` is the current owner, an authorized

    ///      perator, or the approved address for this NFT. Throws if `_from` is

    ///      not the current owner. Throws if `_to` is the zero address. Throws if

    ///      `_tokenId` is not a valid NFT. When transfer is complete, this function

    ///      checks if `_to` is a smart contract (code size > 0). If so, it calls

    ///      `onERC721Received` on `_to` and throws if the return value is not

    ///      `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    /// @param _data Additional data with no specified format, sent in call to `_to`

    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId,

        bytes _data

    )

        external;



    /// @notice Transfers the ownership of an NFT from one address to another address

    /// @dev This works identically to the other function with an extra data parameter,

    ///      except this function just sets data to "".

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId

    )

        external;



    /// @notice Change or reaffirm the approved address for an NFT

    /// @dev The zero address indicates there is no approved address.

    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized

    ///      operator of the current owner.

    /// @param _approved The new approved NFT controller

    /// @param _tokenId The NFT to approve

    function approve(address _approved, uint256 _tokenId)

        external;



    /// @notice Enable or disable approval for a third party ("operator") to manage

    ///         all of `msg.sender`'s assets

    /// @dev Emits the ApprovalForAll event. The contract MUST allow

    ///      multiple operators per owner.

    /// @param _operator Address to add to the set of authorized operators

    /// @param _approved True if the operator is approved, false to revoke approval

    function setApprovalForAll(address _operator, bool _approved)

        external;



    /// @notice Count all NFTs assigned to an owner

    /// @dev NFTs assigned to the zero address are considered invalid, and this

    ///      function throws for queries about the zero address.

    /// @param _owner An address for whom to query the balance

    /// @return The number of NFTs owned by `_owner`, possibly zero

    function balanceOf(address _owner)

        external

        view

        returns (uint256);



    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE

    ///         TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE

    ///         THEY MAY BE PERMANENTLY LOST

    /// @dev Throws unless `msg.sender` is the current owner, an authorized

    ///      operator, or the approved address for this NFT. Throws if `_from` is

    ///      not the current owner. Throws if `_to` is the zero address. Throws if

    ///      `_tokenId` is not a valid NFT.

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    function transferFrom(

        address _from,

        address _to,

        uint256 _tokenId

    )

        public;



    /// @notice Find the owner of an NFT

    /// @dev NFTs assigned to zero address are considered invalid, and queries

    ///      about them do throw.

    /// @param _tokenId The identifier for an NFT

    /// @return The address of the owner of the NFT

    function ownerOf(uint256 _tokenId)

        public

        view

        returns (address);



    /// @notice Get the approved address for a single NFT

    /// @dev Throws if `_tokenId` is not a valid NFT.

    /// @param _tokenId The NFT to find the approved address for

    /// @return The approved address for this NFT, or the zero address if there is none

    function getApproved(uint256 _tokenId) 

        public

        view

        returns (address);

    

    /// @notice Query if an address is an authorized operator for another address

    /// @param _owner The address that owns the NFTs

    /// @param _operator The address that acts on behalf of the owner

    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise

    function isApprovedForAll(address _owner, address _operator)

        public

        view

        returns (bool);

}







contract IExchange is

    IExchangeCore,

    IMatchOrders,

    ISignatureValidator,

    ITransactions,

    IAssetProxyDispatcher,

    IWrapperFunctions

{}







contract OrderValidator {



    using LibBytes for bytes;



    bytes4 constant internal ERC20_DATA_ID = bytes4(keccak256("ERC20Token(address)"));

    bytes4 constant internal ERC721_DATA_ID = bytes4(keccak256("ERC721Token(address,uint256)"));



    struct TraderInfo {

        uint256 makerBalance;       // Maker's balance of makerAsset

        uint256 makerAllowance;     // Maker's allowance to corresponding AssetProxy

        uint256 takerBalance;       // Taker's balance of takerAsset

        uint256 takerAllowance;     // Taker's allowance to corresponding AssetProxy

        uint256 makerZrxBalance;    // Maker's balance of ZRX

        uint256 makerZrxAllowance;  // Maker's allowance of ZRX to ERC20Proxy

        uint256 takerZrxBalance;    // Taker's balance of ZRX

        uint256 takerZrxAllowance;  // Taker's allowance of ZRX to ERC20Proxy

    }



    // solhint-disable var-name-mixedcase

    IExchange internal EXCHANGE;

    bytes internal ZRX_ASSET_DATA;

    // solhint-enable var-name-mixedcase



    constructor (address _exchange, bytes memory _zrxAssetData)

        public

    {

        EXCHANGE = IExchange(_exchange);

        ZRX_ASSET_DATA = _zrxAssetData;

    }



    /// @dev Fetches information for order and maker/taker of order.

    /// @param order The order structure.

    /// @param takerAddress Address that will be filling the order.

    /// @return OrderInfo and TraderInfo instances for given order.

    function getOrderAndTraderInfo(LibOrder.Order memory order, address takerAddress)

        public

        view

        returns (LibOrder.OrderInfo memory orderInfo, TraderInfo memory traderInfo)

    {

        orderInfo = EXCHANGE.getOrderInfo(order);

        traderInfo = getTraderInfo(order, takerAddress);

        return (orderInfo, traderInfo);

    }



    /// @dev Fetches information for all passed in orders and the makers/takers of each order.

    /// @param orders Array of order specifications.

    /// @param takerAddresses Array of taker addresses corresponding to each order.

    /// @return Arrays of OrderInfo and TraderInfo instances that correspond to each order.

    function getOrdersAndTradersInfo(LibOrder.Order[] memory orders, address[] memory takerAddresses)

        public

        view

        returns (LibOrder.OrderInfo[] memory ordersInfo, TraderInfo[] memory tradersInfo)

    {

        ordersInfo = EXCHANGE.getOrdersInfo(orders);

        tradersInfo = getTradersInfo(orders, takerAddresses);

        return (ordersInfo, tradersInfo);

    }



    /// @dev Fetches balance and allowances for maker and taker of order.

    /// @param order The order structure.

    /// @param takerAddress Address that will be filling the order.

    /// @return Balances and allowances of maker and taker of order.

    function getTraderInfo(LibOrder.Order memory order, address takerAddress)

        public

        view

        returns (TraderInfo memory traderInfo)

    {

        (traderInfo.makerBalance, traderInfo.makerAllowance) = getBalanceAndAllowance(order.makerAddress, order.makerAssetData);

        (traderInfo.takerBalance, traderInfo.takerAllowance) = getBalanceAndAllowance(takerAddress, order.takerAssetData);

        bytes memory zrxAssetData = ZRX_ASSET_DATA;

        (traderInfo.makerZrxBalance, traderInfo.makerZrxAllowance) = getBalanceAndAllowance(order.makerAddress, zrxAssetData);

        (traderInfo.takerZrxBalance, traderInfo.takerZrxAllowance) = getBalanceAndAllowance(takerAddress, zrxAssetData);

        return traderInfo;

    }



    /// @dev Fetches balances and allowances of maker and taker for each provided order.

    /// @param orders Array of order specifications.

    /// @param takerAddresses Array of taker addresses corresponding to each order.

    /// @return Array of balances and allowances for maker and taker of each order.

    function getTradersInfo(LibOrder.Order[] memory orders, address[] memory takerAddresses)

        public

        view

        returns (TraderInfo[] memory)

    {

        uint256 ordersLength = orders.length;

        TraderInfo[] memory tradersInfo = new TraderInfo[](ordersLength);

        for (uint256 i = 0; i != ordersLength; i++) {

            tradersInfo[i] = getTraderInfo(orders[i], takerAddresses[i]);

        }

        return tradersInfo;

    }



    /// @dev Fetches token balances and allowances of an address to given assetProxy. Supports ERC20 and ERC721.

    /// @param target Address to fetch balances and allowances of.

    /// @param assetData Encoded data that can be decoded by a specified proxy contract when transferring asset.

    /// @return Balance of asset and allowance set to given proxy of asset.

    ///         For ERC721 tokens, these values will always be 1 or 0.

    function getBalanceAndAllowance(address target, bytes memory assetData)

        public

        view

        returns (uint256 balance, uint256 allowance)

    {

        bytes4 assetProxyId = assetData.readBytes4(0);

        address token = assetData.readAddress(16);

        address assetProxy = EXCHANGE.getAssetProxy(assetProxyId);



        if (assetProxyId == ERC20_DATA_ID) {

            // Query balance

            balance = IERC20Token(token).balanceOf(target);



            // Query allowance

            allowance = IERC20Token(token).allowance(target, assetProxy);

        } else if (assetProxyId == ERC721_DATA_ID) {

            uint256 tokenId = assetData.readUint256(36);



            // Query owner of tokenId

            address owner = getERC721TokenOwner(token, tokenId);



            // Set balance to 1 if tokenId is owned by target

            balance = target == owner ? 1 : 0;



            // Check if ERC721Proxy is approved to spend tokenId

            bool isApproved = IERC721Token(token).isApprovedForAll(target, assetProxy);

            

            // Set alowance to 1 if ERC721Proxy is approved to spend tokenId

            allowance = isApproved ? 1 : 0;

        } else {

            revert("UNSUPPORTED_ASSET_PROXY");

        }

        return (balance, allowance);

    }



    /// @dev Fetches token balances and allowances of an address for each given assetProxy. Supports ERC20 and ERC721.

    /// @param target Address to fetch balances and allowances of.

    /// @param assetData Array of encoded byte arrays that can be decoded by a specified proxy contract when transferring asset.

    /// @return Balances and allowances of assets.

    ///         For ERC721 tokens, these values will always be 1 or 0.

    function getBalancesAndAllowances(address target, bytes[] memory assetData)

        public

        view

        returns (uint256[] memory, uint256[] memory)

    {

        uint256 length = assetData.length;

        uint256[] memory balances = new uint256[](length);

        uint256[] memory allowances = new uint256[](length);

        for (uint256 i = 0; i != length; i++) {

            (balances[i], allowances[i]) = getBalanceAndAllowance(target, assetData[i]);

        }

        return (balances, allowances);

    }



    /// @dev Calls `token.ownerOf(tokenId)`, but returns a null owner instead of reverting on an unowned token.

    /// @param token Address of ERC721 token.

    /// @param tokenId The identifier for the specific NFT.

    /// @return Owner of tokenId or null address if unowned.

    function getERC721TokenOwner(address token, uint256 tokenId)

        public

        view

        returns (address owner)

    {

        assembly {

            // load free memory pointer

            let cdStart := mload(64)



            // bytes4(keccak256(ownerOf(uint256))) = 0x6352211e

            mstore(cdStart, 0x6352211e00000000000000000000000000000000000000000000000000000000)

            mstore(add(cdStart, 4), tokenId)



            // staticcall `ownerOf(tokenId)`

            // `ownerOf` will revert if tokenId is not owned

            let success := staticcall(

                gas,      // forward all gas

                token,    // call token contract

                cdStart,  // start of calldata

                36,       // length of input is 36 bytes

                cdStart,  // write output over input

                32        // size of output is 32 bytes

            )



            // Success implies that tokenId is owned

            // Copy owner from return data if successful

            if success {

                owner := mload(cdStart)

            }    

        }



        // Owner initialized to address(0), no need to modify if call is unsuccessful

        return owner;

    }

}
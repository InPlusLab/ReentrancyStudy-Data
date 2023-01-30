/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

// File: localhost/contracts/sign/ISign.sol

pragma solidity ^0.5.0;

interface ISign {
    function signed(bytes32 hash) external view returns (bool);
}

// File: localhost/contracts/migrate/Migratable.sol

pragma solidity ^0.5.0;

interface Migratable {
    function migrateTo(address user, address token, uint256 amount) payable external;
}

// File: localhost/contracts/SerializableTransferral.sol

pragma solidity ^0.5.0;



/**
 * @title Serializable Transferral
 * @author Ben Huang
 * @notice Let transferral support serialization and deserialization
 */
contract SerializableTransferral {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public TRANSFERRAL_1_SIZE = 25;
    uint constant public RECEIVER_SIZE = 86;
    uint8 constant internal _MASK_IS_ETH = 0x01;

    /**
     * @notice Get from address from the serialized transferral data
     * @param ser_data Serialized transferral data
     * @return from User address
     */
    function _getTransferralFrom(bytes memory ser_data) internal pure returns (address from) {
        from = ser_data.toAddress(ser_data.length - 20);
    }

    /**
     * @notice Check if the fee is paid by transferral token
     * @param ser_data Serialized transferral data
     * @return fETH Is the fee paid in transferral token or DGO
     */
    function _isTransferralFeeMain(bytes memory ser_data) internal pure returns (bool fFeeETH) {
        fFeeETH = (ser_data.toUint8(ser_data.length - 21) & _MASK_IS_ETH != 0);
    }

    /**
     * @notice Get nonce from the serialized transferral data
     * @param ser_data Serialized transferral data
     * @return nonce Nonce
     */
    function _getTransferralNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {
        nonce = ser_data.toUint32(ser_data.length - 25);
    }

    /**
     * @notice Get receiver count
     * @param ser_data Serialized transferral data
     * @return n The transferral receiver amount
     */
    function _getTransferralCount(bytes memory ser_data) internal pure returns (uint256 n) {
        n = (ser_data.length - TRANSFERRAL_1_SIZE) / RECEIVER_SIZE;
    }

    /**
     * @notice Get receiver address to be transferred to
     * @param ser_data Serialized transferral data
     * @param index The index of receiver address to be transferred to
     * @return to The address to be transferred to
     */
    function _getTransferralTo(bytes memory ser_data, uint index) internal pure returns (address to) {
        require(index < _getTransferralCount(ser_data));
        to = ser_data.toAddress(ser_data.length - TRANSFERRAL_1_SIZE - (RECEIVER_SIZE.mul(index)) - 20);
    }

    /**
     * @notice Get token address to be transferred
     * @param ser_data Serialized transferral data
     * @param index The index of token address to be transferred to
     * @return token The token address to be transferred
     */
    function _getTransferralTokenID(bytes memory ser_data, uint index) internal pure returns (uint256 token) {
        require(index < _getTransferralCount(ser_data));
        token = ser_data.toUint16(ser_data.length - TRANSFERRAL_1_SIZE - (RECEIVER_SIZE.mul(index)) - 22);
    }

    /**
     * @notice Get token amount to be transferred
     * @param ser_data Serialized transferral data
     * @param index The index of token amount to be transferred to
     * @return amount The amount to be transferred
     */
    function _getTransferralAmount(bytes memory ser_data, uint index) internal pure returns (uint256 amount) {
        require(index < _getTransferralCount(ser_data));
        amount = ser_data.toUint(ser_data.length - TRANSFERRAL_1_SIZE - (RECEIVER_SIZE.mul(index)) - 54);
    }

    /**
     * @notice Get token amount to be transferred
     * @param ser_data Serialized transferral data
     * @param index The index of token amount to be transferred to
     * @return fee The fee amount
     */
    function _getTransferralFee(bytes memory ser_data, uint index) internal pure returns (uint256 fee) {
        require(index < _getTransferralCount(ser_data));
        fee = ser_data.toUint(ser_data.length - TRANSFERRAL_1_SIZE - (RECEIVER_SIZE.mul(index)) - 86);
    }

    /**
     * @notice Get hash from the serialized transferral data
     * @param ser_data Serialized transferral data
     * @return hash Transferral hash without signature
     */
    function _getTransferralHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data);
    }

    /**
     * @notice Get hash from the transferral parameters
     */
    function getTransferralHash(
        address from,
        uint8 config,
        uint32 nonce,
        address[] memory tos,
        uint16[] memory tokenIDs,
        uint256[] memory amounts,
        uint256[] memory fees
    ) public pure returns (bytes32 hash) {
        uint256 count = tos.length;
        bytes memory ser;
        for (uint256 i = 0; i < count; i++) {
            ser = abi.encodePacked(fees[i], amounts[i], tokenIDs[i], tos[i], ser);
        }
        ser = abi.encodePacked(ser, nonce, config, from);
        hash = _getTransferralHash(ser);
    }
}

// File: localhost/contracts/SerializableMigration.sol

pragma solidity ^0.5.0;



/**
 * @title Serializable Migration
 * @author Ben Huang
 * @notice Let migration support serialization and deserialization
 */
contract SerializableMigration {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public MIGRATION_1_SIZE = 24;
    uint constant public TOKENID_SIZE = 2;
    uint8 constant internal _MASK_IS_ETH = 0x01;

    /**
     * @notice Get target address from the serialized migration data
     * @param ser_data Serialized migration data
     * @return target Target contract address
     */
    function _getMigrationTarget(bytes memory ser_data) internal pure returns (address target) {
        target = ser_data.toAddress(ser_data.length - 20);
    }

    /**
     * @notice Get user ID from the serialized migration data
     * @param ser_data Serialized migration data
     * @return userID User ID
     */
    function _getMigrationUserID(bytes memory ser_data) internal pure returns (uint256 userID) {
        userID = ser_data.toUint32(ser_data.length - 24);
    }

    /**
     * @notice Get token count
     * @param ser_data Serialized migration data
     * @return n The migrate token amount
     */
    function _getMigrationCount(bytes memory ser_data) internal pure returns (uint256 n) {
        n = (ser_data.length - MIGRATION_1_SIZE) / TOKENID_SIZE;
    }

    /**
     * @notice Get token ID to be migrated
     * @param ser_data Serialized migration data
     * @param index The index of token ID to be migrated
     * @return tokenID The token ID to be migrated
     */
    function _getMigrationTokenID(bytes memory ser_data, uint index) internal pure returns (uint256 tokenID) {
        require(index < _getMigrationCount(ser_data));
        tokenID = ser_data.toUint16(ser_data.length - MIGRATION_1_SIZE - (TOKENID_SIZE.mul(index + 1)));
    }

    /**
     * @notice Get hash from the serialized migration data
     * @param ser_data Serialized migration data
     * @return hash Migration hash without signature
     */
    function _getMigrationHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data);
    }
}

// File: localhost/contracts/SerializableWithdrawal.sol

pragma solidity ^0.5.0;



/**
 * @title Serializable Withdrawal
 * @author Ben Huang
 * @notice Let withdrawal support serialization and deserialization
 */
contract SerializableWithdrawal {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public WITHDRAWAL_SIZE = 75;
    uint8 constant internal _MASK_IS_MAIN = 0x01;

    /**
     * @notice Get user ID from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return userID User ID
     */
    function _getWithdrawalUserID(bytes memory ser_data) internal pure returns (uint256 userID) {
        userID = ser_data.toUint32(WITHDRAWAL_SIZE - 4);
    }

    /**
     * @notice Get token ID from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return tokenID Withdrawal token ID
     */
    function _getWithdrawalTokenID(bytes memory ser_data) internal pure returns (uint256 tokenID) {
        tokenID = ser_data.toUint16(WITHDRAWAL_SIZE - 6);
    }

    /**
     * @notice Get amount from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return amount Withdrawal token amount
     */
    function _getWithdrawalAmount(bytes memory ser_data) internal pure returns (uint256 amount) {
        amount = ser_data.toUint(WITHDRAWAL_SIZE - 38);
    }

    /**
     * @notice Check if the fee is paid by main token
     * @param ser_data Serialized withdrawal data
     * @return fFeeMain Is the fee paid in withdraw token or DGO
     */
    function _isWithdrawalFeeMain(bytes memory ser_data) internal pure returns (bool fFeeMain) {
        fFeeMain = (ser_data.toUint8(WITHDRAWAL_SIZE - 39) & _MASK_IS_MAIN != 0);
    }

    /**
     * @notice Get nonce from the serialized withrawal data
     * @param ser_data Serialized withdrawal data
     * @return nonce Nonce
     */
    function _getWithdrawalNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {
        nonce = ser_data.toUint32(WITHDRAWAL_SIZE - 43);
    }

    /**
     * @notice Get fee amount from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return fee Fee amount
     */
    function _getWithdrawalFee(bytes memory ser_data) internal pure returns (uint256 fee) {
        fee = ser_data.toUint(WITHDRAWAL_SIZE - 75);
    }

    /**
     * @notice Get hash from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return hash Withdrawal hash without signature
     */
    function _getWithdrawalHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data);
    }
}

// File: localhost/contracts/SerializableOrder.sol

pragma solidity ^0.5.0;



/**
 * @title Serializable Order
 * @author Ben Huang
 * @notice Let order support serialization and deserialization
 */
contract SerializableOrder {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public ORDER_SIZE = 141;
    uint8 constant internal _MASK_IS_BUY = 0x01;
    uint8 constant internal _MASK_IS_MAIN = 0x02;

    /**
     * @notice Get user ID from the serialized order data
     * @param ser_data Serialized order data
     * @return userID User ID
     */
    function _getOrderUserID(bytes memory ser_data) internal pure returns (uint256 userID) {
        userID = ser_data.toUint32(ORDER_SIZE - 4);
    }

    /**
     * @notice Get base token ID from the serialized order data
     * @param ser_data Serialized order data
     * @return tokenBase Base token ID
     */
    function _getOrderTokenIDBase(bytes memory ser_data) internal pure returns (uint256 tokenBase) {
        tokenBase = ser_data.toUint16(ORDER_SIZE - 6);
    }

    /**
     * @notice Get base token amount from the serialized order data
     * @param ser_data Serialized order data
     * @return amountBase Base token amount
     */
    function _getOrderAmountBase(bytes memory ser_data) internal pure returns (uint256 amountBase) {
        amountBase = ser_data.toUint(ORDER_SIZE - 38);
    }

    /**
     * @notice Get quote token ID from the serialized order data
     * @param ser_data Serialized order data
     * @return tokenQuote Quote token ID
     */
    function _getOrderTokenIDQuote(bytes memory ser_data) internal pure returns (uint256 tokenQuote) {
        tokenQuote = ser_data.toUint16(ORDER_SIZE - 40);
    }

    /**
     * @notice Get quote token amount from the serialized order data
     * @param ser_data Serialized order data
     * @return amountQuote Quote token amount
     */
    function _getOrderAmountQuote(bytes memory ser_data) internal pure returns (uint256 amountQuote) {
        amountQuote = ser_data.toUint(ORDER_SIZE - 72);
    }

    /**
     * @notice Check if the order is a buy order
     * @param ser_data Serialized order data
     * @return fBuy Is buy order or not
     */
    function _isOrderBuy(bytes memory ser_data) internal pure returns (bool fBuy) {
        fBuy = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_BUY != 0);
    }

    /**
     * @notice Check if the fee is paid by main token
     * @param ser_data Serialized order data
     * @return fMain Is the fee paid in main token or not
     */
    function _isOrderFeeMain(bytes memory ser_data) internal pure returns (bool fMain) {
        fMain = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_MAIN != 0);
    }

    /**
     * @notice Get nonce from the serialized order data
     * @param ser_data Serialized order data
     * @return nonce Nonce
     */
    function _getOrderNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {
        nonce = ser_data.toUint32(ORDER_SIZE - 77);
    }

    /**
     * @notice Get handling fee from the serialized order data
     * @param ser_data Serialized order data
     * @return fee Fee amount
     */
    function _getOrderHandleFee(bytes memory ser_data) internal pure returns (uint256 handleFee) {
        handleFee = ser_data.toUint(ORDER_SIZE - 109);
    }

    /**
     * @notice Get gas fee from the serialized order data
     * @param ser_data Serialized order data
     * @return fee Fee amount
     */
    function _getOrderGasFee(bytes memory ser_data) internal pure returns (uint256 gasFee) {
        gasFee = ser_data.toUint(ORDER_SIZE - 141);
    }

    /**
     * @notice Get hash from the serialized order data
     * @param ser_data Serialized order data
     * @return hash Order hash without signature
     */
    function _getOrderHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data);
    }

    /**
     * @notice Fetch the serialized order data with the given index
     * @param ser_data Serialized order data
     * @param index The index of order to be fetched
     * @return order_data The fetched order data
     */
    function _getOrder(bytes memory ser_data, uint index) internal pure returns (bytes memory order_data) {
        require(index < _getOrderCount(ser_data));
        order_data = ser_data.slice(ORDER_SIZE.mul(index), ORDER_SIZE);
    }

    /**
     * @notice Count the order amount
     * @param ser_data Serialized order data
     * @return amount Order amount
     */
    function _getOrderCount(bytes memory ser_data) internal pure returns (uint256 amount) {
        amount = ser_data.length.div(ORDER_SIZE);
    }
}

// File: bytes/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */

pragma solidity ^0.5.0;


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

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {
        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {
        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {
        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
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
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * (.note) This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * (.warning) `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise)
     * be too long), and then calling `toEthSignedMessageHash` on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)
     * JSON-RPC method.
     *
     * See `recover`.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: localhost/contracts/Dinngo.sol

pragma solidity 0.5.12;











/**
 * @title Dinngo
 * @author Ben Huang
 * @notice Main exchange contract for Dinngo
 */
contract Dinngo is
    SerializableOrder,
    SerializableWithdrawal,
    SerializableMigration,
    SerializableTransferral
{
    // Storage alignment
    address private _owner;
    mapping (address => bool) private admins;
    uint256 private _nAdmin;
    uint256 private _nLimit;
    // end
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint256 public processTime;

    mapping (address => mapping (address => uint256)) public balances;
    mapping (bytes32 => uint256) public orderFills;
    mapping (uint256 => address payable) public userID_Address;
    mapping (uint256 => address) public tokenID_Address;
    mapping (address => uint256) public nonces;
    mapping (address => uint256) public ranks;
    mapping (address => uint256) public lockTimes;

    address public walletOwner;
    address public DGOToken;
    uint8 public eventConf;

    // On/Off by _isEventUserOn()
    event AddUser(uint256 userID, address indexed user);
    // On/Off by _isEventTokenOn()
    event AddToken(uint256 tokenID, address indexed token);
    // On/Off by _isEventFundsOn()
    event Deposit(address token, address indexed user, uint256 amount, uint256 balance);
    event Withdraw(
        address token,
        address indexed user,
        uint256 amount,
        uint256 balance,
        address tokenFee,
        uint256 amountFee
    );
    event Trade(
        address indexed user,
        bool isBuy,
        address indexed tokenBase,
        uint256 amountBase,
        address indexed tokenQuote,
        uint256 amountQuote,
        address tokenFee,
        uint256 amountFee
    );
    event Transfer(
        address indexed from,
        address indexed to,
        address token,
        uint256 amount,
        address feeToken,
        uint256 feeAmount
    );
    // On/Off by _isEventUserOn()
    event Lock(address indexed user, uint256 lockTime);
    event Unlock(address indexed user);

    uint256 constant public version = 2;

    uint8 constant internal _MASK_EVENT_USER = 0x01;
    uint8 constant internal _MASK_EVENT_TOKEN = 0x02;
    uint8 constant internal _MASK_EVENT_FUNDS = 0x04;

    /**
     * @dev bit 0: user event
     *      bit 1: token event
     *      bit 2: funds event
     * @notice Set the event switch configuration.
     * @param conf Event configuration
     */
    function setEvent(uint8 conf) external {
        require(eventConf != conf);
        eventConf = conf;
    }

    /**
     * @notice Add the address to the user list. Event AddUser will be emitted
     * after execution.
     * @dev Record the user list to map the user address to a specific user ID, in
     * order to compact the data size when transferring user address information
     * @dev id should be less than 2**32
     * @param id The user id to be assigned
     * @param user The user address to be added
     */
    function addUser(uint256 id, address payable user) external {
        require(user != address(0));
        require(ranks[user] == 0);
        require(id < 2**32);
        if (userID_Address[id] == address(0))
            userID_Address[id] = user;
        else
            require(userID_Address[id] == user);
        ranks[user] = 1;
        if (_isEventUserOn())
            emit AddUser(id, user);
    }

    /**
     * @notice Add the token to the token list. Event AddToken will be emitted
     * after execution.
     * @dev Record the token list to map the token contract address to a specific
     * token ID, in order to compact the data size when transferring token contract
     * address information
     * @dev id should be less than 2**16
     * @param id The token id to be assigned
     * @param token The token contract address to be added
     */
    function addToken(uint256 id, address token) external {
        require(token != address(0));
        require(ranks[token] == 0);
        require(id < 2**16);
        if (tokenID_Address[id] == address(0))
            tokenID_Address[id] = token;
        else
            require(tokenID_Address[id] == token);
        ranks[token] = 1;
        if (_isEventTokenOn())
            emit AddToken(id, token);
    }

    /**
     * @notice Update the rank of user or token.
     * @param addr The address to be updated.
     * @param rank The rank to be assigned.
     */
    function updateRank(address addr, uint256 rank) external {
        require(addr != address(0));
        require(rank != 0);
        require(ranks[addr] != 0);
        require(ranks[addr] != rank);
        ranks[addr] = rank;
    }

    /**
     * @notice Remove the user or token.
     * @dev The rank is set to 0 to remove.
     * @param addr The address to be removed.
     */
    function remove(address addr) external {
        require(addr != address(0));
        require(ranks[addr] != 0);
        ranks[addr] = 0;
    }

    /**
     * @notice The deposit function for ether. The ether that is sent with the function
     * call will be deposited. The first time user will be added to the user list.
     * Event Deposit will be emitted after execution.
     */
    function deposit() external payable {
        require(!_isLocking(msg.sender));
        require(msg.value > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].add(msg.value);
        if (_isEventFundsOn())
            emit Deposit(address(0), msg.sender, msg.value, balances[address(0)][msg.sender]);
    }

    /**
     * @notice The deposit function for tokens. The first time user will be added to
     * the user list. Event Deposit will be emitted after execution.
     * @param token Address of the token contract to be deposited
     * @param amount Amount of the token to be depositied
     */
    function depositToken(address token, uint256 amount) external {
        require(token != address(0));
        require(!_isLocking(msg.sender));
        require(_isValid(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].add(amount);
        if (_isEventFundsOn())
            emit Deposit(token, msg.sender, amount, balances[token][msg.sender]);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice The withdraw function for ether. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param amount The amount to be withdrawn.
     */
    function withdraw(uint256 amount) external {
        require(_isLocked(msg.sender));
        require(_isValid(msg.sender));
        require(amount > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].sub(amount);
        if (_isEventFundsOn())
            emit Withdraw(address(0), msg.sender, amount, balances[address(0)][msg.sender], address(0), 0);
        msg.sender.transfer(amount);
    }

    /**
     * @notice The withdraw function for tokens. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param token The token contract address to be withdrawn.
     * @param amount The token amount to be withdrawn.
     */
    function withdrawToken(address token, uint256 amount) external {
        require(token != address(0));
        require(_isLocked(msg.sender));
        require(_isValid(msg.sender));
        require(_isValid(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].sub(amount);
        if (_isEventFundsOn())
            emit Withdraw(token, msg.sender, amount, balances[token][msg.sender], address(0), 0);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice The extract function for fee in ether. Can only be triggered by
     * the dinngo wallet owner.
     * @param amount The amount to be withdrawn
     */
    function extractFee(uint256 amount) external {
        require(amount > 0);
        require(msg.sender == walletOwner);
        balances[address(0)][address(0)] = balances[address(0)][address(0)].sub(amount);
        msg.sender.transfer(amount);
    }

    /**
     * @notice The extract function for fee in token. Can only be triggered by
     * the dinngo wallet owner.
     * @param token The token contract address to be withdrawn
     * @param amount The amount to be withdrawn
     */
    function extractTokenFee(address token, uint256 amount) external {
        require(amount > 0);
        require(msg.sender ==  walletOwner);
        require(token != address(0));
        balances[token][address(0)] = balances[token][address(0)].sub(amount);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice The function to get the balance from fee account.
     * @param token The token of the balance to be queried
     */
    function getWalletBalance(address token) external view returns (uint256) {
        return balances[token][address(0)];
    }

    /**
     * @notice The function to change the owner of fee wallet.
     * @param newOwner The new wallet owner to be assigned
     */
    function changeWalletOwner(address newOwner) external {
        require(newOwner != address(0));
        require(newOwner != walletOwner);
        walletOwner = newOwner;
    }

    /**
     * @notice The withdraw function that can only be triggered by owner.
     * Event Withdraw will be emitted after execution.
     * @param withdrawal The serialized withdrawal data
     */
    function withdrawByAdmin(bytes calldata withdrawal, bytes calldata signature) external {
        address payable user = userID_Address[_getWithdrawalUserID(withdrawal)];
        require(_isValid(user), "user invalid");
        uint256 nonce = _getWithdrawalNonce(withdrawal);
        require(nonce > nonces[user], "nonce invalid");
        nonces[user] = nonce;
        _verifySig(user, _getWithdrawalHash(withdrawal), signature);
        uint256 tokenID = _getWithdrawalTokenID(withdrawal);
        address token = tokenID == 0? address(0) : tokenID_Address[tokenID];
        uint256 amount = _getWithdrawalAmount(withdrawal);
        uint256 amountFee = _getWithdrawalFee(withdrawal);
        uint256 balance = balances[token][user];
        bool fFeeMain = _isWithdrawalFeeMain(withdrawal);

        if (fFeeMain) {
            balance = balance.sub(amount).sub(amountFee);
            balances[token][address(0)] = balances[token][address(0)].add(amountFee);
        } else {
            balance = balance.sub(amount);
            balances[DGOToken][user] = balances[DGOToken][user].sub(amountFee);
            balances[DGOToken][address(0)] = balances[DGOToken][address(0)].add(amountFee);
        }
        balances[token][user] = balance;

        if (_isEventFundsOn()) {
            if (fFeeMain)
                emit Withdraw(token, user, amount, balance, token, amountFee);
            else
                emit Withdraw(token, user, amount, balance, DGOToken, amountFee);
        }

        if (token == address(0)) {
            user.transfer(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    /**
     * @notice The migrate function the can only triggered by admin.
     * Event Migrate will be emitted after execution.
     * @param migration The serialized migration data
     */
    function migrateByAdmin(bytes calldata migration, bytes calldata signature) external {
        address target = _getMigrationTarget(migration);
        address user = userID_Address[_getMigrationUserID(migration)];
        uint256 nToken = _getMigrationCount(migration);
        require(_isValid(user), "user invalid");
        _verifySig(user, _getWithdrawalHash(migration), signature);
        for (uint i = 0; i < nToken; i++) {
            address token = tokenID_Address[_getMigrationTokenID(migration, i)];
            uint256 balance = balances[token][user];
            require(balance != 0, "0 amount");
            balances[token][user] = 0;
            if (token == address(0)) {
                Migratable(target).migrateTo.value(balance)(user, token, balance);
            } else {
                IERC20(token).safeApprove(target, balance);
                Migratable(target).migrateTo(user, token, balance);
            }
        }
    }

    /**
     * @notice The migration handler
     * @param user The user address to receive the migrated amount.
     * @param token The token address to be migrated.
     * @param amount The amount to be migrated.
     */
    function migrateTo(address user, address token, uint256 amount) payable external {
        balances[token][user] = balances[token][user].add(amount);
        if (token == address(0)) {
            require(msg.value == amount);
        } else {
            _isValid(token);
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    /**
     * @notice The transfer function that can only be triggered by admin.
     * Event transfer will be emitted after execution.
     * @param transferral The serialized transferral data.
     */
    function transferByAdmin(bytes calldata transferral, bytes calldata signature) external {
        address from = _getTransferralFrom(transferral);
        bool fFeeMain = _isTransferralFeeMain(transferral);
        uint256 feeDGO = 0;
        uint256 nTransferral = _getTransferralCount(transferral);
        uint256 nonce = _getTransferralNonce(transferral);
        require(nonce > nonces[from], "nonce invalid");
        nonces[from] = nonce;
        for (uint256 i = 0; i < nTransferral; i++) {
            address to = _getTransferralTo(transferral, i);
            address token = tokenID_Address[_getTransferralTokenID(transferral, i)];
            uint256 amount = _getTransferralAmount(transferral, i);
            uint256 fee = _getTransferralFee(transferral, i);
            if (fFeeMain) {
                balances[token][from] = balances[token][from].sub(amount).sub(fee);
                balances[token][to] = balances[token][to].add(amount);
                balances[token][address(0)] = balances[token][address(0)].add(fee);
                if (_isEventFundsOn())
                    emit Transfer(from, to, token, amount, token, fee);
            } else {
                balances[token][from] = balances[token][from].sub(amount);
                balances[token][to] = balances[token][to].add(amount);
                feeDGO = feeDGO.add(fee);
                if (_isEventFundsOn())
                    emit Transfer(from, to, token, amount, DGOToken, fee);
            }
        }
        if (!fFeeMain) {
            balances[DGOToken][from] = balances[DGOToken][from].sub(feeDGO);
            balances[DGOToken][address(0)] = balances[DGOToken][address(0)].add(feeDGO);
        }
        bytes32 hash = _getTransferralHash(transferral);
        if (signature.length == 65) {
            _verifySig(from, hash, signature);
            require(_isValid(from), "user invalid");
        } else {
            require(ISign(from).signed(hash), 'contract sign failed');
        }
    }

    /**
     * @notice The settle function for orders. First order is taker order and the followings
     * are maker orders.
     * @param orders The serialized orders.
     */
    function settle(bytes calldata orders, bytes calldata signatures) external {
        // Deal with the order list
        uint256 nOrder = _getOrderCount(orders);
        // Get the first order as the taker order
        bytes memory takerOrder = _getOrder(orders, 0);
        uint256[4] memory takerAmounts; //[takerAmountBase, restAmountBase, fillAmountBase, fillAmountQuote]
        takerAmounts[0] = _getOrderAmountBase(takerOrder);
        takerAmounts[1] = takerAmounts[0].sub(orderFills[_getOrderHash(takerOrder)]);
        takerAmounts[2] = takerAmounts[1];
        takerAmounts[3] = 0;
        bool fBuy = _isOrderBuy(takerOrder);
        // Parse maker orders
        for (uint256 i = 1; i < nOrder; i++) {
            // Get ith order as the maker order
            bytes memory makerOrder = _getOrder(orders, i);
            require(fBuy != _isOrderBuy(makerOrder), "buy/buy or sell/sell");
            uint256 makerAmountBase = _getOrderAmountBase(makerOrder);
            uint256 makerAmountQuote = _getOrderAmountQuote(makerOrder);
            if (fBuy) {
                require(
                    makerAmountQuote <= _getOrderAmountQuote(takerOrder).mul(makerAmountBase).div(takerAmounts[0]),
                    "buy high"
                );
            } else {
                require(
                    makerAmountQuote >= _getOrderAmountQuote(takerOrder).mul(makerAmountBase).div(takerAmounts[0]),
                    "sell low"
                );
            }
            uint256 amountBase = makerAmountBase.sub(orderFills[_getOrderHash(makerOrder)]);
            amountBase = (amountBase <= takerAmounts[1])? amountBase : takerAmounts[1];
            uint256 amountQuote = makerAmountQuote.mul(amountBase).div(makerAmountBase);
            takerAmounts[1] = takerAmounts[1].sub(amountBase);
            takerAmounts[3] = takerAmounts[3].add(amountQuote);
            // Trade amountBase and amountQuote for maker order
            bytes memory sig = signatures.slice(i.mul(65), 65);
            _trade(amountBase, amountQuote, makerOrder, sig);
        }
        // Sum the trade amount
        takerAmounts[2] = takerAmounts[2].sub(takerAmounts[1]);
        // Trade amountBase and amountQuote for taker order
        bytes memory sig = signatures.slice(0, 65);
        _trade(takerAmounts[2], takerAmounts[3], takerOrder, sig);
    }

    /**
     * @notice Announce lock of the sender
     */
    function lock() external {
        require(!_isLocking(msg.sender));
        lockTimes[msg.sender] = now.add(processTime);
        if (_isEventUserOn())
            emit Lock(msg.sender, lockTimes[msg.sender]);
    }

    /**
     * @notice Unlock the sender
     */
    function unlock() external {
        require(_isLocking(msg.sender));
        lockTimes[msg.sender] = 0;
        if (_isEventUserOn())
            emit Unlock(msg.sender);
    }

    /**
     * @notice Change the processing time of locking the user address
     */
    function changeProcessTime(uint256 time) external {
        require(processTime != time);
        processTime = time;
    }

    /**
     * @notice Process the trade by the providing information
     * @param amountBase The provided amount to be traded
     * @param amountQuote The amount to be requested
     * @param order The order that triggered the trading
     */
    function _trade(uint256 amountBase, uint256 amountQuote, bytes memory order, bytes memory signature) internal {
        require(amountBase != 0, "0 amount base");
        // Get parameters
        address user = userID_Address[_getOrderUserID(order)];
        bytes32 hash = _getOrderHash(order);
        address tokenQuote = tokenID_Address[_getOrderTokenIDQuote(order)];
        address tokenBase = tokenID_Address[_getOrderTokenIDBase(order)];
        address tokenFee;
        uint256 amountFee =
            _getOrderHandleFee(order).mul(amountBase).div(_getOrderAmountBase(order));
        require(_isValid(user), "user invalid");
        // Trade and fee setting
        if (orderFills[hash] == 0) {
            _verifySig(user, hash, signature);
            amountFee = amountFee.add(_getOrderGasFee(order));
        }
        bool fBuy = _isOrderBuy(order);
        if (fBuy) {
            balances[tokenQuote][user] = balances[tokenQuote][user].sub(amountQuote);
            if (_isOrderFeeMain(order)) {
                tokenFee = tokenBase;
                balances[tokenBase][user] = balances[tokenBase][user].add(amountBase).sub(amountFee);
                balances[tokenBase][address(0)] = balances[tokenBase][address(0)].add(amountFee);
            } else {
                tokenFee = DGOToken;
                balances[tokenBase][user] = balances[tokenBase][user].add(amountBase);
                balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
                balances[tokenFee][address(0)] = balances[tokenFee][address(0)].add(amountFee);
            }
        } else {
            balances[tokenBase][user] = balances[tokenBase][user].sub(amountBase);
            if (_isOrderFeeMain(order)) {
                tokenFee = tokenQuote;
                balances[tokenQuote][user] = balances[tokenQuote][user].add(amountQuote).sub(amountFee);
                balances[tokenQuote][address(0)] = balances[tokenQuote][address(0)].add(amountFee);
            } else {
                tokenFee = DGOToken;
                balances[tokenQuote][user] = balances[tokenQuote][user].add(amountQuote);
                balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
                balances[tokenFee][address(0)] = balances[tokenFee][address(0)].add(amountFee);
            }
        }
        // Order fill
        orderFills[hash] = orderFills[hash].add(amountBase);
        if (_isEventFundsOn())
            emit Trade
            (
                user,
                fBuy,
                tokenBase,
                amountBase,
                tokenQuote,
                amountQuote,
                tokenFee,
                amountFee
            );
    }

    /**
     * @dev Check if the user or token is valid
     * @param addr The address to be checked.
     */
    function _isValid(address addr) internal view returns (bool) {
        return ranks[addr] != 0;
    }

    function _verifySig(address user, bytes32 hash, bytes memory signature) internal pure {
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0);

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        address sigAddr = ecrecover(hash.toEthSignedMessageHash(), v, r, s);
        require(user == sigAddr, "sig failed");
    }

    /**
     * @notice Return if the give user has announced lock
     * @param user The user address to be queried
     * @return Query result
     */
    function _isLocking(address user) internal view returns (bool) {
        return lockTimes[user] > 0;
    }

    /**
     * @notice Return if the user is locked
     * @param user The user address to be queried
     */
    function _isLocked(address user) internal view returns (bool) {
        return _isLocking(user) && lockTimes[user] < now;
    }

    function _isEventUserOn() internal view returns (bool) {
        return (eventConf & _MASK_EVENT_USER != 0);
    }

    function _isEventTokenOn() internal view returns (bool) {
        return (eventConf & _MASK_EVENT_TOKEN != 0);
    }

    function _isEventFundsOn() internal view returns (bool) {
        return (eventConf & _MASK_EVENT_FUNDS != 0);
    }
}
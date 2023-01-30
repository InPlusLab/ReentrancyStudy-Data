/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;

/*

  Copyright 2019 ZeroEx Intl.

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

interface IUniswapExchange {

    /// @dev Buys at least `minTokensBought` tokens with ETH and transfer them
    ///      to `recipient`.
    /// @param minTokensBought The minimum number of tokens to buy.
    /// @param deadline Time when this order expires.
    /// @param recipient Who to transfer the tokens to.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenTransferInput(
        uint256 minTokensBought,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256 tokensBought);

    /// @dev Buys at least `minEthBought` ETH with tokens.
    /// @param tokensSold Amount of tokens to sell.
    /// @param minEthBought The minimum amount of ETH to buy.
    /// @param deadline Time when this order expires.
    /// @return ethBought Amount of tokens bought.
    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEthBought,
        uint256 deadline
    )
        external
        returns (uint256 ethBought);

    /// @dev Buys at least `minTokensBought` tokens with the exchange token
    ///      and transfer them to `recipient`.
    /// @param minTokensBought The minimum number of tokens to buy.
    /// @param minEthBought The minimum amount of intermediate ETH to buy.
    /// @param deadline Time when this order expires.
    /// @param recipient Who to transfer the tokens to.
    /// @param toTokenAddress The token being bought.
    /// @return tokensBought Amount of tokens bought.
    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address recipient,
        address toTokenAddress
    )
        external
        returns (uint256 tokensBought);
}

interface IUniswapExchangeFactory {

    /// @dev Get the exchange for a token.
    /// @param tokenAddress The address of the token contract.
    function getExchange(address tokenAddress)
        external
        view
        returns (address);
}

library LibRichErrors {

    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    // solhint-disable func-name-mixedcase
    /// @dev ABI encode a standard, string revert error payload.
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    /// @param message The error string.
    /// @return The ABI encoded error.
    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
    // solhint-enable func-name-mixedcase

    /// @dev Reverts an encoded rich revert reason `errorData`.
    /// @param errorData ABI encoded error data.
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}


library LibBytesRichErrors {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
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
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

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
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

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
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
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
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

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
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

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
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

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
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

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
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

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

    /// @dev Writes a new length to a byte array.
    ///      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    ///      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    /// @param b Bytes array to write new length to.
    /// @param length New length of byte array.
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

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

library LibERC20Token {
    bytes constant private DECIMALS_CALL_DATA = hex"313ce567";

    /// @dev Calls `IERC20Token(token).approve()`.
    ///      Reverts if `false` is returned or if the return
    ///      data length is nonzero and not 32 bytes.
    /// @param token The address of the token contract.
    /// @param spender The address that receives an allowance.
    /// @param allowance The allowance to set.
    function approve(
        address token,
        address spender,
        uint256 allowance
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).approve.selector,
            spender,
            allowance
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    /// @dev Calls `IERC20Token(token).approve()` and sets the allowance to the
    ///      maximum if the current approval is not already >= an amount.
    ///      Reverts if `false` is returned or if the return
    ///      data length is nonzero and not 32 bytes.
    /// @param token The address of the token contract.
    /// @param spender The address that receives an allowance.
    /// @param amount The minimum allowance needed.
    function approveIfBelow(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (IERC20Token(token).allowance(address(this), spender) < amount) {
            approve(token, spender, uint256(-1));
        }
    }

    /// @dev Calls `IERC20Token(token).transfer()`.
    ///      Reverts if `false` is returned or if the return
    ///      data length is nonzero and not 32 bytes.
    /// @param token The address of the token contract.
    /// @param to The address that receives the tokens
    /// @param amount Number of tokens to transfer.
    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).transfer.selector,
            to,
            amount
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    /// @dev Calls `IERC20Token(token).transferFrom()`.
    ///      Reverts if `false` is returned or if the return
    ///      data length is nonzero and not 32 bytes.
    /// @param token The address of the token contract.
    /// @param from The owner of the tokens.
    /// @param to The address that receives the tokens
    /// @param amount Number of tokens to transfer.
    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).transferFrom.selector,
            from,
            to,
            amount
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    /// @dev Retrieves the number of decimals for a token.
    ///      Returns `18` if the call reverts.
    /// @param token The address of the token contract.
    /// @return tokenDecimals The number of decimals places for the token.
    function decimals(address token)
        internal
        view
        returns (uint8 tokenDecimals)
    {
        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = token.staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length == 32) {
            tokenDecimals = uint8(LibBytes.readUint256(resultData, 0));
        }
    }

    /// @dev Retrieves the allowance for a token, owner, and spender.
    ///      Returns `0` if the call reverts.
    /// @param token The address of the token contract.
    /// @param owner The owner of the tokens.
    /// @param spender The address the spender.
    /// @return allowance The allowance for a token, owner, and spender.
    function allowance(address token, address owner, address spender)
        internal
        view
        returns (uint256 allowance_)
    {
        (bool didSucceed, bytes memory resultData) = token.staticcall(
            abi.encodeWithSelector(
                IERC20Token(0).allowance.selector,
                owner,
                spender
            )
        );
        if (didSucceed && resultData.length == 32) {
            allowance_ = LibBytes.readUint256(resultData, 0);
        }
    }

    /// @dev Retrieves the balance for a token owner.
    ///      Returns `0` if the call reverts.
    /// @param token The address of the token contract.
    /// @param owner The owner of the tokens.
    /// @return balance The token balance of an owner.
    function balanceOf(address token, address owner)
        internal
        view
        returns (uint256 balance)
    {
        (bool didSucceed, bytes memory resultData) = token.staticcall(
            abi.encodeWithSelector(
                IERC20Token(0).balanceOf.selector,
                owner
            )
        );
        if (didSucceed && resultData.length == 32) {
            balance = LibBytes.readUint256(resultData, 0);
        }
    }

    /// @dev Executes a call on address `target` with calldata `callData`
    ///      and asserts that either nothing was returned or a single boolean
    ///      was returned equal to `true`.
    /// @param target The call target.
    /// @param callData The abi-encoded call data.
    function _callWithOptionalBooleanResult(
        address target,
        bytes memory callData
    )
        private
    {
        (bool didSucceed, bytes memory resultData) = target.call(callData);
        if (didSucceed) {
            if (resultData.length == 0) {
                return;
            }
            if (resultData.length == 32) {
                uint256 result = LibBytes.readUint256(resultData, 0);
                if (result == 1) {
                    return;
                }
            }
        }
        LibRichErrors.rrevert(resultData);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

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

/*

  Copyright 2019 ZeroEx Intl.

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

library LibEIP712 {

    // Hash of the EIP712 Domain Separator Schema
    // keccak256(abi.encodePacked(
    //     "EIP712Domain(",
    //     "string name,",
    //     "string version,",
    //     "uint256 chainId,",
    //     "address verifyingContract",
    //     ")"
    // ))
    bytes32 constant internal _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev Calculates a EIP712 domain separator.
    /// @param name The EIP712 domain name.
    /// @param version The EIP712 domain version.
    /// @param verifyingContract The EIP712 verifying contract.
    /// @return EIP712 domain separator.
    function hashEIP712Domain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    )
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH;

        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
        //     keccak256(bytes(name)),
        //     keccak256(bytes(version)),
        //     chainId,
        //     uint256(verifyingContract)
        // ))

        assembly {
            // Calculate hashes of dynamic data
            let nameHash := keccak256(add(name, 32), mload(name))
            let versionHash := keccak256(add(version, 32), mload(version))

            // Load free memory pointer
            let memPtr := mload(64)

            // Store params in memory
            mstore(memPtr, schemaHash)
            mstore(add(memPtr, 32), nameHash)
            mstore(add(memPtr, 64), versionHash)
            mstore(add(memPtr, 96), chainId)
            mstore(add(memPtr, 128), verifyingContract)

            // Compute hash
            result := keccak256(memPtr, 160)
        }
        return result;
    }

    /// @dev Calculates EIP712 encoding for a hash struct with a given domain hash.
    /// @param eip712DomainHash Hash of the domain domain separator data, computed
    ///                         with getDomainHash().
    /// @param hashStruct The EIP712 hash struct.
    /// @return EIP712 hash applied to the given EIP712 Domain.
    function hashEIP712Message(bytes32 eip712DomainHash, bytes32 hashStruct)
        internal
        pure
        returns (bytes32 result)
    {
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

library LibOrder {

    using LibOrder for Order;

    // Hash for the EIP712 Order Schema:
    // keccak256(abi.encodePacked(
    //     "Order(",
    //     "address makerAddress,",
    //     "address takerAddress,",
    //     "address feeRecipientAddress,",
    //     "address senderAddress,",
    //     "uint256 makerAssetAmount,",
    //     "uint256 takerAssetAmount,",
    //     "uint256 makerFee,",
    //     "uint256 takerFee,",
    //     "uint256 expirationTimeSeconds,",
    //     "uint256 salt,",
    //     "bytes makerAssetData,",
    //     "bytes takerAssetData,",
    //     "bytes makerFeeAssetData,",
    //     "bytes takerFeeAssetData",
    //     ")"
    // ))
    bytes32 constant internal _EIP712_ORDER_SCHEMA_HASH =
        0xf80322eb8376aafb64eadf8f0d7623f22130fd9491a221e902b713cb984a7534;

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's status is unaffected by external factors, like account balances.
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
    /// @dev Canonical order structure.
    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Fee paid to feeRecipient by maker when order is filled.
        uint256 takerFee;               // Fee paid to feeRecipient by taker when order is filled.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
        bytes makerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring makerFeeAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring takerFeeAsset. The leading bytes4 references the id of the asset proxy.
    }
    // solhint-enable max-line-length

    /// @dev Order information returned by `getOrderInfo()`.
    struct OrderInfo {
        OrderStatus orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    /// @dev Calculates the EIP712 typed data hash of an order with a given domain separator.
    /// @param order The order structure.
    /// @return EIP712 typed data hash of the order.
    function getTypedDataHash(Order memory order, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 orderHash)
    {
        orderHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            order.getStructHash()
        );
        return orderHash;
    }

    /// @dev Calculates EIP712 hash of the order struct.
    /// @param order The order structure.
    /// @return EIP712 hash of the order struct.
    function getStructHash(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_ORDER_SCHEMA_HASH;
        bytes memory makerAssetData = order.makerAssetData;
        bytes memory takerAssetData = order.takerAssetData;
        bytes memory makerFeeAssetData = order.makerFeeAssetData;
        bytes memory takerFeeAssetData = order.takerFeeAssetData;

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ORDER_SCHEMA_HASH,
        //     uint256(order.makerAddress),
        //     uint256(order.takerAddress),
        //     uint256(order.feeRecipientAddress),
        //     uint256(order.senderAddress),
        //     order.makerAssetAmount,
        //     order.takerAssetAmount,
        //     order.makerFee,
        //     order.takerFee,
        //     order.expirationTimeSeconds,
        //     order.salt,
        //     keccak256(order.makerAssetData),
        //     keccak256(order.takerAssetData),
        //     keccak256(order.makerFeeAssetData),
        //     keccak256(order.takerFeeAssetData)
        // ));

        assembly {
            // Assert order offset (this is an internal error that should never be triggered)
            if lt(order, 32) {
                invalid()
            }

            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)
            let pos4 := add(order, 384)
            let pos5 := add(order, 416)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)
            let temp4 := mload(pos4)
            let temp5 := mload(pos5)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, keccak256(add(makerAssetData, 32), mload(makerAssetData)))        // store hash of makerAssetData
            mstore(pos3, keccak256(add(takerAssetData, 32), mload(takerAssetData)))        // store hash of takerAssetData
            mstore(pos4, keccak256(add(makerFeeAssetData, 32), mload(makerFeeAssetData)))  // store hash of makerFeeAssetData
            mstore(pos5, keccak256(add(takerFeeAssetData, 32), mload(takerFeeAssetData)))  // store hash of takerFeeAssetData
            result := keccak256(pos1, 480)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
            mstore(pos4, temp4)
            mstore(pos5, temp5)
        }
        return result;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

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

library LibSafeMathRichErrors {

    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    // solhint-disable func-name-mixedcase
    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}

library LibSafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
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

library LibMathRichErrors {

    // bytes4(keccak256("DivisionByZeroError()"))
    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    // bytes4(keccak256("RoundingError(uint256,uint256,uint256)"))
    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    // solhint-disable func-name-mixedcase
    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}

library LibMath {

    using LibSafeMath for uint256;

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

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

contract DeploymentConstants {
    /// @dev Mainnet address of the WETH contract.
    address constant private WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // /// @dev Kovan address of the WETH contract.
    // address constant private WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    /// @dev Mainnet address of the KyberNetworkProxy contract.
    address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    // /// @dev Kovan address of the KyberNetworkProxy contract.
    // address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;
    /// @dev Mainnet address of the `UniswapExchangeFactory` contract.
    address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    // /// @dev Kovan address of the `UniswapExchangeFactory` contract.
    // address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xD3E51Ef092B2845f10401a0159B2B96e8B6c3D30;
    /// @dev Mainnet address of the `UniswapV2Router01` contract.
    address constant private UNISWAP_V2_ROUTER_01_ADDRESS = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
    // /// @dev Kovan address of the `UniswapV2Router01` contract.
    // address constant private UNISWAP_V2_ROUTER_01_ADDRESS = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
    /// @dev Mainnet address of the Eth2Dai `MatchingMarket` contract.
    address constant private ETH2DAI_ADDRESS = 0x794e6e91555438aFc3ccF1c5076A74F42133d08D;
    // /// @dev Kovan address of the Eth2Dai `MatchingMarket` contract.
    // address constant private ETH2DAI_ADDRESS = 0xe325acB9765b02b8b418199bf9650972299235F4;
    /// @dev Mainnet address of the `ERC20BridgeProxy` contract
    address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0x8ED95d1746bf1E4dAb58d8ED4724f1Ef95B20Db0;
    // /// @dev Kovan address of the `ERC20BridgeProxy` contract
    // address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0xFb2DD2A1366dE37f7241C83d47DA58fd503E2C64;
    ///@dev Mainnet address of the `Dai` (multi-collateral) contract
    address constant private DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // ///@dev Kovan address of the `Dai` (multi-collateral) contract
    // address constant private DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    /// @dev Mainnet address of the `Chai` contract
    address constant private CHAI_ADDRESS = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    /// @dev Mainnet address of the 0x DevUtils contract.
    address constant private DEV_UTILS_ADDRESS = 0x74134CF88b21383713E096a5ecF59e297dc7f547;
    // /// @dev Kovan address of the 0x DevUtils contract.
    // address constant private DEV_UTILS_ADDRESS = 0x9402639A828BdF4E9e4103ac3B69E1a6E522eB59;
    /// @dev Kyber ETH pseudo-address.
    address constant internal KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// @dev Mainnet address of the dYdX contract.
    address constant private DYDX_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    /// @dev Mainnet address of the GST2 contract
    address constant private GST_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;
    /// @dev Mainnet address of the GST Collector
    address constant private GST_COLLECTOR_ADDRESS = 0x000000D3b08566BE75A6DB803C03C85C0c1c5B96;
    // /// @dev Kovan address of the GST2 contract
    // address constant private GST_ADDRESS = address(0);
    // /// @dev Kovan address of the GST Collector
    // address constant private GST_COLLECTOR_ADDRESS = address(0);

    /// @dev Overridable way to get the `KyberNetworkProxy` address.
    /// @return kyberAddress The `IKyberNetworkProxy` address.
    function _getKyberNetworkProxyAddress()
        internal
        view
        returns (address kyberAddress)
    {
        return KYBER_NETWORK_PROXY_ADDRESS;
    }

    /// @dev Overridable way to get the WETH address.
    /// @return wethAddress The WETH address.
    function _getWethAddress()
        internal
        view
        returns (address wethAddress)
    {
        return WETH_ADDRESS;
    }

    /// @dev Overridable way to get the `UniswapExchangeFactory` address.
    /// @return uniswapAddress The `UniswapExchangeFactory` address.
    function _getUniswapExchangeFactoryAddress()
        internal
        view
        returns (address uniswapAddress)
    {
        return UNISWAP_EXCHANGE_FACTORY_ADDRESS;
    }

    /// @dev Overridable way to get the `UniswapV2Router01` address.
    /// @return uniswapRouterAddress The `UniswapV2Router01` address.
    function _getUniswapV2Router01Address()
        internal
        view
        returns (address uniswapRouterAddress)
    {
        return UNISWAP_V2_ROUTER_01_ADDRESS;
    }

    /// @dev An overridable way to retrieve the Eth2Dai `MatchingMarket` contract.
    /// @return eth2daiAddress The Eth2Dai `MatchingMarket` contract.
    function _getEth2DaiAddress()
        internal
        view
        returns (address eth2daiAddress)
    {
        return ETH2DAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `ERC20BridgeProxy` contract.
    /// @return erc20BridgeProxyAddress The `ERC20BridgeProxy` contract.
    function _getERC20BridgeProxyAddress()
        internal
        view
        returns (address erc20BridgeProxyAddress)
    {
        return ERC20_BRIDGE_PROXY_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `Dai` contract.
    /// @return daiAddress The `Dai` contract.
    function _getDaiAddress()
        internal
        view
        returns (address daiAddress)
    {
        return DAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the `Chai` contract.
    /// @return chaiAddress The `Chai` contract.
    function _getChaiAddress()
        internal
        view
        returns (address chaiAddress)
    {
        return CHAI_ADDRESS;
    }

    /// @dev An overridable way to retrieve the 0x `DevUtils` contract address.
    /// @return devUtils The 0x `DevUtils` contract address.
    function _getDevUtilsAddress()
        internal
        view
        returns (address devUtils)
    {
        return DEV_UTILS_ADDRESS;
    }

    /// @dev Overridable way to get the DyDx contract.
    /// @return exchange The DyDx exchange contract.
    function _getDydxAddress()
        internal
        view
        returns (address dydxAddress)
    {
        return DYDX_ADDRESS;
    }

    /// @dev An overridable way to retrieve the GST2 contract address.
    /// @return gst The GST contract.
    function _getGstAddress()
        internal
        view
        returns (address gst)
    {
        return GST_ADDRESS;
    }

    /// @dev An overridable way to retrieve the GST Collector address.
    /// @return collector The GST collector address.
    function _getGstCollectorAddress()
        internal
        view
        returns (address collector)
    {
        return GST_COLLECTOR_ADDRESS;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IDevUtils {

    /// @dev Fetches all order-relevant information needed to validate if the supplied order is fillable.
    /// @param order The order structure.
    /// @param signature Signature provided by maker that proves the order's authenticity.
    /// `0x01` can always be provided if the signature does not need to be validated.
    /// @return The orderInfo (hash, status, and `takerAssetAmount` already filled for the given order),
    /// fillableTakerAssetAmount (amount of the order's `takerAssetAmount` that is fillable given all on-chain state),
    /// and isValidSignature (validity of the provided signature).
    /// NOTE: If the `takerAssetData` encodes data for multiple assets, `fillableTakerAssetAmount` will represent a "scaled"
    /// amount, meaning it must be multiplied by all the individual asset amounts within the `takerAssetData` to get the final
    /// amount of each asset that can be filled.
    function getOrderRelevantState(LibOrder.Order calldata order, bytes calldata signature)
        external
        view
        returns (
            LibOrder.OrderInfo memory orderInfo,
            uint256 fillableTakerAssetAmount,
            bool isValidSignature
        );
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IERC20BridgeSampler {

    struct FakeBuyOptions {
        uint256 targetSlippageBps;
        uint256 maxIterations;
    }

    /// @dev Call multiple public functions on this contract in a single transaction.
    /// @param callDatas ABI-encoded call data for each function call.
    /// @return callResults ABI-encoded results data for each call.
    function batchCall(bytes[] calldata callDatas)
        external
        view
        returns (bytes[] memory callResults);

    /// @dev Queries the fillable taker asset amounts of native orders.
    /// @param orders Native orders to query.
    /// @param orderSignatures Signatures for each respective order in `orders`.
    /// @return orderFillableTakerAssetAmounts How much taker asset can be filled
    ///         by each order in `orders`.
    function getOrderFillableTakerAssetAmounts(
        LibOrder.Order[] calldata orders,
        bytes[] calldata orderSignatures
    )
        external
        view
        returns (uint256[] memory orderFillableTakerAssetAmounts);

    /// @dev Queries the fillable maker asset amounts of native orders.
    /// @param orders Native orders to query.
    /// @param orderSignatures Signatures for each respective order in `orders`.
    /// @return orderFillableMakerAssetAmounts How much maker asset can be filled
    ///         by each order in `orders`.
    function getOrderFillableMakerAssetAmounts(
        LibOrder.Order[] calldata orders,
        bytes[] calldata orderSignatures
    )
        external
        view
        returns (uint256[] memory orderFillableMakerAssetAmounts);

    /// @dev Sample sell quotes from Kyber.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample buy quotes from Kyber.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @param opts `FakeBuyOptions` specifying target slippage and max iterations.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts,
        FakeBuyOptions calldata opts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

    /// @dev Sample sell quotes from Eth2Dai/Oasis.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample sell quotes from Uniswap.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample buy quotes from Uniswap.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

    /// @dev Sample buy quotes from Eth2Dai/Oasis.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

    /// @dev Sample sell quotes from Curve.
    /// @param curveAddress Address of the Curve contract.
    /// @param fromTokenIdx Index of the taker token (what to sell).
    /// @param toTokenIdx Index of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample buy quotes from Curve.
    /// @param curveAddress Address of the Curve contract.
    /// @param fromTokenIdx Index of the taker token (what to sell).
    /// @param toTokenIdx Index of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

    /// @dev Sample sell quotes from an arbitrary on-chain liquidity provider.
    /// @param registryAddress Address of the liquidity provider registry contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample sell quotes from MultiBridge.
    /// @param multibridge Address of the MultiBridge contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param intermediateToken The address of the intermediate token to
    ///        use in an indirect route.
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromMultiBridge(
        address multibridge,
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample buy quotes from an arbitrary on-chain liquidity provider.
    /// @param registryAddress Address of the liquidity provider registry contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @param opts `FakeBuyOptions` specifying target slippage and max iterations.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts,
        FakeBuyOptions calldata opts

    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

    /// @dev Returns the address of a liquidity provider for the given market
    ///      (takerToken, makerToken), from a registry of liquidity providers.
    ///      Returns address(0) if no such provider exists in the registry.
    /// @param takerToken Taker asset managed by liquidity provider.
    /// @param makerToken Maker asset managed by liquidity provider.
    /// @return providerAddress Address of the liquidity provider.
    function getLiquidityProviderFromRegistry(
        address registryAddress,
        address takerToken,
        address makerToken
    )
        external
        view
        returns (address providerAddress);

    /// @dev Sample sell quotes from UniswapV2.
    /// @param path Token route.
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswapV2(
        address[] calldata path,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);

    /// @dev Sample buy quotes from UniswapV2.
    /// @param path Token route.
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromUniswapV2(
        address[] calldata path,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IEth2Dai {

    function getBuyAmount(
        address buyToken,
        address payToken,
        uint256 payAmount
    )
        external
        view
        returns (uint256 buyAmount);

    function getPayAmount(
        address payToken,
        address buyToken,
        uint256 buyAmount
    )
        external
        view
        returns (uint256 payAmount);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IKyberNetwork {

    function searchBestRate(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        bool usePermissionless
    )
        external
        view
        returns (address reserve, uint256 expectedRate);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IKyberNetworkProxy {

    function kyberNetworkContract() external view returns (address);

    function getExpectedRate(
        address fromToken,
        address toToken,
        uint256 fromAmount
    )
        external
        view
        returns (uint256 expectedRate, uint256 slippageRate);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IUniswapExchangeQuotes {

    function getEthToTokenInputPrice(
        uint256 ethSold
    )
        external
        view
        returns (uint256 tokensBought);

    function getEthToTokenOutputPrice(
        uint256 tokensBought
    )
        external
        view
        returns (uint256 ethSold);

    function getTokenToEthInputPrice(
        uint256 tokensSold
    )
        external
        view
        returns (uint256 ethBought);

    function getTokenToEthOutputPrice(
        uint256 ethBought
    )
        external
        view
        returns (uint256 tokensSold);
}

/*

  Copyright 2019 ZeroEx Intl.

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

// solhint-disable func-name-mixedcase
interface ICurve {

    /// @dev Sell `sellAmount` of `fromToken` token and receive `toToken` token.
    ///      This function exists on early versions of Curve (USDC/DAI)
    /// @param i The token index being sold.
    /// @param j The token index being bought.
    /// @param sellAmount The amount of token being bought.
    /// @param minBuyAmount The minimum buy amount of the token being bought.
    /// @param deadline The time in seconds when this operation should expire.
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount,
        uint256 minBuyAmount,
        uint256 deadline
    )
        external;

    /// @dev Sell `sellAmount` of `fromToken` token and receive `toToken` token.
    ///      This function exists on later versions of Curve (USDC/DAI/USDT)
    /// @param i The token index being sold.
    /// @param j The token index being bought.
    /// @param sellAmount The amount of token being bought.
    /// @param minBuyAmount The minimum buy amount of the token being bought.
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount,
        uint256 minBuyAmount
    )
        external;

    /// @dev Get the amount of `toToken` by selling `sellAmount` of `fromToken`
    /// @param i The token index being sold.
    /// @param j The token index being bought.
    /// @param sellAmount The amount of token being bought.
    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount
    )
        external
        returns (uint256 dy);

    /// @dev Get the amount of `fromToken` by buying `buyAmount` of `toToken`
    ///      This function exists on later versions of Curve (USDC/DAI/USDT)
    /// @param i The token index being sold.
    /// @param j The token index being bought.
    /// @param buyAmount The amount of token being bought.
    function get_dx_underlying(
        int128 i,
        int128 j,
        uint256 buyAmount
    )
        external
        returns (uint256 dx);

    /// @dev Get the underlying token address from the token index
    /// @param i The token index.
    function underlying_coins(
        int128 i
    )
        external
        returns (address tokenAddress);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface ILiquidityProvider {

    /// @dev Transfers `amount` of the ERC20 `tokenAddress` from `from` to `to`.
    /// @param tokenAddress The address of the ERC20 token to transfer.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    /// @param bridgeData Arbitrary asset data needed by the bridge contract.
    /// @return success The magic bytes `0xdc1600f3` if successful.
    function bridgeTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success);

    /// @dev Quotes the amount of `makerToken` that would be obtained by
    ///      selling `sellAmount` of `takerToken`.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param sellAmount Amount of `takerToken` to sell.
    /// @return makerTokenAmount Amount of `makerToken` that would be obtained.
    function getSellQuote(
        address takerToken,
        address makerToken,
        uint256 sellAmount
    )
        external
        view
        returns (uint256 makerTokenAmount);

    /// @dev Quotes the amount of `takerToken` that would need to be sold in
    ///      order to obtain `buyAmount` of `makerToken`.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param buyAmount Amount of `makerToken` to buy.
    /// @return takerTokenAmount Amount of `takerToken` that would need to be sold.
    function getBuyQuote(
        address takerToken,
        address makerToken,
        uint256 buyAmount
    )
        external
        view
        returns (uint256 takerTokenAmount);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface ILiquidityProviderRegistry {

    /// @dev Returns the address of a liquidity provider for the given market
    ///      (takerToken, makerToken), reverting if the pool does not exist.
    /// @param takerToken Taker asset managed by liquidity provider.
    /// @param makerToken Maker asset managed by liquidity provider.
    /// @return Address of the liquidity provider.
    function getLiquidityProviderForMarket(
        address takerToken,
        address makerToken
    )
        external
        view
        returns (address providerAddress);
}

/*

  Copyright 2019 ZeroEx Intl.

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

interface IUniswapV2Router01 {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

/*

  Copyright 2020 ZeroEx Intl.

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

interface IMultiBridge {

    /// @dev Transfers `amount` of the ERC20 `tokenAddress` from `from` to `to`.
    /// @param tokenAddress The address of the ERC20 token to transfer.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    /// @param bridgeData Arbitrary asset data needed by the bridge contract.
    /// @return success The magic bytes `0xdc1600f3` if successful.
    function bridgeTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success);

    /// @dev Quotes the amount of `makerToken` that would be obtained by
    ///      selling `sellAmount` of `takerToken`.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param intermediateToken The address of the intermediate token to
    ///        use in an indirect route.
    /// @param makerToken Address of the maker token (what to buy).
    /// @param sellAmount Amount of `takerToken` to sell.
    /// @return makerTokenAmount Amount of `makerToken` that would be obtained.
    function getSellQuote(
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256 sellAmount
    )
        external
        view
        returns (uint256 makerTokenAmount);
}

contract ERC20BridgeSampler is
    IERC20BridgeSampler,
    DeploymentConstants
{
    /// @dev Gas limit for DevUtils calls.
    uint256 constant internal DEV_UTILS_CALL_GAS = 500e3; // 500k
    /// @dev Gas limit for Kyber calls.
    uint256 constant internal KYBER_CALL_GAS = 1500e3; // 1.5m
    /// @dev Gas limit for Uniswap calls.
    uint256 constant internal UNISWAP_CALL_GAS = 150e3; // 150k
    /// @dev Gas limit for UniswapV2 calls.
    uint256 constant internal UNISWAPV2_CALL_GAS = 150e3; // 150k
    /// @dev Base gas limit for Eth2Dai calls.
    uint256 constant internal ETH2DAI_CALL_GAS = 1000e3; // 1m
    /// @dev Base gas limit for Curve calls. Some Curves have multiple tokens
    ///      So a reasonable ceil is 150k per token. Biggest Curve has 4 tokens.
    uint256 constant internal CURVE_CALL_GAS = 600e3; // 600k
    /// @dev Default gas limit for liquidity provider calls.
    uint256 constant internal DEFAULT_CALL_GAS = 400e3; // 400k
    /// @dev The Kyber Uniswap Reserve address
    address constant internal KYBER_UNIWAP_RESERVE = 0x31E085Afd48a1d6e51Cc193153d625e8f0514C7F;
    /// @dev The Kyber Eth2Dai Reserve address
    address constant internal KYBER_ETH2DAI_RESERVE = 0x1E158c0e93c30d24e918Ef83d1e0bE23595C3c0f;

    address private _devUtilsAddress;

    constructor(address devUtilsAddress) public {
        _devUtilsAddress = devUtilsAddress;
    }

    /// @dev Call multiple public functions on this contract in a single transaction.
    /// @param callDatas ABI-encoded call data for each function call.
    /// @return callResults ABI-encoded results data for each call.
    function batchCall(bytes[] calldata callDatas)
        external
        view
        returns (bytes[] memory callResults)
    {
        callResults = new bytes[](callDatas.length);
        for (uint256 i = 0; i != callDatas.length; ++i) {
            (bool didSucceed, bytes memory resultData) = address(this).staticcall(callDatas[i]);
            if (!didSucceed) {
                assembly { revert(add(resultData, 0x20), mload(resultData)) }
            }
            callResults[i] = resultData;
        }
    }

    /// @dev Queries the fillable taker asset amounts of native orders.
    ///      Effectively ignores orders that have empty signatures or
    ///      maker/taker asset amounts (returning 0).
    /// @param orders Native orders to query.
    /// @param orderSignatures Signatures for each respective order in `orders`.
    /// @return orderFillableTakerAssetAmounts How much taker asset can be filled
    ///         by each order in `orders`.
    function getOrderFillableTakerAssetAmounts(
        LibOrder.Order[] memory orders,
        bytes[] memory orderSignatures
    )
        public
        view
        returns (uint256[] memory orderFillableTakerAssetAmounts)
    {
        orderFillableTakerAssetAmounts = new uint256[](orders.length);
        address devUtilsAddress = _devUtilsAddress;
        for (uint256 i = 0; i != orders.length; i++) {
            // Ignore orders with no signature or empty maker/taker amounts.
            if (orderSignatures[i].length == 0 ||
                orders[i].makerAssetAmount == 0 ||
                orders[i].takerAssetAmount == 0) {
                orderFillableTakerAssetAmounts[i] = 0;
                continue;
            }
            // solhint-disable indent
            (bool didSucceed, bytes memory resultData) =
                devUtilsAddress
                    .staticcall
                    .gas(DEV_UTILS_CALL_GAS)
                    (abi.encodeWithSelector(
                       IDevUtils(devUtilsAddress).getOrderRelevantState.selector,
                       orders[i],
                       orderSignatures[i]
                    ));
            // solhint-enable indent
            if (!didSucceed) {
                orderFillableTakerAssetAmounts[i] = 0;
                continue;
            }
            (
                LibOrder.OrderInfo memory orderInfo,
                uint256 fillableTakerAssetAmount,
                bool isValidSignature
            ) = abi.decode(
                resultData,
                (LibOrder.OrderInfo, uint256, bool)
            );
            // The fillable amount is zero if the order is not fillable or if the
            // signature is invalid.
            if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE ||
                !isValidSignature) {
                orderFillableTakerAssetAmounts[i] = 0;
            } else {
                orderFillableTakerAssetAmounts[i] = fillableTakerAssetAmount;
            }
        }
    }

    /// @dev Queries the fillable taker asset amounts of native orders.
    ///      Effectively ignores orders that have empty signatures or
    /// @param orders Native orders to query.
    /// @param orderSignatures Signatures for each respective order in `orders`.
    /// @return orderFillableMakerAssetAmounts How much maker asset can be filled
    ///         by each order in `orders`.
    function getOrderFillableMakerAssetAmounts(
        LibOrder.Order[] memory orders,
        bytes[] memory orderSignatures
    )
        public
        view
        returns (uint256[] memory orderFillableMakerAssetAmounts)
    {
        orderFillableMakerAssetAmounts = getOrderFillableTakerAssetAmounts(
            orders,
            orderSignatures
        );
        // `orderFillableMakerAssetAmounts` now holds taker asset amounts, so
        // convert them to maker asset amounts.
        for (uint256 i = 0; i < orders.length; ++i) {
            if (orderFillableMakerAssetAmounts[i] != 0) {
                orderFillableMakerAssetAmounts[i] = LibMath.getPartialAmountCeil(
                    orderFillableMakerAssetAmounts[i],
                    orders[i].takerAssetAmount,
                    orders[i].makerAssetAmount
                );
            }
        }
    }

    /// @dev Sample sell quotes from Kyber.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        address wethAddress = _getWethAddress();
        uint256 value;
        address reserve;
        for (uint256 i = 0; i < numSamples; i++) {
            if (takerToken == wethAddress || makerToken == wethAddress) {
                // Direct ETH based trade
                (value, reserve) = _sampleSellFromKyberNetwork(takerToken, makerToken, takerTokenAmounts[i]);
                // If this fills on an on-chain reserve we remove it as that can introduce collisions
                if (reserve == KYBER_UNIWAP_RESERVE || reserve == KYBER_ETH2DAI_RESERVE) {
                    value = 0;
                }
            } else {
                // Hop to ETH
                (value, reserve) = _sampleSellFromKyberNetwork(takerToken, wethAddress, takerTokenAmounts[i]);
                if (value != 0) {
                    address otherReserve;
                    (value, otherReserve) = _sampleSellFromKyberNetwork(wethAddress, makerToken, value);
                    // If this fills on Eth2Dai it is ok as we queried a different market
                    // If this fills on Uniswap on both legs then this is a hard collision
                    if (reserve == KYBER_UNIWAP_RESERVE && reserve == otherReserve) {
                        value = 0;
                    }
                }
            }
            makerTokenAmounts[i] = value;
        }
    }

    /// @dev Sample buy quotes from Kyber.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @param opts `FakeBuyOptions` specifying target slippage and max iterations.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        return _sampleApproximateBuysFromSource(
            takerToken,
            makerToken,
            makerTokenAmounts,
            opts,
            this.sampleSellsFromKyberNetwork.selector,
            address(0) // PLP registry address
        );
    }

    /// @dev Sample sell quotes from Eth2Dai/Oasis.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getEth2DaiAddress().staticcall.gas(ETH2DAI_CALL_GAS)(
                    abi.encodeWithSelector(
                        IEth2Dai(0).getBuyAmount.selector,
                        makerToken,
                        takerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else{
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    /// @dev Sample sell quotes from Eth2Dai/Oasis using a hop to an intermediate token.
    ///      I.e WBTC/DAI via ETH or WBTC/ETH via DAI
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param intermediateToken Address of the token to hop to.
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromEth2DaiHop(
        address takerToken,
        address makerToken,
        address intermediateToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        if (makerToken == intermediateToken || takerToken == intermediateToken) {
            return makerTokenAmounts;
        }
        uint256[] memory intermediateAmounts = sampleSellsFromEth2Dai(takerToken, intermediateToken, takerTokenAmounts);
        makerTokenAmounts = sampleSellsFromEth2Dai(intermediateToken, makerToken, intermediateAmounts);
    }

    /// @dev Sample buy quotes from Eth2Dai/Oasis.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Maker token sell amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getEth2DaiAddress().staticcall.gas(ETH2DAI_CALL_GAS)(
                    abi.encodeWithSelector(
                        IEth2Dai(0).getPayAmount.selector,
                        takerToken,
                        makerToken,
                        makerTokenAmounts[i]
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                sellAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    /// @dev Sample sell quotes from Uniswap.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        IUniswapExchangeQuotes takerTokenExchange = takerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(takerToken);
        IUniswapExchangeQuotes makerTokenExchange = makerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            bool didSucceed = true;
            if (makerToken == _getWethAddress()) {
                (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthInputPrice.selector,
                    takerTokenAmounts[i]
                );
            } else if (takerToken == _getWethAddress()) {
                (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenInputPrice.selector,
                    takerTokenAmounts[i]
                );
            } else {
                uint256 ethBought;
                (ethBought, didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthInputPrice.selector,
                    takerTokenAmounts[i]
                );
                if (ethBought != 0) {
                    (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                        address(makerTokenExchange),
                        makerTokenExchange.getEthToTokenInputPrice.selector,
                        ethBought
                    );
                } else {
                    makerTokenAmounts[i] = 0;
                }
            }
            if (!didSucceed) {
                break;
            }
        }
    }

    /// @dev Sample buy quotes from Uniswap.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token sell amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        IUniswapExchangeQuotes takerTokenExchange = takerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(takerToken);
        IUniswapExchangeQuotes makerTokenExchange = makerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            bool didSucceed = true;
            if (makerToken == _getWethAddress()) {
                (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthOutputPrice.selector,
                    makerTokenAmounts[i]
                );
            } else if (takerToken == _getWethAddress()) {
                (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenOutputPrice.selector,
                    makerTokenAmounts[i]
                );
            } else {
                uint256 ethSold;
                (ethSold, didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenOutputPrice.selector,
                    makerTokenAmounts[i]
                );
                if (ethSold != 0) {
                    (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                        address(takerTokenExchange),
                        takerTokenExchange.getTokenToEthOutputPrice.selector,
                        ethSold
                    );
                } else {
                    takerTokenAmounts[i] = 0;
                }
            }
            if (!didSucceed) {
                break;
            }
        }
    }

    /// @dev Sample sell quotes from Curve.
    /// @param curveAddress Address of the Curve contract.
    /// @param fromTokenIdx Index of the taker token (what to sell).
    /// @param toTokenIdx Index of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                curveAddress.staticcall.gas(CURVE_CALL_GAS)(
                    abi.encodeWithSelector(
                        ICurve(0).get_dy_underlying.selector,
                        fromTokenIdx,
                        toTokenIdx,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    /// @dev Sample buy quotes from Curve.
    /// @param curveAddress Address of the Curve contract.
    /// @param fromTokenIdx Index of the taker token (what to sell).
    /// @param toTokenIdx Index of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                curveAddress.staticcall.gas(CURVE_CALL_GAS)(
                    abi.encodeWithSelector(
                        ICurve(0).get_dx_underlying.selector,
                        fromTokenIdx,
                        toTokenIdx,
                        makerTokenAmounts[i]
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                sellAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    /// @dev Sample sell quotes from an arbitrary on-chain liquidity provider.
    /// @param registryAddress Address of the liquidity provider registry contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        // Initialize array of maker token amounts.
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        // Query registry for provider address.
        address providerAddress = getLiquidityProviderFromRegistry(
            registryAddress,
            takerToken,
            makerToken
        );
        // If provider doesn't exist, return all zeros.
        if (providerAddress == address(0)) {
            return makerTokenAmounts;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                providerAddress.staticcall.gas(DEFAULT_CALL_GAS)(
                    abi.encodeWithSelector(
                        ILiquidityProvider(0).getSellQuote.selector,
                        takerToken,
                        makerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                // Exit early if the amount is too high for the liquidity provider to serve
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    /// @dev Sample sell quotes from MultiBridge.
    /// @param multibridge Address of the MultiBridge contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param intermediateToken The address of the intermediate token to
    ///        use in an indirect route.
    /// @param makerToken Address of the maker token (what to buy).
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromMultiBridge(
        address multibridge,
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        // Initialize array of maker token amounts.
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        // If no address provided, return all zeros.
        if (multibridge == address(0)) {
            return makerTokenAmounts;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                multibridge.staticcall.gas(DEFAULT_CALL_GAS)(
                    abi.encodeWithSelector(
                        IMultiBridge(0).getSellQuote.selector,
                        takerToken,
                        intermediateToken,
                        makerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                // Exit early if the amount is too high for the liquidity provider to serve
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    /// @dev Sample buy quotes from an arbitrary on-chain liquidity provider.
    /// @param registryAddress Address of the liquidity provider registry contract.
    /// @param takerToken Address of the taker token (what to sell).
    /// @param makerToken Address of the maker token (what to buy).
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @param opts `FakeBuyOptions` specifying target slippage and max iterations.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        return _sampleApproximateBuysFromSource(
            takerToken,
            makerToken,
            makerTokenAmounts,
            opts,
            this.sampleSellsFromLiquidityProviderRegistry.selector,
            registryAddress
        );
    }

    /// @dev Returns the address of a liquidity provider for the given market
    ///      (takerToken, makerToken), from a registry of liquidity providers.
    ///      Returns address(0) if no such provider exists in the registry.
    /// @param takerToken Taker asset managed by liquidity provider.
    /// @param makerToken Maker asset managed by liquidity provider.
    /// @return providerAddress Address of the liquidity provider.
    function getLiquidityProviderFromRegistry(
        address registryAddress,
        address takerToken,
        address makerToken
    )
        public
        view
        returns (address providerAddress)
    {
        bytes memory callData = abi.encodeWithSelector(
            ILiquidityProviderRegistry(0).getLiquidityProviderForMarket.selector,
            takerToken,
            makerToken
        );
        (bool didSucceed, bytes memory returnData) = registryAddress.staticcall(callData);
        if (didSucceed && returnData.length == 32) {
            return LibBytes.readAddress(returnData, 12);
        }
    }

    /// @dev Sample sell quotes from UniswapV2.
    /// @param path Token route.
    /// @param takerTokenAmounts Taker token sell amount for each sample.
    /// @return makerTokenAmounts Maker amounts bought at each taker token
    ///         amount.
    function sampleSellsFromUniswapV2(
        address[] memory path,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getUniswapV2Router01Address().staticcall.gas(UNISWAPV2_CALL_GAS)(
                    abi.encodeWithSelector(
                        IUniswapV2Router01(0).getAmountsOut.selector,
                        takerTokenAmounts[i],
                        path
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                // solhint-disable-next-line indent
                buyAmount = abi.decode(resultData, (uint256[]))[path.length - 1];
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    /// @dev Sample buy quotes from UniswapV2.
    /// @param path Token route.
    /// @param makerTokenAmounts Maker token buy amount for each sample.
    /// @return takerTokenAmounts Taker amounts sold at each maker token
    ///         amount.
    function sampleBuysFromUniswapV2(
        address[] memory path,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getUniswapV2Router01Address().staticcall.gas(UNISWAPV2_CALL_GAS)(
                    abi.encodeWithSelector(
                        IUniswapV2Router01(0).getAmountsIn.selector,
                        makerTokenAmounts[i],
                        path
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                // solhint-disable-next-line indent
                sellAmount = abi.decode(resultData, (uint256[]))[path.length - 1];
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    /// @dev Overridable way to get token decimals.
    /// @param tokenAddress Address of the token.
    /// @return decimals The decimal places for the token.
    function _getTokenDecimals(address tokenAddress)
        internal
        view
        returns (uint8 decimals)
    {
        return LibERC20Token.decimals(tokenAddress);
    }

    /// @dev Gracefully calls a Uniswap pricing function.
    /// @param uniswapExchangeAddress Address of an `IUniswapExchangeQuotes` exchange.
    /// @param functionSelector Selector of the target function.
    /// @param inputAmount Quantity parameter particular to the pricing function.
    /// @return outputAmount The returned amount from the function call. Will be
    ///         zero if the call fails or if `uniswapExchangeAddress` is zero.
    function _callUniswapExchangePriceFunction(
        address uniswapExchangeAddress,
        bytes4 functionSelector,
        uint256 inputAmount
    )
        private
        view
        returns (uint256 outputAmount, bool didSucceed)
    {
        if (uniswapExchangeAddress == address(0)) {
            return (outputAmount, didSucceed);
        }
        bytes memory resultData;
        (didSucceed, resultData) =
            uniswapExchangeAddress.staticcall.gas(UNISWAP_CALL_GAS)(
                abi.encodeWithSelector(
                    functionSelector,
                    inputAmount
                ));
        if (didSucceed) {
            outputAmount = abi.decode(resultData, (uint256));
        }
    }

    /// @dev Retrive an existing Uniswap exchange contract.
    ///      Throws if the exchange does not exist.
    /// @param tokenAddress Address of the token contract.
    /// @return exchange `IUniswapExchangeQuotes` for the token.
    function _getUniswapExchange(address tokenAddress)
        private
        view
        returns (IUniswapExchangeQuotes exchange)
    {
        exchange = IUniswapExchangeQuotes(
            address(IUniswapExchangeFactory(_getUniswapExchangeFactoryAddress())
            .getExchange(tokenAddress))
        );
    }

    /// @dev Assert that the tokens in a trade pair are valid.
    /// @param makerToken Address of the maker token.
    /// @param takerToken Address of the taker token.
    function _assertValidPair(address makerToken, address takerToken)
        private
        pure
    {
        require(makerToken != takerToken, "ERC20BridgeSampler/INVALID_TOKEN_PAIR");
    }

    function _sampleSellForApproximateBuy(
        address takerToken,
        address makerToken,
        uint256 takerTokenAmount,
        bytes4 selector,
        address plpRegistryAddress
    )
        private
        view
        returns (uint256 makerTokenAmount)
    {
        bytes memory callData;
        uint256[] memory tmpTakerAmounts = new uint256[](1);
        tmpTakerAmounts[0] = takerTokenAmount;
        if (selector == this.sampleSellsFromKyberNetwork.selector) {
            callData = abi.encodeWithSelector(
                this.sampleSellsFromKyberNetwork.selector,
                takerToken,
                makerToken,
                tmpTakerAmounts
            );
        } else {
            callData = abi.encodeWithSelector(
                this.sampleSellsFromLiquidityProviderRegistry.selector,
                plpRegistryAddress,
                takerToken,
                makerToken,
                tmpTakerAmounts
            );
        }
        (bool success, bytes memory resultData) = address(this).staticcall(callData);
        if (!success) {
            return 0;
        }
        // solhint-disable indent
        makerTokenAmount = abi.decode(resultData, (uint256[]))[0];
    }

    function _sampleApproximateBuysFromSource(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts,
        bytes4 selector,
        address plpRegistryAddress
    )
        private
        view
        returns (uint256[] memory takerTokenAmounts)
    {
        _assertValidPair(makerToken, takerToken);
        if (makerTokenAmounts.length == 0) {
            return takerTokenAmounts;
        }
        uint256 sellAmount;
        uint256 buyAmount;
        uint256 slippageFromTarget;
        takerTokenAmounts = new uint256[](makerTokenAmounts.length);
        sellAmount = _sampleSellForApproximateBuy(
            makerToken,
            takerToken,
            makerTokenAmounts[0],
            selector,
            plpRegistryAddress
        );

        if (sellAmount == 0) {
            return takerTokenAmounts;
        }

        buyAmount = _sampleSellForApproximateBuy(
            takerToken,
            makerToken,
            sellAmount,
            selector,
            plpRegistryAddress
        );
        if (buyAmount == 0) {
            return takerTokenAmounts;
        }

        for (uint256 i = 0; i < makerTokenAmounts.length; i++) {
            for (uint256 iter = 0; iter < opts.maxIterations; iter++) {
                // adjustedSellAmount = previousSellAmount * (target/actual) * JUMP_MULTIPLIER
                sellAmount = LibMath.getPartialAmountCeil(
                    makerTokenAmounts[i],
                    buyAmount,
                    sellAmount
                );
                sellAmount = LibMath.getPartialAmountCeil(
                    (10000 + opts.targetSlippageBps),
                    10000,
                    sellAmount
                );
                uint256 _buyAmount = _sampleSellForApproximateBuy(
                    takerToken,
                    makerToken,
                    sellAmount,
                    selector,
                    plpRegistryAddress
                );
                if (_buyAmount == 0) {
                    break;
                }
                // We re-use buyAmount next iteration, only assign if it is
                // non zero
                buyAmount = _buyAmount;
                // If we've reached our goal, exit early
                if (buyAmount >= makerTokenAmounts[i]) {
                    uint256 slippageFromTarget = (buyAmount - makerTokenAmounts[i]) * 10000 /
                                                makerTokenAmounts[i];
                    if (slippageFromTarget <= opts.targetSlippageBps) {
                        break;
                    }
                }
            }
            // We do our best to close in on the requested amount, but we can either over buy or under buy and exit
            // if we hit a max iteration limit
            // We scale the sell amount to get the approximate target
            takerTokenAmounts[i] = LibMath.getPartialAmountCeil(
                makerTokenAmounts[i],
                buyAmount,
                sellAmount
            );
        }
    }

    function _sampleSellFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256 takerTokenAmount
    )
        private
        view
        returns (uint256 makerTokenAmount, address reserve)
    {
        address _takerToken = takerToken == _getWethAddress() ? KYBER_ETH_ADDRESS : takerToken;
        address _makerToken = makerToken == _getWethAddress() ? KYBER_ETH_ADDRESS : makerToken;
        uint256 takerTokenDecimals = _getTokenDecimals(takerToken);
        uint256 makerTokenDecimals = _getTokenDecimals(makerToken);
        (bool didSucceed, bytes memory resultData) = _getKyberNetworkProxyAddress().staticcall.gas(DEFAULT_CALL_GAS)(
            abi.encodeWithSelector(
                IKyberNetworkProxy(0).kyberNetworkContract.selector
            ));
        if (!didSucceed) {
            return (0, address(0));
        }
        address kyberNetworkContract = abi.decode(resultData, (address));
        (didSucceed, resultData) =
            kyberNetworkContract.staticcall.gas(KYBER_CALL_GAS)(
                abi.encodeWithSelector(
                    IKyberNetwork(0).searchBestRate.selector,
                    _takerToken,
                    _makerToken,
                    takerTokenAmount,
                    false // usePermissionless
                ));
        uint256 rate = 0;
        address reserve;
        if (didSucceed) {
            (reserve, rate) = abi.decode(resultData, (address, uint256));
        } else {
            return (0, address(0));
        }
        makerTokenAmount =
            rate *
            takerTokenAmount *
            10 ** makerTokenDecimals /
            10 ** takerTokenDecimals /
            10 ** 18;

        return (makerTokenAmount, reserve);
    }
}
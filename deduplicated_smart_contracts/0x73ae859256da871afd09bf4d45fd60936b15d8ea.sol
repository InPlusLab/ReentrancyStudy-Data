/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

// File: ../../mosaic-contracts/contracts/lib/EIP20Interface.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 
// ----------------------------------------------------------------------------
// Common: Standard EIP20 Interface
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Based on the 'final' EIP20 token standard as specified at:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------

/**
 * @title EIP20Interface.
 *
 * @notice Provides EIP20 token interface.
 */
contract EIP20Interface {


    /* Events */

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


    /* Public functions */

    /**
     * @notice Public function to get the name of the token.
     *
     * @return tokenName_ Name of the token.
     */
    function name() public view returns (string memory tokenName_);

    /**
     * @notice Public function to get the symbol of the token.
     *
     * @return tokenSymbol_ Symbol of the token.
     */
    function symbol() public view returns (string memory tokenSymbol_);

    /**
     * @notice Public function to get the decimals of the token.
     *
     * @return tokenDecimals Decimals of the token.
     */
    function decimals() public view returns (uint8 tokenDecimals_);

    /**
     * @notice Public function to get the total supply of the tokens.
     *
     * @return totalTokenSupply_ Total token supply.
     */
    function totalSupply()
        public
        view
        returns (uint256 totalTokenSupply_);

    /**
     * @notice Get the balance of an account.
     *
     * @param _owner Address of the owner account.
     *
     * @return balance_ Account balance of the owner account.
     */
    function balanceOf(address _owner) public view returns (uint256 balance_);

    /**
     * @notice Public function to get the allowance.
     *
     * @param _owner Address of the owner account.
     * @param _spender Address of the spender account.
     *
     * @return allowance_ Remaining allowance for the spender to spend from
     *                    owner's account.
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256 allowance_);


    /**
     * @notice Public function to transfer the token.
     *
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to be transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);

    /**
     * @notice Public function transferFrom.
     *
     * @param _from Address from which tokens are transferred.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);

    /**
     * @notice Public function to approve an account for transfer.
     *
     * @param _spender Address authorized to spend from the function caller's
     *                 address.
     * @param _value Amount up to which spender is authorized to spend.
     *
     * @return bool `true` for a successful approval, `false` otherwise.
     */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success_);

}

// File: ../../mosaic-contracts/contracts/lib/SafeMath.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// Based on the SafeMath library by the OpenZeppelin team.
// Copyright (c) 2018 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------


/**
 * @title SafeMath library.
 *
 * @notice Based on the SafeMath library by the OpenZeppelin team.
 *
 * @dev Math operations with safety checks that revert on error.
 */
library SafeMath {

    /* Internal Functions */

    /**
     * @notice Multiplies two numbers, reverts on overflow.
     *
     * @param a Unsigned integer multiplicand.
     * @param b Unsigned integer multiplier.
     *
     * @return uint256 Product.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        /*
         * Gas optimization: this is cheaper than requiring 'a' not being zero,
         * but the benefit is lost if 'b' is also tested.
         * See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
         */
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(
            c / a == b,
            "Overflow when multiplying."
        );

        return c;
    }

    /**
     * @notice Integer division of two numbers truncating the quotient, reverts
     *         on division by zero.
     *
     * @param a Unsigned integer dividend.
     * @param b Unsigned integer divisor.
     *
     * @return uint256 Quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0.
        require(
            b > 0,
            "Cannot do attempted division by less than or equal to zero."
        );
        uint256 c = a / b;

        // There is no case in which the following doesn't hold:
        // assert(a == b * c + a % b);

        return c;
    }

    /**
     * @notice Subtracts two numbers, reverts on underflow (i.e. if subtrahend
     *         is greater than minuend).
     *
     * @param a Unsigned integer minuend.
     * @param b Unsigned integer subtrahend.
     *
     * @return uint256 Difference.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(
            b <= a,
            "Underflow when subtracting."
        );
        uint256 c = a - b;

        return c;
    }

    /**
     * @notice Adds two numbers, reverts on overflow.
     *
     * @param a Unsigned integer augend.
     * @param b Unsigned integer addend.
     *
     * @return uint256 Sum.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(
            c >= a,
            "Overflow when adding."
        );

        return c;
    }

    /**
     * @notice Divides two numbers and returns the remainder (unsigned integer
     *         modulo), reverts when dividing by zero.
     *
     * @param a Unsigned integer dividend.
     * @param b Unsigned integer divisor.
     *
     * @return uint256 Remainder.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(
            b != 0,
            "Cannot do attempted division by zero (in `mod()`)."
        );

        return a % b;
    }
}

// File: ../../mosaic-contracts/contracts/gateway/SimpleStake.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------



/**
 *  @title SimpleStake contract
 *
 *  @notice This holds staked EIP20 tokens for a gateway.
 */
contract SimpleStake {

    /* Usings */

    using SafeMath for uint256;


    /* Events */

    /* Emitted when amount is un-staked */
    event ReleasedStake(
        address indexed _gateway,
        address indexed _to,
        uint256 _amount
    );


    /* Storage */

    /** EIP20 token contract that can be staked. */
    EIP20Interface public token;

    /** EIP20 gateway address. */
    address public gateway;


    /* Modifiers */

    /** Checks that only gateway can call a particular function. */
    modifier onlyGateway() {
        require(
            msg.sender == gateway,
            "Only gateway can call the function."
        );
        _;
    }


    /* Constructor */

    /**
     *  @notice Contract constructor.
     *
     *  @param _token EIP20 token that will be staked.
     *  @param _gateway EIP20Gateway contract that governs staking.
     */
    constructor(
        EIP20Interface _token,
        address _gateway
    )
        public
    {
        require(
            address(_token) != address(0),
            "Token contract address must not be zero."
        );
        require(
            _gateway != address(0),
            "Gateway contract address must not be zero."
        );

        token = _token;
        gateway = _gateway;
    }


    /* External functions */

    /**
     *  @notice This allows gateway to release staked amount to provided address.
     *          Only gateway contract can call this method which defines set of rules
     *          on how the stake can be released and to who. Beneficiary address
     *          can be zero address in order to burn tokens.
     *
     *  @param _to Beneficiary of the amount of the stake.
     *  @param _amount Amount of stake to release to beneficiary.
     *
     *  @return success_ `true` if stake is released to beneficiary, `false` otherwise.
     */
    function releaseTo(
        address _to,
        uint256 _amount
    )
        external
        onlyGateway
        returns (bool success_)
    {
        require(
            token.transfer(_to, _amount) == true,
            "Token transfer must success."
        );

        emit ReleasedStake(msg.sender, _to, _amount);

        success_ = true;
    }

    /**
     *  @notice This function returns total staked amount.
     *
     *  @dev Total stake is the balance of the staking contract
     *       accidental transfers directly to SimpleStake bypassing
     *       the gateway will not mint new utility tokens,
     *       but will add to the total stake,
     *       (accidental) donations can not be prevented.
     *
     *  @return stakedAmount_ Total staked amount.
     */
    function getTotalStake()
        external
        view
        returns (uint256 stakedAmount_)
    {
        stakedAmount_ = token.balanceOf(address(this));
    }
}

// File: ../../mosaic-contracts/contracts/lib/BytesLib.sol

pragma solidity ^0.5.0;

library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure returns (bytes memory bytes_)
    {
        /* solium-disable-next-line */
        assembly {
            // Get a location of some free memory and store it in bytes_ as
            // Solidity does for memory variables.
            bytes_ := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for bytes_.
            let length := mload(_preBytes)
            mstore(bytes_, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(bytes_, 0x20)
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
                // Write the _preBytes data into the bytes_ memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of bytes_
            // and store it as the new length in the first 32 bytes of the
            // bytes_ memory.
            length := mload(_postBytes)
            mstore(bytes_, add(length, mload(bytes_)))

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
            // to 32 bytes: add 31 bytes to the end of bytes_ to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }
    }

    // Pad a bytes array to 32 bytes
    function leftPad(
        bytes memory _bytes
    )
        internal
        pure
        returns (bytes memory padded_)
    {
        bytes memory padding = new bytes(32 - _bytes.length);
        padded_ = concat(padding, _bytes);
    }

    /**
     * @notice Convert bytes32 to bytes
     *
     * @param _inBytes32 bytes32 value
     *
     * @return bytes value
     */
    function bytes32ToBytes(bytes32 _inBytes32)
        internal
        pure
        returns (bytes memory bytes_)
    {
        bytes_ = new bytes(32);

        /* solium-disable-next-line */
        assembly {
            mstore(add(32, bytes_), _inBytes32)
        }
    }

}

// File: ../../mosaic-contracts/contracts/lib/RLP.sol

pragma solidity ^0.5.0;

/**
* @title RLPReader
*
* RLPReader is used to read and parse RLP encoded data in memory.
*
* @author Andreas Olofsson (androlo1980@gmail.com)
*/
library RLP {

    /** Constants */
    uint constant DATA_SHORT_START = 0x80;
    uint constant DATA_LONG_START = 0xB8;
    uint constant LIST_SHORT_START = 0xC0;
    uint constant LIST_LONG_START = 0xF8;

    uint constant DATA_LONG_OFFSET = 0xB7;
    uint constant LIST_LONG_OFFSET = 0xF7;

    /** Storage */
    struct RLPItem {
        uint _unsafe_memPtr;    // Pointer to the RLP-encoded bytes.
        uint _unsafe_length;    // Number of bytes. This is the full length of the string.
    }

    struct Iterator {
        RLPItem _unsafe_item;   // Item that's being iterated over.
        uint _unsafe_nextPtr;   // Position of the next item in the list.
    }

    /* Internal Functions */

    /** Iterator */

    function next(
        Iterator memory self
    )
        internal
        pure
        returns (RLPItem memory subItem_)
    {
        require(hasNext(self));
        uint ptr = self._unsafe_nextPtr;
        uint itemLength = _itemLength(ptr);
        subItem_._unsafe_memPtr = ptr;
        subItem_._unsafe_length = itemLength;
        self._unsafe_nextPtr = ptr + itemLength;
    }

    function next(
        Iterator memory self,
        bool strict
    )
        internal
        pure
        returns (RLPItem memory subItem_)
    {
        subItem_ = next(self);
        require(!(strict && !_validate(subItem_)));
    }

    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self._unsafe_item;
        return self._unsafe_nextPtr < item._unsafe_memPtr + item._unsafe_length;
    }

    /** RLPItem */

    /**
    *  @dev Creates an RLPItem from an array of RLP encoded bytes.
    *
    *  @param self The RLP encoded bytes.
    *
    *  @return An RLPItem.
    */
    function toRLPItem(
        bytes memory self
    )
        internal
        pure
        returns (RLPItem memory)
    {
        uint len = self.length;
        if (len == 0) {
            return RLPItem(0, 0);
        }
        uint memPtr;

        /* solium-disable-next-line */
        assembly {
            memPtr := add(self, 0x20)
        }

        return RLPItem(memPtr, len);
    }

    /**
    *  @dev Creates an RLPItem from an array of RLP encoded bytes.
    *
    *  @param self The RLP encoded bytes.
    *  @param strict Will throw if the data is not RLP encoded.
    *
    *  @return An RLPItem.
    */
    function toRLPItem(
        bytes memory self,
        bool strict
    )
        internal
        pure
        returns (RLPItem memory)
    {
        RLPItem memory item = toRLPItem(self);
        if(strict) {
            uint len = self.length;
            require(_payloadOffset(item) <= len);
            require(_itemLength(item._unsafe_memPtr) == len);
            require(_validate(item));
        }
        return item;
    }

    /**
    *  @dev Check if the RLP item is null.
    *
    *  @param self The RLP item.
    *
    *  @return 'true' if the item is null.
    */
    function isNull(RLPItem memory self) internal pure returns (bool ret) {
        return self._unsafe_length == 0;
    }

    /**
    *  @dev Check if the RLP item is a list.
    *
    *  @param self The RLP item.
    *
    *  @return 'true' if the item is a list.
    */
    function isList(RLPItem memory self) internal pure returns (bool ret) {
        if (self._unsafe_length == 0) {
            return false;
        }
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            ret := iszero(lt(byte(0, mload(memPtr)), 0xC0))
        }
    }

    /**
    *  @dev Check if the RLP item is data.
    *
    *  @param self The RLP item.
    *
    *  @return 'true' if the item is data.
    */
    function isData(RLPItem memory self) internal pure returns (bool ret) {
        if (self._unsafe_length == 0) {
            return false;
        }
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            ret := lt(byte(0, mload(memPtr)), 0xC0)
        }
    }

    /**
    *  @dev Check if the RLP item is empty (string or list).
    *
    *  @param self The RLP item.
    *
    *  @return 'true' if the item is null.
    */
    function isEmpty(RLPItem memory self) internal pure returns (bool ret) {
        if(isNull(self)) {
            return false;
        }
        uint b0;
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        return (b0 == DATA_SHORT_START || b0 == LIST_SHORT_START);
    }

    /**
    *  @dev Get the number of items in an RLP encoded list.
    *
    *  @param self The RLP item.
    *
    *  @return The number of items.
    */
    function items(RLPItem memory self) internal pure returns (uint) {
        if (!isList(self)) {
            return 0;
        }
        uint b0;
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        uint pos = memPtr + _payloadOffset(self);
        uint last = memPtr + self._unsafe_length - 1;
        uint itms;
        while(pos <= last) {
            pos += _itemLength(pos);
            itms++;
        }
        return itms;
    }

    /**
    *  @dev Create an iterator.
    *
    *  @param self The RLP item.
    *
    *  @return An 'Iterator' over the item.
    */
    function iterator(
        RLPItem memory self
    )
        internal
        pure
        returns (Iterator memory it_)
    {
        require (isList(self));
        uint ptr = self._unsafe_memPtr + _payloadOffset(self);
        it_._unsafe_item = self;
        it_._unsafe_nextPtr = ptr;
    }

    /**
    *  @dev Return the RLP encoded bytes.
    *
    *  @param self The RLPItem.
    *
    *  @return The bytes.
    */
    function toBytes(
        RLPItem memory self
    )
        internal
        pure
        returns (bytes memory bts_)
    {
        uint len = self._unsafe_length;
        if (len == 0) {
            return bts_;
        }
        bts_ = new bytes(len);
        _copyToBytes(self._unsafe_memPtr, bts_, len);
    }

    /**
    *  @dev Decode an RLPItem into bytes. This will not work if the RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toData(
        RLPItem memory self
    )
        internal
        pure
        returns (bytes memory bts_)
    {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        bts_ = new bytes(len);
        _copyToBytes(rStartPos, bts_, len);
    }

    /**
    *  @dev Get the list of sub-items from an RLP encoded list.
    *       Warning: This is inefficient, as it requires that the list is read twice.
    *
    *  @param self The RLP item.
    *
    *  @return Array of RLPItems.
    */
    function toList(
        RLPItem memory self
    )
        internal
        pure
        returns (RLPItem[] memory list_)
    {
        require(isList(self));
        uint numItems = items(self);
        list_ = new RLPItem[](numItems);
        Iterator memory it = iterator(self);
        uint idx = 0;
        while(hasNext(it)) {
            list_[idx] = next(it);
            idx++;
        }
    }

    /**
    *  @dev Decode an RLPItem into an ascii string. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toAscii(
        RLPItem memory self
    )
        internal
        pure
        returns (string memory str_)
    {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        bytes memory bts = new bytes(len);
        _copyToBytes(rStartPos, bts, len);
        str_ = string(bts);
    }

    /**
    *  @dev Decode an RLPItem into a uint. This will not work if the
    *  RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toUint(RLPItem memory self) internal pure returns (uint data_) {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        if (len > 32 || len == 0) {
            revert();
        }

        /* solium-disable-next-line */
        assembly {
            data_ := div(mload(rStartPos), exp(256, sub(32, len)))
        }
    }

    /**
    *  @dev Decode an RLPItem into a boolean. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toBool(RLPItem memory self) internal pure returns (bool data) {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        require(len == 1);
        uint temp;

        /* solium-disable-next-line */
        assembly {
            temp := byte(0, mload(rStartPos))
        }
        require (temp <= 1);

        return temp == 1 ? true : false;
    }

    /**
    *  @dev Decode an RLPItem into a byte. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toByte(RLPItem memory self) internal pure returns (byte data) {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        require(len == 1);
        uint temp;

        /* solium-disable-next-line */
        assembly {
            temp := byte(0, mload(rStartPos))
        }

        return byte(uint8(temp));
    }

    /**
    *  @dev Decode an RLPItem into an int. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toInt(RLPItem memory self) internal pure returns (int data) {
        return int(toUint(self));
    }

    /**
    *  @dev Decode an RLPItem into a bytes32. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toBytes32(
        RLPItem memory self
    )
        internal
        pure
        returns (bytes32 data)
    {
        return bytes32(toUint(self));
    }

    /**
    *  @dev Decode an RLPItem into an address. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return The decoded string.
    */
    function toAddress(
        RLPItem memory self
    )
        internal
        pure
        returns (address data)
    {
        require(isData(self));
        uint rStartPos;
        uint len;
        (rStartPos, len) = _decode(self);
        require (len == 20);

        /* solium-disable-next-line */
        assembly {
            data := div(mload(rStartPos), exp(256, 12))
        }
    }

    /**
    *  @dev Decode an RLPItem into an address. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return Get the payload offset.
    */
    function _payloadOffset(RLPItem memory self) private pure returns (uint) {
        if(self._unsafe_length == 0)
            return 0;
        uint b0;
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        if(b0 < DATA_SHORT_START)
            return 0;
        if(b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START))
            return 1;
        if(b0 < LIST_SHORT_START)
            return b0 - DATA_LONG_OFFSET + 1;
        return b0 - LIST_LONG_OFFSET + 1;
    }

    /**
    *  @dev Decode an RLPItem into an address. This will not work if the
    *       RLPItem is a list.
    *
    *  @param memPtr Memory pointer.
    *
    *  @return Get the full length of an RLP item.
    */
    function _itemLength(uint memPtr) private pure returns (uint len) {
        uint b0;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(memPtr))
        }
        if (b0 < DATA_SHORT_START) {
            len = 1;
        } else if (b0 < DATA_LONG_START) {
            len = b0 - DATA_SHORT_START + 1;
        } else if (b0 < LIST_SHORT_START) {
            /* solium-disable-next-line */
            assembly {
                let bLen := sub(b0, 0xB7) // bytes length (DATA_LONG_OFFSET)
                let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
                len := add(1, add(bLen, dLen)) // total length
            }
        } else if (b0 < LIST_LONG_START) {
            len = b0 - LIST_SHORT_START + 1;
        } else {
            /* solium-disable-next-line */
            assembly {
                let bLen := sub(b0, 0xF7) // bytes length (LIST_LONG_OFFSET)
                let dLen := div(mload(add(memPtr, 1)), exp(256, sub(32, bLen))) // data length
                len := add(1, add(bLen, dLen)) // total length
            }
        }
    }

    /**
    *  @dev Decode an RLPItem into an address. This will not work if the
    *       RLPItem is a list.
    *
    *  @param self The RLPItem.
    *
    *  @return Get the full length of an RLP item.
    */
    function _decode(
        RLPItem memory self
    )
        private
        pure
        returns (uint memPtr_, uint len_)
    {
        require(isData(self));
        uint b0;
        uint start = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(start))
        }
        if (b0 < DATA_SHORT_START) {
            memPtr_ = start;
            len_ = 1;

            return (memPtr_, len_);
        }
        if (b0 < DATA_LONG_START) {
            len_ = self._unsafe_length - 1;
            memPtr_ = start + 1;
        } else {
            uint bLen;

            /* solium-disable-next-line */
            assembly {
                bLen := sub(b0, 0xB7) // DATA_LONG_OFFSET
            }
            len_ = self._unsafe_length - 1 - bLen;
            memPtr_ = start + bLen + 1;
        }
    }

    /**
    *  @dev Assumes that enough memory has been allocated to store in target.
    *       Gets the full length of an RLP item.
    *
    *  @param btsPtr Bytes pointer.
    *  @param tgt Last item to be allocated.
    *  @param btsLen Bytes length.
    */
    function _copyToBytes(
        uint btsPtr,
        bytes memory tgt,
        uint btsLen
    )
        private
        pure
    {
        // Exploiting the fact that 'tgt' was the last thing to be allocated,
        // we can write entire words, and just overwrite any excess.
        /* solium-disable-next-line */
        assembly {
                let i := 0 // Start at arr + 0x20
                let stopOffset := add(btsLen, 31)
                let rOffset := btsPtr
                let wOffset := add(tgt, 32)
                for {} lt(i, stopOffset) { i := add(i, 32) }
                {
                    mstore(add(wOffset, i), mload(add(rOffset, i)))
                }
        }
    }

    /**
    *  @dev Check that an RLP item is valid.
    *
    *  @param self The RLPItem.
    */
    function _validate(RLPItem memory self) private pure returns (bool ret) {
        // Check that RLP is well-formed.
        uint b0;
        uint b1;
        uint memPtr = self._unsafe_memPtr;

        /* solium-disable-next-line */
        assembly {
            b0 := byte(0, mload(memPtr))
            b1 := byte(1, mload(memPtr))
        }
        if(b0 == DATA_SHORT_START + 1 && b1 < DATA_SHORT_START)
            return false;
        return true;
    }
}

// File: ../../mosaic-contracts/contracts/lib/MerklePatriciaProof.sol

pragma solidity ^0.5.0;
/**
 * @title MerklePatriciaVerifier
 * @author Sam Mayo (sammayo888@gmail.com)
 *
 * @dev Library for verifing merkle patricia proofs.
 */


library MerklePatriciaProof {
    /**
     * @dev Verifies a merkle patricia proof.
     * @param value The terminating value in the trie.
     * @param encodedPath The path in the trie leading to value.
     * @param rlpParentNodes The rlp encoded stack of nodes.
     * @param root The root hash of the trie.
     * @return The boolean validity of the proof.
     */
    function verify(
        bytes32 value,
        bytes calldata encodedPath,
        bytes calldata rlpParentNodes,
        bytes32 root
    )
        external
        pure
        returns (bool)
    {
        RLP.RLPItem memory item = RLP.toRLPItem(rlpParentNodes);
        RLP.RLPItem[] memory parentNodes = RLP.toList(item);

        bytes memory currentNode;
        RLP.RLPItem[] memory currentNodeList;

        bytes32 nodeKey = root;
        uint pathPtr = 0;

        bytes memory path = _getNibbleArray2(encodedPath);
        if(path.length == 0) {return false;}

        for (uint i=0; i<parentNodes.length; i++) {
            if(pathPtr > path.length) {return false;}

            currentNode = RLP.toBytes(parentNodes[i]);
            if(nodeKey != keccak256(abi.encodePacked(currentNode))) {return false;}
            currentNodeList = RLP.toList(parentNodes[i]);

            if(currentNodeList.length == 17) {
                if(pathPtr == path.length) {
                    if(keccak256(abi.encodePacked(RLP.toBytes(currentNodeList[16]))) == value) {
                        return true;
                    } else {
                        return false;
                    }
                }

                uint8 nextPathNibble = uint8(path[pathPtr]);
                if(nextPathNibble > 16) {return false;}
                nodeKey = RLP.toBytes32(currentNodeList[nextPathNibble]);
                pathPtr += 1;
            } else if(currentNodeList.length == 2) {

                // Count of matching node key nibbles in path starting from pathPtr.
                uint traverseLength = _nibblesToTraverse(RLP.toData(currentNodeList[0]), path, pathPtr);

                if(pathPtr + traverseLength == path.length) { //leaf node
                    if(keccak256(abi.encodePacked(RLP.toData(currentNodeList[1]))) == value) {
                        return true;
                    } else {
                        return false;
                    }
                } else if (traverseLength == 0) { // error: couldn't traverse path
                    return false;
                } else { // extension node
                    pathPtr += traverseLength;
                    nodeKey = RLP.toBytes32(currentNodeList[1]);
                }

            } else {
                return false;
            }
        }
    }

    function verifyDebug(
        bytes32 value,
        bytes memory not_encodedPath,
        bytes memory rlpParentNodes,
        bytes32 root
    )
        public
        pure
        returns (bool res_, uint loc_, bytes memory path_debug_)
    {
        RLP.RLPItem memory item = RLP.toRLPItem(rlpParentNodes);
        RLP.RLPItem[] memory parentNodes = RLP.toList(item);

        bytes memory currentNode;
        RLP.RLPItem[] memory currentNodeList;

        bytes32 nodeKey = root;
        uint pathPtr = 0;

        bytes memory path = _getNibbleArray2(not_encodedPath);
        path_debug_ = path;
        if(path.length == 0) {
            loc_ = 0;
            res_ = false;
            return (res_, loc_, path_debug_);
        }

        for (uint i=0; i<parentNodes.length; i++) {
            if(pathPtr > path.length) {
                loc_ = 1;
                res_ = false;
                return (res_, loc_, path_debug_);
            }

            currentNode = RLP.toBytes(parentNodes[i]);
            if(nodeKey != keccak256(abi.encodePacked(currentNode))) {
                res_ = false;
                loc_ = 100 + i;
                return (res_, loc_, path_debug_);
            }
            currentNodeList = RLP.toList(parentNodes[i]);

            loc_ = currentNodeList.length;

            if(currentNodeList.length == 17) {
                if(pathPtr == path.length) {
                    if(keccak256(abi.encodePacked(RLP.toBytes(currentNodeList[16]))) == value) {
                        res_ = true;
                        return (res_, loc_, path_debug_);
                    } else {
                        loc_ = 3;
                        return (res_, loc_, path_debug_);
                    }
                }

                uint8 nextPathNibble = uint8(path[pathPtr]);
                if(nextPathNibble > 16) {
                    loc_ = 4;
                    return (res_, loc_, path_debug_);
                }
                nodeKey = RLP.toBytes32(currentNodeList[nextPathNibble]);
                pathPtr += 1;
            } else if(currentNodeList.length == 2) {
                pathPtr += _nibblesToTraverse(RLP.toData(currentNodeList[0]), path, pathPtr);

                if(pathPtr == path.length) {//leaf node
                    if(keccak256(abi.encodePacked(RLP.toData(currentNodeList[1]))) == value) {
                        res_ = true;
                        return (res_, loc_, path_debug_);
                    } else {
                        loc_ = 5;
                        return (res_, loc_, path_debug_);
                    }
                }
                //extension node
                if(_nibblesToTraverse(RLP.toData(currentNodeList[0]), path, pathPtr) == 0) {
                    loc_ = 6;
                    res_ = (keccak256(abi.encodePacked()) == value);
                    return (res_, loc_, path_debug_);
                }

                nodeKey = RLP.toBytes32(currentNodeList[1]);
            } else {
                loc_ = 7;
                return (res_, loc_, path_debug_);
            }
        }

        loc_ = 8;
    }

    function _nibblesToTraverse(
        bytes memory encodedPartialPath,
        bytes memory path,
        uint pathPtr
    )
        private
        pure
        returns (uint len_)
    {
        // encodedPartialPath has elements that are each two hex characters (1 byte), but partialPath
        // and slicedPath have elements that are each one hex character (1 nibble)
        bytes memory partialPath = _getNibbleArray(encodedPartialPath);
        bytes memory slicedPath = new bytes(partialPath.length);

        // pathPtr counts nibbles in path
        // partialPath.length is a number of nibbles
        for(uint i=pathPtr; i<pathPtr+partialPath.length; i++) {
            byte pathNibble = path[i];
            slicedPath[i-pathPtr] = pathNibble;
        }

        if(keccak256(abi.encodePacked(partialPath)) == keccak256(abi.encodePacked(slicedPath))) {
            len_ = partialPath.length;
        } else {
            len_ = 0;
        }
    }

    // bytes b must be hp encoded
    function _getNibbleArray(
        bytes memory b
    )
        private
        pure
        returns (bytes memory nibbles_)
    {
        if(b.length>0) {
            uint8 offset;
            uint8 hpNibble = uint8(_getNthNibbleOfBytes(0,b));
            if(hpNibble == 1 || hpNibble == 3) {
                nibbles_ = new bytes(b.length*2-1);
                byte oddNibble = _getNthNibbleOfBytes(1,b);
                nibbles_[0] = oddNibble;
                offset = 1;
            } else {
                nibbles_ = new bytes(b.length*2-2);
                offset = 0;
            }

            for(uint i=offset; i<nibbles_.length; i++) {
                nibbles_[i] = _getNthNibbleOfBytes(i-offset+2,b);
            }
        }
    }

    // normal byte array, no encoding used
    function _getNibbleArray2(
        bytes memory b
    )
        private
        pure
        returns (bytes memory nibbles_)
    {
        nibbles_ = new bytes(b.length*2);
        for (uint i = 0; i < nibbles_.length; i++) {
            nibbles_[i] = _getNthNibbleOfBytes(i, b);
        }
    }

    function _getNthNibbleOfBytes(
        uint n,
        bytes memory str
    )
        private
        pure returns (byte)
    {
        return byte(n%2==0 ? uint8(str[n/2])/0x10 : uint8(str[n/2])%0x10);
    }
}

// File: ../../mosaic-contracts/contracts/lib/GatewayLib.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//



library GatewayLib {

    /* Constants */

    bytes32 constant public STAKE_INTENT_TYPEHASH = keccak256(
        abi.encode(
            "StakeIntent(uint256 amount,address beneficiary,address gateway)"
        )
    );

    bytes32 constant public REDEEM_INTENT_TYPEHASH = keccak256(
        abi.encode(
            "RedeemIntent(uint256 amount,address beneficiary,address gateway)"
        )
    );


    /* External Functions */

    /**
     * @notice Merkle proof verification of account.
     *
     * @param _rlpAccount RLP encoded data of account.
     * @param _rlpParentNodes Path from root node to leaf in merkle tree.
     * @param _encodedPath Encoded path to search account node in merkle tree.
     * @param _stateRoot State root for given block height.
     *
     * @return bytes32 Storage path of the variable.
     */
    function proveAccount(
        bytes calldata _rlpAccount,
        bytes calldata _rlpParentNodes,
        bytes calldata _encodedPath,
        bytes32 _stateRoot
    )
        external
        pure
        returns (bytes32 storageRoot_)
    {
        // Decode RLP encoded account value.
        RLP.RLPItem memory accountItem = RLP.toRLPItem(_rlpAccount);

        // Convert to list.
        RLP.RLPItem[] memory accountArray = RLP.toList(accountItem);

        // Array 3rd position is storage root.
        storageRoot_ = RLP.toBytes32(accountArray[2]);

        // Hash the rlpValue value.
        bytes32 hashedAccount = keccak256(
            abi.encodePacked(_rlpAccount)
        );

        /*
         * Verify the remote OpenST contract against the committed state
         * root with the state trie Merkle proof.
         */
        require(
            MerklePatriciaProof.verify(
                hashedAccount,
                _encodedPath,
                _rlpParentNodes,
                _stateRoot
            ),
            "Account proof is not verified."
        );

    }

    /**
     * @notice Creates the hash of a stake intent struct based on its fields.
     *
     * @param _amount Stake amount.
     * @param _beneficiary The beneficiary address on the auxiliary chain.
     * @param _gateway The address of the  gateway where the staking took place.
     *
     * @return stakeIntentHash_ The hash that represents this stake intent.
     */
    function hashStakeIntent(
        uint256 _amount,
        address _beneficiary,
        address _gateway
    )
        external
        pure
        returns (bytes32 stakeIntentHash_)
    {
        stakeIntentHash_ = keccak256(
            abi.encode(
                STAKE_INTENT_TYPEHASH,
                _amount,
                _beneficiary,
                _gateway
            )
        );
    }

    /**
     * @notice Creates the hash of a redeem intent struct based on its fields.
     *
     * @param _amount Redeem amount.
     * @param _beneficiary The beneficiary address on the origin chain.
     * @param _gateway The address of the  gateway where the redeeming happened.
     *
     * @return redeemIntentHash_ The hash that represents this stake intent.
     */
    function hashRedeemIntent(
        uint256 _amount,
        address _beneficiary,
        address _gateway
    )
        external
        pure
        returns (bytes32 redeemIntentHash_)
    {
        redeemIntentHash_ = keccak256(
            abi.encode(
                REDEEM_INTENT_TYPEHASH,
                _amount,
                _beneficiary,
                _gateway
            )
        );
    }
}

// File: ../../mosaic-contracts/contracts/lib/MessageBus.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------




library MessageBus {

    /* Usings */

    using SafeMath for uint256;


    /* Enums */

    /** Status of the message state machine. */
    enum MessageStatus {
        Undeclared,
        Declared,
        Progressed,
        DeclaredRevocation,
        Revoked
    }

    /** Status of the message state machine. */
    enum MessageBoxType {
        Outbox,
        Inbox
    }


    /* Structs */

    /** MessageBox stores the inbox and outbox mapping. */
    struct MessageBox {

        /** Maps message hash to the MessageStatus. */
        mapping(bytes32 => MessageStatus) outbox;

        /** Maps message hash to the MessageStatus. */
        mapping(bytes32 => MessageStatus) inbox;
    }

    /** A Message is sent between gateways. */
    struct Message {

        /** Intent hash of specific request type. */
        bytes32 intentHash;

        /** Nonce of the sender. */
        uint256 nonce;

        /** Gas price that sender will pay for reward. */
        uint256 gasPrice;

        /** Gas limit that sender will pay. */
        uint256 gasLimit;

        /** Address of the message sender. */
        address sender;

        /** Hash lock provided by the facilitator. */
        bytes32 hashLock;

        /**
         * The amount of the gas consumed, this is used for reward
         * calculation.
         */
        uint256 gasConsumed;
    }


    /* Constants */

    bytes32 public constant MESSAGE_TYPEHASH = keccak256(
        abi.encode(
            "Message(bytes32 intentHash,uint256 nonce,uint256 gasPrice,uint256 gasLimit,address sender,bytes32 hashLock)"
        )
    );

    /**
     * Position of outbox in struct MessageBox.
     * This is used to generate storage merkel proof.
     */
    uint8 public constant OUTBOX_OFFSET = 0;

    /**
     * Position of inbox in struct MessageBox.
     * This is used to generate storage merkel proof.
     */
    uint8 public constant INBOX_OFFSET = 1;


    /* External Functions */

    /**
     * @notice Declare a new message. This will update the outbox status to
     *         `Declared` for the given message hash.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     *
     * @return messageHash_ Message hash
     */
    function declareMessage(
        MessageBox storage _messageBox,
        Message storage _message
    )
        external
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(_message);
        require(
            _messageBox.outbox[messageHash_] == MessageStatus.Undeclared,
            "Message on source must be Undeclared."
        );

        // Update the outbox message status to `Declared`.
        _messageBox.outbox[messageHash_] = MessageStatus.Declared;
    }

    /**
     * @notice Confirm a new message that is declared in outbox on the source
     *         chain. Merkle proof will be performed to verify the declared
     *         status in source chains outbox. This will update the inbox
     *         status to `Declared` for the given message hash.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox outbox.
     * @param _messageBoxOffset position of the messageBox.
     * @param _storageRoot Storage root for proof.
     *
     * @return messageHash_ Message hash.
     */
    function confirmMessage(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes calldata _rlpParentNodes,
        uint8 _messageBoxOffset,
        bytes32 _storageRoot
    )
        external
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(_message);
        require(
            _messageBox.inbox[messageHash_] == MessageStatus.Undeclared,
            "Message on target must be Undeclared."
        );

        // Get the storage path to verify proof.
        bytes memory path = BytesLib.bytes32ToBytes(
            storageVariablePathForStruct(
                _messageBoxOffset,
                OUTBOX_OFFSET,
                messageHash_
            )
        );

        // Verify the merkle proof.
        require(
            MerklePatriciaProof.verify(
                keccak256(abi.encodePacked(MessageStatus.Declared)),
                path,
                _rlpParentNodes,
                _storageRoot
            ),
            "Merkle proof verification failed."
        );

        // Update the message box inbox status to `Declared`.
        _messageBox.inbox[messageHash_] = MessageStatus.Declared;
    }

    /**
     * @notice Update the outbox message hash status to `Progressed`.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _unlockSecret Unlock secret for the hash lock provided while
     *                      declaration.
     *
     * @return messageHash_ Message hash.
     */
    function progressOutbox(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes32 _unlockSecret
    )
        external
        returns (bytes32 messageHash_)
    {
        require(
            _message.hashLock == keccak256(abi.encode(_unlockSecret)),
            "Invalid unlock secret."
        );

        messageHash_ = messageDigest(_message);
        require(
            _messageBox.outbox[messageHash_] == MessageStatus.Declared,
            "Message on source must be Declared."
        );

        // Update the outbox message status to `Progressed`.
        _messageBox.outbox[messageHash_] = MessageStatus.Progressed;
    }

    /**
     * @notice Update the status for the outbox for a given message hash to
     *         `Progressed`. Merkle proof is used to verify status of inbox in
     *         source chain. This is an alternative approach to hashlocks.
     *
     * @dev The messsage status for the message hash in the inbox should be
     *      either `Declared` or `Progresses`. Either of this status will be
     *      verified with the merkle proof.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox inbox.
     * @param _messageBoxOffset Position of the messageBox.
     * @param _storageRoot Storage root for proof.
     * @param _messageStatus Message status of message hash in the inbox of
     *                       source chain.
     *
     * @return messageHash_ Message hash.
     */
    function progressOutboxWithProof(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes calldata _rlpParentNodes,
        uint8 _messageBoxOffset,
        bytes32 _storageRoot,
        MessageStatus _messageStatus
    )
        external
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(_message);

        if(_messageBox.outbox[messageHash_] == MessageStatus.Declared) {

            /*
             * The inbox message status of target must be either `Declared` or
             * `Progressed` when outbox message status at source is `Declared`.
             */
            require(
                _messageStatus == MessageStatus.Declared ||
                _messageStatus == MessageStatus.Progressed,
                "Message on target must be Declared or Progressed."
            );

        } else if (_messageBox.outbox[messageHash_] == MessageStatus.DeclaredRevocation) {

            /*
             * The inbox message status of target must be either `Progressed`
             * when outbox message status at source is `DeclaredRevocation`.
             */
            require(
                _messageStatus == MessageStatus.Progressed,
                "Message on target must be Progressed."
            );

        } else {
            revert("Status of message on source must be Declared or DeclareRevocation.");
        }

        bytes memory storagePath = BytesLib.bytes32ToBytes(
            storageVariablePathForStruct(
                _messageBoxOffset,
                INBOX_OFFSET,
                messageHash_
            )
        );

        // Verify the merkle proof.
        require(
            MerklePatriciaProof.verify(
                keccak256(abi.encodePacked(_messageStatus)),
                storagePath,
                _rlpParentNodes,
                _storageRoot),
            "Merkle proof verification failed."
        );

        _messageBox.outbox[messageHash_] = MessageStatus.Progressed;
    }

    /**
     * @notice Update the status for the inbox for a given message hash to
     *         `Progressed`
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _unlockSecret Unlock secret for the hash lock provided while
     *                      declaration.
     *
     * @return messageHash_ Message hash.
     */
    function progressInbox(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes32 _unlockSecret
    )
        external
        returns (bytes32 messageHash_)
    {
        require(
            _message.hashLock == keccak256(abi.encode(_unlockSecret)),
            "Invalid unlock secret."
        );

        messageHash_ = messageDigest(_message);
        require(
            _messageBox.inbox[messageHash_] == MessageStatus.Declared,
            "Message on target status must be Declared."
        );

        _messageBox.inbox[messageHash_] = MessageStatus.Progressed;
    }

    /**
     * @notice Update the status for the inbox for a given message hash to
     *         `Progressed`. Merkle proof is used to verify status of outbox in
     *         source chain. This is an alternative approach to hashlocks.
     *
     * @dev The messsage status for the message hash in the outbox should be
     *      either `Declared` or `Progresses`. Either of this status will be
     *      verified in the merkle proof.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox outbox.
     * @param _messageBoxOffset Position of the messageBox.
     * @param _storageRoot Storage root for proof.
     * @param _messageStatus Message status of message hash in the outbox of
     *                       source chain.
     *
     * @return messageHash_ Message hash.
     */
    function progressInboxWithProof(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes calldata _rlpParentNodes,
        uint8 _messageBoxOffset,
        bytes32 _storageRoot,
        MessageStatus _messageStatus
    )
        external
        returns (bytes32 messageHash_)
    {
        // Outbox message status must be either `Declared` or `Progressed`.
        require(
            _messageStatus == MessageStatus.Declared ||
            _messageStatus == MessageStatus.Progressed,
            "Message on source must be Declared or Progressed."
        );

        messageHash_ = messageDigest(_message);
        require(
            _messageBox.inbox[messageHash_] == MessageStatus.Declared,
            "Message on target must be Declared."
        );

        // The outbox is at location OUTBOX_OFFSET of the MessageBox struct.
        bytes memory path = BytesLib.bytes32ToBytes(
            storageVariablePathForStruct(
                _messageBoxOffset,
                OUTBOX_OFFSET,
                messageHash_
            )
        );

        // Perform the merkle proof.
        require(
            MerklePatriciaProof.verify(
                keccak256(abi.encodePacked(_messageStatus)),
                path,
                _rlpParentNodes,
                _storageRoot
            ),
            "Merkle proof verification failed."
        );

        _messageBox.inbox[messageHash_] = MessageStatus.Progressed;
    }

    /**
     * @notice Declare a new revocation message. This will update the outbox
     *         status to `DeclaredRevocation` for the given message hash.
     *
     * @dev In order to declare revocation the existing message status for the
     *      given message hash should be `Declared`.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     *
     * @return messageHash_ Message hash.
     */
    function declareRevocationMessage(
        MessageBox storage _messageBox,
        Message storage _message
    )
        external
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(_message);
        require(
            _messageBox.outbox[messageHash_] == MessageStatus.Declared,
            "Message on source must be Declared."
        );

        _messageBox.outbox[messageHash_] = MessageStatus.DeclaredRevocation;
    }

    /**
     * @notice Confirm a revocation message that is declared in the outbox of
     *         source chain. This will update the outbox status to
     *         `Revoked` for the given message hash.
     *
     * @dev In order to declare revocation the existing message status for the
     *      given message hash should be `Declared`.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox outbox.
     * @param _messageBoxOffset Position of the messageBox.
     * @param _storageRoot Storage root for proof.
     *
     * @return messageHash_ Message hash.
     */
    function confirmRevocation(
        MessageBox storage _messageBox,
        Message storage _message,
        bytes calldata _rlpParentNodes,
        uint8 _messageBoxOffset,
        bytes32 _storageRoot
    )
        external
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(_message);
        require(
            _messageBox.inbox[messageHash_] == MessageStatus.Declared,
            "Message on target must be Declared."
        );

        // Get the path.
        bytes memory path = BytesLib.bytes32ToBytes(
            storageVariablePathForStruct(
                _messageBoxOffset,
                OUTBOX_OFFSET,
                messageHash_
            )
        );

        // Perform the merkle proof.
        require(
            MerklePatriciaProof.verify(
                keccak256(abi.encodePacked(MessageStatus.DeclaredRevocation)),
                path,
                _rlpParentNodes,
                _storageRoot
            ),
            "Merkle proof verification failed."
        );

        _messageBox.inbox[messageHash_] = MessageStatus.Revoked;
    }

    /**
     * @notice Update the status for the outbox for a given message hash to
     *         `Revoked`. Merkle proof is used to verify status of inbox in
     *         source chain.
     *
     * @dev The messsage status in the inbox should be
     *      either `DeclaredRevocation` or `Revoked`. Either of this status
     *      will be verified in the merkle proof.
     *
     * @param _messageBox Message Box.
     * @param _message Message object.
     * @param _messageBoxOffset Position of the messageBox.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox inbox.
     * @param _storageRoot Storage root for proof.
     * @param _messageStatus Message status of message hash in the inbox of
     *                       source chain.
     *
     * @return messageHash_ Message hash.
     */
    function progressOutboxRevocation(
        MessageBox storage _messageBox,
        Message storage _message,
        uint8 _messageBoxOffset,
        bytes calldata _rlpParentNodes,
        bytes32 _storageRoot,
        MessageStatus _messageStatus
    )
        external
        returns (bytes32 messageHash_)
    {
        require(
            _messageStatus == MessageStatus.Revoked,
            "Message on target status must be Revoked."
        );

        messageHash_ = messageDigest(_message);
        require(
            _messageBox.outbox[messageHash_] ==
            MessageStatus.DeclaredRevocation,
            "Message status on source must be DeclaredRevocation."
        );

        // The inbox is at location INBOX_OFFSET of the MessageBox struct.
        bytes memory path = BytesLib.bytes32ToBytes(
            storageVariablePathForStruct(
                _messageBoxOffset,
                INBOX_OFFSET,
                messageHash_
            )
        );

        // Perform the merkle proof.
        require(
            MerklePatriciaProof.verify(
                keccak256(abi.encodePacked(_messageStatus)),
                path,
                _rlpParentNodes,
                _storageRoot
            ),
            "Merkle proof verification failed."
        );

        _messageBox.outbox[messageHash_] = MessageStatus.Revoked;
    }

    /**
     * @notice Returns the type hash of the type "Message".
     *
     * @return messageTypehash_ The type hash of the "Message" type.
     */
    function messageTypehash() public pure returns(bytes32 messageTypehash_) {
        messageTypehash_ = MESSAGE_TYPEHASH;
    }


    /* Public Functions */

    /**
     * @notice Generate message hash from the input params
     *
     * @param _intentHash Intent hash.
     * @param _nonce Nonce of the message sender.
     * @param _gasPrice Gas price.
     *
     * @return messageHash_ Message hash.
     */
    function messageDigest(
        bytes32 _intentHash,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _sender,
        bytes32 _hashLock
    )
        public
        pure
        returns (bytes32 messageHash_)
    {
        messageHash_ = keccak256(
            abi.encode(
                MESSAGE_TYPEHASH,
                _intentHash,
                _nonce,
                _gasPrice,
                _gasLimit,
                _sender,
                _hashLock
            )
        );
    }


    /* Private Functions */

    /**
     * @notice Creates a hash from a message struct.
     *
     * @param _message The message to hash.
     *
     * @return messageHash_ The hash that represents this message.
     */
    function messageDigest(
        Message storage _message
    )
        private
        view
        returns (bytes32 messageHash_)
    {
        messageHash_ = messageDigest(
            _message.intentHash,
            _message.nonce,
            _message.gasPrice,
            _message.gasLimit,
            _message.sender,
            _message.hashLock
        );
    }

    /**
     * @notice Get the storage path of the variable inside the struct.
     *
     * @param _structPosition Position of struct variable.
     * @param _offset Offset of variable inside the struct.
     * @param _key Key of variable in case of mapping
     *
     * @return storagePath_ Storage path of the variable.
     */
    function storageVariablePathForStruct(
        uint8 _structPosition,
        uint8 _offset,
        bytes32 _key
    )
        private
        pure
        returns(bytes32 storagePath_)
    {
        if(_offset > 0){
            _structPosition = _structPosition + _offset;
        }

        bytes memory indexBytes = BytesLib.leftPad(
            BytesLib.bytes32ToBytes(bytes32(uint256(_structPosition)))
        );

        bytes memory keyBytes = BytesLib.leftPad(BytesLib.bytes32ToBytes(_key));
        bytes memory path = BytesLib.concat(keyBytes, indexBytes);

        storagePath_ = keccak256(
            abi.encodePacked(keccak256(abi.encodePacked(path)))
        );
    }
}

// File: ../../mosaic-contracts/contracts/lib/OrganizationInterface.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------

/**
 *  @title OrganizationInterface provides methods to check if an address is
 *         currently registered as an active participant in the organization.
 */
interface OrganizationInterface {

    /**
     * @notice Checks if an address is currently registered as the organization.
     *
     * @param _organization Address to check.
     *
     * @return isOrganization_ True if the given address represents the
     *                         organization. Returns false otherwise.
     */
    function isOrganization(
        address _organization
    )
        external
        view
        returns (bool isOrganization_);

    /**
     * @notice Checks if an address is currently registered as an active worker.
     *
     * @param _worker Address to check.
     *
     * @return isWorker_ True if the given address is a registered, active
     *                   worker. Returns false otherwise.
     */
    function isWorker(address _worker) external view returns (bool isWorker_);

}

// File: ../../mosaic-contracts/contracts/lib/Organized.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------


/**
 * @title Organized contract.
 *
 * @notice The Organized contract facilitates integration of
 *         organization administration keys with different contracts.
 */
contract Organized {


    /* Storage */

    /** Organization which holds all the keys needed to administer the economy. */
    OrganizationInterface public organization;


    /* Modifiers */

    modifier onlyOrganization()
    {
        require(
            organization.isOrganization(msg.sender),
            "Only the organization is allowed to call this method."
        );

        _;
    }

    modifier onlyWorker()
    {
        require(
            organization.isWorker(msg.sender),
            "Only whitelisted workers are allowed to call this method."
        );

        _;
    }


    /* Constructor */

    /**
     * @notice Sets the address of the organization contract.
     *
     * @param _organization A contract that manages worker keys.
     */
    constructor(OrganizationInterface _organization) public {
        require(
            address(_organization) != address(0),
            "Organization contract address must not be zero."
        );

        organization = _organization;
    }

}

// File: ../../mosaic-contracts/contracts/lib/StateRootInterface.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------

/** @title An interface to an get state root. */
interface StateRootInterface {

    /**
     * @notice Gets the block number of latest committed state root.
     *
     * @return height_ Block height of the latest committed state root.
     */
    function getLatestStateRootBlockHeight()
        external
        view
        returns (uint256 height_);

    /**
     * @notice Get the state root for the given block height.
     *
     * @param _blockHeight The block height for which the state root is fetched.
     *
     * @return bytes32 State root at the given height.
     */
    function getStateRoot(uint256 _blockHeight)
        external
        view
        returns (bytes32 stateRoot_);

}

// File: ../../mosaic-contracts/contracts/gateway/GatewayBase.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------








/**
 *  @title GatewayBase is the base contract for EIP20Gateway and EIP20CoGateway.
 */
contract GatewayBase is Organized {

    /* Usings */

    using SafeMath for uint256;


    /* Events */

    /**
     * Emitted whenever a Gateway/CoGateway contract is proven.
     * wasAlreadyProved parameter differentiates between first call and replay
     * call of proveGateway method for same block height.
     */
    event GatewayProven(
        address _gateway,
        uint256 _blockHeight,
        bytes32 _storageRoot,
        bool _wasAlreadyProved
    );

    event BountyChangeInitiated(
        uint256 _currentBounty,
        uint256 _proposedBounty,
        uint256 _unlockHeight
    );

    event BountyChangeConfirmed(
        uint256 _currentBounty,
        uint256 _changedBounty
    );


    /* Constants */

    /** Position of message bus in the storage. */
    uint8 constant MESSAGE_BOX_OFFSET = 7;

    /**
     * Penalty in bounty amount percentage charged to staker on revert stake.
     */
    uint8 constant REVOCATION_PENALTY = 150;

    //todo identify how to get block time for both chains
    /**
     * Unlock period of 7-days for change bounty in block height.
     * Considering aux block generation time per block is 3-secs.
     */
    uint256 public constant BOUNTY_CHANGE_UNLOCK_PERIOD = 201600;


    /* Public Variables */

    /**
     *  Address of contract which implements StateRootInterface.
     */
    StateRootInterface public stateRootProvider;

    /** Path to make Merkle account proof for Gateway/CoGateway contract. */
    bytes public encodedGatewayPath;

    /**
     * Remote gateway contract address. If this is a gateway contract, then the
     * remote gateway is a CoGateway and vice versa.
     */
    address public remoteGateway;

    /** Amount of ERC20 which is staked by facilitator. */
    uint256 public bounty;

    /** Proposed new bounty amount for bounty change. */
    uint256 public proposedBounty;

    /** Bounty proposal block height. */
    uint256 public proposedBountyUnlockHeight;


    /* Internal Variables */

    /**
     * Message box.
     * @dev Keep this is at location 1, in case this is changed then update
     *      constant MESSAGE_BOX_OFFSET accordingly.
     */
    MessageBus.MessageBox internal messageBox;

    /** Maps messageHash to the Message object. */
    mapping(bytes32 => MessageBus.Message) public messages;

    /** Maps blockHeight to storageRoot. */
    mapping(uint256 => bytes32) internal storageRoots;


    /* Private Variables */

    /**
     * Maps address to message hash.
     *
     * Once the inbox process is started the corresponding
     * message hash is stored against the address starting process.
     * This is used to restrict simultaneous/multiple process
     * for a particular address. This is also used to determine the
     * nonce of the particular address. Refer getNonce for the details.
     */
    mapping(address => bytes32) private inboxActiveProcess;

    /**
     * Maps address to message hash.
     *
     * Once the outbox process is started the corresponding
     * message hash is stored  against the address starting process.
     * This is used to restrict simultaneous/multiple process
     * for a particular address. This is also used to determine the
     * nonce of the particular address. Refer getNonce for the details.
     */
    mapping(address => bytes32) private outboxActiveProcess;


    /* Constructor */

    /**
     * @notice Initialize the contract and set default values.
     *
     * @param _stateRootProvider Contract address which implements
     *                           StateRootInterface.
     * @param _bounty The amount that facilitator will stakes to initiate the
     *                message transfers.
     * @param _organization Address of an organization contract.
     */
    constructor(
        StateRootInterface _stateRootProvider,
        uint256 _bounty,
        OrganizationInterface _organization
    )
        Organized(_organization)
        public
    {
        require(
            address(_stateRootProvider) != address(0),
            "State root provider contract address must not be zero."
        );

        stateRootProvider = _stateRootProvider;
        bounty = _bounty;

        // The following variables are not known at construction:
        messageBox = MessageBus.MessageBox();
        encodedGatewayPath = '';
        remoteGateway = address(0);
    }


    /* External Functions */

    /**
     *  @notice This can be called by anyone to verify merkle proof of
     *          gateway/co-gateway contract address. Trust factor is brought by
     *          state roots of the contract which implements StateRootInterface.
     *          It's important to note that in replay calls of proveGateway
     *          bytes _rlpParentNodes variable is not validated. In this case
     *          input storage root derived from merkle proof account nodes is
     *          verified with stored storage root of given blockHeight.
     *          GatewayProven event has parameter wasAlreadyProved to
     *          differentiate between first call and replay calls.
     *
     *  @param _blockHeight Block height at which Gateway/CoGateway is to be
     *                      proven.
     *  @param _rlpAccount RLP encoded account node object.
     *  @param _rlpParentNodes RLP encoded value of account proof parent nodes.
     *
     *  @return `true` if Gateway account is proved
     */
    function proveGateway(
        uint256 _blockHeight,
        bytes calldata _rlpAccount,
        bytes calldata _rlpParentNodes
    )
        external
        returns (bool /* success */)
    {
        // _rlpAccount should be valid
        require(
            _rlpAccount.length != 0,
            "Length of RLP account must not be 0."
        );

        // _rlpParentNodes should be valid
        require(
            _rlpParentNodes.length != 0,
            "Length of RLP parent nodes is 0"
        );

        bytes32 stateRoot = stateRootProvider.getStateRoot(_blockHeight);

        // State root should be present for the block height
        require(
            stateRoot != bytes32(0),
            "State root must not be zero"
        );

        // If account already proven for block height
        bytes32 provenStorageRoot = storageRoots[_blockHeight];

        if (provenStorageRoot != bytes32(0)) {

            // wasAlreadyProved is true here since proveOpenST is replay call
            // for same block height
            emit GatewayProven(
                remoteGateway,
                _blockHeight,
                provenStorageRoot,
                true
            );

            // return true
            return true;
        }

        bytes32 storageRoot = GatewayLib.proveAccount(
            _rlpAccount,
            _rlpParentNodes,
            encodedGatewayPath,
            stateRoot
        );

        storageRoots[_blockHeight] = storageRoot;

        // wasAlreadyProved is false since Gateway is called for the first time
        // for a block height
        emit GatewayProven(
            remoteGateway,
            _blockHeight,
            storageRoot,
            false
        );

        return true;
    }

    /**
     * @notice Get the nonce for the given account address
     *
     * @param _account Account address for which the nonce is to fetched
     *
     * @return nonce
     */
    function getNonce(address _account)
        external
        view
        returns (uint256)
    {
        // call the private method
        return _getOutboxNonce(_account);
    }

    /**
     * @notice Method allows organization to propose new bounty amount.
     *
     * @param _proposedBounty proposed bounty amount.
     *
     * @return uint256 proposed bounty amount.
     */
    function initiateBountyAmountChange(uint256 _proposedBounty)
        external
        onlyOrganization
        returns(uint256)
    {
        return initiateBountyAmountChangeInternal(_proposedBounty, BOUNTY_CHANGE_UNLOCK_PERIOD);
    }

    /**
     * @notice Method allows organization to confirm proposed bounty amount
     *         after unlock period.
     *
     * @return changedBountyAmount_  updated bounty amount.
     * @return previousBountyAmount_ previous bounty amount.
     */
    function confirmBountyAmountChange()
        external
        onlyOrganization
        returns (
            uint256 changedBountyAmount_,
            uint256 previousBountyAmount_
        )
    {
        require(
            proposedBounty != bounty,
            "Proposed bounty should be different from existing bounty."
        );
        require(
            proposedBountyUnlockHeight < block.number,
            "Confirm bounty amount change can only be done after unlock period."
        );

        changedBountyAmount_ = proposedBounty;
        previousBountyAmount_ = bounty;

        bounty = proposedBounty;

        proposedBounty = 0;
        proposedBountyUnlockHeight = 0;

        emit BountyChangeConfirmed(previousBountyAmount_, changedBountyAmount_);
    }

    /**
     * @notice Method to get the outbox message status for the given message
     *         hash. If message hash does not exist then it will return
     *         undeclared status.
     *
     * @param _messageHash Message hash to get the status.
     *
     * @return status_ Message status.
     */
    function getOutboxMessageStatus(
        bytes32 _messageHash
    )
        external
        view
        returns (MessageBus.MessageStatus status_)
    {
        status_ = messageBox.outbox[_messageHash];
    }

    /**
     * @notice Method to get the inbox message status for the given message
     *         hash. If message hash does not exist then it will return
     *         undeclared status.
     *
     * @param _messageHash Message hash to get the status.
     *
     * @return status_ Message status.
     */
    function getInboxMessageStatus(
        bytes32 _messageHash
    )
        external
        view
        returns (MessageBus.MessageStatus status_)
    {
        status_ = messageBox.inbox[_messageHash];
    }

    /**
     * @notice Method to get the active message hash and its status from inbox
     *         for the given account address. If message hash does not exist
     *         for the given account address then it will return zero hash and
     *         undeclared status.
     *
     * @param _account Account address.
     *
     * @return messageHash_ Message hash.
     * @return status_ Message status.
     */
    function getInboxActiveProcess(
        address _account
    )
        external
        view
        returns (
            bytes32 messageHash_,
            MessageBus.MessageStatus status_
        )
    {
        messageHash_ = inboxActiveProcess[_account];
        status_ = messageBox.inbox[messageHash_];
    }

    /**
     * @notice Method to get the active message hash and its status from outbox
     *         for the given account address. If message hash does not exist
     *         for the given account address then it will return zero hash and
     *         undeclared status.
     *
     * @param _account Account address.
     *
     * @return messageHash_ Message hash.
     * @return status_ Message status.
     */
    function getOutboxActiveProcess(
        address _account
    )
        external
        view
        returns (
            bytes32 messageHash_,
            MessageBus.MessageStatus status_
        )
    {
        messageHash_ = outboxActiveProcess[_account];
        status_ = messageBox.outbox[messageHash_];
    }


    /* Internal Functions */

    /**
     * @notice Calculate the fee amount which is rewarded to facilitator for
     *         performing message transfers.
     *
     * @param _gasConsumed Gas consumption during message confirmation.
     * @param _gasLimit Maximum amount of gas can be used for reward.
     * @param _gasPrice Gas price at which reward is calculated.
     * @param _initialGas Initial gas at the start of the process.
     *
     * @return fee_ Fee amount.
     * @return totalGasConsumed_ Total gas consumed during message transfer.
     */
    function feeAmount(
        uint256 _gasConsumed,
        uint256 _gasLimit,
        uint256 _gasPrice,
        uint256 _initialGas
    )
        internal
        view
        returns (
            uint256 fee_,
            uint256 totalGasConsumed_
        )
    {
        totalGasConsumed_ = _initialGas.add(
            _gasConsumed
        ).sub(
            gasleft()
        );

        if (totalGasConsumed_ < _gasLimit) {
            fee_ = totalGasConsumed_.mul(_gasPrice);
        } else {
            fee_ = _gasLimit.mul(_gasPrice);
        }
    }

    /**
     * @notice Create and return Message object.
     *
     * @dev This function is to avoid stack too deep error.
     *
     * @param _intentHash Intent hash
     * @param _accountNonce Nonce for the account address
     * @param _gasPrice Gas price
     * @param _gasLimit Gas limit
     * @param _account Account address
     * @param _hashLock Hash lock
     *
     * @return Message object
     */
    function getMessage(
        bytes32 _intentHash,
        uint256 _accountNonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _account,
        bytes32 _hashLock
    )
        internal
        pure
        returns (MessageBus.Message memory)
    {
        return MessageBus.Message({
            intentHash : _intentHash,
            nonce : _accountNonce,
            gasPrice : _gasPrice,
            gasLimit : _gasLimit,
            sender : _account,
            hashLock : _hashLock,
            gasConsumed : 0
        });
    }

    /**
     * @notice Internal function to get the outbox nonce for the given account
     *         address
     *
     * @param _account Account address for which the nonce is to fetched
     *
     * @return nonce
     */
    function _getOutboxNonce(address _account)
        internal
        view
        returns (uint256 /* nonce */)
    {

        bytes32 previousProcessMessageHash = outboxActiveProcess[_account];
        return getMessageNonce(previousProcessMessageHash);
    }

    /**
     * @notice Internal function to get the inbox nonce for the given account
     *         address.
     *
     * @param _account Account address for which the nonce is to fetched
     *
     * @return nonce
     */
    function _getInboxNonce(address _account)
        internal
        view
        returns (uint256 /* nonce */)
    {

        bytes32 previousProcessMessageHash = inboxActiveProcess[_account];
        return getMessageNonce(previousProcessMessageHash);
    }

    /**
     * @notice Stores a message at its hash in the messages mapping.
     *
     * @param _message The message to store.
     *
     * @return messageHash_ The hash that represents the given message.
     */
    function storeMessage(
        MessageBus.Message memory _message
    )
        internal
        returns (bytes32 messageHash_)
    {
        messageHash_ = MessageBus.messageDigest(
            _message.intentHash,
            _message.nonce,
            _message.gasPrice,
            _message.gasLimit,
            _message.sender,
            _message.hashLock
        );

        messages[messageHash_] = _message;
    }

    /**
     * @notice Clears the previous outbox process. Validates the
     *         nonce. Updates the process with new process
     *
     * @param _account Account address
     * @param _nonce Nonce for the account address
     * @param _messageHash Message hash
     */
    function registerOutboxProcess(
        address _account,
        uint256 _nonce,
        bytes32 _messageHash

    )
        internal
    {
        require(
            _nonce == _getOutboxNonce(_account),
            "Invalid nonce."
        );

        bytes32 previousMessageHash = outboxActiveProcess[_account];

        if (previousMessageHash != bytes32(0)) {

            MessageBus.MessageStatus status =
                messageBox.outbox[previousMessageHash];

            require(
                status == MessageBus.MessageStatus.Progressed ||
                status == MessageBus.MessageStatus.Revoked,
                "Previous process is not completed."
            );

            delete messages[previousMessageHash];
        }

        // Update the active process.
        outboxActiveProcess[_account] = _messageHash;

    }

    /**
     * @notice Clears the previous outbox process. Validates the
     *         nonce. Updates the process with new process.
     *
     * @param _account Account address.
     * @param _nonce Nonce for the account address.
     * @param _messageHash Message hash.
     */
    function registerInboxProcess(
        address _account,
        uint256 _nonce,
        bytes32 _messageHash
    )
        internal
    {
        require(
            _nonce == _getInboxNonce(_account),
            "Invalid nonce"
        );

        bytes32 previousMessageHash = inboxActiveProcess[_account];

        if (previousMessageHash != bytes32(0)) {

            MessageBus.MessageStatus status =
                messageBox.inbox[previousMessageHash];

            require(
                status == MessageBus.MessageStatus.Progressed ||
                status == MessageBus.MessageStatus.Revoked,
                "Previous process is not completed"
            );

            delete messages[previousMessageHash];
        }

        // Update the active process.
        inboxActiveProcess[_account] = _messageHash;
    }

    /**
     * @notice Calculates the penalty amount for reverting a message transfer.
     *
     * @param _bounty The amount that facilitator has staked to initiate the
     *                message transfers.
     *
     * @return penalty_ Amount of penalty needs to be paid by message initiator
     *                  to revert message transfers.
     */
    function penaltyFromBounty(uint256 _bounty)
        internal
        pure
        returns(uint256 penalty_)
    {
        penalty_ = _bounty.mul(REVOCATION_PENALTY).div(100);
    }

    /**
     * Internal method to propose new bounty. This is added for large block
     * heights value for unlocking bounty change.
     *
     * @param _proposedBounty proposed bounty amount.
     * @param _bountyChangePeriod  Unlock period for change bounty in
     *                             block height.
     *
     * @return uint256 proposed bounty amount.
     */
    function initiateBountyAmountChangeInternal(
        uint256 _proposedBounty,
        uint256 _bountyChangePeriod
    )
        internal
        returns(uint256)
    {
        proposedBounty = _proposedBounty;
        proposedBountyUnlockHeight = block.number.add(_bountyChangePeriod);

        emit BountyChangeInitiated(
            bounty,
            _proposedBounty,
            proposedBountyUnlockHeight
        );

        return _proposedBounty;
    }

    /* Private Functions */

    /**
     * @notice Returns the next nonce of inbox or outbox process
     *
     * @param _messageHash Message hash
     *
     * @return _nonce nonce of next inbox or outbox process
     */
    function getMessageNonce(bytes32 _messageHash)
        private
        view
        returns(uint256)
    {
        if (_messageHash == bytes32(0)) {
            return 1;
        }

        MessageBus.Message storage message =
        messages[_messageHash];

        return message.nonce.add(1);
    }
}

// File: ../../mosaic-contracts/contracts/gateway/EIP20Gateway.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
// Origin Chain: Gateway Contract
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------


/*

           Origin chain      |       Auxiliary chain
-------------------------------------------------------------------------------
           EIP20Gateway - - - - - - - - - - - EIP20CoGateway
-------------------------------------------------------------------------------

1. Stake and Mint: Normal flow

           stake             --->   confirmStakeIntent
             |
      progressStake (HL)     --->   progressMint (HL)
-------------------------------------------------------------------------------
2. Stake and Mint (Revert): Normal flow

           stake             --->   confirmStakeIntent
             |
        revertStake          --->   confirmRevertStakeIntent
                                            |
      progressRevertStake    <---   progressRevertStake
-------------------------------------------------------------------------------
3. Stake and Mint: Incase the facilitator is not able to progress

    stake (by facilitator)    --->   confirmStakeIntent (by facilitator)
                               |
                        facilitator (offline)
             |
     progressStakeWithProof   --->   progressMintWithProof
-------------------------------------------------------------------------------
*/




/**
 * @title EIP20Gateway Contract
 *
 * @notice EIP20Gateway act as medium to send messages from origin chain to
 *         auxiliary chain. Currently gateway supports stake and revert stake message.
 */
contract EIP20Gateway is GatewayBase {

    /* Events */

    /** Emitted whenever a stake process is initiated. */
    event StakeIntentDeclared(
        bytes32 indexed _messageHash,
        address _staker,
        uint256 _stakerNonce,
        address _beneficiary,
        uint256 _amount
    );

    /** Emitted whenever a stake is completed. */
    event StakeProgressed(
        bytes32 indexed _messageHash,
        address _staker,
        uint256 _stakerNonce,
        uint256 _amount,
        bool _proofProgress,
        bytes32 _unlockSecret
    );

    /** Emitted whenever a process is initiated to revert stake. */
    event RevertStakeIntentDeclared(
        bytes32 indexed _messageHash,
        address _staker,
        uint256 _stakerNonce,
        uint256 _amount
    );

    /** Emitted whenever a stake is reverted. */
    event StakeReverted(
        bytes32 indexed _messageHash,
        address _staker,
        uint256 _stakerNonce,
        uint256 _amount
    );

    /** Emitted whenever a redeem intent is confirmed. */
    event RedeemIntentConfirmed(
        bytes32 indexed _messageHash,
        address _redeemer,
        uint256 _redeemerNonce,
        address _beneficiary,
        uint256 _amount,
        uint256 _blockHeight,
        bytes32 _hashLock
    );

    /** Emitted whenever a unstake process is complete. */
    event UnstakeProgressed(
        bytes32 indexed _messageHash,
        address _redeemer,
        address _beneficiary,
        uint256 _redeemAmount,
        uint256 _unstakeAmount,
        uint256 _rewardAmount,
        bool _proofProgress,
        bytes32 _unlockSecret
    );

    /** Emitted whenever a revert redeem intent is confirmed. */
    event RevertRedeemIntentConfirmed(
        bytes32 indexed _messageHash,
        address _redeemer,
        uint256 _redeemerNonce,
        uint256 _amount
    );

    /** Emitted whenever revert redeem is completed. */
    event RevertRedeemComplete(
        bytes32 indexed _messageHash,
        address _redeemer,
        uint256 _redeemerNonce,
        uint256 _amount
    );


    /* Struct */

    /**
     * Stake stores the stake amount, beneficiary address, message data and
     * facilitator address.
     */
    struct Stake {

        /** Amount that will be staked. */
        uint256 amount;

        /**
         * Address where the utility tokens will be minted in the
         * auxiliary chain.
         */
        address beneficiary;

        /** Bounty kept by facilitator for stake message transfer. */
        uint256 bounty;
    }

    /**
     * Unstake stores the unstake/redeem information
     * like unstake/redeem amount, beneficiary address, message data.
     */
    struct Unstake {

        /** Amount that will be unstaked. */
        uint256 amount;

        /** Address that will receive the unstaked token. */
        address beneficiary;
    }


    /* Public Variables */

    /** Specifies if the Gateway is activated for any new process. */
    bool public activated;

    /** Escrow address to lock staked fund. */
    SimpleStake public stakeVault;

    /** Address of EIP20 token. */
    EIP20Interface public token;

    /**
     * Address of ERC20 token in which the facilitator will stake(bounty)
     * for a process.
     */
    EIP20Interface public baseToken;

    /** Address where token will be burned. */
    address public burner;

    /** Maps messageHash to the Stake object. */
    mapping(bytes32 /*messageHash*/ => Stake) stakes;

    /** Maps messageHash to the Unstake object. */
    mapping(bytes32 /*messageHash*/ => Unstake) unstakes;


    /* Modifiers */

    /** Checks that contract is active. */
    modifier isActive() {
        require(
            activated == true,
            "Gateway is not activated."
        );
        _;
    }


    /* Constructor */

    /**
     * @notice Initialize the contract by providing the ERC20 token address
     *         for which the gateway will enable facilitation of stake and
     *         mint.
     *
     * @param _token The ERC20 token contract address that will be
     *               staked and corresponding utility tokens will be minted
     *               in auxiliary chain.
     * @param _baseToken The ERC20 token address that will be used for
     *                     staking bounty from the facilitators.
     * @param _stateRootProvider Contract address which implements
     *                           StateRootInterface.
     * @param _bounty The amount that facilitator will stakes to initiate the
     *                stake process.
     * @param _organization Address of an organization contract.
     * @param _burner Address where tokens will be burned.
     */
    constructor(
        EIP20Interface _token,
        EIP20Interface _baseToken,
        StateRootInterface _stateRootProvider,
        uint256 _bounty,
        OrganizationInterface _organization,
        address _burner
    )
        GatewayBase(
            _stateRootProvider,
            _bounty,
            _organization
        )
        public
    {
        require(
            address(_token) != address(0),
            "Token contract address must not be zero."
        );
        require(
            address(_baseToken) != address(0),
            "Base token contract address for bounty must not be zero"
        );
        token = _token;
        baseToken = _baseToken;
        burner = _burner;
        // gateway is in-active initially.
        activated = false;
        // deploy simpleStake contract that will keep the staked amounts.
        stakeVault = new SimpleStake(_token, address(this));
    }


    /* External functions */

    /**
     * @notice Initiates the stake process.  In order to stake the staker
     *         needs to approve Gateway contract for stake amount.
     *         Staked amount is transferred from staker address to
     *         Gateway contract. Bounty amount is also transferred from staker.
     *
     * @param _amount Stake amount that will be transferred from the staker
     *                account.
     * @param _beneficiary The address in the auxiliary chain where the utility
     *                     tokens will be minted.
     * @param _gasPrice Gas price that staker is ready to pay to get the stake
     *                  and mint process done.
     * @param _gasLimit Gas limit that staker is ready to pay.
     * @param _nonce Nonce of the staker address.
     * @param _hashLock Hash Lock provided by the facilitator.
     *
     * @return messageHash_ Message hash is unique for each request.
     */
    function stake(
        uint256 _amount,
        address _beneficiary,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _nonce,
        bytes32 _hashLock
    )
        external
        isActive
        returns (bytes32 messageHash_)
    {
        address staker = msg.sender;

        require(
            _amount > uint256(0),
            "Stake amount must not be zero."
        );

        require(
            _beneficiary != address(0),
            "Beneficiary address must not be zero."
        );

        /*
         * Maximum reward possible is _gasPrice * _gasLimit, we check this
         * upfront in this function to make sure that after minting of the
         * tokens it is possible to give the reward to the facilitator.
         */
        require(
            _amount > _gasPrice.mul(_gasLimit),
            "Maximum possible reward must be less than the stake amount."
        );

        // Get the stake intent hash.
        bytes32 intentHash = GatewayLib.hashStakeIntent(
            _amount,
            _beneficiary,
            address(this)
        );

        MessageBus.Message memory message = getMessage(
            intentHash,
            _nonce,
            _gasPrice,
            _gasLimit,
            staker,
            _hashLock
        );

        messageHash_ = storeMessage(message);

        registerOutboxProcess(
            staker,
            _nonce,
            messageHash_
        );

        // New stake object
        stakes[messageHash_] = Stake({
            amount : _amount,
            beneficiary : _beneficiary,
            bounty : bounty
        });

        // Declare message in outbox
        MessageBus.declareMessage(
            messageBox,
            messages[messageHash_]
        );

        // Transfer staker amount to the gateway.
        require(
            token.transferFrom(staker, address(this), _amount),
            "Stake amount must be transferred to gateway"
        );

        // Transfer the bounty amount to the gateway.
        require(
            baseToken.transferFrom(staker, address(this), bounty),
            "Bounty amount must be transferred to gateway"
        );

        emit StakeIntentDeclared(
            messageHash_,
            staker,
            _nonce,
            _beneficiary,
            _amount
        );
    }

    /**
     * @notice Completes the stake process.
     *
     * @dev Message bus ensures correct execution sequence of methods and also
     *      provides safety mechanism for any possible re-entrancy attack.
     *
     * @param _messageHash Message hash.
     * @param _unlockSecret Unlock secret for the hashLock provide by the
     *                      staker while initiating the stake.
     *
     * @return staker_ Staker address.
     * @return stakeAmount_ Stake amount.
     */
    function progressStake(
        bytes32 _messageHash,
        bytes32 _unlockSecret
    )
        external
        returns (
            address staker_,
            uint256 stakeAmount_
        )
    {
        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero"
        );

        // Get the message object
        MessageBus.Message storage message = messages[_messageHash];

        // Progress outbox
        MessageBus.progressOutbox(
            messageBox,
            message,
            _unlockSecret
        );

        (staker_, stakeAmount_) = progressStakeInternal(
            _messageHash,
            message,
            _unlockSecret,
            false
        );
    }

    /**
     * @notice Completes the stake process by providing the merkle proof
     *         instead of unlockSecret. In case the facilitator process is not
     *         able to complete the stake and mint process then this is an
     *         alternative approach to complete the process
     *
     * @dev This can be called to prove that the inbox status of messageBox on
     *      CoGateway is either declared or progressed.
     *
     * @param _messageHash Message hash.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox outbox of CoGateway.
     * @param _blockHeight Block number for which the proof is valid.
     * @param _messageStatus Message status i.e. Declared or Progressed that
     *                       will be proved.
     *
     * @return staker_ Staker address
     * @return stakeAmount_ Stake amount
     */
    function progressStakeWithProof(
        bytes32 _messageHash,
        bytes calldata _rlpParentNodes,
        uint256 _blockHeight,
        uint256 _messageStatus
    )
        external
        returns (
            address staker_,
            uint256 stakeAmount_
        )
    {
        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );
        require(
            _rlpParentNodes.length > 0,
            "RLP encoded parent nodes must not be zero."
        );

        bytes32 storageRoot = storageRoots[_blockHeight];

        require(
            storageRoot != bytes32(0),
            "Storage root must not be zero."
        );

        // Get the message object
        MessageBus.Message storage message = messages[_messageHash];

        MessageBus.progressOutboxWithProof(
            messageBox,
            message,
            _rlpParentNodes,
            MESSAGE_BOX_OFFSET,
            storageRoot,
            MessageBus.MessageStatus(_messageStatus)
        );

        (staker_, stakeAmount_) = progressStakeInternal(
            _messageHash,
            message,
            bytes32(0),
            true
        );
    }

    /**
     * @notice Revert stake process and get the stake
     *         amount back. Only staker can revert stake by providing
     *         penalty i.e. 1.5 times of bounty amount. On progress revert stake
     *         penalty and facilitator bounty will be burned.
     *
     * @param _messageHash Message hash.
     *
     * @return staker_ Staker address
     * @return stakerNonce_ Staker nonce
     * @return amount_ Stake amount
     */
    function revertStake(
        bytes32 _messageHash
    )
        external
        returns (
            address staker_,
            uint256 stakerNonce_,
            uint256 amount_
        )
    {
        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );

        MessageBus.Message storage message = messages[_messageHash];

        require(
            message.sender == msg.sender,
            "Only staker can revert stake."
        );

        // Declare stake revocation.
        MessageBus.declareRevocationMessage(
            messageBox,
            message
        );

        staker_ = message.sender;
        stakerNonce_ = message.nonce;
        amount_ = stakes[_messageHash].amount;

        // Penalty charged to staker for revert stake.
        uint256 penalty = penaltyFromBounty(stakes[_messageHash].bounty);

        // Transfer the penalty amount to burner.
        require(
            baseToken.transferFrom(msg.sender, burner, penalty),
            "Staker must approve gateway for penalty amount."
        );

        emit RevertStakeIntentDeclared(
            _messageHash,
            staker_,
            stakerNonce_,
            amount_
        );
    }

    /**
     * @notice Complete revert stake by providing the merkle proof.
     *         This method will return stake amount to staker and burn
     *         facilitator bounty.
     *
     * @dev Message bus ensures correct execution sequence of methods and also
     *      provides safety mechanism for any possible re-entrancy attack.
     *
     * @param _messageHash Message hash.
     * @param _blockHeight Block number for which the proof is valid
     * @param _rlpParentNodes RLP encoded parent node data to prove
     *                        DeclaredRevocation in messageBox inbox of
     *                        CoGateway.
     *
     * @return staker_ Staker address.
     * @return stakerNonce_ Staker nonce.
     * @return amount_ Stake amount.
     */
    function progressRevertStake(
        bytes32 _messageHash,
        uint256 _blockHeight,
        bytes calldata _rlpParentNodes
    )
        external
        returns (
            address staker_,
            uint256 stakerNonce_,
            uint256 amount_
        )
    {
        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );
        require(
            _rlpParentNodes.length > 0,
            "RLP parent nodes must not be zero."
        );

        // Get the message object.
        MessageBus.Message storage message = messages[_messageHash];
        require(
            message.intentHash != bytes32(0),
            "StakeIntentHash must not be zero."
        );

        // Get the storageRoot for the given block height.
        bytes32 storageRoot = storageRoots[_blockHeight];
        require(
            storageRoot != bytes32(0),
            "Storage root must not be zero."
        );

        amount_ = stakes[_messageHash].amount;

        require(
            amount_ > 0,
            "Stake request must exist."
        );

        staker_ = message.sender;
        stakerNonce_ = message.nonce;
        uint256 stakeBounty = stakes[_messageHash].bounty;

        // Progress with revocation message.
        MessageBus.progressOutboxRevocation(
            messageBox,
            message,
            MESSAGE_BOX_OFFSET,
            _rlpParentNodes,
            storageRoot,
            MessageBus.MessageStatus.Revoked
        );

        delete stakes[_messageHash];

        // Transfer the staked amount to the staker.
        token.transfer(message.sender, amount_);

        // Burn facilitator bounty.
        baseToken.transfer(burner, stakeBounty);

        emit StakeReverted(
            _messageHash,
            staker_,
            stakerNonce_,
            amount_
        );
    }

    /**
     * @notice Declare redeem intent.
     *
     * @param _redeemer Redeemer address.
     * @param _redeemerNonce Redeemer nonce.
     * @param _beneficiary Address where the redeemed tokens will be
     *                     transferred.
     * @param _amount Redeem amount.
     * @param _gasPrice Gas price that redeemer is ready to pay to get the
     *                  redeem and unstake process done.
     * @param _gasLimit Gas limit that redeemer is ready to pay.
     * @param _blockHeight Block number for which the proof is valid.
     * @param _hashLock Hash lock.
     * @param _rlpParentNodes RLP encoded parent node data to prove
     *                        Declared in messageBox outbox of
     *                        CoGateway.
     *
     * @return messageHash_ Message hash.
     */
    function confirmRedeemIntent(
        address _redeemer,
        uint256 _redeemerNonce,
        address _beneficiary,
        uint256 _amount,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _blockHeight,
        bytes32 _hashLock,
        bytes calldata _rlpParentNodes
    )
        external
        returns (bytes32 messageHash_)
    {
        // Get the initial gas.
        uint256 initialGas = gasleft();

        require(
            _redeemer != address(0),
            "Redeemer address must not be zero."
        );
        require(
            _beneficiary != address(0),
            "Beneficiary address must not be zero."
        );
        require(
            _amount != 0,
            "Redeem amount must not be zero."
        );
        require(
            _rlpParentNodes.length > 0,
            "RLP encoded parent nodes must not be zero."
        );

        /*
         * Maximum reward possible is _gasPrice * _gasLimit, we check this
         * upfront in this function to make sure that after unstake of the
         * tokens it is possible to give the reward to the facilitator.
         */
        require(
            _amount > _gasPrice.mul(_gasLimit),
            "Maximum possible reward must be less than the redeem amount."
        );

        bytes32 intentHash = hashRedeemIntent(
            _amount,
            _beneficiary
        );

        MessageBus.Message memory message = MessageBus.Message(
            intentHash,
            _redeemerNonce,
            _gasPrice,
            _gasLimit,
            _redeemer,
            _hashLock,
            0 // Gas consumed will be updated at the end of this function.
        );
        messageHash_ = storeMessage(message);

        registerInboxProcess(
            message.sender,
            message.nonce,
            messageHash_
        );

        unstakes[messageHash_] = Unstake({
            amount : _amount,
            beneficiary : _beneficiary
        });

        confirmRedeemIntentInternal(
            messages[messageHash_],
            _blockHeight,
            _rlpParentNodes
        );

        // Emit RedeemIntentConfirmed event.
        emit RedeemIntentConfirmed(
            messageHash_,
            _redeemer,
            _redeemerNonce,
            _beneficiary,
            _amount,
            _blockHeight,
            _hashLock
        );

        // Update the gas consumed for this function.
        messages[messageHash_].gasConsumed = initialGas.sub(gasleft());
    }

    /**
     * @notice Complete unstake.
     *
     * @dev Message bus ensures correct execution sequence of methods and also
     *      provides safety mechanism for any possible re-entrancy attack.
     *
     * @param _messageHash Message hash.
     * @param _unlockSecret Unlock secret for the hashLock provide by the
     *                      facilitator while initiating the redeem.
     *
     * @return redeemer_ Redeemer address.
     * @return redeemAmount_ Total amount for which the redeem was
     *                       initiated. The reward amount is deducted from the
     *                       total redeem amount and is given to the
     *                       facilitator.
     * @return unstakeAmount_ Actual unstake amount, after deducting the reward
     *                        from the total redeem amount.
     * @return rewardAmount_ Reward amount that is transferred to facilitator.
     */
    function progressUnstake(
        bytes32 _messageHash,
        bytes32 _unlockSecret
    )
        external
        returns (
            uint256 redeemAmount_,
            uint256 unstakeAmount_,
            uint256 rewardAmount_
        )
    {
        // Get the inital gas.
        uint256 initialGas = gasleft();

        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );

        MessageBus.Message storage message = messages[_messageHash];

        MessageBus.progressInbox(
            messageBox,
            message,
            _unlockSecret
        );
        (redeemAmount_, unstakeAmount_, rewardAmount_) =
        progressUnstakeInternal(_messageHash, initialGas, _unlockSecret, false);

    }

    /**
     * @notice Gets the penalty amount. If the message hash does not exist in
     *         stakes mapping it will return zero amount. If the message is
     *         already progressed or revoked then the penalty amount will be
     *         zero.
     *
     * @param _messageHash Message hash.
     *
     * @return penalty_ Penalty amount.
     */
    function penalty(bytes32 _messageHash)
        external
        view
        returns (uint256 penalty_)
    {
        penalty_ = super.penaltyFromBounty(stakes[_messageHash].bounty);
    }

    /**
     * @notice Completes the redeem process by providing the merkle proof
     *         instead of unlockSecret. In case the facilitator process is not
     *         able to complete the redeem and unstake process then this is an
     *         alternative approach to complete the process
     *
     * @dev This can be called to prove that the outbox status of messageBox on
     *      CoGateway is either declared or progressed.
     *
     * @param _messageHash Message hash.
     * @param _rlpParentNodes RLP encoded parent node data to prove in
     *                        messageBox inbox of CoGateway.
     * @param _blockHeight Block number for which the proof is valid.
     * @param _messageStatus Message status i.e. Declared or Progressed that
     *                       will be proved.
     *
     * @return redeemAmount_ Total amount for which the redeem was
     *                       initiated. The reward amount is deducted from the
     *                       total redeem amount and is given to the
     *                       facilitator.
     * @return unstakeAmount_ Actual unstake amount, after deducting the reward
     *                        from the total redeem amount.
     * @return rewardAmount_ Reward amount that is transferred to facilitator.
     */
    function progressUnstakeWithProof(
        bytes32 _messageHash,
        bytes calldata _rlpParentNodes,
        uint256 _blockHeight,
        uint256 _messageStatus
    )
        external
        returns (
            uint256 redeemAmount_,
            uint256 unstakeAmount_,
            uint256 rewardAmount_
        )
    {
        // Get the initial gas.
        uint256 initialGas = gasleft();

        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );
        require(
            _rlpParentNodes.length > 0,
            "RLP parent nodes must not be zero"
        );

        // Get the storage root for the given block height.
        bytes32 storageRoot = storageRoots[_blockHeight];
        require(
            storageRoot != bytes32(0),
            "Storage root must not be zero"
        );

        MessageBus.Message storage message = messages[_messageHash];

        MessageBus.progressInboxWithProof(
            messageBox,
            message,
            _rlpParentNodes,
            MESSAGE_BOX_OFFSET,
            storageRoot,
            MessageBus.MessageStatus(_messageStatus)
        );

        (redeemAmount_, unstakeAmount_, rewardAmount_) =
        progressUnstakeInternal(_messageHash, initialGas, bytes32(0), true);
    }

    /**
     * @notice Declare redeem revert intent.
     *         This will set message status to revoked. This method will also
     *         clear unstakes mapping storage.
     *
     * @param _messageHash Message hash.
     * @param _blockHeight Block number for which the proof is valid.
     * @param _rlpParentNodes RLP encoded parent node data to prove
     *                        DeclaredRevocation in messageBox outbox of
     *                        CoGateway.
     *
     * @return redeemer_ Redeemer address.
     * @return redeemerNonce_ Redeemer nonce.
     * @return amount_ Redeem amount.
     */
    function confirmRevertRedeemIntent(
        bytes32 _messageHash,
        uint256 _blockHeight,
        bytes calldata _rlpParentNodes
    )
        external
        returns (
            address redeemer_,
            uint256 redeemerNonce_,
            uint256 amount_
        )
    {

        require(
            _messageHash != bytes32(0),
            "Message hash must not be zero."
        );
        require(
            _rlpParentNodes.length > 0,
            "RLP parent nodes must not be zero."
        );

        amount_ = unstakes[_messageHash].amount;

        require(
            amount_ > uint256(0),
            "Unstake amount must not be zero."
        );

        delete unstakes[_messageHash];

        // Get the message object.
        MessageBus.Message storage message = messages[_messageHash];
        require(
            message.intentHash != bytes32(0),
            "RevertRedeem intent hash must not be zero."
        );

        // Get the storage root
        bytes32 storageRoot = storageRoots[_blockHeight];
        require(
            storageRoot != bytes32(0),
            "Storage root must not be zero."
        );

        // Confirm revocation
        MessageBus.confirmRevocation(
            messageBox,
            message,
            _rlpParentNodes,
            MESSAGE_BOX_OFFSET,
            storageRoot
        );

        redeemer_ = message.sender;
        redeemerNonce_ = message.nonce;

        emit RevertRedeemIntentConfirmed(
            _messageHash,
            redeemer_,
            redeemerNonce_,
            amount_
        );
    }

    /**
     * @notice Activate Gateway contract. Can be set only by the
     *         Organization address only once by passing co-gateway address.
     *
     * @param _coGatewayAddress Address of cogateway.
     *
     * @return success_ `true` if value is set
     */
    function activateGateway(
            address _coGatewayAddress
    )
        external
        onlyOrganization
        returns (bool success_)
    {

        require(
            _coGatewayAddress != address(0),
            "Co-gateway address must not be zero."
        );
        require(
            remoteGateway == address(0),
            "Gateway was already activated once."
        );

        remoteGateway = _coGatewayAddress;

        // update the encodedGatewayPath
        encodedGatewayPath = BytesLib.bytes32ToBytes(
            keccak256(abi.encodePacked(remoteGateway))
        );
        activated = true;
        success_ = true;
    }

    /**
     * @notice Deactivate Gateway contract. Can be set only by the
     *         organization address
     *
     * @return success_  `true` if value is set
     */
    function deactivateGateway()
        external
        onlyOrganization
        returns (bool success_)
    {
        require(
            activated == true,
            "Gateway is already deactivated."
        );
        activated = false;
        success_ = true;
    }


    /* Private functions */

    /**
     * @notice Private function to execute confirm redeem intent.
     *
     * @dev This function is to avoid stack too deep error in
     *      confirmRedeemIntent function.
     *
     * @param _message Message object.
     * @param _blockHeight Block number for which the proof is valid.
     * @param _rlpParentNodes RLP encoded parent nodes.
     *
     * @return `true` if executed successfully.
     */
    function confirmRedeemIntentInternal(
        MessageBus.Message storage _message,
        uint256 _blockHeight,
        bytes memory _rlpParentNodes
    )
        private
        returns (bool)
    {
        // Get storage root.
        bytes32 storageRoot = storageRoots[_blockHeight];
        require(
            storageRoot != bytes32(0),
            "Storage root must not be zero."
        );

        // Confirm message.
        MessageBus.confirmMessage(
            messageBox,
            _message,
            _rlpParentNodes,
            MESSAGE_BOX_OFFSET,
            storageRoot
        );

        return true;
    }

    /**
     * @notice Private function contains logic for process stake.
     *
     * @param _messageHash Message hash.
     * @param _message Message object.
     * @param _unlockSecret For process with hash lock, proofProgress event
     *                      param is set to false otherwise set to true.
     *
     * @return staker_ Staker address
     * @return stakeAmount_ Stake amount
     */
    function progressStakeInternal(
        bytes32 _messageHash,
        MessageBus.Message storage _message,
        bytes32 _unlockSecret,
        bool _proofProgress
    )
        private
        returns (
            address staker_,
            uint256 stakeAmount_
        )
    {

        // Get the staker address
        staker_ = _message.sender;

        // Get the stake amount.
        stakeAmount_ = stakes[_messageHash].amount;

        require(
            stakeAmount_ > 0,
            "Stake request must exist."
        );

        uint256 stakedBounty = stakes[_messageHash].bounty;

        delete stakes[_messageHash];

        // Transfer the staked amount to stakeVault.
        token.transfer(address(stakeVault), stakeAmount_);

        baseToken.transfer(msg.sender, stakedBounty);

        emit StakeProgressed(
            _messageHash,
            staker_,
            _message.nonce,
            stakeAmount_,
            _proofProgress,
            _unlockSecret
        );
    }

    /**
     * @notice This is internal method for process unstake called from external
     *         methods which processUnstake(with hashlock) and
     *         processUnstakeWithProof
     *
     * @param _messageHash hash to identify message
     * @param _initialGas initial available gas during process unstake call.
     * @param _unlockSecret Block number for which the proof is valid
     * @param _proofProgress true if progress with proof and false if
     *                       progress with unlock secret.
     *
     * @return redeemAmount_ Total amount for which the redeem was
     *                       initiated. The reward amount is deducted from the
     *                       total redeem amount and is given to the
     *                       facilitator.
     * @return unstakeAmount_ Actual unstake amount, after deducting the reward
     *                        from the total redeem amount.
     * @return rewardAmount_ Reward amount that is transferred to facilitator
     */
    function progressUnstakeInternal(
        bytes32 _messageHash,
        uint256 _initialGas,
        bytes32 _unlockSecret,
        bool _proofProgress
    )
        private
        returns (
            uint256 redeemAmount_,
            uint256 unstakeAmount_,
            uint256 rewardAmount_
        )
    {

        Unstake storage unStake = unstakes[_messageHash];
        // Get the message object.
        MessageBus.Message storage message = messages[_messageHash];

        redeemAmount_ = unStake.amount;

        require(
            redeemAmount_ > 0,
            "Unstake request must exist."
        );
        /*
         * Reward calculation depends upon
         *  - the gas consumed in target chain for confirmation and progress steps.
         *  - gas price and gas limit provided in the message.
         */
        (rewardAmount_, message.gasConsumed) = feeAmount(
            message.gasConsumed,
            message.gasLimit,
            message.gasPrice,
            _initialGas
        );

        unstakeAmount_ = redeemAmount_.sub(rewardAmount_);

        address beneficiary = unstakes[_messageHash].beneficiary;

        delete unstakes[_messageHash];

        // Release the amount to beneficiary, but with reward subtracted.
        stakeVault.releaseTo(beneficiary, unstakeAmount_);

        // Reward facilitator with the reward amount.
        stakeVault.releaseTo(msg.sender, rewardAmount_);

        emit UnstakeProgressed(
            _messageHash,
            message.sender,
            beneficiary,
            redeemAmount_,
            unstakeAmount_,
            rewardAmount_,
            _proofProgress,
            _unlockSecret
        );

    }

    /**
     * @notice Private function to calculate redeem intent hash.
     *
     * @dev This function is to avoid stack too deep error in
     *      confirmRedeemIntent function.
     *
     * @param _amount Redeem amount.
     * @param _beneficiary Unstake account.
     *
     * @return bytes32 Redeem intent hash.
     */
    function hashRedeemIntent(
        uint256 _amount,
        address _beneficiary
    )
        private
        view
        returns(bytes32)
    {
        return GatewayLib.hashRedeemIntent(
            _amount,
            _beneficiary,
            remoteGateway
        );
    }

}
/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

// File: ../../mosaic-contracts/contracts/lib/CircularBufferUint.sol

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
 * @title Circular buffer for `uint`s.
 *
 * @notice This contract represents a circular buffer that stores `uint`s. When
 *         a set number of `uint`s have been stored, the storage starts
 *         overwriting older entries. It overwrites always the oldest entry in
 *         the buffer.
 */
contract CircularBufferUint {

    /* Storage */

    /**
     * The circular buffer that stores the latest `items.length` items. Once
     * `items.length` items were stored, items will be overwritten starting at
     * zero.
     */
    uint256[] private items;

    /**
     * The current index in the items array. The index increases up to
     * `items.length - 1` and then resets to zero in an endless loop. This
     * means that a new item will always overwrite the oldest item.
     */
    uint256 private index;


    /* Constructor */

    /**
     * @notice Create a new buffer with the size `_maxItems`.
     *
     * @param _maxItems Defines how many items this buffer stores before
     *                  overwriting older items.
     */
    constructor(uint256 _maxItems) public {
        require(
            _maxItems > 0,
            "The max number of items to store in a circular buffer must be greater than 0."
        );

        items.length = _maxItems;
    }


    /* Internal functions */

    /**
     * @notice Store a new item in the circular buffer.
     *
     * @param _item The item to store in the circular buffer.
     *
     * @return overwrittenItem_ The item that was in the circular buffer's
     *                          position where the new item is now stored. The
     *                          overwritten item is no longer available in the
     *                          circular buffer.
     */
    function store(uint256 _item) internal returns(uint256 overwrittenItem_) {
        nextIndex();

        /*
         * Retrieve the old item from the circular buffer before overwriting it
         * with the new item.
         */
        overwrittenItem_ = items[index];
        items[index] = _item;
    }

    /**
     * @notice Get the most recent item that was stored in the circular buffer.
     *
     * @return head_ The most recently stored item.
     */
    function head() internal view returns(uint256 head_) {
        head_ = items[index];
    }


    /* Private functions */

    /**
     * @notice Updates the index of the circular buffer to point to the next
     *         slot of where to store an item. Resets to zero if it gets to the
     *         end of the array that represents the circular.
     */
    function nextIndex() private {
        index++;
        if (index == items.length) {
            index = 0;
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

// File: ../../mosaic-contracts/contracts/anchor/Anchor.sol

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
 * @title Anchor contract which implements StateRootInterface.
 *
 * @notice Anchor stores another chain's state roots. It stores the address of
 *         the co-anchor, which will be the anchor on the other chain. State
 *         roots are exchanged bidirectionally between the anchor and the
 *         co-anchor by the organization.
 */
contract Anchor is StateRootInterface, Organized, CircularBufferUint {

    /* Usings */

    using SafeMath for uint256;


    /* Events */

    event StateRootAvailable(uint256 _blockHeight, bytes32 _stateRoot);


    /* Storage */

    /** Maps block heights to their respective state root. */
    mapping (uint256 => bytes32) private stateRoots;

    /**
     * The remote chain ID is the remote chain id where anchor contract is
     * deployed.
     */
    uint256 private remoteChainId;

    /** Address of the anchor on the auxiliary chain. Can be zero. */
    address public coAnchor;


    /*  Constructor */

    /**
     * @notice Contract constructor.
     *
     * @param _remoteChainId The chain id of the chain that is tracked by this
     *                       anchor.
     * @param _blockHeight Block height at which _stateRoot needs to store.
     * @param _stateRoot State root hash of given _blockHeight.
     * @param _maxStateRoots The max number of state roots to store in the
     *                       circular buffer.
     * @param _organization Address of an organization contract.
     */
    constructor(
        uint256 _remoteChainId,
        uint256 _blockHeight,
        bytes32 _stateRoot,
        uint256 _maxStateRoots,
        OrganizationInterface _organization
    )
        Organized(_organization)
        CircularBufferUint(_maxStateRoots)
        public
    {
        require(
            _remoteChainId != 0,
            "Remote chain Id must not be 0."
        );

        remoteChainId = _remoteChainId;

        stateRoots[_blockHeight] = _stateRoot;
        CircularBufferUint.store(_blockHeight);
    }


    /* External functions */

    /**
     *  @notice The Co-Anchor address is the address of the anchor that is
     *          deployed on the other (origin/auxiliary) chain.
     *
     *  @param _coAnchor Address of the Co-Anchor on auxiliary.
     */
    function setCoAnchorAddress(address _coAnchor)
        external
        onlyOrganization
        returns (bool success_)
    {

        require(
            _coAnchor != address(0),
            "Co-Anchor address must not be 0."
        );

        require(
            coAnchor == address(0),
            "Co-Anchor has already been set and cannot be updated."
        );

        coAnchor = _coAnchor;

        success_ = true;
    }

    /**
     * @notice Get the state root for the given block height.
     *
     * @param _blockHeight The block height for which the state root is needed.
     *
     * @return bytes32 State root of the given height.
     */
    function getStateRoot(
        uint256 _blockHeight
    )
        external
        view
        returns (bytes32 stateRoot_)
    {
        stateRoot_ = stateRoots[_blockHeight];
    }

    /**
     * @notice Gets the block height of latest anchored state root.
     *
     * @return uint256 Block height of the latest anchored state root.
     */
    function getLatestStateRootBlockHeight()
        external
        view
        returns (uint256 height_)
    {
        height_ = CircularBufferUint.head();
    }

    /**
     *  @notice External function anchorStateRoot.
     *
     *  @dev anchorStateRoot Called from game process.
     *       Anchor new state root for a block height.
     *
     *  @param _blockHeight Block height for which stateRoots mapping needs to
     *                      update.
     *  @param _stateRoot State root of input block height.
     *
     *  @return bytes32 stateRoot
     */
    function anchorStateRoot(
        uint256 _blockHeight,
        bytes32 _stateRoot
    )
        external
        onlyOrganization
        returns (bool success_)
    {
        // State root should be valid
        require(
            _stateRoot != bytes32(0),
            "State root must not be zero."
        );

        // Input block height should be valid.
        require(
            _blockHeight > CircularBufferUint.head(),
            "Given block height is lower or equal to highest anchored state root block height."
        );

        stateRoots[_blockHeight] = _stateRoot;
        uint256 oldestStoredBlockHeight = CircularBufferUint.store(_blockHeight);
        delete stateRoots[oldestStoredBlockHeight];

        emit StateRootAvailable(_blockHeight, _stateRoot);

        success_ = true;
    }

    /**
     *  @notice Get the remote chain id of this anchor.
     *
     *  @return remoteChainId_ The remote chain id.
     */
    function getRemoteChainId()
        external
        view
        returns (uint256 remoteChainId_)
    {
        remoteChainId_ = remoteChainId;
    }
}
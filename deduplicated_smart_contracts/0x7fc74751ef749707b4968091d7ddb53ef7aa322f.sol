/***********************************************************
* This file is part of the Slock.it IoT Layer.             *
* The Slock.it IoT Layer contains:                         *
*   - USN (Universal Sharing Network)                      *
*   - INCUBED (Trustless INcentivized remote Node Network) *
************************************************************
* Copyright (C) 2016 - 2018 Slock.it GmbH                  *
* All Rights Reserved.                                     *
************************************************************
* You may use, distribute and modify this code under the   *
* terms of the license contract you have concluded with    *
* Slock.it GmbH.                                           *
* For information about liability, maintenance etc. also   *
* refer to the contract concluded with Slock.it GmbH.      *
************************************************************
* For more information, please refer to https://slock.it   *
* For questions, please contact info@slock.it              *
***********************************************************/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;


/// @title Registry for blockhashes
contract BlockhashRegistry {

    /// a new blockhash and its number has been added to the contract
    event LogBlockhashAdded(uint indexed blockNr, bytes32 indexed bhash);

    /// maps the blocknumber to its blockhash
    mapping(uint => bytes32) public blockhashMapping;

    /// constructor, calls snapshot-function when contract get deployed as entry point
    /// @dev cannot be deployed in a genesis block
    constructor() public {
        snapshot();
    }

    /// @notice searches for an already existing snapshot
    /// @param _startNumber the blocknumber to start searching
    /// @param _numBlocks the number of blocks to search for
    /// @return the closes snapshot of found within the given range, 0 else
    function searchForAvailableBlock(uint _startNumber, uint _numBlocks) external view returns (uint) {
        uint target = _startNumber + _numBlocks;

        require(target <= block.number || target < _startNumber, "invalid search");

        for (uint i = _startNumber; i <= target; i++) {
            if (blockhashMapping[i] != 0x0) {
                return i;
            }
        }
    }

    /// @notice starts with a given blocknumber and its header and tries to recreate a (reverse) chain of blocks
    /// @notice only usable when the given blocknumber is already in the smart contract
    /// @notice it will be checked whether the provided chain is correct by using the reCalculateBlockheaders function
    /// @notice if successfull the last blockhash of the header will be added to the smart contract
    /// @param _blockNumber the block number to start recreation from
    /// @param _blockheaders array with serialized blockheaders in reverse order (youngest -> oldest) => (e.g. 100, 99, 98)
    /// @dev reverts when there is not parent block already stored in the contract
    /// @dev reverts when the chain of headers is incorrect
    /// @dev function is public due to the usage of a dynamic bytes array (not yet supported for external functions)
    function recreateBlockheaders(uint _blockNumber, bytes[] memory _blockheaders) public {
        /// we should never fail this assert, as this would mean that we were able to recreate a invalid blockchain
        require(_blockNumber > _blockheaders.length, "too many blockheaders provided");
        require(_blockNumber < block.number, "cannot recreate a not yet existing block");

        require(_blockheaders.length > 0, "no blockheaders provided");

        uint bnr = _blockNumber - _blockheaders.length;
        require(blockhashMapping[bnr] == 0x0, "block already stored");

        bytes32 currentBlockhash = blockhashMapping[_blockNumber];
        require(currentBlockhash != 0x0, "parentBlock is not available");

        /// if the blocknumber we want to store is within the last 256 blocks, we use the evm hash
        if (bnr > block.number-256) {
            saveBlockNumber(bnr);
            return;
        }

        bytes32 calculatedHash = reCalculateBlockheaders(_blockheaders, currentBlockhash, _blockNumber);
        require(calculatedHash != 0x0, "invalid headers");

        blockhashMapping[bnr] = calculatedHash;
        emit LogBlockhashAdded(bnr, calculatedHash);
    }

    /// @notice stores a certain blockhash to the state
    /// @param _blockNumber the blocknumber to be stored
    /// @dev reverts if the block can't be found inside the evm
    function saveBlockNumber(uint _blockNumber) public {

        require(blockhashMapping[_blockNumber] == 0x0, "block already stored");

        bytes32 bHash = blockhash(_blockNumber);

        require(bHash != 0x0, "block not available");

        blockhashMapping[_blockNumber] = bHash;
        emit LogBlockhashAdded(_blockNumber, bHash);
    }

    /// @notice stores the currentBlock-1 in the smart contract
    function snapshot() public {
        /// blockhash cannot return the current block, so we use the previous block
        saveBlockNumber(block.number-1);
    }

    /// @notice returns the value from rlp encoded data.
    ///         This function is limited to only value up to 32 bytes length!
    /// @param _data rlp encoded data
    /// @param _offset the offset
    /// @return the value
    function getRlpUint(bytes memory _data, uint _offset) public pure returns (uint value) {
        /// get the byte at offset to figure out the length of the value
        uint8 c = uint8(_data[_offset]);

        /// we will not accept values above 0xa0, since this would mean we either have a list
        /// or we have a value with a length greater 32 bytes
        /// for the use cases (getting the blockNumber or difficulty) we can accept these limits.
        require(c < 0xa1, "lists or long fields are not supported");
        if (c < 0x80)  // single byte-item
            return uint(c); // value = byte

        // length of the value
        uint len = c - 0x80;
        // we skip the first 32 bytes since they contain the legth and add 1 because this byte contains the length of the value.
        uint dataOffset = _offset + 33;

        /// check the range
        require(_offset + len <= _data.length, "invalid offset");

        /// we are using assembly because we need to get the value of the next `len` bytes
        /// This is done by copying the bytes in the "scratch space" so we can take the first 32 bytes as value afterwards.
        // solium-disable-next-line security/no-inline-assembly
        assembly { // solhint-disable-line no-inline-assembly
            mstore(0x0, 0) // clean memory in the "scratch space"
            mstore(
                sub (0x20, len), // we move the position so the first bytes from rlp are the last bytes within the 32 bytes
                mload(
                    add ( _data, dataOffset ) // load the data from rlp-data
                )
            )
            value:=mload(0x0)
        }
        return value;
    }

    /// @notice returns the blockhash and the parent blockhash from the provided blockheader
    /// @param _blockheader a serialized (rlp-encoded) blockheader
    /// @return the parent blockhash and the keccak256 of the provided blockheader (= the corresponding blockhash)
    function getParentAndBlockhash(bytes memory _blockheader) public pure returns (bytes32 parentHash, bytes32 bhash, uint blockNumber) {

        /// we need the 1st byte of the blockheader to calculate the position of the parentHash
        uint8 first = uint8(_blockheader[0]);

        /// calculates the offset
        /// by using the 1st byte (usually f9) and substracting f7 to get the start point of the parentHash information
        require(first > 0xf7, "invalid offset");

        /// we also have to add "2" = 1 byte to it to skip the length-information
        uint offset = first - 0xf7 + 2;
        require(offset+32 < _blockheader.length, "invalid length");

        /// we are using assembly because it's the most efficent way to access the parent blockhash within the rlp-encoded blockheader
        // solium-disable-next-line security/no-inline-assembly
        assembly { // solhint-disable-line no-inline-assembly
            // we load the provided blockheader
            // then we add 0x20 (32 bytes) to get to the start of the blockheader
            // then we add the offset we calculated
            // and load it to the parentHash variable
            parentHash :=mload(
                add(
                    add(
                        _blockheader, 0x20
                    ), offset)
            )
        }

        // verify parentHash
        require(parentHash != 0x0, "invalid parentHash");
        bhash = keccak256(_blockheader);

        // get the blockNumber
        // we set the offset to the difficulty field which is fixed since all fields between them have a fixed length.
        offset += 444;

        // we get the first byte for the difficulty field ( which is a field with a dynamic length)
        // and calculate the length, because the next field is the blockNumber
        uint8 c = uint8(_blockheader[offset]);
        require(c < 0xa1, "lists or long fields are not supported for difficulty");
        offset += c < 0x80 ? 1 : (c - 0x80 + 1);

        // we fetch the blockNumber from the calculated offset
        blockNumber = getRlpUint(_blockheader, offset);
    }

    /// @notice starts with a given blockhash and its header and tries to recreate a (reverse) chain of blocks
    /// @notice the array of the blockheaders have to be in reverse order (e.g. [100,99,98,97])
    /// @param _blockheaders array with serialized blockheaders in reverse order, i.e. from youngest to oldest
    /// @param _bHash blockhash of the 1st element of the _blockheaders-array
    /// @param _blockNumber blocknumber of the 1st element of the _blockheaders-array. This is only needed to verify the blockheader
    /// @return 0x0 if the functions detects a wrong chaining of blocks, blockhash of the last element of the array otherwhise
    function reCalculateBlockheaders(bytes[] memory _blockheaders, bytes32 _bHash, uint _blockNumber) public view returns (bytes32 bhash) {

        require(_blockheaders.length > 0, "no blockheaders provided");
        require(_bHash != 0x0, "invalid blockhash provided");
        bytes32 currentBlockhash = _bHash;
        bytes32 calcParent = 0x0;
        bytes32 calcBlockhash = 0x0;
        uint calcBlockNumber = 0;
        uint currentBlockNumber = _blockNumber;

        /// save to use for up to 200 blocks, exponential increase of gas-usage afterwards
        for (uint i = 0; i < _blockheaders.length; i++) {
            /// we alway need to verify the blockHash and parentHash
            /// but in addition we also verify the blockNumber.
            /// This is just safety-check in case of detected hash collision which makes it almost impossible
            /// to add an invalid header which might create the correct hash.
            (calcParent, calcBlockhash, calcBlockNumber) = getParentAndBlockhash(_blockheaders[i]);
            if (calcBlockhash != currentBlockhash || calcParent == 0x0 || calcBlockNumber != currentBlockNumber) {
                return 0x0;
            }

            uint currentBlock = block.number > 256 ? block.number : 256;

            if (currentBlock - 256 < calcBlockNumber) {
                if (calcBlockhash != blockhash(calcBlockNumber)) {
                    return 0x0;
                }
            }
            currentBlockhash = calcParent;
            currentBlockNumber--;
        }

        return currentBlockhash;
    }
}
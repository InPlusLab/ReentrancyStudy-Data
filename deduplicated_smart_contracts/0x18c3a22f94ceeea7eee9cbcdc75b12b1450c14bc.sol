/**

 *Submitted for verification at Etherscan.io on 2018-10-26

*/



pragma solidity ^0.4.13;



library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract ERC721Basic {

  event Transfer(

    address indexed _from,

    address indexed _to,

    uint256 _tokenId

  );

  event Approval(

    address indexed _owner,

    address indexed _approved,

    uint256 _tokenId

  );

  event ApprovalForAll(

    address indexed _owner,

    address indexed _operator,

    bool _approved

  );



  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);



  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId)

    public view returns (address _operator);



  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator)

    public view returns (bool);



  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId)

    public;



  function safeTransferFrom(

    address _from,

    address _to,

    uint256 _tokenId,

    bytes _data

  )

    public;

}



contract ERC721Enumerable is ERC721Basic {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(

    address _owner,

    uint256 _index

  )

    public

    view

    returns (uint256 _tokenId);



  function tokenByIndex(uint256 _index) public view returns (uint256);

}



contract ERC721Metadata is ERC721Basic {

  function name() public view returns (string _name);

  function symbol() public view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}



contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}



contract ERC721Receiver {

  /**

   * @dev Magic value to be returned upon successful reception of an NFT

   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,

   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`

   */

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;



  /**

   * @notice Handle the receipt of an NFT

   * @dev The ERC721 smart contract calls this function on the recipient

   *  after a `safetransfer`. This function MAY throw to revert and reject the

   *  transfer. This function MUST use 50,000 gas or less. Return of other

   *  than the magic value MUST result in the transaction being reverted.

   *  Note: the contract address is always the message sender.

   * @param _from The sending address

   * @param _tokenId The NFT identifier which is being transfered

   * @param _data Additional data with no specified format

   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`

   */

  function onERC721Received(

    address _from,

    uint256 _tokenId,

    bytes _data

  )

    public

    returns(bytes4);

}



library ChallengeLib {

    struct Challenge {

        address owner;

        address challenger;

        bytes32 txHash;

        uint256 challengingBlockNumber;

    }



    function contains(Challenge[] storage _array, bytes32 txHash) internal view returns (bool) {

        int index = indexOf(_array, txHash);

        return index != -1;

    }



    function remove(Challenge[] storage _array, bytes32 txHash) internal returns (bool) {

        int index = indexOf(_array, txHash);

        if (index == -1) {

            return false; // Tx not in challenge arraey

        }

        // Replace element with last element

        Challenge memory lastChallenge = _array[_array.length - 1];

        _array[uint(index)] = lastChallenge;



        // Reduce array length

        delete _array[_array.length - 1];

        _array.length -= 1;

        return true;

    }



    function indexOf(Challenge[] storage _array, bytes32 txHash) internal view returns (int) {

        for (uint i = 0; i < _array.length; i++) {

            if (_array[i].txHash == txHash) {

                return int(i);

            }

        }

        return -1;

    }

}



library ECVerify {



    enum SignatureMode {

        EIP712,

        GETH,

        TREZOR

    }



    function recover(bytes32 hash, bytes signature) internal pure returns (address) {

        require(signature.length == 66);

        SignatureMode mode = SignatureMode(uint8(signature[0]));



        uint8 v;

        bytes32 r;

        bytes32 s;

        assembly {

            r := mload(add(signature, 33))

            s := mload(add(signature, 65))

            v := and(mload(add(signature, 66)), 255)

        }



        if (mode == SignatureMode.GETH) {

            hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

        } else if (mode == SignatureMode.TREZOR) {

            hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));

        }



        return ecrecover(

            hash,

            v,

            r,

            s);

    }



    function ecverify(bytes32 hash, bytes sig, address signer) internal pure returns (bool) {

        return signer == recover(hash, sig);

    }



}



contract ERC20Receiver {

    /**

     * @dev Magic value to be returned upon successful reception of an amount of ERC20 tokens

     *  Equals to `bytes4(keccak256("onERC20Received(address,uint256,bytes)"))`,

     *  which can be also obtained as `ERC20Receiver(0).onERC20Received.selector`

     */

    bytes4 constant ERC20_RECEIVED = 0x65d83056;



    function onERC20Received(address _from, uint256 amount, bytes data) public returns(bytes4);



}



library RLP {

    uint constant DATA_SHORT_START = 0x80;

    uint constant DATA_LONG_START = 0xB8;

    uint constant LIST_SHORT_START = 0xC0;

    uint constant LIST_LONG_START = 0xF8;



    uint constant DATA_LONG_OFFSET = 0xB7;





    struct RLPItem {

        uint _unsafeMemPtr;    // Pointer to the RLP-encoded bytes.

        uint _unsafeLength;    // Number of bytes. This is the full length of the string.

    }



    struct Iterator {

        RLPItem _unsafeItem;   // Item that's being iterated over.

        uint _unsafeNextPtr;   // Position of the next item in the list.

    }



    /* RLPItem */



    /// @dev Creates an RLPItem from an array of RLP encoded bytes.

    /// @param self The RLP encoded bytes.

    /// @return An RLPItem

    function toRLPItem(bytes memory self) internal pure returns (RLPItem memory) {

        uint len = self.length;

        uint memPtr;

        assembly {

            memPtr := add(self, 0x20)

        }

        return RLPItem(memPtr, len);

    }



    /// @dev Get the list of sub-items from an RLP encoded list.

    /// Warning: This requires passing in the number of items.

    /// @param self The RLP item.

    /// @return Array of RLPItems.

    function toList(RLPItem memory self, uint256 numItems) internal pure returns (RLPItem[] memory list) {

        list = new RLPItem[](numItems);

        Iterator memory it = iterator(self);

        uint idx;

        while (idx < numItems) {

            list[idx] = next(it);

            idx++;

        }

    }



    /// @dev Decode an RLPItem into a uint. This will not work if the

    /// RLPItem is a list.

    /// @param self The RLPItem.

    /// @return The decoded string.

    function toUint(RLPItem memory self) internal pure returns (uint data) {

        (uint rStartPos, uint len) = _decode(self);

        assembly {

            data := div(mload(rStartPos), exp(256, sub(32, len)))

        }

    }



    /// @dev Decode an RLPItem into an address. This will not work if the

    /// RLPItem is a list.

    /// @param self The RLPItem.

    /// @return The decoded string.

    function toAddress(RLPItem memory self)

        internal

        pure

        returns (address data)

    {

        (uint rStartPos,) = _decode(self);

        assembly {

            data := div(mload(rStartPos), exp(256, 12))

        }

    }



    /// @dev Create an iterator.

    /// @param self The RLP item.

    /// @return An 'Iterator' over the item.

    function iterator(RLPItem memory self) private pure returns (Iterator memory it) {

        uint ptr = self._unsafeMemPtr + _payloadOffset(self);

        it._unsafeItem = self;

        it._unsafeNextPtr = ptr;

    }



    /* Iterator */

    function next(Iterator memory self) private pure returns (RLPItem memory subItem) {

        uint ptr = self._unsafeNextPtr;

        uint itemLength = _itemLength(ptr);

        subItem._unsafeMemPtr = ptr;

        subItem._unsafeLength = itemLength;

        self._unsafeNextPtr = ptr + itemLength;

    }



    function hasNext(Iterator memory self) private pure returns (bool) {

        RLPItem memory item = self._unsafeItem;

        return self._unsafeNextPtr < item._unsafeMemPtr + item._unsafeLength;

    }



    // Get the payload offset.

    function _payloadOffset(RLPItem memory self)

        private

        pure

        returns (uint)

    {

        uint b0;

        uint memPtr = self._unsafeMemPtr;

        assembly {

            b0 := byte(0, mload(memPtr))

        }

        if (b0 < DATA_SHORT_START)

            return 0;

        if (b0 < DATA_LONG_START || (b0 >= LIST_SHORT_START && b0 < LIST_LONG_START))

            return 1;

    }



    // Get the full length of an RLP item.

    function _itemLength(uint memPtr)

        private

        pure

        returns (uint len)

    {

        uint b0;

        assembly {

            b0 := byte(0, mload(memPtr))

        }

        if (b0 < DATA_SHORT_START)

            len = 1;

        else if (b0 < DATA_LONG_START)

            len = b0 - DATA_SHORT_START + 1;

    }



    // Get start position and length of the data.

    function _decode(RLPItem memory self)

        private

        pure

        returns (uint memPtr, uint len)

    {

        uint b0;

        uint start = self._unsafeMemPtr;

        assembly {

            b0 := byte(0, mload(start))

        }

        if (b0 < DATA_SHORT_START) {

            memPtr = start;

            len = 1;

            return;

        }

        if (b0 < DATA_LONG_START) {

            len = self._unsafeLength - 1;

            memPtr = start + 1;

        } else {

            uint bLen;

            assembly {

                bLen := sub(b0, 0xB7) // DATA_LONG_OFFSET

            }

            len = self._unsafeLength - 1 - bLen;

            memPtr = start + bLen + 1;

        }

        return;

    }



    /// @dev Return the RLP encoded bytes.

    /// @param self The RLPItem.

    /// @return The bytes.

    function toBytes(RLPItem memory self)

        internal

        pure

        returns (bytes memory bts)

    {

        uint len = self._unsafeLength;

        if (len == 0)

            return;

        bts = new bytes(len);

        _copyToBytes(self._unsafeMemPtr, bts, len);

    }



    // Assumes that enough memory has been allocated to store in target.

    function _copyToBytes(uint btsPtr, bytes memory tgt, uint btsLen)

        private

        pure

    {

        // Exploiting the fact that 'tgt' was the last thing to be allocated,

        // we can write entire words, and just overwrite any excess.

        assembly {

            {

                // evm operations on words

                let words := div(add(btsLen, 31), 32)

                let rOffset := btsPtr

                let wOffset := add(tgt, 0x20)

                for

                    { let i := 0 } // start at arr + 0x20 -> first byte corresponds to length

                    lt(i, words)

                    { i := add(i, 1) }

                {

                    let offset := mul(i, 0x20)

                    mstore(add(wOffset, offset), mload(add(rOffset, offset)))

                }

                mstore(add(tgt, add(0x20, mload(tgt))), 0)

            }

        }



    }



}



contract RootChain is ERC721Receiver, ERC20Receiver {



    /**

     * Event for coin deposit logging.

     * @notice The Deposit event indicates that a deposit block has been added

     *         to the Plasma chain

     * @param slot Plasma slot, a unique identifier, assigned to the deposit

     * @param blockNumber The index of the block in which a deposit transaction

     *                    is included

     * @param denomination Quantity of a particular coin deposited

     * @param from The address of the depositor

     * @param contractAddress The address of the contract making the deposit

     */

    event Deposit(uint64 indexed slot, uint256 blockNumber, uint256 denomination, 

                  address indexed from, address indexed contractAddress);



    /**

     * Event for block submission logging

     * @notice The event indicates the addition of a new Plasma block

     * @param blockNumber The block number of the submitted block

     * @param root The root hash of the Merkle tree containing all of a block's

     *             transactions.

     * @param timestamp The time when a block was added to the Plasma chain

     */

    event SubmittedBlock(uint256 blockNumber, bytes32 root, uint256 timestamp);



    /**

     * Event for logging exit starts

     * @param slot The slot of the coin being exited

     * @param owner The user who claims to own the coin being exited

     */

    event StartedExit(uint64 indexed slot, address indexed owner);



    /**

     * Event for exit challenge logging

     * @notice This event only fires if `challengeBefore` is called.

     * @param slot The slot of the coin whose exit was challenged

     * @param txHash The hash of the tx used for the challenge

     */

    event ChallengedExit(uint64 indexed slot, bytes32 txHash, uint256 challengingBlockNumber);



    /**

     * Event for exit response logging

     * @notice This only logs responses to `challengeBefore`

     * @param slot The slot of the coin whose challenge was responded to

     */

    event RespondedExitChallenge(uint64 indexed slot);



    /**

     * Event for logging when an exit was successfully challenged

     * @param slot The slot of the coin being reset to DEPOSITED

     * @param owner The owner of the coin

     */

    event CoinReset(uint64 indexed slot, address indexed owner);



    /**

     * Event for exit finalization logging

     * @param slot The slot of the coin whose exit has been finalized

     * @param owner The owner of the coin whose exit has been finalized

     */

    event FinalizedExit(uint64 indexed slot, address owner);



    /**

     * Event to log the freeing of a bond

     * @param from The address of the user whose bonds have been freed

     * @param amount The bond amount which can now be withdrawn

     */

    event FreedBond(address indexed from, uint256 amount);



    /**

     * Event to log the slashing of a bond

     * @param from The address of the user whose bonds have been slashed

     * @param to The recipient of the slashed bonds

     * @param amount The bound amount which has been forfeited

     */

    event SlashedBond(address indexed from, address indexed to, uint256 amount);



    /**

     * Event to log the withdrawal of a bond

     * @param from The address of the user who withdrew bonds

     * @param amount The bond amount which has been withdrawn

     */

    event WithdrewBonds(address indexed from, uint256 amount);



    /**

     * Event to log the withdrawal of a coin

     * @param owner The address of the user who withdrew bonds

     * @param slot the slot of the coin that was exited

     * @param mode The type of coin that is being withdrawn (ERC20/ERC721/ETH)

     * @param contractAddress The contract address where the coin is being withdrawn from

              is same as `from` when withdrawing a ETH coin

     * @param uid The uid of the coin being withdrawn if ERC721, else 0

     * @param denomination The denomination of the coin which has been withdrawn (=1 for ERC721)

     */

    event Withdrew(address indexed owner, uint64 indexed slot, Mode mode, address contractAddress, uint uid, uint denomination);



    using SafeMath for uint256;

    using Transaction for bytes;

    using ECVerify for bytes32;

    using ChallengeLib for ChallengeLib.Challenge[];



    uint256 constant BOND_AMOUNT = 0.1 ether;

    // An exit can be finalized after it has matured,

    // after T2 = T0 + MATURITY_PERIOD

    // An exit can be challenged in the first window

    // between T0 and T1 ( T1 = T0 + CHALLENGE_WINDOW)

    // A challenge can be responded to in the second window

    // between T1 and T2

    uint256 constant MATURITY_PERIOD = 7 days;

    uint256 constant CHALLENGE_WINDOW = 3 days + 12 hours;



    /*

     * Modifiers

     */

    modifier isValidator() {

        require(vmc.checkValidator(msg.sender));

        _;

    }



    modifier isTokenApproved(address _address) {

        require(vmc.allowedTokens(_address));

        _;

    }



    modifier isBonded() {

        require(msg.value == BOND_AMOUNT);



        // Save challenger's bond

        balances[msg.sender].bonded = balances[msg.sender].bonded.add(msg.value);

        _;

    }



    modifier isState(uint64 slot, State state) {

        require(coins[slot].state == state, "Wrong state");

        _;

    }



    modifier cleanupExit(uint64 slot) {

        _;

        delete coins[slot].exit;

        delete exitSlots[getExitIndex(slot)];

    }



    struct Balance {

        uint256 bonded;

        uint256 withdrawable;

    }

    mapping (address => Balance) public balances;



    // exits

    uint64[] public exitSlots;

    // Each exit can only be challenged by a single challenger at a time

    struct Exit {

        address prevOwner; // previous owner of coin

        address owner;

        uint256 createdAt;

        uint256 bond;

        uint256 prevBlock;

        uint256 exitBlock;

    }

    enum State {

        DEPOSITED,

        EXITING,

        EXITED

    }



    // Track owners of txs that are pending a response

    struct Challenge {

        address owner;

        uint256 blockNumber;

    }

    mapping (uint64 => ChallengeLib.Challenge[]) challenges;



    // tracking of NFTs deposited in each slot

    enum Mode {

        ETH,

        ERC20,

        ERC721

    }

    uint64 public numCoins = 0;

    mapping (uint64 => Coin) coins;

    struct Coin {

        Mode mode;

        State state;

        address owner; // who owns that nft

        address contractAddress; // which contract does the coin belong to

        Exit exit;

        uint256 uid; 

        uint256 denomination;

        uint256 depositBlock;

    }



    // child chain

    uint256 public childBlockInterval = 1000;

    uint256 public currentBlock = 0;

    struct ChildBlock {

        bytes32 root;

        uint256 createdAt;

    }



    mapping(uint256 => ChildBlock) public childChain;

    ValidatorManagerContract vmc;

    SparseMerkleTree smt;



    constructor (ValidatorManagerContract _vmc) public {

        vmc = _vmc;

        smt = new SparseMerkleTree();

    }





    /// @dev called by a Validator to append a Plasma block to the Plasma chain

    /// @param root The transaction root hash of the Plasma block being added

    function submitBlock(bytes32 root)

        public

        isValidator

    {

        // rounding to next whole `childBlockInterval`

        currentBlock = currentBlock.add(childBlockInterval)

            .div(childBlockInterval)

            .mul(childBlockInterval);



        childChain[currentBlock] = ChildBlock({

            root: root,

            createdAt: block.timestamp

        });



        emit SubmittedBlock(currentBlock, root, block.timestamp);

    }



    /// @dev Allows anyone to deposit funds into the Plasma chain, called when

    //       contract receives ERC721

    /// @notice Appends a deposit block to the Plasma chain

    /// @param from The address of the user who is depositing a coin

    /// @param uid The uid of the ERC721 coin being deposited. This is an

    ///            identifier allocated by the ERC721 token contract; it is not

    ///            related to `slot`. If the coin is ETH or ERC20 the uid is 0

    /// @param denomination The quantity of a particular coin being deposited

    /// @param mode The type of coin that is being deposited (ETH/ERC721/ERC20)

    function deposit(

        address from, 

        address contractAddress,

        uint256 uid, 

        uint256 denomination, 

        Mode mode

    )

        private

    {

        currentBlock = currentBlock.add(1);

        uint64 slot = uint64(bytes8(keccak256(abi.encodePacked(numCoins, msg.sender, from))));



        // Update state. Leave `exit` empty

        Coin storage coin = coins[slot];

        coin.uid = uid;

        coin.contractAddress = contractAddress;

        coin.denomination = denomination;

        coin.depositBlock = currentBlock;

        coin.owner = from;

        coin.state = State.DEPOSITED;

        coin.mode = mode;



        childChain[currentBlock] = ChildBlock({

            // save signed transaction hash as root

            // hash for deposit transactions is the hash of its slot

            root: keccak256(abi.encodePacked(slot)),

            createdAt: block.timestamp

        });



        // create a utxo at `slot`

        emit Deposit(

            slot,

            currentBlock,

            denomination,

            from,

            contractAddress

        );



        numCoins += 1;

    }



    /******************** EXIT RELATED ********************/



    function startExit(

        uint64 slot,

        bytes prevTxBytes, bytes exitingTxBytes,

        bytes prevTxInclusionProof, bytes exitingTxInclusionProof,

        bytes signature,

        uint256[2] blocks)

        external

        payable isBonded

        isState(slot, State.DEPOSITED)

    {

        require(msg.sender == exitingTxBytes.getOwner());

        doInclusionChecks(

            prevTxBytes, exitingTxBytes,

            prevTxInclusionProof, exitingTxInclusionProof,

            signature,

            blocks

        );

        pushExit(slot, prevTxBytes.getOwner(), blocks);

    }



    /// @dev Verifies that consecutive two transaction involving the same coin

    ///      are valid

    /// @notice If exitingTxBytes corresponds to a deposit transaction,

    ///         prevTxBytes cannot have a meaningul value and thus it is ignored.

    /// @param prevTxBytes The RLP-encoded transaction involving a particular

    ///        coin which took place directly before exitingTxBytes

    /// @param exitingTxBytes The RLP-encoded transaction involving a particular

    ///        coin which an exiting owner of the coin claims to be the latest

    /// @param prevTxInclusionProof An inclusion proof of prevTx

    /// @param exitingTxInclusionProof An inclusion proof of exitingTx

    /// @param signature The signature of the exitingTxBytes by the coin

    ///        owner indicated in prevTx

    /// @param blocks An array of two block numbers, at index 0, the block

    ///        containing the prevTx and at index 1, the block containing

    ///        the exitingTx

    function doInclusionChecks(

        bytes prevTxBytes, bytes exitingTxBytes,

        bytes prevTxInclusionProof, bytes exitingTxInclusionProof,

        bytes signature,

        uint256[2] blocks)

        private

        view

    {

        if (blocks[1] % childBlockInterval != 0) {

            checkIncludedAndSigned(

                exitingTxBytes,

                exitingTxInclusionProof,

                signature,

                blocks[1]

            );

        } else {

            checkBothIncludedAndSigned(

                prevTxBytes, exitingTxBytes, prevTxInclusionProof,

                exitingTxInclusionProof, signature,

                blocks

            );

        }

    }



    // Needed to bypass stack limit errors

    function pushExit(

        uint64 slot,

        address prevOwner,

        uint256[2] blocks)

        private

    {

        // Push exit to list

        exitSlots.push(slot);



        // Create exit

        Coin storage c = coins[slot];

        c.exit = Exit({

            prevOwner: prevOwner,

            owner: msg.sender,

            createdAt: block.timestamp,

            bond: msg.value,

            prevBlock: blocks[0],

            exitBlock: blocks[1]

        });



        // Update coin state

        c.state = State.EXITING;

        emit StartedExit(slot, msg.sender);

    }



    /// @dev Finalizes an exit, i.e. puts the exiting coin into the EXITED

    ///      state which will allow it to be withdrawn, provided the exit has

    ///      matured and has not been successfully challenged

    function finalizeExit(uint64 slot) public {

        Coin storage coin = coins[slot];



        // If a coin is not under exit/challenge, then ignore it

        if (coin.state != State.EXITING)

            return;



        // If an exit is not matured, ignore it

        if ((block.timestamp - coin.exit.createdAt) <= MATURITY_PERIOD)

            return;



        // Check if there are any pending challenges for the coin.

        // `checkPendingChallenges` will also penalize

        // for each challenge that has not been responded to

        bool hasChallenges = checkPendingChallenges(slot);



        if (!hasChallenges) {

            // Update coin's owner

            coin.owner = coin.exit.owner;

            coin.state = State.EXITED;



            // Allow the exitor to withdraw their bond

            freeBond(coin.owner);



            emit FinalizedExit(slot, coin.owner);

        } else {

            // Reset coin state since it was challenged

            coin.state = State.DEPOSITED;

            emit CoinReset(slot, coin.owner);

        }



        delete coins[slot].exit;

        delete exitSlots[getExitIndex(slot)];

    }



    function checkPendingChallenges(uint64 slot) private returns (bool hasChallenges) {

        uint256 length = challenges[slot].length;

        bool slashed;

        for (uint i = 0; i < length; i++) {

            if (challenges[slot][i].txHash != 0x0) {

                // Penalize the exitor and reward the first valid challenger. 

                if (!slashed) {

                    slashBond(coins[slot].exit.owner, challenges[slot][i].challenger);

                    slashed = true;

                }

                // Also free the bond of the challenger.

                freeBond(challenges[slot][i].challenger);



                // Challenge resolved, delete it

                delete challenges[slot][i];

                hasChallenges = true;

            }

        }

    }



    /// @dev Iterates through all of the initiated exits and finalizes those

    ///      which have matured without being successfully challenged

    function finalizeExits() external {

        uint256 exitSlotsLength = exitSlots.length;

        for (uint256 i = 0; i < exitSlotsLength; i++) {

            finalizeExit(exitSlots[i]);

        }

    }



    /// @dev Withdraw a UTXO that has been exited

    /// @param slot The slot of the coin being withdrawn

    function withdraw(uint64 slot) external isState(slot, State.EXITED) {

        require(coins[slot].owner == msg.sender, "You do not own that UTXO");

        uint256 uid = coins[slot].uid;

        uint256 denomination = coins[slot].denomination;



        // Delete the coin that is being withdrawn

        Coin memory c = coins[slot];

        delete coins[slot];

        if (c.mode == Mode.ETH) {

            msg.sender.transfer(denomination);

        } else if (c.mode == Mode.ERC20) {

            require(ERC20(c.contractAddress).transfer(msg.sender, denomination), "transfer failed");

        } else if (c.mode == Mode.ERC721) {

            ERC721(c.contractAddress).safeTransferFrom(address(this), msg.sender, uid);

        } else {

            revert("Invalid coin mode");

        }



        emit Withdrew(

            msg.sender,

            slot,

            c.mode,

            c.contractAddress,

            uid,

            denomination

        );

    }



    /******************** CHALLENGES ********************/



    /// @dev Submits proof of a transaction before prevTx as an exit challenge

    /// @notice Exitor has to call respondChallengeBefore and submit a

    ///         transaction before prevTx or prevTx itself.

    /// @param slot The slot corresponding to the coin whose exit is being challenged

    /// @param prevTxBytes The RLP-encoded transaction involving a particular

    ///        coin which took place directly before exitingTxBytes

    /// @param txBytes The RLP-encoded transaction involving a particular

    ///        coin which an exiting owner of the coin claims to be the latest

    /// @param prevTxInclusionProof An inclusion proof of prevTx

    /// @param txInclusionProof An inclusion proof of exitingTx

    /// @param signature The signature of the txBytes by the coin

    ///        owner indicated in prevTx

    /// @param blocks An array of two block numbers, at index 0, the block

    ///        containing the prevTx and at index 1, the block containing

    ///        the exitingTx

    function challengeBefore(

        uint64 slot,

        bytes prevTxBytes, bytes txBytes,

        bytes prevTxInclusionProof, bytes txInclusionProof,

        bytes signature,

        uint256[2] blocks)

        external

        payable isBonded

        isState(slot, State.EXITING)

    {

        doInclusionChecks(

            prevTxBytes, txBytes,

            prevTxInclusionProof, txInclusionProof,

            signature,

            blocks

        );

        setChallenged(slot, txBytes.getOwner(), blocks[1], txBytes.getHash());

    }



    /// @dev Submits proof of a later transaction that corresponds to a challenge

    /// @notice Can only be called in the second window of the exit period.

    /// @param slot The slot corresponding to the coin whose exit is being challenged

    /// @param challengingTxHash The hash of the transaction

    ///        corresponding to the challenge we're responding to

    /// @param respondingBlockNumber The block number which included the transaction

    ///        we are responding with

    /// @param respondingTransaction The RLP-encoded transaction involving a particular

    ///        coin which took place directly after challengingTransaction

    /// @param proof An inclusion proof of respondingTransaction

    /// @param signature The signature which proves a direct spend from the challenger

    function respondChallengeBefore(

        uint64 slot,

        bytes32 challengingTxHash,

        uint256 respondingBlockNumber,

        bytes respondingTransaction,

        bytes proof,

        bytes signature)

        external

    {

        // Check that the transaction being challenged exists

        require(challenges[slot].contains(challengingTxHash), "Responding to non existing challenge");



        // Get index of challenge in the challenges array

        uint256 index = uint256(challenges[slot].indexOf(challengingTxHash));



        checkResponse(slot, index, respondingBlockNumber, respondingTransaction, signature, proof);



        // If the exit was actually challenged and responded, penalize the challenger and award the responder

        slashBond(challenges[slot][index].challenger, msg.sender);



        // Put coin back to the exiting state

        coins[slot].state = State.EXITING;



        challenges[slot].remove(challengingTxHash);

        emit RespondedExitChallenge(slot);

    }



    function checkResponse(

        uint64 slot,

        uint256 index,

        uint256 blockNumber,

        bytes txBytes,

        bytes signature,

        bytes proof

    )

        private

        view

    {

        Transaction.TX memory txData = txBytes.getTx();

        require(txData.hash.ecverify(signature, challenges[slot][index].owner), "Invalid signature");

        require(txData.slot == slot, "Tx is referencing another slot");

        require(blockNumber > challenges[slot][index].challengingBlockNumber);

        checkTxIncluded(txData.slot, txData.hash, blockNumber, proof);

    }



    function challengeBetween(

        uint64 slot,

        uint256 challengingBlockNumber,

        bytes challengingTransaction,

        bytes proof,

        bytes signature)

        external isState(slot, State.EXITING) cleanupExit(slot)

    {

        checkBetween(slot, challengingTransaction, challengingBlockNumber, signature, proof);

        applyPenalties(slot);

    }



    function challengeAfter(

        uint64 slot,

        uint256 challengingBlockNumber,

        bytes challengingTransaction,

        bytes proof,

        bytes signature)

        external

        isState(slot, State.EXITING)

        cleanupExit(slot)

    {

        checkAfter(slot, challengingTransaction, challengingBlockNumber, signature, proof);

        applyPenalties(slot);

    }





    // Must challenge with a tx in between



    // Check that the challenging transaction has been signed

    // by the attested previous owner of the coin in the exit

    function checkBetween(

        uint64 slot,

        bytes txBytes,

        uint blockNumber, 

        bytes signature, 

        bytes proof

    ) 

        private 

        view 

    {

        require(

            coins[slot].exit.exitBlock > blockNumber &&

            coins[slot].exit.prevBlock < blockNumber,

            "Tx should be between the exit's blocks"

        );



        Transaction.TX memory txData = txBytes.getTx();

        require(txData.hash.ecverify(signature, coins[slot].exit.prevOwner), "Invalid signature");

        require(txData.slot == slot, "Tx is referencing another slot");

        checkTxIncluded(slot, txData.hash, blockNumber, proof);

    }



    function checkAfter(uint64 slot, bytes txBytes, uint blockNumber, bytes signature, bytes proof) private view {

        Transaction.TX memory txData = txBytes.getTx();

        require(txData.hash.ecverify(signature, coins[slot].exit.owner), "Invalid signature");

        require(txData.slot == slot, "Tx is referencing another slot");

        require(txData.prevBlock == coins[slot].exit.exitBlock, "Not a direct spend");

        checkTxIncluded(slot, txData.hash, blockNumber, proof);

    }



    function applyPenalties(uint64 slot) private {

        // Apply penalties and change state

        slashBond(coins[slot].exit.owner, msg.sender);

        coins[slot].state = State.DEPOSITED;

        emit CoinReset(slot, coins[slot].owner);

    }



    /// @param slot The slot of the coin being challenged

    /// @param owner The user claimed to be the true ower of the coin

    function setChallenged(uint64 slot, address owner, uint256 challengingBlockNumber, bytes32 txHash) private {

        // Require that the challenge is in the first half of the challenge window

        require(block.timestamp <= coins[slot].exit.createdAt + CHALLENGE_WINDOW);



        require(!challenges[slot].contains(txHash),

                "Transaction used for challenge already");



        // Need to save the exiting transaction's owner, to verify

        // that the response is valid

        challenges[slot].push(

            ChallengeLib.Challenge({

                owner: owner,

                challenger: msg.sender,

                txHash: txHash,

                challengingBlockNumber: challengingBlockNumber

            })

        );



        emit ChallengedExit(slot, txHash, challengingBlockNumber);

    }



    /******************** BOND RELATED ********************/



    function freeBond(address from) private {

        balances[from].bonded = balances[from].bonded.sub(BOND_AMOUNT);

        balances[from].withdrawable = balances[from].withdrawable.add(BOND_AMOUNT);

        emit FreedBond(from, BOND_AMOUNT);

    }



    function withdrawBonds() external {

        // Can only withdraw bond if the msg.sender

        uint256 amount = balances[msg.sender].withdrawable;

        balances[msg.sender].withdrawable = 0; // no reentrancy!



        msg.sender.transfer(amount);

        emit WithdrewBonds(msg.sender, amount);

    }



    function slashBond(address from, address to) private {

        balances[from].bonded = balances[from].bonded.sub(BOND_AMOUNT);

        balances[to].withdrawable = balances[to].withdrawable.add(BOND_AMOUNT);

        emit SlashedBond(from, to, BOND_AMOUNT);

    }



    /******************** PROOF CHECKING ********************/



    function checkIncludedAndSigned(

        bytes exitingTxBytes,

        bytes exitingTxInclusionProof,

        bytes signature,

        uint256 blk)

        private

        view

    {

        Transaction.TX memory txData = exitingTxBytes.getTx();



        // Deposit transactions need to be signed by their owners

        // e.g. Alice signs a transaction to Alice

        require(txData.hash.ecverify(signature, txData.owner), "Invalid signature");

        checkTxIncluded(txData.slot, txData.hash, blk, exitingTxInclusionProof);

    }



    function checkBothIncludedAndSigned(

        bytes prevTxBytes, bytes exitingTxBytes,

        bytes prevTxInclusionProof, bytes exitingTxInclusionProof,

        bytes signature,

        uint256[2] blocks)

        private

        view

    {

        require(blocks[0] < blocks[1]);



        Transaction.TX memory exitingTxData = exitingTxBytes.getTx();

        Transaction.TX memory prevTxData = prevTxBytes.getTx();



        // Both transactions need to be referring to the same slot

        require(exitingTxData.slot == prevTxData.slot);



        // The exiting transaction must be signed by the previous transaciton's owner

        require(exitingTxData.hash.ecverify(signature, prevTxData.owner), "Invalid signature");



        // Both transactions must be included in their respective blocks

        checkTxIncluded(prevTxData.slot, prevTxData.hash, blocks[0], prevTxInclusionProof);

        checkTxIncluded(exitingTxData.slot, exitingTxData.hash, blocks[1], exitingTxInclusionProof);

    }



    function checkTxIncluded(

        uint64 slot, 

        bytes32 txHash, 

        uint256 blockNumber,

        bytes proof

    ) 

        private 

        view 

    {

        bytes32 root = childChain[blockNumber].root;



        if (blockNumber % childBlockInterval != 0) {

            // Check against block root for deposit block numbers

            require(txHash == root);

        } else {

            // Check against merkle tree for all other block numbers

            require(

                checkMembership(

                    txHash,

                    root,

                    slot,

                    proof

            ),

            "Tx not included in claimed block"

            );

        }

    }



    /******************** DEPOSIT FUNCTIONS ********************/



    function() payable public {

        deposit(msg.sender, msg.sender, 0, msg.value, Mode.ETH);

    }



    function onERC20Received(address _from, uint256 _amount, bytes)

        public

        isTokenApproved(msg.sender)

        returns(bytes4)

    {

        deposit(_from, msg.sender, 0, _amount, Mode.ERC20);

        return ERC20_RECEIVED;

    }





    function onERC721Received(address _from, uint256 _uid, bytes)

        public

        isTokenApproved(msg.sender)

        returns(bytes4)

    {

        deposit(_from, msg.sender, _uid, 1, Mode.ERC721);

        return ERC721_RECEIVED;

    }



    // Approve and Deposit function for 2-step deposits without having to approve the token by the validators

    // Requires first to have called `approve` on the specified ERC20 contract

    function depositERC20(uint256 amount, address contractAddress) external {

        require(ERC20(contractAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        deposit(msg.sender, contractAddress, 0, amount, Mode.ERC20);

    }



    // Approve and Deposit function for 2-step deposits without having to approve the token by the validators

    // Requires first to have called `approve` on the specified ERC721 contract

    function depositERC721(uint256 uid, address contractAddress) external {

        ERC721(contractAddress).safeTransferFrom(msg.sender, address(this), uid);

        deposit(msg.sender, contractAddress, uid, 1, Mode.ERC721);

    }



    /******************** HELPERS ********************/



    /// @notice If the slot's exit is not found, a large number is returned to

    ///         ensure the exit array access fails

    /// @param slot The slot being exited

    /// @return The index of the slot's exit in the exitSlots array

    function getExitIndex(uint64 slot) private view returns (uint256) {

        uint256 len = exitSlots.length;

        for (uint256 i = 0; i < len; i++) {

            if (exitSlots[i] == slot)

                return i;

        }

        // a default value to return larger than the possible number of coins

        return 2**65;

    }



    function checkMembership(

        bytes32 txHash,

        bytes32 root,

        uint64 slot,

        bytes proof) public view returns (bool)

    {

        return smt.checkMembership(

            txHash,

            root,

            slot,

            proof);

    }



    function getPlasmaCoin(uint64 slot) external view returns(uint256, uint256, uint256, address, State, Mode, address) {

        Coin memory c = coins[slot];

        return (c.uid, c.depositBlock, c.denomination, c.owner, c.state, c.mode, c.contractAddress);

    }



    function getChallenge(uint64 slot, bytes32 txHash) 

        external 

        view 

        returns(address, address, bytes32, uint256)

    {

        uint256 index = uint256(challenges[slot].indexOf(txHash));

        ChallengeLib.Challenge memory c = challenges[slot][index];

        return (c.owner, c.challenger, c.txHash, c.challengingBlockNumber);

    }



    function getExit(uint64 slot) external view returns(address, uint256, uint256, State) {

        Exit memory e = coins[slot].exit;

        return (e.owner, e.prevBlock, e.exitBlock, coins[slot].state);

    }



    function getBlockRoot(uint256 blockNumber) public view returns (bytes32 root) {

        root = childChain[blockNumber].root;

    }

}



contract SparseMerkleTree {



    uint8 constant DEPTH = 64;

    bytes32[DEPTH + 1] public defaultHashes;



    constructor() public {

        // defaultHash[0] is being set to keccak256(uint256(0));

        defaultHashes[0] = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;

        setDefaultHashes(1, DEPTH);

    }



    function checkMembership(

        bytes32 leaf,

        bytes32 root,

        uint64 tokenID,

        bytes proof) public view returns (bool)

    {

        bytes32 computedHash = getRoot(leaf, tokenID, proof);

        return (computedHash == root);

    }



    // first 64 bits of the proof are the 0/1 bits

    function getRoot(bytes32 leaf, uint64 index, bytes proof) public view returns (bytes32) {

        require((proof.length - 8) % 32 == 0 && proof.length <= 2056);

        bytes32 proofElement;

        bytes32 computedHash = leaf;

        uint16 p = 8;

        uint64 proofBits;

        assembly {proofBits := div(mload(add(proof, 32)), exp(256, 24))}



        for (uint d = 0; d < DEPTH; d++ ) {

            if (proofBits % 2 == 0) { // check if last bit of proofBits is 0

                proofElement = defaultHashes[d];

            } else {

                p += 32;

                require(proof.length >= p);

                assembly { proofElement := mload(add(proof, p)) }

            }

            if (index % 2 == 0) {

                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));

            } else {

                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));

            }

            proofBits = proofBits / 2; // shift it right for next bit

            index = index / 2;

        }

        return computedHash;

    }



    function setDefaultHashes(uint8 startIndex, uint8 endIndex) private {

        for (uint8 i = startIndex; i <= endIndex; i ++) {

            defaultHashes[i] = keccak256(abi.encodePacked(defaultHashes[i-1], defaultHashes[i-1]));

        }

    }

}



library Transaction {



    using RLP for bytes;

    using RLP for RLP.RLPItem;



    struct TX {

        uint64 slot;

        address owner;

        bytes32 hash;

        uint256 prevBlock;

        uint256 denomination; 

    }



    function getTx(bytes memory txBytes) internal pure returns (TX memory) {

        RLP.RLPItem[] memory rlpTx = txBytes.toRLPItem().toList(4);

        TX memory transaction;



        transaction.slot = uint64(rlpTx[0].toUint());

        transaction.prevBlock = rlpTx[1].toUint();

        transaction.denomination = rlpTx[2].toUint();

        transaction.owner = rlpTx[3].toAddress();

        if (transaction.prevBlock == 0) { // deposit transaction

            transaction.hash = keccak256(abi.encodePacked(transaction.slot));

        } else {

            transaction.hash = keccak256(txBytes);

        }

        return transaction;

    }



    function getHash(bytes memory txBytes) internal pure returns (bytes32 hash) {

        RLP.RLPItem[] memory rlpTx = txBytes.toRLPItem().toList(4);

        uint64 slot = uint64(rlpTx[0].toUint());

        uint256 prevBlock = uint256(rlpTx[1].toUint());



        if (prevBlock == 0) { // deposit transaction

            hash = keccak256(abi.encodePacked(slot));

        } else {

            hash = keccak256(txBytes);

        }

    }



    function getOwner(bytes memory txBytes) internal pure returns (address owner) {

        RLP.RLPItem[] memory rlpTx = txBytes.toRLPItem().toList(4);

        owner = rlpTx[3].toAddress();

    }

}



contract ValidatorManagerContract is Ownable {



    mapping (address => bool) public validators;

    mapping (address => bool) public allowedTokens;



    function checkValidator(address _address) public view returns (bool) {

        // owner is a permanent validator

        if (_address == owner)

            return true;

        return validators[_address];

    }



    function toggleValidator(address _address) public onlyOwner {

        validators[_address] = !validators[_address];

    }



    function toggleToken(address _token) public {

        require(checkValidator(msg.sender), "not a validator");

        allowedTokens[_token] = !allowedTokens[_token];

    }



}
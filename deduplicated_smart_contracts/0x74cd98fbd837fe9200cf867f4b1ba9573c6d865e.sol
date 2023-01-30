pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <[email protected]> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}


// // Auction wrapper functions


// Auction wrapper functions







/// @title SEKRETOOOO
contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneScience() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock) public returns (uint256);
}



contract VariationInterface {

    function isVariation() public pure returns(bool);
    
    function createVariation(uint256 _gene, uint256 _totalSupply) public returns (uint8);
    
    function registerVariation(uint256 _dogId, address _owner) public;
}


contract LotteryInterface {
    
    function isLottery() public pure returns (bool);

    function checkLottery(uint256 genes) public pure returns (uint8 lotclass);
    
    function registerLottery(uint256 _dogId) public payable returns (uint8);

    function getCLottery() 
        public 
        view 
        returns (
            uint8[7]        luckyGenes1,
            uint256         totalAmount1,
            uint256         openBlock1,
            bool            isReward1,
            uint256         term1,
            uint8           currentGenes1,
            uint256         tSupply,
            uint256         sPoolAmount1,
            uint256[]       reward1
        );
}




/// @title A facet of KittyCore that manages special access privileges.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract DogAccessControl {
    // This facet controls access control for Cryptodogs. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the KittyCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from KittyCore and its auction contracts.
    //
    //     - The COO: The COO can release gen0 dogs to auction, and mint promo cats.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(msg.sender == cooAddress || msg.sender == ceoAddress || msg.sender == cfoAddress);
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}




/// @title Base contract for Cryptodogs. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract DogBase is DogAccessControl {
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new kitten comes into existence. This obviously
    ///  includes any time a cat is created through the giveBirth method, but it is also called
    ///  when a new gen0 cat is created.
    event Birth(address owner, uint256 dogId, uint256 matronId, uint256 sireId, uint256 genes, uint16 generation, uint8 variation, uint256 gen0, uint256 birthTime, uint256 income, uint16 cooldownIndex);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a kitten
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The main Dog struct. Every cat in Cryptodogs is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Dog {
        // The Dog's genetic code is packed into these 256-bits, the format is
        // sooper-sekret! A cat's genes never change.
        uint256 genes;

        // The timestamp from the block when this cat came into existence.
        uint256 birthTime;

        // The minimum timestamp after which this cat can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 cooldownEndBlock;

        // The ID of the parents of this Dog, set to 0 for gen0 cats.
        // Note that using 32-bit unsigned integers limits us to a "mere"
        // 4 billion cats. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! So, this definitely won't be a problem
        // for several years (even as Ethereum learns to scale).
        uint32 matronId;
        uint32 sireId;

        // Set to the ID of the sire cat for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know a cat
        // is pregnant. Used to retrieve the genetic material for the new
        // kitten when the birth transpires.
        uint32 siringWithId;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Dog. This starts at zero
        // for gen0 cats, and is initialized to floor(generation/2) for others.
        // Incremented by one for each successful breeding action, regardless
        // of whether this cat is acting as matron or sire.
        uint16 cooldownIndex;

        // The "generation number" of this cat. Cats minted by the CK contract
        // for sale are called "gen0" and have a generation number of 0. The
        // generation number of all other cats is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 generation;

        //zhangyong
        //变异系数
        uint8  variation;

        //zhangyong
        //0代狗祖先
        uint256 gen0;
    }

    /*** CONSTANTS ***/

    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  breeding action, called "pregnancy time" for matrons and "siring cooldown"
    ///  for sires. Designed such that the cooldown roughly doubles each time a cat
    ///  is bred, encouraging owners not to just keep breeding the same cat over
    ///  and over again. Caps out at one week (a cat can breed an unbounded number
    ///  of times, and the maximum cooldown is always seven days).
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(24 hours),
        uint32(2 days),
        uint32(3 days),
        uint32(5 days)
    ];

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Dog struct for all dogs in existence. The ID
    ///  of each cat is actually an index into this array. Note that ID 0 is a negacat,
    ///  the unKitty, the mythical beast that is the parent of all gen0 cats. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, cat ID 0 is invalid... ;-)
    Dog[] dogs;

    /// @dev A mapping from cat IDs to the address that owns them. All cats have
    ///  some valid owner address, even gen0 cats are created with a non-zero owner.
    mapping (uint256 => address) dogIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from KittyIDs to an address that has been approved to call
    ///  transferFrom(). Each Dog can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public dogIndexToApproved;

    /// @dev A mapping from KittyIDs to an address that has been approved to use
    ///  this Dog for siring via breedWith(). Each Dog can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public sireAllowedToAddress;

    /// @dev The address of the ClockAuction contract that handles sales of dogs. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public siringAuction;
  
    uint256 public autoBirthFee = 5000 szabo;

    //zhangyong
    //0代狗获取的繁殖收益
    uint256 public gen0Profit = 500 szabo;

    //zhangyong
    //0代狗获取繁殖收益的系数，可以动态调整，取值范围0到100
    function setGen0Profit(uint256 _value) public onlyCOO{        
        uint256 ration = _value * 100 / autoBirthFee;
        require(ration > 0);
        require(_value <= 100);
        gen0Profit = _value;
    }

    /// @dev Assigns ownership of a specific Dog to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of kittens is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        dogIndexToOwner[_tokenId] = _to;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // once the kitten is transferred also clear sire allowances
            delete sireAllowedToAddress[_tokenId];
            // clear any previously approved ownership exchange
            delete dogIndexToApproved[_tokenId];
        }

        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new Dog and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    /// @param _matronId The Dog ID of the matron of this cat (zero for gen0)
    /// @param _sireId The Dog ID of the sire of this cat (zero for gen0)
    /// @param _generation The generation number of this cat, must be computed by caller.
    /// @param _genes The Dog's genetic code.
    /// @param _owner The inital owner of this cat, must be non-zero (except for the unKitty, ID 0)
    //zhangyong
    //增加变异系数与0代狗祖先作为参数
    function _createDog(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner,
        uint8 _variation,
        uint256 _gen0,
        bool _isGen0Siring
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createDog() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint16(_generation)));

        // New Dog starts with the same cooldown as parent gen/2
        uint16 cooldownIndex = uint16(_generation / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        Dog memory _dog = Dog({
            genes: _genes,
            birthTime: block.number,
            cooldownEndBlock: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: cooldownIndex,
            generation: uint16(_generation),
            variation : uint8(_variation),
            gen0 : _gen0
        });
        uint256 newDogId = dogs.push(_dog) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        // require(newDogId == uint256(uint32(newDogId)));
        require(newDogId < 23887872);

        // emit the birth event
        Birth(
            _owner,
            newDogId,
            uint256(_dog.matronId),
            uint256(_dog.sireId),
            _dog.genes,
            uint16(_generation),
            _variation,
            _gen0,
            block.number,
            _isGen0Siring ? 0 : gen0Profit,
            cooldownIndex
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newDogId);

        return newDogId;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}





/// @title The external contract that is responsible for generating metadata for the dogs,
///  it has one function that will return the data as bytes.
// contract ERC721Metadata {
//     /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
//     function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
//         if (_tokenId == 1) {
//             buffer[0] = "Hello World! :D";
//             count = 15;
//         } else if (_tokenId == 2) {
//             buffer[0] = "I would definitely choose a medi";
//             buffer[1] = "um length string.";
//             count = 49;
//         } else if (_tokenId == 3) {
//             buffer[0] = "Lorem ipsum dolor sit amet, mi e";
//             buffer[1] = "st accumsan dapibus augue lorem,";
//             buffer[2] = " tristique vestibulum id, libero";
//             buffer[3] = " suscipit varius sapien aliquam.";
//             count = 128;
//         }
//     }
// }


/// @title The facet of the Cryptodogs core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract DogOwnership is DogBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "HelloDog";
    string public constant symbol = "HD";

    // The contract that will return Dog metadata
    // ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
    bytes4(keccak256("transferFrom(address,address,uint256)"));
        // bytes4(keccak256("tokensOfOwner(address)")) ^
        // bytes4(keccak256("tokenMetadata(uint256,string)"));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev Set the address of the sibling contract that tracks metadata.
    ///  CEO only.
    // function setMetadataAddress(address _contractAddress) public onlyCEO {
    //     erc721Metadata = ERC721Metadata(_contractAddress);
    // }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Dog.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return dogIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Dog.
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return dogIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting dogs on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        dogIndexToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of dogs owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Dog to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  Cryptodogs specifically) or your Dog may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Dog to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any dogs (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of dogs
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));
        require(_to != address(siringAuction));

        // You can only send your own cat.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Dog via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Dog that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Dog owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Dog to be transfered.
    /// @param _to The address that should take ownership of the Dog. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Dog to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any dogs (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of dogs currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return dogs.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Dog.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = dogIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Returns a list of all Dog IDs assigned to an address.
    /// @param _owner The owner whose dogs we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Dog array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    // function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
    //     uint256 tokenCount = balanceOf(_owner);

    //     if (tokenCount == 0) {
    //         // Return an empty array
    //         return new uint256[](0);
    //     } else {
    //         uint256[] memory result = new uint256[](tokenCount);
    //         uint256 totalCats = totalSupply();
    //         uint256 resultIndex = 0;

    //         // We count on the fact that all cats have IDs starting at 1 and increasing
    //         // sequentially up to the totalCat count.
    //         uint256 catId;

    //         for (catId = 1; catId <= totalCats; catId++) {
    //             if (dogIndexToOwner[catId] == _owner) {
    //                 result[resultIndex] = catId;
    //                 resultIndex++;
    //             }
    //         }

    //         return result;
    //     }
    // }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <[email protected]>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    // function _memcpy(uint _dest, uint _src, uint _len) private view {
    //     // Copy word-length chunks while possible
    //     for(; _len >= 32; _len -= 32) {
    //         assembly {
    //             mstore(_dest, mload(_src))
    //         }
    //         _dest += 32;
    //         _src += 32;
    //     }

    //     // Copy remaining bytes
    //     uint256 mask = 256 ** (32 - _len) - 1;
    //     assembly {
    //         let srcpart := and(mload(_src), not(mask))
    //         let destpart := and(mload(_dest), mask)
    //         mstore(_dest, or(destpart, srcpart))
    //     }
    // }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <[email protected]>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    // function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
    //     var outputString = new string(_stringLength);
    //     uint256 outputPtr;
    //     uint256 bytesPtr;

    //     assembly {
    //         outputPtr := add(outputString, 32)
    //         bytesPtr := _rawBytes
    //     }

    //     _memcpy(outputPtr, bytesPtr, _stringLength);

    //     return outputString;
    // }

    /// @notice Returns a URI pointing to a metadata package for this token conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Dog whose metadata should be returned.
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
    //     require(erc721Metadata != address(0));
    //     bytes32[4] memory buffer;
    //     uint256 count;
    //     (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

    //     return _toString(buffer, count);
    // }
}



/// @title A facet of KittyCore that manages Dog siring, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract DogBreeding is DogOwnership {

    /// @dev The Pregnant event is fired when two cats successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 matronCooldownEndBlock, uint256 sireCooldownEndBlock, uint256 matronCooldownIndex, uint256 sireCooldownIndex);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    // uint256 public autoBirthFee = 2 finney;

    // Keeps track of number of pregnant dogs.
    uint256 public pregnantDogs;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    GeneScienceInterface public geneScience;
    
    VariationInterface public variation;

    LotteryInterface public lottery;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isGeneScience());

        // Set the new contract address
        geneScience = candidateContract;
    }

    /// @dev Checks that a given kitten is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToBreed(Dog _dog) internal view returns (bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_dog.siringWithId == 0) && (_dog.cooldownEndBlock <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = dogIndexToOwner[_matronId];
        address sireOwner = dogIndexToOwner[_sireId];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }

    /// @dev Set the cooldownEndTime for the given Dog, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _dog A reference to the Dog in storage which needs its timer started.
    function _triggerCooldown(Dog storage _dog) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _dog.cooldownEndBlock = uint64((cooldowns[_dog.cooldownIndex]/secondsPerBlock) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_dog.cooldownIndex < 13) {
            _dog.cooldownIndex += 1;
        }
    }

    /// @notice Grants approval to another user to sire with one of your dogs.
    /// @param _addr The address that will be able to sire with your Dog. Set to
    ///  address(0) to clear all siring approvals for this Dog.
    /// @param _sireId A Dog that you own that _addr will now be able to sire with.
    function approveSiring(address _addr, uint256 _sireId)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _sireId));
        sireAllowedToAddress[_sireId] = _addr;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function setAutoBirthFee(uint256 val) external onlyCOO {
        require(val > 0);
        autoBirthFee = val;
    }

    /// @dev Checks to see if a given Dog is pregnant and (if so) if the gestation
    ///  period has passed.
    function _isReadyToGiveBirth(Dog _matron) private view returns (bool) {
        return (_matron.siringWithId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
    }

    /// @notice Checks that a given kitten is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _dogId reference the id of the kitten, any user can inquire about it
    function isReadyToBreed(uint256 _dogId)
        public
        view
        returns (bool)
    {
        //zhangyong
        //创世狗有两只
        require(_dogId > 1);
        Dog storage dog = dogs[_dogId];
        return _isReadyToBreed(dog);
    }

    /// @dev Checks whether a Dog is currently pregnant.
    /// @param _dogId reference the id of the kitten, any user can inquire about it
    function isPregnant(uint256 _dogId)
        public
        view
        returns (bool)
    {
        // A Dog is pregnant if and only if this field is set
        return dogs[_dogId].siringWithId != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Dog struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Dog struct of the potential sire.
    /// @param _sireId The sire's ID
    function _isValidMatingPair(
        Dog storage _matron,
        uint256 _matronId,
        Dog storage _sire,
        uint256 _sireId
    )
        private
        view
        returns(bool)
    {
        // A Dog can't breed with itself!
        if (_matronId == _sireId) {
            return false;
        }

        // dogs can't breed with their parents.
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        // dogs can't breed with full or half siblings.
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
        internal
        view
        returns (bool)
    {
        Dog storage matron = dogs[_matronId];
        Dog storage sire = dogs[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    // @notice Checks to see if two cats can breed together, including checks for
    //  ownership and siring approvals. Does NOT check that both cats are ready for
    //  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    //  TODO: Shouldn't this check pregnancy and cooldowns?!?
    // @param _matronId The ID of the proposed matron.
    // @param _sireId The ID of the proposed sire.
    // function canBreedWith(uint256 _matronId, uint256 _sireId)
    //     external
    //     view
    //     returns(bool)
    // {
    //     require(_matronId > 1);
    //     require(_sireId > 1);
    //     Dog storage matron = dogs[_matronId];
    //     Dog storage sire = dogs[_sireId];
    //     return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
    //         _isSiringPermitted(_sireId, _matronId);
    // }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _breedWith(uint256 _matronId, uint256 _sireId) internal {
        //zhangyong
        //创世狗不能繁殖
        require(_matronId > 1);
        require(_sireId > 1);
        
        // Grab a reference to the dogs from storage.
        Dog storage sire = dogs[_sireId];
        Dog storage matron = dogs[_matronId];

        //zhangyong
        //变异狗不能繁殖
        require(sire.variation == 0);
        require(matron.variation == 0);

        if (matron.generation > 0) {
            var(,,openBlock,,,,,,) = lottery.getCLottery();
            if (matron.birthTime < openBlock) {
                require(lottery.checkLottery(matron.genes) == 100);
            }
        }

        // Mark the matron as pregnant, keeping track of who the sire is.
        matron.siringWithId = uint32(_sireId);

        // Trigger the cooldown for both parents.
        _triggerCooldown(sire);
        _triggerCooldown(matron);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete sireAllowedToAddress[_matronId];
        delete sireAllowedToAddress[_sireId];

        // Every time a Dog gets pregnant, counter is incremented.
        pregnantDogs++;

        //zhangyong
        //只能由系统接生，接生费转给公司作为开发费用
        cfoAddress.transfer(autoBirthFee);

        //zhangyong
        //如果母狗是0代狗，那么小狗的祖先就是母狗的ID,否则跟母狗的祖先相同
        if (matron.generation > 0) {
            dogIndexToOwner[matron.gen0].transfer(gen0Profit);
        }

        // Emit the pregnancy event.
        Pregnant(dogIndexToOwner[_matronId], _matronId, _sireId, matron.cooldownEndBlock, sire.cooldownEndBlock, matron.cooldownIndex, sire.cooldownIndex);
    }

    /// @notice Breed a Dog you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your cat pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Dog acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Dog acting as sire (will begin its siring cooldown if successful)
    function breedWithAuto(uint256 _matronId, uint256 _sireId)
        external
        payable
        whenNotPaused
    {        
        // zhangyong
        // 如果不是0代狗繁殖，则多收0代狗的繁殖收益
        uint256 totalFee = autoBirthFee;
        Dog storage matron = dogs[_matronId];
        if (matron.generation > 0) {
            totalFee += gen0Profit;
        }

        // Checks for payment.
        require(msg.value >= totalFee);

        // Caller must own the matron.
        require(_owns(msg.sender, _matronId));

        // Neither sire nor matron are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For matron: The caller of this function can't be the owner of the matron
        //   because the owner of a Dog on auction is the auction house, and the
        //   auction house will never call breedWith().
        // For sire: Similarly, a sire on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either cat
        // is on auction.

        // Check that matron and sire are both owned by caller, or that the sire
        // has given siring permission to caller (i.e. matron's owner).
        // Will fail for _sireId = 0
        require(_isSiringPermitted(_sireId, _matronId));

        // Grab a reference to the potential matron
        // Dog storage matron = dogs[_matronId];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(matron));

        // Grab a reference to the potential sire
        Dog storage sire = dogs[_sireId];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(sire));

        // Test that these cats are a valid mating pair.
        require(_isValidMatingPair(matron, _matronId, sire, _sireId));

        // All checks passed, Dog gets pregnant!
        _breedWith(_matronId, _sireId);

        // zhangyong
        // 多余的费用返还给用户
        uint256 breedExcess = msg.value - totalFee;
        if (breedExcess > 0) {
            msg.sender.transfer(breedExcess);
        }
    }

    /// @notice Have a pregnant Dog give birth!
    /// @param _matronId A Dog ready to give birth.
    /// @return The Dog ID of the new kitten.
    /// @dev Looks at a given Dog and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Dog is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new kitten will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    //zhangyong
    //只能由系统接生，接生费转给公司作为开发费用,同时避免其他人帮助接生后，后台不知如何处理
    function giveBirth(uint256 _matronId)
        external
        whenNotPaused
        returns(uint256)
    {
        // Grab a reference to the matron in storage.
        Dog storage matron = dogs[_matronId];

        // Check that the matron is a valid cat.
        require(matron.birthTime != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(matron));

        // Grab a reference to the sire in storage.
        uint256 sireId = matron.siringWithId;
        Dog storage sire = dogs[sireId];

        // Determine the higher generation number of the two parents
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        //zhangyong
        //如果母狗是0代狗，那么小狗的祖先就是母狗的ID,否则跟母狗的祖先相同
        uint256 gen0 = matron.generation == 0 ? _matronId : matron.gen0;

        // Call the sooper-sekret gene mixing operation.
        uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1);

        // Make the new kitten!
        address owner = dogIndexToOwner[_matronId];

        uint8 _variation = variation.createVariation(childGenes, dogs.length);

        bool isGen0Siring = matron.generation == 0;

        uint256 kittenId = _createDog(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner, _variation, gen0, isGen0Siring);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.siringWithId;

        // Every time a Dog gives birth counter is decremented.
        pregnantDogs--;

        // Send the balance fee to the person who made birth happen.
       
        if(_variation != 0){
            variation.registerVariation(kittenId, owner);      
            _transfer(owner, address(variation), kittenId);
        }

        // return the new kitten's ID
        return kittenId;
    }
}




/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount, address _to)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        uint256 auctioneerCut = computeCut(price);

        //zhangyong
        //两只创世狗每次交易需要收取10%的手续费
        //创世狗无法繁殖，所以只有创世狗交易才会进入到这个方法
        uint256 fee = 0;
        if (_tokenId == 0 || _tokenId == 1) {
            fee = price / 5;
        }        
        require((_bidAmount + auctioneerCut + fee) >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 sellerProceeds = price - auctioneerCut - fee;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the auction
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelAuction(). )
            seller.transfer(sellerProceeds);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or
        // equal to the price so this cannot underflow.
        // zhangyong
        // _bidAmount在进入这个方法之前已经扣掉了fee，所以买者需要加上这笔费用才等于开始出价
        // uint256 bidExcess = _bidAmount + fee - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the auction is
        // removed before any transfers occur.
        // zhangyong
        // msg.sender是主合约地址，并不是出价人的地址
        // msg.sender.transfer(bidExcess);

        // Tell the world!
        AuctionSuccessful(_tokenId, price, _to);

        return price;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in
        //  _addAuction())
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function computeCut(uint256 _price) public view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}







/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
    modifier whenPaused {
        require(paused);
        _;
    }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}


/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    // bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);
    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
    bytes4(keccak256("transferFrom(address,address,uint256)"));

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        nftAddress.transfer(address(this).balance);
    }

    // @dev Creates and begins a new auction.
    // @param _tokenId - ID of token to auction, sender must be owner.
    // @param _startingPrice - Price of item (in wei) at beginning of auction.
    // @param _endingPrice - Price of item (in wei) at end of auction.
    // @param _duration - Length of time to move between starting
    //  price and ending price (in seconds).
    // @param _seller - Seller, if not the message sender
    // function createAuction(
    //     uint256 _tokenId,
    //     uint256 _startingPrice,
    //     uint256 _endingPrice,
    //     uint256 _duration,
    //     address _seller
    // )
    //     external
    //     whenNotPaused
    // {
    //     // Sanity check that no inputs overflow how many bits we've allocated
    //     // to store them in the auction struct.
    //     require(_startingPrice == uint256(uint128(_startingPrice)));
    //     require(_endingPrice == uint256(uint128(_endingPrice)));
    //     require(_duration == uint256(uint64(_duration)));

    //     require(_owns(msg.sender, _tokenId));
    //     _escrow(msg.sender, _tokenId);
    //     Auction memory auction = Auction(
    //         _seller,
    //         uint128(_startingPrice),
    //         uint128(_endingPrice),
    //         uint64(_duration),
    //         uint64(now)
    //     );
    //     _addAuction(_tokenId, auction);
    // }

    // @dev Bids on an open auction, completing the auction and transferring
    //  ownership of the NFT if enough Ether is supplied.
    // @param _tokenId - ID of token to bid on.
    // function bid(uint256 _tokenId)
    //     external
    //     payable
    //     whenNotPaused
    // {
    //     // _bid will throw if the bid or funds transfer fails
    //     _bid(_tokenId, msg.value);
    //     _transfer(msg.sender, _tokenId);
    // }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId)
        external
    {
        // zhangyong
        // 普通用户无法下架创世狗
        require(_tokenId > 1);

        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}


/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public isSiringClockAuction = true;

    // Delegate constructor
    function SiringClockAuction(address _nftAddr, uint256 _cut) public ClockAuction(_nftAddr, _cut) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be KittyCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the KittyCore contract because all bid methods
    /// should be wrapped. Also returns the Dog to the
    /// seller rather than the winner.
    function bid(uint256 _tokenId, address _to)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_tokenId, msg.value, _to);
        // We transfer the Dog back to the seller, the winner will get
        // the offspring
        _transfer(seller, _tokenId);
    }

}





/// @title Clock auction modified for sale of dogs
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    // Tracks last 5 sale price of gen0 Dog sales
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;

    // Delegate constructor
    function SaleClockAuction(address _nftAddr, uint256 _cut) public ClockAuction(_nftAddr, _cut) {}

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId, address _to)
        external
        payable
    {
        //zhangyong
        //只能由主合约调用出价竞购,因为要判断当期中奖了的狗无法买卖
        require(msg.sender == address(nonFungibleContract));

        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;  

        // zhangyong
        // 自己不能买自己卖的同一只狗
        require(seller != _to);

        uint256 price = _bid(_tokenId, msg.value, _to);
        
        //zhangyong
        //当狗被拍卖后，主人变成拍卖合约，主合约并不是狗的购买人，需要额外传入
        _transfer(_to, _tokenId);
   
        // If not a gen0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }

    function averageGen0SalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastGen0SalePrices[i];
        }
        return sum / 5;
    }

}


/// @title Handles creating auctions for sale and siring of dogs.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract DogAuction is DogBreeding {

    uint256 public constant GEN0_AUCTION_DURATION = 1 days;

    // @notice The auction contract variables are defined in KittyBase to allow
    //  us to refer to them in KittyOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of dogs.
    // `siringAuction` refers to the auction for siring rights of dogs.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function setSiringAuctionAddress(address _address) external onlyCEO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSiringClockAuction());

        // Set the new contract address
        siringAuction = candidateContract;
    }

    /// @dev Put a Dog up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _dogId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If Dog is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _dogId) || _approvedFor(msg.sender, _dogId));
        // Ensure the Dog is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Dog IS allowed to be in a cooldown.
        require(!isPregnant(_dogId));
        _approve(_dogId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Dog.
        saleAuction.createAuction(
            _dogId,
            _startingPrice,
            _endingPrice,
            _duration,
            dogIndexToOwner[_dogId]
        );
    }

    /// @dev Put a Dog up for auction to be sire.
    ///  Performs checks to ensure the Dog can be sired, then
    ///  delegates to reverse auction.
    function createSiringAuction(
        uint256 _dogId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {    
        //zhangyong
        Dog storage dog = dogs[_dogId];    
        //变异狗不能繁殖
        require(dog.variation == 0);

        // Auction contract checks input sizes
        // If Dog is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _dogId));
        require(isReadyToBreed(_dogId));
        _approve(_dogId, siringAuction);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the Dog.
        siringAuction.createAuction(
            _dogId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function bidOnSiringAuction(
        uint256 _sireId,
        uint256 _matronId
    )
        external
        payable
        whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _matronId));
        require(isReadyToBreed(_matronId));
        require(_canBreedWithViaAuction(_matronId, _sireId));

        // Define the current price of the auction.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        
        // zhangyong
        // 如果不是0代狗繁殖，则多收0代狗的繁殖收益
        uint256 totalFee = currentPrice + autoBirthFee;
        Dog storage matron = dogs[_matronId];
        if (matron.generation > 0) {
            totalFee += gen0Profit;
        }        
        require(msg.value >= totalFee);

        uint256 auctioneerCut = saleAuction.computeCut(currentPrice);
        // Siring auction will throw if the bid fails.
        siringAuction.bid.value(currentPrice - auctioneerCut)(_sireId, msg.sender);
        _breedWith(uint32(_matronId), uint32(_sireId));

        // zhangyong
        // 额外的钱返还给用户
        uint256 bidExcess = msg.value - totalFee;
        if (bidExcess > 0) {
            msg.sender.transfer(bidExcess);
        }
    }

    // zhangyong
    // 创世狗交易需要收取10%的手续费给CFO
    // 所有交易都要收取3.75%的手续费给买卖合约
    function bidOnSaleAuction(
        uint256 _dogId
    )
        external
        payable
        whenNotPaused
    {
        Dog storage dog = dogs[_dogId];

        //中奖的狗无法交易
        if (dog.generation > 0) {
            var(,,openBlock,,,,,,) = lottery.getCLottery();
            if (dog.birthTime < openBlock) {
                require(lottery.checkLottery(dog.genes) == 100);
            }
        }

        //交易成功之后，买卖合约会被删除，无法获取到当前价格
        uint256 currentPrice = saleAuction.getCurrentPrice(_dogId);

        require(msg.value >= currentPrice);

        //创世狗交易需要收取10%的手续费
        bool isCreationKitty = _dogId == 0 || _dogId == 1;
        uint256 fee = 0;
        if (isCreationKitty) {
            fee = currentPrice / 5;
        }
        uint256 auctioneerCut = saleAuction.computeCut(currentPrice);
        saleAuction.bid.value(currentPrice - (auctioneerCut + fee))(_dogId, msg.sender);

        // 创世狗被交易之后，下次的价格为当前成交价的2倍
        if (isCreationKitty) {
            //转账到主合约进行，因为买卖合约访问不了cfoAddress
            cfoAddress.transfer(fee);

            uint256 nextPrice = uint256(uint128(2 * currentPrice));
            if (nextPrice < currentPrice) {
                nextPrice = currentPrice;
            }
            _approve(_dogId, saleAuction);
            saleAuction.createAuction(
                _dogId,
                nextPrice,
                nextPrice,                                               
                GEN0_AUCTION_DURATION,
                msg.sender);
        }

        uint256 bidExcess = msg.value - currentPrice;
        if (bidExcess > 0) {
            msg.sender.transfer(bidExcess);
        }
    }

    // @dev Transfers the balance of the sale auction contract
    // to the KittyCore contract. We use two-step withdrawal to
    // prevent two transfer calls in the auction bid function.
    // function withdrawAuctionBalances() external onlyCLevel {
    //     saleAuction.withdrawBalance();
    //     siringAuction.withdrawBalance();
    // }
}


/// @title all functions related to creating kittens
contract DogMinting is DogAuction {

    // Limits the number of cats the contract owner can ever create.
    // uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant GEN0_CREATION_LIMIT = 40000;

    // Constants for gen0 auctions.
    uint256 public constant GEN0_STARTING_PRICE = 200 finney;
    // uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    // Counts the number of cats the contract owner has created.
    // uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    // @dev we can create promo kittens, up to a limit. Only callable by COO
    // @param _genes the encoded genes of the kitten to be created, any value is accepted
    // @param _owner the future owner of the created kittens. Default to contract COO
    // function createPromoKitty(uint256 _genes, address _owner) external onlyCOO {
    //     address kittyOwner = _owner;
    //     if (kittyOwner == address(0)) {
    //         kittyOwner = cooAddress;
    //     }
    //     require(promoCreatedCount < PROMO_CREATION_LIMIT);

    //     promoCreatedCount++;
    //     //zhangyong
    //     //增加变异系数与0代狗祖先作为参数
    //     _createDog(0, 0, 0, _genes, kittyOwner, 0, 0, false);
    // }

    // @dev Creates a new gen0 Dog with the given genes
    function createGen0Dog(uint256 _genes) external onlyCLevel returns(uint256) {
        require(gen0CreatedCount < GEN0_CREATION_LIMIT);
        //zhangyong
        //增加变异系数与0代狗祖先作为参数
        uint256 dogId = _createDog(0, 0, 0, _genes, address(this), 0, 0, false);
        
        _approve(dogId, msg.sender);

        gen0CreatedCount++;
        return dogId;
    }

    /// @dev creates an auction for it.
    // function createGen0Auction(uint256 _dogId) external onlyCOO {
    //     require(_owns(address(this), _dogId));

    //     _approve(_dogId, saleAuction);

    //     //zhangyong
    //     //0代狗的价格随时间递减到最低价，起始价与前5只价格相关
    //     uint256 price = _computeNextGen0Price();
    //     saleAuction.createAuction(
    //         _dogId,
    //         price,
    //         price,
    //         GEN0_AUCTION_DURATION,
    //         address(this)
    //     );
    // }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function computeNextGen0Price() public view returns (uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < GEN0_STARTING_PRICE) {
            nextPrice = GEN0_STARTING_PRICE;
        }

        return nextPrice;
    }
}


/// @title Cryptodogs: Collectible, breedable, and oh-so-adorable cats on the Ethereum blockchain.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev The main Cryptodogs contract, keeps track of kittens so they don't wander around and get lost.
contract DogCore is DogMinting {

    // This is the main Cryptodogs contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // Dog ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - KittyBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - KittyAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - KittyOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - KittyBreeding: This file contains the methods necessary to breed cats together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - KittyAuctions: Here we have the public methods for auctioning or bidding on cats or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - KittyMinting: This final facet contains the functionality we use for creating new gen0 cats.
    //             We can make up to 5000 "promo" cats that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 cats. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main Cryptodogs smart contract instance.
    function DogCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        //zhangyong
        //增加变异系数与0代狗祖先作为参数
        _createDog(0, 0, 0, uint256(0), address(this), 0, 0, false);   
        _approve(0, cooAddress);     
        _createDog(0, 0, 0, uint256(0), address(this), 0, 0, false);   
        _approve(1, cooAddress);
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction) ||
            msg.sender == ceoAddress
        );
    }

    /// @notice Returns all the relevant information about a specific Dog.
    /// @param _id The ID of the Dog of interest.
    function getDog(uint256 _id)
        external
        view
        returns (
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes,
        uint8 variation,
        uint256 gen0
    ) {
        Dog storage dog = dogs[_id];

        // if this variable is 0 then it's not gestating
        cooldownIndex = uint256(dog.cooldownIndex);
        nextActionAt = uint256(dog.cooldownEndBlock);
        siringWithId = uint256(dog.siringWithId);
        birthTime = uint256(dog.birthTime);
        matronId = uint256(dog.matronId);
        sireId = uint256(dog.sireId);
        generation = uint256(dog.generation);
        genes = uint256(dog.genes);
        variation = uint8(dog.variation);
        gen0 = uint256(dog.gen0);
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(lottery != address(0));
        require(variation != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
      
    function setLotteryAddress(address _address) external onlyCEO {
        LotteryInterface candidateContract = LotteryInterface(_address);

        require(candidateContract.isLottery());

        lottery = candidateContract;
    }  
      
    function setVariationAddress(address _address) external onlyCEO {
        VariationInterface candidateContract = VariationInterface(_address);

        require(candidateContract.isVariation());

        variation = candidateContract;
    }  

    function registerLottery(uint256 _dogId) external returns (uint8) {
        require(_owns(msg.sender, _dogId));
        require(lottery.registerLottery(_dogId) == 0);    
        _transfer(msg.sender, address(lottery), _dogId);
    }

    function sendMoney(address _to, uint256 _money) external {
        require(msg.sender == address(lottery) || msg.sender == address(variation));
        require(address(this).balance >= _money);
        _to.transfer(_money);
    }

}
/**
 *Submitted for verification at Etherscan.io on 2020-01-12
*/

pragma solidity ^0.4.25;
// Pixelicu Source code
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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

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

/// @title A facet of ArtworkCore that manages special access privileges.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the ArtworkCore contract documentation to understand how the various contract facets are arranged.
contract ArtworkAccessControl {
    // This facet controls access control for Pixelicu. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the ArtworkCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from ArtworkCore and its auction contracts.
    //
    //     - The COO: The COO can release gen0 artworks to auction, and mint promo artworks.
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
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external payable onlyCEO {
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
    function setCOO(address _newCOO) external payable onlyCEO {
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
    function unpause() public payable onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}




/// @title Base contract for Pixelicu. Holds all common structs, events and base variables.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the ArtworkCore contract documentation to understand how the various contract facets are arranged.
contract ArtworkBase is ArtworkAccessControl {
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new artwork comes into existence. This obviously
    event Birth(address owner,bytes artworkContent);
     /// @dev The CoupledArt  event is fired when two artworks successfully couple a
    event CoupledArt(address owner, uint256 topId, uint256 bottomId);
    event CoupledArtRightpiece(address owner, uint256 topId, uint256 bottomId);

    /// @dev The Grant events are fired when a control token assigns a token to the left/right/control slots
    event Grant(uint256 _tokenToGrantControlOf, uint256 _tokenToGrantControlTo);
    event GrantControl(uint256 _tokenToGrantControlOf, uint256 _tokenToGrantControlTo);


    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a artwork
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The main Artwork struct. Every artwork in Pixelicu is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Artwork {
        address creatorId;
        uint64 birthTime;
        bytes artworkContent;
    }

    /*** CONSTANTS ***/


    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Artwork struct for all Artworks in existence. The ID
    ///  of each artwork is actually an index into this array. Note that ID 0 is a negaartwork,
    ///  the unArtwork, the mythical beast that is the parent of all gen0 artworks. A bizarre
    ///  creature that is both creator and license... to itself! Has an invalid genetic code.
    ///  In other words, artwork ID 0 is invalid... ;-)
    // Artwork[] artworks; 
    Artwork[] artworks;
    mapping (bytes => bool) isTaken;


    /// @dev A mapping from artwork IDs to the address that owns them. All artworks have
    ///  some valid owner address, even gen0 artworks are created with a non-zero owner.
    mapping (uint256 => address) public artworkIndexToOwner;
    mapping (uint256 => bool) public artworkIndexToPublic;
    mapping (address=> bytes32) public addressToUsername;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from ArtworkIDs to an address that has been approved to call
    ///  transferFrom(). Each Artwork can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public artworkIndexToApproved;
    
    mapping (uint256 => uint256) public artworkIndexToLeftpiece;
    mapping (uint256 => uint256) public artworkIndexToRightpiece;
    mapping (uint256 => uint256) public artworkIndexToControlPiece;


    
        /// @dev A mapping from artworkIDs to an address that has been approved to use
    ///  this Kitty for coupling . Each Artwork can only have one approved
    ///  address for coupling at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public coupleAllowedToAddress;
    /// @dev The address of the ClockAuction contract that handles sales of Artworks. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;
    CouplingClockAuction public couplingAuction;


      function _getBytes(uint256 _artworkId) internal returns (bytes artworkContent){
           return artworks[_artworkId].artworkContent;
    }

    /// @dev Assigns ownership of a specific Artwork to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of artworks is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        artworkIndexToOwner[_tokenId] = _to;
        // When creating new artworks _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete artworkIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new artwork and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    /// @param _creatorId The artwork ID of the creator of this artwork (zero for gen0)
    /// @param _artworkContent The artwork's genetic code.
    /// @param _owner The inital owner of this artwork, must be non-zero (except for the unArtwork, ID 0)
    function _createArtwork(
        bytes _artworkContent,
        address _owner,
        address _creatorId
    )
        internal
        returns (uint256)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createArtwork() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(isTaken[_artworkContent] == false);
        Artwork memory _artwork = Artwork({
            birthTime: uint64(now),
            creatorId: _creatorId,
            artworkContent: _artworkContent
        });
        
        uint256 newArtId = artworks.push(_artwork) - 1;
        isTaken[_artworkContent] = true;

        // It's probably never going to happen, 4 ga-billion artworks is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newArtId == uint256(newArtId));

        // emit the birth event
        Birth(
            _artwork.creatorId,
            _artworkContent
        );
        artworkIndexToLeftpiece[newArtId] = 0;
        artworkIndexToRightpiece[newArtId] = 0;

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newArtId);

        return newArtId;
    }
    
     function _assignLeftpiece(uint256 _topId, uint256 _leftId) internal {


        // Mark the topPiece as having a tailpiece, keeping track of which one
        
        artworkIndexToLeftpiece[_topId] = _leftId;
        // Emit the coupling event.
        CoupledArt(artworkIndexToOwner[_topId], _topId, _leftId);
    }

     function _assignControlPiece(uint256 _tokenId, uint256 _controlId) internal {
    
        artworkIndexToControlPiece[_tokenId] = _controlId;
    }

    function _assignRightpiece(uint256 _topId, uint256 _rightId) internal {
         Artwork storage topArtwork = artworks[_topId];

        // Mark the topPiece as having a tailpiece, keeping track of which one
        //topArtwork.rightpieceId = _rightId;
        
        artworkIndexToRightpiece[_topId] = _rightId;
        // Emit the coupling event.
        CoupledArtRightpiece(artworkIndexToOwner[_topId], _topId, _rightId);
    }
    
     function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artworkIndexToOwner[_tokenId] == _claimant;
    }
      // External function intended for subcontracts to be able to attach rewards to tokens
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _claimant the owned token of the msg sender they are using to validate their claim.
    /// @param _tokenId the token that the caller is indicating as being controlled
    /// @param _controlToken tthe token that is being used to control the _tokenId;
      function _ownsOrControls(address _claimant, uint256 _tokenId, uint256 _controlToken) internal view returns (bool) {
        return artworkIndexToOwner[_tokenId] == _claimant || artworkIndexToControlPiece[_tokenId] == _controlToken;
    }

    function _shareControl(uint256 _masterToken, uint256 _childToken) internal view returns (bool){
        return (artworkIndexToControlPiece[_childToken] == _masterToken || artworkIndexToControlPiece[_childToken] == artworkIndexToControlPiece[_masterToken]);
    }
    
     function _isCouplingPermitted(uint256 _topId, uint256 _partnerId) internal view returns (bool) {
        address topOwner = artworkIndexToOwner[_topId];
        address bottomOwner = artworkIndexToOwner[_partnerId];

        // Coupling is okay if they have same owner, or if the top's owner was given
        // permission to pair with this artwork.
        return (topOwner == bottomOwner || coupleAllowedToAddress[_partnerId] == topOwner || artworkIndexToPublic[_partnerId] == true);
    }
    
        function approveCoupling(address _addr, uint256 _partnerId)
        external payable
        whenNotPaused
    {
        require(_owns(msg.sender, _partnerId));
        coupleAllowedToAddress[_partnerId] = _addr;
    }

        function setUsername(bytes32 _username)
        external payable
        whenNotPaused
    {
        addressToUsername[msg.sender] = _username;
    }


      function setTokenAsPublic(uint256 _tokenId)
        external payable
        whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));
        artworkIndexToPublic[_tokenId] = true;
    }

      function setTokenAsPrivate(uint256 _tokenId)
        external payable
        whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));
        artworkIndexToPublic[_tokenId] = false;
    }
    
           function removeCouplingPermission(uint256 _partnerId)
        external payable
        whenNotPaused
    {
        require(_owns(msg.sender, _partnerId));
        coupleAllowedToAddress[_partnerId] = msg.sender;
    }

}


/// @title The external contract that is responsible for generating metadata for the artworks,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}


/// @title The facet of the PIxelicus core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the ArtworkCore contract documentation to understand how the various contract facets are arranged.
contract ArtworkOwnership is ArtworkBase, ERC721 {
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "glia.icu";
    string public constant symbol = "GLIA";

    // The contract that will return artwork metadata
    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
 function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev Set the address of the sibling contract that tracks metadata.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
     }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId artwork id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artworkIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Artwork.
    /// @param _claimant the address we are confirming artwork is approved for.
    /// @param _tokenId artwork id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artworkIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Artworks on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        artworkIndexToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of Artworks owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Artwork to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  Pixelicu specifically) or your Artwork may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Artwork to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external payable
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any artworks (except very briefly
        // after a gen0 artwork is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of artworks
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));
        require(_to != address(couplingAuction));

        // You can only send your own artwork.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Artwork via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Artwork that can be transferred if this call succeeds.
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

    /// @notice Transfer a Artwork owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Artwork to be transfered.
    /// @param _to The address that should take ownership of the Artwork. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Artwork to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external payable
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any artworks (except very briefly
        // after a gen0 artwork is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Artworks currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return artworks.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Artwork.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = artworkIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Returns a list of all Artwork IDs assigned to an address.
    /// @param _owner The owner whose Artworks we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Artwork array looking for artworks belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty arrayz
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalArtpieces = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all artworks have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 artworkId;

            for (artworkId = 1; artworkId <= totalArtpieces; artworkId++) {
                if (artworkIndexToOwner[artworkId] == _owner) {
                    result[resultIndex] = artworkId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    /// @notice Returns a URI pointing to a metadata package for this token conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Artwork whose metadata should be returned.
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

        return _toString(buffer, count);
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
    function _bid(uint256 _tokenId, uint256 _bidAmount)
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
        require(_bidAmount >= price);

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
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

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
        uint256 bidExcess = _bidAmount - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the auction is
        // removed before any transfers occur.
        msg.sender.transfer(bidExcess);

        // Tell the world!
        AuctionSuccessful(_tokenId, price, msg.sender);

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
    function _computeCut(uint256 _price) internal view returns (uint256) {
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
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() payable onlyOwner whenPaused returns (bool) {
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
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

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
        bool res = nftAddress.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
        whenNotPaused
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId)
        external
        payable
        whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId)
        external
    {
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

/// @title Reverse auction modified for coupling
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract CouplingClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setCouplingAuctionAddress() call.
    bool public isCouplingClockAuction = true;

    // Delegate constructor
    function CouplingClockAuction(address _nftAddr, uint256 _cut) public
        ClockAuction(_nftAddr, _cut) {}

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

    /// @dev Places a bid for coupling. Requires the sender
    /// is the KittyCore contract because all bid methods
    /// should be wrapped. Also returns the artwork to the
    /// seller rather than the winner.
    function bid(uint256 _tokenId)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_tokenId, msg.value);
        // We transfer the artwork back to the seller, the winner will get
        // the offspring
        _transfer(seller, _tokenId);
    }

}


/// @title Clock auction modified for sale of artworks
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    // Tracks last 5 sale price of gen0 artwork sales
    uint256 public saleCount;
    uint256[5] public lastSalePrices;

    // Delegate constructor
    function SaleClockAuction(address _nftAddr, uint256 _cut) public
        ClockAuction(_nftAddr, _cut) 
        {}

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
        /// @param _tokenId - tokenId

    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
        external
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

       
            lastSalePrices[saleCount % 5] = price;
            saleCount++;
        }
    }

contract ArtworkLicensing is ArtworkOwnership {

   


    /// @notice The minimum payment required to createArtwork(). This is a cost paid 
    ///  the gas cost paid by whatever calls createArtwork(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public autoCreationFee = 2 finney;


    /// @dev Updates the minimum payment required for calling createArtwork(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function setAutoCreationFee(uint256 val) external onlyCOO {
        autoCreationFee = val;
    }
}

contract ArtworkAuction is ArtworkLicensing {

    // @notice The auction contract variables are defined in ArtworkBase to allow
    //  us to refer to them in ArtworkOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of kitties.
    // `siringAuction` refers to the auction for siring rights of kitties.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect -
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

        /// @dev Sets the reference to the coupling auction.
    /// @param _address - Address of coupling contract.
    function setCouplingAuctionAddress(address _address) external onlyCEO {
        CouplingClockAuction candidateContract = CouplingClockAuction(_address);

        // NOTE: verify that a contract is what we expect -
        require(candidateContract.isCouplingClockAuction());

        // Set the new contract address
        couplingAuction = candidateContract;
    }
        /// @dev Put a artwork up for auction to be coupled.
    ///  delegates to reverse auction.
        function createCouplingAuction(
        uint256 _artworkId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If artwork is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _artworkId));
        _approve(_artworkId, couplingAuction);
        // Coupling auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the artwork.
        couplingAuction.createAuction(
            _artworkId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    /// @dev Sets the reference to the siring auction.
        // FIXME ? removed for now

    /// @dev Put an artwork up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _artworkId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If artwork is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _artworkId));
        // Ensure the artwork is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the artwork IS allowed to be in a cooldown.
        _approve(_artworkId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the artwork.
        saleAuction.createAuction(
            _artworkId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }



        /// @dev Completes a coupling auction by bidding.
    ///  Immediately couples the winning top with the bottom on auction.
    /// @param _partnerId - ID of the bottom on auction.
    /// @param _topId - ID of the artwork owned by the bidder.
    function bidOnCouplingAuction(
        uint256 _partnerId,
        uint256 _topId
    )
        external
        payable
        whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _topId));

        // Define the current price of the auction.
        uint256 currentPrice = couplingAuction.getCurrentPrice(_partnerId);
        require(msg.value >= currentPrice);

        // Coupling auction will throw if the bid fails.
        couplingAuction.bid.value(msg.value)(_partnerId);
        _assignLeftpiece(_topId,_partnerId);
    }
   

    /// @dev Transfers the balance of the sale auction contract
    /// to the ArtworkCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        couplingAuction.withdrawBalance();
    }
}

/// @title all functions related to creating artworks
contract ArtworkMinting is ArtworkAuction {

    // Limits the number of artworks the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 5000;

    // Counts the number of artworks the contract owner has created.
    uint256 public promoCreatedCount;

    /// @dev we can create promo artworks, up to a limit. Only callable by COO
    /// @param _artworkContent the encoded artworkContent of the artwork to be created, any value is accepted
    function createPromoArtwork(bytes _artworkContent) external payable onlyCOO {
        address artOwner = msg.sender;
        if (artOwner == address(0)) {
             artOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);
        promoCreatedCount++;
        _createArtwork(_artworkContent, artOwner,artOwner);
    }

    // Same as above but accessible by non-COO requires additional payment equal to autoCreation Fee
     function createArtwork(bytes _artworkContent) external payable whenNotPaused {
        address artOwner = msg.sender;
        if (artOwner == address(0)) {
             artOwner = cooAddress;
        }
        require(msg.value >= autoCreationFee);
        _createArtwork(_artworkContent, artOwner,artOwner);
    }
     function _ownsOrIsOpUnassigned(address _claimant, uint256 _tokenId) internal view returns (bool) {
         
        return (_owns(msg.sender, _tokenId) || (msg.sender == cooAddress && artworkIndexToLeftpiece[_tokenId] == 0));

    }
      // public function callable in contract to assign the control/left/right pieces for an owner
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _tokenId (a.k.a. _topId) the owned token of the msg sender they are using to validate their claim.
    /// @param _controlId the token that the caller is indicating as a control piece
    /// msg.sender doesn't need to own _controlId to be able to assign, must own _tokenId which will receive assignment

     function assignControlPiece(uint256 _tokenId, uint256 _controlId) external payable whenNotPaused  {
        require(_owns(msg.sender, _tokenId));
       _assignControlPiece(_tokenId,_controlId);
    }
       function assignLeftpiece(uint256 _topId, uint256 _leftId) external payable whenNotPaused  {
        require(_owns(msg.sender, _topId));
        require(_isCouplingPermitted(_topId, _leftId));
       _assignLeftpiece(_topId,_leftId);
    }

          function assignRightpiece(uint256 _topId, uint256 _rightId) external payable whenNotPaused  {
        require(_owns(msg.sender, _topId));
        require(_isCouplingPermitted(_topId, _rightId));
       _assignRightpiece(_topId,_rightId);
    }
    // External function intended for subcontracts to be able to attach rewards to tokens
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _masterId the owned token of the msg sender they are using to validate their claim.
    /// @param _controlTargetId the token that the caller is indicating as a control piece
    /// @param _receiverId the token that will have the piece attached to it msg.sender must own
    /// @param _tokenToGrant the tokenThatWill be assigned.
    /// @param _controlOwner address of owner of the control token.  If the address doesn't own those token grant fails

    function grantRightpiece(uint256 _masterId,uint256 _controlTargetId, uint256 _receiverId, uint256 _tokenToGrant, address _controlOwner) external payable whenNotPaused {
        require(artworkIndexToControlPiece[_masterId] != 0);
        require(_owns(msg.sender, _masterId));  
        require(_ownsOrControls(msg.sender, _tokenToGrant, _masterId));
         require(_owns(_controlOwner, _receiverId));
        require(_owns(_controlOwner, _controlTargetId));
        require(_shareControl(_masterId,_controlTargetId));
        require(_shareControl(_masterId,_receiverId));

        _assignRightpiece(_receiverId,_tokenToGrant);
        Grant(_receiverId, _tokenToGrant);
    }


       function grantLeftpiece(uint256 _masterId,uint256 _controlTargetId, uint256 _receiverId, uint256 _tokenToGrant, address _controlOwner) external payable whenNotPaused {
        require(artworkIndexToControlPiece[_masterId] != 0);
        require(_owns(msg.sender, _masterId));
        require(_ownsOrControls(msg.sender, _tokenToGrant, _masterId));
         require(_owns(_controlOwner, _receiverId));
        require(_owns(_controlOwner, _controlTargetId));
        require(_shareControl(_masterId,_controlTargetId));
        require(_shareControl(_masterId,_receiverId));
         _assignLeftpiece(_receiverId,_tokenToGrant);
         Grant(_receiverId, _tokenToGrant);

    }
       // Allows an external contract to change the control piece of a token provided the msg.sender owns token
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _tokenToGrantControlOf this is the token that will have its control reassigned
    /// @param _tokenToGrantControlTo the token that the caller wants to grant as a control piece
    function grantControlpiece(uint256 _masterId,uint256 _tokenToGrantControlOf, uint256 _tokenToGrantControlTo)  external payable whenNotPaused {
          require(artworkIndexToControlPiece[_masterId] != 0);
        require(_owns(msg.sender, _masterId));  
        require(_ownsOrControls(msg.sender, _tokenToGrantControlOf, _masterId));
        require(_shareControl(_masterId,_tokenToGrantControlOf));
        artworkIndexToControlPiece[_tokenToGrantControlTo];
        GrantControl(_tokenToGrantControlOf, _tokenToGrantControlTo);
    }
      // Allows an external contract to change the control piece of a token provided the msg.sender owns token
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _masterId this is the token that is being used to assert control
    /// @param _tokenToPoint this is the token the _masterId asserts control over and will be pointed to
    /// @param _topToken this is the token that will point to _tokenToPoint
    /// @param _controlOwner Additional Sanity check to make sure the address matches owner of token
     function pointRightToControlledArtwork(uint256 _masterId, uint256 _tokenToPoint, uint256 _topToken, address _controlOwner) external payable whenNotPaused {
        require(artworkIndexToControlPiece[_masterId] != 0);
        require(_owns(msg.sender, _masterId));  
        require(_ownsOrControls(msg.sender, _topToken, _masterId));
        require(_ownsOrControls(msg.sender, _topToken, _masterId));
        require(_shareControl(_masterId,_tokenToPoint));
        _assignRightpiece(_topToken,_tokenToPoint);
        Grant(_topToken, _tokenToPoint);
    }


     function pointLeftToControlledArtwork(uint256 _masterId, uint256 _tokenToPoint, uint256 _topToken, address _controlOwner) external payable whenNotPaused {
        require(artworkIndexToControlPiece[_masterId] != 0);
        require(_owns(msg.sender, _masterId));  
        require(_ownsOrControls(msg.sender, _topToken, _masterId));
         require(_owns(_controlOwner, _tokenToPoint));
        require(_shareControl(_masterId,_tokenToPoint));

        _assignLeftpiece(_topToken,_tokenToPoint);
        Grant(_topToken, _tokenToPoint);
    }


    // Allows a external contract to allow token owner to reset the right/left pieces on their token to 0;
     /// @dev Checks if a given address is the current owner of a particular Artwork.
    /// @param _topId this is the token that will have its control reassigned
          function removeRightpiece(uint256 _topId) external payable whenNotPaused {
        require(_owns(msg.sender, _topId));
        artworkIndexToRightpiece[_topId] = 0;
    }

          function removeLeftpiece(uint256 _topId) external payable whenNotPaused {
        require(_owns(msg.sender, _topId));
        artworkIndexToLeftpiece[_topId] = 0;
    }

    function shareControl(uint256 _tokenA, uint256 _tokenB) external view returns (bool){
        return _shareControl(_tokenA,_tokenB);
    }


}
/// @title Pixelicu: Collectible artworks on the Ethereum blockchain.
/// @dev The main Pixelicu contract, keeps track of artworks

contract ArtworkCore is ArtworkMinting {

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main Pixelicu smart contract instance.
    function ArtworkCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with the mythical artwork 0 - so we don't have generation-0 parent issues
        // we'll do this manually 
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
            msg.sender == address(couplingAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific artwork.
    /// @param _id The ID of the artwork of interest.
    function getArtwork(uint256 _id)
        external
        view
        returns (
        uint256 birthTime,
        address creatorId,
        bytes artworkContent
    ) {
        Artwork storage art = artworks[_id];
        birthTime = uint256(art.birthTime);
        creatorId = art.creatorId;
        artworkContent = art.artworkContent;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public payable onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(couplingAuction != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
    
   

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant artworks we have, plus 1 of margin.
        cfoAddress.transfer(balance);
    }
}


// @title Voting with delegation.
contract Contest {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted contestEntry
    }

    // This is a type for a single contestEntry.
    struct ContestEntry {
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `ContestEntry` structs.
    ContestEntry[] public contestEntrys;

    /// Create a new contest to choose one of `contestEntryTokens`.
    constructor(uint256[] contestEntryTokens) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided contestEntry names,
        // create a new contestEntry object and add it
        // to the end of the array.
    }

    function addEntry(uint256 tokenId) public {
        contestEntrys.push(  ContestEntry(   {voteCount:0}  ) );
    }

    // Give `voter` the right to vote on this contest.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) public {
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) public {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            contestEntrys[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to contestEntry `contestEntrys[contestEntry].name`.
    function vote(uint contestEntry) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = contestEntry;

        // If `contestEntry` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        contestEntrys[contestEntry].voteCount += sender.weight;
    }

    /// @dev Computes the winning contestEntry taking all
    /// previous votes into account.
    function winningContestEntry() public view
            returns (uint winningContestEntry_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < contestEntrys.length; p++) {
            if (contestEntrys[p].voteCount > winningVoteCount) {
                winningVoteCount = contestEntrys[p].voteCount;
                winningContestEntry_ = p;
            }
        }
    }

    
}
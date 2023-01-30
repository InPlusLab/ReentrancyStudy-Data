/**

 *Submitted for verification at Etherscan.io on 2019-06-12

*/



pragma solidity ^0.4.24;



/**

 * @title Initializable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Initializable {



  /**

   * @dev Indicates that the contract has been initialized.

   */

  bool private initialized;



  /**

   * @dev Indicates that the contract is in the process of being initialized.

   */

  bool private initializing;



  /**

   * @dev Modifier to use in the initializer function of a contract.

   */

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable is Initializable {

  address private _owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function initialize(address sender) public initializer {

    _owner = sender;

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }



  uint256[50] private ______gap;

}



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface IERC165 {



  /**

   * @notice Query if a contract implements an interface

   * @param interfaceId The interface identifier, as specified in ERC-165

   * @dev Interface identification is specified in ERC-165. This function

   * uses less than 30,000 gas.

   */

  function supportsInterface(bytes4 interfaceId)

    external

    view

    returns (bool);

}



/**

 * @title ERC165

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract ERC165 is Initializable, IERC165 {



  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) internal _supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  function initialize()

    public

    initializer

  {

    _registerInterface(_InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 interfaceId)

    public

    view

    returns (bool)

  {

    return _supportedInterfaces[interfaceId];

  }



  /**

   * @dev private method for registering an interface

   */

  function _registerInterface(bytes4 interfaceId)

    internal

  {

    require(interfaceId != 0xffffffff);

    _supportedInterfaces[interfaceId] = true;

  }



  uint256[50] private ______gap;

}



/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721 is Initializable, IERC165 {



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 indexed tokenId

  );

  event Approval(

    address indexed owner,

    address indexed approved,

    uint256 indexed tokenId

  );

  event ApprovalForAll(

    address indexed owner,

    address indexed operator,

    bool approved

  );



  function balanceOf(address owner) public view returns (uint256 balance);

  function ownerOf(uint256 tokenId) public view returns (address owner);



  function approve(address to, uint256 tokenId) public;

  function getApproved(uint256 tokenId)

    public view returns (address operator);



  function setApprovalForAll(address operator, bool _approved) public;

  function isApprovedForAll(address owner, address operator)

    public view returns (bool);



  function transferFrom(address from, address to, uint256 tokenId) public;

  function safeTransferFrom(address from, address to, uint256 tokenId)

    public;



  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId,

    bytes data

  )

    public;

}



/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is Initializable, ERC165, IERC721 {



  using SafeMath for uint256;

  using Address for address;



  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

  // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



  // Mapping from token ID to owner

  mapping (uint256 => address) private _tokenOwner;



  // Mapping from token ID to approved address

  mapping (uint256 => address) private _tokenApprovals;



  // Mapping from owner to number of owned token

  mapping (address => uint256) private _ownedTokensCount;



  // Mapping from owner to operator approvals

  mapping (address => mapping (address => bool)) private _operatorApprovals;



  bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

  /*

   * 0x80ac58cd ===

   *   bytes4(keccak256('balanceOf(address)')) ^

   *   bytes4(keccak256('ownerOf(uint256)')) ^

   *   bytes4(keccak256('approve(address,uint256)')) ^

   *   bytes4(keccak256('getApproved(uint256)')) ^

   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^

   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^

   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^

   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))

   */



  function initialize()

    public

    initializer

  {

    ERC165.initialize();



    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721);

  }



  function _hasBeenInitialized() internal view returns (bool) {

    return supportsInterface(_InterfaceId_ERC721);

  }



  /**

   * @dev Gets the balance of the specified address

   * @param owner address to query the balance of

   * @return uint256 representing the amount owned by the passed address

   */

  function balanceOf(address owner) public view returns (uint256) {

    require(owner != address(0));

    return _ownedTokensCount[owner];

  }



  /**

   * @dev Gets the owner of the specified token ID

   * @param tokenId uint256 ID of the token to query the owner of

   * @return owner address currently marked as the owner of the given token ID

   */

  function ownerOf(uint256 tokenId) public view returns (address) {

    address owner = _tokenOwner[tokenId];

    require(owner != address(0));

    return owner;

  }



  /**

   * @dev Approves another address to transfer the given token ID

   * The zero address indicates there is no approved address.

   * There can only be one approved address per token at a given time.

   * Can only be called by the token owner or an approved operator.

   * @param to address to be approved for the given token ID

   * @param tokenId uint256 ID of the token to be approved

   */

  function approve(address to, uint256 tokenId) public {

    address owner = ownerOf(tokenId);

    require(to != owner);

    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



    _tokenApprovals[tokenId] = to;

    emit Approval(owner, to, tokenId);

  }



  /**

   * @dev Gets the approved address for a token ID, or zero if no address set

   * Reverts if the token ID does not exist.

   * @param tokenId uint256 ID of the token to query the approval of

   * @return address currently approved for the given token ID

   */

  function getApproved(uint256 tokenId) public view returns (address) {

    require(_exists(tokenId));

    return _tokenApprovals[tokenId];

  }



  /**

   * @dev Sets or unsets the approval of a given operator

   * An operator is allowed to transfer all tokens of the sender on their behalf

   * @param to operator address to set the approval

   * @param approved representing the status of the approval to be set

   */

  function setApprovalForAll(address to, bool approved) public {

    require(to != msg.sender);

    _operatorApprovals[msg.sender][to] = approved;

    emit ApprovalForAll(msg.sender, to, approved);

  }



  /**

   * @dev Tells whether an operator is approved by a given owner

   * @param owner owner address which you want to query the approval of

   * @param operator operator address which you want to query the approval of

   * @return bool whether the given operator is approved by the given owner

   */

  function isApprovedForAll(

    address owner,

    address operator

  )

    public

    view

    returns (bool)

  {

    return _operatorApprovals[owner][operator];

  }



  /**

   * @dev Transfers the ownership of a given token ID to another address

   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

  */

  function transferFrom(

    address from,

    address to,

    uint256 tokenId

  )

    public

  {

    require(_isApprovedOrOwner(msg.sender, tokenId));

    require(to != address(0));



    _clearApproval(from, tokenId);

    _removeTokenFrom(from, tokenId);

    _addTokenTo(to, tokenId);



    emit Transfer(from, to, tokenId);

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   *

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

  */

  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId

  )

    public

  {

    // solium-disable-next-line arg-overflow

    safeTransferFrom(from, to, tokenId, "");

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

   * @param _data bytes data to send along with a safe transfer check

   */

  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId,

    bytes _data

  )

    public

  {

    transferFrom(from, to, tokenId);

    // solium-disable-next-line arg-overflow

    require(_checkAndCallSafeTransfer(from, to, tokenId, _data));

  }



  /**

   * @dev Returns whether the specified token exists

   * @param tokenId uint256 ID of the token to query the existence of

   * @return whether the token exists

   */

  function _exists(uint256 tokenId) internal view returns (bool) {

    address owner = _tokenOwner[tokenId];

    return owner != address(0);

  }



  /**

   * @dev Returns whether the given spender can transfer a given token ID

   * @param spender address of the spender to query

   * @param tokenId uint256 ID of the token to be transferred

   * @return bool whether the msg.sender is approved for the given token ID,

   *  is an operator of the owner, or is the owner of the token

   */

  function _isApprovedOrOwner(

    address spender,

    uint256 tokenId

  )

    internal

    view

    returns (bool)

  {

    address owner = ownerOf(tokenId);

    // Disable solium check because of

    // https://github.com/duaraghav8/Solium/issues/175

    // solium-disable-next-line operator-whitespace

    return (

      spender == owner ||

      getApproved(tokenId) == spender ||

      isApprovedForAll(owner, spender)

    );

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param to The address that will own the minted token

   * @param tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address to, uint256 tokenId) internal {

    require(to != address(0));

    _addTokenTo(to, tokenId);

    emit Transfer(address(0), to, tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    _clearApproval(owner, tokenId);

    _removeTokenFrom(owner, tokenId);

    emit Transfer(owner, address(0), tokenId);

  }



  /**

   * @dev Internal function to clear current approval of a given token ID

   * Reverts if the given address is not indeed the owner of the token

   * @param owner owner of the token

   * @param tokenId uint256 ID of the token to be transferred

   */

  function _clearApproval(address owner, uint256 tokenId) internal {

    require(ownerOf(tokenId) == owner);

    if (_tokenApprovals[tokenId] != address(0)) {

      _tokenApprovals[tokenId] = address(0);

    }

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * @param to address representing the new owner of the given token ID

   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function _addTokenTo(address to, uint256 tokenId) internal {

    require(_tokenOwner[tokenId] == address(0));

    _tokenOwner[tokenId] = to;

    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * @param from address representing the previous owner of the given token ID

   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function _removeTokenFrom(address from, uint256 tokenId) internal {

    require(ownerOf(tokenId) == from);

    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);

    _tokenOwner[tokenId] = address(0);

  }



  /**

   * @dev Internal function to invoke `onERC721Received` on a target address

   * The call is not executed if the target address is not a contract

   * @param from address representing the previous owner of the given token ID

   * @param to target address that will receive the tokens

   * @param tokenId uint256 ID of the token to be transferred

   * @param _data bytes optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function _checkAndCallSafeTransfer(

    address from,

    address to,

    uint256 tokenId,

    bytes _data

  )

    internal

    returns (bool)

  {

    if (!to.isContract()) {

      return true;

    }

    bytes4 retval = IERC721Receiver(to).onERC721Received(

      msg.sender, from, tokenId, _data);

    return (retval == _ERC721_RECEIVED);

  }



  uint256[50] private ______gap;

}



/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Enumerable is Initializable, IERC721 {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(

    address owner,

    uint256 index

  )

    public

    view

    returns (uint256 tokenId);



  function tokenByIndex(uint256 index) public view returns (uint256);

}



contract ERC721Enumerable is Initializable, ERC165, ERC721, IERC721Enumerable {

  // Mapping from owner to list of owned token IDs

  mapping(address => uint256[]) private _ownedTokens;



  // Mapping from token ID to index of the owner tokens list

  mapping(uint256 => uint256) private _ownedTokensIndex;



  // Array with all token ids, used for enumeration

  uint256[] private _allTokens;



  // Mapping from token id to position in the allTokens array

  mapping(uint256 => uint256) private _allTokensIndex;



  bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;

  /**

   * 0x780e9d63 ===

   *   bytes4(keccak256('totalSupply()')) ^

   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

   *   bytes4(keccak256('tokenByIndex(uint256)'))

   */



  /**

   * @dev Constructor function

   */

  function initialize() public initializer {

    require(ERC721._hasBeenInitialized());



    // register the supported interface to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721Enumerable);

  }



  function _hasBeenInitialized() internal view returns (bool) {

    return supportsInterface(_InterfaceId_ERC721Enumerable);

  }



  /**

   * @dev Gets the token ID at a given index of the tokens list of the requested owner

   * @param owner address owning the tokens list to be accessed

   * @param index uint256 representing the index to be accessed of the requested tokens list

   * @return uint256 token ID at the given index of the tokens list owned by the requested address

   */

  function tokenOfOwnerByIndex(

    address owner,

    uint256 index

  )

    public

    view

    returns (uint256)

  {

    require(index < balanceOf(owner));

    return _ownedTokens[owner][index];

  }



  /**

   * @dev Gets the total amount of tokens stored by the contract

   * @return uint256 representing the total amount of tokens

   */

  function totalSupply() public view returns (uint256) {

    return _allTokens.length;

  }



  /**

   * @dev Gets the token ID at a given index of all the tokens in this contract

   * Reverts if the index is greater or equal to the total number of tokens

   * @param index uint256 representing the index to be accessed of the tokens list

   * @return uint256 token ID at the given index of the tokens list

   */

  function tokenByIndex(uint256 index) public view returns (uint256) {

    require(index < totalSupply());

    return _allTokens[index];

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * @param to address representing the new owner of the given token ID

   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function _addTokenTo(address to, uint256 tokenId) internal {

    super._addTokenTo(to, tokenId);

    uint256 length = _ownedTokens[to].length;

    _ownedTokens[to].push(tokenId);

    _ownedTokensIndex[tokenId] = length;

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * @param from address representing the previous owner of the given token ID

   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function _removeTokenFrom(address from, uint256 tokenId) internal {

    super._removeTokenFrom(from, tokenId);



    // To prevent a gap in the array, we store the last token in the index of the token to delete, and

    // then delete the last slot.

    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);

    uint256 lastToken = _ownedTokens[from][lastTokenIndex];



    _ownedTokens[from][tokenIndex] = lastToken;

    // This also deletes the contents at the last position of the array

    _ownedTokens[from].length--;



    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to

    // be zero. Then we can make sure that we will remove tokenId from the ownedTokens list since we are first swapping

    // the lastToken to the first position, and then dropping the element placed in the last position of the list



    _ownedTokensIndex[tokenId] = 0;

    _ownedTokensIndex[lastToken] = tokenIndex;

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param to address the beneficiary that will own the minted token

   * @param tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address to, uint256 tokenId) internal {

    super._mint(to, tokenId);



    _allTokensIndex[tokenId] = _allTokens.length;

    _allTokens.push(tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param owner owner of the token to burn

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    super._burn(owner, tokenId);



    // Reorg all tokens array

    uint256 tokenIndex = _allTokensIndex[tokenId];

    uint256 lastTokenIndex = _allTokens.length.sub(1);

    uint256 lastToken = _allTokens[lastTokenIndex];



    _allTokens[tokenIndex] = lastToken;

    _allTokens[lastTokenIndex] = 0;



    _allTokens.length--;

    _allTokensIndex[tokenId] = 0;

    _allTokensIndex[lastToken] = tokenIndex;

  }



  uint256[50] private ______gap;

}



/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Metadata is Initializable, IERC721 {

  function name() external view returns (string);

  function symbol() external view returns (string);

  function tokenURI(uint256 tokenId) public view returns (string);

}



contract ERC721Metadata is Initializable, ERC165, ERC721, IERC721Metadata {

  // Token name

  string internal _name;



  // Token symbol

  string internal _symbol;



  // Optional mapping for token URIs

  mapping(uint256 => string) private _tokenURIs;



  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  /**

   * 0x5b5e139f ===

   *   bytes4(keccak256('name()')) ^

   *   bytes4(keccak256('symbol()')) ^

   *   bytes4(keccak256('tokenURI(uint256)'))

   */



  /**

   * @dev Constructor function

   */

  function initialize(string name, string symbol) public initializer {

    require(ERC721._hasBeenInitialized());



    _name = name;

    _symbol = symbol;



    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(InterfaceId_ERC721Metadata);

  }



  function _hasBeenInitialized() internal view returns (bool) {

    return supportsInterface(InterfaceId_ERC721Metadata);

  }



  /**

   * @dev Gets the token name

   * @return string representing the token name

   */

  function name() external view returns (string) {

    return _name;

  }



  /**

   * @dev Gets the token symbol

   * @return string representing the token symbol

   */

  function symbol() external view returns (string) {

    return _symbol;

  }



  /**

   * @dev Returns an URI for a given token ID

   * Throws if the token ID does not exist. May return an empty string.

   * @param tokenId uint256 ID of the token to query

   */

  function tokenURI(uint256 tokenId) public view returns (string) {

    require(_exists(tokenId));

    return _tokenURIs[tokenId];

  }



  /**

   * @dev Internal function to set the token URI for a given token

   * Reverts if the token ID does not exist

   * @param tokenId uint256 ID of the token to set its URI

   * @param uri string URI to assign

   */

  function _setTokenURI(uint256 tokenId, string uri) internal {

    require(_exists(tokenId));

    _tokenURIs[tokenId] = uri;

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param owner owner of the token to burn

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    super._burn(owner, tokenId);



    // Clear metadata (if any)

    if (bytes(_tokenURIs[tokenId]).length != 0) {

      delete _tokenURIs[tokenId];

    }

  }



  uint256[50] private ______gap;

}





contract MinterRole is Initializable {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  function initialize(address sender) public initializer {

    if (!isMinter(sender)) {

      _addMinter(sender);

    }

  }



  modifier onlyMinter() {

    require(isMinter(msg.sender));

    _;

  }



  function isMinter(address account) public view returns (bool) {

    return minters.has(account);

  }



  function addMinter(address account) public onlyMinter {

    _addMinter(account);

  }



  function renounceMinter() public {

    _removeMinter(msg.sender);

  }



  function _addMinter(address account) internal {

    minters.add(account);

    emit MinterAdded(account);

  }



  function _removeMinter(address account) internal {

    minters.remove(account);

    emit MinterRemoved(account);

  }



  uint256[50] private ______gap;

}



/**

 * @title ERC721MetadataMintable

 * @dev ERC721 minting logic with metadata

 */

contract ERC721MetadataMintable is Initializable, ERC721, ERC721Metadata, MinterRole {

  function initialize(address sender) public initializer {

    require(ERC721._hasBeenInitialized());

    require(ERC721Metadata._hasBeenInitialized());

    MinterRole.initialize(sender);

  }



  /**

   * @dev Function to mint tokens

   * @param to The address that will receive the minted tokens.

   * @param tokenId The token id to mint.

   * @param tokenURI The token URI of the minted token.

   * @return A boolean that indicates if the operation was successful.

   */

  function mintWithTokenURI(

    address to,

    uint256 tokenId,

    string tokenURI

  )

    public

    onlyMinter

    returns (bool)

  {

    _mint(to, tokenId);

    _setTokenURI(tokenId, tokenURI);

    return true;

  }



  uint256[50] private ______gap;

}





contract PauserRole is Initializable {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  function initialize(address sender) public initializer {

    if (!isPauser(sender)) {

      _addPauser(sender);

    }

  }



  modifier onlyPauser() {

    require(isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    _addPauser(account);

  }



  function renouncePauser() public {

    _removePauser(msg.sender);

  }



  function _addPauser(address account) internal {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }



  uint256[50] private ______gap;

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Initializable, PauserRole {

  event Paused();

  event Unpaused();



  bool private _paused = false;



  function initialize(address sender) public initializer {

    PauserRole.initialize(sender);

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyPauser whenNotPaused {

    _paused = true;

    emit Paused();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused();

  }



  uint256[50] private ______gap;

}



/**

 * @title ERC721 Non-Fungible Pausable token

 * @dev ERC721 modified with pausable transfers.

 **/

contract ERC721Pausable is Initializable, ERC721, Pausable {

  function initialize(address sender) public initializer {

    require(ERC721._hasBeenInitialized());

    Pausable.initialize(sender);

  }



  function approve(

    address to,

    uint256 tokenId

  )

    public

    whenNotPaused

  {

    super.approve(to, tokenId);

  }



  function setApprovalForAll(

    address to,

    bool approved

  )

    public

    whenNotPaused

  {

    super.setApprovalForAll(to, approved);

  }



  function transferFrom(

    address from,

    address to,

    uint256 tokenId

  )

    public

    whenNotPaused

  {

    super.transferFrom(from, to, tokenId);

  }



  uint256[50] private ______gap;

}



/**

 * @title Standard ERC721 token, with minting and pause functionality.

 *

 */

contract StandaloneERC721

  is Initializable, ERC721, ERC721Enumerable, ERC721Metadata, ERC721MetadataMintable, ERC721Pausable

{

  function initialize(string name, string symbol, address[] minters, address[] pausers) public initializer {

    ERC721.initialize();

    ERC721Enumerable.initialize();

    ERC721Metadata.initialize(name, symbol);



    // Initialize the minter and pauser roles, and renounce them

    ERC721MetadataMintable.initialize(address(this));

    renounceMinter();



    ERC721Pausable.initialize(address(this));

    renouncePauser();



    // Add the requested minters and pausers (this can be done after renouncing since

    // these are the internal calls)

    for (uint256 i = 0; i < minters.length; ++i) {

      _addMinter(minters[i]);

    }



    for (i = 0; i < pausers.length; ++i) {

      _addPauser(pausers[i]);

    }

  }

}





contract CryptofieldBase is Initializable, Ownable {

    bytes32 horseType;

    bytes32 public gender; // First horse is a male.

    bytes32[2] private gen;



    uint256 constant GENOTYPE_CAP = 268;

    uint256 bloodlineCounter;



    address breedingContract;

    HorseData public horseDataContract;



    /*

    @dev horseHash stores basic horse information in a hash returned by IPFS.

    */

    struct Horse {

        address buyer;



        uint256 genotype;

        uint256 baseValue;

        uint256 timestamp;

        uint256 lastTimeSold;

        uint256 amountOfTimesSold;



        string horseHash;



        bytes32 bloodline;

        bytes32 sex;

        bytes32 hType;

    }



    mapping(uint256 => Horse) public horses;



    event LogHorseSell(uint256 _horseId, uint256 _amountOfTimesSold);

    event LogOffspringBuy(address _buyer, uint256 _timestamp, uint256 _tokenId);

    event LogGOPCreated(address _buyer, uint256 _timestamp, uint256 _tokenId);



    modifier onlyBreeding() {

        require(msg.sender == breedingContract, "CB notAuthorized");

        _;

    }



    function initialize(address _owner) public initializer {

        Ownable.initialize(_owner);



        gender = bytes32("F");

        gen = [

            bytes32("M"),

            bytes32("F")

        ];

    }



    function buyGOP(

        address _buyer,

        string _horseHash,

        uint256 _tokenId,

        uint256 _batchNumber,

        uint256 _baseValue

    ) internal {

        require(bloodlineCounter <= 38000, "GOP cap met");



        // Pick the gender and type.

        if(gender == gen[0]) {

            gender = gen[1]; // Female

            horseType = bytes32("Filly");

        } else {

            gender = gen[0]; // Male

            horseType = bytes32("Colt");

        }



        bytes32 bloodline = horseDataContract.getBloodline(_batchNumber);

        uint256 genotype = horseDataContract.getGenotype(_batchNumber);



        Horse memory h;

        h.timestamp = now;

        h.buyer = _buyer;

        h.horseHash = _horseHash;

        h.sex = gender;

        h.baseValue = _baseValue;

        h.genotype = genotype;

        h.bloodline = bloodline;

        h.hType = horseType;



        horses[_tokenId] = h;



        bloodlineCounter += 1;



        emit LogGOPCreated(_buyer, now, _tokenId);

    }



    /*

    @dev Called internally, should only be called by 'Token'.

    */

    function buyOffspring(

        address _buyer,

        string _horseHash,

        uint256 _tokenId,

        uint256 _maleParent,

        uint256 _femaleParent

        ) internal {

        bytes32 randGender;



        // Creates a 'random' gender.

        // This won't affect Genesis horses.

        if(_getRandGender() == 0) {

            randGender = gen[0]; // Male

            horseType = bytes32("Colt");

        } else {

            randGender = gen[1];

            horseType = bytes32("Filly"); // Female

        }



        Horse storage male = horses[_maleParent];

        Horse storage female = horses[_femaleParent];



        // Change type of parents

        male.hType = bytes32("Stallion");

        female.hType = bytes32("Mare");



        Horse memory horse;

        horse.buyer = _buyer;

        // The use of 'now' here shouldn't be a concern since that's only used for the timestamp of a horse

        // which really doesn't have much effect on the horse itself.

        horse.timestamp = now;

        horse.horseHash = _horseHash;

        horse.sex = randGender;

        horse.genotype = _getType(male.genotype, female.genotype);

        horse.bloodline = horseDataContract.getBloodlineFromParents(male.bloodline, female.bloodline);

        horse.hType = horseType;



        horses[_tokenId] = horse;



        emit LogOffspringBuy(_buyer, now, _tokenId);

    }



    // Called when creating a custom horse.

    function createHorse(

        address _buyer,

        string _hash,

        uint256 _tokenId,

        uint256 _baseValue,

        uint256 _genotype,

        bytes32 _gender

    ) internal {

        require(_genotype >= 1 && _genotype <= 10, "Gen out of bounds");

        require(bloodlineCounter <= 38000, "GOP cap met");



        bytes32 bloodline = horseDataContract.getBloodline(_genotype);



        Horse memory h;

        h.timestamp = now;

        h.buyer = _buyer;

        h.horseHash = _hash;

        h.baseValue = _baseValue;

        h.genotype = _genotype;

        h.bloodline = bloodline;



        if(_gender == bytes32("Male")) {

            h.sex = gen[0];

            h.hType = bytes32("Colt");

        } else {

            h.sex = gen[1];

            h.hType = bytes32("Filly");

        }



        horses[_tokenId] = h;



        bloodlineCounter += 1;



        emit LogGOPCreated(_buyer, now, _tokenId);

    }



    /*

    @dev Returns data from a horse.

    */

    function getHorseData(

        uint256 _horse

    )

    public

    view

    returns(string, bytes32, uint256, uint256, uint256, uint256, bytes32, bytes32) {

        Horse memory h = horses[_horse];



        return (

            h.horseHash,

            h.sex,

            h.baseValue,

            h.timestamp,

            h.amountOfTimesSold,

            h.genotype,

            h.bloodline,

            h.hType

        );

    }



    function getHorseSex(uint256 _horse) public view returns(bytes32) {

        return horses[_horse].sex;

    }



    function getTimestamp(uint256 _horse) public view returns(uint256) {

        return horses[_horse].timestamp;

    }



    function getBaseValue(uint256 _horse) public view returns(uint256) {

        return horses[_horse].baseValue;

    }



    function lastHorseSex() public view returns(bytes32) {

        return gender;

    }



    function getBloodline(uint256 _horse) public view returns(bytes32) {

        return horses[_horse].bloodline;

    }



    /*

    @dev Adds 1 to the amount of times a horse has been sold.

    @dev Adds unix timestamp of the date the horse was sold.

    */

    function horseSold(uint256 _horseId) internal {

        Horse storage horse = horses[_horseId];

        horse.amountOfTimesSold += 1;

        horse.lastTimeSold = now;



        emit LogHorseSell(_horseId, horse.amountOfTimesSold);

    }



    /* RESTRICTED FUNCTIONS /*



    /*

    @dev Sets the address of the breeding contract.

    */

    function setBreedingAddr(address _address) public onlyOwner() {

        breedingContract = _address;

    }



    /*

    @dev Sets address for HorseData contract

    */

    function setHorseDataAddr(address _address) public onlyOwner() {

        horseDataContract = HorseData(_address);

    }



    function setHorseHash(uint256 _horse, string _hash) public onlyOwner() {

        horses[_horse].horseHash = _hash;

    }



    /*

    @dev Changes the baseValue of a horse, this is useful when creating offspring and should be

    allowed only by the breeding contract.

    */

    function setBaseValue(uint256 _horseId, uint256 _baseValue) external onlyBreeding() {

        Horse storage h = horses[_horseId];

        h.baseValue = _baseValue;

    }



    /* PRIVATE FUNCTIONS */



    /*

    @dev Gets a random number between 1 and 'max';

    */

    function _getRand(uint256 _max) private view returns(uint256) {

        return uint256(blockhash(block.number - 1)) % _max + 1;

    }



    /*

    @dev Gets random number between 1 and 50.

    */

    function _getRand() private view returns(uint256) {

        return uint256(blockhash(block.number - 1)) % 50 + 1;

    }



    /*

    @dev This function returns either 0 or 1, this can be used to select a 'random' gender.

    */

    function _getRandGender() private view returns(uint256) {

        return uint256(blockhash(block.number - 1)) % 2;

    }



    /*

    @dev Calculates the genotype for an offspring based on the type of the parents.

    @dev It returns the Genotype for an offspring unless it is greater than the cap, otherwise it returns the CAP.

    */

    function _getType(uint256 _maleGT, uint256 _femaleGT) private pure returns(uint256) {

        // We're not going to run into overflows here since we have a genotype cap.

        uint256 geno = _maleGT + _femaleGT;

        if(geno > GENOTYPE_CAP) return GENOTYPE_CAP;

        return geno;

    }





    /* ORACLIZE IMPLEMENTATION */



    /* @dev Converts 'uint' to 'string' */

    function uint2str(uint256 i) internal pure returns(string) {

        if (i == 0) return "0";

        uint256 j = i;

        uint256 len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint256 k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }

}



contract Token is StandaloneERC721, CryptofieldBase {

    address gopcreator;

    address[] private minters;

    address[] private pausers;



    function initialize(address _owner) public initializer {

        minters.push(_owner);

        pausers.push(_owner);



        StandaloneERC721.initialize("Zed Token", "ZT", minters, pausers);

        CryptofieldBase.initialize(_owner);

    }



    modifier ownerOfToken(uint256 _tokenId) {

        require(ownerOf(_tokenId) == msg.sender, "Not owner");

        _;

    }



    modifier onlyApprovedOrOwner(uint256 _tokenId) {

        require(_isApprovedOrOwner(msg.sender, _tokenId), "Not owner or approved");

        _;

    }



    /*

    @dev Simply creates a new token and calls base contract to add the horse information.

    @dev Used for offsprings mostly, called from 'Breeding'

    */

    function createOffspring(address _owner, string _hash, uint256 _male, uint256 _female)

    external

    payable

    onlyBreeding()

    returns(uint256) {

        uint256 tokenId = totalSupply();



        _mint(_owner, tokenId);

        buyOffspring(_owner, _hash, tokenId, _male, _female);



        return tokenId;

    }



    /*

    @dev Creates a G1P.

    @dev Mostly used for Private and public sales to calculate genotypes.

    */

    function mintToken(address _owner, string _hash, uint256 _batchNumber)

    public

    payable

    returns(uint256) {

        require(msg.sender == gopcreator, "T notAuthorized");

        uint256 tokenId = totalSupply();

        uint256 baseValue = horseDataContract.getBaseValue(_batchNumber);



        string memory uri = _uriStringConcat("https://api.zed.run/api/v1/horses/get/", uint2str(tokenId));



        _mint(_owner, tokenId);

        _setTokenURI(tokenId, uri);

        buyGOP(_owner, _hash, tokenId, _batchNumber, baseValue);



        return tokenId;

    }



    function mintCustomHorse(address _owner, string _hash, uint256 _genotype, bytes32 _gender)

    public

    returns(uint256) {

        require(msg.sender == gopcreator, "T notAuthorized");



        uint256 tokenId = totalSupply();

        uint256 baseValue = horseDataContract.getBaseValue(_genotype);



        string memory uri = _uriStringConcat("https://api.zed.run/api/v1/horses/get/", uint2str(tokenId));



        _mint(_owner, tokenId);

        _setTokenURI(tokenId, uri);

        createHorse(_owner, _hash, tokenId, baseValue, _genotype, _gender);



        return tokenId;

    }



    // Check if an address has been granted approval of a token.

    function isTokenApproved(address _spender, uint256 _tokenId) public view returns(bool) {

        return _isApprovedOrOwner(_spender, _tokenId);

    }



    /*

    @dev Calls the 'horseSold' function after applying the modifier.

    */

    function tokenSold(uint256 _tokenId) external onlyApprovedOrOwner(_tokenId) {

        horseSold(_tokenId);

    }



    /*

    @dev Returns whether a horse exists or not.

    */

    function exists(uint256 _tokenId) public view returns(bool) {

        return _tokenId < totalSupply();

    }



    /*  RESTRICTED  */



    function setGOPCreator(address _addr) public onlyOwner() {

        gopcreator = _addr;

    }



    /* INTERNAL */

    function _uriStringConcat(string _a, string _b) internal pure returns(string) {

        return string(abi.encodePacked(_a, _b));

    }



    function uint2str(uint i) internal pure returns(string) {

        if (i == 0) return "0";



        uint j = i;

        uint len;



        while (j != 0){

            len++;

            j /= 10;

        }



        bytes memory bstr = new bytes(len);

        uint k = len - 1;



        while(i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }



        return string(bstr);

    }

}





contract Auctions is Token {

    SaleAuction nft;



    event LogAuctionCreated(uint256 _auctionId);



    function initialize(address _owner) public initializer {

        Token.initialize(_owner);

        Ownable.initialize(_owner);

    }



    function createAuction(uint256 _duration, uint256 _horseId, uint256 _minimum) public payable {

        require(msg.sender == ownerOf(_horseId), "notTokenOwner");



        safeTransferFrom(msg.sender, nft, _horseId); // New owner is the contract.



        uint256 id = nft.createUserAuction.value(msg.value)(msg.sender, _duration, _horseId, _minimum);

        emit LogAuctionCreated(id);

    }



    function setSaleAuctionAddress(address _nft) public onlyOwner() {

        nft = SaleAuction(_nft);

    }

}



// This api is currently targeted at 0.4.22 to 0.4.25 (stable builds), please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}



contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

}



library Buffer {

    struct buffer {

        bytes buf;

        uint capacity;

    }



    function init(buffer memory buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);

        // Allocate space for the buffer data

        buf.capacity = capacity;

        assembly {

            let ptr := mload(0x40)

            mstore(buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;

        init(buf, capacity);

        append(buf, oldbuf);

    }



    function max(uint a, uint b) private pure returns(uint) {

        if(a > b) {

            return a;

        }

        return b;

    }



    /**

     * @dev Appends a byte array to the end of the buffer. Resizes if doing so

     *      would exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {

        if(data.length + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, data.length) * 2);

        }



        uint dest;

        uint src;

        uint len = data.length;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Start address = buffer address + buffer length + sizeof(buffer length)

            dest := add(add(bufptr, buflen), 32)

            // Update buffer length

            mstore(bufptr, add(buflen, mload(data)))

            src := add(data, 32)

        }



        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }



        return buf;

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, uint8 data) internal pure {

        if(buf.buf.length + 1 > buf.capacity) {

            resize(buf, buf.capacity * 2);

        }



        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length)

            let dest := add(add(bufptr, buflen), 32)

            mstore8(dest, data)

            // Update buffer length

            mstore(bufptr, add(buflen, 1))

        }

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

        if(len + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, len) * 2);

        }



        uint mask = 256 ** len - 1;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length) + len

            let dest := add(add(bufptr, buflen), len)

            mstore(dest, or(and(mload(dest), not(mask)), data))

            // Update buffer length

            mstore(bufptr, add(buflen, len))

        }

        return buf;

    }

}



library CBOR {

    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {

        if(value <= 23) {

            buf.append(uint8((major << 5) | value));

        } else if(value <= 0xFF) {

            buf.append(uint8((major << 5) | 24));

            buf.appendInt(value, 1);

        } else if(value <= 0xFFFF) {

            buf.append(uint8((major << 5) | 25));

            buf.appendInt(value, 2);

        } else if(value <= 0xFFFFFFFF) {

            buf.append(uint8((major << 5) | 26));

            buf.appendInt(value, 4);

        } else if(value <= 0xFFFFFFFFFFFFFFFF) {

            buf.append(uint8((major << 5) | 27));

            buf.appendInt(value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {

        buf.append(uint8((major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {

        encodeType(buf, MAJOR_TYPE_INT, value);

    }



    function encodeInt(Buffer.buffer memory buf, int value) internal pure {

        if(value >= 0) {

            encodeType(buf, MAJOR_TYPE_INT, uint(value));

        } else {

            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));

        }

    }



    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {

        encodeType(buf, MAJOR_TYPE_BYTES, value.length);

        buf.append(value);

    }



    function encodeString(Buffer.buffer memory buf, string value) internal pure {

        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);

        buf.append(bytes(value));

    }



    function startArray(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);

    }

}



/*

End solidity-cborutils

 */



contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Android = 0x40;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_consensys = 161;



    OraclizeAddrResolverI OAR;



    OraclizeI oraclize;

    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))

            oraclize_setNetwork(networkID_auto);



        if(address(oraclize) != OAR.getAddress())

            oraclize = OraclizeI(OAR.getAddress());



        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();

      networkID; // silence the warning and remain backwards compatible

    }

    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) public {

      return;

      // Following should never be reached with a preceding return, however

      // this is just a placeholder function, ideally meant to be defined in

      // child contract when proofs are used

      myid; result; proof; // Silence compiler warnings

      oraclize = OraclizeI(0); // Additional compiler silence about making function pure/view.

    }



    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);

    }



    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);

    }



    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(0, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(timestamp, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(0, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();

    }

    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);

    }

    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) view internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            iaddr *= 256;

            b1 = uint160(tmp[i]);

            b2 = uint160(tmp[i+1]);

            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;

            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;

            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

            iaddr += (b1*16+b2);

        }

        return address(iaddr);

    }



    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        for (uint i = 0; i < minLength; i ++)

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }



    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if(h.length < 1 || n.length < 1 || (n.length > h.length))

            return -1;

        else if(h.length > (2**128 -1))

            return -1;

        else

        {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i ++)

            {

                if (h[i] == n[0])

                {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])

                    {

                        subindex++;

                    }

                    if(subindex == n.length)

                        return int(i);

                }

            }

            return -1;

        }

    }



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }



    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i=0; i<bresult.length; i++){

            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                if (decimals){

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(bresult[i]) - 48;

            } else if (bresult[i] == 46) decimals = true;

        }

        if (_b > 0) mint *= 10**_b;

        return mint;

    }



    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }



    using CBOR for Buffer.buffer;

    function stra2cbor(string[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeString(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeBytes(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));

        // Convert from seconds to ledger timer ticks

        _delay *= 10;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            // the following variables can be relaxed

            // check relaxed random contract under ethereum-examples repo

            // for an idea on how to override and replace comit hash vars

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes memory delay = new bytes(32);

        assembly {

            mstore(add(delay, 0x20), _delay)

        }



        bytes memory delay_bytes8 = new bytes(8);

        copyBytes(delay, 24, 8, delay_bytes8, 0);



        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];

        bytes32 queryId = oraclize_query("random", args, _customGasLimit);



        bytes memory delay_bytes8_left = new bytes(8);



        assembly {

            let x := mload(add(delay_bytes8, 0x20))

            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))



        }



        oraclize_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));

        return queryId;

    }



    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;

    }



    mapping(bytes32=>bytes32) oraclize_randomDS_args;

    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;



    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;

        address signer;



        bytes32 sigr;

        bytes32 sigs;



        bytes memory sigr_ = new bytes(32);

        uint offset = 4+(uint(dersig[3]) - 0x20);

        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);



        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }





        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);

        if (address(keccak256(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(keccak256(pubkey)) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;



        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);

        copyBytes(proof, sig2offset, sig2.length, sig2, 0);



        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);



        bytes memory tosign2 = new bytes(1+65+32);

        tosign2[0] = byte(1); //role

        copyBytes(proof, sig2offset-65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);



        if (sigok == false) return false;





        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";



        bytes memory tosign3 = new bytes(1+65);

        tosign3[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign3, 1);



        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig3.length, sig3, 0);



        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);



        return sigok;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);



        _;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;



        return 0;

    }



    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;



        require(prefix.length == n_random_bytes);



        for (uint256 i=0; i< n_random_bytes; i++) {

            if (content[i] != prefix[i]) match_ = false;

        }



        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){



        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(context_name, queryId)))))) return false;



        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);



        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;



        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);



        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);



        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;





        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;



        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }



        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;



        // Buffer too small

        require(to.length >= minLength); // Should be a better way?



        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint i = 32 + fromOffset;

        uint j = 32 + toOffset;



        while (i < (32 + fromOffset + length)) {

            assembly {

                let tmp := mload(add(from, i))

                mstore(add(to, j), tmp)

            }

            i += 32;

            j += 32;

        }



        return to;

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    // Duplicate Solidity's ecrecover, but catching the CALL return value

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {

        // We do our own memory management here. Solidity uses memory offset

        // 0x40 to store the current end of memory. We write past it (as

        // writes are memory extensions), but don't update the offset so

        // Solidity will reuse it. The memory used here is only needed for

        // this context.



        // FIXME: inline assembly can't access return values

        bool ret;

        address addr;



        assembly {

            let size := mload(0x40)

            mstore(size, hash)

            mstore(add(size, 32), v)

            mstore(add(size, 64), r)

            mstore(add(size, 96), s)



            // NOTE: we can reuse the request memory because we deal with

            //       the return code

            ret := call(3000, 1, 0, size, 128, size, 32)

            addr := mload(size)

        }



        return (ret, addr);

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        if (sig.length != 65)

          return (false, 0);



        // The signature format is a compact form of:

        //   {bytes32 r}{bytes32 s}{uint8 v}

        // Compact means, uint8 is not padded to 32 bytes.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))



            // Here we are loading the last 32 bytes. We exploit the fact that

            // 'mload' will pad with zeroes if we overread.

            // There is no 'mload8' to do this, but that would be nicer.

            v := byte(0, mload(add(sig, 96)))



            // Alternative solution:

            // 'byte' is not working due to the Solidity parser, so lets

            // use the second best option, 'and'

            // v := and(mload(add(sig, 65)), 255)

        }



        // albeit non-transactional signatures are not specified by the YP, one would expect it

        // to match the YP range of [27, 28]

        //

        // geth uses [0, 1] and some clients have followed. This might change, see:

        //  https://github.com/ethereum/go-ethereum/issues/2053

        if (v < 27)

          v += 27;



        if (v != 27 && v != 28)

            return (false, 0);



        return safer_ecrecover(hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }



}

// </ORACLIZE_API>



/*

@description Contract in charge of tracking availability of male horses in Stud.

*/

contract StudService is Auctions, usingOraclize {

    uint256[3] private ALLOWED_TIMEFRAMES;



    uint256[] horsesInStud;



    struct StudInfo {

        bool inStud;



        uint256 matingPrice;

        uint256 duration;

    }



    mapping(uint256 => StudInfo) internal studs;

    mapping(uint256 => uint256) internal horseIndex;



    /*

    @dev We only remove the horse from the mapping ONCE the '__callback' is called, this is for a reason.

    For Studs we use Oraclize as a service for queries in the future but we also have a function

    to manually remove the horse from stud but this does not cancel the

    query that was already sent, so the horse is blocked from being in Stud again until the

    callback is called and effectively removing it from stud.



    Main case: User puts horse in stud, horse is manually removed, horse is put in stud

    again thus creating another query, this time the user decides to leave the horse

    for the whole period of time but the first query which couldn't be cancelled is

    executed, calling the '__callback' function and removing the horse from Stud and leaving

    yet another query in air.

    */



    mapping(uint256 => bool) internal currentlyInStud;



    modifier onlyHorseOwner(uint256 _id) {

        require(msg.sender == ownerOf(_id), "Not owner of horse");

        _;

    }



    function initialize(address _owner) public initializer {

        Auctions.initialize(_owner);



        ALLOWED_TIMEFRAMES = [

            259200,

            518400,

            777600

        ];



        // OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

    }



    event LogHorseInStud(uint256 _horseId, uint256 _amount, uint256 _duration);

}





/*

Core contract, it inherits from the last contract.

*/

contract Core is Ownable, StudService {

    function initialize(address _owner) public initializer {

        StudService.initialize(_owner);

        Ownable.initialize(_owner);

    }

}



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract IERC721Receiver {

  /**

   * @notice Handle the receipt of an NFT

   * @dev The ERC721 smart contract calls this function on the recipient

   * after a `safeTransfer`. This function MUST return the function selector,

   * otherwise the caller will revert the transaction. The selector to be

   * returned can be obtained as `this.onERC721Received.selector`. This

   * function MAY throw to revert and reject the transfer.

   * Note: the ERC721 contract address is always the message sender.

   * @param operator The address which called `safeTransferFrom` function

   * @param from The address which previously owned the token

   * @param tokenId The NFT identifier which is being transferred

   * @param data Additional data with no specified format

   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

   */

  function onERC721Received(

    address operator,

    address from,

    uint256 tokenId,

    bytes data

  )

    public

    returns(bytes4);

}





contract ERC721Holder is Initializable, IERC721Receiver {

  function onERC721Received(

    address,

    address,

    uint256,

    bytes

  )

    public

    returns(bytes4)

  {

    return this.onERC721Received.selector;

  }



  uint256[50] private ______gap;

}



/*

Main contract for Auctions, we keep this as a separate contract in case it needs to be replaced

we don't have to mess with Horse ownership in the Core contract.

*/

contract SaleAuction is ERC721Holder, usingOraclize, Ownable {

    using SafeMath for uint256;



    uint256[] auctionIds;

    uint256[] openAuctions;



    Auctions core;



    struct AuctionData {

        address owner;



        bool isOpen;



        uint256 duration;

        uint256 createdAt;

        uint256 maxBid;

        uint256 horse;

        uint256 minimum; // Minimum price to be met to make a bid.



        address maxBidder;

        address[] bidders;

        // Maps each address on this auction to a bid.

        mapping(address => uint256) bids;

        // Maps each address on this auction to a bid time.

        mapping(address => uint256) bidTimes;

        mapping(address => bool) exists;

    }



    mapping(uint256 => AuctionData) internal auctions;



    // Maps an auction ID to an index.

    mapping(uint256 => uint256) private auctionIndex;



    // Maps address to auction

    mapping(address => uint256[]) internal auctionsParticipating;



    // Maps address to auctions created

    mapping(address => uint256[]) internal auctionsCreatedBy;



    event LogBid(address _bidder, uint256 _amount);

    event LogWithdraw(address _user, uint256 _payout);



    function initialize(address _core, address _owner) public initializer {

        Ownable.initialize(_owner);

        core = Auctions(_core);

        // OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

    }



    // External, called from the 'Auctions' contract.

    function createUserAuction(

        address _owner,

        uint256 _duration,

        uint256 _horseId,

        uint256 _minimum

    ) external payable returns(uint256) {

        // Zed's fee is 8% of minimum

        uint256 fee = _minimum.mul(8).div(100);

        uint256 queryPrice = oraclize_getPrice("URL");



        require(msg.value >= fee.add(queryPrice), "SA operationMinimumNotMet");



        uint256 auctionId = auctionIds.push(0) - 1;



        AuctionData storage auction = auctions[auctionId];

        auction.owner = _owner;

        auction.isOpen = true;

        auction.duration = _duration;

        auction.horse = _horseId;

        auction.createdAt = now;

        auction.minimum = _minimum;



        sendAuctionQuery(_duration, auctionId);



        uint256 index = openAuctions.push(auctionId) - 1;

        auctionIndex[auctionId] = index;



        auctionsCreatedBy[_owner].push(auctionId);



        owner().transfer(fee);



        return auctionId;

    }



    /*

    @dev bid function when an auction is created

    */

    function userAuctionBid(uint256 _auctionId) public payable {

        AuctionData storage auction = auctions[_auctionId];



        require(auction.isOpen, "SA auctionClosed");

        // owner can't bid on its own auction.

        require(msg.sender != auction.owner, "SA cantBeOwner");



        // 'newBid' is the current value of an user's bid and the msg.value.

        uint256 newBid = auction.bids[msg.sender].add(msg.value);



        // You can only record another bid if it is higher than the max bid.

        require(newBid > auction.maxBid, "SA lowerBidThanMaximum");



        // We're going to do this 'require' only if the auction has no

        // bids yet.

        if(auction.bidders.length == 0) {

            require(msg.value >= auction.minimum, "SA lowerBidThanMinimum");

        }



        auction.bids[msg.sender] = newBid;

        auction.bidTimes[msg.sender] = now;



        // push to the array of bidders if the address doesn't exist yet.

        if(!auction.exists[msg.sender]) {

            auction.bidders.push(msg.sender);

            auction.exists[msg.sender] = true;



            // Adds to the auctions where the user is participating

            auctionsParticipating[msg.sender].push(_auctionId);

        }



        auction.maxBid = newBid;

        auction.maxBidder = msg.sender;



        emit LogBid(msg.sender, newBid);

    }



    // Withdrawals need to be manually triggered.

    function userAuctionWithdraw(uint256 _auctionId) public returns(bool) {

        AuctionData storage auction = auctions[_auctionId];

        require(!auction.isOpen, "SA auctionOpen");



        uint256 payout;



        if(msg.sender == auction.owner) {

            // Send the horse back to the owner if no one participated in the auction.

            if(auction.bidders.length == 0) {

                core.safeTransferFrom(this, msg.sender, auction.horse);



                return true;

            }



            payout = auction.maxBid;

            delete auction.maxBid;

        }



        if(msg.sender == auction.maxBidder) {

            // Sends the token from 'auction.owner' to 'maxBidder'.

            core.tokenSold(auction.horse);



            core.safeTransferFrom(this, msg.sender, auction.horse);

            delete auction.maxBidder;



            // Return so we don't send an innecesary transfer, the token is the prize.

            return true;

        }



        // We ensure the msg.sender isn't either the max bidder or the owner.

        // If the address is the owner that would evaluate to true two times (above and this one)

        // and 'payout' wouldn't be correct.

        // If 'msg.sender' didn't bid then the payout will be 0.

        if(msg.sender != auction.maxBidder && msg.sender != auction.owner) {

            payout = auction.bids[msg.sender];

            delete auction.bids[msg.sender];

        }



        msg.sender.transfer(payout);



        emit LogWithdraw(msg.sender, payout);



        return true;

    }



    /*

    @dev We construct the query with the auction ID and duration of it.

    */

    function sendAuctionQuery(uint256 _duration, uint256 _auctionId) private {

        string memory url = "json(https://api.zed.run/api/v1/close_auction).auction_closed";

        string memory payload = strConcat("{\"auction\":", uint2str(_auctionId), "}");



        oraclize_query(_duration, "URL", url, payload);

    }



    /*

    @dev Only one Query is being sent, when we get a response back we automatically

    close the given auction and remove it from the 'openAuctions' array.

    */

    function __callback(bytes32 _id, string _result) public {

        require(msg.sender == oraclize_cbAddress(), "SA notOraclizeAddr");

        uint256 auctionId = parseInt(_result);

        AuctionData storage auction = auctions[auctionId];



        // Since we're providing a way to cancel auctions we will only execute this function if the auction is still open.

        if(auction.isOpen) {

            _removeAuction(auctionId);

            auction.isOpen = false;



        }

    }



    /*

    @dev Gives a way for the owner to close a given auction of them. Users will be able to only close auctions

    that have zero bidders.

    */

    function cancelAuction(uint256 _auctionId) public {

        AuctionData storage auction = auctions[_auctionId];



        require(auction.bidders.length != 0, "SA auctionNotEmpty");

        require(msg.sender == auction.owner || msg.sender == owner(), "SA unauthorized");



        _removeAuction(_auctionId);

        auction.isOpen = false;

    }



    /*

    @return Returns the price of the Query so the contract has enough Ether when the query is sent.

    */

    function getQueryPrice() public returns(uint) {

        return oraclize_getPrice("URL");

    }



    /*

    @dev Gets some fields about a given auction.

    */

    function getAuction(uint256 _auctionId) public view returns(address, uint256, uint256, uint256, address[]) {

        AuctionData memory auction = auctions[_auctionId];



        return(auction.owner, auction.createdAt, auction.duration, auction.horse, auction.bidders);

    }



    /*

    @dev Returns bid information for a given address on a given auction.

    */

    function getBidData(uint256 _auctionId, address _bidder) public view returns(uint256, uint256) {

        AuctionData storage auction = auctions[_auctionId];



        return (auction.bids[_bidder], auction.bidTimes[_bidder]);

    }



    /*

    @dev Check if an auction is open or closed by a given ID.

    */

    function getAuctionStatus(uint256 _id) public view returns(bool) {

        return auctions[_id].isOpen;

    }



    /*

    @dev Just returns the length of all the auctions created for enumeration and tests.

    */

    function getAuctionsLength() public view returns(uint) {

        return auctionIds.length;

    }



    /*

    @dev Gets the duration of a given auction.

    */

    function getAuctionDuration(uint256 _id) public view returns(uint256) {

        AuctionData memory auction = auctions[_id];



        return auction.duration;

    }



    /*

    @dev Gets the max bidder and the bid for a given auction.

    */

    function getMaxBidder(uint256 _auctionId) public view returns(address, uint256) {

        AuctionData memory auction = auctions[_auctionId];



        return (auction.maxBidder, auction.maxBid);

    }



    /*

    @dev Gets the length of the bidders in a given auction.

    */

    function amountOfBidders(uint256 _auctionId) public view returns(uint256) {

        AuctionData memory auction = auctions[_auctionId];

        return auction.bidders.length;

    }



    /*

    @dev Returns a list of the open auctions.

    */

    function getOpenAuctions() public view returns(uint256[]) {

        return openAuctions;

    }



    /*

    @dev Returns ids of the auctions created by 'msg.sender'

    */

    function getAuctionsCreated(address _from) public view returns(uint256[]) {

        return auctionsCreatedBy[_from];

    }



    /*

    @dev Gets the minimum asking price for an auction.

    */

    function getMinimumAuctionPrice(uint256 _auctionId) public view returns(uint256) {

        AuctionData memory auction = auctions[_auctionId];

        return auction.minimum;

    }



    /*

    @dev Gets a list of auctions ID where the address is/was participating.

    We can get this information with all the auctions and then proceed to filter the ones we're

    interested about.

    */

    function participatingIn(address _user) public view returns(uint256[]) {

        return auctionsParticipating[_user];

    }



    /*     RESTRICTED FUNCTIONS A.K.A. ONLY OWNER CAN EXECUTE     */



    /*

    @dev Transfer ownership of the contract to a given address.

    */

    function giveOwnership(address _to) public onlyOwner() {

        transferOwnership(_to);

    }



    /*   PRIVATE FUNCTIONS   */



    /*

    @dev Zeppelin implementation.

    @dev Here we're swapping the auction at a given '_index' for the last element

    and removing it from the array by reducing it.

    */

    function _removeAuction(uint256 _tokenId) private {

        uint256 index = auctionIndex[_tokenId];

        uint256 lastAuctionIndex = openAuctions.length.sub(1);

        uint256 lastAuction = openAuctions[lastAuctionIndex];



        openAuctions[index] = lastAuction;

        auctionIndex[lastAuction] = index;



        delete openAuctions[lastAuctionIndex];



        openAuctions.length--;

    }



    function setCore(address _core) public onlyOwner() {

        core = Auctions(_core);

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



library Address {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   * as the code is not actually created until after the constructor finishes.

   * @param account address of the account to check

   * @return whether the target address is a contract

   */

  function isContract(address account) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(account) }

    return size > 0;

  }

}



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an account access to this role

   */

  function add(Role storage role, address account) internal {

    require(account != address(0));

    role.bearer[account] = true;

  }



  /**

   * @dev remove an account's access to this role

   */

  function remove(Role storage role, address account) internal {

    require(account != address(0));

    role.bearer[account] = false;

  }



  /**

   * @dev check if an account has this role

   * @return bool

   */

  function has(Role storage role, address account)

    internal

    view

    returns (bool)

  {

    require(account != address(0));

    return role.bearer[account];

  }

}



/*

@description Contract in charge of sending back needed data for the creation of horses.

*/

contract HorseData is Initializable {

    mapping(bytes32 => bytes32) internal bloodlines;



    function initialize() public initializer {

        // Bloodline matrix.

        bloodlines[keccak256(abi.encodePacked(bytes32("N"), bytes32("N")))] = "N";

        bloodlines[keccak256(abi.encodePacked(bytes32("N"), bytes32("S")))] = "S";

        bloodlines[keccak256(abi.encodePacked(bytes32("N"), bytes32("F")))] = "F";

        bloodlines[keccak256(abi.encodePacked(bytes32("N"), bytes32("W")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("S"), bytes32("N")))] = "S";

        bloodlines[keccak256(abi.encodePacked(bytes32("S"), bytes32("S")))] = "S";

        bloodlines[keccak256(abi.encodePacked(bytes32("S"), bytes32("F")))] = "F";

        bloodlines[keccak256(abi.encodePacked(bytes32("S"), bytes32("W")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("F"), bytes32("N")))] = "F";

        bloodlines[keccak256(abi.encodePacked(bytes32("F"), bytes32("S")))] = "F";

        bloodlines[keccak256(abi.encodePacked(bytes32("F"), bytes32("F")))] = "F";

        bloodlines[keccak256(abi.encodePacked(bytes32("F"), bytes32("W")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("W"), bytes32("N")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("W"), bytes32("S")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("W"), bytes32("F")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("W"), bytes32("W")))] = "W";

        bloodlines[keccak256(abi.encodePacked(bytes32("W"), bytes32("N")))] = "W";

    }



    /*

    @dev Generate bloodline and genotype based on '_batchNumber'

    */

    function getBloodline(uint256 _batchNumber) public pure returns(bytes32) {

        bytes32 bloodline;



        if(_batchNumber == 1) {

            bloodline = bytes32("N");

        } else if(_batchNumber == 2) {

            bloodline = bytes32("N");

        } else if(_batchNumber == 3) {

            bloodline = bytes32("S");

        } else if(_batchNumber == 4) {

            bloodline = bytes32("S");

        } else if(_batchNumber == 5) {

            bloodline = bytes32("F");

        } else if(_batchNumber == 6) {

            bloodline = bytes32("F");

        } else if(_batchNumber == 7) {

            bloodline = bytes32("F");

        } else if(_batchNumber == 8) {

            bloodline = bytes32("W");

        } else if(_batchNumber == 9) {

            bloodline = bytes32("W");

        } else {

            bloodline = bytes32("W");

        }



        return bloodline;

    }



    function getGenotype(uint256 _batchNumber) public pure returns(uint256) {

        require(_batchNumber >= 1 && _batchNumber <= 10, "Batch number out of bounds");

        return _batchNumber;

    }



    function getBaseValue(uint256 _batchNumber) public view returns(uint256) {

        uint256 baseValue;



        if(_batchNumber == 1) {

            baseValue = _getRandom(4, 100);

        } else if(_batchNumber == 2) {

            baseValue = _getRandom(9, 90);

        } else if(_batchNumber == 3) {

            baseValue = _getRandom(4, 80);

        } else if(_batchNumber == 4) {

            baseValue = _getRandom(4, 75);

        } else if(_batchNumber == 5) {

            baseValue = _getRandom(9, 70);

        } else if(_batchNumber == 6) {

            baseValue = _getRandom(4, 60);

        } else if(_batchNumber == 7) {

            baseValue = _getRandom(9, 50);

        } else if(_batchNumber == 8) {

            baseValue = _getRandom(9, 40);

        } else if(_batchNumber == 9) {

            baseValue = _getRandom(9, 30);

        } else {

            baseValue = _getRandom(19, 20);

        }



        return baseValue;

    }



    function getBloodlineFromParents(bytes32 _male, bytes32 _female) public view returns(bytes32) {

        return bloodlines[keccak256(abi.encodePacked(_male, _female))];

    }



    function _getRandom(uint256 _num, uint256 _deleteFrom) private view returns(uint256) {

        uint256 rand = uint256(blockhash(block.number - 1)) % _num + 1;



        return _deleteFrom - rand;

    }

}



contract StudServiceV2 is Ownable, usingOraclize {

    using SafeMath for uint256;



    uint256 baseFee;

    uint256[] horsesInStud;



    Core core;

    BreedTypes breedTypes;



    struct StudInfoV2 {

        bool inStud;



        uint256 matingPrice;

        uint256 duration;

        uint256 studCreatedAt;

    }



    mapping(bytes32 => uint256) public bloodlineWeights;

    mapping(bytes32 => uint256) public breedTypeWeights;



    mapping(uint256 => StudInfoV2) internal studs;

    mapping(uint256 => uint256) internal horseIndex;



    mapping(uint256 => bool) internal timeframes;



    /*

    @dev We only remove the horse from the mapping ONCE the '__callback' is called, this is for a reason.

    For Studs we use Oraclize as a service for queries in the future but we also have a function

    to manually remove the horse from stud but this does not cancel the

    query that was already sent, so the horse is blocked from being in Stud again until the

    callback is called and effectively removing it from stud.



    Main case: User puts horse in stud, horse is manually removed, horse is put in stud

    again thus creating another query, this time the user decides to leave the horse

    for the whole period of time but the first query which couldn't be cancelled is

    executed, calling the '__callback' function and removing the horse from Stud and leaving

    yet another query in air.

    */



    mapping(uint256 => bool) internal currentlyInStud;



    modifier onlyHorseOwner(uint256 _id) {

        require(msg.sender == core.ownerOf(_id), "SS notOwnerOfHorse");

        _;

    }



    function initialize(address _owner, address _core, address _breedTypes) public initializer {

        Ownable.initialize(_owner);

        core = Core(_core);

        breedTypes = BreedTypes(_breedTypes);



        // Nakamoto - Szabo - Finney - Buterin

        bloodlineWeights[bytes32("N")] = 180;

        bloodlineWeights[bytes32("S")] = 120;

        bloodlineWeights[bytes32("F")] = 40;

        bloodlineWeights[bytes32("B")] = 15;



        // Genesis - Legendary - Exclusive - Elite - Cross - Pacer

        breedTypeWeights[bytes32("genesis")] = 180;

        breedTypeWeights[bytes32("legendary")] = 150;

        breedTypeWeights[bytes32("exclusive")] = 120;

        breedTypeWeights[bytes32("elite")] = 90;

        breedTypeWeights[bytes32("cross")] = 80;

        breedTypeWeights[bytes32("pacer")] = 60;



        timeframes[86400] = true;

        timeframes[259200] = true;

        timeframes[604800] = true;



        baseFee = 0.4 ether;



        // OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

    }



    event HorseInStud(uint256 _horseId, uint256 _matingPrice, uint256 _duration, uint256 _timestamp);



    // we don't need to check here if the horse is on sale or not, this is done by default because

    // the horse is transferred to another address (Core) when the user puts the horse on auction,

    // this means they won't be able to place them here as they're not the owner of the horse

    function putInStud(uint256 _id, uint256 _matingPrice, uint256 _duration) public payable onlyHorseOwner(_id) {

        // We're checking the horse exists because we're relying on the breed type for genesis to be a default value.

        // this way we don't get false positives for horses that don't exist

        require(core.exists(_id), "SS horseDoesNotExist");

        require(bytes32("M") == core.getHorseSex(_id), "SS horseIsNotMale");

        require(msg.value >= oraclize_getPrice("URL"), "SS oraclizePriceNotMet");

        require(!currentlyInStud[_id], "SS horseIsInStud");



        // if we happen to receive another time we're going to default to 1 day.

        uint256 duration = 86400;

        uint256 minimumBreedPrice = getMinimumBreedPrice(_id);



        require(_matingPrice >= minimumBreedPrice, "SS matingPriceLowerThanMinimumBreedPrice");



        // if specified timeframe does not exist, fallback to default

        if(timeframes[_duration]) {

            duration = _duration;

        }



        studs[_id] = StudInfoV2(true, _matingPrice, duration, now);



        horseIndex[_id] = horsesInStud.push(_id) - 1;



        string memory url = "json(https://api.zed.run/api/v1/remove_horse_stud).horse_id";

        string memory payload = strConcat("{\"stud_info\":", uint2str(_id), "}");



        oraclize_query(duration, "URL", url, payload);



        currentlyInStud[_id] = true;



        emit HorseInStud(_id, _matingPrice, duration, now);

    }



    function getMinimumBreedPrice(uint256 _id) public view returns(uint256) {

        bytes32 breedType;

        bytes32 breedTypeFromContract = breedTypes.getBreedType(_id);



        // If the horse exists and the returned value from breed type is the default one (0x00000...)

        // it means it is a genesis horse. Otherwise we will just stick to the value returned by the call

        if(breedTypeFromContract == bytes32(0)) {

            breedType = bytes32("genesis");

        } else {

            breedType = breedTypeFromContract;

        }



        // Get horse data

        bytes32 bloodline = core.getBloodline(_id);

        uint256 bloodlineWeight = bloodlineWeights[bloodline].mul(0.80 ether).div(100);

        uint256 breedWeight = breedTypeWeights[breedType].mul(0.20 ether).div(100);



        return bloodlineWeight.add(breedWeight).mul(baseFee).div(1 ether);

    }



    function __callback(bytes32 _id, string _result) public {

        require(msg.sender == oraclize_cbAddress(), "SS notOraclize");



        uint256 horseId = parseInt(_result);



        // manually remove the horse from stud since removeFromStud/1 allos only the owner

        delete studs[horseId];

        _removeHorseFromStud(horseId);



        currentlyInStud[horseId] = false;

    }



    function removeFromStud(uint256 _id) public {

        require(msg.sender == core.ownerOf(_id), "SS unauthorized");

        require(isHorseInStud(_id), "SS horseIsNotInStud");



        delete studs[_id];

        // The horse will be removed from Stud (Will not be visible) but whoever is the owner will have

        // to wait for the initial cooldown or that '__callback' is called to be able to put the horse

        // in stud again, unless 'removeHorseOWN/1' is called by the 'owner'.

        _removeHorseFromStud(_id);

    }



    function studInfo(uint256 _id) public view returns(bool, uint256, uint256, uint256) {

        StudInfoV2 memory s = studs[_id];



        return(s.inStud, s.matingPrice, s.duration, s.studCreatedAt);

    }



    function isHorseInStud(uint256 _id) public view returns(bool) {

        return studs[_id].inStud;

    }



    function matingPrice(uint256 _id) public view returns(uint256) {

        return studs[_id].matingPrice;

    }



    function studTime(uint256 _id) public view returns(uint256) {

        return studs[_id].duration;

    }



    function getQueryPrice() public returns(uint256) {

        return oraclize_getPrice("URL");

    }



    function getHorsesInStud() public view returns(uint256[]) {

        return horsesInStud;

    }



    /*      RESTRICTED      */



    function addTimeframe(uint256 _timeframe) public onlyOwner() {

        timeframes[_timeframe] = true;

    }



    function removeHorseOwner(uint256 _horseId) public onlyOwner() {

        delete studs[_horseId];

        _removeHorseFromStud(_horseId);



        currentlyInStud[_horseId] = false;

    }



    function makeAvailableForStud(uint256 _horseId) public onlyOwner() {

        currentlyInStud[_horseId] = false;

    }



    function setBreedTypesAddr(address _breedTypes) public onlyOwner() {

        breedTypes = BreedTypes(_breedTypes);

    }



    /*      PRIVATE     */



    // We move the last horse to the index of the horse we're about to remove

    // then delete the last horse from the list.

    function _removeHorseFromStud(uint256 _horseId) private {

        uint256 index = horseIndex[_horseId];

        uint256 lastHorseIndex = horsesInStud.length - 1;

        uint256 lastHorse = horsesInStud[lastHorseIndex];



        // We need to reassign the index of the last horse, otherwise it'd be out of bounds

        // and the transaction will fail.

        horsesInStud[index] = lastHorse;

        horseIndex[lastHorse] = index;



        delete horsesInStud[lastHorseIndex];



        horsesInStud.length--;

    }

}



contract Breeding is Ownable {

    using SafeMath for uint256;



    // we're going to use the funds on this address for races

    address poolAddress;



    uint256 nonce;



    Core core;

    BreedTypes breedTypes;

    StudServiceV2 studService;



    // All this is subject to a change

    struct HorseBreed {

        uint256[2] parents;

        uint256[] offsprings;



        uint256 firstOffspring;

        uint256 offspringCounter;



        mapping(uint256 => bool) grandparents;

    }



    // Maps the horseID to a specific HorseBreed struct.

    mapping(uint256 => HorseBreed) internal horseBreedById;



    // Tracks offsprings of each horse.

    mapping(uint256 => mapping(uint256 => bool)) internal offspringsOf;



    // maps percentages for stud duration to stud owner for PUBLIC STABLES

    mapping(uint256 => uint256) internal studOwnerPercentage;



    // maps percentages for stud duration to prize pool for PUBLIC STABLES

    mapping(uint256 => uint256) internal prizePoolPercentage;



    event OffspringCreated(

        uint256 _father,

        uint256 _mother,

        uint256 _offspring

    );



    event BreedingFunds(

        uint256 _studOwner,

        uint256 _racesPool,

        uint256 _zed

    );



    function initialize(

        address _owner,

        address _core,

        address _studService,

        address _poolAddress

    ) public initializer {

        Ownable.initialize(_owner);

        core = Core(_core);

        studService = StudServiceV2(_studService);

        poolAddress = _poolAddress;



        studOwnerPercentage[86400] = 24;

        studOwnerPercentage[259200] = 30;

        studOwnerPercentage[604800] = 36;



        prizePoolPercentage[86400] = 56;

        prizePoolPercentage[259200] = 50;

        prizePoolPercentage[604800] = 44;

    }



    // here we're going to alter the minimum breed price based on the stable type as well

    function mix(uint256 _maleId, uint256 _femaleId, string _hash) external payable {

        require(core.exists(_maleId) && core.exists(_femaleId), "BR horsesDontExist");

        require(bytes32("M") == core.getHorseSex(_maleId), "BR expectedMaleHorseReceivedFemale");

        require(bytes32("F") == core.getHorseSex(_femaleId), "BR expectedFemaleHorseReceivedMale");

        require(studService.isHorseInStud(_maleId), "BR maleNotInStud");

        // female's owner is offspring's owner

        address femaleOwner = core.ownerOf(_femaleId);



        require(msg.sender == femaleOwner, "BR invalidTransactionSender");



        address maleOwner = core.ownerOf(_maleId);

        uint256 matingPrice = studService.matingPrice(_maleId);



        // check if we should apply a discount

        if(maleOwner == femaleOwner) {

            // msg.sender will only pay 35% of 'msg.value'

            require(msg.value >= matingPrice.sub(matingPrice.mul(35).div(100)), "BR matingPriceNotMet");

        } else {

            require(msg.value >= matingPrice, "BR matingPriceNotMet");

        }



        HorseBreed storage male = horseBreedById[_maleId];

        HorseBreed storage female = horseBreedById[_femaleId];



        require(_notBrothers(male, female), "BR horsesAreBrothers");

        require(_notParents(_maleId, _femaleId), "BR horsesAreDirectlyRelated");

        require(_notGrandparents(_maleId, _femaleId), "BR horseIsGrandchild");



        male.offspringCounter += 1;

        female.offspringCounter += 1;



        uint256 offspringId = core.createOffspring(femaleOwner, _hash, _maleId, _femaleId);

        // put the newly generated token into the mapping for both parents

        offspringsOf[_maleId][offspringId] = true;

        offspringsOf[_femaleId][offspringId] = true;



        // offspring's data

        HorseBreed storage o = horseBreedById[offspringId];

        o.parents = [_maleId, _femaleId];



        // save offspring's ID to parents

        male.offsprings.push(offspringId);

        female.offsprings.push(offspringId);



        // Manually save ID of each on the mapping, looks uglier but this way we can perform checks

        // more efficiently by just checking IDs instead of looping or doing another mechanism that could

        // be more expensive.

        o.grandparents[male.parents[0]] = true;

        o.grandparents[male.parents[1]] = true;

        o.grandparents[female.parents[0]] = true;

        o.grandparents[female.parents[1]] = true;



        core.setBaseValue(offspringId, _getBaseValue(_maleId, _femaleId));

        breedTypes.generateBreedType(offspringId, _maleId, _femaleId);



        sendBreedingFunds(maleOwner, femaleOwner, _maleId);



        emit OffspringCreated(_maleId, _femaleId, offspringId);

    }



    /*

    @dev Alters the breed price of the horse depending on the type of stable (Public, private)



    Private: Same owner of both horses

    Public: Different owners

    */

    function sendBreedingFunds(address _maleOwner, address _femaleOwner, uint256 _male) private {

        if(_maleOwner == _femaleOwner) {

            // Private or own stable

            // We won't send anything to the Stud Owner AKA msg.sender



            // 60% to the prize pool address

            poolAddress.transfer(msg.value.mul(60).div(100));



            // 40% to ZED

            owner().transfer(msg.value.mul(40).div(100));



            emit BreedingFunds(0, msg.value.mul(60).div(100), msg.value.mul(40).div(100));

        } else {

            // Other stables - take into consideration stud time of the horse

            uint256 studTime = studService.studTime(_male);

            uint256 studOwner = studOwnerPercentage[studTime];

            uint256 prizePool = prizePoolPercentage[studTime];



            // stud owner

            _maleOwner.transfer(msg.value.mul(studOwner).div(100));



            // prize pool

            poolAddress.transfer(msg.value.mul(prizePool).div(100));



            // 20% to ZED

            owner().transfer(msg.value.mul(20).div(100));



            emit BreedingFunds(

                msg.value.mul(studOwner).div(100),

                msg.value.mul(prizePool).div(100),

                msg.value.mul(20).div(100)

            );

        }

    }



    /*

    @dev Checks whether two given horses are brothers or not.

    @dev Having the same parents obviously make them directly related.

    */

    function _notBrothers(HorseBreed _male, HorseBreed _female) private pure returns(bool) {

        // We're going to avoid the case where parents are ID 0

        if(_male.parents[0] == 0 || _male.parents[1] == 0) return true;

        if(_female.parents[0] == 0 || _female.parents[1] == 0) return true;



        // Hash of both parents shouldn't be the same.

        return keccak256(abi.encodePacked(_male.parents)) != keccak256(abi.encodePacked(_female.parents));

    }



    /*

    @dev Checks whether two horses are directly related, i.e. one being an offspring of another.

    The process for this verification is simple, we track offsprings of each horse in a mapping

    here we check if either horse is an offspring of the other one, if true then we revert the op.

    */

    function _notParents(uint256 _male, uint256 _female) private view returns(bool) {

        if(offspringsOf[_male][_female]) return false;

        if(offspringsOf[_female][_male]) return false;



        return true;

    }



    /*

    @dev Checks whether two horses are directly related, i.e. one being a grandparent of another.

    We follow a similar approach as above, we just check for other's sex ID on the mapping

    of grandparents for a truthy value.

    */

    function _notGrandparents(uint256 _male, uint256 _female) private view returns(bool) {

        HorseBreed storage m = horseBreedById[_male];

        HorseBreed storage f = horseBreedById[_female];



        if(m.grandparents[_female]) return false;

        if(f.grandparents[_male]) return false;



        return true;

    }



    /*

    Returns whether or not two horses are related, if they are it specifies where they're related.

    */

    function areHorsesRelated(uint256 _male, uint256 _female) public view returns(bool, string) {

        HorseBreed storage male = horseBreedById[_male];

        HorseBreed storage female = horseBreedById[_female];



        if(!_notBrothers(male, female)) {

            return (true, "brothers");

        }



        if(!_notParents(_male, _female)) {

            return (true, "parents");

        }



        if(!_notGrandparents(_male, _female)) {

            return (true, "grandparents");

        }



        return (false, "");

    }



    /*

    @dev Gets a random number between two bounds.

    @param _num the inner bound

    @param _deleteFrom maximum number it can generate

    */

    function _getRandNum(uint256 _num, uint256 _deleteFrom) private returns(uint256) {

        nonce += 1;



        bytes32 randData = keccak256(

            abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))

        );



        uint256 rand = uint256(randData) % _num + 1;

        uint256 finalRand = _deleteFrom - rand;



        require(finalRand > 0, "BR randonNumberOutOfBounds");



        return finalRand;

    }



    /*

    @dev Computes the base value for an offspring

    */

    function _getBaseValue(uint256 _maleParent, uint256 _femaleParent) private returns(uint) {

        // Create the offspring baseValue

        uint256 percentage = _getRandNum(34, 65); // Creates a random number between 30 and 65.

        uint256 maleBaseValue = core.getBaseValue(_maleParent);

        uint256 femaleBaseValue = core.getBaseValue(_femaleParent);

        uint256 finalParents = maleBaseValue.add(femaleBaseValue);



        return finalParents.mul(percentage).div(100);

    }



    /*

    @dev Returns all data from HorseBreed struct.

    */

    function breedingData(uint256 _id) public view returns(uint256[2], uint256[], uint256, uint256) {

        HorseBreed memory h = horseBreedById[_id];



        return (h.parents, h.offsprings, h.firstOffspring, h.offspringCounter);

    }



    /*

    @dev Returns whether or not '_grandparentId' is related to '_horseId'.

    */

    function isGrandparent(uint256 _horseId, uint256 _grandparentId) public view returns(bool) {

        return horseBreedById[_horseId].grandparents[_grandparentId];

    }



    /*

    @dev Returns a horse stats for breeding.

    */

    function getHorseOffspringStats(uint256 _horseId) public view returns(uint256, uint256) {

        HorseBreed memory h = horseBreedById[_horseId];

        return(h.offspringCounter, h.firstOffspring);

    }



    /*

    @dev Returns the parents of a given horse

    */

    function getParents(uint256 _horseId) public view returns(uint256[2]) {

        return horseBreedById[_horseId].parents;

    }



    /*  RESTRICTED */



    function setCore(address _core) public onlyOwner() {

        core = Core(_core);

    }



    function setBreedTypesAddress(address _breedTypes) public onlyOwner() {

        breedTypes = BreedTypes(_breedTypes);

    }

}



contract BreedTypes is Ownable, Breeding {

    // Maps each horse ID to a breed type.

    mapping(uint256 => bytes32) public horseBreed;



    // Maps hash of parents breed type to another breed type

    mapping(bytes32 => bytes32) public breedTypeMatrix;



    Breeding breeding;



    event BreedType(bytes32 _breed, uint256 _horseId);



    function initialize(address _owner) public initializer {

        Ownable.initialize(_owner);

    }



    function getBreedType(uint256 _id) public view returns(bytes32) {

        return horseBreed[_id];

    }



    /*

    @dev get breed type of a horse depending on parents.

    */

    function generateBreedType(

        uint256 _id,

        uint256 _father,

        uint256 _mother

    ) public {

        require(msg.sender == address(breeding), "BT unauthorized");



        // get hash from parent's types

        bytes32 fatherType = horseBreed[_father];

        bytes32 motherType = horseBreed[_mother];

        bytes32 parentsHash = keccak256(abi.encodePacked(fatherType, motherType));

        bytes32 typeFromHash = breedTypeMatrix[parentsHash];



        emit BreedType(typeFromHash, _id);



        horseBreed[_id] = typeFromHash;

    }



    /*      Restricted     */

    function populateMatrix() public onlyOwner() {

        // Horse Type Matrix

        // Genesis - Legendary - Exclusive - Elite - Cross - Pacer

        bytes32 genesis = bytes32(0);

        bytes32 legendary = bytes32("legendary");

        bytes32 exclusive = bytes32("exclusive");

        bytes32 elite = bytes32("elite");

        bytes32 cross = bytes32("cross");

        bytes32 pacer = bytes32("pacer");



        // genesis

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, genesis))] = legendary;

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, legendary))] = exclusive;

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, exclusive))] = exclusive;

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, elite))] = elite;

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, cross))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(genesis, pacer))] = pacer;



        // legendary

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, genesis))] = exclusive;

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, legendary))] = exclusive;

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, exclusive))] = elite;

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, elite))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, cross))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(legendary, pacer))] = pacer;



        // exclusive

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, genesis))] = elite;

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, legendary))] = elite;

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, exclusive))] = elite;

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, elite))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, cross))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(exclusive, pacer))] = pacer;



        // elite

        breedTypeMatrix[keccak256(abi.encodePacked(elite, genesis))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(elite, legendary))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(elite, exclusive))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(elite, elite))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(elite, cross))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(elite, pacer))] = pacer;



        // cross

        breedTypeMatrix[keccak256(abi.encodePacked(cross, genesis))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(cross, legendary))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(cross, exclusive))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(cross, elite))] = cross;

        breedTypeMatrix[keccak256(abi.encodePacked(cross, cross))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(cross, pacer))] = pacer;



        // pacer

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, genesis))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, legendary))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, exclusive))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, elite))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, cross))] = pacer;

        breedTypeMatrix[keccak256(abi.encodePacked(pacer, pacer))] = pacer;

    }



    function setBreedingAddress(address _breeding) public onlyOwner() {

        breeding = Breeding(_breeding);

    }

}
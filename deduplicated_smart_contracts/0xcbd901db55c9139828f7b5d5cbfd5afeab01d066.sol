/**

 *Submitted for verification at Etherscan.io on 2018-12-16

*/



pragma solidity ^0.4.25;



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



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

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

    emit OwnershipTransferred(_owner, address(0));

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

    require(!has(role, account));



    role.bearer[account] = true;

  }



  /**

   * @dev remove an account's access to this role

   */

  function remove(Role storage role, address account) internal {

    require(account != address(0));

    require(has(role, account));



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



contract PauserRole {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() internal {

    _addPauser(msg.sender);

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

}







/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

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

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

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

contract ERC165 is IERC165 {



  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) private _supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  constructor()

    internal

  {

    _registerInterface(_InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 interfaceId)

    external

    view

    returns (bool)

  {

    return _supportedInterfaces[interfaceId];

  }



  /**

   * @dev internal method for registering an interface

   */

  function _registerInterface(bytes4 interfaceId)

    internal

  {

    require(interfaceId != 0xffffffff);

    _supportedInterfaces[interfaceId] = true;

  }

}





/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721 is IERC165 {



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

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Metadata is IERC721 {

  function name() external view returns (string);

  function symbol() external view returns (string);

  function tokenURI(uint256 tokenId) external view returns (string);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Enumerable is IERC721 {

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



/**

 * Utility library of inline functions on addresses

 */

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

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC165, IERC721 {



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



  constructor()

    public

  {

    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721);

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

    require(_checkOnERC721Received(from, to, tokenId, _data));

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

   * @dev Internal function to add a token ID to the list of a given address

   * Note that this function is left internal to make ERC721Enumerable possible, but is not

   * intended to be called by custom derived contracts: in particular, it emits no Transfer event.

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

   * Note that this function is left internal to make ERC721Enumerable possible, but is not

   * intended to be called by custom derived contracts: in particular, it emits no Transfer event,

   * and doesn't clear approvals.

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

  function _checkOnERC721Received(

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



  /**

   * @dev Private function to clear current approval of a given token ID

   * Reverts if the given address is not indeed the owner of the token

   * @param owner owner of the token

   * @param tokenId uint256 ID of the token to be transferred

   */

  function _clearApproval(address owner, uint256 tokenId) private {

    require(ownerOf(tokenId) == owner);

    if (_tokenApprovals[tokenId] != address(0)) {

      _tokenApprovals[tokenId] = address(0);

    }

  }

}



contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

  // Token name

  string private _name;



  // Token symbol

  string private _symbol;



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

  constructor(string name, string symbol) public {

    _name = name;

    _symbol = symbol;



    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(InterfaceId_ERC721Metadata);

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

  function tokenURI(uint256 tokenId) external view returns (string) {

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

}







contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

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

  constructor() public {

    // register the supported interface to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721Enumerable);

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

   * This function is internal due to language limitations, see the note in ERC721.sol.

   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event.

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

   * This function is internal due to language limitations, see the note in ERC721.sol.

   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event,

   * and doesn't clear approvals.

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

}







contract NFT is ERC721Metadata,

  ERC721Enumerable,

  Ownable {

  

  constructor(string name, string symbol) public ERC721Metadata(name, symbol){

  }

    

  function mintWithTokenURI(

		uint256 _id,			    

		string _uri

		) onlyOwner public {

    super._mint(owner(), _id);

    super._setTokenURI(_id, _uri);

  }

  

}







contract CryptoxmasEscrow is Pausable, Ownable {

  using SafeMath for uint256;

  

  /* Giveth */

  address public givethBridge;

  uint64 public givethReceiverId;



  /* NFT */

  NFT public nft; 

  

  // commission to fund paying gas for claim transactions

  uint public EPHEMERAL_ADDRESS_FEE = 0.01 ether;

  uint public MIN_PRICE = 0.05 ether; // minimum token price

  uint public tokensCounter; // minted tokens counter

  

  /* GIFT */

  enum Statuses { Empty, Deposited, Claimed, Cancelled }  

  

  struct Gift {

    address sender;

    uint claimEth; // ETH for receiver    

    uint256 tokenId;

    Statuses status;

    string msgHash; // IFPS message hash

  }



  // Mappings of transitAddress => Gift Struct

  mapping (address => Gift) gifts;





  /* Token Categories */

  enum CategoryId { Common, Special, Rare, Scarce, Limited, Epic, Unique }  

  struct TokenCategory {

    CategoryId categoryId;

    uint minted;  // already minted

    uint maxQnty; // maximum amount of tokens to mint

    uint price; 

  }



  // tokenURI => TokenCategory

  mapping(string => TokenCategory) tokenCategories;

  

  /*

   * EVENTS

   */

  event LogBuy(

	       address indexed transitAddress,

	       address indexed sender,

	       string indexed tokenUri,

	       uint tokenId,

	       uint claimEth,

	       uint nftPrice

	       );



  event LogClaim(

		 address indexed transitAddress,

		 address indexed sender,

		 uint tokenId,

		 address receiver,

		 uint claimEth

		 );  



  event LogCancel(

		  address indexed transitAddress,

		  address indexed sender,

		  uint tokenId

		  );



  event LogAddTokenCategory(

			    string tokenUri,

			    CategoryId categoryId,

			    uint maxQnty,

			    uint price

		  );

  



  /**

   * @dev Contructor that sets msg.sender as owner in Ownable,

   * sets escrow contract params and deploys new NFT contract 

   * for minting and selling tokens.

   *

   * @param _givethBridge address Address of GivethBridge contract

   * @param _givethReceiverId uint64 Campaign Id created on Giveth platform.

   * @param _name string Name for the NFT 

   * @param _symbol string Symbol for the NFT 

   */

  constructor(address _givethBridge,

	      uint64 _givethReceiverId,

	      string _name,

	      string _symbol) public {

    // setup Giveth params

    givethBridge = _givethBridge;

    givethReceiverId = _givethReceiverId;

    

    // deploy nft contract

    nft = new NFT(_name, _symbol);

  }



   /* 

   * METHODS 

   */

  

  /**

   * @dev Get Token Category for the tokenUri.

   *

   * @param _tokenUri string token URI of the category

   * @return Token Category details (CategoryId, minted, maxQnty, price)

   */  

  function getTokenCategory(string _tokenUri) public view returns (CategoryId categoryId,

								  uint minted,

								  uint maxQnty,

								  uint price) { 

    TokenCategory memory category = tokenCategories[_tokenUri];    

    return (category.categoryId,

	    category.minted,

	    category.maxQnty,

	    category.price);

  }



  /**

   * @dev Add Token Category for the tokenUri.

   *

   * @param _tokenUri string token URI of the category

   * @param _categoryId uint categoryid of the category

   * @param _maxQnty uint maximum quantity of tokens allowed to be minted

   * @param _price uint price tokens of that category will be sold at  

   * @return True if success.

   */    

  function addTokenCategory(string _tokenUri, CategoryId _categoryId, uint _maxQnty, uint _price)

    public onlyOwner returns (bool success) {



    // price should be more than MIN_PRICE

    require(_price >= MIN_PRICE);

	    

    // can't override existing category

    require(tokenCategories[_tokenUri].price == 0);

    

    tokenCategories[_tokenUri] = TokenCategory(_categoryId,

					       0, // zero tokens minted initially

					       _maxQnty,

					       _price);



    emit LogAddTokenCategory(_tokenUri, _categoryId, _maxQnty, _price);

    return true;

  }



  /**

   * @dev Checks that it's possible to buy gift and mint token with the tokenURI.

   *

   * @param _tokenUri string token URI of the category

   * @param _transitAddress address transit address assigned to gift

   * @param _value uint amount of ether, that is send in tx. 

   * @return True if success.

   */      

  function canBuyGift(string _tokenUri, address _transitAddress, uint _value) public view whenNotPaused returns (bool) {

    // can not override existing gift

    require(gifts[_transitAddress].status == Statuses.Empty);



    // eth covers NFT price

    TokenCategory memory category = tokenCategories[_tokenUri];

    require(_value >= category.price);



    // tokens of that type not sold out yet

    require(category.minted < category.maxQnty);

    

    return true;

  }



  /**

   * @dev Buy gift and mint token with _tokenUri, new minted token will be kept in escrow

   * until receiver claims it. 

   *

   * Received ether, splitted in 3 parts:

   *   - 0.01 ETH goes to ephemeral account, so it can pay gas fee for claim transaction. 

   *   - token price (minus ephemeral account fee) goes to the Giveth Campaign as a donation.  

   *   - Eth above token price is kept in the escrow, waiting for receiver to claim. 

   *

   * @param _tokenUri string token URI of the category

   * @param _transitAddress address transit address assigned to gift

   * @param _msgHash string IPFS hash, where gift message stored at 

   * @return True if success.

   */    

  function buyGift(string _tokenUri, address _transitAddress, string _msgHash)

          payable public whenNotPaused returns (bool) {

    

    require(canBuyGift(_tokenUri, _transitAddress, msg.value));



    // get token price from the category for that token URI

    uint tokenPrice = tokenCategories[_tokenUri].price;



    // ether above token price is for receiver to claim

    uint claimEth = msg.value.sub(tokenPrice);



    // mint new token 

    uint tokenId = tokensCounter.add(1);

    nft.mintWithTokenURI(tokenId, _tokenUri);



    // increment counters

    tokenCategories[_tokenUri].minted = tokenCategories[_tokenUri].minted.add(1);

    tokensCounter = tokensCounter.add(1);

    

    // saving gift details

    gifts[_transitAddress] = Gift(

				  msg.sender,

				  claimEth,

				  tokenId,

				  Statuses.Deposited,

				  _msgHash

				  );





    // transfer small fee to ephemeral account to fund claim txs

    _transitAddress.transfer(EPHEMERAL_ADDRESS_FEE);



    // send donation to Giveth campaign

    uint donation = tokenPrice.sub(EPHEMERAL_ADDRESS_FEE);

    if (donation > 0) {

      bool donationSuccess = _makeDonation(msg.sender, donation);



      // revert if there was problem with sending ether to GivethBridge

      require(donationSuccess == true);

    }

    

    // log buy event

    emit LogBuy(

		_transitAddress,

		msg.sender,

		_tokenUri,

		tokenId,

		claimEth,

		tokenPrice);

    return true;

  }



  /**

   * @dev Send donation to Giveth campaign 

   * by calling function 'donateAndCreateGiver' of GivethBridge contract.

   *

   * @param _giver address giver address

   * @param _value uint donation amount (in wei)

   * @return True if success.

   */    

  function _makeDonation(address _giver, uint _value) internal returns (bool success) {

    bytes memory _data = abi.encodePacked(0x1870c10f, // function signature

					   bytes32(_giver),

					   bytes32(givethReceiverId),

					   bytes32(0),

					   bytes32(0));

    // make donation tx

    success = givethBridge.call.value(_value)(_data);

    return success;

  }



  /**

   * @dev Get Gift assigned to transit address.

   *

   * @param _transitAddress address transit address assigned to gift

   * @return Gift details

   */    

  function getGift(address _transitAddress) public view returns (

	     uint256 tokenId,

	     string tokenUri,								 

	     address sender,  // gift buyer

	     uint claimEth,   // eth for receiver

	     uint nftPrice,   // token price 	     

	     Statuses status, // gift status (deposited, claimed, cancelled) 								 	     

	     string msgHash   // IPFS hash, where gift message stored at 

    ) {

    Gift memory gift = gifts[_transitAddress];

    tokenUri =  nft.tokenURI(gift.tokenId);

    TokenCategory memory category = tokenCategories[tokenUri];    

    return (

	    gift.tokenId,

	    tokenUri,

	    gift.sender,

	    gift.claimEth,

	    category.price,	    

	    gift.status,

	    gift.msgHash

	    );

  }

  

  /**

   * @dev Cancel gift and get sent ether back. Only gift buyer can

   * cancel.

   * 

   * @param _transitAddress transit address assigned to gift

   * @return True if success.

   */

  function cancelGift(address _transitAddress) public returns (bool success) {

    Gift storage gift = gifts[_transitAddress];



    // is deposited and wasn't claimed or cancelled before

    require(gift.status == Statuses.Deposited);

    

    // only sender can cancel transfer;

    require(msg.sender == gift.sender);

    

    // update status to cancelled

    gift.status = Statuses.Cancelled;



    // transfer optional ether to receiver's address

    if (gift.claimEth > 0) {

      gift.sender.transfer(gift.claimEth);

    }



    // send nft to buyer

    nft.transferFrom(address(this), msg.sender, gift.tokenId);



    // log cancel event

    emit LogCancel(_transitAddress, msg.sender, gift.tokenId);



    return true;

  }



  

  /**

   * @dev Claim gift to receiver's address if it is correctly signed

   * with private key for verification public key assigned to gift.

   * 

   * @param _receiver address Signed address.

   * @return True if success.

   */

  function claimGift(address _receiver) public whenNotPaused returns (bool success) {

    // only holder of ephemeral private key can claim gift

    address _transitAddress = msg.sender;

    

    Gift storage gift = gifts[_transitAddress];



    // is deposited and wasn't claimed or cancelled before

    require(gift.status == Statuses.Deposited);



    // update gift status to claimed

    gift.status = Statuses.Claimed;

    

    // send nft to receiver

    nft.transferFrom(address(this), _receiver, gift.tokenId);

    

    // transfer ether to receiver's address

    if (gift.claimEth > 0) {

      _receiver.transfer(gift.claimEth);

    }



    // log claim event

    emit LogClaim(_transitAddress, gift.sender, gift.tokenId, _receiver, gift.claimEth);

    

    return true;

  }



  // fallback function - do not receive ether by default

  function() public payable {

    revert();

  }

}
/**

 *Submitted for verification at Etherscan.io on 2018-11-16

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

contract ERC165 is IERC165, Initializable {



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

function initialize() initializer public {

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

* @dev private method for registering an interface

*/

function _registerInterface(bytes4 interfaceId)

	internal

{

	require(interfaceId != 0xffffffff);

	_supportedInterfaces[interfaceId] = true;

}

}



// import "./ERC721.sol";



// import "./IERC721.sol";



// import "../../introspection/IERC165.sol";



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

// import "./IERC721Receiver.sol";



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





// import "../../math/SafeMath.sol";



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

	require(b > 0);// Solidity only automatically asserts when dividing by 0

	uint256 c = a / b;

	// assert(a == b * c + a % b);// There is no case in which this doesn't hold



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

// import "../../utils/Address.sol";



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



function initialize() initializer public {

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

* `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`;otherwise,

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

* `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`;otherwise,

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

}



//import "./ERC721Enumerable.sol";



// import "./IERC721Enumerable.sol";



// import "./IERC721.sol";



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



// import "./ERC721.sol";

// import "../../introspection/ERC165.sol";



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

function initialize() initializer public {

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

}



// import "./ERC721Metadata.sol";



// import "./IERC721Metadata.sol";



// import "./IERC721.sol";





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

	function initialize(address addr) initializer public {

		// can not be same as deployer!

		_owner = addr;

		

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

  modifier contract_onlyOwner() {

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

  function renounceOwnership() public contract_onlyOwner {

	emit OwnershipRenounced(_owner);

	_owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public contract_onlyOwner {

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

* @title Helper to allow various addresses to mint Chibis

* @dev Adds addresses to mapping that can be true/false queried

*/

contract MintWallets is Ownable {

	mapping (address => bool) internal _mintWallets;

	

	function initialize(address addr) initializer public {

		_mintWallets[msg.sender] = true;

		_mintWallets[addr] = true;

	}

	

	/**

	* @dev Add a wallet/contract to the mint function functionality

	* @param _address The address/contract to allow minting 

	*/

	function setMintAddress(address _address, bool _active) public contract_onlyOwner {

		_mintWallets[_address] = _active;

	}



	/**

	* @dev Check if wallet is true/false

	* @param _address The address/contract to check

	*/

	function checkMintAllowed(address _address) public view returns (bool) {

		return _mintWallets[_address];

	}

	

	/**

	* @dev Throws if called by any account other than the owner.

	*/

	modifier mintAllowed(address _address) {

		require(_mintWallets[_address]);

		_;

	}

}







/**

* @title ERC-721 Non-Fungible Token Standard, optional metadata extension

* @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

*/

contract IERC721Metadata is IERC721 {

function name() external view returns (string);

function symbol() external view returns (string);

function tokenURI(uint256 tokenId) public view returns (string);

}

// import "../../introspection/ERC165.sol";



contract ERC721Metadata is ERC165, ERC721, IERC721Metadata, MintWallets {

// Token name

string internal _name;



// Token symbol

string internal _symbol;



string infoUrlPrefix;





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

function initialize(string name, string symbol) initializer public {

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

function tokenURI(uint256 tokenId) public view returns (string) {

	require(_exists(tokenId));

	string memory uri = strConcat(infoUrlPrefix, uint2str(tokenId));

	return uri;

}





/**

* @dev Internal function to burn a specific token

* Reverts if the token does not exist

* @param owner owner of the token to burn

* @param tokenId uint256 ID of the token being burned by the msg.sender

*/

function _burn(address owner, uint256 tokenId) internal {

	super._burn(owner, tokenId);

}



	// set info url for weapons

	function setInfoUrl(string _url) public contract_onlyOwner returns(bool success) {

		infoUrlPrefix = _url;

		return true;

	}

	



	/**

	 * 

	 * Helper stuff

	 * 

	 **/

	 

	function stringToBytes32(string memory source) internal pure returns (bytes32 result) {

		bytes memory tempEmptyStringTest = bytes(source);

		if (tempEmptyStringTest.length == 0) {

			return 0x0;

		}

	

		assembly {

			result := mload(add(source, 32))

		}

	}

	

	function strConcat(string _a, string _b) internal pure returns (string) {

		return strConcatDoIt(_a, _b, "", "", "");

	}

	

	function strConcatDoIt(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

		bytes memory _ba = bytes(_a);

		bytes memory _bb = bytes(_b);

		bytes memory _bc = bytes(_c);

		bytes memory _bd = bytes(_d);

		bytes memory _be = bytes(_e);

		string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

		bytes memory babcde = bytes(abcde);

		uint k = 0;

		for (uint i = 0;i < _ba.length;i++) babcde[k++] = _ba[i];

		for (i = 0;i < _bb.length;i++) babcde[k++] = _bb[i];

		for (i = 0;i < _bc.length;i++) babcde[k++] = _bc[i];

		for (i = 0;i < _bd.length;i++) babcde[k++] = _bd[i];

		for (i = 0;i < _be.length;i++) babcde[k++] = _be[i];

		return string(babcde);

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



	function bytesToUint(bytes b) internal pure returns (uint256) {

	  require(b.length == 32);



	  bytes32 out;



	  for (uint i = 0;i < 32;i++) {

		out |= bytes32(b[i] & 0xFF) >> (i * 8);

	  }



	  return uint256(out);

	}

	

	

}



/**

* @title Full ERC721 Token

* This implementation includes all the required and some optional functionality of the ERC721 standard

* Moreover, it includes approve all functionality using operator terminology

* @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

*/

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

	

	string name;

	string symbol;

		

	function initialize() initializer public {

		name = 'weapons';

		symbol = 'CBW';

		ERC721Metadata.initialize(name, symbol);

	}



}





interface ERC20InterfaceClassic {

	function transfer(address to, uint tokens) external returns (bool success);

}



interface ERC20Interface {

	function transferFrom(address from, address to, uint tokens) external returns (bool success);

	function transfer(address to, uint tokens) external;

	function balanceOf(address _owner) external view returns (uint256 _balance);

}





contract Referral is Ownable {

	

	uint refIdCounter;

	uint refCutPerc;

	

	mapping (address => uint) refId;

	mapping (uint => address) refIdAddress;

	mapping (uint => uint) refCut;

	mapping (uint => uint) refIdAvail;



	event RefPaid(uint refId, address indexed refOwner, uint amount);

	event RefCreated(uint refId, address indexed wallet);

	

	function initialize() initializer public {

		refIdCounter = 400;

		refCutPerc = 12;

	}



	// creates a new refid if address has none

    function createRefId() public {

        require(refId[msg.sender] == 0);

        

        refIdCounter++;

        refId[msg.sender] = refIdCounter;

        refIdAddress[refIdCounter] = msg.sender;

        refCut[refIdCounter] = refCutPerc;



		emit RefCreated(refIdCounter, msg.sender);

    }

    

    function setRefCut(uint _refId, uint _cut) public contract_onlyOwner {

        refCut[_refId] = _cut;

    }

    

    // user can query his own ref data, not that of others

    function queryRefId() public view returns(uint _refId, uint _refCut, address _address) {

        uint _id = refId[msg.sender];

        return (_id, refCut[_id], refIdAddress[_id]);

    }

	

}





contract WeaponGenesInterface {

	function generateData(uint _tokenId) public view returns (uint, uint);

	function generateRareMythicData(uint _tokenId) public view returns (uint);

	function generateLegendaryData(uint _tokenId) public view returns (uint);

}





// new and old chibi contract

contract ChibiInterface {

	function queryChibiDNA(uint) public pure returns (

		uint16[13]

		) {}



	function ownerOf(uint256) public pure returns (address) {}

	

	// legacy support old chibi contract

	function queryChibi(uint) public pure returns (

		string,

		string,

		uint16[13],

		uint256,

		uint256,

		uint,

		uint

		) {}

	

}





/**

 *  Weapons for Chibis

 *  

 */

contract Weapons is ERC721Full, Referral {

	

	// couple events

	event WeaponClaimed(address indexed from, uint chibiId, uint weaponTokenId, uint weaponRarity, uint weaponType);

	event WeaponSaleBought(address indexed from, address indexed to, uint weaponTokenId, uint weaponPricePlayer, uint weaponPrice);

	event WeaponBought(address indexed from, uint weaponTokenId, uint weaponRarity, uint weaponType);

	event WeaponMintedToAddr(address indexed from, uint weaponTokenId, uint weaponRarity, uint weaponType, string weaponCode);

	event WeaponForSale(address indexed from, uint weaponTokenId, uint weaponPrice);

	event WeaponSaleCancelled(address indexed from, uint weaponTokenId);



	uint uniqueCounter;



	ChibiInterface chibiContract;



	WeaponGenesInterface genesContract;



	// default weapon price

	uint _weaponPrice;

	uint _rareWeaponPrice;

	uint _mythicWeaponPrice;

	uint _legendaryWeaponPrice;

	

	// sell weapon internally

	mapping(uint256 => uint256) private _weaponSalePrice;

	

	// mapping for Chibi to claim weapon

	mapping(uint256 => bool) private _weaponClaimed;

	

	// our comission

	uint comission;

	

	// for players putting weapons up, to avoid super low prices from botters

	uint minPrice;

	

	struct WeaponsData {

		uint rarity;

		uint weaponType;

	}

	

	bool public gameState;

	bool public gameStateClaim;

	

	mapping(uint256 => WeaponsData) private weapons;



	uint presaleLockdown;

	

	function initialize() initializer public {



		// 2019-02-28 00:00:00

		presaleLockdown = 1551312000;



		ERC721Full.initialize();

		ERC165.initialize();

		ERC721.initialize();

		ERC721Enumerable.initialize();

		Ownable.initialize(address(0x3e0f98ea1B916BB2373BAf21c2C8E6eE970e1126));

		MintWallets.initialize(address(0x3e0f98ea1B916BB2373BAf21c2C8E6eE970e1126));

		Referral.initialize();

		

		// min price people can put up weapons

		minPrice = 100;

		

		// prices based on droprates

		_weaponPrice = 20000000000000000; // 0.02 ETH ~3.50 USD (nov 18)

		_rareWeaponPrice = 88000000000000000; // 0.088 ETH

		_mythicWeaponPrice = 200000000000000000; // 0.2 ETH

		_legendaryWeaponPrice = 3000000000000000000; // 3 ETH



		uniqueCounter = 0;

		infoUrlPrefix = "https://chibifighters.io/weaponapi/";



		// set comission percentage inv

		comission = 90;

		

		gameState = true;

		gameStateClaim = true;

		

	}





    // returns min price for weapon sale to avoid cheap sales

    function queryMinPrice() public view returns (uint price) {

        return minPrice;

    }



    	

	function queryDefaultSalePrice(uint rarity) public view returns (uint price) {

		if (rarity == 0) {

			return _weaponPrice;

		}else

		if (rarity == 1) {

			return _rareWeaponPrice;

		}else

		if (rarity == 2) {

			return _mythicWeaponPrice;

		}else

		if (rarity == 3) {

			return _legendaryWeaponPrice;

		}

		return 0;

	}



	// returns min price for weapon sale to avoid cheap sales

	function setMinPrice(uint _minPrice) public contract_onlyOwner returns (uint price) {

		minPrice = _minPrice;

		return minPrice;

	}



	// returns min price for weapon sale to avoid cheap sales

	function setGameState(bool _paused) public contract_onlyOwner returns (bool paused) {

		gameState = _paused;

		return gameState;

	}

	

	// returns min price for weapon sale to avoid cheap sales

	function setGameStateClaim(bool _paused) public contract_onlyOwner returns (bool paused) {

		gameStateClaim = _paused;

		return gameState;

	}

	

	function queryWeaponData(uint _tokenId) public view returns (uint tokenId, address owner, uint rarity, uint weaponType) {

		return (

			_tokenId,

			ownerOf(_tokenId),

			weapons[_tokenId].rarity,

			weapons[_tokenId].weaponType

			);

	}



	

	// check if chibi already claimed weapon

	function queryChibiClaimed(uint chibiId) public view returns (bool success) {

		return _weaponClaimed[chibiId];

	}

	



	function setCommission(uint percent) public contract_onlyOwner returns(bool success) {

		comission = 100 - percent;

		return true;

	}

	

	

	function getCommission() public view contract_onlyOwner returns(uint _comission) {

		return 100 - comission;

	}





	function putWeaponForSale(uint tokenId, uint price) public notPaused returns (bool success) {

		require (msg.sender == ownerOf(tokenId));

		require (price >= minPrice);



		_weaponSalePrice[tokenId] = price;

		approve(this, tokenId);



		emit WeaponForSale(msg.sender, tokenId, price);

		return true;

	}

	

	

	function cancelWeaponSale(uint tokenId) public returns (bool success) {

		require (msg.sender == ownerOf(tokenId));

		_weaponSalePrice[tokenId] = 0;

		

		// remove approval from contract

		_clearApproval(msg.sender, tokenId);



		emit WeaponSaleCancelled(msg.sender, tokenId);

		return true;

	}

	

	

	function buySaleWeapon(uint tokenId) public payable notPaused returns (bool success) {

		require(msg.sender != ownerOf(tokenId));

		require(_weaponSalePrice[tokenId] > 0);

		require(msg.value == _weaponSalePrice[tokenId]);

		require(_isApprovedOrOwner(this, tokenId));

		

		address _to = msg.sender;

		require(_to != address(0));

		

		_weaponSalePrice[tokenId] = 0;

		address _from = ownerOf(tokenId);

		

		uint finalPrice = msg.value / 100 * comission;

		

		// transfer weapon

		_removeTokenFrom(_from, tokenId);

		_addTokenTo(_to, tokenId);

		_clearApproval(msg.sender, tokenId);

	

		emit Transfer(_from, _to, tokenId);



		// transfer ether

		_from.transfer(finalPrice);

			

		emit WeaponSaleBought(_from, _to, tokenId, finalPrice, msg.value);

		return true;

	}

	



	// price for default weapons

	function setWeaponPrice(uint mode, uint _setWeaponPrice) public contract_onlyOwner returns(bool success, uint weaponPrice) {

		if (mode == 0) {

			_weaponPrice = _setWeaponPrice;

		}else

		if (mode == 1) {

			_rareWeaponPrice = _setWeaponPrice;

		}else

		if (mode == 2) {

			_mythicWeaponPrice = _setWeaponPrice;

		}else

		if (mode == 3) {

			_legendaryWeaponPrice = _setWeaponPrice;

		}

		

		return (true, _setWeaponPrice);

	}

	



	// set chibi contract

	function setChibiAddress(address _address) public contract_onlyOwner returns (bool success) {

		chibiContract = ChibiInterface(_address);

		return true;

	}

	

	

	// set genes contract

	function setGenesAddress(address _address) public contract_onlyOwner returns (bool success) {

		genesContract = WeaponGenesInterface(_address);

		return true;

	}

	

	

	// get dna to claim weapons (only way to get founder weapons)

	function getChibiWeaponDna(uint _chibiId) internal view returns (uint weapon, uint rarity) {

		uint16[13] memory _dna = chibiContract.queryChibiDNA(_chibiId);

		

		return (_dna[7], _dna[8]);

	}

	



	// buy a random weapon, can be anything from common to legendary

	function buyWeapon(uint amount, uint _refId) public payable notPaused {

		require(_weaponPrice.mul(amount) == msg.value);

		// founder weapons can not be bought, and nothing that doesn't exist yet



		for (uint i=0;i<amount;i++) {

			uniqueCounter++;

			require(!_exists(uniqueCounter));

			

			// mint also triggers transfer event

			_mint(address(msg.sender), uniqueCounter);

			

			(uint _weaponRarity, uint _weaponType) = genesContract.generateData(uniqueCounter);

			weapons[uniqueCounter].rarity = _weaponRarity;

			weapons[uniqueCounter].weaponType = _weaponType;

			

			emit WeaponBought(msg.sender, uniqueCounter, _weaponRarity, _weaponType);

		}

		

		if (refIdAddress[_refId] != address(0) && msg.sender != refIdAddress[_refId]) {

		    uint amountRef = msg.value.mul(refCut[_refId]).div(100);

		    refIdAddress[_refId].transfer(amountRef);

		    emit RefPaid(_refId, refIdAddress[_refId], amountRef);

		}

	}

	

	

	// buy a guaranteed rare weapon

	function buyWeaponRare(uint amount, uint _refId) public payable notPaused {

		require(_rareWeaponPrice.mul(amount) == msg.value);

		require(now < presaleLockdown);



		for (uint i=0;i<amount;i++) {

			uniqueCounter++;

			require(!_exists(uniqueCounter));

			

			// mint also triggers transfer event

			_mint(address(msg.sender), uniqueCounter);

			

			uint _weaponType = genesContract.generateRareMythicData(uniqueCounter);

			weapons[uniqueCounter].rarity = 1;

			weapons[uniqueCounter].weaponType = _weaponType;



			emit WeaponBought(msg.sender, uniqueCounter, 1, _weaponType);

		}

		

		if (refIdAddress[_refId] != address(0) && msg.sender != refIdAddress[_refId]) {

		    uint amountRef = msg.value.mul(refCut[_refId]).div(100);

		    refIdAddress[_refId].transfer(amountRef);

		    emit RefPaid(_refId, refIdAddress[_refId], amountRef);

		}

	}

	

	

	// buy a guaranteed mythic weapon

	function buyWeaponMythic(uint amount, uint _refId) public payable notPaused {

		require(_mythicWeaponPrice.mul(amount) == msg.value);

		require(now < presaleLockdown);



		for (uint i=0;i<amount;i++) {

			uniqueCounter++;

			require(!_exists(uniqueCounter));

			

			// mint also triggers transfer event

			_mint(address(msg.sender), uniqueCounter);

			

			uint _weaponType = genesContract.generateRareMythicData(uniqueCounter);

			weapons[uniqueCounter].rarity = 2;

			weapons[uniqueCounter].weaponType = _weaponType;



			emit WeaponBought(msg.sender, uniqueCounter, 2, _weaponType);

		}

		

		if (refIdAddress[_refId] != address(0) && msg.sender != refIdAddress[_refId]) {

		    uint amountRef = msg.value.mul(refCut[_refId]).div(100);

		    refIdAddress[_refId].transfer(amountRef);

		    emit RefPaid(_refId, refIdAddress[_refId], amountRef);

		}

	}

	

	

	// buy a guaranteed legendary weapon

	function buyWeaponLegendary(uint amount, uint _refId) public payable notPaused {

		require(_legendaryWeaponPrice.mul(amount) == msg.value);

		require(now < presaleLockdown);



		for (uint i=0;i<amount;i++) {

			uniqueCounter++;

			require(!_exists(uniqueCounter));

			

			// mint also triggers transfer event

			_mint(address(msg.sender), uniqueCounter);

			

			uint _weaponType = genesContract.generateLegendaryData(uniqueCounter);

			weapons[uniqueCounter].rarity = 3;

			weapons[uniqueCounter].weaponType = _weaponType;



			emit WeaponBought(msg.sender, uniqueCounter, 3, _weaponType);

		}

		

		if (refIdAddress[_refId] != address(0) && msg.sender != refIdAddress[_refId]) {

		    uint amountRef = msg.value.mul(refCut[_refId]).div(100);

		    refIdAddress[_refId].transfer(amountRef);

		    emit RefPaid(_refId, refIdAddress[_refId], amountRef);

		}

	}



	// mint weapon as result of voucher purchase or what not

	// code is used to identify weapon and apply required stats

	function mintWeaponToAddr(uint _weaponRarity, uint _weaponType, address _receiver, string _code) public mintAllowed(msg.sender) {



        if (_weaponType < 10 || (_weaponType>=8000 && _weaponType<=8013)) revert();

        

		uniqueCounter++;

		require(!_exists(uniqueCounter));



		// mint also triggers transfer event

		_mint(address(_receiver), uniqueCounter);

		

		weapons[uniqueCounter].rarity = _weaponRarity;

		weapons[uniqueCounter].weaponType = _weaponType;

		

		emit WeaponMintedToAddr(_receiver, uniqueCounter, _weaponRarity, _weaponType, _code);



	}

	

	

	// Chibis can claim their initial weapon

	// that is also the only way to get a founder weapon

	//

	function claimWeapon(uint _chibiId) public claimNotPaused {

		require(chibiContract.ownerOf(_chibiId) == msg.sender);

		require(_weaponClaimed[_chibiId] == false);

		

		uniqueCounter++;

		

		// mark claimed

		_weaponClaimed[_chibiId] = true;

		

		// get weapon dna of chibi

		(uint _weaponType, uint _chibiRarity) = getChibiWeaponDna(_chibiId);

		

		_mint(address(msg.sender), uniqueCounter);

		

		weapons[uniqueCounter].weaponType = _weaponType;



		if (_weaponType < 10 || _weaponType > 7999) {

			weapons[uniqueCounter].rarity = 3;

		} else {

			// rarity comes from chibi when claimed, however legendary chibis still get just a mythic weapon since legendary weapons are either bought or made with a fragment

			if (_chibiRarity == 3) weapons[uniqueCounter].rarity = 2;

				else weapons[uniqueCounter].rarity = _chibiRarity;

		}



		emit WeaponClaimed(msg.sender, _chibiId, uniqueCounter, weapons[uniqueCounter].rarity, weapons[uniqueCounter].weaponType);

		

	}

	

	// old chibi contract

	function claimWeaponOld(uint _chibiId) public notPaused {

		require(chibiContract.ownerOf(_chibiId) == msg.sender);

		require(_weaponClaimed[_chibiId] == false);

		

		uniqueCounter++;

		

		// mark claimed

		_weaponClaimed[_chibiId] = true;

		

		// get weapon dna of chibi

		uint16[13] memory _dna;

		(

		,

		,

		_dna,

		,

		,

		,

		

		) = chibiContract.queryChibi(_chibiId);

		

		uint _weaponType = _dna[7];

		uint _chibiRarity = _dna[8];



		_mint(address(msg.sender), uniqueCounter);

		

		weapons[uniqueCounter].weaponType = _weaponType;



		if (_weaponType < 10 || _weaponType > 7999) {

			weapons[uniqueCounter].rarity = 3;

		}else {

			// rarity comes from chibi when claimed, however legendary chibis still get just a mythic weapon since legendary weapons are either bought or made with a fragment

			if (_chibiRarity == 3) weapons[uniqueCounter].rarity = 2;

				else weapons[uniqueCounter].rarity = _chibiRarity;

		}



		emit WeaponClaimed(msg.sender, _chibiId, uniqueCounter, weapons[uniqueCounter].rarity, weapons[uniqueCounter].weaponType);

		

	}





	function queryForSale(uint _tokenId) public view returns (uint price, address owner) {

		require(_isApprovedOrOwner(this, _tokenId));

		

		return (

			_weaponSalePrice[_tokenId],

			ownerOf(_tokenId)

		);

	}



	

	/**

	* @dev Send Ether to owner

	* @param _address Receiving address

	* @param _amountWei Amount in WEI to send

	**/

	function weiToOwner(address _address, uint _amountWei) public contract_onlyOwner returns (bool success) {

		require(_amountWei <= address(this).balance);

		_address.transfer(_amountWei);

		return true;

	}

	

	function ERC20ToOwner(address _to, uint256 _amount, ERC20Interface _tokenContract) public contract_onlyOwner {

		_tokenContract.transfer(_to, _amount);

	}



	function ERC20ClassicToOwner(address _to, uint256 _amount, ERC20InterfaceClassic _tokenContract) public contract_onlyOwner {

		_tokenContract.transfer(_to, _amount);

	}

	

	function queryERC20(ERC20Interface _tokenContract) public view contract_onlyOwner returns (uint) {

		return _tokenContract.balanceOf(this);

	}





	modifier notPaused() {

		require(gameState == false);

		_;

	}

	

	modifier claimNotPaused() {

		require(gameStateClaim == false);

		_;

	}

	

}
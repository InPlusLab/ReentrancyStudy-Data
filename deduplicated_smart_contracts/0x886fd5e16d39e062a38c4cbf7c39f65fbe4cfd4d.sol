pragma solidity ^0.4.24;
	
	/*
	
	Created By Daniel Pittman
	Qwoyn.io
	2018
	
	CryptoCaps A smartcontract that mints unique bottle caps and 
	slammers in order to play the infamous game Pogs on the blockchain!
	
	ERC721
	
	*/
	
	

	/**
	 * @title SafeMath
	 * @dev Math operations with safety checks that throw on error
	 */
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

	/**
	 * @title ERC165
	 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
	 */
	interface ERC165 {

	  /**
	   * @notice Query if a contract implements an interface
	   * @param _interfaceId The interface identifier, as specified in ERC-165
	   * @dev Interface identification is specified in ERC-165. This function
	   * uses less than 30,000 gas.
	   */
	  function supportsInterface(bytes4 _interfaceId)
		external
		view
		returns (bool);
	}

	/**
	 * @title ERC721 token receiver interface
	 * @dev Interface for any contract that wants to support safeTransfers
	 * from ERC721 asset contracts.
	 */
	contract ERC721Receiver {
	  /**
	   * @dev Magic value to be returned upon successful reception of an NFT
	   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
	   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
	   */
	  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

	  /**
	   * @notice Handle the receipt of an NFT
	   * @dev The ERC721 smart contract calls this function on the recipient
	   * after a `safetransfer`. This function MAY throw to revert and reject the
	   * transfer. Return of other than the magic value MUST result in the 
	   * transaction being reverted.
	   * Note: the contract address is always the message sender.
	   * @param _operator The address which called `safeTransferFrom` function
	   * @param _from The address which previously owned the token
	   * @param _tokenId The NFT identifier which is being transfered
	   * @param _data Additional data with no specified format
	   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
	   */
	  function onERC721Received(
		address _operator,
		address _from,
		uint256 _tokenId,
		bytes _data
	  )
		public
		returns(bytes4);
	}

	/**
	 * Utility library of inline functions on addresses
	 */
	library AddressUtils {

	  /**
	   * Returns whether the target address is a contract
	   * @dev This function will return false if invoked during the constructor of a contract,
	   * as the code is not actually created until after the constructor finishes.
	   * @param addr address to check
	   * @return whether the target address is a contract
	   */
	  function isContract(address addr) internal view returns (bool) {
		uint256 size;
		// XXX Currently there is no better way to check if there is a contract in an address
		// than to check the size of the code at that address.
		// See https://ethereum.stackexchange.com/a/14016/36603
		// for more details about how this works.
		// TODO Check this again before the Serenity release, because all addresses will be
		// contracts then.
		// solium-disable-next-line security/no-inline-assembly
		assembly { size := extcodesize(addr) }
		return size > 0;
	  }

	}

	/**
	 * @title Ownable
	 * @dev The Ownable contract has an owner address, and provides basic authorization control
	 * functions, this simplifies the implementation of "user permissions".
	 */
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
	   * @notice Renouncing to ownership will leave the contract without an owner.
	   * It will not be possible to call the functions with the `onlyOwner`
	   * modifier anymore.
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

	/**
	 * @title SupportsInterfaceWithLookup
	 * @author Matt Condon (@shrugs)
	 * @dev Implements ERC165 using a lookup table.
	 */
	contract SupportsInterfaceWithLookup is ERC165 {
	  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
	  /**
	   * 0x01ffc9a7 ===
	   *   bytes4(keccak256('supportsInterface(bytes4)'))
	   */

	  /**
	   * @dev a mapping of interface id to whether or not it's supported
	   */
	  mapping(bytes4 => bool) internal supportedInterfaces;

	  /**
	   * @dev A contract implementing SupportsInterfaceWithLookup
	   * implement ERC165 itself
	   */
	  constructor()
		public
	  {
		_registerInterface(InterfaceId_ERC165);
	  }

	  /**
	   * @dev implement supportsInterface(bytes4) using a lookup table
	   */
	  function supportsInterface(bytes4 _interfaceId)
		external
		view
		returns (bool)
	  {
		return supportedInterfaces[_interfaceId];
	  }

	  /**
	   * @dev private method for registering an interface
	   */
	  function _registerInterface(bytes4 _interfaceId)
		internal
	  {
		require(_interfaceId != 0xffffffff);
		supportedInterfaces[_interfaceId] = true;
	  }
	}

	/**
	 * @title ERC721 Non-Fungible Token Standard basic interface
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
	contract ERC721Basic is ERC165 {
	  event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 indexed _tokenId
	  );
	  event Approval(
		address indexed _owner,
		address indexed _approved,
		uint256 indexed _tokenId
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

	/**
	 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
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


	/**
	 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
	contract ERC721Metadata is ERC721Basic {
	  function name() external view returns (string _name);
	  function symbol() external view returns (string _symbol);
	  function tokenURI(uint256 _tokenId) public view returns (string);
	}


	/**
	 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
	contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
	}

	/**
	 * @title ERC721 Non-Fungible Token Standard basic implementation
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
	contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

	  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
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

	  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
	  /*
	   * 0x4f558e79 ===
	   *   bytes4(keccak256('exists(uint256)'))
	   */

	  using SafeMath for uint256;
	  using AddressUtils for address;

	  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
	  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
	  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

	  // Mapping from token ID to owner
	  mapping (uint256 => address) internal tokenOwner;

	  // Mapping from token ID to approved address
	  mapping (uint256 => address) internal tokenApprovals;

	  // Mapping from owner to number of owned token
	  mapping (address => uint256) internal ownedTokensCount;

	  // Mapping from owner to operator approvals
	  mapping (address => mapping (address => bool)) internal operatorApprovals;

	  /**
	   * @dev Guarantees msg.sender is owner of the given token
	   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
	   */
	  modifier onlyOwnerOf(uint256 _tokenId) {
		require(ownerOf(_tokenId) == msg.sender);
		_;
	  }

	  /**
	   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
	   * @param _tokenId uint256 ID of the token to validate
	   */
	  modifier canTransfer(uint256 _tokenId) {
		require(isApprovedOrOwner(msg.sender, _tokenId));
		_;
	  }

	  constructor()
		public
	  {
		// register the supported interfaces to conform to ERC721 via ERC165
		_registerInterface(InterfaceId_ERC721);
		_registerInterface(InterfaceId_ERC721Exists);
	  }

	  /**
	   * @dev Gets the balance of the specified address
	   * @param _owner address to query the balance of
	   * @return uint256 representing the amount owned by the passed address
	   */
	  function balanceOf(address _owner) public view returns (uint256) {
		require(_owner != address(0));
		return ownedTokensCount[_owner];
	  }

	  /**
	   * @dev Gets the owner of the specified token ID
	   * @param _tokenId uint256 ID of the token to query the owner of
	   * @return owner address currently marked as the owner of the given token ID
	   */
	  function ownerOf(uint256 _tokenId) public view returns (address) {
		address owner = tokenOwner[_tokenId];
		require(owner != address(0));
		return owner;
	  }

	  /**
	   * @dev Returns whether the specified token exists
	   * @param _tokenId uint256 ID of the token to query the existence of
	   * @return whether the token exists
	   */
	  function exists(uint256 _tokenId) public view returns (bool) {
		address owner = tokenOwner[_tokenId];
		return owner != address(0);
	  }

	  /**
	   * @dev Approves another address to transfer the given token ID
	   * The zero address indicates there is no approved address.
	   * There can only be one approved address per token at a given time.
	   * Can only be called by the token owner or an approved operator.
	   * @param _to address to be approved for the given token ID
	   * @param _tokenId uint256 ID of the token to be approved
	   */
	  function approve(address _to, uint256 _tokenId) public {
		address owner = ownerOf(_tokenId);
		require(_to != owner);
		require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

		tokenApprovals[_tokenId] = _to;
		emit Approval(owner, _to, _tokenId);
	  }

	  /**
	   * @dev Gets the approved address for a token ID, or zero if no address set
	   * @param _tokenId uint256 ID of the token to query the approval of
	   * @return address currently approved for the given token ID
	   */
	  function getApproved(uint256 _tokenId) public view returns (address) {
		return tokenApprovals[_tokenId];
	  }

	  /**
	   * @dev Sets or unsets the approval of a given operator
	   * An operator is allowed to transfer all tokens of the sender on their behalf
	   * @param _to operator address to set the approval
	   * @param _approved representing the status of the approval to be set
	   */
	  function setApprovalForAll(address _to, bool _approved) public {
		require(_to != msg.sender);
		operatorApprovals[msg.sender][_to] = _approved;
		emit ApprovalForAll(msg.sender, _to, _approved);
	  }

	  /**
	   * @dev Tells whether an operator is approved by a given owner
	   * @param _owner owner address which you want to query the approval of
	   * @param _operator operator address which you want to query the approval of
	   * @return bool whether the given operator is approved by the given owner
	   */
	  function isApprovedForAll(
		address _owner,
		address _operator
	  )
		public
		view
		returns (bool)
	  {
		return operatorApprovals[_owner][_operator];
	  }

	  /**
	   * @dev Transfers the ownership of a given token ID to another address
	   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
	   * Requires the msg sender to be the owner, approved, or operator
	   * @param _from current owner of the token
	   * @param _to address to receive the ownership of the given token ID
	   * @param _tokenId uint256 ID of the token to be transferred
	  */
	  function transferFrom(
		address _from,
		address _to,
		uint256 _tokenId
	  )
		public
		canTransfer(_tokenId)
	  {
		require(_from != address(0));
		require(_to != address(0));

		clearApproval(_from, _tokenId);
		removeTokenFrom(_from, _tokenId);
		addTokenTo(_to, _tokenId);

		emit Transfer(_from, _to, _tokenId);
	  }

	  /**
	   * @dev Safely transfers the ownership of a given token ID to another address
	   * If the target address is a contract, it must implement `onERC721Received`,
	   * which is called upon a safe transfer, and return the magic value
	   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
	   * the transfer is reverted.
	   *
	   * Requires the msg sender to be the owner, approved, or operator
	   * @param _from current owner of the token
	   * @param _to address to receive the ownership of the given token ID
	   * @param _tokenId uint256 ID of the token to be transferred
	  */
	  function safeTransferFrom(
		address _from,
		address _to,
		uint256 _tokenId
	  )
		public
		canTransfer(_tokenId)
	  {
		// solium-disable-next-line arg-overflow
		safeTransferFrom(_from, _to, _tokenId, "");
	  }

	  /**
	   * @dev Safely transfers the ownership of a given token ID to another address
	   * If the target address is a contract, it must implement `onERC721Received`,
	   * which is called upon a safe transfer, and return the magic value
	   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
	   * the transfer is reverted.
	   * Requires the msg sender to be the owner, approved, or operator
	   * @param _from current owner of the token
	   * @param _to address to receive the ownership of the given token ID
	   * @param _tokenId uint256 ID of the token to be transferred
	   * @param _data bytes data to send along with a safe transfer check
	   */
	  function safeTransferFrom(
		address _from,
		address _to,
		uint256 _tokenId,
		bytes _data
	  )
		public
		canTransfer(_tokenId)
	  {
		transferFrom(_from, _to, _tokenId);
		// solium-disable-next-line arg-overflow
		require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
	  }

	  /**
	   * @dev Returns whether the given spender can transfer a given token ID
	   * @param _spender address of the spender to query
	   * @param _tokenId uint256 ID of the token to be transferred
	   * @return bool whether the msg.sender is approved for the given token ID,
	   *  is an operator of the owner, or is the owner of the token
	   */
	  function isApprovedOrOwner(
		address _spender,
		uint256 _tokenId
	  )
		internal
		view
		returns (bool)
	  {
		address owner = ownerOf(_tokenId);
		// Disable solium check because of
		// https://github.com/duaraghav8/Solium/issues/175
		// solium-disable-next-line operator-whitespace
		return (
		  _spender == owner ||
		  getApproved(_tokenId) == _spender ||
		  isApprovedForAll(owner, _spender)
		);
	  }

	  /**
	   * @dev Internal function to mint a new token
	   * Reverts if the given token ID already exists
	   * @param _to The address that will own the minted token
	   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
	   */
	  function _mint(address _to, uint256 _tokenId) internal {
		require(_to != address(0));
		addTokenTo(_to, _tokenId);
		emit Transfer(address(0), _to, _tokenId);
	  }

	  /**
	   * @dev Internal function to burn a specific token
	   * Reverts if the token does not exist
	   * @param _tokenId uint256 ID of the token being burned by the msg.sender
	   */
	  function _burn(address _owner, uint256 _tokenId) internal {
		clearApproval(_owner, _tokenId);
		removeTokenFrom(_owner, _tokenId);
		emit Transfer(_owner, address(0), _tokenId);
	  }

	  /**
	   * @dev Internal function to clear current approval of a given token ID
	   * Reverts if the given address is not indeed the owner of the token
	   * @param _owner owner of the token
	   * @param _tokenId uint256 ID of the token to be transferred
	   */
	  function clearApproval(address _owner, uint256 _tokenId) internal {
		require(ownerOf(_tokenId) == _owner);
		if (tokenApprovals[_tokenId] != address(0)) {
		  tokenApprovals[_tokenId] = address(0);
		}
	  }

	  /**
	   * @dev Internal function to add a token ID to the list of a given address
	   * @param _to address representing the new owner of the given token ID
	   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
	   */
	  function addTokenTo(address _to, uint256 _tokenId) internal {
		require(tokenOwner[_tokenId] == address(0));
		tokenOwner[_tokenId] = _to;
		ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
	  }

	  /**
	   * @dev Internal function to remove a token ID from the list of a given address
	   * @param _from address representing the previous owner of the given token ID
	   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
	   */
	  function removeTokenFrom(address _from, uint256 _tokenId) internal {
		require(ownerOf(_tokenId) == _from);
		ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
		tokenOwner[_tokenId] = address(0);
	  }

	  /**
	   * @dev Internal function to invoke `onERC721Received` on a target address
	   * The call is not executed if the target address is not a contract
	   * @param _from address representing the previous owner of the given token ID
	   * @param _to target address that will receive the tokens
	   * @param _tokenId uint256 ID of the token to be transferred
	   * @param _data bytes optional data to send along with the call
	   * @return whether the call correctly returned the expected magic value
	   */
	  function checkAndCallSafeTransfer(
		address _from,
		address _to,
		uint256 _tokenId,
		bytes _data
	  )
		internal
		returns (bool)
	  {
		if (!_to.isContract()) {
		  return true;
		}
		bytes4 retval = ERC721Receiver(_to).onERC721Received(
		  msg.sender, _from, _tokenId, _data);
		return (retval == ERC721_RECEIVED);
	  }
	}

	/**
	 * @title Full ERC721 Token
	 * This implementation includes all the required and some optional functionality of the ERC721 standard
	 * Moreover, it includes approve all functionality using operator terminology
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
	 */
	contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

	  bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
	  /**
	   * 0x780e9d63 ===
	   *   bytes4(keccak256('totalSupply()')) ^
	   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
	   *   bytes4(keccak256('tokenByIndex(uint256)'))
	   */

	  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
	  /**
	   * 0x5b5e139f ===
	   *   bytes4(keccak256('name()')) ^
	   *   bytes4(keccak256('symbol()')) ^
	   *   bytes4(keccak256('tokenURI(uint256)'))
	   */

	  // Token name
	  string internal name_;

	  // Token symbol
	  string internal symbol_;

	  // Mapping from owner to list of owned token IDs
	  mapping(address => uint256[]) internal ownedTokens;

	  // Mapping from token ID to index of the owner tokens list
	  mapping(uint256 => uint256) internal ownedTokensIndex;

	  // Array with all token ids, used for enumeration
	  uint256[] internal allTokens;

	  // Mapping from token id to position in the allTokens array
	  mapping(uint256 => uint256) internal allTokensIndex;

	  // Optional mapping for token URIs
	  mapping(uint256 => string) internal tokenURIs;

	  /**
	   * @dev Constructor function
	   */
	  constructor(string _name, string _symbol) public {
		name_ = _name;
		symbol_ = _symbol;

		// register the supported interfaces to conform to ERC721 via ERC165
		_registerInterface(InterfaceId_ERC721Enumerable);
		_registerInterface(InterfaceId_ERC721Metadata);
	  }

	  /**
	   * @dev Gets the token name
	   * @return string representing the token name
	   */
	  function name() external view returns (string) {
		return name_;
	  }

	  /**
	   * @dev Gets the token symbol
	   * @return string representing the token symbol
	   */
	  function symbol() external view returns (string) {
		return symbol_;
	  }

	  /**
	   * @dev Returns an URI for a given token ID
	   * Throws if the token ID does not exist. May return an empty string.
	   * @param _tokenId uint256 ID of the token to query
	   */
	  function tokenURI(uint256 _tokenId) public view returns (string) {
		require(exists(_tokenId));
		return tokenURIs[_tokenId];
	  }

	  /**
	   * @dev Gets the token ID at a given index of the tokens list of the requested owner
	   * @param _owner address owning the tokens list to be accessed
	   * @param _index uint256 representing the index to be accessed of the requested tokens list
	   * @return uint256 token ID at the given index of the tokens list owned by the requested address
	   */
	  function tokenOfOwnerByIndex(
		address _owner,
		uint256 _index
	  )
		public
		view
		returns (uint256)
	  {
		require(_index < balanceOf(_owner));
		return ownedTokens[_owner][_index];
	  }

	  /**
	   * @dev Gets the total amount of tokens stored by the contract
	   * @return uint256 representing the total amount of tokens
	   */
	  function totalSupply() public view returns (uint256) {
		return allTokens.length;
	  }

	  /**
	   * @dev Gets the token ID at a given index of all the tokens in this contract
	   * Reverts if the index is greater or equal to the total number of tokens
	   * @param _index uint256 representing the index to be accessed of the tokens list
	   * @return uint256 token ID at the given index of the tokens list
	   */
	  function tokenByIndex(uint256 _index) public view returns (uint256) {
		require(_index < totalSupply());
		return allTokens[_index];
	  }

	  /**
	   * @dev Internal function to set the token URI for a given token
	   * Reverts if the token ID does not exist
	   * @param _tokenId uint256 ID of the token to set its URI
	   * @param _uri string URI to assign
	   */
	  function _setTokenURI(uint256 _tokenId, string _uri) internal {
		require(exists(_tokenId));
		tokenURIs[_tokenId] = _uri;
	  }

	  /**
	   * @dev Internal function to add a token ID to the list of a given address
	   * @param _to address representing the new owner of the given token ID
	   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
	   */
	  function addTokenTo(address _to, uint256 _tokenId) internal {
		super.addTokenTo(_to, _tokenId);
		uint256 length = ownedTokens[_to].length;
		ownedTokens[_to].push(_tokenId);
		ownedTokensIndex[_tokenId] = length;
	  }

	  /**
	   * @dev Internal function to remove a token ID from the list of a given address
	   * @param _from address representing the previous owner of the given token ID
	   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
	   */
	  function removeTokenFrom(address _from, uint256 _tokenId) internal {
		super.removeTokenFrom(_from, _tokenId);

		uint256 tokenIndex = ownedTokensIndex[_tokenId];
		uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
		uint256 lastToken = ownedTokens[_from][lastTokenIndex];

		ownedTokens[_from][tokenIndex] = lastToken;
		ownedTokens[_from][lastTokenIndex] = 0;
		// Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
		// be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
		// the lastToken to the first position, and then dropping the element placed in the last position of the list

		ownedTokens[_from].length--;
		ownedTokensIndex[_tokenId] = 0;
		ownedTokensIndex[lastToken] = tokenIndex;
	  }

	  /**
	   * @dev Internal function to mint a new token
	   * Reverts if the given token ID already exists
	   * @param _to address the beneficiary that will own the minted token
	   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
	   */
	  function _mint(address _to, uint256 _tokenId) internal {
		super._mint(_to, _tokenId);

		allTokensIndex[_tokenId] = allTokens.length;
		allTokens.push(_tokenId);
	  }

	  /**
	   * @dev Internal function to burn a specific token
	   * Reverts if the token does not exist
	   * @param _owner owner of the token to burn
	   * @param _tokenId uint256 ID of the token being burned by the msg.sender
	   */
	  function _burn(address _owner, uint256 _tokenId) internal {
		super._burn(_owner, _tokenId);

		// Clear metadata (if any)
		if (bytes(tokenURIs[_tokenId]).length != 0) {
		  delete tokenURIs[_tokenId];
		}

		// Reorg all tokens array
		uint256 tokenIndex = allTokensIndex[_tokenId];
		uint256 lastTokenIndex = allTokens.length.sub(1);
		uint256 lastToken = allTokens[lastTokenIndex];

		allTokens[tokenIndex] = lastToken;
		allTokens[lastTokenIndex] = 0;

		allTokens.length--;
		allTokensIndex[_tokenId] = 0;
		allTokensIndex[lastToken] = tokenIndex;
	  }

	}

	contract CryptoCaps is ERC721Token, Ownable {

	  /*** EVENTS ***/
	  /// The event emitted (useable by web3) when a token is purchased
	  event BoughtToken(address indexed buyer, uint256 tokenId);

	  /*** CONSTANTS ***/
	  uint8 constant TITLE_MIN_LENGTH = 1;
	  uint8 constant TITLE_MAX_LENGTH = 64;
	  uint256 constant DESCRIPTION_MIN_LENGTH = 1;
	  uint256 constant DESCRIPTION_MAX_LENGTH = 10000;

	  /*** DATA TYPES ***/

	  /// Price set by contract owner for each token in Wei.
	  /// @dev If you'd like a different price for each token type, you will
	  ///   need to use a mapping like: `mapping(uint256 => uint256) tokenTypePrices;`
	  uint256 currentPrice = 0;

	  /// The token type (1 for idea, 2 for belonging, etc)
	  mapping(uint256 => uint256) tokenTypes;

	  /// The title of the token
	  mapping(uint256 => string) tokenTitles;
	  
	  /// The description of the token
	  mapping(uint256 => string) tokenDescription;

	  constructor() ERC721Token("CryptoCaps", "QCC") public {
		// any init code when you deploy the contract would run here
	  }

	  /// Requires the amount of Ether be at least or more of the currentPrice
	  /// @dev Creates an instance of an token and mints it to the purchaser
	  /// @param _type The token type as an integer
	  /// @param _title The short title of the token
	  /// @param _description Description of the token
	  function buyToken (
		uint256 _type,
		string _title,
		string _description
	  ) external payable {
		bytes memory _titleBytes = bytes(_title);
		require(_titleBytes.length >= TITLE_MIN_LENGTH, "Title is too short");
		require(_titleBytes.length <= TITLE_MAX_LENGTH, "Title is too long");
		
		bytes memory _descriptionBytes = bytes(_description);
		require(_descriptionBytes.length >= DESCRIPTION_MIN_LENGTH, "Description is too short");
		require(_descriptionBytes.length <= DESCRIPTION_MAX_LENGTH, "Description is too long");
		require(msg.value >= currentPrice, "Amount of Ether sent too small");

		uint256 index = allTokens.length + 1;

		_mint(msg.sender, index);

		tokenTypes[index] = _type;
		tokenTitles[index] = _title;
		tokenDescription[index] = _description;

		emit BoughtToken(msg.sender, index);
	  }

	  /**
	   * @dev Returns all of the tokens that the user owns
	   * @return An array of token indices
	   */
	  function myTokens()
		external
		view
		returns (
		  uint256[]
		)
	  {
		return ownedTokens[msg.sender];
	  }

	  /// @notice Returns all the relevant information about a specific token
	  /// @param _tokenId The ID of the token of interest
	  function viewToken(uint256 _tokenId)
		external
		view
		returns (
		  uint256 tokenType_,
		  string tokenTitle_,
		  string tokenDescription_
	  ) {
		  tokenType_ = tokenTypes[_tokenId];
		  tokenTitle_ = tokenTitles[_tokenId];
		  tokenDescription_ = tokenDescription[_tokenId];
	  }

	  /// @notice Allows the owner of this contract to set the currentPrice for each token
	  function setCurrentPrice(uint256 newPrice)
		public
		onlyOwner
	  {
		  currentPrice = newPrice;
	  }

	  /// @notice Returns the currentPrice for each token
	  function getCurrentPrice()
		external
		view
		returns (
		uint256 price
	  ) {
		  price = currentPrice;
	  }
	  /// @notice allows the owner of this contract to destroy the contract
	   function kill() public {
		  if(msg.sender == owner) selfdestruct(owner);
	   }  
	}
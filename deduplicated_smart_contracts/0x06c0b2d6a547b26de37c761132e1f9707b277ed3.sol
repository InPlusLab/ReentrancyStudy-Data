/**

 *Submitted for verification at Etherscan.io on 2018-08-12

*/



pragma solidity 0.4.21;



// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

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



// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





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

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



// File: zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Basic {

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);



  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId) public view returns (address _operator);



  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator) public view returns (bool);



  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(

    address _from,

    address _to,

    uint256 _tokenId,

    bytes _data

  )

    public;

}



// File: zeppelin-solidity/contracts/token/ERC721/ERC721.sol



/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Enumerable is ERC721Basic {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Metadata is ERC721Basic {

  function name() public view returns (string _name);

  function symbol() public view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, full implementation interface

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}



// File: zeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 *  from ERC721 asset contracts.

 */

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

  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);

}



// File: zeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */

library AddressUtils {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   *  as the code is not actually created until after the constructor finishes.

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

    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly

    return size > 0;

  }



}



// File: zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721BasicToken is ERC721Basic {

  using SafeMath for uint256;

  using AddressUtils for address;



  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`

  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;



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

   * @param _tokenId uint256 ID of the token to query the existance of

   * @return whether the token exists

   */

  function exists(uint256 _tokenId) public view returns (bool) {

    address owner = tokenOwner[_tokenId];

    return owner != address(0);

  }



  /**

   * @dev Approves another address to transfer the given token ID

   * @dev The zero address indicates there is no approved address.

   * @dev There can only be one approved address per token at a given time.

   * @dev Can only be called by the token owner or an approved operator.

   * @param _to address to be approved for the given token ID

   * @param _tokenId uint256 ID of the token to be approved

   */

  function approve(address _to, uint256 _tokenId) public {

    address owner = ownerOf(_tokenId);

    require(_to != owner);

    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



    if (getApproved(_tokenId) != address(0) || _to != address(0)) {

      tokenApprovals[_tokenId] = _to;

      emit Approval(owner, _to, _tokenId);

    }

  }



  /**

   * @dev Gets the approved address for a token ID, or zero if no address set

   * @param _tokenId uint256 ID of the token to query the approval of

   * @return address currently approved for a the given token ID

   */

  function getApproved(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];

  }



  /**

   * @dev Sets or unsets the approval of a given operator

   * @dev An operator is allowed to transfer all tokens of the sender on their behalf

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

  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

    return operatorApprovals[_owner][_operator];

  }



  /**

   * @dev Transfers the ownership of a given token ID to another address

   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible

   * @dev Requires the msg sender to be the owner, approved, or operator

   * @param _from current owner of the token

   * @param _to address to receive the ownership of the given token ID

   * @param _tokenId uint256 ID of the token to be transferred

  */

  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {

    require(_from != address(0));

    require(_to != address(0));



    clearApproval(_from, _tokenId);

    removeTokenFrom(_from, _tokenId);

    addTokenTo(_to, _tokenId);



    emit Transfer(_from, _to, _tokenId);

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * @dev If the target address is a contract, it must implement `onERC721Received`,

   *  which is called upon a safe transfer, and return the magic value

   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,

   *  the transfer is reverted.

   * @dev Requires the msg sender to be the owner, approved, or operator

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

   * @dev If the target address is a contract, it must implement `onERC721Received`,

   *  which is called upon a safe transfer, and return the magic value

   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,

   *  the transfer is reverted.

   * @dev Requires the msg sender to be the owner, approved, or operator

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

  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {

    address owner = ownerOf(_tokenId);

    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);

  }



  /**

   * @dev Internal function to mint a new token

   * @dev Reverts if the given token ID already exists

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

   * @dev Reverts if the token does not exist

   * @param _tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address _owner, uint256 _tokenId) internal {

    clearApproval(_owner, _tokenId);

    removeTokenFrom(_owner, _tokenId);

    emit Transfer(_owner, address(0), _tokenId);

  }



  /**

   * @dev Internal function to clear current approval of a given token ID

   * @dev Reverts if the given address is not indeed the owner of the token

   * @param _owner owner of the token

   * @param _tokenId uint256 ID of the token to be transferred

   */

  function clearApproval(address _owner, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _owner);

    if (tokenApprovals[_tokenId] != address(0)) {

      tokenApprovals[_tokenId] = address(0);

      emit Approval(_owner, address(0), _tokenId);

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

   * @dev The call is not executed if the target address is not a contract

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

    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);

    return (retval == ERC721_RECEIVED);

  }

}



// File: zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol



/**

 * @title Full ERC721 Token

 * This implementation includes all the required and some optional functionality of the ERC721 standard

 * Moreover, it includes approve all functionality using operator terminology

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Token is ERC721, ERC721BasicToken {

  // Token name

  string internal name_;



  // Token symbol

  string internal symbol_;



  // Mapping from owner to list of owned token IDs

  mapping (address => uint256[]) internal ownedTokens;



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

  function ERC721Token(string _name, string _symbol) public {

    name_ = _name;

    symbol_ = _symbol;

  }



  /**

   * @dev Gets the token name

   * @return string representing the token name

   */

  function name() public view returns (string) {

    return name_;

  }



  /**

   * @dev Gets the token symbol

   * @return string representing the token symbol

   */

  function symbol() public view returns (string) {

    return symbol_;

  }



  /**

   * @dev Returns an URI for a given token ID

   * @dev Throws if the token ID does not exist. May return an empty string.

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

  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {

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

   * @dev Reverts if the index is greater or equal to the total number of tokens

   * @param _index uint256 representing the index to be accessed of the tokens list

   * @return uint256 token ID at the given index of the tokens list

   */

  function tokenByIndex(uint256 _index) public view returns (uint256) {

    require(_index < totalSupply());

    return allTokens[_index];

  }



  /**

   * @dev Internal function to set the token URI for a given token

   * @dev Reverts if the token ID does not exist

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

   * @dev Reverts if the given token ID already exists

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

   * @dev Reverts if the token does not exist

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



// File: contracts/IWasFirstServiceToken.sol



contract IWasFirstServiceToken is StandardToken, Ownable {



    string public constant NAME = "IWasFirstServiceToken"; // solium-disable-line uppercase

    string public constant SYMBOL = "IWF"; // solium-disable-line uppercase

    uint8 public constant DECIMALS = 18; // solium-disable-line uppercase



    uint256 public constant INITIAL_SUPPLY = 10000000 * (10 ** uint256(DECIMALS));

    address fungibleTokenAddress;

    address shareTokenAddress;



    /**

     * @dev Constructor that gives msg.sender all of existing tokens.

     */

    function IWasFirstServiceToken() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

       emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    }



    function getFungibleTokenAddress() public view returns (address) {

        return fungibleTokenAddress;

    }



    function setFungibleTokenAddress(address _address) onlyOwner() public {

        require(fungibleTokenAddress == address(0));

        fungibleTokenAddress = _address;

    }



    function getShareTokenAddress() public view returns (address) {

        return shareTokenAddress;

    }



    function setShareTokenAddress(address _address) onlyOwner() public {

        require(shareTokenAddress == address(0));

        shareTokenAddress = _address;

    }



    function transferByRelatedToken(address _from, address _to, uint256 _value) public returns (bool) {

        require(msg.sender == fungibleTokenAddress || msg.sender == shareTokenAddress);

        require(_to != address(0));

        require(_value <= balances[_from]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

}



// File: contracts/IWasFirstFungibleToken.sol



contract IWasFirstFungibleToken is ERC721Token("IWasFirstFungible", "IWX"), Ownable {



    struct TokenMetaData {

        uint creationTime;

        string creatorMetadataJson;

    }

    address _serviceTokenAddress;

    address _shareTokenAddress;

    mapping (uint256 => string) internal tokenHash;

    mapping (string => uint256) internal tokenIdOfHash;

    uint256 internal tokenIdSeq = 1;

    mapping (uint256 => TokenMetaData[]) internal tokenMetaData;

    

    function hashExists(string hash) public view returns (bool) {

        return tokenIdOfHash[hash] != 0;

    }



    function mint(string hash, string creatorMetadataJson) external {

        require(!hashExists(hash));

        uint256 currentTokenId = tokenIdSeq;

        tokenIdSeq = tokenIdSeq + 1;

        IWasFirstServiceToken serviceToken = IWasFirstServiceToken(_serviceTokenAddress);

        serviceToken.transferByRelatedToken(msg.sender, _shareTokenAddress, 10 ** uint256(serviceToken.DECIMALS()));

        tokenHash[currentTokenId] = hash;

        tokenIdOfHash[hash] = currentTokenId;

        tokenMetaData[currentTokenId].push(TokenMetaData(now, creatorMetadataJson));

        super._mint(msg.sender, currentTokenId);

    }



    function getTokenCreationTime(string hash) public view returns(uint) {

        require(hashExists(hash));

        uint length = tokenMetaData[tokenIdOfHash[hash]].length;

        return tokenMetaData[tokenIdOfHash[hash]][length-1].creationTime;

    }



    function getCreatorMetadata(string hash) public view returns(string) {

        require(hashExists(hash));

        uint length = tokenMetaData[tokenIdOfHash[hash]].length;

        return tokenMetaData[tokenIdOfHash[hash]][length-1].creatorMetadataJson;

    }



    function getMetadataHistoryLength(string hash) public view returns(uint) {

        if(hashExists(hash)) {

            return tokenMetaData[tokenIdOfHash[hash]].length;

        } else {

            return 0;

        }

    }



    function getCreationDateOfHistoricalMetadata(string hash, uint index) public view returns(uint) {

        require(hashExists(hash));

        return tokenMetaData[tokenIdOfHash[hash]][index].creationTime;

    }



    function getCreatorMetadataOfHistoricalMetadata(string hash, uint index) public view returns(string) {

        require(hashExists(hash));

        return tokenMetaData[tokenIdOfHash[hash]][index].creatorMetadataJson;

    }



    function updateMetadata(string hash, string creatorMetadataJson) public {

        require(hashExists(hash));

        require(ownerOf(tokenIdOfHash[hash]) == msg.sender);

        tokenMetaData[tokenIdOfHash[hash]].push(TokenMetaData(now, creatorMetadataJson));

    }



    function getTokenIdByHash(string hash) public view returns(uint256) {

        require(hashExists(hash));

        return tokenIdOfHash[hash];

    }



    function getHashByTokenId(uint256 tokenId) public view returns(string) {

        require(exists(tokenId));

        return tokenHash[tokenId];

    }



    function getNumberOfTokens() public view returns(uint) {

        return allTokens.length;

    }



    function setServiceTokenAddress(address serviceTokenAdress) onlyOwner() public {

        require(_serviceTokenAddress == address(0));

        _serviceTokenAddress = serviceTokenAdress;

    }



    function getServiceTokenAddress() public view returns(address) {

        return _serviceTokenAddress;

    }



    function setShareTokenAddress(address shareTokenAdress) onlyOwner() public {

        require(_shareTokenAddress == address(0));

        _shareTokenAddress = shareTokenAdress;

    }



    function getShareTokenAddress() public view returns(address) {

        return _shareTokenAddress;

    }

}



// File: contracts/IWasFirstShareToken.sol



contract IWasFirstShareToken is StandardToken, Ownable{



    struct TxState {

        uint256 numOfServiceTokenWei;

        uint256 userBalance;

    }



    string public constant NAME = "IWasFirstShareToken"; // solium-disable-line uppercase

    string public constant SYMBOL = "XWF"; // solium-disable-line uppercase

    uint8 public constant DECIMALS = 12; // solium-disable-line uppercase



    uint256 public constant INITIAL_SUPPLY = 100000 * (10 ** uint256(DECIMALS));

    address fungibleTokenAddress;

    address _serviceTokenAddress;

    mapping (address => TxState[]) internal txStates;

    event Withdraw(address to, uint256 value);



	function IWasFirstShareToken() public {

		totalSupply_ = INITIAL_SUPPLY;

		balances[msg.sender] = INITIAL_SUPPLY;

        txStates[msg.sender].push(TxState(0, INITIAL_SUPPLY));

		emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

	}

    function getFungibleTokenAddress() public view returns (address) {

        return fungibleTokenAddress;

    }



    function setFungibleTokenAddress(address _address) onlyOwner() public {

        require(fungibleTokenAddress == address(0));

        fungibleTokenAddress = _address;

    }



    function setServiceTokenAddress(address serviceTokenAdress) onlyOwner() public {

        require(_serviceTokenAddress == address(0));

        _serviceTokenAddress = serviceTokenAdress;

    }



    function getServiceTokenAddress() public view returns(address) {

        return _serviceTokenAddress;

    }



    function transfer(address _to, uint256 _value) public returns (bool) {

        super.transfer(_to, _value);

        uint serviceTokenWei = this.getCurrentNumberOfUsedServiceTokenWei();

        txStates[msg.sender].push(TxState(serviceTokenWei, balances[msg.sender]));

        txStates[_to].push(TxState(serviceTokenWei, balances[_to]));

        return true;

    }



    function getWithdrawAmount(address _address) public view returns(uint256) {

        TxState[] storage states = txStates[_address];

        uint256 withdrawAmount = 0;

        if(states.length == 0) {

            return 0;

        }

        for(uint i=0; i < states.length-1; i++) {

           withdrawAmount += (states[i+1].numOfServiceTokenWei - states[i].numOfServiceTokenWei)*states[i].userBalance/INITIAL_SUPPLY;

        }

        withdrawAmount += (this.getCurrentNumberOfUsedServiceTokenWei() - states[states.length-1].numOfServiceTokenWei)*states[states.length-1].userBalance/INITIAL_SUPPLY;

        return withdrawAmount;

    }



    function withdraw() external {

        uint256 _value = getWithdrawAmount(msg.sender);

        IWasFirstServiceToken serviceToken = IWasFirstServiceToken(_serviceTokenAddress);

        require(_value <= serviceToken.balanceOf(address(this)));

        

        delete txStates[msg.sender];

        serviceToken.transferByRelatedToken(address(this), msg.sender, _value);



        emit Withdraw(msg.sender, _value);

    }



    function getCurrentNumberOfUsedServiceTokenWei() external view returns(uint) {

        IWasFirstFungibleToken fToken = IWasFirstFungibleToken(fungibleTokenAddress);

        return fToken.getNumberOfTokens()*(10**18);

    }

}
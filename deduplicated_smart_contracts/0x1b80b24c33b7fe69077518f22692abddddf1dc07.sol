/**

 *Submitted for verification at Etherscan.io on 2019-03-14

*/



// File: contracts/Strings.sol



library Strings {

    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol

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



    function uint2str(uint i) internal pure returns (string) {

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

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol



pragma solidity ^0.4.23;





/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

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



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol



pragma solidity ^0.4.23;







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



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol



pragma solidity ^0.4.23;





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

  function onERC721Received(

    address _from,

    uint256 _tokenId,

    bytes _data

  )

    public

    returns(bytes4);

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.4.23;





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



// File: openzeppelin-solidity/contracts/AddressUtils.sol



pragma solidity ^0.4.23;





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

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(addr) }

    return size > 0;

  }



}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol



pragma solidity ^0.4.23;













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

   * @param _tokenId uint256 ID of the token to query the existence of

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

   * @return address currently approved for the given token ID

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

   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible

   * @dev Requires the msg sender to be the owner, approved, or operator

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

    bytes4 retval = ERC721Receiver(_to).onERC721Received(

      _from, _tokenId, _data);

    return (retval == ERC721_RECEIVED);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol



pragma solidity ^0.4.23;









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



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



pragma solidity ^0.4.23;





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



// File: contracts/TradeableERC721Token.sol



/*

Abstract contract which allows trading to some external (contract) party



Mostly copied from OpenSea https://github.com/ProjectOpenSea/opensea-creatures/blob/master/contracts/TradeableERC721Token.sol



*/

pragma solidity ^0.4.25;















contract OwnableDelegateProxy { }



contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;

}



/**

 * @title TradeableERC721Token

 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.

 */

contract TradeableERC721Token is ERC721Token, Ownable {

    using SafeMath for uint256;

    using Strings for string;



    uint256 burnedCounter = 0;

    address proxyRegistryAddress;

    string baseURI;



    constructor(string _name, string _symbol, address _proxyRegistryAddress, string _baseTokenURI) ERC721Token(_name, _symbol) public {

        proxyRegistryAddress = _proxyRegistryAddress;

        baseURI = _baseTokenURI;

    }



    /**

      * @dev Mints a token to an address with a tokenURI.

      * @param _to address of the future owner of the token

      */

    function mintTo(address _to) public onlyOwner {

        uint256 newTokenId = _getNextTokenId();

        _mint(_to, newTokenId);

    }



    /**

   * @dev Approves another address to transfer the given array of token IDs

   * @param _to address to be approved for the given token ID

   * @param _tokenIds uint256[] IDs of the tokens to be approved

   */

    function approveBulk(address _to, uint256[] _tokenIds) public {

        for (uint256 i = 0; i < _tokenIds.length; i++) {

           approve(_to, _tokenIds[i]);

        }

    }



    /**

      * @dev calculates the next token ID based on totalSupply and the burned offset

      * @return uint256 for the next token ID

      */

    function _getNextTokenId() private view returns (uint256) {

        return totalSupply().add(1).add(burnedCounter);

    }



    /**

      * @dev extends default burn functionality with the the burned counter

      */

    function _burn(address _owner, uint256 _tokenId) internal {

        super._burn(_owner, _tokenId);

        burnedCounter++;

    }



    function baseTokenURI() public view returns (string) {

        return baseURI;

    }



    function tokenURI(uint256 _tokenId) public view returns (string) {

        return Strings.strConcat(

            baseTokenURI(),

            Strings.uint2str(_tokenId)

        );

    }



    /**

     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.

     */

    function isApprovedForAll(

        address owner,

        address operator

    )

    public

    view

    returns (bool)

    {

        //Check optional proxy

        if (proxyRegistryAddress != address(0)) {

            // Whitelist OpenSea proxy contract for easy trading.

            ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

            if (proxyRegistry.proxies(owner) == operator) {

                return true;

            }

        }



        return super.isApprovedForAll(owner, operator);

    }



    /// @notice Returns a list of all tokens assigned to an address.

    /// @param _owner The owner whose tokens we are interested in.

    /// @dev This method MUST NEVER be called by smart contract code, due to the price

    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {

        uint256 tokenCount = balanceOf(_owner);



        if (tokenCount == 0) {

            // Return an empty array

            return new uint256[](0);

        } else {

            uint256[] memory result = new uint256[](tokenCount);

            uint256 resultIndex = 0;



            uint256 _tokenIdx;



            for (_tokenIdx = 0; _tokenIdx < tokenCount; _tokenIdx++) {

                result[resultIndex] = tokenOfOwnerByIndex(_owner, _tokenIdx);

                resultIndex++;

            }



            return result;

        }

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



pragma solidity ^0.4.23;





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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.4.23;







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

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



// File: contracts/ERC20Box.sol



pragma solidity ^0.4.25;







/**

 * @title ERC20Box

 *

 * A tradable box (ERC-721), OpenSee.io compliant, which holds a portion of ERC-20 tokens,

 * that get credited to the owner upon 'opening' it

 */

contract ERC20Box is TradeableERC721Token {



    ERC20 public token;



    uint256 tokensPerBox;



    /**

   * @dev Constructor function

   * Important! This token is not functional until depositERC() is called

   */

    constructor(string _name, string _symbol, address _proxyRegistryAddress, address _tokenAddress,

    uint256 _tokensPerBox, string _baseTokenURI)

    TradeableERC721Token(_name, _symbol, _proxyRegistryAddress, _baseTokenURI) public {

        token = ERC20(_tokenAddress);

        tokensPerBox = _tokensPerBox;

    }



    // Important! remember to call ERC20(address).approve(this, amount)

    // or this contract will not be able to do the transfer on your behalf.

    function depositERC(uint256 amount) onlyOwner public {

        require(amount % tokensPerBox == 0, "Wrong amount of tokens!");

        require(token.transferFrom(msg.sender, this, amount), "Insufficient funds");

        for(uint i = 0; i < amount.div(tokensPerBox); i++) {

            mintTo(msg.sender);

        }

    }



    function unpack(uint256 _tokenId) public onlyOwnerOf(_tokenId){

        require(token.balanceOf(this) >= tokensPerBox, "Hmm, been opened already?");

        require(token.transfer(msg.sender, tokensPerBox), "Couldn't transfer token");



        // Burn the box.

        _burn(msg.sender, _tokenId);

    }



    /**

   * @dev OpenSee compatibility, expects user-friendly number

   */

    function itemsPerLootbox() public view returns (uint256) {

        return tokensPerBox.div(10**18);

    }

}
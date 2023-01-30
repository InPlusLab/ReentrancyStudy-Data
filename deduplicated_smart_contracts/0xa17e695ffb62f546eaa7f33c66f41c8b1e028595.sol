/**

 *Submitted for verification at Etherscan.io on 2018-09-06

*/



pragma solidity ^0.4.21;



// File: contracts\ERC721\ERC721Receiver.sol



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



// File: contracts\utils\SafeMath.sol



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



// File: contracts\utils\Serialize.sol



contract Serialize {

    using SafeMath for uint256;

    function addAddress(uint _offst, bytes memory _output, address _input) internal pure returns(uint _offset) {

      assembly {

        mstore(add(_output, _offst), _input)

      }

      return _offst.sub(20);

    }



    function addUint(uint _offst, bytes memory _output, uint _input) internal pure returns (uint _offset) {

      assembly {

        mstore(add(_output, _offst), _input)

      }

      return _offst.sub(32);

    }



    function addUint8(uint _offst, bytes memory _output, uint _input) internal pure returns (uint _offset) {

      assembly {

        mstore(add(_output, _offst), _input)

      }

      return _offst.sub(1);

    }



    function addUint16(uint _offst, bytes memory _output, uint _input) internal pure returns (uint _offset) {

      assembly {

        mstore(add(_output, _offst), _input)

      }

      return _offst.sub(2);

    }



    function addUint64(uint _offst, bytes memory _output, uint _input) internal pure returns (uint _offset) {

      assembly {

        mstore(add(_output, _offst), _input)

      }

      return _offst.sub(8);

    }



    function getAddress(uint _offst, bytes memory _input) internal pure returns (address _output, uint _offset) {

      assembly {

        _output := mload(add(_input, _offst))

      }

      return (_output, _offst.sub(20));

    }



    function getUint(uint _offst, bytes memory _input) internal pure returns (uint _output, uint _offset) {

      assembly {

          _output := mload(add(_input, _offst))

      }

      return (_output, _offst.sub(32));

    }



    function getUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output, uint _offset) {

      assembly {

        _output := mload(add(_input, _offst))

      }

      return (_output, _offst.sub(1));

    }



    function getUint16(uint _offst, bytes memory _input) internal pure returns (uint16 _output, uint _offset) {

      assembly {

        _output := mload(add(_input, _offst))

      }

      return (_output, _offst.sub(2));

    }



    function getUint64(uint _offst, bytes memory _input) internal pure returns (uint64 _output, uint _offset) {

      assembly {

        _output := mload(add(_input, _offst))

      }

      return (_output, _offst.sub(8));

    }

}



// File: contracts\utils\AddressUtils.sol



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



// File: contracts\utils\Ownable.sol



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



// File: contracts\utils\Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



// File: contracts\ERC721\ERC721Basic.sol



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



// File: contracts\ERC721\ERC721BasicToken.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721BasicToken is ERC721Basic, Pausable {

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



  function transferBatch(address _from, address _to, uint[] _tokenIds) public {

    require(_from != address(0));

    require(_to != address(0));



    for(uint i=0; i<_tokenIds.length; i++) {

      require(isApprovedOrOwner(msg.sender, _tokenIds[i]));

      clearApproval(_from,  _tokenIds[i]);

      removeTokenFrom(_from, _tokenIds[i]);

      addTokenTo(_to, _tokenIds[i]);



      emit Transfer(_from, _to, _tokenIds[i]);

    }

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

  function addTokenTo(address _to, uint256 _tokenId) internal whenNotPaused {

    require(tokenOwner[_tokenId] == address(0));

    tokenOwner[_tokenId] = _to;

    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * @param _from address representing the previous owner of the given token ID

   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function removeTokenFrom(address _from, uint256 _tokenId) internal whenNotPaused{

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



// File: contracts\ERC721\GirlBasicToken.sol



// add atomic swap feature in the token contract.

contract GirlBasicToken is ERC721BasicToken, Serialize {



  event CreateGirl(address owner, uint256 tokenID, uint256 genes, uint64 birthTime, uint64 cooldownEndTime, uint16 starLevel);

  event CoolDown(uint256 tokenId, uint64 cooldownEndTime);

  event GirlUpgrade(uint256 tokenId, uint64 starLevel);



  struct Girl{

    /**

    ��Ů����,�����Ժ󲻻�ı�

    **/

    uint genes;



    /*

    ����ʱ�� ��Ů����ʱ���ʱ���

    */

    uint64 birthTime;



    /*

    ��ȴ����ʱ��

    */

    uint64 cooldownEndTime;

    /*

    star level

    */

    uint16 starLevel;

  }



  Girl[] girls;





  function totalSupply() public view returns (uint256) {

    return girls.length;

  }



  function getGirlGene(uint _index) public view returns (uint) {

    return girls[_index].genes;

  }



  function getGirlBirthTime(uint _index) public view returns (uint64) {

    return girls[_index].birthTime;

  }



  function getGirlCoolDownEndTime(uint _index) public view returns (uint64) {

    return girls[_index].cooldownEndTime;

  }



  function getGirlStarLevel(uint _index) public view returns (uint16) {

    return girls[_index].starLevel;

  }



  function isNotCoolDown(uint _girlId) public view returns(bool) {

    return uint64(now) > girls[_girlId].cooldownEndTime;

  }



  function _createGirl(

      uint _genes,

      address _owner,

      uint16 _starLevel

  ) internal returns (uint){

      Girl memory _girl = Girl({

          genes:_genes,

          birthTime:uint64(now),

          cooldownEndTime:0,

          starLevel:_starLevel

      });

      uint256 girlId = girls.push(_girl) - 1;

      _mint(_owner, girlId);

      emit CreateGirl(_owner, girlId, _genes, _girl.birthTime, _girl.cooldownEndTime, _girl.starLevel);

      return girlId;

  }



  function _setCoolDownTime(uint _tokenId, uint _coolDownTime) internal {

    girls[_tokenId].cooldownEndTime = uint64(now.add(_coolDownTime));

    emit CoolDown(_tokenId, girls[_tokenId].cooldownEndTime);

  }



  function _LevelUp(uint _tokenId) internal {

    require(girls[_tokenId].starLevel < 65535);

    girls[_tokenId].starLevel = girls[_tokenId].starLevel + 1;

    emit GirlUpgrade(_tokenId, girls[_tokenId].starLevel);

  }



  // ---------------

  // this is atomic swap for girl to be set cross chain.

  // ---------------

  uint8 constant public GIRLBUFFERSIZE = 50;  // buffer size need to serialize girl data; used for cross chain sync



  struct HashLockContract {

    address sender;

    address receiver;

    uint tokenId;

    bytes32 hashlock;

    uint timelock;

    bytes32 secret;

    States state;

    bytes extraData;

  }



  enum States {

    INVALID,

    OPEN,

    CLOSED,

    REFUNDED

  }



  mapping (bytes32 => HashLockContract) private contracts;



  modifier contractExists(bytes32 _contractId) {

    require(_contractExists(_contractId));

    _;

  }



  modifier hashlockMatches(bytes32 _contractId, bytes32 _secret) {

    require(contracts[_contractId].hashlock == keccak256(_secret));

    _;

  }



  modifier closable(bytes32 _contractId) {

    require(contracts[_contractId].state == States.OPEN);

    require(contracts[_contractId].timelock > now);

    _;

  }



  modifier refundable(bytes32 _contractId) {

    require(contracts[_contractId].state == States.OPEN);

    require(contracts[_contractId].timelock <= now);

    _;

  }



  event NewHashLockContract (

    bytes32 indexed contractId,

    address indexed sender,

    address indexed receiver,

    uint tokenId,

    bytes32 hashlock,

    uint timelock,

    bytes extraData

  );



  event SwapClosed(bytes32 indexed contractId);

  event SwapRefunded(bytes32 indexed contractId);



  function open (

    address _receiver,

    bytes32 _hashlock,

    uint _duration,

    uint _tokenId

  ) public

    onlyOwnerOf(_tokenId)

    returns (bytes32 contractId)

  {

    uint _timelock = now.add(_duration);



    // compute girl data;

    bytes memory _extraData = new bytes(GIRLBUFFERSIZE);

    uint offset = GIRLBUFFERSIZE;



    offset = addUint16(offset, _extraData, girls[_tokenId].starLevel);

    offset = addUint64(offset, _extraData, girls[_tokenId].cooldownEndTime);

    offset = addUint64(offset, _extraData, girls[_tokenId].birthTime);

    offset = addUint(offset, _extraData, girls[_tokenId].genes);



    contractId = keccak256 (

      msg.sender,

      _receiver,

      _tokenId,

      _hashlock,

      _timelock,

      _extraData

    );



    // the new contract must not exist

    require(!_contractExists(contractId));



    // temporary change the ownership to this contract address.

    // the ownership will be change to user when close is called.

    clearApproval(msg.sender, _tokenId);

    removeTokenFrom(msg.sender, _tokenId);

    addTokenTo(address(this), _tokenId);





    contracts[contractId] = HashLockContract(

      msg.sender,

      _receiver,

      _tokenId,

      _hashlock,

      _timelock,

      0x0,

      States.OPEN,

      _extraData

    );



    emit NewHashLockContract(contractId, msg.sender, _receiver, _tokenId, _hashlock, _timelock, _extraData);

  }



  function close(bytes32 _contractId, bytes32 _secret)

    public

    contractExists(_contractId)

    hashlockMatches(_contractId, _secret)

    closable(_contractId)

    returns (bool)

  {

    HashLockContract storage c = contracts[_contractId];

    c.secret = _secret;

    c.state = States.CLOSED;



    // transfer token ownership from this contract address to receiver.

    // clearApproval(address(this), c.tokenId);

    removeTokenFrom(address(this), c.tokenId);

    addTokenTo(c.receiver, c.tokenId);



    emit SwapClosed(_contractId);

    return true;

  }



  function refund(bytes32 _contractId)

    public

    contractExists(_contractId)

    refundable(_contractId)

    returns (bool)

  {

    HashLockContract storage c = contracts[_contractId];

    c.state = States.REFUNDED;



    // transfer token ownership from this contract address to receiver.

    // clearApproval(address(this), c.tokenId);

    removeTokenFrom(address(this), c.tokenId);

    addTokenTo(c.sender, c.tokenId);





    emit SwapRefunded(_contractId);

    return true;

  }



  function _contractExists(bytes32 _contractId) internal view returns (bool exists) {

    exists = (contracts[_contractId].sender != address(0));

  }



  function checkContract(bytes32 _contractId)

    public

    view

    contractExists(_contractId)

    returns (

      address sender,

      address receiver,

      uint amount,

      bytes32 hashlock,

      uint timelock,

      bytes32 secret,

      bytes extraData

    )

  {

    HashLockContract memory c = contracts[_contractId];

    return (

      c.sender,

      c.receiver,

      c.tokenId,

      c.hashlock,

      c.timelock,

      c.secret,

      c.extraData

    );

  }





}



// File: contracts\utils\AccessControl.sol



contract AccessControl is Ownable{

    address CFO;

    //Owner address can set to COO address. it have same effect.



    modifier onlyCFO{

        require(msg.sender == CFO);

        _;

    }



    function setCFO(address _newCFO)public onlyOwner {

        CFO = _newCFO;

    }



    //use pausable in the contract that need to pause. save gas and clear confusion.



}



// File: contracts\Auction\ClockAuctionBase.sol



/// @title Auction Core

/// @dev Contains models, variables, and internal methods for the auction.

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

    GirlBasicToken public girlBasicToken;



    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).

    // Values 0-10,000 map to 0%-100%

    uint256 public ownerCut;



    // Map from token ID to their corresponding auction.

    mapping (uint256 => Auction) tokenIdToAuction;



    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);

    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    event AuctionCancelled(uint256 tokenId);



    /// @dev DON'T give me your money.

    function() external {}





    /// @dev Returns true if the claimant owns the token.

    /// @param _claimant - Address claiming to own the token.

    /// @param _tokenId - ID of token whose ownership to verify.

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {

        return (girlBasicToken.ownerOf(_tokenId) == _claimant);

    }



    /// @dev Escrows the NFT, assigning ownership to this contract.

    /// Throws if the escrow fails.

    /// @param _owner - Current owner address of token to escrow.

    /// @param _tokenId - ID of token whose approval to verify.

    // function _escrow(address _owner, uint256 _tokenId) internal {

    //     // it will throw if transfer fails

    //     nonFungibleContract.transfer(_owner, _tokenId);

    // }



    /// @dev Transfers an NFT owned by this contract to another address.

    /// Returns true if the transfer succeeds.

    /// @param _receiver - Address to transfer NFT to.

    /// @param _tokenId - ID of token to transfer.

    function _transfer(address _receiver, uint256 _tokenId) internal {

        // it will throw if transfer fails

        girlBasicToken.safeTransferFrom(address(this), _receiver, _tokenId);

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



        emit AuctionCreated(

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

        emit AuctionCancelled(_tokenId);

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



        // Check that the incoming bid is higher than the current

        // price

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

            //  Calculate the auctioneer's cut.

            // (NOTE: _computeCut() is guaranteed to return a

            //  value <= price, so this subtraction can't go negative.)

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



        // Tell the world!

        emit AuctionSuccessful(_tokenId, price, msg.sender);



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



// File: contracts\Auction\ClockAuction.sol



/// @title Clock auction for non-fungible tokens.

contract ClockAuction is Pausable, ClockAuctionBase, AccessControl {



    /// @dev Constructor creates a reference to the NFT ownership contract

    ///  and verifies the owner cut is in the valid range.

    /// @param _nftAddress - address of a deployed contract implementing

    ///  the Nonfungible Interface.

    /// @param _cut - percent cut the owner takes on each auction, must be

    ///  between 0-10,000.

    constructor(address _nftAddress, uint256 _cut) public {

        require(_cut <= 10000);

        ownerCut = _cut;



        GirlBasicToken candidateContract = GirlBasicToken(_nftAddress);

        //require(candidateContract.implementsERC721());

        girlBasicToken = candidateContract;

    }



    function withDrawBalance(uint256 amount) public onlyCFO {

      require(address(this).balance >= amount);

      CFO.transfer(amount);

    }





    /// @dev Bids on an open auction, completing the auction and transferring

    ///  ownership of the NFT if enough Ether is supplied.

    /// @param _tokenId - ID of token to bid on.

    function bid(uint256 _tokenId)

        public

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

        public

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

        public

    {

        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction));

        _cancelAuction(_tokenId, auction.seller);

    }



    /// @dev Returns auction info for an NFT on auction.

    /// @param _tokenId - ID of NFT on auction.

    function getAuction(uint256 _tokenId)

        public

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

        public

        view

        returns (uint256)

    {

        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction));

        return _currentPrice(auction);

    }



    function setOwnerCut(uint _cut) public onlyOwner {

      ownerCut  = _cut;

    }



}



// File: contracts\GenesFactory.sol



contract GenesFactory{

    function mixGenes(uint256 gene1, uint gene2) public returns(uint256);

    function getPerson(uint256 genes) public pure returns (uint256 person);

    function getRace(uint256 genes) public pure returns (uint256);

    function getRarity(uint256 genes) public pure returns (uint256);

    function getBaseStrengthenPoint(uint256 genesMain,uint256 genesSub) public pure returns (uint256);



    function getCanBorn(uint256 genes) public pure returns (uint256 canBorn,uint256 cooldown);

}



// File: contracts\GirlOperation\GirlAuction.sol



contract GirlAuction is Serialize, ERC721Receiver, ClockAuction {



  event GirlAuctionCreated(address sender, uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);





  constructor(address _nftAddr, uint256 _cut) public

        ClockAuction(_nftAddr, _cut) {}

  // example:

  // _startingPrice = 5000000000000,

  // _endingPrice = 100000000000,

  // _duration = 600,

  // _data = 0x0000000000000000000000000000000000000000000000000000000000000258000000000000000000000000000000000000000000000000000000e8d4a510000000000000000000000000000000000000000000000000000000048c27395000



  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {



    require(msg.sender == address(girlBasicToken));



    uint _startingPrice;

    uint _endingPrice;

    uint _duration;



    uint offset = 96;

    (_startingPrice, offset) = getUint(offset, _data);

    (_endingPrice, offset) = getUint(offset, _data);

    (_duration, offset) = getUint(offset, _data);



    require(_startingPrice > _endingPrice);

    require(girlBasicToken.isNotCoolDown(_tokenId));





    emit GirlAuctionCreated(_from, _tokenId, _startingPrice, _endingPrice, _duration);





    require(_startingPrice <= 340282366920938463463374607431768211455);

    require(_endingPrice <= 340282366920938463463374607431768211455);

    require(_duration <= 18446744073709551615);



    Auction memory auction = Auction(

        _from,

        uint128(_startingPrice),

        uint128(_endingPrice),

        uint64(_duration),

        uint64(now)

    );

    _addAuction(_tokenId, auction);



    return ERC721_RECEIVED;

  }









}
/**

 *Submitted for verification at Etherscan.io on 2019-03-29

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



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



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Basic is ERC165 {



  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;

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



  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;

  /*

   * 0x4f558e79 ===

   *   bytes4(keccak256('exists(uint256)'))

   */



  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;

  /**

   * 0x780e9d63 ===

   *   bytes4(keccak256('totalSupply()')) ^

   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

   *   bytes4(keccak256('tokenByIndex(uint256)'))

   */



  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  /**

   * 0x5b5e139f ===

   *   bytes4(keccak256('name()')) ^

   *   bytes4(keccak256('symbol()')) ^

   *   bytes4(keccak256('tokenURI(uint256)'))

   */



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



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol



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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: contracts/gateway/ERC20Receiver.sol



/**

 * @title ERC20 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 *  from ERC20 asset contracts.

 */

contract ERC20Receiver {

  /**

   * @dev Magic value to be returned upon successful reception of an NFT

   *  Equals to `bytes4(keccak256("onERC20Received(address,uint256,bytes)"))`,

   *  which can be also obtained as `ERC20Receiver(0).onERC20Received.selector`

   */

  bytes4 constant ERC20_RECEIVED = 0xbc04f0af;



  function onERC20Received(address _from, uint256 amount) public returns(bytes4);

}



// File: contracts/gateway/ERC721Receiver.sol



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



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: contracts/gateway/ECVerify.sol



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



    return ecrecover(hash, v, r, s);

  }



  function ecverify(bytes32 hash, bytes sig, address signer) internal pure returns (bool) {

    return signer == recover(hash, sig);

  }

}



// File: contracts/gateway/ValidatorManagerContract.sol



contract ValidatorManagerContract is Ownable {

  using ECVerify for bytes32;



  mapping (address => bool) public allowedTokens;

  mapping (address => uint256) public nonces;

  mapping (address => bool) validators;



  uint8 threshold_num;

  uint8 threshold_denom;

  uint256 public numValidators;

  uint256 public nonce; // used for replay protection when adding/removing validators



  event AddedValidator(address validator);

  event RemovedValidator(address validator);



  modifier onlyValidator() { require(checkValidator(msg.sender)); _; }



  constructor (address[] _validators, uint8 _threshold_num, uint8 _threshold_denom) public {

    uint256 length = _validators.length;

    require(length > 0);



    threshold_num = _threshold_num;

    threshold_denom = _threshold_denom;

    for (uint256 i = 0; i < length ; i++) {

      require(_validators[i] != address(0));

      validators[_validators[i]] = true;

      emit AddedValidator(_validators[i]);

    }

    numValidators = _validators.length;

  }



  modifier isVerifiedByValidator(uint256 num, address contractAddress, bytes sig) {

    // prevent replay attacks by adding the nonce in the sig

    // if a validator signs an invalid nonce,

    // it won't pass the signature verification

    // since the nonce in the hash is stored in the contract

    bytes32 hash = keccak256(abi.encodePacked(msg.sender, contractAddress, nonces[msg.sender], num));

    address sender = hash.recover(sig);

    require(validators[sender], "Message not signed by a validator");

    _;

    nonces[msg.sender]++; // increment nonce after execution

  }



  function checkValidator(address _address) public view returns (bool) {

    // owner is a permanent validator

    if (_address == owner) {

      return true;

    }

    return validators[_address];

  }



  function addValidator(address validator, uint8[] v, bytes32[] r, bytes32[] s)

    external

  {

    require(!validators[validator], "Already a validator");



    // Check that we have enough signatures

    bytes32 message = keccak256(abi.encodePacked("add", validator, nonce));

    checkThreshold(message, v, r, s);



    // Add validator and increment nonce

    validators[validator] = true;

    numValidators++;

    nonce++;

    emit AddedValidator(validator);

  }



  function removeValidator(address validator, uint8[] v, bytes32[] r, bytes32[] s)

    external

  {

    require(validators[validator], "Not a validator");

    // The last validator may not remove himself

    require(numValidators > 1);



    // Check that we have enough signatures

    bytes32 message = keccak256(abi.encodePacked("remove", validator, nonce));

    checkThreshold(message, v, r, s);



    delete validators[validator];

    numValidators--;

    nonce++;

    emit RemovedValidator(validator);

  }



  // Can't pass bytes[] to use the whole sig due to ABI enc

  //, so we need to send v,r,s params

  function checkThreshold(bytes32 message, uint8[] v, bytes32[] r, bytes32[] s) private view {

    require(v.length > 0 && v.length == r.length && r.length == s.length,

      "Incorrect number of params");

    require(v.length >= (threshold_num * numValidators / threshold_denom ),

      "Not enough votes");



    bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));

    uint256 sig_length = v.length;



    // Check that all addresess were from validators

    // Prevent duplicates by requiring that the sender sigs

    // get submitted in increasing order

    // influenced by

    // https://github.com/christianlundkvist/simple-multisig

    address lastAdd = address(0);

    for (uint256 i = 0; i < sig_length; i++) {

      address signer = ecrecover(hash, v[i], r[i], s[i]);

      require(signer > lastAdd && validators[signer], "Not signed by a validator");

      lastAdd = signer;

    }

  }



  function toggleToken(address _token) public onlyValidator {

    allowedTokens[_token] = !allowedTokens[_token];

  }

}



// File: contracts/gateway/Gateway.sol



contract Gateway is ERC20Receiver, ERC721Receiver, ValidatorManagerContract {



  using SafeMath for uint256;



  struct Balance {

    uint256 eth;

    mapping(address => uint256) erc20;

    mapping(address => mapping(uint256 => bool)) erc721;

  }



  mapping (address => Balance) balances;



  event ETHReceived(address from, uint256 amount);

  event ERC20Received(address from, uint256 amount, address contractAddress);

  event ERC721Received(address from, uint256 uid, address contractAddress);



  enum TokenKind {

    ETH,

    ERC20,

    ERC721

  }



  /**

   * Event to log the withdrawal of a token from the Gateway.

   * @param owner Address of the entity that made the withdrawal.

   * @param kind The type of token withdrawn (ERC20/ERC721/ETH).

   * @param contractAddress Address of token contract the token belong to.

   * @param value For ERC721 this is the uid of the token, for ETH/ERC20 this is the amount.

   */

  event TokenWithdrawn(address indexed owner, TokenKind kind, address contractAddress, uint256 value);



  constructor (address[] _validators, uint8 _threshold_num, uint8 _threshold_denom)

    public ValidatorManagerContract(_validators, _threshold_num, _threshold_denom) {

  }



  // Deposit functions

  function depositETH() private {

    balances[msg.sender].eth = balances[msg.sender].eth.add(msg.value);

  }



  function depositERC721(address from, uint256 uid) private {

    balances[from].erc721[msg.sender][uid] = true;

  }



  function depositERC20(address from, uint256 amount) private {

    balances[from].erc20[msg.sender] = balances[from].erc20[msg.sender].add(amount);

  }



  // Withdrawal functions

  function withdrawERC20(uint256 amount, bytes sig, address contractAddress)

    external

    isVerifiedByValidator(amount, contractAddress, sig)

  {

    balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].sub(amount);

    ERC20(contractAddress).transfer(msg.sender, amount);

    emit TokenWithdrawn(msg.sender, TokenKind.ERC20, contractAddress, amount);

  }



  function withdrawERC721(uint256 uid, bytes sig, address contractAddress)

    external

    isVerifiedByValidator(uid, contractAddress, sig)

  {

    require(balances[msg.sender].erc721[contractAddress][uid], "Does not own token");

    ERC721(contractAddress).safeTransferFrom(address(this),  msg.sender, uid);

    delete balances[msg.sender].erc721[contractAddress][uid];

    emit TokenWithdrawn(msg.sender, TokenKind.ERC721, contractAddress, uid);

  }



  function withdrawETH(uint256 amount, bytes sig)

    external

    isVerifiedByValidator(amount, address(this), sig)

  {

    balances[msg.sender].eth = balances[msg.sender].eth.sub(amount);

    msg.sender.transfer(amount); // ensure it's not reentrant

    emit TokenWithdrawn(msg.sender, TokenKind.ETH, address(0), amount);

  }



  // Approve and Deposit function for 2-step deposits

  // Requires first to have called `approve` on the specified ERC20 contract

  function depositERC20(uint256 amount, address contractAddress) external {

    ERC20(contractAddress).transferFrom(msg.sender, address(this), amount);

    balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].add(amount);

    emit ERC20Received(msg.sender, amount, contractAddress);

  }



  // Receiver functions for 1-step deposits to the gateway



  function onERC20Received(address _from, uint256 amount)

    public

    returns (bytes4)

  {

    require(allowedTokens[msg.sender], "Not a valid token");

    depositERC20(_from, amount);

    emit ERC20Received(_from, amount, msg.sender);

    return ERC20_RECEIVED;

  }



  function onERC721Received(address _from, uint256 _uid, bytes)

    public

    returns (bytes4)

  {

    require(allowedTokens[msg.sender], "Not a valid token");

    depositERC721(_from, _uid);

    emit ERC721Received(_from, _uid, msg.sender);

    return ERC721_RECEIVED;

  }



  function () external payable {

    depositETH();

    emit ETHReceived(msg.sender, msg.value);

  }



  // Returns all the ETH you own

  function getETH(address owner) external view returns (uint256) {

    return balances[owner].eth;

  }



  // Returns all the ETH you own

  function getERC20(address owner, address contractAddress) external view returns (uint256) {

    return balances[owner].erc20[contractAddress];

  }



  // Returns ERC721 token by uid

  function getNFT(address owner, uint256 uid, address contractAddress) external view returns (bool) {

    return balances[owner].erc721[contractAddress][uid];

  }

}
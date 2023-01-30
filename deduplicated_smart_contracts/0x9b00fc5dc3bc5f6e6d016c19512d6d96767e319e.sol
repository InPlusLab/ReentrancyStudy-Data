/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity 0.4.24;



contract CrabData {

  modifier crabDataLength(uint256[] memory _crabData) {

    require(_crabData.length == 8);

    _;

  }



  struct CrabPartData {

    uint256 hp;

    uint256 dps;

    uint256 blockRate;

    uint256 resistanceBonus;

    uint256 hpBonus;

    uint256 dpsBonus;

    uint256 blockBonus;

    uint256 mutiplierBonus;

  }



  function arrayToCrabPartData(

    uint256[] _partData

  ) 

    internal 

    pure 

    crabDataLength(_partData) 

    returns (CrabPartData memory _parsedData) 

  {

    _parsedData = CrabPartData(

      _partData[0],   // hp

      _partData[1],   // dps

      _partData[2],   // block rate

      _partData[3],   // resistance bonus

      _partData[4],   // hp bonus

      _partData[5],   // dps bonus

      _partData[6],   // block bonus

      _partData[7]);  // multiplier bonus

  }



  function crabPartDataToArray(CrabPartData _crabPartData) internal pure returns (uint256[] memory _resultData) {

    _resultData = new uint256[](8);

    _resultData[0] = _crabPartData.hp;

    _resultData[1] = _crabPartData.dps;

    _resultData[2] = _crabPartData.blockRate;

    _resultData[3] = _crabPartData.resistanceBonus;

    _resultData[4] = _crabPartData.hpBonus;

    _resultData[5] = _crabPartData.dpsBonus;

    _resultData[6] = _crabPartData.blockBonus;

    _resultData[7] = _crabPartData.mutiplierBonus;

  }

}



contract GeneSurgeon {

  //0 - filler, 1 - body, 2 - leg, 3 - left claw, 4 - right claw

  uint256[] internal crabPartMultiplier = [0, 10**9, 10**6, 10**3, 1];



  function extractElementsFromGene(uint256 _gene) internal view returns (uint256[] memory _elements) {

    _elements = new uint256[](4);

    _elements[0] = _gene / crabPartMultiplier[1] / 100 % 10;

    _elements[1] = _gene / crabPartMultiplier[2] / 100 % 10;

    _elements[2] = _gene / crabPartMultiplier[3] / 100 % 10;

    _elements[3] = _gene / crabPartMultiplier[4] / 100 % 10;

  }



  function extractPartsFromGene(uint256 _gene) internal view returns (uint256[] memory _parts) {

    _parts = new uint256[](4);

    _parts[0] = _gene / crabPartMultiplier[1] % 100;

    _parts[1] = _gene / crabPartMultiplier[2] % 100;

    _parts[2] = _gene / crabPartMultiplier[3] % 100;

    _parts[3] = _gene / crabPartMultiplier[4] % 100;

  }

}



interface GenesisCrabInterface {

  function generateCrabGene(bool isPresale, bool hasLegendaryPart) external returns (uint256 _gene, uint256 _skin, uint256 _heartValue, uint256 _growthValue);

  function mutateCrabPart(uint256 _part, uint256 _existingPartGene, uint256 _legendaryPercentage) external view returns (uint256);

  function generateCrabHeart() external view returns (uint256, uint256);

}



contract Randomable {

  // Generates a random number base on last block hash

  function _generateRandom(bytes32 seed) view internal returns (bytes32) {

    return keccak256(abi.encodePacked(blockhash(block.number-1), seed));

  }



  function _generateRandomNumber(bytes32 seed, uint256 max) view internal returns (uint256) {

    return uint256(_generateRandom(seed)) % max;

  }

}



contract CryptantCrabStoreInterface {

  function createAddress(bytes32 key, address value) external returns (bool);

  function createAddresses(bytes32[] keys, address[] values) external returns (bool);

  function updateAddress(bytes32 key, address value) external returns (bool);

  function updateAddresses(bytes32[] keys, address[] values) external returns (bool);

  function removeAddress(bytes32 key) external returns (bool);

  function removeAddresses(bytes32[] keys) external returns (bool);

  function readAddress(bytes32 key) external view returns (address);

  function readAddresses(bytes32[] keys) external view returns (address[]);

  // Bool related functions

  function createBool(bytes32 key, bool value) external returns (bool);

  function createBools(bytes32[] keys, bool[] values) external returns (bool);

  function updateBool(bytes32 key, bool value) external returns (bool);

  function updateBools(bytes32[] keys, bool[] values) external returns (bool);

  function removeBool(bytes32 key) external returns (bool);

  function removeBools(bytes32[] keys) external returns (bool);

  function readBool(bytes32 key) external view returns (bool);

  function readBools(bytes32[] keys) external view returns (bool[]);

  // Bytes32 related functions

  function createBytes32(bytes32 key, bytes32 value) external returns (bool);

  function createBytes32s(bytes32[] keys, bytes32[] values) external returns (bool);

  function updateBytes32(bytes32 key, bytes32 value) external returns (bool);

  function updateBytes32s(bytes32[] keys, bytes32[] values) external returns (bool);

  function removeBytes32(bytes32 key) external returns (bool);

  function removeBytes32s(bytes32[] keys) external returns (bool);

  function readBytes32(bytes32 key) external view returns (bytes32);

  function readBytes32s(bytes32[] keys) external view returns (bytes32[]);

  // uint256 related functions

  function createUint256(bytes32 key, uint256 value) external returns (bool);

  function createUint256s(bytes32[] keys, uint256[] values) external returns (bool);

  function updateUint256(bytes32 key, uint256 value) external returns (bool);

  function updateUint256s(bytes32[] keys, uint256[] values) external returns (bool);

  function removeUint256(bytes32 key) external returns (bool);

  function removeUint256s(bytes32[] keys) external returns (bool);

  function readUint256(bytes32 key) external view returns (uint256);

  function readUint256s(bytes32[] keys) external view returns (uint256[]);

  // int256 related functions

  function createInt256(bytes32 key, int256 value) external returns (bool);

  function createInt256s(bytes32[] keys, int256[] values) external returns (bool);

  function updateInt256(bytes32 key, int256 value) external returns (bool);

  function updateInt256s(bytes32[] keys, int256[] values) external returns (bool);

  function removeInt256(bytes32 key) external returns (bool);

  function removeInt256s(bytes32[] keys) external returns (bool);

  function readInt256(bytes32 key) external view returns (int256);

  function readInt256s(bytes32[] keys) external view returns (int256[]);

  // internal functions

  function parseKey(bytes32 key) internal pure returns (bytes32);

  function parseKeys(bytes32[] _keys) internal pure returns (bytes32[]);

}



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



contract CryptantCrabBase is Ownable {

  GenesisCrabInterface public genesisCrab;

  CryptantCrabNFT public cryptantCrabToken;

  CryptantCrabStoreInterface public cryptantCrabStorage;



  constructor(address _genesisCrabAddress, address _cryptantCrabTokenAddress, address _cryptantCrabStorageAddress) public {

    // constructor

    

    _setAddresses(_genesisCrabAddress, _cryptantCrabTokenAddress, _cryptantCrabStorageAddress);

  }



  function setAddresses(

    address _genesisCrabAddress, 

    address _cryptantCrabTokenAddress, 

    address _cryptantCrabStorageAddress

  ) 

  external onlyOwner {

    _setAddresses(_genesisCrabAddress, _cryptantCrabTokenAddress, _cryptantCrabStorageAddress);

  }



  function _setAddresses(

    address _genesisCrabAddress,

    address _cryptantCrabTokenAddress,

    address _cryptantCrabStorageAddress

  )

  internal 

  {

    if(_genesisCrabAddress != address(0)) {

      GenesisCrabInterface genesisCrabContract = GenesisCrabInterface(_genesisCrabAddress);

      genesisCrab = genesisCrabContract;

    }

    

    if(_cryptantCrabTokenAddress != address(0)) {

      CryptantCrabNFT cryptantCrabTokenContract = CryptantCrabNFT(_cryptantCrabTokenAddress);

      cryptantCrabToken = cryptantCrabTokenContract;

    }

    

    if(_cryptantCrabStorageAddress != address(0)) {

      CryptantCrabStoreInterface cryptantCrabStorageContract = CryptantCrabStoreInterface(_cryptantCrabStorageAddress);

      cryptantCrabStorage = cryptantCrabStorageContract;

    }

  }

}



contract CryptantCrabInformant is CryptantCrabBase{

  constructor

  (

    address _genesisCrabAddress, 

    address _cryptantCrabTokenAddress, 

    address _cryptantCrabStorageAddress

  ) 

  public 

  CryptantCrabBase

  (

    _genesisCrabAddress, 

    _cryptantCrabTokenAddress, 

    _cryptantCrabStorageAddress

  ) {

    // constructor



  }



  function _getCrabData(uint256 _tokenId) internal view returns 

  (

    uint256 _gene, 

    uint256 _level, 

    uint256 _exp, 

    uint256 _mutationCount,

    uint256 _trophyCount,

    uint256 _heartValue,

    uint256 _growthValue

  ) {

    require(cryptantCrabStorage != address(0));



    bytes32[] memory keys = new bytes32[](7);

    uint256[] memory values;



    keys[0] = keccak256(abi.encodePacked(_tokenId, "gene"));

    keys[1] = keccak256(abi.encodePacked(_tokenId, "level"));

    keys[2] = keccak256(abi.encodePacked(_tokenId, "exp"));

    keys[3] = keccak256(abi.encodePacked(_tokenId, "mutationCount"));

    keys[4] = keccak256(abi.encodePacked(_tokenId, "trophyCount"));

    keys[5] = keccak256(abi.encodePacked(_tokenId, "heartValue"));

    keys[6] = keccak256(abi.encodePacked(_tokenId, "growthValue"));



    values = cryptantCrabStorage.readUint256s(keys);



    // process heart value

    uint256 _processedHeartValue;

    for(uint256 i = 1 ; i <= 1000 ; i *= 10) {

      if(uint256(values[5]) / i % 10 > 0) {

        _processedHeartValue += i;

      }

    }



    _gene = values[0];

    _level = values[1];

    _exp = values[2];

    _mutationCount = values[3];

    _trophyCount = values[4];

    _heartValue = _processedHeartValue;

    _growthValue = values[6];

  }



  function _geneOfCrab(uint256 _tokenId) internal view returns (uint256 _gene) {

    require(cryptantCrabStorage != address(0));



    _gene = cryptantCrabStorage.readUint256(keccak256(abi.encodePacked(_tokenId, "gene")));

  }

}



contract CryptantCrabPurchasable is CryptantCrabInformant {

  using SafeMath for uint256;



  event CrabHatched(address indexed owner, uint256 tokenId, uint256 gene, uint256 specialSkin, uint256 crabPrice, uint256 growthValue);

  event CryptantFragmentsAdded(address indexed cryptantOwner, uint256 amount, uint256 newBalance);

  event CryptantFragmentsRemoved(address indexed cryptantOwner, uint256 amount, uint256 newBalance);

  event Refund(address indexed refundReceiver, uint256 reqAmt, uint256 paid, uint256 refundAmt);



  constructor

  (

    address _genesisCrabAddress, 

    address _cryptantCrabTokenAddress, 

    address _cryptantCrabStorageAddress

  ) 

  public 

  CryptantCrabInformant

  (

    _genesisCrabAddress, 

    _cryptantCrabTokenAddress, 

    _cryptantCrabStorageAddress

  ) {

    // constructor



  }



  function getCryptantFragments(address _sender) public view returns (uint256) {

    return cryptantCrabStorage.readUint256(keccak256(abi.encodePacked(_sender, "cryptant")));

  }



  function createCrab(uint256 _customTokenId, uint256 _crabPrice, uint256 _customGene, uint256 _customSkin, uint256 _customHeart, bool _hasLegendary) external onlyOwner {

    return _createCrab(false, _customTokenId, _crabPrice, _customGene, _customSkin, _customHeart, _hasLegendary);

  }



  function _addCryptantFragments(address _cryptantOwner, uint256 _amount) internal returns (uint256 _newBalance) {

    _newBalance = getCryptantFragments(_cryptantOwner).add(_amount);

    cryptantCrabStorage.updateUint256(keccak256(abi.encodePacked(_cryptantOwner, "cryptant")), _newBalance);

    emit CryptantFragmentsAdded(_cryptantOwner, _amount, _newBalance);

  }



  function _removeCryptantFragments(address _cryptantOwner, uint256 _amount) internal returns (uint256 _newBalance) {

    _newBalance = getCryptantFragments(_cryptantOwner).sub(_amount);

    cryptantCrabStorage.updateUint256(keccak256(abi.encodePacked(_cryptantOwner, "cryptant")), _newBalance);

    emit CryptantFragmentsRemoved(_cryptantOwner, _amount, _newBalance);

  }



  function _createCrab(bool _isPresale, uint256 _tokenId, uint256 _crabPrice, uint256 _customGene, uint256 _customSkin, uint256 _customHeart, bool _hasLegendary) internal {

    uint256[] memory _values = new uint256[](4);

    bytes32[] memory _keys = new bytes32[](4);



    uint256 _gene;

    uint256 _specialSkin;

    uint256 _heartValue;

    uint256 _growthValue;

    if(_customGene == 0) {

      (_gene, _specialSkin, _heartValue, _growthValue) = genesisCrab.generateCrabGene(_isPresale, _hasLegendary);

    } else {

      _gene = _customGene;

    }



    if(_customSkin != 0) {

      _specialSkin = _customSkin;

    }



    if(_customHeart != 0) {

      _heartValue = _customHeart;

    } else if (_heartValue == 0) {

      (_heartValue, _growthValue) = genesisCrab.generateCrabHeart();

    }

    

    cryptantCrabToken.mintToken(msg.sender, _tokenId, _specialSkin);



    // Gene pair

    _keys[0] = keccak256(abi.encodePacked(_tokenId, "gene"));

    _values[0] = _gene;



    // Level pair

    _keys[1] = keccak256(abi.encodePacked(_tokenId, "level"));

    _values[1] = 1;



    // Heart Value pair

    _keys[2] = keccak256(abi.encodePacked(_tokenId, "heartValue"));

    _values[2] = _heartValue;



    // Growth Value pair

    _keys[3] = keccak256(abi.encodePacked(_tokenId, "growthValue"));

    _values[3] = _growthValue;



    require(cryptantCrabStorage.createUint256s(_keys, _values));



    emit CrabHatched(msg.sender, _tokenId, _gene, _specialSkin, _crabPrice, _growthValue);

  }



  function _refundExceededValue(uint256 _senderValue, uint256 _requiredValue) internal {

    uint256 _exceededValue = _senderValue.sub(_requiredValue);



    if(_exceededValue > 0) {

      msg.sender.transfer(_exceededValue);



      emit Refund(msg.sender, _requiredValue, _senderValue, _exceededValue);

    } 

  }

}



contract Withdrawable is Ownable {

  address public withdrawer;



  /**

   * @dev Throws if called by any account other than the withdrawer.

   */

  modifier onlyWithdrawer() {

    require(msg.sender == withdrawer);

    _;

  }



  function setWithdrawer(address _newWithdrawer) external onlyOwner {

    withdrawer = _newWithdrawer;

  }



  /**

   * @dev withdraw the specified amount of ether from contract.

   * @param _amount the amount of ether to withdraw. Units in wei.

   */

  function withdraw(uint256 _amount) external onlyWithdrawer returns(bool) {

    require(_amount <= address(this).balance);

    withdrawer.transfer(_amount);

    return true;

  }

}



contract HasNoEther is Ownable {



  /**

  * @dev Constructor that rejects incoming Ether

  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we

  * leave out payable, then Solidity will allow inheriting contracts to implement a payable

  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively

  * we could use assembly to access msg.value.

  */

  constructor() public payable {

    require(msg.value == 0);

  }



  /**

   * @dev Disallows direct send by settings a default function without the `payable` flag.

   */

  function() external {

  }



  /**

   * @dev Transfer all Ether held by the contract to the owner.

   */

  function reclaimEther() external onlyOwner {

    owner.transfer(address(this).balance);

  }

}



contract CryptantCrabPresale is CryptantCrabPurchasable, HasNoEther, Withdrawable, Randomable {

  event PresalePurchased(address indexed owner, uint256 amount, uint256 cryptant, uint256 refund);



  uint256 constant public PRICE_INCREMENT = 1 finney;



  uint256 constant public PRESALE_LIMIT = 5000;



  uint256 constant public PRESALE_MAX_PRICE = 490 finney;



  /**

   * @dev Currently is set to 17/11/2018 00:00:00

   */

  uint256 public presaleEndTime = 1542412800;



  /**

   * @dev Initial presale price is 0.12 ether

   */

  uint256 public currentPresalePrice = 120 finney;



  /**

   * @dev The number of seconds that the presale price will stay fixed. 

   */

  uint256 constant public presalePriceUpdatePeriod = 3600;



  /**

   * @dev Keep tracks on the presale price period.

   *  initial period = (GMT): Thursday, October 25, 2018 12:00:00 AM

   */

  uint256 public currentPresalePeriod = 427896;



  /** 

   * @dev tracks the current token id, starts from 10

   */

  uint256 public currentTokenId = 10;



  /** 

   * @dev tracks the current giveaway token id, starts from 5001

   */

  uint256 public giveawayTokenId = 5001;



  constructor

  (

    address _genesisCrabAddress, 

    address _cryptantCrabTokenAddress, 

    address _cryptantCrabStorageAddress

  ) 

  public 

  CryptantCrabPurchasable

  (

    _genesisCrabAddress, 

    _cryptantCrabTokenAddress, 

    _cryptantCrabStorageAddress

  ) {

    // constructor



  }



  function setPresaleEndtime(uint256 _newEndTime) external onlyOwner {

    presaleEndTime = _newEndTime;

  }



  function getPresalePrice() public returns (uint256) {

    uint256 _currentPresalePeriod = now / presalePriceUpdatePeriod;



    if(_currentPresalePeriod > currentPresalePeriod) {

      // need to update current presale price

      uint256 _periodDifference = _currentPresalePeriod - currentPresalePeriod;



      uint256 _newPrice = PRICE_INCREMENT * _periodDifference;



      if(_newPrice <= PRESALE_MAX_PRICE) {

        currentPresalePrice += _newPrice;

        currentPresalePeriod = _currentPresalePeriod;

      } else {

        if (currentPresalePrice != PRESALE_MAX_PRICE) {

          currentPresalePrice = PRESALE_MAX_PRICE;

          currentPresalePeriod = _currentPresalePeriod;

        }

      }



      return currentPresalePrice;

    } else {

      return currentPresalePrice;

    }

  }



  function purchase(uint256 _amount) external payable {

    require(genesisCrab != address(0));

    require(cryptantCrabToken != address(0));

    require(cryptantCrabStorage != address(0));

    require(_amount > 0 && _amount <= 10);

    require(isPresale());

    require(PRESALE_LIMIT >= currentTokenId + _amount);



    uint256 _value = msg.value;

    uint256 _currentPresalePrice = getPresalePrice();

    uint256 _totalRequiredAmount = _currentPresalePrice * _amount;



    require(_value >= _totalRequiredAmount);



    // Purchase 10 crabs will have 1 crab with legendary part

    // Default value for _crabWithLegendaryPart is just a unreacable number

    uint256 _crabWithLegendaryPart = 100;

    if(_amount == 10) {

      // decide which crab will have the legendary part

      _crabWithLegendaryPart = _generateRandomNumber(bytes32(currentTokenId), 10);

    }



    for(uint256 i = 0 ; i < _amount ; i++) {

      currentTokenId++;

      _createCrab(true, currentTokenId, _currentPresalePrice, 0, 0, 0, _crabWithLegendaryPart == i);

    }



    // Presale crab will get free cryptant fragments

    _addCryptantFragments(msg.sender, (i * 3000));



    // Refund exceeded value

    _refundExceededValue(_value, _totalRequiredAmount);



    emit PresalePurchased(msg.sender, _amount, i * 3000, _value - _totalRequiredAmount);

  }



  function createCrab(uint256 _customTokenId, uint256 _crabPrice, uint256 _customGene, uint256 _customSkin, uint256 _customHeart, bool _hasLegendary) external onlyOwner {

    return _createCrab(true, _customTokenId, _crabPrice, _customGene, _customSkin, _customHeart, _hasLegendary);

  }



  function generateGiveawayCrabs(uint256 _amount) external onlyOwner {

    for(uint256 i = 0 ; i < _amount ; i++) {

      _createCrab(false, giveawayTokenId++, 120 finney, 0, 0, 0, false);

    }

  }



  function isPresale() internal view returns (bool) {

    return now < presaleEndTime;

  }



  function setCurrentPresalePeriod(uint256 _newPresalePeriod) external onlyOwner {

    currentPresalePeriod = _newPresalePeriod;

  }

}



contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address indexed operator, string role);

  event RoleRemoved(address indexed operator, string role);



  /**

   * @dev reverts if addr does not have role

   * @param _operator address

   * @param _role the name of the role

   * // reverts

   */

  function checkRole(address _operator, string _role)

    view

    public

  {

    roles[_role].check(_operator);

  }



  /**

   * @dev determine if addr has role

   * @param _operator address

   * @param _role the name of the role

   * @return bool

   */

  function hasRole(address _operator, string _role)

    view

    public

    returns (bool)

  {

    return roles[_role].has(_operator);

  }



  /**

   * @dev add a role to an address

   * @param _operator address

   * @param _role the name of the role

   */

  function addRole(address _operator, string _role)

    internal

  {

    roles[_role].add(_operator);

    emit RoleAdded(_operator, _role);

  }



  /**

   * @dev remove a role from an address

   * @param _operator address

   * @param _role the name of the role

   */

  function removeRole(address _operator, string _role)

    internal

  {

    roles[_role].remove(_operator);

    emit RoleRemoved(_operator, _role);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param _role the name of the role

   * // reverts

   */

  modifier onlyRole(string _role)

  {

    checkRole(msg.sender, _role);

    _;

  }



  /**

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param _roles the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] _roles) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < _roles.length; i++) {

  //         if (hasRole(msg.sender, _roles[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}



contract Whitelist is Ownable, RBAC {

  string public constant ROLE_WHITELISTED = "whitelist";



  /**

   * @dev Throws if operator is not whitelisted.

   * @param _operator address

   */

  modifier onlyIfWhitelisted(address _operator) {

    checkRole(_operator, ROLE_WHITELISTED);

    _;

  }



  /**

   * @dev add an address to the whitelist

   * @param _operator address

   * @return true if the address was added to the whitelist, false if the address was already in the whitelist

   */

  function addAddressToWhitelist(address _operator)

    onlyOwner

    public

  {

    addRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev getter to determine if address is in whitelist

   */

  function whitelist(address _operator)

    public

    view

    returns (bool)

  {

    return hasRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev add addresses to the whitelist

   * @param _operators addresses

   * @return true if at least one address was added to the whitelist,

   * false if all addresses were already in the whitelist

   */

  function addAddressesToWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      addAddressToWhitelist(_operators[i]);

    }

  }



  /**

   * @dev remove an address from the whitelist

   * @param _operator address

   * @return true if the address was removed from the whitelist,

   * false if the address wasn't in the whitelist in the first place

   */

  function removeAddressFromWhitelist(address _operator)

    onlyOwner

    public

  {

    removeRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev remove addresses from the whitelist

   * @param _operators addresses

   * @return true if at least one address was removed from the whitelist,

   * false if all addresses weren't in the whitelist in the first place

   */

  function removeAddressesFromWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      removeAddressFromWhitelist(_operators[i]);

    }

  }



}



library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an address access to this role

   */

  function add(Role storage role, address addr)

    internal

  {

    role.bearer[addr] = true;

  }



  /**

   * @dev remove an address' access to this role

   */

  function remove(Role storage role, address addr)

    internal

  {

    role.bearer[addr] = false;

  }



  /**

   * @dev check if an address has this role

   * // reverts

   */

  function check(Role storage role, address addr)

    view

    internal

  {

    require(has(role, addr));

  }



  /**

   * @dev check if an address has this role

   * @return bool

   */

  function has(Role storage role, address addr)

    view

    internal

    returns (bool)

  {

    return role.bearer[addr];

  }

}



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



contract ERC721Metadata is ERC721Basic {

  function name() external view returns (string _name);

  function symbol() external view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}



contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}



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



contract CryptantCrabNFT is ERC721Token, Whitelist, CrabData, GeneSurgeon {

  event CrabPartAdded(uint256 hp, uint256 dps, uint256 blockAmount);

  event GiftTransfered(address indexed _from, address indexed _to, uint256 indexed _tokenId);

  event DefaultMetadataURIChanged(string newUri);



  /**

   * @dev Pre-generated keys to save gas

   * keys are generated with:

   * CRAB_BODY       = bytes4(keccak256("crab_body"))       = 0xc398430e

   * CRAB_LEG        = bytes4(keccak256("crab_leg"))        = 0x889063b1

   * CRAB_LEFT_CLAW  = bytes4(keccak256("crab_left_claw"))  = 0xdb6290a2

   * CRAB_RIGHT_CLAW = bytes4(keccak256("crab_right_claw")) = 0x13453f89

   */

  bytes4 internal constant CRAB_BODY = 0xc398430e;

  bytes4 internal constant CRAB_LEG = 0x889063b1;

  bytes4 internal constant CRAB_LEFT_CLAW = 0xdb6290a2;

  bytes4 internal constant CRAB_RIGHT_CLAW = 0x13453f89;



  /**

   * @dev Stores all the crab data

   */

  mapping(bytes4 => mapping(uint256 => CrabPartData[])) internal crabPartData;



  /**

   * @dev Mapping from tokenId to its corresponding special skin

   * tokenId with default skin will not be stored. 

   */

  mapping(uint256 => uint256) internal crabSpecialSkins;



  /**

   * @dev default MetadataURI

   */

  string public defaultMetadataURI = "https://www.cryptantcrab.io/md/";



  constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {

    // constructor

    initiateCrabPartData();

  }



  /**

   * @dev Returns an URI for a given token ID

   * Throws if the token ID does not exist.

   * Will return the token's metadata URL if it has one, 

   * otherwise will just return base on the default metadata URI

   * @param _tokenId uint256 ID of the token to query

   */

  function tokenURI(uint256 _tokenId) public view returns (string) {

    require(exists(_tokenId));



    string memory _uri = tokenURIs[_tokenId];



    if(bytes(_uri).length == 0) {

      _uri = getMetadataURL(bytes(defaultMetadataURI), _tokenId);

    }



    return _uri;

  }



  /**

   * @dev Returns the data of a specific parts

   * @param _partIndex the part to retrieve. 1 = Body, 2 = Legs, 3 = Left Claw, 4 = Right Claw

   * @param _element the element of part to retrieve. 1 = Fire, 2 = Earth, 3 = Metal, 4 = Spirit, 5 = Water

   * @param _setIndex the set index of for the specified part. This will starts from 1.

   */

  function dataOfPart(uint256 _partIndex, uint256 _element, uint256 _setIndex) public view returns (uint256[] memory _resultData) {

    bytes4 _key;

    if(_partIndex == 1) {

      _key = CRAB_BODY;

    } else if(_partIndex == 2) {

      _key = CRAB_LEG;

    } else if(_partIndex == 3) {

      _key = CRAB_LEFT_CLAW;

    } else if(_partIndex == 4) {

      _key = CRAB_RIGHT_CLAW;

    } else {

      revert();

    }



    CrabPartData storage _crabPartData = crabPartData[_key][_element][_setIndex];



    _resultData = crabPartDataToArray(_crabPartData);

  }



  /**

   * @dev Gift(Transfer) a token to another address. Caller must be token owner

   * @param _from current owner of the token

   * @param _to address to receive the ownership of the given token ID

   * @param _tokenId uint256 ID of the token to be transferred

   */

  function giftToken(address _from, address _to, uint256 _tokenId) external {

    safeTransferFrom(_from, _to, _tokenId);



    emit GiftTransfered(_from, _to, _tokenId);

  }



  /**

   * @dev External function to mint a new token, for whitelisted address only.

   * Reverts if the given token ID already exists

   * @param _tokenOwner address the beneficiary that will own the minted token

   * @param _tokenId uint256 ID of the token to be minted by the msg.sender

   * @param _skinId the skin ID to be applied for all the token minted

   */

  function mintToken(address _tokenOwner, uint256 _tokenId, uint256 _skinId) external onlyIfWhitelisted(msg.sender) {

    super._mint(_tokenOwner, _tokenId);



    if(_skinId > 0) {

      crabSpecialSkins[_tokenId] = _skinId;

    }

  }



  /**

   * @dev Returns crab data base on the gene provided

   * @param _gene the gene info where crab data will be retrieved base on it

   * @return 4 uint arrays:

   * 1st Array = Body's Data

   * 2nd Array = Leg's Data

   * 3rd Array = Left Claw's Data

   * 4th Array = Right Claw's Data

   */

  function crabPartDataFromGene(uint256 _gene) external view returns (

    uint256[] _bodyData,

    uint256[] _legData,

    uint256[] _leftClawData,

    uint256[] _rightClawData

  ) {

    uint256[] memory _parts = extractPartsFromGene(_gene);

    uint256[] memory _elements = extractElementsFromGene(_gene);



    _bodyData = dataOfPart(1, _elements[0], _parts[0]);

    _legData = dataOfPart(2, _elements[1], _parts[1]);

    _leftClawData = dataOfPart(3, _elements[2], _parts[2]);

    _rightClawData = dataOfPart(4, _elements[3], _parts[3]);

  }



  /**

   * @dev For developer to add new parts, notice that this is the only method to add crab data

   * so that developer can add extra content. there's no other method for developer to modify

   * the data. This is to assure token owner actually owns their data.

   * @param _partIndex the part to add. 1 = Body, 2 = Legs, 3 = Left Claw, 4 = Right Claw

   * @param _element the element of part to add. 1 = Fire, 2 = Earth, 3 = Metal, 4 = Spirit, 5 = Water

   * @param _partDataArray data of the parts.

   */

  function setPartData(uint256 _partIndex, uint256 _element, uint256[] _partDataArray) external onlyOwner {

    CrabPartData memory _partData = arrayToCrabPartData(_partDataArray);



    bytes4 _key;

    if(_partIndex == 1) {

      _key = CRAB_BODY;

    } else if(_partIndex == 2) {

      _key = CRAB_LEG;

    } else if(_partIndex == 3) {

      _key = CRAB_LEFT_CLAW;

    } else if(_partIndex == 4) {

      _key = CRAB_RIGHT_CLAW;

    }



    // if index 1 is empty will fill at index 1

    if(crabPartData[_key][_element][1].hp == 0 && crabPartData[_key][_element][1].dps == 0) {

      crabPartData[_key][_element][1] = _partData;

    } else {

      crabPartData[_key][_element].push(_partData);

    }



    emit CrabPartAdded(_partDataArray[0], _partDataArray[1], _partDataArray[2]);

  }



  /**

   * @dev Updates the default metadata URI

   * @param _defaultUri the new metadata URI

   */

  function setDefaultMetadataURI(string _defaultUri) external onlyOwner {

    defaultMetadataURI = _defaultUri;



    emit DefaultMetadataURIChanged(_defaultUri);

  }



  /**

   * @dev Updates the metadata URI for existing token

   * @param _tokenId the tokenID that metadata URI to be changed

   * @param _uri the new metadata URI for the specified token

   */

  function setTokenURI(uint256 _tokenId, string _uri) external onlyIfWhitelisted(msg.sender) {

    _setTokenURI(_tokenId, _uri);

  }



  /**

   * @dev Returns the special skin of the provided tokenId

   * @param _tokenId cryptant crab's tokenId

   * @return Special skin belongs to the _tokenId provided. 

   * 0 will be returned if no special skin found.

   */

  function specialSkinOfTokenId(uint256 _tokenId) external view returns (uint256) {

    return crabSpecialSkins[_tokenId];

  }



  /**

   * @dev This functions will adjust the length of crabPartData

   * so that when adding data the index can start with 1.

   * Reason of doing this is because gene cannot have parts with index 0.

   */

  function initiateCrabPartData() internal {

    require(crabPartData[CRAB_BODY][1].length == 0);



    for(uint256 i = 1 ; i <= 5 ; i++) {

      crabPartData[CRAB_BODY][i].length = 2;

      crabPartData[CRAB_LEG][i].length = 2;

      crabPartData[CRAB_LEFT_CLAW][i].length = 2;

      crabPartData[CRAB_RIGHT_CLAW][i].length = 2;

    }

  }



  /**

   * @dev Returns whether the given spender can transfer a given token ID

   * @param _spender address of the spender to query

   * @param _tokenId uint256 ID of the token to be transferred

   * @return bool whether the msg.sender is approved for the given token ID,

   *  is an operator of the owner, or is the owner of the token, 

   *  or has been whitelisted by contract owner

   */

  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {

    address owner = ownerOf(_tokenId);

    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender) || whitelist(_spender);

  }



  /**

   * @dev Will merge the uri and tokenId together. 

   * @param _uri URI to be merge. This will be the first part of the result URL.

   * @param _tokenId tokenID to be merge. This will be the last part of the result URL.

   * @return the merged urL

   */

  function getMetadataURL(bytes _uri, uint256 _tokenId) internal pure returns (string) {

    uint256 _tmpTokenId = _tokenId;

    uint256 _tokenLength;



    // Getting the length(number of digits) of token ID

    do {

      _tokenLength++;

      _tmpTokenId /= 10;

    } while (_tmpTokenId > 0);



    // creating a byte array with the length of URL + token digits

    bytes memory _result = new bytes(_uri.length + _tokenLength);



    // cloning the uri bytes into the result bytes

    for(uint256 i = 0 ; i < _uri.length ; i ++) {

      _result[i] = _uri[i];

    }



    // appending the tokenId to the end of the result bytes

    uint256 lastIndex = _result.length - 1;

    for(_tmpTokenId = _tokenId ; _tmpTokenId > 0 ; _tmpTokenId /= 10) {

      _result[lastIndex--] = byte(48 + _tmpTokenId % 10);

    }



    return string(_result);

  }

}
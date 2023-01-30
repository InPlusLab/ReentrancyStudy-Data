/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

/*
 * Copyright ©️ 2018-2020 Galt•Project Society Construction and Terraforming Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka)
 *
 * Copyright ©️ 2018-2020 Galt•Core Blockchain Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka) by
 * [Basic Agreement](ipfs/QmaCiXUmSrP16Gz8Jdzq6AJESY1EAANmmwha15uR3c1bsS)).
 * 
 * 🌎 Galt Project is an international decentralized land and real estate property registry
 * governed by DAO (Decentralized autonomous organization) and self-governance platform for communities
 * of homeowners on Ethereum.
 * 
 * 🏡 https://galtproject.io
 */

pragma solidity ^0.5.13;

interface IHomeMediator {
  function handleBridgedTokens(address _recipient, uint256 _tokenId, bytes calldata _metadata, bytes32 _nonce) external;
}

contract Initializable {

  /**
   * @dev Indicates if the contract has been initialized.
   */
  bool public initialized;

  /**
   * @dev Modifier to use in the initialization function of a contract.
   */
  modifier isInitializer() {
    require(!initialized, "Contract instance has already been initialized");
    _;
    initialized = true;
  }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract OwnableAndInitializable is Ownable, Initializable {

  /**
   * @dev Modifier to use in the initialization function of a contract.
   */
  modifier isInitializer() {
    require(!initialized, "Contract instance has already been initialized");
    _;
    initialized = true;
    _transferOwnership(tx.origin);
  }

  /**
   * @dev Modifier to use in the initialization function of a contract. Allow a custom owner setup;
   */
  modifier initializeWithOwner(address _owner) {
    require(!initialized, "Contract instance has already been initialized");
    _;
    initialized = true;
    _transferOwnership(_owner);
  }
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

interface IPPToken {
  event SetBaseURI(string baseURI);
  event SetContractDataLink(string indexed dataLink);
  event SetLegalAgreementIpfsHash(bytes32 legalAgreementIpfsHash);
  event SetController(address indexed controller);
  event SetDetails(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetContour(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetHumanAddress(uint256 indexed tokenId, string humanAddress);
  event SetDataLink(uint256 indexed tokenId, string dataLink);
  event SetLedgerIdentifier(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexRootHash(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexStorageLink(uint256 indexed tokenId, string vertexStorageLink);
  event SetArea(uint256 indexed tokenId, uint256 area, AreaSource areaSource);
  event SetExtraData(bytes32 indexed key, bytes32 value);
  event SetPropertyExtraData(uint256 indexed propertyId, bytes32 indexed key, bytes32 value);
  event Mint(address indexed to, uint256 indexed privatePropertyId);
  event Burn(address indexed from, uint256 indexed privatePropertyId);

  enum AreaSource {
    USER_INPUT,
    CONTRACT
  }

  enum TokenType {
    NULL,
    LAND_PLOT,
    BUILDING,
    ROOM,
    PACKAGE
  }

  struct Property {
    uint256 setupStage;

    // (LAND_PLOT,BUILDING,ROOM) Type cannot be changed after token creation
    TokenType tokenType;
    // Geohash5z (x,y,z)
    uint256[] contour;
    // Meters above the sea
    int256 highestPoint;

    // USER_INPUT or CONTRACT
    AreaSource areaSource;
    // Calculated either by contract (for land plots and buildings) or by manual input
    // in sq. meters (1 sq. meter == 1 eth)
    uint256 area;

    bytes32 ledgerIdentifier;
    string humanAddress;
    string dataLink;

    // Reserved for future use
    bytes32 vertexRootHash;
    string vertexStorageLink;
  }

  // PERMISSIONED METHODS

  function setContractDataLink(string calldata _dataLink) external;
  function setLegalAgreementIpfsHash(bytes32 _legalAgreementIpfsHash) external;
  function setController(address payable _controller) external;
  function setDetails(
    uint256 _tokenId,
    TokenType _tokenType,
    AreaSource _areaSource,
    uint256 _area,
    bytes32 _ledgerIdentifier,
    string calldata _humanAddress,
    string calldata _dataLink
  )
    external;

  function setContour(
    uint256 _tokenId,
    uint256[] calldata _contour,
    int256 _highestPoint
  )
    external;

  function setArea(uint256 _tokenId, uint256 _area, AreaSource _areaSource) external;
  function setLedgerIdentifier(uint256 _tokenId, bytes32 _ledgerIdentifier) external;
  function setDataLink(uint256 _tokenId, string calldata _dataLink) external;
  function setVertexRootHash(uint256 _tokenId, bytes32 _vertexRootHash) external;
  function setVertexStorageLink(uint256 _tokenId, string calldata _vertexStorageLink) external;
  function setExtraData(bytes32 _key, bytes32 _value) external;
  function setPropertyExtraData(uint256 _tokenId, bytes32 _key, bytes32 _value) external;

  function incrementSetupStage(uint256 _tokenId) external;

  function mint(address _to) external returns (uint256);
  function burn(uint256 _tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;

  // GETTERS
  function controller() external view returns (address payable);
  function extraData(bytes32 _key) external view returns (bytes32);
  function propertyExtraData(uint256 _tokenId, bytes32 _key) external view returns (bytes32);
  function propertyCreatedAt(uint256 _tokenId) external view returns (uint256);
  function tokensOfOwner(address _owner) external view returns (uint256[] memory);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function exists(uint256 _tokenId) external view returns (bool);
  function getType(uint256 _tokenId) external view returns (TokenType);
  function getContour(uint256 _tokenId) external view returns (uint256[] memory);
  function getContourLength(uint256 _tokenId) external view returns (uint256);
  function getHighestPoint(uint256 _tokenId) external view returns (int256);
  function getHumanAddress(uint256 _tokenId) external view returns (string memory);
  function getArea(uint256 _tokenId) external view returns (uint256);
  function getAreaSource(uint256 _tokenId) external view returns (AreaSource);
  function getLedgerIdentifier(uint256 _tokenId) external view returns (bytes32);
  function getDataLink(uint256 _tokenId) external view returns (string memory);
  function getVertexRootHash(uint256 _tokenId) external view returns (bytes32);
  function getVertexStorageLink(uint256 _tokenId) external view returns (string memory);
  function getSetupStage(uint256 _tokenId) external view returns (uint256);
  function getDetails(uint256 _tokenId)
    external
    view
    returns (
      TokenType tokenType,
      uint256[] memory contour,
      int256 highestPoint,
      AreaSource areaSource,
      uint256 area,
      bytes32 ledgerIdentifier,
      string memory humanAddress,
      string memory dataLink,
      uint256 setupStage,
      bytes32 vertexRootHash,
      string memory vertexStorageLink
    );
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract ERC721Bridge {
  event SetERC721Token(address token);

  bytes32 internal constant ERC721_TOKEN = keccak256(abi.encodePacked("erc721token"));

  address public erc721Token;

  function _setErc721token(address _token) internal {
    require(Address.isContract(_token), "Address should be a contract");
    erc721Token = _token;

    emit SetERC721Token(_token);
  }
}

interface IAMB {
  function messageSender() external view returns (address);
  function maxGasPerTx() external view returns (uint256);
  function transactionHash() external view returns (bytes32);
  function messageCallStatus(bytes32 _txHash) external view returns (bool);
  function failedMessageDataHash(bytes32 _txHash) external view returns (bytes32);
  function failedMessageReceiver(bytes32 _txHash) external view returns (address);
  function failedMessageSender(bytes32 _txHash) external view returns (address);
  function requireToPassMessage(address _contract, bytes calldata _data, uint256 _gas) external;
}

contract AMBMediator is Ownable {
  event SetBridgeContract(address bridgeContract);
  event SetMediatorContractOnOtherSide(address mediatorContract);
  event SetRequestGasLimit(uint256 requestGasLimit);

  uint256 public oppositeChainId;
  IAMB public bridgeContract;
  address public mediatorContractOnOtherSide;
  uint256 public requestGasLimit;

  // OWNER INTERFACE

  function setBridgeContract(address _bridgeContract) external onlyOwner {
    _setBridgeContract(_bridgeContract);
  }

  function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
    _setMediatorContractOnOtherSide(_mediatorContract);
  }

  function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {
    _setRequestGasLimit(_requestGasLimit);
  }

  // INTERNAL

  function _setBridgeContract(address _bridgeContract) internal {
    require(Address.isContract(_bridgeContract), "Address should be a contract");
    bridgeContract = IAMB(_bridgeContract);

    emit SetBridgeContract(_bridgeContract);
  }

  function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
    mediatorContractOnOtherSide = _mediatorContract;

    emit SetMediatorContractOnOtherSide(_mediatorContract);
  }

  function _setRequestGasLimit(uint256 _requestGasLimit) internal {
    require(_requestGasLimit <= bridgeContract.maxGasPerTx(), "Gas value exceeds bridge limit");
    requestGasLimit = _requestGasLimit;

    emit SetRequestGasLimit(_requestGasLimit);
  }
}

contract BasicMediator is AMBMediator, ERC721Bridge, OwnableAndInitializable {
  event RequestFailedMessageFix(bytes32 indexed txHash);
  event FailedMessageFixed(bytes32 indexed dataHash, address recipient, uint256 tokenId);

  bytes4 internal constant GET_DETAILS = 0xb93a89f7; // getDetails(uint256)

  bytes32 internal nonce;
  mapping(bytes32 => uint256) internal messageHashTokenId;
  mapping(bytes32 => address) internal messageHashRecipient;
  mapping(bytes32 => bool) public messageHashFixed;

  function initialize(
    address _bridgeContract,
    address _mediatorContractOnOtherSide,
    address _erc721token,
    uint256 _requestGasLimit,
    uint256 _oppositeChainId,
    address _owner
  )
    external
    initializeWithOwner(_owner)
    returns (bool)
  {
    _setBridgeContract(_bridgeContract);
    _setMediatorContractOnOtherSide(_mediatorContractOnOtherSide);
    _setErc721token(_erc721token);
    _setRequestGasLimit(_requestGasLimit);

    oppositeChainId = _oppositeChainId;

    setNonce(keccak256(abi.encodePacked(address(this))));

    return true;
  }

  // ABSTRACT METHODS

  function fixFailedMessage(bytes32 _dataHash) external;

  function bridgeSpecificActionsOnTokenTransfer(address _from, uint256 _tokenId) internal;

  // INFO GETTERS

  function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
    return (1, 0, 0);
  }

  function getBridgeMode() external pure returns (bytes4 _data) {
    return bytes4(keccak256(abi.encodePacked("nft-to-nft-amb")));
  }

  // USER INTERFACE

  function transferToken(address _from, uint256 _tokenId) external {
    address to = address(this);

    IERC721(erc721Token).transferFrom(_from, to, _tokenId);
    bridgeSpecificActionsOnTokenTransfer(_from, _tokenId);
  }

  function getMetadata(uint256 _tokenId) public view returns (bytes memory metadata) {
    bytes memory callData = abi.encodeWithSelector(GET_DETAILS, _tokenId);
    address tokenAddress = address(erc721Token);
    uint256 size;

    assembly {
      let result := staticcall(gas, tokenAddress, add(callData, 0x20), mload(callData), 0, 0)
      size := returndatasize

      switch result
      case 0 { revert(0, 0) }
    }

    metadata = new bytes(size);

    assembly {
      returndatacopy(add(metadata, 0x20), 0, size)
    }
  }

  function setNonce(bytes32 _hash) internal {
    nonce = _hash;
  }

  function setMessageHashTokenId(bytes32 _hash, uint256 _tokenId) internal {
    messageHashTokenId[_hash] = _tokenId;
  }

  function setMessageHashRecipient(bytes32 _hash, address _recipient) internal {
    messageHashRecipient[_hash] = _recipient;
  }

  function setMessageHashFixed(bytes32 _hash) internal {
    messageHashFixed[_hash] = true;
  }

  function requestFailedMessageFix(bytes32 _txHash) external {
    require(!bridgeContract.messageCallStatus(_txHash), "No fix required");
    require(bridgeContract.failedMessageReceiver(_txHash) == address(this), "Invalid receiver");
    require(bridgeContract.failedMessageSender(_txHash) == mediatorContractOnOtherSide, "Invalid sender");
    bytes32 dataHash = bridgeContract.failedMessageDataHash(_txHash);

    bytes4 methodSelector = this.fixFailedMessage.selector;
    bytes memory data = abi.encodeWithSelector(methodSelector, dataHash);
    bridgeContract.requireToPassMessage(mediatorContractOnOtherSide, data, requestGasLimit);

    emit RequestFailedMessageFix(_txHash);
  }
}

contract PPForeignMediator is BasicMediator {
  bytes32 public constant LOCKER_TYPE = bytes32("MEDIATOR");

  function passMessage(address _from, uint256 _tokenId) internal {
    bytes memory metadata = getMetadata(_tokenId);

    bytes4 methodSelector = IHomeMediator(0).handleBridgedTokens.selector;
    bytes memory data = abi.encodeWithSelector(methodSelector, _from, _tokenId, metadata, nonce);

    bytes32 dataHash = keccak256(data);
    setMessageHashTokenId(dataHash, _tokenId);
    setMessageHashRecipient(dataHash, _from);
    setNonce(dataHash);

    bridgeContract.requireToPassMessage(mediatorContractOnOtherSide, data, requestGasLimit);
  }

  function handleBridgedTokens(
    address _recipient,
    uint256 _tokenId,
    bytes32 /* _nonce */
  )
    external
  {
    require(msg.sender == address(bridgeContract), "Only bridge allowed");
    require(bridgeContract.messageSender() == mediatorContractOnOtherSide, "Invalid contract on other side");
    IERC721(erc721Token).transferFrom(address(this), _recipient, _tokenId);
  }

  function bridgeSpecificActionsOnTokenTransfer(address _from, uint256 _tokenId) internal {
    passMessage(_from, _tokenId);
  }

  function fixFailedMessage(bytes32 _dataHash) external {
    require(msg.sender == address(bridgeContract), "Only bridge allowed");
    require(bridgeContract.messageSender() == mediatorContractOnOtherSide, "Invalid contract on other side");
    require(!messageHashFixed[_dataHash], "Already fixed");

    address recipient = messageHashRecipient[_dataHash];
    uint256 tokenId = messageHashTokenId[_dataHash];

    setMessageHashFixed(_dataHash);
    IERC721(erc721Token).transferFrom(address(this), recipient, tokenId);

    emit FailedMessageFixed(_dataHash, recipient, tokenId);
  }
}
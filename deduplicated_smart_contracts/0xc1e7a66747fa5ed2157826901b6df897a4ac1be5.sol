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

contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * Should be implemented in a descendant contract
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address) {
    assert(false);
  }

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}


contract UpgradeabilityProxy is Proxy {
  /**
   * @dev This event will be emitted every time the implementation gets upgraded
   * @param implementation representing the address of the upgraded implementation
   */
  event Upgraded(address indexed implementation);

  // Storage position of the address of the current implementation
  bytes32 private constant implementationPosition = keccak256("io.galtproject.proxy.implementation");

  /**
   * @dev Constructor function
   */
  constructor() public {}

  /**
   * @dev Tells the address of the current implementation
   * @return address of the current implementation
   */
  function implementation() public view returns (address impl) {
    bytes32 position = implementationPosition;
    assembly {
      impl := sload(position)
    }
  }

  /**
   * @dev Sets the address of the current implementation
   * @param newImplementation address representing the new implementation to be set
   */
  function setImplementation(address newImplementation) internal {
    bytes32 position = implementationPosition;
    assembly {
      sstore(position, newImplementation)
    }
  }

  /**
   * @dev Upgrades the implementation address
   * @param newImplementation representing the address of the new implementation to be set
   */
  function _upgradeTo(address newImplementation) internal {
    address currentImplementation = implementation();
    require(currentImplementation != newImplementation);
    setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }
}

interface IOwnedUpgradeabilityProxy {
  function implementation() external view returns (address);
  function proxyOwner() external view returns (address owner);
  function transferProxyOwnership(address newOwner) external;
  function upgradeTo(address _implementation) external;
  function upgradeToAndCall(address _implementation, bytes calldata _data) external payable;
}

contract OwnedUpgradeabilityProxy is IOwnedUpgradeabilityProxy, UpgradeabilityProxy {
  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  // Storage position of the owner of the contract
  bytes32 private constant proxyOwnerPosition = keccak256("io.galtproject.proxy.owner");

  /**
  * @dev the constructor sets the original owner of the contract to the sender account.
  */
  constructor() public {
    setUpgradeabilityOwner(msg.sender);
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function proxyOwner() public view returns (address owner) {
    bytes32 position = proxyOwnerPosition;
    assembly {
      owner := sload(position)
    }
  }

  /**
   * @dev Sets the address of the owner
   */
  function setUpgradeabilityOwner(address newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, newProxyOwner)
    }
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferProxyOwnership(address newOwner) external onlyProxyOwner {
    require(newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy.
   * @param implementation representing the address of the new implementation to be set.
   */
  function upgradeTo(address implementation) external onlyProxyOwner {
    _upgradeTo(implementation);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
   * to initialize whatever is needed through a low level call.
   * @param implementation representing the address of the new implementation to be set.
   * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
   * signature of the implementation to be called with the needed payload
   */
  function upgradeToAndCall(address implementation, bytes calldata data) payable external onlyProxyOwner {
    _upgradeTo(implementation);
    (bool x,) = address(this).call.value(msg.value)(data);
    require(x);
  }
}

interface IOwnedUpgradeabilityProxyFactory {
  function build() external returns(IOwnedUpgradeabilityProxy);
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

contract PPMediatorFactory {
  event NewPPMediatorRaw(address mediator);
  event NewPPMediator(address mediator, address tokenId, address _mediatorContractOnOtherSide);

  // oppositeChainId specified only for information
  uint256 public oppositeChainId;
  address public implementation;
  address public bridgeContract;
  uint256 public initialGasLimit;
  IOwnedUpgradeabilityProxyFactory internal ownedUpgradeabilityProxyFactory;

  constructor(
    IOwnedUpgradeabilityProxyFactory _factory,
    address _impl,
    address _bridgeContract,
    uint256 _initialGasLimit,
    uint256 _oppositeChainId
  )
    public
  {
    ownedUpgradeabilityProxyFactory = _factory;
    implementation = _impl;
    bridgeContract = _bridgeContract;
    initialGasLimit = _initialGasLimit;
    oppositeChainId = _oppositeChainId;
  }

  function buildWithPayload(
    bytes calldata _payload
  )
    external
    returns (address)
  {
    address mediator = _build(
      _payload,
      false,
      true
    );

    emit NewPPMediatorRaw(mediator);

    return mediator;
  }

  function build(
    address _owner,
    address _token,
    address _mediatorContractOnOtherSide
  )
    external
    returns (address)
  {
    bytes memory payload = abi.encodeWithSignature(
      "initialize(address,address,address,uint256,uint256,address)",
      bridgeContract,
      _mediatorContractOnOtherSide,
      _token,
      initialGasLimit,
      oppositeChainId,
      _owner
    );

    address mediator = _build(
      payload,
      false,
      true
    );

    emit NewPPMediator(mediator, _token, _mediatorContractOnOtherSide);

    return mediator;
  }

  // INTERNAL

  function _build(bytes memory _payload, bool _transferOwnership, bool _transferProxyOwnership)
    internal
    returns (address)
  {
    IOwnedUpgradeabilityProxy proxy = ownedUpgradeabilityProxyFactory.build();

    proxy.upgradeToAndCall(implementation, _payload);

    if (_transferOwnership == true) {
      Ownable(address(proxy)).transferOwnership(msg.sender);
    }

    if (_transferProxyOwnership == true) {
      proxy.transferProxyOwnership(msg.sender);
    }

    return address(proxy);
  }
}
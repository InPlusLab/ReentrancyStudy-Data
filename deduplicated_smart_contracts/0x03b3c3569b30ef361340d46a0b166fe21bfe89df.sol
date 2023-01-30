/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


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

// File: openzeppelin-eth/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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
  function initialize(address sender) public initializer {
    _owner = sender;
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
    emit OwnershipRenounced(_owner);
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

  uint256[50] private ______gap;
}

// File: contracts/proxies/SlaveProxy.sol

pragma solidity ^0.4.24;

//import './WalletManager.sol';

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract SlaveProxy {

  bytes32 private constant MANAGER_SLOT = 0x7a55c4d64d3f68c3935ebba18bdf734d8a1d1d068c865f9e08eab9d3a6da73b4;

  /**
   * @dev Contract constructor.
   * @param manager Address of the proxy manager.
   * @param data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address manager, bytes data) public {
    assert(MANAGER_SLOT == keccak256("minuteman-wallet-manager"));
    setManager(manager);

    if(data.length > 0) {
      require(_implementation().delegatecall(data));
    }
  }

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address) {
    return WalletManager(managerAddress()).getImplementation();
  }

  function setManager(address manager) internal {
    bytes32 slot = MANAGER_SLOT;
    assembly {
      sstore(slot, manager)
    }
  }

  function managerAddress() internal view returns(address manager) {
    bytes32 slot = MANAGER_SLOT;
    assembly {
      manager := sload(slot)
    }
  }

  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _delegate(_implementation());
  }
}

// File: contracts/proxies/WalletManager.sol

pragma solidity ^0.4.24;




contract WalletManager is Initializable, Ownable {

  mapping(address => address) public walletsByUser;
  address private implementation;

  event UserWalletCreated(address user, address walletAddress);
  event ImplementationChanged(address implementation);

  function initialize(address _implementation) initializer public {
    Ownable.initialize(msg.sender);
    implementation = _implementation;
    emit ImplementationChanged(implementation);
  }

  function getImplementation() external view returns (address) {
    return implementation;
  }

  function setImplementation(address newImplementation) external onlyOwner {
    implementation = newImplementation;
    emit ImplementationChanged(implementation);
  }

  function createWallet(address owner) public returns (address) {
    require(owner == address(0x0) || walletsByUser[owner] == address(0x0), "Address already has existing wallet");

    bytes memory data = abi.encodeWithSignature("initialize(address,address)", address(this), owner);
    address proxy = new SlaveProxy(address(this), data);

    if (owner != address(0x0)) {
      walletsByUser[owner] = proxy;
    }
    emit UserWalletCreated(owner, proxy);
    return proxy;
  }

  function changeOwner(address oldOwner, address newOwner) public {
    require(oldOwner == address(0) || msg.sender == walletsByUser[oldOwner]);
    walletsByUser[oldOwner] = address(0);
    walletsByUser[newOwner] = msg.sender;
  }
}
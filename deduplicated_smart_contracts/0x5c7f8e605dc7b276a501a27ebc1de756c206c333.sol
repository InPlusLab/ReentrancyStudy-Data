/**
 *Submitted for verification at Etherscan.io on 2020-04-07
*/

// File: openzeppelin-solidity/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

// File: openzeppelin-solidity/contracts/ownership/OWnable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// File: contracts/RootChainI.sol

pragma solidity ^0.5.12;

interface RootChainI {
  function operator() external view returns (address);
  function isRootChain() external view returns (bool);
  function currentFork() external view returns (uint);
  function lastEpoch(uint forkNumber) external view returns (uint);
}

// File: contracts/stake/interfaces/SeigManagerI.sol

pragma solidity ^0.5.12;


interface SeigManagerI {
  function registry() external view returns (address);
  function depositManager() external view returns (address);
  function ton() external view returns (address);
  function wton() external view returns (address);
  function powerton() external view returns (address);
  function tot() external view returns (address);
  function coinages(address rootchain) external view returns (address);
  function commissionRates(address rootchain) external view returns (uint256);

  function lastCommitBlock(address rootchain) external view returns (uint256);
  function seigPerBlock() external view returns (uint256);
  function lastSeigBlock() external view returns (uint256);
  function pausedBlock() external view returns (uint256);
  function unpausedBlock() external view returns (uint256);
  function DEFAULT_FACTOR() external view returns (uint256);

  function deployCoinage(address rootchain) external returns (bool);
  function setCommissionRate(address rootchain, uint256 commission) external returns (bool);

  function uncomittedStakeOf(address rootchain, address account) external view returns (uint256);
  function stakeOf(address rootchain, address account) external view returns (uint256);
  function additionalTotBurnAmount(address rootchain, address account, uint256 amount) external view returns (uint256 totAmount);

  function onTransfer(address sender, address recipient, uint256 amount) external returns (bool);
  function onCommit() external returns (bool);
  function onDeposit(address rootchain, address account, uint256 amount) external returns (bool);
  function onWithdraw(address rootchain, address account, uint256 amount) external returns (bool);

}

// File: contracts/stake/interfaces/RootChainRegistryI.sol

pragma solidity ^0.5.12;


interface RootChainRegistryI {
  function rootchains(address rootchain) external view returns (bool);

  function register(address rootchain) external returns (bool);
  function numRootChains() external view returns (uint256);
  function rootchainByIndex(uint256 index) external view returns (address);

  function deployCoinage(address rootchain, address seigManager) external returns (bool);
  function registerAndDeployCoinage(address rootchain, address seigManager) external returns (bool);
  function unregister(address rootchain) external returns (bool);
}

// File: contracts/stake/RootChainRegistry.sol

pragma solidity ^0.5.12;






// TODO: transfer coinages ownership to seig manager
contract RootChainRegistry is RootChainRegistryI, Ownable {
  // check whether the address is root chain contract or not
  mapping (address => bool) internal _rootchains;

  // array-like storages
  // NOTE: unregistered rootchains could exists in that array. so, should check by rootchains(address)
  uint256 internal _numRootChains;
  mapping (uint256 => address) internal _rootchainByIndex;

  modifier onlyOwnerOrOperator(address rootchain) {
    require(isOwner() || RootChainI(rootchain).operator() == msg.sender, "sender is neither operator nor operator");
    _;
  }

  function rootchains(address rootchain) external view returns (bool) {
    return _rootchains[rootchain];
  }

  function numRootChains() external view returns (uint256) {
    return _numRootChains;
  }

  function rootchainByIndex(uint256 index) external view returns (address) {
    return _rootchainByIndex[index];
  }

  function register(address rootchain)
    external
    onlyOwnerOrOperator(rootchain)
    returns (bool)
  {
    return _register(rootchain);
  }

  function _register(address rootchain) internal returns (bool) {
    require(!_rootchains[rootchain]);
    require(RootChainI(rootchain).isRootChain());

    _rootchains[rootchain] = true;
    _rootchainByIndex[_numRootChains] = rootchain;
    _numRootChains += 1;

    return true;
  }

  function deployCoinage(
    address rootchain,
    address seigManager
  )
    external
    onlyOwnerOrOperator(rootchain)
    returns (bool)
  {
    return _deployCoinage(rootchain, seigManager);
  }

  function _deployCoinage(
    address rootchain,
    address seigManager
  )
   internal
   returns (bool)
  {
    return SeigManagerI(seigManager).deployCoinage(rootchain);
  }

  function registerAndDeployCoinage(
    address rootchain,
    address seigManager
  )
    external
    onlyOwnerOrOperator(rootchain)
    returns (bool)
  {
    require(_register(rootchain));
    require(_deployCoinage(rootchain, seigManager));
    return true;
  }

  function registerAndDeployCoinageAndSetCommissionRate(
    address rootchain,
    address seigManager,
    uint256 commissionRate
  )
    external
    onlyOwnerOrOperator(rootchain)
    returns (bool)
  {
    require(_register(rootchain));
    require(_deployCoinage(rootchain, seigManager));
    require(_setCommissionRate(rootchain, seigManager, commissionRate));
    return true;
  }

  function _setCommissionRate(
    address rootchain,
    address seigManager,
    uint256 commissionRate
  )
    internal
    returns (bool)
  {
    return SeigManagerI(seigManager).setCommissionRate(rootchain, commissionRate);
  }

  function unregister(address rootchain) external onlyOwner returns (bool) {
    require(_rootchains[rootchain]);

    _rootchains[rootchain] = false;
  }
}
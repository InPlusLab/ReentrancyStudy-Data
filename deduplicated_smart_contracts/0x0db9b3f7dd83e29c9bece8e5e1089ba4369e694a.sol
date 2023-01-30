// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import './Context.sol';

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
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
  constructor() {
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
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// Contracts by dYdX Foundation. Individual files are released under different licenses.
//
// https://dydx.community
// https://github.com/dydxfoundation/governance-contracts
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import { Ownable } from '../dependencies/open-zeppelin/Ownable.sol';
import { IStarkPerpetual } from '../interfaces/IStarkPerpetual.sol';

/**
 * @title StarkExHelperGovernor
 * @author dYdX
 *
 * @notice This is a StarkEx governor which can be used by the owner to execute config changes.
 */
contract StarkExHelperGovernor is
  Ownable
{
  IStarkPerpetual public immutable STARK_PERPETUAL;

  constructor(
    address starkPerpetual
  ) {
    STARK_PERPETUAL = IStarkPerpetual(starkPerpetual);
  }

  function mainAcceptGovernance()
    external
    onlyOwner
  {
    STARK_PERPETUAL.mainAcceptGovernance();
  }

  /**
   * @notice Helper function to register and apply multiple asset configuration changes.
   *
   *  Requires that there is no timelock set on the StarkEx contract.
   *
   * @param  assetIds      Array of asset IDs for the assets to be configured.
   * @param  configHashes  Array of hashes of the asset configurations.
   */
  function executeAssetConfigurationChanges(
    uint256[] calldata assetIds,
    bytes32[] calldata configHashes
  )
    external
    onlyOwner
  {
    require(
      assetIds.length == configHashes.length,
      'StarkExHelperGovernor: Input params must have the same length'
    );
    for (uint256 i = 0; i < assetIds.length; i++) {
      STARK_PERPETUAL.registerAssetConfigurationChange(assetIds[i], configHashes[i]);
      STARK_PERPETUAL.applyAssetConfigurationChange(assetIds[i], configHashes[i]);
    }
  }

  /**
   * @notice Helper function to register and apply a global configuration change.
   *
   *  Requires that there is no timelock set on the StarkEx contract.
   *
   * @param  configHash  The hash of the global configuration.
   */
  function executeGlobalConfigurationChange(
    bytes32 configHash
  )
    external
    onlyOwner
  {
    STARK_PERPETUAL.registerGlobalConfigurationChange(configHash);
    STARK_PERPETUAL.applyGlobalConfigurationChange(configHash);
  }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.7.5;
pragma abicoder v2;

/**
 * @title IStarkPerpetual
 * @author dYdX
 *
 * @notice Partial interface for the StarkPerpetual contract, for accessing the dYdX L2 exchange.
 * @dev See https://github.com/starkware-libs/starkex-contracts
 */
interface IStarkPerpetual {

  function registerUser(
    address ethKey,
    uint256 starkKey,
    bytes calldata signature
  ) external;

  function deposit(
    uint256 starkKey,
    uint256 assetType,
    uint256 vaultId,
    uint256 quantizedAmount
  ) external;

  function withdraw(uint256 starkKey, uint256 assetType) external;

  function forcedWithdrawalRequest(
    uint256 starkKey,
    uint256 vaultId,
    uint256 quantizedAmount,
    bool premiumCost
  ) external;

  function forcedTradeRequest(
    uint256 starkKeyA,
    uint256 starkKeyB,
    uint256 vaultIdA,
    uint256 vaultIdB,
    uint256 collateralAssetId,
    uint256 syntheticAssetId,
    uint256 amountCollateral,
    uint256 amountSynthetic,
    bool aIsBuyingSynthetic,
    uint256 submissionExpirationTime,
    uint256 nonce,
    bytes calldata signature,
    bool premiumCost
  ) external;

  function mainAcceptGovernance() external;
  function proxyAcceptGovernance() external;

  function mainRemoveGovernor(address governorForRemoval) external;
  function proxyRemoveGovernor(address governorForRemoval) external;

  function registerAssetConfigurationChange(uint256 assetId, bytes32 configHash) external;
  function applyAssetConfigurationChange(uint256 assetId, bytes32 configHash) external;

  function registerGlobalConfigurationChange(bytes32 configHash) external;
  function applyGlobalConfigurationChange(bytes32 configHash) external;

  function getEthKey(uint256 starkKey) external view returns (address);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "evmVersion": "istanbul",
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}
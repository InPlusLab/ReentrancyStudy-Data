/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

interface IProposalExecutor {
  function execute() external;
}

interface IProxyWithAdminActions {
  event AdminChanged(address previousAdmin, address newAdmin);

  function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

  function upgradeTo(address newImplementation) external payable;

  function changeAdmin(address newAdmin) external;
}

interface IAaveTokenV2 {
  function initialize() external;
}

interface IStkAaveV2 {
  function initialize() external;
}

interface ILendingPoolAddressesProvider {
  event LendingPoolUpdated(address indexed newAddress);
  event LendingPoolCoreUpdated(address indexed newAddress);
  event LendingPoolParametersProviderUpdated(address indexed newAddress);
  event LendingPoolManagerUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolLiquidationManagerUpdated(address indexed newAddress);
  event LendingPoolDataProviderUpdated(address indexed newAddress);
  event EthereumAddressUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event FeeProviderUpdated(address indexed newAddress);
  event TokenDistributorUpdated(address indexed newAddress);

  event ProxyCreated(bytes32 id, address indexed newAddress);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address _pool) external;

  function getLendingPoolCore() external view returns (address payable);

  function setLendingPoolCoreImpl(address _lendingPoolCore) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address _configurator) external;

  function getLendingPoolDataProvider() external view returns (address);

  function setLendingPoolDataProviderImpl(address _provider) external;

  function getLendingPoolParametersProvider() external view returns (address);

  function setLendingPoolParametersProviderImpl(address _parametersProvider) external;

  function getTokenDistributor() external view returns (address);

  function setTokenDistributor(address _tokenDistributor) external;

  function getFeeProvider() external view returns (address);

  function setFeeProviderImpl(address _feeProvider) external;

  function getLendingPoolLiquidationManager() external view returns (address);

  function setLendingPoolLiquidationManager(address _manager) external;

  function getLendingPoolManager() external view returns (address);

  function setLendingPoolManager(address _lendingPoolManager) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address _priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address _lendingRateOracle) external;
}

interface IOwnable {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function transferOwnership(address newOwner) external;

  function owner() external view returns (address);
}

/**
 * @title GovernanceV2ProposalPayload
 * @notice Proposal payload to be executed by the Aave Governance contract via DELEGATECALL
 * - Upgrade implementations of AAVE and stkAAVE, to include proposition/voting delegation
 * - Transfer all permissions from the Aave governance v1 to the Aave governance v2, with
 *   granularity per Executor contracts (short and long)
 * @author Aave
 **/
contract GovernanceV2ProposalPayload is IProposalExecutor {
  event ProposalExecuted();

  address public immutable AAVE_TOKEN_PROXY;
  address public immutable AAVE_TOKEN_NEW_IMPL;
  address public immutable STKAAVE_PROXY;
  address public immutable STKAAVE_NEW_IMPL;
  address public immutable RESERVE_ECOSYSTEM_PROXY;
  address public immutable ADDRESSES_PROVIDER_V1_PROTO;
  address public immutable ADDRESSES_PROVIDER_V1_UNISWAP;
  address public immutable TOKEN_DISTRIBUTOR_PROXY;
  address public immutable FEES_COLLECTOR;
  address public immutable SHORT_EXECUTOR_V2;
  address public immutable LONG_EXECUTOR_V2;

  constructor(
    address aaveTokenProxy,
    address aaveTokenNewImpl,
    address stkAaveProxy,
    address stkAaveNewImpl,
    address reserveEcosystemProxy,
    address addressesProviderV1Proto,
    address addressesProviderV1Uniswap,
    address tokenDistributorProxy,
    address feesCollector,
    address shortExecutor,
    address longExecutor
  ) public {
    AAVE_TOKEN_PROXY = aaveTokenProxy;
    AAVE_TOKEN_NEW_IMPL = aaveTokenNewImpl;
    STKAAVE_PROXY = stkAaveProxy;
    STKAAVE_NEW_IMPL = stkAaveNewImpl;
    RESERVE_ECOSYSTEM_PROXY = reserveEcosystemProxy;
    ADDRESSES_PROVIDER_V1_PROTO = addressesProviderV1Proto;
    ADDRESSES_PROVIDER_V1_UNISWAP = addressesProviderV1Uniswap;
    TOKEN_DISTRIBUTOR_PROXY = tokenDistributorProxy;
    FEES_COLLECTOR = feesCollector;
    SHORT_EXECUTOR_V2 = shortExecutor;
    LONG_EXECUTOR_V2 = longExecutor;
  }

  /**
   * @dev Payload execution function, called once a proposal passed in the Aave governance
   */
  function execute() external override {
    bytes memory aaveTokenParams =
      abi.encodeWithSelector(IAaveTokenV2(AAVE_TOKEN_NEW_IMPL).initialize.selector);

    IProxyWithAdminActions(AAVE_TOKEN_PROXY).upgradeToAndCall(AAVE_TOKEN_NEW_IMPL, aaveTokenParams);

    IProxyWithAdminActions(AAVE_TOKEN_PROXY).changeAdmin(LONG_EXECUTOR_V2);

    bytes memory stkAaveParams =
      abi.encodeWithSelector(IStkAaveV2(STKAAVE_NEW_IMPL).initialize.selector);

    IProxyWithAdminActions(STKAAVE_PROXY).upgradeToAndCall(STKAAVE_NEW_IMPL, stkAaveParams);

    IProxyWithAdminActions(STKAAVE_PROXY).changeAdmin(LONG_EXECUTOR_V2);

    ILendingPoolAddressesProvider(ADDRESSES_PROVIDER_V1_PROTO).setLendingPoolManager(
      SHORT_EXECUTOR_V2
    );
    IOwnable(ADDRESSES_PROVIDER_V1_PROTO).transferOwnership(SHORT_EXECUTOR_V2);

    ILendingPoolAddressesProvider(ADDRESSES_PROVIDER_V1_UNISWAP).setLendingPoolManager(
      SHORT_EXECUTOR_V2
    );
    IOwnable(ADDRESSES_PROVIDER_V1_UNISWAP).transferOwnership(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(TOKEN_DISTRIBUTOR_PROXY).changeAdmin(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(FEES_COLLECTOR).changeAdmin(SHORT_EXECUTOR_V2);

    IProxyWithAdminActions(RESERVE_ECOSYSTEM_PROXY).changeAdmin(SHORT_EXECUTOR_V2);

    emit ProposalExecuted();
  }
}
/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


interface IProposalExecutor {
    function execute() external;
}

/**
 * @title AIP3ProposalPayload
 * @notice Proposal payload to be executed by the Aave Governance contract via DELEGATECALL
 * - Updates the LendingPool contract as defined by the AIP-3 
 * @author Aave
 **/
contract AIP3ProposalPayload is IProposalExecutor {
  event ProposalExecuted();

  ILendingPoolAddressesProvider public constant ADDRESSES_PROVIDER = ILendingPoolAddressesProvider(
    0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
  );

  address public constant POOL_IMPL =  0x017788DDEd30FDd859d295b90D4e41a19393F423;

  /**
   * @dev Payload execution function, called once a proposal passed in the Aave governance
   */
  function execute() external override {

    ADDRESSES_PROVIDER.setLendingPoolImpl(POOL_IMPL);

    emit ProposalExecuted();
  }
}
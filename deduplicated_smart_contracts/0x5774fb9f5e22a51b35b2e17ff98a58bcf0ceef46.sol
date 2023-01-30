// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ModuleMapConsumer.sol";
import "../interfaces/IKernel.sol";

abstract contract Controlled is Initializable, ModuleMapConsumer {
  // controller address => is a controller
  mapping(address => bool) internal _controllers;
  address[] public controllers;

  function __Controlled_init(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    for (uint256 i; i < controllers_.length; i++) {
      _controllers[controllers_[i]] = true;
    }
    controllers = controllers_;
    __ModuleMapConsumer_init(moduleMap_);
  }

  function addController(address controller) external onlyOwner {
    _controllers[controller] = true;
    bool added;
    for (uint256 i; i < controllers.length; i++) {
      if (controller == controllers[i]) {
        added = true;
      }
    }
    if (!added) {
      controllers.push(controller);
    }
  }

  modifier onlyOwner() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),
      "Controlled::onlyOwner: Caller is not owner"
    );
    _;
  }

  modifier onlyManager() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),
      "Controlled::onlyManager: Caller is not manager"
    );
    _;
  }

  modifier onlyController() {
    require(
      _controllers[msg.sender],
      "Controlled::onlyController: Caller is not controller"
    );
    _;
  }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

import "../interfaces/IEtherRewards.sol";
import "../interfaces/IIntegrationMap.sol";
import "../interfaces/IStrategyMap.sol";
import "./Controlled.sol";
import "./ModuleMapConsumer.sol";

contract EtherRewards is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IEtherRewards
{
  /// @param controllers_ The array of controllers for this contract
  /// @param moduleMap_ The address of the ModuleMap contract
  function initialize(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
  }

  uint256 private totalEthRewards;
  uint256 private totalClaimedEthRewards;
  mapping(address => uint256) private totalUserClaimedEthRewards;
  mapping(address => uint256) private tokenRewardRate;
  mapping(address => uint256) private tokenEthRewards;
  mapping(address => mapping(address => uint256)) private userTokenRewardRate;
  mapping(address => mapping(address => uint256))
    private userTokenAccumulatedRewards;

  /// @param token The address of the token ERC20 contract
  /// @param user The address of the user
  function updateUserRewards(address token, address user)
    public
    override
    onlyController
  {
    uint256 userTokenDeposits = IStrategyMap(
      moduleMap.getModuleAddress(Modules.StrategyMap)
    ).getUserInvestedAmountByToken(token, user);

    userTokenAccumulatedRewards[token][user] +=
      ((tokenRewardRate[token] - userTokenRewardRate[token][user]) *
        userTokenDeposits) /
      10**18;

    userTokenRewardRate[token][user] = tokenRewardRate[token];
  }

  /// @param token The address of the token ERC20 contract
  /// @param ethRewardsAmount The amount of Ether rewards to add
  function increaseEthRewards(address token, uint256 ethRewardsAmount)
    external
    override
    onlyController
  {
    uint256 tokenTotalDeposits = IStrategyMap(
      moduleMap.getModuleAddress(Modules.StrategyMap)
    ).getTokenTotalBalance(token);
    require(
      tokenTotalDeposits > 0,
      "EtherRewards::increaseEthRewards: Token has not been deposited yet"
    );

    totalEthRewards += ethRewardsAmount;
    tokenEthRewards[token] += ethRewardsAmount;
    tokenRewardRate[token] += (ethRewardsAmount * 10**18) / tokenTotalDeposits;
  }

  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function claimEthRewards(address user)
    external
    override
    onlyController
    returns (uint256 ethRewards)
  {
    address integrationMap = moduleMap.getModuleAddress(Modules.IntegrationMap);
    uint256 tokenCount = IIntegrationMap(integrationMap)
      .getTokenAddressesLength();

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      address token = IIntegrationMap(integrationMap).getTokenAddress(tokenId);
      ethRewards += claimTokenEthRewards(token, user);
    }
  }

  /// @param token The address of the token ERC20 contract
  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function claimTokenEthRewards(address token, address user)
    private
    returns (uint256 ethRewards)
  {
    updateUserRewards(token, user);
    ethRewards = userTokenAccumulatedRewards[token][user];

    userTokenAccumulatedRewards[token][user] = 0;
    tokenEthRewards[token] -= ethRewards;
    totalEthRewards -= ethRewards;
    totalClaimedEthRewards += ethRewards;
    totalUserClaimedEthRewards[user] += ethRewards;
  }

  /// @param token The address of the token ERC20 contract
  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function getUserTokenEthRewards(address token, address user)
    public
    view
    override
    returns (uint256 ethRewards)
  {
    uint256 userTokenDeposits = IStrategyMap(
      moduleMap.getModuleAddress(Modules.StrategyMap)
    ).getUserInvestedAmountByToken(token, user);

    ethRewards =
      userTokenAccumulatedRewards[token][user] +
      ((tokenRewardRate[token] - userTokenRewardRate[token][user]) *
        userTokenDeposits) /
      10**18;
  }

  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function getUserEthRewards(address user)
    external
    view
    override
    returns (uint256 ethRewards)
  {
    address integrationMap = moduleMap.getModuleAddress(Modules.IntegrationMap);
    uint256 tokenCount = IIntegrationMap(integrationMap)
      .getTokenAddressesLength();

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      address token = IIntegrationMap(integrationMap).getTokenAddress(tokenId);
      ethRewards += getUserTokenEthRewards(token, user);
    }
  }

  /// @param token The address of the token ERC20 contract
  /// @return The amount of Ether rewards for the specified token
  function getTokenEthRewards(address token)
    external
    view
    override
    returns (uint256)
  {
    return tokenEthRewards[token];
  }

  /// @return The total value of ETH claimed by users
  function getTotalClaimedEthRewards()
    external
    view
    override
    returns (uint256)
  {
    return totalClaimedEthRewards;
  }

  /// @return The total value of ETH claimed by a user
  function getTotalUserClaimedEthRewards(address account)
    external
    view
    override
    returns (uint256)
  {
    return totalUserClaimedEthRewards[account];
  }

  /// @return The total amount of Ether rewards
  function getEthRewards() external view override returns (uint256) {
    return totalEthRewards;
  }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IModuleMap.sol";

abstract contract ModuleMapConsumer is Initializable {
  IModuleMap public moduleMap;

  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {
    moduleMap = IModuleMap(moduleMap_);
  }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

interface IEtherRewards {
  /// @param token The address of the token ERC20 contract
  /// @param user The address of the user
  function updateUserRewards(address token, address user) external;

  /// @param token The address of the token ERC20 contract
  /// @param ethRewardsAmount The amount of Ether rewards to add
  function increaseEthRewards(address token, uint256 ethRewardsAmount) external;

  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function claimEthRewards(address user) external returns (uint256 ethRewards);

  /// @param token The address of the token ERC20 contract
  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function getUserTokenEthRewards(address token, address user)
    external
    view
    returns (uint256 ethRewards);

  /// @param user The address of the user
  /// @return ethRewards The amount of Ether claimed
  function getUserEthRewards(address user)
    external
    view
    returns (uint256 ethRewards);

  /// @param token The address of the token ERC20 contract
  /// @return The amount of Ether rewards for the specified token
  function getTokenEthRewards(address token) external view returns (uint256);

  /// @return The total value of ETH claimed by users
  function getTotalClaimedEthRewards() external view returns (uint256);

  /// @return The total value of ETH claimed by a user
  function getTotalUserClaimedEthRewards(address user)
    external
    view
    returns (uint256);

  /// @return The total amount of Ether rewards
  function getEthRewards() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

interface IIntegration {
  /// @param tokenAddress The address of the deposited token
  /// @param amount The amount of the token being deposited
  function deposit(address tokenAddress, uint256 amount) external;

  /// @param tokenAddress The address of the withdrawal token
  /// @param amount The amount of the token to withdraw
  function withdraw(address tokenAddress, uint256 amount) external;

  /// @dev Deploys all tokens held in the integration contract to the integrated protocol
  function deploy() external;

  /// @dev Harvests token yield from the Aave lending pool
  function harvestYield() external;

  /// @dev This returns the total amount of the underlying token that
  /// @dev has been deposited to the integration contract
  /// @param tokenAddress The address of the deployed token
  /// @return The amount of the underlying token that can be withdrawn
  function getBalance(address tokenAddress) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

interface IIntegrationMap {
  struct Integration {
    bool added;
    string name;
  }

  struct Token {
    uint256 id;
    bool added;
    bool acceptingDeposits;
    bool acceptingWithdrawals;
    uint256 biosRewardWeight;
    uint256 reserveRatioNumerator;
  }

  /// @param contractAddress The address of the integration contract
  /// @param name The name of the protocol being integrated to
  function addIntegration(address contractAddress, string memory name) external;

  /// @param tokenAddress The address of the ERC20 token contract
  /// @param acceptingDeposits Whether token deposits are enabled
  /// @param acceptingWithdrawals Whether token withdrawals are enabled
  /// @param biosRewardWeight Token weight for BIOS rewards
  /// @param reserveRatioNumerator Number that gets divided by reserve ratio denominator to get reserve ratio
  function addToken(
    address tokenAddress,
    bool acceptingDeposits,
    bool acceptingWithdrawals,
    uint256 biosRewardWeight,
    uint256 reserveRatioNumerator
  ) external;

  /// @param tokenAddress The address of the token ERC20 contract
  function enableTokenDeposits(address tokenAddress) external;

  /// @param tokenAddress The address of the token ERC20 contract
  function disableTokenDeposits(address tokenAddress) external;

  /// @param tokenAddress The address of the token ERC20 contract
  function enableTokenWithdrawals(address tokenAddress) external;

  /// @param tokenAddress The address of the token ERC20 contract
  function disableTokenWithdrawals(address tokenAddress) external;

  /// @param tokenAddress The address of the token ERC20 contract
  /// @param rewardWeight The updated token BIOS reward weight
  function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)
    external;

  /// @param tokenAddress the address of the token ERC20 contract
  /// @param reserveRatioNumerator Number that gets divided by reserve ratio denominator to get reserve ratio
  function updateTokenReserveRatioNumerator(
    address tokenAddress,
    uint256 reserveRatioNumerator
  ) external;

  /// @param integrationId The ID of the integration
  /// @return The address of the integration contract
  function getIntegrationAddress(uint256 integrationId)
    external
    view
    returns (address);

  /// @param integrationAddress The address of the integration contract
  /// @return The name of the of the protocol being integrated to
  function getIntegrationName(address integrationAddress)
    external
    view
    returns (string memory);

  /// @return The address of the WETH token
  function getWethTokenAddress() external view returns (address);

  /// @return The address of the BIOS token
  function getBiosTokenAddress() external view returns (address);

  /// @param tokenId The ID of the token
  /// @return The address of the token ERC20 contract
  function getTokenAddress(uint256 tokenId) external view returns (address);

  /// @param tokenAddress The address of the token ERC20 contract
  /// @return The index of the token in the tokens array
  function getTokenId(address tokenAddress) external view returns (uint256);

  /// @param tokenAddress The address of the token ERC20 contract
  /// @return The token BIOS reward weight
  function getTokenBiosRewardWeight(address tokenAddress)
    external
    view
    returns (uint256);

  /// @return rewardWeightSum reward weight of depositable tokens
  function getBiosRewardWeightSum()
    external
    view
    returns (uint256 rewardWeightSum);

  /// @param tokenAddress The address of the token ERC20 contract
  /// @return bool indicating whether depositing this token is currently enabled
  function getTokenAcceptingDeposits(address tokenAddress)
    external
    view
    returns (bool);

  /// @param tokenAddress The address of the token ERC20 contract
  /// @return bool indicating whether withdrawing this token is currently enabled
  function getTokenAcceptingWithdrawals(address tokenAddress)
    external
    view
    returns (bool);

  // @param tokenAddress The address of the token ERC20 contract
  // @return bool indicating whether the token has been added
  function getIsTokenAdded(address tokenAddress) external view returns (bool);

  // @param integrationAddress The address of the integration contract
  // @return bool indicating whether the integration has been added
  function getIsIntegrationAdded(address tokenAddress)
    external
    view
    returns (bool);

  /// @notice get the length of supported tokens
  /// @return The quantity of tokens added
  function getTokenAddressesLength() external view returns (uint256);

  /// @notice get the length of supported integrations
  /// @return The quantity of integrations added
  function getIntegrationAddressesLength() external view returns (uint256);

  /// @param tokenAddress The address of the token ERC20 contract
  /// @return The value that gets divided by the reserve ratio denominator
  function getTokenReserveRatioNumerator(address tokenAddress)
    external
    view
    returns (uint256);

  /// @return The token reserve ratio denominator
  function getReserveRatioDenominator() external view returns (uint32);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

interface IKernel {
  /// @param account The address of the account to check if they are a manager
  /// @return Bool indicating whether the account is a manger
  function isManager(address account) external view returns (bool);

  /// @param account The address of the account to check if they are an owner
  /// @return Bool indicating whether the account is an owner
  function isOwner(address account) external view returns (bool);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

enum Modules {
  Kernel, // 0
  UserPositions, // 1
  YieldManager, // 2
  IntegrationMap, // 3
  BiosRewards, // 4
  EtherRewards, // 5
  SushiSwapTrader, // 6
  UniswapTrader, // 7
  StrategyMap, // 8
  StrategyManager // 9
}

interface IModuleMap {
  function getModuleAddress(Modules key) external view returns (address);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;
import "../interfaces/IIntegration.sol";

interface IStrategyMap {
  // #### Structs
  struct WeightedIntegration {
    address integration;
    uint256 weight;
  }

  struct Strategy {
    string name;
    uint256 totalStrategyWeight;
    mapping(address => bool) enabledTokens;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategySummary {
    string name;
    uint256 totalStrategyWeight;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategyTransaction {
    uint256 amount;
    address token;
  }

  // #### Events
  event NewStrategy(
    uint256 indexed id,
    string name,
    WeightedIntegration[] integrations,
    address[] tokens
  );
  event UpdateName(uint256 indexed id, string name);
  event UpdateIntegrations(
    uint256 indexed id,
    WeightedIntegration[] integrations
  );
  event UpdateTokens(uint256 indexed id, address[] tokens);
  event DeleteStrategy(
    uint256 indexed id,
    string name,
    address[] tokens,
    WeightedIntegration[] integrations
  );

  event EnterStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );
  event ExitStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );

  // #### Functions
  /**
     @notice Adds a new strategy to the list of available strategies
     @param name  the name of the new strategy
     @param integrations  the integrations and weights that form the strategy
     */
  function addStrategy(
    string calldata name,
    WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external;

  /**
    @notice Updates the strategy name
    @param name  the new name
     */
  function updateName(uint256 id, string calldata name) external;

  /**
  @notice Updates a strategy's accepted tokens
  @param id  The strategy ID
  @param tokens  The new tokens to allow
  */
  function updateTokens(uint256 id, address[] calldata tokens) external;

  /**
    @notice Updates the strategy integrations 
    @param integrations  the new integrations
     */
  function updateIntegrations(
    uint256 id,
    WeightedIntegration[] memory integrations
  ) external;

  /**
    @notice Deletes a strategy
    @dev This can only be called successfully if the strategy being deleted doesn't have any assets invested in it
    @param id  the strategy to delete
     */
  function deleteStrategy(uint256 id) external;

  /**
    @notice Increases the amount of a set of tokens in a strategy
    @param id  the strategy to deposit into
    @param tokens  the tokens to deposit
    @param amounts  The amounts to be deposited
     */
  function enterStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Decreases the amount of a set of tokens invested in a strategy
    @param id  the strategy to withdraw assets from
    @param tokens  the tokens to withdraw
    @param amounts  The amounts to be withdrawn
     */
  function exitStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Getter function to return the nested arrays as well as the name
    @param id  the strategy to return
     */
  function getStrategy(uint256 id)
    external
    view
    returns (StrategySummary memory);

  /**
    @notice Returns the expected balance of a given token in a given integration
    @param integration  the integration the amount should be invested in
    @param token  the token that is being invested
    @return balance  the balance of the token that should be currently invested in the integration 
     */
  function getExpectedBalance(address integration, address token)
    external
    view
    returns (uint256 balance);

  /**
    @notice Returns the amount of a given token currently invested in a strategy
    @param id  the strategy id to check
    @param token  The token to retrieve the balance for
    @return amount  the amount of token that is invested in the strategy
     */
  function getStrategyTokenBalance(uint256 id, address token)
    external
    view
    returns (uint256 amount);

  /**
    @notice returns the amount of a given token a user has invested in a given strategy
    @param id  the strategy id
    @param token  the token address
    @param user  the user who holds the funds
    @return amount  the amount of token that the user has invested in the strategy 
     */
  function getUserStrategyBalanceByToken(
    uint256 id,
    address token,
    address user
  ) external view returns (uint256 amount);

  /**
    @notice Returns the amount of a given token that a user has invested across all strategies
    @param token  the token address
    @param user  the user holding the funds
    @return amount  the amount of tokens the user has invested across all strategies
     */
  function getUserInvestedAmountByToken(address token, address user)
    external
    view
    returns (uint256 amount);

  /**
    @notice Returns the total amount of a token invested across all strategies
    @param token  the token to fetch the balance for
    @return amount  the amount of the token currently invested
    */
  function getTokenTotalBalance(address token)
    external
    view
    returns (uint256 amount);

  /**
  @notice Returns the weight of an individual integration within the system
  @param integration  the integration to look up
  @return The weight of the integration
   */
  function getIntegrationWeight(address integration)
    external
    view
    returns (uint256);

  /**
  @notice Returns the sum of all weights in the system.
  @return The sum of all integration weights within the system
   */
  function getIntegrationWeightSum() external view returns (uint256);

  /// @notice autogenerated getter definition
  function idCounter() external view returns(uint256);
}
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "../interfaces/IBiosRewards.sol";
import "../interfaces/IUserPositions.sol";
import "../interfaces/IIntegrationMap.sol";
import "./Controlled.sol";
import "./ModuleMapConsumer.sol";

contract BiosRewards is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IBiosRewards
{
  uint256 private totalBiosRewards;
  uint256 private totalClaimedBiosRewards;
  mapping(address => uint256) private totalUserClaimedBiosRewards;
  mapping(address => uint256) public periodFinish;
  mapping(address => uint256) public rewardRate;
  mapping(address => uint256) public lastUpdateTime;
  mapping(address => uint256) public rewardPerTokenStored;
  mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
  mapping(address => mapping(address => uint256)) public rewards;

  event RewardAdded(address indexed token, uint256 reward, uint32 duration);

  function initialize(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
  }

  modifier updateReward(address token, address account) {
    rewardPerTokenStored[token] = rewardPerToken(token);
    lastUpdateTime[token] = lastTimeRewardApplicable(token);
    if (account != address(0)) {
      rewards[token][account] = earned(token, account);
      userRewardPerTokenPaid[token][account] = rewardPerTokenStored[token];
    }
    _;
  }

  /// @param token The address of the ERC20 token contract
  /// @param reward The updated reward amount
  /// @param duration The duration of the rewards period
  function notifyRewardAmount(
    address token,
    uint256 reward,
    uint32 duration
  ) external override onlyController updateReward(token, address(0)) {
    if (block.timestamp >= periodFinish[token]) {
      rewardRate[token] = reward / duration;
    } else {
      uint256 remaining = periodFinish[token] - block.timestamp;
      uint256 leftover = remaining * rewardRate[token];
      rewardRate[token] = (reward + leftover) / duration;
    }
    lastUpdateTime[token] = block.timestamp;
    periodFinish[token] = block.timestamp + duration;
    totalBiosRewards += reward;
    emit RewardAdded(token, reward, duration);
  }

  function increaseRewards(
    address token,
    address account,
    uint256 amount
  ) public override onlyController updateReward(token, account) {
    require(amount > 0, "BiosRewards::increaseRewards: Cannot increase 0");
  }

  function decreaseRewards(
    address token,
    address account,
    uint256 amount
  ) public override onlyController updateReward(token, account) {
    require(amount > 0, "BiosRewards::decreaseRewards: Cannot decrease 0");
  }

  function claimReward(address token, address account)
    public
    override
    onlyController
    updateReward(token, account)
    returns (uint256 reward)
  {
    reward = earned(token, account);
    if (reward > 0) {
      rewards[token][account] = 0;
      totalBiosRewards -= reward;
      totalClaimedBiosRewards += reward;
      totalUserClaimedBiosRewards[account] += reward;
    }
    return reward;
  }

  function lastTimeRewardApplicable(address token)
    public
    view
    override
    returns (uint256)
  {
    return MathUpgradeable.min(block.timestamp, periodFinish[token]);
  }

  function rewardPerToken(address token)
    public
    view
    override
    returns (uint256)
  {
    uint256 totalSupply = IUserPositions(
      moduleMap.getModuleAddress(Modules.UserPositions)
    ).totalTokenBalance(token);
    if (totalSupply == 0) {
      return rewardPerTokenStored[token];
    }
    return
      rewardPerTokenStored[token] +
      (((lastTimeRewardApplicable(token) - lastUpdateTime[token]) *
        rewardRate[token] *
        1e18) / totalSupply);
  }

  function earned(address token, address account)
    public
    view
    override
    returns (uint256)
  {
    IUserPositions userPositions = IUserPositions(
      moduleMap.getModuleAddress(Modules.UserPositions)
    );
    return
      ((userPositions.userTokenBalance(token, account) *
        (rewardPerToken(token) - userRewardPerTokenPaid[token][account])) /
        1e18) + rewards[token][account];
  }

  function getUserBiosRewards(address account)
    external
    view
    override
    returns (uint256 userBiosRewards)
  {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );

    for (
      uint256 tokenId;
      tokenId < integrationMap.getTokenAddressesLength();
      tokenId++
    ) {
      userBiosRewards += earned(
        integrationMap.getTokenAddress(tokenId),
        account
      );
    }
  }

  function getTotalClaimedBiosRewards()
    external
    view
    override
    returns (uint256)
  {
    return totalClaimedBiosRewards;
  }

  function getTotalUserClaimedBiosRewards(address account)
    external
    view
    override
    returns (uint256)
  {
    return totalUserClaimedBiosRewards[account];
  }

  function getBiosRewards() external view override returns (uint256) {
    return totalBiosRewards;
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

interface IBiosRewards {
  /// @param token The address of the ERC20 token contract
  /// @param reward The updated reward amount
  /// @param duration The duration of the rewards period
  function notifyRewardAmount(
    address token,
    uint256 reward,
    uint32 duration
  ) external;

  function increaseRewards(
    address token,
    address account,
    uint256 amount
  ) external;

  function decreaseRewards(
    address token,
    address account,
    uint256 amount
  ) external;

  function claimReward(address asset, address account)
    external
    returns (uint256 reward);

  function lastTimeRewardApplicable(address token)
    external
    view
    returns (uint256);

  function rewardPerToken(address token) external view returns (uint256);

  function earned(address token, address account)
    external
    view
    returns (uint256);

  function getUserBiosRewards(address account)
    external
    view
    returns (uint256 userBiosRewards);

  function getTotalClaimedBiosRewards() external view returns (uint256);

  function getTotalUserClaimedBiosRewards(address account)
    external
    view
    returns (uint256);

  function getBiosRewards() external view returns (uint256);
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

interface IUserPositions {
  /// @param biosRewardsDuration_ The duration in seconds for a BIOS rewards period to last
  function setBiosRewardsDuration(uint32 biosRewardsDuration_) external;

  /// @param sender The account seeding BIOS rewards
  /// @param biosAmount The amount of BIOS to add to rewards
  function seedBiosRewards(address sender, uint256 biosAmount) external;

  /// @notice Sends all BIOS available in the Kernel to each token BIOS rewards pool based up configured weights
  function increaseBiosRewards() external;

  /// @notice User is allowed to deposit whitelisted tokens
  /// @param depositor Address of the account depositing
  /// @param tokens Array of token the token addresses
  /// @param amounts Array of token amounts
  /// @param ethAmount The amount of ETH sent with the deposit
  function deposit(
    address depositor,
    address[] memory tokens,
    uint256[] memory amounts,
    uint256 ethAmount
  ) external;

  /// @notice User is allowed to withdraw tokens
  /// @param recipient The address of the user withdrawing
  /// @param tokens Array of token the token addresses
  /// @param amounts Array of token amounts
  /// @param withdrawWethAsEth Boolean indicating whether should receive WETH balance as ETH
  function withdraw(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bool withdrawWethAsEth
  ) external returns (uint256 ethWithdrawn);

  /// @notice Allows a user to withdraw entire balances of the specified tokens and claim rewards
  /// @param recipient The address of the user withdrawing tokens
  /// @param tokens Array of token address that user is exiting positions from
  /// @param withdrawWethAsEth Boolean indicating whether should receive WETH balance as ETH
  /// @return tokenAmounts The amounts of each token being withdrawn
  /// @return ethWithdrawn The amount of ETH being withdrawn
  /// @return ethClaimed The amount of ETH being claimed from rewards
  /// @return biosClaimed The amount of BIOS being claimed from rewards
  function withdrawAllAndClaim(
    address recipient,
    address[] memory tokens,
    bool withdrawWethAsEth
  )
    external
    returns (
      uint256[] memory tokenAmounts,
      uint256 ethWithdrawn,
      uint256 ethClaimed,
      uint256 biosClaimed
    );

  /// @param user The address of the user claiming ETH rewards
  function claimEthRewards(address user) external returns (uint256 ethClaimed);

  /// @notice Allows users to claim their BIOS rewards for each token
  /// @param recipient The address of the usuer claiming BIOS rewards
  function claimBiosRewards(address recipient)
    external
    returns (uint256 biosClaimed);

  /// @param asset Address of the ERC20 token contract
  /// @return The total balance of the asset deposited in the system
  function totalTokenBalance(address asset) external view returns (uint256);

  /// @param asset Address of the ERC20 token contract
  /// @param account Address of the user account
  function userTokenBalance(address asset, address account)
    external
    view
    returns (uint256);

  /// @return The Bios Rewards Duration
  function getBiosRewardsDuration() external view returns (uint32);

  /// @notice Transfers tokens to the StrategyMap
  /// @dev This is a ledger adjustment. The tokens remain in the kernel.
  /// @param recipient  The user to transfer funds for
  /// @param tokens  the tokens to be moved
  /// @param amounts  the amounts of each token to move
  function transferToStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;

  /// @notice Transfers tokens from the StrategyMap
  /// @dev This is a ledger adjustment. The tokens remain in the kernel.
  /// @param recipient  The user to transfer funds for
  /// @param tokens  the tokens to be moved
  /// @param amounts  the amounts of each token to move
  function transferFromStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;
}
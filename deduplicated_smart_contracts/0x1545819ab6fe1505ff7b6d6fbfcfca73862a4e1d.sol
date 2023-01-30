/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// 
/******************
@title WadRayMath library
@author Aave
@dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 */
library WadRayMath {
  using SafeMath for uint256;

  uint256 internal constant WAD = 1e18;
  uint256 internal constant halfWAD = WAD / 2;

  uint256 internal constant RAY = 1e27;
  uint256 internal constant halfRAY = RAY / 2;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {
    return RAY;
  }

  function wad() internal pure returns (uint256) {
    return WAD;
  }

  function halfRay() internal pure returns (uint256) {
    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {
    return halfWAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {
    return halfWAD.add(a.mul(b)).div(WAD);
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 halfB = b / 2;

    return halfB.add(a.mul(WAD)).div(b);
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
    return halfRAY.add(a.mul(b)).div(RAY);
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 halfB = b / 2;

    return halfB.add(a.mul(RAY)).div(b);
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {
    uint256 halfRatio = WAD_RAY_RATIO / 2;

    return halfRatio.add(a).div(WAD_RAY_RATIO);
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {
    return a.mul(WAD_RAY_RATIO);
  }

  /**
   * @dev calculates x^n, in ray. The code uses the ModExp precompile
   * @param x base
   * @param n exponent
   * @return z = x^n, in ray
   */
  function rayPow(uint256 x, uint256 n) internal pure returns (uint256 z) {
    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rayMul(x, x);

      if (n % 2 != 0) {
        z = rayMul(z, x);
      }
    }
  }
}

// 
interface IVaultsCore {
  event Opened(uint256 indexed vaultId, address indexed collateralType, address indexed owner);
  event Deposited(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Withdrawn(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Borrowed(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Repaid(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Liquidated(
    uint256 indexed vaultId,
    uint256 debtRepaid,
    uint256 collateralLiquidated,
    address indexed owner,
    address indexed sender
  );

  event CumulativeRateUpdated(
    address indexed collateralType,
    uint256 elapsedTime,
    uint256 newCumulativeRate
  ); //cumulative interest rate from deployment time T0

  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);

  function a() external view returns (IAddressProvider);

  function deposit(address _collateralType, uint256 _amount) external;

  function withdraw(uint256 _vaultId, uint256 _amount) external;

  function withdrawAll(uint256 _vaultId) external;

  function borrow(uint256 _vaultId, uint256 _amount) external;

  function repayAll(uint256 _vaultId) external;

  function repay(uint256 _vaultId, uint256 _amount) external;

  function liquidate(uint256 _vaultId) external;

  //Read only

  function availableIncome() external view returns (uint256);

  function cumulativeRates(address _collateralType) external view returns (uint256);

  function lastRefresh(address _collateralType) external view returns (uint256);

  //Refresh
  function initializeRates(address _collateralType) external;

  function refresh() external;

  function refreshCollateral(address collateralType) external;

  //upgrade
  function upgrade(address _newVaultsCore) external;
}

// 
interface IAccessController {
  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  function MANAGER_ROLE() external view returns (bytes32);

  function MINTER_ROLE() external view returns (bytes32);

  function hasRole(bytes32 role, address account) external view returns (bool);

  function getRoleMemberCount(bytes32 role) external view returns (uint256);

  function getRoleMember(bytes32 role, uint256 index) external view returns (address);

  function getRoleAdmin(bytes32 role) external view returns (bytes32);

  function grantRole(bytes32 role, address account) external;

  function revokeRole(bytes32 role, address account) external;

  function renounceRole(bytes32 role, address account) external;
}

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// 
interface ISTABLEX is IERC20 {
  function a() external view returns (IAddressProvider);

  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;
}

// 
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// 
interface IPriceFeed {
  event OracleUpdated(address indexed asset, address oracle);

  function a() external view returns (IAddressProvider);

  function setAssetOracle(address _asset, address _oracle) external;

  function assetOracles(address _asset) external view returns (AggregatorV3Interface);

  function getAssetPrice(address _asset) external view returns (uint256);

  function convertFrom(address _asset, uint256 _balance) external view returns (uint256);

  function convertTo(address _asset, uint256 _balance) external view returns (uint256);
}

// 
interface IRatesManager {
  function a() external view returns (IAddressProvider);

  //current annualized borrow rate
  function annualizedBorrowRate(uint256 _currentBorrowRate) external pure returns (uint256);

  //uses current cumulative rate to calculate totalDebt based on baseDebt at time T0
  function calculateDebt(uint256 _baseDebt, uint256 _cumulativeRate) external pure returns (uint256);

  //uses current cumulative rate to calculate baseDebt at time T0
  function calculateBaseDebt(uint256 _debt, uint256 _cumulativeRate) external pure returns (uint256);

  //calculate a new cumulative rate
  function calculateCumulativeRate(
    uint256 _borrowRate,
    uint256 _cumulativeRate,
    uint256 _timeElapsed
  ) external view returns (uint256);
}

// 
interface ILiquidationManager {
  function a() external view returns (IAddressProvider);

  function calculateHealthFactor(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (uint256 healthFactor);

  function liquidationBonus(uint256 _amount) external view returns (uint256 bonus);

  function applyLiquidationDiscount(uint256 _amount) external view returns (uint256 discountedAmount);

  function isHealthy(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (bool);
}

// 
interface IVaultsDataProvider {
  struct Vault {
    // borrowedType support USDX / PAR
    address collateralType;
    address owner;
    uint256 collateralBalance;
    uint256 baseDebt;
    uint256 createdAt;
  }

  function a() external view returns (IAddressProvider);

  // Read
  function baseDebt(address _collateralType) external view returns (uint256);

  function vaultCount() external view returns (uint256);

  function vaults(uint256 _id) external view returns (Vault memory);

  function vaultOwner(uint256 _id) external view returns (address);

  function vaultCollateralType(uint256 _id) external view returns (address);

  function vaultCollateralBalance(uint256 _id) external view returns (uint256);

  function vaultBaseDebt(uint256 _id) external view returns (uint256);

  function vaultId(address _collateralType, address _owner) external view returns (uint256);

  function vaultExists(uint256 _id) external view returns (bool);

  function vaultDebt(uint256 _vaultId) external view returns (uint256);

  function debt() external view returns (uint256);

  function collateralDebt(address _collateralType) external view returns (uint256);

  //Write
  function createVault(address _collateralType, address _owner) external returns (uint256);

  function setCollateralBalance(uint256 _id, uint256 _balance) external;

  function setBaseDebt(uint256 _id, uint256 _newBaseDebt) external;
}

// 
interface IFeeDistributor {
  event PayeeAdded(address indexed account, uint256 shares);
  event FeeReleased(uint256 income, uint256 releasedAt);

  function a() external view returns (IAddressProvider);

  function lastReleasedAt() external view returns (uint256);

  function getPayees() external view returns (address[] memory);

  function totalShares() external view returns (uint256);

  function shares(address payee) external view returns (uint256);

  function release() external;

  function changePayees(address[] memory _payees, uint256[] memory _shares) external;
}

// 
interface IAddressProvider {
  function controller() external view returns (IAccessController);

  function config() external view returns (IConfigProvider);

  function core() external view returns (IVaultsCore);

  function stablex() external view returns (ISTABLEX);

  function ratesManager() external view returns (IRatesManager);

  function priceFeed() external view returns (IPriceFeed);

  function liquidationManager() external view returns (ILiquidationManager);

  function vaultsData() external view returns (IVaultsDataProvider);

  function feeDistributor() external view returns (IFeeDistributor);

  function setAccessController(IAccessController _controller) external;

  function setConfigProvider(IConfigProvider _config) external;

  function setVaultsCore(IVaultsCore _core) external;

  function setStableX(ISTABLEX _stablex) external;

  function setRatesManager(IRatesManager _ratesManager) external;

  function setPriceFeed(IPriceFeed _priceFeed) external;

  function setLiquidationManager(ILiquidationManager _liquidationManager) external;

  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;

  function setFeeDistributor(IFeeDistributor _feeDistributor) external;
}

// 
interface IConfigProvider {
  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
  }

  function a() external view returns (IAddressProvider);

  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);

  function collateralIds(address _collateralType) external view returns (uint256);

  function numCollateralConfigs() external view returns (uint256);

  function liquidationBonus() external view returns (uint256);

  event CollateralUpdated(
    address indexed collateralType,
    uint256 debtLimit,
    uint256 minCollateralRatio,
    uint256 borrowRate,
    uint256 originationFee
  );
  event CollateralRemoved(address indexed collateralType);

  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee
  ) external;

  function removeCollateral(address _collateralType) external;

  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) external;

  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio) external;

  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) external;

  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) external;

  function setLiquidationBonus(uint256 _bonus) external;

  function collateralDebtLimit(address _collateralType) external view returns (uint256);

  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);

  function collateralBorrowRate(address _collateralType) external view returns (uint256);

  function collateralOriginationFee(address _collateralType) external view returns (uint256);
}

// 
contract ConfigProvider is IConfigProvider {
  IAddressProvider public override a;

  mapping(uint256 => CollateralConfig) private _collateralConfigs; //indexing starts at 1
  mapping(address => uint256) public override collateralIds;

  uint256 public override numCollateralConfigs;
  uint256 public override liquidationBonus = 5e16; // 5%

  constructor(IAddressProvider _addresses) public {
    a = _addresses;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender), "Caller is not a Manager");
    _;
  }

  /**
    Creates or overwrites an existing config for a collateral type
    @param _collateralType address of the collateral type
    @param _debtLimit the debt ceiling for the collateral type 
    @param _minCollateralRatio the minimum ratio to maintain to avoid liquidation
    @param _borrowRate the borrowing rate specified in 1 second interval in RAY accuracy.
    @param _originationFee an optional origination fee for newly created debt. Can be 0.
  */
  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee
  ) public override onlyManager {
    require(address(_collateralType) != address(0));
    if (collateralIds[_collateralType] == 0) {
      //new collateral
      a.core().initializeRates(_collateralType);
      CollateralConfig memory config = CollateralConfig({
        collateralType: _collateralType,
        debtLimit: _debtLimit,
        minCollateralRatio: _minCollateralRatio,
        borrowRate: _borrowRate,
        originationFee: _originationFee
      });

      numCollateralConfigs++;
      _collateralConfigs[numCollateralConfigs] = config;
      collateralIds[_collateralType] = numCollateralConfigs;
    } else {
      // Update collateral config
      a.core().refreshCollateral(_collateralType);
      uint256 id = collateralIds[_collateralType];

      _collateralConfigs[id].collateralType = _collateralType;
      _collateralConfigs[id].debtLimit = _debtLimit;
      _collateralConfigs[id].minCollateralRatio = _minCollateralRatio;
      _collateralConfigs[id].borrowRate = _borrowRate;
      _collateralConfigs[id].originationFee = _originationFee;
    }
    emit CollateralUpdated(_collateralType, _debtLimit, _minCollateralRatio, _borrowRate, _originationFee);
  }

  function emitUpdateEvent(address _collateralType) internal {
    emit CollateralUpdated(
      _collateralType,
      _collateralConfigs[collateralIds[_collateralType]].debtLimit,
      _collateralConfigs[collateralIds[_collateralType]].minCollateralRatio,
      _collateralConfigs[collateralIds[_collateralType]].borrowRate,
      _collateralConfigs[collateralIds[_collateralType]].originationFee
    );
  }

  /**
    Remove the config for a collateral type
    @param _collateralType address of the collateral type
  */
  function removeCollateral(address _collateralType) public override onlyManager {
    uint256 id = collateralIds[_collateralType];
    require(id != 0, "collateral does not exist");

    collateralIds[_collateralType] = 0;

    _collateralConfigs[id] = _collateralConfigs[numCollateralConfigs]; //move last entry forward
    collateralIds[_collateralConfigs[id].collateralType] = id; //update id for last entry
    delete _collateralConfigs[numCollateralConfigs];
    numCollateralConfigs--;

    emit CollateralRemoved(_collateralType);
  }

  /**
    Sets the debt limit for a collateral type
    @param _collateralType address of the collateral type
    @param _debtLimit the new debt limit
  */
  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) public override onlyManager {
    _collateralConfigs[collateralIds[_collateralType]].debtLimit = _debtLimit;
    emitUpdateEvent(_collateralType);
  }

  /**
    Sets the minimum collateralization ratio for a collateral type
    @dev this is the liquidation treshold under which a vault is considered open for liquidation.
    @param _collateralType address of the collateral type
    @param _minCollateralRatio the new minimum collateralization ratio
  */
  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio)
    public
    override
    onlyManager
  {
    _collateralConfigs[collateralIds[_collateralType]].minCollateralRatio = _minCollateralRatio;
    emitUpdateEvent(_collateralType);
  }

  /**
    Sets the borrowing rate for a collateral type
    @dev borrowing rate is specified for a 1 sec interval and accurancy is in RAY.
    @param _collateralType address of the collateral type
    @param _borrowRate the new borrowing rate for a 1 sec interval
  */
  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) public override onlyManager {
    a.core().refreshCollateral(_collateralType);
    _collateralConfigs[collateralIds[_collateralType]].borrowRate = _borrowRate;
    emitUpdateEvent(_collateralType);
  }

  /**
    Sets the origiation fee for a collateral type
    @dev this rate is applied as a one time fee for new borrowing and is specified in WAD
    @param _collateralType address of the collateral type
    @param _originationFee new origination fee in WAD
  */
  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) public override onlyManager {
    _collateralConfigs[collateralIds[_collateralType]].originationFee = _originationFee;
    emitUpdateEvent(_collateralType);
  }

  /**
    Get the debt limit for a collateral type
    @dev this is a platform wide limit for new debt issuance against a specific collateral type
    @param _collateralType address of the collateral type
  */
  function collateralDebtLimit(address _collateralType) public override view returns (uint256) {
    return _collateralConfigs[collateralIds[_collateralType]].debtLimit;
  }

  /**
    Get the minimum collateralization ratio for a collateral type
    @dev this is the liquidation treshold under which a vault is considered open for liquidation.
    @param _collateralType address of the collateral type
  */
  function collateralMinCollateralRatio(address _collateralType) public override view returns (uint256) {
    return _collateralConfigs[collateralIds[_collateralType]].minCollateralRatio;
  }

  /**
    Get the borrowing rate for a collateral type
    @dev borrowing rate is specified for a 1 sec interval and accurancy is in RAY.
    @param _collateralType address of the collateral type
  */
  function collateralBorrowRate(address _collateralType) public override view returns (uint256) {
    return _collateralConfigs[collateralIds[_collateralType]].borrowRate;
  }

  /**
    Get the origiation fee for a collateral type
    @dev this rate is applied as a one time fee for new borrowing and is specified in WAD
    @param _collateralType address of the collateral type
  */
  function collateralOriginationFee(address _collateralType) public override view returns (uint256) {
    return _collateralConfigs[collateralIds[_collateralType]].originationFee;
  }

  /**
    Set the platform wide incentive for liquidations.
    @dev the liquidation bonus is specified in WAD
    @param _bonus the liquidation bonus to be paid to liquidators
  */
  function setLiquidationBonus(uint256 _bonus) public override onlyManager {
    liquidationBonus = _bonus;
  }

  /**
    Retreives the entire config for a specific config id.
    @param _id the ID of the conifg to be returned
  */
  function collateralConfigs(uint256 _id) public override view returns (CollateralConfig memory) {
    require(_id <= numCollateralConfigs, "Invalid config id");
    return _collateralConfigs[_id];
  }
}
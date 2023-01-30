// SPDX-License-Identifier: None
pragma solidity 0.6.12;

import "../BoilerplateStrategy.sol";

import "../../interfaces/curvefi/ICurveFi_Gauge.sol";
import "../../interfaces/curvefi/ICurveFi_Minter.sol";
import "../../interfaces/curvefi/ICurveFi_DepositY.sol";
import "../../interfaces/curvefi/IYERC20.sol";
import "../../interfaces/uniswap/IUniswapV2Router02.sol";

/**
* This strategy is for the yCRV vault, i.e., the underlying token is yCRV. It is not to accept
* stable coins. It will farm the CRV crop. For liquidation, it swaps CRV into DAI and uses DAI
* to produce yCRV.
*/

contract CRVStrategyYCRV is IStrategy, BoilerplateStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // yDAIyUSDCyUSDTyTUSD (yCRV)
    address public pool; //aka Gauge
    address public mintr;
    address public crv;

    address public curve; // aka DepositY
    address public dai;

    address public uniswapRouter;

    address[] public uniswap_CRV2DAI;

    constructor(
        address _vault,
        address _underlying,
        address _strategist,
        address _pool,
        address _curve,
        address _dai,
        address _uniswap
    ) public BoilerplateStrategy(_vault, _underlying, _strategist) {
        require(IVault(_vault).token() == _underlying, "vault does not support underlying");
        pool = _pool;
        require(ICurveFi_Gauge(pool).lp_token() == _underlying, "Incorrect Gauge");

        mintr = ICurveFi_Gauge(pool).minter();
        crv = ICurveFi_Gauge(pool).crv_token();
        curve = _curve;
        dai = _dai;

        uniswapRouter = _uniswap;
        uniswap_CRV2DAI = [crv, IUniswapV2Router02(uniswapRouter).WETH(), dai];

        // set these tokens to be not salvageable
        unsalvageableTokens[underlying] = true;
        unsalvageableTokens[crv] = true;
    }

    /*****
    * VIEW INTERFACE
    *****/

    function getNameStrategy() external override view returns(string memory){
        return "CRVStrategyYCRV";
    }

    function want() external override view returns(address){
        return address(underlying);
    }

    /**
    * Balance of invested.
    */
    function balanceOf() public override view returns (uint256) {
        return ICurveFi_Gauge(pool).balanceOf(address(this)).add(
            IERC20(underlying).balanceOf(address(this))
        );
    }

    /*****
    * DEPOSIT/WITHDRAW/HARVEST EXTERNAL
    *****/

    /**
    * Invests all the underlying yCRV into the pool that mints crops (CRV_.
    */
    function deposit() public override restricted {
        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            IERC20(underlying).safeApprove(pool, 0);
            IERC20(underlying).safeApprove(pool, underlyingBalance);
            ICurveFi_Gauge(pool).deposit(underlyingBalance);
        }
    }

    /**
    * Withdraws the yCRV tokens from the pool in the specified amount.
    */
    function withdraw(uint256 amountUnderlying) public override restricted {
        require(amountUnderlying > 0, "Incorrect amount");
        if (harvestOnWithdraw && liquidationAllowed) {
            claimAndLiquidateCrv();
        }
        uint256 balanceUnderlying = ICurveFi_Gauge(pool).balanceOf(address(this));
        uint256 looseBalance = IERC20(underlying).balanceOf(address(this));
        uint256 total = balanceUnderlying.add(looseBalance);

        if (amountUnderlying > total) {
            //cant withdraw more than we own
            amountUnderlying = total;
        }

        if (looseBalance >= amountUnderlying) {
            IERC20(underlying).safeTransfer(vault, amountUnderlying);
            return;
        }

        uint256 toWithdraw = amountUnderlying.sub(looseBalance);
        withdrawYCrvFromPool(toWithdraw);

        looseBalance = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(vault, looseBalance);
    }

    /**
    * Withdraws all the yCRV tokens to the pool.
    */
    function withdrawAll() external override restricted {
      if (harvestOnWithdraw && liquidationAllowed) {
          claimAndLiquidateCrv();
      }
      uint256 balanceUnderlying = ICurveFi_Gauge(pool).balanceOf(address(this));
      withdrawYCrvFromPool(balanceUnderlying);

      uint256 balance = IERC20(underlying).balanceOf(address(this));
      IERC20(underlying).safeTransfer(vault, balance);
    }

    function emergencyExit() external onlyGovernance {
        claimAndLiquidateCrv();

        uint256 balanceUnderlying = ICurveFi_Gauge(pool).balanceOf(address(this));
        withdrawYCrvFromPool(balanceUnderlying);

        uint256 balance = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(IVault(vault).governance(), balance);
    }

  /**
  * Claims and liquidates CRV into yCRV, and then invests all underlying.
  */
  function earn() public restricted {
      if (liquidationAllowed) {
          claimAndLiquidateCrv();
      }

      deposit();
  }


    function convert(address) external override returns(uint256){
        return 0;
    }

    function skim()  override external {
        revert("Can't skim");
    }


    /**
    * Claims the CRV crop, converts it to DAI on Uniswap, and then uses DAI to mint yCRV using the
    * Curve protocol.
    */
    function claimAndLiquidateCrv() public {
        ICurveFi_Minter(mintr).mint(pool);
        // claiming rewards and sending them to the master strategy

        uint256 crvBalance = IERC20(crv).balanceOf(address(this));

        if (crvBalance > sellFloor) {
            uint256 daiBalanceBefore = IERC20(dai).balanceOf(address(this));
            IERC20(crv).safeApprove(uniswapRouter, 0);
            IERC20(crv).safeApprove(uniswapRouter, crvBalance);
            // we can accept 1 as the minimum because this will be called only by a trusted worker
            IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
              crvBalance, 1, uniswap_CRV2DAI, address(this), block.timestamp + 10
            );
            // now we have DAI
            // pay fee before making yCRV
            _profitSharing(IERC20(dai).balanceOf(address(this)) - daiBalanceBefore);

            // liquidate if there is any DAI left
            yCurveFromDai();
            // now we have yCRV
        }
    }

  /**
  * Withdraws yCRV from the investment pool that mints crops.
  */
  function withdrawYCrvFromPool(uint256 amount) internal {
      Gauge(pool).withdraw(amount);
  }

  /**
  * Converts all DAI to yCRV using the CRV protocol.
  */
  function yCurveFromDai() internal {
    uint256 daiBalance = IERC20(dai).balanceOf(address(this));
    if (daiBalance > 0) {
        IERC20(dai).safeApprove(curve, 0);
        IERC20(dai).safeApprove(curve, daiBalance);
        uint256 minimum = 0;
        ICurveFi_DepositY(curve).add_liquidity([daiBalance, 0, 0, 0], minimum);
    }
    // now we have yCRV
  }

  function _profitSharing(uint256 amount) internal override {
      if (profitSharingNumerator == 0) {
          return;
      }
      uint256 feeAmount = amount.mul(profitSharingNumerator).div(profitSharingDenominator);
      emit ProfitShared(amount, feeAmount, block.timestamp);

      if(feeAmount > 0) {
        IERC20(dai).safeTransfer(controller, feeAmount);
      }
  }
}

// SPDX-License-Identifier: None
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../interfaces/yearn/IVault.sol";
import "../interfaces/yearn/IStrategy.sol";

abstract contract BoilerplateStrategy is IStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    enum Setting { CONTROLLER_SET, STRATEGIST_SET, PROFIT_SHARING_SET, LIQ_ALLOWED_SET,
                    HARVEST_ALLOWED_SET, SELL_FLOOR_SET } 

    address public underlying;
    address public strategist;
    address public controller;
    address public vault;

    uint256 public profitSharingNumerator;
    uint256 public profitSharingDenominator;

    bool public harvestOnWithdraw;

    bool public liquidationAllowed = true;
    uint256 public sellFloor = 0;

    // These tokens cannot be claimed by the controller
    mapping(address => bool) public unsalvageableTokens;


    event ProfitShared(uint256 amount, uint256 fee, uint256 timestamp);
    event SettingChanged(Setting setting, address initiator, uint timestamp);

    modifier restricted() {
        require(
            msg.sender == vault || msg.sender == controller ||
            msg.sender == IVault(vault).governance() || msg.sender == strategist,
            "Sender must be privileged"
        );
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == IVault(vault).governance(), "!governance");
        _;
    }

    constructor(address _vault, address _underlying, address _strategist) public {
        vault = _vault;

        underlying = _underlying;

        strategist = _strategist;

        harvestOnWithdraw = true;

        profitSharingNumerator = 30;
        profitSharingDenominator = 100;

        require(IVault(vault).token() == _underlying, "vault does not support underlying");
        controller = IVault(vault).controller();       
    }

    function setController(address _controller) external onlyGovernance {
        controller = _controller;
        emit SettingChanged(Setting.CONTROLLER_SET, msg.sender, block.timestamp);
    }

    function setStrategist(address _strategist) external restricted {
        strategist = _strategist;
        emit SettingChanged(Setting.STRATEGIST_SET, msg.sender, block.timestamp);
    }

    function setProfitSharing(uint256 _profitSharingNumerator, uint256 _profitSharingDenominator) external restricted {
        require(_profitSharingDenominator > 0, "Incorrect denominator");
        require(_profitSharingNumerator < _profitSharingDenominator, "Numerator < Denominator");
        profitSharingNumerator = _profitSharingNumerator;
        profitSharingDenominator = _profitSharingDenominator;
        emit SettingChanged(Setting.PROFIT_SHARING_SET, msg.sender, block.timestamp);
    }

    function setHarvestOnWithdraw(bool _flag) external restricted {
        harvestOnWithdraw = _flag;
        emit SettingChanged(Setting.HARVEST_ALLOWED_SET, msg.sender, block.timestamp);
    }

    /**
     * Allows liquidation
     */
    function setLiquidationAllowed(bool allowed) external restricted {
        liquidationAllowed = allowed;
        emit SettingChanged(Setting.LIQ_ALLOWED_SET, msg.sender, block.timestamp);
    }

    function setSellFloor(uint256 value) external restricted {
        sellFloor = value;
        emit SettingChanged(Setting.SELL_FLOOR_SET, msg.sender, block.timestamp);
    }

    /**
     * Withdraws a token.
     */
    function withdraw(address token) external override restricted {
        // To make sure that governance cannot come in and take away the coins
        require(!unsalvageableTokens[token], "!salvageable");
        uint256 balance =  IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(vault, balance);
    }


    function _profitSharing(uint256 amount) internal virtual {
      if (profitSharingNumerator == 0) {
          return;
      }
      uint256 feeAmount = amount.mul(profitSharingNumerator).div(profitSharingDenominator);
      emit ProfitShared(amount, feeAmount, block.timestamp);

      if(feeAmount > 0) {
        IERC20(underlying).safeTransfer(controller, feeAmount);
      }
    }
}

// SPDX-License-Identifier: None
pragma solidity 0.6.12;

/**
 * @dev Interface for Curve.Fi CRV staking Gauge contract.
 * @dev See original implementation in official repository:
 * https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/LiquidityGauge.vy
 */
interface ICurveFi_Gauge {
    function lp_token() external view returns(address);
    function crv_token() external view returns(address);

    function balanceOf(address addr) external view returns (uint256);
    function deposit(uint256 _value) external;
    function withdraw(uint256 _value) external;

    function claimable_tokens(address addr) external returns (uint256);
    function minter() external view returns(address); //use minter().mint(gauge_addr) to claim CRV

    function integrate_fraction(address _for) external view returns(uint256);
    function user_checkpoint(address _for) external returns(bool);
}

interface Gauge {
    function deposit(uint) external;
    function balanceOf(address) external view returns (uint);
    function withdraw(uint) external;
    function user_checkpoint(address) external;
}

interface VotingEscrow {
    function create_lock(uint256 v, uint256 time) external;
    function increase_amount(uint256 _value) external;
    function increase_unlock_time(uint256 _unlock_time) external;
    function withdraw() external;
}

interface Mintr {
    function mint(address) external;
}

// SPDX-License-Identifier: None
pragma solidity 0.6.12;

/**
 * @dev Interface for Curve.Fi CRV minter contract.
 * @dev See original implementation in official repository:
 * https://github.com/curvefi/curve-dao-contracts/blob/master/contracts/Minter.vy
 */
interface ICurveFi_Minter {
    function mint(address gauge_addr) external;
    function mint_for(address gauge_addr, address _for) external;
    function minted(address _for, address gauge_addr) external view returns(uint256);

    function toggle_approve_mint(address minting_user) external;

    function token() external view returns(address);
}

// SPDX-License-Identifier: None
pragma solidity 0.6.12;

/**
 * @dev Interface for Curve.Fi deposit contract for Y-pool.
 * @dev See original implementation in official repository:
 * https://github.com/curvefi/curve-contract/blob/master/contracts/pools/y/DepositY.vy
 */
interface ICurveFi_DepositY {
    function add_liquidity(uint256[4] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 _amount, uint256[4] calldata min_uamounts) external;
    function remove_liquidity_imbalance(uint256[4] calldata uamounts, uint256 max_burn_amount) external;
    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount) external;
    
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns(uint256);

    function coins(int128 i) external view returns (address);
    function underlying_coins(int128 i) external view returns (address);
    function underlying_coins() external view returns (address[4] memory);
    function curve() external view returns (address);
    function token() external view returns (address);

}

// SPDX-License-Identifier: None
pragma solidity 0.6.12;

interface IYERC20 {

    // //ERC20 functions
    // function totalSupply() external view returns (uint256);
    // function balanceOf(address account) external view returns (uint256);
    // function transfer(address recipient, uint256 amount) external returns (bool);
    // function allowance(address owner, address spender) external view returns (uint256);
    // function approve(address spender, uint256 amount) external returns (bool);
    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    // function name() external view returns (string memory);
    // function symbol() external view returns (string memory);
    // function decimals() external view returns (uint8);

    //Y-token functions
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
    function getPricePerFullShare() external view returns (uint256);

    function token() external returns(address);

}

// SPDX-License-Identifier: None
pragma solidity >=0.5.0;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IVault {
    function token() external view returns (address);

    function controller() external view returns (address);

    function governance() external view returns (address);

    function getPricePerFullShare() external view returns (uint256);

    function deposit(uint256) external;

    function depositAll() external;

    function withdraw(uint256) external;

    function withdrawAll() external;

    // Part of ERC20 interface

    //function name() external view returns (string memory);
    //function symbol() external view returns (string memory);
    //function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IStrategy {

    /// @notice Returns the name of the strategy
    /// @dev The name is set when the strategy is deployed
    /// @return Returns the name of the strategy
    function getNameStrategy() external view returns (string memory);

    /// @notice Returns the want address of the strategy
    /// @dev The want is set when the strategy is deployed
    /// @return Returns the name of the strategy
    function want() external view returns (address);

    /// @notice Shows the balance of the strategy.
    function balanceOf() external view returns (uint256);

    /// @notice Transfers tokens for earnings
    function deposit() external;

    // NOTE: must exclude any tokens used in the yield
    /// @notice Controller role - withdraw should return to Controller
    function withdraw(address) external;

    /// @notice Controller | Vault role - withdraw should always return to Vault
    function withdraw(uint256) external;

    /// @notice Controller | Vault role - withdraw should always return to Vault
    function withdrawAll() external;

    /// @notice Calls to the method to convert the required token to the want token
    function convert(address _token) external returns(uint256);

    function skim() external;
}

// SPDX-License-Identifier: None
pragma solidity >=0.5.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

{
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "optimizer": {
    "enabled": true,
    "runs": 200
  }
}
pragma solidity >=0.5.17 <0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/math/SafeCast.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';



import '../BaseStrategy.sol';
import '../../enums/ProtocolEnum.sol';
import '../../external/harvest/HarvestVault.sol';
import '../../external/harvest/HarvestStakePool.sol';
import '../../external/chainlink/EthPriceFeed.sol';
import './../../external/uniswap/IUniswapV2.sol';
import './../../external/uniswap/IUniswapV3.sol';
import '../../external/curve/ICurveFi.sol';
//import './../../external/sushi/Sushi.sol';
import '../../dex/uniswap/SwapFarm2EursInUniswapV2.sol';

contract HarvestCrvEursStrategy is BaseStrategy, SwapFarm2EursInUniswapV2 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    //投资crvEURS对应的金库，返回FARM_eursCRV (feursCRV)
    address public constant fVault = address(0x6eb941BD065b8a5bd699C5405A928c1f561e2e5a);
    //crvEURS二次抵押对应的池子
    address public constant fPool = address(0xf4d50f60D53a230abc8268c6697972CB255Cd940);
    //FARM币
    address public rewardToken = address(0xa0246c9032bC3A600820415aE600c6388619A14D);
    address constant EURS = address(0xdB25f211AB05b1c97D595516F45794528a807ad8);
    IERC20 sEURToken = IERC20(0xD71eCFF9342A5Ced620049e616c5035F1dB98620);
    IERC20 constant baseToken = IERC20(0x194eBd173F6cDacE046C53eACcE9B953F28411d1);
    // the address of the Curve protocol's pool for EURS and sEUR
    address public curveAddress = address(0x0Ce6a5fF5217e38315f87032CF90686C96627CAA);
    // 8位精度结果。其他汇率兑换：Ethereum Price Feeds https://docs.chain.link/docs/ethereum-addresses/
    address public EUR_USD = address(0xb49f677943BC038e9857d61E7d053CaA2C1734C1);

    //uni v2 address
    address constant uniV2Address = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    //WETH
    address constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    //USDC
    address constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    //curve eurs pool address
    address constant curvePool = address(0x0Ce6a5fF5217e38315f87032CF90686C96627CAA);
    //sushi address
    address constant sushiAddress = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    //上次doHardwork按币本位计价的资产总值
    uint256 internal lastTotalAssets = 0;
    //当日赎回
    uint256 internal dailyWithdrawAmount = 0;

    constructor(address _vault) public {
        address[] memory tokens = new address[](1);
        tokens[0] = address(baseToken);
//        tokens[1] = address(sEURToken);
        initialize('HarvestCrvEursStrategy', uint16(ProtocolEnum.Harvest), _vault, tokens);
    }

    function _getExchangePrice(address pairProxyAddress) internal view returns (int) {
        (uint80 roundID,int price,uint startedAt,uint timeStamp,uint80 answeredInRound) = AggregatorV3Interface(pairProxyAddress).latestRoundData();
        return price;
    }

    /**
     * 计算基础币(USDT)与其它币种的数量关系，
     * sEUR没有汇率，暂时与ERUS比例为1:1
     * 如该池是CrvUSDN池，underlying是USDT数量，返回的则是EURS和sEUR的数量
     * @param amountUnderlying 需要投资USDT数量
     **/
    function calculate(uint256 amountUnderlying) external view override returns (uint256[] memory, uint256[] memory) {
        require(amountUnderlying > 0, 'amountUnderlying<=0');
        //一个单位ERU换几个单位USD
        int256 price = _getExchangePrice(EUR_USD);
        uint256 curveVirtualPrice = ICurveFi(curveAddress).get_virtual_price();
        uint256[] memory coinsAmount = new uint256[](1);
        coinsAmount[0] = amountUnderlying.mul(1e20).div(uint(price)).mul(1e18).div(curveVirtualPrice);
        uint256[] memory underlyingAmount = new uint256[](1);
        underlyingAmount[0] = amountUnderlying;

        return (coinsAmount,underlyingAmount);
    }

    function withdrawAllToVault() external onlyVault override {
        uint stakingAmount = HarvestStakePool(fPool).balanceOf(address(this));
        if (stakingAmount > 0){
            _claimRewards();
            HarvestStakePool(fPool).withdraw(stakingAmount);
            HarvestVault(fVault).withdraw(stakingAmount);
        }
        uint256 withdrawAmount = baseToken.balanceOf(address(this));
        if (withdrawAmount > 0){
            baseToken.safeTransfer(address(vault),withdrawAmount);
            dailyWithdrawAmount += withdrawAmount;
        }
    }

    /**
    * amountUnderlying:需要的基础代币数量
    **/
    function withdrawToVault(uint256 amountUnderlying) external onlyVault override {
        ( uint256[] memory coinsAmount,) = this.calculate(amountUnderlying);
        uint256 needCrvEurs = coinsAmount[0];

        uint256 balance = baseToken.balanceOf(address(this));
        if (balance >= needCrvEurs){
            baseToken.transfer(address(vault),needCrvEurs);
        } else {
            uint256 missAmount = needCrvEurs - balance;
            uint256 shares = missAmount
                                .mul(10 ** IERC20Metadata(fVault).decimals())
                                .div(HarvestVault(fVault).getPricePerFullShare());


            if (shares > 0){

                shares = Math.min(shares,HarvestStakePool(fPool).balanceOf(address(this)));
                HarvestStakePool(fPool).withdraw(shares);
                HarvestVault(fVault).withdraw(shares);
                uint256 withdrawAmount = baseToken.balanceOf(address(this));

                baseToken.safeTransfer(address(vault),withdrawAmount);

                dailyWithdrawAmount += withdrawAmount;


            }
        }

    }

    /**
     * 第三方池的净值,单个yToken的价格(USDN)
     **/
    function getPricePerFullShare() external view override returns (uint256) {
        return HarvestVault(fVault).getPricePerFullShare();
    }

    /**
     * 已经投资的underlying数量，策略实际投入的是不同的稳定币，这里涉及待投稳定币与underlying之间的换算
     **/
    function investedUnderlyingBalance() external view override returns (uint256) {
        uint256 stakingAmount = HarvestStakePool(fPool).balanceOf(address(this));
        uint256 balance = baseToken.balanceOf(address(this));
        uint256 crvEURSAmount = stakingAmount.mul(HarvestVault(fVault).getPricePerFullShare()).div(10 ** IERC20Metadata(fVault).decimals()).add(balance);
        int256 price = _getExchangePrice(EUR_USD);
        uint256 curveVirtualPrice = ICurveFi(curveAddress).get_virtual_price();
        return crvEURSAmount
                .mul(curveVirtualPrice)
                .div(1e18)
                .mul(uint(price))
                .div(1e8)
                .div(10 ** (IERC20Metadata(fVault).decimals() - 6));
    }

    /**
     * 查看策略投资池子的总数量（priced in want）
     **/
    function getInvestVaultAssets() external view override returns (uint256) {
        int256 price = _getExchangePrice(EUR_USD);
        uint256 curveVirtualPrice = ICurveFi(curveAddress).get_virtual_price();
        uint256 crvEURSAmount = HarvestVault(fVault).getPricePerFullShare()
                                    .mul(IERC20(fVault).totalSupply())
                                    .div(10 ** IERC20Metadata(fVault).decimals());
        return crvEURSAmount.mul(curveVirtualPrice)
                .div(1e18)
                .mul(uint(price))
                .div(1e8)
                .div(10 ** (IERC20Metadata(fVault).decimals() - 6));
    }

    /**
     * 针对策略的作业：
     * 1.提矿 & 换币（矿币换成策略所需的稳定币？）
     * 2.计算apy
     * 3.投资
     **/
    function doHardWorkInner() internal override {
        uint256 rewards = 0;
        if (HarvestStakePool(fPool).balanceOf(address(this)) > 0){
            rewards = _claimRewards();
        }
        _updateApy(rewards);
        _invest();
        lastTotalAssets = HarvestStakePool(fPool).balanceOf(address(this))
                            .mul(HarvestVault(fVault).getPricePerFullShare())
                            .div(10 ** IERC20Metadata(fVault).decimals());
        lastDoHardworkTimestamp = block.timestamp;
        dailyWithdrawAmount = 0;
    }

    function _claimRewards() internal returns (uint256) {
        HarvestStakePool(fPool).getReward();
        uint256 amount = IERC20(rewardToken).balanceOf(address(this));
        if (amount == 0){
            return 0;
        }

        //兑换成investToken
        //TODO::当Farm数量大于50时先从uniV2换成ETH然后再从curve换
        uint256 balanceBeforeSwap = IERC20(baseToken).balanceOf(address(this));
        //Farm swap to WETH from UniV2
        address[] memory path = new address[](2);
        path[0] = rewardToken;
        path[1] = USDC;
        IERC20(rewardToken).approve(uniV2Address,0);
        IERC20(rewardToken).approve(uniV2Address,amount);

        // 矿币达到一定数量后，才去兑换，要不然会存在返回为0的情况。
        if(amount > 10**15){
            swapFarm2EursInUniswapV2(amount,0,1800);
            uint256 eursBalance = IERC20(EURS).balanceOf(address(this));

            IERC20(EURS).safeApprove(curvePool,0);
            IERC20(EURS).safeApprove(curvePool,eursBalance);
            ICurveFi(curvePool).add_liquidity([eursBalance, 0], 0);
            uint256 balanceAfterSwap = IERC20(baseToken).balanceOf(address(this));

            return balanceAfterSwap - balanceBeforeSwap;
        }
        return 0;
    }

    function _updateApy(uint256 _rewards) internal {
        // 第一次投资时lastTotalAssets为0，不用计算apy
        if (lastTotalAssets > 0 && lastDoHardworkTimestamp > 0){
            uint256 totalAssets = HarvestStakePool(fPool).balanceOf(address(this))
                                    .mul(HarvestVault(fVault).getPricePerFullShare())
                                    .div(10 ** IERC20Metadata(fVault).decimals());

            int assetsDelta = int(totalAssets + dailyWithdrawAmount + _rewards - lastTotalAssets);
            calculateProfitRate(lastTotalAssets,assetsDelta);
        }
    }


    function _invest() internal {
        uint256 balance = baseToken.balanceOf(address(this));
        if (balance > 0) {
            baseToken.safeApprove(fVault, 0);
            baseToken.safeApprove(fVault, balance);
            HarvestVault(fVault).deposit(balance);


            //stake
            uint256 lpAmount = IERC20(fVault).balanceOf(address(this));
            IERC20(fVault).safeApprove(fPool, 0);
            IERC20(fVault).safeApprove(fPool, lpAmount);
            HarvestStakePool(fPool).stake(lpAmount);

            lastTotalAssets = HarvestStakePool(fPool).balanceOf(address(this)).mul(HarvestVault(fVault).getPricePerFullShare()).div(10 ** IERC20Metadata(fVault).decimals());
        }
    }

    /**
     * 策略迁移
     **/
    function migrate(address _newStrategy) external override {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
        // (a + b) / 2 can overflow, so we distribute.
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity >=0.5.17 <0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';


import './IStrategy.sol';
import '../vault/IVault.sol';

abstract contract BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;

    uint16 public protocol;

    IVault public vault;

    address[] public tokens;

    uint256 internal constant BASIS_PRECISION = 1e18;
    //基础收益率，初始化时为1000000
    uint256 internal basisProfitRate;
    //有效时长，用于计算apy，若策略没有资金时，不算在有效时长内
    uint256 internal effectiveTime;
    //上次doHardwork的时间
    uint256 public lastDoHardworkTimestamp = 0;

    function getTokens() external view returns (address[] memory) {
        return tokens;
    }

    function setApy(uint256 nextBasisProfitRate, uint256 nextEffectiveTime) external onlyGovernance {

        basisProfitRate = nextBasisProfitRate;
        effectiveTime = nextEffectiveTime;
        vault.strategyUpdate(this.investedUnderlyingBalance(),apy());
    }

    //10000表示100%，当前apy的算法是一直累计过去的变化，有待改进
    function apy() public view returns (uint256) {

        if (basisProfitRate <= BASIS_PRECISION) {
            return 0;
        }
        if (effectiveTime == 0) {
            return 0;
        }
        return (31536000 * (basisProfitRate - BASIS_PRECISION) * 10000) / (BASIS_PRECISION * effectiveTime);
    }


    modifier onlyGovernance() {
        require(msg.sender == vault.governance(), '!only governance');
        _;
    }

    modifier onlyVault() {
        require(msg.sender == address(vault), '!only vault');
        _;
    }

    function initialize(
        string memory _name,
        uint16 _protocol,
        address _vault,
        address[] memory _tokens
    ) internal {
        name = _name;
        protocol = _protocol;
        vault = IVault(_vault);
        tokens = _tokens;
        effectiveTime = 0;
        basisProfitRate = BASIS_PRECISION;
    }



    /**
     * 计算基础币与其它币种的数量关系
     * 如该池是CrvEURS池，underlying是USDT数量，返回的则是 EURS、SEUR的数量
     **/
    function calculate(uint256 amountUnderlying) external view virtual returns (uint256[] memory, uint256[] memory);

    function withdrawAllToVault() external virtual;

    /**
     * amountUnderlying:需要的基础代币数量
     **/
    function withdrawToVault(uint256 amountUnderlying) external virtual;

    /**
     * 第三方池的净值
     **/
    function getPricePerFullShare() external view virtual returns (uint256);

    /**
     * 已经投资的underlying数量，策略实际投入的是不同的稳定币，这里涉及待投稳定币与underlying之间的换算
     **/
    function investedUnderlyingBalance() external view virtual returns (uint256);

    /**
     * 查看策略投资池子的总资产
     **/
    function getInvestVaultAssets() external view virtual returns (uint256);

    /**
     * 针对策略的作业：
     * 1.提矿 & 换币（矿币换成策略所需的稳定币？）
     * 2.计算apy
     * 3.投资
     **/
    function doHardWork() external onlyGovernance{
        doHardWorkInner();
        vault.strategyUpdate(this.investedUnderlyingBalance(),apy());
        lastDoHardworkTimestamp = block.timestamp;
    }

    function doHardWorkInner() internal virtual;

    function calculateProfitRate(uint256 previousInvestedAssets,int assetsDelta) internal {
        if (assetsDelta < 0)return;
        uint256 secondDelta = block.timestamp - lastDoHardworkTimestamp;
        if (secondDelta > 10 && assetsDelta != 0){
            effectiveTime += secondDelta;
            uint256 dailyProfitRate = uint256(assetsDelta>0?assetsDelta:-assetsDelta) * BASIS_PRECISION / previousInvestedAssets;
            if (assetsDelta > 0){
                basisProfitRate = (BASIS_PRECISION + dailyProfitRate) * basisProfitRate / BASIS_PRECISION;
            } else {
                basisProfitRate = (BASIS_PRECISION - dailyProfitRate) * basisProfitRate / BASIS_PRECISION;
            }

        }
    }

    /**
     * 策略迁移
     **/
    function migrate(address _newStrategy) external virtual;
}

pragma solidity ^0.8.0;

enum ProtocolEnum {
    Yearn,
    Harvest,
    Dodo,
    Curve,
    Pickle,
    Liquity,
    TrueFi
}

pragma solidity ^0.8.0;

interface HarvestVault {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function withdrawAll() external;

    function doHardWork() external;

    function underlyingBalanceWithInvestment() view external returns (uint256);

    function getPricePerFullShare() external view returns (uint256);

//    function pricePerShare() external view returns (uint256);

    function decimals() external view returns (uint256);

    function balance() external view returns (uint256);
}

pragma solidity ^0.8.0;

interface HarvestStakePool {

    function balanceOf(address account) external view returns (uint256);

    function getReward() external;

    function stake(uint256 amount) external;

    function rewardPerToken() external view returns (uint256);

    function withdraw(uint256 amount) external;

    function exit() external;
}

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

abstract contract EthPriceFeed {

    //https://docs.chain.link/docs/ethereum-addresses/
    function getExchangePrice(address pairProxyAddress) public view returns (int) {
        (uint80 roundID,int price,uint startedAt,uint timeStamp,uint80 answeredInRound) = AggregatorV3Interface(pairProxyAddress).latestRoundData();
        return price;
    }
}

pragma solidity =0.8.0;

interface IUniswapV2 {
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

pragma solidity =0.8.0;

interface IUniswapV3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

pragma solidity >=0.5.17 <0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface ICurveFi {
    /**
     * 返回一个lpToken对应的价值
     * return：一个lpToken的价值，单位是DAI，精度为1e18
     **/
    function get_virtual_price() external view returns (uint256);

    /**
     * 增加流动性接口
     * amounts：是一个数组，代表要投入的币种组合，amounts[0]是EURS的数量，amounts[1]是SEUR的数量
     * min_mint_amount：最小铸币数量，期望得到的最小lpToken数量
     * return：返回投资凭证数
     **/
    function add_liquidity(
        // EURs
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external;

    function add_liquidity(
        // sBTC pool
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external;

    /**
     * 移除流动性接口,提款金额基于活期存款比率
     * _amount：需要提取的lpToken数量
     * min_amounts：期望返回的最小代币数，min_amounts[0]是EURS的数量，min_amounts[1]是SEUR的数量
     * return：实际返回的代币数量
     **/
    function remove_liquidity(uint256 _amount, uint256[2] calldata min_amounts) external returns (uint256[2] memory);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;

    function exchange(
        int128 from, //源币索引
        int128 to, //目标币索引
        uint256 _from_amount, //源币数量
        uint256 _min_to_amount //期望的最少目标币数量
    ) external;

    /**
     * 余额查询
     * index：0-EURS,1-SEUR
     * return：余额
     **/
    function balances(uint256) external view returns (uint256);
}

pragma solidity >=0.5.17 <=0.8.0;


import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './SwapInUniswapV2.sol';

interface ISwapFarm2EursInUniswapV2 {
    function swapFarm2UsdtInUniswapV2(
        uint256 _amount,
        uint256 _minReturn,
        uint256 _timeout
    ) external returns (uint256[] memory);
}

contract SwapFarm2EursInUniswapV2 is SwapInUniswapV2 {
    address private FARM_ADDRESS = address(0xa0246c9032bC3A600820415aE600c6388619A14D);
    address private WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address private EURS_ADDRESS = address(0xdB25f211AB05b1c97D595516F45794528a807ad8);

    /**
     * farm => eurs
     */
    function swapFarm2EursInUniswapV2(
        uint256 _amount,
        uint256 _minReturn,
        uint256 _timeout
    ) internal returns (uint256[] memory) {
        require(_amount > 0, '_amount>0');
        require(_amount > 10**15, '_amount>10**15, small amount');
        require(_minReturn >= 0, '_minReturn>=0');
        address[] memory _path = new address[](3);
        _path[0] = FARM_ADDRESS;
        _path[1] = WETH_ADDRESS;
        _path[2] = EURS_ADDRESS;
        return this.swap(FARM_ADDRESS, _amount, _minReturn, _path, address(this), _timeout);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

pragma solidity >=0.5.17 <0.8.4;

interface IStrategy {

//    function underlying() external view returns (address);
    function vault() external view returns (address);

    function name() external pure returns (string calldata);

    /**
    * 第三方池需要的代币地址列表
    **/
    function getTokens() external view returns (address[] memory);

    function apy() external view returns (uint256);

    /**
    * 计算基础币与其它币种的数量关系
    * 如该池是CrvEURS池，underlying是USDT数量，返回的则是 EURS、SEUR的数量
    **/
    function calculate(uint256 amountUnderlying) external view returns (uint256[] memory);

    function withdrawAllToVault() external;

    /**
    * amountUnderlying:需要的基础代币数量
    **/
    function withdrawToVault(uint256 amountUnderlying) external;


    /**
    * 第三方池的净值
    **/
    function getPricePerFullShare() external view returns (uint256);

    /**
    * 已经投资的underlying数量，策略实际投入的是不同的稳定币，这里涉及待投稳定币与underlying之间的换算
    **/
    function investedUnderlyingBalance() external view returns (uint256);

    /**
    * 查看策略投资池子的总数量（priced in want）
    **/
    function getInvestVaultAssets() external view returns (uint256);


    /**
    * 针对策略的作业：
    * 1.提矿 & 换币（矿币换成策略所需的稳定币？）
    * 2.计算apy
    * 3.投资
    **/
    function doHardWork() external;

    /**
    * 策略迁移
    **/
    function migrate(address _newStrategy) external virtual;
}

pragma solidity >=0.5.17 <0.8.4;

interface IVault {
    function name() external view returns (string calldata);

    function symbol() external view returns (string calldata);

    function decimals() external view returns (uint256);

    function governance() external view returns (address);

    /**
     * USDT地址
     **/
    function underlying() external view returns (address);

    /**
     * Vault净值
     **/
    function getPricePerFullShare() external view returns (uint256);

    /**
     * 总锁仓量
     **/
    function tlv() external view returns (uint256);

    function deposit(uint256 amountWei) external;

    function withdraw(uint256 numberOfShares) external;

    function addStrategy(address _strategy) external;

    function removeStrategy(address _strategy) external;

    function strategyUpdate(uint256 newTotalAssets, uint256 apy) external;

    /**
     * 策略列表
     **/
    function strategies() external view returns (address[] memory);

    /**
     * 分两种情况：
     * 不足一周时，维持Vault中USDT数量占总资金的5%，多余的投入到apy高的策略中，不足时从低apy策略中赎回份额来补够
     * 到达一周时，统计各策略apy，按照资金配比规则进行调仓（统计各策略需要的稳定币数量，在Vault中汇总后再分配）
     **/
    function doHardWork() external;

    struct StrategyState {
        uint256 totalAssets; //当前总资产
        uint256 totalDebt; //投入未返还成本
    }

    function strategyState(address strategyAddress) external view returns (StrategyState memory);

    /**
     * 获取总成本
     */
    function totalCapital() external view returns (uint256);

    /**
     * 获取总估值
     */
    function totalAssets() external view returns (uint256);

    /**
     * 获取策略投资总额
     */
    function strategyTotalAssetsValue() external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

pragma solidity >=0.5.17 <=0.8.0;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './../../external/uniswap/IUniswapV2.sol';

contract SwapInUniswapV2 {
    using SafeERC20 for IERC20;
    address private uniswapV2Address = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function swap(
        address fromToken,
        uint256 _amount,
        uint256 _minReturn,
        address[] memory _path,
        address recipient,
        uint256 _timeout
    ) public returns (uint256[] memory) {
        require(_amount > 0, '_amount>0');
        require(_minReturn >= 0, '_minReturn>=0');
        IERC20(fromToken).safeApprove(uniswapV2Address, 0);
        IERC20(fromToken).safeApprove(uniswapV2Address, _amount);

       try IUniswapV2(uniswapV2Address).swapExactTokensForTokens(
            _amount,
            _minReturn,
            _path,
            recipient,
            block.timestamp + _timeout
        ) returns (uint256[] memory amounts){
           return amounts;
       }catch{

       }
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 0;
        amounts[1] = 0;
        return amounts;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

{
  "optimizer": {
    "enabled": true,
    "runs": 1
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
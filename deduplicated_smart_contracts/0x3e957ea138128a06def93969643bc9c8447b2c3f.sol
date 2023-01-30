// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

interface ICurve {
    function add_liquidity(uint[2] memory amounts, uint amountOutMin) external;
    function remove_liquidity_one_coin(uint amount, int128 index, uint amountOutMin) external;
}

interface IDaoL1Vault is IERC20Upgradeable {
    function deposit(uint amount) external;
    function withdraw(uint share) external returns (uint);
    function getAllPoolInUSD() external view returns (uint);
    function getAllPoolInETH() external view returns (uint);
    function getAllPoolInNative() external view returns (uint);
}

interface IChainlink {
    function latestAnswer() external view returns (int256);
}

contract CitadelV2Strategy is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable constant WETH = IERC20Upgradeable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20Upgradeable constant WBTC = IERC20Upgradeable(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20Upgradeable constant DPI = IERC20Upgradeable(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b);
    IERC20Upgradeable constant DAI = IERC20Upgradeable(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    IERC20Upgradeable constant HBTCWBTC = IERC20Upgradeable(0xb19059ebb43466C323583928285a49f558E572Fd);
    IERC20Upgradeable constant WBTCETH = IERC20Upgradeable(0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58);
    IERC20Upgradeable constant DPIETH = IERC20Upgradeable(0x34b13F8CD184F55d0Bd4Dd1fe6C07D46f245c7eD);
    IERC20Upgradeable constant DAIETH = IERC20Upgradeable(0xC3D03e4F041Fd4cD388c549Ee2A29a9E5075882f);

    ICurve constant curvePool = ICurve(0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F);
    IRouter constant sushiRouter = IRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    IDaoL1Vault public HBTCWBTCVault;
    IDaoL1Vault public WBTCETHVault;
    IDaoL1Vault public DPIETHVault;
    IDaoL1Vault public DAIETHVault;

    uint constant HBTCWBTCTargetPerc = 3000;
    uint constant WBTCETHTargetPerc = 3000;
    uint constant DPIETHTargetPerc = 3000;
    uint constant DAIETHTargetPerc = 1000;

    address public vault;
    uint public watermark; // In USD (18 decimals)
    uint public profitFeePerc;

    event TargetComposition (uint HBTCWBTCTargetPool, uint WBTCETHTargetPool, uint DPIETHTargetPool, uint DAIETHTargetPool);
    event CurrentComposition (uint HBTCWBTCCurrentPool, uint WBTCETHCurrentPool, uint DPIETHCurrentPool, uint DAIETHCurrentPool);
    event InvestHBTCWBTC(uint WETHAmt, uint HBTCWBTCAmt);
    event InvestWBTCETH(uint WETHAmt, uint WBTCETHAmt);
    event InvestDPIETH(uint WETHAmt, uint DPIETHAmt);
    event InvestDAIETH(uint WETHAmt, uint DAIETHAmt);
    event Withdraw(uint amount, uint WETHAmt);
    event WithdrawHBTCWBTC(uint lpTokenAmt, uint WETHAmt);
    event WithdrawWBTCETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawDPIETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawDAIETH(uint lpTokenAmt, uint WETHAmt);
    event CollectProfitAndUpdateWatermark(uint currentWatermark, uint lastWatermark, uint fee);
    event AdjustWatermark(uint currentWatermark, uint lastWatermark);
    event Reimburse(uint WETHAmt);
    event EmergencyWithdraw(uint WETHAmt);

    modifier onlyVault {
        require(msg.sender == vault, "Only vault");
        _;
    }

    function initialize(
        address _HBTCWBTCVault, address _WBTCETHVault, address _DPIETHVault, address _DAIETHVault
    ) external initializer {
        __Ownable_init();

        HBTCWBTCVault = IDaoL1Vault(_HBTCWBTCVault);
        WBTCETHVault = IDaoL1Vault(_WBTCETHVault);
        DPIETHVault = IDaoL1Vault(_DPIETHVault);
        DAIETHVault = IDaoL1Vault(_DAIETHVault);

        profitFeePerc = 2000;

        WETH.safeApprove(address(sushiRouter), type(uint).max);
        WBTC.safeApprove(address(curvePool), type(uint).max);
        WBTC.safeApprove(address(sushiRouter), type(uint).max);
        DPI.safeApprove(address(sushiRouter), type(uint).max);
        DAI.safeApprove(address(sushiRouter), type(uint).max);

        HBTCWBTC.safeApprove(address(HBTCWBTCVault), type(uint).max);
        HBTCWBTC.safeApprove(address(sushiRouter), type(uint).max);
        WBTCETH.safeApprove(address(WBTCETHVault), type(uint).max);
        WBTCETH.safeApprove(address(sushiRouter), type(uint).max);
        DPIETH.safeApprove(address(DPIETHVault), type(uint).max);
        DPIETH.safeApprove(address(sushiRouter), type(uint).max);
        DAIETH.safeApprove(address(DAIETHVault), type(uint).max);
        DAIETH.safeApprove(address(sushiRouter), type(uint).max);
    }

    function invest(uint WETHAmt) external onlyVault {
        WETH.safeTransferFrom(vault, address(this), WETHAmt);

        uint[] memory pools = getEachPool();
        uint pool = pools[0] + pools[1] + pools[2] + pools[3] + WETHAmt;
        uint HBTCWBTCTargetPool = pool * 3000 / 10000; // 30%
        uint WBTCETHTargetPool = HBTCWBTCTargetPool; // 30%
        uint DPIETHTargetPool = HBTCWBTCTargetPool; // 30%
        uint DAIETHTargetPool = pool * 1000 / 10000; // 10%

        // Rebalancing invest
        if (
            HBTCWBTCTargetPool > pools[0] &&
            WBTCETHTargetPool > pools[1] &&
            DPIETHTargetPool > pools[2] &&
            DAIETHTargetPool > pools[3]
        ) {
            investHBTCWBTC(HBTCWBTCTargetPool - pools[0]);
            investWBTCETH((WBTCETHTargetPool - pools[1]));
            investDPIETH((DPIETHTargetPool - pools[2]));
            investDAIETH((DAIETHTargetPool - pools[3]));
        } else {
            uint furthest;
            uint farmIndex;
            uint diff;

            if (HBTCWBTCTargetPool > pools[0]) {
                diff = HBTCWBTCTargetPool - pools[0];
                furthest = diff;
                farmIndex = 0;
            }
            if (WBTCETHTargetPool > pools[1]) {
                diff = WBTCETHTargetPool - pools[1];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 1;
                }
            }
            if (DPIETHTargetPool > pools[2]) {
                diff = DPIETHTargetPool - pools[2];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 2;
                }
            }
            if (DAIETHTargetPool > pools[3]) {
                diff = DAIETHTargetPool - pools[3];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 3;
                }
            }

            if (farmIndex == 0) investHBTCWBTC(WETHAmt);
            else if (farmIndex == 1) investWBTCETH(WETHAmt);
            else if (farmIndex == 2) investDPIETH(WETHAmt);
            else investDAIETH(WETHAmt);
        }

        emit TargetComposition(HBTCWBTCTargetPool, WBTCETHTargetPool, DPIETHTargetPool, DAIETHTargetPool);
        emit CurrentComposition(pools[0], pools[1], pools[2], pools[3]);
    }

    function investHBTCWBTC(uint WETHAmt) private {
        uint WBTCAmt = swap(address(WETH), address(WBTC), WETHAmt, 0);
        uint256[2] memory amounts = [0, WBTCAmt];
        curvePool.add_liquidity(amounts, 0);
        uint HBTCWBTCAmt = HBTCWBTC.balanceOf(address(this));
        HBTCWBTCVault.deposit(HBTCWBTCAmt);
        emit InvestHBTCWBTC(WETHAmt, HBTCWBTCAmt);
    }

    function investWBTCETH(uint WETHAmt) private {
        uint halfWETH = WETHAmt / 2;
        uint WBTCAmt = swap(address(WETH), address(WBTC), halfWETH, 0);
        (,,uint WBTCETHAmt) = sushiRouter.addLiquidity(address(WBTC), address(WETH), WBTCAmt, halfWETH, 0, 0, address(this), block.timestamp);
        WBTCETHVault.deposit(WBTCETHAmt);
        emit InvestWBTCETH(WETHAmt, WBTCETHAmt);
    }

    function investDPIETH(uint WETHAmt) private {
        uint halfWETH = WETHAmt / 2;
        uint DPIAmt = swap(address(WETH), address(DPI), halfWETH, 0);
        (,,uint DPIETHAmt) = sushiRouter.addLiquidity(address(DPI), address(WETH), DPIAmt, halfWETH, 0, 0, address(this), block.timestamp);
        DPIETHVault.deposit(DPIETHAmt);
        emit InvestDPIETH(WETHAmt, DPIETHAmt);
    }

    function investDAIETH(uint WETHAmt) private {
        uint halfWETH = WETHAmt / 2;
        uint DAIAmt = swap(address(WETH), address(DAI), halfWETH, 0);
        (,,uint DAIETHAmt) = sushiRouter.addLiquidity(address(DAI), address(WETH), DAIAmt, halfWETH, 0, 0, address(this), block.timestamp);
        DAIETHVault.deposit(DAIETHAmt);
        emit InvestDAIETH(WETHAmt, DAIETHAmt);
    }

    /// @param amount Amount to withdraw in USD
    function withdraw(uint amount, uint[] calldata tokenPrice) external onlyVault returns (uint WETHAmt) {
        uint sharePerc = amount * 1e18 / getAllPoolInUSD();
        uint WETHAmtBefore = WETH.balanceOf(address(this));
        withdrawHBTCWBTC(sharePerc, tokenPrice[1]);
        withdrawWBTCETH(sharePerc, tokenPrice[1]);
        withdrawDPIETH(sharePerc, tokenPrice[2]);
        withdrawDAIETH(sharePerc, tokenPrice[3]);
        WETHAmt = WETH.balanceOf(address(this)) - WETHAmtBefore;
        WETH.safeTransfer(vault, WETHAmt);
        emit Withdraw(amount, WETHAmt);
    }

    function withdrawHBTCWBTC(uint sharePerc, uint WBTCPrice) private {
        uint HBTCWBTCAmt = HBTCWBTCVault.withdraw(HBTCWBTCVault.balanceOf(address(this)) * sharePerc / 1e18);
        curvePool.remove_liquidity_one_coin(HBTCWBTCAmt, 1, 0);
        uint WBTCAmt = WBTC.balanceOf(address(this));
        uint _WETHAmt = swap(address(WBTC), address(WETH), WBTCAmt, WBTCAmt * WBTCPrice / 1e8);
        emit WithdrawHBTCWBTC(HBTCWBTCAmt, _WETHAmt);
    }

    function withdrawWBTCETH(uint sharePerc, uint WBTCPrice) private {
        uint WBTCETHAmt = WBTCETHVault.withdraw(WBTCETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint WBTCAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(WBTC), address(WETH), WBTCETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = swap(address(WBTC), address(WETH), WBTCAmt, WBTCAmt * WBTCPrice / 1e8);
        emit WithdrawWBTCETH(WBTCETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawDPIETH(uint sharePerc, uint DPIPrice) private {
        uint DPIETHAmt = DPIETHVault.withdraw(DPIETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint DPIAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(DPI), address(WETH), DPIETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = swap(address(DPI), address(WETH), DPIAmt, DPIAmt * DPIPrice / 1e18);
        emit WithdrawDPIETH(DPIETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawDAIETH(uint sharePerc, uint DAIPrice) private {
        uint DAIETHAmt = DAIETHVault.withdraw(DAIETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint DAIAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(DAI), address(WETH), DAIETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = swap(address(DAI), address(WETH), DAIAmt, DAIAmt * DAIPrice / 1e18);
        emit WithdrawDAIETH(DAIETHAmt, WETHAmt + _WETHAmt);
    }

    function collectProfitAndUpdateWatermark() public onlyVault returns (uint fee) {
        uint currentWatermark = getAllPoolInUSD();
        uint lastWatermark = watermark;
        if (currentWatermark > lastWatermark) {
            uint profit = currentWatermark - lastWatermark;
            fee = profit * profitFeePerc / 10000;
        }
        emit CollectProfitAndUpdateWatermark(currentWatermark, lastWatermark, fee);
    }

    /// @param signs True for positive, false for negative
    function adjustWatermark(uint amount, bool signs) external onlyVault {
        uint lastWatermark = watermark;
        watermark = signs == true ? watermark + amount : watermark - amount;
        emit AdjustWatermark(watermark, lastWatermark);
    }

    /// @param amount Amount to reimburse to vault contract in ETH
    function reimburse(uint farmIndex, uint amount) external onlyVault returns (uint WETHAmt) {
        if (farmIndex == 0) withdrawHBTCWBTC(amount * 1e18 / getHBTCWBTCPool(), 0);
        else if (farmIndex == 1) withdrawWBTCETH(amount * 1e18 / getWBTCETHPool(), 0);
        else if (farmIndex == 2) withdrawDPIETH(amount * 1e18 / getDPIETHPool(), 0);
        else if (farmIndex == 3) withdrawDAIETH(amount * 1e18 / getDAIETHPool(), 0);
        WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        emit Reimburse(WETHAmt);
    }

    function emergencyWithdraw() external onlyVault {
        // 1e18 == 100% of share
        withdrawHBTCWBTC(1e18, 0);
        withdrawWBTCETH(1e18, 0);
        withdrawDPIETH(1e18, 0);
        withdrawDAIETH(1e18, 0);
        uint WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        watermark = 0;
        emit EmergencyWithdraw(WETHAmt);
    }

    function swap(address from, address to, uint amount, uint amountOutMin) private returns (uint) {
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        return (sushiRouter.swapExactTokensForTokens(amount, amountOutMin, path, address(this), block.timestamp))[1];
    }

    function setVault(address _vault) external onlyOwner {
        require(vault == address(0), "Vault set");
        vault = _vault;
    }

    function setProfitFeePerc(uint _profitFeePerc) external onlyVault {
        profitFeePerc = _profitFeePerc;
    }

    function getPath(address tokenA, address tokenB) private pure returns (address[] memory path) {
        path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
    }

    function getHBTCWBTCPool() private view returns (uint) {
        uint HBTCWBTCVaultPoolInBTC = HBTCWBTCVault.getAllPoolInNative();
        uint BTCPriceInETH = uint(IChainlink(0xdeb288F737066589598e9214E782fa5A8eD689e8).latestAnswer());
        require(BTCPriceInETH > 0, "ChainLink error");
        return HBTCWBTCVaultPoolInBTC * BTCPriceInETH / 1e18;
    }

    function getWBTCETHPool() private view returns (uint) {
        return WBTCETHVault.getAllPoolInETH();
    }

    function getDPIETHPool() private view returns (uint) {
        return DPIETHVault.getAllPoolInETH();
    }

    function getDAIETHPool() private view returns (uint) {
        return DAIETHVault.getAllPoolInETH();
    }

    function getEachPool() private view returns (uint[] memory pools) {
        pools = new uint[](4);
        pools[0] = getHBTCWBTCPool();
        pools[1] = getWBTCETHPool();
        pools[2] = getDPIETHPool();
        pools[3] = getDAIETHPool();
    }

    /// @notice This function return only farms TVL
    function getAllPoolInETH() public view returns (uint) {
        uint[] memory pools = getEachPool();
        return pools[0] + pools[1] + pools[2] + pools[3];
    }

    function getAllPoolInUSD() public view returns (uint) {
        uint ETHPriceInUSD = uint(IChainlink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).latestAnswer()); // 8 decimals
        require(ETHPriceInUSD > 0, "ChainLink error");
        return getAllPoolInETH() * ETHPriceInUSD / 1e8;
    }

    function getCurrentCompositionPerc() external view returns (uint[] memory percentages) {
        uint[] memory pools = getEachPool();
        uint allPool = pools[0] + pools[1] + pools[2] + pools[3];
        percentages = new uint[](4);
        percentages[0] = pools[0] * 10000 / allPool;
        percentages[1] = pools[1] * 10000 / allPool;
        percentages[2] = pools[2] * 10000 / allPool;
        percentages[3] = pools[3] * 10000 / allPool;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
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
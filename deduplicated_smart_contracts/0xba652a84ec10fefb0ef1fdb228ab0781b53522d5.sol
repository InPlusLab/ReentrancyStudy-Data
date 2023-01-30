// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
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

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function userInfo(uint _pid, address _user) external view returns(uint amount, uint rewardDebt);
}

interface IDaoL1Vault is IERC20Upgradeable {
    function deposit(uint amount) external;
    function withdraw(uint share) external returns (uint);
    function getAllPoolInUSD() external view returns (uint);
    function getAllPoolInETH() external view returns (uint);
}

interface IChainlink {
    function latestAnswer() external view returns (int256);
}

contract TAStrategy is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable constant WETH = IERC20Upgradeable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20Upgradeable constant WBTC = IERC20Upgradeable(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20Upgradeable constant USDC = IERC20Upgradeable(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    IERC20Upgradeable constant WBTCETH = IERC20Upgradeable(0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58);
    IERC20Upgradeable constant USDCETH = IERC20Upgradeable(0x397FF1542f962076d0BFE58eA045FfA2d347ACa0);

    IDaoL1Vault public WBTCETHVault;
    IDaoL1Vault public USDCETHVault;

    IRouter constant router = IRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Sushi
    IMasterChef constant masterChef = IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);

    address public vault;
    uint public watermark; // In USD (18 decimals)
    uint public profitFeePerc;
    bool public mode; // Attack: true, Defence: false

    event InvestWBTCETH(uint WETHAmt, uint WBTCETHAmt);
    event InvestUSDCETH(uint WETHAmt, uint USDCETHAmt);
    event WithdrawWBTCETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawUSDCETH(uint lpTokenAmt, uint WETHAmt);
    event SwitchMode(uint lpTokenAmtFrom, uint lpTokenAmtTo, bool modeFrom, bool modeTo);
    event CollectProfitAndUpdateWatermark(uint currentWatermark, uint lastWatermark, uint fee);
    event AdjustWatermark(uint currentWatermark, uint lastWatermark);
    event Reimburse(uint WETHAmt);
    event EmergencyWithdraw(uint WETHAmt);

    modifier onlyVault {
        require(msg.sender == vault, "Only vault");
        _;
    }

    function initialize(address _WBTCETHVault, address _USDCETHVault, bool _mode) external initializer {
        WBTCETHVault = IDaoL1Vault(_WBTCETHVault);
        USDCETHVault = IDaoL1Vault(_USDCETHVault);

        profitFeePerc = 2000;
        mode = _mode;

        WETH.safeApprove(address(router), type(uint).max);
        WBTC.safeApprove(address(router), type(uint).max);
        USDC.safeApprove(address(router), type(uint).max);

        WBTCETH.safeApprove(address(WBTCETHVault), type(uint).max);
        WBTCETH.safeApprove(address(router), type(uint).max);
        USDCETH.safeApprove(address(USDCETHVault), type(uint).max);
        USDCETH.safeApprove(address(router), type(uint).max);
    }

    function invest(uint WETHAmt) external onlyVault {
        WETH.safeTransferFrom(vault, address(this), WETHAmt);
        uint halfWETHAmt = WETHAmt / 2;

        if (mode) { // Attack
            uint WBTCAmt = swap2(address(WETH), address(WBTC), halfWETHAmt, 0);
            (,,uint WBTCETHAmt) = router.addLiquidity(
                address(WBTC), address(WETH), WBTCAmt, halfWETHAmt, 0, 0, address(this), block.timestamp
            );
            WBTCETHVault.deposit(WBTCETHAmt);
            emit InvestWBTCETH(WETHAmt, WBTCETHAmt);
        } else { // Defence
            uint USDCAmt = swap2(address(WETH), address(USDC), halfWETHAmt, 0);
            (,,uint USDCETHAmt) = router.addLiquidity(
                address(USDC), address(WETH), USDCAmt, halfWETHAmt, 0, 0, address(this), block.timestamp
            );
            USDCETHVault.deposit(USDCETHAmt);
            emit InvestUSDCETH(WETHAmt, USDCETHAmt);
        }
    }

    /// @param amount Amount to withdraw in USD
    function withdraw(uint amount, uint[] calldata tokenPrice) external onlyVault returns (uint WETHAmt) {
        uint sharePerc = amount * 1e18 / getAllPoolInUSD();
        if (mode) WETHAmt = withdrawWBTCETH(sharePerc, tokenPrice[1]);
        else WETHAmt = withdrawUSDCETH(sharePerc, tokenPrice[2]);
        WETH.safeTransfer(vault, WETHAmt);
    }

    function withdrawWBTCETH(uint sharePerc, uint WBTCPriceInETH) private returns (uint) {
        uint WBTCETHAmt = WBTCETHVault.withdraw(WBTCETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint WBTCAmt, uint WETHAmt) = router.removeLiquidity(
            address(WBTC), address(WETH), WBTCETHAmt, 0, 0, address(this), block.timestamp
        );
        WETHAmt += swap2(address(WBTC), address(WETH), WBTCAmt, WBTCAmt * WBTCPriceInETH / 1e8);
        emit WithdrawWBTCETH(WBTCETHAmt, WETHAmt);
        return WETHAmt;
    }

    function withdrawUSDCETH(uint sharePerc, uint USDCPriceInETH) private returns (uint) {
        uint USDCETHAmt = USDCETHVault.withdraw(USDCETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint USDCAmt, uint WETHAmt) = router.removeLiquidity(
            address(USDC), address(WETH), USDCETHAmt, 0, 0, address(this), block.timestamp
        );
        WETHAmt += swap2(address(USDC), address(WETH), USDCAmt, USDCAmt * USDCPriceInETH / 1e6);
        emit WithdrawUSDCETH(USDCETHAmt, WETHAmt);
        return WETHAmt;
    }

    function switchMode(uint[] calldata tokenPrice) external onlyVault {
        if (mode) { // Attack switch to defence
            uint WBTCETHAmt = WBTCETHVault.withdraw(WBTCETHVault.balanceOf(address(this)));
            (uint WBTCAmt, uint WETHAmt) = router.removeLiquidity(
                address(WBTC), address(WETH), WBTCETHAmt, 0, 0, address(this), block.timestamp
            );
            // tokenPrice[0] = 1 WBTC Price In USDC
            uint USDCAmt = swap3(address(WBTC), address(USDC), WBTCAmt, WBTCAmt * tokenPrice[0] / 1e8);
            (,,uint USDCETHAmt) = router.addLiquidity(
                address(USDC), address(WETH), USDCAmt, WETHAmt, 0, 0, address(this), block.timestamp
            );
            USDCETHVault.deposit(USDCETHAmt);
            mode = false;
            emit SwitchMode(WBTCETHAmt, USDCETHAmt, true, false);
        } else { // Defence switch to attack
            uint USDCETHAmt = USDCETHVault.withdraw(USDCETHVault.balanceOf(address(this)));
            (uint USDCAmt, uint WETHAmt) = router.removeLiquidity(
                address(USDC), address(WETH), USDCETHAmt, 0, 0, address(this), block.timestamp
            );
            // tokenPrice[1] = 1 USDC Price In WBTC
            uint WBTCAmt = swap3(address(USDC), address(WBTC), USDCAmt, USDCAmt * tokenPrice[1] / 1e6);
            (,,uint WBTCETHAmt) = router.addLiquidity(
                address(WBTC), address(WETH), WBTCAmt, WETHAmt, 0, 0, address(this), block.timestamp
            );
            WBTCETHVault.deposit(WBTCETHAmt);
            mode = true;
            emit SwitchMode(USDCETHAmt, WBTCETHAmt, false, true);
        }
    }

    function collectProfitAndUpdateWatermark() public onlyVault returns (uint fee) {
        uint currentWatermark = getAllPoolInUSD();
        uint lastWatermark = watermark;
        if (currentWatermark > lastWatermark) {
            uint profit = currentWatermark - lastWatermark;
            fee = profit * profitFeePerc / 10000;
            watermark = currentWatermark;
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
    function reimburse(uint amount) external onlyVault returns (uint WETHAmt) {
        if (mode) withdrawWBTCETH(amount * 1e18 / getWBTCETHPoolInETH(), 0);
        else withdrawUSDCETH(amount * 1e18 / getUSDCETHPoolInETH(), 0);
        WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        emit Reimburse(WETHAmt);
    }

    function emergencyWithdraw() external onlyVault {
        // 1e18 == 100% of share
        if (mode) withdrawWBTCETH(1e18, 0);
        else withdrawUSDCETH(1e18, 0);
        uint WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        watermark = 0;
        emit EmergencyWithdraw(WETHAmt);
    }

    function swap2(address from, address to, uint amount, uint amountOutMin) private returns (uint) {
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        return router.swapExactTokensForTokens(amount, amountOutMin, path, address(this), block.timestamp)[1];
    }

    function swap3(address from, address to, uint amount, uint amountOutMin) private returns (uint) {
        address[] memory path = new address[](3);
        path[0] = from;
        path[1] = address(WETH);
        path[2] = to;
        return router.swapExactTokensForTokens(amount, amountOutMin, path, address(this), block.timestamp)[2];
    }

    function setVault(address _vault) external {
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

    function getWBTCETHPoolInETH() private view returns (uint) {
        uint WBTCETHVaultPool = WBTCETHVault.getAllPoolInETH();
        if (WBTCETHVaultPool == 0) return 0;
        return WBTCETHVaultPool * WBTCETHVault.balanceOf(address(this)) / WBTCETHVault.totalSupply();
    }

    function getUSDCETHPoolInETH() private view returns (uint) {
        uint USDCETHVaultPool = USDCETHVault.getAllPoolInETH();
        if (USDCETHVaultPool == 0) return 0;
        return USDCETHVaultPool * USDCETHVault.balanceOf(address(this)) / USDCETHVault.totalSupply();
    }

    /// @notice This function return only farms TVL in ETH
    function getAllPoolInETH() public view returns (uint) {
        if (mode) return getWBTCETHPoolInETH(); // Attack
        else return getUSDCETHPoolInETH(); // Defence
    }

    function getAllPoolInUSD() public view returns (uint) {
        uint ETHPriceInUSD = uint(IChainlink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).latestAnswer()); // 8 decimals
        require(ETHPriceInUSD > 0, "ChainLink error");
        return getAllPoolInETH() * ETHPriceInUSD / 1e8;
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
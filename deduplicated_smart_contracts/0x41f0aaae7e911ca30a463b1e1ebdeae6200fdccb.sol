// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ICurvePool.sol";
import "./interfaces/ICurvePool2.sol";
import "./TangoSmartWallet.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/ITangoSmartWallet.sol";
import "./interfaces/ITangoFactory.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/ISecretBridge.sol";

contract Constant { 
    address public constant uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public constant uniswapV2Factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;
    address public constant busd = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address public constant ust = 0xa47c8bf37f92aBed4A126BDA807A7b7498661acD;
    address public constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant tango = 0x182F4c4C97cd1c24E1Df8FC4c053E5C47bf53Bef;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant convex = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant curvePool = 0xb6c057591E073249F2D9D88Ba59a46CFC9B59EdB;
    address public constant curveUSTPool = 0x890f4e345B1dAED0367A877a1612f86A1f86985f;
    address public constant curveLpToken = 0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B;
    address public constant curveExchangeBUSD = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
    address public constant convexDeposit = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address public constant convexWithDrawAndClaim = 0x602c4cD53a715D8a7cf648540FAb0d3a2d546560;
    uint256 public constant pidBUSD = 3;
}

contract TangoFactoryBUSD is ITangoFactory, Constant, Ownable { 
    using SafeERC20 for IERC20;
    struct UserInfo { 
        uint256 totalCurveLpStaked;
        mapping(address => uint256) totalTokenInvest;
    }

    uint256 public feeOut;
    uint256 public feeIn;
    address public feeCollector;
    address public router;
    mapping (address => address) public userSW;
    mapping (address => bool) public isSw;
    mapping (address => UserInfo) public usersInfo;
    address[] public allSWs;

    modifier onlyRouter() {
        require(msg.sender == router,"Only-router");
        _;
    }
    constructor(address _router) {
        router = _router;
        IERC20(curveLpToken).safeApprove(curvePool, type(uint256).max);
        IERC20(usdc).safeApprove(curveUSTPool, type(uint256).max);
        IERC20(dai).safeApprove(curveUSTPool, type(uint256).max);
        IERC20(usdt).safeApprove(curveUSTPool, type(uint256).max);
        IERC20(ust).safeApprove(curveUSTPool, type(uint256).max);

        IERC20(usdc).safeApprove(curvePool, type(uint256).max);
        IERC20(dai).safeApprove(curvePool, type(uint256).max);
        IERC20(usdt).safeApprove(curvePool, type(uint256).max);
        IERC20(busd).safeApprove(curvePool, type(uint256).max);
    }

    /**
     * @dev swap token at UniswapV2Router with path fromToken - WETH - toToken
     * @param _fromToken is source token
     * @param _toToken is des token
     * @param _swapAmount is amount of source token to swap
     * @return _amountOut is the amount of _toToken 
     */
    function _uniswapSwapToken(
        address _router,
        address _fromToken,
        address _toToken,
        uint256 _swapAmount
    ) private returns (uint256 _amountOut) {
        if(IERC20(_fromToken).allowance(address(this), _router) == 0) {
            IERC20(_fromToken).safeApprove(_router, type(uint256).max);
        }        
        address[] memory path;
        if(_fromToken == wETH || _toToken == wETH) {
            path = new address[](2);
            path[0] = _fromToken == wETH ? wETH : _fromToken;
			path[1] = _toToken == wETH ? wETH : _toToken;
        } else { 
            path = new address[](3);
            path[0] = _fromToken;
            path[1] = wETH;
            path[2] = _toToken;
        }
       
        _amountOut = IUniswapV2Router02(_router)
            .swapExactTokensForTokens(
            _swapAmount,
            0,
            path,
            address(this),
            deadline
        )[path.length - 1];
    }


    /**
     * @dev add liquidity to Curve at UST poool
     * @param _curvePool is curve liqudity pool address
     * @param _param is [ust, dai, usdc, usdt]
     * @return amount of lp token
     */
    function _curveAddLiquidity(address _curvePool, uint256[4] memory _param) private returns(uint256) { 
        return ICurvePool(_curvePool).add_liquidity(_param, 0);
    }

    /**
     * @dev add liquidity to Curve at UST poool
     * @param _curvePool is curve liqudity pool address
     * @param _curveLpBalance is amount lp token
     * @param i is index of toke
     * @return amount of lp token
     */
    function _curveRemoveLiquidity(address _curvePool, uint256 _curveLpBalance, int128 i) private returns(uint256) { 
        return ICurvePool(_curvePool).remove_liquidity_one_coin(_curveLpBalance, i, 0);
    }

    function calculateLpAmount(address _curvePool, uint256 _daiAmount) private returns (uint256){
        return ICurvePool(_curvePool).calc_token_amount([_daiAmount, 0, 0, 0], false);
    }
    
    function exchangeUnderlying(address _curvePool, uint256 _dx, int128 i, int128 j) private returns (uint256) {
        return ICurvePool(_curvePool).exchange_underlying(i, j, _dx, 0);
    }
    function secretInvest(address _user, address _token, uint256 _amount) external override onlyRouter() {
        address sw = userSW[_user];
        if(sw == address(0)) {
            bytes memory bytecode = type(TangoSmartWallet).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(address(this), _user));
            assembly {
                sw := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }
            TangoSmartWallet(sw).initialize(_user, curveLpToken, convexDeposit);
            userSW[_user] = sw;
            isSw[sw] = true;
            allSWs.push(sw);
        }
        if(feeIn > 0) {
            uint feeAmount = _amount * feeIn / 10000;
            IERC20(_token).safeTransfer(feeCollector, feeAmount);
            _amount = _amount - feeAmount;
        }
        uint256 amountUSDC = exchangeUnderlying(curveUSTPool, _amount, 0, 2);
        uint256 balanceLP = IERC20(curveLpToken).balanceOf(address(this));
        ICurvePool2(curvePool).add_liquidity([0, amountUSDC, 0, 0], 0); 
        uint256 balanceDiff = IERC20(curveLpToken).balanceOf(address(this)) - balanceLP;
        IERC20(curveLpToken).safeTransfer(sw, balanceDiff);
        ITangoSmartWallet(sw).stake(convexDeposit, pidBUSD);
        UserInfo storage userInfo = usersInfo[_user];
        userInfo.totalCurveLpStaked =  userInfo.totalCurveLpStaked + balanceDiff;
        userInfo.totalTokenInvest[_token] = userInfo.totalTokenInvest[_token] + _amount;
    }

     /**
     * @dev invest function, create tango smart wallet for user at 1st time invest
     * store the TSW in userSw and isSW set as true
     * swap DAI, USDT, USDC to UST, then charge fee if feeIn greater than 0
     * add amount UST to Curve pool (UST) then call TSW for staking to Convex
     * @param _param is [busd, dai, usdc, usdt]
     */
    function invest4(uint256[4] memory _param) external override { 
        address sw = userSW[msg.sender];
        if(sw == address(0)) {
            bytes memory bytecode = type(TangoSmartWallet).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(address(this), msg.sender));
            assembly {
                sw := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }
            TangoSmartWallet(sw).initialize(msg.sender, curveLpToken, convexDeposit);
            userSW[msg.sender] = sw;
            isSw[sw] = true;
            allSWs.push(sw);
        }
        uint256 balanceDAI = IERC20(dai).balanceOf(address(this));
        for(uint i = 0; i < _param.length; i++) {
            if(_param[i] > 0) {
                if(i == 3) {
                    IERC20(busd).safeTransferFrom(msg.sender, address(this), _param[i]);
                    exchangeUnderlying(curvePool, _param[i], 3, 0);
                }
                if(i == 2) {
                     IERC20(usdt).safeTransferFrom(msg.sender, address(this), _param[i]);
                    exchangeUnderlying(curvePool, _param[i], 2, 0);
                }
                if( i == 1) {
                    IERC20(usdc).safeTransferFrom(msg.sender, address(this), _param[i]);
                    exchangeUnderlying(curvePool, _param[i], 1, 0);
                }
            }
        }
        IERC20(dai).safeTransferFrom(msg.sender, address(this), _param[0]); // take DAI from user wallet
        balanceDAI = IERC20(dai).balanceOf(address(this)) - balanceDAI; // total deposit to Curve balance
        if(feeIn > 0) {
            uint feeAmount = balanceDAI * feeIn / 10000;
            IERC20(ust).safeTransfer(feeCollector, feeAmount);
            balanceDAI = balanceDAI - feeAmount;
        }
        uint256 balanceLP = IERC20(curveLpToken).balanceOf(address(this));
        ICurvePool2(curvePool).add_liquidity([balanceDAI, 0, 0, 0], 0); 
        uint256 balanceDiff = IERC20(curveLpToken).balanceOf(address(this)) - balanceLP;
        IERC20(curveLpToken).safeTransfer(sw, balanceDiff);
        ITangoSmartWallet(sw).stake(convexDeposit, pidBUSD);
        UserInfo storage userInfo = usersInfo[msg.sender];
        userInfo.totalCurveLpStaked =  userInfo.totalCurveLpStaked + balanceDiff;
        userInfo.totalTokenInvest[dai] = userInfo.totalTokenInvest[dai] + balanceDAI;
    }

    function withdraw(uint256 _amount, bool isClaimReward) external override {
        address sw = userSW[msg.sender];
        require(sw != address(0), "User-dont-have-wallet");
        require(msg.sender == ITangoSmartWallet(sw).owner(), "Only-sw-owner");
        uint256 lpAmount = calculateLpAmount(curveExchangeBUSD ,_amount) * 102 / 100; // extra 2%
        ITangoSmartWallet(sw).withdraw(convexWithDrawAndClaim, lpAmount);
        uint256 balanceUSDC = IERC20(usdc).balanceOf(address(this));
        ICurvePool2(curvePool).remove_liquidity_one_coin(lpAmount, 1, 0);
        uint256 withdrawBalance = IERC20(usdc).balanceOf(address(this)) - balanceUSDC;
        IERC20(usdc).safeTransfer(msg.sender, withdrawBalance);
        if(isClaimReward) {
            userClaimReward();
        }
    }

    function secretWithdraw(address _user, uint256 _amount) external override onlyRouter() {
        address sw = userSW[_user];
        // expect that _amount is UST amunt, equal to 
        uint256 lpAmount = calculateLpAmount(curveExchangeBUSD ,_amount) * 102 / 100; // extra 2%
        ITangoSmartWallet(sw).withdraw(convexWithDrawAndClaim, lpAmount);
        uint256 balanceUSDC = IERC20(usdc).balanceOf(address(this));
        ICurvePool2(curvePool).remove_liquidity_one_coin(lpAmount, 1, 0);
        uint256 swapBalance = IERC20(usdc).balanceOf(address(this)) - balanceUSDC;
        uint256 balanceUST = exchangeUnderlying(curveUSTPool, swapBalance, 2, 0);
        IERC20(ust).safeTransfer(_user, balanceUST);
    }


     /**
     * @dev swap reward received from convex staking program to SEFI or TANGO
     * @param _amountCrv is amount Curve token received from Convex Pool
     * @param _amountCVX is amount Convex token received from Convex Pool
     * @param _owner is address of smart wallet owner that receive reward
     */
    function swapReward(uint256 _amountCrv, uint256 _amountCVX, address _owner) private { 
        uint256 wETHBalanceBefore = IERC20(wETH).balanceOf(address(this));
        _uniswapSwapToken(uniRouter, crv, wETH, _amountCrv);
        _uniswapSwapToken(sushiRouter, convex, wETH, _amountCVX);
        uint256 tangoBalanceBefore = IERC20(tango).balanceOf(address(this));
        uint256 wETHBalanceAfter = IERC20(wETH).balanceOf(address(this));
        _uniswapSwapToken(uniRouter, wETH, tango, wETHBalanceAfter - wETHBalanceBefore);
        uint256 tangoBalanceAfter = IERC20(tango).balanceOf(address(this));
        uint256 rewardAmount = tangoBalanceAfter - tangoBalanceBefore;
        if(feeOut > 0) {
            uint feeAmout = rewardAmount * feeOut / 10000;
            IERC20(tango).safeTransfer(feeCollector, feeAmout);
            rewardAmount = rewardAmount - feeAmout;
        }
        IERC20(tango).safeTransfer(_owner, rewardAmount);
    }


    function adminClaimRewardForSCRT(address _secretBridge, address _secretSW, bytes memory _recipient) external override onlyOwner() { 
        uint256 wETHBalanceBefore = IERC20(wETH).balanceOf(address(this));
        (uint256 amountCRV, uint256 amountCVX) = ITangoSmartWallet(_secretSW).claimReward(convexWithDrawAndClaim);
        _uniswapSwapToken(uniRouter, crv, wETH, amountCRV);
        _uniswapSwapToken(sushiRouter, convex, wETH, amountCVX);
        uint256 wETHBalanceAfter = IERC20(wETH).balanceOf(address(this));
        uint256 balanceDiff = wETHBalanceAfter - wETHBalanceBefore;
        IWETH(wETH).withdraw(balanceDiff);
        ISecretBridge(_secretBridge).swap{value: balanceDiff}(_recipient);
    }


    function userClaimReward() public override { 
        address sw = userSW[msg.sender];
        require(sw != address(0) && ITangoSmartWallet(sw).owner() == msg.sender, "Forbiden");
        (uint256 amountCRV, uint256 amountCVX) = ITangoSmartWallet(sw).claimReward(convexWithDrawAndClaim);
        swapReward(amountCRV, amountCVX, msg.sender);
    }

    receive() external payable {
        
    }

    function getStakedAmount(address _user) external returns (uint256, uint256) { 
         address sw = userSW[_user];
         require(sw != address(0), "Invalid-user"); 
         uint256 stakedBalance = ITangoSmartWallet(sw).stakedBalance();
         uint256 ustAmount = calculateLpAmount(curvePool ,stakedBalance);
         return (stakedBalance, ustAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
interface ICurvePool { 
    function add_liquidity(uint256[4] memory, uint256) external returns(uint256);
    function remove_liquidity_one_coin(uint256, int128, uint256) external returns(uint256);
    function calc_token_amount(uint256[4] memory, bool) external returns(uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICurvePool2 { 
    function add_liquidity(uint256[4] memory, uint256) external;
    function remove_liquidity_one_coin(uint256, int128, uint256) external;
    function calc_token_amount(uint256[4] memory, bool) external returns(uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IConvexDeposit.sol";
import "./interfaces/ITangoSmartWallet.sol";
import "./interfaces/IConvexWithdraw.sol";
import "./interfaces/ITangoFactory.sol";

contract TangoSmartWallet is ITangoSmartWallet { 
    using SafeERC20 for IERC20;
    address public immutable factory;
    address public lpToken;
    uint256 public override stakedBalance;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant convex = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public override owner;


    event Stake(uint256 indexed amount);
    event WithDraw(uint256 indexed amount);
    modifier onlyFactory() {
        require(msg.sender == factory, "Opps!Only-factory");
        _;
    }
    constructor() public {
        factory = msg.sender;
    }
    function initialize(address _owner, address _lp, address _pool) external override onlyFactory() { 
        owner = _owner;
        lpToken = _lp;
        IERC20(_lp).approve(_pool, type(uint256).max);
    }

    function stake(address _pool, uint256 _pid) external override onlyFactory() {
        uint balance = IERC20(lpToken).balanceOf(address(this));
        require(balance > 0, "Invalid-amount");
        IConvexDeposit(_pool).depositAll(_pid, true);
        stakedBalance = stakedBalance + balance;
        emit Stake(balance);
    }

    function withdraw(address _pool, uint256 _amount) external override onlyFactory() {
        IConvexWithdraw(_pool).withdrawAndUnwrap(_amount, false);
        IERC20(lpToken).safeTransfer(msg.sender, _amount);  
        stakedBalance = stakedBalance - _amount;
        emit WithDraw(_amount);
    }

    function claimReward(address _pool) external override onlyFactory() returns (uint256, uint256) {
        IConvexWithdraw(_pool).getReward();
        uint balanceCrv = IERC20(crv).balanceOf(address(this));
        uint balanceCvx = IERC20(convex).balanceOf(address(this));
        return (
            balanceCrv, 
            balanceCvx
        );
    } 

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ITangoSmartWallet { 
    function owner()  external returns(address);
    function initialize(address _owner, address _lp, address _pool) external;
    function stake(address _pool, uint256 _pid) external;
    function stakedBalance() external returns(uint256);
    function withdraw(address _pool, uint256 _amount) external;
    function claimReward(address) external returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ITangoFactory { 
    function withdraw(uint256 _amount, bool _isClaimReward) external;
    function invest4(uint256[4] memory _param) external;
    function secretInvest(address, address, uint256) external;
    function secretWithdraw(address , uint256) external;
    function adminClaimRewardForSCRT(address, address, bytes memory) external;
    function userClaimReward() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISecretBridge {
    function swap(bytes memory _recipient)
        external
        payable;
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
interface IConvexDeposit{
    function depositAll(uint256 _pid, bool _stake) external; 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IConvexWithdraw{
    function withdrawAndUnwrap(uint256, bool) external;
    function balanceOf(address account) external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function getReward() external;
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
  "metadata": {
    "useLiteralContent": true
  },
  "libraries": {}
}
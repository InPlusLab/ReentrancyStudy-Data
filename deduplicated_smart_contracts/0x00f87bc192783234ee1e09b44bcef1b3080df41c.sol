/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

/**
 *Submitted for verification at Etherscan.io on 12-14-2020
*/
/*

    Copyright 2020 Charge Factory.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface IChargeFactory {
    function getCharge(address baseToken, address quoteToken) external view returns (address);
}

// lib/ReentrancyGuard.sol
/**
 * @title ReentrancyGuard
 * @author Charge Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

// lib/SafeERC20.sol
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// lib/SafeMath.sol
/**
 * @title SafeMath
 * @author Charge Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

// intf/ICharge.sol
interface ICharge {
    function init(
        address owner,
        address supervisor,
        address maintainer,
        address baseToken,
        address quoteToken,
        address oracle,
        uint256 lpFeeRate,
        uint256 mtFeeRate,
        uint256 k,
        uint256 gasPriceLimit
    ) external;

    function transferOwnership(address newOwner) external;

    function claimOwnership() external;

    function sellBaseToken(
        uint256 amount,
        uint256 minReceiveQuote,
        bytes calldata data
    ) external returns (uint256);

    function buyBaseToken(
        uint256 amount,
        uint256 maxPayQuote,
        bytes calldata data
    ) external returns (uint256);

    function querySellBaseToken(uint256 amount) external view returns (uint256 receiveQuote);

    function queryBuyBaseToken(uint256 amount) external view returns (uint256 payQuote);

    function getExpectedTarget() external view returns (uint256 baseTarget, uint256 quoteTarget);

    function depositBaseTo(address to, uint256 amount) external returns (uint256);

    function withdrawBase(uint256 amount) external returns (uint256);

    function withdrawAllBase() external returns (uint256);

    function depositQuoteTo(address to, uint256 amount) external returns (uint256);

    function withdrawQuote(uint256 amount) external returns (uint256);

    function withdrawAllQuote() external returns (uint256);

    function _BASE_CAPITAL_TOKEN_() external view returns (address);

    function _QUOTE_CAPITAL_TOKEN_() external view returns (address);

    function _BASE_TOKEN_() external returns (address);

    function _QUOTE_TOKEN_() external returns (address);
}

// intf/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

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
}

// intf/IWETH.sol
interface IWETH {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}
// ChargeEthProxy.sol
/**
 * @title Charge Eth Proxy
 * @author Charge Breeder
 *
 * @notice Handle ETH-WETH converting for users.
 */
contract ChargeEthProxy is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public _Charge_Factory_;
    address payable public _WETH_;

    // ============ Events ============

    event ProxySellEthToToken(
        address indexed seller,
        address indexed quoteToken,
        uint256 payEth,
        uint256 receiveToken
    );

    event ProxyBuyEthWithToken(
        address indexed buyer,
        address indexed quoteToken,
        uint256 receiveEth,
        uint256 payToken
    );

    event ProxySellTokenToEth(
        address indexed seller,
        address indexed baseToken,
        uint256 payToken,
        uint256 receiveEth
    );

    event ProxyBuyTokenWithEth(
        address indexed buyer,
        address indexed baseToken,
        uint256 receiveToken,
        uint256 payEth
    );

    event ProxyDepositEthAsBase(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyWithdrawEthAsBase(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyDepositEthAsQuote(address indexed lp, address indexed Charge, uint256 ethAmount);

    event ProxyWithdrawEthAsQuote(address indexed lp, address indexed Charge, uint256 ethAmount);

    // ============ Functions ============

    constructor(address ChargeFactory, address payable weth) public {
        _Charge_Factory_ = ChargeFactory;
        _WETH_ = weth;
    }

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVED_YOUR_ETH_:)");
    }

    function sellEthToToken(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 minReceiveTokenAmount
    ) external payable preventReentrant returns (uint256 receiveTokenAmount) {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        receiveTokenAmount = ICharge(Charge).sellBaseToken(ethAmount, minReceiveTokenAmount, "");
        _transferOut(quoteTokenAddress, msg.sender, receiveTokenAmount);
        emit ProxySellEthToToken(msg.sender, quoteTokenAddress, ethAmount, receiveTokenAmount);
        return receiveTokenAmount;
    }

    function buyEthWithToken(
        address quoteTokenAddress,
        uint256 ethAmount,
        uint256 maxPayTokenAmount
    ) external preventReentrant returns (uint256 payTokenAmount) {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        payTokenAmount = ICharge(Charge).queryBuyBaseToken(ethAmount);
        _transferIn(quoteTokenAddress, msg.sender, payTokenAmount);
        IERC20(quoteTokenAddress).safeApprove(Charge, payTokenAmount);
        ICharge(Charge).buyBaseToken(ethAmount, maxPayTokenAmount, "");
        IWETH(_WETH_).withdraw(ethAmount);
        msg.sender.transfer(ethAmount);
        emit ProxyBuyEthWithToken(msg.sender, quoteTokenAddress, ethAmount, payTokenAmount);
        return payTokenAmount;
    }

    function sellTokenToEth(
        address baseTokenAddress,
        uint256 tokenAmount,
        uint256 minReceiveEthAmount
    ) external preventReentrant returns (uint256 receiveEthAmount) {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IERC20(baseTokenAddress).safeApprove(Charge, tokenAmount);
        _transferIn(baseTokenAddress, msg.sender, tokenAmount);
        receiveEthAmount = ICharge(Charge).sellBaseToken(tokenAmount, minReceiveEthAmount, "");
        IWETH(_WETH_).withdraw(receiveEthAmount);
        msg.sender.transfer(receiveEthAmount);
        emit ProxySellTokenToEth(msg.sender, baseTokenAddress, tokenAmount, receiveEthAmount);
        return receiveEthAmount;
    }

    function buyTokenWithEth(
        address baseTokenAddress,
        uint256 tokenAmount,
        uint256 maxPayEthAmount
    ) external payable preventReentrant returns (uint256 payEthAmount) {
        require(msg.value == maxPayEthAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        payEthAmount = ICharge(Charge).queryBuyBaseToken(tokenAmount);
        IWETH(_WETH_).deposit{value: payEthAmount}();
        IWETH(_WETH_).approve(Charge, payEthAmount);
        ICharge(Charge).buyBaseToken(tokenAmount, maxPayEthAmount, "");
        _transferOut(baseTokenAddress, msg.sender, tokenAmount);
        uint256 refund = maxPayEthAmount.sub(payEthAmount);
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
        emit ProxyBuyTokenWithEth(msg.sender, baseTokenAddress, tokenAmount, payEthAmount);
        return payEthAmount;
    }

    function depositEthAsBase(uint256 ethAmount, address quoteTokenAddress)
        external
        payable
        preventReentrant
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        ICharge(Charge).depositBaseTo(msg.sender, ethAmount);
        emit ProxyDepositEthAsBase(msg.sender, Charge, ethAmount);
    }

    function withdrawEthAsBase(uint256 ethAmount, address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawBase(ethAmount);

        // transfer remain shares back to msg.sender
        lpBalance = IERC20(ethLpToken).balanceOf(address(this));
        IERC20(ethLpToken).transfer(msg.sender, lpBalance);

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsBase(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function withdrawAllEthAsBase(address quoteTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(_WETH_, quoteTokenAddress);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._BASE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawAllBase();

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsBase(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function depositEthAsQuote(uint256 ethAmount, address baseTokenAddress)
        external
        payable
        preventReentrant
    {
        require(msg.value == ethAmount, "ETH_AMOUNT_NOT_MATCH");
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        IWETH(_WETH_).deposit{value: ethAmount}();
        IWETH(_WETH_).approve(Charge, ethAmount);
        ICharge(Charge).depositQuoteTo(msg.sender, ethAmount);
        emit ProxyDepositEthAsQuote(msg.sender, Charge, ethAmount);
    }

    function withdrawEthAsQuote(uint256 ethAmount, address baseTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._QUOTE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawQuote(ethAmount);

        // transfer remain shares back to msg.sender
        lpBalance = IERC20(ethLpToken).balanceOf(address(this));
        IERC20(ethLpToken).transfer(msg.sender, lpBalance);

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsQuote(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    function withdrawAllEthAsQuote(address baseTokenAddress)
        external
        preventReentrant
        returns (uint256 withdrawAmount)
    {
        address Charge = IChargeFactory(_Charge_Factory_).getCharge(baseTokenAddress, _WETH_);
        require(Charge != address(0), "Charge_NOT_EXIST");
        address ethLpToken = ICharge(Charge)._QUOTE_CAPITAL_TOKEN_();

        // transfer all pool shares to proxy
        uint256 lpBalance = IERC20(ethLpToken).balanceOf(msg.sender);
        IERC20(ethLpToken).transferFrom(msg.sender, address(this), lpBalance);
        ICharge(Charge).withdrawAllQuote();

        // because of withdraw penalty, withdrawAmount may not equal to ethAmount
        // query weth amount first and than transfer ETH to msg.sender
        uint256 wethAmount = IERC20(_WETH_).balanceOf(address(this));
        IWETH(_WETH_).withdraw(wethAmount);
        msg.sender.transfer(wethAmount);
        emit ProxyWithdrawEthAsQuote(msg.sender, Charge, wethAmount);
        return wethAmount;
    }

    // ============ Helper Functions ============

    function _transferIn(
        address tokenAddress,
        address from,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransferFrom(from, address(this), amount);
    }

    function _transferOut(
        address tokenAddress,
        address to,
        uint256 amount
    ) internal {
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}
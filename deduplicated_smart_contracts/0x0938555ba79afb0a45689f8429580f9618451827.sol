/**
 *Submitted for verification at Etherscan.io on 2020-02-23
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/IHolder.sol

pragma solidity ^0.5.0;



contract IIFlashLoan {
    function _flashLoan(IERC20 asset, uint256 amount, bytes memory data) internal;
    function _repayFlashLoan(IERC20 token, uint256 amount) internal;
}


contract IIExchange {
    function _exchange(IERC20 fromToken, IERC20 toToken, uint256 amount) internal returns(uint256);
}


contract IIOracle {
    function _getPrice(IERC20 token) internal view returns (uint256);
}


contract IIProtocol {
    function collateralAmount(IERC20 token) public returns(uint256);
    function borrowAmount(IERC20 token) public returns(uint256);
    function pnl(IERC20 collateral, IERC20 debt, uint256 leverageRatio) public returns(uint256);

    function _pnl(IERC20 collateral, IERC20 debt) internal returns(uint256);
    function _deposit(IERC20 token, uint256 amount) internal;
    function _redeem(IERC20 token, uint256 amount) internal;
    function _redeemAll(IERC20 token) internal;
    function _borrow(IERC20 token, uint256 amount) internal;
    function _repay(IERC20 token, uint256 amount) internal;
}


contract IHolder is IIFlashLoan, IIExchange, IIProtocol {
    function stopLoss() public view returns(uint256);
    function takeProfit() public view returns(uint256);

    function openPosition(
        IERC20 collateral,
        IERC20 debt,
        uint256 amount,
        uint256 leverageRatio,
        uint256 _stopLoss,
        uint256 _takeProfit
    )
        external
        payable
        returns(uint256);

    function closePosition(
        IERC20 collateral,
        IERC20 debt,
        address user
    )
        external;
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;




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
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/lib/UniversalERC20.sol

pragma solidity ^0.5.0;






library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IERC20 token, address to, uint256 amount) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (isETH(token)) {
            address(uint160(to)).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalApprove(IERC20 token, address to, uint256 amount) internal {
        if (!isETH(token)) {
            if (amount > 0 && token.allowance(address(this), to) > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, amount);
        }
    }

    function universalInfiniteApproveIfNeeded(IERC20 token, address to) internal {
        if (!isETH(token)) {
            if ((token.allowance(address(this), to) >> 255) == 0) {
                token.safeApprove(to, uint256(-1));
            }
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalSymbol(IERC20 token) internal view returns (string memory) {
        if (isETH(token)) {
            return "ETH";
        } else {
            return ERC20Detailed(address(token)).symbol();
        }
    }

    function universalDecimals(IERC20 token) internal view returns (uint256) {

        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall.gas(5000)(
            abi.encodeWithSignature("decimals()")
        );
        if (!success) {
            (success, data) = address(token).staticcall.gas(5000)(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return success ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS));
    }
}

// File: contracts/HolderBase.sol

pragma solidity ^0.5.0;






contract HolderBase is IHolder {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    address public delegate;
    address public owner = msg.sender;
    uint256 private _stopLoss;
    uint256 private _takeProfit;

    modifier onlyOwner {
        require(msg.sender == owner, "Access denied");
        _;
    }

    modifier onlyCallback {
        require(msg.sender == address(this), "Access denied");
        _;
    }

    function stopLoss() public view returns(uint256) {
        return _stopLoss;
    }

    function takeProfit() public view returns(uint256) {
        return _takeProfit;
    }

    function() external payable {
        require(msg.sender != tx.origin);
    }

    function pnl(IERC20 collateral, IERC20 debt, uint256 leverageRatio) public returns(uint256) {
        return _pnl(collateral, debt).mul(leverageRatio.sub(1)).div(leverageRatio);
    }

    function openPosition(
        IERC20 collateral,
        IERC20 debt,
        uint256 amount,
        uint256 leverageRatio,
        uint256 stopLossValue,
        uint256 takeProfitValue
    )
        external
        payable
        onlyOwner
        returns(uint256)
    {
        _stopLoss = stopLossValue;
        _takeProfit = takeProfitValue;

        debt.universalTransferFrom(msg.sender, address(this), amount);

        _flashLoan(
            debt,
            amount.mul(leverageRatio.sub(1)),
            abi.encodeWithSelector(
                this.openPositionCallback.selector,
                collateral,
                debt,
                amount,
                leverageRatio
                // repayAmount added dynamically in executeOperation
            )
        );

        return collateralAmount(collateral);
    }

    function openPositionCallback(
        IERC20 collateral,
        IERC20 debt,
        uint256 amount,
        uint256 leverageRatio,
        uint256 repayAmount
    )
        external
        onlyCallback
    {
        uint256 value = _exchange(debt, collateral, amount.mul(leverageRatio));
        _deposit(collateral, value);
        _borrow(debt, repayAmount);
        _repayFlashLoan(debt, repayAmount);
    }

    function closePosition(
        IERC20 collateral,
        IERC20 debt,
        address user
    )
        external
        onlyOwner
    {
        uint256 borrowedAmount = borrowAmount(debt);

        _flashLoan(
            debt,
            borrowedAmount,
            abi.encodeWithSelector(
                this.closePositionCallback.selector,
                collateral,
                debt,
                user,
                borrowedAmount
                // repayAmount added dynamically in executeOperation
            )
        );
    }

    function closePositionCallback(
        IERC20 collateral,
        IERC20 debt,
        address user,
        uint256 borrowedAmount,
        uint256 repayAmount
    )
        external
        onlyCallback
    {
        _repay(debt, borrowedAmount);
        _redeemAll(collateral);
        uint256 returnedAmount = _exchange(collateral, debt, collateral.universalBalanceOf(address(this)));
        _repayFlashLoan(debt, repayAmount);
        debt.universalTransfer(user, returnedAmount.sub(repayAmount));
    }
}

// File: contracts/interface/aave/IFlashLoanReceiver.sol

pragma solidity ^0.5.0;

interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}

// File: contracts/interface/aave/ILendingPool.sol

pragma solidity ^0.5.0;

interface ILendingPool {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
    function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;
    function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
    function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params) external;
}

// File: contracts/mixins/FlashLoanAave.sol

pragma solidity ^0.5.0;








contract FlashLoanAave is IIFlashLoan {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    ILendingPool public constant POOL = ILendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    address public constant CORE = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    function _flashLoan(IERC20 token, uint256 amount, bytes memory data) internal {
        POOL.flashLoan(
            address(this),
            token.isETH() ? 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE : address(token),
            amount,
            data
        );
    }

    function _repayFlashLoan(IERC20 token, uint256 amount) internal {
        token.universalTransfer(CORE, amount);
    }

    // Callback for Aave flashLoan
    function executeOperation(
        address /*reserve*/,
        uint256 amount,
        uint256 fee,
        bytes calldata params
    )
        external
    {
        require(msg.sender == address(POOL), "Access denied, only pool alowed");
        (bool success, bytes memory data) = address(this).call(abi.encodePacked(params, amount.add(fee)));
        require(success, string(abi.encodePacked("External call failed: ", data)));
    }
}

// File: contracts/interface/IOneSplit.sol

pragma solidity ^0.5.0;



contract IOneSplit {

    // disableFlags = FLAG_UNISWAP + FLAG_KYBER + ...
    uint256 constant public FLAG_UNISWAP = 0x01;
    uint256 constant public FLAG_KYBER = 0x02;
    uint256 constant public FLAG_KYBER_UNISWAP_RESERVE = 0x100000000; // Turned off by default
    uint256 constant public FLAG_KYBER_OASIS_RESERVE = 0x200000000; // Turned off by default
    uint256 constant public FLAG_KYBER_BANCOR_RESERVE = 0x400000000; // Turned off by default
    uint256 constant public FLAG_BANCOR = 0x04;
    uint256 constant public FLAG_OASIS = 0x08;
    uint256 constant public FLAG_COMPOUND = 0x10;
    uint256 constant public FLAG_FULCRUM = 0x20;
    uint256 constant public FLAG_CHAI = 0x40;
    uint256 constant public FLAG_AAVE = 0x80;
    uint256 constant public FLAG_SMART_TOKEN = 0x100;
    uint256 constant public FLAG_MULTI_PATH_ETH = 0x200; // Turned off by default

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags // 1 - Uniswap, 2 - Kyber, 4 - Bancor, 8 - Oasis, 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution // [Uniswap, Kyber, Bancor, Oasis]
        );

    function swap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution, // [Uniswap, Kyber, Bancor, Oasis]
        uint256 disableFlags // 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken
    )
        public
        payable;

    function goodSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256 parts,
        uint256 disableFlags // 1 - Uniswap, 2 - Kyber, 4 - Bancor, 8 - Oasis, 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken
    )
        public
        payable;
}

// File: contracts/mixins/ExchangeOneSplit.sol

pragma solidity ^0.5.0;







contract ExchangeOneSplit is IIExchange {

    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    IOneSplit public constant ONE_SPLIT = IOneSplit(0xDFf2AA5689FCBc7F479d8c84aC857563798436DD);

    function _exchange(IERC20 fromToken, IERC20 toToken, uint256 amount) internal returns(uint256) {
        fromToken.universalApprove(address(ONE_SPLIT), amount);

        uint256 beforeBalance = toToken.universalBalanceOf(address(this));
        ONE_SPLIT.goodSwap.value(fromToken.isETH() ? amount : 0)(
            fromToken,
            toToken,
            amount,
            0,
            1,
            0
        );

        return toToken.universalBalanceOf(address(this)).sub(beforeBalance);
    }
}

// File: contracts/interface/compound/IPriceOracle.sol

pragma solidity ^0.5.0;

interface IPriceOracle {
    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}

// File: contracts/interface/compound/ICompoundController.sol

pragma solidity ^0.5.0;



interface ICompoundController {
    function oracle() external view returns(IPriceOracle);
    function enterMarkets(address[] calldata cTokens) external returns(uint256[] memory);
    function checkMembership(address account, address cToken) external view returns (bool);
}

// File: contracts/interface/compound/ICERC20.sol

pragma solidity ^0.5.0;



contract ICERC20 is IERC20 {
    function comptroller() external view returns(ICompoundController);
    function balanceOfUnderlying(address account) external returns(uint256);
    function borrowBalanceCurrent(address account) external returns(uint256);

    function mint() external payable;
    function mint(uint256 amount) external returns(uint256);
    function redeem(uint256 amount) external returns(uint256);
    function borrow(uint256 amount) external returns(uint256);
    function repayBorrow() external payable returns (uint256);
    function repayBorrow(uint256 repayAmount) external returns (uint256);
}

// File: contracts/mixins/CompoundUtils.sol

pragma solidity ^0.5.0;





contract CompoundUtils {
    using UniversalERC20 for IERC20;

    function _getCToken(IERC20 token) internal pure returns(ICERC20) {
        if (token.isETH()) {                                                // ETH
            return ICERC20(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
        }
        if (token == IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {  // DAI
            return ICERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
        }
        if (token == IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF)) {  // BAT
            return ICERC20(0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E);
        }
        if (token == IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862)) {  // REP
            return ICERC20(0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1);
        }
        if (token == IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {  // USDC
            return ICERC20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
        }
        if (token == IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {  // WBTC
            return ICERC20(0xC11b1268C1A384e55C48c2391d8d480264A3A7F4);
        }
        if (token == IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498)) {  // ZRX
            return ICERC20(0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407);
        }

        revert("Unsupported token");
    }
}

// File: contracts/mixins/ProtocolCompound.sol

pragma solidity ^0.5.0;









contract ProtocolCompound is IIProtocol, IIOracle, CompoundUtils {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    function collateralAmount(IERC20 token) public returns(uint256) {
        return _getCToken(token).balanceOfUnderlying(address(this));
    }

    function borrowAmount(IERC20 token) public returns(uint256) {
        return _getCToken(token).borrowBalanceCurrent(address(this));
    }

    function _pnl(IERC20 collateral, IERC20 debt) internal returns(uint256) {
        return _getPrice(collateral).mul(collateralAmount(collateral))
            .mul(1e18)
            .div(
                _getPrice(debt).mul(borrowAmount(debt))
            );
    }

    function _deposit(IERC20 token, uint256 amount) internal {
        ICERC20 cToken = _getCToken(token);
        if (!cToken.comptroller().checkMembership(address(this), address(cToken))) {
            _enterMarket(cToken);
        }

        if (token.isETH()) {
            // cToken.mint.value(amount)();
            // TypeError: Member "mint" not unique after argument-dependent lookup in contract ICERC20.
            (bool success,) = address(cToken).call.value(amount)(abi.encodeWithSignature("mint()"));
            require(success);
        } else {
            token.universalApprove(address(cToken), amount);
            cToken.mint(amount);
        }
    }

    function _redeem(IERC20 token, uint256 amount) internal {
        ICERC20 cToken = _getCToken(token);
        cToken.redeem(amount);
    }

    function _redeemAll(IERC20 token) internal {
        ICERC20 cToken = _getCToken(token);
        _redeem(token, IERC20(cToken).universalBalanceOf(address(this)));
    }

    function _borrow(IERC20 token, uint256 amount) internal {
        ICERC20 cToken = _getCToken(token);
        if (!cToken.comptroller().checkMembership(address(this), address(cToken))) {
            _enterMarket(cToken);
        }

        cToken.borrow(amount);
    }

    function _repay(IERC20 token, uint256 amount) internal {
        ICERC20 cToken = _getCToken(token);
        if (token.isETH()) {
            // cToken.repayBorrow.value(amount)();
            // TypeError: Member "repayBorrow" not unique after argument-dependent lookup in contract ICERC20.
            (bool success,) = address(cToken).call.value(amount)(abi.encodeWithSignature("repayBorrow()"));
            require(success);
        } else {
            token.universalApprove(address(cToken), amount);
            cToken.repayBorrow(amount);
        }
    }

    // Private

    function _enterMarket(ICERC20 cToken) private {
        address[] memory tokens = new address[](1);
        tokens[0] = address(cToken);
        cToken.comptroller().enterMarkets(tokens);
    }
}

// File: contracts/interface/chainlink/IAggregator.sol

pragma solidity ^0.5.0;


interface IAggregator {
  function latestAnswer() external view returns (int256);
}

// File: contracts/mixins/OracleChainLink.sol

pragma solidity ^0.5.0;






contract OracleChainLink is IIOracle {

    using UniversalERC20 for IERC20;

    function _getPrice(IERC20 token) internal view returns (uint256) {
        if (token.isETH()) {
            return 1e18;
        }

        return uint256(_getChainLinkOracleByToken(token).latestAnswer());
    }

    function _getChainLinkOracleByToken(IERC20 token) private pure returns (IAggregator) {
        if (token == IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {  // DAI
            return IAggregator(0x037E8F2125bF532F3e228991e051c8A7253B642c);
        }
        if (token == IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF)) {  // BAT
            return IAggregator(0x9b4e2579895efa2b4765063310Dc4109a7641129);
        }
        if (token == IERC20(0x1985365e9f78359a9B6AD760e32412f4a445E862)) {  // REP
            return IAggregator(0xb8b513d9cf440C1b6f5C7142120d611C94fC220c);
        }
        if (token == IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {  // USDC
            return IAggregator(0xdE54467873c3BCAA76421061036053e371721708);
        }
        if (token == IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {  // WBTC
            return IAggregator(0x0133Aa47B6197D0BA090Bf2CD96626Eb71fFd13c);
        }
        if (token == IERC20(0xE41d2489571d322189246DaFA5ebDe1F4699F498)) {  // ZRX
            return IAggregator(0xA0F9D94f060836756FFC84Db4C78d097cA8C23E8);
        }

        revert("Unsupported token");
    }
}

// File: contracts/HolderOne.sol

pragma solidity ^0.5.0;






//import "./mixins/OracleCompound.sol";


contract HolderOne is
    HolderBase,
    FlashLoanAave,
    ExchangeOneSplit,
    ProtocolCompound,
    OracleChainLink
    //OracleCompound
{
}
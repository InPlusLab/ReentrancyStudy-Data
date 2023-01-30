pragma solidity 0.6.6;

import "./IBurnGasHelper.sol";
import "@kyber.network/utils-sc/contracts/Utils.sol";
import "@kyber.network/utils-sc/contracts/Withdrawable.sol";


contract BurnGasHelper is IBurnGasHelper, Utils, Withdrawable {


    address public gasTokenAddr;

    constructor(
        address _admin,
        address _gasToken
    ) public Withdrawable(_admin) {
        gasTokenAddr = _gasToken;
    }

    function updateGasToken(address _gasToken) external onlyAdmin {
        gasTokenAddr = _gasToken;
    }

    function getAmountGasTokensToBurn(
        uint256 gasTotalConsumption
    ) external override view returns(uint numGas, address gasToken) {

        gasToken = gasTokenAddr;
        uint256 gas = gasleft();
        uint256 safeNumTokens = 0;
        if (gas >= 27710) {
            safeNumTokens = (gas - 27710) / 7020; // (1148 + 5722 + 150);
        }

        uint256 gasSpent = 21000 + 16 * gasTotalConsumption;
        numGas = (gasSpent + 14154) / 41947;

        numGas = minOf(safeNumTokens, numGas);
    }
}

pragma solidity 0.6.6;


interface IBurnGasHelper {
    function getAmountGasTokensToBurn(uint256 gasTotalConsumption)
        external
        view
        returns (uint256 numGas, address gasToken);
}

pragma solidity 0.6.6;

import "./IERC20Ext.sol";


/**
 * @title Kyber utility file
 * mostly shared constants and rate calculation helpers
 * inherited by most of kyber contracts.
 * previous utils implementations are for previous solidity versions.
 */
contract Utils {
    /// Declared constants below to be used in tandem with
    /// getDecimalsConstant(), for gas optimization purposes
    /// which return decimals from a constant list of popular
    /// tokens.
    IERC20Ext internal constant ETH_TOKEN_ADDRESS = IERC20Ext(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IERC20Ext internal constant USDT_TOKEN_ADDRESS = IERC20Ext(
        0xdAC17F958D2ee523a2206206994597C13D831ec7
    );
    IERC20Ext internal constant DAI_TOKEN_ADDRESS = IERC20Ext(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    IERC20Ext internal constant USDC_TOKEN_ADDRESS = IERC20Ext(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    IERC20Ext internal constant WBTC_TOKEN_ADDRESS = IERC20Ext(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    IERC20Ext internal constant KNC_TOKEN_ADDRESS = IERC20Ext(
        0xdd974D5C2e2928deA5F71b9825b8b646686BD200
    );
    uint256 public constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20Ext => uint256) internal decimals;

    /// @dev Sets the decimals of a token to storage if not already set, and returns
    ///      the decimals value of the token. Prefer using this function over
    ///      getDecimals(), to avoid forgetting to set decimals in local storage.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getSetDecimals(IERC20Ext token) internal returns (uint256 tokenDecimals) {
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }
    }

    /// @dev Get the balance of a user
    /// @param token The token type
    /// @param user The user's address
    /// @return The balance
    function getBalance(IERC20Ext token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    /// @dev Get the decimals of a token, read from the constant list, storage,
    ///      or from token.decimals(). Prefer using getSetDecimals when possible.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getDecimals(IERC20Ext token) internal view returns (uint256 tokenDecimals) {
        // return token decimals if has constant value
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        // handle case where token decimals is not a declared decimal constant
        tokenDecimals = decimals[token];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        return (tokenDecimals > 0) ? tokenDecimals : token.decimals();
    }

    function calcDestAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    /// @dev save storage access by declaring token decimal constants
    /// @param token The token type
    /// @return token decimals
    function getDecimalsConstant(IERC20Ext token) internal pure returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return ETH_DECIMALS;
        } else if (token == USDT_TOKEN_ADDRESS) {
            return 6;
        } else if (token == DAI_TOKEN_ADDRESS) {
            return 18;
        } else if (token == USDC_TOKEN_ADDRESS) {
            return 6;
        } else if (token == WBTC_TOKEN_ADDRESS) {
            return 8;
        } else if (token == KNC_TOKEN_ADDRESS) {
            return 18;
        } else {
            return 0;
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./IERC20Ext.sol";
import "./PermissionGroups.sol";

contract Withdrawable is PermissionGroups {
    using SafeERC20 for IERC20Ext;

    event TokenWithdraw(IERC20Ext token, uint256 amount, address sendTo);
    event EtherWithdraw(uint256 amount, address sendTo);

    constructor(address _admin) public PermissionGroups(_admin) {}

    /**
     * @dev Withdraw all IERC20Ext compatible tokens
     * @param token IERC20Ext The address of the token contract
     */
    function withdrawToken(
        IERC20Ext token,
        uint256 amount,
        address sendTo
    ) external onlyAdmin {
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint256 amount, address payable sendTo) external onlyAdmin {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "withdraw failed");
        emit EtherWithdraw(amount, sendTo);
    }
}

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
 * @dev Interface extending ERC20 standard to include decimals() as
 *      it is optional in the OpenZeppelin IERC20 interface.
 */
interface IERC20Ext is IERC20 {
    /**
     * @dev This function is required as Kyber requires to interact
     *      with token.decimals() with many of its operations.
     */
    function decimals() external view returns (uint8 digits);
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

pragma solidity 0.6.6;

contract PermissionGroups {
    uint256 internal constant MAX_GROUP_SIZE = 50;

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    mapping(address => bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;

    event AdminClaimed(address newAdmin, address previousAdmin);

    event TransferAdminPending(address pendingAdmin);

    event OperatorAdded(address newOperator, bool isAdd);

    event AlerterAdded(address newAlerter, bool isAdd);

    constructor(address _admin) public {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "only operator");
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender], "only alerter");
        _;
    }

    function getOperators() external view returns (address[] memory) {
        return operatorsGroup;
    }

    function getAlerters() external view returns (address[] memory) {
        return alertersGroup;
    }

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter], "alerter exists"); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE, "max alerters");

        emit AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter(address alerter) public onlyAdmin {
        require(alerters[alerter], "not alerter");
        alerters[alerter] = false;

        for (uint256 i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.pop();
                emit AlerterAdded(alerter, false);
                break;
            }
        }
    }

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator], "operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator(address operator) public onlyAdmin {
        require(operators[operator], "not operator");
        operators[operator] = false;

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }
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

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./ILendingPoolV1.sol";
import "./ILendingPoolV2.sol";
import "./IFetchAaveDataWrapper.sol";
import "./ILendingPoolCore.sol";
import "@kyber.network/utils-sc/contracts/Withdrawable.sol";
import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";


/// Fetch data for multiple users or reserves from AAVE
/// Checkout list deployed AAVE's contracts here
/// https://docs.aave.com/developers/deployed-contracts/deployed-contract-instances
contract FetchAaveDataWrapper is Withdrawable, IFetchAaveDataWrapper {
    uint256 internal constant PRECISION = 10**18;
    uint256 internal constant RATE_PRECISION = 10**27;

    constructor(address _admin) public Withdrawable(_admin) {}

    function getReserves(address pool, bool isV1)
        external
        view
        override
        returns (address[] memory reserves)
    {
        if (isV1) {
            return ILendingPoolV1(pool).getReserves();
        }
        return ILendingPoolV2(pool).getReservesList();
    }

    function getReservesConfigurationData(
        address pool,
        bool isV1,
        address[] calldata _reserves
    ) external view override returns (ReserveConfigData[] memory configsData) {
        configsData = new ReserveConfigData[](_reserves.length);
        for (uint256 i = 0; i < _reserves.length; i++) {
            if (isV1) {
                (
                    configsData[i].ltv,
                    configsData[i].liquidationThreshold,
                    configsData[i].liquidationBonus, // rate strategy address
                    ,
                    configsData[i].usageAsCollateralEnabled,
                    configsData[i].borrowingEnabled,
                    configsData[i].stableBorrowRateEnabled,
                    configsData[i].isActive
                ) = ILendingPoolV1(pool).getReserveConfigurationData(_reserves[i]);
                configsData[i].aTokenAddress = ILendingPoolCore(ILendingPoolV1(pool).core())
                    .getReserveATokenAddress(_reserves[i]);
            } else {
                IProtocolDataProvider provider = IProtocolDataProvider(pool);
                (
                    ,
                    // decimals
                    configsData[i].ltv,
                    configsData[i].liquidationThreshold,
                    configsData[i].liquidationBonus, // reserve factor
                    ,
                    configsData[i].usageAsCollateralEnabled,
                    configsData[i].borrowingEnabled,
                    configsData[i].stableBorrowRateEnabled,
                    configsData[i].isActive,

                ) = provider.getReserveConfigurationData(_reserves[i]);
                (configsData[i].aTokenAddress, , ) = provider.getReserveTokensAddresses(
                    _reserves[i]
                );
            }
        }
    }

    function getReservesData(
        address pool,
        bool isV1,
        address[] calldata _reserves
    ) external view override returns (ReserveData[] memory reservesData) {
        reservesData = new ReserveData[](_reserves.length);
        if (isV1) {
            ILendingPoolCore core = ILendingPoolCore(ILendingPoolV1(pool).core());
            for (uint256 i = 0; i < _reserves.length; i++) {
                reservesData[i].totalLiquidity = core.getReserveTotalLiquidity(_reserves[i]);
                reservesData[i].availableLiquidity = core.getReserveAvailableLiquidity(
                    _reserves[i]
                );
                reservesData[i].utilizationRate = core.getReserveUtilizationRate(_reserves[i]);
                reservesData[i].liquidityRate = core.getReserveCurrentLiquidityRate(_reserves[i]);

                reservesData[i].totalBorrowsStable = core.getReserveTotalBorrowsStable(
                    _reserves[i]
                );
                reservesData[i].totalBorrowsVariable = core.getReserveTotalBorrowsVariable(
                    _reserves[i]
                );

                reservesData[i].variableBorrowRate = core.getReserveCurrentVariableBorrowRate(
                    _reserves[i]
                );
                reservesData[i].stableBorrowRate = core.getReserveCurrentStableBorrowRate(
                    _reserves[i]
                );
                reservesData[i].averageStableBorrowRate = core
                    .getReserveCurrentAverageStableBorrowRate(_reserves[i]);
            }
        } else {
            IProtocolDataProvider provider = IProtocolDataProvider(pool);
            for (uint256 i = 0; i < _reserves.length; i++) {
                (
                    reservesData[i].availableLiquidity,
                    reservesData[i].totalBorrowsStable,
                    reservesData[i].totalBorrowsVariable,
                    reservesData[i].liquidityRate,
                    reservesData[i].variableBorrowRate,
                    reservesData[i].stableBorrowRate,
                    reservesData[i].averageStableBorrowRate,
                    ,
                    ,

                ) = provider.getReserveData(_reserves[i]);
                (address aTokenAddress, , ) = provider.getReserveTokensAddresses(_reserves[i]);
                reservesData[i].availableLiquidity = IERC20Ext(_reserves[i]).balanceOf(
                    aTokenAddress
                );

                reservesData[i].totalLiquidity =
                    reservesData[i].availableLiquidity +
                    reservesData[i].totalBorrowsStable +
                    reservesData[i].totalBorrowsVariable;
                if (reservesData[i].totalLiquidity > 0) {
                    reservesData[i].utilizationRate =
                        RATE_PRECISION -
                        (reservesData[i].availableLiquidity * RATE_PRECISION) /
                        reservesData[i].totalLiquidity;
                }
            }
        }
    }

    function getUserAccountsData(
        address pool,
        bool isV1,
        address[] calldata _users
    ) external view override returns (UserAccountData[] memory accountsData) {
        accountsData = new UserAccountData[](_users.length);

        for (uint256 i = 0; i < _users.length; i++) {
            accountsData[i] = getSingleUserAccountData(pool, isV1, _users[i]);
        }
    }

    function getUserReservesData(
        address pool,
        bool isV1,
        address[] calldata _reserves,
        address _user
    ) external view override returns (UserReserveData[] memory userReservesData) {
        userReservesData = new UserReserveData[](_reserves.length);
        for (uint256 i = 0; i < _reserves.length; i++) {
            if (isV1) {
                userReservesData[i] = getSingleUserReserveDataV1(
                    ILendingPoolV1(pool),
                    _reserves[i],
                    _user
                );
            } else {
                userReservesData[i] = getSingleUserReserveDataV2(
                    IProtocolDataProvider(pool),
                    _reserves[i],
                    _user
                );
            }
        }
    }

    function getUsersReserveData(
        address pool,
        bool isV1,
        address _reserve,
        address[] calldata _users
    ) external view override returns (UserReserveData[] memory userReservesData) {
        userReservesData = new UserReserveData[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            if (isV1) {
                userReservesData[i] = getSingleUserReserveDataV1(
                    ILendingPoolV1(pool),
                    _reserve,
                    _users[i]
                );
            } else {
                userReservesData[i] = getSingleUserReserveDataV2(
                    IProtocolDataProvider(pool),
                    _reserve,
                    _users[i]
                );
            }
        }
    }

    function getSingleUserReserveDataV1(
        ILendingPoolV1 pool,
        address _reserve,
        address _user
    ) public view returns (UserReserveData memory data) {
        (
            data.currentATokenBalance,
            data.currentBorrowBalance,
            data.principalBorrowBalance,
            data.borrowRateMode,
            data.borrowRate,
            data.liquidityRate,
            data.originationFee,
            ,
            ,
            data.usageAsCollateralEnabled
        ) = pool.getUserReserveData(_reserve, _user);
        IERC20Ext aToken =
            IERC20Ext(ILendingPoolCore(pool.core()).getReserveATokenAddress(_reserve));
        uint256 totalSupply = aToken.totalSupply();
        if (totalSupply > 0) {
            data.poolShareInPrecision = aToken.balanceOf(_user) * RATE_PRECISION / totalSupply;
        }
    }

    function getSingleUserReserveDataV2(
        IProtocolDataProvider provider,
        address _reserve,
        address _user
    ) public view returns (UserReserveData memory data) {
        {
            (
                data.currentATokenBalance,
                data.currentStableDebt,
                data.currentVariableDebt,
                data.principalStableDebt,
                data.scaledVariableDebt,
                data.stableBorrowRate,
                data.liquidityRate,
                ,
                data.usageAsCollateralEnabled
            ) = provider.getUserReserveData(_reserve, _user);
        }
        {
            (address aTokenAddress, , ) = provider.getReserveTokensAddresses(_reserve);
            uint256 totalSupply = IERC20Ext(aTokenAddress).totalSupply();
            if (totalSupply > 0) {
                data.poolShareInPrecision =
                    IERC20Ext(aTokenAddress).balanceOf(_user) * RATE_PRECISION /
                    totalSupply;
            }
        }
    }

    function getSingleUserAccountData(
        address pool,
        bool isV1,
        address _user
    ) public view returns (UserAccountData memory data) {
        if (isV1) {
            (
                data.totalLiquidityETH,
                data.totalCollateralETH,
                data.totalBorrowsETH,
                data.totalFeesETH,
                data.availableBorrowsETH,
                data.currentLiquidationThreshold,
                data.ltv,
                data.healthFactor
            ) = ILendingPoolV1(pool).getUserAccountData(_user);
            return data;
        }
        (
            data.totalCollateralETH,
            data.totalBorrowsETH,
            data.availableBorrowsETH,
            data.currentLiquidationThreshold,
            data.ltv,
            data.healthFactor
        ) = ILendingPoolV2(pool).getUserAccountData(_user);
    }
}

pragma solidity 0.6.6;


interface ILendingPoolV1{
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
    function core() external view returns (address);
    function getReserves() external view returns (address[] memory);
    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address rateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );
    function getUserAccountData(address _user)
        external
        view
        returns (
            uint256 totalLiquidityETH,
            uint256 totalCollateralETH,
            uint256 totalBorrowsETH,
            uint256 totalFeesETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );
}

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./DataTypes.sol";
import "./IProtocolDataProvider.sol";

interface ILendingPoolV2 {
  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);

  /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
  function getReserveData(address asset)
    external
    view
    returns (DataTypes.ReserveData memory);

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralETH the total collateral in ETH of the user
   * @return totalDebtETH the total debt in ETH of the user
   * @return availableBorrowsETH the borrowing power left of the user
   * @return currentLiquidationThreshold the liquidation threshold of the user
   * @return ltv the loan to value of the user
   * @return healthFactor the current health factor of the user
   **/
  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  /**
   * @dev Returns the configuration of the user across all the reserves
   * @param user The user address
   * @return The configuration of the user
   **/
  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);

  function getReservesList() external view returns (address[] memory);
  function getAddressesProvider() external view returns (IProtocolDataProvider);
}

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


interface IFetchAaveDataWrapper {
    struct ReserveConfigData {
        uint256 ltv;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
        bool usageAsCollateralEnabled;
        bool borrowingEnabled;
        bool stableBorrowRateEnabled;
        bool isActive;
        address aTokenAddress;
    }

    struct ReserveData {
        uint256 availableLiquidity;
        uint256 totalBorrowsStable;
        uint256 totalBorrowsVariable;
        uint256 liquidityRate;
        uint256 variableBorrowRate;
        uint256 stableBorrowRate;
        uint256 averageStableBorrowRate;
        uint256 totalLiquidity;
        uint256 utilizationRate;
    }

    struct UserAccountData {
        uint256 totalLiquidityETH; // only v1
        uint256 totalCollateralETH;
        uint256 totalBorrowsETH;
        uint256 totalFeesETH; // only v1
        uint256 availableBorrowsETH;
        uint256 currentLiquidationThreshold;
        uint256 ltv;
        uint256 healthFactor;
    }

    struct UserReserveData {
        uint256 currentATokenBalance;
        uint256 liquidityRate;
        uint256 poolShareInPrecision;
        bool usageAsCollateralEnabled;
        // v1 data
        uint256 currentBorrowBalance;
        uint256 principalBorrowBalance;
        uint256 borrowRateMode;
        uint256 borrowRate;
        uint256 originationFee;
        // v2 data
        uint256 currentStableDebt;
        uint256 currentVariableDebt;
        uint256 principalStableDebt;
        uint256 scaledVariableDebt;
        uint256 stableBorrowRate;
    }

    function getReserves(address pool, bool isV1) external view returns (address[] memory);
    function getReservesConfigurationData(address pool, bool isV1, address[] calldata _reserves)
        external
        view
        returns (
            ReserveConfigData[] memory configsData
        );

    function getReservesData(address pool, bool isV1, address[] calldata _reserves)
        external
        view
        returns (
            ReserveData[] memory reservesData
        );

    function getUserAccountsData(address pool, bool isV1, address[] calldata _users)
        external
        view
        returns (
            UserAccountData[] memory accountsData
        );

    function getUserReservesData(address pool, bool isV1, address[] calldata _reserves, address _user)
        external
        view
        returns (
            UserReserveData[] memory userReservesData
        );

    function getUsersReserveData(address pool, bool isV1, address _reserve, address[] calldata _users)
        external
        view
        returns (
            UserReserveData[] memory userReservesData
        );
}

pragma solidity 0.6.6;


interface ILendingPoolCore {
    function getReserveATokenAddress(address _reserve) external view returns (address);
    function getReserveTotalLiquidity(address _reserve) external view returns (uint256);
    function getReserveAvailableLiquidity(address _reserve) external view returns (uint256);
    function getReserveCurrentLiquidityRate(address _reserve) external view returns (uint256);
    function getReserveUtilizationRate(address _reserve) external view returns (uint256);

    function getReserveTotalBorrowsStable(address _reserve) external view returns (uint256);
    function getReserveTotalBorrowsVariable(address _reserve) external view returns (uint256);
    function getReserveCurrentVariableBorrowRate(address _reserve) external view returns (uint256);
    function getReserveCurrentStableBorrowRate(address _reserve) external view returns (uint256);
    function getReserveCurrentAverageStableBorrowRate(address _reserve) external view returns (uint256);
}

pragma solidity 0.6.6;

library DataTypes {
  struct ReserveData {
    //stores the reserve configuration
    ReserveConfigurationMap configuration;
    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate;
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate;
    //the current stable borrow rate. Expressed in ray
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    //tokens addresses
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint8 id;
  }

  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals
    //bit 56: Reserve is active
    //bit 57: reserve is frozen
    //bit 58: borrowing is enabled
    //bit 59: stable rate borrowing enabled
    //bit 60-63: reserved
    //bit 64-79: reserve factor
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

interface IProtocolDataProvider {
  struct TokenData {
    string symbol;
    address tokenAddress;
  }

  function getAllReservesTokens() external view returns (TokenData[] memory);
  function getAllATokens() external view returns (TokenData[] memory);
  function getReserveConfigurationData(address asset)
    external view returns(
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    );
  function getReserveData(address asset)
    external view returns (
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 stableBorrowRate,
        uint256 averageStableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex,
        uint40 lastUpdateTimestamp
    );
  function getUserReserveData(address asset, address user)
    external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );
  function getReserveTokensAddresses(address asset)
    external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );
  function calculateUserGlobalData(address _user)
    external
    view
    returns (
        uint256 totalLiquidityBalanceETH,
        uint256 totalCollateralBalanceETH,
        uint256 totalBorrowBalanceETH,
        uint256 totalFeesETH,
        uint256 currentLtv,
        uint256 currentLiquidationThreshold,
        uint256 healthFactor,
        bool healthFactorBelowThreshold
    );
}

pragma solidity 0.6.6;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";


interface IKyberProxy {

    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);

    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);
}

pragma solidity 0.6.6;

import "../burnHelper/IBurnGasHelper.sol";
import "../interfaces/IKyberProxy.sol";
import "../interfaces/IGasToken.sol";
import "../lending/ISmartWalletLending.sol";
import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "@kyber.network/utils-sc/contracts/Utils.sol";
import "@kyber.network/utils-sc/contracts/Withdrawable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract SmartWalletSwapStorage is Utils, Withdrawable, ReentrancyGuard {

    uint256 constant internal MAX_AMOUNT = uint256(-1);

    mapping (address => mapping(IERC20Ext => uint256)) public platformWalletFees;
    // Proxy and routers will be set only once in constructor
    IKyberProxy public kyberProxy;
    // check if a router (Uniswap or its clones) is supported
    mapping(IUniswapV2Router02 => bool) public isRouterSupported;

    IBurnGasHelper public burnGasHelper;
    mapping (address => bool) public supportedPlatformWallets;

    struct TradeInput {
        uint256 srcAmount;
        uint256 minData; // min rate if Kyber, min return if Uni-pools
        address payable recipient;
        uint256 platformFeeBps;
        address payable platformWallet;
        bytes hint;
    }

    ISmartWalletLending public lendingImpl;

    // bytes32(uint256(keccak256("SmartWalletSwapImplementation")) - 1)
    bytes32 internal constant IMPLEMENTATION = 0x6a7efb0627ddb0e69b773958c7c9c3c9c3dc049819cdf56a8ee84c3074b2a5d7;

    constructor(address _admin) public Withdrawable(_admin) {}
}

pragma solidity 0.6.6;

interface IGasToken {
    function mint(uint256 value) external;
    function freeUpTo(uint256 value) external returns (uint256 freed);

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function approve(address spender, uint256 value) external returns (bool success);
}

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "../interfaces/IAaveLendingPoolV2.sol";
import "../interfaces/IAaveLendingPoolV1.sol";
import "../interfaces/IWeth.sol";
import "../interfaces/ICompErc20.sol";


interface ISmartWalletLending {

    event ClaimedComp(
        address[] holders,
        ICompErc20[] cTokens,
        bool borrowers,
        bool suppliers
    );

    enum LendingPlatform { AAVE_V1, AAVE_V2, COMPOUND }

    struct UserReserveData {
        uint256 currentATokenBalance;
        uint256 liquidityRate;
        uint256 poolShareInPrecision;
        bool usageAsCollateralEnabled;
        // Aave v1 data
        uint256 currentBorrowBalance;
        uint256 principalBorrowBalance;
        uint256 borrowRateMode;
        uint256 borrowRate;
        uint256 originationFee;
        // Aave v2 data
        uint256 currentStableDebt;
        uint256 currentVariableDebt;
        uint256 principalStableDebt;
        uint256 scaledVariableDebt;
        uint256 stableBorrowRate;
    }

    function updateAaveLendingPoolData(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] calldata tokens
    ) external;

    function updateCompoundData(
        address _comptroller,
        address _cEth,
        address[] calldata _cTokens
    ) external;

    function depositTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount
    ) external;

    function borrowFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external;

    function withdrawFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn
    ) external returns (uint256 returnedAmount);

    function repayBorrowTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 payAmount,
        uint256 rateMode // only for aave v2
    ) external;
    
    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external;

    function storeAndRetrieveUserDebtCurrent(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) external returns (uint256 debt);

    function getLendingToken(LendingPlatform platform, IERC20Ext token) external view returns(address);

    function getUserDebtStored(LendingPlatform platform, address reserve, address user)
        external
        view
        returns (uint256 debt);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "../wrappers/AAVE/DataTypes.sol";
import "../wrappers/AAVE/IProtocolDataProvider.sol";


interface IAaveLendingPoolV2 {
    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     **/
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    /**
     * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
     * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
     * @param to Address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     **/
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
     * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
     * corresponding debt token (StableDebtToken or VariableDebtToken)
     * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
     *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
     * @param asset The address of the underlying asset to borrow
     * @param amount The amount to be borrowed
     * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
     * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
     * if he has been given credit delegation allowance
     **/
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    /**
     * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
     * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
     * @param asset The address of the borrowed underlying asset previously borrowed
     * @param amount The amount to repay
     * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
     * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
     * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
     * user calling the function if he wants to reduce/remove his own debt, or the address of any other
     * other borrower whose debt should be removed
     * @return The final amount repaid
     **/
    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);

    /**
     * @dev Allows depositors to enable/disable a specific deposited asset as collateral
     * @param asset The address of the underlying asset deposited
     * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
     **/
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

    /**
     * @dev Returns the state and configuration of the reserve
     * @param asset The address of the underlying asset of the reserve
     * @return The state of the reserve
     **/
    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);
}

pragma solidity 0.6.6;


interface IAaveLendingPoolV1 {
    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;

    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;

    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;

    function repay(
        address _reserve,
        uint256 _amount,
        address payable _onBehalfOf
    ) external payable;

    function core() external view returns (address);

    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );
}

interface IAToken {
    function redeem(uint256 _amount) external;
}

pragma solidity 0.6.6;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";


interface IWeth is IERC20Ext {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

pragma solidity 0.6.6;


interface ICompErc20 {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function underlying() external view returns (address);
}

interface ICompEth {
    function mint() external payable;
    function repayBorrowBehalf(address borrower) external payable;
    function repayBorrow() external payable;
}

pragma solidity >=0.6.2;

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

pragma solidity 0.6.6;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SmartWalletSwapStorage.sol";


contract SmartWalletSwapProxy is SmartWalletSwapStorage {
    using Address for address;

    event ImplementationUpdated(address indexed implementation);

    constructor(
        address _admin,
        address _implementation,
        IKyberProxy _proxy,
        IUniswapV2Router02[] memory _routers
    ) public SmartWalletSwapStorage(_admin) {
        _setImplementation(_implementation);
        kyberProxy = _proxy;
        for (uint256 i = 0; i < _routers.length; i++) {
            isRouterSupported[_routers[i]] = true;
        }
    }

    function updateNewImplementation(address _implementation) external onlyAdmin {
        _setImplementation(_implementation);
        emit ImplementationUpdated(_implementation);
    }

    receive() external payable {}

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback() external payable {
        (bool success, ) = implementation().delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
            switch success
                case 0 {
                    revert(free_mem_ptr, returndatasize())
                }
                default {
                    return(free_mem_ptr, returndatasize())
                }
        }
    }

    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address _implementation) internal {
        require(_implementation.isContract(), "non-contract address");

        bytes32 slot = IMPLEMENTATION;
        assembly {
            sstore(slot, _implementation)
        }
    }
}

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "../wrappers/AAVE/ILendingPoolCore.sol";
import "../interfaces/IComptroller.sol";
import "./ISmartWalletLending.sol";
import "@kyber.network/utils-sc/contracts/Utils.sol";
import "@kyber.network/utils-sc/contracts/Withdrawable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


contract SmartWalletLending is ISmartWalletLending, Utils, Withdrawable {
    using SafeERC20 for IERC20Ext;
    using SafeMath for uint256;

    struct AaveLendingPoolData {
        IAaveLendingPoolV2 lendingPoolV2;
        IProtocolDataProvider provider;
        mapping(IERC20Ext => address) aTokensV2;
        IWeth weth;
        IAaveLendingPoolV1 lendingPoolV1;
        mapping(IERC20Ext => address) aTokensV1;
        address lendingPoolCoreV1;
        uint16 referalCode;
    }

    AaveLendingPoolData public aaveLendingPool;

    struct CompoundData {
        address comptroller;
        mapping(IERC20Ext => address) cTokens;
    }

    CompoundData public compoundData;

    address public swapImplementation;

    event UpdatedSwapImplementation(address indexed _oldSwapImpl, address indexed _newSwapImpl);
    event UpdatedAaveLendingPool(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] tokens,
        address[] aTokensV1,
        address[] aTokensV2
    );
    event UpdatedCompoudData(
        address comptroller,
        address cEth,
        address[] cTokens,
        IERC20Ext[] underlyingTokens
    );

    modifier onlySwapImpl() {
        require(msg.sender == swapImplementation, "only swap impl");
        _;
    }

    constructor(address _admin) public Withdrawable(_admin) {}

    receive() external payable {}

    function updateSwapImplementation(address _swapImpl) external onlyAdmin {
        require(_swapImpl != address(0), "invalid swap impl");
        emit UpdatedSwapImplementation(swapImplementation, _swapImpl);
        swapImplementation = _swapImpl;
    }

    function updateAaveLendingPoolData(
        IAaveLendingPoolV2 poolV2,
        IProtocolDataProvider provider,
        IAaveLendingPoolV1 poolV1,
        address lendingPoolCoreV1,
        uint16 referalCode,
        IWeth weth,
        IERC20Ext[] calldata tokens
    ) external override onlyAdmin {
        require(weth != IWeth(0), "invalid weth");
        aaveLendingPool.lendingPoolV2 = poolV2;
        aaveLendingPool.provider = provider;
        aaveLendingPool.lendingPoolV1 = poolV1;
        aaveLendingPool.lendingPoolCoreV1 = lendingPoolCoreV1;
        aaveLendingPool.referalCode = referalCode;
        aaveLendingPool.weth = weth;

        address[] memory aTokensV1 = new address[](tokens.length);
        address[] memory aTokensV2 = new address[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            if (poolV1 != IAaveLendingPoolV1(0)) {
                // update data for pool v1
                try
                    ILendingPoolCore(poolV1.core()).getReserveATokenAddress(address(tokens[i]))
                returns (address aToken) {
                    aTokensV1[i] = aToken;
                } catch {}
                aaveLendingPool.aTokensV1[tokens[i]] = aTokensV1[i];
            }
            if (poolV2 != IAaveLendingPoolV2(0)) {
                address token =
                    tokens[i] == ETH_TOKEN_ADDRESS ? address(weth) : address(tokens[i]);
                // update data for pool v2
                try poolV2.getReserveData(token) returns (DataTypes.ReserveData memory data) {
                    aTokensV2[i] = data.aTokenAddress;
                } catch {}
                aaveLendingPool.aTokensV2[tokens[i]] = aTokensV2[i];
            }
        }

        // do token approvals
        if (lendingPoolCoreV1 != address(0)) {
            for (uint256 j = 0; j < aTokensV1.length; j++) {
                safeApproveAllowance(lendingPoolCoreV1, tokens[j]);
            }
        }
        if (poolV2 != IAaveLendingPoolV2(0)) {
            for (uint256 j = 0; j < aTokensV1.length; j++) {
                safeApproveAllowance(address(poolV2), tokens[j]);
            }
        }

        emit UpdatedAaveLendingPool(
            poolV2,
            provider,
            poolV1,
            lendingPoolCoreV1,
            referalCode,
            weth,
            tokens,
            aTokensV1,
            aTokensV2
        );
    }

    function updateCompoundData(
        address _comptroller,
        address _cEth,
        address[] calldata _cTokens
    ) external override onlyAdmin {
        require(_comptroller != address(0), "invalid _comptroller");
        require(_cEth != address(0), "invalid cEth");

        compoundData.comptroller = _comptroller;
        compoundData.cTokens[ETH_TOKEN_ADDRESS] = _cEth;

        IERC20Ext[] memory tokens;
        if (_cTokens.length > 0) {
            // add specific markets
            tokens = new IERC20Ext[](_cTokens.length);
            for (uint256 i = 0; i < _cTokens.length; i++) {
                require(_cTokens[i] != address(0), "invalid cToken");
                tokens[i] = IERC20Ext(ICompErc20(_cTokens[i]).underlying());
                require(tokens[i] != IERC20Ext(0), "invalid underlying token");
                compoundData.cTokens[tokens[i]] = _cTokens[i];

                // do token approvals
                safeApproveAllowance(_cTokens[i], tokens[i]);
            }
            emit UpdatedCompoudData(_comptroller, _cEth, _cTokens, tokens);
        } else {
            // add all markets
            ICompErc20[] memory markets = IComptroller(_comptroller).getAllMarkets();
            tokens = new IERC20Ext[](markets.length);
            address[] memory cTokens = new address[](markets.length);
            for (uint256 i = 0; i < markets.length; i++) {
                if (address(markets[i]) == _cEth) {
                    tokens[i] = ETH_TOKEN_ADDRESS;
                    cTokens[i] = _cEth;
                    continue;
                }
                require(markets[i] != ICompErc20(0), "invalid cToken");
                tokens[i] = IERC20Ext(markets[i].underlying());
                require(tokens[i] != IERC20Ext(0), "invalid underlying token");
                cTokens[i] = address(markets[i]);
                compoundData.cTokens[tokens[i]] = cTokens[i];

                // do token approvals
                safeApproveAllowance(_cTokens[i], tokens[i]);
            }
            emit UpdatedCompoudData(_comptroller, _cEth, cTokens, tokens);
        }
    }

    /// @dev deposit to lending platforms like AAVE, COMPOUND
    ///     expect amount of token should already be in the contract
    function depositTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount
    ) external override onlySwapImpl {
        require(getBalance(token, address(this)) >= amount, "low balance");
        if (platform == LendingPlatform.AAVE_V1) {
            IAaveLendingPoolV1 poolV1 = aaveLendingPool.lendingPoolV1;
            IERC20Ext aToken = IERC20Ext(aaveLendingPool.aTokensV1[token]);
            require(aToken != IERC20Ext(0), "aToken not found");

            // deposit and compute received aToken amount
            uint256 aTokenBalanceBefore = aToken.balanceOf(address(this));
            poolV1.deposit{value: token == ETH_TOKEN_ADDRESS ? amount : 0}(
                address(token),
                amount,
                aaveLendingPool.referalCode
            );
            uint256 aTokenBalanceAfter = aToken.balanceOf(address(this));
            // transfer all received aToken back to the sender
            aToken.safeTransfer(onBehalfOf, aTokenBalanceAfter.sub(aTokenBalanceBefore));
        } else if (platform == LendingPlatform.AAVE_V2) {
            if (token == ETH_TOKEN_ADDRESS) {
                // wrap eth -> weth, then deposit
                IWeth weth = aaveLendingPool.weth;
                IAaveLendingPoolV2 pool = aaveLendingPool.lendingPoolV2;
                weth.deposit{value: amount}();
                pool.deposit(address(weth), amount, onBehalfOf, aaveLendingPool.referalCode);
            } else {
                IAaveLendingPoolV2 pool = aaveLendingPool.lendingPoolV2;
                pool.deposit(address(token), amount, onBehalfOf, aaveLendingPool.referalCode);
            }
        } else {
            // Compound
            address cToken = compoundData.cTokens[token];
            require(cToken != address(0), "token is not supported by Compound");
            uint256 cTokenBalanceBefore = IERC20Ext(cToken).balanceOf(address(this));
            if (token == ETH_TOKEN_ADDRESS) {
                ICompEth(cToken).mint{value: amount}();
            } else {
                require(ICompErc20(cToken).mint(amount) == 0, "can not mint cToken");
            }
            uint256 cTokenBalanceAfter = IERC20Ext(cToken).balanceOf(address(this));
            IERC20Ext(cToken).safeTransfer(
                onBehalfOf,
                cTokenBalanceAfter.sub(cTokenBalanceBefore)
            );
        }
    }

    /// @dev borrow from lending platforms like AAVE v2, COMPOUND
    function borrowFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 borrowAmount,
        uint256 interestRateMode
    ) external override onlySwapImpl {
        require(platform != LendingPlatform.AAVE_V1, "Aave V1 not supported");

        if (platform == LendingPlatform.AAVE_V2) {
            IAaveLendingPoolV2 poolV2 = aaveLendingPool.lendingPoolV2;
            poolV2.borrow(
                address(token),
                borrowAmount,
                interestRateMode,
                aaveLendingPool.referalCode,
                onBehalfOf
            );
        }
    }

    /// @dev withdraw from lending platforms like AAVE, COMPOUND
    ///     expect amount of aToken or cToken should already be in the contract
    function withdrawFrom(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn
    ) external override onlySwapImpl returns (uint256 returnedAmount) {
        address lendingToken = getLendingToken(platform, token);

        uint256 tokenBalanceBefore;
        uint256 tokenBalanceAfter;
        if (platform == LendingPlatform.AAVE_V1) {
            // burn aToken to withdraw underlying token
            tokenBalanceBefore = getBalance(token, address(this));
            IAToken(lendingToken).redeem(amount);
            tokenBalanceAfter = getBalance(token, address(this));
            returnedAmount = tokenBalanceAfter.sub(tokenBalanceBefore);
            require(returnedAmount >= minReturn, "low returned amount");
            // transfer token to user
            transferToken(onBehalfOf, token, returnedAmount);
        } else if (platform == LendingPlatform.AAVE_V2) {
            if (token == ETH_TOKEN_ADDRESS) {
                // withdraw weth, then convert to eth for user
                address weth = address(aaveLendingPool.weth);
                // withdraw underlying token from pool
                tokenBalanceBefore = IERC20Ext(weth).balanceOf(address(this));
                returnedAmount = aaveLendingPool.lendingPoolV2.withdraw(
                    weth,
                    amount,
                    address(this)
                );
                tokenBalanceAfter = IERC20Ext(weth).balanceOf(address(this));
                require(
                    tokenBalanceAfter.sub(tokenBalanceBefore) >= returnedAmount,
                    "invalid return"
                );
                require(returnedAmount >= minReturn, "low returned amount");
                // convert weth to eth and transfer to sender
                IWeth(weth).withdraw(returnedAmount);
                (bool success, ) = onBehalfOf.call{value: returnedAmount}("");
                require(success, "transfer eth to sender failed");
            } else {
                // withdraw token directly to user's wallet
                tokenBalanceBefore = getBalance(token, onBehalfOf);
                returnedAmount = aaveLendingPool.lendingPoolV2.withdraw(
                    address(token),
                    amount,
                    onBehalfOf
                );
                tokenBalanceAfter = getBalance(token, onBehalfOf);
                // valid received amount in user's wallet
                require(
                    tokenBalanceAfter.sub(tokenBalanceBefore) >= returnedAmount,
                    "invalid return"
                );
                require(returnedAmount >= minReturn, "low returned amount");
            }
        } else {
            // COMPOUND
            // burn cToken to withdraw underlying token
            tokenBalanceBefore = getBalance(token, address(this));
            require(ICompErc20(lendingToken).redeem(amount) == 0, "unable to redeem");
            tokenBalanceAfter = getBalance(token, address(this));
            returnedAmount = tokenBalanceAfter.sub(tokenBalanceBefore);
            require(returnedAmount >= minReturn, "low returned amount");
            // transfer underlying token to user
            transferToken(onBehalfOf, token, returnedAmount);
        }
    }

    /// @dev repay borrows to lending platforms like AAVE, COMPOUND
    ///     expect amount of token should already be in the contract
    ///     if amount > payAmount, (amount - payAmount) will be sent back to user
    function repayBorrowTo(
        LendingPlatform platform,
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 payAmount,
        uint256 rateMode // only for aave v2
    ) external override onlySwapImpl {
        require(amount >= payAmount, "invalid pay amount");
        require(getBalance(token, address(this)) >= amount, "bad token balance");

        if (amount > payAmount) {
            // transfer back token
            transferToken(payable(onBehalfOf), token, amount - payAmount);
        }
        if (platform == LendingPlatform.AAVE_V1) {
            IAaveLendingPoolV1 poolV1 = aaveLendingPool.lendingPoolV1;

            poolV1.repay{value: token == ETH_TOKEN_ADDRESS ? payAmount : 0}(
                address(token),
                payAmount,
                onBehalfOf
            );
        } else if (platform == LendingPlatform.AAVE_V2) {
            IAaveLendingPoolV2 poolV2 = aaveLendingPool.lendingPoolV2;
            if (token == ETH_TOKEN_ADDRESS) {
                IWeth weth = aaveLendingPool.weth;
                weth.deposit{value: payAmount}();
                require(
                    poolV2.repay(address(weth), payAmount, rateMode, onBehalfOf) == payAmount,
                    "wrong paid amount"
                );
            } else {
                require(
                    poolV2.repay(address(token), payAmount, rateMode, onBehalfOf) == payAmount,
                    "wrong paid amount"
                );
            }
        } else {
            // compound
            address cToken = compoundData.cTokens[token];
            require(cToken != address(0), "token is not supported by Compound");
            if (token == ETH_TOKEN_ADDRESS) {
                ICompEth(cToken).repayBorrowBehalf{value: payAmount}(onBehalfOf);
            } else {
                require(
                    ICompErc20(cToken).repayBorrowBehalf(onBehalfOf, payAmount) == 0,
                    "compound repay error"
                );
            }
        }
    }

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external override onlySwapImpl {
        require(holders.length > 0, "no holders");
        IComptroller comptroller = IComptroller(compoundData.comptroller);
        if (cTokens.length == 0) {
            // claim for all markets
            ICompErc20[] memory markets = comptroller.getAllMarkets();
            comptroller.claimComp(holders, markets, borrowers, suppliers);
        } else {
            comptroller.claimComp(holders, cTokens, borrowers, suppliers);
        }
        emit ClaimedComp(holders, cTokens, borrowers, suppliers);
    }

    function getLendingToken(LendingPlatform platform, IERC20Ext token)
        public
        view
        override
        returns (address)
    {
        if (platform == LendingPlatform.AAVE_V1) {
            return aaveLendingPool.aTokensV1[token];
        } else if (platform == LendingPlatform.AAVE_V2) {
            return aaveLendingPool.aTokensV2[token];
        }
        return compoundData.cTokens[token];
    }

    /** @dev Calculate the current user debt and return
    */
    function storeAndRetrieveUserDebtCurrent(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) external override returns (uint256 debt) {
        if (platform == LendingPlatform.AAVE_V1 || platform == LendingPlatform.AAVE_V2) {
            debt = getUserDebtStored(platform, _reserve, _user);
            return debt;
        }
        ICompErc20 cToken = ICompErc20(compoundData.cTokens[IERC20Ext(_reserve)]);
        debt = cToken.borrowBalanceCurrent(_user);
    }

    /** @dev Return the stored user debt from given platform
    *   to get the latest data of user's debt for repaying, should call
    *   storeAndRetrieveUserDebtCurrent function, esp for Compound platform
    */
    function getUserDebtStored(
        LendingPlatform platform,
        address _reserve,
        address _user
    ) public view override returns (uint256 debt) {
        if (platform == LendingPlatform.AAVE_V1) {
            uint256 originationFee;
            IAaveLendingPoolV1 pool = aaveLendingPool.lendingPoolV1;
            (, debt, , , , , originationFee, , , ) = pool.getUserReserveData(_reserve, _user);
            debt = debt.add(originationFee);
        } else if (platform == LendingPlatform.AAVE_V2) {
            IProtocolDataProvider provider = aaveLendingPool.provider;
            (, uint256 stableDebt, uint256 variableDebt, , , , , , ) =
                provider.getUserReserveData(_reserve, _user);
            debt = stableDebt > 0 ? stableDebt : variableDebt;
        } else {
            ICompErc20 cToken = ICompErc20(compoundData.cTokens[IERC20Ext(_reserve)]);
            debt = cToken.borrowBalanceStored(_user);
        }
    }

    function safeApproveAllowance(address spender, IERC20Ext token) internal {
        if (token != ETH_TOKEN_ADDRESS && token.allowance(address(this), spender) == 0) {
            token.safeApprove(spender, MAX_ALLOWANCE);
        }
    }

    function transferToken(
        address payable recipient,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = recipient.call{value: amount}("");
            require(success, "failed to transfer eth");
        } else {
            token.safeTransfer(recipient, amount);
        }
    }
}

pragma solidity 0.6.6;

import "./ICompErc20.sol";


interface IComptroller {
    function getAllMarkets() external view returns (ICompErc20[] memory);
    function getCompAddress() external view returns (address);
    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers
    ) external;
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
}

pragma solidity 0.6.6;

import "../lending/ISmartWalletLending.sol";
import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


interface ISmartWalletSwapImplementation {
    event KyberTrade(
        address indexed trader,
        IERC20Ext indexed src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        address recipient,
        uint256 platformFeeBps,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTrade(
        address indexed trader,
        address indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        address recipient,
        uint256 platformFeeBps,
        address platformWallet,
        bool feeInSrc,
        bool useGasToken,
        uint256 numGasBurns
    );

    event KyberTradeAndDeposit(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 platformFeeBps,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTradeAndDeposit(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IUniswapV2Router02 indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 platformFeeBps,
        address platformWallet,
        bool useGasToken,
        uint256 numGasBurns
    );

    event BorrowFromLending(
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext token,
        uint256 amountBorrowed,
        uint256 interestRateMode,
        bool useGasToken,
        uint256 numGasBurns
    );

    event WithdrawFromLending(
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        uint256 actualReturnAmount,
        bool useGasToken,
        uint256 numGasBurns
    );

    event KyberTradeAndRepay(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IERC20Ext src,
        IERC20Ext indexed dest,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address platformWallet,
        bytes hint,
        bool useGasToken,
        uint numGasBurns
    );

    event UniswapTradeAndRepay(
        address indexed trader,
        ISmartWalletLending.LendingPlatform indexed platform,
        IUniswapV2Router02 indexed router,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address platformWallet,
        bool useGasToken,
        uint256 numGasBurns
    );

    function getExpectedReturnKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (
        uint256 destAmount,
        uint256 expectedRate
    );

    function getExpectedReturnUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps
    ) external view returns (
        uint256 destAmount,
        uint256 expectedRate
    );

    function swapKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapKyberAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswapAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function withdrawFromLendingPlatform(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        bool useGasToken
    ) external returns (uint256 returnedAmount);

    function swapKyberAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 payAmount,
        uint256 feeAndRateMode, // in case aave v2, fee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function swapUniswapAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 payAmount,
        address[] calldata tradePath,
        uint256 feeAndRateMode, // in case aave v2, fee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
        address payable platformWallet,
        bool useGasToken
    ) external payable returns (uint256 destAmount);

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers,
        bool useGasToken
    ) external;

    function claimPlatformFees(
        address[] calldata platformWallets,
        IERC20Ext[] calldata tokens
    ) external;
}

pragma solidity 0.6.6;

import "../interfaces/ISmartWalletSwapImplementation.sol";
import "./SmartWalletSwapStorage.sol";
import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


contract SmartWalletSwapImplementation is SmartWalletSwapStorage, ISmartWalletSwapImplementation {
    using SafeERC20 for IERC20Ext;
    using SafeMath for uint256;

    event UpdatedSupportedPlatformWallets(address[] wallets, bool isSupported);
    event UpdatedBurnGasHelper(IBurnGasHelper indexed gasHelper);
    event UpdatedLendingImplementation(ISmartWalletLending impl);
    event ApprovedAllowances(IERC20Ext[] tokens, address[] spenders, bool isReset);
    event ClaimedPlatformFees(address[] wallets, IERC20Ext[] tokens, address claimer);

    constructor(address _admin) public SmartWalletSwapStorage(_admin) {}

    receive() external payable {}

    function updateBurnGasHelper(IBurnGasHelper _burnGasHelper) external onlyAdmin {
        if (burnGasHelper != _burnGasHelper) {
            burnGasHelper = _burnGasHelper;
            emit UpdatedBurnGasHelper(_burnGasHelper);
        }
    }

    function updateLendingImplementation(ISmartWalletLending newImpl) external onlyAdmin {
        require(newImpl != ISmartWalletLending(0), "invalid lending impl");
        lendingImpl = newImpl;
        emit UpdatedLendingImplementation(newImpl);
    }

    /// @dev to prevent other integrations to call trade from this contract
    function updateSupportedPlatformWallets(address[] calldata wallets, bool isSupported)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < wallets.length; i++) {
            supportedPlatformWallets[wallets[i]] = isSupported;
        }
        emit UpdatedSupportedPlatformWallets(wallets, isSupported);
    }

    function claimPlatformFees(address[] calldata platformWallets, IERC20Ext[] calldata tokens)
        external
        override
        nonReentrant
    {
        for (uint256 i = 0; i < platformWallets.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 fee = platformWalletFees[platformWallets[i]][tokens[j]];
                if (fee > 1) {
                    platformWalletFees[platformWallets[i]][tokens[j]] = 1;
                    transferToken(payable(platformWallets[i]), tokens[j], fee - 1);
                }
            }
        }
        emit ClaimedPlatformFees(platformWallets, tokens, msg.sender);
    }

    function approveAllowances(
        IERC20Ext[] calldata tokens,
        address[] calldata spenders,
        bool isReset
    ) external onlyAdmin {
        uint256 allowance = isReset ? 0 : MAX_ALLOWANCE;
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = 0; j < spenders.length; j++) {
                tokens[i].safeApprove(spenders[j], allowance);
            }
            getSetDecimals(tokens[i]);
        }

        emit ApprovedAllowances(tokens, spenders, isReset);
    }

    /// ========== SWAP ========== ///

    /// @dev swap token via Kyber
    /// @notice for some tokens that are paying fee, for example: DGX
    /// contract will trade with received src token amount (after minus fee)
    /// for Kyber, fee will be taken in ETH as part of their feature
    function swapKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        destAmount = doKyberTrade(
            src,
            dest,
            srcAmount,
            minConversionRate,
            recipient,
            platformFeeBps,
            platformWallet,
            hint
        );
        uint256 numGasBurns = 0;
        // burn gas token if needed
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }
        emit KyberTrade(
            msg.sender,
            src,
            dest,
            srcAmount,
            destAmount,
            recipient,
            platformFeeBps,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    /// @dev swap token via a supported Uniswap router
    /// @notice for some tokens that are paying fee, for example: DGX
    /// contract will trade with received src token amount (after minus fee)
    /// for Uniswap, fee will be taken in src token
    function swapUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            // prevent stack too deep
            uint256 gasBefore = useGasToken ? gasleft() : 0;
            destAmount = swapUniswapInternal(
                router,
                srcAmount,
                minDestAmount,
                tradePath,
                recipient,
                platformFeeBps,
                platformWallet,
                feeInSrc
            );
            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit UniswapTrade(
            msg.sender,
            address(router),
            tradePath,
            srcAmount,
            destAmount,
            recipient,
            platformFeeBps,
            platformWallet,
            feeInSrc,
            useGasToken,
            numGasBurns
        );
    }

    /// ========== SWAP & DEPOSIT ========== ///

    function swapKyberAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        if (src == dest) {
            // just collect src token, no need to swap
            destAmount = safeForwardTokenAndCollectFee(
                src,
                msg.sender,
                payable(address(lendingImpl)),
                srcAmount,
                platformFeeBps,
                platformWallet
            );
        } else {
            destAmount = doKyberTrade(
                src,
                dest,
                srcAmount,
                minConversionRate,
                payable(address(lendingImpl)),
                platformFeeBps,
                platformWallet,
                hint
            );
        }

        // eth or token alr transferred to the address
        lendingImpl.depositTo(platform, msg.sender, dest, destAmount);

        uint256 numGasBurns = 0;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }

        emit KyberTradeAndDeposit(
            msg.sender,
            platform,
            src,
            dest,
            srcAmount,
            destAmount,
            platformFeeBps,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    /// @dev swap Uniswap then deposit to platform
    ///     if tradePath has only 1 token, don't need to do swap
    /// @param platform platform to deposit
    /// @param router which Uni-clone to use for swapping
    /// @param srcAmount amount of src token
    /// @param minDestAmount minimal accepted dest amount
    /// @param tradePath path of the trade on Uniswap
    /// @param platformFeeBps fee if swapping
    /// @param platformWallet wallet to receive fee
    /// @param useGasToken whether to use gas token or not
    function swapUniswapAndDeposit(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        {
            IERC20Ext dest = IERC20Ext(tradePath[tradePath.length - 1]);
            if (tradePath.length == 1) {
                // just collect src token, no need to swap
                destAmount = safeForwardTokenAndCollectFee(
                    dest,
                    msg.sender,
                    payable(address(lendingImpl)),
                    srcAmount,
                    platformFeeBps,
                    platformWallet
                );
            } else {
                destAmount = swapUniswapInternal(
                    router,
                    srcAmount,
                    minDestAmount,
                    tradePath,
                    payable(address(lendingImpl)),
                    platformFeeBps,
                    platformWallet,
                    false
                );
            }

            // eth or token alr transferred to the address
            lendingImpl.depositTo(platform, msg.sender, dest, destAmount);
        }

        uint256 numGasBurns = 0;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }

        emit UniswapTradeAndDeposit(
            msg.sender,
            platform,
            router,
            tradePath,
            srcAmount,
            destAmount,
            platformFeeBps,
            platformWallet,
            useGasToken,
            numGasBurns
        );
    }

    /// @dev withdraw token from Lending platforms (AAVE, COMPOUND)
    /// @param platform platform to withdraw token
    /// @param token underlying token to withdraw, e.g ETH, USDT, DAI
    /// @param amount amount of cToken (COMPOUND) or aToken (AAVE) to withdraw
    /// @param minReturn minimum amount of USDT tokens to return
    /// @param useGasToken whether to use gas token or not
    /// @return returnedAmount returns the amount withdrawn to the user
    function withdrawFromLendingPlatform(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        bool useGasToken
    ) external override nonReentrant returns (uint256 returnedAmount) {
        require(lendingImpl != ISmartWalletLending(0));
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        IERC20Ext lendingToken = IERC20Ext(lendingImpl.getLendingToken(platform, token));
        require(lendingToken != IERC20Ext(0), "unsupported token");
        // AAVE aToken's transfer logic could have rounding errors
        uint256 tokenBalanceBefore = lendingToken.balanceOf(address(lendingImpl));
        lendingToken.safeTransferFrom(msg.sender, address(lendingImpl), amount);
        uint256 tokenBalanceAfter = lendingToken.balanceOf(address(lendingImpl));

        returnedAmount = lendingImpl.withdrawFrom(
            platform,
            msg.sender,
            token,
            tokenBalanceAfter.sub(tokenBalanceBefore),
            minReturn
        );

        uint256 numGasBurns;
        if (useGasToken) {
            numGasBurns = burnGasTokensAfter(gasBefore);
        }
        emit WithdrawFromLending(
            platform,
            token,
            amount,
            minReturn,
            returnedAmount,
            useGasToken,
            numGasBurns
        );
    }

    /// @dev swap on Kyber and repay borrow for sender
    /// if src == dest, no need to swap, use src token to repay directly
    /// @param payAmount: amount that user wants to pay, if the dest amount (after swap) is higher,
    ///     the remain amount will be sent back to user's wallet
    /// @param feeAndRateMode: in case of aave v2, user needs to specify the rateMode to repay
    ///     to prevent stack too deep, combine fee and rateMode into a single value
    ///     platformFee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
    /// Other params are params for trade on Kyber
    function swapKyberAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 payAmount,
        uint256 feeAndRateMode,
        address payable platformWallet,
        bytes calldata hint,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            require(lendingImpl != ISmartWalletLending(0));
            uint256 gasBefore = useGasToken ? gasleft() : 0;

            {
                // use user debt value if debt is <= payAmount,
                // user can pay all debt by putting really high payAmount as param
                payAmount = checkUserDebt(platform, address(dest), payAmount);
                if (src == dest) {
                    if (src == ETH_TOKEN_ADDRESS) {
                        require(msg.value == srcAmount, "invalid msg value");
                        transferToken(payable(address(lendingImpl)), src, srcAmount);
                    } else {
                        destAmount = srcAmount > payAmount ? payAmount : srcAmount;
                        src.safeTransferFrom(msg.sender, address(lendingImpl), destAmount);
                    }
                } else {
                    // use user debt value if debt is <= payAmount
                    payAmount = checkUserDebt(platform, address(dest), payAmount);

                    // use min rate so it can return earlier if failed to swap
                    uint256 minRate =
                        calcRateFromQty(srcAmount, payAmount, src.decimals(), dest.decimals());

                    destAmount = doKyberTrade(
                        src,
                        dest,
                        srcAmount,
                        minRate,
                        payable(address(lendingImpl)),
                        feeAndRateMode % BPS,
                        platformWallet,
                        hint
                    );
                }
            }

            lendingImpl.repayBorrowTo(
                platform,
                msg.sender,
                dest,
                destAmount,
                payAmount,
                feeAndRateMode / BPS
            );

            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit KyberTradeAndRepay(
            msg.sender,
            platform,
            src,
            dest,
            srcAmount,
            destAmount,
            payAmount,
            feeAndRateMode,
            platformWallet,
            hint,
            useGasToken,
            numGasBurns
        );
    }

    /// @dev swap on Uni-clone and repay borrow for sender
    /// if tradePath.length == 1, no need to swap, use tradePath[0] token to repay directly
    /// @param payAmount: amount that user wants to pay, if the dest amount (after swap) is higher,
    ///     the remain amount will be sent back to user's wallet
    /// @param feeAndRateMode: in case of aave v2, user needs to specify the rateMode to repay
    ///     to prevent stack too deep, combine fee and rateMode into a single value
    ///     platformFee: feeAndRateMode % BPS, rateMode: feeAndRateMode / BPS
    /// Other params are params for trade on Uni-clone
    function swapUniswapAndRepay(
        ISmartWalletLending.LendingPlatform platform,
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 payAmount,
        address[] calldata tradePath,
        uint256 feeAndRateMode,
        address payable platformWallet,
        bool useGasToken
    ) external payable override nonReentrant returns (uint256 destAmount) {
        uint256 numGasBurns;
        {
            // scope to prevent stack too deep
            require(lendingImpl != ISmartWalletLending(0));
            uint256 gasBefore = useGasToken ? gasleft() : 0;
            IERC20Ext dest = IERC20Ext(tradePath[tradePath.length - 1]);

            // use user debt value if debt is <= payAmount
            // user can pay all debt by putting really high payAmount as param
            payAmount = checkUserDebt(platform, address(dest), payAmount);
            if (tradePath.length == 1) {
                if (dest == ETH_TOKEN_ADDRESS) {
                    require(msg.value == srcAmount, "invalid msg value");
                    transferToken(payable(address(lendingImpl)), dest, srcAmount);
                } else {
                    destAmount = srcAmount > payAmount ? payAmount : srcAmount;
                    dest.safeTransferFrom(msg.sender, address(lendingImpl), destAmount);
                }
            } else {
                destAmount = swapUniswapInternal(
                    router,
                    srcAmount,
                    payAmount,
                    tradePath,
                    payable(address(lendingImpl)),
                    feeAndRateMode % BPS,
                    platformWallet,
                    false
                );
            }

            lendingImpl.repayBorrowTo(
                platform,
                msg.sender,
                dest,
                destAmount,
                payAmount,
                feeAndRateMode / BPS
            );

            if (useGasToken) {
                numGasBurns = burnGasTokensAfter(gasBefore);
            }
        }

        emit UniswapTradeAndRepay(
            msg.sender,
            platform,
            router,
            tradePath,
            srcAmount,
            destAmount,
            payAmount,
            feeAndRateMode,
            platformWallet,
            useGasToken,
            numGasBurns
        );
    }

    function claimComp(
        address[] calldata holders,
        ICompErc20[] calldata cTokens,
        bool borrowers,
        bool suppliers,
        bool useGasToken
    ) external override nonReentrant {
        uint256 gasBefore = useGasToken ? gasleft() : 0;
        lendingImpl.claimComp(holders, cTokens, borrowers, suppliers);
        if (useGasToken) {
            burnGasTokensAfter(gasBefore);
        }
    }

    /// @dev get expected return and conversion rate if using Kyber
    function getExpectedReturnKyber(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 platformFee,
        bytes calldata hint
    ) external view override returns (uint256 destAmount, uint256 expectedRate) {
        try kyberProxy.getExpectedRateAfterFee(src, dest, srcAmount, platformFee, hint) returns (
            uint256 rate
        ) {
            expectedRate = rate;
        } catch {
            expectedRate = 0;
        }
        destAmount = calcDestAmount(src, dest, srcAmount, expectedRate);
    }

    /// @dev get expected return and conversion rate if using a Uniswap router
    function getExpectedReturnUniswap(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        address[] calldata tradePath,
        uint256 platformFee
    ) external view override returns (uint256 destAmount, uint256 expectedRate) {
        if (platformFee >= BPS) return (0, 0); // platform fee is too high
        if (!isRouterSupported[router]) return (0, 0); // router is not supported
        uint256 srcAmountAfterFee = (srcAmount * (BPS - platformFee)) / BPS;
        if (srcAmountAfterFee == 0) return (0, 0);
        // in case pair is not supported
        try router.getAmountsOut(srcAmountAfterFee, tradePath) returns (uint256[] memory amounts) {
            destAmount = amounts[tradePath.length - 1];
        } catch {
            destAmount = 0;
        }
        expectedRate = calcRateFromQty(
            srcAmountAfterFee,
            destAmount,
            getDecimals(IERC20Ext(tradePath[0])),
            getDecimals(IERC20Ext(tradePath[tradePath.length - 1]))
        );
    }

    function checkUserDebt(
        ISmartWalletLending.LendingPlatform platform,
        address token,
        uint256 amount
    ) internal returns (uint256) {
        uint256 debt = lendingImpl.storeAndRetrieveUserDebtCurrent(platform, token, msg.sender);

        if (debt >= amount) {
            return amount;
        }

        return debt;
    }

    function doKyberTrade(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 minConversionRate,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bytes memory hint
    ) internal virtual returns (uint256 destAmount) {
        uint256 actualSrcAmount =
            validateAndPrepareSourceAmount(address(kyberProxy), src, srcAmount, platformWallet);
        uint256 callValue = src == ETH_TOKEN_ADDRESS ? actualSrcAmount : 0;
        destAmount = kyberProxy.tradeWithHintAndFee{value: callValue}(
            src,
            actualSrcAmount,
            dest,
            recipient,
            MAX_AMOUNT,
            minConversionRate,
            platformWallet,
            platformFeeBps,
            hint
        );
    }

    function swapUniswapInternal(
        IUniswapV2Router02 router,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] memory tradePath,
        address payable recipient,
        uint256 platformFeeBps,
        address payable platformWallet,
        bool feeInSrc
    ) internal returns (uint256 destAmount) {
        TradeInput memory input =
            TradeInput({
                srcAmount: srcAmount,
                minData: minDestAmount,
                recipient: recipient,
                platformFeeBps: platformFeeBps,
                platformWallet: platformWallet,
                hint: ""
            });

        // extra validation when swapping on Uniswap
        require(isRouterSupported[router], "unsupported router");
        require(platformFeeBps < BPS, "high platform fee");

        IERC20Ext src = IERC20Ext(tradePath[0]);

        input.srcAmount = validateAndPrepareSourceAmount(
            address(router),
            src,
            srcAmount,
            platformWallet
        );

        destAmount = doUniswapTrade(router, src, tradePath, input, feeInSrc);
    }

    function doUniswapTrade(
        IUniswapV2Router02 router,
        IERC20Ext src,
        address[] memory tradePath,
        TradeInput memory input,
        bool feeInSrc
    ) internal virtual returns (uint256 destAmount) {
        uint256 tradeLen = tradePath.length;
        IERC20Ext actualDest = IERC20Ext(tradePath[tradeLen - 1]);
        {
            // convert eth -> weth address to trade on Uniswap
            if (tradePath[0] == address(ETH_TOKEN_ADDRESS)) {
                tradePath[0] = router.WETH();
            }
            if (tradePath[tradeLen - 1] == address(ETH_TOKEN_ADDRESS)) {
                tradePath[tradeLen - 1] = router.WETH();
            }
        }

        uint256 srcAmountFee;
        uint256 srcAmountAfterFee;
        uint256 destBalanceBefore;
        address recipient;

        if (feeInSrc) {
            srcAmountFee = input.srcAmount.mul(input.platformFeeBps).div(BPS);
            srcAmountAfterFee = input.srcAmount.sub(srcAmountFee);
            recipient = input.recipient;
        } else {
            srcAmountAfterFee = input.srcAmount;
            destBalanceBefore = getBalance(actualDest, address(this));
            recipient = address(this);
        }

        uint256[] memory amounts;
        if (src == ETH_TOKEN_ADDRESS) {
            // swap eth -> token
            amounts = router.swapExactETHForTokens{value: srcAmountAfterFee}(
                input.minData,
                tradePath,
                recipient,
                MAX_AMOUNT
            );
        } else {
            if (actualDest == ETH_TOKEN_ADDRESS) {
                // swap token -> eth
                amounts = router.swapExactTokensForETH(
                    srcAmountAfterFee,
                    input.minData,
                    tradePath,
                    recipient,
                    MAX_AMOUNT
                );
            } else {
                // swap token -> token
                amounts = router.swapExactTokensForTokens(
                    srcAmountAfterFee,
                    input.minData,
                    tradePath,
                    recipient,
                    MAX_AMOUNT
                );
            }
        }

        if (!feeInSrc) {
            // fee in dest token, calculated received dest amount
            uint256 destBalanceAfter = getBalance(actualDest, address(this));
            destAmount = destBalanceAfter.sub(destBalanceBefore);
            uint256 destAmountFee = destAmount.mul(input.platformFeeBps).div(BPS);
            // charge fee in dest token
            addFeeToPlatform(input.platformWallet, actualDest, destAmountFee);
            // transfer back dest token to recipient
            destAmount = destAmount.sub(destAmountFee);
            transferToken(input.recipient, actualDest, destAmount);
        } else {
            // fee in src amount
            destAmount = amounts[amounts.length - 1];
            addFeeToPlatform(input.platformWallet, src, srcAmountFee);
        }
    }

    function validateAndPrepareSourceAmount(
        address protocol,
        IERC20Ext src,
        uint256 srcAmount,
        address platformWallet
    ) internal virtual returns (uint256 actualSrcAmount) {
        require(supportedPlatformWallets[platformWallet], "unsupported platform wallet");
        if (src == ETH_TOKEN_ADDRESS) {
            require(msg.value == srcAmount, "wrong msg value");
            actualSrcAmount = srcAmount;
        } else {
            require(msg.value == 0, "bad msg value");
            uint256 balanceBefore = src.balanceOf(address(this));
            src.safeTransferFrom(msg.sender, address(this), srcAmount);
            uint256 balanceAfter = src.balanceOf(address(this));
            actualSrcAmount = balanceAfter.sub(balanceBefore);
            require(actualSrcAmount > 0, "invalid src amount");

            safeApproveAllowance(protocol, src);
        }
    }

    function burnGasTokensAfter(uint256 gasBefore) internal virtual returns (uint256 numGasBurns) {
        if (burnGasHelper == IBurnGasHelper(0)) return 0;
        IGasToken gasToken;
        uint256 gasAfter = gasleft();

        try
            burnGasHelper.getAmountGasTokensToBurn(gasBefore.sub(gasAfter).add(msg.data.length))
        returns (uint256 _gasBurns, address _gasToken) {
            numGasBurns = _gasBurns;
            gasToken = IGasToken(_gasToken);
        } catch {
            numGasBurns = 0;
        }

        if (numGasBurns > 0 && gasToken != IGasToken(0)) {
            numGasBurns = gasToken.freeFromUpTo(msg.sender, numGasBurns);
        }
    }

    function safeForwardTokenAndCollectFee(
        IERC20Ext token,
        address from,
        address payable to,
        uint256 amount,
        uint256 platformFeeBps,
        address payable platformWallet
    ) internal returns (uint256 destAmount) {
        require(platformFeeBps < BPS, "high platform fee");
        require(supportedPlatformWallets[platformWallet], "unsupported platform wallet");
        uint256 feeAmount = (amount * platformFeeBps) / BPS;
        destAmount = amount - feeAmount;
        if (token == ETH_TOKEN_ADDRESS) {
            require(msg.value >= amount);
            (bool success, ) = to.call{value: destAmount}("");
            require(success, "transfer eth failed");
        } else {
            uint256 balanceBefore = token.balanceOf(to);
            token.safeTransferFrom(from, to, amount);
            uint256 balanceAfter = token.balanceOf(to);
            destAmount = balanceAfter.sub(balanceBefore);
        }
        addFeeToPlatform(platformWallet, token, feeAmount);
    }

    function addFeeToPlatform(
        address wallet,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount > 0) {
            platformWalletFees[wallet][token] = platformWalletFees[wallet][token].add(amount);
        }
    }

    function transferToken(
        address payable recipient,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount == 0) return;
        if (token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = recipient.call{value: amount}("");
            require(success, "failed to transfer eth");
        } else {
            token.safeTransfer(recipient, amount);
        }
    }

    function safeApproveAllowance(address spender, IERC20Ext token) internal {
        if (token.allowance(address(this), spender) == 0) {
            getSetDecimals(token);
            token.safeApprove(spender, MAX_ALLOWANCE);
        }
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^0.5.16;

contract Ownable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }
}

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

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

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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

interface IToken {
    function decimals() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function deposit() external payable;
    function withdraw(uint amount) external;
}

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

    function safeTransfer(IToken token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IToken token, bytes memory data) private {
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

library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {
        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {
        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

contract FundsMgr is Ownable {
    using UniversalERC20 for IToken;

    function withdraw(address token, uint256 amount) public onlyOwner {
        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            IToken(token).universalTransfer(owner, amount);
        }
    }

    function withdrawAll(address[] memory tokens) public onlyOwner {
        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
        }
    }
}

interface IGST2 {
	function freeUpTo(uint256 value) external returns(uint256 freed);
	function freeFromUpTo(address from, uint256 value) external returns(uint256 freed);
    function balanceOf(address account) external view returns (uint256);
}

contract GasTokenSpender {

    address public constant GAS_TOKEN = 0x0000000000b3F879cb30FE243b4Dfee438691c04;

    // ** PUBLIC VIEW functions **

    function gasTokenBalance() public view returns(uint256 amount) {
        amount = IGST2(GAS_TOKEN).balanceOf(address(this));
    }

    // ** INTERNAL functions **

    function _burnGasToken(uint256 gasSpent) internal returns(bool) {
        uint maxTokens = gasTokenBalance();
        if (maxTokens == 0) {
            return false;
        }

        uint tokensToBurn = (gasSpent + 14154) / 41130;
        if (tokensToBurn > maxTokens) {
            tokensToBurn = maxTokens;
        }

        IGST2(GAS_TOKEN).freeUpTo(tokensToBurn);

        return true;
    }
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    /*function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }*/
}
// import "../utils/UniversalERC20.sol";

contract ConstantAddressesMainnet {
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public constant COMPOUND_ORACLE = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant CETH_ADDRESS = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant CUSDC_ADDRESS = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
}

// solhint-disable-next-line no-empty-blocks
contract ConstantAddresses is ConstantAddressesMainnet {}

// ** INTERFACES **

interface IDfWallet {

    function setDfFinanceClose(address _dfFinanceClose) external;

    function deposit(
        address _tokenIn, address _cTokenIn, uint _amountIn, address _tokenOut, address _cTokenOut, uint _amountOut
    ) external payable;

    function withdraw(
        address _tokenIn, address _cTokenIn, address _tokenOut, address _cTokenOut
    ) external payable;

}

interface ICToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral)
        external
        returns (uint256);

    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function borrowRatePerBlock() external returns (uint256);

    function totalReserves() external returns (uint256);

    function reserveFactorMantissa() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function getCash() external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function underlying() external returns (address);
}

interface ICompoundOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}

interface IDfFinanceClose {

    // setup with Compound Oracle eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) external;

    // setup with special eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) external;

    // setup with special eth price and current extraCoef 每 for strategy migration
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee, uint256 _extraCoef
    ) external;

    function getStrategy(
        address _dfWallet
    ) external view
    returns(
        address strategyOwner,
        uint deposit,
        uint extraCoef,
        uint entryEthPrice,
        uint profitPercent,
        uint fee,
        uint ethForRedeem,
        uint usdToWithdraw,
        bool onlyProfitInUsd);

    function migrateStrategies(address[] calldata _dfWallets) external;

    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes calldata _exData
    ) external payable;

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes calldata _exData
    ) external payable;

    function depositEth(address _dfWallet) external payable;

}

interface IOneInchExchange {
    function spender() external view returns (address);
}

interface ILoanPool {
    function loan(uint _amount) external;
}

interface IAffiliateProgram {

    function getProfitPercentByReferral(address referral) external view returns (uint8);

    function addReferral(address referral, bytes32 code, uint256 ethValue) external;
    function distributeProfitByReferral(address referral) external payable;

/*
    function getPartnerByReferral(address referral) external view returns (address, uint8, uint256, uint256, uint256);
    function levels(uint8 level) external view returns (uint16, uint256);
*/

    // Old functions for Maker Sai ver.
    function addUserUseCode(address user, string calldata code) external;
    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);
    function levels(uint8 level) external view returns (uint16, uint256);
    function addPartnerProfitUseAddress(address partner) external payable;

}

contract DfFinanceCloseCompound is DSMath, ConstantAddresses, GasTokenSpender, FundsMgr {
    using UniversalERC20 for IToken;

    struct Strategy {
        // first bytes32 (== uint256) slot
        uint80 deposit;  // in eth 每 max more 1.2 mln eth
        uint80 entryEthPrice;  // in usd 每 max more 1.2 mln USD for 1 eth
        uint8 profitPercent;  // % 每 0 to 255
        uint8 fee;  // % 每 0 to 100 (ex. 30% = 30)
        uint80 ethForRedeem;  // eth for repay loan 每 max more 1.2 mln eth

        // second bytes32 (== uint256) slot
        uint64 usdToWithdraw;  // in usd
        bool onlyProfitInUsd;  // only profit withdraw in usd (deposit withdraw in eth)
        address owner;  // == uint160
        uint16 extraCoef;  // extra locked coef in % (100 == 1/1) where ethLocked = extraCoef * deposit
    }

    mapping(address => bool) public admins;
    mapping(address => bool) public strategyManagers;

    mapping(address => Strategy) public strategies;  //  dfWallet => Strategy

    ILoanPool public loanPool;
    IAffiliateProgram public aff;

    IDfFinanceClose public upgradedAddress;  // DfFinanceClose contract for migration

    // Fee
    uint256 public earlyCloseFee;  // fee for early close
    uint256 public dateUntilFees;  // date until earlyCloseFee available

    // ** EVENTS **

    event StrategyClosing(address indexed dfWallet, uint ethToWithdraw, uint usdToWithdraw);
    event StrategyClosed(address indexed dfWallet, uint ethToWithdraw, uint usdToWithdraw);
    event SetupStrategy(
        address indexed owner, address indexed dfWallet, uint deposit, uint priceEth, uint8 profitPercent, uint8 fee
    );

    event StrategyMigrated(address indexed dfWallet);

    event SystemProfit(uint profit);

    // ** MODIFIERS **

    modifier hasSetupStrategyPermission {
        require(strategyManagers[msg.sender], "Setup cup permission denied");
        _;
    }

    modifier onlyOwnerOrAdmin {
        require(admins[msg.sender] || msg.sender == owner, "Permission denied");
        _;
    }

    modifier useGasToken {
        uint gasProvided = gasleft();
        _;
        _burnGasToken(sub(gasProvided, gasleft()));
    }

    // ** CONSTRUCTOR **

    constructor() public {
        loanPool = ILoanPool(0x9EdAe6aAb4B0f0f8146051ab353593209982d6B6);
        strategyManagers[address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b)] = true;  // TODO: set DfFinanceOpenCompound
        strategyManagers[address(0x7eF7eBf6c5DA51A95109f31063B74ECf269b22bE)] = true;  // TODO: set DfFinanceOpenCompound (v2)
    }

    // ** PUBLIC VIEW function **

    function getStrategy(address _dfWallet) public view returns(
        address strategyOwner,
        uint deposit,
        uint extraCoef,
        uint entryEthPrice,
        uint profitPercent,
        uint fee,
        uint ethForRedeem,
        uint usdToWithdraw,
        bool onlyProfitInUsd)
    {
        strategyOwner = strategies[_dfWallet].owner;
        deposit = strategies[_dfWallet].deposit;
        extraCoef = strategies[_dfWallet].extraCoef;
        entryEthPrice = strategies[_dfWallet].entryEthPrice;
        profitPercent = strategies[_dfWallet].profitPercent;
        fee = strategies[_dfWallet].fee;
        ethForRedeem = strategies[_dfWallet].ethForRedeem;
        usdToWithdraw = strategies[_dfWallet].usdToWithdraw;
        onlyProfitInUsd = strategies[_dfWallet].onlyProfitInUsd;
    }

    function getCurPriceEth() public view returns(uint256) {
        // eth - usdc price call to Compound Oracle contract
        uint price = ICompoundOracle(COMPOUND_ORACLE).getUnderlyingPrice(CUSDC_ADDRESS) / 1e12;   // get 1e18 price * 1e12
        return wdiv(WAD, price);
    }

    // * SETUP_STRATAGY_PERMISSION function **

    // setup with Compound Oracle eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint8 _profitPercent, uint8 _fee
    ) public hasSetupStrategyPermission {
        _setupStrategy(_owner, _dfWallet, _deposit, getCurPriceEth(), _profitPercent, _fee, 0);
    }

    // setup with special eth price
    function setupStrategy(
        address _owner, address _dfWallet, uint256 _deposit, uint256 _priceEth, uint8 _profitPercent, uint8 _fee
    ) public hasSetupStrategyPermission {
        _setupStrategy(_owner, _dfWallet, _deposit, _priceEth, _profitPercent, _fee, 0);
    }

    // setup with special eth price and current extraCoef 每 for strategy migration
    function setupStrategy(
        address _owner,
        address _dfWallet,
        uint256 _deposit,
        uint256 _priceEth,
        uint8 _profitPercent,
        uint8 _fee,
        uint256 _extraCoef
    ) public hasSetupStrategyPermission {
        _setupStrategy(_owner, _dfWallet, _deposit, _priceEth, _profitPercent, _fee, _extraCoef);
    }

    // ** ONLY_OWNER_OR_ADMIN functions **

    // with GasToken usage
    function collectUsdForStrategies(
        address[] memory _dfWallets,
        uint256 _amountUsdToRedeem,
        uint256 _amountUsdToBuy,
        uint256 _usdPrice,
        bool _onlyProfitInUsd,
        bool _useExchange,
        bytes memory _exData
    ) public
    useGasToken
    onlyOwnerOrAdmin {
        // uint usdDecimals = IToken(USDC_ADDRESS).decimals(); == 1e6
        uint totalLoanEth = wmul(add(_amountUsdToRedeem, _amountUsdToBuy), _usdPrice, 1e6) * 1e12;

        // exchange function result
        /**
            exResult[2] - extra ToTokens after exchange 每 USDC
            exResult[3] - extra FromTokens after exchange 每 ETH
         */
        uint[4] memory exResult;

        // Use 1inch exchange (ETH to USDC swap)
        if (_useExchange) {
            loanPool.loan(totalLoanEth);  // take an totalCredit eth loan
            exResult = _exchange(
                IToken(ETH_ADDRESS), totalLoanEth,
                IToken(USDC_ADDRESS), add(_amountUsdToRedeem, _amountUsdToBuy),
                _exData
            );
        }

        uint ethAfterClose = 0; //  count all ETH gets for USDC exchange after closing strategies

        // collect USD for close logic
        for (uint i = 0; i < _dfWallets.length; i++) {
            ethAfterClose += _collectUsdHelper(_dfWallets[i], _amountUsdToBuy, _usdPrice, _onlyProfitInUsd);
        }

        require(ethAfterClose >= totalLoanEth, "EthAfterClose is not enough");

        // distribute extra exchange profit
        if (exResult[2] > 0 || exResult[3] > 0) {
            /**
                exResult[2] - extra ToTokens after exchange 每 USDC
                exResult[3] - extra FromTokens after exchange 每 ETH
             */
            _distributeExtraExchangeProfit(_dfWallets, exResult[3], exResult[2]);
        }
    }

    // with GasToken usage
    function collectAndClose(
        address[] memory _dfWallets,
        uint256 _amountUsdToRedeem,
        uint256 _amountUsdToBuy,
        uint256 _usdPrice,
        bool _onlyProfitInUsd,
        bool _useExchange,
        bytes memory _exData
    ) public {  // onlyOwnerOrAdmin & useGasToken in collectUsdForStrategies function

        // step 1: collect usd for closing
        collectUsdForStrategies(
            _dfWallets,
            _amountUsdToRedeem,
            _amountUsdToBuy,
            _usdPrice,
            _onlyProfitInUsd,
            _useExchange,
            _exData
        );

        // step 2: close strategies
        closeStrategies(_dfWallets);
    }

    // ** PUBLIC function **

    // with GasToken usage
    function closeStrategy(address _dfWallet) public useGasToken {
        require(strategies[_dfWallet].ethForRedeem > 0, "Strategy is not exists or ready for close");

        // close strategy internal
        _strategyCloseHelper(_dfWallet);
    }

    // with GasToken usage
    function closeStrategies(address[] memory _dfWallets) public useGasToken {
        for (uint i = 0; i < _dfWallets.length; i++) {
            require(strategies[_dfWallets[i]].ethForRedeem > 0, "Strategy is not exists or ready for close");
            // close strategy internal
            _strategyCloseHelper(_dfWallets[i]);
        }
    }

    function migrateStrategies(address[] memory _dfWallets) public {
        IDfFinanceClose migrationAddress = upgradedAddress;
        require(migrationAddress != IDfFinanceClose(0), "Migration is not available");

        for(uint i = 0; i < _dfWallets.length; i++) {
            Strategy memory strategy = strategies[_dfWallets[i]];
            require(strategy.owner == msg.sender, "Strategy permission denied");
            require(strategy.ethForRedeem == 0, "Strategy is not valid for migrate");

            migrationAddress.setupStrategy(
                strategy.owner,
                _dfWallets[i],
                strategy.deposit,
                strategy.entryEthPrice,
                strategy.profitPercent,
                strategy.fee,
                strategy.extraCoef
            );

            // change dfWallet's DfFinanceClose contract state
            IDfWallet(_dfWallets[i]).setDfFinanceClose(address(migrationAddress));

            // clear _dfWallets[i] strategy struct
            _clearStrategy(_dfWallets[i]);

            emit StrategyMigrated(_dfWallets[i]);
        }
    }

    function depositEth(address _dfWallet) public payable {
        require(strategies[_dfWallet].deposit > 0, "Strategy is not exists");

        uint addedEth = msg.value;

        strategies[_dfWallet].deposit += uint80(addedEth);

        // mint cEther without borrowing
        IDfWallet(_dfWallet).deposit.value(addedEth)(ETH_ADDRESS, CETH_ADDRESS, addedEth, address(0), address(0), 0);
    }

    // with GasToken usage
    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes memory _exData
    ) public payable useGasToken {
        require(strategies[_dfWallet].owner == msg.sender, "Strategy permission denied");

        _collectAndCloseHelper(
            _dfWallet, _ethForRedeem, _minAmountUsd, _onlyProfitInUsd, _exData, true
        );
    }

    // with GasToken usage
    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes memory _exData
    ) public payable useGasToken {
        Strategy memory strategy = strategies[_dfWallet];

        // only strategy owner or onlyOwnerOrAdmin call
        require(
            msg.sender == strategy.owner ||
            msg.sender == owner ||
            admins[msg.sender], "Permission denied");

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint ethInitial = mul(strategy.deposit, strategy.extraCoef) / 100;

        require(ethLocked < ethInitial, "Strategy is active - there was no liquidation");

        _collectAndCloseHelper(
            _dfWallet, _ethForRedeem, _minAmountUsd, false, _exData, false
        );
    }

    // ** ONLY_OWNER functions **

    function setLoanPool(address _loanAddr) public onlyOwner {
        require(_loanAddr != address(0), "Address must not be zero");
        loanPool = ILoanPool(_loanAddr);
    }

    function setAdminPermission(address _admin, bool _status) public onlyOwner {
        admins[_admin] = _status;
    }

    function setAdminPermission(address[] memory _admins, bool _status) public onlyOwner {
        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = _status;
        }
    }

    function setSetupStrategyPermission(address _manager, bool _status) public onlyOwner {
        strategyManagers[_manager] = _status;
    }

    function setSetupStrategyPermission(address[] memory _managers, bool _status) public onlyOwner {
        for (uint i = 0; i < _managers.length; i++) {
            strategyManagers[_managers[i]] = _status;
        }
    }

    function setAffProgram(address _aff) public onlyOwner {
        aff = IAffiliateProgram(_aff);
    }

    function upgrade(address _upgradedAddress) public onlyOwner {
        require(_upgradedAddress != address(0), "Address must not be zero");
        upgradedAddress = IDfFinanceClose(_upgradedAddress);
    }

    // ** INTERNAL VIEW functions **

    function _getProfitEth(
        address _dfWallet, uint256 _ethLocked, uint256 _ethForRedeem
    ) internal view returns(uint256 profitEth) {
        uint deposit = strategies[_dfWallet].deposit;  // in eth
        uint fee = strategies[_dfWallet].fee; // in percent (from 0 to 100)
        uint profitPercent = strategies[_dfWallet].profitPercent; // in percent (from 0 to 255)

        // user additional profit in eth
        profitEth = sub(sub(_ethLocked, deposit), _ethForRedeem) * sub(100, fee) / 100;

        require(wdiv(profitEth, deposit) * 100 >= profitPercent * WAD, "Needs more profit in eth");
    }

    function _getUsdToWithdraw(
        address _dfWallet, uint256 _ethLocked, uint256 _ethForRedeem, uint256 _usdPrice
    ) internal view returns(uint256 usdProfit, uint256 usdToWithdraw) {
        uint deposit = strategies[_dfWallet].deposit;  // in eth
        uint fee = strategies[_dfWallet].fee; // in percent (from 0 to 100)
        uint profitPercent = strategies[_dfWallet].profitPercent; // in percent (from 0 to 255)
        uint ethPrice = strategies[_dfWallet].entryEthPrice;

        // user additional profit in eth
        uint profitEth = sub(sub(_ethLocked, deposit), _ethForRedeem) * sub(100, fee) / 100;

        usdToWithdraw = wdiv(add(deposit, profitEth), _usdPrice * 1e12) / 1e12;

        uint usdOriginal = wmul(deposit, ethPrice) / 1e12;
        require(usdOriginal > 0, "Incorrect entry usd amount");

        usdProfit = sub(usdToWithdraw, usdOriginal);

        require(wdiv(usdProfit, usdOriginal) * 100 >= profitPercent * WAD, "Needs more profit in usd");
    }

    function _takeFeeHelper(
        Strategy memory _strategy,
        uint256 _ethToWithdraw,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd
    ) internal view returns(
        uint256 ethToWithdraw, bool hasProfit, uint256 extraProfitEth
    ) {
        ethToWithdraw = _ethToWithdraw;

        // is profitable
        // ethToWithdraw = ethLocked - ethForReedem
        if (ethToWithdraw > _strategy.deposit) {
            extraProfitEth = sub(ethToWithdraw, _strategy.deposit);

            if (_minAmountUsd > 0) {
                if (_onlyProfitInUsd) {
                    // VIA deposit in ETH and profit in USD
                    hasProfit = (_minAmountUsd * 1e12 * 10000 / wmul(_strategy.deposit, _strategy.entryEthPrice)) >= uint(_strategy.profitPercent) * 100;
                } else {
                    // VIA USD
                    hasProfit = (_minAmountUsd * 1e12 * 10000 / wmul(_strategy.deposit, _strategy.entryEthPrice)) >= (100 + uint(_strategy.profitPercent)) * 100;
                }
            } else {
                // VIA ETH
                hasProfit = ((extraProfitEth * sub(100, _strategy.fee) / 100) * 10000 / _strategy.deposit) >= uint(_strategy.profitPercent) * 100;
            }
        }

        if (hasProfit) {
            uint ethAfterFee = add(_strategy.deposit, extraProfitEth * sub(100, _strategy.fee) / 100);
            require(ethToWithdraw >= ethAfterFee, "ethRest less then ethAfterFee");

            ethToWithdraw = ethAfterFee;
        } else {
            // if not profitable strategy - addition fee
            if (now < dateUntilFees) {
                ethToWithdraw = sub(ethToWithdraw, mul(ethToWithdraw, earlyCloseFee) / 100);
            }
        }
    }

    // ** INTERNAL functions **

    function _setupStrategy(
        address _owner,
        address _dfWallet,
        uint256 _deposit,
        uint256 _priceEth,
        uint8 _profitPercent,
        uint8 _fee,
        uint256 _extraCoef
    ) internal {
        require(strategies[_dfWallet].deposit == 0, "Strategy already set");

        uint extraCoef = _extraCoef;
        if (extraCoef == 0) {
            uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
            extraCoef = ethLocked / _deposit;
        }

        strategies[_dfWallet] = Strategy(
            uint80(_deposit),
            uint80(_priceEth),
            _profitPercent,
            _fee,
            0,
            0,
            false,
            _owner,
            uint16(extraCoef)
        );

        emit SetupStrategy(_owner, _dfWallet, _deposit, _priceEth, _profitPercent, _fee);
    }

    function _collectUsdHelper(
        address _dfWallet,
        uint256 _amountUsdToBuy,
        uint256 _usdPrice,
        bool _onlyProfitInUsd
    ) internal returns(
        uint256 ethAfterClose
    ) {
        Strategy storage strategy = strategies[_dfWallet];
        require(strategy.ethForRedeem == 0 && strategy.deposit > 0, "Strategy is not exists or valid");

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        uint ethForRedeem = wmul(ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet), _usdPrice, 1e6) * 1e12;

        uint usdToWithdraw = 0;
        uint ethToWithdraw = 0;

        if (_amountUsdToBuy > 0) { // in USD
            uint usdProfit;
            (usdProfit, usdToWithdraw) = _getUsdToWithdraw(_dfWallet, ethLocked, ethForRedeem, _usdPrice);

            // return value
            ethAfterClose = ethLocked;

            // deposit in ETH and profit in USD
            if (_onlyProfitInUsd) {
                strategy.onlyProfitInUsd = _onlyProfitInUsd;  // set strategy value

                ethToWithdraw = strategy.deposit;
                usdToWithdraw = usdProfit;

                // return value
                ethAfterClose = sub(ethLocked, ethToWithdraw);
            }

            strategy.usdToWithdraw = uint64(usdToWithdraw);  // set strategy value
        } else { // in ETH
            uint profitEth = _getProfitEth(_dfWallet, ethLocked, ethForRedeem);
            ethToWithdraw = add(strategy.deposit, profitEth);

            // return value
            ethAfterClose = ethForRedeem;
        }

        strategy.ethForRedeem = uint80(ethForRedeem);  // set strategy value

        emit StrategyClosing(_dfWallet, ethToWithdraw, usdToWithdraw);
    }

    function _strategyCloseHelper(address _dfWallet) internal {
        Strategy memory strategy = strategies[_dfWallet];

        uint ethLocked = ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet);
        // uint ethForRedeem = wmul(ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet), _usdPrice, 1e6) * 1e12;

        // TODO: check usdc balance and ceth transfer to dfWallet
        IToken(USDC_ADDRESS).approve(_dfWallet, uint(-1));
        IDfWallet(_dfWallet).withdraw(ETH_ADDRESS, CETH_ADDRESS, USDC_ADDRESS, CUSDC_ADDRESS);

        // Calculate affiliate process partner profit
        uint systemProfit = sub(sub(ethLocked, strategy.deposit), strategy.ethForRedeem) * strategy.fee / 100;
        uint partnerProfit = _affiliateProcess(strategy.owner, systemProfit);

        uint usdToWithdraw = strategy.usdToWithdraw;
        uint ethToWithdraw = 0;

        if (usdToWithdraw > 0) {
            // transfer USDC to user
            IToken(USDC_ADDRESS).universalTransfer(strategy.owner, usdToWithdraw);

            // close: deposit in ETH + profit in usd
            if (strategy.onlyProfitInUsd) {
                ethToWithdraw = strategy.deposit;
            }
        } else {  // close in ETH
            uint profitEth = _getProfitEth(_dfWallet, ethLocked, strategy.ethForRedeem);
            ethToWithdraw = add(strategy.deposit, profitEth);
        }

        // transfer ETH to user
        if (ethToWithdraw > 0) {
            IToken(ETH_ADDRESS).universalTransfer(strategy.owner, ethToWithdraw);
        }

        // transfer loan and our profit to loanPool
        uint loanAndProfit = sub(sub(ethLocked, ethToWithdraw), partnerProfit);
        _transferEth(address(loanPool), loanAndProfit);

        // call strategy owner's callback function (without revert if callback does not exist)
        _callbackTo(strategy.owner);

        // clear _dfWallet strategy struct
        _clearStrategy(_dfWallet);

        emit StrategyClosed(_dfWallet, ethToWithdraw, usdToWithdraw);
    }

    function _collectAndCloseHelper(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes memory _exData,
        bool _withFee
    ) internal returns(bool hasProfit, uint256 extraProfitEth) {
        Strategy memory strategy = strategies[_dfWallet];
        require(strategy.deposit > 0 && strategy.ethForRedeem == 0, "Strategy is not exists or valid for close");

        // ethToWithdraw = ethLocked - _ethForRedeem
        uint ethToWithdraw = sub(ICToken(CETH_ADDRESS).balanceOfUnderlying(_dfWallet), _ethForRedeem);

        // with fee logic
        if (_withFee) {
            (ethToWithdraw, hasProfit, extraProfitEth) = _takeFeeHelper(strategy, ethToWithdraw, _minAmountUsd, _onlyProfitInUsd);
        }

        uint ethForExchange = _ethForRedeem;

        // if close not in eth
        if (_minAmountUsd > 0) {
            // VIA USD
            ethForExchange = add(ethForExchange, ethToWithdraw);

            if (_onlyProfitInUsd) {
                // VIA deposit in ETH and profit in USD
                ethForExchange = sub(ethForExchange, strategy.deposit);
            }
        }

        // calculate and take an extra eth loan from LoanPool
        uint loan = 0;
        if (msg.value < ethForExchange) {
            loan = sub(ethForExchange, msg.value);
            loanPool.loan(loan);
        }

        /**
            exResult[2] - extra ToTokens after exchange 每 USDC
            exResult[3] - extra FromTokens after exchange 每 ETH
         */
        uint[4] memory exResult = _exchangeAndRedeemHelper(_dfWallet, ethForExchange, _minAmountUsd, _exData);

        // affiliate pay to referrer
        uint systemProfit = 0;
        if (hasProfit) {
            uint fee = mul(extraProfitEth, strategy.fee) / 100;
            systemProfit = sub(fee, _affiliateProcess(strategy.owner, fee));
        }

        // return loan and system profit to LoanPool
        if (add(loan, systemProfit) > 0) {
            _transferEth(address(loanPool), add(loan, systemProfit));
        }

        if (_minAmountUsd > 0) {
            if (_onlyProfitInUsd) {
                // VIA deposit in ETH and profit in USD
                ethToWithdraw = strategy.deposit;
            } else {
                // VIA USD
                ethToWithdraw = 0;
            }
        }

        /**
            exResult[2] - extra ToTokens after exchange 每 USDC
            exResult[3] - extra FromTokens after exchange 每 ETH
         */
        _withdrawProfit(
            strategy.owner,
            (ethToWithdraw + exResult[3]),
            (_minAmountUsd + exResult[2])
        );

        // call strategy owner's callback function (without revert if callback does not exist)
        _callbackTo(strategy.owner);

        // clear _dfWallet strategy struct
        _clearStrategy(_dfWallet);

        // return msg.value to msg.sender
        if (msg.value > 0) {
            address(msg.sender).transfer(msg.value);
        }

        // emit StrategyClosed(_dfWallet, ethToWithdraw, _minAmountUsd);

        // with extra eth and usdc after exchange profit
        emit StrategyClosed(_dfWallet, (ethToWithdraw + exResult[3]), (_minAmountUsd + exResult[2]));
    }

    function _exchangeAndRedeemHelper(
        address _dfWallet,
        uint256 _ethForExchange,
        uint256 _minAmountUsd,
        bytes memory _exData
    ) internal returns(
        uint[4] memory exResult
        /**
            [0] - received ToTokens
            [1] - spent FromTokens
            [2] - extra ToTokens after exchange
            [3] - extra FromTokens after exchange
         */
    ) {
        //  ETH => USDC - 1inch exchange
        uint usdcForRedeem = ICToken(CUSDC_ADDRESS).borrowBalanceStored(_dfWallet);

        exResult = _exchange(
            IToken(ETH_ADDRESS), _ethForExchange,
            IToken(USDC_ADDRESS), add(usdcForRedeem, _minAmountUsd),
            _exData
        );

        // redeem usdc and unlock eth
        IToken(USDC_ADDRESS).approve(_dfWallet, uint(-1));
        IDfWallet(_dfWallet).withdraw(ETH_ADDRESS, CETH_ADDRESS, USDC_ADDRESS, CUSDC_ADDRESS);
    }

    function _withdrawProfit(
        address _strategyOwner, uint256 _ethToWithdraw, uint256 _usdToWithdraw
    ) internal {
        // withdraw ETH to strategy owner
        if (_ethToWithdraw > 0) {
            IToken(ETH_ADDRESS).universalTransfer(_strategyOwner, _ethToWithdraw);
        }

        // withdraw USDC to strategy owner
        if (_usdToWithdraw > 0) {
            IToken(USDC_ADDRESS).universalTransfer(_strategyOwner, _usdToWithdraw);
        }
    }

    function _transferEth(address receiver, uint256 amount) internal {
        address payable receiverPayable = address(uint160(receiver));
        (bool result, ) = receiverPayable.call.value(amount)("");
        require(result, "Transfer of ETH failed");
    }

    function _exchange(
        IToken _fromToken, uint256 _maxFromTokenAmount,
        IToken _toToken, uint256 _minToTokenAmount,
        bytes memory _exData
    ) internal returns(
        uint[4] memory res
        /**
            [0] - received ToTokens
            [1] - spent FromTokens
            [2] - extra ToTokens after exchange
            [3] - extra FromTokens after exchange
         */
    ) {
        IOneInchExchange ex = IOneInchExchange(0x11111254369792b2Ca5d084aB5eEA397cA8fa48B);

        // Approve tokens for 1inch
        uint256 ethAmount = 0;
        if (address(_fromToken) != ETH_ADDRESS) {
            if (_fromToken.allowance(address(this), ex.spender()) != uint(-1)) {
                _fromToken.approve(ex.spender(), uint(-1));
            }
        } else {
            ethAmount = _maxFromTokenAmount;
        }

        uint fromTokenBalanceBefore = _fromToken.universalBalanceOf(address(this));
        uint toTokenBalanceBefore = _toToken.universalBalanceOf(address(this));

        bytes32 response;
        assembly {
            // call(g, a, v, in, insize, out, outsize)
            let succeeded := call(sub(gas, 5000), ex, ethAmount, add(_exData, 0x20), mload(_exData), 0, 32)
            response := mload(0)      // load delegatecall output
            //switch iszero(succeeded)
            //case 1 {
            //    // throw if call failed
            //    revert(0, 0)
            //}
        }

        res[0] = sub(_toToken.universalBalanceOf(address(this)), toTokenBalanceBefore);         //  received ToTokens
        res[1] = sub(fromTokenBalanceBefore, _fromToken.universalBalanceOf(address(this)));     // spent FromTokens
        res[2] = sub(res[0], _minToTokenAmount);    //  extra ToTokens
        res[3] = sub(_maxFromTokenAmount, res[1]);  // extra FromTokens
    }

    function _clearStrategy(address _dfWallet) internal {
        strategies[_dfWallet] = Strategy(0, 0, 0, 0, 0, 0, false, address(0), 0);
    }

    function _affiliateProcess(address _strategyOwner, uint256 _systemProfit) internal returns(uint256 affPayment) {
        if (aff != IAffiliateProgram(0)) {
            affPayment = _systemProfit * aff.getProfitPercentByReferral(_strategyOwner) / 100;
            require(affPayment < _systemProfit, "Incorrect affiliate program payment percent");

            // tranfer eth to AffiliateProgram contract
            aff.distributeProfitByReferral.value(affPayment)(_strategyOwner);

            emit SystemProfit(sub(_systemProfit, affPayment));
        } else {
            emit SystemProfit(_systemProfit);
        }
    }

    function _distributeExtraExchangeProfit(
        address[] memory _dfWallets,
        uint256 _extraEth,
        uint256 _extraUsd
    ) internal {

        // deposits of strategies
        uint[] memory deposits = new uint[](_dfWallets.length);

        uint totalDeposit = 0;  //  total deposit of these strategies

        // deposits of strategies and totalDeposit calculate
        for (uint i = 0; i < _dfWallets.length; i++) {
            deposits[i] = strategies[_dfWallets[i]].deposit;
            totalDeposit += deposits[i];
        }

        // add extra ETH and USDC to strategies profit
        for (uint i = 0; i < _dfWallets.length; i++) {
            uint strategyShare = wdiv(deposits[i], totalDeposit);

            if (_extraEth > 0) {
                uint ethForStrategy = wmul(strategyShare, _extraEth);
                if (strategies[_dfWallets[i]].ethForRedeem > ethForStrategy) {
                    strategies[_dfWallets[i]].ethForRedeem -= uint80(ethForStrategy);
                }
            }

            if (_extraUsd > 0) {
                uint usdForStrategy = wmul(strategyShare, _extraUsd);
                strategies[_dfWallets[i]].usdToWithdraw += uint64(usdForStrategy);
            }
        }
    }

    function _callbackTo(address _to) internal {
        bytes4 sig = bytes4(keccak256("__callback()"));

        // call without revert if function does not exist
        assembly {
            let x := mload(0x40)
            mstore(x, sig)
            let success := call(sub(gas, 5000), _to, 0, x, 0x04, 0, 0)
        }
    }

    // ** FALLBACK functions **
    function() external payable {}

}
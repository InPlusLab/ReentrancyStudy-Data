/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

// File: localhost/interfaces/IAffiliateProgram.sol

pragma solidity ^0.5.16;

interface IAffiliateProgram {
    function addUserUseCode(address user, string calldata code) external;
    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);
    function levels(uint8 level) external view returns (uint16, uint256);
    function addPartnerProfitUseAddress(address partner) external payable;
}
// File: localhost/interfaces/ILoanPool.sol

pragma solidity ^0.5.16;


interface ILoanPool {
    function loan(uint _amount) external;
}
// File: localhost/interfaces/IPep.sol

pragma solidity ^0.5.16;

interface IPep {
    function peek() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
}
// File: localhost/interfaces/ITub.sol


pragma solidity ^0.5.16;



interface ITub {
    function open() external returns (bytes32);
    function join(uint) external;
    function exit(uint) external;
    function lock(bytes32, uint) external;
    function free(bytes32, uint) external;
    function draw(bytes32, uint) external;
    function wipe(bytes32, uint) external;
    function give(bytes32, address) external;
    function shut(bytes32) external;
    function cups(bytes32) external view returns (address, uint, uint, uint);
    function gem() external view returns (IToken);
    function gov() external view returns (IToken);
    function skr() external view returns (IToken);
    function sai() external view returns (IToken);
    function mat() external view returns (uint);
    function ink(bytes32) external view returns (uint);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function per() external view returns (uint);
    function pep() external view returns (IPep);
    function pip() external view returns (IPep);
    function ask(uint wad) external view returns (uint);
}
// File: localhost/interfaces/IOneInchExchange.sol

pragma solidity ^0.5.16;

interface IOneInchExchange {
    function spender() external view returns (address);
}
// File: localhost/interfaces/IDfFinanceMgr.sol

pragma solidity ^0.5.16;

interface IDfFinanceMgr {
    function setupCup(address cdpOwner, bytes32 cup, uint256 deposit, uint8 profitPercent, uint256 etherPrice, uint8 feeForBonusEther) external;
}
// File: localhost/utils/DSMath.sol

pragma solidity ^0.5.0;

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
// File: localhost/interfaces/IToken.sol

pragma solidity ^0.5.16;

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
// File: localhost/utils/Address.sol

pragma solidity ^0.5.5;

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

// File: localhost/utils/SafeERC20.sol

pragma solidity ^0.5.16;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";



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
// File: localhost/utils/SafeMath.sol

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

// File: localhost/utils/UniversalERC20.sol

pragma solidity ^0.5.16;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";




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
// File: localhost/nonupgradable/Ownable.sol

pragma solidity ^0.5.16;

contract Ownable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate);
        owner = newOwnerCandidate;
    }
}
// File: localhost/nonupgradable/FundsMgr.sol

pragma solidity ^0.5.16;



contract FundsMgr is Ownable {
    using UniversalERC20 for IToken;

    function withdraw(address token, uint256 amount) onlyOwner public  {
        require(msg.sender == owner);

        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            IToken(token).universalTransfer(owner, amount);
        }
    }
    function withdrawAll(address[] memory tokens) onlyOwner public  {
        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
        }
    }
}
// File: localhost/DfFinanceMgr.sol

pragma solidity ^0.5.16;




// **INTERFACES**







contract DfFinanceMgr is FundsMgr, DSMath  {
    using UniversalERC20 for IToken;

    struct CupInfo {
        uint256 deposit;
        uint256 etherPrice;

        uint8 profitPercent; // in ether
        uint8 feeForBonusEther;

        uint256 etherForRepayLoan;
        uint256 usdToWithdraw;
    }


    IAffiliateProgram public aff;

    // Fees
    uint256 public earlyCloseFee;
    uint256 public dateUntilFees;

    mapping(address => bool) public admins;
    mapping(address => bool) public cupManagers;

    IDfFinanceMgr public migrateToNewContract;

    IToken public usdToken;

    ILoanPool public loanPool;

    mapping(bytes32 => bool) public ownedCups;

    mapping(address => mapping(bytes32 => CupInfo)) internal cups;
    uint256 internal minMKRPrice;


    IToken internal constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    ITub internal constant tub = ITub(0x448a5065aeBB8E423F0896E6c5D525C040f59af3);


    // **EVENTS**
    event StrategyClosing(bytes32 cup, uint256 profit, address token);
    event StrategyClosed(bytes32 cup, uint256 profit, address token);
    event SetupCup(address, bytes32, uint256, uint8, uint256, uint8);

    event SystemProfit(uint256 profit);


    // **MODIFIERS**
    modifier hasSetupCupPermission {
        require(cupManagers[msg.sender], "Setup cup permission denied");
        _;
    }


    constructor() public {
        usdToken = IToken(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
        minMKRPrice = 500 * 10**18;

        if (tub.sai().allowance(address(this), address(tub)) != uint256(-1)) { // OPTIMIZE
            tub.sai().approve(address(tub), uint256(-1));
        }
        if (tub.gov().allowance(address(this), address(tub)) != uint256(-1)) { // OPTIMIZE
            tub.gov().approve(address(tub), uint256(-1));
        }

        if (tub.skr().allowance(address(this), address(tub)) != uint256(-1)) { // OPTIMIZE
            tub.skr().approve(address(tub), uint256(-1));
        }

        loanPool = ILoanPool(0x9EdAe6aAb4B0f0f8146051ab353593209982d6B6);

        // added cupManagers: prev DfFinanceMgr contracts and DfFinanceMgrOpenCdp
        cupManagers[0xD757EBb746167495716Ef3f11942c429203DBB75] = true;
        cupManagers[0x0E679aC20BE465766e3ae681cE828a37642A83d5] = true;
        cupManagers[0x061956a73F00B1392213dBEdfA61bE6eA63Da2FC] = true;
        cupManagers[0x735ba150d6A842B1feE3737F023fDdF781CfEaA0] = true;
        cupManagers[0xF57960f6b5363b9f4091eAB7d0cF1CdA35CCAF70] = true;
    }


    // **PUBLIC VIEW functions**
    function calcEthFromAmountAndPrice(uint256 amountUsdToBuy, uint256 usdPrice) public view returns (uint256) {
        return wmul(amountUsdToBuy, usdPrice, 10**usdToken.decimals()) * WAD / 10**usdToken.decimals();
    }

    function priceETH() public view returns(uint256) {
        return uint256(IPep(ITub(tub).pip()).read());
    }

    function getMKRPrice() public view returns(uint256) {
        return minMKRPrice;
    }

    function getCupInfo(address cdpOwner, bytes32 cup) public view returns(
        uint256 deposit,
        uint8 profitPercent,
        uint256 etherPrice,
        uint8 feeForBonusEther,
        uint256 etherForRepayLoan,
        uint256 usdToWithdraw)
    {
        deposit = cups[cdpOwner][cup].deposit;
        profitPercent = cups[cdpOwner][cup].profitPercent;
        etherPrice = cups[cdpOwner][cup].etherPrice;
        feeForBonusEther = cups[cdpOwner][cup].feeForBonusEther;
        etherForRepayLoan = cups[cdpOwner][cup].etherForRepayLoan;
        usdToWithdraw = cups[cdpOwner][cup].usdToWithdraw;
    }

    function caluclateAmountSaiFromEth(uint256 wad, uint256 rate) public view returns(uint256) {
        uint256 price = priceETH();
        return wmul(wmul(wdiv(wad, tub.ask(wad)), wad), price) * 100 / rate;
    }

    function totalDeb(bytes32 cup) public view returns(uint256) {
        return rmul(tub.ink(cup), tub.per());
    }


    // **PUBLIC functions**
    function collectSaiAndUsdForOpenDeals(address[] memory userAddresses, bytes32[] memory cupsList, uint256 amountSaiToBuy, uint256 saiPrice, uint256 amountUsdToBuy, uint256 usdPrice, bytes memory _saiData, bytes memory _usdData, uint8 useExternalExchange) public {
        uint16 len = uint16(userAddresses.length);
        require(len == cupsList.length);
        require(admins[msg.sender] || msg.sender == owner);

        uint256 totalCredit = wmul(amountSaiToBuy, saiPrice) + calcEthFromAmountAndPrice(amountUsdToBuy, usdPrice);

        if (useExternalExchange == 0)
        {
            // take an totalCredit eth loan
            loanPool.loan(totalCredit);

            exchange(ETH_ADDRESS, wmul(amountSaiToBuy, saiPrice), tub.sai(), amountSaiToBuy, _saiData);
            if (amountUsdToBuy > 0) exchange(ETH_ADDRESS, calcEthFromAmountAndPrice(amountUsdToBuy, usdPrice), usdToken, amountUsdToBuy, _usdData);
        }

        for(uint16 i = 0; i < len;i++) {
            bytes32 cupId = cupsList[i];
            CupInfo storage cup = cups[userAddresses[i]][cupId];
            require(cup.etherForRepayLoan == 0 && cup.deposit > 0);

            uint256 jam = totalDeb(cupId);

            uint256 etherForRepayLoan = calcCreditInEther(cupId, saiPrice);


            // check has profit
            if (amountUsdToBuy > 0) { // in USD
                uint256 usdToWithdraw = calcUsdToWithdraw(cup, jam, usdPrice, etherForRepayLoan);
                totalCredit = totalCredit < jam ? 0 : totalCredit - jam;
                emit StrategyClosing(cupId, usdToWithdraw, address(usdToken));
                cup.usdToWithdraw = usdToWithdraw;
            } else { //in ETH
                // uint256 profitETH = sub(sub(jam, cup.deposit), etherForRepayLoan)  * (100 - cup.feeForBonusEther) / 100;
                // require((profitETH * 10000 / cup.deposit) > cup.profitPercent * 100);
                emit StrategyClosing(cupId, cup.deposit + calcProfitETH(cup, jam, etherForRepayLoan), address(0x0));
                totalCredit = totalCredit < etherForRepayLoan ? 0 : totalCredit - etherForRepayLoan;
            }

            cup.etherForRepayLoan = etherForRepayLoan;
        }

        require(totalCredit == 0);
    }

    // test!
    function exitAfterLiquidation(address userAddress, bytes32 cup) public {
        CupInfo memory cupInfo = cups[userAddress][cup];

        require(cupInfo.deposit > 0);

        uint256 jam = totalDeb(cup);

        uint256 wad = tub.tab(cup);

        require(wad == 0 && jam < cupInfo.deposit);

        uint ink = rdiv(jam, tub.per());
        ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;

        tub.free(cup, ink);

        tub.exit(ink);

        tub.shut(cup);

        tub.gem().withdraw(jam);

        address(uint160(address(userAddress))).transfer(jam);
    }

    function closeStrategies(address[] memory userAddresses, bytes32[] memory cupsList) public {
        uint16 len = uint16(userAddresses.length);
        require(len == cupsList.length);
        for(uint16 i = 0; i < len;i++) closeStrategy(userAddresses[i], cupsList[i]);
    }

    function closeStrategy(address userAddress, bytes32 cup) public {
        CupInfo memory cupInfo = cups[userAddress][cup];

        require(cupInfo.deposit > 0 && cupInfo.etherForRepayLoan > 0);

        uint256 jam = totalDeb(cup);

        uint256 wad = tub.tab(cup);

        tub.wipe(cup, wad); // repay sai & mkr

        uint ink = rdiv(jam, tub.per());
        ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;

        tub.free(cup, ink);

        tub.exit(ink);

        tub.shut(cup);

        require(jam > cupInfo.etherForRepayLoan);

        tub.gem().withdraw(jam);

        uint256 systemProfit = sub(sub(jam, cupInfo.deposit), cupInfo.etherForRepayLoan)  * (cupInfo.feeForBonusEther) / 100;

        jam = sub(jam, affiliateProcess(userAddress, systemProfit));

        if (cupInfo.usdToWithdraw > 0) {
            transferEthInternal(address(loanPool), jam);

            usdToken.universalTransfer(userAddress, cupInfo.usdToWithdraw);
            emit StrategyClosed(cup, cupInfo.usdToWithdraw, address(usdToken));
        } else {
            transferEthInternal(address(loanPool), cupInfo.etherForRepayLoan);

            uint256 profitETH = calcProfitETH(cupInfo, jam, cupInfo.etherForRepayLoan);
            address(uint160(address(userAddress))).transfer(add(cupInfo.deposit, profitETH));
            emit StrategyClosed(cup, cupInfo.deposit + profitETH, address(0x0));
        }
    }

    function migrate(bytes32[] memory cups_to_migrate) public {
        require(migrateToNewContract != IDfFinanceMgr(0x0));

        for(uint256 i = 0; i < cups_to_migrate.length; i++) {
            CupInfo memory info = cups[msg.sender][cups_to_migrate[i]];
            require(info.deposit > 0 && info.etherForRepayLoan == 0);

            migrateToNewContract.setupCup(msg.sender, cups_to_migrate[i], info.deposit, info.profitPercent, info.etherPrice, info.feeForBonusEther);

            tub.give(cups_to_migrate[i], address(migrateToNewContract));

            cups[msg.sender][cups_to_migrate[i]] = CupInfo(0,0,0,0,0,0);
            ownedCups[cups_to_migrate[i]] = false;
        }
    }

    function calc(bytes32 cup) public returns(uint256 saiGovAmt, uint256 govAmt, uint256 wad) {
        wad = tub.tab(cup);
        // uint256 fee = feeSai(wad, cup);
        // bytes32 val;
        // bool ok;
        // (val, ok) = tub.pep().peek();
        // if (ok && val != 0) {
        //     govAmt = wdiv(fee, uint256(val));
        //     if (uint256(val) < minMKRPrice)
        //     {
        //         saiGovAmt = wmul(govAmt, minMKRPrice); // we can change market price too high ?
        //     } else {
        //         saiGovAmt = fee; // market price ?
        //     }
        // } else {
        //     assert(false);
        // }
    }

    function setupCup(address cdpOwner, bytes32 cup, uint256 deposit, uint8 profitPercent, uint256 etherPrice, uint8 feeForBonusEther) public hasSetupCupPermission {
        require(cups[cdpOwner][cup].deposit == 0);
        require(!ownedCups[cup]);

        cups[cdpOwner][cup] = CupInfo(deposit, etherPrice, profitPercent, feeForBonusEther, 0, 0);
        ownedCups[cup] = true;

        emit SetupCup(cdpOwner, cup, deposit, profitPercent, etherPrice, feeForBonusEther);
    }


    // **PUBLIC PAYABLE functions**
    function lockEther(bytes32 cup) public payable {
        require(cups[msg.sender][cup].deposit > 0);
        // §à§Ò§ß§à§Ó§Ý§ñ§ä§î §ã§ä§â§å§Ü§ä§å§â§å (§ã§Ü§à§Ý§î§Ü§à §Ù§Ñ§Õ§Ö§á§à§Ù§Ú§é§Ö§ß§à)

        cups[msg.sender][cup].deposit += msg.value;
        // correct ether price ?

        tub.gem().deposit.value(msg.value)();

        uint ink = rdiv(msg.value, tub.per());
        ink = rmul(ink, tub.per()) <= msg.value ? ink : ink - 1;

        if (tub.gem().allowance(address(this), address(tub)) != uint(-1)) {
            tub.gem().approve(address(tub), uint(-1));
        }
        tub.join(ink);

        if (tub.skr().allowance(address(this), address(tub)) != uint(-1)) {
            tub.skr().approve(address(tub), uint(-1));
        }
        tub.lock(cup, ink);
    }

    function wipeAndCloseProfitOnly(bytes32 cup, address payable cdpOwner, uint256 etherNeeded, bytes memory _saiData, bytes memory _usdData, uint256 minAmountAllowed) public payable returns(uint256 extraProfitInEther) {
        require(admins[msg.sender]);

        bool hasProfit;
        (hasProfit, extraProfitInEther) = wipeAndClose(cup, cdpOwner, etherNeeded, _saiData, _usdData, minAmountAllowed);

        require(hasProfit); // can close only if user has profit
    }

    function userWipeAndClose(bytes32 cup,uint256 etherNeeded, bytes memory _saiData, bytes memory _usdData, uint256 minAmountAllowed) public payable {
        // require(tx.origin == msg.sender);

        CupInfo memory info = cups[msg.sender][cup];
        require(info.deposit > 0 && info.etherForRepayLoan == 0);

        wipeAndClose(cup, msg.sender, etherNeeded, _saiData, _usdData, minAmountAllowed);
    }


    // **ONLY_OWNER functions**
    function setAffProgram(address newAff) public onlyOwner {
        aff = IAffiliateProgram(newAff);
    }

    function changeUsdToken(IToken newToken) public onlyOwner {
        usdToken = newToken;
    }

    function setAdmin(address newAdmin, bool active) public onlyOwner {
        admins[newAdmin] = active;
    }

    function changeMinMkrPrice(uint256 _minPrice) public onlyOwner {
        minMKRPrice = _minPrice;
    }

    function updateContract(address newContract) public onlyOwner {
        migrateToNewContract = IDfFinanceMgr(newContract);
    }

    function changeFees(uint256 _earlyCloseFee) public onlyOwner {
        earlyCloseFee = _earlyCloseFee;
    }

    function changeStrategicDate(uint256 newDate) public onlyOwner {
        dateUntilFees = newDate;
    }

    function setLoanPool(address loanAddr) public onlyOwner {
        require(loanAddr != address(0), "Address must not be zero");
        loanPool = ILoanPool(loanAddr);
    }

    function setSetupCupPermission(address manager, bool status) public onlyOwner {
        cupManagers[manager] = status;
    }

    function setSetupCupPermission(address[] memory managers, bool status) public onlyOwner {
        for (uint i = 0; i < managers.length; i++) {
            cupManagers[managers[i]] = status;
        }
    }


    // **INTERNAL functions**
    // TODO: wmul
    function ethMulUsdPrice(uint256 ethamount, uint256 usdPrice, uint256 decimals) internal pure returns(uint256) {
        return wdiv(ethamount, usdPrice * 10**(18 - decimals)) / 10**(18 - decimals);
    }

    function calcProfitETH(CupInfo memory cup, uint256 jam, uint256 etherForRepayLoan) internal pure returns(uint256 profitETH) {
        profitETH = sub(sub(jam, cup.deposit), etherForRepayLoan)  * (100 - cup.feeForBonusEther) / 100;
        require((profitETH * 10000 / cup.deposit) >= uint256(cup.profitPercent) * 100);
    }

    function calcUsdToWithdraw(CupInfo memory cup, uint256 jam, uint256 usdPrice, uint256 etherForRepayLoan ) internal view returns(uint256) {
        uint256 profit = sub(sub(jam, cup.deposit), etherForRepayLoan);
        profit = profit * sub(100, cup.feeForBonusEther) / 100;

        uint256 usdToWithdraw = ethMulUsdPrice(cup.deposit + profit, usdPrice, usdToken.decimals());
        uint256 originalUSDAmount = wmul(cup.deposit, cup.etherPrice) / 10 ** (18 - usdToken.decimals()); // convert to usdToken precision
        require(originalUSDAmount > 0);

        require((sub(usdToWithdraw, originalUSDAmount) * 10000 / originalUSDAmount) >= uint256(cup.profitPercent) * 100);

        return usdToWithdraw;
    }

    function calcCreditInEther(bytes32 cupId, uint256 saiPrice) internal returns (uint256) {
        uint256 saiGovAmt;
        uint256 wad;

        (saiGovAmt, ,wad) = calc(cupId);

        return wmul(wad + saiGovAmt, saiPrice);
    }

    function feeSai(uint256 wad, bytes32 cup) internal returns(uint256) {
        return rmul(wad, rdiv(tub.rap(cup), tub.tab(cup)));
    }

    function exchange(IToken fromToken, uint256 maxFromTokenAmount, IToken toToken, uint256 minToTokenAmount, bytes memory _data) internal {
        IOneInchExchange ex = IOneInchExchange(0x11111254369792b2Ca5d084aB5eEA397cA8fa48B);

        uint256 etherAmount;
        if (fromToken != ETH_ADDRESS) {
            if (fromToken.allowance(address(this), ex.spender()) != uint(-1)) {
                fromToken.approve(ex.spender(), uint(-1));
            }
            etherAmount = 0;
        } else {
            etherAmount = maxFromTokenAmount;
        }
        uint256 fromTokenBalance = fromToken.universalBalanceOf(address(this));
        uint256 toTokenBalance = toToken.universalBalanceOf(address(this));

        bytes32 response;
        assembly {
        // call(g, a, v, in, insize, out, outsize)
            let succeeded := call(sub(gas, 5000), ex, etherAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
        //switch iszero(succeeded)
        //case 1 {
        //    // throw if call failed
        //    revert(0, 0)
        //}
        }

        require(fromToken.universalBalanceOf(address(this)) + maxFromTokenAmount >= fromTokenBalance);
        require(toToken.universalBalanceOf(address(this)) >= toTokenBalance + minToTokenAmount);
    }

    function affiliateProcess(address cdpOwner, uint256 systemProfit) internal returns(uint256 affiliatePayment) {
        if (aff != IAffiliateProgram(0x0)) {
            (address partner, uint8 level,,) = aff.getPartnerFromUser(cdpOwner);
            (uint16 percent,) = aff.levels(level);
            require(percent < 100);
            affiliatePayment = systemProfit * percent / 100;
            aff.addPartnerProfitUseAddress.value(affiliatePayment)(partner);
            emit SystemProfit(systemProfit * (100 - percent) / 100);
        } else {
            emit SystemProfit(systemProfit);
        }
    }

    function wipeAndClose(bytes32 cup, address payable cdpOwner, uint256 etherNeeded, bytes memory _saiData, bytes memory _usdData, uint256 minAmountAllowed) internal returns(bool hasProfit, uint256 extraProfitInEther) {
        CupInfo memory info = cups[cdpOwner][cup];
        require(info.deposit > 0);

        hasProfit = false;

        uint256 jam = totalDeb(cup);

        // §±§à§ã§Ý§Ö §Ó§í§é§Ö§ä§Ñ §Ü§â§Ö§Õ§Ú§ä§Ñ
        jam = wipeAndCloseInternal(cup, jam, etherNeeded, _saiData);

        uint256 userSelfCredit = 0;
        if (msg.sender == cdpOwner) userSelfCredit = (msg.value > etherNeeded) ? etherNeeded : msg.value;

        // §Ö§ã§ä§î §á§â§à§æ§Ú§ä
        if (jam > info.deposit + userSelfCredit) {
            extraProfitInEther = sub(jam, info.deposit + userSelfCredit);

            if (minAmountAllowed == 0) {
                // VIA ETH
                hasProfit = ((extraProfitInEther * sub(100, info.feeForBonusEther) / 100) * 10000 / info.deposit) >= uint256(info.profitPercent) * 100;
            } else {
                // VIA USD
                hasProfit = (minAmountAllowed * 10000 / wmul(info.deposit, info.etherPrice)) >= uint256(info.profitPercent) * 100;
            }
        }

        if (hasProfit) {
            affiliateProcess(msg.sender, extraProfitInEther * info.feeForBonusEther / 100);

            require(jam >= info.deposit + extraProfitInEther * sub(100, info.feeForBonusEther) / 100);
            jam = info.deposit + extraProfitInEther * sub(100, info.feeForBonusEther) / 100;
        } else {
            // §Ö§ã§Ý§Ú §â§Ñ§ã§ä§à§â§Ô§Ñ§Ö§ä§ã§ñ §ã§ä§â§Ñ§ä§Ö§Ô§Ú§ñ §Õ§à§ã§â§à§é§ß§à §Ü§Ý§Ú§Ö§ß§ä §Þ§à§Ø§Ö§ä §Ù§Ñ§á§Ý§Ñ§ä§Ú§ä§î fee
            if (now < dateUntilFees) {
                jam = sub(jam, jam * earlyCloseFee / 100);
            }
        }

        if (minAmountAllowed > 0) {
            emit StrategyClosed(cup, minAmountAllowed, address(usdToken));
        } else {
            emit StrategyClosed(cup, jam, address(0x0));
        }

        tub.gem().withdraw(tub.gem().balanceOf(address(this)));

        withdrawProfit(cdpOwner, jam, _usdData, minAmountAllowed);
    }

    function withdrawProfit(address payable userAddress, uint256 jam, bytes memory _usdData, uint256 minAmountAllowed) internal {
        // tub.gem().withdraw(jam);
        if (minAmountAllowed == 0) {
            userAddress.transfer(jam); // withdraw ether to user
        } else {
            exchange(ETH_ADDRESS, jam, usdToken, minAmountAllowed, _usdData);

            IToken(usdToken).universalTransfer(userAddress, minAmountAllowed);
        }
    }

    function wipeAndCloseInternal(bytes32 cup, uint256 jam, uint256 etherNeeded, bytes memory _saiData) internal returns(uint256) {
        uint256 wad;
        uint256 saiGovAmt;
        uint256 govAmt;

        (saiGovAmt, govAmt,  wad) = calc(cup);

        uint256 credit = 0;
        if (msg.value > etherNeeded) { // user sent too much
            address(msg.sender).transfer(sub(msg.value, etherNeeded));
        } else {
            credit = sub(etherNeeded, msg.value);
            // TODO §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §ã§Ü§à§â§Ö§Ö §Ó§ã§Ö§Ô§à §ß§Ö§ä §ä§Ñ§Ü§Ú§ç §Õ§Ö§ß§Ö§Ô, §Ó§ã§× §Ó ETH
            // creditAddress.showmethemoney(credit);

            // take an extra eth loan
            loanPool.loan(credit);

            // TokenInterface(tub.gem()).transferFrom(creditAddress, address(this), credit);
        }
        require(jam > credit);

        // user sent some funds
        // TODO:
        // uint256 balanceWETH = tub.gem().balanceOf(address(this));
        // if (balanceWETH < etherNeeded) tub.gem().deposit.value(etherNeeded - balanceWETH)();


        // ETH => SAI
        exchange(ETH_ADDRESS, etherNeeded, tub.sai(), wad + saiGovAmt, _saiData);

        //-------------------------------

        tub.wipe(cup, wad); // repay sai & mkr

        uint ink = rdiv(jam, tub.per());
        ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;

        tub.free(cup, ink);

        tub.exit(ink);

        tub.shut(cup); // close

        jam = sub(jam, credit);

        // return the credi
        if (credit > 0) {
            tub.gem().withdraw(credit);
            transferEthInternal(address(loanPool), credit);
            // TokenInterface(tub.gem()).transfer(creditAddress, credit);
        }

        return jam;
    }

    function transferEthInternal(address receiver, uint256 amount) internal {
        address payable receiverPayable = address(uint160(receiver));
        (bool result, ) = receiverPayable.call.value(amount)("");
        require(result, "Transfer of ETH failed");
    }


    // **FALLBACK functions**
    function() external payable {}
}
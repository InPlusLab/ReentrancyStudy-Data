/**
 *Submitted for verification at Etherscan.io on 2020-03-27
*/

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/upgradable/OwnableUpgradable.sol

pragma solidity ^0.5.16;


contract OwnableUpgradable is Initializable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    // Initializer 每 Constructor for Upgradable contracts
    function initialize() initializer public {
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

    uint256[50] private ______gap;
}

// File: contracts/utils/SafeMath.sol

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

// File: contracts/utils/Address.sol

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

// File: contracts/interfaces/TokenInterface.sol

pragma solidity ^0.5.16;

interface TokenInterface {
    function decimals() external view returns (uint);
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

// File: contracts/utils/SafeERC20.sol

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

    function safeTransfer(TokenInterface token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(TokenInterface token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(TokenInterface token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(TokenInterface token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(TokenInterface token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(TokenInterface token, bytes memory data) private {
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

// File: contracts/utils/UniversalERC20.sol

pragma solidity ^0.5.16;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";




library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for TokenInterface;

    TokenInterface private constant ZERO_ADDRESS = TokenInterface(0x0000000000000000000000000000000000000000);
    TokenInterface private constant ETH_ADDRESS = TokenInterface(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(TokenInterface token, address to, uint256 amount) internal {
        universalTransfer(token, to, amount, false);
    }

    function universalTransfer(TokenInterface token, address to, uint256 amount, bool mayFail) internal returns(bool) {
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

    function universalApprove(TokenInterface token, address to, uint256 amount) internal {
        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(TokenInterface token, address from, address to, uint256 amount) internal {
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

    function universalBalanceOf(TokenInterface token, address who) internal view returns (uint256) {
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

// File: contracts/upgradable/FundsMgrUpgradable.sol

pragma solidity ^0.5.16;




contract FundsMgrUpgradable is Initializable, OwnableUpgradable {
    using UniversalERC20 for TokenInterface;

    // Initializer 每 Constructor for Upgradable contracts
    function initialize() initializer public {
        OwnableUpgradable.initialize();  // Initialize Parent Contract
    }

    function withdraw(address token, uint256 amount) onlyOwner public  {
        require(msg.sender == owner);

        if (token == address(0x0)) {
            owner.transfer(amount);
        } else {
            TokenInterface(token).universalTransfer(owner, amount);
        }
    }
    function withdrawAll(address[] memory tokens) onlyOwner public  {
        for(uint256 i = 0; i < tokens.length;i++) {
            withdraw(tokens[i], TokenInterface(tokens[i]).universalBalanceOf(address(this)));
        }
    }

    uint256[50] private ______gap;
}

// File: contracts/utils/DSMath.sol

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

// File: contracts/interfaces/DfFinanceMgrInterface.sol

pragma solidity ^0.5.16;

interface DfFinanceMgrInterface {
    function setupCup(address cdpOwner, bytes32 cup, uint256 deposit, uint8 profitPercent, uint256 etherPrice, uint8 feeForBonusEther) external;
}

// File: contracts/interfaces/OtcInterface.sol

pragma solidity ^0.5.16;


interface OtcInterface {
    // function getPayAmount(address, address, uint) public view returns (uint);
    function buyAllAmount(address, uint, address pay_gem, uint) external returns (uint);
    function getSellAmount(TokenInterface dest, TokenInterface src, uint256 srcAmount) external view returns (uint256);
    function getBuyAmount(TokenInterface dest, TokenInterface src, uint256 srcAmount) external view returns (uint256);
}

// File: contracts/interfaces/PepInterface.sol

pragma solidity ^0.5.16;

interface PepInterface {
    function peek() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
}

// File: contracts/interfaces/TubInterface.sol

pragma solidity ^0.5.16;



interface TubInterface {
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
    function gem() external view returns (TokenInterface);
    function gov() external view returns (TokenInterface);
    function skr() external view returns (TokenInterface);
    function sai() external view returns (TokenInterface);
    function mat() external view returns (uint);
    function ink(bytes32) external view returns (uint);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function per() external view returns (uint);
    function pep() external view returns (PepInterface);
    function pip() external view returns (PepInterface);
    function ask(uint wad) external view returns (uint);
}

// File: contracts/interfaces/AffiliateProgramInterface.sol

pragma solidity ^0.5.16;

contract AffiliateProgram {
    function addUserUseCode(address user, string memory code) public;
    function getPartnerFromUser(address user) external view returns (address, uint8, uint256, uint256);
    function levels(uint8 level) external view returns (uint16, uint256);
    function addPartnerProfitUseAddress(address partner) external payable;
}

// File: contracts/DfFinanceMgrOpenCdp.sol

pragma solidity ^0.5.16;









// **INTERFACES**
interface DfProxyBetInterface {
    function insure(address beneficiary, bytes32 cup, uint256 amountSai) external;
}

contract ProxyOneInchExchangeInterface {
    function exchange(TokenInterface fromToken, uint256 amountFromToken, bytes memory _data) public;
}

contract DfFinanceMgrOpenCdp is Initializable, DSMath, FundsMgrUpgradable {

    mapping(address => bool) public allowedOtc;

    TubInterface tub;
    AffiliateProgram public aff;

    // Fees
    uint8 public inFee;
    uint8 public currentFeeForBonusEther;

    // Insurance
    DfProxyBetInterface public proxyInsuranceBet;
    uint256 public insuranceCoef;  // in percent

    mapping(address => bool) public admins;
    OtcInterface[] public allOtc;
    DfFinanceMgrInterface public migrateToNewContract;
    uint256 public maxAllowedExtractSaiPercent;
    DfFinanceMgrInterface public dfManagerAddress;


    TokenInterface private constant ETH_ADDRESS = TokenInterface(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);


    // Initializer 每 Constructor for Upgradable contracts
    function initialize() initializer public {
        FundsMgrUpgradable.initialize();  // Initialize Parent Contract

        tub = TubInterface(0x448a5065aeBB8E423F0896E6c5D525C040f59af3);  // MainNet SaiTub: 0x448a5065aeBB8E423F0896E6c5D525C040f59af3
        inFee = 0;
        currentFeeForBonusEther = 30;
        maxAllowedExtractSaiPercent = 2;

        if (tub.gem().allowance(address(this), address(tub)) != uint256(-1)) {
            tub.gem().approve(address(tub), uint256(-1));
        }

        if (tub.skr().allowance(address(this), address(tub)) != uint256(-1)) {
            tub.skr().approve(address(tub), uint256(-1));
        }
    }

    // Admin functions
    function setDfManagerAddress(address payable newAddress) onlyOwner public {
        require(newAddress != address(0x0));

        dfManagerAddress = DfFinanceMgrInterface(newAddress);

        // 把忘戒把快扮忘快技 找把忘找我找抆 扶忘扮快技批 抗抉扶找把忘抗找批 抉忌投我快 改扳我把抑
        //if (tub.gem().allowance(address(this), address(dfManagerAddress)) != uint256(-1)) {
        //    tub.gem().approve(address(dfManagerAddress), uint256(-1));
        //}
    }

    function setDfProxyBetAddress(DfProxyBetInterface proxyBet, uint256 newInsuranceCoef) onlyOwner public {
        require(address(proxyBet) != address(0) && newInsuranceCoef > 0 
            || address(proxyBet) == address(0) && newInsuranceCoef == 0, "Incorrect proxy address or insurance coefficient");

        proxyInsuranceBet = proxyBet;
        insuranceCoef = newInsuranceCoef;  // in percent (5 == 5%)

        // all sai of this contract approved to BetEthPrice Contract
        tub.sai().approve(address(proxyBet), uint(-1));
    }

    function setAffProgram(address newAff) onlyOwner public {
        aff = AffiliateProgram(newAff);
    }

    function changeMaxAllowedExtractSaiPercent(uint256 newPercent) onlyOwner public {
        maxAllowedExtractSaiPercent = newPercent;
    }

    function setAdmin(address newAdmin, bool active) onlyOwner public {
        admins[newAdmin] = active;
    }

    function changeOtc(OtcInterface _newOtc, bool allow) onlyOwner public {
        allowedOtc[address(_newOtc)] = allow;
    }

    function changeFees(uint8 _inFee, uint8 _currentFeeForBonusEther) onlyOwner public {
        require(_inFee <= 5);
        require(_currentFeeForBonusEther < 100);
        inFee = _inFee;
        currentFeeForBonusEther = _currentFeeForBonusEther;
    }

    function priceETH() view public returns (uint256) {
        return uint256(PepInterface(TubInterface(tub).pip()).read());
    }

    function addOtc(OtcInterface newOtc) onlyOwner public {
        allOtc.push(newOtc);
        allowedOtc[address(newOtc)] = true;
    }

    function removeOtc(OtcInterface otcToRemove) onlyOwner public {

        for(uint256 i =0; i < allOtc.length;i++ ) {
            if (allOtc[i] == otcToRemove) {
                allowedOtc[address(otcToRemove)] = false;

                allOtc[i] = allOtc[allOtc.length -1];
                delete allOtc[allOtc.length - 1];
                allOtc.length--;
                break;
            }
        }
    }

    function caluclateAmountSaiFromEth(uint256 wad, uint256 rate) view public returns(uint256) {
        uint256 price = priceETH();

        return wmul(wmul(wdiv(wad, tub.ask(wad)), wad), price) * 100 / rate;
    }

    function exchange(TokenInterface fromToken, uint256 maxFromTokenAmount, TokenInterface toToken, uint256 minToTokenAmount, bytes memory _data) internal returns (uint256)
    {
        // Proxy call for avoid out of gas in fallback (because of .transfer())
        ProxyOneInchExchangeInterface proxyEx = ProxyOneInchExchangeInterface(0x3fF9Cc22ef2bF6de5Fd2E78f511EDdF0813f6B36);

        if (fromToken.allowance(address(this), address(proxyEx)) != uint256(-1)) {
            fromToken.approve(address(proxyEx), uint256(-1));
        }

        uint256 fromTokenBalance = fromToken.universalBalanceOf(address(this));
        uint256 toTokenBalance = toToken.universalBalanceOf(address(this));

        // Proxy call for avoid out of gas in fallback (because of .transfer())
        proxyEx.exchange(fromToken, maxFromTokenAmount, _data);

        uint256 newBalanceToToken = toToken.universalBalanceOf(address(this));
        require(fromToken.universalBalanceOf(address(this)) + maxFromTokenAmount >= fromTokenBalance);
        require(newBalanceToToken >= toTokenBalance + minToTokenAmount);

        return sub(newBalanceToToken, toTokenBalance); // how many tokens received
    }

    function openCdpAndDraw(uint256 saiAmount, uint256 ethAmount) internal returns(bytes32 cup)
    {
        cup = tub.open();

        (address lad,,,) = tub.cups(cup);
        require(lad == address(this), "cup-not-owned");

        tub.gem().deposit.value(ethAmount)();

        uint256 ink = rdiv(ethAmount, tub.per());
        ink = rmul(ink, tub.per()) <= ethAmount ? ink : ink - 1;

        tub.join(ink);

        tub.lock(cup, ink);

        tub.draw(cup, saiAmount);
    }


    function findBestOtc(address tokenPay, address tokenNeeded, uint256 amountNeeded) view public returns(OtcInterface bestOtc, uint256 bestAmount) {
        uint256 index = allOtc.length;
        bestOtc = allOtc[index - 1];
        bestAmount = bestOtc.getBuyAmount(TokenInterface(tokenPay), TokenInterface(tokenNeeded), amountNeeded);
        index--;
        while (index > 0) {
            uint256 amount = allOtc[index - 1].getBuyAmount(TokenInterface(tokenPay), TokenInterface(tokenNeeded), amountNeeded);
            if (amount < bestAmount) {
                bestAmount = amount;
                bestOtc = allOtc[index - 1];
            }
            index--;
        }
    }

    function dealWithPromo(address newOwner, uint256 coef, uint8 profitPercent, bytes memory data, string memory code, uint256 saiToBuyEther, uint8 ethType ) public payable returns(bytes32) {
        aff.addUserUseCode(newOwner, code);
        return _deal(newOwner, profitPercent, coef, msg.value, data, saiToBuyEther, ethType);
    }

    function deal(address newOwner, uint256 coef, uint8 profitPercent, bytes memory data, uint256 saiToBuyEther, uint8 ethType) public payable returns(bytes32) {
        return _deal(newOwner, profitPercent, coef, msg.value, data, saiToBuyEther, ethType);
    }

    function dealViaOtc(address newOwner, uint256 coef, uint8 profitPercent, OtcInterface otc, uint256 maxSai) public payable returns(bytes32 cup) {
        cup = _deal_otc(newOwner, coef, msg.value, otc, maxSai);

        tub.give(cup, address(dfManagerAddress));
        dfManagerAddress.setupCup(newOwner, cup, msg.value, profitPercent, priceETH(), currentFeeForBonusEther);
    }

    function _deal(address newOwner, uint8 profitPercent, uint256 coef, uint256 valueEth, bytes memory data, uint256 saiToBuyEther, uint8 ethType) internal returns(bytes32 cup)
    {
        if (newOwner == address(0x0)) newOwner = msg.sender;
        require(coef >= 150 && coef <= 300); // TODO: replace coef >= 125

        uint256 extraEth = valueEth * (coef - 100) / 100;

        uint256 extractSai = saiToBuyEther * (100 + inFee + insuranceCoef) / 100;

        // 扶批忪扶抑 抖我 改找我 扭把抉志快把抗我 ?
        uint256 rate = (caluclateAmountSaiFromEth(valueEth + extraEth, 100) * 100) / extractSai;
        require(rate > 175);

        // 妒戒志抖快抗忘快技 SAI
        cup = openCdpAndDraw(extractSai, valueEth + extraEth);

        // call DfProxyBet contract (and transferFrom sai)
        if (address(proxyInsuranceBet) != address(0)) {
            proxyInsuranceBet.insure(newOwner, cup, saiToBuyEther * insuranceCoef / 100);
        }

        exchange(tub.sai(), saiToBuyEther, ethType == 0 ? tub.gem() : ETH_ADDRESS, extraEth, data);

        if (ethType == 0) tub.gem().withdraw(tub.gem().balanceOf(address(this)));

        tub.give(cup, address(dfManagerAddress));
        dfManagerAddress.setupCup(newOwner, cup, valueEth, profitPercent, wdiv(saiToBuyEther, extraEth), currentFeeForBonusEther);
    }

    function showmethemoney(uint256 amount) external {
        require(msg.sender == address(dfManagerAddress));
        address(msg.sender).transfer(amount); // send eth to friendly contract, it should return them in the same transaction
    }

    function _deal_otc(address newOwner, uint256 coef, uint256 valueEth, OtcInterface otc, uint256 maxSai) internal returns(bytes32 cup)
    {
        if (newOwner == address(0x0)) newOwner = msg.sender;
        require(coef >= 150 && coef <= 300);

        uint256 extraEth = valueEth * (coef - 100) / 100;

        uint256 fee =  valueEth * inFee / 100; // inFee = 5%

        if (maxSai == 0) {
            maxSai = wmul(priceETH(), extraEth + fee) * (100 + maxAllowedExtractSaiPercent) / 100;
        }

        uint256 saiToBuyEther;
        if (otc == OtcInterface(0x0)) {
            (otc, saiToBuyEther) = findBestOtc(address(tub.sai()), address(tub.gem()), extraEth + fee);
        } else {
            require(allowedOtc[address(otc)]);
            saiToBuyEther = otc.getBuyAmount(tub.sai(), tub.gem(), extraEth + fee);
        }

        if (tub.sai().allowance(address(this), address(otc)) != uint(-1)) {  // TODO: optimize
            tub.sai().approve(address(otc), uint(-1));
        }

        // 扶批忪扶抑 抖我 改找我 扭把抉志快把抗我 ?
        uint256 rate = (caluclateAmountSaiFromEth(valueEth + extraEth, 100) * 100) / saiToBuyEther;
        require(rate > 170);

        require(saiToBuyEther <= maxSai);

        // 妒戒志抖快抗忘快技 SAI
        cup = openCdpAndDraw(saiToBuyEther, valueEth + extraEth);

        uint256 balance = tub.gem().balanceOf(address(this));

        otc.buyAllAmount(address(tub.gem()), extraEth, address(tub.sai()), saiToBuyEther);

        uint256 newBalance = tub.gem().balanceOf(address(this));

        require(newBalance >= balance + extraEth); // check that we got ether

        tub.gem().withdraw(newBalance);
    }

    function() external payable {

    }

    uint256[50] private ______gap;
}
/**
 *Submitted for verification at Etherscan.io on 2020-03-30
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

// File: contracts/BetEthPrice.sol

pragma solidity ^0.5.16;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";




contract ETHUSD {
    function read() external view returns (bytes32);
}

contract BetEthPrice {
    using UniversalERC20 for TokenInterface;
    using SafeMath for uint256;

    struct Bet {
        uint256 betCoef;
        uint256 amountUsd;
    }

    mapping(address => Bet) public betsHighPrice;
    mapping(address => Bet) public betsLowPrice;

    bool public isExistsBetsHighPrice;
    bool public isExistsBetsLowPrice;

    ETHUSD public oracleUsd;
    TokenInterface public usdToken;

    uint256 public targetPrice;
    uint256 public endTime;

    bool public isFinalized;
    bool public isCanceled;

    bool public isHighPriceWin;

    uint256 public totalHighPriceCoef;
    uint256 public totalLowPriceCoef;

    uint256 public finalBalance;

    constructor(uint256 _targetPrice, uint256 _endTime) public {
        oracleUsd = ETHUSD(0x729D19f657BD0614b4985Cf1D82531c67569197B);  // MainNet Medianizer MakerDao (pip): 0x729D19f657BD0614b4985Cf1D82531c67569197B
        usdToken = TokenInterface(0xdAC17F958D2ee523a2206206994597C13D831ec7);  // MainNet USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7

        targetPrice = _targetPrice;  // 80 * 1e18 每 equals 80.000 eth (1e18) 每 price should multiple of 10
        endTime = _endTime;  //  1588291200 每 01.05.2020 @ 12:00am (UTC)
    }


    function betOnHighPrice(uint256 amount) public {
        _bet(msg.sender, amount, true);
    }

    function betOnHighPrice(address beneficiary, uint256 amount) public {
        _bet(beneficiary, amount, true);
    }


    function betOnLowPrice(uint256 amount) public {
        _bet(msg.sender, amount, false);
    }

    function betOnLowPrice(address beneficiary, uint256 amount) public {
        _bet(beneficiary, amount, false);
    }

    // finalize Betting (time is over or price is lower than targetPrice)
    function finalize() public {
        require(!isFinalized, "Have already finilized");

        bool isLowWin = (getCurPriceUsd() <= targetPrice);
        bool isHighWin = (!isLowWin && (now >= endTime));
        require(isLowWin || isHighWin, "Betting is active");

        // set win bets
        isHighPriceWin = isHighWin;

        // if no winners 每 cancel betting
        if ((isHighWin && !isExistsBetsHighPrice)
         || (!isHighWin && !isExistsBetsLowPrice)) {
            isCanceled = true;
            return;
        }

        finalBalance = usdToken.balanceOf(address(this));
        isFinalized = true;
    }

    function withdrawPrize() public  {
        require(isFinalized, "Betting is active or cancel");

        uint256 amount = 0;
        if (isHighPriceWin) {
            amount = finalBalance.mul(betsHighPrice[msg.sender].betCoef).div(totalHighPriceCoef);

            // set user's betCoef state as 0
            betsHighPrice[msg.sender].betCoef = 0;
        } else {
            amount = finalBalance.mul(betsLowPrice[msg.sender].betCoef).div(totalLowPriceCoef);

            // set user's betCoef state as 0
            betsLowPrice[msg.sender].betCoef = 0;
        }

        // transfer prize to user
        usdToken.universalTransfer(msg.sender, amount);
    }

    function withdrawCanceled() public {
        require(isCanceled, "Betting is not canceled");

        // transfer user's bet to user
        usdToken.universalTransfer(msg.sender, betsLowPrice[msg.sender].amountUsd.add(betsHighPrice[msg.sender].amountUsd));
    }


    // **VIEW functions**

    function getUsdtBalance() public view returns(uint256 usdtBalance) {
        usdtBalance = usdToken.balanceOf(address(this));
    }

    function getCurPriceUsd() public view returns(uint256) {
        return uint256(oracleUsd.read());  // USD price call to MakerDao Oracles 每 Medianizer contract
    }

    function getTimeLeft() public view returns(uint256) {
        uint256 curEndTime = endTime;
        if (curEndTime > now) {
            return curEndTime - now;
        }

        return 0;
    }


    // **INTERNAL functions**

    function _bet(address beneficiary, uint256 amount, bool isHighPrice) internal {
        require(now < endTime, "Betting time is over");
        require(amount > 0, "USD should be more than 0");

        // transfer USD from msg.sender to this contract
        usdToken.universalTransferFrom(msg.sender, address(this), amount);

        uint256 priceUsd = getCurPriceUsd();
        uint256 timeLeft = getTimeLeft();
        uint256 curBetCoef = 0;

        if (isHighPrice) {
            curBetCoef = amount.mul(timeLeft).mul(1e21).div(priceUsd);  // amount * timeLeft / priceUsd

            // set states
            betsHighPrice[beneficiary].betCoef = betsHighPrice[beneficiary].betCoef.add(curBetCoef);
            totalHighPriceCoef = totalHighPriceCoef.add(curBetCoef);

            betsHighPrice[beneficiary].amountUsd = betsHighPrice[beneficiary].amountUsd.add(amount);
        } else {
            curBetCoef = amount.mul(timeLeft).mul(priceUsd).div(1e18);  // amount * timeLeft * priceUsd

            // set states
            betsLowPrice[beneficiary].betCoef = betsLowPrice[beneficiary].betCoef.add(curBetCoef);
            totalLowPriceCoef = totalLowPriceCoef.add(curBetCoef);

            betsLowPrice[beneficiary].amountUsd = betsLowPrice[beneficiary].amountUsd.add(amount);
        }

        // if no betters
        if (!isExistsBetsHighPrice && isHighPrice) {
            isExistsBetsHighPrice = true;
        } else if (!isExistsBetsLowPrice && !isHighPrice) {
            isExistsBetsLowPrice = true;
        }
    }
}

// File: contracts/BetEthPriceFactory.sol

pragma solidity ^0.5.16;



contract BetEthPriceFactory is Initializable {

    event CreatedBetEthPrice(address indexed betEthPrice, uint256 targetPrice, uint256 endTime);

    function createBetEthPrice(uint256 targetPrice, uint256 endTime) public returns(address) {
        BetEthPrice betEthPrice = new BetEthPrice(targetPrice, endTime);
        emit CreatedBetEthPrice(address(betEthPrice), targetPrice, endTime);

        return address(betEthPrice);
    }
}
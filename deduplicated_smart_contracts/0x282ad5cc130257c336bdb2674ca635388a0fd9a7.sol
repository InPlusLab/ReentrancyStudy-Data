/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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
    require(c >= a, 'SafeMath: addition overflow');

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
    return sub(a, b, 'SafeMath: subtraction overflow');
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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
    return div(a, b, 'SafeMath: division by zero');
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    return mod(a, b, 'SafeMath: modulo by zero');
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/interfaces/IExtendedAggregator.sol

pragma solidity ^0.6.6;

interface IExtendedAggregator {
  function getToken() external view returns (address);

  function getTokenType() external view returns (uint256);

  function getPlatformId() external view returns (uint256);

  function getSubTokens() external view returns (address[] memory);

  function latestAnswer() external view returns (int256);
}

// File: contracts/interfaces/ILatestAnswerGetter.sol

pragma solidity ^0.6.6;

interface ILatestAnswerGetter {
  function latestAnswer() external view returns (int256);
}

// File: contracts/interfaces/IPriceOracleGetter.sol

pragma solidity ^0.6.6;

interface IPriceOracleGetter {
  function getAssetPrice(address _asset) external view returns (uint256);
}

// File: contracts/interfaces/IERC20Metadata.sol

pragma solidity ^0.6.6;

interface IERC20Metadata {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

// File: contracts/interfaces/IPriceGetterCpm.sol

pragma solidity ^0.6.6;

interface IPriceGetterCpm {
  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256);
}

// File: contracts/misc/EthAddressLib.sol

pragma solidity ^0.6.6;

library EthAddressLib {
  /**
   * @dev returns the address used within the protocol to identify ETH
   * @return the address assigned to ETH
   */
  function ethAddress() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  }
}

// File: contracts/misc/MathUtils.sol

pragma solidity ^0.6.6;

library MathUtils {
  /**
   * @notice Returns the square root of an uint256 x
   * - Uses the Babylonian method, but using (x + 1) / 2 as initial guess in order to have decreasing guessing iterations
   * which allow to do z < y instead of checking that z*z is within a range of precision respect to x
   * @param x The number to calculate the sqrt from
   * @return The root
   */
  function sqrt(uint256 x) internal pure returns (uint256) {
    uint256 z = (x + 1) / 2;
    uint256 y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
    return y;
  }
}

// File: contracts/proxies/CpmPriceProvider.sol

pragma solidity ^0.6.6;

/** @title CpmPriceProvider
 * @author Aave
 * @notice Constant Product Market price provider for a token/ETH pair , represented by a CPM token
 * - Using an external price source for the token side of the pair and an extra oracle as fallback
 * - IMPORTANT. It's as assumption that the last calculation on latestAnswer() doesn't overflow because
 *   the token/ETH balances and prices are validated before creating the corresponding CpmPriceProvider
 *   for them.
 */
contract CpmPriceProvider is IExtendedAggregator {
  using SafeMath for uint256;

  uint256 public immutable PRICE_DEVIATION; // 10 represents a 1% deviation
  IERC20 internal immutable CPM_TOKEN;
  IERC20 public immutable TOKEN;
  bool public immutable PEGGED_TO_ETH;
  ILatestAnswerGetter public immutable TOKEN_PRICE_PROVIDER;
  IPriceOracleGetter public immutable FALLBACK_ORACLE;
  uint256 public immutable TOKEN_DECIMALS;
  uint256 internal immutable CPM_TOKEN_TYPE;
  uint256 internal immutable PLATFORM_ID;
  address[] internal subTokens;

  event Setup(
    address indexed creator,
    IERC20 indexed cpmToken,
    IERC20 indexed token,
    bool peggedToEth,
    uint256 priceDeviation,
    ILatestAnswerGetter tokenPriceProvider,
    IPriceOracleGetter fallbackOracle,
    uint256 cpmTokenType,
    uint256 platformId
  );

  constructor(
    IERC20 _cpmToken,
    IERC20 _token,
    bool _peggedToEth,
    uint256 _priceDeviation,
    ILatestAnswerGetter _tokenPriceProvider,
    IPriceOracleGetter _fallbackOracle,
    uint256 _cpmTokenType,
    uint256 _platformId
  ) public {
    CPM_TOKEN = _cpmToken;
    TOKEN = _token;
    PEGGED_TO_ETH = _peggedToEth;
    PRICE_DEVIATION = _priceDeviation;
    TOKEN_PRICE_PROVIDER = _tokenPriceProvider;
    FALLBACK_ORACLE = _fallbackOracle;
    TOKEN_DECIMALS = (_peggedToEth) ? 18 : uint256(IERC20Metadata(address(_token)).decimals());
    CPM_TOKEN_TYPE = _cpmTokenType;
    PLATFORM_ID = _platformId;
    subTokens.push(EthAddressLib.ethAddress());
    subTokens.push(address(_token));
    emit Setup(
      msg.sender,
      _cpmToken,
      _token,
      _peggedToEth,
      _priceDeviation,
      _tokenPriceProvider,
      _fallbackOracle,
      _cpmTokenType,
      _platformId
    );
  }

  /**
   * @notice Returns the price in ETH wei of 1 big unit of CPM_TOKEN, taking into account the different ETH prices of the underlyings
   * - If a big deviation between the price token -> ETH within the CPM compared with the price in the TOKEN_PRICE_PROVIDER is detected,
   * it reverts, as there is an ongoing attempt to manipulate the price
   * @return The price
   */
  function latestAnswer() external override view returns (int256) {
    uint256 _cpmTokenSupply = CPM_TOKEN.totalSupply();
    int256 _signedPrice = (PEGGED_TO_ETH) ? 1 ether : TOKEN_PRICE_PROVIDER.latestAnswer();
    uint256 _externalPriceOfTokenBigUnitsInWei = (_signedPrice > 0)
      ? uint256(_signedPrice)
      : FALLBACK_ORACLE.getAssetPrice(address(TOKEN));
    if (_externalPriceOfTokenBigUnitsInWei == 0) {
      return 0;
    }
    uint256 _cpmPriceOfTokenBigUnitsInWei = IPriceGetterCpm(address(CPM_TOKEN))
      .getTokenToEthInputPrice(10**TOKEN_DECIMALS);

    uint256 _cpmEthBalanceInWei = address(CPM_TOKEN).balance;
    uint256 _cpmTokenBalanceInDecimalUnits = TOKEN.balanceOf(address(CPM_TOKEN));
    uint256 _priceDeviation = _cpmPriceOfTokenBigUnitsInWei.mul(1000).div(
      _externalPriceOfTokenBigUnitsInWei
    );

    // In the case of a high deviation, revert to not cause any potential issues to the system
    require(
      _priceDeviation < (1000 + PRICE_DEVIATION) && _priceDeviation > (1000 - PRICE_DEVIATION),
      'INVALID_PRICE_DEVIATION'
    );

    return
      int256(
        (_cpmEthBalanceInWei +
          _cpmTokenBalanceInDecimalUnits.mul(_externalPriceOfTokenBigUnitsInWei).div(
            10**TOKEN_DECIMALS
          ))
          .mul(1 ether)
          .div(_cpmTokenSupply)
      );
  }

  /**
   * @notice Return the address of the CPM token
   * @return address
   */
  function getToken() external override view returns (address) {
    return address(CPM_TOKEN);
  }

  /**
   * @notice Return the list of tokens' addresses composing the CPM token
   * - Using EthAddressLib.ethAddress() as mock address for ETH.
   * - The reference token is first on the list
   * @return addresses
   */
  function getSubTokens() external override view returns (address[] memory) {
    return subTokens;
  }

  /**
   * @notice Return the numeric type of the CPM token
   * @return type
   */
  function getTokenType() external override view returns (uint256) {
    return CPM_TOKEN_TYPE;
  }

  /**
   * @notice Return the numeric platform id
   * @return platform id
   */
  function getPlatformId() external override view returns (uint256) {
    return PLATFORM_ID;
  }
}
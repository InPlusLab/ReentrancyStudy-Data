// SPDX-License-Identifier: MIT

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

pragma solidity ^0.6.0;


/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import './SafeMath.sol';
import './SafeCast.sol';
import './AggregatorV3Interface.sol';

contract sbTokens {
  event TokenAdded(address indexed token, address indexed oracle);
  event TokenPricesRecorded(uint256 indexed day);

  using SafeCast for int256;
  using SafeMath for uint256;

  bool internal initDone;

  uint16 internal constant PHASE_OFFSET = 64;

  address internal sbTimelock;

  address[] internal tokens;
  address[] internal oracles;
  mapping(address => uint16) internal oraclePhase;

  mapping(address => AggregatorV3Interface) internal priceFeeds;

  mapping(address => mapping(uint256 => uint256)) internal tokenDayPrice;
  mapping(address => uint64) internal tokenRoundLatest;
  mapping(address => uint256) internal tokenDayStart;
  uint256 internal dayLastRecordedPricesFor;

  function init(
    address sbTimelockAddress,
    address[] memory tokenAddresses,
    address[] memory oracleAddresses
  ) public {
    require(!initDone, 'init done');
    // NOTE: ETH will be address(0)
    require(tokenAddresses.length == oracleAddresses.length, 'mismatch array lengths');
    require(tokenAddresses.length > 0, 'zero');
    sbTimelock = sbTimelockAddress;
    dayLastRecordedPricesFor = _getCurrentDay().sub(1);
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
      _addToken(tokenAddresses[i], oracleAddresses[i]);
    }
    initDone = true;
  }

  function upToDate() external view returns (bool) {
    return dayLastRecordedPricesFor == _getCurrentDay().sub(1);
  }

  function addToken(address token, address oracle) external {
    require(msg.sender == sbTimelock, 'not sbTimelock');
    require(token != address(0), 'token not zero address');
    require(oracle != address(0), 'oracle not zero address');
    require(oracle != token, 'token oracle not same');
    require(!_tokenExists(token), 'token exists');
    require(!_oracleExists(oracle), 'oracle exists');
    _addToken(token, oracle);
  }

  function getTokens() external view returns (address[] memory) {
    return tokens;
  }

  function getTokenPrices(uint256 day) external view returns (uint256[] memory) {
    require(day <= dayLastRecordedPricesFor, 'invalid day');
    uint256[] memory prices = new uint256[](tokens.length);
    for (uint256 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      prices[i] = tokenDayPrice[token][day];
    }
    return prices;
  }

  function tokenAccepted(address token) external view returns (bool) {
    return _tokenExists(token);
  }

  function getTokenPrice(address token, uint256 day) external view returns (uint256) {
    require(_tokenExists(token), 'invalid token');
    require(day >= tokenDayStart[token], '1: invalid day');
    require(day <= dayLastRecordedPricesFor, '2: invalid day');
    return tokenDayPrice[token][day];
  }

  function getOracles() public view returns (address[] memory) {
    return oracles;
  }

  function getDayLastRecordedPricesFor() public view returns (uint256) {
    return dayLastRecordedPricesFor;
  }

  function getSbTimelockAddressUsed() public view returns (address) {
    return sbTimelock;
  }

  function getTokenRoundLatest(address token) public view returns (uint80) {
    require(_tokenExists(token), 'invalid token');
    return _makeCombinedId(oraclePhase[token], tokenRoundLatest[token]);
  }

  function getTokenDayStart(address token) public view returns (uint256) {
    require(_tokenExists(token), 'invalid token');
    return tokenDayStart[token];
  }

  function getCurrentDay() public view returns (uint256) {
    return _getCurrentDay();
  }

  function recordTokenPrices() public {
    require(_getCurrentDay() > dayLastRecordedPricesFor.add(1), 'already recorded');
    dayLastRecordedPricesFor = dayLastRecordedPricesFor.add(1);
    for (uint256 i = 0; i < tokens.length; i++) {
      (uint80 roundId, , , , ) = priceFeeds[tokens[i]].latestRoundData();
      (uint16 phase, ) = _getPhaseIdRoundId(roundId);

      if (oraclePhase[tokens[i]] != phase) {
        oraclePhase[tokens[i]] = phase;
        _cacheToken(tokens[i], _dayToTimestamp(dayLastRecordedPricesFor));
      }

      tokenDayPrice[tokens[i]][dayLastRecordedPricesFor] = _getDayClosingPrice(tokens[i], dayLastRecordedPricesFor);
    }
    emit TokenPricesRecorded(dayLastRecordedPricesFor);
  }

  function _addToken(address token, address oracle) internal {
    tokens.push(token);
    oracles.push(oracle);
    priceFeeds[token] = AggregatorV3Interface(oracle);
    (uint80 roundId, , , , ) = priceFeeds[token].latestRoundData();
    (uint16 phaseId, ) = _getPhaseIdRoundId(roundId);
    oraclePhase[token] = phaseId;
    uint256 currentDay = _getCurrentDay();
    tokenDayStart[token] = currentDay;
    uint256 timestamp = _dayToTimestamp(currentDay.sub(1));
    _cacheToken(token, timestamp);
    emit TokenAdded(token, oracle);
  }

  function _cacheToken(address token, uint256 timestamp) internal {
    tokenRoundLatest[token] = 1;
    uint64 roundId = _getRoundBeforeTimestamp(token, timestamp);
    tokenRoundLatest[token] = roundId;
  }

  function _getRoundBeforeTimestamp(address token, uint256 timestamp) internal view returns (uint64) {
    uint64 left = tokenRoundLatest[token];
    (uint80 roundId, , , , ) = priceFeeds[token].latestRoundData();
    (, uint64 right) = _getPhaseIdRoundId(roundId);
    uint64 middle = (right + left) / 2;
    while (left <= right) {
      roundId = _makeCombinedId(oraclePhase[token], middle);
      (, , , uint256 roundTimestamp, ) = priceFeeds[token].getRoundData(roundId);
      if (roundTimestamp == timestamp) {
        return middle - 1;
      } else if (roundTimestamp < timestamp) {
        left = middle + 1;
      } else {
        right = middle - 1;
      }
      middle = (right + left) / 2;
    }
    return middle;
  }

  function _getDayClosingPrice(address token, uint256 day) internal returns (uint256) {
    uint256 timestamp = _dayToTimestamp(day);
    uint64 roundId = _getRoundBeforeTimestamp(token, timestamp);
    tokenRoundLatest[token] = roundId;
    uint80 combinedId = _makeCombinedId(oraclePhase[token], roundId);
    (, int256 price, , , ) = priceFeeds[token].getRoundData(combinedId);
    uint256 priceUint256 = price.toUint256();
    uint8 decimals = priceFeeds[token].decimals();
    for (uint8 i = decimals; i < 18; i++) {
      priceUint256 = priceUint256.mul(10);
    }
    return priceUint256;
  }

  function _getCurrentDay() internal view returns (uint256) {
    return block.timestamp.div(1 days).add(1);
  }

  function _dayToTimestamp(uint256 day) internal pure returns (uint256) {
    return day.mul(1 days);
  }

  function _tokenExists(address token) internal view returns (bool) {
    for (uint256 i = 0; i < tokens.length; i++) {
      if (token == tokens[i]) {
        return true;
      }
    }
    return false;
  }

  function _oracleExists(address oracle) internal view returns (bool) {
    for (uint256 i = 0; i < oracles.length; i++) {
      if (oracle == oracles[i]) {
        return true;
      }
    }
    return false;
  }

  function _getPhaseIdRoundId(uint256 combinedId) internal pure returns (uint16, uint64) {
    return (uint16(combinedId >> PHASE_OFFSET), uint64(combinedId));
  }

  function _makeCombinedId(uint80 phaseId, uint64 roundId) internal pure returns (uint80) {
    return (phaseId << PHASE_OFFSET) | roundId;
  }
}


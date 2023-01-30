/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeDecimalMath {
    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {
        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {
        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {
        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {
        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {
        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {
        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}

// solhint-disable-next-line compiler-version

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}

/**
 * @title LnAdminUpgradeable
 *
 * @dev This is an upgradeable version of `LnAdmin` by replacing the constructor with
 * an initializer and reserving storage slots.
 */
contract LnAdminUpgradeable is Initializable {
    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);

    address public admin;
    address public candidate;

    function __LnAdminUpgradeable_init(address _admin) public initializer {
        require(_admin != address(0), "LnAdminUpgradeable: zero address");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "LnAdminUpgradeable: only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "LnAdminUpgradeable: only the contract admin can perform this action");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}

// a facade for prices fetch from oracles
interface LnPrices {
    // get price for a currency
    function getPrice(bytes32 currencyName) external view returns (uint);

    // get price and updated time for a currency
    function getPriceAndUpdatedTime(bytes32 currencyName) external view returns (uint price, uint time);

    // is the price is stale
    function isStale(bytes32 currencyName) external view returns (bool);

    // the defined stale time
    function stalePeriod() external view returns (uint);

    // exchange amount of source currenty for some dest currency, also get source and dest curreny price
    function exchange(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    ) external view returns (uint);

    // exchange amount of source currenty for some dest currency
    function exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        external
        view
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        );

    // price names
    function LUSD() external view returns (bytes32);

    function LINA() external view returns (bytes32);
}

abstract contract LnBasePrices is LnPrices {
    // const name
    bytes32 public constant override LINA = "LINA";
    bytes32 public constant override LUSD = "lUSD";
}

contract LnDefaultPrices is LnAdminUpgradeable, LnBasePrices {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    address public oracle;

    uint public override stalePeriod;

    mapping(bytes32 => uint) public mPricesLastRound;

    struct PriceData {
        uint216 mPrice;
        uint40 mTime;
    }

    mapping(bytes32 => mapping(uint => PriceData)) private mPricesStorage;

    uint private constant ORACLE_TIME_LIMIT = 10 minutes;

    function __LnDefaultPrices_init(
        address _admin,
        address _oracle,
        bytes32[] memory _currencyNames,
        uint[] memory _newPrices
    ) public initializer {
        __LnAdminUpgradeable_init(_admin);

        stalePeriod = 12 hours;

        require(_currencyNames.length == _newPrices.length, "array length error.");

        oracle = _oracle;

        // The LUSD price is always 1 and is never stale.
        _setPrice(LUSD, SafeDecimalMath.unit(), now);

        _updateAll(_currencyNames, _newPrices, now);
    }

    /* interface */
    function getPrice(bytes32 currencyName) external view override returns (uint) {
        return _getPrice(currencyName);
    }

    function getPriceAndUpdatedTime(bytes32 currencyName) external view override returns (uint price, uint time) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return (priceAndTime.mPrice, priceAndTime.mTime);
    }

    function exchange(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    ) external view override returns (uint value) {
        (value, , ) = _exchangeAndPrices(sourceName, sourceAmount, destName);
    }

    function exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        external
        view
        override
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        )
    {
        return _exchangeAndPrices(sourceName, sourceAmount, destName);
    }

    function isStale(bytes32 currencyName) external view override returns (bool) {
        if (currencyName == LUSD) return false;
        return _getUpdatedTime(currencyName).add(stalePeriod) < now;
    }

    /* functions */
    function getCurrentRoundId(bytes32 currencyName) external view returns (uint) {
        return mPricesLastRound[currencyName];
    }

    function setOracle(address _oracle) external onlyAdmin {
        oracle = _oracle;
        emit OracleUpdated(oracle);
    }

    function setStalePeriod(uint _time) external onlyAdmin {
        stalePeriod = _time;
        emit StalePeriodUpdated(stalePeriod);
    }

    // 外部调用，更新汇率 oracle是一个地址，从外部用脚本定期调用这个接口
    function updateAll(
        bytes32[] calldata currencyNames,
        uint[] calldata newPrices,
        uint timeSent
    ) external onlyOracle returns (bool) {
        _updateAll(currencyNames, newPrices, timeSent);
    }

    function deletePrice(bytes32 currencyName) external onlyOracle {
        require(_getPrice(currencyName) > 0, "price is zero");

        delete mPricesStorage[currencyName][mPricesLastRound[currencyName]];

        mPricesLastRound[currencyName]--;

        emit PriceDeleted(currencyName);
    }

    function _setPrice(
        bytes32 currencyName,
        uint256 price,
        uint256 time
    ) internal {
        // start from 1
        mPricesLastRound[currencyName]++;
        mPricesStorage[currencyName][mPricesLastRound[currencyName]] = PriceData({
            mPrice: uint216(price),
            mTime: uint40(time)
        });
    }

    function _updateAll(
        bytes32[] memory currencyNames,
        uint[] memory newPrices,
        uint timeSent
    ) internal returns (bool) {
        require(currencyNames.length == newPrices.length, "array length error, not match.");
        require(timeSent < (now + ORACLE_TIME_LIMIT), "Time error");

        for (uint i = 0; i < currencyNames.length; i++) {
            bytes32 currencyName = currencyNames[i];

            require(newPrices[i] != 0, "Zero is not a valid price, please call deletePrice instead.");
            require(currencyName != LUSD, "LUSD cannot be updated.");

            if (timeSent < _getUpdatedTime(currencyName)) {
                continue;
            }

            _setPrice(currencyName, newPrices[i], timeSent);
        }

        emit PricesUpdated(currencyNames, newPrices);

        return true;
    }

    function _getPriceData(bytes32 currencyName) internal view virtual returns (PriceData memory) {
        return mPricesStorage[currencyName][mPricesLastRound[currencyName]];
    }

    function _getPrice(bytes32 currencyName) internal view returns (uint256) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return priceAndTime.mPrice;
    }

    function _getUpdatedTime(bytes32 currencyName) internal view returns (uint256) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return priceAndTime.mTime;
    }

    function _exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        internal
        view
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        )
    {
        sourcePrice = _getPrice(sourceName);
        // If there's no change in the currency, then just return the amount they gave us
        if (sourceName == destName) {
            destPrice = sourcePrice;
            value = sourceAmount;
        } else {
            // Calculate the effective value by going from source -> USD -> destination
            destPrice = _getPrice(destName);
            value = sourceAmount.multiplyDecimalRound(sourcePrice).divideDecimalRound(destPrice);
        }
    }

    /* ========== MODIFIERS ========== */
    modifier onlyOracle {
        require(msg.sender == oracle, "Only the oracle can perform this action");
        _;
    }

    /* ========== EVENTS ========== */
    event OracleUpdated(address newOracle);
    event StalePeriodUpdated(uint priceStalePeriod);
    event PricesUpdated(bytes32[] currencyNames, uint[] newPrices);
    event PriceDeleted(bytes32 currencyName);

    // Reserved storage space to allow for layout changes in the future.
    uint256[46] private __gap;
}
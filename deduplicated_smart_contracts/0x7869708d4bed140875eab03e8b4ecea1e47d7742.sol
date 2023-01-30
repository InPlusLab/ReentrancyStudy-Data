/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

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

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
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

contract LnAdmin {
    address public admin;
    address public candidate;

    constructor(address _admin) public {
        require(_admin != address(0), "admin address cannot be 0");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "Only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "Only the contract admin can perform this action");
        _;
    }

    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

interface IAsset {
    function keyName() external view returns (bytes32);
}

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
        assembly {
            size := extcodesize(account)
        }
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
        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

contract LnAddressStorage is LnAdmin {
    mapping(bytes32 => address) public mAddrs;

    constructor(address _admin) public LnAdmin(_admin) {}

    function updateAll(bytes32[] calldata names, address[] calldata destinations) external onlyAdmin {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            mAddrs[names[i]] = destinations[i];
            emit StorageAddressUpdated(names[i], destinations[i]);
        }
    }

    function update(bytes32 name, address dest) external onlyAdmin {
        require(name != "", "name can not be empty");
        require(dest != address(0), "address cannot be 0");
        mAddrs[name] = dest;
        emit StorageAddressUpdated(name, dest);
    }

    function getAddress(bytes32 name) external view returns (address) {
        return mAddrs[name];
    }

    function getAddressWithRequire(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = mAddrs[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    event StorageAddressUpdated(bytes32 name, address addr);
}

interface LnAddressCache {
    function updateAddressCache(LnAddressStorage _addressStorage) external;

    event CachedAddressUpdated(bytes32 name, address addr);
}

contract testAddressCache is LnAddressCache, LnAdmin {
    address public addr1;
    address public addr2;

    constructor(address _admin) public LnAdmin(_admin) {}

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        addr1 = LnAddressStorage(_addressStorage).getAddressWithRequire("a", "");
        addr2 = LnAddressStorage(_addressStorage).getAddressWithRequire("b", "");
        emit CachedAddressUpdated("a", addr1);
        emit CachedAddressUpdated("b", addr2);
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// example:
//LnAccessControl accessCtrl = LnAccessControl(addressStorage.getAddress("LnAccessControl"));
//require(accessCtrl.hasRole(accessCtrl.DEBT_SYSTEM(), _address), "Need debt system access role");

// contract access control
contract LnAccessControl is AccessControl {
    using Address for address;

    // -------------------------------------------------------
    // role type
    bytes32 public constant ISSUE_ASSET_ROLE = ("ISSUE_ASSET"); //keccak256
    bytes32 public constant BURN_ASSET_ROLE = ("BURN_ASSET");

    bytes32 public constant DEBT_SYSTEM = ("LnDebtSystem");

    // -------------------------------------------------------
    constructor(address admin) public {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function IsAdmin(address _address) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function SetAdmin(address _address) public returns (bool) {
        require(IsAdmin(msg.sender), "Only admin");

        _setupRole(DEFAULT_ADMIN_ROLE, _address);
    }

    // -------------------------------------------------------
    // this func need admin role. grantRole and revokeRole need admin role
    function SetRoles(
        bytes32 roleType,
        address[] calldata addresses,
        bool[] calldata setTo
    ) external {
        require(IsAdmin(msg.sender), "Only admin");

        _setRoles(roleType, addresses, setTo);
    }

    function _setRoles(
        bytes32 roleType,
        address[] calldata addresses,
        bool[] calldata setTo
    ) private {
        require(addresses.length == setTo.length, "parameter address length not eq");

        for (uint256 i = 0; i < addresses.length; i++) {
            //require(addresses[i].isContract(), "Role address need contract only");
            if (setTo[i]) {
                grantRole(roleType, addresses[i]);
            } else {
                revokeRole(roleType, addresses[i]);
            }
        }
    }

    // function SetRoles(bytes32 roleType, address[] calldata addresses, bool[] calldata setTo) public {
    //     _setRoles(roleType, addresses, setTo);
    // }

    // Issue burn
    function SetIssueAssetRole(address[] calldata issuer, bool[] calldata setTo) public {
        _setRoles(ISSUE_ASSET_ROLE, issuer, setTo);
    }

    function SetBurnAssetRole(address[] calldata burner, bool[] calldata setTo) public {
        _setRoles(BURN_ASSET_ROLE, burner, setTo);
    }

    //
    function SetDebtSystemRole(address[] calldata _address, bool[] calldata _setTo) public {
        _setRoles(DEBT_SYSTEM, _address, _setTo);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
library SafeMathUpgradeable {
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[44] private __gap;
}

/**
 * @title LnAssetUpgradeable
 *
 * @dev This is an upgradeable version of `LnAsset`.
 */
contract LnAssetUpgradeable is ERC20Upgradeable, LnAdminUpgradeable, IAsset, LnAddressCache {
    bytes32 mKeyName;
    LnAccessControl accessCtrl;

    modifier onlyIssueAssetRole(address _address) {
        require(accessCtrl.hasRole(accessCtrl.ISSUE_ASSET_ROLE(), _address), "Need issue access role");
        _;
    }
    modifier onlyBurnAssetRole(address _address) {
        require(accessCtrl.hasRole(accessCtrl.BURN_ASSET_ROLE(), _address), "Need burn access role");
        _;
    }

    function __LnAssetUpgradeable_init(
        bytes32 _key,
        string memory _name,
        string memory _symbol,
        address _admin
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __LnAdminUpgradeable_init(_admin);

        mKeyName = _key;
    }

    function keyName() external view override returns (bytes32) {
        return mKeyName;
    }

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        accessCtrl = LnAccessControl(
            _addressStorage.getAddressWithRequire("LnAccessControl", "LnAccessControl address not valid")
        );

        emit CachedAddressUpdated("LnAccessControl", address(accessCtrl));
    }

    function mint(address account, uint256 amount) external onlyIssueAssetRole(msg.sender) {
        _mint(account, amount);
    }

    function burn(address account, uint amount) external onlyBurnAssetRole(msg.sender) {
        _burn(account, amount);
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}

contract LnAssetSystem is LnAddressStorage {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    IAsset[] public mAssetList; // 合约地址数组
    mapping(address => bytes32) public mAddress2Names; // 地址到名称的映射

    constructor(address _admin) public LnAddressStorage(_admin) {}

    function addAsset(IAsset asset) external onlyAdmin {
        bytes32 name = asset.keyName();

        require(mAddrs[name] == address(0), "Asset already exists");
        require(mAddress2Names[address(asset)] == bytes32(0), "Asset address already exists");

        mAssetList.push(asset);
        mAddrs[name] = address(asset);
        mAddress2Names[address(asset)] = name;

        emit AssetAdded(name, address(asset));
    }

    function removeAsset(bytes32 name) external onlyAdmin {
        address assetToRemove = address(mAddrs[name]);

        require(assetToRemove != address(0), "asset does not exist");

        // Remove from list
        for (uint i = 0; i < mAssetList.length; i++) {
            if (address(mAssetList[i]) == assetToRemove) {
                delete mAssetList[i];
                mAssetList[i] = mAssetList[mAssetList.length - 1];
                mAssetList.pop();
                break;
            }
        }

        // And remove it from the assets mapping
        delete mAddress2Names[assetToRemove];
        delete mAddrs[name];

        emit AssetRemoved(name, assetToRemove);
    }

    function assetNumber() external view returns (uint) {
        return mAssetList.length;
    }

    // check exchange rate invalid condition ? invalid just fail.
    function totalAssetsInUsd() public view returns (uint256 rTotal) {
        require(mAddrs["LnPrices"] != address(0), "LnPrices address cannot access");
        LnPrices priceGetter = LnPrices(mAddrs["LnPrices"]); //getAddress
        for (uint256 i = 0; i < mAssetList.length; i++) {
            uint256 exchangeRate = priceGetter.getPrice(mAssetList[i].keyName());
            rTotal = rTotal.add(LnAssetUpgradeable(address(mAssetList[i])).totalSupply().multiplyDecimal(exchangeRate));
        }
    }

    function getAssetAddresses() external view returns (address[] memory) {
        address[] memory addr = new address[](mAssetList.length);
        for (uint256 i = 0; i < mAssetList.length; i++) {
            addr[i] = address(mAssetList[i]);
        }
        return addr;
    }

    event AssetAdded(bytes32 name, address asset);
    event AssetRemoved(bytes32 name, address asset);
}

contract LnConfig is LnAdmin {
    mapping(bytes32 => uint) internal mUintConfig;

    constructor(address _admin) public LnAdmin(_admin) {}

    //some configue keys
    bytes32 public constant BUILD_RATIO = "BuildRatio"; // percent, base 10e18

    function getUint(bytes32 key) external view returns (uint) {
        return mUintConfig[key];
    }

    function setUint(bytes32 key, uint value) external onlyAdmin {
        mUintConfig[key] = value;
        emit SetUintConfig(key, value);
    }

    function deleteUint(bytes32 key) external onlyAdmin {
        delete mUintConfig[key];
        emit SetUintConfig(key, 0);
    }

    function batchSet(bytes32[] calldata names, uint[] calldata values) external onlyAdmin {
        require(names.length == values.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            mUintConfig[names[i]] = values[i];
            emit SetUintConfig(names[i], values[i]);
        }
    }

    event SetUintConfig(bytes32 key, uint value);
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        assembly {
            size := extcodesize(account)
        }
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
        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 根据 LnCollateralSystem 的抵押资产计算相关抵押率，buildable lusd
contract LnBuildBurnSystem is LnAdmin, Pausable, LnAddressCache {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Address for address;

    // -------------------------------------------------------
    // need set before system running value.
    LnAssetUpgradeable private lUSDToken; // this contract need

    LnDebtSystem private debtSystem;
    LnAssetSystem private assetSys;
    LnPrices private priceGetter;
    LnCollateralSystem private collaterSys;
    LnConfig private mConfig;

    // -------------------------------------------------------
    constructor(address admin, address _lUSDTokenAddr) public LnAdmin(admin) {
        lUSDToken = LnAssetUpgradeable(_lUSDTokenAddr);
    }

    function setPaused(bool _paused) external onlyAdmin {
        if (_paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        priceGetter = LnPrices(_addressStorage.getAddressWithRequire("LnPrices", "LnPrices address not valid"));
        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        assetSys = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));
        address payable collateralAddress =
            payable(_addressStorage.getAddressWithRequire("LnCollateralSystem", "LnCollateralSystem address not valid"));
        collaterSys = LnCollateralSystem(collateralAddress);
        mConfig = LnConfig(_addressStorage.getAddressWithRequire("LnConfig", "LnConfig address not valid"));

        emit CachedAddressUpdated("LnPrices", address(priceGetter));
        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnAssetSystem", address(assetSys));
        emit CachedAddressUpdated("LnCollateralSystem", address(collaterSys));
        emit CachedAddressUpdated("LnConfig", address(mConfig));
    }

    function SetLusdTokenAddress(address _address) public onlyAdmin {
        emit UpdateLusdToken(address(lUSDToken), _address);
        lUSDToken = LnAssetUpgradeable(_address);
    }

    event UpdateLusdToken(address oldAddr, address newAddr);

    function MaxCanBuildAsset(address user) public view returns (uint256) {
        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 maxCanBuild = collaterSys.MaxRedeemableInUsd(user).mul(buildRatio).div(SafeDecimalMath.unit());
        return maxCanBuild;
    }

    // build lusd
    function BuildAsset(uint256 amount) public whenNotPaused returns (bool) {
        address user = msg.sender;
        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 maxCanBuild = collaterSys.MaxRedeemableInUsd(user).multiplyDecimal(buildRatio);
        require(amount <= maxCanBuild, "Build amount too big, you need more collateral");

        // calc debt
        (uint256 oldUserDebtBalance, uint256 totalAssetSupplyInUsd) = debtSystem.GetUserDebtBalanceInUsd(user);

        uint256 newTotalAssetSupply = totalAssetSupplyInUsd.add(amount);
        // update debt data
        uint256 buildDebtProportion = amount.divideDecimalRoundPrecise(newTotalAssetSupply); // debtPercentage
        uint oldTotalProportion = SafeDecimalMath.preciseUnit().sub(buildDebtProportion); //

        uint256 newUserDebtProportion = buildDebtProportion;
        if (oldUserDebtBalance > 0) {
            newUserDebtProportion = oldUserDebtBalance.add(amount).divideDecimalRoundPrecise(newTotalAssetSupply);
        }

        // update debt
        debtSystem.UpdateDebt(user, newUserDebtProportion, oldTotalProportion);

        // mint asset
        lUSDToken.mint(user, amount);

        return true;
    }

    function BuildMaxAsset() external whenNotPaused {
        address user = msg.sender;
        uint256 max = MaxCanBuildAsset(user);
        BuildAsset(max);
    }

    function _burnAsset(address user, uint256 amount) internal {
        //uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        require(amount > 0, "amount need > 0");
        // calc debt
        (uint256 oldUserDebtBalance, uint256 totalAssetSupplyInUsd) = debtSystem.GetUserDebtBalanceInUsd(user);
        require(oldUserDebtBalance > 0, "no debt, no burn");
        uint256 burnAmount = oldUserDebtBalance < amount ? oldUserDebtBalance : amount;
        // burn asset
        lUSDToken.burn(user, burnAmount);

        uint newTotalDebtIssued = totalAssetSupplyInUsd.sub(burnAmount);

        uint oldTotalProportion = 0;
        if (newTotalDebtIssued > 0) {
            uint debtPercentage = burnAmount.divideDecimalRoundPrecise(newTotalDebtIssued);
            oldTotalProportion = SafeDecimalMath.preciseUnit().add(debtPercentage);
        }

        uint256 newUserDebtProportion = 0;
        if (oldUserDebtBalance > burnAmount) {
            uint newDebt = oldUserDebtBalance.sub(burnAmount);
            newUserDebtProportion = newDebt.divideDecimalRoundPrecise(newTotalDebtIssued);
        }

        // update debt
        debtSystem.UpdateDebt(user, newUserDebtProportion, oldTotalProportion);
    }

    // burn
    function BurnAsset(uint256 amount) external whenNotPaused returns (bool) {
        address user = msg.sender;
        _burnAsset(user, amount);
        return true;
    }

    //所有
    // function MaxAssetToTarget(address user) external view returns(uint256) {
    //     uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
    //     uint256 totalCollateral = collaterSys.GetUserTotalCollateralInUsd(user);
    // }

    // burn to target ratio
    function BurnAssetToTarget() external whenNotPaused returns (bool) {
        address user = msg.sender;

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 totalCollateral = collaterSys.GetUserTotalCollateralInUsd(user);
        uint256 maxBuildAssetToTarget = totalCollateral.multiplyDecimal(buildRatio);
        (uint256 debtAsset, ) = debtSystem.GetUserDebtBalanceInUsd(user);
        require(debtAsset > maxBuildAssetToTarget, "You maybe want build to target");

        uint256 needBurn = debtAsset.sub(maxBuildAssetToTarget);
        uint balance = lUSDToken.balanceOf(user); // burn as many as possible
        if (balance < needBurn) {
            needBurn = balance;
        }
        _burnAsset(user, needBurn);
        return true;
    }
}

// Reward Distributor
contract LnRewardLocker is LnAdminUpgradeable {
    using SafeMath for uint256;

    struct RewardData {
        uint64 lockToTime;
        uint256 amount;
    }

    mapping(address => RewardData[]) public userRewards; // RewardData[0] is claimable
    mapping(address => uint256) public balanceOf;
    uint256 public totalNeedToReward;

    uint256 public constant maxRewardArrayLen = 100;

    address feeSysAddr;
    IERC20 public linaToken;

    function __LnRewardLocker_init(address _admin, address linaAddress) public initializer {
        __LnAdminUpgradeable_init(_admin);

        linaToken = IERC20(linaAddress);
    }

    function setLinaAddress(address _token) external onlyAdmin {
        linaToken = IERC20(_token);
    }

    function Init(address _feeSysAddr) external onlyAdmin {
        feeSysAddr = _feeSysAddr;
    }

    modifier onlyFeeSys() {
        require((msg.sender == feeSysAddr), "Only Fee System call");
        _;
    }

    function appendReward(
        address _user,
        uint256 _amount,
        uint64 _lockTo
    ) external onlyFeeSys {
        if (userRewards[_user].length >= maxRewardArrayLen) {
            Slimming(_user);
        }

        require(userRewards[_user].length <= maxRewardArrayLen, "user array out of");
        // init cliamable
        if (userRewards[_user].length == 0) {
            RewardData memory data = RewardData({lockToTime: 0, amount: 0});
            userRewards[_user].push(data);
        }

        // append new reward
        RewardData memory data = RewardData({lockToTime: _lockTo, amount: _amount});
        userRewards[_user].push(data);

        balanceOf[_user] = balanceOf[_user].add(_amount);
        totalNeedToReward = totalNeedToReward.add(_amount);

        emit AppendReward(_user, _amount, _lockTo);
    }

    // move claimable to RewardData[0]
    function Slimming(address _user) public {
        require(userRewards[_user].length > 1, "not data to slimming");
        RewardData storage claimable = userRewards[_user][0];
        for (uint256 i = 1; i < userRewards[_user].length; ) {
            if (now >= userRewards[_user][i].lockToTime) {
                claimable.amount = claimable.amount.add(userRewards[_user][i].amount);

                //swap last to current position
                uint256 len = userRewards[_user].length;
                userRewards[_user][i].lockToTime = userRewards[_user][len - 1].lockToTime;
                userRewards[_user][i].amount = userRewards[_user][len - 1].amount;
                userRewards[_user].pop(); // delete last one
            } else {
                i++;
            }
        }
    }

    // if lock lina is collateral, claimable need calc to fix target ratio
    function ClaimMaxable() public {
        address user = msg.sender;
        Slimming(user);
        _claim(user, userRewards[user][0].amount);
    }

    function _claim(address _user, uint256 _amount) internal {
        userRewards[_user][0].amount = userRewards[_user][0].amount.sub(_amount);

        balanceOf[_user] = balanceOf[_user].sub(_amount);
        totalNeedToReward = totalNeedToReward.sub(_amount);

        linaToken.transfer(_user, _amount);
        emit ClaimLog(_user, _amount);
    }

    function Claim(uint256 _amount) public {
        address user = msg.sender;
        Slimming(user);
        require(_amount <= userRewards[user][0].amount, "Claim amount invalid");
        _claim(user, _amount);
    }

    event AppendReward(address user, uint256 amount, uint64 lockTo);
    event ClaimLog(address user, uint256 amount);

    // Reserved storage space to allow for layout changes in the future.
    uint256[45] private __gap;
}

// 单纯抵押进来
// 赎回时需要 债务率良好才能赎回， 赎回部分能保持债务率高于目标债务率
contract LnCollateralSystem is LnAdminUpgradeable, PausableUpgradeable, LnAddressCache {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using AddressUpgradeable for address;

    // -------------------------------------------------------
    // need set before system running value.
    LnPrices public priceGetter;
    LnDebtSystem public debtSystem;
    LnBuildBurnSystem public buildBurnSystem;
    LnConfig public mConfig;
    LnRewardLocker public mRewardLocker;

    bytes32 public constant Currency_ETH = "ETH";
    bytes32 public constant Currency_LINA = "LINA";

    // -------------------------------------------------------
    uint256 public uniqueId; // use log

    struct TokenInfo {
        address tokenAddr;
        uint256 minCollateral; // min collateral amount.
        uint256 totalCollateral;
        bool bClose; // TODO : 为了防止价格波动，另外再加个折扣价?
    }

    mapping(bytes32 => TokenInfo) public tokenInfos;
    bytes32[] public tokenSymbol; // keys of tokenInfos, use to iteration

    struct CollateralData {
        uint256 collateral; // total collateral
    }

    // [user] => ([token=> collateraldata])
    mapping(address => mapping(bytes32 => CollateralData)) public userCollateralData;

    // -------------------------------------------------------
    function __LnCollateralSystem_init(address _admin) public initializer {
        __LnAdminUpgradeable_init(_admin);
    }

    function setPaused(bool _paused) external onlyAdmin {
        if (_paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    // ------------------ system config ----------------------
    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        priceGetter = LnPrices(_addressStorage.getAddressWithRequire("LnPrices", "LnPrices address not valid"));
        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        buildBurnSystem = LnBuildBurnSystem(
            _addressStorage.getAddressWithRequire("LnBuildBurnSystem", "LnBuildBurnSystem address not valid")
        );
        mConfig = LnConfig(_addressStorage.getAddressWithRequire("LnConfig", "LnConfig address not valid"));
        mRewardLocker = LnRewardLocker(
            _addressStorage.getAddressWithRequire("LnRewardLocker", "LnRewardLocker address not valid")
        );

        emit CachedAddressUpdated("LnPrices", address(priceGetter));
        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnBuildBurnSystem", address(buildBurnSystem));
        emit CachedAddressUpdated("LnConfig", address(mConfig));
        emit CachedAddressUpdated("LnRewardLocker", address(mRewardLocker));
    }

    function updateTokenInfo(
        bytes32 _currency,
        address _tokenAddr,
        uint256 _minCollateral,
        bool _close
    ) private returns (bool) {
        require(_currency[0] != 0, "symbol cannot empty");
        require(_currency != Currency_ETH, "ETH is used by system");
        require(_tokenAddr != address(0), "token address cannot zero");
        require(_tokenAddr.isContract(), "token address is not a contract");

        if (tokenInfos[_currency].tokenAddr == address(0)) {
            // new token
            tokenSymbol.push(_currency);
        }

        uint256 totalCollateral = tokenInfos[_currency].totalCollateral;
        tokenInfos[_currency] = TokenInfo({
            tokenAddr: _tokenAddr,
            minCollateral: _minCollateral,
            totalCollateral: totalCollateral,
            bClose: _close
        });
        emit UpdateTokenSetting(_currency, _tokenAddr, _minCollateral, _close);
        return true;
    }

    // delete token info? need to handle it's staking data.

    function UpdateTokenInfo(
        bytes32 _currency,
        address _tokenAddr,
        uint256 _minCollateral,
        bool _close
    ) external onlyAdmin returns (bool) {
        return updateTokenInfo(_currency, _tokenAddr, _minCollateral, _close);
    }

    function UpdateTokenInfos(
        bytes32[] calldata _symbols,
        address[] calldata _tokenAddrs,
        uint256[] calldata _minCollateral,
        bool[] calldata _closes
    ) external onlyAdmin returns (bool) {
        require(_symbols.length == _tokenAddrs.length, "length of array not eq");
        require(_symbols.length == _minCollateral.length, "length of array not eq");
        require(_symbols.length == _closes.length, "length of array not eq");

        for (uint256 i = 0; i < _symbols.length; i++) {
            updateTokenInfo(_symbols[i], _tokenAddrs[i], _minCollateral[i], _closes[i]);
        }

        return true;
    }

    // ------------------------------------------------------------------------
    function GetSystemTotalCollateralInUsd() public view returns (uint256 rTotal) {
        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            if (tokenInfos[currency].totalCollateral > 0) {
                // this check for avoid calling getPrice when collateral is zero
                if (Currency_LINA == currency) {
                    uint256 totallina = tokenInfos[currency].totalCollateral.add(mRewardLocker.totalNeedToReward());
                    rTotal = rTotal.add(totallina.multiplyDecimal(priceGetter.getPrice(currency)));
                } else {
                    rTotal = rTotal.add(
                        tokenInfos[currency].totalCollateral.multiplyDecimal(priceGetter.getPrice(currency))
                    );
                }
            }
        }

        if (address(this).balance > 0) {
            rTotal = rTotal.add(address(this).balance.multiplyDecimal(priceGetter.getPrice(Currency_ETH)));
        }
    }

    function GetUserTotalCollateralInUsd(address _user) public view returns (uint256 rTotal) {
        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            if (userCollateralData[_user][currency].collateral > 0) {
                if (Currency_LINA == currency) {
                    uint256 totallina = userCollateralData[_user][currency].collateral.add(mRewardLocker.balanceOf(_user));
                    rTotal = rTotal.add(totallina.multiplyDecimal(priceGetter.getPrice(currency)));
                } else {
                    rTotal = rTotal.add(
                        userCollateralData[_user][currency].collateral.multiplyDecimal(priceGetter.getPrice(currency))
                    );
                }
            }
        }

        if (userCollateralData[_user][Currency_ETH].collateral > 0) {
            rTotal = rTotal.add(
                userCollateralData[_user][Currency_ETH].collateral.multiplyDecimal(priceGetter.getPrice(Currency_ETH))
            );
        }
    }

    function GetUserCollateral(address _user, bytes32 _currency) external view returns (uint256) {
        if (Currency_LINA != _currency) {
            return userCollateralData[_user][_currency].collateral;
        }
        return mRewardLocker.balanceOf(_user).add(userCollateralData[_user][_currency].collateral);
    }

    // NOTE: LINA collateral not include reward in locker
    function GetUserCollaterals(address _user) external view returns (bytes32[] memory, uint256[] memory) {
        bytes32[] memory rCurrency = new bytes32[](tokenSymbol.length + 1);
        uint256[] memory rAmount = new uint256[](tokenSymbol.length + 1);
        uint256 retSize = 0;
        for (uint256 i = 0; i < tokenSymbol.length; i++) {
            bytes32 currency = tokenSymbol[i];
            if (userCollateralData[_user][currency].collateral > 0) {
                rCurrency[retSize] = currency;
                rAmount[retSize] = userCollateralData[_user][currency].collateral;
                retSize++;
            }
        }
        if (userCollateralData[_user][Currency_ETH].collateral > 0) {
            rCurrency[retSize] = Currency_ETH;
            rAmount[retSize] = userCollateralData[_user][Currency_ETH].collateral;
            retSize++;
        }

        return (rCurrency, rAmount);
    }

    // need approve
    function Collateral(bytes32 _currency, uint256 _amount) external whenNotPaused returns (bool) {
        require(tokenInfos[_currency].tokenAddr.isContract(), "Invalid token symbol");
        TokenInfo storage tokeninfo = tokenInfos[_currency];
        require(_amount > tokeninfo.minCollateral, "Collateral amount too small");
        require(tokeninfo.bClose == false, "This token is closed");

        address user = msg.sender;

        IERC20 erc20 = IERC20(tokenInfos[_currency].tokenAddr);
        require(erc20.balanceOf(user) >= _amount, "insufficient balance");
        require(erc20.allowance(user, address(this)) >= _amount, "insufficient allowance, need approve more amount");

        erc20.transferFrom(user, address(this), _amount);

        userCollateralData[user][_currency].collateral = userCollateralData[user][_currency].collateral.add(_amount);
        tokeninfo.totalCollateral = tokeninfo.totalCollateral.add(_amount);

        emit CollateralLog(user, _currency, _amount, userCollateralData[user][_currency].collateral);
        return true;
    }

    function IsSatisfyTargetRatio(address _user) public view returns (bool) {
        (uint256 debtBalance, ) = debtSystem.GetUserDebtBalanceInUsd(_user);
        if (debtBalance == 0) {
            return true;
        }

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 totalCollateralInUsd = GetUserTotalCollateralInUsd(_user);
        if (totalCollateralInUsd == 0) {
            return false;
        }
        uint256 myratio = debtBalance.divideDecimal(totalCollateralInUsd);
        return myratio <= buildRatio;
    }

    // 满足最低抵押率的情况下可最大赎回的资产 TODO: return multi value
    function MaxRedeemableInUsd(address _user) public view returns (uint256) {
        uint256 totalCollateralInUsd = GetUserTotalCollateralInUsd(_user);

        (uint256 debtBalance, ) = debtSystem.GetUserDebtBalanceInUsd(_user);
        if (debtBalance == 0) {
            return totalCollateralInUsd;
        }

        uint256 buildRatio = mConfig.getUint(mConfig.BUILD_RATIO());
        uint256 minCollateral = debtBalance.divideDecimal(buildRatio);
        if (totalCollateralInUsd < minCollateral) {
            return 0;
        }

        return totalCollateralInUsd.sub(minCollateral);
    }

    function MaxRedeemable(address user, bytes32 _currency) public view returns (uint256) {
        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);
        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(_currency));
        if (maxRedeem > userCollateralData[user][_currency].collateral) {
            maxRedeem = userCollateralData[user][_currency].collateral;
        }
        if (Currency_LINA != _currency) {
            return maxRedeem;
        }
        uint256 lockedLina = mRewardLocker.balanceOf(user);
        if (maxRedeem <= lockedLina) {
            return 0;
        }
        return maxRedeem.sub(lockedLina);
    }

    function RedeemMax(bytes32 _currency) external whenNotPaused {
        address user = msg.sender;
        uint256 maxRedeem = MaxRedeemable(user, _currency);
        _Redeem(user, _currency, maxRedeem);
    }

    function _Redeem(
        address user,
        bytes32 _currency,
        uint256 _amount
    ) internal {
        require(_amount <= userCollateralData[user][_currency].collateral, "Can not redeem more than collateral");
        require(_amount > 0, "Redeem amount need larger than zero");

        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);
        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(_currency));
        require(_amount <= maxRedeem, "Because lower collateral ratio, can not redeem too much");

        userCollateralData[user][_currency].collateral = userCollateralData[user][_currency].collateral.sub(_amount);

        TokenInfo storage tokeninfo = tokenInfos[_currency];
        tokeninfo.totalCollateral = tokeninfo.totalCollateral.sub(_amount);

        IERC20(tokenInfos[_currency].tokenAddr).transfer(user, _amount);

        emit RedeemCollateral(user, _currency, _amount, userCollateralData[user][_currency].collateral);
    }

    // 1. After redeem, collateral ratio need bigger than target ratio.
    // 2. Cannot redeem more than collateral.
    function Redeem(bytes32 _currency, uint256 _amount) public whenNotPaused returns (bool) {
        address user = msg.sender;
        _Redeem(user, _currency, _amount);
        return true;
    }

    receive() external payable whenNotPaused {
        address user = msg.sender;
        uint256 ethAmount = msg.value;
        _CollateralEth(user, ethAmount);
    }

    function _CollateralEth(address user, uint256 ethAmount) internal {
        require(ethAmount > 0, "ETH amount need more than zero");

        userCollateralData[user][Currency_ETH].collateral = userCollateralData[user][Currency_ETH].collateral.add(ethAmount);

        emit CollateralLog(user, Currency_ETH, ethAmount, userCollateralData[user][Currency_ETH].collateral);
    }

    // payable eth receive,
    function CollateralEth() external payable whenNotPaused returns (bool) {
        address user = msg.sender;
        uint256 ethAmount = msg.value;
        _CollateralEth(user, ethAmount);
        return true;
    }

    function RedeemETH(uint256 _amount) external whenNotPaused returns (bool) {
        address payable user = msg.sender;
        require(_amount <= userCollateralData[user][Currency_ETH].collateral, "Can not redeem more than collateral");
        require(_amount > 0, "Redeem amount need larger than zero");

        uint256 maxRedeemableInUsd = MaxRedeemableInUsd(user);

        uint256 maxRedeem = maxRedeemableInUsd.divideDecimal(priceGetter.getPrice(Currency_ETH));
        require(_amount <= maxRedeem, "Because lower collateral ratio, can not redeem too much");

        userCollateralData[user][Currency_ETH].collateral = userCollateralData[user][Currency_ETH].collateral.sub(_amount);
        user.transfer(_amount);

        emit RedeemCollateral(user, Currency_ETH, _amount, userCollateralData[user][Currency_ETH].collateral);
        return true;
    }

    event UpdateTokenSetting(bytes32 symbol, address tokenAddr, uint256 minCollateral, bool close);
    event CollateralLog(address user, bytes32 _currency, uint256 _amount, uint256 _userTotal);
    event RedeemCollateral(address user, bytes32 _currency, uint256 _amount, uint256 _userTotal);

    // Reserved storage space to allow for layout changes in the future.
    uint256[41] private __gap;
}

contract LnFeeSystem is LnAdminUpgradeable, LnAddressCache {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    address public constant FEE_DUMMY_ADDRESS = address(0x2048);

    struct UserDebtData {
        uint256 PeriodID; // Period id
        uint256 debtProportion;
        uint256 debtFactor; // PRECISE_UNIT
    }

    struct RewardPeriod {
        uint256 id; // Period id
        uint256 startingDebtFactor;
        uint256 startTime;
        uint256 feesToDistribute; // 要分配的费用
        uint256 feesClaimed; // 已领取的费用
        uint256 rewardsToDistribute; // 要分配的奖励
        uint256 rewardsClaimed; // 已领取的奖励
    }

    RewardPeriod public curRewardPeriod;
    RewardPeriod public preRewardPeriod;
    uint256 public OnePeriodSecs;
    uint64 public LockTime;

    mapping(address => uint256) public userLastClaimedId;

    mapping(address => UserDebtData[2]) public userPeriodDebt; // one for current period, one for pre period

    //
    LnDebtSystem public debtSystem;
    LnCollateralSystem public collateralSystem;
    LnRewardLocker public rewardLocker;
    LnAssetSystem mAssets;

    address public exchangeSystemAddress;
    address public rewardDistributer;

    function __LnFeeSystem_init(address _admin) public initializer {
        __LnAdminUpgradeable_init(_admin);

        OnePeriodSecs = 1 weeks;
        LockTime = uint64(52 weeks);
    }

    // Note: before start run need call this func to init.
    function Init(address _exchangeSystem, address _rewardDistri) public onlyAdmin {
        exchangeSystemAddress = _exchangeSystem;
        rewardDistributer = _rewardDistri;
    }

    //set period data, maybe copy from old contract
    function SetPeriodData(
        int16 index, // 0 current 1 pre
        uint256 id,
        uint256 startingDebtFactor,
        uint256 startTime,
        uint256 feesToDistribute,
        uint256 feesClaimed,
        uint256 rewardsToDistribute,
        uint256 rewardsClaimed
    ) public onlyAdmin {
        RewardPeriod storage toset = index == 0 ? curRewardPeriod : preRewardPeriod;
        toset.id = id;
        toset.startingDebtFactor = startingDebtFactor;
        toset.startTime = startTime;
        toset.feesToDistribute = feesToDistribute;
        toset.feesClaimed = feesClaimed;
        toset.rewardsToDistribute = rewardsToDistribute;
        toset.rewardsClaimed = rewardsClaimed;
    }

    function setExchangeSystemAddress(address _address) public onlyAdmin {
        exchangeSystemAddress = _address;
    }

    modifier onlyExchanger {
        require((msg.sender == exchangeSystemAddress), "Only Exchange System call");
        _;
    }

    modifier onlyDistributer {
        require((msg.sender == rewardDistributer), "Only Reward Distributer call");
        _;
    }

    function addExchangeFee(uint feeUsd) public onlyExchanger {
        curRewardPeriod.feesToDistribute = curRewardPeriod.feesToDistribute.add(feeUsd);
        emit ExchangeFee(feeUsd);
    }

    // TODO: call by contract or auto distribute?
    function addCollateralRewards(uint reward) public onlyDistributer {
        curRewardPeriod.rewardsToDistribute = curRewardPeriod.rewardsToDistribute.add(reward);
        emit RewardCollateral(reward);
    }

    event ExchangeFee(uint feeUsd);
    event RewardCollateral(uint reward);
    event FeesClaimed(address user, uint lUSDAmount, uint linaRewards);

    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        debtSystem = LnDebtSystem(_addressStorage.getAddressWithRequire("LnDebtSystem", "LnDebtSystem address not valid"));
        address payable collateralAddress =
            payable(_addressStorage.getAddressWithRequire("LnCollateralSystem", "LnCollateralSystem address not valid"));
        collateralSystem = LnCollateralSystem(collateralAddress);
        rewardLocker = LnRewardLocker(
            _addressStorage.getAddressWithRequire("LnRewardLocker", "LnRewardLocker address not valid")
        );
        mAssets = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));

        // as Init func. record LnExchangeSystem address
        exchangeSystemAddress = _addressStorage.getAddressWithRequire(
            "LnExchangeSystem",
            "LnExchangeSystem address not valid"
        );

        emit CachedAddressUpdated("LnDebtSystem", address(debtSystem));
        emit CachedAddressUpdated("LnCollateralSystem", address(collateralSystem));
        emit CachedAddressUpdated("LnRewardLocker", address(rewardLocker));
        emit CachedAddressUpdated("LnAssetSystem", address(mAssets));
        emit CachedAddressUpdated("LnExchangeSystem", address(exchangeSystemAddress));
    }

    function switchPeriod() public {
        require(now >= curRewardPeriod.startTime + OnePeriodSecs, "It's not time to switch");

        preRewardPeriod.id = curRewardPeriod.id;
        preRewardPeriod.startingDebtFactor = curRewardPeriod.startingDebtFactor;
        preRewardPeriod.startTime = curRewardPeriod.startTime;
        preRewardPeriod.feesToDistribute = curRewardPeriod.feesToDistribute.add(
            preRewardPeriod.feesToDistribute.sub(preRewardPeriod.feesClaimed)
        );
        preRewardPeriod.feesClaimed = 0;
        preRewardPeriod.rewardsToDistribute = curRewardPeriod.rewardsToDistribute.add(
            preRewardPeriod.rewardsToDistribute.sub(preRewardPeriod.rewardsClaimed)
        );
        preRewardPeriod.rewardsClaimed = 0;

        curRewardPeriod.id = curRewardPeriod.id + 1;
        curRewardPeriod.startingDebtFactor = debtSystem.LastSystemDebtFactor();
        curRewardPeriod.startTime = now;
        curRewardPeriod.feesToDistribute = 0;
        curRewardPeriod.feesClaimed = 0;
        curRewardPeriod.rewardsToDistribute = 0;
        curRewardPeriod.rewardsClaimed = 0;
    }

    function feePeriodDuration() external view returns (uint) {
        return OnePeriodSecs;
    }

    function recentFeePeriods(uint index)
        external
        view
        returns (
            uint256 id,
            uint256 startingDebtFactor,
            uint256 startTime,
            uint256 feesToDistribute,
            uint256 feesClaimed,
            uint256 rewardsToDistribute,
            uint256 rewardsClaimed
        )
    {
        if (index > 1) {
            return (0, 0, 0, 0, 0, 0, 0);
        }
        RewardPeriod memory rewardPd;
        if (index == 0) {
            rewardPd = curRewardPeriod;
        } else {
            rewardPd = preRewardPeriod;
        }
        return (
            rewardPd.id,
            rewardPd.startingDebtFactor,
            rewardPd.startTime,
            rewardPd.feesToDistribute,
            rewardPd.feesClaimed,
            rewardPd.rewardsToDistribute,
            rewardPd.rewardsClaimed
        );
    }

    modifier onlyDebtSystem() {
        require(msg.sender == address(debtSystem), "Only Debt system call");
        _;
    }

    // build record
    function RecordUserDebt(
        address user,
        uint256 debtProportion,
        uint256 debtFactor
    ) public onlyDebtSystem {
        uint256 curId = curRewardPeriod.id;
        uint256 minPos = 0;
        if (userPeriodDebt[user][0].PeriodID > userPeriodDebt[user][1].PeriodID) {
            minPos = 1;
        }
        uint256 pos = minPos;
        for (uint64 i = 0; i < userPeriodDebt[user].length; i++) {
            if (userPeriodDebt[user][i].PeriodID == curId) {
                pos = i;
                break;
            }
        }
        userPeriodDebt[user][pos].PeriodID = curId;
        userPeriodDebt[user][pos].debtProportion = debtProportion;
        userPeriodDebt[user][pos].debtFactor = debtFactor;
    }

    function isFeesClaimable(address account) public view returns (bool feesClaimable) {
        if (collateralSystem.IsSatisfyTargetRatio(account) == false) {
            return false;
        }

        if (userLastClaimedId[account] == preRewardPeriod.id) {
            return false;
        }

        // TODO: other condition?
        return true;
    }

    // total fee and total reward
    function feesAvailable(address user) public view returns (uint, uint) {
        if (preRewardPeriod.feesToDistribute == 0 && preRewardPeriod.rewardsToDistribute == 0) {
            return (0, 0);
        }
        uint256 debtFactor = 0;
        uint256 debtProportion = 0;
        uint256 pid = 0; //get last period factor
        for (uint64 i = 0; i < userPeriodDebt[user].length; i++) {
            if (userPeriodDebt[user][i].PeriodID < curRewardPeriod.id && userPeriodDebt[user][i].PeriodID > pid) {
                pid = curRewardPeriod.id;
                debtFactor = userPeriodDebt[user][i].debtFactor;
                debtProportion = userPeriodDebt[user][i].debtProportion;
            }
        }
        //
        //if (debtProportion == 0) {
        //    (debtProportion, debtFactor) = debtSystem.userDebtState(user);
        //}

        if (debtProportion == 0) {
            return (0, 0);
        }

        uint256 lastPeriodDebtFactor = curRewardPeriod.startingDebtFactor;
        uint256 userDebtProportion =
            lastPeriodDebtFactor.divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);

        uint256 fee =
            preRewardPeriod
                .feesToDistribute
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(userDebtProportion)
                .preciseDecimalToDecimal();

        uint256 reward =
            preRewardPeriod
                .rewardsToDistribute
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(userDebtProportion)
                .preciseDecimalToDecimal();
        return (fee, reward);
    }

    // claim fee and reward.
    function claimFees() external returns (bool) {
        address user = msg.sender;
        require(isFeesClaimable(user), "User is not claimable");

        userLastClaimedId[user] = preRewardPeriod.id;
        // fee reward: mint lusd
        // : rewardLocker.appendReward(use, reward, now + 1 years);
        (uint256 fee, uint256 reward) = feesAvailable(user);
        require(fee > 0 || reward > 0, "Nothing to claim");

        if (fee > 0) {
            LnAssetUpgradeable lusd =
                LnAssetUpgradeable(mAssets.getAddressWithRequire("lUSD", "get lUSD asset address fail"));
            lusd.burn(FEE_DUMMY_ADDRESS, fee);
            lusd.mint(user, fee);
        }

        if (reward > 0) {
            uint64 totime = uint64(now + LockTime);
            rewardLocker.appendReward(user, reward, totime);
        }
        emit FeesClaimed(user, fee, reward);
        return true;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[38] private __gap;
}

contract LnFeeSystemTest is LnFeeSystem {
    function __LnFeeSystemTest_init(address _admin) public initializer {
        __LnFeeSystem_init(_admin);

        OnePeriodSecs = 6 hours;
        LockTime = 1 hours;
    }
}

contract LnDebtSystem is LnAdminUpgradeable, LnAddressCache {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Address for address;

    // -------------------------------------------------------
    // need set before system running value.
    LnAccessControl private accessCtrl;
    LnAssetSystem private assetSys;
    LnFeeSystem public feeSystem;
    // -------------------------------------------------------
    struct DebtData {
        uint256 debtProportion;
        uint256 debtFactor; // PRECISE_UNIT
    }
    mapping(address => DebtData) public userDebtState;

    //use mapping to store array data
    mapping(uint256 => uint256) public lastDebtFactors; // PRECISE_UNIT Note: 能直接记 factor 的记 factor, 不能记的就用index查
    uint256 public debtCurrentIndex; // length of array. this index of array no value
    // follow var use to manage array size.
    uint256 public lastCloseAt; // close at array index
    uint256 public lastDeletTo; // delete to array index, lastDeletTo < lastCloseAt
    uint256 public constant MAX_DEL_PER_TIME = 50;

    //

    // -------------------------------------------------------
    function __LnDebtSystem_init(address _admin) public initializer {
        __LnAdminUpgradeable_init(_admin);
    }

    event UpdateAddressStorage(address oldAddr, address newAddr);
    event UpdateUserDebtLog(address addr, uint256 debtProportion, uint256 debtFactor);
    event PushDebtLog(uint256 index, uint256 newFactor);

    // ------------------ system config ----------------------
    function updateAddressCache(LnAddressStorage _addressStorage) public override onlyAdmin {
        accessCtrl = LnAccessControl(
            _addressStorage.getAddressWithRequire("LnAccessControl", "LnAccessControl address not valid")
        );
        assetSys = LnAssetSystem(_addressStorage.getAddressWithRequire("LnAssetSystem", "LnAssetSystem address not valid"));
        feeSystem = LnFeeSystem(_addressStorage.getAddressWithRequire("LnFeeSystem", "LnFeeSystem address not valid"));

        emit CachedAddressUpdated("LnAccessControl", address(accessCtrl));
        emit CachedAddressUpdated("LnAssetSystem", address(assetSys));
        emit CachedAddressUpdated("LnFeeSystem", address(feeSystem));
    }

    // -----------------------------------------------
    modifier OnlyDebtSystemRole(address _address) {
        require(accessCtrl.hasRole(accessCtrl.DEBT_SYSTEM(), _address), "Need debt system access role");
        _;
    }

    function SetLastCloseFeePeriodAt(uint256 index) external OnlyDebtSystemRole(msg.sender) {
        require(index >= lastCloseAt, "Close index can not return to pass");
        require(index <= debtCurrentIndex, "Can not close at future index");
        lastCloseAt = index;
    }

    function _pushDebtFactor(uint256 _factor) private {
        if (debtCurrentIndex == 0 || lastDebtFactors[debtCurrentIndex - 1] == 0) {
            // init or all debt has be cleared, new set value will be one unit
            lastDebtFactors[debtCurrentIndex] = SafeDecimalMath.preciseUnit();
        } else {
            lastDebtFactors[debtCurrentIndex] = lastDebtFactors[debtCurrentIndex - 1].multiplyDecimalRoundPrecise(_factor);
        }
        emit PushDebtLog(debtCurrentIndex, lastDebtFactors[debtCurrentIndex]);

        debtCurrentIndex = debtCurrentIndex.add(1);

        // delete out of date data
        if (lastDeletTo < lastCloseAt) {
            // safe check
            uint256 delNum = lastCloseAt - lastDeletTo;
            delNum = (delNum > MAX_DEL_PER_TIME) ? MAX_DEL_PER_TIME : delNum; // not delete all in one call, for saving someone fee.
            for (uint256 i = lastDeletTo; i < delNum; i++) {
                delete lastDebtFactors[i];
            }
            lastDeletTo = lastDeletTo.add(delNum);
        }
    }

    function PushDebtFactor(uint256 _factor) external OnlyDebtSystemRole(msg.sender) {
        _pushDebtFactor(_factor);
    }

    function _updateUserDebt(address _user, uint256 _debtProportion) private {
        userDebtState[_user].debtProportion = _debtProportion;
        userDebtState[_user].debtFactor = _lastSystemDebtFactor();
        emit UpdateUserDebtLog(_user, _debtProportion, userDebtState[_user].debtFactor);

        feeSystem.RecordUserDebt(_user, userDebtState[_user].debtProportion, userDebtState[_user].debtFactor);
    }

    // need update lastDebtFactors first
    function UpdateUserDebt(address _user, uint256 _debtProportion) external OnlyDebtSystemRole(msg.sender) {
        _updateUserDebt(_user, _debtProportion);
    }

    function UpdateDebt(
        address _user,
        uint256 _debtProportion,
        uint256 _factor
    ) external OnlyDebtSystemRole(msg.sender) {
        _pushDebtFactor(_factor);
        _updateUserDebt(_user, _debtProportion);
    }

    function GetUserDebtData(address _user) external view returns (uint256 debtProportion, uint256 debtFactor) {
        debtProportion = userDebtState[_user].debtProportion;
        debtFactor = userDebtState[_user].debtFactor;
    }

    function _lastSystemDebtFactor() private view returns (uint256) {
        if (debtCurrentIndex == 0) {
            return SafeDecimalMath.preciseUnit();
        }
        return lastDebtFactors[debtCurrentIndex - 1];
    }

    function LastSystemDebtFactor() external view returns (uint256) {
        return _lastSystemDebtFactor();
    }

    function GetUserCurrentDebtProportion(address _user) public view returns (uint256) {
        uint256 debtProportion = userDebtState[_user].debtProportion;
        uint256 debtFactor = userDebtState[_user].debtFactor;

        if (debtProportion == 0) {
            return 0;
        }

        uint256 currentUserDebtProportion =
            _lastSystemDebtFactor().divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);
        return currentUserDebtProportion;
    }

    /**
     *
     *@return [0] the debt balance of user. [1] system total asset in usd.
     */
    function GetUserDebtBalanceInUsd(address _user) external view returns (uint256, uint256) {
        uint256 totalAssetSupplyInUsd = assetSys.totalAssetsInUsd();

        uint256 debtProportion = userDebtState[_user].debtProportion;
        uint256 debtFactor = userDebtState[_user].debtFactor;

        if (debtProportion == 0) {
            return (0, totalAssetSupplyInUsd);
        }

        uint256 currentUserDebtProportion =
            _lastSystemDebtFactor().divideDecimalRoundPrecise(debtFactor).multiplyDecimalRoundPrecise(debtProportion);
        uint256 userDebtBalance =
            totalAssetSupplyInUsd
                .decimalToPreciseDecimal()
                .multiplyDecimalRoundPrecise(currentUserDebtProportion)
                .preciseDecimalToDecimal();

        return (userDebtBalance, totalAssetSupplyInUsd);
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[42] private __gap;
}
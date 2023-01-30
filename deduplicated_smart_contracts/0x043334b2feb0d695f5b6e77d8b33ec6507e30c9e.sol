/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

// File @openzeppelin/contracts/math/SafeMath.sol@v3.2.0

// SPDX-License-Identifier: GPLv2


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


// File @openzeppelin/contracts/utils/EnumerableSet.sol@v3.2.0



pragma solidity ^0.6.0;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
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


// File @openzeppelin/contracts/utils/Address.sol@v3.2.0



pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


// File @openzeppelin/contracts/GSN/Context.sol@v3.2.0



pragma solidity ^0.6.0;

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


// File @openzeppelin/contracts/access/AccessControl.sol@v3.2.0



pragma solidity ^0.6.0;



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

    mapping (bytes32 => RoleData) private _roles;

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


// File contracts/DigitalaxAccessControls.sol

pragma solidity 0.6.12;

/**
 * @notice Access Controls contract for the Digitalax Platform
 * @author BlockRocket.tech
 */
contract DigitalaxAccessControls is AccessControl {
    /// @notice Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");

    /// @notice Events for adding and removing various roles
    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    /**
     * @notice The deployer is automatically given the admin role which will allow them to then grant roles to other addresses
     */
    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /////////////
    // Lookups //
    /////////////

    /**
     * @notice Used to check whether an address has the admin role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the minter role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasMinterRole(address _address) external view returns (bool) {
        return hasRole(MINTER_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the smart contract role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasSmartContractRole(address _address) external view returns (bool) {
        return hasRole(SMART_CONTRACT_ROLE, _address);
    }

    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @notice Grants the admin role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addAdminRole(address _address) external {
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the admin role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeAdminRole(address _address) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the minter role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addMinterRole(address _address) external {
        grantRole(MINTER_ROLE, _address);
        emit MinterRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the minter role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeMinterRole(address _address) external {
        revokeRole(MINTER_ROLE, _address);
        emit MinterRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the smart contract role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addSmartContractRole(address _address) external {
        grantRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the smart contract role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeSmartContractRole(address _address) external {
        revokeRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleRemoved(_address, _msgSender());
    }
}


// File @openzeppelin/contracts/introspection/IERC165.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// File @openzeppelin/contracts/token/ERC721/IERC721Metadata.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}


// File @openzeppelin/contracts/introspection/ERC165.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// File @openzeppelin/contracts/utils/EnumerableMap.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one
            // in the array, and then remove the last entry (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            MapEntry storage lastEntry = map._entries[lastIndex];

            // Move the last entry to the index where the entry to delete is
            map._entries[toDeleteIndex] = lastEntry;
            // Update the index for the moved entry
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved entry was stored
            map._entries.pop();

            // Delete the index for the deleted slot
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


// File contracts/ERC721/ERC721WithSameTokenURIForAllTokens.sol



pragma solidity 0.6.12;










/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 * @dev This is a modified OZ ERC721 base contract with one change where all tokens have the same token URI
 */
contract ERC721WithSameTokenURIForAllTokens is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Single token URI for all tokens
    string public tokenURI_;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tokenURI_;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                _msgSender(),
                from,
                tokenId,
                _data
            ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


// File contracts/DigitalaxGenesisNFT.sol



pragma solidity 0.6.12;



/**
 * @title Digitalax Genesis NFT
 * @dev To facilitate the genesis sale for the Digitialax platform
 */
contract DigitalaxGenesisNFT is ERC721WithSameTokenURIForAllTokens("DigitalaxGenesis", "DXG") {
    using SafeMath for uint256;

    // @notice event emitted upon construction of this contract, used to bootstrap external indexers
    event DigitalaxGenesisNFTContractDeployed();

    // @notice event emitted when a contributor buys a Genesis NFT
    event GenesisPurchased(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 contribution
    );

    // @notice event emitted when a admin mints a Genesis NFT
    event AdminGenesisMinted(
        address indexed beneficiary,
        address indexed admin,
        uint256 indexed tokenId
    );

    // @notice event emitted when a contributors amount is increased
    event ContributionIncreased(
        address indexed buyer,
        uint256 contribution
    );

    // @notice event emitted when end date is changed
    event GenesisEndUpdated(
        uint256 genesisEndTimestamp,
        address indexed admin
    );

    // @notice event emitted when DigitalaxAccessControls is updated
    event AccessControlsUpdated(
        address indexed newAdress
    );

    // @notice responsible for enforcing admin access
    DigitalaxAccessControls public accessControls;

    // @notice all funds will be sent to this address pon purchase of a Genesis NFT
    address payable public fundsMultisig;

    // @notice start date for them the Genesis sale is open to the public, before this data no purchases can be made
    uint256 public genesisStartTimestamp;

    // @notice end date for them the Genesis sale is closed, no more purchased can be made after this point
    uint256 public genesisEndTimestamp;

    // @notice set after end time has been changed once, prevents further changes to end timestamp
    bool public genesisEndTimestampLocked;

    // @notice the minimum amount a buyer can contribute in a single go
    uint256 public constant minimumContributionAmount = 0.1 ether;

    // @notice the maximum accumulative amount a user can contribute to the genesis sale
    uint256 public constant maximumContributionAmount = 2 ether;

    // @notice accumulative => contribution total
    mapping(address => uint256) public contribution;

    // @notice global accumulative contribution amount
    uint256 public totalContributions;

    // @notice max number of paid contributions to the genesis sale
    uint256 public constant maxGenesisContributionTokens = 460;

    uint256 public totalAdminMints;

    constructor(
        DigitalaxAccessControls _accessControls,
        address payable _fundsMultisig,
        uint256 _genesisStartTimestamp,
        uint256 _genesisEndTimestamp,
        string memory _tokenURI
    ) public {
        accessControls = _accessControls;
        fundsMultisig = _fundsMultisig;
        genesisStartTimestamp = _genesisStartTimestamp;
        genesisEndTimestamp = _genesisEndTimestamp;
        tokenURI_ = _tokenURI;
        emit DigitalaxGenesisNFTContractDeployed();
    }

    /**
     * @dev Proxy method for facilitating a single point of entry to either buy or contribute additional value to the Genesis sale
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     */
    function buyOrIncreaseContribution() external payable {
        if (contribution[_msgSender()] == 0) {
            buy();
        } else {
            increaseContribution();
        }
    }

    /**
     * @dev Facilitating the initial purchase of a Genesis NFT
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     * @dev Reverts if already owns an genesis token
     * @dev Buyer receives a NFT on success
     * @dev All funds move to fundsMultisig
     */
    function buy() public payable {
        require(contribution[_msgSender()] == 0, "DigitalaxGenesisNFT.buy: You already own a genesis NFT");
        require(
            _getNow() >= genesisStartTimestamp && _getNow() <= genesisEndTimestamp,
            "DigitalaxGenesisNFT.buy: No genesis are available outside of the genesis window"
        );

        uint256 _contributionAmount = msg.value;
        require(
            _contributionAmount >= minimumContributionAmount,
            "DigitalaxGenesisNFT.buy: Contribution does not meet minimum requirement"
        );

        require(
            _contributionAmount <= maximumContributionAmount,
            "DigitalaxGenesisNFT.buy: You cannot exceed the maximum contribution amount"
        );

        require(remainingGenesisTokens() > 0, "DigitalaxGenesisNFT.buy: Total number of genesis token holders reached");

        contribution[_msgSender()] = _contributionAmount;
        totalContributions = totalContributions.add(_contributionAmount);

        (bool fundsTransferSuccess,) = fundsMultisig.call{value : _contributionAmount}("");
        require(fundsTransferSuccess, "DigitalaxGenesisNFT.buy: Unable to send contribution to funds multisig");

        uint256 tokenId = totalSupply().add(1);
        _safeMint(_msgSender(), tokenId);

        emit GenesisPurchased(_msgSender(), tokenId, _contributionAmount);
    }

    /**
     * @dev Facilitates an owner to increase there contribution
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     * @dev Reverts if caller does not already owns an genesis token
     * @dev All funds move to fundsMultisig
     */
    function increaseContribution() public payable {
        require(
            _getNow() >= genesisStartTimestamp && _getNow() <= genesisEndTimestamp,
            "DigitalaxGenesisNFT.increaseContribution: No increases are possible outside of the genesis window"
        );

        require(
            contribution[_msgSender()] > 0,
            "DigitalaxGenesisNFT.increaseContribution: You do not own a genesis NFT"
        );

        uint256 _amountToIncrease = msg.value;
        contribution[_msgSender()] = contribution[_msgSender()].add(_amountToIncrease);

        require(
            contribution[_msgSender()] <= maximumContributionAmount,
            "DigitalaxGenesisNFT.increaseContribution: You cannot exceed the maximum contribution amount"
        );

        totalContributions = totalContributions.add(_amountToIncrease);

        (bool fundsTransferSuccess,) = fundsMultisig.call{value : _amountToIncrease}("");
        require(
            fundsTransferSuccess,
            "DigitalaxGenesisNFT.increaseContribution: Unable to send contribution to funds multisig"
        );

        emit ContributionIncreased(_msgSender(), _amountToIncrease);
    }

    // Admin

    /**
     * @dev Allows a whitelisted admin to mint a token and issue it to a beneficiary
     * @dev One token per holder
     * @dev All holders contribution as set o zero on creation
     */
    function adminBuy(address _beneficiary) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.adminBuy: Sender must be admin"
        );
        require(_beneficiary != address(0), "DigitalaxGenesisNFT.adminBuy: Beneficiary cannot be ZERO");
        require(balanceOf(_beneficiary) == 0, "DigitalaxGenesisNFT.adminBuy: Beneficiary already owns a genesis NFT");

        uint256 tokenId = totalSupply().add(1);
        _safeMint(_beneficiary, tokenId);

        // Increase admin mint counts
        totalAdminMints = totalAdminMints.add(1);

        emit AdminGenesisMinted(_beneficiary, _msgSender(), tokenId);
    }

    /**
     * @dev Allows a whitelisted admin to update the end date of the genesis
     */
    function updateGenesisEnd(uint256 _end) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.updateGenesisEnd: Sender must be admin"
        );
        // If already passed, dont allow opening again
        require(genesisEndTimestamp > _getNow(), "DigitalaxGenesisNFT.updateGenesisEnd: End time already passed");

        // Only allow setting this once
        require(!genesisEndTimestampLocked, "DigitalaxGenesisNFT.updateGenesisEnd: End time locked");

        genesisEndTimestamp = _end;

        // Lock future end time modifications
        genesisEndTimestampLocked = true;

        emit GenesisEndUpdated(genesisEndTimestamp, _msgSender());
    }

    /**
     * @dev Allows a whitelisted admin to update the start date of the genesis
     */
    function updateAccessControls(DigitalaxAccessControls _accessControls) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.updateAccessControls: Sender must be admin"
        );
        require(address(_accessControls) != address(0), "DigitalaxGenesisNFT.updateAccessControls: Zero Address");
        accessControls = _accessControls;

        emit AccessControlsUpdated(address(_accessControls));
    }

    /**
    * @dev Returns total remaining number of tokens available in the Genesis sale
    */
    function remainingGenesisTokens() public view returns (uint256) {
        return _getMaxGenesisContributionTokens() - (totalSupply() - totalAdminMints);
    }

    // Internal

    function _getNow() internal virtual view returns (uint256) {
        return block.timestamp;
    }

    function _getMaxGenesisContributionTokens() internal virtual view returns (uint256) {
        return maxGenesisContributionTokens;
    }

    /**
     * @dev Before token transfer hook to enforce that no token can be moved to another address until the genesis sale has ended
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (from != address(0) && _getNow() <= genesisEndTimestamp) {
            revert("DigitalaxGenesisNFT._beforeTokenTransfer: Transfers are currently locked at this time");
        }
    }
}


// File interfaces/IERC20.sol

pragma solidity ^0.6.2;


interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}


// File contracts/Utils/ABDKMathQuad.sol

/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
// pragma solidity ^0.5.0 || ^0.6.0 || ^0.7.0;
pragma solidity 0.6.12;

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */
library ABDKMathQuad {
  /*
   * 0.
   */
  bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

  /*
   * -0.
   */
  bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

  /*
   * +Infinity.
   */
  bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

  /*
   * -Infinity.
   */
  bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

  /*
   * Canonical NaN value.
   */
  bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

  /**
   * Convert signed 256-bit integer number into quadruple precision number.
   *
   * @param x signed 256-bit integer number
   * @return quadruple precision number
   */
  function fromInt (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = _msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 256-bit integer number
   * rounding towards zero.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 256-bit integer number
   */
  function toInt (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16638); // Overflow
    if (exponent < 16383) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into quadruple precision number.
   *
   * @param x unsigned 256-bit integer number
   * @return quadruple precision number
   */
  function fromUInt (uint256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = x;

      uint256 msb = _msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into unsigned 256-bit integer number
   * rounding towards zero.  Revert on underflow.  Note, that negative floating
   * point numbers in range (-1.0 .. 0.0) may be converted to unsigned integer
   * without error, because they are rounded to zero.
   *
   * @param x quadruple precision number
   * @return unsigned 256-bit integer number
   */
  function toUInt (bytes16 x) internal pure returns (uint256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    if (exponent < 16383) return 0; // Underflow

    require (uint128 (x) < 0x80000000000000000000000000000000); // Negative

    require (exponent <= 16638); // Overflow
    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    return result;
  }

  /**
   * Convert signed 128.128 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 128.128 bit fixed point number
   * @return quadruple precision number
   */
  function from128x128 (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = _msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 128.128 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 128.128 bit fixed point number
   */
  function to128x128 (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16510); // Overflow
    if (exponent < 16255) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16367) result >>= 16367 - exponent;
    else if (exponent > 16367) result <<= exponent - 16367;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  /**
   * Convert signed 64.64 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 64.64 bit fixed point number
   * @return quadruple precision number
   */
  function from64x64 (int128 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint128 (x > 0 ? x : -x);

      uint256 msb = _msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 64.64 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 64.64 bit fixed point number
   */
  function to64x64 (bytes16 x) internal pure returns (int128) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16446); // Overflow
    if (exponent < 16319) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16431) result >>= 16431 - exponent;
    else if (exponent > 16431) result <<= exponent - 16431;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x80000000000000000000000000000000);
      return -int128 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (result);
    }
  }

  /**
   * Convert octuple precision number into quadruple precision number.
   *
   * @param x octuple precision number
   * @return quadruple precision number
   */
  function fromOctuple (bytes32 x) internal pure returns (bytes16) {
    bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

    uint256 exponent = uint256 (x) >> 236 & 0x7FFFF;
    uint256 significand = uint256 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFFF) {
      if (significand > 0) return NaN;
      else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    }

    if (exponent > 278526)
      return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    else if (exponent < 245649)
      return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
    else if (exponent < 245761) {
      significand = (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
      exponent = 0;
    } else {
      significand >>= 124;
      exponent -= 245760;
    }

    uint128 result = uint128 (significand | exponent << 112);
    if (negative) result |= 0x80000000000000000000000000000000;

    return bytes16 (result);
  }

  /**
   * Convert quadruple precision number into octuple precision number.
   *
   * @param x quadruple precision number
   * @return octuple precision number
   */
  function toOctuple (bytes16 x) internal pure returns (bytes32) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    uint256 result = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) exponent = 0x7FFFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = _msb (result);
        result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 245649 + msb;
      }
    } else {
      result <<= 124;
      exponent += 245760;
    }

    result |= exponent << 236;
    if (uint128 (x) >= 0x80000000000000000000000000000000)
      result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

    return bytes32 (result);
  }

  /**
   * Convert double precision number into quadruple precision number.
   *
   * @param x double precision number
   * @return quadruple precision number
   */
  function fromDouble (bytes8 x) internal pure returns (bytes16) {
    uint256 exponent = uint64 (x) >> 52 & 0x7FF;

    uint256 result = uint64 (x) & 0xFFFFFFFFFFFFF;

    if (exponent == 0x7FF) exponent = 0x7FFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = _msb (result);
        result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 15309 + msb;
      }
    } else {
      result <<= 60;
      exponent += 15360;
    }

    result |= exponent << 112;
    if (x & 0x8000000000000000 > 0)
      result |= 0x80000000000000000000000000000000;

    return bytes16 (uint128 (result));
  }

  /**
   * Convert quadruple precision number into double precision number.
   *
   * @param x quadruple precision number
   * @return double precision number
   */
  function toDouble (bytes16 x) internal pure returns (bytes8) {
    bool negative = uint128 (x) >= 0x80000000000000000000000000000000;

    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 significand = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) {
      if (significand > 0) return 0x7FF8000000000000; // NaN
      else return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    }

    if (exponent > 17406)
      return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    else if (exponent < 15309)
      return negative ?
          bytes8 (0x8000000000000000) : // -0
          bytes8 (0x0000000000000000); // 0
    else if (exponent < 15361) {
      significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
      exponent = 0;
    } else {
      significand >>= 60;
      exponent -= 15360;
    }

    uint64 result = uint64 (significand | exponent << 52);
    if (negative) result |= 0x8000000000000000;

    return bytes8 (result);
  }

  /**
   * Test whether given quadruple precision number is NaN.
   *
   * @param x quadruple precision number
   * @return true if x is NaN, false otherwise
   */
  function isNaN (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >
      0x7FFF0000000000000000000000000000;
  }

  /**
   * Test whether given quadruple precision number is positive or negative
   * infinity.
   *
   * @param x quadruple precision number
   * @return true if x is positive or negative infinity, false otherwise
   */
  function isInfinity (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ==
      0x7FFF0000000000000000000000000000;
  }

  /**
   * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
   * is positive.  Note that sign (-0) is zero.  Revert if x is NaN.
   *
   * @param x quadruple precision number
   * @return sign of x
   */
  function sign (bytes16 x) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    if (absoluteX == 0) return 0;
    else if (uint128 (x) >= 0x80000000000000000000000000000000) return -1;
    else return 1;
  }

  /**
   * Calculate sign (x - y).  Revert if either argument is NaN, or both
   * arguments are infinities of the same sign.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return sign (x - y)
   */
  function cmp (bytes16 x, bytes16 y) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    uint128 absoluteY = uint128 (y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

    // Not infinities of the same sign
    require (x != y || absoluteX < 0x7FFF0000000000000000000000000000);

    if (x == y) return 0;
    else {
      bool negativeX = uint128 (x) >= 0x80000000000000000000000000000000;
      bool negativeY = uint128 (y) >= 0x80000000000000000000000000000000;

      if (negativeX) {
        if (negativeY) return absoluteX > absoluteY ? -1 : int8 (1);
        else return -1;
      } else {
        if (negativeY) return 1;
        else return absoluteX > absoluteY ? int8 (1) : -1;
      }
    }
  }

  /**
   * Test whether x equals y.  NaN, infinity, and -infinity are not equal to
   * anything.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return true if x equals to y, false otherwise
   */
  function eq (bytes16 x, bytes16 y) internal pure returns (bool) {
    if (x == y) {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF <
        0x7FFF0000000000000000000000000000;
    } else return false;
  }

  /**
   * Calculate x + y.  Special values behave in the following way:
   *
   * NaN + x = NaN for any x.
   * Infinity + x = Infinity for any finite x.
   * -Infinity + x = -Infinity for any finite x.
   * Infinity + Infinity = Infinity.
   * -Infinity + -Infinity = -Infinity.
   * Infinity + -Infinity = -Infinity + Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function add (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) {
        if (x == y) return x;
        else return NaN;
      } else return x;
    } else if (yExponent == 0x7FFF) return y;
    else {
      bool xSign = uint128 (x) >= 0x80000000000000000000000000000000;
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      bool ySign = uint128 (y) >= 0x80000000000000000000000000000000;
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
      else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
      else {
        int256 delta = int256 (xExponent) - int256 (yExponent);

        if (xSign == ySign) {
          if (delta > 112) return x;
          else if (delta > 0) ySignifier >>= uint256 (delta);
          else if (delta < -112) return y;
          else if (delta < 0) {
            xSignifier >>= uint256 (-delta);
            xExponent = yExponent;
          }

          xSignifier += ySignifier;

          if (xSignifier >= 0x20000000000000000000000000000) {
            xSignifier >>= 1;
            xExponent += 1;
          }

          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else {
            if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
            else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            return bytes16 (uint128 (
                (xSign ? 0x80000000000000000000000000000000 : 0) |
                (xExponent << 112) |
                xSignifier));
          }
        } else {
          if (delta > 0) {
            xSignifier <<= 1;
            xExponent -= 1;
          } else if (delta < 0) {
            ySignifier <<= 1;
            xExponent = yExponent - 1;
          }

          if (delta > 112) ySignifier = 1;
          else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256 (delta - 1)) + 1;
          else if (delta < -112) xSignifier = 1;
          else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256 (-delta - 1)) + 1;

          if (xSignifier >= ySignifier) xSignifier -= ySignifier;
          else {
            xSignifier = ySignifier - xSignifier;
            xSign = ySign;
          }

          if (xSignifier == 0)
            return POSITIVE_ZERO;

          uint256 msb = _msb (xSignifier);

          if (msb == 113) {
            xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            xExponent += 1;
          } else if (msb < 112) {
            uint256 shift = 112 - msb;
            if (xExponent > shift) {
              xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
              xExponent -= shift;
            } else {
              xSignifier <<= xExponent - 1;
              xExponent = 0;
            }
          } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else return bytes16 (uint128 (
              (xSign ? 0x80000000000000000000000000000000 : 0) |
              (xExponent << 112) |
              xSignifier));
        }
      }
    }
  }

  /**
   * Calculate x - y.  Special values behave in the following way:
   *
   * NaN - x = NaN for any x.
   * Infinity - x = Infinity for any finite x.
   * -Infinity - x = -Infinity for any finite x.
   * Infinity - -Infinity = Infinity.
   * -Infinity - Infinity = -Infinity.
   * Infinity - Infinity = -Infinity - -Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function sub (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    return add (x, y ^ 0x80000000000000000000000000000000);
  }

  /**
   * Calculate x * y.  Special values behave in the following way:
   *
   * NaN * x = NaN for any x.
   * Infinity * x = Infinity for any finite positive x.
   * Infinity * x = -Infinity for any finite negative x.
   * -Infinity * x = -Infinity for any finite positive x.
   * -Infinity * x = Infinity for any finite negative x.
   * Infinity * 0 = NaN.
   * -Infinity * 0 = NaN.
   * Infinity * Infinity = Infinity.
   * Infinity * -Infinity = -Infinity.
   * -Infinity * Infinity = -Infinity.
   * -Infinity * -Infinity = Infinity.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function mul (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) {
        if (x == y) return x ^ y & 0x80000000000000000000000000000000;
        else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
        else return NaN;
      } else {
        if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return x ^ y & 0x80000000000000000000000000000000;
      }
    } else if (yExponent == 0x7FFF) {
        if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return y ^ x & 0x80000000000000000000000000000000;
    } else {
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      xSignifier *= ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      xExponent += yExponent;

      uint256 msb =
        xSignifier >= 0x200000000000000000000000000000000000000000000000000000000 ? 225 :
        xSignifier >= 0x100000000000000000000000000000000000000000000000000000000 ? 224 :
        _msb (xSignifier);

      if (xExponent + msb < 16496) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb < 16608) { // Subnormal
        if (xExponent < 16496)
          xSignifier >>= 16496 - xExponent;
        else if (xExponent > 16496)
          xSignifier <<= xExponent - 16496;
        xExponent = 0;
      } else if (xExponent + msb > 49373) {
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else {
        if (msb > 112)
          xSignifier >>= msb - 112;
        else if (msb < 112)
          xSignifier <<= 112 - msb;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb - 16607;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  /**
   * Calculate x / y.  Special values behave in the following way:
   *
   * NaN / x = NaN for any x.
   * x / NaN = NaN for any x.
   * Infinity / x = Infinity for any finite non-negative x.
   * Infinity / x = -Infinity for any finite negative x including -0.
   * -Infinity / x = -Infinity for any finite non-negative x.
   * -Infinity / x = Infinity for any finite negative x including -0.
   * x / Infinity = 0 for any finite non-negative x.
   * x / -Infinity = -0 for any finite non-negative x.
   * x / Infinity = -0 for any finite non-negative x including -0.
   * x / -Infinity = 0 for any finite non-negative x including -0.
   *
   * Infinity / Infinity = NaN.
   * Infinity / -Infinity = -NaN.
   * -Infinity / Infinity = -NaN.
   * -Infinity / -Infinity = NaN.
   *
   * Division by zero behaves in the following way:
   *
   * x / 0 = Infinity for any finite positive x.
   * x / -0 = -Infinity for any finite positive x.
   * x / 0 = -Infinity for any finite negative x.
   * x / -0 = Infinity for any finite negative x.
   * 0 / 0 = NaN.
   * 0 / -0 = NaN.
   * -0 / 0 = NaN.
   * -0 / -0 = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function div (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) return NaN;
      else return x ^ y & 0x80000000000000000000000000000000;
    } else if (yExponent == 0x7FFF) {
      if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
      else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
    } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
      if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
      else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
    } else {
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) {
        if (xSignifier != 0) {
          uint shift = 226 - _msb (xSignifier);

          xSignifier <<= shift;

          xExponent = 1;
          yExponent += shift - 114;
        }
      }
      else {
        xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
      }

      xSignifier = xSignifier / ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      assert (xSignifier >= 0x1000000000000000000000000000);

      uint256 msb =
        xSignifier >= 0x80000000000000000000000000000 ? _msb (xSignifier) :
        xSignifier >= 0x40000000000000000000000000000 ? 114 :
        xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

      if (xExponent + msb > yExponent + 16497) { // Overflow
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else if (xExponent + msb + 16380  < yExponent) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb + 16268  < yExponent) { // Subnormal
        if (xExponent + 16380 > yExponent)
          xSignifier <<= xExponent + 16380 - yExponent;
        else if (xExponent + 16380 < yExponent)
          xSignifier >>= yExponent - xExponent - 16380;

        xExponent = 0;
      } else { // Normal
        if (msb > 112)
          xSignifier >>= msb - 112;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb + 16269 - yExponent;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  /**
   * Calculate -x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function neg (bytes16 x) internal pure returns (bytes16) {
    return x ^ 0x80000000000000000000000000000000;
  }

  /**
   * Calculate |x|.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function abs (bytes16 x) internal pure returns (bytes16) {
    return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  }

  /**
   * Calculate square root of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function sqrt (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) >  0x80000000000000000000000000000000) return NaN;
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return POSITIVE_ZERO;

        bool oddExponent = xExponent & 0x1 == 0;
        xExponent = xExponent + 16383 >> 1;

        if (oddExponent) {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 113;
          else {
            uint256 msb = _msb (xSignifier);
            uint256 shift = (226 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
          }
        } else {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 112;
          else {
            uint256 msb = _msb (xSignifier);
            uint256 shift = (225 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
          }
        }

        uint256 r = 0x10000000000000000000000000000;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
        uint256 r1 = xSignifier / r;
        if (r1 < r) r = r1;

        return bytes16 (uint128 (xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  /**
   * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function log_2 (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) > 0x80000000000000000000000000000000) return NaN;
    else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO;
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return NEGATIVE_INFINITY;

        bool resultNegative;
        uint256 resultExponent = 16495;
        uint256 resultSignifier;

        if (xExponent >= 0x3FFF) {
          resultNegative = false;
          resultSignifier = xExponent - 0x3FFF;
          xSignifier <<= 15;
        } else {
          resultNegative = true;
          if (xSignifier >= 0x10000000000000000000000000000) {
            resultSignifier = 0x3FFE - xExponent;
            xSignifier <<= 15;
          } else {
            uint256 msb = _msb (xSignifier);
            resultSignifier = 16493 - msb;
            xSignifier <<= 127 - msb;
          }
        }

        if (xSignifier == 0x80000000000000000000000000000000) {
          if (resultNegative) resultSignifier += 1;
          uint256 shift = 112 - _msb (resultSignifier);
          resultSignifier <<= shift;
          resultExponent -= shift;
        } else {
          uint256 bb = resultNegative ? 1 : 0;
          while (resultSignifier < 0x10000000000000000000000000000) {
            resultSignifier <<= 1;
            resultExponent -= 1;

            xSignifier *= xSignifier;
            uint256 b = xSignifier >> 255;
            resultSignifier += b ^ bb;
            xSignifier >>= 127 + b;
          }
        }

        return bytes16 (uint128 ((resultNegative ? 0x80000000000000000000000000000000 : 0) |
            resultExponent << 112 | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  /**
   * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function ln (bytes16 x) internal pure returns (bytes16) {
    return mul (log_2 (x), 0x3FFE62E42FEFA39EF35793C7673007E5);
  }

  /**
   * Calculate 2^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function pow_2 (bytes16 x) internal pure returns (bytes16) {
    bool xNegative = uint128 (x) > 0x80000000000000000000000000000000;
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
    else if (xExponent > 16397)
      return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
    else if (xExponent < 16255)
      return 0x3FFF0000000000000000000000000000;
    else {
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      if (xExponent > 16367)
        xSignifier <<= xExponent - 16367;
      else if (xExponent < 16367)
        xSignifier >>= 16367 - xExponent;

      if (xNegative && xSignifier > 0x406E00000000000000000000000000000000)
        return POSITIVE_ZERO;

      if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        return POSITIVE_INFINITY;

      uint256 resultExponent = xSignifier >> 128;
      xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xNegative && xSignifier != 0) {
        xSignifier = ~xSignifier;
        resultExponent += 1;
      }

      uint256 resultSignifier = 0x80000000000000000000000000000000;
      if (xSignifier & 0x80000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (xSignifier & 0x40000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (xSignifier & 0x20000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (xSignifier & 0x10000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (xSignifier & 0x8000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (xSignifier & 0x4000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (xSignifier & 0x2000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (xSignifier & 0x1000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (xSignifier & 0x800000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (xSignifier & 0x400000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (xSignifier & 0x200000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (xSignifier & 0x100000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (xSignifier & 0x80000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (xSignifier & 0x40000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (xSignifier & 0x20000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
      if (xSignifier & 0x10000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (xSignifier & 0x8000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (xSignifier & 0x4000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (xSignifier & 0x2000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (xSignifier & 0x1000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (xSignifier & 0x800000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (xSignifier & 0x400000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (xSignifier & 0x200000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (xSignifier & 0x100000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (xSignifier & 0x80000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (xSignifier & 0x40000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (xSignifier & 0x20000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (xSignifier & 0x10000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (xSignifier & 0x8000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (xSignifier & 0x4000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (xSignifier & 0x2000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (xSignifier & 0x1000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (xSignifier & 0x800000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (xSignifier & 0x400000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (xSignifier & 0x200000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (xSignifier & 0x100000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (xSignifier & 0x80000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (xSignifier & 0x40000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (xSignifier & 0x20000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (xSignifier & 0x10000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (xSignifier & 0x8000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (xSignifier & 0x4000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (xSignifier & 0x2000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (xSignifier & 0x1000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (xSignifier & 0x800000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (xSignifier & 0x400000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (xSignifier & 0x200000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (xSignifier & 0x100000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (xSignifier & 0x80000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (xSignifier & 0x40000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (xSignifier & 0x20000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (xSignifier & 0x10000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (xSignifier & 0x8000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (xSignifier & 0x4000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (xSignifier & 0x2000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (xSignifier & 0x1000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (xSignifier & 0x800000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (xSignifier & 0x400000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (xSignifier & 0x200000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (xSignifier & 0x100000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (xSignifier & 0x80000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (xSignifier & 0x40000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (xSignifier & 0x20000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (xSignifier & 0x10000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
      if (xSignifier & 0x8000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
      if (xSignifier & 0x4000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
      if (xSignifier & 0x2000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
      if (xSignifier & 0x1000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
      if (xSignifier & 0x800000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
      if (xSignifier & 0x400000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
      if (xSignifier & 0x200000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
      if (xSignifier & 0x100000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
      if (xSignifier & 0x80000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
      if (xSignifier & 0x40000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
      if (xSignifier & 0x20000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
      if (xSignifier & 0x10000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
      if (xSignifier & 0x8000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
      if (xSignifier & 0x4000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
      if (xSignifier & 0x2000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
      if (xSignifier & 0x1000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
      if (xSignifier & 0x800000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
      if (xSignifier & 0x400000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
      if (xSignifier & 0x200000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
      if (xSignifier & 0x100000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
      if (xSignifier & 0x80000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
      if (xSignifier & 0x40000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
      if (xSignifier & 0x20000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
      if (xSignifier & 0x10000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
      if (xSignifier & 0x8000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
      if (xSignifier & 0x4000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
      if (xSignifier & 0x2000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
      if (xSignifier & 0x1000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
      if (xSignifier & 0x800000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
      if (xSignifier & 0x400000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
      if (xSignifier & 0x200000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
      if (xSignifier & 0x100000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
      if (xSignifier & 0x80000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
      if (xSignifier & 0x40000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
      if (xSignifier & 0x20000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
      if (xSignifier & 0x10000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
      if (xSignifier & 0x8000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
      if (xSignifier & 0x4000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
      if (xSignifier & 0x2000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
      if (xSignifier & 0x1000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
      if (xSignifier & 0x800000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
      if (xSignifier & 0x400000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
      if (xSignifier & 0x200000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
      if (xSignifier & 0x100000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
      if (xSignifier & 0x80000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
      if (xSignifier & 0x40000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
      if (xSignifier & 0x20000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
      if (xSignifier & 0x10000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
      if (xSignifier & 0x8000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
      if (xSignifier & 0x4000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
      if (xSignifier & 0x2000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
      if (xSignifier & 0x1000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
      if (xSignifier & 0x800 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
      if (xSignifier & 0x400 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
      if (xSignifier & 0x200 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
      if (xSignifier & 0x100 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
      if (xSignifier & 0x80 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
      if (xSignifier & 0x40 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
      if (xSignifier & 0x20 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
      if (xSignifier & 0x10 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
      if (xSignifier & 0x8 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
      if (xSignifier & 0x4 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;

      if (!xNegative) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent += 0x3FFF;
      } else if (resultExponent <= 0x3FFE) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent = 0x3FFF - resultExponent;
      } else {
        resultSignifier = resultSignifier >> resultExponent - 16367;
        resultExponent = 0;
      }

      return bytes16 (uint128 (resultExponent << 112 | resultSignifier));
    }
  }

  /**
   * Calculate e^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function exp (bytes16 x) internal pure returns (bytes16) {
    return pow_2 (mul (x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
  }

  /**
   * Get index of the most significant non-zero bit in binary representation of
   * x.  Reverts if x is zero.
   *
   * @return index of the most significant non-zero bit in binary representation
   *         of x
   */
  function _msb (uint256 x) private pure returns (uint256) {
    require (x > 0);

    uint256 result = 0;

    if (x >= 0x100000000000000000000000000000000) { x >>= 128; result += 128; }
    if (x >= 0x10000000000000000) { x >>= 64; result += 64; }
    if (x >= 0x100000000) { x >>= 32; result += 32; }
    if (x >= 0x10000) { x >>= 16; result += 16; }
    if (x >= 0x100) { x >>= 8; result += 8; }
    if (x >= 0x10) { x >>= 4; result += 4; }
    if (x >= 0x4) { x >>= 2; result += 2; }
    if (x >= 0x2) result += 1; // No need to shift x anymore

    return result;
  }
}


// File interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// File contracts/Utils/UniswapV2Library.sol

pragma solidity 0.6.12;


library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


// File contracts/DigitalaxRewards.sol


pragma solidity 0.6.12;








/**
 * @title Digitalax Rewards
 * @dev Calculates the rewards for staking on the Digitialax platform
 * @author Adrian Guerrera (deepyr)
 */

interface DigialaxStaking {
    function stakedEthTotal() external view returns (uint256);
    function lpToken() external view returns (address);
    function WETH() external view returns (address);
}

interface MONA is IERC20 {
    function mint(address tokenOwner, uint tokens) external returns (bool);
}

contract DigitalaxRewards {
    using SafeMath for uint256;
    using ABDKMathQuad for bytes16;

    /* ========== Variables ========== */

    MONA public rewardsToken;
    DigitalaxAccessControls public accessControls;
    DigialaxStaking public genesisStaking;
    DigialaxStaking public parentStaking;
    DigialaxStaking public lpStaking;

    uint256 constant pointMultiplier = 10e32;
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_WEEK = 7 * 24 * 60 * 60;
    
    // weekNumber => rewards
    mapping (uint256 => uint256) public weeklyRewardsPerSecond;
    mapping (address => mapping(uint256 => uint256)) public weeklyBonusPerSecond;

    uint256 public startTime;
    uint256 public lastRewardTime;

    uint256 public genesisRewardsPaid;
    uint256 public parentRewardsPaid;
    uint256 public lpRewardsPaid;

    /* ========== Structs ========== */

    struct Weights {
        uint256 genesisWtPoints;
        uint256 parentWtPoints;
        uint256 lpWeightPoints;
    }

    /// @notice mapping of a staker to its current properties
    mapping (uint256 => Weights) public weeklyWeightPoints;

    /* ========== Events ========== */

    event RewardAdded(address indexed addr, uint256 reward);
    event RewardDistributed(address indexed addr, uint256 reward);
    event Recovered(address indexed token, uint256 amount);

    
    /* ========== Admin Functions ========== */
    constructor(
        MONA _rewardsToken,
        DigitalaxAccessControls _accessControls,
        DigialaxStaking _genesisStaking,
        DigialaxStaking _parentStaking,
        DigialaxStaking _lpStaking,
        uint256 _startTime
    )
        public
    {
        rewardsToken = _rewardsToken;
        accessControls = _accessControls;
        genesisStaking = _genesisStaking;
        parentStaking = _parentStaking;
        lpStaking = _lpStaking;
        startTime = _startTime;
        lastRewardTime = _startTime;
    }

    /// @dev Setter functions for contract config
    function setStartTime(
        uint256 _startTime
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setStartTime: Sender must be admin"
        );
        startTime = _startTime;
        lastRewardTime = _startTime;
    }

    function setGenesisStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setGenesisStaking: Sender must be admin"
        );
        require(_addr != address(parentStaking));
        require(_addr != address(lpStaking));
        genesisStaking = DigialaxStaking(_addr);
    }

    function setParentStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setParentStaking: Sender must be admin"
        );
        require(_addr != address(genesisStaking));
        require(_addr != address(lpStaking));
        parentStaking = DigialaxStaking(_addr);
    }

    function setLPStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setLPStaking: Sender must be admin"
        );
        require(_addr != address(parentStaking));
        require(_addr != address(genesisStaking));
        lpStaking = DigialaxStaking(_addr);
    } 

    /// @notice Set rewards distributed each week
    /// @dev this number is the total rewards that week with 18 decimals
    function setRewards(
        uint256[] memory rewardWeeks,
        uint256[] memory amounts
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setRewards: Sender must be admin"
        );
        uint256 numRewards = rewardWeeks.length;
        for (uint256 i = 0; i < numRewards; i++) {
            uint256 week = rewardWeeks[i];
            uint256 amount = amounts[i].mul(pointMultiplier)
                                       .div(SECONDS_PER_WEEK)
                                       .div(pointMultiplier);
            weeklyRewardsPerSecond[week] = amount;
        }
    }
    /// @notice Set rewards distributed each week
    /// @dev this number is the total rewards that week with 18 decimals
    function bonusRewards(
        address pool,
        uint256[] memory rewardWeeks,
        uint256[] memory amounts
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setRewards: Sender must be admin"
        );
        uint256 numRewards = rewardWeeks.length;
        for (uint256 i = 0; i < numRewards; i++) {
            uint256 week = rewardWeeks[i];
            uint256 amount = amounts[i].mul(pointMultiplier)
                                       .div(SECONDS_PER_WEEK)
                                       .div(pointMultiplier);
            weeklyBonusPerSecond[pool][week] = amount;
        }
    }

    // From BokkyPooBah's DateTime Library v1.01
    // https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }


    /* ========== Mutative Functions ========== */

    /// @notice Calculate the current normalised weightings and update rewards
    /// @dev 
    function updateRewards() 
        external
        returns(bool)
    {
        if (block.timestamp <= lastRewardTime) {
            return false;
        }
        uint256 g_net = genesisStaking.stakedEthTotal();
        uint256 p_net = parentStaking.stakedEthTotal();
        uint256 m_net = lpStaking.stakedEthTotal();

        /// @dev check that the staking pools have contributions, and rewards have started
        if (g_net.add(p_net).add(m_net) == 0 || block.timestamp <= startTime) {
            lastRewardTime = block.timestamp;
            return false;
        }

        (uint256 gW, uint256 pW, uint256 mW) = _getReturnWeights(g_net, p_net, m_net);
        _updateWeightingAcc(gW,pW,mW);

        /// @dev This mints and sends rewards
        _updateGenesisRewards();
        _updateParentRewards();
        _updateLPRewards();

        /// @dev update accumulated reward
        lastRewardTime = block.timestamp;
        return true;
    }


    /* ========== View Functions ========== */

    /// @notice Gets the total rewards outstanding from last reward time
    function totalRewards() external view returns (uint256) {
        uint256 gRewards = genesisRewards(lastRewardTime, block.timestamp);
        uint256 pRewards = parentRewards(lastRewardTime, block.timestamp);
        uint256 lRewards = LPRewards(lastRewardTime, block.timestamp);
        return gRewards.add(pRewards).add(lRewards);     
    }


    /// @notice Gets the total contributions from the staked contracts
    function getTotalContributions()
        external
        view
        returns(uint256)
    {
        return genesisStaking.stakedEthTotal()
            .add(parentStaking.stakedEthTotal())
            .add(lpStaking.stakedEthTotal());
    }

    /// @dev Getter functions for Rewards contract
    function getCurrentRewardWeek()
        external 
        view 
        returns(uint256)
    {
        return diffDays(startTime, block.timestamp) / 7;
    }

    function totalRewardsPaid()
        external
        view
        returns(uint256)
    {
        return genesisRewardsPaid.add(parentRewardsPaid).add(lpRewardsPaid);
    } 

    /// @notice Return genesis rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function genesisRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;
        uint256 toWeek = diffDays(startTime, _to) / 7;

       if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].genesisWtPoints)
                        .add(weeklyBonusPerSecond[address(genesisStaking)][fromWeek].mul(_to.sub(_from)));
        }
        /// @dev First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].genesisWtPoints)
                        .add(weeklyBonusPerSecond[address(genesisStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].genesisWtPoints))
                             .add(weeklyBonusPerSecond[address(genesisStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].genesisWtPoints))
                          .add(weeklyBonusPerSecond[address(genesisStaking)][toWeek].mul(finalRemander));
        return rewards;
    }

    /// @notice Return parent rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function parentRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;
        uint256 toWeek = diffDays(startTime, _to) / 7;
       
        if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].parentWtPoints)
                        .add(weeklyBonusPerSecond[address(parentStaking)][fromWeek].mul(_to.sub(_from)));
        }
        // First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].parentWtPoints)
                        .add(weeklyBonusPerSecond[address(parentStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].parentWtPoints))
                             .add(weeklyBonusPerSecond[address(parentStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].parentWtPoints))
                          .add(weeklyBonusPerSecond[address(parentStaking)][toWeek].mul(finalRemander));
        return rewards;
    }

    /// @notice Return LP rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function LPRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;                      
        uint256 toWeek = diffDays(startTime, _to) / 7;                          

        if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].lpWeightPoints)
                        .add(weeklyBonusPerSecond[address(lpStaking)][fromWeek].mul(_to.sub(_from)));
        }
        /// @dev First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].lpWeightPoints)
                        .add(weeklyBonusPerSecond[address(lpStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].lpWeightPoints))
                             .add(weeklyBonusPerSecond[address(lpStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].lpWeightPoints))
                        .add(weeklyBonusPerSecond[address(lpStaking)][toWeek].mul(finalRemander));
        return rewards;
    }


    /* ========== Internal Functions ========== */

    function _updateGenesisRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = genesisRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            genesisRewardsPaid = genesisRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(genesisStaking), rewards));
        }
    }

    function _updateParentRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = parentRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            parentRewardsPaid = parentRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(parentStaking), rewards));
        }
    }

    function _updateLPRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = LPRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            lpRewardsPaid = lpRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(lpStaking), rewards));
        }
    }

    function _rewardsFromPoints(
        uint256 rate,
        uint256 duration, 
        uint256 weight
    ) 
        internal
        pure
        returns(uint256)
    {
        return rate.mul(duration)
            .mul(weight)
            .div(1e18)
            .div(pointMultiplier);
    }

    /// @dev Internal fuction to update the weightings 
    function _updateWeightingAcc(uint256 gW, uint256 pW, uint256 mW) internal {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        uint256 lastRewardWeek = diffDays(startTime, lastRewardTime) / 7;
        uint256 startCurrentWeek = startTime.add(currentWeek.mul(SECONDS_PER_WEEK)); 

        /// @dev Initialisation of new weightings and fill gaps
        if (weeklyWeightPoints[0].genesisWtPoints == 0 
                && weeklyWeightPoints[0].parentWtPoints == 0 
                && weeklyWeightPoints[0].lpWeightPoints == 0  ) {
            Weights storage weights = weeklyWeightPoints[0];
            weights.genesisWtPoints = gW;
            weights.parentWtPoints = pW;
            weights.lpWeightPoints = mW;
        }
        /// @dev Fill gaps in weightings
        if (lastRewardWeek < currentWeek ) {
            /// @dev Back fill missing weeks
            for (uint256 i = lastRewardWeek+1; i <= currentWeek; i++) {
                Weights storage weights = weeklyWeightPoints[i];
                weights.genesisWtPoints = gW;
                weights.parentWtPoints = pW;
                weights.lpWeightPoints = mW;
            }
            return;
        }      
        /// @dev Calc the time weighted averages
        Weights storage weights = weeklyWeightPoints[currentWeek];
        weights.genesisWtPoints = _calcWeightPoints(weights.genesisWtPoints,gW,startCurrentWeek);
        weights.parentWtPoints = _calcWeightPoints(weights.parentWtPoints,pW,startCurrentWeek);
        weights.lpWeightPoints = _calcWeightPoints(weights.lpWeightPoints,mW,startCurrentWeek);
    }

    /// @dev Time weighted average of the token weightings
    function _calcWeightPoints(
        uint256 prevWeight,
        uint256 newWeight,
        uint256 startCurrentWeek
    ) 
        internal 
        view 
        returns(uint256) 
    {
        uint256 previousWeighting = prevWeight.mul(lastRewardTime.sub(startCurrentWeek));
        uint256 currentWeighting = newWeight.mul(block.timestamp.sub(lastRewardTime));
        return previousWeighting.add(currentWeighting)
                                .div(block.timestamp.sub(startCurrentWeek));
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a >= b ? a : b;
    }
    
    /// @notice Normalised weightings of weights with point multiplier 
    function _getReturnWeights(
        uint256 _g,
        uint256 _p,
        uint256 _m
    )   
        internal
        view
        returns(uint256,uint256,uint256)
    {
        uint256 eg = _g.mul(_getSqrtWeight(_g,_p,_m).div(1e18));
        uint256 ep = _p.mul(_getSqrtWeight(_p,_m,_g).div(1e18));
        uint256 em = _m.mul(_getSqrtWeight(_m,_g,_p).div(1e18));

        uint256 norm = eg.add(ep).add(em);

        return (eg.mul(pointMultiplier).mul(1e18).div(norm), ep.mul(pointMultiplier).mul(1e18).div(norm), 
                em.mul(pointMultiplier).mul(1e18).div(norm));

    }


    // /// @notice Normalised weightings  
    function _getSqrtWeight(
        uint256 _a,
        uint256 _b,
        uint256 _c
    )  
        internal
        view
        returns(
            uint256 wA
        )
    {
        if ( _a <= _b.add(_c) ||  _b.add(_c) == 0  ) {
            return 1e18;
        }
        uint256 A1 = max(_a.mul(1e18).div(max(_b,1e18)),1e18);
        uint256 A2 = max(_a.mul(1e18).div(max(_c,1e18)),1e18);
        uint256 A = A1.mul(A2).div(1e18);

        bytes16 ten18 = ABDKMathQuad.fromUInt(10**18); 
        wA = ABDKMathQuad.toUInt(ABDKMathQuad.sqrt(ABDKMathQuad.fromUInt(uint256(1e18).mul(1e18).div(A)))).mul(1e18); 
        
    }


    /* ========== Recover ERC20 ========== */

    /// @notice allows for the recovery of incorrect ERC20 tokens sent to contract
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    )
        external
    {
        // Cannot recover the staking token or the rewards token
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.recoverERC20: Sender must be admin"
        );
        require(
            tokenAddress != address(rewardsToken),
            "Cannot withdraw the rewards token"
        );
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }


    /* ========== Getters ========== */

    function getCurrentWeek()
        external
        view
        returns(uint256)
    {
        return diffDays(startTime, block.timestamp) / 7;
    }


    function getCurrentGenesisWtPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].genesisWtPoints;
    }

    function getCurrentParentWtPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].parentWtPoints;
    }
    function getCurrentLpWeightPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].lpWeightPoints;
    }

    function getGenesisStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return genesisStaking.stakedEthTotal();
    }

    function getLpStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return lpStaking.stakedEthTotal();
    }

    function getParentStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return parentStaking.stakedEthTotal();
    }

    function getGenesisDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getGenesisStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = genesisRewards(block.timestamp,block.timestamp + SECONDS_PER_DAY);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        return rewardsInEth.mul(1e18).div(stakedEth);
    } 

    function getParentDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getParentStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = parentRewards(block.timestamp,block.timestamp + SECONDS_PER_DAY);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        return rewardsInEth.mul(1e18).div(stakedEth);
    } 

    function getLpDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getLpStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = LPRewards(block.timestamp,block.timestamp + SECONDS_PER_DAY);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        return rewardsInEth.mul(1e18).div(stakedEth);
    } 

    function getMonaPerEth()
        public 
        view 
        returns (uint256)
    {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();
        return UniswapV2Library.quote(1e18, wethReserve, tokenReserve);
    }

    function getEthPerMona()
        public
        view
        returns (uint256)
    {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();
        return UniswapV2Library.quote(1e18, tokenReserve, wethReserve);
    }

    function getPairReserves() internal view returns (uint256 wethReserves, uint256 tokenReserves) {
        (address token0,) = UniswapV2Library.sortTokens(address(lpStaking.WETH()), address(rewardsToken));
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(lpStaking.lpToken()).getReserves();
        (wethReserves, tokenReserves) = token0 == address(rewardsToken) ? (reserve1, reserve0) : (reserve0, reserve1);
    }

}
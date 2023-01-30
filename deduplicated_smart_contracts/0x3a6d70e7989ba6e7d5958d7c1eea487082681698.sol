// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function renounceRole(bytes32 role, address account) public virtual override {
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
     * bearer except when using {AccessControl-_setupRole}.
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
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

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
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

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
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal initializer {
        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";

import "./interfaces/IUninterestedUnicorns.sol";
import "./interfaces/ICandyToken.sol";

contract UniQuest is
    AccessControlUpgradeable,
    ERC721HolderUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Quest {
        address questOwner;
        uint256 questLevel;
        uint256 questStart;
        uint256 questEnd;
        uint256 lastClaim;
        uint256 clanMultiplier;
        uint256 rareMultiplier;
        uint256 lengthMultiplier;
        uint256[] unicornIds;
        QuestState questState;
    }

    struct ClanCounter {
        uint8 airCount;
        uint8 earthCount;
        uint8 fireCount;
        uint8 waterCount;
        uint8 darkCount;
        uint8 pureCount;
    }

    // Enums
    enum Clans {
        AIR,
        EARTH,
        FIRE,
        WATER,
        DARK,
        PURE
    }

    enum QuestState {
        IN_PROGRESS,
        ENDED
    }

    IUninterestedUnicorns public UU;
    ICandyToken public UCD;

    uint256 public baseReward;
    uint256 public baseRoboReward;
    uint256 public baseGoldenReward;
    uint256 private timescale;

    uint256[] public clanMultipliers;
    uint256[] public rareMultipliers;
    uint256[] public lengthMultipliers;
    uint256[] public questLengths;
    bytes public clans;

    mapping(uint256 => Quest) public quests;
    mapping(address => uint256[]) public userQuests; // Maps user address to questIds
    mapping(uint256 => uint256) public onQuest; // Maps tokenId to QuestId (0 = not questing)
    mapping(uint256 => uint256) clanCounter;

    mapping(uint256 => bool) private isRoboUni;
    mapping(uint256 => bool) private isGoldenUni;
    mapping(uint256 => uint256) private HODLLastClaim;

    // Private Variables
    CountersUpgradeable.Counter private _questId;
    bool private initialized;

    // Reserve Storage
    uint256[50] private ______gap;

    // Events
    event QuestStarted(
        address indexed user,
        uint256 questId,
        uint256[] unicornIds,
        uint256 questLevel,
        uint256 questStart,
        uint256 questEnd
    );
    event QuestEnded(address indexed user, uint256 questId, uint256 endDate);
    event RewardClaimed(
        address indexed user,
        uint256 amount,
        uint256 claimTime
    );

    // Modifiers
    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "UninterestedUnicorns: OnlyAdmin"
        );
        _;
    }

    function __UniQuest_init(
        address uu,
        uint256 _baseReward,
        uint256 _baseRoboReward,
        uint256 _baseGoldenReward,
        address deployer,
        address treasury
    ) public initializer {
        require(!initialized, "Contract instance has already been initialized");
        __AccessControl_init();
        __ReentrancyGuard_init();
        __ERC721Holder_init();

        // Constructor init
        _setupRole(DEFAULT_ADMIN_ROLE, deployer); // To revoke access after functions are set
        grantRole(DEFAULT_ADMIN_ROLE, treasury);
        baseReward = _baseReward;
        baseRoboReward = _baseRoboReward;
        baseGoldenReward = _baseGoldenReward;
        UU = IUninterestedUnicorns(uu);
        clanMultipliers = [10000, 10000, 10200, 10400, 10600, 11000];
        rareMultipliers = [10000, 10200, 10400, 10600, 10800, 11000];
        lengthMultipliers = [10000, 10500, 11000];
        questLengths = [30 days, 90 days, 180 days];
        timescale = 1 days;

        initialized = true;
    }

    // ------------------------- USER FUNCTION ---------------------------

    /// @dev Start quest. questLevels = 0,1,2
    /// @notice Sends U_Us (max. 5) on a quest, U_Us of the same clan and if rare will get a bonus multiplier!
    function startQuest(uint256[] memory unicornIds, uint256 questLevel)
        public
    {
        require(
            areAvailiable(unicornIds),
            "UniQuest: One or More Unicorns are already on a Quest"
        );

        require(
            areOwned(unicornIds),
            "UniQuest: One or More Unicorns are not owned by you!"
        );

        require(questLevel <= 2, "UniQuest: Invalid Quest Level!");
        require(unicornIds.length <= 5, "UniQuest: Maximum of 5 U_U only!");
        require(unicornIds.length > 0, "UniQuest: At least 1 U_U required!");

        _questId.increment();
        _lockTokens(unicornIds);

        for (uint256 i = 0; i < unicornIds.length; i++) {
            onQuest[unicornIds[i]] = _questId.current();
        }

        uint256 _clanMultiplier;
        uint256 _rareMultiplier;

        (_clanMultiplier, _rareMultiplier) = calculateMultipliers(unicornIds);

        Quest memory _quest = Quest(
            msg.sender, // address questOwner
            questLevel, // uint256 questLevel;
            block.timestamp, // uint256 questStart;
            block.timestamp.add(questLengths[questLevel]), // uint256 questEnd;
            block.timestamp, // uint256 lastClaim;
            _clanMultiplier, // uint256 clanMultiplier;
            _rareMultiplier, // uint256 rareMultiplier;
            lengthMultipliers[questLevel], // uint256 lengthMultiplier;
            unicornIds, // uint256[] unicornIds;
            QuestState.IN_PROGRESS // QuestState questState;
        );

        quests[_questId.current()] = _quest;
        userQuests[msg.sender].push(_questId.current());

        emit QuestStarted(
            msg.sender,
            _questId.current(),
            unicornIds,
            questLevel,
            block.timestamp,
            block.timestamp.add(questLengths[questLevel])
        );
    }

    /// @dev Claim UCD reward for given quest
    function claimRewards(uint256 questId) public nonReentrant {
        Quest storage quest = quests[questId];
        address questOwner = quest.questOwner;
        require(
            msg.sender == questOwner,
            "UniQuest: Only quest owner can claim candy"
        );
        require(
            quest.questState == QuestState.IN_PROGRESS,
            "UniQuest: Quest has already ended!"
        );
        uint256 rewards = calculateRewards(questId);
        UCD.mint(questOwner, rewards);
        quest.lastClaim = block.timestamp;
        emit RewardClaimed(msg.sender, rewards, block.timestamp);
    }

    /// @dev QOL to claim all rewards
    function claimAllRewards() public nonReentrant {
        uint256[] memory questIds = getUserQuests(msg.sender);
        uint256 totalRewards = 0;
        Quest storage quest;

        for (uint256 i = 0; i < questIds.length; i++) {
            totalRewards = totalRewards.add(calculateRewards(questIds[i]));
            quest = quests[questIds[i]];
            quest.lastClaim = block.timestamp;
        }
        UCD.mint(msg.sender, totalRewards);
    }

    /// @dev Claim HODLing Rewards for owned pure U_Us
    /// @notice You can only claim HODL rewards for your owned pure U_Us
    function claimHODLRewards(uint256[] memory tokenIds) public nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                UU.ownerOf(tokenIds[i]) == msg.sender,
                "UniQuest: Not Owner of token"
            );
        }

        uint256 rewards = calculateHODLRewards(tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            HODLLastClaim[tokenIds[i]] = block.timestamp;
        }

        UCD.mint(msg.sender, rewards);
    }

    /// @dev Claim tokens and leave quest
    /// @notice End quest for U_Us. You will stop acumulating UCD.
    function endQuest(uint256 questId) public {
        // Only Quest Owner
        require(
            msg.sender == quests[questId].questOwner,
            "UniQuest: Not the owner of quest"
        );
        // Current Time > Quest End Time
        require(
            isQuestEndable(questId),
            "UniQuest: Unicorns are still questing!"
        );
        // Must be questing state
        require(
            quests[questId].questState == QuestState.IN_PROGRESS,
            "UniQuest: Quest already Ended"
        );

        // Distribute Remaining Rewards
        claimRewards(questId);

        // Unlock Tokens
        _unlockTokens(quests[questId].unicornIds);

        // Change Quest State such that further claims cannot be made
        quests[questId].questState = QuestState.ENDED;

        emit QuestEnded(msg.sender, questId, block.timestamp);
    }

    // ----------------------- View FUNCTIONS -----------------------

    /// @dev Determines if quest is ended
    function isQuestEndable(uint256 questId) public view returns (bool) {
        return block.timestamp > quests[questId].questEnd;
    }

    /// @dev Retrieves clan multiplier
    function getClanMultiplier(uint256 clanCount)
        public
        view
        returns (uint256)
    {
        return clanMultipliers[clanCount];
    }

    /// @dev Retrieves Rare multiplier
    function getRareMultiplier(uint256 rareCount)
        public
        view
        returns (uint256)
    {
        return rareMultipliers[rareCount];
    }

    /// @dev Retrieves Length multiplier
    function getLengthMultiplier(uint256 questLevel)
        public
        view
        returns (uint256)
    {
        return lengthMultipliers[questLevel];
    }

    /// @dev Calculates Clan Multiplier based on tokenIds
    function calculateMultipliers(uint256[] memory _tokenIds)
        internal
        view
        returns (uint256 _clanMultiplier, uint256 _rareMultiplier)
    {
        uint8[6] memory _clanCounter = [0, 0, 0, 0, 0, 0];
        uint8 maxCount = 0;
        uint8 maxIndex;
        uint256 rareCount = 0;

        // Count UU per clan
        for (uint8 i = 0; i < _tokenIds.length; i++) {
            _clanCounter[getClan(_tokenIds[i]) - 1] += 1;
        }

        // Find Maximum Count and Index of Max Count
        for (uint8 i = 0; i < _clanCounter.length; i++) {
            if (_clanCounter[i] > maxCount) {
                maxCount = _clanCounter[i];
                maxIndex = i;
            }
        }

        // Wildcard bonus
        if (maxIndex < 4) {
            maxCount += _clanCounter[5];
        }

        _clanMultiplier = getClanMultiplier(maxCount);

        rareCount = rareCount.add(_clanCounter[4]).add(_clanCounter[5]);
        _rareMultiplier = getRareMultiplier(rareCount);
    }

    /// @dev Calulate HODLing rewards for tokenIds given
    function calculateHODLRewards(uint256[] memory tokenIds)
        public
        view
        returns (uint256 HODLRewards)
    {
        HODLRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (isGoldenUni[tokenIds[i]]) {
                HODLRewards = HODLRewards.add(
                    baseGoldenReward.mul(calcGoldenDuration(tokenIds[i])).div(
                        timescale
                    )
                );
            } else if (isRoboUni[tokenIds[i]]) {
                HODLRewards = HODLRewards.add(
                    baseRoboReward.mul(calcRoboDuration(tokenIds[i])).div(
                        timescale
                    )
                );
            }
        }
    }

    /// @dev Calculate duration since last claim for golden U_Us
    function calcGoldenDuration(uint256 tokenId)
        private
        view
        returns (uint256)
    {
        return block.timestamp.sub(HODLLastClaim[tokenId]);
    }

    /// @dev Calculate duration since last claim for UniMech U_Us
    function calcRoboDuration(uint256 tokenId) private view returns (uint256) {
        return block.timestamp.sub(HODLLastClaim[tokenId]);
    }

    /// @dev Caluclate rewards for given Quest Id
    function calculateRewards(uint256 questId)
        public
        view
        returns (uint256 rewardAmount)
    {
        Quest memory quest = quests[questId];
        rewardAmount = baseReward
            .mul(block.timestamp.sub(quest.lastClaim))
            .mul(quest.unicornIds.length)
            .mul(quest.clanMultiplier)
            .mul(quest.rareMultiplier)
            .mul(quest.lengthMultiplier)
            .div(timescale)
            .div(1000000000000);
    }

    /// @dev Determines if the tokenIds are availiable for questing
    function areAvailiable(uint256[] memory tokenIds)
        public
        view
        returns (bool out)
    {
        out = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (onQuest[tokenIds[i]] > 0) {
                out = false;
            }
        }
    }

    /// @dev Determines if the all tokenIds are owned by msg sneder
    function areOwned(uint256[] memory tokenIds)
        public
        view
        returns (bool out)
    {
        out = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (UU.ownerOf(tokenIds[i]) != msg.sender) {
                out = false;
            }
        }
    }

    function getUserQuests(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userQuests[user];
    }

    function getQuest(uint256 questId) public view returns (Quest memory) {
        return quests[questId];
    }

    function isQuestOver(uint256 questId) public view returns (bool) {
        Quest memory quest = quests[questId];
        return block.timestamp > quest.questEnd;
    }

    function getClan(uint256 tokenId) public view returns (uint8) {
        return uint8(clans[tokenId - 1]);
    }

    // ---------------------- ADMIN FUNCTIONS -----------------------

    function setBaseReward(uint256 _amount) public onlyAdmin {
        baseReward = _amount;
    }

    function setRoboReward(uint256 _amount) public onlyAdmin {
        baseRoboReward = _amount;
    }

    function setGoldenReward(uint256 _amount) public onlyAdmin {
        baseGoldenReward = _amount;
    }

    /// @dev Storing Clan Metadata as 1 byte hexes on a byte for gas optimization
    function setRoboIds(uint256[] memory _roboTokenIds) public onlyAdmin {
        for (uint256 i = 0; i < _roboTokenIds.length; i++) {
            isRoboUni[_roboTokenIds[i]] = true;
            HODLLastClaim[_roboTokenIds[i]] = block.timestamp;
        }
    }

    /// @dev Storing Clan Metadata as 1 byte hexes on a byte for gas optimization
    function setGoldenIds(uint256[] memory _goldenTokenIds) public onlyAdmin {
        for (uint256 i = 0; i < _goldenTokenIds.length; i++) {
            isGoldenUni[_goldenTokenIds[i]] = true;
            HODLLastClaim[_goldenTokenIds[i]] = block.timestamp;
        }
    }

    /// @dev Storing Clan Metadata as 1 byte hexes on a byte for gas optimization
    function updateClans(bytes calldata _clans) public onlyAdmin {
        clans = _clans;
    }

    function setUniCandy(address uniCandy) public onlyAdmin {
        UCD = ICandyToken(uniCandy);
    }

    function setTimeScale(uint256 _newTimescale) public onlyAdmin {
        timescale = _newTimescale;
    }

    function setQuestLengths(uint256[] memory _newQuestLengths)
        public
        onlyAdmin
    {
        questLengths = _newQuestLengths;
    }

    function _lockTokens(uint256[] memory tokenIds) private {
        for (uint256 i; i < tokenIds.length; i++) {
            UU.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
    }

    function _unlockTokens(uint256[] memory tokenIds) private {
        for (uint256 i; i < tokenIds.length; i++) {
            UU.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
            // reset last claim for HODL rewards
            HODLLastClaim[tokenIds[i]] = block.timestamp;
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICandyToken is IERC20 {
    function updateRewardOnMint(address _user, uint256 _amount) external;

    function updateReward(address _from, address _to) external;

    function getReward(address _to) external;

    function burn(address _from, uint256 _amount) external;

    function mint(address to, uint256 amount) external;

    function getTotalClaimable(address _user) external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IUninterestedUnicorns is IERC721 {
    function mint(uint256 _quantity) external payable;

    function getPrice(uint256 _quantity) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function lockTokens(uint8[] memory tokenId) external;

    function unlockTokens(uint8[] memory tokenId) external;
}
/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

library Exclusive {
    struct RoleMembership {
        address member;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.member == memberToCheck;
    }

    function resetMember(RoleMembership storage roleMembership, address newMember) internal {
        require(newMember != address(0x0), "Cannot set an exclusive role to 0x0");
        roleMembership.member = newMember;
    }

    function getMember(RoleMembership storage roleMembership) internal view returns (address) {
        return roleMembership.member;
    }

    function init(RoleMembership storage roleMembership, address initialMember) internal {
        resetMember(roleMembership, initialMember);
    }
}

library Shared {
    struct RoleMembership {
        mapping(address => bool) members;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.members[memberToCheck];
    }

    function addMember(RoleMembership storage roleMembership, address memberToAdd) internal {
        roleMembership.members[memberToAdd] = true;
    }

    function removeMember(RoleMembership storage roleMembership, address memberToRemove) internal {
        roleMembership.members[memberToRemove] = false;
    }

    function init(RoleMembership storage roleMembership, address[] memory initialMembers) internal {
        for (uint i = 0; i < initialMembers.length; i++) {
            addMember(roleMembership, initialMembers[i]);
        }
    }
}

contract MultiRole {
    using Exclusive for Exclusive.RoleMembership;
    using Shared for Shared.RoleMembership;

    enum RoleType { Invalid, Exclusive, Shared }

    struct Role {
        uint managingRole;
        RoleType roleType;
        Exclusive.RoleMembership exclusiveRoleMembership;
        Shared.RoleMembership sharedRoleMembership;
    }

    mapping(uint => Role) private roles;

    /**
     * @notice Reverts unless the caller is a member of the specified roleId.
     */
    modifier onlyRoleHolder(uint roleId) {
        require(holdsRole(roleId, msg.sender), "Sender does not hold required role");
        _;
    }

    /**
     * @notice Reverts unless the caller is a member of the manager role for the specified roleId.
     */
    modifier onlyRoleManager(uint roleId) {
        require(holdsRole(roles[roleId].managingRole, msg.sender), "Can only be called by a role manager");
        _;
    }

    /**
     * @notice Reverts unless the roleId represents an initialized, exclusive roleId.
     */
    modifier onlyExclusive(uint roleId) {
        require(roles[roleId].roleType == RoleType.Exclusive, "Must be called on an initialized Exclusive role");
        _;
    }

    /**
     * @notice Reverts unless the roleId represents an initialized, shared roleId.
     */
    modifier onlyShared(uint roleId) {
        require(roles[roleId].roleType == RoleType.Shared, "Must be called on an initialized Shared role");
        _;
    }

    /**
     * @notice Whether `memberToCheck` is a member of roleId.
     * @dev Reverts if roleId does not correspond to an initialized role.
     */
    function holdsRole(uint roleId, address memberToCheck) public view returns (bool) {
        Role storage role = roles[roleId];
        if (role.roleType == RoleType.Exclusive) {
            return role.exclusiveRoleMembership.isMember(memberToCheck);
        } else if (role.roleType == RoleType.Shared) {
            return role.sharedRoleMembership.isMember(memberToCheck);
        }
        require(false, "Invalid roleId");
    }

    /**
     * @notice Changes the exclusive role holder of `roleId` to `newMember`.
     * @dev Reverts if the caller is not a member of the managing role for `roleId` or if `roleId` is not an
     * initialized, exclusive role.
     */
    function resetMember(uint roleId, address newMember) public onlyExclusive(roleId) onlyRoleManager(roleId) {
        roles[roleId].exclusiveRoleMembership.resetMember(newMember);
    }

    /**
     * @notice Gets the current holder of the exclusive role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, exclusive role.
     */
    function getMember(uint roleId) public view onlyExclusive(roleId) returns (address) {
        return roles[roleId].exclusiveRoleMembership.getMember();
    }

    /**
     * @notice Adds `newMember` to the shared role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, shared role or if the caller is not a member of the
     * managing role for `roleId`.
     */
    function addMember(uint roleId, address newMember) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.addMember(newMember);
    }

    /**
     * @notice Removes `memberToRemove` from the shared role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, shared role or if the caller is not a member of the
     * managing role for `roleId`.
     */
    function removeMember(uint roleId, address memberToRemove) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.removeMember(memberToRemove);
    }

    /**
     * @notice Reverts if `roleId` is not initialized.
     */
    modifier onlyValidRole(uint roleId) {
        require(roles[roleId].roleType != RoleType.Invalid, "Attempted to use an invalid roleId");
        _;
    }

    /**
     * @notice Reverts if `roleId` is initialized.
     */
    modifier onlyInvalidRole(uint roleId) {
        require(roles[roleId].roleType == RoleType.Invalid, "Cannot use a pre-existing role");
        _;
    }

    /**
     * @notice Internal method to initialize a shared role, `roleId`, which will be managed by `managingRoleId`.
     * `initialMembers` will be immediately added to the role.
     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already
     * initialized.
     */
    function _createSharedRole(uint roleId, uint managingRoleId, address[] memory initialMembers)
        internal
        onlyInvalidRole(roleId)
    {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Shared;
        role.managingRole = managingRoleId;
        role.sharedRoleMembership.init(initialMembers);
        require(roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage a shared role");
    }

    /**
     * @notice Internal method to initialize a exclusive role, `roleId`, which will be managed by `managingRoleId`.
     * `initialMembers` will be immediately added to the role.
     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already
     * initialized.
     */
    function _createExclusiveRole(uint roleId, uint managingRoleId, address initialMember)
        internal
        onlyInvalidRole(roleId)
    {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Exclusive;
        role.managingRole = managingRoleId;
        role.exclusiveRoleMembership.init(initialMember);
        require(roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage an exclusive role");
    }
}

interface RegistryInterface {
    /**
     * @dev Registers a new derivative. Only authorized derivative creators can call this method.
     */
    function registerDerivative(address[] calldata counterparties, address derivativeAddress) external;

    /**
     * @dev Returns whether the derivative has been registered with the registry (and is therefore an authorized.
     * participant in the UMA system).
     */
    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered);

    /**
     * @dev Returns a list of all derivatives that are associated with a particular party.
     */
    function getRegisteredDerivatives(address party) external view returns (address[] memory derivatives);

    /**
     * @dev Returns all registered derivatives.
     */
    function getAllRegisteredDerivatives() external view returns (address[] memory derivatives);
}

contract Registry is RegistryInterface, MultiRole {

    using SafeMath for uint;

    enum Roles {
        // The owner manages the set of DerivativeCreators.
        Owner,
        // Can register derivatives.
        DerivativeCreator
    }

    // Array of all derivatives that are approved to use the UMA Oracle.
    address[] private registeredDerivatives;

    // This enum is required because a WasValid state is required to ensure that derivatives cannot be re-registered.
    enum PointerValidity {
        Invalid,
        Valid
    }

    struct Pointer {
        PointerValidity valid;
        uint128 index;
    }

    // Maps from derivative address to a pointer that refers to that registered derivative in `registeredDerivatives`.
    mapping(address => Pointer) private derivativePointers;

    // Note: this must be stored outside of `registeredDerivatives` because mappings cannot be deleted and copied
    // like normal data. This could be stored in the Pointer struct, but storing it there would muddy the purpose
    // of the Pointer struct and break separation of concern between referential data and data.
    struct PartiesMap {
        mapping(address => bool) parties;
    }

    // Maps from derivative address to the set of parties that are involved in that derivative.
    mapping(address => PartiesMap) private derivativesToParties;

    event NewDerivativeRegistered(address indexed derivativeAddress, address indexed creator, address[] parties);

    constructor() public {
        _createExclusiveRole(uint(Roles.Owner), uint(Roles.Owner), msg.sender);
        // Start with no derivative creators registered.
        _createSharedRole(uint(Roles.DerivativeCreator), uint(Roles.Owner), new address[](0));
    }

    function registerDerivative(address[] calldata parties, address derivativeAddress)
        external
        onlyRoleHolder(uint(Roles.DerivativeCreator))
    {
        // Create derivative pointer.
        Pointer storage pointer = derivativePointers[derivativeAddress];

        // Ensure that the pointer was not valid in the past (derivatives cannot be re-registered or double
        // registered).
        require(pointer.valid == PointerValidity.Invalid);
        pointer.valid = PointerValidity.Valid;

        registeredDerivatives.push(derivativeAddress);

        // No length check necessary because we should never hit (2^127 - 1) derivatives.
        pointer.index = uint128(registeredDerivatives.length.sub(1));

        // Set up PartiesMap for this derivative.
        PartiesMap storage partiesMap = derivativesToParties[derivativeAddress];
        for (uint i = 0; i < parties.length; i = i.add(1)) {
            partiesMap.parties[parties[i]] = true;
        }

        address[] memory partiesForEvent = parties;
        emit NewDerivativeRegistered(derivativeAddress, msg.sender, partiesForEvent);
    }

    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered) {
        return derivativePointers[derivative].valid == PointerValidity.Valid;
    }

    function getRegisteredDerivatives(address party) external view returns (address[] memory derivatives) {
        // This is not ideal - we must statically allocate memory arrays. To be safe, we make a temporary array as long
        // as registeredDerivatives. We populate it with any derivatives that involve the provided party. Then, we copy
        // the array over to the return array, which is allocated using the correct size. Note: this is done by double
        // copying each value rather than storing some referential info (like indices) in memory to reduce the number
        // of storage reads. This is because storage reads are far more expensive than extra memory space (~100:1).
        address[] memory tmpDerivativeArray = new address[](registeredDerivatives.length);
        uint outputIndex = 0;
        for (uint i = 0; i < registeredDerivatives.length; i = i.add(1)) {
            address derivative = registeredDerivatives[i];
            if (derivativesToParties[derivative].parties[party]) {
                // Copy selected derivative to the temporary array.
                tmpDerivativeArray[outputIndex] = derivative;
                outputIndex = outputIndex.add(1);
            }
        }

        // Copy the temp array to the return array that is set to the correct size.
        derivatives = new address[](outputIndex);
        for (uint j = 0; j < outputIndex; j = j.add(1)) {
            derivatives[j] = tmpDerivativeArray[j];
        }
    }

    function getAllRegisteredDerivatives() external view returns (address[] memory derivatives) {
        return registeredDerivatives;
    }
}

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
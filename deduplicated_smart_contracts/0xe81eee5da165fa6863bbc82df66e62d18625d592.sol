/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

contract EncryptedSender {
    struct TopicData {
        // An (optional) public key used to encrypt messages for this topic. This is only necessary if the sender will
        // not have access to the public key offchain.
        bytes publicKey;

        // The encrypted message.
        bytes message;
    }

    struct Recipient {
        // This maps from a hash to the data for this topic.
        // Note: the hash is a hash of the "subject" or "topic" of the message.
        mapping(bytes32 => TopicData) topics;

        // This contains the set of all authorized senders for this recipient.
        mapping(address => bool) authorizedSenders;
    }

    mapping(address => Recipient) private recipients;

    /**
     * @notice Authorizes `sender` to send messages to the caller.
     */
    function addAuthorizedSender(address sender) external {
        recipients[msg.sender].authorizedSenders[sender] = true;
    }

    /**
     * @notice Revokes `sender`'s authorization to send messages to the caller.
     */
    function removeAuthorizedSender(address sender) external {
        recipients[msg.sender].authorizedSenders[sender] = false;
    }

    /**
     * @notice Gets the current stored message corresponding to `recipient` and `topicHash`.
     * @dev To decrypt messages (this requires access to the recipient's private keys), use the decryptMessage()
     * function in common/Crypto.js.
     */
    function getMessage(address recipient, bytes32 topicHash) external view returns (bytes memory) {
        return recipients[recipient].topics[topicHash].message;
    }

    /**
     * @notice Gets the stored public key for a particular `recipient` and `topicHash`. Return value will be 0 length
     * if no public key has been set.
     * @dev Senders may need this public key to encrypt messages that only the `recipient` can read. If the public key
     * is communicated offchain, this field may be left empty.
     */
    function getPublicKey(address recipient, bytes32 topicHash) external view returns (bytes memory) {
        return recipients[recipient].topics[topicHash].publicKey;
    }

    /**
     * @notice Sends `message` to `recipient_` categorized by a particular `topicHash`. This will overwrite any
     * previous messages sent to this `recipient` with this `topicHash`.
     * @dev To construct an encrypted message, use the encryptMessage() in common/Crypto.js.
     * The public key for the recipient can be obtained using the getPublicKey() method.
     */
    function sendMessage(address recipient_, bytes32 topicHash, bytes memory message) public {
        Recipient storage recipient = recipients[recipient_];
        require(isAuthorizedSender(msg.sender, recipient_), "Not authorized to send to this recipient");
        recipient.topics[topicHash].message = message;
    }

    function removeMessage(address recipient_, bytes32 topicHash) public {
        Recipient storage recipient = recipients[recipient_];
        require(isAuthorizedSender(msg.sender, recipient_), "Not authorized to remove message");
        delete recipient.topics[topicHash].message;
    }

    /**
     * @notice Sets the public key for this caller and topicHash.
     * @dev Note: setting the public key is optional - if the publicKey is communicated or can be derived offchain by
     * the sender, there is no need to set it here. Because there are no specific requirements for the publicKey, there
     * is also no verification of its validity other than its length.
     */
    function setPublicKey(bytes memory publicKey, bytes32 topicHash) public {
        require(publicKey.length == 64, "Public key is the wrong length");
        recipients[msg.sender].topics[topicHash].publicKey = publicKey;
    }

    /**
     * @notice Returns true if the `sender` is authorized to send to the `recipient`.
     */
    function isAuthorizedSender(address sender, address recipient) public view returns (bool) {
        // Note: the recipient is always authorized to send messages to themselves.
        return recipients[recipient].authorizedSenders[sender] || recipient == sender;
    }
}

library FixedPoint {

    using SafeMath for uint;

    // Supports 18 decimals. E.g., 1e18 represents "1", 5e17 represents "0.5".
    // Can represent a value up to (2^256 - 1)/10^18 = ~10^59. 10^59 will be stored internally as uint 10^77.
    uint private constant FP_SCALING_FACTOR = 10**18;

    struct Unsigned {
        uint rawValue;
    }

    /** @dev Constructs an `Unsigned` from an unscaled uint, e.g., `b=5` gets stored internally as `5**18`. */
    function fromUnscaledUint(uint a) internal pure returns (Unsigned memory) {
        return Unsigned(a.mul(FP_SCALING_FACTOR));
    }

    /** @dev Whether `a` is greater than `b`. */
    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
        return a.rawValue > b.rawValue;
    }

    /** @dev Whether `a` is greater than `b`. */
    function isGreaterThan(Unsigned memory a, uint b) internal pure returns (bool) {
        return a.rawValue > fromUnscaledUint(b).rawValue;
    }

    /** @dev Whether `a` is greater than `b`. */
    function isGreaterThan(uint a, Unsigned memory b) internal pure returns (bool) {
        return fromUnscaledUint(a).rawValue > b.rawValue;
    }

    /** @dev Whether `a` is less than `b`. */
    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {
        return a.rawValue < b.rawValue;
    }

    /** @dev Whether `a` is less than `b`. */
    function isLessThan(Unsigned memory a, uint b) internal pure returns (bool) {
        return a.rawValue < fromUnscaledUint(b).rawValue;
    }

    /** @dev Whether `a` is less than `b`. */
    function isLessThan(uint a, Unsigned memory b) internal pure returns (bool) {
        return fromUnscaledUint(a).rawValue < b.rawValue;
    }

    /** @dev Adds two `Unsigned`s, reverting on overflow. */
    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
        return Unsigned(a.rawValue.add(b.rawValue));
    }

    /** @dev Adds an `Unsigned` to an unscaled uint, reverting on overflow. */
    function add(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {
        return add(a, fromUnscaledUint(b));
    }

    /** @dev Subtracts two `Unsigned`s, reverting on underflow. */
    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
        return Unsigned(a.rawValue.sub(b.rawValue));
    }

    /** @dev Subtracts an unscaled uint from an `Unsigned`, reverting on underflow. */
    function sub(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {
        return sub(a, fromUnscaledUint(b));
    }

    /** @dev Subtracts an `Unsigned` from an unscaled uint, reverting on underflow. */
    function sub(uint a, Unsigned memory b) internal pure returns (Unsigned memory) {
        return sub(fromUnscaledUint(a), b);
    }

    /** @dev Multiplies two `Unsigned`s, reverting on overflow. */
    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
        // There are two caveats with this computation:
        // 1. Max output for the represented number is ~10^41, otherwise an intermediate value overflows. 10^41 is
        // stored internally as a uint ~10^59.
        // 2. Results that can't be represented exactly are truncated not rounded. E.g., 1.4 * 2e-18 = 2.8e-18, which
        // would round to 3, but this computation produces the result 2.
        // No need to use SafeMath because FP_SCALING_FACTOR != 0.
        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
    }

    /** @dev Multiplies an `Unsigned` by an unscaled uint, reverting on overflow. */
    function mul(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {
        return Unsigned(a.rawValue.mul(b));
    }

    /** @dev Divides with truncation two `Unsigned`s, reverting on overflow or division by 0. */
    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {
        // There are two caveats with this computation:
        // 1. Max value for the number dividend `a` represents is ~10^41, otherwise an intermediate value overflows.
        // 10^41 is stored internally as a uint 10^59.
        // 2. Results that can't be represented exactly are truncated not rounded. E.g., 2 / 3 = 0.6 repeating, which
        // would round to 0.666666666666666667, but this computation produces the result 0.666666666666666666.
        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
    }

    /** @dev Divides with truncation an `Unsigned` by an unscaled uint, reverting on division by 0. */
    function div(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {
        return Unsigned(a.rawValue.div(b));
    }

    /** @dev Divides with truncation an unscaled uint by an `Unsigned`, reverting on overflow or division by 0. */
    function div(uint a, Unsigned memory b) internal pure returns (Unsigned memory) {
        return div(fromUnscaledUint(a), b);
    }

    /** @dev Raises an `Unsigned` to the power of an unscaled uint, reverting on overflow. E.g., `b=2` squares `a`. */
    function pow(Unsigned memory a, uint b) internal pure returns (Unsigned memory output) {
        // TODO(ptare): Consider using the exponentiation by squaring technique instead:
        // https://en.wikipedia.org/wiki/Exponentiation_by_squaring
        output = fromUnscaledUint(1);
        for (uint i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }
}

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

interface OracleInterface {

    /**
     * @notice Enqueues a request (if a request isn't already present) for the given `identifier`, `time` pair.
     * @dev Returns the time at which the user should expect the price to be resolved. 0 means the price has already
     * been resolved.
     */
    function requestPrice(bytes32 identifier, uint time) external returns (uint expectedTime);

    /**
     * @notice Whether the Oracle provides prices for this identifier.
     */
    function isIdentifierSupported(bytes32 identifier) external view returns (bool);

    /**
     * @notice Whether the price for `identifier` and `time` is available.
     */
    function hasPrice(bytes32 identifier, uint time) external view returns (bool);

    /**
     * @notice Gets the price for `identifier` and `time` if it has already been requested and resolved.
     * @dev If the price is not available, the method reverts.
     */
    function getPrice(bytes32 identifier, uint time) external view returns (int price);
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

library ResultComputation {

    using FixedPoint for FixedPoint.Unsigned;

    struct Data {
        // Maps price to number of tokens that voted for that price.
        mapping(int => FixedPoint.Unsigned) voteFrequency;
        // The total votes that have been added.
        FixedPoint.Unsigned totalVotes;
        // The price that is the current mode, i.e., the price with the highest frequency in `voteFrequency`.
        int currentMode;
    }

    /**
     * @dev Returns whether the result is resolved, and if so, what value it resolved to. `price` should be ignored if
     * `isResolved` is false.
     * @param minVoteThreshold Minimum number of tokens that must have been voted for the result to be valid. Can be
     * used to enforce a minimum voter participation rate, regardless of how the votes are distributed.
     */
    function getResolvedPrice(Data storage data, FixedPoint.Unsigned memory minVoteThreshold)
        internal
        view
        returns (bool isResolved, int price)
    {
        // TODO(ptare): Figure out where this parameter is supposed to come from.
        FixedPoint.Unsigned memory modeThreshold = FixedPoint.fromUnscaledUint(50).div(100);

        if (data.totalVotes.isGreaterThan(minVoteThreshold) &&
            data.voteFrequency[data.currentMode].div(data.totalVotes).isGreaterThan(modeThreshold)) {
            // `modeThreshold` and `minVoteThreshold` are met, so the current mode is the resolved price.
            isResolved = true;
            price = data.currentMode;
        } else {
            isResolved = false;
        }
    }

    /**
     * @dev Adds a new vote to be used when computing the result.
     */
    function addVote(Data storage data, int votePrice, FixedPoint.Unsigned memory numberTokens)
        internal
    {
        data.totalVotes = data.totalVotes.add(numberTokens);
        data.voteFrequency[votePrice] = data.voteFrequency[votePrice].add(numberTokens);
        if (votePrice != data.currentMode
            && data.voteFrequency[votePrice].isGreaterThan(data.voteFrequency[data.currentMode])) {
            data.currentMode = votePrice;
        }
    }

    /**
     * @dev Checks whether a `voteHash` is considered correct. Should only be called after a vote is resolved, i.e.,
     * via `getResolvedPrice`.
     */
    function wasVoteCorrect(Data storage data, bytes32 voteHash) internal view returns (bool) {
        return voteHash == keccak256(abi.encode(data.currentMode));
    }

    /**
     * @dev Gets the total number of tokens whose votes are considered correct. Should only be called after a vote is
     * resolved, i.e., via `getResolvedPrice`.
     */
    function getTotalCorrectlyVotedTokens(Data storage data)
        internal
        view
        returns (FixedPoint.Unsigned memory)
    {
        return data.voteFrequency[data.currentMode];
    }
}

contract Testable {
    // Is the contract being run on the test network. Note: this variable should be set on construction and never
    // modified.
    bool public isTest;

    uint private currentTime;

    constructor(bool _isTest) internal {
        isTest = _isTest;
        if (_isTest) {
            currentTime = now; // solhint-disable-line not-rely-on-time
        }
    }

    /**
     * @notice Reverts if not running in test mode.
     */
    modifier onlyIfTest {
        require(isTest);
        _;
    }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     */
    function setCurrentTime(uint _time) external onlyIfTest {
        currentTime = _time;
    }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     */
    function getCurrentTime() public view returns (uint) {
        if (isTest) {
            return currentTime;
        } else {
            return now; // solhint-disable-line not-rely-on-time
        }
    }
}

library VoteTiming {
    using SafeMath for uint;

    // Note: the phases must be in order. Meaning the first enum value must be the first phase, etc.
    enum Phase {
        Commit,
        Reveal
    }

    // Note: this MUST match the number of values in the enum above.
    uint private constant NUM_PHASES = 2;

    struct Data {
        uint roundId;
        uint roundStartTime;
        uint phaseLength;
    }

    /**
     * @notice Initializes the data object. Sets the phase length based on the input and resets the round id and round
     * start time to 1 and 0 respectively.
     * @dev This method should generally only be run once, but it can also be used to reset the data structure to its
     * initial values.
     */
    function init(Data storage data, uint phaseLength) internal {
        data.phaseLength = phaseLength;
        data.roundId = 1;
        data.roundStartTime = 0;
    }

    /**
     * @notice Gets the most recently stored round ID set by updateRoundId().
     */
    function getLastUpdatedRoundId(Data storage data) internal view returns (uint) {
        return data.roundId;
    }

    /**
     * @notice Determines whether time has advanced far enough to advance to the next voting round and update the
     * stored round id.
     */
    function shouldUpdateRoundId(Data storage data, uint currentTime) internal view returns (bool) {
        (uint roundId,) = _getCurrentRoundIdAndStartTime(data, currentTime);
        return data.roundId != roundId;
    }

    /**
     * @notice Updates the round id. Note: if shouldUpdateRoundId() returns false, this method will have no effect.
     */
    function updateRoundId(Data storage data, uint currentTime) internal {
        (data.roundId, data.roundStartTime) = _getCurrentRoundIdAndStartTime(data, currentTime);
    }

    /**
     * @notice Computes what the stored round id would be if it were updated right now, but this method does not
     * commit the update.
     */
    function computeCurrentRoundId(Data storage data, uint currentTime) internal view returns (uint roundId) {
        (roundId,) = _getCurrentRoundIdAndStartTime(data, currentTime);
    }

    /**
     * @notice Computes the current phase based only on the current time.
     */
    function computeCurrentPhase(Data storage data, uint currentTime) internal view returns (Phase) {
        // This employs some hacky casting. We could make this an if-statement if we're worried about type safety.
        return Phase(currentTime.div(data.phaseLength).mod(NUM_PHASES));
    }

    /**
     * @notice Gets the end time of the current round or any round in the future. Note: this method will revert if
     * the roundId < getLastUpdatedRoundId().
     */
    function computeEstimatedRoundEndTime(Data storage data, uint roundId) internal view returns (uint) {
        // The add(1) is because we want the round end time rather than the start time, so it's really the start of
        // the next round.
        uint roundDiff = roundId.sub(data.roundId).add(1);
        uint roundLength = data.phaseLength.mul(NUM_PHASES);
        return data.roundStartTime.add(roundDiff.mul(roundLength));
    }

    /**
     * @dev Computes an updated round id and round start time based on the current time.
     */
    function _getCurrentRoundIdAndStartTime(Data storage data, uint currentTime)
        private
        view
        returns (uint roundId, uint startTime)
    {
        uint currentStartTime = data.roundStartTime;
        // Return current data if time has moved backwards.
        if (currentTime <= data.roundStartTime) {
            return (data.roundId, data.roundStartTime);
        }

        // Get the start of the round that currentTime would be a part of by flooring by roundLength.
        uint roundLength = data.phaseLength.mul(NUM_PHASES);
        startTime = currentTime.div(roundLength).mul(roundLength);

        // Only increment the round ID if the start time has changed.
        if (startTime > currentStartTime) {
            roundId = data.roundId.add(1);
        } else {
            roundId = data.roundId;
        }
    }
}

contract VotingInterface {
    struct PendingRequest {
        bytes32 identifier;
        uint time;
    }

    /**
     * @notice Commit your vote for a price request for `identifier` at `time`.
     * @dev (`identifier`, `time`) must correspond to a price request that's currently in the commit phase. `hash`
     * should be the keccak256 hash of the price you want to vote for and a `int salt`. Commits can be changed.
     */
    function commitVote(bytes32 identifier, uint time, bytes32 hash) external;

    /**
     * @notice Reveal a previously committed vote for `identifier` at `time`.
     * @dev The revealed `price` and `salt` must match the latest `hash` that `commitVote()` was called with. Only the
     * committer can reveal their vote.
     */
    function revealVote(bytes32 identifier, uint time, int price, int salt) external;

    /**
     * @notice Gets the queries that are being voted on this round.
     */
    function getPendingRequests() external view returns (PendingRequest[] memory);

    /**
     * @notice Gets the current vote phase (commit or reveal) based on the current block time.
     */
    function getVotePhase() external view returns (VoteTiming.Phase);

    /**
     * @notice Gets the current vote round id based on the current block time.
     */
    function getCurrentRoundId() external view returns (uint);

    /**
     * @notice Retrieves rewards owed for a set of resolved price requests.
     */
    function retrieveRewards(address voterAddress, uint roundId, PendingRequest[] memory) public returns
    (FixedPoint.Unsigned memory);
}

contract Withdrawable is MultiRole {

    uint private _roleId;

    /**
     * @notice Withdraws ETH from the contract.
     */
    function withdraw(uint amount) external onlyRoleHolder(_roleId) {
        msg.sender.transfer(amount);
    }

    /**
     * @notice Withdraws ERC20 tokens from the contract.
     */
    function withdrawErc20(address erc20Address, uint amount) external onlyRoleHolder(_roleId) {
        IERC20 erc20 = IERC20(erc20Address);
        require(erc20.transfer(msg.sender, amount));
    }

    /**
     * @notice Internal method that allows derived contracts to create a role for withdrawal.
     * @dev Either this method or `setWithdrawRole` must be called by the derived class for this contract to function
     * properly.
     */
    function createWithdrawRole(uint roleId, uint managingRoleId, address owner) internal {
        _roleId = roleId;
        _createExclusiveRole(roleId, managingRoleId, owner);
    }

    /**
     * @notice Internal method that allows derived contracts to choose the role for withdrawal.
     * @dev The role `roleId` must exist. Either this method or `createWithdrawRole` must be called by the derived class
     * for this contract to function properly.
     */
    function setWithdrawRole(uint roleId) internal {
        _roleId = roleId;
    }
}

contract DesignatedVoting is MultiRole, Withdrawable {

    enum Roles {
        // Can set the Voter and Withdrawer roles.
        Owner,
        // Can vote through this contract.
        Voter
    }

    // Reference to the UMA Finder contract, allowing Voting upgrades to be performed without requiring any calls to
    // this contract.
    Finder private finder;

    constructor(address finderAddress, address ownerAddress, address voterAddress) public {
        _createExclusiveRole(uint(Roles.Owner), uint(Roles.Owner), ownerAddress);
        _createExclusiveRole(uint(Roles.Voter), uint(Roles.Owner), voterAddress);
        setWithdrawRole(uint(Roles.Owner));

        finder = Finder(finderAddress);
    }

    /**
     * @notice Forwards a commit to Voting.
     */
    function commitVote(bytes32 identifier, uint time, bytes32 hash) external onlyRoleHolder(uint(Roles.Voter)) {
        _getVotingAddress().commitVote(identifier, time, hash);
    }

    /**
     * @notice Forwards a batch commit to Voting.
     */
    function batchCommit(Voting.Commitment[] calldata commits) external onlyRoleHolder(uint(Roles.Voter)) {
        _getVotingAddress().batchCommit(commits);
    }

    /**
     * @notice Forwards a reveal to Voting.
     */
    function revealVote(bytes32 identifier, uint time, int price, int salt) external onlyRoleHolder(uint(Roles.Voter)) {
        _getVotingAddress().revealVote(identifier, time, price, salt);
    }

    /**
     * @notice Forwards a batch reveal to Voting.
     */
    function batchReveal(Voting.Reveal[] calldata reveals) external onlyRoleHolder(uint(Roles.Voter)) {
        _getVotingAddress().batchReveal(reveals);
    }

    /**
     * @notice Forwards a reward retrieval to Voting.
     */
    function retrieveRewards(uint roundId, VotingInterface.PendingRequest[] memory toRetrieve)
        public
        onlyRoleHolder(uint(Roles.Voter))
        returns (FixedPoint.Unsigned memory rewardsIssued)
    {
        return _getVotingAddress().retrieveRewards(address(this), roundId, toRetrieve);
    }

    function _getVotingAddress() private view returns (Voting) {
        return Voting(finder.getImplementationAddress("Oracle"));
    }
}

contract DesignatedVotingFactory is Withdrawable {

    enum Roles {
        // Can withdraw any ETH or ERC20 sent accidentally to this contract.
        Withdrawer
    }

    address private finder;
    mapping(address => DesignatedVoting) public designatedVotingContracts;

    constructor(address finderAddress) public {
        finder = finderAddress;

        createWithdrawRole(uint(Roles.Withdrawer), uint(Roles.Withdrawer), msg.sender);
    }

    /**
     * @notice Deploys a new `DesignatedVoting` contract.
     */
    function newDesignatedVoting(address ownerAddress) external returns (DesignatedVoting designatedVoting) {
        require(address(designatedVotingContracts[msg.sender]) == address(0), "Duplicate hot key not permitted");

        designatedVoting = new DesignatedVoting(finder, ownerAddress, msg.sender);
        designatedVotingContracts[msg.sender] = designatedVoting;
    }

    /**
     * @notice Associates a `DesignatedVoting` instance with `msg.sender`.
     */
    function setDesignatedVoting(address designatedVotingAddress) external {
        require(address(designatedVotingContracts[msg.sender]) == address(0), "Duplicate hot key not permitted");
        designatedVotingContracts[msg.sender] = DesignatedVoting(designatedVotingAddress);
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Counters {
    using SafeMath for uint256;

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
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Finder is Ownable {

    mapping(bytes32 => address) public interfacesImplemented;

    event InterfaceImplementationChanged(bytes32 indexed interfaceName, address indexed newImplementationAddress);

    /**
     * @dev Updates the address of the contract that implements `interfaceName`.
     */
    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress)
        external
        onlyOwner
    {
        interfacesImplemented[interfaceName] = implementationAddress;
        emit InterfaceImplementationChanged(interfaceName, implementationAddress);
    }
    
    /**
     * @dev Gets the address of the contract that implements the given `interfaceName`.
     */
    function getImplementationAddress(bytes32 interfaceName)
        external
        view
        returns (address implementationAddress)
    {
        implementationAddress = interfacesImplemented[interfaceName];
        require(implementationAddress != address(0x0), "No implementation for interface found");
    }
}

contract Voting is Testable, Ownable, OracleInterface, VotingInterface, EncryptedSender {
    using FixedPoint for FixedPoint.Unsigned;
    using SafeMath for uint;
    using VoteTiming for VoteTiming.Data;
    using ResultComputation for ResultComputation.Data;

    // Identifies a unique price request for which the Oracle will always return the same value.
    // Tracks ongoing votes as well as the result of the vote.
    struct PriceRequest {
        bytes32 identifier;
        uint time;

        // A map containing all votes for this price in various rounds.
        mapping(uint => VoteInstance) voteInstances;

        // If in the past, this was the voting round where this price was resolved. If current or the upcoming round,
        // this is the voting round where this price will be voted on, but not necessarily resolved.
        uint lastVotingRound;

        // The index in the `pendingPriceRequests` that references this PriceRequest. A value of UINT_MAX means that
        // this PriceRequest is resolved and has been cleaned up from `pendingPriceRequests`.
        uint index;
    }

    struct VoteInstance {
        // Maps (voterAddress) to their submission.
        mapping(address => VoteSubmission) voteSubmissions;

        // The data structure containing the computed voting results.
        ResultComputation.Data resultComputation;
    }

    struct VoteSubmission {
        // A bytes32 of `0` indicates no commit or a commit that was already revealed.
        bytes32 commit;

        // The hash of the value that was revealed.
        // Note: this is only used for computation of rewards.
        bytes32 revealHash;
    }

    // Captures the necessary data for making a commitment.
    // Used as a parameter when making batch commitments.
    // Not used as a data structure for storage.
    struct Commitment {
        bytes32 identifier;

        uint time;

        bytes32 hash;

        bytes encryptedVote;
    }

    // Captures the necessary data for revealing a vote.
    // Used as a parameter when making batch reveals.
    // Not used as a data structure for storage.
    struct Reveal {
        bytes32 identifier;

        uint time;

        int price;

        int salt;
    }

    struct Round {
        // Voting token snapshot ID for this round. If this is 0, no snapshot has been taken.
        uint snapshotId;

        // Inflation rate set for this round.
        FixedPoint.Unsigned inflationRate;
    }

    // Represents the status a price request has.
    enum RequestStatus {
        // Was never requested.
        NotRequested,
        // Is being voted on in the current round.
        Active,
        // Was resolved in a previous round.
        Resolved,
        // Is scheduled to be voted on in a future round.
        Future
    }

    // Maps round numbers to the rounds.
    mapping(uint => Round) private rounds;

    // Maps price request IDs to the PriceRequest struct.
    mapping(bytes32 => PriceRequest) private priceRequests;

    // Price request ids for price requests that haven't yet been marked as resolved. These requests may be for future
    // rounds.
    bytes32[] private pendingPriceRequests;

    VoteTiming.Data private voteTiming;

    // The set of identifiers the oracle can provide verified prices for.
    mapping(bytes32 => bool) private supportedIdentifiers;

    // Percentage of the total token supply that must be used in a vote to create a valid price resolution.
    // 1 == 100%.
    FixedPoint.Unsigned private gatPercentage;

    // Global setting for the rate of inflation per vote. This is the percentage of the snapshotted total supply that
    // should be split among the correct voters. Note: this value is used to set per-round inflation at the beginning
    // of each round.
    // 1 = 100%
    FixedPoint.Unsigned private inflationRate;

    // Reference to the voting token.
    VotingToken private votingToken;

    // Reference to the Finder.
    Finder private finder;

    // If non-zero, this contract has been migrated to this address. All voters and financial contracts should query the
    // new address only.
    address private migratedAddress;

    // Max value of an unsigned integer.
    uint constant private UINT_MAX = ~uint(0);

    event VoteCommitted(address indexed voter, uint indexed roundId, bytes32 indexed identifier, uint time);

    event VoteRevealed(
        address indexed voter,
        uint indexed roundId,
        bytes32 indexed identifier,
        uint time,
        int price,
        uint numTokens
    );

    event RewardsRetrieved(address indexed voter, uint indexed roundId, bytes32 indexed identifier, uint time,
        uint numTokens);

    event PriceRequestAdded(uint indexed votingRoundId, bytes32 indexed identifier, uint time);

    event PriceResolved(uint indexed resolutionRoundId, bytes32 indexed identifier, uint time, int price);

    event SupportedIdentifierAdded(bytes32 indexed identifier);

    event SupportedIdentifierRemoved(bytes32 indexed identifier);

    /**
     * @notice Construct the Voting contract.
     * @param phaseLength length of the commit and reveal phases in seconds.
     * @param _gatPercentage percentage of the total token supply that must be used in a vote to create a valid price
     * resolution.
     * @param _isTest whether this contract is being constructed for the purpose of running automated tests.
     */
    constructor(
        uint phaseLength,
        FixedPoint.Unsigned memory _gatPercentage,
        FixedPoint.Unsigned memory _inflationRate,
        address _votingToken,
        address _finder,
        bool _isTest
    ) public Testable(_isTest) {
        voteTiming.init(phaseLength);
        // TODO(#779): GAT percentage must be < 100%
        require(_gatPercentage.isLessThan(1));
        gatPercentage = _gatPercentage;
        inflationRate = _inflationRate;
        votingToken = VotingToken(_votingToken);
        finder = Finder(_finder);
    }

    modifier onlyRegisteredDerivative() {
        if (migratedAddress != address(0)) {
            require(msg.sender == migratedAddress);
        } else {
            Registry registry = Registry(finder.getImplementationAddress("Registry"));
            // TODO(#779): Must be registered derivative
            require(registry.isDerivativeRegistered(msg.sender));
        }
        _;
    }

    modifier onlyIfNotMigrated() {
        require(migratedAddress == address(0));
        _;
    }

    function requestPrice(bytes32 identifier, uint time)
        external
        onlyRegisteredDerivative()
        returns (uint expectedTime)
    {
        uint blockTime = getCurrentTime();
        // TODO(#779): Price request must be for a time in the past
        require(time <= blockTime);
        // TODO(#779): Price request for unsupported identifier
        require(supportedIdentifiers[identifier]);

        // Must ensure the round is updated here so the requested price will be voted on in the next commit cycle.
        _updateRound(blockTime);

        bytes32 priceRequestId = _encodePriceRequest(identifier, time);
        PriceRequest storage priceRequest = priceRequests[priceRequestId];
        uint currentRoundId = voteTiming.computeCurrentRoundId(blockTime);

        RequestStatus requestStatus = _getRequestStatus(priceRequest, currentRoundId);
        if (requestStatus == RequestStatus.Active) {
            return voteTiming.computeEstimatedRoundEndTime(currentRoundId);
        } else if (requestStatus == RequestStatus.Resolved) {
            return 0;
        } else if (requestStatus == RequestStatus.Future) {
            return voteTiming.computeEstimatedRoundEndTime(priceRequest.lastVotingRound);
        }

        // Price has never been requested.
        // Price requests always go in the next round, so add 1 to the computed current round.
        uint nextRoundId = currentRoundId.add(1);

        priceRequests[priceRequestId] = PriceRequest({
            identifier: identifier,
            time: time,
            lastVotingRound: nextRoundId,
            index: pendingPriceRequests.length
        });
        pendingPriceRequests.push(priceRequestId);
        emit PriceRequestAdded(nextRoundId, identifier, time);

        // Estimate the end of next round and return the time.
        return voteTiming.computeEstimatedRoundEndTime(nextRoundId);
    }

    function batchCommit(Commitment[] calldata commits) external {
        for (uint i = 0; i < commits.length; i++) {
            if (commits[i].encryptedVote.length == 0) {
                commitVote(commits[i].identifier, commits[i].time, commits[i].hash);
            } else {
                commitAndPersistEncryptedVote(
                    commits[i].identifier,
                    commits[i].time,
                    commits[i].hash,
                    commits[i].encryptedVote);
            }
        }
    }

    function batchReveal(Reveal[] calldata reveals) external {
        for (uint i = 0; i < reveals.length; i++) {
            revealVote(reveals[i].identifier, reveals[i].time, reveals[i].price, reveals[i].salt);
        }
    }

    /**
     * @notice Disables this Voting contract in favor of the migrated one.
     */
    function setMigrated(address newVotingAddress) external onlyOwner {
        migratedAddress = newVotingAddress;
    }

    /**
     * @notice Adds the provided identifier as a supported identifier. Price requests using this identifier will be
     * succeed after this call.
     */
    function addSupportedIdentifier(bytes32 identifier) external onlyOwner {
        if (!supportedIdentifiers[identifier]) {
            supportedIdentifiers[identifier] = true;
            emit SupportedIdentifierAdded(identifier);
        }
    }

    /**
     * @notice Removes the identifier from the whitelist. Price requests using this identifier will no longer succeed
     * after this call.
     */
    function removeSupportedIdentifier(bytes32 identifier) external onlyOwner {
        if (supportedIdentifiers[identifier]) {
            supportedIdentifiers[identifier] = false;
            emit SupportedIdentifierRemoved(identifier);
        }
    }

    function isIdentifierSupported(bytes32 identifier) external view returns (bool) {
        return supportedIdentifiers[identifier];
    }

    function hasPrice(bytes32 identifier, uint time) external view onlyRegisteredDerivative() returns (bool _hasPrice) {
        (_hasPrice, ,) = _getPriceOrError(identifier, time);
    }

    function getPrice(bytes32 identifier, uint time) external view onlyRegisteredDerivative() returns (int) {
        (bool _hasPrice, int price, string memory message) = _getPriceOrError(identifier, time);

        // TODO(#779): If the price wasn't available, revert with the provided message.
        require(_hasPrice, message);
        return price;
    }

    function getPendingRequests() external view returns (PendingRequest[] memory pendingRequests) {
        uint blockTime = getCurrentTime();
        uint currentRoundId = voteTiming.computeCurrentRoundId(blockTime);

        // Solidity memory arrays aren't resizable (and reading storage is expensive). Hence this hackery to filter
        // `pendingPriceRequests` only to those requests that `isActive()`.
        PendingRequest[] memory unresolved = new PendingRequest[](pendingPriceRequests.length);
        uint numUnresolved = 0;

        for (uint i = 0; i < pendingPriceRequests.length; i++) {
            PriceRequest storage priceRequest = priceRequests[pendingPriceRequests[i]];
            if (_getRequestStatus(priceRequest, currentRoundId) == RequestStatus.Active) {
                unresolved[numUnresolved] = PendingRequest(
                    { identifier: priceRequest.identifier, time: priceRequest.time });
                numUnresolved++;
            }
        }

        pendingRequests = new PendingRequest[](numUnresolved);
        for (uint i = 0; i < numUnresolved; i++) {
            pendingRequests[i] = unresolved[i];
        }
    }

    function getVotePhase() external view returns (VoteTiming.Phase) {
        return voteTiming.computeCurrentPhase(getCurrentTime());
    }

    function getCurrentRoundId() external view returns (uint) {
        return voteTiming.computeCurrentRoundId(getCurrentTime());
    }

    function commitVote(bytes32 identifier, uint time, bytes32 hash) public onlyIfNotMigrated() {
        // TODO(#779): Committed hash of 0 is disallowed, choose a different salt
        require(hash != bytes32(0));

        // Current time is required for all vote timing queries.
        uint blockTime = getCurrentTime();
        // TODO(#779): Cannot commit while in the reveal phase
        require(voteTiming.computeCurrentPhase(blockTime) == VoteTiming.Phase.Commit);

        // Should only update the round in the commit phase because a new round that's already in the reveal phase
        // would be wasted.
        _updateRound(blockTime);

        // At this point, the computed and last updated round ID should be equal.
        uint currentRoundId = voteTiming.computeCurrentRoundId(blockTime);

        PriceRequest storage priceRequest = _getPriceRequest(identifier, time);
        // TODO(#779): Cannot commit on inactive request
        require(_getRequestStatus(priceRequest, currentRoundId) == RequestStatus.Active);

        priceRequest.lastVotingRound = currentRoundId;
        VoteInstance storage voteInstance = priceRequest.voteInstances[currentRoundId];
        voteInstance.voteSubmissions[msg.sender].commit = hash;

        emit VoteCommitted(msg.sender, currentRoundId, identifier, time);
    }

    function revealVote(bytes32 identifier, uint time, int price, int salt) public onlyIfNotMigrated() {
        uint blockTime = getCurrentTime();
        require(voteTiming.computeCurrentPhase(blockTime) == VoteTiming.Phase.Reveal,
            "Cannot reveal while in the commit phase");

        // Note: computing the current round is required to disallow people from revealing an old commit after the
        // round is over.
        uint roundId = voteTiming.computeCurrentRoundId(blockTime);

        PriceRequest storage priceRequest = _getPriceRequest(identifier, time);
        VoteInstance storage voteInstance = priceRequest.voteInstances[roundId];
        VoteSubmission storage voteSubmission = voteInstance.voteSubmissions[msg.sender];

        // 0 hashes are disallowed in the commit phase, so they indicate a different error.
        require(voteSubmission.commit != bytes32(0), "Cannot reveal an uncommitted or previously revealed hash");
        require(keccak256(abi.encode(price, salt)) == voteSubmission.commit,
                "Committed hash doesn't match revealed price and salt");
        delete voteSubmission.commit;

        // Get or create a snapshot for this round.
        uint snapshotId = _getOrCreateSnapshotId(roundId);

        // Get the voter's snapshotted balance. Since balances are returned pre-scaled by 10**18, we can directly
        // initialize the Unsigned value with the returned uint.
        FixedPoint.Unsigned memory balance = FixedPoint.Unsigned(votingToken.balanceOfAt(msg.sender, snapshotId));

        // Set the voter's submission.
        voteSubmission.revealHash = keccak256(abi.encode(price));

        // Add vote to the results.
        voteInstance.resultComputation.addVote(price, balance);

        // Remove the stored message for this price request, if it exists.
        bytes32 topicHash = keccak256(abi.encode(identifier, time, roundId));
        removeMessage(msg.sender, topicHash);

        emit VoteRevealed(msg.sender, roundId, identifier, time, price, balance.rawValue);
    }

    function commitAndPersistEncryptedVote(
        bytes32 identifier,
        uint time,
        bytes32 hash,
        bytes memory encryptedVote
    ) public {
        commitVote(identifier, time, hash);

        uint roundId = voteTiming.computeCurrentRoundId(getCurrentTime());
        bytes32 topicHash = keccak256(abi.encode(identifier, time, roundId));
        sendMessage(msg.sender, topicHash, encryptedVote);
    }

    /**
     * @notice Resets the inflation rate. Note: this change only applies to rounds that have not yet begun.
     * @dev This method is public because calldata structs are not currently supported by solidity.
     */
    function setInflationRate(FixedPoint.Unsigned memory _inflationRate) public onlyOwner {
        inflationRate = _inflationRate;
    }

    function retrieveRewards(address voterAddress, uint roundId, PendingRequest[] memory toRetrieve)
        public
        returns (FixedPoint.Unsigned memory totalRewardToIssue)
    {
        if (migratedAddress != address(0)) {
            require(msg.sender == migratedAddress);
        }
        uint blockTime = getCurrentTime();
        _updateRound(blockTime);
        require(roundId < voteTiming.computeCurrentRoundId(blockTime));

        Round storage round = rounds[roundId];
        FixedPoint.Unsigned memory snapshotBalance = FixedPoint.Unsigned(
            votingToken.balanceOfAt(voterAddress, round.snapshotId));

        // Compute the total amount of reward that will be issued for each of the votes in the round.
        FixedPoint.Unsigned memory snapshotTotalSupply = FixedPoint.Unsigned(
            votingToken.totalSupplyAt(round.snapshotId));
        FixedPoint.Unsigned memory totalRewardPerVote = round.inflationRate.mul(snapshotTotalSupply);

        // Keep track of the voter's accumulated token reward.
        totalRewardToIssue = FixedPoint.Unsigned(0);

        for (uint i = 0; i < toRetrieve.length; i++) {
            PriceRequest storage priceRequest = _getPriceRequest(toRetrieve[i].identifier, toRetrieve[i].time);
            VoteInstance storage voteInstance = priceRequest.voteInstances[priceRequest.lastVotingRound];

            require(priceRequest.lastVotingRound == roundId, "Only retrieve rewards for votes resolved in same round");

            _resolvePriceRequest(priceRequest, voteInstance);

            if (voteInstance.resultComputation.wasVoteCorrect(voteInstance.voteSubmissions[voterAddress].revealHash)) {
                // The price was successfully resolved during the voter's last voting round, the voter revealed and was
                // correct, so they are elgible for a reward.
                FixedPoint.Unsigned memory correctTokens = voteInstance.resultComputation.
                    getTotalCorrectlyVotedTokens();

                // Compute the reward and add to the cumulative reward.
                FixedPoint.Unsigned memory reward = snapshotBalance.mul(totalRewardPerVote).div(correctTokens);
                totalRewardToIssue = totalRewardToIssue.add(reward);

                // Emit reward retrieval for this vote.
                emit RewardsRetrieved(voterAddress, roundId, toRetrieve[i].identifier, toRetrieve[i].time,
                    reward.rawValue);
            } else {
                // Emit a 0 token retrieval on incorrect votes.
                emit RewardsRetrieved(voterAddress, roundId, toRetrieve[i].identifier, toRetrieve[i].time, 0);
            }

            // Delete the submission to capture any refund and clean up storage.
            delete voteInstance.voteSubmissions[voterAddress].revealHash;
        }

        // Issue any accumulated rewards.
        if (totalRewardToIssue.isGreaterThan(0)) {
            require(votingToken.mint(voterAddress, totalRewardToIssue.rawValue));
        }
    }

    /*
     * @dev Checks to see if there is a price that has or can be resolved for an (identifier, time) pair.
     * @returns a boolean noting whether a price is resolved, the price, and an error string if necessary.
     */
    function _getPriceOrError(bytes32 identifier, uint time)
        private
        view
        returns (bool _hasPrice, int price, string memory err)
    {
        PriceRequest storage priceRequest = _getPriceRequest(identifier, time);
        uint currentRoundId = voteTiming.computeCurrentRoundId(getCurrentTime());

        RequestStatus requestStatus = _getRequestStatus(priceRequest, currentRoundId);
        if (requestStatus == RequestStatus.Active) {
            return (false, 0, "The current voting round has not ended");
        } else if (requestStatus == RequestStatus.Resolved) {
            VoteInstance storage voteInstance = priceRequest.voteInstances[priceRequest.lastVotingRound];
            (, int resolvedPrice) = voteInstance.resultComputation.getResolvedPrice(
                _computeGat(priceRequest.lastVotingRound));
            return (true, resolvedPrice, "");
        } else if (requestStatus == RequestStatus.Future) {
            return (false, 0, "Price will be voted on in the future");
        } else {
            return (false, 0, "Price was never requested");
        }
    }

    function _getPriceRequest(bytes32 identifier, uint time) private view returns (PriceRequest storage) {
        return priceRequests[_encodePriceRequest(identifier, time)];
    }

    function _encodePriceRequest(bytes32 identifier, uint time) private pure returns (bytes32) {
        return keccak256(abi.encode(identifier, time));
    }

    function _getOrCreateSnapshotId(uint roundId) private returns (uint) {
        Round storage round = rounds[roundId];
        if (round.snapshotId == 0) {
            // There is no snapshot ID set, so create one.
            round.snapshotId = votingToken.snapshot();
        }

        return round.snapshotId;
    }

    function _resolvePriceRequest(PriceRequest storage priceRequest, VoteInstance storage voteInstance) private {
        if (priceRequest.index == UINT_MAX) {
            return;
        }
        (bool isResolved, int resolvedPrice) = voteInstance.resultComputation.getResolvedPrice(
            _computeGat(priceRequest.lastVotingRound));
        require(isResolved, "Can't resolve an unresolved price request");

        // Delete the resolved price request from pendingPriceRequests.
        uint lastIndex = pendingPriceRequests.length - 1;
        PriceRequest storage lastPriceRequest = priceRequests[pendingPriceRequests[lastIndex]];
        lastPriceRequest.index = priceRequest.index;
        pendingPriceRequests[priceRequest.index] = pendingPriceRequests[lastIndex];
        delete pendingPriceRequests[lastIndex];

        priceRequest.index = UINT_MAX;
        emit PriceResolved(priceRequest.lastVotingRound, priceRequest.identifier, priceRequest.time, resolvedPrice);
    }

    function _updateRound(uint blockTime) private {
        if (!voteTiming.shouldUpdateRoundId(blockTime)) {
            return;
        }
        uint nextVotingRoundId = voteTiming.computeCurrentRoundId(blockTime);

        // Set the round inflation rate to the current global inflation rate.
        rounds[nextVotingRoundId].inflationRate = inflationRate;

        // Update the stored round to the current one.
        voteTiming.updateRoundId(blockTime);
    }

    function _computeGat(uint roundId) private view returns (FixedPoint.Unsigned memory) {
        uint snapshotId = rounds[roundId].snapshotId;
        if (snapshotId == 0) {
            // No snapshot - return max value to err on the side of caution.
            return FixedPoint.Unsigned(UINT_MAX);
        }

        // Grab the snaphotted supply from the voting token. It's already scaled by 10**18, so we can directly
        // initialize the Unsigned value with the returned uint.
        FixedPoint.Unsigned memory snapshottedSupply = FixedPoint.Unsigned(votingToken.totalSupplyAt(snapshotId));

        // Multiply the total supply at the snapshot by the gatPercentage to get the GAT in number of tokens.
        return snapshottedSupply.mul(gatPercentage);
    }

    function _getRequestStatus(PriceRequest storage priceRequest, uint currentRoundId)
        private
        view
        returns (RequestStatus)
    {
        if (priceRequest.lastVotingRound == 0) {
            return RequestStatus.NotRequested;
        } else if (priceRequest.lastVotingRound < currentRoundId) {
            VoteInstance storage voteInstance = priceRequest.voteInstances[priceRequest.lastVotingRound];
            (bool isResolved, ) = voteInstance.resultComputation.getResolvedPrice(
                _computeGat(priceRequest.lastVotingRound));
            return isResolved ? RequestStatus.Resolved : RequestStatus.Active;
        } else if (priceRequest.lastVotingRound == currentRoundId) {
            return RequestStatus.Active;
        } else {
            // Means than priceRequest.lastVotingRound > currentRoundId
            return RequestStatus.Future;
        }
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract ExpandedIERC20 is IERC20 {
    /**
     * @notice Burns a specific amount of the caller's tokens.
     * @dev Only burns the caller's tokens, so it is safe to leave this method permissionless.
     */
    function burn(uint value) external;

    /**
     * @notice Mints tokens and adds them to the balance of the `to` address.
     * @dev This method should be permissioned to only allow designated parties to mint tokens.
     */
    function mint(address to, uint value) external returns (bool);
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

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
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Snapshot is ERC20 {
    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    // Creates a new snapshot id. Balances are only stored in snapshots on demand: unless a snapshot was taken, a
    // balance change will not be recorded. This means the extra added cost of storing snapshotted balances is only paid
    // when required, but is also flexible enough that it allows for e.g. daily snapshots.
    function snapshot() public returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // _transfer, _mint and _burn are the only functions where the balances are modified, so it is there that the
    // snapshots are updated. Note that the update happens _before_ the balance change, with the pre-modified value.
    // The same is true for the total supply and _mint and _burn.
    function _transfer(address from, address to, uint256 value) internal {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    // When a valid snapshot is queried, there are three possibilities:
    //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
    //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
    //  to this id is the current one.
    //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
    //  requested id, and its value is the one to return.
    //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
    //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
    //  larger than the requested one.
    //
    // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
    // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
    // exactly this.
    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        // solhint-disable-next-line max-line-length
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

contract VotingToken is ExpandedIERC20, ERC20Snapshot, MultiRole {

    enum Roles {
        // Can set the minter and burner.
        Owner,
        // Addresses that can mint new tokens.
        Minter,
        // Addresses that can burn tokens that address owns.
        Burner
    }

    // Standard ERC20 metadata.
    string public constant name = "UMA Voting Token v1"; // solhint-disable-line const-name-snakecase
    string public constant symbol = "UMA"; // solhint-disable-line const-name-snakecase
    uint8 public constant decimals = 18; // solhint-disable-line const-name-snakecase

    constructor() public {
        _createExclusiveRole(uint(Roles.Owner), uint(Roles.Owner), msg.sender);
        _createSharedRole(uint(Roles.Minter), uint(Roles.Owner), new address[](0));
        _createSharedRole(uint(Roles.Burner), uint(Roles.Owner), new address[](0));
    }

    /**
     * @dev Mints `value` tokens to `recipient`, returning true on success.
     */
    function mint(address recipient, uint value) external onlyRoleHolder(uint(Roles.Minter)) returns (bool) {
        _mint(recipient, value);
        return true;
    }

    /**
     * @dev Burns `value` tokens owned by `msg.sender`.
     */
    function burn(uint value) external onlyRoleHolder(uint(Roles.Burner)) {
        _burn(msg.sender, value);
    }
}

library Arrays {
   /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}
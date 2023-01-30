/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;


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

interface StoreInterface {

    /** 
     * @dev Pays Oracle fees in ETH to the store. To be used by contracts whose margin currency is ETH.
     */
    function payOracleFees() external payable;

    /**
     * @dev Pays oracle fees in the margin currency, erc20Address, to the store. To be used if the margin
     * currency is an ERC20 token rather than ETH> All approved tokens are transfered.
     */
    function payOracleFeesErc20(address erc20Address) external; 

    /**
     * @dev Computes the regular oracle fees that a contract should pay for a period. 
     * pfc` is the "profit from corruption", or the maximum amount of margin currency that a
     * token sponsor could extract from the contract through corrupting the price feed
     * in their favor.
     */
    function computeRegularFee(uint startTime, uint endTime, FixedPoint.Unsigned calldata pfc) 
    external view returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty);
    
    /**
     * @dev Computes the final oracle fees that a contract should pay at settlement.
     */
    function computeFinalFee(address currency) external view returns (FixedPoint.Unsigned memory finalFee);
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

contract Store is StoreInterface, MultiRole, Withdrawable {

    using SafeMath for uint;
    using FixedPoint for FixedPoint.Unsigned;
    using FixedPoint for uint;

    enum Roles {
        Owner,
        Withdrawer
    }

    FixedPoint.Unsigned private fixedOracleFeePerSecond; // Percentage of 1 E.g., .1 is 10% Oracle fee.

    FixedPoint.Unsigned private weeklyDelayFee; // Percentage of 1 E.g., .1 is 10% weekly delay fee.
    mapping(address => FixedPoint.Unsigned) private finalFees;
    uint private constant SECONDS_PER_WEEK = 604800;

    event NewFixedOracleFeePerSecond(FixedPoint.Unsigned newOracleFee);

    constructor() public {
        _createExclusiveRole(uint(Roles.Owner), uint(Roles.Owner), msg.sender);
        createWithdrawRole(uint(Roles.Withdrawer), uint(Roles.Owner), msg.sender);
    }

    function payOracleFees() external payable {
        require(msg.value > 0);
    }

    function payOracleFeesErc20(address erc20Address) external {
        IERC20 erc20 = IERC20(erc20Address);
        uint authorizedAmount = erc20.allowance(msg.sender, address(this));
        require(authorizedAmount > 0);
        require(erc20.transferFrom(msg.sender, address(this), authorizedAmount));
    }

    function computeRegularFee(uint startTime, uint endTime, FixedPoint.Unsigned calldata pfc) 
        external 
        view 
        returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty) 
    {
        uint timeDiff = endTime.sub(startTime);

        // Multiply by the unscaled `timeDiff` first, to get more accurate results.
        regularFee = pfc.mul(timeDiff).mul(fixedOracleFeePerSecond);
        // `weeklyDelayFee` is already scaled up.
        latePenalty = pfc.mul(weeklyDelayFee.mul(timeDiff.div(SECONDS_PER_WEEK)));

        return (regularFee, latePenalty);
    }

    function computeFinalFee(address currency) 
        external 
        view 
        returns (FixedPoint.Unsigned memory finalFee) 
    {
        finalFee = finalFees[currency];
    }

    /**
     * @dev Sets a new oracle fee per second
     */ 
    function setFixedOracleFeePerSecond(FixedPoint.Unsigned memory newOracleFee) 
        public 
        onlyRoleHolder(uint(Roles.Owner)) 
    {
        // Oracle fees at or over 100% don't make sense.
        require(newOracleFee.isLessThan(1));
        fixedOracleFeePerSecond = newOracleFee;
        emit NewFixedOracleFeePerSecond(newOracleFee);
    }

    /**
     * @dev Sets a new weekly delay fee
     */ 
    function setWeeklyDelayFee(FixedPoint.Unsigned memory newWeeklyDelayFee) 
        public 
        onlyRoleHolder(uint(Roles.Owner)) 
    {
        weeklyDelayFee = newWeeklyDelayFee;
    }

    /**
     * @dev Sets a new final fee for a particular currency
     */ 
    function setFinalFee(address currency, FixedPoint.Unsigned memory finalFee) 
        public 
        onlyRoleHolder(uint(Roles.Owner))
    {
        finalFees[currency] = finalFee;
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
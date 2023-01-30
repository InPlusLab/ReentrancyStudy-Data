/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// File: contracts/interfaces/IWhitelist.sol

pragma solidity 0.5.17;

/**
 * Source: https://raw.githubusercontent.com/simple-restricted-token/reference-implementation/master/contracts/token/ERC1404/ERC1404.sol
 * With ERC-20 APIs removed (will be implemented as a separate contract).
 * And adding authorizeTransfer.
 */
interface IWhitelist {
  /**
   * @notice Detects if a transfer will be reverted and if so returns an appropriate reference code
   * @param from Sending address
   * @param to Receiving address
   * @param value Amount of tokens being transferred
   * @return Code by which to reference message for rejection reasoning
   * @dev Overwrite with your custom transfer restriction logic
   */
  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view returns (uint8);

  /**
   * @notice Returns a human-readable message for a given restriction code
   * @param restrictionCode Identifier for looking up a message
   * @return Text showing the restriction's reasoning
   * @dev Overwrite with your custom message and restrictionCode handling
   */
  function messageForTransferRestriction(uint8 restrictionCode)
    external
    pure
    returns (string memory);

  /**
   * @notice Called by the DAT contract before a transfer occurs.
   * @dev This call will revert when the transfer is not authorized.
   * This is a mutable call to allow additional data to be recorded,
   * such as when the user aquired their tokens.
   */
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;

  function walletActivated(
    address _wallet
  ) external returns(bool);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.5.0;


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
contract Context is Initializable {
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

// File: @openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
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
     * > Note: Renouncing ownership will leave the contract without an owner,
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

    uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

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

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: contracts/mixins/OperatorRole.sol

pragma solidity ^0.5.0;

// Original source: openzeppelin's SignerRole





/**
 * @notice allows a single owner to manage a group of operators which may
 * have some special permissions in the contract.
 */
contract OperatorRole is Initializable, Context, Ownable {
  using Roles for Roles.Role;

  event OperatorAdded(address indexed account);
  event OperatorRemoved(address indexed account);

  Roles.Role private _operators;

  function _initializeOperatorRole() internal {
    _addOperator(msg.sender);
  }

  modifier onlyOperator() {
    require(
      isOperator(msg.sender),
      "OperatorRole: caller does not have the Operator role"
    );
    _;
  }

  function isOperator(address account) public view returns (bool) {
    return _operators.has(account);
  }

  function addOperator(address account) public onlyOwner {
    _addOperator(account);
  }

  function removeOperator(address account) public onlyOwner {
    _removeOperator(account);
  }

  function renounceOperator() public {
    _removeOperator(msg.sender);
  }

  function _addOperator(address account) internal {
    _operators.add(account);
    emit OperatorAdded(account);
  }

  function _removeOperator(address account) internal {
    _operators.remove(account);
    emit OperatorRemoved(account);
  }

  uint[50] private ______gap;
}

// File: contracts/Whitelist.sol

pragma solidity 0.5.17;






/**
 * @notice whitelist which manages KYC approvals, token lockup, and transfer
 * restrictions for a DAT token.
 */
contract Whitelist is IWhitelist, Ownable, OperatorRole {
  using SafeMath for uint;

  // uint8 status codes as suggested by the ERC-1404 spec
  uint8 private constant STATUS_SUCCESS = 0;
  uint8 private constant STATUS_ERROR_JURISDICTION_FLOW = 1;
  uint8 private constant STATUS_ERROR_LOCKUP = 2;
  uint8 private constant STATUS_ERROR_USER_UNKNOWN = 3;
  uint8 private constant STATUS_ERROR_JURISDICTION_HALT = 4;
  uint8 private constant STATUS_ERROR_NON_LISTED_USER = 5;

  event ConfigWhitelist(
    uint _startDate,
    uint _lockupGranularity,
    address indexed _operator
  );
  event UpdateJurisdictionFlow(
    uint indexed _fromJurisdictionId,
    uint indexed _toJurisdictionId,
    uint _lockupLength,
    address indexed _operator
  );
  event ApproveNewUser(
    address indexed _trader,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddApprovedUserWallet(
    address indexed _userId,
    address indexed _newWallet,
    address indexed _operator
  );
  event RevokeUserWallet(address indexed _wallet, address indexed _operator);
  event UpdateJurisdictionForUserId(
    address indexed _userId,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddLockup(
    address indexed _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked,
    address indexed _operator
  );
  event UnlockTokens(
    address indexed _userId,
    uint _tokensUnlocked,
    address indexed _operator
  );
  event Halt(uint indexed _jurisdictionId, uint _until);
  event Resume(uint indexed _jurisdictionId);
  event MaxInvestorsChanged(uint _limit);
  event MaxInvestorsByJurisdictionChanged(uint indexed _jurisdictionId, uint _limit);
  event InvestorEnlisted(address indexed _userId, uint indexed _jurisdictionId);
  event InvestorDelisted(address indexed _userId, uint indexed _jurisdictionId);
  event WalletActivated(address indexed _userId, address indexed _wallet);
  event WalletDeactivated(address indexed _userId, address indexed _wallet);

  /**
   * @notice the address of the contract this whitelist manages.
   * @dev this cannot change after initialization
   */
  IERC20 public callingContract;

  /**
   * @notice blocks all new purchases until now >= startDate.
   * @dev this can be changed by the owner at any time
   */
  uint public startDate;

  /**
   * @notice Merges lockup entries when the time delta between
   * them is less than this value.
   * @dev this can be changed by the owner at any time
   */
  uint public lockupGranularity;

  /**
   * @notice Maps the `from` jurisdiction to the `to` jurisdiction to determine if
   * transfers between these entities are allowed and if a token lockup should apply:
   * - 0 means transfers between these jurisdictions is blocked (the default)
   * - 1 is supported with no token lockup required
   * - >1 is supported and this value defines the lockup length in seconds
   * @dev You can read data externally with `getJurisdictionFlow`.
   * This configuration can be modified by the owner at any time
   */
  mapping(uint => mapping(uint => uint)) internal jurisdictionFlows;

  /**
   * @notice Maps a KYC'd user addresses to their userId.
   * @dev The first entry for each user should set userId = user address.
   * Future entries can use the same userId for shared accounts
   * (e.g. a single user with multiple wallets).
   *
   * All wallets with the same userId share the same token lockup.
   */
  mapping(address => address) public authorizedWalletToUserId;

  /**
   * @notice info stored for each userId.
   */
  struct UserInfo {
    // The user's current jurisdictionId or 0 for unknown (the default)
    uint jurisdictionId;
    // The number of tokens locked, with details tracked in userIdLockups
    uint totalTokensLocked;
    // The first applicable entry in userIdLockups
    uint startIndex;
    // The last applicable entry in userIdLockups + 1
    uint endIndex;
  }

  /**
   * @notice Maps the userId to UserInfo.
   * @dev You can read data externally with `getAuthorizedUserIdInfo`.
   */
  mapping(address => UserInfo) internal authorizedUserIdInfo;

  /**
   * @notice info stored for each token lockup.
   */
  struct Lockup {
    // The date/time that this lockup entry has expired and the tokens may be transferred
    uint lockupExpirationDate;
    // How many tokens locked until the given expiration date.
    uint numberOfTokensLocked;
  }

  /**
   * @notice Maps the userId -> lockup entry index -> a Lockup entry
   * @dev Indexes are tracked by the UserInfo entries.
   * You can read data externally with `getUserIdLockup`.
   * We assume lockups are always added in order of expiration date -
   * if that assumption does not hold, some tokens may remain locked
   * until older lockup entries from that user have expired.
   */
  mapping(address => mapping(uint => Lockup)) internal userIdLockups;

  /**
   * @notice Maps Jurisdiction Id to it's halt due
   */
  mapping(uint => uint) public jurisdictionHaltsUntil;

  /**
   * @notice maximum investors that this contract can hold
   */
  uint public maxInvestors;

  /**
   * @notice number of users enlisted in the contract. Should be less or equal to `maxInvestors`
   */
  uint public currentInvestors;

  /**
   * @notice maximum investors for jurisdictions
   */
  mapping(uint => uint) public maxInvestorsByJurisdiction;

  /**
   * @notice current investors for jurisdictions
   */
  mapping(uint => uint) public currentInvestorsByJurisdiction;

  /**
   * @notice mapping to check if user is in `currenctInvestors` for both contract and jurisdiction
   * should be true to interact with the contract
   */
  mapping(address => bool) public investorEnlisted;

  /**
   * @notice count of user wallet to check investor should be enlisted
   */
  mapping(address => uint) public userActiveWalletCount;

  /**
   * @notice mapping to check if wallet is in `userActiveWalletCount`
   */
  mapping(address => bool) public walletActivated;


  /**
   * @notice mapping to check wallet's previous owner userId
   */
  mapping(address => address) public revokedFrom;

  /**
   * @notice checks for transfer restrictions between jurisdictions.
   * @return if transfers between these jurisdictions are allowed and if a
   * token lockup should apply:
   * - 0 means transfers between these jurisdictions is blocked (the default)
   * - 1 is supported with no token lockup required
   * - >1 is supported and this value defines the lockup length in seconds
   */
  function getJurisdictionFlow(
    uint _fromJurisdictionId,
    uint _toJurisdictionId
  ) external view returns (uint lockupLength) {
    return jurisdictionFlows[_fromJurisdictionId][_toJurisdictionId];
  }

  /**
   * @notice checks details for a given userId.
   */
  function getAuthorizedUserIdInfo(address _userId)
    external
    view
    returns (
      uint jurisdictionId,
      uint totalTokensLocked,
      uint startIndex,
      uint endIndex
    )
  {
    UserInfo memory info = authorizedUserIdInfo[_userId];
    return (
      info.jurisdictionId,
      info.totalTokensLocked,
      info.startIndex,
      info.endIndex
    );
  }

  /**
   * @notice gets a specific lockup entry for a userId.
   * @dev use `getAuthorizedUserIdInfo` to determine the range of applicable lockupIndex.
   */
  function getUserIdLockup(address _userId, uint _lockupIndex)
    external
    view
    returns (uint lockupExpirationDate, uint numberOfTokensLocked)
  {
    Lockup memory lockup = userIdLockups[_userId][_lockupIndex];
    return (lockup.lockupExpirationDate, lockup.numberOfTokensLocked);
  }

  /**
   * @notice Returns the number of unlocked tokens a given userId has available.
   * @dev this is a `view`-only way to determine how many tokens are still locked
   * (info.totalTokensLocked is only accurate after processing lockups which changes state)
   */
  function getLockedTokenCount(address _userId)
    external
    view
    returns (uint lockedTokens)
  {
    UserInfo memory info = authorizedUserIdInfo[_userId];
    lockedTokens = info.totalTokensLocked;
    uint endIndex = info.endIndex;
    for (uint i = info.startIndex; i < endIndex; i++) {
      Lockup memory lockup = userIdLockups[_userId][i];
      if (lockup.lockupExpirationDate > block.timestamp) {
        // no more eligible entries
        break;
      }
      // this lockup entry has expired and would be processed on the next tx
      lockedTokens -= lockup.numberOfTokensLocked;
    }
  }

  /**
   * @notice Checks if there is a transfer restriction for the given addresses.
   * Does not consider tokenLockup. Use `getLockedTokenCount` for that.
   * @dev this function is from the erc-1404 standard and currently in use by the DAT
   * for the `pay` feature.
   */
  function detectTransferRestriction(
    address _from,
    address _to,
    uint /* _value */
  ) external view returns (uint8 status) {
    address fromUserId = authorizedWalletToUserId[_from];
    address toUserId = authorizedWalletToUserId[_to];
    if (
      (fromUserId == address(0) && _from != address(0)) ||
      (toUserId == address(0) && _to != address(0))
    ) {
      return STATUS_ERROR_USER_UNKNOWN;
    }
    if (fromUserId != toUserId) {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId]
        .jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;
      if (_isJurisdictionHalted(fromJurisdictionId) || _isJurisdictionHalted(toJurisdictionId)){
        return STATUS_ERROR_JURISDICTION_HALT;
      }
      if (jurisdictionFlows[fromJurisdictionId][toJurisdictionId] == 0) {
        return STATUS_ERROR_JURISDICTION_FLOW;
      }
    }

    return STATUS_SUCCESS;
  }

  function messageForTransferRestriction(uint8 _restrictionCode)
    external
    pure
    returns (string memory)
  {
    if (_restrictionCode == STATUS_SUCCESS) {
      return "SUCCESS";
    }
    if (_restrictionCode == STATUS_ERROR_JURISDICTION_FLOW) {
      return "DENIED: JURISDICTION_FLOW";
    }
    if (_restrictionCode == STATUS_ERROR_LOCKUP) {
      return "DENIED: LOCKUP";
    }
    if (_restrictionCode == STATUS_ERROR_USER_UNKNOWN) {
      return "DENIED: USER_UNKNOWN";
    }
    if (_restrictionCode == STATUS_ERROR_JURISDICTION_HALT){
      return "DENIED: JURISDICTION_HALT";
    }
    return "DENIED: UNKNOWN_ERROR";
  }

  /**
   * @notice Called once to complete configuration for this contract.
   * @dev Done with `initialize` instead of a constructor in order to support
   * using this contract via an Upgradable Proxy.
   */
  function initialize(address _callingContract) public {
    Ownable.initialize(msg.sender);
    _initializeOperatorRole();
    callingContract = IERC20(_callingContract);
  }

  /**
   * @notice Called by the owner to update the startDate or lockupGranularity.
   */
  function configWhitelist(uint _startDate, uint _lockupGranularity)
    external
    onlyOwner()
  {
    startDate = _startDate;
    lockupGranularity = _lockupGranularity;
    emit ConfigWhitelist(_startDate, _lockupGranularity, msg.sender);
  }

  /**
   * @notice Called by the owner to define or update jurisdiction flows.
   * @param _lockupLengths defines transfer restrictions where:
   * - 0 is not supported (the default)
   * - 1 is supported with no token lockup required
   * - >1 is supported and this value defines the lockup length in seconds.
   * @dev note that this can be called with a partial list, only including entries
   * to be added or which have changed.
   */
  function updateJurisdictionFlows(
    uint[] calldata _fromJurisdictionIds,
    uint[] calldata _toJurisdictionIds,
    uint[] calldata _lockupLengths
  ) external onlyOwner() {
    uint count = _fromJurisdictionIds.length;
    for (uint i = 0; i < count; i++) {
      uint fromJurisdictionId = _fromJurisdictionIds[i];
      uint toJurisdictionId = _toJurisdictionIds[i];
      require(
        fromJurisdictionId > 0 && toJurisdictionId > 0,
        "INVALID_JURISDICTION_ID"
      );
      jurisdictionFlows[fromJurisdictionId][toJurisdictionId] = _lockupLengths[i];
      emit UpdateJurisdictionFlow(
        fromJurisdictionId,
        toJurisdictionId,
        _lockupLengths[i],
        msg.sender
      );
    }
  }

  /**
   * @notice Called by an operator to add new traders.
   * @dev The trader will be assigned a userId equal to their wallet address.
   */
  function approveNewUsers(
    address[] calldata _traders,
    uint[] calldata _jurisdictionIds
  ) external onlyOperator() {
    uint length = _traders.length;
    for (uint i = 0; i < length; i++) {
      address trader = _traders[i];
      require(
        authorizedWalletToUserId[trader] == address(0),
        "USER_WALLET_ALREADY_ADDED"
      );
      require(
        revokedFrom[trader] == address(0) ||
        revokedFrom[trader] == trader,
        "ATTEMPT_TO_ADD_PREVIOUS_WALLET_AS_NEW_USER"
      );
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");

      authorizedWalletToUserId[trader] = trader;
      authorizedUserIdInfo[trader].jurisdictionId = jurisdictionId;
      emit ApproveNewUser(trader, jurisdictionId, msg.sender);
    }
  }

  /**
   * @notice Called by an operator to add wallets to known userIds.
   */
  function addApprovedUserWallets(
    address[] calldata _userIds,
    address[] calldata _newWallets
  ) external onlyOperator() {
    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      address userId = _userIds[i];
      require(
        authorizedUserIdInfo[userId].jurisdictionId != 0,
        "USER_ID_UNKNOWN"
      );
      address newWallet = _newWallets[i];
      require(
        authorizedWalletToUserId[newWallet] == address(0),
        "WALLET_ALREADY_ADDED"
      );
      require(
        revokedFrom[newWallet] == address(0) ||
        revokedFrom[newWallet] == userId,
        "ATTEMPT_TO_EXCHANGE_WALLET"
      );

      authorizedWalletToUserId[newWallet] = userId;
      emit AddApprovedUserWallet(userId, newWallet, msg.sender);
    }
  }

  /**
   * @notice Called by an operator to revoke approval for the given wallets.
   * @dev If this is called in error, you can restore access with `addApprovedUserWallets`.
   */
  function revokeUserWallets(address[] calldata _wallets)
    external
    onlyOperator()
  {
    uint length = _wallets.length;
    for (uint i = 0; i < length; i++) {
      address wallet = _wallets[i];
      require(
        authorizedWalletToUserId[wallet] != address(0),
        "WALLET_NOT_FOUND"
      );

      // deactivate wallet
      if(walletActivated[wallet]){
        _deactivateWallet(wallet);
      }

      // save previous userId to prevent offchain wallet trade
      revokedFrom[wallet] = authorizedWalletToUserId[wallet];

      authorizedWalletToUserId[wallet] = address(0);
      emit RevokeUserWallet(wallet, msg.sender);
    }
  }

  /**
   * @notice Called by an operator to change the jurisdiction
   * for the given userIds.
   */
  function updateJurisdictionsForUserIds(
    address[] calldata _userIds,
    uint[] calldata _jurisdictionIds
  ) external onlyOperator() {
    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      address userId = _userIds[i];
      require(
        authorizedUserIdInfo[userId].jurisdictionId != 0,
        "USER_ID_UNKNOWN"
      );
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");
      if(investorEnlisted[userId]){
        //decrease current user count from old jurisdiction
        currentInvestorsByJurisdiction[authorizedUserIdInfo[userId].jurisdictionId]--;
        //increase current user count for new jurisdiction
        currentInvestorsByJurisdiction[jurisdictionId]++;
      }
      authorizedUserIdInfo[userId].jurisdictionId = jurisdictionId;
      emit UpdateJurisdictionForUserId(userId, jurisdictionId, msg.sender);
    }
  }

  /**
   * @notice Adds a tokenLockup for the userId.
   * @dev A no-op if lockup is not required for this transfer.
   * The lockup entry is merged with the most recent lockup for that user
   * if the expiration date is <= `lockupGranularity` from the previous entry.
   */
  function _addLockup(
    address _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked
  ) internal {
    if (
      _numberOfTokensLocked == 0 || _lockupExpirationDate <= block.timestamp
    ) {
      // This is a no-op
      return;
    }
    emit AddLockup(
      _userId,
      _lockupExpirationDate,
      _numberOfTokensLocked,
      msg.sender
    );
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId != 0, "USER_ID_UNKNOWN");
    info.totalTokensLocked = info.totalTokensLocked.add(_numberOfTokensLocked);
    if (info.endIndex > 0) {
      Lockup storage lockup = userIdLockups[_userId][info.endIndex - 1];
      if (
        lockup.lockupExpirationDate + lockupGranularity >= _lockupExpirationDate
      ) {
        // Merge with the previous entry
        // if totalTokensLocked can't overflow then this value will not either
        lockup.numberOfTokensLocked += _numberOfTokensLocked;
        return;
      }
    }
    // Add a new lockup entry
    userIdLockups[_userId][info.endIndex] = Lockup(
      _lockupExpirationDate,
      _numberOfTokensLocked
    );
    info.endIndex++;
  }

  /**
   * @notice Operators can manually add lockups for userIds.
   * This may be used by the organization before transfering tokens
   * from the initial supply.
   */
  function addLockups(
    address[] calldata _userIds,
    uint[] calldata _lockupExpirationDates,
    uint[] calldata _numberOfTokensLocked
  ) external onlyOperator() {
    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      _addLockup(
        _userIds[i],
        _lockupExpirationDates[i],
        _numberOfTokensLocked[i]
      );
    }
  }

  /**
   * @notice Checks the next lockup entry for a given user and unlocks
   * those tokens if applicable.
   * @param _ignoreExpiration bypasses the recorded expiration date and
   * removes the lockup entry if there are any remaining for this user.
   */
  function _processLockup(
    UserInfo storage info,
    address _userId,
    bool _ignoreExpiration
  ) internal returns (bool isDone) {
    if (info.startIndex >= info.endIndex) {
      // no lockups for this user
      return true;
    }
    Lockup storage lockup = userIdLockups[_userId][info.startIndex];
    if (lockup.lockupExpirationDate > block.timestamp && !_ignoreExpiration) {
      // no more eligable entries
      return true;
    }
    emit UnlockTokens(_userId, lockup.numberOfTokensLocked, msg.sender);
    info.totalTokensLocked -= lockup.numberOfTokensLocked;
    info.startIndex++;
    // Free up space we don't need anymore
    lockup.numberOfTokensLocked = 0;
    lockup.lockupExpirationDate = 0;
    // There may be another entry
    return false;
  }

  /**
   * @notice Anyone can process lockups for a userId.
   * This is generally unused but may be required if a given userId
   * has a lot of individual lockup entries which are expired.
   */
  function processLockups(address _userId, uint _maxCount) external {
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    for (uint i = 0; i < _maxCount; i++) {
      if (_processLockup(info, _userId, false)) {
        break;
      }
    }
  }

  /**
   * @notice Allows operators to remove lockup entries, bypassing the
   * recorded expiration date.
   * @dev This should generally remain unused. It could be used in combination with
   * `addLockups` to fix an incorrect lockup expiration date or quantity.
   */
  function forceUnlockUpTo(address _userId, uint _maxLockupIndex)
    external
    onlyOperator()
  {
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    require(_maxLockupIndex > info.startIndex, "ALREADY_UNLOCKED");
    uint maxCount = _maxLockupIndex - info.startIndex;
    for (uint i = 0; i < maxCount; i++) {
      if (_processLockup(info, _userId, true)) {
        break;
      }
    }
  }

  function _isJurisdictionHalted(uint _jurisdictionId) internal view returns(bool){
    uint until = jurisdictionHaltsUntil[_jurisdictionId];
    return until != 0 && until > now;
  }

  /**
   * @notice halts jurisdictions of id `_jurisdictionIds` for `_duration` seconds
   * @dev only owner can call this function
   * @param _jurisdictionIds ids of the jurisdictions to halt
   * @param _expirationTimestamps due when halt ends
   **/
  function halt(uint[] calldata _jurisdictionIds, uint[] calldata _expirationTimestamps) external onlyOwner {
    uint length = _jurisdictionIds.length;
    for(uint i = 0; i<length; i++){
      _halt(_jurisdictionIds[i], _expirationTimestamps[i]);
    }
  }

  function _halt(uint _jurisdictionId, uint _until) internal {
    require(_until > now, "HALT_DUE_SHOULD_BE_FUTURE");
    jurisdictionHaltsUntil[_jurisdictionId] = _until;
    emit Halt(_jurisdictionId, _until);
  }

  /**
   * @notice resume halted jurisdiction
   * @dev only owner can call this function
   * @param _jurisdictionIds list of jurisdiction ids to resume
   **/
  function resume(uint[] calldata _jurisdictionIds) external onlyOwner{
    uint length = _jurisdictionIds.length;
    for(uint i = 0; i < length; i++){
      _resume(_jurisdictionIds[i]);
    }
  }

  function _resume(uint _jurisdictionId) internal {
    require(jurisdictionHaltsUntil[_jurisdictionId] != 0, "ATTEMPT_TO_RESUME_NONE_HALTED_JURISDICATION");
    jurisdictionHaltsUntil[_jurisdictionId] = 0;
    emit Resume(_jurisdictionId);
  }

  /**
   * @notice changes max investors limit of the contract to `_limit`
   * @dev only owner can call this function
   * @param _limit new investor limit for contract
   */
  function setInvestorLimit(uint _limit) external onlyOwner {
    require(_limit >= currentInvestors, "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
    maxInvestors = _limit;
    emit MaxInvestorsChanged(_limit);
  }

  /**
   * @notice changes max investors limit of the `_jurisdcitionId` to `_limit`
   * @dev only owner can call this function
   * @param _jurisdictionIds jurisdiction id to update
   * @param _limits new investor limit for jurisdiction
   */
  function setInvestorLimitForJurisdiction(uint[] calldata _jurisdictionIds, uint[] calldata _limits) external onlyOwner {
    for(uint i = 0; i<_jurisdictionIds.length; i++){
      uint jurisdictionId = _jurisdictionIds[i];
      uint limit = _limits[i];
      require(limit >= currentInvestorsByJurisdiction[jurisdictionId], "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
      maxInvestorsByJurisdiction[jurisdictionId] = limit;
      emit MaxInvestorsByJurisdictionChanged(jurisdictionId, limit);
    }
  }

  /**
   * @notice activate wallet enlist user when user is not enlisted
   * @dev This function can be called even user does not have balance
   * only owner can call this function
   */
  function activateWallets(
    address[] calldata _wallets
  ) external onlyOperator {
    for(uint i = 0; i<_wallets.length; i++){
      _activateWallet(_wallets[i]);
    }
  }

  function _activateWallet(
    address _wallet
  ) internal {
    address userId = authorizedWalletToUserId[_wallet];
    require(userId != address(0), "USER_UNKNOWN");
    require(!walletActivated[_wallet],"ALREADY_ACTIVATED_WALLET");
    if(!investorEnlisted[userId]){
      _enlistUser(userId);
    }
    userActiveWalletCount[userId]++;
    walletActivated[_wallet] = true;
    emit WalletActivated(userId, _wallet);
  }

  /**
   * @notice deactivate wallet delist user if user does not have any wallet left
   * @dev This function can only be called when _wallet has zero balance
   */
  function deactivateWallet(
    address _wallet
  ) external {
    require(callingContract.balanceOf(_wallet) == 0, "ATTEMPT_TO_DEACTIVATE_WALLET_WITH_BALANCE");
    _deactivateWallet(_wallet);
  }

  function deactivateWallets(
    address[] calldata _wallets
  ) external onlyOperator {
    for(uint i = 0; i<_wallets.length; i++){
      require(callingContract.balanceOf(_wallets[i]) == 0, "ATTEMPT_TO_DEACTIVATE_WALLET_WITH_BALANCE");
      _deactivateWallet(_wallets[i]);
    }
  }

  function _deactivateWallet(
    address _wallet
  ) internal {
    address userId = authorizedWalletToUserId[_wallet];
    require(userId != address(0), "USER_UNKNOWN");
    require(walletActivated[_wallet],"ALREADY_DEACTIVATED_WALLET");
    userActiveWalletCount[userId]--;
    walletActivated[_wallet] = false;
    emit WalletDeactivated(userId, _wallet);
    if(userActiveWalletCount[userId]==0){
      _delistUser(userId);
    }
  }

  function enlistUsers(
    address[] calldata _userIds
  ) external onlyOperator {
    for(uint i = 0; i<_userIds.length; i++){
      _enlistUser(_userIds[i]);
    }
  }

  function _enlistUser(
    address _userId
  ) internal {
    require(
      authorizedUserIdInfo[_userId].jurisdictionId != 0,
      "USER_ID_UNKNOWN"
    );
    require(!investorEnlisted[_userId],"ALREADY_ENLISTED_USER");
    investorEnlisted[_userId] = true;
    uint jurisdictionId = authorizedUserIdInfo[_userId]
      .jurisdictionId;
    uint totalCount = ++currentInvestors;
    require(maxInvestors == 0 || totalCount <= maxInvestors, "EXCEEDING_MAX_INVESTORS");
    uint jurisdictionCount = ++currentInvestorsByJurisdiction[jurisdictionId];
    uint maxJurisdictionLimit = maxInvestorsByJurisdiction[jurisdictionId];
    require(maxJurisdictionLimit == 0 || jurisdictionCount <= maxJurisdictionLimit,"EXCEEDING_JURISDICTION_MAX_INVESTORS");
    emit InvestorEnlisted(_userId, jurisdictionId);
  }

  function delistUsers(
    address[] calldata _userIds
  ) external onlyOperator {
    for(uint i = 0; i<_userIds.length; i++){
      _delistUser(_userIds[i]);
    }
  }

  function _delistUser(
    address _userId
  ) internal {
    require(investorEnlisted[_userId],"ALREADY_DELISTED_USER");
    require(userActiveWalletCount[_userId]==0,"ATTEMPT_TO_DELIST_USER_WITH_ACTIVE_WALLET");
    investorEnlisted[_userId] = false;
    uint jurisdictionId = authorizedUserIdInfo[_userId]
      .jurisdictionId;
    --currentInvestors;
    --currentInvestorsByJurisdiction[jurisdictionId];
    emit InvestorDelisted(_userId, jurisdictionId);
  }
  /**
   * @notice Called by the callingContract before a transfer occurs.
   * @dev This call will revert when the transfer is not authorized.
   * This is a mutable call to allow additional data to be recorded,
   * such as when the user aquired their tokens.
   **/
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external {
    require(address(callingContract) == msg.sender, "CALL_VIA_CONTRACT_ONLY");

    if (_to == address(0) && !_isSell) {
      // This is a burn, no authorization required
      // You can burn locked tokens. Burning will effectively burn unlocked tokens,
      // and then burn locked tokens starting with those that will be unlocked first.
      return;
    }
    address fromUserId = authorizedWalletToUserId[_from];
    require(
      fromUserId != address(0) || _from == address(0),
      "FROM_USER_UNKNOWN"
    );
    address toUserId = authorizedWalletToUserId[_to];
    require(toUserId != address(0) || _to == address(0), "TO_USER_UNKNOWN");
    if(!walletActivated[_from] && _from != address(0)){
      _activateWallet(_from);
    }
    if(!walletActivated[_to] && _to != address(0)){
      _activateWallet(_to);
    }
    if(callingContract.balanceOf(_from) == _value && _from != address(0)){
      //deactivate wallets without balance
      _deactivateWallet(_from);
    }

    // A single user can move funds between wallets they control without restriction
    if (fromUserId != toUserId) {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId]
      .jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;

      require(!_isJurisdictionHalted(fromJurisdictionId), "FROM_JURISDICTION_HALTED");
      require(!_isJurisdictionHalted(toJurisdictionId), "TO_JURISDICTION_HALTED");

      uint lockupLength = jurisdictionFlows[fromJurisdictionId][toJurisdictionId];
      require(lockupLength > 0, "DENIED: JURISDICTION_FLOW");

      // If the lockupLength is 1 then we interpret this as approved without any lockup
      // This means any token lockup period must be at least 2 seconds long in order to apply.
      if (lockupLength > 1 && _to != address(0)) {
        // Lockup may apply for any action other than burn/sell (e.g. buy/pay/transfer)
        uint lockupExpirationDate = block.timestamp + lockupLength;
        _addLockup(toUserId, lockupExpirationDate, _value);
      }

      if (_from == address(0)) {
        // This is minting (buy or pay)
        require(block.timestamp >= startDate, "WAIT_FOR_START_DATE");
      } else {
        // This is a transfer (or sell)
        UserInfo storage info = authorizedUserIdInfo[fromUserId];
        while (true) {
          if (_processLockup(info, fromUserId, false)) {
            break;
          }
        }
        uint balance = callingContract.balanceOf(_from);
        // This first require is redundant, but allows us to provide
        // a more clear error message.
        require(balance >= _value, "INSUFFICIENT_BALANCE");
        require(
          balance >= info.totalTokensLocked.add(_value),
          "INSUFFICIENT_TRANSFERABLE_BALANCE"
        );
      }
    }
  }
}
/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

// File: openzeppelin-solidity/contracts/GSN/Context.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: contracts/Interfaces/StakingInterface.sol

pragma solidity ^0.5.15;

interface StakingInterface {
    /// @notice This emits when the `owner` whitelists a new token and its underlying.
    event WhitelistToken(address indexed tokenAddress);

    /// @notice This emits when the `owner` discard a token.
    event DiscardToken(address indexed tokenAddress);

    /// @notice This emits when a new stake is created.
    event StakeEvent(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenBalance
    );

    /// @notice This emits when either the staker or the `owner` redeems the stake. The deposit plus
    ///  any accrued interest is returned back to the staker and the `owner` withholds their fee.
    event Redeem(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenWithdrawal
    );

    /// @notice This emits when the `owner` withdraws a portion or all of the accrued profits.
    event TakeEarnings(address indexed tokenAddress, uint256 indexed amount);

    /// @notice This emits when the `owner` updates the fee practiced by the contract.
//    event UpdateFee(uint256 indexed fee);

    /// @notice Returns the owner of the contract.
    /// @dev This address can whitelist and discard tokens and withdraw profits accrued over time.
    function owner() external view returns (address);

    /// @notice Returns the stake that consists of the initial deposit plus the interest accrued over time.
    /// @dev Reverts if `staker` doesn't have an active stake. Reverts if `tokenAddress` doesn't match either
    ///  the token or the underlying of the stake.
    /// @param staker The address of the user that has an active stake.
    /// @param tokenAddress The address of either the token or the underlying of the stake.
    function balanceOf(address staker, address tokenAddress) external view returns (uint256);

    /// @notice Whistelists a token to automatically convert its underlying when deposited.
    /// @dev Reverts if token is whitelisted. Reverts if `msg.sender` is not `owner`.
    /// @param tokenAddress The address of the token.
    function whitelistToken(address tokenAddress) external;

    /// @notice Discards a token that has been whitelisted before.
    /// @dev Reverts if token is not whitelisted. Reverts if `msg.sender` is not `owner`.
    /// @param tokenAddress The address of the token to discard.
    function discardToken(address tokenAddress) external;

    /// @notice Creates a new stake object for `msg.sender`. It automatically converts an underlying to
    ///  its token form so that the contract can earn interest.
    /// @dev Reverts if `msg.sender` already has an active stake. Reverts if the token/ underlying pair has not been whitelisted.
    /// @param tokenAddress The address of either the token or the underlying.
    /// @param amount The amount of tokens to deposit.
    function stake(address tokenAddress, uint256 amount) external;

    /// @notice Returns the deposit plus any accrued interest to the staker and takes the fee for the `owner`.
    /// @dev Note that the fee can only be levied on the accrued interest, never on the base deposit.
    ///  Reverts if `msg.sender` is not the staker or the `owner`.
    /// @param staker The address for whom to redeem the stake.
    /// @param tokenAddress The address of the Staking address.
    function redeem(address staker, address tokenAddress, uint256 amount) external;

    /// @notice Withdraws the earnings accrued over time to owner.
    /// @dev Reverts if `amount` is more than what's available. Reverts if `msg.sender` is not `owner`.
    /// @param tokenAddress The address of the currency for which to withdraw the funds.
    /// @param amount The amount of funds to withdraw.
    function takeEarnings(address tokenAddress, uint256 amount) external;
}

// File: contracts/Types.sol

pragma solidity ^0.5.15;

library Types {
    struct Token {
        uint256 listPointer;
    }
    struct Stake {
        address TokenAddress;
        uint256 TokenBalance;
    }
}

// File: contracts/Compound/ErrorReporter.sol

pragma solidity ^0.5.8;

contract ComptrollerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED,
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        ZUNUSED
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED
    }

    /*
     * Note: FailureInfo (but not Error) is kept in alphabetical order
     *       This is because FailureInfo grows significantly faster, and
     *       the order of Error has some meaning, while the order of FailureInfo
     *       is entirely arbitrary.
     */
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

// File: contracts/Stake.sol

pragma solidity ^0.5.15;








contract Stake is StakingInterface, Ownable, TokenErrorReporter {
    using SafeMath for uint256;
    using Roles for Roles.Role;

    Roles.Role operators;

    event WhitelistToken(address indexed tokenAddress);
    event DiscardToken(address indexed tokenAddress);

    event StakeEvent(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenBalance
    );
    event Redeem(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenWithdrawal
    );

    event TakeEarnings(address indexed tokenAddress, uint256 indexed amount);

    address[] public TokenList;
    mapping(address => Types.Token) public TokenStructs;
    mapping(address => mapping(address => Types.Stake)) public stakes;

    string private constant ERROR_AMOUNT_ZERO = "STAKING_AMOUNT_ZERO";
    string private constant ERROR_AMOUNT_NEGATIVE = "STAKING_AMOUNT_NEGATIVE";
    string private constant ERROR_TOKEN_TRANSFER = "STAKING_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "STAKING_NOT_ENOUGH_BALANCE";
    string private constant ERROR_NOT_ENOUGH_ALLOWANCE = "STAKING_NOT_ENOUGH_ALLOWANCE";
    string private constant ERROR_TOKEN_NOT_WHITELISTED = "STAKING_TOKEN_NOT_WHITELISTED";
    string private constant ERROR_NOT_OWNER = "SEND_IS_NOT_OWNER";
    string private constant ERROR_NO_STAKE = "STAKING_NOT_FOUND";
    string private constant ERROR_TOKEN_EXISTS = "TOKEN_EXISTS";
    string private constant ERROR_TOKEN_NOT_FOUND = "TOKEN_NOT_FOUND";
    string private constant ERROR_TRANSFER_FAILED = "TOKEN_TRANSFER_FAILED";

    constructor(address[] memory TokenAddress) public {
        uint256 length = TokenAddress.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                whitelistToken(TokenAddress[i]);
            }
        }
    }

    modifier onlyOperatorOrOwner() {
        require(operators.has(msg.sender) || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier onlyStakerOrOwner(address staker) {
        require(msg.sender == staker || operators.has(msg.sender)  || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier stakeExists(address staker, address tokenAddress) {
        require(stakes[staker][tokenAddress].TokenAddress == tokenAddress, ERROR_NO_STAKE);
        _;
    }

    function addOperator(address _operator) public onlyOwner
    {
        operators.add(_operator);
    }

    function removeOperator(address _operator) public onlyOwner
    {
        operators.remove(_operator);
    }

    function balanceOf(address staker, address tokenAddress) public view returns (uint256) {
        if(isStake(staker, tokenAddress)) {
            return stakes[staker][tokenAddress].TokenBalance;
        }
        return 0;
    }

    function isToken(address tokenAddress) public view returns (bool) {
        if (TokenList.length == uint256(Error.NO_ERROR)) return false;
        return (TokenList[TokenStructs[tokenAddress].listPointer] == tokenAddress);
    }

    function isStake(address staker, address tokenAddress) public view returns (bool) {
        return stakes[staker][tokenAddress].TokenAddress == tokenAddress;
    }

    function whitelistToken(address TokenAddress) public onlyOwner {
        require(!isToken(TokenAddress), ERROR_TOKEN_EXISTS);
        TokenStructs[TokenAddress].listPointer = TokenList.push(TokenAddress).sub(1);
        emit WhitelistToken(TokenAddress);
    }

    function discardToken(address TokenAddress) public onlyOwner {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        uint256 rowToDelete = TokenStructs[TokenAddress].listPointer;
        address keyToMove = TokenList[TokenList.length.sub(1)];
        TokenList[rowToDelete] = keyToMove;
        TokenStructs[keyToMove].listPointer = rowToDelete;
        TokenList.length = TokenList.length.sub(1);
        delete TokenStructs[TokenAddress];
        emit DiscardToken(TokenAddress);
    }

    function stake(address tokenAddress, uint256 amount) public {
        addStakeForToken(msg.sender, tokenAddress, amount);
    }

    function stakeFor(address staker, address tokenAddress, uint256 amount) public onlyOperatorOrOwner {
        addStakeForToken(staker, tokenAddress, amount);
    }

    function redeem(address staker, address tokenAddress, uint256 amount) public onlyOperatorOrOwner {
        require(isToken(tokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(isStake(staker, tokenAddress), ERROR_NO_STAKE);
        require(amount > 0, ERROR_AMOUNT_ZERO);

        // Get Stake
        Types.Stake memory memStake = stakes[staker][tokenAddress];
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, ERROR_NOT_ENOUGH_BALANCE);

        uint256 tBalance = memStake.TokenBalance;
        require(tBalance >= amount, ERROR_NOT_ENOUGH_BALANCE);
        require(tBalance > 0, ERROR_NOT_ENOUGH_BALANCE);

        // Calculate Remaining Balance
        uint256 remainingAmount = tBalance.sub(amount);
        require(remainingAmount >= 0, ERROR_NOT_ENOUGH_BALANCE);
        _updateStakeForToken(staker, tokenAddress, remainingAmount);

        // Transfer Amount
        require(token.transfer(staker, amount), ERROR_TOKEN_TRANSFER);
        emit Redeem(staker, tokenAddress, amount);
    }

    function takeEarnings(address tokenAddress, uint256 amount) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > amount, ERROR_NOT_ENOUGH_BALANCE);

        require(IERC20(tokenAddress).transfer(msg.sender, amount));
        emit TakeEarnings(tokenAddress, amount);
    }

    function takeAllEarnings(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, ERROR_NOT_ENOUGH_BALANCE);

        require(token.transfer(msg.sender, balance));
        emit TakeEarnings(tokenAddress, balance);
    }

    function addStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(amount > 0, ERROR_AMOUNT_ZERO);
        IERC20 token = IERC20(TokenAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, ERROR_NOT_ENOUGH_ALLOWANCE);
        uint256 funds = amount;
        if (isStake(staker, TokenAddress)) {
            Types.Stake memory memStake = stakes[staker][TokenAddress];
            funds = memStake.TokenBalance.add(amount);
        } else {
            funds = amount;
        }
        _updateStakeForToken(staker, TokenAddress, amount);
        require(token.transferFrom(msg.sender, address(this), amount), ERROR_TOKEN_TRANSFER);
        emit StakeEvent(staker, TokenAddress, amount);
    }

    function _updateStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(amount >= 0, ERROR_AMOUNT_NEGATIVE);
        stakes[staker][TokenAddress] = Types.Stake({
            TokenAddress : TokenAddress,
            TokenBalance : amount
            });
    }
}
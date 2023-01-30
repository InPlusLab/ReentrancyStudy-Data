pragma solidity ^0.5.5;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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

/**
 * Original work from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol
 * changes we made:
 * 1. add two methods that take errorMessage as input parameter
 */

library KineSafeMath {
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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     * added by Kine
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

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
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     * added by Kine
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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

pragma solidity ^0.5.0;

import "./Context.sol";
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./KineSafeMath.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using KineSafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.5.16;

import "./Context.sol";
import "./Math.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

contract TokenDispenserBase is Context, Ownable {
    using KineSafeMath for uint;
    using SafeERC20 for IERC20;

    event TransferAllocation(address indexed sender, address indexed recipient, uint amount);
    event AddAllocation(address indexed recipient, uint addAllocation, uint newAllocation);
    event ReplaceAllocation(address indexed oldAddress, address indexed newAddress, uint allocation);
    event TransferPaused();
    event TransferUnpaused();
    event AddTransferWhitelist(address account);
    event RemoveTransferWhitelist(address account);

    IERC20 kine;
    uint public startTime;
    uint public vestedPerAllocationStored;
    uint public lastUpdateTime;
    uint public totalAllocation;
    mapping(address => uint) public accountAllocations;

    struct AccountVestedDetail {
        uint vestedPerAllocationUpdated;
        uint accruedVested;
        uint claimed;
    }

    mapping(address => AccountVestedDetail) public accountVestedDetails;
    uint public totalClaimed;

    bool public transferPaused;
    // @dev transfer whitelist maintains a list of accounts that can receive allocations
    // owner transfer isn't limitted by this whitelist
    mapping(address => bool) public transferWhitelist;

    modifier onlyAfterStart() {
        require(block.timestamp >= startTime, "not started yet");
        _;
    }

    modifier onlyInTransferWhitelist(address account) {
        require(transferWhitelist[account], "receipient not in transfer whitelist");
        _;
    }

    modifier updateVested(address account) {
        updateVestedInternal(account);
        _;
    }

    modifier onlyTransferNotPaused() {
        require(!transferPaused, "transfer paused");
        _;
    }

    modifier onlyTransferPaused() {
        require(transferPaused, "transfer not paused");
        _;
    }

    function updateVestedInternal(address account) internal {
        vestedPerAllocationStored = vestedPerAllocation();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            accountVestedDetails[account].accruedVested = vested(account);
            accountVestedDetails[account].vestedPerAllocationUpdated = vestedPerAllocationStored;
        }
    }

    // @dev should be implemented by inheritent contract
    function vestedPerAllocation() public view returns (uint);

    function vested(address account) public view returns (uint) {
        return accountAllocations[account]
        .mul(vestedPerAllocation().sub(accountVestedDetails[account].vestedPerAllocationUpdated))
        .div(1e18)
        .add(accountVestedDetails[account].accruedVested);
    }

    function claimed(address account) public view returns (uint) {
        return accountVestedDetails[account].claimed;
    }

    function claim() external onlyAfterStart updateVested(msg.sender) {
        AccountVestedDetail storage detail = accountVestedDetails[msg.sender];
        uint accruedVested = detail.accruedVested;
        if (accruedVested > 0) {
            detail.claimed = detail.claimed.add(accruedVested);
            totalClaimed = totalClaimed.add(accruedVested);
            detail.accruedVested = 0;
            kine.safeTransfer(msg.sender, accruedVested);
        }
    }

    // @notice User may transfer part or full of its allocations to others.
    // The vested tokens right before transfer belongs to the user account, and the to-be vested tokens will belong to recipient after transfer.
    // Transfer will revert if transfer is paused by owner.
    // Only whitelisted account may transfer their allocations.
    function transferAllocation(address recipient, uint amount) external onlyTransferNotPaused onlyInTransferWhitelist(recipient) updateVested(msg.sender) updateVested(recipient) returns (bool) {
        address payable sender = _msgSender();
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        accountAllocations[sender] = accountAllocations[sender].sub(amount, "transfer amount exceeds balance");
        accountAllocations[recipient] = accountAllocations[recipient].add(amount);
        emit TransferAllocation(sender, recipient, amount);
        return true;
    }

    //////////////////////////////////////////
    // allocation management by owner

    // @notice Only owner may add allocations to accounts.
    // When owner add allocations to recipients after distribution start time, recipients can only recieve partial tokens.
    function addAllocation(address[] calldata recipients, uint[] calldata allocations) external onlyOwner {
        require(recipients.length == allocations.length, "recipients and allocations length not match");
        if (block.timestamp <= startTime) {
            // if distribution has't start, just add allocations to recipients
            for (uint i = 0; i < recipients.length; i++) {
                accountAllocations[recipients[i]] = accountAllocations[recipients[i]].add(allocations[i]);
                totalAllocation = totalAllocation.add(allocations[i]);
                transferWhitelist[recipients[i]] = true;
                emit AddAllocation(recipients[i], allocations[i], accountAllocations[recipients[i]]);
                emit AddTransferWhitelist(recipients[i]);
            }
        } else {
            // if distribution already started, need to update recipients vested allocations before add allocations
            for (uint i = 0; i < recipients.length; i++) {
                updateVestedInternal(recipients[i]);
                accountAllocations[recipients[i]] = accountAllocations[recipients[i]].add(allocations[i]);
                totalAllocation = totalAllocation.add(allocations[i]);
                transferWhitelist[recipients[i]] = true;
                emit AddAllocation(recipients[i], allocations[i], accountAllocations[recipients[i]]);
                emit AddTransferWhitelist(recipients[i]);
            }
        }
    }

    //////////////////////////////////////////////
    // transfer management by owner
    function pauseTransfer() external onlyOwner onlyTransferNotPaused {
        transferPaused = true;
        emit TransferPaused();
    }

    function unpauseTransfer() external onlyOwner onlyTransferPaused {
        transferPaused = false;
        emit TransferUnpaused();
    }

    // @notice Owner is able to transfer allocation between any accounts in case special cases happened, e.g. someone lost their address/key.
    // However, the vested tokens before transfer will remain in the account before transfer.
    // Onwer transfer is not limited by the transfer pause status.
    function transferAllocationFrom(address from, address recipient, uint amount) external onlyOwner updateVested(from) updateVested(recipient) returns (bool) {
        require(from != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        accountAllocations[from] = accountAllocations[from].sub(amount, "transfer amount exceeds balance");
        accountAllocations[recipient] = accountAllocations[recipient].add(amount);
        emit TransferAllocation(from, recipient, amount);
        return true;
    }

    // @notice Owner is able to replace accountVestedDetails address with a new one, in case of receipient give us an unoperateable address (like exchange address)
    // The unclaimed allocations will all be transferred to new address including the vest status.
    function replaceAccountWith(address oldAddress, address newAddress) external onlyOwner {
        require(oldAddress != address(0), "replace from the zero address");
        require(newAddress != address(0), "replace to the zero address");

        uint allocation = accountAllocations[oldAddress];
        AccountVestedDetail memory avd = accountVestedDetails[oldAddress];
        AccountVestedDetail storage navd = accountVestedDetails[newAddress];

        require(accountAllocations[newAddress] == 0, "new address already has allocation");
        require(navd.vestedPerAllocationUpdated == 0, "new address already has vestedPerAllocationUpdated");

        accountAllocations[newAddress] = allocation;
        navd.accruedVested = avd.accruedVested;
        navd.vestedPerAllocationUpdated = avd.vestedPerAllocationUpdated;
        navd.claimed = avd.claimed;

        transferWhitelist[newAddress] = true;

        delete accountAllocations[oldAddress];
        delete accountVestedDetails[oldAddress];
        delete transferWhitelist[oldAddress];

        emit RemoveTransferWhitelist(oldAddress);
        emit AddTransferWhitelist(newAddress);
        emit ReplaceAllocation(oldAddress, newAddress, allocation);
    }

    function addTransferWhitelist(address account) external onlyOwner {
        transferWhitelist[account] = true;
        emit AddTransferWhitelist(account);
    }

    function removeTransferWhitelist(address account) external onlyOwner {
        delete transferWhitelist[account];
        emit RemoveTransferWhitelist(account);
    }
}

pragma solidity ^0.5.16;

import "./TokenDispenserBase.sol";

contract TokenDispenserSeedI10Y60Y30 is TokenDispenserBase {
    uint public year1EndTime;
    uint public year2EndTime;
    // @notice 10% vested immediately after launch. scaled by 1e18
    uint public constant immediateVestRatio = 1e17;
    // @notice 60% vested lineary in 1st year. scaled by 1e18
    uint public constant y1VestRatio = 6e17;
    // @notice 30% vested lineary in 2nd year. scaled by 1e18
    uint public constant y2VestRatio = 3e17;
    // @notice the vest rate in first year is 0.6 / 365 days in seconds, scaled by 1e18
    uint public constant y1rate = y1VestRatio / 365 days;
    // @notice the vest rate in second year is 0.3 / 365 days in seconds, scaled by 1e18
    uint public constant y2rate = y2VestRatio / 365 days;

    constructor (address kine_, uint startTime_) public {
        kine = IERC20(kine_);
        startTime = startTime_;
        transferPaused = false;
        year1EndTime = startTime_.add(365 days);
        year2EndTime = startTime_.add(730 days);
    }

    function vestedPerAllocation() public view returns (uint) {
        // vested token per allocation is calculated as
        // Immediately vest 10% after distribution launched
        // Linearly vest 60% in the 1st year after launched
        // Linearly vest 30% in the 2nd year after launched
        uint currentTime = block.timestamp;
        if (currentTime <= startTime) {
            return 0;
        }
        if (currentTime <= year1EndTime) {
            return immediateVestRatio.add(currentTime.sub(startTime).mul(y1rate));
        }
        if (currentTime <= year2EndTime) {
            return immediateVestRatio.add(y1VestRatio).add(currentTime.sub(year1EndTime).mul(y2rate));
        }
        return 1e18;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Pausable.sol

pragma solidity >=0.6.0 <0.8.0;


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
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor () internal {
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
}

// File: contracts/TimeLockedTokenDistribute.sol

pragma solidity ^0.6.0;

contract TimeLockedTokenDistribute is Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;

    // represents total distribution for locked balances
    mapping(address => uint256) public distribution;

    // represents first unlock
    mapping(address => uint256) public firstunlock;

    // Token Address
    IERC20 token;

    // Claimed Token
    mapping(address => uint256) public ClaimedBalances;

    // start of the lockup period
    // Wednesday, April 21, 2021 02:00:00 AM UTC +0
    uint256 constant LOCK_START = 1618970400;
    // length of time to delay first epoch
    uint256 constant FIRST_EPOCH_DELAY = 21 days;
    // how long does an epoch last
    uint256 constant EPOCH_DURATION = 1 days;
    // number of epochs
    uint256 constant TOTAL_EPOCHS = 365;

    // // Friday, July 24, 2021 4:58:31 PM GMT
    // uint256 constant LOCK_START = 1618840800;
    // // length of time to delay first epoch
    // uint256 constant FIRST_EPOCH_DELAY = 0 minutes;
    // // how long does an epoch last
    // uint256 constant EPOCH_DURATION = 5 minutes;
    // // number of epochs
    // uint256 constant TOTAL_EPOCHS = 20000;

    // first unlock percent * 100
    uint256 constant FIRST_UNLOCK = 30;

    // registry of locked addresses
    address public timeLockRegistry;

    modifier onlyTimeLockRegistry() {
        require(msg.sender == timeLockRegistry, "only TimeLockRegistry");
        _;
    }

    constructor(address _TimeLockRegistry, IERC20 _token) public {
        require(_TimeLockRegistry != address(0), "cannot be zero address");

        token = _token;
        timeLockRegistry = _TimeLockRegistry;
    }

    function setToken(IERC20 _token) external onlyOwner {
        require(address(token) != address(0), "cannot be zero address");
        require(_token != token, "must be new token");
        token = _token;
    }

    function setTimeLockRegistry(address newTimeLockRegistry)
        external
        onlyOwner
    {
        require(newTimeLockRegistry != address(0), "cannot be zero address");
        require(
            newTimeLockRegistry != timeLockRegistry,
            "must be new TimeLockRegistry"
        );
        timeLockRegistry = newTimeLockRegistry;
    }

    function claim() public nonReentrant() whenNotPaused() {
        uint256 tokenCanClaimed =
            unlockedBalance(msg.sender).sub(ClaimedBalances[msg.sender]);
        require(tokenCanClaimed > 0, "Sender has 0 unclaimed tokens");
        //Log
        ClaimedBalances[msg.sender] = unlockedBalance(msg.sender);
        require(
            token.balanceOf(address(this)) >= tokenCanClaimed,
            "insufficient balance"
        );
        token.transfer(msg.sender, tokenCanClaimed);
    }

    function registerLockupByArr(
        address[] memory _receivers,
        uint256[] memory _amounts,
        uint256[] memory _unlocks
    ) external onlyTimeLockRegistry {
        uint256 totalAmount;
        for (uint256 i = 0; i < _receivers.length; i++) {
            require(distribution[_receivers[i]] == 0, "Only add once.");
            require(firstunlock[_receivers[i]] == 0, "Only add once.");
            require(_unlocks[i] <= _amounts[i], "invalid first unlock amount.");

            // add amount to locked distribution
            distribution[_receivers[i]] = distribution[_receivers[i]].add(
                _amounts[i]
            );

            // add firstunlock
            firstunlock[_receivers[i]] = firstunlock[_receivers[i]].add(
                _unlocks[i]
            );

            totalAmount = totalAmount.add(_amounts[i]);
        }

        // transfer to LockContract
        // require(
        //     token.balanceOf(msg.sender) >= totalAmount,
        //     "insufficient balance"
        // );
        // token.transferFrom(msg.sender, address(this), totalAmount);
    }

    /**
     * @dev Transfer tokens to another account under the lockup schedule
     * Emits a transfer event showing a transfer to the recipient
     * Only the registry can call this function
     * @param receiver Address to receive the tokens
     * @param amount Tokens to be transferred
     */
    function registerLockup(
        address receiver,
        uint256 amount,
        uint256 unlock
    ) external onlyTimeLockRegistry {
        require(token.balanceOf(msg.sender) >= amount, "insufficient balance");

        require(distribution[receiver] == 0, "Only add once.");
        require(firstunlock[receiver] == 0, "Only add once.");
        require(unlock <= amount, "invalid first unlock amount.");

        // add amount to locked distribution
        distribution[receiver] = distribution[receiver].add(amount);

        // add firstunlock
        firstunlock[receiver] = firstunlock[receiver].add(unlock);

        // transfer to LockContract
        // token.transferFrom(msg.sender, address(this), amount);
    }

    function deposit(uint256 amount) external onlyTimeLockRegistry {
        require(token.balanceOf(msg.sender) >= amount, "insufficient balance");
        // transfer to LockContract
        token.transferFrom(msg.sender, address(this), amount);
    }

    // function lockedBalance(address account) public view returns (uint256) {
    //     // distribution * (epochsLeft / totalEpochs)
    //     return distribution[account].mul(epochsLeft()).div(TOTAL_EPOCHS);
    // }

    function lockedBalance(address account) public view returns (uint256) {
        // distribution * 0.7 * (epochsLeft / totalEpochs)
        // return distribution[account].mul(100 - FIRST_UNLOCK).div(100).mul(epochsLeft()).div(TOTAL_EPOCHS);

        // (distribution - firstunlock) * (epochsLeft / totalEpochs)
        return
            distribution[account]
                .sub(firstunlock[account])
                .mul(epochsLeft())
                .div(TOTAL_EPOCHS);
    }

    function unlockedBalance(address account) public view returns (uint256) {
        // totalBalance - lockedBalance
        return distribution[account].sub(lockedBalance(account));
    }

    function claimedBalance(address account) public view returns (uint256) {
        return ClaimedBalances[account];
    }

    function epochsPassed() public view returns (uint256) {
        // return 0 if timestamp is lower than start time
        if (block.timestamp < LOCK_START) {
            return 0;
        }

        // how long it has been since the beginning of lockup period
        uint256 timePassed = block.timestamp.sub(LOCK_START);

        // 1st epoch is FIRST_EPOCH_DELAY longer; we check to prevent subtraction underflow
        if (timePassed < FIRST_EPOCH_DELAY) {
            return 0;
        }

        // subtract the FIRST_EPOCH_DELAY, so that we can count all epochs as lasting EPOCH_DURATION
        uint256 totalEpochsPassed =
            timePassed.sub(FIRST_EPOCH_DELAY).div(EPOCH_DURATION);

        // epochs don't count over TOTAL_EPOCHS
        if (totalEpochsPassed > TOTAL_EPOCHS) {
            return TOTAL_EPOCHS;
        }

        return totalEpochsPassed;
    }

    function epochsLeft() public view returns (uint256) {
        return TOTAL_EPOCHS.sub(epochsPassed());
    }

    function nextEpoch() public view returns (uint256) {
        // get number of epochs passed
        uint256 passed = epochsPassed();

        // if all epochs passed, return
        if (passed == TOTAL_EPOCHS) {
            // return INT_MAX
            return uint256(-1);
        }

        // if no epochs passed, return latest epoch + delay + standard duration
        if (passed == 0) {
            return latestEpoch().add(FIRST_EPOCH_DELAY).add(EPOCH_DURATION);
        }

        // otherwise return latest epoch + epoch duration
        return latestEpoch().add(EPOCH_DURATION);
    }

    function latestEpoch() public view returns (uint256) {
        // get number of epochs passed
        uint256 passed = epochsPassed();

        // if no epochs passed, return lock start time
        if (passed == 0) {
            return LOCK_START;
        }

        // accounts for first epoch being longer
        // lockStart + firstEpochDelay + (epochsPassed * epochDuration)
        return
            LOCK_START.add(FIRST_EPOCH_DELAY).add(passed.mul(EPOCH_DURATION));
    }

    function finalEpoch() public pure returns (uint256) {
        // lockStart + firstEpochDelay + (epochDuration * totalEpochs)
        return
            LOCK_START.add(FIRST_EPOCH_DELAY).add(
                EPOCH_DURATION.mul(TOTAL_EPOCHS)
            );
    }

    function lockStart() public pure returns (uint256) {
        return LOCK_START;
    }
}
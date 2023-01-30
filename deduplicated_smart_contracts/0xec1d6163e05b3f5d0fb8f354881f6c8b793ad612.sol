/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

//  =====================================================================================
//
//   ___ __ __    ________  ___   __   _________   ______  ______   ______  ______
//  /__//_//_/\  /_______/\/__/\ /__/\/________/\ /_____/\/_____/\ /_____/\/_____/\
//  \::\| \| \ \ \__.::._\/\::\_\\  \ \__.::.__\/ \:::_ \ \:::_ \ \\:::_ \ \:::_ \ \
//   \:.      \ \   \::\ \  \:. `-\  \ \ \::\ \    \:\ \ \ \:(_) ) )\:\ \ \ \:(_) \ \
//    \:.\-/\  \ \  _\::\ \__\:. _    \ \ \::\ \    \:\ \ \ \: __ `\ \:\ \ \ \: ___\/
//     \. \  \  \ \/__\::\__/\\. \`-\  \ \ \::\ \    \:\/.:| \ \ `\ \ \:\_\ \ \ \ \
//      \__\/ \__\/\________\/ \__\/ \__\/  \__\/     \____/_/\_\/ \_\/\_____\/\_\/
//
//  =====================================================================================

// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

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

pragma solidity 0.6.11;

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

pragma solidity 0.6.11;

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


pragma solidity 0.6.11;

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

pragma solidity 0.6.11;

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity 0.6.11;

// This interface is designed to be compatible with the Vyper version.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
interface IDepositContract {
    /// @notice A processed deposit event.
    event DepositEvent(
        bytes pubkey,
        bytes withdrawal_credentials,
        bytes amount,
        bytes signature,
        bytes index
    );

    /// @notice Submit a Phase 0 DepositData object.
    /// @param pubkey A BLS12-381 public key.
    /// @param withdrawal_credentials Commitment to a public key for withdrawals.
    /// @param signature A BLS12-381 signature.
    /// @param deposit_data_root The SHA-256 hash of the SSZ-encoded DepositData object.
    /// Used as a protection against malformed input.
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    /// @notice Query the current deposit root hash.
    /// @return The deposit root hash.
    function get_deposit_root() external view returns (bytes32);

    /// @notice Query the current deposit count.
    /// @return The deposit count encoded as a little endian 64-bit number.
    function get_deposit_count() external view returns (bytes memory);
}

pragma solidity 0.6.11;

interface IVETH {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function unpause() external;
    function paused() external view returns (bool);
}

pragma solidity 0.6.11;

contract MintDrop is Ownable {
    using SafeMath for uint;

    /* ========== CONSTANTS ========== */

    uint constant public BONUS_DURATION = 32 days;
    uint constant public MAX_CLAIM_DURATION = 8 days;
    uint constant public TOTAL_BNC_REWARDS = 100000 ether;

    /* ========== STATE VARIABLES ========== */

    // address of vETH
    address public immutable vETHAddress;
    // address of Ethereum 2.0 Deposit Contract
    address public immutable depositAddress;
    // a timestamp when the bonus activity initialized
    uint public immutable bonusStartAt;
    // a flag to control whether the withdraw function is locked
    bool public withdrawLocked;
    // total amount of ETH deposited to Ethereum 2.0 Deposit Contract
    uint public totalLocked;
    // total amount of ETH deposited in this contract
    uint public totalDeposit;
    // total claimed amount of BNC rewards
    uint public claimedRewards;
    // user address => amount of ETH deposited by this user in this contract
    mapping(address => uint) public myDeposit;
    // user address => amount of BNC rewards that will rewarded to this user
    mapping(address => uint) public myRewards;
    // user address => a timestamp that this user claimed rewards
    mapping(address => uint) public myLastClaimedAt;
    // user address => the address of this user which in ss58 format on Bifrost Network
    mapping(address => string) public bifrostAddress;

    /* ========== EVENTS ========== */

    event Deposit(address indexed sender, uint amount);
    event Withdrawal(address indexed sender, uint amount);
    event Claimed(address indexed sender, uint amount, uint claimed);
    event NewValidator(bytes little_endian_deposit_count);
    event BindAddress(address indexed sender, string bifrostAddress);

    /* ========== CONSTRUCTOR ========== */

    constructor(address vETHAddress_, address depositAddress_, uint bonusStartAt_) public Ownable() {
        vETHAddress = vETHAddress_;
        depositAddress = depositAddress_;
        bonusStartAt = bonusStartAt_;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function deposit() external payable {
        claimRewards();
        myDeposit[msg.sender] = myDeposit[msg.sender].add(msg.value);
        totalDeposit = totalDeposit.add(msg.value);
        // mint vETH, MintDrop should have ownership of vETH contract
        IVETH(vETHAddress).mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) external isWithdrawNotLocked {
        claimRewards();
        myDeposit[msg.sender] = myDeposit[msg.sender].sub(amount);
        totalDeposit = totalDeposit.sub(amount);
        // burn vETH, MintDrop should have ownership of vETH contract
        IVETH(vETHAddress).burn(msg.sender, amount);
        msg.sender.transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function claimRewards() public {
        // claim must start from bonusStartAt
        if (now < bonusStartAt) {
            if (myLastClaimedAt[msg.sender] < bonusStartAt) {
                myLastClaimedAt[msg.sender] = bonusStartAt;
            }
            return;
        }
        if (myLastClaimedAt[msg.sender] >= bonusStartAt) {
            uint rewards = getIncrementalRewards(msg.sender);
            myRewards[msg.sender] = myRewards[msg.sender].add(rewards);
            claimedRewards = claimedRewards.add(rewards);
            emit Claimed(msg.sender, myRewards[msg.sender], claimedRewards);
        }
        myLastClaimedAt[msg.sender] = now > bonusStartAt.add(BONUS_DURATION)
        ? bonusStartAt.add(BONUS_DURATION)
        : now;
    }

    function lockForValidator(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external onlyOwner isWithdrawLocked {
        uint amount = 32 ether;
        require(address(this).balance >= amount, "insufficient balance");
        totalLocked = totalLocked.add(amount);
        IDepositContract(depositAddress).deposit{value: amount}(
            pubkey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
        emit NewValidator(IDepositContract(depositAddress).get_deposit_count());
    }

    function bindBifrostAddress(string memory bifrostAddress_) external {
        bifrostAddress[msg.sender] = bifrostAddress_;
        emit BindAddress(msg.sender, bifrostAddress_);
    }

    function lockWithdraw() external onlyOwner isWithdrawNotLocked {
        withdrawLocked = true;
        // enable vETH transfer, MintDrop should have ownership of vETH contract
        if (IVETH(vETHAddress).paused()) {
            IVETH(vETHAddress).unpause();
        }
    }

    function unlockWithdraw() external onlyOwner isWithdrawLocked {
        withdrawLocked = false;
    }

    /* ========== VIEWS ========== */

    function getTotalRewards() public view returns (uint) {
        if (now < bonusStartAt) {
            return 0;
        }
        uint duration = now.sub(bonusStartAt);
        if (duration > BONUS_DURATION) {
            return TOTAL_BNC_REWARDS;
        }
        return TOTAL_BNC_REWARDS.mul(duration).div(BONUS_DURATION);
    }

    function getIncrementalRewards(address target) public view returns (uint) {
        uint totalRewards = getTotalRewards();
        if (
            myLastClaimedAt[target] < bonusStartAt ||
            totalDeposit == 0 ||
            totalRewards == 0
        ) {
            return 0;
        }
        uint remainingRewards = totalRewards.sub(claimedRewards);
        uint myDuration = now > bonusStartAt.add(BONUS_DURATION)
        ? bonusStartAt.add(BONUS_DURATION).sub(myLastClaimedAt[target])
        : now.sub(myLastClaimedAt[target]);
        if (myDuration > MAX_CLAIM_DURATION) {
            myDuration = MAX_CLAIM_DURATION;
        }
        uint rewards = remainingRewards
        .mul(myDeposit[target])
        .div(totalDeposit)
        .mul(myDuration)
        .div(MAX_CLAIM_DURATION);
        return rewards;
    }

    function getRewards(address target) external view returns (uint) {
        return myRewards[target].add(getIncrementalRewards(target));
    }

    modifier isWithdrawLocked() {
        require(withdrawLocked, "withdrawal not locked");
        _;
    }

    modifier isWithdrawNotLocked() {
        require(!withdrawLocked, "withdrawal locked");
        _;
    }
}
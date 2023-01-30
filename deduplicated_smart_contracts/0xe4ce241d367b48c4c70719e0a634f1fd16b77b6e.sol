// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/Context.sol";
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
    constructor () {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IWETH.sol";

interface IRewardPool {
    function fundPool(uint256 reward) external;
}

interface IDrainController {
    function distribute() external;
}

/**
* @title Receives rewards from MasterVampire via drain and redistributes
*/
contract DrainDistributor is Ownable {
    using SafeMath for uint256;
    IWETH immutable WETH;

    // Distribution
    // Percentages are using decimal base of 1000 ie: 10% = 100
    uint256 public gasShare = 100;
    uint256 public devShare = 250;
    uint256 public uniRewardPoolShare = 200;
    uint256 public yflRewardPoolShare = 200;
    uint256 public drcRewardPoolShare = 250;
    uint256 public wethThreshold = 200000000000000000 wei;

    address public devFund;
    address public uniRewardPool;
    address public yflRewardPool;
    address public drcRewardPool;
    address payable public drainController;

    /**
     * @notice Construct the contract
     * @param uniRewardPool_ address of the uniswap LP reward pool
     * @param yflRewardPool_ address of the linkswap LP reward pool
     * @param drcRewardPool_ address of the DRC->ETH reward pool
     */
    constructor(address weth_, address _devFund, address uniRewardPool_, address yflRewardPool_, address drcRewardPool_) {
        require((gasShare + devShare + uniRewardPoolShare + yflRewardPoolShare + drcRewardPoolShare) == 1000, "invalid distribution");
        uniRewardPool = uniRewardPool_;
        yflRewardPool = yflRewardPool_;
        drcRewardPool = drcRewardPool_;
        WETH = IWETH(weth_);
        devFund = _devFund;
        IWETH(weth_).approve(uniRewardPool, uint256(-1));
        IWETH(weth_).approve(yflRewardPool, uint256(-1));
        IWETH(weth_).approve(drcRewardPool, uint256(-1));
    }

    /**
     * @notice Allow depositing ether to the contract
     */
    receive() external payable {}

    /**
     * @notice Distributes drained rewards
     */
    function distribute() external {
        require(drainController != address(0), "drainctrl not set");
        require(WETH.balanceOf(address(this)) >= wethThreshold, "weth balance too low");
        uint256 drainWethBalance = WETH.balanceOf(address(this));
        uint256 gasAmt = drainWethBalance.mul(gasShare).div(1000);
        uint256 devAmt = drainWethBalance.mul(devShare).div(1000);
        uint256 uniRewardPoolAmt = drainWethBalance.mul(uniRewardPoolShare).div(1000);
        uint256 yflRewardPoolAmt = drainWethBalance.mul(yflRewardPoolShare).div(1000);
        uint256 drcRewardPoolAmt = drainWethBalance.mul(drcRewardPoolShare).div(1000);

        // Unwrap WETH and transfer ETH to DrainController to cover drain gas fees
        WETH.withdraw(gasAmt);
        drainController.transfer(gasAmt);

        // Treasury
        WETH.transfer(devFund, devAmt);

        // Reward pools
        IRewardPool(uniRewardPool).fundPool(uniRewardPoolAmt);
        IRewardPool(yflRewardPool).fundPool(yflRewardPoolAmt);
        IRewardPool(drcRewardPool).fundPool(drcRewardPoolAmt);
    }

    /**
     * @notice Changes the distribution percentage
     *         Percentages are using decimal base of 1000 ie: 10% = 100
     */
    function changeDistribution(
        uint256 gasShare_,
        uint256 devShare_,
        uint256 uniRewardPoolShare_,
        uint256 yflRewardPoolShare_,
        uint256 drcRewardPoolShare_)
        external
        onlyOwner
    {
        require((gasShare_ + devShare_ + uniRewardPoolShare_ + yflRewardPoolShare_ + drcRewardPoolShare_) == 1000, "invalid distribution");
        gasShare = gasShare_;
        devShare = devShare_;
        uniRewardPoolShare = uniRewardPoolShare_;
        yflRewardPoolShare = yflRewardPoolShare_;
        drcRewardPoolShare = drcRewardPoolShare_;
    }

    /**
     * @notice Changes the address of the dev treasury
     * @param devFund_ the new address
     */
    function changeDev(address devFund_) external onlyOwner {
        require(devFund_ != address(0));
        devFund = devFund_;
    }

    /**
     * @notice Changes the address of the Drain controller
     * @param drainController_ the new address
     */
    function changeDrainController(address payable drainController_) external onlyOwner {
        require(drainController_ != address(0));
        drainController = drainController_;
    }

    /**
     * @notice Changes the address of the uniswap LP reward pool
     * @param rewardPool_ the new address
     */
    function changeUniRewardPool(address rewardPool_) external onlyOwner {
        require(rewardPool_ != address(0));
        uniRewardPool = rewardPool_;
         WETH.approve(uniRewardPool, uint256(-1));
    }

    /**
     * @notice Changes the address of the linkswap LP reward pool
     * @param rewardPool_ the new address
     */
    function changeYFLRewardPool(address rewardPool_) external onlyOwner {
        require(rewardPool_ != address(0));
        yflRewardPool = rewardPool_;
        WETH.approve(yflRewardPool, uint256(-1));
    }

    /**
     * @notice Changes the address of the DRC->ETH reward pool
     * @param rewardPool_ the new address
     */
    function changeDRCRewardPool(address rewardPool_) external onlyOwner {
        require(rewardPool_ != address(0));
        drcRewardPool = rewardPool_;
        WETH.approve(drcRewardPool, uint256(-1));
    }

    /**
     * @notice Change the WETH distribute threshold
     */
    function setWETHThreshold(uint256 wethThreshold_) external onlyOwner {
        wethThreshold = wethThreshold_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

{
  "evmVersion": "istanbul",
  "libraries": {},
  "metadata": {
    "bytecodeHash": "ipfs",
    "useLiteralContent": true
  },
  "optimizer": {
    "enabled": true,
    "runs": 9999
  },
  "remappings": [],
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}
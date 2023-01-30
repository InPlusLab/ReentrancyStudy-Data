/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
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
}

// File: contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Emitted when the `owner` initiates a force transfer
     *
     * Note that `value` may be zero.
     * Note that `details` may be zero.
     */
    event ForceTransfer(address indexed from, address indexed to, uint256 value, bytes32 details);
}

// File: contracts/atomic-swap/AtomicSwap.sol
contract AtomicSwap is Ownable {
    using SafeMath for uint256;

    enum Direction { Buy, Sell }
    enum SwapState {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
    }

    struct Swap {
        uint256 price;
        uint256 amount;
        uint256 remainingAmount;
        Direction direction;
        address openTrader;
        SwapState swapState;
    }
    mapping (uint256 => Swap) private swaps;
    uint256 public minimumPrice = 0;
    uint256 public minimumAmount = 0;
    uint256 priceMultiplicator = 1000000; // 6 decimals price

    uint256 swapId = 0;
    IERC20 awgContract;
    IERC20 awxContract;
    event Open(uint256 _swapId);
    event Trade(uint256 _swapId, address taker, uint256 amount);
    event Close(uint256 _swapId);

    constructor(address _awgContract, address _awxContract) public {
        minimumPrice = 0;
        awgContract = IERC20(_awgContract);
        awxContract = IERC20(_awxContract);
    }

    function setMinimumPrice(uint256 _price) onlyOwner public {
        minimumPrice = _price;
    }
    function setMinimumAmount(uint256 _amount) onlyOwner public {
        minimumAmount = _amount;
    }

    function forceCloseSwap(uint256 _swapId) onlyOwner public {
        Swap memory swap = swaps[_swapId];
        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(swap.openTrader,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(swap.openTrader,swap.remainingAmount), "Cannot transfer AWX");
        }
        emit Close(_swapId);
    }

    function openSwap(uint256 _price, uint256 _amount, Direction _direction) public {
        require(_price > minimumPrice, "Price is too low");
        require(_amount > minimumAmount, "Amount is too low");
        if (_direction == Direction.Buy) {
            require(_amount.mul(_price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)), "Cannot transfer AWG");
            require(awgContract.transferFrom(msg.sender, address(this), _amount.mul(_price).div(priceMultiplicator)));
        } else {
            require(_amount <= awxContract.allowance(msg.sender, address(this)), "Cannot transfer AWX");
            require(awxContract.transferFrom(msg.sender, address(this), _amount));
        }
        Swap memory swap = Swap({
            price: _price,
            amount: _amount,
            direction: _direction,
            remainingAmount: _amount,
            openTrader: msg.sender,
            swapState: SwapState.OPEN
            });

        swaps[swapId] = swap;
        emit Open(swapId);
        swapId++;
    }

    function closeSwap(uint256 _swapId) public {
        Swap memory swap = swaps[_swapId];
        require(swap.swapState == SwapState.OPEN);
        require(swap.openTrader == msg.sender);

        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(msg.sender,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(msg.sender,swap.remainingAmount), "Cannot transfer AWX");
        }

        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        emit Close(_swapId);
    }

    function tradeSwap(uint256 _swapId, uint256 _amount) public {
        require(_amount > minimumAmount, "Amount is too low");
        Swap memory swap = swaps[_swapId];
        require(_amount <= swap.remainingAmount);
        require(swap.swapState == SwapState.OPEN);
        if (swap.direction == Direction.Buy) {
            require(_amount <= awxContract.allowance(msg.sender, address(this)));
            require(awxContract.transferFrom(msg.sender, swap.openTrader, _amount));
            require(awgContract.transfer(msg.sender, _amount.mul(swap.price).div(priceMultiplicator)));
        } else {
            require(_amount.mul(swap.price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)));
            require(awgContract.transferFrom(msg.sender, swap.openTrader, _amount.mul(swap.price).div(priceMultiplicator)));
            require(awxContract.transfer(msg.sender, _amount));
        }
        swap.remainingAmount -= _amount;
        if (swap.remainingAmount == 0) {
            swap.swapState = SwapState.CLOSED;
            emit Close(_swapId);
        }
        swaps[_swapId] = swap;
        emit Trade(_swapId, msg.sender, _amount);
    }

    function getSwap(uint256 _swapId) public view returns (uint256 price, uint256 amount, uint256 remainingAmount, Direction direction, address openTrader, SwapState swapState) {
        Swap memory swap = swaps[_swapId];
        return (swap.price, swap.amount, swap.remainingAmount, swap.direction, swap.openTrader, swap.swapState);
    }
}
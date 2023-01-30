/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

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
}

contract  DividendToken is IERC20 {
    function totalSupplyAt(uint _blockNumber) external view returns(uint);
    function balanceOfAt(address _owner, uint _blockNumber) external view returns (uint);
}


contract DividendManager is Ownable {
    using SafeMath for uint;

    event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);
    event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);
    event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

    DividendToken public dividendToken;

    uint256 public RECYCLE_TIME = 365 days;

    struct Dividend {
        uint256 blockNumber;
        uint256 timestamp;
        uint256 amount;
        uint256 claimedAmount;
        uint256 totalSupply;
        bool recycled;
        mapping(address => bool) claimed;
    }

    Dividend[] public dividends;

    uint public allocatedValue;

    mapping(address => uint256) dividendsClaimed;

    modifier validDividendIndex(uint256 _dividendIndex) {
        require(_dividendIndex < dividends.length);
        _;
    }

    constructor (DividendToken _dividendToken) public {
        dividendToken = _dividendToken;
    }

    function () external payable {
    }

    function dividendsCount() external view returns (uint) {
        return dividends.length;
    }

    function unallocatedValue() public view returns (uint) {
        return address(this).balance.sub(allocatedValue);
    }

    function allocateDividend() public {
        uint balance = unallocatedValue();
        require(balance > 0);
        _depositDividend(balance);
    }

    function depositDividend() public payable {
        _depositDividend(msg.value);
    }

    function _depositDividend(uint value) internal {
        require(value > 0);
        uint256 currentSupply = dividendToken.totalSupplyAt(block.number);
        uint256 dividendIndex = dividends.length;
        uint256 blockNumber = block.number - 1;
        dividends.push(
            Dividend(
                blockNumber,
                now,
                value,
                0,
                currentSupply,
                false
            )
        );
        allocatedValue = allocatedValue.add(value);
        emit DividendDeposited(msg.sender, blockNumber, msg.value, currentSupply, dividendIndex);
    }

    function provisionDividend(uint256 _dividendIndex) public view returns (uint provisionAmount){
        if (_dividendIndex >= dividends.length ) {
            return 0;
        }
        Dividend storage dividend = dividends[_dividendIndex];
        if (dividend.claimed[msg.sender] || dividend.recycled) {
            return 0;
        }
        uint256 balance = dividendToken.balanceOfAt(msg.sender, dividend.blockNumber);
        provisionAmount = balance.mul(dividend.amount).div(dividend.totalSupply);
    }

    function provisionDividendAll() public view returns (uint provisionAmount) {
        if (dividendsClaimed[msg.sender] == dividends.length) {
            return 0;
        }
        for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
            if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {
                provisionAmount = provisionAmount.add(provisionDividend(i));
            }
        }
    }

    function _claimDividend(uint256 _dividendIndex) internal returns (uint claim){
        Dividend storage dividend = dividends[_dividendIndex];
        require(dividend.claimed[msg.sender] == false);
        require(dividend.recycled == false);
        uint256 balance = dividendToken.balanceOfAt(msg.sender, dividend.blockNumber);
        claim = balance.mul(dividend.amount).div(dividend.totalSupply);
        dividend.claimed[msg.sender] = true;
        dividend.claimedAmount = dividend.claimedAmount.add(claim);
    }

    function claimDividend(uint256 _dividendIndex) validDividendIndex(_dividendIndex) public {
        uint claim = _claimDividend(_dividendIndex);

        if (claim > 0) {
            allocatedValue = allocatedValue.sub(claim);
            msg.sender.transfer(claim);
            emit DividendClaimed(msg.sender, _dividendIndex, claim);
        }
        if (dividendsClaimed[msg.sender] == _dividendIndex) {
            dividendsClaimed[msg.sender] = _dividendIndex + 1;
        }
    }

    function claimDividendAll() public {
        require(dividendsClaimed[msg.sender] < dividends.length);
        uint claimSum;
        uint claim;
        for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
            if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {
                claim = _claimDividend(i);
                dividendsClaimed[msg.sender] = i + 1;
                if (claim > 0) {
                    claimSum = claimSum.add(claim);
                    emit DividendClaimed(msg.sender, i, claim);
                }
            }
        }
        if (claimSum > 0) {
            allocatedValue = allocatedValue.sub(claimSum);
            msg.sender.transfer(claimSum);
        }
    }

    function recycleDividend(uint256 _dividendIndex) onlyOwner validDividendIndex(_dividendIndex) public {
        Dividend storage dividend = dividends[_dividendIndex];
        require(dividend.recycled == false);
        require(dividend.timestamp < now.sub(RECYCLE_TIME));
        dividends[_dividendIndex].recycled = true;
        uint256 currentSupply = dividendToken.totalSupplyAt(block.number);
        uint256 remainingAmount = dividend.amount.sub(dividend.claimedAmount);
        uint256 dividendIndex = dividends.length;
        uint256 blockNumber = block.number - 1;
        dividends.push(
            Dividend(
                blockNumber,
                now,
                remainingAmount,
                0,
                currentSupply,
                false
            )
        );
        emit DividendRecycled(msg.sender, blockNumber, remainingAmount, currentSupply, dividendIndex);
    }
}
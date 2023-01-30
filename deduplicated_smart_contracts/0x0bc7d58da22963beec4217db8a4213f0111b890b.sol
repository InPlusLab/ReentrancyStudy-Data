/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity 0.6.10;

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
        assert(c >= a/*, "SafeMath: addition overflow"*/);

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
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b <= a/*, errorMessage*/);
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
        assert(c / a == b/*, "SafeMath: multiplication overflow"*/);

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
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b > 0/*, errorMessage*/);
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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        assert(b != 0/*, errorMessage*/);
        return a % b;
    }
}



abstract contract Staking {
    struct update {             // Price updateState
        uint timestamp;         // Last update timestamp, unix time
        uint numerator;         // Numerator of percent change (1% increase = 1/100)
        uint denominator;       // Denominator of percent change
        uint price;         // In USD. 0001 is $0.001, 1000 is $1.000, 1001 is $1.001, etc
        uint volume;        // In whole USD (100 = $100)
    }
    update public _lastUpdate; 
    function streak() public virtual view returns (uint);
}

contract Calculator {
    using SafeMath for uint256;
    
    struct update {             // Price updateState
        uint timestamp;         // Last update timestamp, unix time
        uint numerator;         // Numerator of percent change (1% increase = 1/100)
        uint denominator;       // Denominator of percent change
        uint price;         // In USD. 0001 is $0.001, 1000 is $1.000, 1001 is $1.001, etc
        uint volume;        // In whole USD (100 = $100)
    }
    
    uint public _percent;
    
    uint public _inflationAdjustmentFactor;
    
    Staking public _stakingContract;
    
    uint public _maxStreak;
    
    address payable public _owner;
    
    constructor(address stakingContract) public {
        _stakingContract = Staking(stakingContract);
        _owner = msg.sender;
        _percent = 8;
        _inflationAdjustmentFactor = 350;
        _maxStreak = 7;
    }
    
    
    
    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          assert (h < z);
          uint mm = mulmod (x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }
    
    function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod (x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }
    
    function calculateNumTokens(uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) external view returns (uint256) {
        require(msg.sender == address(_stakingContract));
        uint256 inflationAdjustmentFactor = _inflationAdjustmentFactor;
        uint _streak = _stakingContract.streak();
        (uint _, uint numerator, uint denominator, uint price, uint volume) = _stakingContract._lastUpdate();
        
        if(_streak > _maxStreak) {
            _streak = _maxStreak;
        }
        
        if (_streak > 1) {
            inflationAdjustmentFactor /= _streak;       // If there is a streak, we decrease the inflationAdjustmentFactor
        }
        
        if (daysStaked > 60) {      // If you stake for more than 60 days, you have hit the upper limit of the multiplier
            daysStaked = 60;
        } else if (daysStaked == 0) {   // If the minimum days staked is zero, we change the number to 1 so we don't return zero below
            daysStaked = 1;
        }
        
        uint ratio = mulDiv(totalSupply, price, 1000E18).div(volume);     // Ratio of market cap to volume
        
        if (ratio > 50) {  // Too little volume. Decrease rewards. To be honest, this number was arbitrarily chosen.
            inflationAdjustmentFactor = inflationAdjustmentFactor.mul(10);
        } else if (ratio > 25) { // Still not enough. Streak doesn't count.
            inflationAdjustmentFactor = _inflationAdjustmentFactor;
        }
        
        uint numTokens = mulDiv(balance, numerator * daysStaked, denominator * inflationAdjustmentFactor);      // Function that calculates how many tokens are due. See muldiv below.
        uint tenPercent = mulDiv(balance, 1, 10);
        
        if (numTokens > tenPercent) {       // We don't allow a daily rewards of greater than ten percent of a holder's balance.
            numTokens = tenPercent;
        }
        
        return numTokens;
    }
    
    function randomness() public view returns (uint256) {
        return _percent;
    }
    
    function updatePercent(uint percent) external {
        require(msg.sender == _owner);
        _percent = percent;
    }
    
    function updateMaxStreak(uint maxStreak) external {
        require(msg.sender == _owner);
        _maxStreak = maxStreak;
    }
    
    function updateInflationAdjustmentFactor(uint inflationAdjustmentFactor) external {
        require(msg.sender == _owner);
        _inflationAdjustmentFactor = inflationAdjustmentFactor;
    }
    
    function selfDestruct() external {
        require(msg.sender == _owner);
        selfdestruct(_owner);
    }
}
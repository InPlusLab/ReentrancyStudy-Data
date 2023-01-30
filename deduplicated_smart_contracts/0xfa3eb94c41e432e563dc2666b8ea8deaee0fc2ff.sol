pragma solidity =0.6.6;

import "./libraries/SafeMath.sol";
import "./interfaces/IImx.sol";
import "./interfaces/IClaimable.sol";

abstract contract Distributor is IClaimable {
	using SafeMath for uint;

	address public immutable imx;
	address public immutable claimable;

	struct Recipient {
		uint shares;
		uint lastShareIndex;
		uint credit;
	}
	mapping(address => Recipient) public recipients;
	
	uint public totalShares;
	uint public shareIndex;
	
	event UpdateShareIndex(uint shareIndex);
	event UpdateCredit(address indexed account, uint lastShareIndex, uint credit);
	event Claim(address indexed account, uint amount);
	event EditRecipient(address indexed account, uint shares, uint totalShares);

	constructor (
		address imx_,
		address claimable_
	) public {
		imx = imx_;
		claimable = claimable_;
	}
	
	function updateShareIndex() public virtual nonReentrant returns (uint _shareIndex) {
		if (totalShares == 0) return shareIndex;
		uint amount = IClaimable(claimable).claim();
		if (amount == 0) return shareIndex;
		_shareIndex = amount.mul(2**160).div(totalShares).add(shareIndex);
		shareIndex = _shareIndex;
		emit UpdateShareIndex(_shareIndex);
	}
	
	function updateCredit(address account) public returns (uint credit) {
		uint _shareIndex = updateShareIndex();
		if (_shareIndex == 0) return 0;
		Recipient storage recipient = recipients[account];
		credit = recipient.credit + _shareIndex.sub(recipient.lastShareIndex).mul(recipient.shares) / 2**160;
		recipient.lastShareIndex = _shareIndex;
		recipient.credit = credit;
		emit UpdateCredit(account, _shareIndex, credit);
	}

	function claimInternal(address account) internal virtual returns (uint amount) {
		amount = updateCredit(account);
		if (amount > 0) {
			recipients[account].credit = 0;
			IImx(imx).transfer(account, amount);
			emit Claim(account, amount);
		}
	}

	function claim() external virtual override returns (uint amount) {
		return claimInternal(msg.sender);
	}
	
	function editRecipientInternal(address account, uint shares) internal {
		updateCredit(account);
		Recipient storage recipient = recipients[account];
		uint prevShares = recipient.shares;
		uint _totalShares = shares > prevShares ? 
			totalShares.add(shares - prevShares) : 
			totalShares.sub(prevShares - shares);
		totalShares = _totalShares;
		recipient.shares = shares;
		emit EditRecipient(account, shares, _totalShares);
	}
	
	// Prevents a contract from calling itself, directly or indirectly.
	bool internal _notEntered = true;
	modifier nonReentrant() {
		require(_notEntered, "Distributor: REENTERED");
		_notEntered = false;
		_;
		_notEntered = true;
	}
}

pragma solidity =0.6.6;

import "./Distributor.sol";
import "./interfaces/IBorrowTracker.sol";
import "./interfaces/IVester.sol";
import "./libraries/Math.sol";

// ASSUMTPIONS:
// - advance is called at least once for each epoch
// - farmingPool shares edits are effective starting from the next epoch

contract FarmingPool is IBorrowTracker, Distributor {

	address public immutable borrowable;

	uint public immutable vestingBegin;
	uint public immutable segmentLength;
	
	uint public epochBegin;
	uint public epochAmount;
	uint public lastUpdate;
	
	event UpdateShareIndex(uint shareIndex);
	event Advance(uint epochBegin, uint epochAmount);
	
	constructor (
		address imx_,
		address claimable_,
		address borrowable_,
		address vester_
	) public Distributor(imx_, claimable_) {
		borrowable = borrowable_;
		uint _vestingBegin = IVester(vester_).vestingBegin();
		vestingBegin = _vestingBegin;
		segmentLength = IVester(vester_).vestingEnd().sub(_vestingBegin).div(IVester(vester_).segments());
	}
	
	function updateShareIndex() public virtual override returns (uint _shareIndex) {
		if (totalShares == 0) return shareIndex;
		if (epochBegin == 0) return shareIndex;
		uint epochEnd = epochBegin + segmentLength;
		uint blockTimestamp = getBlockTimestamp();
		uint timestamp = Math.min(blockTimestamp, epochEnd);
		uint timeElapsed = timestamp - lastUpdate;
		assert(timeElapsed <= segmentLength);
		if (timeElapsed == 0) return shareIndex;
		
		uint amount =  epochAmount.mul(timeElapsed).div(segmentLength);
		_shareIndex = amount.mul(2**160).div(totalShares).add(shareIndex);
		shareIndex = _shareIndex;
		lastUpdate = timestamp;
		emit UpdateShareIndex(_shareIndex);
	}
	
	function advance() public nonReentrant {
		uint blockTimestamp = getBlockTimestamp();
		if (blockTimestamp < vestingBegin) return;
		uint _epochBegin = epochBegin;
		if (_epochBegin != 0 && blockTimestamp < _epochBegin + segmentLength) return;
		uint amount = IClaimable(claimable).claim();
		if (amount == 0) return;
		updateShareIndex();		
		uint timeSinceBeginning = blockTimestamp - vestingBegin;
		epochBegin = blockTimestamp.sub(timeSinceBeginning.mod(segmentLength));
		epochAmount = amount;
		lastUpdate = epochBegin;
		emit Advance(epochBegin, epochAmount);
	}

	function claimInternal(address account) internal override returns (uint amount) {
		advance();
		return super.claimInternal(account);
	}
	
	function claimAccount(address account) external returns (uint amount) {
		return claimInternal(account);
	}
	
	function trackBorrow(address borrower, uint borrowBalance, uint borrowIndex) external override {
		require(msg.sender == borrowable, "FarmingPool: UNAUTHORIZED");
		uint newShares = borrowBalance.mul(2**96).div(borrowIndex);
		editRecipientInternal(borrower, newShares);
	}
	
	function getBlockTimestamp() public virtual view returns (uint) {
		return block.timestamp;
	}
}

pragma solidity >=0.5.0;

interface IBorrowTracker {
	function trackBorrow(address borrower, uint borrowBalance, uint borrowIndex) external;
}

pragma solidity =0.6.6;

interface IClaimable {
	function claim() external returns (uint amount);
	event Claim(address indexed account, uint amount);
}

pragma solidity =0.6.6;
//IERC20?
interface IImx {
    function balanceOf(address account) external view returns (uint);
    function transfer(address dst, uint rawAmount) external returns (bool);
}

pragma solidity >=0.5.0;

interface IVester {
	function segments() external pure returns (uint);
	function vestingAmount() external pure returns (uint);
	function vestingBegin() external pure returns (uint);
	function vestingEnd() external pure returns (uint);
}

pragma solidity =0.6.6;

// a library for performing various math operations
// forked from: https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/libraries/Math.sol

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity =0.6.6;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
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
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
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
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
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
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
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
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

{
  "remappings": [],
  "optimizer": {
    "enabled": true,
    "runs": 999999
  },
  "evmVersion": "istanbul",
  "libraries": {},
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
/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity ^0.5.13;

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

}

interface Callable {
	function tokenCallback(address _from, uint256 _tokens, bytes calldata _data) external returns (bool);
}

contract ANULNetwork {
    
    using SafeMath for uint256;
	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private INITIAL_SUPPLY = 21000000e18;
	uint256 constant private MIN_STAKE_AMOUNT = 1e21; // 1,000 Tokens Needed

	uint256 private XFER_FEE = 5; // 5% per tx
	uint256 private POOL_FEE = 3; // 3% to pool
	uint256 private DESTRUCTION = 2;  // 2% to Destruction
	uint256 private SHARE_DIVIDENDS = 6;  // 25% every collect
	uint256 private BASE_PROFIT = 5; // 1% Base Prifit

// 	uint256 constant private MAX_UNSTAKE_LIMIT = 2592000;
	uint256 private MAX_UNSTAKE_LIMIT = 3600;

	string constant public name = "Annular Network";
	string constant public symbol = "ANUL";
	uint8 constant public decimals = 18;

	struct User {
		
		uint256 balance;
		uint256 staked;
		mapping(address => uint256) allowance;
		uint collectTime;
		uint stakeTime;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalSupply;
		uint256 totalStaked;
		uint256 totalStake;
		mapping(address => User) users;
		uint256 scaledPayoutPerToken;
		address admin;
	}
	
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
	event Stake(address indexed owner, uint256 tokens);
	event Unstake(address indexed owner, uint256 tokens);
	event Collect(address indexed owner, uint256 tokens);
	event Tax(uint256 tokens);


	constructor() public {
		info.admin = msg.sender;
		info.totalSupply = INITIAL_SUPPLY;
		info.users[msg.sender].balance = INITIAL_SUPPLY;
		emit Transfer(address(0x0), msg.sender, INITIAL_SUPPLY);
	}
	
	function SetXferFee(uint256 newXferFee) public {
        require(msg.sender == info.admin);
        require(newXferFee <= 10);
        XFER_FEE = newXferFee;
    }
    
    function SetPoolFee(uint256 newPoolFee) public {
        require(msg.sender == info.admin);
        require(XFER_FEE >= newPoolFee);
        POOL_FEE = newPoolFee;
    }
    
    function SetDestruction(uint256 newDestruction) public {
        require(msg.sender == info.admin);
        require(XFER_FEE >= newDestruction);
        DESTRUCTION = newDestruction;
    }
    
    
    function SetShareDividends(uint256 newShareDividends) public {
        require(msg.sender == info.admin);
        require(newShareDividends < 100);
        SHARE_DIVIDENDS = newShareDividends;
    }
    
    function SetBaseProfit(uint256 newBaseProfit) public {
        require(msg.sender == info.admin);
        require(newBaseProfit < 10);
        BASE_PROFIT = newBaseProfit;
    }
    
     function SetMaxUnStakeLimit(uint256 newMaxUnStakeLimit) public {
        require(msg.sender == info.admin);
        require(newMaxUnStakeLimit < 8640000);
        MAX_UNSTAKE_LIMIT = newMaxUnStakeLimit;
    }
    

	function stake(uint256 _tokens) external {
		_stake(_tokens);
	}

	function unstake(uint256 _tokens) external {
		_unstake(_tokens);
	}

	function collect() external returns (uint256) {
		uint256 _dividends = dividendsOf(msg.sender);
		require(_dividends > 0);
		require(info.users[msg.sender].collectTime < now);
		uint256 profit = _dividends.mul(SHARE_DIVIDENDS).div(100);
		uint256 base = info.users[msg.sender].staked.mul(BASE_PROFIT).div(100);
		info.users[msg.sender].scaledPayout += int256(_dividends.mul(FLOAT_SCALAR).mul(SHARE_DIVIDENDS).div(100));
		info.users[msg.sender].balance += profit + base;
// 		info.users[msg.sender].collectTime = now + 86400;
		info.users[msg.sender].collectTime = now + 600;

		info.totalSupply += base;
		
		emit Transfer(address(this), msg.sender, profit + base);
		emit Collect(msg.sender, _dividends);
		return _dividends;
	}
	function reinvest() external returns (uint256) {
	    uint256 _dividends = dividendsOf(msg.sender);
		require(_dividends > 0);
		require(info.users[msg.sender].collectTime < now);
		uint256 profit = _dividends.mul(SHARE_DIVIDENDS).div(100);
		uint256 base = info.users[msg.sender].staked.mul(BASE_PROFIT).div(100);
		uint256 _amount = profit + base;
		
		require(balanceOf(msg.sender) >= _amount);
		require(stakedOf(msg.sender) + _amount >= MIN_STAKE_AMOUNT);
		
		info.users[msg.sender].scaledPayout += int256(_dividends.mul(FLOAT_SCALAR).mul(SHARE_DIVIDENDS).div(100));
// 		info.users[msg.sender].collectTime = now + 86400;
		info.users[msg.sender].collectTime = now + 600;

		info.totalSupply += base;
		info.totalStaked += _amount;
		info.users[msg.sender].staked += _amount;
		info.users[msg.sender].scaledPayout += int256(_amount.mul(info.scaledPayoutPerToken));
		
		return _dividends;
    }
	function distribute(uint256 _tokens) external {
		require(info.totalStaked > 0);
		require(balanceOf(msg.sender) >= _tokens);
		info.users[msg.sender].balance -= _tokens;
		info.scaledPayoutPerToken += _tokens.mul(FLOAT_SCALAR).div(info.totalStaked);
		emit Transfer(msg.sender, address(this), _tokens);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		uint256 _transferred = _transfer(msg.sender, _to, _tokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _transferred, _data));
		}
		return true;
	}

	function bulkTransfer(address[] calldata _receivers, uint256[] calldata _amounts) external {
		require(_receivers.length == _amounts.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amounts[i]);
		}
	}


	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

	function totalStaked() public view returns (uint256) {
		return info.totalStaked;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance - stakedOf(_user);
	}

	function stakedOf(address _user) public view returns (uint256) {
		return info.users[_user].staked;
	}
	
	function unstakeTimeOf(address _user) public view returns (uint256) {
	    return uint256(int256(info.users[_user].stakeTime + (info.totalSupply - info.totalStaked) * MAX_UNSTAKE_LIMIT / info.totalSupply ));
	}
	
	function collectTimeOf(address _user) public view returns (uint256) {
		return info.users[_user].collectTime;
	}
	
	function stakeTimeOf(address _user) public view returns (uint256) {
		return info.users[_user].stakeTime;
	}

	function dividendsOf(address _user) public view returns (uint256) {
		return uint256(int256(info.scaledPayoutPerToken * info.users[_user].staked) - info.users[_user].scaledPayout) / FLOAT_SCALAR;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function allDataFor(address _user) public view returns (uint256 totalTokenSupply, uint256 totalTokensStaked, uint256 userBalance, uint256 userStaked, uint256 userDividends, uint256 userCollectTime, uint256 userUnstakeTime) {
		return (totalSupply(), totalStaked(), balanceOf(_user), stakedOf(_user), dividendsOf(_user), collectTimeOf(_user), unstakeTimeOf(_user));
	}


	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {
		require(balanceOf(_from) >= _tokens);
		info.users[_from].balance -= _tokens;
		
		uint256 _taxAmount = _tokens.mul(XFER_FEE).div(100);
		uint256 _poolAmount = _tokens.mul(POOL_FEE).div(100);
		uint256 _destructionAmount = _tokens.mul(DESTRUCTION).div(100);
		
		uint256 _transferred = _tokens - _taxAmount;
		
        if (info.totalStaked > 0) {
            info.users[_to].balance += _transferred;
            info.totalSupply = info.totalSupply.sub(_destructionAmount);
            emit Transfer(_from, _to, _transferred);
            info.scaledPayoutPerToken += _poolAmount.mul(FLOAT_SCALAR).div(info.totalStaked);
            emit Transfer(_from, address(this), _poolAmount);
            emit Transfer(_from, address(0), _destructionAmount);
            emit Tax(_taxAmount);
            return _transferred;
        } else {
            info.users[_to].balance += _tokens;
            emit Transfer(_from, _to, _tokens);
            return _tokens;
        }
    }

	function _stake(uint256 _amount) internal {
		require(balanceOf(msg.sender) >= _amount);
		require(stakedOf(msg.sender) + _amount >= MIN_STAKE_AMOUNT);
		info.users[msg.sender].stakeTime = now;
		info.totalStaked += _amount;
		info.users[msg.sender].staked += _amount;
		info.users[msg.sender].scaledPayout += int256(_amount.mul(info.scaledPayoutPerToken));
		emit Transfer(msg.sender, address(this), _amount);
		emit Stake(msg.sender, _amount);
	}

	function _unstake(uint256 _amount) internal {
	    require(now > info.users[msg.sender].stakeTime.add(info.totalSupply.sub(info.totalStaked).mul(MAX_UNSTAKE_LIMIT).div(info.totalSupply)));
		require(stakedOf(msg.sender) >= _amount);
		uint256 _taxAmount = _amount.mul(XFER_FEE).div(100);
		info.scaledPayoutPerToken += _taxAmount.mul(FLOAT_SCALAR).div(info.totalStaked);
		info.totalStaked -= _amount;
		info.users[msg.sender].balance -= _taxAmount;
		info.users[msg.sender].staked -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount.mul(info.scaledPayoutPerToken));
		emit Transfer(address(this), msg.sender, _amount.sub(_taxAmount));
		emit Unstake(msg.sender, _amount);
	}
}
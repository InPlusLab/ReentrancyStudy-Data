/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

pragma solidity >=0.4.22 <0.7.0;
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
 * Forked from AmplGeyser*/
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

contract DGOVMINING  {
    using SafeMath for uint256;
    IERC20 public DistributionToken; //0x3087d935aa27128be399851bf8dbf6a40a9964fb
    event TokensClaimed(address indexed user, uint256 amount);
    event CheckIn(address indexed user); 
    //
    // Global accounting state
    //
    uint256 public globalShares = 0;
    uint256 private globalSeconds = 0;
    uint256 private _lastGlobalTimestampSec = now;
	uint256 private _iniTimestampSec = now;
    uint256 private _totalclaimed =0;
	uint256 private _baseShare = 1;
	uint256 private _lockingPeriod = 600;
    uint256 private _iniSharesPerToken = 1 * (10**17);
	uint256 private _totalUnlockedToken = 15000000 * (10**18);
   
    // If lastTimestampSec is 0, there's no entry for that user.
    struct UserRecords {
        uint256 stakingShares;
        uint256 stakingShareSeconds;
        uint256 lastTimestampSec;
    }
     
    // Aggregated staking values per user
    mapping(address => UserRecords) private _userRecords;
    
    /**
     * @param distributionToken The token users receive as they unstake.
     */
    constructor(IERC20 distributionToken) public {       
            DistributionToken = distributionToken;
    }

	function initialTimestampSec() public view returns (uint256) {
       
		return _iniTimestampSec;
    }
	function userTimestampSec() public view returns (uint256) {
       
		return _userRecords[msg.sender].lastTimestampSec;
    }
	function userShares() public view returns (uint256) {
       
		return _userRecords[msg.sender].stakingShares;
    }
	function userShareSeconds() public view returns (uint256) {
       
		return _userRecords[msg.sender].stakingShareSeconds;
    }
	function globalShareSeconds() public view returns (uint256) {
       
		return globalSeconds;
    }
    function totalDistributionToken() public view returns (uint256) {
       
		return DistributionToken.balanceOf(address(this));
    }
    function totalClaimedTokens() public view returns (uint256) {
       
		return _totalclaimed;
    }
    /**
      *@dev Start the mining process  
     */
    function Mining() external {
          // User Accounting
        UserRecords storage totals = _userRecords[msg.sender];
		uint256 waitingPeriod = now.sub(totals.lastTimestampSec);
		require(waitingPeriod > _lockingPeriod,"Doro.Network: must be 10-minute average interval");		       
         //User Accounting
		uint256 newUserSeconds =
		    now
            .sub(totals.lastTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds =totals.stakingShareSeconds.add(newUserSeconds);       
		totals.stakingShares = totals.stakingShares.add(_baseShare);
        totals.lastTimestampSec = now;
        // 2. Global Accounting
		uint256 newStakingShareSeconds =
            now
            .sub(_lastGlobalTimestampSec)
            .mul(globalShares);
        globalSeconds = globalSeconds.add(newStakingShareSeconds);
        _lastGlobalTimestampSec = now;
        globalShares = globalShares.add(_baseShare);
		emit CheckIn(msg.sender);
    }
    /*User Claim Token */
	function claimTokens () external {	    
	   require(_totalclaimed <= _totalUnlockedToken,"Doro.Network:15 Millions Tokens have been mined");
	   // User Accounting
	   UserRecords storage totals = _userRecords[msg.sender];
	   require(totals.stakingShares >0,"Doro.Network: User has no mining power.");
	   uint256 claimInterval = now.sub(totals.lastTimestampSec);
	   require(claimInterval > _lockingPeriod, "Doro.Network:must be 10-minute average interval");		      
	    // Global accounting
		uint256 UnlockedTokens =now.sub(_iniTimestampSec).mul(_iniSharesPerToken);	
		UnlockedTokens =(_totalclaimed>0)? UnlockedTokens.sub(_totalclaimed):UnlockedTokens;
        uint256 newGlobalSeconds =
            now
            .sub(_lastGlobalTimestampSec)
            .mul(globalShares);
        globalSeconds = globalSeconds.add(newGlobalSeconds);
        _lastGlobalTimestampSec = now;
         // User Accounting       
        uint256 newUserSeconds =
            now
            .sub(totals.lastTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds =
            totals.stakingShareSeconds
            .add(newUserSeconds);  
        uint256 totalUserRewards = (globalSeconds > 0)
            ? UnlockedTokens.mul(totals.stakingShareSeconds).div(globalSeconds)
            : 0;
		globalSeconds = globalSeconds.sub(totals.stakingShareSeconds);
		globalShares = globalShares.sub(totals.stakingShares);
        _totalclaimed =  _totalclaimed.add(totalUserRewards);
		totals.stakingShareSeconds =0;
		totals.stakingShares = 0;
        totals.lastTimestampSec = now;	  	   	  
	    require(DistributionToken.transfer(msg.sender, totalUserRewards),
            'Doro.Network: transfer out of distribution token failed');
	    emit TokensClaimed(msg.sender, totalUserRewards);
	}	
}
pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title TokenTimelock
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 * use this contract need :
 * 1.release ERC20 contract;
 * 2.configure and release TokenTimelock contract
 * 3.transfer ERC20 Tokens which need to be timelocked to TokenTimelock contract
 * 4.when time reached, call release() to release tokens to beneficiary
 * 
 * for example:
 * (D=Duration   R=ReleaseRatio)
 *      ^
 *      |
 *      |
 *  R4  |                ！！！！
 *  R3  |            ！！！！
 *  R2  |        ！！！！
 *  R1  |    ！！！！ 
 *      |         
 *      |！！！！！！！！！！！！！！！！！！！！！！！！！！>
 *            D1  D2   D3  D4
 * 
 * start = 2019-1-1 00:00:00
 * D1=D2=D3=D4=1year
 * R1=10,R2=20,R3=30,R4=40  (please ensure R1+R2+R3+R4=100)
 * so, you will get below tokens in total
 *        Time                                     Tokens Get
 *   Start~Start+D1                                   0
 * Start+D1~Start+D1+D2                      10% total in this Timelock contract
 * Start+D1+D2~Start+D1+D2+D3              10%+20% total
 * Start+D1+D2+D3~Start+D1+D2+D3+D4        10%+20%+30% total
 * Start+D1+D2+D3+D4~infinity              10%+20%+30%+40% total(usually ensures 100 percent)
 */
contract TokenTimelock is Ownable {
    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is
    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,
    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a
    // cliff period of a year and a duration of four years, are safe to use.
    // solhint-disable not-rely-on-time

    using SafeMath for uint256;

    event TokensReleased(address token, uint256 amount);
    event TokenTimelockRevoked(address token);

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    
    uint256 private _start;
    uint256 private _totalDuration;
    
    //Durations and token release ratios expressed in UNIX time
    struct DurationsAndRatios{
        uint256 _periodDuration;
        uint256 _periodReleaseRatio;
    }
    DurationsAndRatios[4] _durationRatio;//four period of duration and ratios
    
    bool private _revocable;

    mapping (address => uint256) private _released;
    mapping (address => bool) private _revoked;

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary, gradually in a linear fashion until start + duration. By then all
     * of the balance will have vested.
     * @param beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param start the time (as Unix time) at which point vesting starts
     * @param firstDuration: first period duration
     * @param firstRatio: first period release ratio
     * @param secondDuration: second period duration
     * @param secondRatio: second period release ratio
     * @param thirdDuration: third period duration
     * @param thirdRatio: third period release ratio
     * @param fourthDuration: fourth period duration
     * @param fourthRatio: fourth period release ratio
     * @param revocable whether the vesting is revocable or not
     */
    constructor (address beneficiary, uint256 start, uint256 firstDuration,uint256 firstRatio,uint256 secondDuration, uint256 secondRatio,
    uint256 thirdDuration,uint256 thirdRatio,uint256 fourthDuration, uint256 fourthRatio,bool revocable) public {
        require(beneficiary != address(0), "TokenTimelock: beneficiary is the zero address");
        
        require(firstRatio.add(secondRatio).add(thirdRatio).add(fourthRatio)==100, "TokenTimelock: ratios added not equal 100.");
    
        _beneficiary = beneficiary;
        _revocable = revocable;
        _start = start;
        
        _durationRatio[0]._periodDuration = firstDuration;
        _durationRatio[1]._periodDuration = secondDuration;
        _durationRatio[2]._periodDuration = thirdDuration;
        _durationRatio[3]._periodDuration = fourthDuration;
        
        _durationRatio[0]._periodReleaseRatio = firstRatio;
        _durationRatio[1]._periodReleaseRatio = secondRatio;
        _durationRatio[2]._periodReleaseRatio = thirdRatio;
        _durationRatio[3]._periodReleaseRatio = fourthRatio;
        
        _totalDuration = firstDuration.add(secondDuration).add(thirdDuration).add(fourthDuration);
        require(_start.add(_totalDuration) > block.timestamp, "TokenTimelock: final time is before current time");
        
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the end time of every period.
     */
    function getDurationsAndRatios() public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        return (_durationRatio[0]._periodDuration,_durationRatio[1]._periodDuration,_durationRatio[2]._periodDuration,_durationRatio[3]._periodDuration,
        _durationRatio[0]._periodReleaseRatio,_durationRatio[1]._periodReleaseRatio,_durationRatio[2]._periodReleaseRatio,_durationRatio[3]._periodReleaseRatio);
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _start;
    }
    
    /**
     * @return current time of the contract.
     */
    function currentTime() public view returns (uint256) {
        return block.timestamp;
    }
    
    /**
     * @return the total duration of the token vesting.
     */
    function totalDuration() public view returns (uint256) {
        return _totalDuration;
    }
    
    /**
     * @return true if the vesting is revocable.
     */
    function revocable() public view returns (bool) {
        return _revocable;
    }
    
    /**
     * @return the amount of the token released.
     */
    function released(address token) public view returns (uint256) {
        return _released[token];
    }
    
    /**
     * @return true if the token is revoked.
     */
    function revoked(address token) public view returns (bool) {
        return _revoked[token];
    }
    
    /**
     * @notice Transfers vested tokens to beneficiary.
     * @param token ERC20 token which is being vested
     */
    function release(IERC20 token) public {
        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenTimelock: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.transfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param token ERC20 token which is being vested
     */
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenTimelock: cannot revoke");
        require(!_revoked[address(token)], "TokenTimelock: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.transfer(owner(), refund);

        emit TokenTimelockRevoked(address(token));
    }
    
    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     * @param token ERC20 token which is being vested
     */
    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }
    
    /**
     * @dev Calculates the amount that should be vested totally.
     * @param token ERC20 token which is being vested
     */
    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));//token balance in TokenTimelock contract
        uint256 totalBalance = currentBalance.add(_released[address(token)]);//total balance in TokenTimelock contract
        
        uint256[4] memory periodEndTimestamp;
        periodEndTimestamp[0] = _start.add(_durationRatio[0]._periodDuration);
        periodEndTimestamp[1] = periodEndTimestamp[0].add(_durationRatio[1]._periodDuration);
        periodEndTimestamp[2] = periodEndTimestamp[1].add(_durationRatio[2]._periodDuration);
        periodEndTimestamp[3] = periodEndTimestamp[2].add(_durationRatio[3]._periodDuration);
        uint256 releaseRatio;
        if (block.timestamp < periodEndTimestamp[0]) {
            return 0;
        }else if(block.timestamp >= periodEndTimestamp[0] && block.timestamp < periodEndTimestamp[1]){
            releaseRatio = _durationRatio[0]._periodReleaseRatio;
        }else if(block.timestamp >= periodEndTimestamp[1] && block.timestamp < periodEndTimestamp[2]){
            releaseRatio = _durationRatio[0]._periodReleaseRatio.add(_durationRatio[1]._periodReleaseRatio);
        }else if(block.timestamp >= periodEndTimestamp[2] && block.timestamp < periodEndTimestamp[3]) {
            releaseRatio = _durationRatio[0]._periodReleaseRatio.add(_durationRatio[1]._periodReleaseRatio).add(_durationRatio[2]._periodReleaseRatio);
        } else {
            releaseRatio = 100;
        }
        return releaseRatio.mul(totalBalance).div(100);
    }
    
}
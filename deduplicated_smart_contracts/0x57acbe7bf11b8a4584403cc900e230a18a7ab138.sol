/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.5.0;

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


/**
 * @dev APIX 토큰을 1년 동안 잠그는 기능을 수행한다.
 * 매 분기마다(1년에 4번 - 3, 6, 9, 12개월 차) 잠긴 토큰의 1/4 만큼 씩 잠금 해제한다.
 * 
 * 컨트렉트 사용 절차 : 
 * 1. 컨트렉트를 생성한다.
 * 2. 생성된 컨트렉트 주소에 APIX 토큰을 전송한다.
 * 3. initLockedBalance() 메서드를 호출한다.
 * 4. getNextRound() 및 getNextRoundTime() 값을 확인하여 다음 잠금해제 정보를 확인한다.
 * 5. 해제 가능 시점에 도달하면 unlock() 메서드를 실행한다.
 */

 /**
 * @dev This contract locks specific amount of APIX tokens for 1 year.
 * In every quarter of the year(4 times in 1 year - 3rd, 6th, 9th, 12th months), contract unlocks 1/4 of annually locked tokens.
 * 
 * Contract use sequence : 
 * 1. Deploy contract.
 * 2. Transfer APIX tokens to the generated contract address.
 * 3. Call initLockedBalance() method.
 * 4. Check getNextRound() and getNextRoundTime() value to find out next unlock information.
 * 5. Call unlock() method when unlockable time has come.
 */

contract Locker {
    IERC20  APIX;
    address receiver;
    uint32 unlockStartYear;
    uint256 unlockStartTime;
    uint256 unlockOffsetTime = 7884000; /* (365*24*60*60)/4 */
    uint256 totalLockedBalance = 0;
    uint256 unlockBalancePerRound = 0;
    uint8 lastRound = 0;
    
    /**
     * @dev APIX 토큰이 락업될 때 emit됩니다.
     *
     * 유의사항 : `value`는 0일 수도 있습니다.
     */

    /**
     * @dev Emits when APIX token is locked.
     *
     * Note that `value` may be zero.
     */
    event APIXLock(uint256 value);
    
    /**
     * @dev APIX 토큰이 락업 해제되고 (`receiver`)에게 전송될 때 emit됩니다.
     *
     * 유의사항 : `value`는 0일 수도 있습니다.
     */

    /**
     * @dev Emitted when APIX token is unlocked and transfer tokens to (`receiver`)
     *
     * Note that `value` may be zero.
     */
    event APIXUnlock(uint256 value, address receiver);
    
    /**
     * @dev 컨트렉트를 생성한다.
     * 
     * @param _APIX 토큰 컨트렉트 주소
     * @param _receiver 잠금 해제된 토큰을 수령할 주소
     * @param _unlockStartTime 잠금 해제가 시작되는 년도의 1월 1일 0시 0분 0초 시간(GMT, Unix Timestamp)
     * @param _unlockStartYear 잠금 해제가 시작되는 년도(정수)
     */

     /**
     * @dev Creates contract.
     * 
     * @param _APIXContractAddress Address of APIX token contract
     * @param _receiver Address which will receive unlocked tokens
     * @param _unlockStartTime Time of the Jan 1st, 00:00:00 of the year that unlocking will be started(GMT, Unix Timestamp)
     * @param _unlockStartYear Year that unlocking will be started
     */
    constructor (address _APIXContractAddress, address _receiver, uint256 _unlockStartTime, uint32 _unlockStartYear) public {
        APIX = IERC20(_APIXContractAddress);
        receiver = _receiver;
        unlockStartTime = _unlockStartTime;
        unlockStartYear = _unlockStartYear;
    }
    
    /**
     * @dev Lock 컨트렉트가 보유한 토큰의 수량을 반환한다.
     * @return 현재 컨트렉트에서 보유한 APIX 수량 (wei)
     */
    /**
     * @dev Returns APIX token balance of this Lock contract.
     * @return Current contract's APIX balance (wei)
     */
    function getContractBalance() external view returns (uint256) {
        return APIX.balanceOf(address(this));
    }
    
    /**
     * @dev 잠겨진 토큰의 전체 수량을 반환한다.
     * @return 컨트렉트 초기화 시 설정된 잠금 수량
     */
    /**
     * @dev Returns amount of total locked tokens.
     * @return Locked amount set at the contract initalization step
     */
    function totalLockedTokens() external view returns (uint256) {
        return totalLockedBalance;
    }
    
    /**
     * @dev 다음 잠금이 해제되는 회차를 확인한다.
     * @return 다음 라운드 번호
     */
    /**
     * @dev Check next unlock round.
     * @return Next round number
     */
    function getNextRound() external view returns (uint8) {
        return lastRound + 1;
    }
    
    /**
     * @dev 다음 잠금이 해제되는 시간을 확인한다.
     */
     /**
     * @dev Check next round's unlock time.
     */
    function getNextRoundTime() external view returns (uint256) {
        return _getNextRoundTime();
    }
    
    function _getNextRoundTime() internal view returns (uint256) {
        return unlockStartTime + unlockOffsetTime * (lastRound + 1);
    }
    /**
     * @dev 다음 라운드에서 해제되는 수량을 조회한다
     * @return 해제되는 토큰 수량
     */
    /**
     * @dev Check next round's APIX unlock amount
     * @return Unlock amount
     */
    function getNextRoundUnlock() external view returns (uint256) {
        return _getNextRoundUnlock();
    }
    function _getNextRoundUnlock() internal view returns (uint256) {
        uint8 round = lastRound + 1;
        uint256 unlockAmount;
        
        if(round < 4) {
            unlockAmount = unlockBalancePerRound;
        }
        else {
            unlockAmount = APIX.balanceOf(address(this));
        }
        
        return unlockAmount;
    }
    
    /**
     * @dev 현재 컨트렉트에 대한 정보를 반환한다.
     * @return  initLockedToken 컨트렉트에 잠겨진 수량
     *          balance 현재 컨트렉트가 보관하고 있는 토큰의 수량
     *          unlockYear 락 컨트렉트가 해제되는 년도
     *          nextRound 다음 회차 번호
     *          nextRoundUnlockAt 다음 회차 시작 시간 (Unix timestamp)
     *          nextRoundUnlockToken 다음 회차에 풀리는 토큰의 수량
     */
     /**
     * @dev Returns information of current contract.
     * @return  initLockedToken - Locked APIX token amount
     *          balance - APIX token balance of contract
     *          unlockYear - Contract unlock year
     *          nextRound - Next unlock round number
     *          nextRoundUnlockAt - Next unlock round start time (Unix timestamp)
     *          nextRoundUnlockToken - Unlocking APIX amount of next unlock round
     */
    function getLockInfo() external view returns (uint256 initLockedToken, uint256 balance, uint32 unlockYear, uint8 nextRound, uint256 nextRoundUnlockAt, uint256 nextRoundUnlockToken) {
        initLockedToken = totalLockedBalance;
        balance = APIX.balanceOf(address(this));
        nextRound = lastRound + 1;
        nextRoundUnlockAt = _getNextRoundTime();
        nextRoundUnlockToken = _getNextRoundUnlock();
        unlockYear = unlockStartYear;
    }
    
    
    /**
     * 컨트랙트에서 보관하고 있는 잠긴 수량을 설정한다.
     * 이 함수를 실행하기 전에 토큰을 먼저 보내야 한다.
     * 
     * !!** 잠긴 수량은 한 번 설정되면 다시 변경할 수 없음 **!!
     * 
     * @return 잠겨진 토큰의 수량
     */
    /**
     * Sets locked amount of current contract.
     * Must transfer APIX tokens to this contract.
     * 
     * !!** After locked amount is set, it cannot be updated again **!!
     * 
     * @return Locked token amount
     */
    function initLockedBalance() public returns (uint256) {
        require(totalLockedBalance == 0, "Locker: There is no token stored");
        
        totalLockedBalance = APIX.balanceOf(address(this));
        unlockBalancePerRound = totalLockedBalance / 4;
        
        emit APIXLock (totalLockedBalance);
        
        return totalLockedBalance;
    }
    
    
    /**
     * @dev 토큰 잠김을 해제하고 보유자에게 반환한다.
     * 
     * @param round 토큰 잠김 해제 회차
     * @return 성공했을 경우 TRUE, 아니면 FALSE
     */
    /**
     * @dev Unlocks APIX token and transfer it to the receiver.
     * 
     * @param round Round to unlock the token
     * @return TRUE if successed, FALSE in other situations.
     */
    function unlock(uint8 round) public returns (bool) {
        // 잠긴 토큰이 존재해야 한다.
        // Locked token must be exist.
        require(totalLockedBalance > 0, "Locker: There is no locked token");
        
        
        // 직전에 출금된 라운드보다 한 번 증가된 라운드여야 한다.
        // Round should be 1 round bigger than the latest unlocked round.
        require(round == lastRound + 1, "Locker: The round value is incorrect");
        
        
        // 4라운드까지만 실행 가능하다.
        // Can only be executed for the round 4.
        require(round <= 4, "Locker: The round value has exceeded the executable range");
        
        
        // 해당 라운드의 시간이 아직 되지 않았을 경우 실행하지 못하도록 한다.
        // Cannot execute when the round's unlock time has not yet reached.
        require(block.timestamp >= _getNextRoundTime(), "Locker: It's not time to unlock yet");
        
        
        // 출금 실행
        // Withdrawal
        uint256 amount = _getNextRoundUnlock();
        require(amount > 0, 'Locker: There is no unlockable token');
        require(APIX.transfer(receiver, amount));
        
        emit APIXUnlock(amount, receiver);
        
        // 실행된 회차를 기록한다.
        // Records executed round.
        lastRound = round;
        return true;
    }
}
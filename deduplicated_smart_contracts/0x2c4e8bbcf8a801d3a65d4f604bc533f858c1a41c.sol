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
contract Locker {
    IERC20  APIX;
    address receiver;
    uint16 unlockStartYear;
    uint256 unlockStartTime;
    uint256 unlockOffsetTime = 7884000; /* (365*24*60*60)/4 */
    uint256 totalLockedBalance = 0;
    uint256 unlockBalancePerRound = 0;
    uint8 lastRound = 0;
    
    /**
     * @dev Emitted when the locked 'value' tokens is set
     *
     * Note that `value` may be zero.
     */
    event Lock(uint256 value);
    
    /**
     * @dev Emitted when the unlocked and moved 'value' tokens to (`receiver`)
     *
     * Note that `value` may be zero.
     */
    event Unlock(uint256 value, address receiver);
    
    /**
     * @dev 컨트렉트를 생성한다.
     * 
     * @param _APIX 토큰 컨트렉트 주소
     * @param _receiver 잠금 해제된 토큰을 수령할 주소
     * @param _unlockStartTime 잠금 해제가 시작되는 년도의 1월 1일 0시 0분 0초 시간(Unix Timestamp)
     */
    constructor (address _APIX, address _receiver, uint256 _unlockStartTime, uint16 _unlockStartYear) public {
        APIX = IERC20(_APIX);
        receiver = _receiver;
        unlockStartTime = _unlockStartTime;
        unlockStartYear = _unlockStartYear;
    }
    
    /**
     * @dev 잠금 컨트렉트의 잔고를 확인한다.
     */
    function getLockedBalance() external view returns (uint256) {
        return APIX.balanceOf(address(this));
    }
    
    /**
     * @dev 컨트렉트에 잠겨진 토큰의 수량을 확인한다.
     */
    function getTotalLockedBalance() external view returns (uint256) {
        return totalLockedBalance;
    }
    
    /**
     * @dev 다음 잠금이 해제되는 회차를 확인한다.
     */
    function getNextRound() external view returns (uint8) {
        return lastRound + 1;
    }
    
    /**
     * @dev 다음 잠금이 해제되는 시간을 확인한다.
     */
    function _getNextRoundTime() internal view returns (uint256) {
        return unlockStartTime + unlockOffsetTime * (lastRound + 1);
    }
    function getNextRoundTime() external view returns (uint256) {
        return _getNextRoundTime();
    }
    
    /**
     * @dev 다음 라운드에서 해제되는 수량을 조회한다
     */
    function _getNextUnlockToken() internal view returns (uint256) {
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
    function getNextUnlockToken() external view returns (uint256) {
        return _getNextUnlockToken();
    }
    
    /**
     * @dev 현재 컨트렉트에 대한 정보를 반환한다.
     * @return  initLockedToken 컨트렉트에 잠겨진 수량
     *          balance 현재 컨트렉트가 보관하고 있는 토큰의 수량
     *          nextRound 다음 회차 번호
     *          nextRoundUnlockAt 다음 회차 시작 시간 (Unix timestamp)
     *          nextRoundUnlockToken 다음 회차에 풀리는 토큰의 수량
     */
    function getLockInfo() external view returns (uint256 initLockedToken, uint256 balance, uint16 unlockYear, uint8 nextRound, uint256 nextRoundUnlockAt, uint256 nextRoundUnlockToken) {
        initLockedToken = totalLockedBalance;
        balance = APIX.balanceOf(address(this));
        nextRound = lastRound + 1;
        nextRoundUnlockAt = _getNextRoundTime();
        nextRoundUnlockToken = _getNextUnlockToken();
        unlockYear = unlockStartYear;
    }
    
    
    /**
     * 락컨트렉트에서 보관하고 있는 잠긴 수량을 설정한다.
     * 이 함수를 실행하기 전에 토큰을 먼저 보내야 한다.
     * 
     * !! 잠긴 수량은 한 번 설정되면 다시 변경할 수 없다 !!
     */
    function initLockedBalance() public returns (uint256) {
        require(totalLockedBalance == 0, "Locker: There is no token stored");
        
        totalLockedBalance = APIX.balanceOf(address(this));
        unlockBalancePerRound = totalLockedBalance / 4;
        
        emit Lock (totalLockedBalance);
        
        return totalLockedBalance;
    }
    
    
    function unlock(uint8 round) public returns (bool) {
        // 잠긴 토큰이 존재해야 한다.
        require(totalLockedBalance > 0, "Locker: There is no locked token");
        
        
        // 직전에 출금된 라운드보다 한 번 증가된 라운드여야 한다.
        require(round == lastRound + 1, "Locker: The round value is incorrect");
        
        
        // 이 주석을 해제하면 4라운드까지만 실행할 수 있다.
        // 그대로 두면, 4회차 이상에서는 오입금 된 토큰이 있더라도 꺼낼 수 있다
        // require(round <= 4, "Locker: The round value has exceeded the executable range");
        
        
        // 해당 라운드의 시간이 아직 되지 않았을 경우 실행하지 못하도록 한다.
        require(block.timestamp >= _getNextRoundTime(), "Locker: It's not time to unlock yet");
        
        
        // 출금 실행
        uint256 amount = _getNextUnlockToken();
        require(amount > 0, 'Locker: There is no unlockable token');
        require(APIX.transfer(receiver, amount));
        
        emit Unlock(amount, receiver);
        
        // 실행된 회차를 기록한다.
        lastRound = round;
        return true;
    }
}
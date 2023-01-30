pragma solidity >= 0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";

contract CardioCoin is ERC20, Ownable {
    using SafeMath for uint256;

    uint public constant UNLOCK_PERIOD = 30 days;
    uint public constant UNLOCK_TIME = 1572566400;    // 11월 1일 0시

    string public constant name = "CardioCoin";
    string public constant symbol = "CRDC";

    uint8 public constant decimals = 18;

    uint256 internal totalSupply_ = 12000000000 * (10 ** uint256(decimals));

    struct balance {
        uint256 available;
        uint256 lockedUp;
    }

    struct lockUp {
        uint256 amount;
        uint unlockTimestamp;
        uint unlockCount;
    }

    struct locker {
        bool isLocker;
        string role;
        uint lockUpPeriod;
        uint unlockCount;
        bool useFixedTime;
    }

    mapping(address => balance) internal _balances;
    mapping(address => lockUp[]) internal _lockUps;
    mapping(address => locker) internal _lockerList;

    event Burn(address indexed burner, uint256 value);
    event AddToLocker(address indexed owner, string role, uint lockUpPeriod, uint unlockCount);
    event TokenLocked(address indexed owner, uint256 amount);
    event TokenUnlocked(address indexed owner, uint256 amount);

    constructor() public Ownable() {
        balance memory b;

        b.available = totalSupply_;
        _balances[msg.sender] = b;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    //Getter Functions
    function lockerInfo(address _operator)public view returns(bool isLocker, string memory role, uint lockUpPeriod, uint unlockCount) {
        locker memory l = _lockerList[_operator];
        isLocker = l.isLocker;
        role = l.role;
        lockUpPeriod = l.lockUpPeriod;
        unlockCount = l.unlockCount;
    }

    function balanceInfo(address user) view public returns(uint256 available, uint256 lockedUp) {
        balance memory b = _balances[user];
        available = b.available;
        lockedUp = b.lockedUp;
    }

    function lockUpInfo(address user, uint256 index) view public returns (uint256 amount, uint256 unlockTimestamp, uint256 unlockCount) {
        lockUp memory l = _lockUps[user][index];
        amount = l.amount;
        unlockTimestamp = l.unlockTimestamp;
        unlockCount = l.unlockCount;
    }

    function lockUpLength(address user) view public returns (uint256) {
        lockUp[] memory l = _lockUps[user];
        return l.length;
    }

    // ERC20 Custom
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function _transfer(address from, address to, uint256 value) internal {
        locker storage l = _lockerList[from];

        this.unlockAll(from);
        require(value <= _balances[from].available);
        require(to != address(0));
        _balances[from].available = _balances[from].available.sub(value);
        if (l.isLocker) {
            if (l.useFixedTime) {
                if (UNLOCK_TIME <= now) {
                    uint elapsedPeriod = (now - UNLOCK_TIME) / UNLOCK_PERIOD + 1;

                    if (elapsedPeriod < l.unlockCount) {
                        uint unlockedAmount = (value / l.unlockCount).mul(elapsedPeriod);

                        _balances[to].available = _balances[to].available.add(unlockedAmount);
                        addLockedUpTokens(to, value.sub(unlockedAmount), UNLOCK_TIME + UNLOCK_PERIOD * elapsedPeriod - now, l.unlockCount - elapsedPeriod);
                    } else {
                        l.isLocker = false;
                        _balances[to].available = _balances[to].available.add(value);
                    }
                } else {
                    addLockedUpTokens(to, value, UNLOCK_TIME - now, l.unlockCount);
                }
            } else {
                addLockedUpTokens(to, value, l.lockUpPeriod, l.unlockCount);
            }
        } else {
            _balances[to].available = _balances[to].available.add(value);
        }
        emit Transfer(from, to, value);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner].available.add(_balances[_owner].lockedUp);
    }

    // Burnable
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _balances[_who].available);

        _balances[_who].available = _balances[_who].available.sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    // Lockup
    function addAddressToLockerList(address _operator, string memory role, uint lockUpPeriod, uint unlockCount, bool useFixedTime)
    public
    onlyOwner {
        locker memory lockerData = _lockerList[_operator];

        require(!lockerData.isLocker);
        require(unlockCount > 0);
        lockerData.isLocker = true;
        lockerData.role = role;
        lockerData.lockUpPeriod = lockUpPeriod;
        lockerData.unlockCount = unlockCount;
        lockerData.useFixedTime = useFixedTime;
        _lockerList[_operator] = lockerData;
        emit AddToLocker(_operator, role, lockUpPeriod, unlockCount);
    }

    function lockedUpBalanceOf(address _owner) public view returns (uint256) {
        lockUp[] memory lockups = _lockUps[_owner];
        balance memory b = _balances[_owner];
        uint256 lockedUpBalance = b.lockedUp;

        for (uint i = 0; i < lockups.length; i++) {
            lockUp memory l = lockups[i];

            uint count = calculateUnlockCount(l.unlockTimestamp, l.unlockCount);
            uint256 unlockedAmount = l.amount.mul(count).div(l.unlockCount);
            lockedUpBalance = lockedUpBalance.sub(unlockedAmount);
        }

        return lockedUpBalance;
    }

    function addLockedUpTokens(address _owner, uint256 amount, uint lockUpPeriod, uint unlockCount)
    internal {
        lockUp[] storage lockups = _lockUps[_owner];
        lockups.length += 1;
        lockUp storage l = lockups[lockups.length - 1];
        l.amount = amount;
        l.unlockTimestamp = now.add(lockUpPeriod);
        l.unlockCount = unlockCount;

        balance storage b = _balances[_owner];
        b.lockedUp = b.lockedUp.add(amount);
        emit TokenLocked(_owner, amount);
    }

    function unlockAll(address _owner) external returns (bool success) {
        balance storage b = _balances[_owner];
        lockUp[] storage lockupList = _lockUps[_owner];
        uint256 unlocked = 0;
        for (uint i = 0; i < lockupList.length; i++){
            uint256 unlocked_i = _unlock(_owner,i);
            unlocked = unlocked.add(unlocked_i);
            //when fullyUnlocked
            if(lockupList[i].unlockCount == 0) {
                //remove
                lockUp storage temp = lockupList[lockupList.length.sub(1)];
                lockupList[i] = temp;
                lockupList.length--;
                i--;
            }
        }
        //add unlocked to available
        b.available = b.available.add(unlocked);
        //sub unlocked from lockedUp
        b.lockedUp = b.lockedUp.sub(unlocked);

        success = true;

        emit TokenUnlocked(_owner, unlocked);
    }

    function _unlock(address _owner, uint256 index) internal returns(uint256 unlocked) {
        lockUp storage l = _lockUps[_owner][index];

        uint count = calculateUnlockCount(l.unlockTimestamp, l.unlockCount);
        if( count == 0 ){
            return 0;
        }
        // if fully unlocked, unlocked amount will match l.amount
        unlocked = l.amount.mul(count).div(l.unlockCount);

        l.unlockTimestamp = l.unlockTimestamp.add(UNLOCK_PERIOD * count);
        l.amount = l.amount.sub(unlocked);
        l.unlockCount = l.unlockCount.sub(count);
    }


    function calculateUnlockCount(uint timestamp, uint unlockCount) view internal returns (uint) {
        if (now < timestamp) {
            return 0;
        }
        uint256 timeCount = (now.sub(timestamp)).div(UNLOCK_PERIOD).add(1);
        if (timeCount > unlockCount){
            return unlockCount;
        }
        else {
            return timeCount;
        }
    }
}
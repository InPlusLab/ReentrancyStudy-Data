pragma solidity 0.4.24;

contract ERC20Interface {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract SqueezerTokenLock {
    ERC20Interface constant public SQR_TOKEN = ERC20Interface(0xf53e6deda250bc5fa12793ac49c257edf4efdbc2);
    uint constant public SQR_TOKEN_DECIMALS = 18;
    uint constant public SQR_TOKEN_MULTIPLIER = 10**SQR_TOKEN_DECIMALS;
    address constant public PROJECT_WALLET = 0xA76A464f409b5570a92b657E08FE23f9C4956068;
    uint constant public PROJECT_MONTHLY = (4687500 * SQR_TOKEN_MULTIPLIER) / 12;
    uint96 constant SEP_02_2019 = 1567426352;
    uint96 constant OCT_02_2019 = 1570018352;
    uint96 constant NOV_02_2019 = 1572696752;
    uint96 constant DEC_02_2019 = 1575288752;
    uint96 constant JAN_02_2020 = 1577967152;
    uint96 constant FEB_02_2020 = 1580645552;
    uint96 constant MAR_02_2020 = 1583151152;
    uint96 constant APR_02_2020 = 1585829552;
    uint96 constant MAY_02_2020 = 1588421552;
    uint96 constant JUN_02_2020 = 1591099952;
    uint96 constant JUL_02_2020 = 1593691952;
    uint96 constant AUG_02_2020 = 1596370352;
    uint96 constant SEP_02_2020 = 1599048752;
    uint96 constant OCT_02_2020 = 1601640752;
    uint96 constant NOV_02_2020 = 1604319152;
    uint96 constant DEC_02_2020 = 1606911152;
    uint96 constant JAN_02_2021 = 1609589552;
    uint96 constant FEB_02_2021 = 1612267952;
    uint96 constant MAR_02_2021 = 1614687152;
    uint96 constant APR_02_2021 = 1617365552;
    uint96 constant MAY_02_2021 = 1619957552;
    uint96 constant JUN_02_2021 = 1622635952;
    uint96 constant JUL_02_2021 = 1625227952;
    uint96 constant AUG_02_2021 = 1627906352;
    uint constant public TOTAL_LOCKS = 25;
    uint8 public unlockStep;

    struct Lock {
        uint96 releaseDate;
        address receiver;
        uint amount;
    }

    Lock[TOTAL_LOCKS] public locks;

    event Released(uint step, uint date, address receiver, uint amount);

    constructor() public {
        uint index = 0;
        _addLock(index++, SEP_02_2019, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, OCT_02_2019, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, NOV_02_2019, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, DEC_02_2019, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JAN_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, FEB_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, MAR_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, APR_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, MAY_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JUN_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JUL_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, AUG_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, SEP_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, OCT_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, NOV_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, DEC_02_2020, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JAN_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, FEB_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, MAR_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, APR_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, MAY_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JUN_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, JUL_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
        _addLock(index++, AUG_02_2021, PROJECT_WALLET, PROJECT_MONTHLY);
    }

    function _addLock(uint _index, uint96 _releaseDate, address _receiver, uint _amount) internal {
        locks[_index].releaseDate = _releaseDate;
        locks[_index].receiver = _receiver;
        locks[_index].amount = _amount;
    }

    function unlock() public returns(bool) {
        uint8 step = unlockStep;
        bool success = false;
        while (step < TOTAL_LOCKS) {
            Lock memory lock = locks[step];
            if (now < lock.releaseDate) {
                break;
            }
            require(SQR_TOKEN.transfer(lock.receiver, lock.amount), 'Transfer failed');
            delete locks[step];
            emit Released(step, lock.releaseDate, lock.receiver, lock.amount);
            success = true;
            step++;
        }
        unlockStep = step;
        return success;
    }

    function () public {
        unlock();
    }

    function recoverTokens(ERC20Interface _token) public returns(bool) {
        // Don't allow recovering SQR Token till the end of lock.
        if (_token == SQR_TOKEN && (now < AUG_02_2021 || unlockStep != TOTAL_LOCKS)) {
            return false;
        }
        return _token.transfer(PROJECT_WALLET, _token.balanceOf(this));
    }
}
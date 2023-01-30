// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./lottery/JoysLotteryMeta.sol";
import "./JoysToken.sol";
import "./JoysNFT.sol";

contract JoysNFTMinning is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using Counters for Counters.Counter;

    // Info of each user.
    struct UserInfo {
        uint256 point;              // The point of nft from the user has provided.
        uint256 heroId;             // Joys hero token id.
        uint256 weaponId;           // Joys weapon token id.
        bool withWeapon;            // Whether stake weapon.
        uint256 heroPoint;          // Joys hero point
        uint256 weaponPoint;        // Joys weapon point
        uint256 rewardDebt;         // Reward debt. See explanation below.
        uint256 blockNumber;        // The block when user deposit.

        // We do some fancy math here. Basically, any point in time, the amount of Joys
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.point * pool.accJoysPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws NFTs to a pool. Here's what happens:
        //   1. The pool's `accJoysPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each user for special pool that stakes NFTs.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    mapping (address => uint256) public userReward;

    // Info of each pool.
    struct PoolInfo {
        uint256 point;              // Joys nft point
        bool withWeapon;            // Whether require weapon nft.
        uint256 allocPoint;         // How many allocation points assigned to this pool. Joys to distribute per block.
        uint256 lastRewardBlock;    // Last block number that Joys distribution occurs.
        uint256 accJoysPerShare;    // Accumulated Joys per share, times 1e12. See below.
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Tracker of special pool's hero count with sub
    mapping (uint256 => uint256) public heroTracker;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    JoysToken public joys;                  // address of joys token contract
    JoysNFT public joysHero;                // address of joys hero contract
    JoysNFT public joysWeapon;              // address of joys weapon contract

    // Block number when bonus JOYS period ends.
    uint256 public bonusBeginBlock;
    uint256 public bonusEndBlock;

    // block per day
    uint256 public constant BLOCK_PER_DAY = 6000;
    // max mine joys per day
    uint256 public constant MAX_REWARD_JOYS_PER_DAY = 20000;

    // multiplier for nft minner.
    uint256 public constant BONUS_MULTIPLIER_8 = 20 * 10;
    uint256 public constant BONUS_MULTIPLIER_4 = 10 * 10;
    uint256 public constant BONUS_MULTIPLIER_2 = 5 * 10;
    uint256 public constant BONUS_MULTIPLIER_1 = 2.5 * 10;

    // mined 48 days
    uint256 public constant MINED_DAYS = 48;

    // continue days per every mine stage
    uint256 public constant CONTINUE_DAYS_PER_STAGE = 12;

    // default min miner
    uint256 public constant DEFAULT_HEROES = 100;

    struct PeriodInfo {
        uint256 begin;
        uint256 end;
        uint256 multiplier;     // times 10
        uint256 joysPerBlock;   // times 1e12
    }
    PeriodInfo[] public periodInfo;

    // miners tracker
    uint256 public lastMinersCount;

    event Deposit(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId, uint256 _amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId);

    constructor(address _joys,
        address _joysHero,
        address _joysWeapon
    ) public {
        joys = JoysToken(_joys);
        joysHero = JoysNFT(_joysHero);
        joysWeapon = JoysNFT(_joysWeapon);

        // init variables
        lastMinersCount = DEFAULT_HEROES;

        bonusBeginBlock = block.number;
        bonusEndBlock = bonusBeginBlock.add(BLOCK_PER_DAY.mul(MINED_DAYS));

        uint256 multiplier = BONUS_MULTIPLIER_8;
        uint256 currentBlock = bonusBeginBlock;
        uint256 lastBlock = currentBlock;
        for (; currentBlock < bonusEndBlock; currentBlock = currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY))) {
            periodInfo.push(PeriodInfo({
                begin: lastBlock,
                end: currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY)),
                multiplier: multiplier,
                joysPerBlock: DEFAULT_HEROES.mul(multiplier).mul(1e11).div(BLOCK_PER_DAY)
                }));

            lastBlock = currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY));
            multiplier = multiplier.div(2);
        }

        // add pool
        add(30, false, false);
        add(30, false, false);
        add(40, true, true);
    }

    function periodInfoLength() external view returns (uint256) {
        return periodInfo.length;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, bool _withWeapon, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > bonusBeginBlock? block.number : bonusBeginBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            point: 0,
            withWeapon: _withWeapon,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accJoysPerShare: 0
            }));
    }

    // Update the given pool's JOYS allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function heroes(uint256 _pid) public view returns (uint256) {
        return heroTracker[_pid];
    }

    function totalHeroes() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            sum = sum.add(heroes(pid));
        }
        return sum;
    }

    function withdrawPercent(uint256 _from, uint256 _to) public pure returns (uint256) {
        // less than 3days deposit, withdraw will take out 10%
        if (_to.sub(_from) <= BLOCK_PER_DAY.mul(3)) {
            return 90;
        }
        return 100;
    }

    function poolAllocPoint(uint256 _pid) public view returns (uint256){
        return poolInfo[_pid].allocPoint;
    }

    // Return reward over the given _from to _to block.
    function getReward(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 totalReward;
        for (uint256 i = 0; i < periodInfo.length; ++i) {
            if (_to <= periodInfo[i].end) {
                if (i == 0) {
                    totalReward = totalReward.add(_to.sub(_from).mul(periodInfo[i].joysPerBlock));
                    break;
                } else {
                    uint256 dest = periodInfo[i].begin;
                    if (_from > periodInfo[i].begin) {
                        dest = _from;
                    }
                    totalReward = totalReward.add(_to.sub(dest).mul(periodInfo[i].joysPerBlock));
                    break;
                }
            } else if (_from >= periodInfo[i].end) {
                continue;
            } else {
                totalReward = totalReward.add(periodInfo[i].end.sub(_from).mul(periodInfo[i].joysPerBlock));
                _from = periodInfo[i].end;
            }
        }

        // minersInfo multi times 1e12, 1e18/(1e12)
        return totalReward.mul(1e6);
    }

    // Rate return rate NOTE it times 10
    function getRate(uint256 _block) public view returns (uint256) {
        for (uint256 i = 0; i < periodInfo.length; ++i) {
            if (_block <= periodInfo[i].end) {
               return periodInfo[i].multiplier;
            }
        }
        return 0;
    }

    // View function to see pending JOYS on frontend.
    function pendingJoys(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accJoysPerShare = pool.accJoysPerShare;
        uint256 nftPoint = pool.point;
        if (block.number > pool.lastRewardBlock && nftPoint != 0) {
            uint256 reward = getReward(pool.lastRewardBlock, block.number);
            uint256 poolReward = reward.mul(pool.allocPoint).div(totalAllocPoint);
            accJoysPerShare = accJoysPerShare.add(poolReward.mul(1e12).div(nftPoint));
        }
        return user.point.mul(accJoysPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 nftPoint = pool.point;
        if (nftPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 reward = getReward(pool.lastRewardBlock, block.number);
        uint256 poolReward = reward.mul(pool.allocPoint).div(totalAllocPoint);
        pool.accJoysPerShare = pool.accJoysPerShare.add(poolReward.mul(1e12).div(nftPoint));
        pool.lastRewardBlock = block.number;
    }

    function updatePeriod() public {
        uint256 th = totalHeroes();
        if (th < lastMinersCount.add(DEFAULT_HEROES)) {
            return;
        }
        lastMinersCount = th;

        // push new
        periodInfo.push(PeriodInfo({
            begin: block.number,
            end: 0,
            multiplier:0,
            joysPerBlock:0
            }));

        // swap the last and update new joysPerBlock for every period
        for (uint256 i = periodInfo.length - 1; i > 0; i--) {
            if (periodInfo[i-1].begin < block.number) {
                uint256 end = periodInfo[i-1].end;
                uint256 multiplier = periodInfo[i-1].multiplier;

                periodInfo[i-1].end = block.number;

                // multiplier times 10 here div 10
                uint256 joysPerDay = lastMinersCount.mul(multiplier).div(10);
                if (joysPerDay > MAX_REWARD_JOYS_PER_DAY) {
                    joysPerDay = MAX_REWARD_JOYS_PER_DAY;
                }
                uint256 joysPerBlock = joysPerDay.mul(1e12).div(BLOCK_PER_DAY);
                periodInfo[i].end = end;
                periodInfo[i].multiplier = multiplier;
                periodInfo[i].joysPerBlock = joysPerBlock;
                break;
            }

            uint256 begin = periodInfo[i-1].begin;
            uint256 end = periodInfo[i-1].end;
            uint256 multiplier = periodInfo[i-1].multiplier;
            uint256 joysPerDay = lastMinersCount.mul(multiplier).div(10);
            if (joysPerDay > MAX_REWARD_JOYS_PER_DAY) {
                joysPerDay = MAX_REWARD_JOYS_PER_DAY;
            }
            uint256 joysPerBlock = joysPerDay.mul(1e12).div(BLOCK_PER_DAY);

            periodInfo[i-1] = periodInfo[i];

            periodInfo[i].begin = begin;
            periodInfo[i].end = end;
            periodInfo[i].multiplier = multiplier;
            periodInfo[i].joysPerBlock = joysPerBlock;
        }
    }

    function deposit(uint256 _pid, uint256 _heroId, bool _withWeapon, uint256 _weaponId) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.point <= 0, "JoysNFTMinning: Do the withdrawal operation first.");
        if (pool.withWeapon) {
          require(_withWeapon, "JoysNftMinning: Need weapon.");
        }

        // hero tracker
        heroTracker[_pid] = heroTracker[_pid].add(1);
        updatePool(_pid);
        updatePeriod();

        uint256 heroStrength;
        (, heroStrength, , ) = joysHero.info(_heroId);
        user.point = user.point.add(heroStrength);
        user.heroPoint = heroStrength;
        pool.point = pool.point.add(heroStrength);
        joysHero.transferFrom(_msgSender(), address(this), _heroId);

        if (_withWeapon) {
            uint256 weaponStrength;
            (, weaponStrength, , ) = joysWeapon.info(_weaponId);
            user.point = user.point.add(weaponStrength);
            user.weaponPoint = weaponStrength;
            pool.point = pool.point.add(weaponStrength);
            joysWeapon.transferFrom(_msgSender(), address(this), _weaponId);
        }

        user.heroId = _heroId;
        user.weaponId = _weaponId;
        user.withWeapon = _withWeapon;
        user.rewardDebt = user.point.mul(pool.accJoysPerShare).div(1e12);
        user.blockNumber = block.number;

        emit Deposit(_msgSender(), _pid, _heroId, _withWeapon, _weaponId);
    }

    function withdraw(uint256 _pid, bool _withNFT) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.point > 0, "JoysNftMinning: withdraw not good");

        updatePool(_pid);

        uint256 pending = user.point.mul(pool.accJoysPerShare).div(1e12).sub(user.rewardDebt);
        uint256 amount = 0;
        if (pending > 0) {
            amount = pending.mul(withdrawPercent(user.blockNumber, block.number)).div(100);
            safeJoysTransfer(_msgSender(), amount);
        }
        if (_withNFT && user.point > 0) {
            if(user.withWeapon) {
                pool.point = pool.point.sub(user.weaponPoint);
                joysWeapon.transferFrom(address(this), _msgSender(), user.weaponId);
            }
            pool.point = pool.point.sub(user.heroPoint);
            joysHero.transferFrom(address(this), _msgSender(), user.heroId);
            heroTracker[_pid] = heroTracker[_pid].sub(1);

            user.point = 0;
        }

        user.rewardDebt = user.point.mul(pool.accJoysPerShare).div(1e12);
        emit Withdraw(_msgSender(), _pid, user.heroId, user.withWeapon, user.weaponId, amount);

        // user reward tracking
        userReward[_msgSender()] = userReward[_msgSender()].add(amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        if (user.point > 0) {
            if(user.withWeapon) {
                pool.point = pool.point.sub(user.weaponPoint);
                joysWeapon.transferFrom(address(this), _msgSender(), user.weaponId);
            }
            pool.point = pool.point.sub(user.heroPoint);
            joysHero.transferFrom(address(this), _msgSender(), user.heroId);
            heroTracker[_pid] = heroTracker[_pid].sub(1);
        }
        emit EmergencyWithdraw(_msgSender(), _pid, user.heroId, user.withWeapon, user.weaponId);
        user.point = 0;
        user.rewardDebt = 0;
    }

    // Safe joys transfer function, just in case if rounding error causes pool to not have enough JOYS.
    function safeJoysTransfer(address _to, uint256 _amount) internal {
        uint256 joysBal = joys.balanceOf(address(this));
        if (_amount > joysBal) {
            joys.transfer(_to, joysBal);
        } else {
            joys.transfer(_to, _amount);
        }
        return;
    }

    function recycleJoysToken(address _address) public onlyOwner {
        require(_address != address(0), "JoysLottery:Invalid address");
        require(joys.balanceOf(address(this)) > 0, "JoysLottery:no JOYS");
        joys.transfer(_address, joys.balanceOf(address(this)));
    }
}
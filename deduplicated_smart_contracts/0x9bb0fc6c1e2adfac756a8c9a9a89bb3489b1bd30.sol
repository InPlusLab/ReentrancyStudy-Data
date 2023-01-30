// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./EnumerableSet.sol";
import "./Ownable.sol";
import "./AlphaPools.sol";
import "./IUniswapV2Pair.sol";
import "./UniswapV2OracleLibrary.sol";
import "./IMakerPriceFeed.sol";
import "./DSMath.sol";

// Alpha Master is the distributor of APOOL and will share the pool with his community out of generosity.
// Farm APOOL in a pool of joy, fulfill your deepest wishes and join the Alpha team on its road to success.
//
// Note that it's ownable and the owner can call himself pool master. The ownership
// will be transferred to a governance smart contract once APOOL is sufficiently
// distributed and the community can show to govern itself. 
//
// Have fun reading it. Hopefully it's bug-free. Lets all get into the pool of joy.
contract AlphaMaster is Ownable {
    using DSMath for uint;
    using SafeERC20 for IERC20;

    // Info of each pooler.
    struct UserInfo {
        uint amount; // How many LP tokens the pooler has provided.
        uint rewardDebt; // Reward debt. See explanation below.
        uint lastHarvestBlock;
        uint totalHarvestReward;
        //
        // We do some fancy math here. Basically, any point in time, the amount of APOOL
        // entitled to a pooler but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accAlphaPoolsPerShare) - user.rewardDebt
        //
        // Whenever a pooler deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accAlphaPoolsPerShare` (and `lastRewardBlock`) gets updated.
        //   2. Pooler receives the pending reward sent to his/her address.
        //   3. Adventurer's `amount` gets updated.
        //   4. Adventurer's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint allocPoint; // How many allocation points assigned to this pool. APOOL to distribute per block.
        uint lastRewardBlock; // Last block number that APOOL distribution occurs.
        uint accAlphaPoolsPerShare; // Accumulated APOOL per share, times 1e6. See below.
    }

    // The AlphaPools TOKEN!
    AlphaPools public alphapools;
    // Dev fund (2%, initially)
    uint public devFundDivRate = 50 * 1e18; //Pool Masters joining in pools to teach tadpolls how to swim crafting APOOL in the process.
    // Dev address.
    address public devaddr;
    // AlphaPools tokens created per block.
    uint public alphapoolsPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    mapping(address => uint256) public poolId1; // poolId1 count from 1, subtraction 1 before using with poolInfo

    // Info of each user that stakes LP tokens.
    mapping(uint => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint public totalAllocPoint = 0;
    // The block number when APOOL mining starts.
    uint public startBlock;

    //uint public endBlock;
    uint public startBlockTime;

    /// @notice pair for reserveToken <> APOOL
    address public uniswap_pair;

    /// @notice last TWAP update time
    uint public blockTimestampLast;

    /// @notice last TWAP cumulative price;
    uint public priceCumulativeLast;

    /// @notice Whether or not this token is first in uniswap APOOL<>Reserve pair
    bool public isToken0;

    uint public apoolPriceMultiplier;

    uint public minAPOOLTWAPIntervalSec;

    address public makerEthPriceFeed;

    uint public timeOfInitTWAP;

    bool public testMode;

    bool public farmEnded;

    // Events
    event Recovered(address token, uint amount);
    event Deposit(address indexed user, uint indexed pid, uint amount);
    event Withdraw(address indexed user, uint indexed pid, uint amount);
    event EmergencyWithdraw(
        address indexed user,
        uint indexed pid,
        uint amount
    );

    constructor(
        AlphaPools _alphapools,
        address reserveToken_,//WETH
        address _devaddr,
        uint _startBlock,
        bool _testMode
    ) public {
        alphapools = _alphapools;
        devaddr = _devaddr;
        startBlock = _startBlock;

        (address _uniswap_pair, bool _isToken0) = UniswapV2OracleLibrary.getUniswapV2Pair(address(alphapools),reserveToken_);

        uniswap_pair = _uniswap_pair;
        isToken0 = _isToken0;

        makerEthPriceFeed = 0x729D19f657BD0614b4985Cf1D82531c67569197B;

        apoolPriceMultiplier = 0;
        testMode = _testMode;
        
         if(testMode == true) {
            minAPOOLTWAPIntervalSec = 1 minutes;
         }
         else {
            minAPOOLTWAPIntervalSec = 23 hours;
         }
    }

    function poolLength() external view returns (uint) {
        return poolInfo.length;
    }

    function start_crafting() external onlyOwner {
        require(block.number > startBlock, "not this time.!");
        require(startBlockTime == 0, "already started.!");

        startBlockTime = block.timestamp;

        alphapoolsPerBlock = getAlphaPoolsPerBlock();
        apoolPriceMultiplier = 1e18;
    }
   function end_crafting() external onlyOwner 
    {
        require(startBlockTime > 0, "not started.!");

        if(alphapools.totalSupply() > (1e18 * 2000000)) {
            farmEnded = true;
        }

    }
    function init_TWAP() external onlyOwner {
        require(timeOfInitTWAP == 0,"already initialized.!");
        (uint priceCumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);

        require(blockTimestamp > 0, "no trades");

        blockTimestampLast = blockTimestamp;
        priceCumulativeLast = priceCumulative;
        timeOfInitTWAP = blockTimestamp;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        require(poolId1[address(_lpToken)] == 0, "add: lp is already in pool");

        if (_withUpdate) {
            massUpdatePools();
        }
        _allocPoint = _allocPoint.toWAD18();

        uint lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolId1[address(_lpToken)] = poolInfo.length + 1;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accAlphaPoolsPerShare: 0
            })
        );
    }

    // Update the given pool's APOOL allocation point. Can only be called by the owner.
    function set(
        uint _pid,
        uint _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }

        _allocPoint = _allocPoint.toWAD18();

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }
     //Updates the price of APOOL token
    function getTWAP() private returns (uint) {

        (uint priceCumulative,uint blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);
        
        uint timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        priceCumulativeLast = priceCumulative;
        blockTimestampLast = blockTimestamp;

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 10**18));
    }
    function getCurrentTWAP() external view returns (uint) {

        (uint priceCumulative,uint blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(uniswap_pair, isToken0);
        
        uint timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 10**18));
    }
    //Updates the ETHUSD price to calculate APOOL price in USD. 
    function getETHUSDPrice() public view returns(uint) {
        if(testMode){
            return 384.2e18;
        }
        return uint(IMakerPriceFeed(makerEthPriceFeed).read());
    }
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint _from, uint _to) private view returns (uint) {
        //require(startBlockTime > 0, "farming not activated yet.!");
        uint _blockCount = _to.sub(_from);
        return alphapoolsPerBlock.wmul(apoolPriceMultiplier).mul(_blockCount);//.wdiv(1 ether);
    }

    // View function to see pending APOOL on frontend.
    function pendingAlphaPools(uint _pid, address _user)
        external
        view
        returns (uint)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint accAlphaPoolsPerShare = pool.accAlphaPoolsPerShare;
        uint lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint alphapoolsReward = multiplier
            //.mul(alphapoolsPerBlock)
                .wmul(pool.allocPoint)
                .wdiv(totalAllocPoint);
                //.wdiv(1e18);
            accAlphaPoolsPerShare = accAlphaPoolsPerShare.add(
                alphapoolsReward
                //.mul(1e6)
                .wdiv(lpSupply)
            );
        }
        return user.amount.wmul(accAlphaPoolsPerShare)
        //.div(1e12)
        .sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        if(farmEnded){
            return;
        }

        uint multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint apoolReward = multiplier
        //.mul(alphapoolsPerBlock)
            .wmul(pool.allocPoint)
            .wdiv(totalAllocPoint);
            //.wdiv(1e18);
        alphapools.mint(devaddr, apoolReward.wdiv(devFundDivRate));
        alphapools.mint(address(this), apoolReward);
        pool.accAlphaPoolsPerShare = pool.accAlphaPoolsPerShare.add(
            apoolReward
            //.mul(1e12)
            .wdiv(lpSupply)
        );
        pool.lastRewardBlock = block.number;

        //setAPOOLPriceMultiplierInt();
    }

    // Deposit LP tokens to PoolMaster for APOOL allocation.
    function deposit(uint _pid, uint _amount) public {
        require(startBlockTime > 0, "farming not activated yet.!");
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint pending = user
                .amount
                .wmul(pool.accAlphaPoolsPerShare)
                //.div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                uint _harvestMultiplier = getAlphaPoolsHarvestMultiplier(
                    user.lastHarvestBlock
                );

                uint _harvestBonus = pending.wmul(_harvestMultiplier);

                // For you, Pool Master rewards poolers if you choose to let your rewards stay in the masters Pool.    
                if (_harvestBonus > 1e18) {
                    alphapools.mint(msg.sender, _harvestBonus);
                    user.totalHarvestReward = user.totalHarvestReward.add(
                        _harvestBonus
                    );
                }
                safeAPOOLTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        user.lastHarvestBlock = block.number;
        user.rewardDebt = user.amount.wmul(pool.accAlphaPoolsPerShare);
        //.div(1e12);

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from PoolMaster.
    function withdraw(uint _pid, uint _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint pending = user.amount.wmul(pool.accAlphaPoolsPerShare)
        //.div(1e12)
        .sub(user.rewardDebt);

        if (pending > 0) {
            safeAPOOLTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.wmul(pool.accAlphaPoolsPerShare);//.div(1e12);

        user.lastHarvestBlock = block.number;

        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.lastHarvestBlock = block.number;
        // user.withdrawalCount++;
    }

    // Safe alphapools transfer function, just in case if rounding error causes pool to not have enough APOOL.
    function safeAPOOLTransfer(address _to, uint _amount) private {
        uint apoolBalance = alphapools.balanceOf(address(this));
        if (_amount > apoolBalance) {
            alphapools.transfer(_to, apoolBalance);
        } else {
            alphapools.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    //function dev(address _devaddr) public {
    //    require(msg.sender == devaddr, "dev: wut?");
    //    devaddr = _devaddr;
    //}

    function setStartBlockTime(uint _startBlockTime) external {
        require(testMode, "testing or not ?");

        startBlockTime = _startBlockTime;
    }
    function setAPOOLPriceMultiplier(uint _multiplier) external {
        require(testMode, "testing or not ?");

        apoolPriceMultiplier = _multiplier * 1e18;
    }
    function getAlphaPoolsTotalSupply() external view returns(uint) {
        require(testMode, "testing or not ?");

        return alphapools.totalSupply();
    }

    // Community swiming in the grand master pool every day and decides the daily bonus multiplier for the next day. This pool can be swam in only once in every day. 
    function setAPOOLPriceMultiplier() external {
        require(startBlockTime > 0 && blockTimestampLast.add(minAPOOLTWAPIntervalSec) < now, "not this time.!");
        require(timeOfInitTWAP > 0, "farm not initialized.!");
        require(farmEnded == false, "farm ended :(");
        
        setAPOOLPriceMultiplierInt();
    }
    function setAPOOLPriceMultiplierInt() private {
        if(startBlockTime == 0 || blockTimestampLast.add(minAPOOLTWAPIntervalSec) > now || timeOfInitTWAP == 0 || farmEnded == true) {
            return;
        }
        uint _apoolPriceETH = getTWAP();
        uint _ethPriceUSD = getETHUSDPrice();
        uint _price = _apoolPriceETH.wmul(_ethPriceUSD);

        if (_price < 1.5e18) 
            apoolPriceMultiplier = 1e18;
        else if (_price >= 1.5e18 && _price < 2.5e18)
            apoolPriceMultiplier = 2e18; 
        else if (_price >= 2.5e18 && _price < 5e18)
            apoolPriceMultiplier = 3e18;
        else apoolPriceMultiplier = 4e18;

        alphapoolsPerBlock = getAlphaPoolsPerBlock();
    }

    // alphapools per block multiplier
    function getAlphaPoolsPerBlock() private view returns (uint) {
        uint elapsedDays = ((now - startBlockTime).div(86400) + 1) * 1e6;
        return elapsedDays.sqrt().wdiv(6363);
    }

    // harvest multiplier
    function getAlphaPoolsHarvestMultiplier(uint _lastHarvestBlock) private view returns (uint) {
        return
            (block.number - _lastHarvestBlock).wdiv(67000).min(1e18);
    }

    function setDevFundDivRate(uint _devFundDivRate) external onlyOwner {
        require(_devFundDivRate > 0, "dev fund rate 0 ?");
        devFundDivRate = _devFundDivRate;
    }

    function setminAPOOLTWAPIntervalSec(uint _interval) external onlyOwner {
        require(_interval > 0, "minAPOOLTWAPIntervalSec 0 ?");
        minAPOOLTWAPIntervalSec = _interval;
    }    
}

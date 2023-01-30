/**
 *Submitted for verification at Etherscan.io on 2019-10-15
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-26
*/

/*

 Copyright 2017-2019 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity 0.5.4;

contract Pool {

    address public owner;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function balanceOf(address _who) external view returns (uint256);
    function totalSupply() external view returns (uint256 totaSupply);
    function getEventful() external view returns (address);
    function getData() external view returns (string memory name, string memory symbol, uint256 sellPrice, uint256 buyPrice);
    function calcSharePrice() external view returns (uint256);
    function getAdminData() external view returns (address, address feeCollector, address dragodAO, uint256 ratio, uint256 transactionFee, uint32 minPeriod);
}

contract ReentrancyGuard {

    // Locked state of mutex
    bool private locked = false;

    /// @dev Functions with this modifer cannot be reentered. The mutex will be locked
    ///      before function execution and unlocked after.
    modifier nonReentrant() {
        // Ensure mutex is unlocked
        require(
            !locked,
            "REENTRANCY_ILLEGAL"
        );

        // Lock mutex before function call
        locked = true;

        // Perform function call
        _;

        // Unlock mutex after function call
        locked = false;
    }
}

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface ProofOfPerformanceFace {

    /*
     * CORE FUNCTIONS
     */
    /// @dev Allows anyone to allocate the pop reward to pool wizards.
    /// @param _ofPool Number of pool id in registry.
    function claimPop(uint256 _ofPool) external;
    
    /// @dev Allows RigoBlock Dao to update the pools registry.
    /// @param _dragoRegistry Address of new registry.
    function setRegistry(address _dragoRegistry) external;
    
    /// @dev Allows RigoBlock Dao to update its address.
    /// @param _rigoblockDao Address of new dao.
    function setRigoblockDao(address _rigoblockDao) external;
    
    /// @dev Allows RigoBlock Dao to set the ratio between assets and performance reward for a group.
    /// @param _ofGroup Id of the pool.
    /// @param _ratio Id of the pool.
    /// @notice onlyRigoblockDao can set ratio.
    function setRatio(address _ofGroup, uint256 _ratio) external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @dev Gets data of a pool.
    /// @param _ofPool Id of the pool.
    /// @return Bool the pool is active.
    /// @return address of the pool.
    /// @return address of the pool factory.
    /// @return price of the pool in wei.
    /// @return total supply of the pool in units.
    /// @return total value of the pool in wei.
    /// @return value of the reward factor or said pool.
    /// @return ratio of assets/performance reward (from 0 to 10000).
    /// @return value of the pop reward to be claimed in GRGs.
    function getPoolData(uint256 _ofPool)
        external
        view
        returns (
            bool active,
            address thePoolAddress,
            address thePoolGroup,
            uint256 thePoolPrice,
            uint256 thePoolSupply,
            uint256 poolValue,
            uint256 epochReward,
            uint256 ratio,
            uint256 pop
        );

    /// @dev Returns the highwatermark of a pool.
    /// @param _ofPool Id of the pool.
    /// @return Value of the all-time-high pool nav.
    function getHwm(uint256 _ofPool) external view returns (uint256);

    /// @dev Returns the reward factor for a pool.
    /// @param _ofPool Id of the pool.
    /// @return Value of the reward factor.
    function getEpochReward(uint256 _ofPool)
        external
        view
        returns (uint256);

    /// @dev Returns the split ratio of asset and performance reward.
    /// @param _ofPool Id of the pool.
    /// @return Value of the ratio from 1 to 100.
    function getRatio(uint256 _ofPool)
        external
        view
        returns (uint256);

    /// @dev Returns the proof of performance reward for a pool.
    /// @param _ofPool Id of the pool.
    /// @return popReward Value of the pop reward in Rigo tokens.
    /// @return performanceReward Split of the performance reward in Rigo tokens.
    /// @notice epoch reward should be big enough that it.
    /// @notice can be decreased if number of funds increases.
    /// @notice should be at least 10^6 (just as pool base) to start with.
    /// @notice rigo token has 10^18 decimals.
    function proofOfPerformance(uint256 _ofPool)
        external
        view
        returns (uint256 popReward, uint256 performanceReward);

    /// @dev Checks whether a pool is registered and active.
    /// @param _ofPool Id of the pool.
    /// @return Bool the pool is active.
    function isActive(uint256 _ofPool)
        external
        view
        returns (bool);

    /// @dev Returns the address and the group of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function addressFromId(uint256 _ofPool)
        external
        view
        returns (
            address pool,
            address group
        );

    /// @dev Returns the price a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Price of the pool in wei.
    /// @return Number of tokens of a pool (totalSupply).
    function getPoolPrice(uint256 _ofPool)
        external
        view
        returns (
            uint256 thePoolPrice,
            uint256 totalTokens
        );

    /// @dev Returns the address and the group of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function calcPoolValue(uint256 _ofPool)
        external
        view
        returns (
            uint256 aum
        );
}

interface DragoRegistry {

    //EVENTS

    event Registered(string name, string symbol, uint256 id, address indexed drago, address indexed owner, address indexed group);
    event Unregistered(string indexed name, string indexed symbol, uint256 indexed id);
    event MetaChanged(uint256 indexed id, bytes32 indexed key, bytes32 value);

    /*
     * CORE FUNCTIONS
     */
    function register(address _drago, string calldata _name, string calldata _symbol, uint256 _dragoId, address _owner) external payable returns (bool);
    function unregister(uint256 _id) external;
    function setMeta(uint256 _id, bytes32 _key, bytes32 _value) external;
    function addGroup(address _group) external;
    function setFee(uint256 _fee) external;
    function updateOwner(uint256 _id) external;
    function updateOwners(uint256[] calldata _id) external;
    function upgrade(address _newAddress) external payable; //payable as there is a transfer of value, otherwise opcode might throw an error
    function setUpgraded(uint256 _version) external;
    function drain() external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function dragoCount() external view returns (uint256);
    function fromId(uint256 _id) external view returns (address drago, string memory name, string memory symbol, uint256 dragoId, address owner, address group);
    function fromAddress(address _drago) external view returns (uint256 id, string memory name, string memory symbol, uint256 dragoId, address owner, address group);
    function fromName(string calldata _name) external view returns (uint256 id, address drago, string memory symbol, uint256 dragoId, address owner, address group);
    function getNameFromAddress(address _pool) external view returns (string memory);
    function getSymbolFromAddress(address _pool) external view returns (string memory);
    function meta(uint256 _id, bytes32 _key) external view returns (bytes32);
    function getGroups() external view returns (address[] memory);
    function getFee() external view returns (uint256);
}

contract Inflation {
    
    uint256 public period;

    /*
     * CORE FUNCTIONS
     */
    function mintInflation(address _thePool, uint256 _reward) external returns (bool);
    function setInflationFactor(address _group, uint256 _inflationFactor) external;
    function setMinimumRigo(uint256 _minimum) external;
    function setRigoblock(address _newRigoblock) external;
    function setAuthority(address _authority) external;
    function setProofOfPerformance(address _pop) external;
    function setPeriod(uint256 _newPeriod) external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function canWithdraw(address _thePool) external view returns (bool);
    function timeUntilClaim(address _thePool) external view returns (uint256);
    function getInflationFactor(address _group) external view returns (uint256);
}

contract RigoToken {
    address public minter;
    uint256 public totalSupply;

    function balanceOf(address _who) external view returns (uint256);
}

/// @title Proof of Performance - Controls parameters of inflation.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
contract ProofOfPerformance is
    SafeMath,
    ReentrancyGuard,
    ProofOfPerformanceFace
{
    address public RIGOTOKENADDRESS;

    address public dragoRegistry;
    address public rigoblockDao;

    mapping (uint256 => PoolPrice) poolPrice;
    mapping (address => Group) groups;

    struct PoolPrice {
        uint256 highwatermark;
    }

    struct Group {
        uint256 rewardRatio;
    }

    modifier onlyRigoblockDao() {
        require(
            msg.sender == rigoblockDao,
            "ONLY_RIGOBLOCK_DAO"
        );
        _;
    }

    constructor(
        address _rigoTokenAddress,
        address _rigoblockDao,
        address _dragoRegistry)
        public
    {
        RIGOTOKENADDRESS = _rigoTokenAddress;
        rigoblockDao = _rigoblockDao;
        dragoRegistry = _dragoRegistry;
    }

    /*
     * CORE FUNCTIONS
     */
    /// @dev Allows anyone to allocate the pop reward to pool wizards.
    /// @param _ofPool Number of pool id in registry.
    function claimPop(uint256 _ofPool)
        external
        nonReentrant
    {
        DragoRegistry registry = DragoRegistry(dragoRegistry);
        address poolAddress;
        (poolAddress, , , , , ) = registry.fromId(_ofPool);
        (uint256 pop, ) = proofOfPerformanceInternal(_ofPool);
        require(
            pop > 0,
            "POP_REWARD_IS_NULL"
        );
        uint256 price = Pool(poolAddress).calcSharePrice();
        poolPrice[_ofPool].highwatermark = price;
        require(
            Inflation(getMinter()).mintInflation(poolAddress, pop),
            "MINT_INFLATION_ERROR"
        );
    }

    /// @dev Allows RigoBlock Dao to update the pools registry.
    /// @param _dragoRegistry Address of new registry.
    function setRegistry(address _dragoRegistry)
        external
        onlyRigoblockDao
    {
        dragoRegistry = _dragoRegistry;
    }

    /// @dev Allows RigoBlock Dao to update its address.
    /// @param _rigoblockDao Address of new dao.
    function setRigoblockDao(address _rigoblockDao)
        external
        onlyRigoblockDao
    {
        rigoblockDao = _rigoblockDao;
    }

    /// @dev Allows RigoBlock Dao to set the ratio between assets and performance reward for a group.
    /// @param _ofGroup Id of the pool.
    /// @param _ratio Id of the pool.
    /// @notice onlyRigoblockDao can set ratio.
    function setRatio(
        address _ofGroup,
        uint256 _ratio)
        external
        onlyRigoblockDao
    {
        require(
            _ratio <= 10000,
            "RATIO_BIGGER_THAN_10000"
        ); //(from 0 to 10000)
        groups[_ofGroup].rewardRatio = _ratio;
    }

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @dev Gets data of a pool.
    /// @param _ofPool Id of the pool.
    /// @return Bool the pool is active.
    /// @return address of the pool.
    /// @return address of the pool factory.
    /// @return price of the pool in wei.
    /// @return total supply of the pool in units.
    /// @return total value of the pool in wei.
    /// @return value of the reward factor or said pool.
    /// @return ratio of assets/performance reward (from 0 to 10000).
    /// @return value of the pop reward to be claimed in GRGs.
    function getPoolData(uint256 _ofPool)
        external
        view
        returns (
            bool active,
            address thePoolAddress,
            address thePoolGroup,
            uint256 thePoolPrice,
            uint256 thePoolSupply,
            uint256 poolValue,
            uint256 epochReward,
            uint256 ratio,
            uint256 pop
        )
    {
        active = isActiveInternal(_ofPool);
        (thePoolAddress, thePoolGroup) = addressFromIdInternal(_ofPool);
        (thePoolPrice, thePoolSupply, poolValue) = getPoolPriceAndValueInternal(_ofPool);
        (epochReward, , ratio) = getInflationParameters(_ofPool);
        (pop, ) = proofOfPerformanceInternal(_ofPool);
        return(
            active,
            thePoolAddress,
            thePoolGroup,
            thePoolPrice,
            thePoolSupply,
            poolValue,
            epochReward,
            ratio,
            pop
        );
    }

    /// @dev Returns the highwatermark of a pool.
    /// @param _ofPool Id of the pool.
    /// @return Value of the all-time-high pool nav.
    function getHwm(uint256 _ofPool)
        external
        view
        returns (uint256)
    {
        return (getHwmInternal(_ofPool));
    }

    /// @dev Returns the reward factor for a pool.
    /// @param _ofPool Id of the pool.
    /// @return Value of the reward factor.
    function getEpochReward(uint256 _ofPool)
        external
        view
        returns (uint256)
    {
        (uint256 epochReward, , ) = getInflationParameters(_ofPool);
        return epochReward;
    }

    /// @dev Returns the split ratio of asset and performance reward.
    /// @param _ofPool Id of the pool.
    /// @return Value of the ratio from 1 to 100.
    function getRatio(uint256 _ofPool)
        external
        view
        returns (uint256)
    {
        ( , , uint256 ratio) = getInflationParameters(_ofPool);
        return ratio;
    }

    /// @dev Returns the proof of performance reward for a pool.
    /// @param _ofPool Id of the pool.
    /// @return popReward Value of the pop reward in Rigo tokens.
    /// @return performanceReward Split of the performance reward in Rigo tokens.
    /// @notice epoch reward should be big enough that it.
    /// @notice can be decreased if number of funds increases.
    /// @notice should be at least 10^6 (just as pool base) to start with.
    /// @notice rigo token has 10^18 decimals.
    function proofOfPerformance(uint256 _ofPool)
        external
        view
        returns (uint256 popReward, uint256 performanceReward)
    {
        return proofOfPerformanceInternal(_ofPool);
    }

    /// @dev Checks whether a pool is registered and active.
    /// @param _ofPool Id of the pool.
    /// @return Bool the pool is active.
    function isActive(uint256 _ofPool)
        external
        view
        returns (bool)
    {
        return isActiveInternal(_ofPool);
    }

    /// @dev Returns the address and the group of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function addressFromId(uint256 _ofPool)
        external
        view
        returns (
            address pool,
            address group
        )
    {
        return (addressFromIdInternal(_ofPool));
    }

    /// @dev Returns the price a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Price of the pool in wei.
    /// @return Number of tokens of a pool (totalSupply).
    function getPoolPrice(uint256 _ofPool)
        external
        view
        returns (
            uint256 thePoolPrice,
            uint256 totalTokens
        )
    {
        (thePoolPrice, totalTokens, ) = getPoolPriceAndValueInternal(_ofPool);
    }

    /// @dev Returns the address and the group of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function calcPoolValue(uint256 _ofPool)
        external
        view
        returns (
            uint256 aum
        )
    {
        ( , , aum) = getPoolPriceAndValueInternal(_ofPool);
    }

    /*
     * INTERNAL FUNCTIONS
     */
    /// @dev Returns the split ratio of asset and performance reward.
    /// @param _ofPool Id of the pool.
    /// @return Value of the reward factor.
    /// @return Value of epoch time.
    /// @return Value of the ratio from 1 to 100.
    function getInflationParameters(uint256 _ofPool)
        internal
        view
        returns (
            uint256 epochReward,
            uint256 epochTime,
            uint256 ratio
        )
    {
        ( , address group) = addressFromIdInternal(_ofPool);
        epochReward = Inflation(getMinter()).getInflationFactor(group);
        epochTime = Inflation(getMinter()).period();
        ratio = groups[group].rewardRatio;
    }

    /// @dev Returns the address of the Inflation contract.
    /// @return Address of the minter/inflation.
    function getMinter()
        internal
        view
        returns (address)
    {
        RigoToken token = RigoToken(RIGOTOKENADDRESS);
        return token.minter();
    }

    /// @dev Returns the proof of performance reward for a pool.
    /// @param _ofPool Id of the pool.
    /// @return popReward Value of the pop reward in Rigo tokens.
    /// @return performanceReward Split of the performance reward in Rigo tokens.
    /// @notice epoch reward should be big enough that it  can be decreased when number of funds increases
    /// @notice should be at least 10^6 (just as pool base) to start with.
    function proofOfPerformanceInternal(uint256 _ofPool)
        internal
        view
        returns (uint256 popReward, uint256 performanceReward)
    {
        uint256 highwatermark= getHwmInternal(_ofPool);
        (uint256 newPrice, uint256 tokenSupply, uint256 poolValue) = getPoolPriceAndValueInternal(_ofPool);
        require (
            newPrice >= highwatermark,
            "PRICE_LOWER_THAN_HWM_ERROR"
        );
        (address thePoolAddress, ) = addressFromIdInternal(_ofPool);
        (uint256 epochReward, uint256 epochTime, uint256 rewardRatio) = getInflationParameters(_ofPool);

        uint256 assetsComponent = safeMul(
            poolValue,
            epochReward
        ) * epochTime / 1 days; // proportional to epoch time

        uint256 performanceComponent = safeMul(
            safeMul(
                (newPrice - highwatermark),
                tokenSupply
            ) / 1000000, // Pool(thePoolAddress).BASE(),
            epochReward
        ) * 365 days / 1 days;

        uint256 assetsReward = (
            safeMul(
                assetsComponent,
                safeSub(10000, rewardRatio) // 100000 = 100%
            ) / 10000 ether
        ) * ethBalanceAdjustmentInternal(thePoolAddress, poolValue) / 1 ether; // reward inversly proportional to Eth in pool

        performanceReward = safeDiv(
            safeMul(performanceComponent, rewardRatio),
            10000 ether
        ) * ethBalanceAdjustmentInternal(thePoolAddress, poolValue) / 1 ether;

        popReward = grgBalanceRewardSlashInternal(thePoolAddress, safeAdd(performanceReward, assetsReward));

        if (popReward > 10 ** 25 / 10000) {
            popReward = 10 ** 25 / 10000; // max single reward 0.01% of total supply
        }
    }

    /// @dev Returns the high-watermark of the pool.
    /// @param _ofPool Number of the pool in registry.
    /// @return Number high-watermark.
    function getHwmInternal(uint256 _ofPool) 
        internal
        view
        returns (uint256)
    {
        if (poolPrice[_ofPool].highwatermark == 0) {
            return (1 ether);

        } else {
            return poolPrice[_ofPool].highwatermark;
        }
    }

    /// @dev Returns the non-linear rewards adjustment by eth.
    /// @param thePoolAddress Address of the pool.
    /// @param poolValue Number of value of the pool in wei.
    /// @return Number non-linear adjustment.
    function ethBalanceAdjustmentInternal(
        address thePoolAddress,
        uint256 poolValue)
        internal
        view
        returns (uint256)
    {
        uint256 poolEthBalance = address(Pool(thePoolAddress)).balance;
        require(
            poolEthBalance <= poolValue && poolEthBalance >= 1 finney, // prevent dust from small pools
            "ETH_BALANCE_HIGHER_THAN_AUM_OR_TOO_SMALL_ERROR"
        );

        // non-linear progression series with decay factor 18%
        // y = (1-decay factor)*k^[(1-decay factor)^(n-1)]
        if (1 ether * poolEthBalance / poolValue >= 800 finney) {
            return (1 ether * poolEthBalance / poolValue);

        } else if (1 ether * poolEthBalance / poolValue >= 600 finney) {
            return (1 ether * poolEthBalance / poolValue * 820 / 1000);

        } else if (1 ether * poolEthBalance / poolValue >= 400 finney) {
            return (1 ether * poolEthBalance / poolValue * 201 / 1000);

        } else if (1 ether * poolEthBalance / poolValue >= 200 finney) {
            return (1 ether * poolEthBalance / poolValue * 29 / 1000);

        } else if (1 ether * poolEthBalance / poolValue >= 100 finney) {
            return (1 ether * poolEthBalance / poolValue * 5 / 1000);

        } else { // reward is 0 for any pool not backed by < 10% eth
            revert('ETH_BELOW_10_PERCENT_AUM_ERROR');
        }
    }

    /// @dev Returns the non-linear rewards adjustment by grg operator balance.
    /// @param thePoolAddress Address of the pool.
    /// @param pop Number of preliminary reward.
    /// @return Number non-linear adjustment.
    function grgBalanceRewardSlashInternal(
        address thePoolAddress,
        uint256 pop)
        internal
        view
        returns (uint256)
    {
        uint256 operatorGrgBalance = RigoToken(RIGOTOKENADDRESS).balanceOf(Pool(thePoolAddress).owner());
        uint256 grgTotalSupply = RigoToken(RIGOTOKENADDRESS).totalSupply();

        // non-linear progression series with decay factor 18%
        // y = (1-decay factor)*k^[(1-decay factor)^(n-1)]
        if (10 ether * operatorGrgBalance / grgTotalSupply >= 5 finney) {
            return (pop);

        } else if (10 ether * operatorGrgBalance / grgTotalSupply >= 4 finney) {
            return (pop * 820 / 1000);

        } else if (10 ether * operatorGrgBalance / grgTotalSupply >= 3 finney) {
            return (pop * 201 / 1000);

        } else if (10 ether * operatorGrgBalance / grgTotalSupply >= 2 finney) {
            return (pop * 29 / 1000);

        } else if (10 ether * operatorGrgBalance / grgTotalSupply >= 1 finney) {
            return (pop * 5 / 1000);

        } else {
            return (pop * 2 / 1000);
        }
    }

    /// @dev Checks whether a pool is registered and active.
    /// @param _ofPool Id of the pool.
    /// @return Bool the pool is active.
    function isActiveInternal(uint256 _ofPool)
        internal view
        returns (bool)
    {
        DragoRegistry registry = DragoRegistry(dragoRegistry);
        (address thePool, , , , , ) = registry.fromId(_ofPool);
        if (thePool != address(0)) {
            return true;
        }
    }

    /// @dev Returns the address and the group of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function addressFromIdInternal(uint256 _ofPool)
        internal
        view
        returns (
            address pool,
            address group
        )
    {
        DragoRegistry registry = DragoRegistry(dragoRegistry);
        (pool, , , , , group) = registry.fromId(_ofPool);
        return (pool, group);
    }

    /// @dev Returns price, supply, aum and boolean of a pool from its id.
    /// @param _ofPool Id of the pool.
    /// @return Price of the pool in wei.
    /// @return Number of tokens of a pool (totalSupply).
    /// @return Address of the target pool.
    /// @return Address of the pool's group.
    function getPoolPriceAndValueInternal(uint256 _ofPool)
        internal
        view
        returns (
            uint256 thePoolPrice,
            uint256 totalTokens,
            uint256 aum
        )
    {
        (address poolAddress, ) = addressFromIdInternal(_ofPool);
        Pool pool = Pool(poolAddress);
        thePoolPrice = pool.calcSharePrice();
        totalTokens = pool.totalSupply();
        require(
            thePoolPrice != uint256(0) && totalTokens != uint256(0),
            "POOL_PRICE_OR_TOTAL_SUPPLY_NULL_ERROR"
        );
        aum = safeMul(thePoolPrice, totalTokens) / 1000000; // pool.BASE();
    }
}
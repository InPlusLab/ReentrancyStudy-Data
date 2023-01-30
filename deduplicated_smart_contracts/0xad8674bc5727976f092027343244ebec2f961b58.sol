/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity = 0.7.0;


interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256 supply);

    function approve(address spender, uint256 value) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address to, uint256 value) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface Minter is ERC20 {
    event Mint(address indexed to, uint256 value, uint indexed period, uint userEthLocked, uint totalEthLocked);

    function governanceRouter() external view returns (GovernanceRouter);
    function mint(address to, uint period, uint128 userEthLocked, uint totalEthLocked) external returns (uint amount);
    function userTokensToClaim(address user) external view returns (uint amount);
    function periodTokens(uint period) external pure returns (uint128);
    function periodDecayK() external pure returns (uint decayK);
    function initialPeriodTokens() external pure returns (uint128);
}

interface PoolFactory {
    event PoolCreatedEvent(address tokenA, address tokenB, bool aIsWETH, address indexed pool);

    function getPool(address tokenA, address tokenB) external returns (address);
    function findPool(address tokenA, address tokenB) external view returns (address);
    function pools(uint poolIndex) external view returns (address pool);
    function getPoolCount() external view returns (uint);
}

interface WETH is ERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

interface GovernanceRouter {
    event GovernanceApplied(uint packedGovernance);
    event GovernorChanged(address covernor);
    event ProtocolFeeReceiverChanged(address protocolFeeReceiver);
    event PoolFactoryChanged(address poolFactory);

    function schedule() external returns(uint timeZero, uint miningPeriod);
    function creator() external returns(address);
    function weth() external returns(WETH);

    function activityMeter() external returns(ActivityMeter);
    function setActivityMeter(ActivityMeter _activityMeter) external;

    function minter() external returns(Minter);
    function setMinter(Minter _minter) external;

    function poolFactory() external returns(PoolFactory);
    function setPoolFactory(PoolFactory _poolFactory) external;

    function protocolFeeReceiver() external returns(address);
    function setProtocolFeeReceiver(address _protocolFeeReceiver) external;

    function governance() external view returns (address _governor, uint96 _defaultGovernancePacked);
    function setGovernor(address _governor) external;
    function applyGovernance(uint96 _defaultGovernancePacked) external;
}

interface ActivityMeter {
    event Deposit(address indexed user, address indexed pool, uint amount);
    event Withdraw(address indexed user, address indexed pool, uint amount);

    function actualizeUserPool(uint endPeriod, address user, address pool) external returns (uint ethLocked, uint mintedAmount) ;  
    function deposit(address pool, uint128 amount) external returns (uint ethLocked, uint mintedAmount);
    function withdraw(address pool, uint128 amount) external returns (uint ethLocked, uint mintedAmount);
    function actualizeUserPools() external returns (uint ethLocked, uint mintedAmount);
    function liquidityEthPriceChanged(uint effectiveTime, uint availableBalanceEth, uint totalSupply) external;
    function effectivePeriod(uint effectiveTime) external view returns (uint periodNumber, uint quantaElapsed);
    function governanceRouter() external view returns (GovernanceRouter);
    function userEthLocked(address user) external view returns (uint ethLockedPeriod, uint ethLocked, uint totalEthLocked);
    
    function ethLockedHistory(uint period) external view returns (uint ethLockedTotal);

    function poolsPriceHistory(uint period, address pool) external view returns (
        uint cumulativeEthPrice,
        uint240 lastEthPrice,
        uint16 timeRef
    );

    function userPoolsSummaries(address user, address pool) external view returns (
        uint144 cumulativeAmountLocked,
        uint16 amountChangeQuantaElapsed,

        uint128 lastAmountLocked,
        uint16 firstPeriod,
        uint16 lastPriceRecord,
        uint16 earnedForPeriod
    );

    function userPools(address user, uint poolIndex) external view returns (address pool);
    function userPoolsLength(address user) external view returns (uint length);

    function userSummaries(address user) external view returns (
        uint128 ethLocked,
        uint16 ethLockedPeriod,
        uint16 firstPeriod
    );
    
    function poolSummaries(address pool) external view returns (
        uint16 lastPriceRecord
    );
    
    function users(uint userIndex) external view returns (address user);
    function usersLength() external view returns (uint);
}

// SPDX-License-Identifier: GPL-3.0
contract LiquifiGovernanceRouter is GovernanceRouter {
    uint private immutable timeZero;
    uint private immutable miningPeriod;

    address public immutable override creator;
    WETH public immutable override weth;
    
    // write once props
    PoolFactory public override poolFactory;
    ActivityMeter public override activityMeter;
    Minter public override minter;
    
    // props managed by governor
    address public override protocolFeeReceiver;

    address private governor;
    uint96 private defaultGovernancePacked;
    
    constructor(uint _miningPeriod, address _weth) public {
        defaultGovernancePacked = (
            /*instantSwapFee*/uint96(3) << 88 | // 0.3%
            /*fee*/uint96(3) << 80 | // 0.3%
            /*maxPeriod*/uint96(1 hours) << 40 |
            /*desiredMaxHistory*/uint96(100) << 24
        );

        creator = tx.origin;
        timeZero = block.timestamp;
        miningPeriod = _miningPeriod;
        weth = WETH(_weth);
    }

    function schedule() external override view returns(uint _timeZero, uint _miningPeriod) {
        _timeZero = timeZero;
        _miningPeriod = address(activityMeter) == address(0) ? 0 : miningPeriod;
    }

    function setActivityMeter(ActivityMeter _activityMeter) external override {
        require(address(activityMeter) == address(0) && tx.origin == creator, "LIQUIFI_GVR: INVALID INIT SENDER");
        activityMeter = _activityMeter;
    }

    function setMinter(Minter _minter) external override {
        require(address(minter) == address(0) && tx.origin == creator, "LIQUIFI_GVR: INVALID INIT SENDER");
        minter = _minter;
    }

    function setPoolFactory(PoolFactory _poolFactory) external override {
        require(msg.sender == governor || (address(poolFactory) == address(0) && tx.origin == creator), "LIQUIFI_GVR: INVALID INIT SENDER");
        poolFactory = _poolFactory;
        emit PoolFactoryChanged(address(_poolFactory));
    }

    function setGovernor(address _governor) external override {
        require(msg.sender == governor || (governor == address(0) && tx.origin == creator), "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        governor = _governor;
        emit GovernorChanged(_governor);
    }

    function setProtocolFeeReceiver(address _protocolFeeReceiver) external override {
        require(msg.sender == governor, "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        protocolFeeReceiver = _protocolFeeReceiver;
        emit ProtocolFeeReceiverChanged(_protocolFeeReceiver);
    }

    function applyGovernance(uint96 _defaultGovernancePacked) external override {
        require(msg.sender == governor, "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        defaultGovernancePacked = _defaultGovernancePacked;
        emit GovernanceApplied(_defaultGovernancePacked);
    }

    // grouped read for gas saving
    function governance() external override view returns (address _governor, uint96 _defaultGovernancePacked) {
        _governor = governor;
        _defaultGovernancePacked = defaultGovernancePacked;
    }
}
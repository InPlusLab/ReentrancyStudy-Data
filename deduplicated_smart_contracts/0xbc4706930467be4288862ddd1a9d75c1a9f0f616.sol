// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./StrongPoolInterface.sol";

contract PoolV2 {
    event Mined(address indexed miner, uint256 amount);
    event Unmined(address indexed miner, uint256 amount);
    event Claimed(address indexed miner, uint256 reward);

    using SafeMath for uint256;

    bool public initDone;
    address public admin;
    address public pendingAdmin;
    address public superAdmin;
    address public pendingSuperAdmin;
    address public parameterAdmin;
    address payable public feeCollector;

    IERC20 public token;
    IERC20 public strongToken;
    StrongPoolInterface public strongPool;

    mapping(address => uint256) public minerBalance;
    uint256 public totalBalance;
    mapping(address => uint256) public minerBlockLastClaimedOn;

    uint256 public rewardBalance;

    uint256 public rewardPerBlockNumerator;
    uint256 public rewardPerBlockDenominator;

    uint256 public miningFeeNumerator;
    uint256 public miningFeeDenominator;

    uint256 public unminingFeeNumerator;
    uint256 public unminingFeeDenominator;

    uint256 public claimingFeeNumerator;
    uint256 public claimingFeeDenominator;

    uint256 public claimingFeeInWei;

    function init(
        address strongTokenAddress,
        address tokenAddress,
        address strongPoolAddress,
        address adminAddress,
        address superAdminAddress,
        uint256 rewardPerBlockNumeratorValue,
        uint256 rewardPerBlockDenominatorValue,
        uint256 miningFeeNumeratorValue,
        uint256 miningFeeDenominatorValue,
        uint256 unminingFeeNumeratorValue,
        uint256 unminingFeeDenominatorValue,
        uint256 claimingFeeNumeratorValue,
        uint256 claimingFeeDenominatorValue
    ) public {
        require(!initDone, "init done");
        strongToken = IERC20(strongTokenAddress);
        token = IERC20(tokenAddress);
        strongPool = StrongPoolInterface(strongPoolAddress);
        admin = adminAddress;
        superAdmin = superAdminAddress;
        rewardPerBlockNumerator = rewardPerBlockNumeratorValue;
        rewardPerBlockDenominator = rewardPerBlockDenominatorValue;
        miningFeeNumerator = miningFeeNumeratorValue;
        miningFeeDenominator = miningFeeDenominatorValue;
        unminingFeeNumerator = unminingFeeNumeratorValue;
        unminingFeeDenominator = unminingFeeDenominatorValue;
        claimingFeeNumerator = claimingFeeNumeratorValue;
        claimingFeeDenominator = claimingFeeDenominatorValue;
        initDone = true;
    }

    // ADMIN
    // *************************************************************************************
    function updateParameterAdmin(address newParameterAdmin) public {
        require(newParameterAdmin != address(0), "zero");
        require(msg.sender == superAdmin);
        parameterAdmin = newParameterAdmin;
    }

    function setPendingAdmin(address newPendingAdmin) public {
        require(newPendingAdmin != address(0), "zero");
        require(msg.sender == admin, "not admin");
        pendingAdmin = newPendingAdmin;
    }

    function acceptAdmin() public {
        require(
            msg.sender == pendingAdmin && msg.sender != address(0),
            "not pendingAdmin"
        );
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function setPendingSuperAdmin(address newPendingSuperAdmin) public {
        require(newPendingSuperAdmin != address(0), "zero");
        require(msg.sender == superAdmin, "not superAdmin");
        pendingSuperAdmin = newPendingSuperAdmin;
    }

    function acceptSuperAdmin() public {
        require(
            msg.sender == pendingSuperAdmin && msg.sender != address(0),
            "not pendingSuperAdmin"
        );
        superAdmin = pendingSuperAdmin;
        pendingSuperAdmin = address(0);
    }

    // REWARD
    // *************************************************************************************
    function updateRewardPerBlock(uint256 numerator, uint256 denominator)
        public
    {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(denominator != 0, "invalid value");
        rewardPerBlockNumerator = numerator;
        rewardPerBlockDenominator = denominator;
    }

    function deposit(uint256 amount) public {
        require(msg.sender == superAdmin, "not an admin");
        require(amount > 0, "zero");
        strongToken.transferFrom(msg.sender, address(this), amount);
        rewardBalance = rewardBalance.add(amount);
    }

    function withdraw(address destination, uint256 amount) public {
        require(msg.sender == superAdmin, "not an admin");
        require(amount > 0, "zero");
        require(rewardBalance >= amount, "not enough");
        strongToken.transfer(destination, amount);
        rewardBalance = rewardBalance.sub(amount);
    }

    // FEES
    // *************************************************************************************
    function updateFeeCollector(address payable newFeeCollector) public {
        require(newFeeCollector != address(0), "zero");
        require(msg.sender == superAdmin);
        feeCollector = newFeeCollector;
    }

    function updateMiningFee(uint256 numerator, uint256 denominator) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(denominator != 0, "invalid value");
        miningFeeNumerator = numerator;
        miningFeeDenominator = denominator;
    }

    function updateUnminingFee(uint256 numerator, uint256 denominator) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(denominator != 0, "invalid value");
        unminingFeeNumerator = numerator;
        unminingFeeDenominator = denominator;
    }

    function updateClaimingFee(uint256 feeInWei) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        claimingFeeInWei = feeInWei;
    }

    // CORE
    // *************************************************************************************
    function mine(uint256 amount) public payable {
        require(amount > 0, "zero");
        uint256 fee = amount.mul(miningFeeNumerator).div(miningFeeDenominator);
        require(msg.value == fee, "invalid fee");
        feeCollector.transfer(msg.value);
        if (block.number > minerBlockLastClaimedOn[msg.sender]) {
            uint256 reward = getReward(msg.sender);
            if (reward > 0) {
                rewardBalance = rewardBalance.sub(reward);
                strongToken.approve(address(strongPool), reward);
                strongPool.mineFor(msg.sender, reward);
                minerBlockLastClaimedOn[msg.sender] = block.number;
            }
        }
        token.transferFrom(msg.sender, address(this), amount);
        minerBalance[msg.sender] = minerBalance[msg.sender].add(amount);
        totalBalance = totalBalance.add(amount);
        if (minerBlockLastClaimedOn[msg.sender] == 0) {
            minerBlockLastClaimedOn[msg.sender] = block.number;
        }
        emit Mined(msg.sender, amount);
    }

    function unmine(uint256 amount) public payable {
        require(amount > 0, "zero");
        uint256 fee = amount.mul(unminingFeeNumerator).div(
            unminingFeeDenominator
        );
        require(msg.value == fee, "invalid fee");
        require(minerBalance[msg.sender] >= amount, "not enough");
        feeCollector.transfer(msg.value);
        if (block.number > minerBlockLastClaimedOn[msg.sender]) {
            uint256 reward = getReward(msg.sender);
            if (reward > 0) {
                rewardBalance = rewardBalance.sub(reward);
                strongToken.approve(address(strongPool), reward);
                strongPool.mineFor(msg.sender, reward);
                minerBlockLastClaimedOn[msg.sender] = block.number;
            }
        }
        minerBalance[msg.sender] = minerBalance[msg.sender].sub(amount);
        totalBalance = totalBalance.sub(amount);
        token.transfer(msg.sender, amount);
        if (minerBalance[msg.sender] == 0) {
            minerBlockLastClaimedOn[msg.sender] = 0;
        }
        emit Unmined(msg.sender, amount);
    }

    function claim() public payable {
        require(minerBlockLastClaimedOn[msg.sender] != 0, "error");
        require(block.number > minerBlockLastClaimedOn[msg.sender], "too soon");
        uint256 reward = getReward(msg.sender);
        require(reward > 0, "no reward");
        require(msg.value == claimingFeeInWei, "invalid fee");
        feeCollector.transfer(msg.value);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(msg.sender, reward);
        rewardBalance = rewardBalance.sub(reward);
        minerBlockLastClaimedOn[msg.sender] = block.number;
        emit Claimed(msg.sender, reward);
    }

    function getReward(address miner) public view returns (uint256) {
        if (totalBalance == 0) return 0;
        if (minerBlockLastClaimedOn[miner] == 0) return 0;
        uint256 blockResult = block.number.sub(minerBlockLastClaimedOn[miner]);
        uint256 rewardPerBlockResult = blockResult
            .mul(rewardPerBlockNumerator)
            .div(rewardPerBlockDenominator);
        return rewardPerBlockResult.mul(minerBalance[miner]).div(totalBalance);
    }
}

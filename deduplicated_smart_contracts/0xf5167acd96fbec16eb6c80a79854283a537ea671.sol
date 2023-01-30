// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./StrongPoolInterface.sol";

contract Service {
    event Requested(address indexed miner);
    event Claimed(address indexed miner, uint256 reward);

    using SafeMath for uint256;
    bool public initDone;
    address public admin;
    address public pendingAdmin;
    address public superAdmin;
    address public pendingSuperAdmin;
    address public serviceAdmin;
    address public parameterAdmin;
    address payable public feeCollector;

    IERC20 public strongToken;
    StrongPoolInterface public strongPool;

    uint256 public rewardPerBlockNumerator;
    uint256 public rewardPerBlockDenominator;

    uint256 public naasRewardPerBlockNumerator;
    uint256 public naasRewardPerBlockDenominator;

    uint256 public claimingFeeNumerator;
    uint256 public claimingFeeDenominator;

    uint256 public requestingFeeInWei;

    uint256 public strongFeeInWei;

    uint256 public recurringFeeInWei;
    uint256 public recurringNaaSFeeInWei;
    uint256 public recurringPaymentCycleInBlocks;

    uint256 public rewardBalance;

    mapping(address => uint256) public entityBlockLastClaimedOn;

    address[] public entities;
    mapping(address => uint256) public entityIndex;
    mapping(address => bool) public entityActive;
    mapping(address => bool) public requestPending;
    mapping(address => bool) public entityIsNaaS;
    mapping(address => uint256) public paidOnBlock;
    uint256 public activeEntities;

    string public desciption;

    function init(
        address strongTokenAddress,
        address strongPoolAddress,
        address adminAddress,
        address superAdminAddress,
        uint256 rewardPerBlockNumeratorValue,
        uint256 rewardPerBlockDenominatorValue,
        uint256 naasRewardPerBlockNumeratorValue,
        uint256 naasRewardPerBlockDenominatorValue,
        uint256 requestingFeeInWeiValue,
        uint256 strongFeeInWeiValue,
        uint256 recurringFeeInWeiValue,
        uint256 recurringNaaSFeeInWeiValue,
        uint256 recurringPaymentCycleInBlocksValue,
        uint256 claimingFeeNumeratorValue,
        uint256 claimingFeeDenominatorValue,
        string memory desc
    ) public {
        require(!initDone, "init done");
        strongToken = IERC20(strongTokenAddress);
        strongPool = StrongPoolInterface(strongPoolAddress);
        admin = adminAddress;
        superAdmin = superAdminAddress;
        rewardPerBlockNumerator = rewardPerBlockNumeratorValue;
        rewardPerBlockDenominator = rewardPerBlockDenominatorValue;
        naasRewardPerBlockNumerator = naasRewardPerBlockNumeratorValue;
        naasRewardPerBlockDenominator = naasRewardPerBlockDenominatorValue;
        requestingFeeInWei = requestingFeeInWeiValue;
        strongFeeInWei = strongFeeInWeiValue;
        recurringFeeInWei = recurringFeeInWeiValue;
        recurringNaaSFeeInWei = recurringNaaSFeeInWeiValue;
        claimingFeeNumerator = claimingFeeNumeratorValue;
        claimingFeeDenominator = claimingFeeDenominatorValue;
        recurringPaymentCycleInBlocks = recurringPaymentCycleInBlocksValue;
        desciption = desc;
        initDone = true;
    }

    // ADMIN
    // *************************************************************************************
    function updateServiceAdmin(address newServiceAdmin) public {
        require(msg.sender == superAdmin);
        serviceAdmin = newServiceAdmin;
    }

    function updateParameterAdmin(address newParameterAdmin) public {
        require(newParameterAdmin != address(0), "zero");
        require(msg.sender == superAdmin);
        parameterAdmin = newParameterAdmin;
    }

    function updateFeeCollector(address payable newFeeCollector) public {
        require(newFeeCollector != address(0), "zero");
        require(msg.sender == superAdmin);
        feeCollector = newFeeCollector;
    }

    function setPendingAdmin(address newPendingAdmin) public {
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

    // ENTITIES
    // *************************************************************************************
    function getEntities() public view returns (address[] memory) {
        return entities;
    }

    function isEntityActive(address entity) public view returns (bool) {
        return entityActive[entity];
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

    function updateNaaSRewardPerBlock(uint256 numerator, uint256 denominator)
        public
    {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(denominator != 0, "invalid value");
        naasRewardPerBlockNumerator = numerator;
        naasRewardPerBlockDenominator = denominator;
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
    function updateRequestingFee(uint256 feeInWei) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        requestingFeeInWei = feeInWei;
    }

    function updateStrongFee(uint256 feeInWei) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        strongFeeInWei = feeInWei;
    }

    function updateClaimingFee(uint256 numerator, uint256 denominator) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(denominator != 0, "invalid value");
        claimingFeeNumerator = numerator;
        claimingFeeDenominator = denominator;
    }

    function updateRecurringFee(uint256 feeInWei) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        recurringFeeInWei = feeInWei;
    }

    function updateRecurringNaaSFee(uint256 feeInWei) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        recurringNaaSFeeInWei = feeInWei;
    }

    function updateRecurringPaymentCycleInBlocks(uint256 blocks) public {
        require(
            msg.sender == admin ||
                msg.sender == parameterAdmin ||
                msg.sender == superAdmin,
            "not an admin"
        );
        require(blocks > 0, "zero");
        recurringPaymentCycleInBlocks = blocks;
    }

    // CORE
    // *************************************************************************************
    function requestAccess() public payable {
        require(!requestPending[msg.sender], "pending");
        require(!entityActive[msg.sender], "active");
        require(msg.value == requestingFeeInWei, "invalid fee");
        feeCollector.transfer(msg.value);
        strongToken.transferFrom(msg.sender, address(this), strongFeeInWei);
        strongToken.transfer(feeCollector, strongFeeInWei);
        requestPending[msg.sender] = true;
        emit Requested(msg.sender);
    }

    function grantAccess(
        address[] memory ents,
        bool[] memory entIsNaaS,
        bool useChecks
    ) public {
        require(
            msg.sender == admin ||
                msg.sender == serviceAdmin ||
                msg.sender == superAdmin,
            "not admin"
        );
        require(ents.length > 0, "zero");
        require(ents.length == entIsNaaS.length, "lengths dont match");
        for (uint256 i = 0; i < ents.length; i++) {
            address entity = ents[i];
            bool nass = entIsNaaS[i];
            if (useChecks) {
                require(requestPending[entity], "not pending");
            }
            require(!entityActive[entity], "exists");
            uint256 len = entities.length;
            entityIndex[entity] = len;
            entities.push(entity);
            entityActive[entity] = true;
            requestPending[entity] = false;
            entityIsNaaS[entity] = nass;
            activeEntities = activeEntities.add(1);
            entityBlockLastClaimedOn[entity] = block.number;
            paidOnBlock[entity] = block.number;
        }
    }

    function setEntityActiveStatus(address entity, bool status) public {
        require(
            msg.sender == admin ||
                msg.sender == serviceAdmin ||
                msg.sender == superAdmin,
            "not admin"
        );
        uint256 index = entityIndex[entity];
        require(entities[index] == entity, "invalid entity");
        require(entityActive[entity] != status, "already set");
        entityActive[entity] = status;
        if (status) {
            activeEntities = activeEntities.add(1);
            entityBlockLastClaimedOn[entity] = block.number;
        } else {
            if (block.number > entityBlockLastClaimedOn[entity]) {
                uint256 reward = getReward(entity);
                if (reward > 0) {
                    rewardBalance = rewardBalance.sub(reward);
                    strongToken.approve(address(strongPool), reward);
                    strongPool.mineFor(entity, reward);
                }
            }
            activeEntities = activeEntities.sub(1);
            entityBlockLastClaimedOn[entity] = 0;
        }
    }

    function payFee() public payable {
        if (entityIsNaaS[msg.sender]) {
            require(msg.value == recurringNaaSFeeInWei, "naas fee");
        } else {
            require(msg.value == recurringFeeInWei, "basic fee");
        }
        feeCollector.transfer(msg.value);
        paidOnBlock[msg.sender] = block.number;
    }

    function getReward(address entity) public view returns (uint256) {
        if (activeEntities == 0) return 0;
        if (entityBlockLastClaimedOn[entity] == 0) return 0;
        uint256 blockResult = block.number.sub(
            entityBlockLastClaimedOn[entity]
        );
        uint256 rewardNumerator;
        uint256 rewardDenominator;
        if (entityIsNaaS[msg.sender]) {
            rewardNumerator = naasRewardPerBlockNumerator;
            rewardDenominator = naasRewardPerBlockDenominator;
        } else {
            rewardNumerator = rewardPerBlockNumerator;
            rewardDenominator = rewardPerBlockDenominator;
        }
        uint256 rewardPerBlockResult = blockResult.mul(rewardNumerator).div(
            rewardDenominator
        );
        return rewardPerBlockResult.div(activeEntities);
    }

    function claim() public payable {
        require(entityActive[msg.sender], "not active");
        require(paidOnBlock[msg.sender] != 0, "zero");
        require(
            block.number <
                paidOnBlock[msg.sender] + recurringPaymentCycleInBlocks,
            "pay fee"
        );
        require(entityBlockLastClaimedOn[msg.sender] != 0, "error");
        require(
            block.number > entityBlockLastClaimedOn[msg.sender],
            "too soon"
        );
        uint256 reward = getReward(msg.sender);
        require(reward > 0, "no reward");
        uint256 fee = reward.mul(claimingFeeNumerator).div(
            claimingFeeDenominator
        );
        require(msg.value == fee, "invalid fee");
        feeCollector.transfer(msg.value);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(msg.sender, reward);
        rewardBalance = rewardBalance.sub(reward);
        entityBlockLastClaimedOn[msg.sender] = block.number;
        emit Claimed(msg.sender, reward);
    }
}

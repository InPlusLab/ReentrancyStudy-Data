pragma solidity ^0.4.24;
import "./SafeMath.sol";

interface ERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract EscrowFund {
    using SafeMath for uint256;

    uint256 USDTPercentage = 90;

    // BCNT token contract
    ERC20 public BCNTToken;
    ERC20 public StableToken;

    // Roles
    address public bincentiveHot; // i.e., Platform Owner
    address public bincentiveCold;
    address[] public investors; // implicitly first investor is the lead investor
    address public accountManager;
    address public fundManager; // i.e., Exchange Deposit and Withdraw Manager
    address[] public traders;

    uint256 public numMidwayQuitInvestors;
    uint256 public numRefundedInvestors; // i.e., number of investors that already received refund
    uint256 public numAUMDistributedInvestors; // i.e., number of investors that already received AUM

    // Contract(Fund) Status
    // 0: not initialized
    // 1: initialized
    // 2: not enough fund came in in time
    // 3: fundStarted
    // 4: running
    // 5: stoppped
    // 6: closed
    uint256 public fundStatus;

    // Money
    uint256 public currentInvestedAmount;
    uint256 public investedUSDTAmount;
    uint256 public investedBCNTAmount;
    mapping(address => uint256) public investedAmount;
    mapping(address => uint256) public depositedUSDTAmount;
    mapping(address => uint256) public depositedBCNTAmount;
    uint256 public BCNTLockAmount;
    uint256 public returnedStableTokenAmounts;
    uint256 public returnedBCNTAmounts;
    mapping(address => uint256) public traderReceiveUSDTAmounts;
    mapping(address => uint256) public traderReceiveBCNTAmounts;

    // Fund Parameters
    uint256 public minInvestAmount;
    // Risk management Parameters...
    uint256 public investPaymentDueTime;
    uint256 public softCap;
    uint256 public hardCap;

    // Events
    event Deposit(address indexed investor, uint256 amount);
    event StartFund(uint256 num_investors, uint256 totalInvestedAmount, uint256 BCNTLockAmount);
    event AbortFund(uint256 num_investors, uint256 totalInvestedAmount);
    event MidwayQuit(address indexed investor, uint256 investAmount, uint256 BCNTWithdrawAmount);
    event DesignateFundManager(address indexed fundManager);
    event Allocate(address indexed to, uint256 amountStableTokenForInvestment, uint256 amountBCNTForInvestment);
    event ReturnAUM(uint256 amountStableToken, uint256 amountBCNT);
    event DistributeAUM(address indexed to, uint256 amountStableToken, uint256 amountBCNT);


    // Modifiers
    modifier initialized() {
        require(fundStatus == 1);
        _;
    }

    modifier fundStarted() {
        require(fundStatus == 3);
        _;
    }

    modifier running() {
        require(fundStatus == 4);
        _;
    }

    modifier stopped() {
        require(fundStatus == 5);
        _;
    }

    modifier afterStartedBeforeStopped() {
        require((fundStatus >= 3) && (fundStatus < 5));
        _;
    }

    modifier closedOrAborted() {
        require((fundStatus == 6) || (fundStatus == 2));
        _;
    }

    modifier isBincentive() {
        require(
            (msg.sender == bincentiveHot) || (msg.sender == bincentiveCold)
        );
        _;
    }

    modifier isBincentiveCold() {
        require(msg.sender == bincentiveCold);
        _;
    }

    modifier isInvestor() {
        // bincentive is not investor
        require(msg.sender != bincentiveHot);
        require(msg.sender != bincentiveCold);
        require(investedAmount[msg.sender] > 0);
        _;
    }

    modifier isAccountManager() {
        require(msg.sender == accountManager);
        _;
    }

    modifier isFundManager() {
        require(msg.sender == fundManager);
        _;
    }

    // Getter Functions


    // Investor Deposit
    function deposit(address investor, uint256 depositUSDTAmount, uint256 depositBCNTAmount) initialized public {
        require(now < investPaymentDueTime);
        require(currentInvestedAmount < hardCap);
        require((investor != bincentiveHot) && (investor != bincentiveCold));

        uint256 amount;
        if(depositBCNTAmount > 0) {
            // Only bincentive can deposit with BCNT
            require((msg.sender == bincentiveHot) || (msg.sender == bincentiveCold));

            amount = depositUSDTAmount.mul(100).div(USDTPercentage);
        }
        else {
            amount = depositUSDTAmount;
        }
        // Check if deposit amount exceed minimum invest amount
        require(amount >= minInvestAmount);
        // Check if deposit amount exceed hard cap
        require(currentInvestedAmount.add(amount) <= hardCap);

        // Transfer Stable Token to this contract
        // If deposit from bincentive, transferFrom `bincentiveCold`
        // Else transferFrom msg.sender
        if((msg.sender == bincentiveHot) || (msg.sender == bincentiveCold)) {
            require(StableToken.transferFrom(bincentiveCold, address(this), depositUSDTAmount));
            // Deposit BCNT only if invest amount does not exceed hard cap
            if(depositBCNTAmount > 0) {
                require(BCNTToken.transferFrom(bincentiveCold, address(this), depositBCNTAmount));
                depositedBCNTAmount[investor] = depositedBCNTAmount[investor].add(depositBCNTAmount);
                investedBCNTAmount = investedBCNTAmount.add(depositBCNTAmount);
            }
        }
        else{
            require(StableToken.transferFrom(msg.sender, address(this), depositUSDTAmount));
        }
        depositedUSDTAmount[investor] = depositedUSDTAmount[investor].add(depositUSDTAmount);
        investedUSDTAmount = investedUSDTAmount.add(depositUSDTAmount);

        currentInvestedAmount = currentInvestedAmount.add(amount);
        if(investedAmount[investor] == 0) {
            investors.push(investor);
        }
        investedAmount[investor] = investedAmount[investor].add(amount);

        emit Deposit(investor, amount);
    }

    // Start Investing
    function start(uint256 _BCNTLockAmount) initialized isBincentive public {
        require(currentInvestedAmount >= softCap);

        // Transfer and lock BCNT into the contract
        require(BCNTToken.transferFrom(bincentiveCold, address(this), _BCNTLockAmount));
        BCNTLockAmount = _BCNTLockAmount;

        // Start the contract
        fundStatus = 3;
        emit StartFund(investors.length, currentInvestedAmount, BCNTLockAmount);
    }

    // NOTE: might consider changing to withdrawal pattern
    // Not Enough Fund
    function notEnoughFund(uint256 numInvestorsToRefund) initialized isBincentive public {
        require(now >= investPaymentDueTime);
        require(currentInvestedAmount < softCap);
        require(numRefundedInvestors.add(numInvestorsToRefund) <= investors.length, "Refund to more than total number of investors");

        address investor;
        // Return Stable Token to investors
        for(uint i = numRefundedInvestors; i < (numRefundedInvestors.add(numInvestorsToRefund)); i++) {
            investor = investors[i];
            if(investedAmount[investor] == 0) continue;

            require(StableToken.transfer(investor, depositedUSDTAmount[investor]));
            if(depositedBCNTAmount[investor] > 0) {
                require(BCNTToken.transfer(investor, depositedBCNTAmount[investor]));
            }
        }

        numRefundedInvestors = numRefundedInvestors.add(numInvestorsToRefund);
        if(numRefundedInvestors >= investors.length) {
            // End the contract due to not enough fund
            fundStatus = 2;

            emit AbortFund(investors.length, currentInvestedAmount);
        }
    }

    // Investor quit and withdraw
    function midwayQuit() afterStartedBeforeStopped isInvestor public {
        uint256 investor_amount = investedAmount[msg.sender];
        investedAmount[msg.sender] = 0;

        // Subtract total invest amount and transfer investor's share to `bincentiveCold`
        uint256 totalAmount = currentInvestedAmount;
        currentInvestedAmount = currentInvestedAmount.sub(investor_amount);
        investedAmount[bincentiveCold] = investedAmount[bincentiveCold].add(investor_amount);

        uint256 BCNTWithdrawAmount = BCNTLockAmount.mul(investor_amount).div(totalAmount);
        BCNTLockAmount = BCNTLockAmount.sub(BCNTWithdrawAmount);
        require(BCNTToken.transfer(msg.sender, BCNTWithdrawAmount));

        numMidwayQuitInvestors = numMidwayQuitInvestors.add(1);
        // Close the contract if every investor has quit
        if(numMidwayQuitInvestors == investors.length) {
            fundStatus = 6;
        }

        emit MidwayQuit(msg.sender, investor_amount, BCNTWithdrawAmount);
    }

    // Account manager designate fund manager
    function designateFundManager(address _fundManager) fundStarted isAccountManager public {
        require(fundManager == address(0), "Fund manager is already declared.");
        fundManager = _fundManager;

        emit DesignateFundManager(_fundManager);
    }

    // Fund manager allocate the resources
    function allocateFund(address[] _traders, uint256[] receiveUSDTAmounts, uint256[] receiveBCNTAmounts) fundStarted isFundManager public {
        require(traders.length == 0, "Already allocated");
        require(_traders.length > 0, "Must has at least one recipient");
        require(_traders.length == receiveUSDTAmounts.length, "Input not of the same length");
        require(receiveUSDTAmounts.length == receiveBCNTAmounts.length, "Input not of the same length");

        uint256 totalAllocatedUSDTAmount;
        uint256 totalAllocatedBCNTAmount;
        address trader;
        for(uint i = 0; i < _traders.length; i++) {
            trader = _traders[i];
            traders.push(trader);
            traderReceiveUSDTAmounts[trader] = receiveUSDTAmounts[i];
            traderReceiveBCNTAmounts[trader] = receiveBCNTAmounts[i];

            emit Allocate(trader, traderReceiveUSDTAmounts[trader], traderReceiveBCNTAmounts[trader]);

            totalAllocatedUSDTAmount = totalAllocatedUSDTAmount.add(receiveUSDTAmounts[i]);
            totalAllocatedBCNTAmount = totalAllocatedBCNTAmount.add(receiveBCNTAmounts[i]);
        }

        require(totalAllocatedUSDTAmount == investedUSDTAmount, "Must allocate the full invested amount");
        require(totalAllocatedBCNTAmount == investedBCNTAmount, "Must allocate the full invested amount");
    }

    // `bincentiveCold` dispense the resources
    function dispenseFund() fundStarted isBincentiveCold public {
        require(traders.length > 0, "Must has at least one recipient");

        address trader;
        for(uint i = 0; i < traders.length; i++) {
            trader = traders[i];
            // Transfer the fund to trader
            require(StableToken.transfer(trader, traderReceiveUSDTAmounts[trader]));
            if(traderReceiveBCNTAmounts[trader] > 0) {
                require(BCNTToken.transfer(trader, traderReceiveBCNTAmounts[trader]));
            }
        }

        fundStatus = 4;
    }

    // Return AUM
    function returnAUM(uint256 stableTokenAmount, uint256 BCNTAmount) running isBincentiveCold public {

        returnedStableTokenAmounts = stableTokenAmount;
        returnedBCNTAmounts = BCNTAmount;

        // Transfer stable token AUM to trader
        require(StableToken.transferFrom(bincentiveCold, address(this), stableTokenAmount));

        // Transfer BCNT AUM to trader
        require(BCNTToken.transferFrom(bincentiveCold, address(this), BCNTAmount));

        emit ReturnAUM(stableTokenAmount, BCNTAmount);

        fundStatus = 5;
    }

    // Distribute AUM
    function distributeAUM(uint256 numInvestorsToDistribute) stopped isBincentive public {
        require(numAUMDistributedInvestors.add(numInvestorsToDistribute) <= investors.length, "Distributing to more than total number of investors");

        uint256 totalStableTokenReturned = returnedStableTokenAmounts;
        uint256 totalBCNTReturned = returnedBCNTAmounts;
        // Count `bincentiveCold`'s share in total amount when distributing AUM
        uint256 totalAmount = currentInvestedAmount.add(investedAmount[bincentiveCold]);

        uint256 stableTokenDistributeAmount;
        uint256 BCNTDistributeAmount;
        address investor;
        uint256 investor_amount;
        // Distribute Stable Token and BCNT to investors
        for(uint i = numAUMDistributedInvestors; i < (numAUMDistributedInvestors.add(numInvestorsToDistribute)); i++) {
            investor = investors[i];
            if(investedAmount[investor] == 0) continue;
            investor_amount = investedAmount[investor];
            investedAmount[investor] = 0;

            stableTokenDistributeAmount = totalStableTokenReturned.mul(investor_amount).div(totalAmount);
            require(StableToken.transfer(investor, stableTokenDistributeAmount));

            BCNTDistributeAmount = totalBCNTReturned.mul(investor_amount).div(totalAmount);
            require(BCNTToken.transfer(investor, BCNTDistributeAmount));

            emit DistributeAUM(investor, stableTokenDistributeAmount, BCNTDistributeAmount);
        }

        numAUMDistributedInvestors = numAUMDistributedInvestors.add(numInvestorsToDistribute);
        // If all investors have received AUM,
        // distribute AUM and return BCNT stake to `bincentiveCold` then close the fund.
        if(numAUMDistributedInvestors >= investors.length) {
            returnedStableTokenAmounts = 0;
            returnedBCNTAmounts = 0;
            currentInvestedAmount = 0;
            // Distribute Stable Token and BCNT to `bincentiveCold`
            if(investedAmount[bincentiveCold] > 0) {
                investor_amount = investedAmount[bincentiveCold];
                investedAmount[bincentiveCold] = 0;
                stableTokenDistributeAmount = totalStableTokenReturned.mul(investor_amount).div(totalAmount);
                require(StableToken.transfer(bincentiveCold, stableTokenDistributeAmount));

                BCNTDistributeAmount = totalBCNTReturned.mul(investor_amount).div(totalAmount);
                require(BCNTToken.transfer(bincentiveCold, BCNTDistributeAmount));

                emit DistributeAUM(bincentiveCold, stableTokenDistributeAmount, BCNTDistributeAmount);
            }

            // Transfer the BCNT stake left back to `bincentiveCold`
            uint256 _BCNTLockAmount = BCNTLockAmount;
            BCNTLockAmount = 0;
            require(BCNTToken.transfer(bincentiveCold, _BCNTLockAmount));

            fundStatus = 6;
        }
    }

    function claimWronglyTransferredFund() closedOrAborted isBincentive public {
        uint256 leftOverAmount;
        leftOverAmount = StableToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(StableToken.transfer(bincentiveCold, leftOverAmount));
        }
        leftOverAmount = BCNTToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(BCNTToken.transfer(bincentiveCold, leftOverAmount));
        }
    }


    // Constructor
    constructor(
        address _BCNTToken,
        address _StableToken,
        address _bincentiveHot,
        address _bincentiveCold,
        address _accountManager,
        uint256 _minInvestAmount,
        uint256 _investPaymentPeriod,
        uint256 _softCap,
        uint256 _hardCap) public {

        bincentiveHot = _bincentiveHot;
        bincentiveCold = _bincentiveCold;
        BCNTToken = ERC20(_BCNTToken);
        StableToken = ERC20(_StableToken);

        // Assign roles
        accountManager = _accountManager;

        // Set parameters
        minInvestAmount = _minInvestAmount;
        investPaymentDueTime = now.add(_investPaymentPeriod);
        softCap = _softCap;
        hardCap = _hardCap;

        // Initialized the contract
        fundStatus = 1;
    }
}
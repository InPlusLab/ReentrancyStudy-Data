pragma solidity ^0.5.17;

import "./Agent.sol";
import "./SafeMath.sol";
import "./CashBackMoneyI.sol";


/**
 * @title CashBackMoney Investing Contract
 * https://cashbackmoney.club/  - Investment community with simple rules and high returns. Earn up to 8% daily profit in ETH
 */
contract CashBackMoney is CashBackMoneyI, Agent {
    using SafeMath for uint256;

    // Constants
    uint256 public constant amount1 = 0.15 ether;
    uint256 public constant amount2 = 0.50 ether;
    uint256 public constant amount3 = 1.00 ether;
    uint256 public constant amount4 = 2.50 ether;
    uint256 public constant amount5 = 5.00 ether;
    uint256 public constant amount6 = 10.00 ether;

    uint256 public constant subs_amount1 = 1.00 ether;
    uint256 public constant subs_amount2 = 5.00 ether;
    uint256 public constant subs_amount3 = 10.00 ether;

    uint256 public constant subs_amount_with_fee1 = 1.18 ether;
    uint256 public constant subs_amount_with_fee2 = 5.90 ether;
    uint256 public constant subs_amount_with_fee3 = 11.80 ether;

    uint256 public days1 = 1 days;
    uint256 public hours24 = 24 hours;
    uint256 public hours3 = 3 hours;

    // Variables
    bool public production = false;
    uint256 public deploy_block;

    address payable public reward_account;
    uint256 public reward;
    uint256 public start_point;

    uint256 public NumberOfParticipants = 0;
    uint256 public NumberOfClicks = 0;
    uint256 public NumberOfSubscriptions = 0;
    uint256 public ProfitPayoutAmount = 0;
    uint256 public FundBalance = 0;

    uint256 public LastRefererID = 0;

    // RefererID[referer address]
    mapping(address => uint256) public RefererID;

    // RefererAddr[referer ID]
    mapping(uint256 => address) public RefererAddr;

    // Referer[Referal address]
    mapping(address => uint256) public Referer;

    // Participants[address]
    mapping(address => bool) public Participants;

    // OwnerAmountStatus[owner address][payXamount]
    mapping(address => mapping(uint256 => bool)) public OwnerAmountStatus;

    // RefClickCount[referer address][payXamount]
    mapping(address => mapping(uint256 => uint256)) public RefClickCount;

    // OwnerTotalProfit[owner address]
    mapping(address => uint256) public OwnerTotalProfit;

    // RefTotalClicks[referer address]
    mapping(address => uint256) public RefTotalClicks;

    // RefTotalIncome[referer address]
    mapping(address => uint256) public RefTotalIncome;

    // Balances[address][level][payXamount]
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public Balances;

    // WithdrawDate[address][level][payXamount]
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public WithdrawDate;

    // OwnerAutoClickCount[owner address][msg.value][GetPeriod(now)]
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public OwnerAutoClickCount;

    // RefAutoClickCount[referer address][msg.value][GetPeriod(now)]
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public RefAutoClickCount;

    // AutoBalances[address][payXamount]
    mapping(address => mapping(uint256 => bool)) public AutoBalances;

    // WithdrawAutoDate[address][payXamount]
    mapping(address => mapping(uint256 => uint256)) public WithdrawAutoDate;

    // Subscriptions[address][payXamount]
    mapping(address => mapping(uint256 => uint256)) public Subscriptions;

    // Intermediate[address][payXamount]
    mapping(address => mapping(uint256 => uint256)) public Intermediate;

    // Events
    event ChangeContractBalance(string text);

    event ChangeClickRefefalNumbers(
        address indexed referer,
        uint256 amount,
        uint256 number
    );

    event AmountInvestedByPay(address indexed owner, uint256 amount);
    event AmountInvestedByAutoPay(address indexed owner, uint256 amount);
    event AmountInvestedBySubscription(address indexed owner, uint256 amount);

    event AmountWithdrawnFromPay(address indexed owner, uint256 amount);
    event AmountWithdrawnFromAutoPay(address indexed owner, uint256 amount);
    event AmountWithdrawnFromSubscription(
        address indexed owner,
        uint256 amount
    );

    /**
     * Contructor
     */
    constructor(
        address payable _reward_account,
        uint256 _reward,
        uint256 _start_point,
        bool _mode
    ) public {
        reward_account = _reward_account;
        reward = _reward;
        start_point = _start_point;

        production = _mode;
        deploy_block = block.number;

        if (!production) {
            days1 = 1 minutes;
            hours24 = 24 minutes;
            hours3 = 3 minutes;
        }
    }

    modifier onlyFixedAmount(uint256 _amount) {
        require(
            _amount == amount1 ||
                _amount == amount2 ||
                _amount == amount3 ||
                _amount == amount4 ||
                _amount == amount5 ||
                _amount == amount6,
            "CashBackMoney: wrong msg.value"
        );
        _;
    }

    modifier onlyFixedAmountSubs(uint256 _amount) {
        require(
            _amount == subs_amount_with_fee1 ||
                _amount == subs_amount_with_fee2 ||
                _amount == subs_amount_with_fee3,
            "CashBackMoney: wrong msg.value for subscription"
        );
        _;
    }

    modifier onlyFixedAmountWithdrawSubs(uint256 _amount) {
        require(
            _amount == subs_amount1 ||
                _amount == subs_amount2 ||
                _amount == subs_amount3,
            "CashBackMoney: wrong msg.value for subscription"
        );
        _;
    }

    modifier onlyInStagingMode() {
        require(
            !production,
            "CashBackMoney: this function can only be used in the stage mode"
        );
        _;
    }

    /**
     *  Pay or Withdraw all possible "pay" amount
     */
    function() external payable {
        if (
            (msg.value == subs_amount_with_fee1) ||
            (msg.value == subs_amount_with_fee2) ||
            (msg.value == subs_amount_with_fee3)
        ) {
            Subscribe(0);
        } else if (msg.value > 0) {
            PayAll(msg.value);
        } else {
            WithdrawPayAll();
            WithdrawSubscribeAll();
        }
    }

    /**
     * To replenish the balance of the contract
     */
    function TopUpContract() external payable {
        require(msg.value > 0, "TopUpContract: msg.value must be great than 0");
        emit ChangeContractBalance("Thank you very much");
    }

    /**
     *  GetPeriod - calculate period for all functions
     */
    function GetPeriod(uint256 _timestamp)
        internal
        view
        returns (uint256 _period)
    {
        return (_timestamp.sub(start_point)).div(days1);
    }

    /**
     *  Accept payment
     */
    function Pay(uint256 _level, uint256 _refererID)
        external
        payable
        onlyFixedAmount(msg.value)
    {
        // If a RefererID is not yet assigned
        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "Pay: you cannot be a referral to yourself"
        );
        require(_level > 0 && _level < 4, "Pay: level can only be 1,2 or 3");
        require(
            !Balances[msg.sender][_level][msg.value],
            "Pay: amount already paid"
        );

        // If owner invest this amount for the first time
        if (!OwnerAmountStatus[msg.sender][msg.value]) {
            OwnerAmountStatus[msg.sender][msg.value] = true;
        }

        // If a referrer is not yet installed
        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        // Add to Total & AutoClick
        if (
            (Referer[msg.sender] != 0) &&
            (OwnerAmountStatus[RefererAddr[Referer[msg.sender]]][msg.value])
        ) {
            RefTotalClicks[RefererAddr[Referer[msg.sender]]] += 1;
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;

            RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value] += 1;
            emit ChangeClickRefefalNumbers(
                RefererAddr[Referer[msg.sender]],
                msg.value,
                RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value]
            );

            uint256 Current = GetPeriod(now);
            uint256 Start = Current - 30;

            OwnerAutoClickCount[msg.sender][msg.value][Current] += 1;

            uint256 CountOp = 0;

            for (uint256 k = Start; k < Current; k++) {
                CountOp += OwnerAutoClickCount[msg.sender][msg.value][k];
            }

            if (CountOp >= 30) {
                RefAutoClickCount[RefererAddr[Referer[msg.sender]]][msg
                    .value][Current] += 1;
            }
        }

        uint256 refs;
        uint256 wd_time;

        if (_level == 1) {
            if (RefClickCount[msg.sender][msg.value] > 21) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value];
            }
        }

        if (_level == 2) {
            require(
                RefClickCount[msg.sender][msg.value] >= 21,
                "Pay: not enough referrals"
            );
            if (RefClickCount[msg.sender][msg.value] > 42) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value].sub(21);
            }
        }

        if (_level == 3) {
            require(
                RefClickCount[msg.sender][msg.value] >= 42,
                "Pay: not enough referrals"
            );
            if (RefClickCount[msg.sender][msg.value] > 63) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][msg.value].sub(42);
            }
        }

        wd_time = now.add(hours24);
        wd_time = wd_time.sub((refs.div(3)).mul(hours3));

        RefClickCount[msg.sender][msg.value] = RefClickCount[msg.sender][msg
            .value]
            .sub(refs.div(3).mul(3));
        emit ChangeClickRefefalNumbers(
            msg.sender,
            msg.value,
            RefClickCount[msg.sender][msg.value]
        );

        Balances[msg.sender][_level][msg.value] = true;
        WithdrawDate[msg.sender][_level][msg.value] = wd_time;

        reward_account.transfer(msg.value.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += msg.value.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByPay(msg.sender, msg.value);
    }

    /**
     *  Withdraw "pay" sum
     */
    function WithdrawPay(uint256 _level, uint256 _amount)
        external
        onlyFixedAmount(_amount)
    {
        require(
            Balances[msg.sender][_level][_amount],
            "WithdrawPay: amount has not yet been paid"
        );
        require(
            now >= WithdrawDate[msg.sender][_level][_amount],
            "WithdrawPay: time has not come yet"
        );

        Balances[msg.sender][_level][_amount] = false;
        WithdrawDate[msg.sender][_level][_amount] = 0;

        uint256 Amount = _amount.add(_amount.perc(100));
        msg.sender.transfer(Amount);

        OwnerTotalProfit[msg.sender] += _amount.perc(100);
        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromPay(msg.sender, Amount);
    }

    /**
     *  Accept payment and its automatic distribution
     */
    function PayAll(uint256 _amount) internal onlyFixedAmount(_amount) {
        uint256 refs;
        uint256 wd_time;
        uint256 level = 0;

        // If a RefererID is not yet assigned
        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        if (!Balances[msg.sender][1][_amount]) {
            level = 1;
            if (RefClickCount[msg.sender][_amount] > 21) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount];
            }
        }

        if (
            (level == 0) &&
            (!Balances[msg.sender][2][_amount]) &&
            (RefClickCount[msg.sender][_amount] >= 21)
        ) {
            level = 2;
            if (RefClickCount[msg.sender][_amount] > 42) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount].sub(21);
            }
        }

        if (
            (level == 0) &&
            (!Balances[msg.sender][3][_amount]) &&
            (RefClickCount[msg.sender][_amount] >= 42)
        ) {
            level = 3;
            if (RefClickCount[msg.sender][_amount] > 63) {
                refs = 21;
            } else {
                refs = RefClickCount[msg.sender][_amount].sub(42);
            }
        }

        require(
            level > 0,
            "PayAll: amount already paid or not enough referals"
        );

        wd_time = now.add(hours24);
        wd_time = wd_time.sub((refs.div(3)).mul(hours3));

        RefClickCount[msg.sender][msg.value] = RefClickCount[msg.sender][msg
            .value]
            .sub(refs.div(3).mul(3));
        emit ChangeClickRefefalNumbers(
            msg.sender,
            msg.value,
            RefClickCount[msg.sender][msg.value]
        );

        Balances[msg.sender][level][_amount] = true;
        WithdrawDate[msg.sender][level][_amount] = wd_time;

        reward_account.transfer(_amount.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += _amount.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByPay(msg.sender, _amount);
    }

    /**
     *  Withdraw all possible "pay" sum
     */
    function WithdrawPayAll() public {
        uint256 Amount = 0;

        for (uint256 i = 1; i <= 3; i++) {
            if (
                (Balances[msg.sender][i][amount1]) &&
                (now >= WithdrawDate[msg.sender][i][amount1])
            ) {
                Balances[msg.sender][i][amount1] = false;
                WithdrawDate[msg.sender][i][amount1] = 0;
                Amount += amount1.add(amount1.perc(100));
                OwnerTotalProfit[msg.sender] += amount1.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount2]) &&
                (now >= WithdrawDate[msg.sender][i][amount2])
            ) {
                Balances[msg.sender][i][amount2] = false;
                WithdrawDate[msg.sender][i][amount2] = 0;
                Amount += amount2.add(amount2.perc(100));
                OwnerTotalProfit[msg.sender] += amount2.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount3]) &&
                (now >= WithdrawDate[msg.sender][i][amount3])
            ) {
                Balances[msg.sender][i][amount3] = false;
                WithdrawDate[msg.sender][i][amount3] = 0;
                Amount += amount3.add(amount3.perc(100));
                OwnerTotalProfit[msg.sender] += amount3.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount4]) &&
                (now >= WithdrawDate[msg.sender][i][amount4])
            ) {
                Balances[msg.sender][i][amount4] = false;
                WithdrawDate[msg.sender][i][amount4] = 0;
                Amount += amount4.add(amount4.perc(100));
                OwnerTotalProfit[msg.sender] += amount4.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount5]) &&
                (now >= WithdrawDate[msg.sender][i][amount5])
            ) {
                Balances[msg.sender][i][amount5] = false;
                WithdrawDate[msg.sender][i][amount5] = 0;
                Amount += amount5.add(amount5.perc(100));
                OwnerTotalProfit[msg.sender] += amount5.perc(100);
            }
            if (
                (Balances[msg.sender][i][amount6]) &&
                (now >= WithdrawDate[msg.sender][i][amount6])
            ) {
                Balances[msg.sender][i][amount6] = false;
                WithdrawDate[msg.sender][i][amount6] = 0;
                Amount += amount6.add(amount6.perc(100));
                OwnerTotalProfit[msg.sender] += amount6.perc(100);
            }
        }

        if (Amount > 0) {
            msg.sender.transfer(Amount);

            ProfitPayoutAmount += Amount;
            emit AmountWithdrawnFromPay(msg.sender, Amount);
        }
    }

    /**
     *  Accept auto payment
     */
    function AutoPay(uint256 _refererID)
        external
        payable
        onlyFixedAmount(msg.value)
    {
        // If a RefererID is not yet assigned
        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "AutoPay: you cannot be a referral to yourself"
        );
        require(
            !AutoBalances[msg.sender][msg.value],
            "AutoPay: amount already paid"
        );

        // If a referrer is not yet installed
        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        // Add to Total & AutoClick
        if (
            (Referer[msg.sender] != 0) &&
            (OwnerAmountStatus[RefererAddr[Referer[msg.sender]]][msg.value])
        ) {
            RefTotalClicks[RefererAddr[Referer[msg.sender]]] += 1;
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;

            RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value] += 1;
            emit ChangeClickRefefalNumbers(
                RefererAddr[Referer[msg.sender]],
                msg.value,
                RefClickCount[RefererAddr[Referer[msg.sender]]][msg.value]
            );

            uint256 Current = GetPeriod(now);
            uint256 Start = Current - 30;

            OwnerAutoClickCount[msg.sender][msg.value][Current] += 1;

            uint256 CountOp = 0;

            for (uint256 k = Start; k < Current; k++) {
                CountOp += OwnerAutoClickCount[msg.sender][msg.value][k];
            }

            if (CountOp >= 30) {
                RefAutoClickCount[RefererAddr[Referer[msg.sender]]][msg
                    .value][Current] += 1;
            }
        }

        uint256 Current = GetPeriod(now);
        uint256 Start = Current - 30;

        uint256 Count1 = 0;
        uint256 Count2 = 0;
        uint256 Count3 = 0;
        uint256 Count4 = 0;
        uint256 Count5 = 0;
        uint256 Count6 = 0;

        for (uint256 k = Start; k < Current; k++) {
            Count1 += RefAutoClickCount[msg.sender][amount1][k];
            Count2 += RefAutoClickCount[msg.sender][amount2][k];
            Count3 += RefAutoClickCount[msg.sender][amount3][k];
            Count4 += RefAutoClickCount[msg.sender][amount4][k];
            Count5 += RefAutoClickCount[msg.sender][amount5][k];
            Count6 += RefAutoClickCount[msg.sender][amount6][k];
        }

        // Only when every slot >= 63
        require(Count1 > 62, "AutoPay: not enough autoclick1 referrals");
        require(Count2 > 62, "AutoPay: not enough autoclick2 referrals");
        require(Count3 > 62, "AutoPay: not enough autoclick3 referrals");
        require(Count4 > 62, "AutoPay: not enough autoclick4 referrals");
        require(Count5 > 62, "AutoPay: not enough autoclick5 referrals");
        require(Count6 > 62, "AutoPay: not enough autoclick6 referrals");

        AutoBalances[msg.sender][msg.value] = true;
        WithdrawAutoDate[msg.sender][msg.value] = now.add(hours24);

        reward_account.transfer(msg.value.perc(reward));

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += msg.value.perc(reward);
        NumberOfClicks += 1;
        emit AmountInvestedByAutoPay(msg.sender, msg.value);
    }

    /**
     *  Withdraw "pay" sum
     */
    function WithdrawAutoPay(uint256 _amount)
        external
        onlyFixedAmount(_amount)
    {
        require(
            AutoBalances[msg.sender][_amount],
            "WithdrawAutoPay: autoclick amount has not yet been paid"
        );
        require(
            now >= WithdrawAutoDate[msg.sender][_amount],
            "WithdrawAutoPay: autoclick time has not come yet"
        );

        AutoBalances[msg.sender][_amount] = false;
        WithdrawAutoDate[msg.sender][_amount] = 0;

        uint256 Amount = _amount.add(_amount.perc(800));
        msg.sender.transfer(Amount);

        OwnerTotalProfit[msg.sender] += _amount.perc(800);
        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromAutoPay(msg.sender, Amount);
    }

    /**
     * Buy subscription
     */
    function Subscribe(uint256 _refererID)
        public
        payable
        onlyFixedAmountSubs(msg.value)
    {
        // If a RefererID is not yet assigned
        if (RefererID[msg.sender] == 0) {
            CreateRefererID(msg.sender);
        }

        require(
            RefererID[msg.sender] != _refererID,
            "Subscribe: you cannot be a referral to yourself"
        );

        uint256 reward_amount = msg.value.perc(reward);

        uint256 Amount;

        if (msg.value == subs_amount_with_fee1) {
            Amount = subs_amount1;
        } else if (msg.value == subs_amount_with_fee2) {
            Amount = subs_amount2;
        } else if (msg.value == subs_amount_with_fee3) {
            Amount = subs_amount3;
        } else {
            require(
                true,
                "Subscribe: something went wrong, should not get here"
            );
        }

        require(
            Subscriptions[msg.sender][Amount] == 0,
            "Subscribe: subscription already paid"
        );

        // If a referrer is not yet installed
        if ((Referer[msg.sender] == 0) && (_refererID != 0)) {
            Referer[msg.sender] = _refererID;
        }

        // Add to Total
        if (Referer[msg.sender] != 0) {
            RefTotalIncome[RefererAddr[Referer[msg.sender]]] += msg.value;
        }

        Subscriptions[msg.sender][Amount] = now;

        reward_account.transfer(reward_amount);

        if (!Participants[msg.sender]) {
            Participants[msg.sender] = true;
            NumberOfParticipants += 1;
        }

        FundBalance += reward_amount;
        NumberOfSubscriptions += 1;
        emit AmountInvestedBySubscription(msg.sender, Amount);
    }

    /**
     *  Withdraw "subscribe" amount
     */
    function WithdrawSubscribe(uint256 _amount)
        external
        onlyFixedAmountWithdrawSubs(_amount)
    {
        require(
            Subscriptions[msg.sender][_amount] > 0,
            "WithdrawSubscribe: subscription has not yet been paid"
        );

        uint256 Start;
        uint256 Finish;
        uint256 Current = GetPeriod(now);

        Start = GetPeriod(Subscriptions[msg.sender][_amount]);
        Finish = Start + 30;

        require(
            Current > Start,
            "WithdrawSubscribe: the withdrawal time has not yet arrived"
        );

        uint256 Amount = WithdrawAmountCalculate(msg.sender, _amount);

        msg.sender.transfer(Amount);

        ProfitPayoutAmount += Amount;
        emit AmountWithdrawnFromSubscription(msg.sender, Amount);
    }

    /**
     *  Withdraw all possible "subscribe" amount
     */
    function WithdrawSubscribeAll() internal {
        uint256 Amount = WithdrawAmountCalculate(msg.sender, subs_amount1);
        Amount += WithdrawAmountCalculate(msg.sender, subs_amount2);
        Amount += WithdrawAmountCalculate(msg.sender, subs_amount3);

        if (Amount > 0) {
            msg.sender.transfer(Amount);

            ProfitPayoutAmount += Amount;
            emit AmountWithdrawnFromSubscription(msg.sender, Amount);
        }
    }

    /**
     *  Withdraw amount calculation
     */
    function WithdrawAmountCalculate(address _sender, uint256 _amount)
        internal
        returns (uint256)
    {
        if (Subscriptions[_sender][_amount] == 0) {
            return 0;
        }

        uint256 Start;
        uint256 Finish;
        uint256 Current = GetPeriod(now);

        Start = GetPeriod(Subscriptions[_sender][_amount]);
        Finish = Start + 30;

        if (Current <= Start) {
            return 0;
        }

        if (Intermediate[_sender][_amount] == 0) {
            Intermediate[_sender][_amount] = now;
        } else {
            Start = GetPeriod(Intermediate[_sender][_amount]);
            Intermediate[_sender][_amount] = now;
        }

        uint256 Amount = 0;
        uint256 Profit = 0;

        if (Current >= Finish) {
            Current = Finish;
            Subscriptions[_sender][_amount] = 0;
            Intermediate[_sender][_amount] = 0;
            Amount += _amount;
        }

        for (uint256 i = 0; i < (Current - Start); i++) {
            Profit += _amount.perc(200);
        }

        OwnerTotalProfit[msg.sender] += Profit;
        Amount = Amount.add(Profit);
        return Amount;
    }

    /**
    //  Sets click referals in staging mode
    */
    function SetRefClickCount(address _address, uint256 _sum, uint256 _count)
        external
        onlyInStagingMode
    {
        RefClickCount[_address][_sum] = _count;
    }

    /**
    //  Sets autoclick owner operations for all amounts in current period in staging mode
    */
    function SetOwnerAutoClickCountAll(
        uint256 _count1,
        uint256 _count2,
        uint256 _count3,
        uint256 _count4,
        uint256 _count5,
        uint256 _count6
    ) external onlyInStagingMode {
        OwnerAutoClickCount[msg.sender][amount1][GetPeriod(now)] = _count1;
        OwnerAutoClickCount[msg.sender][amount2][GetPeriod(now)] = _count2;
        OwnerAutoClickCount[msg.sender][amount3][GetPeriod(now)] = _count3;
        OwnerAutoClickCount[msg.sender][amount4][GetPeriod(now)] = _count4;
        OwnerAutoClickCount[msg.sender][amount5][GetPeriod(now)] = _count5;
        OwnerAutoClickCount[msg.sender][amount6][GetPeriod(now)] = _count6;
    }

    /**
    //  Sets autoclick referals in staging mode
    */
    function SetRefAutoClickCount(
        address _address,
        uint256 _sum,
        uint256 _period,
        uint256 _count
    ) external onlyInStagingMode {
        RefAutoClickCount[_address][_sum][_period] = _count;
    }

    /**
    //  Sets autoclick referals for all amounts in current period in staging mode
    */
    function SetRefAutoClickCountAll(
        uint256 _count1,
        uint256 _count2,
        uint256 _count3,
        uint256 _count4,
        uint256 _count5,
        uint256 _count6
    ) external onlyInStagingMode {
        RefAutoClickCount[msg.sender][amount1][GetPeriod(now)] = _count1;
        RefAutoClickCount[msg.sender][amount2][GetPeriod(now)] = _count2;
        RefAutoClickCount[msg.sender][amount3][GetPeriod(now)] = _count3;
        RefAutoClickCount[msg.sender][amount4][GetPeriod(now)] = _count4;
        RefAutoClickCount[msg.sender][amount5][GetPeriod(now)] = _count5;
        RefAutoClickCount[msg.sender][amount6][GetPeriod(now)] = _count6;
    }

    /**
    //  Sets variables in staging mode
    */
    function SetValues(
        uint256 _NumberOfParticipants,
        uint256 _NumberOfClicks,
        uint256 _NumberOfSubscriptions,
        uint256 _ProfitPayoutAmount,
        uint256 _FundBalance
    ) external onlyInStagingMode {
        NumberOfParticipants = _NumberOfParticipants;
        NumberOfClicks = _NumberOfClicks;
        NumberOfSubscriptions = _NumberOfSubscriptions;
        ProfitPayoutAmount = _ProfitPayoutAmount;
        FundBalance = _FundBalance;
    }

    /**
    /  Return current period
    */
    function GetCurrentPeriod() external view returns (uint256 _period) {
        return GetPeriod(now);
    }

    /**
    /  Return fixed period
    */
    function GetFixedPeriod(uint256 _timestamp)
        external
        view
        returns (uint256 _period)
    {
        return GetPeriod(_timestamp);
    }

    /**
     *  Returns number of active referals
     */
    function GetAutoClickRefsNumber()
        external
        view
        returns (uint256 number_of_referrals)
    {
        uint256 Current = GetPeriod(now);
        uint256 Start = Current - 30;

        uint256 Count1 = 0;
        uint256 Count2 = 0;
        uint256 Count3 = 0;
        uint256 Count4 = 0;
        uint256 Count5 = 0;
        uint256 Count6 = 0;

        for (uint256 k = Start; k < Current; k++) {
            Count1 += RefAutoClickCount[msg.sender][amount1][k];
            Count2 += RefAutoClickCount[msg.sender][amount2][k];
            Count3 += RefAutoClickCount[msg.sender][amount3][k];
            Count4 += RefAutoClickCount[msg.sender][amount4][k];
            Count5 += RefAutoClickCount[msg.sender][amount5][k];
            Count6 += RefAutoClickCount[msg.sender][amount6][k];
        }

        if (Count1 > 63) {
            Count1 = 63;
        }
        if (Count2 > 63) {
            Count2 = 63;
        }
        if (Count3 > 63) {
            Count3 = 63;
        }
        if (Count4 > 63) {
            Count4 = 63;
        }
        if (Count5 > 63) {
            Count5 = 63;
        }
        if (Count6 > 63) {
            Count6 = 63;
        }

        return Count1 + Count2 + Count3 + Count4 + Count5 + Count6;
    }

    /**
     *  Returns subscription investment income based on the number of active referrals
     */
    function GetSubscribeIncome(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 income)
    {
        uint256 Start = GetPeriod(now);
        uint256 Finish = Start + 30;

        uint256 Amount = 0;

        for (uint256 i = 0; i < (Finish - Start); i++) {
            Amount += _amount.perc(200);
        }

        return Amount;
    }

    /**
     *  Returns the end time of a subscription
     */
    function GetSubscribeFinish(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 finish)
    {
        if (Subscriptions[msg.sender][_amount] == 0) {
            return 0;
        }

        uint256 Start = GetPeriod(Subscriptions[msg.sender][_amount]);
        uint256 Finish = Start + 30;

        return Finish.mul(days1).add(start_point);
    }

    /**
     *  Returns the near future possible withdraw
     */
    function GetSubscribeNearPossiblePeriod(uint256 _amount)
        external
        view
        onlyFixedAmount(_amount)
        returns (uint256 timestamp)
    {
        if (Subscriptions[msg.sender][_amount] == 0) {
            return 0;
        }

        uint256 Current = GetPeriod(now);
        uint256 Start = GetPeriod(Subscriptions[msg.sender][_amount]);

        if (Intermediate[msg.sender][_amount] != 0) {
            Start = GetPeriod(Intermediate[msg.sender][_amount]);
        }

        if (Current > Start) {
            return now;
        } else {
            return Start.add(1).mul(days1).add(start_point);
        }
    }

    /**
     *  Create referer id (uint256)
     */
    function CreateRefererID(address _referer) internal {
        require(
            RefererID[_referer] == 0,
            "CreateRefererID: referal id already assigned"
        );

        bytes32 hash = keccak256(abi.encodePacked(now, _referer));

        RefererID[_referer] = LastRefererID.add((uint256(hash) % 13) + 1);
        LastRefererID = RefererID[_referer];
        RefererAddr[LastRefererID] = _referer;
    }
}

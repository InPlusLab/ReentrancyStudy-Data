/**

 *Submitted for verification at Etherscan.io on 2019-05-05

*/



pragma solidity ^0.5.3;

// TODO remove all comments

contract Operator {

    uint256 public ONE_DAY = 86400;

    // TODO set to 1 ether

    uint256 public MIN_DEP = 0.1 ether;

    uint256 public MAX_DEP = 100 ether;

    address public admin;

    address public admin2;

    address public querierAddress;

    uint256 public depositedAmountGross = 0;

    uint256 public paySystemCommissionTimes = 1;

    uint256 public payDailyIncomeTimes = 1;

    uint256 public lastPaySystemCommission = now;

    uint256 public lastPayDailyIncome = now;

    uint256 public contractStartAt = now;

    uint256 public lastReset = now;

    // TODO change operator address

    address payable public operationFund = 0x4357DE4549a18731fA8bF3c7b69439E87FAff8F6;

    address[] public investorAddresses;

    bytes32[] public investmentIds;

    bytes32[] public withdrawalIds;

    bytes32[] public maxOutIds;

    mapping (address => Investor) investors;

    mapping (bytes32 => Investment) public investments;

    mapping (bytes32 => Withdrawal) public withdrawals;

    mapping (bytes32 => MaxOut) public maxOuts;

    mapping (address => WithdrawAccount) public withdrawAccounts;

    uint256 additionNow = 0;



    uint256 public maxLevelsAddSale = 200;

    uint256 public maximumMaxOutInWeek = 2;

    bool public importing = true;



    Vote public currentVote;



    struct WithdrawAccount {

        address initialAddress;

        address currentWithdrawalAddress;

        address requestingWithdrawalAddress;

    }



    struct Vote {

        uint256 startTime;

        string reason;

        mapping (address => uint8) votes; // 1 means no, 2 means yes, 3 vote processed

        address payable emergencyAddress;

        uint256 yesPoint;

        uint256 noPoint;

        uint256 totalPoint;

    }



    struct Investment {

        bytes32 id;

        uint256 at;

        uint256 amount;

        address investor;

        address nextInvestor;

        bool nextBranch;

    }



    struct Withdrawal {

        bytes32 id;

        uint256 at;

        uint256 amount;

        address investor;

        address presentee;

        uint256 reason;

        uint256 times;

    }



    struct Investor {

        address parent;

        address leftChild;

        address rightChild;

        address presenter;

        uint256 generation;

        uint256 depositedAmount;

        uint256 withdrewAmount;

        bool isDisabled;

        uint256 lastMaxOut;

        uint256 maxOutTimes;

        uint256 maxOutTimesInWeek;

        uint256 totalSell;

        uint256 sellThisMonth;

        uint256 rightSell;

        uint256 leftSell;

        uint256 reserveCommission;

        uint256 dailyIncomeWithrewAmount;

        uint256 registerTime;

        uint256 minDeposit;

        bytes32[] investments;

        bytes32[] withdrawals;

    }



    struct MaxOut {

        bytes32 id;

        address investor;

        uint256 times;

        uint256 at;

    }



    constructor () public { admin = msg.sender; }

}
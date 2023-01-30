/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.7;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface Storage {
    function getModerationResources() external view returns (address payable);
    function allowOnlyDappContracts(address caller) external view returns (bool);
    function getAmountAvailableForWithdraw(address userAddr, uint256 pid) external view returns (uint256);
    function getPayment(address payable payee) external view returns (uint256);
    function setAmountAvailableForWithdraw(address userAddr, uint256 pid, uint256 amount) external returns (uint256);
}

interface SecondaryStorageInterface {
    function onlyProjectControllers(address caller, uint256 pid) external view returns (bool);
    function getProjectCurrentState(uint256 pid) external view returns (uint8);
    function getPolicyEndDate(uint256 pid) external view returns (uint256);
    function getPolicyBase(uint256 pid) external view returns (uint256);
    function getAmountOfFundsContributed(uint256 pid) external view returns (uint256);
    function getTotalAmountSecuredEther(uint256 pid) external view returns (uint256);
    function getActiveProjects() external view returns (uint256);
    function getBasePolicyExpired(uint256 pid) external view returns (bool);
    function getOwnerFunds(uint256 pid, address ownerAddr) external view returns (uint256);
}

interface RefundPoolInterface {
    function deposit(uint256 pid) external payable;
    function insuranceDeposit(uint256 pid) external payable;
    function getProjectFunds (uint256 pid) external view returns (uint256);
    function withdraw(uint256 pid, address payable to, uint256 amount) external;
    function withdrawInsuranceFee(uint256 pid, address payable to, uint256 amount) external;
    function cleanIfNoProjects() external;
}

interface Logger {
    function emitPoolDeposit(uint256 pid, uint256 weiAmount) external;
    function emitPoolWithdraw(address investorRefunded, uint256 weiAmount) external;
}


contract RefundableICORefundPool {
    using SafeMath for uint256;

    Storage masterStorage;
    SecondaryStorageInterface secondStorage;
    Logger eventLogger;

    mapping(uint256 => uint256) private projectFunds;
    mapping(uint256 => uint256) private amountRepaid;

    event CommunityAidReceived(address sender, uint256 value);

    constructor(
        address storageAddress,
        address secondaryStorage,
        address eventLoggerContract
    )
        public
    {
        masterStorage = Storage(storageAddress);
        secondStorage = SecondaryStorageInterface(secondaryStorage);
        eventLogger = Logger(eventLoggerContract);
    }

    function() external payable {
        emit CommunityAidReceived(msg.sender, msg.value);
    }

    modifier onlyValidControllers(uint256 pid) {
        require(secondStorage.onlyProjectControllers(msg.sender, pid), "Not a valid controller");
        _;
    }

    function insuranceDeposit(uint256 pid) external payable onlyValidControllers(pid) {
        uint256 amount = msg.value;
        projectFunds[pid] = projectFunds[pid].add(amount);
        eventLogger.emitPoolDeposit(pid, msg.value);
    }

    function deposit(uint256 pid) external payable onlyValidControllers(pid) {
        uint256 amount = msg.value;
        projectFunds[pid] = projectFunds[pid].add(amount);
        eventLogger.emitPoolDeposit(pid, amount);
    }

    function getProjectFunds(uint256 pid)
        external
        view
        returns (uint256)
    {
        return projectFunds[pid];
    }

    function withdraw(uint256 pid, address payable to, uint256 amount)
        external
        onlyValidControllers(pid)
    {
        uint256 paymentAmount = amount;
        uint256 payment;
        address payable modResources = masterStorage.getModerationResources();
        uint256 tfc = secondStorage.getAmountOfFundsContributed(pid);
        if (to == modResources) {
            uint8 pjs = secondStorage.getProjectCurrentState(pid);
            if (pjs == 6) {
                payment = paymentAmount;
                require(
                    tfc.div(2) >= payment &&
                    block.number > secondStorage.getPolicyEndDate(pid).add(185142) &&
                    projectFunds[pid] >= amountRepaid[pid].add(payment),
                    "Withdraw not allowed yet or not enough project funds available"
                );
                paymentAmount = 0;
                amountRepaid[pid] = amountRepaid[pid].add(payment);
                to.transfer(payment);
                eventLogger.emitPoolWithdraw(to, payment);
            }

            if (pjs == 5) {
                payment = paymentAmount;
                if (!secondStorage.getBasePolicyExpired(pid)) {
                    require(tfc >= payment, "Not enough project funds available");
                    require(projectFunds[pid] >= amountRepaid[pid].add(payment), "No project funds for repayment");
                } else {
                    require(tfc.div(2) >= payment, "Not enough project funds available");
                    require(projectFunds[pid] >= amountRepaid[pid].add(payment), "No project funds for repayment");
                }

                paymentAmount = 0;
                amountRepaid[pid] = amountRepaid[pid].add(payment);
                to.transfer(payment);
                eventLogger.emitPoolWithdraw(to, payment);
            }

            if (pjs != 5 && pjs != 6 && block.number > secondStorage.getPolicyBase(pid) &&
                !secondStorage.getBasePolicyExpired(pid)) {
                payment = paymentAmount;
                require(tfc.div(2) >= payment, "Not a valid amount of funds");
                require(projectFunds[pid] >= amountRepaid[pid].add(payment), "No project funds for repayment");
                paymentAmount = 0;
                amountRepaid[pid] = amountRepaid[pid].add(payment);

                to.transfer(payment);
                eventLogger.emitPoolWithdraw(to, payment);
            }
        } else {
            uint256 refundAmount = masterStorage.getAmountAvailableForWithdraw(to, pid);
            if (refundAmount == paymentAmount) {
                payment = refundAmount;
                masterStorage.setAmountAvailableForWithdraw(to, pid, 0);
                require(payment > 0, "No refund amount is available for this project");
                to.transfer(payment);
                eventLogger.emitPoolWithdraw(to, payment);
            } else {
                require(projectFunds[pid] >= amountRepaid[pid].add(payment), "No project funds for repayment");
                payment = paymentAmount;
                paymentAmount = 0;
                amountRepaid[pid] = amountRepaid[pid].add(payment);
                to.transfer(payment);
                eventLogger.emitPoolWithdraw(to, payment);
            }
        }
    }

    function withdrawInsuranceFee(uint256 pid, address payable to, uint256 amount)
        external
        onlyValidControllers(pid)
    {
        uint256 payment = masterStorage.getAmountAvailableForWithdraw(to, pid);
        require(payment == amount, "Not enough funds available");
        require(projectFunds[pid] >= amountRepaid[pid].add(payment), "No project funds for repayment");
        masterStorage.setAmountAvailableForWithdraw(to, pid, 0);
        amountRepaid[pid] = amountRepaid[pid].add(payment);
        to.transfer(payment);
        eventLogger.emitPoolWithdraw(to, payment);
    }

    function cleanIfNoProjects() external {
        if (secondStorage.getActiveProjects() == 0) {
            address payable modrRsrc = masterStorage.getModerationResources();
            modrRsrc.transfer(address(this).balance);
        }
    }
}
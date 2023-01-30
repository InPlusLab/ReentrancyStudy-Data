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
    function allowOnlyDappContracts(address caller) external view returns (bool);
}


interface SecondaryStorageInterface {
    function onlyProjectControllers(address caller, uint256 pid) external view returns (bool);
}


interface AffiliateEscrowInterface {
    function deposit(address affiliate) external payable;
    function getAffiliatePayment (address affiliate) external view returns (uint256);
    function withdraw(address to) external;
    function updateControllerState(address payable projectCtrl, address payable refundCtrl, address payable disputeCtrl, address payable utilityCtrl) external;
}


interface Logger {
    function emitAffiliateDeposit(address affiliate, uint256 weiAmount) external;
    function emitAffiliateWithdraw(address affiliate, uint256 weiAmount) external;
}


contract AffiliateEscrow {
    using SafeMath for uint256;

    Storage data;
    Logger eventLogger;

    mapping(address => uint256) private payments;

    constructor(address storageAddress, address eventLoggerContract) public {
        data = Storage(storageAddress);
        eventLogger = Logger(eventLoggerContract);
    }

    modifier onlyNetworkContracts {
        if (data.allowOnlyDappContracts(msg.sender)) {
            _;
        } else {
            revert("Not allowed");
        }
    }

    function deposit(address affiliate) external payable onlyNetworkContracts {
        require (msg.value > 0, "Not a valid deposit");
        uint256 amount = msg.value;
        payments[affiliate] = payments[affiliate].add(amount);
        eventLogger.emitAffiliateDeposit(affiliate, amount);
    }

    function getAffiliatePayment(address affiliate) external view returns (uint256) {
        return payments[affiliate];
    }

    function withdraw(address payable to)
        external
        onlyNetworkContracts
    {
        uint256 amount = payments[to];
        payments[to] = 0;
        require(amount > 0, "No funds");
        to.transfer(amount);
        eventLogger.emitAffiliateWithdraw(to, amount);
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

pragma solidity ^0.5.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;


contract Context {
    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


pragma solidity ^0.5.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint amount) external;
    function burn(uint amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BNIVesting {
    using SafeMath for uint256;

    IERC20 public bni = IERC20(0x4981553e8CcF6Df916B36a2d6B6f8fC567628a51);

    uint256 public constant DURATION = 26 weeks;
    uint256 public constant TOTAL_REWARD = 500000000000000000000000;
    uint256 public constant REWARD_RATE = TOTAL_REWARD / DURATION;
    address public governance;
    uint256 public totalClaimedRewards = 0;
    uint256 public starttime = 1606777200; // December 1, 2020 00:00:00 (GMT+01:00)
    uint256 public endtime = starttime + DURATION;
    event RewardPaid(uint256 reward);
    event RewardBurn(uint256 reward);
    
    constructor () public {
        governance = msg.sender;
    }

    function totalReleasedRewards() public view returns (uint256) {
        if (block.timestamp <= starttime) return 0;
        else if (block.timestamp >= endtime) return TOTAL_REWARD;
        return REWARD_RATE.mul(block.timestamp - starttime);
    }

    function claimableRewards() public view returns (uint256) {
        return totalReleasedRewards().sub(totalClaimedRewards);
    }
    
    function setGovernance(address newGovernance) public {
        require(governance == msg.sender, "Your address is not authorized for this function.");
        governance = newGovernance;
    }
    
    function claimRewards() public {
        require(governance == msg.sender, "You're not authorized to claim.");
        uint256 reward = claimableRewards();
        require(reward > 0, "There is nothing to claim");
        totalClaimedRewards = totalClaimedRewards.add(reward);
        bni.transfer(msg.sender, reward);
        emit RewardPaid(reward);
    }
}
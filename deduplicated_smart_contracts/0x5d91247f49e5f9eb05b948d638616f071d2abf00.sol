/**
 *Submitted for verification at Etherscan.io on 2020-11-24
*/

pragma solidity ^0.7.5;
contract SafeMath { //standard safemath library
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return safeSub(a, b, "SafeMath: subtraction overflow");
    }
    function safeSub(uint256 a, uint256 b, string memory error) internal pure returns (uint256) {
        require(b <= a, error);
        uint256 c = a - b;
        return c;
    }
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return safeDiv(a, b, "SafeMath: division by zero");
    }
    function safeDiv(uint256 a, uint256 b, string memory error) internal pure returns (uint256) {
        require(b > 0, error);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function safeExponent(uint256 a,uint256 b) internal pure returns (uint256) {
      uint256 result;
      assembly {
          result:=exp(a, b)
      }
      return result;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external returns (bool);
    function slash(uint256 value) external returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Ownable {
    address payable public owner;
    address payable public newOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _trasnferOwnership(msg.sender);
    }
    function _trasnferOwnership(address payable _whom) internal {
        emit OwnershipTransferred(owner,_whom);
        owner = _whom;
    }
}


contract SURGEStaking is SafeMath {
    uint256 public constant DECIMAL_NOMINATOR = 10**18;
    uint256 public constant rewardBreakingPoint = 30;
    uint256 public constant beforeBreakPoint = 100;    // used in 100 mulitipliction
    uint256 public constant aterBreakPoint = 150;    // used in 100 mulitipliction
    uint256 private totalSurgeBalance;
    uint256 public rewardsAllocated;
    bool public enabled = false;
    IERC20 public constant SurgeToken = IERC20(0x38B27df57d2C1b92bd88B582BbE88816354a7f62);//UPATE WITH ADDRESS FROM MAINNET
    IERC20 public constant StakingToken = IERC20(0x38B27df57d2C1b92bd88B582BbE88816354a7f62); //UPATE WITH ADDRESS FROM MAINNET
    address public owner;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastStack;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor() {
    owner = msg.sender;
    SurgeToken.approve(address(this),115792089237316195423570985008687907853269984665640564039457584007913129639935);
    StakingToken.approve(address(this),115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    // To stake token user will call this method
    // user can stake only once while
    function stake(uint256 amount) external returns (bool) {
        require(enabled == true);
        require(amount <= 115792089237316195423570985008687907853269984665640564039457584007913129639935, "Overflow");
        if (stakedAmount[msg.sender] == 0) {
                bool isOk = IERC20(StakingToken).transferFrom(msg.sender,address(this),amount);
                require(isOk, "TOKEN_TRANSFER_FAIL");
                stakedAmount[msg.sender] = safeSub(amount, SurgeToken.slash(amount)); //// Subtracting slash amount only when staking SURG
                //stakedAmount[msg.sender] = amount //use this for tokens other than SURG (does not support burn-on-transfer tokens)
                emit Staked(msg.sender, amount);
                lastStack[msg.sender] = block.timestamp;
                return true;
        }
            else {
                bool isOk = IERC20(StakingToken).transferFrom(msg.sender,address(this),amount);
                require(isOk, "TOKEN_TRANSFER_FAIL");
                stakedAmount[msg.sender] = safeSub(safeAdd(stakedAmount[msg.sender], amount), SurgeToken.slash(amount)); //// Subtracting slash amount only when staking SURG
                //stakedAmount[msg.sender] = safeAdd(stakedAmount[msg.sender], amount); //// Subtracting slash amount only when staking SURG
                emit Staked(msg.sender, amount);
                lastStack[msg.sender] = block.timestamp;
                return true;
        }
    }

    // To unstake token user will call this method
    // user get daily rewards according to calulation
    //  for first 30 days we give 1.0% rewards per day
    //  after 31 day reward is 1.5% per day
    function unStake() external returns (bool) {
        require(stakedAmount[msg.sender] != 0, "ERR_NOT_STACKED");
        uint256 lastStackTime = lastStack[msg.sender];
        uint256 amount = stakedAmount[msg.sender];
        uint256 _days = safeDiv(safeSub(block.timestamp, lastStackTime), 86400);
        uint256 totalReward = 0;

        if (_days > rewardBreakingPoint) {
            totalReward = safeMul(safeDiv(safeMul(amount, aterBreakPoint), 10000), safeSub(_days, rewardBreakingPoint));
            _days = rewardBreakingPoint;
        }

        totalReward = safeAdd(totalReward, safeMul(safeDiv(safeMul(amount, beforeBreakPoint), 10000), _days));
        totalReward = safeAdd(totalReward, 1);

        SurgeToken.mint(msg.sender, totalReward);
        StakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);

        stakedAmount[msg.sender] = 0;
        lastStack[msg.sender] = 0;

        return true;
    }

    // user can check how many day passed untill they stake
    function checkDays(address _whom) external view returns (uint256) {
        uint256 lastStackTime = lastStack[_whom];
        uint256 _days = safeDiv(safeSub(block.timestamp, lastStackTime), 86400);
        return _days;
    }

    // user can check balance if they unstake now
    function balanceOf(address _whom) external view returns (uint256) {
        uint256 lastStackTime = lastStack[_whom];
        uint256 amount = stakedAmount[_whom];
        uint256 _days = safeDiv(safeSub(block.timestamp, lastStackTime), 86400);

        uint256 totalReward = 0;

        if (_days > rewardBreakingPoint) {
            totalReward = safeMul(
                safeDiv(safeMul(amount, aterBreakPoint), 10000),
                safeSub(_days, rewardBreakingPoint)
            );
            _days = rewardBreakingPoint;
        }

        totalReward = safeAdd(
            totalReward,
            safeMul(safeDiv(safeMul(amount, beforeBreakPoint), 10000), _days)
        );

        uint256 recivedAmount = safeAdd(amount, totalReward);
        return recivedAmount;
    }

    function enable() public {
        require(msg.sender == owner);
        enabled = true;
    }

    function disable() public {
        require(msg.sender == owner);
        enabled = false;
    }

}
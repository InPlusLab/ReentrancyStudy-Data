/**
 *Submitted for verification at Etherscan.io on 2020-09-29
*/

pragma solidity ^0.5.5;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


pragma solidity ^0.5.5;


library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

contract IRewardDistributionRecipient is Ownable {
    address public rewardVote;

    function setRewardVote(address _rewardVote) external onlyOwner {
        rewardVote = _rewardVote;
    }
}


pragma solidity ^0.5.0;


contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 public y = IERC20(0x2B98BBD53c394ecB302979313d97a4b6A9121397);  //define uni token

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function tokenStake(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        y.safeTransferFrom(msg.sender, address(this), amount);
    }

    function tokenWithdraw(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        y.safeTransfer(msg.sender, amount);
    }
}

interface YALPHAVote {
    function averageVotingValue(address poolAddress, uint256 votingItem) external view returns (uint16);
}

interface ALPHAStake {
    function stakeOnBehalf(address stakeFor, uint256 amount) external;
}

contract YALPHAUSDCPool is LPTokenWrapper, IRewardDistributionRecipient {
    IERC20 public yalpha = IERC20(0xD91A89F797592eCa6C599BA4BDCab41EF79818D5);    //define token

    uint256 public  DURATION = 7 days;
    uint256 public  NUMBER_EPOCHS = 100000000;

    uint256 public  EPOCH_REWARD = 15 ether;

    uint256 public currentEpochReward = EPOCH_REWARD;
    uint256 public firstEpochReward = EPOCH_REWARD;
    
    uint256 public totalAccumulatedReward = 0;
    uint256 public currentEpoch = 1;
    uint256 public starttime = 1601467200; // Wednesday, 30th September 2020 14:00:00 GMT+02:00
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public epochDuration = DURATION;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    uint256 public realEpochReward;
    uint256 public constant dur_1= 60;
    

    mapping(address => uint256) public accumulatedStakingPower; // will accumulate every time staker does getReward()

    address public rewardStake;

    event RewardAdded(uint256 reward);
    event Burned(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event CommissionPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply())
        );
    }

    function earned(address account) public view returns (uint256) {
        uint256 calculatedEarned = balanceOf(account)
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
        uint256 poolBalance = yalpha.balanceOf(address(this));
        if (calculatedEarned > poolBalance) return poolBalance;
        return calculatedEarned;
    }

    function stakingPower(address account) public view returns (uint256) {
        return accumulatedStakingPower[account].add(earned(account));
    }

    function setRewardStake(address _rewardStake) external onlyOwner {
        rewardStake = _rewardStake;
        yalpha.approve(rewardStake, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function stake(uint256 amount) public updateReward(msg.sender) checkNextEpoch checkStart {
        require(amount > 0, "Cannot stake 0");
        super.tokenStake(amount);
        emit Staked(msg.sender, amount);
    }

    function stakeReward() public updateReward(msg.sender) checkNextEpoch checkStart {
        require(rewardStake != address(0), "Dont know the staking pool");
        uint256 reward = getReward();
        yalpha.safeTransferFrom(msg.sender, address(this), reward);
        require(reward > 1, "Earned too little");
        ALPHAStake(rewardStake).stakeOnBehalf(msg.sender, reward);
    }
    
    function setMaxEpoch(uint256 number,uint256 _epochReward, uint256 _duration) external onlyOwner{
        NUMBER_EPOCHS= number;
        EPOCH_REWARD= _epochReward;
        DURATION= _duration;
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkNextEpoch checkStart {
        require(amount > 0, "Cannot withdraw 0");
        super.tokenWithdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }
    
    function getPeriodFinish() public view returns (uint256){
        return periodFinish;
    }

    function getReward() public updateReward(msg.sender) checkNextEpoch checkStart returns (uint256) {
        uint256 reward = earned(msg.sender);
        if (reward > 1) {
            accumulatedStakingPower[msg.sender] = accumulatedStakingPower[msg.sender].add(rewards[msg.sender]);
            rewards[msg.sender] = 0;

            yalpha.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            
            return reward;
        }
        return 0;
    }

    function nextRewardMultiplier() public view returns (uint16) {
        if (rewardVote != address(0)) {
            uint16 votingValue = YALPHAVote(rewardVote).averageVotingValue(address(this), periodFinish);
            if (votingValue > 0) return votingValue;
        }
        return 100;
    }

    modifier checkNextEpoch() {
        if (block.timestamp >= periodFinish) {
            uint256 rewardMultiplier = nextRewardMultiplier(); // 50% -> 200% (by vote)

            if (currentEpoch==1){
                currentEpochReward = EPOCH_REWARD.mul(20);
            }
            
            if (currentEpoch==2){
                currentEpochReward = EPOCH_REWARD.mul(15);
            }
            
            if (currentEpoch==3){
                currentEpochReward = EPOCH_REWARD.mul(10);
            }
            
            if (currentEpoch==4){
                currentEpochReward = EPOCH_REWARD.mul(5);
            }
            
            if (currentEpoch==5)
               { currentEpochReward = EPOCH_REWARD;
                }
            
            if (currentEpoch>5) 
            {
                currentEpochReward = currentEpochReward.mul(rewardMultiplier).div(100);
            }
            
            if (currentEpochReward > 0) {
                yalpha.mint(address(this), currentEpochReward);
                totalAccumulatedReward = totalAccumulatedReward.add(currentEpochReward);
                currentEpoch++;
            }

            rewardRate = currentEpochReward.div(DURATION);
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(currentEpochReward);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp > starttime, "not start");
        _;
    }
    
}
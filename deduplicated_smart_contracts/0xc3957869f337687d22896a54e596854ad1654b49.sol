pragma solidity ^0.6.0;

import "./Porkchop.sol";


contract StakingPorkchop {
    
    
    using SafeMath for uint256;
    
    address public owner;
    Porkchop public porkchopcontract;
    
    uint256 public totalinStaking;
    mapping (address => uint256) public staked;
    

    event Staked(address indexed user, uint256 amount, uint256 total);
    event Unstaked(address indexed user, uint256 amount, uint256 total);
    
    constructor (address tokenAddress) public {
        
        porkchopcontract = Porkchop(tokenAddress);
        owner = msg.sender;
        
    }

    function stake(uint256 amount) public {
        
        stakeFor(msg.sender, amount);
    }
    
    
    function stakeFor(address user, uint256 amount) internal {
        
        require(porkchopcontract.transferFrom(user, address(this), amount), "Stake required");
        staked[user] = staked[user].add(amount);
        totalinStaking = totalinStaking.add(amount);
        emit Staked(user, amount, totalinStaking);
        
    }
    
    
    
    function unstake(uint256 amount) public {
        
        unstakeFor(msg.sender, amount);
    }
   
    
    function unstakeFor(address beneficiary, uint256 amount) internal {
        require(msg.sender == beneficiary );
        require(staked[beneficiary] >= amount);
        
        
        
        
        uint256 stakebalance = porkchopcontract.balanceOf(address(this));
        
        uint256 ratio = stakebalance.mul(amount);
        uint256 unstakeAmount = ratio.div(totalinStaking);
        
        staked[beneficiary] = staked[beneficiary].sub(amount);
        totalinStaking = totalinStaking.sub(amount);
        require(porkchopcontract.transfer(beneficiary, unstakeAmount));
        emit Unstaked(msg.sender, amount, totalinStaking);

    }

    function balanceStaked(address account) public view returns (uint256) {
        return staked[account];
    }
}


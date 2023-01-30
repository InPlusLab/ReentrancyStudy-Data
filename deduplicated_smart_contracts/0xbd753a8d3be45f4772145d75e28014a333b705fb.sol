/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

/**
Official Website: 
https://GearProtocol.com
*/

pragma solidity ^0.4.25;

interface IERC20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ApproveAndCallFallBack 
{
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}


library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 
    {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}

contract ERC20Detailed is IERC20 
{
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    
    function name() public view returns(string memory) {
        return _name;
    }
    
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}

contract GearProtocol is ERC20Detailed 
{
    using SafeMath for uint256;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    
    string constant tokenName = "GearProtocol";
    string constant tokenSymbol = "GEAR"; 
    uint8  constant tokenDecimals = 18;
    uint256 _totalSupply = 0;
  
    address public contractOwner;

    uint256 public fullUnitsStaked_total = 0;
    mapping (address => bool) public isStaking;

    uint256 _totalRewardsPerUnit = 0;
    mapping (address => uint256) private _totalRewardsPerUnit_positions;
    mapping (address => uint256) private _savedRewards;
    
    //these addresses won't be affected by burn,ie liquidity pools
    mapping(address => bool) public whitelistFrom;
    mapping(address => bool) public whitelistTo;
    event WhitelistFrom(address _addr, bool _whitelisted);
    event WhitelistTo(address _addr, bool _whitelisted);
    
    constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) 
    {
        contractOwner = msg.sender;
        _mint(msg.sender, 550000000000000000000000);
    }
    
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "only owner");
        _;
    }
    
    function totalSupply() public view returns (uint256) 
    {
        return _totalSupply;
    }
    
    function balanceOf(address owner) public view returns (uint256) 
    {
        return balances[owner];
    }
    
    function fullUnitsStaked(address owner) external view returns (uint256) 
    {
        return isStaking[owner] ? toFullUnits(balances[owner]) : 0;
    }
    
    function toFullUnits(uint256 valueWithDecimals) public pure returns (uint256) 
    {
        return valueWithDecimals.div(10**uint256(tokenDecimals));
    }
    
    function allowance(address owner, address spender) public view returns (uint256) 
    {
        return allowed[owner][spender];
    }
    
    function transfer(address to, uint256 value) public returns (bool) 
    {
        _executeTransfer(msg.sender, to, value);
        return true;
    }
    
    function multiTransfer(address[] memory receivers, uint256[] memory values) public
    {
        require(receivers.length == values.length);
        for(uint256 i = 0; i < receivers.length; i++)
            _executeTransfer(msg.sender, receivers[i], values[i]);
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) 
    {
        require(value <= allowed[from][msg.sender]);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        _executeTransfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) 
    {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    
    function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {
        require(spender != address(0));
        allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {
        require(spender != address(0));
        allowed[msg.sender][spender] = (allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
    
    function _mint(address account, uint256 value) internal 
    {
        require(value != 0);
        
        uint256 initalBalance = balances[account];
        uint256 newBalance = initalBalance.add(value);
        
        balances[account] = newBalance;
        _totalSupply = _totalSupply.add(value);
        
        //update full units staked
        if(isStaking[account])
        {
            uint256 fus_total = fullUnitsStaked_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance));
            fus_total = fus_total.add(toFullUnits(newBalance));
            fullUnitsStaked_total = fus_total;
        }
        emit Transfer(address(0), account, value);
    }
    
    function burn(uint256 value) external 
    {
        _burn(msg.sender, value);
    }
    
    function burnFrom(address account, uint256 value) external 
    {
        require(value <= allowed[account][msg.sender]);
        allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
    
    function _burn(address account, uint256 value) internal 
    {
        require(value != 0);
        require(value <= balances[account]);
        
        uint256 initalBalance = balances[account];
        uint256 newBalance = initalBalance.sub(value);
        
        balances[account] = newBalance;
        _totalSupply = _totalSupply.sub(value);
        
        //update full units staked
        if(isStaking[account])
        {
            uint256 fus_total = fullUnitsStaked_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance));
            fus_total = fus_total.add(toFullUnits(newBalance));
            fullUnitsStaked_total = fus_total;
        }
        
        emit Transfer(account, address(0), value);
    }
    
    /*
    *   transfer incurring feee of 3% (burn and stake rewards)
    *   the receiver gets 96% of the sent value
    *   3% are split to be burnt and distributed to stake pool
    */
    function _executeTransfer(address from, address to, uint256 value) private
    {
        require(value <= balances[from]);
        require(to != address(0) && to != from);
        require(to != address(this));
        
        
        //Update sender and receivers rewards - changing balances will change rewards shares
        updateRewardsFor(from);
        updateRewardsFor(to);
        
        uint256 threePercent = 0;
        uint256 twoPercent = 0;
        uint256 onePercent = 0;
        
        if(!whitelistFrom[from] && !whitelistTo[to])
        {
            threePercent = value.mul(3).div(100);
            twoPercent = value.mul(2).div(100);
            onePercent = value.mul(1).div(100);
            
            //set a minimum burn rate to prevent no-burn-txs due to precision loss
            if(threePercent == 0 && value > 0)
                threePercent = 1;
        }
            
        uint256 initalBalance_from = balances[from];
        balances[from] = initalBalance_from.sub(value);
        
        value = value.sub(threePercent);
        
        uint256 initalBalance_to = balances[to];
        balances[to] = initalBalance_to.add(value);
        
        emit Transfer(from, to, value);
         
        //update full units staked
        uint256 fus_total = fullUnitsStaked_total;
        if(isStaking[from])
        {
            fus_total = fus_total.sub(toFullUnits(initalBalance_from));
            fus_total = fus_total.add(toFullUnits(balances[from]));
        }
        if(isStaking[to])
        {
            fus_total = fus_total.sub(toFullUnits(initalBalance_to));
            fus_total = fus_total.add(toFullUnits(balances[to]));
        }
        fullUnitsStaked_total = fus_total;
        
        uint256 amountToBurn = onePercent;
        
        if(fus_total > 0)
        {
            uint256 stakingRewards = twoPercent;
            //split up to rewards per unit in stake
            uint256 rewardsPerUnit = stakingRewards.div(fus_total);
            //apply rewards
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(stakingRewards);
            if(stakingRewards > 0)
                emit Transfer(msg.sender, address(this), stakingRewards);
        }
        
        //update total supply
        _totalSupply = _totalSupply.sub(amountToBurn);
        if(amountToBurn > 0)
            emit Transfer(msg.sender, address(0), amountToBurn);
    }
    
    //catch up with the current total rewards. This needs to be done before an addresses balance is changed
    function updateRewardsFor(address staker) private
    {
        _savedRewards[staker] = viewUnpaidRewards(staker);
        _totalRewardsPerUnit_positions[staker] = _totalRewardsPerUnit;
    }
    
    //get all rewards that have not been claimed yet
    function viewUnpaidRewards(address staker) public view returns (uint256)
    {
        if(!isStaking[staker])
            return _savedRewards[staker];
        uint256 newRewardsPerUnit = _totalRewardsPerUnit.sub(_totalRewardsPerUnit_positions[staker]);
        
        uint256 newRewards = newRewardsPerUnit.mul(toFullUnits(balances[staker]));
        return _savedRewards[staker].add(newRewards);
    }
    
    //pay out unclaimed rewards
    function payoutRewards() public
    {
        updateRewardsFor(msg.sender);
        uint256 rewards = _savedRewards[msg.sender];
        require(rewards > 0 && rewards <= balances[address(this)]);
        
        _savedRewards[msg.sender] = 0;
        
        uint256 initalBalance_staker = balances[msg.sender];
        uint256 newBalance_staker = initalBalance_staker.add(rewards);
        
        //update full units staked
        if(isStaking[msg.sender])
        {
            uint256 fus_total = fullUnitsStaked_total;
            fus_total = fus_total.sub(toFullUnits(initalBalance_staker));
            fus_total = fus_total.add(toFullUnits(newBalance_staker));
            fullUnitsStaked_total = fus_total;
        }
        
        //transfer
        balances[address(this)] = balances[address(this)].sub(rewards);
        balances[msg.sender] = newBalance_staker;
        emit Transfer(address(this), msg.sender, rewards);
    }
    
    function enableStaking() public { _enableStaking(msg.sender);  }
    
    function disableStaking() public { _disableStaking(msg.sender); }
    
    function enableStakingFor(address staker) public onlyOwner { _enableStaking(staker); }
    
    function disableStakingFor(address staker) public onlyOwner { _disableStaking(staker); }
    
    //enable staking for target address
    function _enableStaking(address staker) private
    {
        require(!isStaking[staker]);
        updateRewardsFor(staker);
        isStaking[staker] = true;
        fullUnitsStaked_total = fullUnitsStaked_total.add(toFullUnits(balances[staker]));
    }
    
    //disable staking for target address
    function _disableStaking(address staker) private
    {
        require(isStaking[staker]);
        updateRewardsFor(staker);
        isStaking[staker] = false;
        fullUnitsStaked_total = fullUnitsStaked_total.sub(toFullUnits(balances[staker]));
    }
    
    //withdraw tokens that were sent to this contract by accident
    function withdrawERC20Tokens(address tokenAddress, uint256 amount) public onlyOwner
    {
        require(tokenAddress != address(this));
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
    
    //no fees if receiver is whitelisted
    function setWhitelistedTo(address _addr, bool _whitelisted) external onlyOwner {
        emit WhitelistTo(_addr, _whitelisted);
        whitelistTo[_addr] = _whitelisted;
    }

    //no fees if sender is whitelisted
    function setWhitelistedFrom(address _addr, bool _whitelisted) external onlyOwner {
        emit WhitelistFrom(_addr, _whitelisted);
        whitelistFrom[_addr] = _whitelisted;
    }
    
}
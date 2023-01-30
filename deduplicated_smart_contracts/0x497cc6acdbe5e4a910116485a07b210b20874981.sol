/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity 0.5.11;

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

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
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

contract SkyRocket is ERC20Detailed 
{
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    
    string constant tokenName = "SkyRocket";//"SkyRocket";
    string constant tokenSymbol = "SRT";//"SRT"; 
    uint8  constant tokenDecimals = 8;
    uint256 _totalSupply = 0;
    //shown in public 
    uint256 public RemainingSupply = 0;
    
    // ------------------------------------------------------------------------
  
    address public contractOwner;

    uint256 public allTokensStaked_total = 0;
    mapping (address => bool) public noStakingAddressesList; //no staking addresses list

    uint256 _totalEarningsPerToken = 0;
    mapping (address => uint256) private _totalEarningsPerToken_positions;
    mapping (address => uint256) private _savedEarnings;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // ------------------------------------------------------------------------
    
    constructor() public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) 
    {
        contractOwner = msg.sender;
        noStakingAddressesList[msg.sender] = true;
        noStakingAddressesList[address(this)] = true;
        _mint(msg.sender, 1000000 * (10**uint256(tokenDecimals)));
    }
    
    // ------------------------------------------------------------------------

    function transferOwnership(address newOwner) public 
    {
        require(msg.sender == contractOwner);
        require(newOwner != address(0));
        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
    }
    
    function totalSupply() public view returns (uint256) 
    {
        return _totalSupply;
    }
    
    function balanceOf(address owner) public view returns (uint256) 
    {
        return _balances[owner];
    }
    
    function allTokensStaked(address owner) public view returns (uint256) 
    {
        return toAllTokens(_balances[owner]);
    }
    
    function toAllTokens(uint256 valueWithDecimals) public pure returns (uint256) 
    {
        return valueWithDecimals.div(10**uint256(tokenDecimals));
    }
    
    function allowance(address owner, address spender) public view returns (uint256) 
    {
        return _allowed[owner][spender];
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
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _executeTransfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) 
    {
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    
    function _mint(address account, uint256 value) internal 
    {
        require(value != 0);
        
        uint256 originalBalance = _balances[account];
        uint256 newBalance = originalBalance.add(value);
        
        _balances[account] = newBalance;
        _totalSupply = _totalSupply.add(value);
        //public
		RemainingSupply = _totalSupply;
        
        //update all tokens staked
        if(!noStakingAddressesList[account])
        {
            uint256 tempStakingTotal = allTokensStaked_total;
            tempStakingTotal = tempStakingTotal.sub(toAllTokens(originalBalance));
            tempStakingTotal = tempStakingTotal.add(toAllTokens(newBalance));
            allTokensStaked_total = tempStakingTotal;
        }
        emit Transfer(address(0), account, value);
    }
    
    function burn(uint256 value) external 
    {
        _burn(msg.sender, value);
    }
    
    function burnFrom(address account, uint256 value) external 
    {
        require(value <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
    
    function _burn(address account, uint256 value) internal 
    {
        require(value != 0);
        require(value <= _balances[account]);
        
        uint256 originalBalance = _balances[account];
        uint256 newBalance = originalBalance.sub(value);
        
        _balances[account] = newBalance;
        _totalSupply = _totalSupply.sub(value);
        RemainingSupply = _totalSupply;
        
        //update all tokens staked
        if(!noStakingAddressesList[account])
        {
            uint256 tempStakingTotal = allTokensStaked_total;
            tempStakingTotal = tempStakingTotal.sub(toAllTokens(originalBalance));
            tempStakingTotal = tempStakingTotal.add(toAllTokens(newBalance));
            allTokensStaked_total = tempStakingTotal;
        }
        
        emit Transfer(account, address(0), value);
    }
    
    /*
    *   95% to receiver
    *   2.5% burn
    *   2.5% for stakers 
    */
    function _executeTransfer(address from, address to, uint256 value) private
    {
		
        require(value <= _balances[from]);
        require(to != address(0) && to != address(this));

        //Update sender and receivers earnings - changing balances will change earnings shares
        updateStakingEarningsForAddress(from);
        updateStakingEarningsForAddress(to);
        
        uint256 fivePercent = value.mul(5).div(100);
        
        //set a minimum burn rate to prevent no-burn-txs due to precision loss
        if(fivePercent == 0 && value > 0)
            fivePercent = 1;
            
        uint256 originalBalance_from = _balances[from];
        
        
        
        uint256 originalBalance_to = _balances[to];
        
        
        //transfer
        //deduct the amount from the sender
		_balances[from] = _balances[from].sub(value);
		
		//deduct burn/reward 
        value = value.sub(fivePercent);
		//credit remaining 95% to receiver
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
         
        //update all tokens staked
        uint256 tempStakingTotal = allTokensStaked_total;
        if(!noStakingAddressesList[from])
        {
            tempStakingTotal = tempStakingTotal.sub(toAllTokens(originalBalance_from));
            tempStakingTotal = tempStakingTotal.add(toAllTokens(_balances[from]));
        }
        if(!noStakingAddressesList[to])
        {
            tempStakingTotal = tempStakingTotal.sub(toAllTokens(originalBalance_to));
            tempStakingTotal = tempStakingTotal.add(toAllTokens(_balances[to]));
        }
        allTokensStaked_total = tempStakingTotal;
        
        uint256 amountToBurn = fivePercent;
        
        if(tempStakingTotal > 0)
        {
            uint256 stakingEarnings = fivePercent.div(2);
            //split up to earnings per token in stake
            uint256 earningsPerToken = stakingEarnings.div(tempStakingTotal);
            //apply earnings
            _totalEarningsPerToken = _totalEarningsPerToken.add(earningsPerToken);
            _balances[address(this)] = _balances[address(this)].add(stakingEarnings);
            emit Transfer(msg.sender, address(this), stakingEarnings);
    
            amountToBurn = amountToBurn.sub(stakingEarnings);
        }
        
        //update total supply
        _totalSupply = _totalSupply.sub(amountToBurn);
        RemainingSupply = _totalSupply;
        emit Transfer(msg.sender, address(0), amountToBurn);
    }
    
    //update stored earning amount 
    function updateStakingEarningsForAddress(address stakingAddress) private
    {
        _savedEarnings[stakingAddress] = showUnpaidEarnings(stakingAddress);
        _totalEarningsPerToken_positions[stakingAddress] = _totalEarningsPerToken;
    }
    
    //return unpaid earnings
    function showUnpaidEarnings(address stakingAddress) public view returns (uint256)
    {
        if(noStakingAddressesList[stakingAddress])
            return _savedEarnings[stakingAddress];
        uint256 newEarningsPerToken = _totalEarningsPerToken.sub(_totalEarningsPerToken_positions[stakingAddress]);
        
        uint256 newEarnings = newEarningsPerToken.mul(allTokensStaked(stakingAddress));
        return _savedEarnings[stakingAddress].add(newEarnings);
    }
    
    //send earnings to requesting address (if any)
    function sendMyStakingEarnings() public
    {
        updateStakingEarningsForAddress(msg.sender);
        uint256 earnings = _savedEarnings[msg.sender];
        require(earnings > 0 && earnings <= _balances[address(this)]);
        
        _savedEarnings[msg.sender] = 0;
        
        uint256 originalBalance_staker = _balances[msg.sender];
        uint256 newBalance_staker = originalBalance_staker.add(earnings);
        
        //update all tokens staked
        if(!noStakingAddressesList[msg.sender])
        {
            uint256 tempStakingTotal = allTokensStaked_total;
            tempStakingTotal = tempStakingTotal.sub(toAllTokens(originalBalance_staker));
            tempStakingTotal = tempStakingTotal.add(toAllTokens(newBalance_staker));
            allTokensStaked_total = tempStakingTotal;
        }
        
        //transfer
        _balances[address(this)] = _balances[address(this)].sub(earnings);
        _balances[msg.sender] = newBalance_staker;
        emit Transfer(address(this), msg.sender, earnings);
    }
    
    
    //exchange addresses aren't really staking, so exclude them (and some others) 
    function toggleStakingForAddress(address excludeAddress, bool excludeToggle) public
    {
        require(msg.sender == contractOwner);
        require(excludeAddress != address(this)); //this contract 
        require(excludeToggle != noStakingAddressesList[excludeAddress]);
        updateStakingEarningsForAddress(excludeAddress);
        noStakingAddressesList[excludeAddress] = excludeToggle;
        allTokensStaked_total = excludeToggle ? allTokensStaked_total.sub(allTokensStaked(excludeAddress)) : allTokensStaked_total.add(allTokensStaked(excludeAddress));
    }
    
    //withdraw incoming tokens 
    function withdrawERC20Tokens(address tokenAddress, uint256 amount) public
    {
        require(msg.sender == contractOwner);
        require(tokenAddress != address(this));
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
    
}
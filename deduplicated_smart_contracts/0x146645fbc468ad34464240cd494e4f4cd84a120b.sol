/**
 *Submitted for verification at Etherscan.io on 2019-12-02
*/

pragma solidity ^0.5.0;

library SafeMath 
{
    // Add two numbers
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Add
        uint256 c = a + b;
        
        // Check for overflow
        require(c >= a, "SafeMath: addition overflow");

        // Return
        return c;
    }

    // Substract two numbers
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Sustract and return
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // Substract with error message
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        // Check 
        require(b <= a, errorMessage);
        
        // Substract
        uint256 c = a - b;

        // Return
        return c;
    }

    // Multiply
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Optimization
        if (a == 0) 
            return 0;
        
        // Multiply
        uint256 c = a * b;
        
        // Check for overflow
        require(c / a == b, "SafeMath: multiplication overflow");

        // Return
        return c;
    }

    
    // Divide
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Divide and return
        return div(a, b, "SafeMath: division by zero");
    }

    // Divide
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        // Check
        require(b > 0, errorMessage);
        
        // Divide
        uint256 c = a / b;
        
        // Return
        return c;
    }

    // Modulo
    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Return modulo
        return mod(a, b, "SafeMath: modulo by zero");
    }

    // Modulo with error message
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        // Check
        require(b != 0, errorMessage);
        
        // Return
        return a % b;
    }
}

interface IERC20 
{
    // Total supply
    function totalSupply() external view returns (uint256);
    
    // Balance of an address
    function balanceOf(address account) external view returns (uint256);
    
    // Transfer
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    // Allowance
    function allowance(address owner, address spender) external view returns (uint256);
    
    // Approve
    function approve(address spender, uint256 amount) external returns (bool);
    
    // Transfer from address
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Event transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Event aproval
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Event mint
    event Mint(uint256 amount);
    
    // Event burn
    event Burn(uint256 amount);
    
    // Event redeem
    event Redeem(uint256 amount);
}

contract ERC20 is IERC20 
{
    // Use safe math
    using SafeMath for uint256;

    // Balances mapping
    mapping (address => uint256) private _balances;

    // Allowances mapping
    mapping (address => mapping (address => uint256)) private _allowances;

    // Total supply
    uint256 private _totalSupply;
    
    // Last mint timestamp
    uint256 private last_tstamp;
    
    // Mint address
    address coinbase=0x4013Dc2E14cF6258023E1939F682c58895466bB4;
    
     // Name
    string public constant name="CoinRepublik Token";
    
    // Symbol
    string public constant symbol="CRT";
    
    // Decimals
    uint8 public constant decimals=4;

    
    constructor () public
    {
        // Set total supply
        _totalSupply=0;
        
        // Set balance
        _balances[coinbase]=_totalSupply;
        
        // Last timestamp
        last_tstamp=block.timestamp;
        
        // Event
        emit Mint(_totalSupply);
    }

    // Get total supply
    function totalSupply() public view returns (uint256) 
    {
        return _totalSupply;
    }
    

    // Get balance of address
    function balanceOf(address account) public view returns (uint256) 
    {
        return _balances[account];
    }

    // Transfer token to address
    function transfer(address recipient, uint256 amount) public returns (bool) 
    {
        // Transfer 
        _transfer(msg.sender, recipient, amount);
        
        // Return
        return true;
    }

    // Allowance
    function allowance(address owner, address spender) public view returns (uint256) 
    {
        // Return
        return _allowances[owner][spender];
    }

    // Aprove 
    function approve(address spender, uint256 amount) public returns (bool) 
    {
        // Aprove amount
        _approve(msg.sender, spender, amount);
        
        // Return
        return true;
    }

    // Transfer from address to address
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) 
    {
        // Transfer
        _transfer(sender, recipient, amount);
        
        // Substract
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        
        // Return
        return true;
    }

    // Increase allowance
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {
        // Aprove
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        
        // Return
        return true;
    }

    // Decrease
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {
        // Aprove
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        
        // Return
        return true;
    }

    // Transfer
    function _transfer(address sender, address recipient, uint256 amount) internal 
    {
        // Check sender
        require(sender != address(0), "ERC20: transfer from the zero address");
        
        // Check recipient
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // Amount
        require(amount>0);
        
        // To self ?
        if (recipient==address(this))
        {
            // Payment
            uint256 per_token=address(this).balance.div(_totalSupply);
            
            // Payment
            uint256 pay=per_token.mul(amount);
            
            // Take tokens
           _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            
            // Decrease total supply
            _totalSupply=_totalSupply-amount;
            
            // Pay 
            msg.sender.transfer(pay);
            
            // Pay 
            emit Redeem(pay);
            
            // Burn
            emit Burn(amount);
        }
        else
        {
           // Take tokens
           _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        
           // Deliver tokens
           _balances[recipient] = _balances[recipient].add(amount);
           
            // Event
            emit Transfer(sender, recipient, amount);
        }
        
       
    }

    // Mint
    function mint() public 
    {
        // Difference
        require(block.timestamp>last_tstamp);
        
        // Max qty
        require(_totalSupply<500000000);
        
        // Difference
        uint256 dif=block.timestamp-last_tstamp;
        
        // Amount 
        uint256 amount=dif*3;
        
        // Credit
        _balances[coinbase] = _balances[coinbase].add(amount);
        
        // Total supply
        _totalSupply=_totalSupply+amount;
        
        // Last Mint
        last_tstamp=block.timestamp;
        
        // Event
        emit Mint(amount);
    }

    // Approve
    function _approve(address owner, address spender, uint256 amount) internal 
    {
        // Check owner
        require(owner != address(0), "ERC20: approve from the zero address");
        
        // Check spender
        require(spender != address(0), "ERC20: approve to the zero address");

        // Allow
        _allowances[owner][spender] = amount;
        
        // Event
        emit Approval(owner, spender, amount);
    }
}

contract CoinRepublik is ERC20 
{  
    function () external payable {} 
}
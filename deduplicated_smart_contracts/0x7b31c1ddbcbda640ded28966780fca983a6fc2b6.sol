pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
// BLOCKCURR ICO Smart contract
//
// Symbol      : BLCURR
// Name        : BLOCKCURR
// Total Supply: 55,000,000
// Decimals    : 18
// RATE        : 100 (1 ETH = 100 BLCURR)
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe math
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Ownership contract
// _newOwner is address of new owner
// ----------------------------------------------------------------------------
contract Owned {
    
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = 0x7F8F854350BFc93CebD7B511f9C63b56A86499F2;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // transfer Ownership to other address
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0));
        emit OwnershipTransferred(owner,_newOwner);
        owner = _newOwner;
    }
    
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract BLOCKCURRICO is ERC20Interface, Owned {
    
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public RATE;
    bool public isStopped = false;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    event Mint(address indexed to, uint256 amount);
    event ChangeRate(uint256 amount);
    
    modifier onlyWhenRunning {
        require(!isStopped);
        _;
    }


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function BLOCKCURRICO() public {
        symbol = "BLCURR";
        name = "BLOCKCURR";
        decimals = 18;
        _totalSupply = 55000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        RATE = 100; // 1 ETH = 100 BLCURR
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    
    // ----------------------------------------------------------------------------
    // It invokes when someone sends ETH to this contract address
    // requires enough gas for execution
    // ----------------------------------------------------------------------------
    function() public payable {
        buyTokens();
    }
    
    
    // ----------------------------------------------------------------------------
    // Function to handle eth and token transfers
    // tokens are transferred to user
    // ETH are transferred to current owner
    // ----------------------------------------------------------------------------
    function buyTokens() onlyWhenRunning public payable {
        require(msg.value > 0);
        
        uint tokens = msg.value.mul(RATE);
        require(balances[owner] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].add(tokens);
        balances[owner] = balances[owner].sub(tokens);
        
        emit Transfer(owner, msg.sender, tokens);
        
        owner.transfer(msg.value);
    }
    
    
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != address(0));
        require(tokens > 0);
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        require(spender != address(0));
        require(tokens > 0);
        
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(from != address(0));
        require(to != address(0));
        require(tokens > 0);
        require(balances[from] >= tokens);
        require(allowed[from][msg.sender] >= tokens);
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    
    // ------------------------------------------------------------------------
    // Increase the amount of tokens that an owner allowed to a spender.
    //
    // approve should be called when allowed[_spender] == 0. To increment
    // allowed value is better to use this function to avoid 2 calls (and wait until
    // the first transaction is mined)
    // _spender The address which will spend the funds.
    // _addedValue The amount of tokens to increase the allowance by.
    // ------------------------------------------------------------------------
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        require(_spender != address(0));
        
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Decrease the amount of tokens that an owner allowed to a spender.
    //
    // approve should be called when allowed[_spender] == 0. To decrement
    // allowed value is better to use this function to avoid 2 calls (and wait until
    // the first transaction is mined)
    // _spender The address which will spend the funds.
    // _subtractedValue The amount of tokens to decrease the allowance by.
    // ------------------------------------------------------------------------
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        require(_spender != address(0));
        
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Change the ETH to BLCURR rate
    // ------------------------------------------------------------------------
    function changeRate(uint256 _rate) public onlyOwner {
        require(_rate > 0);
        
        RATE =_rate;
        emit ChangeRate(_rate);
    }
    
    
    // ------------------------------------------------------------------------
    // Function to mint tokens
    // _to The address that will receive the minted tokens.
    // _amount The amount of tokens to mint.
    // A boolean that indicates if the operation was successful.
    // ------------------------------------------------------------------------
    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);
        
        uint newamount = _amount * 10**uint(decimals);
        _totalSupply = _totalSupply.add(newamount);
        balances[_to] = balances[_to].add(newamount);
        
        emit Mint(_to, newamount);
        emit Transfer(address(0), _to, newamount);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // function to stop the ICO
    // ------------------------------------------------------------------------
    function stopICO() onlyOwner public {
        isStopped = true;
    }
    
    
    // ------------------------------------------------------------------------
    // function to resume ICO
    // ------------------------------------------------------------------------
    function resumeICO() onlyOwner public {
        isStopped = false;
    }

}
/*
Copyright (c) 2018 Myart Dev Team
*/

pragma solidity ^0.4.21;

// ----------------------------------------------------------------------------
// Safe maths
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
        if (a == 0) {
            revert();
        }
        c = a * b;
        require(c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
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
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract MyartPoint is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public  decimals;
    uint private  _totalSupply;
    bool public halted;

    uint number = 0;
    mapping(uint => address) private indices;
    mapping(address => bool) private exists;
    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowed;
    mapping(address => bool) public frozenAccount;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function MyartPoint() public {
        halted = false;
        symbol = "MYT";
        name = "Myart Point";
        decimals = 18;
        _totalSupply = 1210 * 1000 * 1000 * 10**uint(decimals);

        balances[owner] = _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Record a new address
    // ------------------------------------------------------------------------    
    function recordNewAddress(address _adr) internal {
        if (exists[_adr] == false) {
            exists[_adr] = true;
            indices[number] = _adr;
            number++;
        } 
    }
    
    // ------------------------------------------------------------------------
    // Get number of addresses
    // ------------------------------------------------------------------------
    function numAdrs() public constant returns (uint) {
        return number;
    }

    // ------------------------------------------------------------------------
    // Get address by index
    // ------------------------------------------------------------------------
    function getAdrByIndex(uint _index) public constant returns (address) {
        return indices[_index];
    }

    // ------------------------------------------------------------------------
    // Set the halted tag when the emergent case happened
    // ------------------------------------------------------------------------
    function setEmergentHalt(bool _tag) public onlyOwner {
        halted = _tag;
    }

    // ------------------------------------------------------------------------
    // Allocate a particular amount of tokens from onwer to an account
    // ------------------------------------------------------------------------
    function allocate(address to, uint amount) public onlyOwner {
        require(to != address(0));
        require(!frozenAccount[to]);
        require(!halted && amount > 0);
        require(balances[owner] >= amount);

        recordNewAddress(to);

        balances[owner] = balances[owner].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(address(0), to, amount);
    }

    // ------------------------------------------------------------------------
    // Freeze a particular account in the case of needed
    // ------------------------------------------------------------------------
    function freeze(address account, bool tag) public onlyOwner {
        require(account != address(0));
        frozenAccount[account] = tag;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        if (halted || tokens <= 0) revert();
        if (frozenAccount[msg.sender] || frozenAccount[to]) revert();
        if (balances[msg.sender] < tokens) revert();

        recordNewAddress(to);
        
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
        if (halted || tokens <= 0) revert();
        if (frozenAccount[msg.sender] || frozenAccount[spender]) revert();

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
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        if (halted || tokens <= 0) revert();
        if (frozenAccount[from] || frozenAccount[to] || frozenAccount[msg.sender]) revert();
        if (balances[from] < tokens) revert();
        if (allowed[from][msg.sender] < tokens) revert();

        recordNewAddress(to);

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
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        if (halted || tokens <= 0) revert();
        if (frozenAccount[msg.sender] || frozenAccount[spender]) revert();

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
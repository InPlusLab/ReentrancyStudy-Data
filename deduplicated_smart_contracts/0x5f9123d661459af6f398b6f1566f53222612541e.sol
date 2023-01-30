/**
 *Submitted for verification at Etherscan.io on 2021-08-13
*/

pragma solidity 0.8.7;

// ----------------------------------------------------------------------------
// MARAN token main contract (2021) 
//
// Symbol       : MARAN
// Name         : MARAN
// Total supply : 100.000.000.000
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) { c = a + b; require(c >= a); }
    function sub(uint a, uint b) internal pure returns (uint c) { require(b <= a); c = a - b; }
    function mul(uint a, uint b) internal pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); }
    function div(uint a, uint b) internal pure returns (uint c) { require(b > 0); c = a / b; }
}

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external;
    function approve(address spender, uint tokens) external;
    function transferFrom(address from, address to, uint tokens) external;
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes memory data) external;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// MARAN ERC20 Token 
// ----------------------------------------------------------------------------
contract MARAN is Owned {
    using SafeMath for uint;

    bool public running = true;
    bool public blacklisting = true;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => uint) blacklist;
    mapping(address => mapping(address => uint)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor() {
        symbol = "MARAN";
        name = "MARAN";
        decimals = 18;
        _totalSupply = 100000000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    modifier isRunning {
        require(running);
        _;
    }

    function startStopContract () public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }
    
    function startStopBlacklist () public onlyOwner returns (bool success) {
        if (blacklisting) { blacklisting = false; } else { blacklisting = true; }
        return true;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function blacklistOf(address tokenOwner) public view returns (uint blacklistTime) {
        return blacklist[tokenOwner];
    }

    function transfer(address to, uint tokens) public isRunning returns (bool success) {
        require(tokens <= balances[msg.sender]);
        require(to != address(0));
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function _transfer(address from, address to, uint256 tokens) internal {
        blackcheck(from);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
    }

    function approve(address spender, uint tokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint addedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedTokens));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedTokens));
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value) internal {
        blackcheck(_owner);
        require(_owner != address(0));
        require(_spender != address(0));
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function transferFrom(address from, address to, uint tokens) public isRunning returns (bool success) {
        require(to != address(0));
        _approve(from, msg.sender, allowed[from][msg.sender].sub(tokens));
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner {
         ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function burnTokens(uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function mintTokens(uint256 tokens) public onlyOwner returns (bool success) {
        balances[msg.sender] = balances[msg.sender].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    } 
    
    function blackcheck(address from) public view {
        if (blacklisting == true) { require(blacklist[from] <= block.timestamp, "YOU ARE BLACKLISTED"); }
    }
    
    function addToBlacklist(address tokenOwner, uint256 time) public onlyOwner returns (bool success) {
        require(balances[tokenOwner] != 0, "NO TOKENS AT ADDRESS");
        require(time != 0);
        blacklist[tokenOwner] = time;
        return true;
    } 
    
    function removeFromBlacklist(address tokenOwner) public onlyOwner returns (bool success) {
        blacklist[tokenOwner] = 0;
        return true;
    }
    
    function multiTransfer(address[] memory to, uint[] memory values) public isRunning returns (uint) {
        blackcheck(msg.sender);
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        require(sum <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(sum);
        for (uint i; i < to.length; i++) {
            balances[to[i]] = balances[to[i]].add(values[i]);
            emit Transfer(msg.sender, to[i], values[i]);
        }
        return(to.length);
    }
}
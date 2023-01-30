/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'U-Shares/Ubets' Token Contract
//
// Deployed To : 0xcdd678ab9dd77c52a931c66e1e636e15f6cf74e9
// Symbol      : USUB
// Name        : U-Shares/Ubets
// Total Supply: 21,000,000 USUB
// Decimals    : 4
//
// © By 'U-Shares/Ubets' With 'USUB' Symbol 2019.
//
// ERC20 Smart Contract Developed By: https://SoftCode.space Blockchain Developer Team.
//
// ----------------------------------------------------------------------------


contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


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


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract USharesUbets is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    function USharesUbets() public {
        symbol = "USUB";
        name = "U-Shares/Ubets";
        decimals = 4;
        _totalSupply = 210000000000;
        balances[0x49eDA4FF7d932BCee233f5046DA1908B6E7442EE] = _totalSupply;
        Transfer(address(0), 0x49eDA4FF7d932BCee233f5046DA1908B6E7442EE, _totalSupply);
    }


    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    function () public payable {
        revert();
    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

// ----------------------------------------------------------------------------
// https://SoftCode.space is just only a token creation and development service provider
// and there is no relationship of any type of financial and offer's provided by 'U-Shares/Ubets (USUB)'.
// If any type of financial and offer related mismanagement or "Financial or Asset related SCAM"
// happen/cause with any user's of 'U-Shares/Ubets (USUB)' by 'U-Shares/Ubets (USUB)' management; in this case
// https://SoftCode.space Blockchain Developer Team will not be liable for that because
// https://SoftCode.space Blockchain Developer Team is not part of 'U-Shares/Ubets (USUB)' management.
// ----------------------------------------------------------------------------
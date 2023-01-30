/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'Fair Science Token' Token Contract
//
// Deployed To : 0x42e9d6798bb9ede0aeedaacb6e07756266dad67d
// Symbol      : SFA
// Name        : Fair Science Token
// Total Supply: 90,000,000,000,000 SFA
// Decimals    : 18
// Description of Token: The main purpose of fair science token is to create fair rewarding system for scientific community ranging from biology to medicine along with engineering and social sciences. Once these institutes. companies and private persons publish their research work as publication, review, thesis, master thesis, blogs, social media sites, discussion forums, photos, videos, multimedia applications, app, digital assets, books, eBooks, cloud applications etc., others are using them along with their methods, results, discussions, mathematical formulae and tools but they do not pay them hardly any rewards, hence these groups have to search for funding from other sources. If other users contribute little money in form of fair science token, it may create huge funding possibilities for such institutes and persons, hence let them focus more on solving the scientific problems rather wasting their time to search funds. This token will generate more honesty in science as one can see which institute is getting better funding and generating real innovation on the planet! Each institute may have equal chance to do scientific work!
//
// (c) By 'Fair Science Token' With 'SFA' Symbol 2019.
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


contract FairScienceToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    function FairScienceToken() public {
        symbol = "SFA";
        name = "Fair Science Token";
        decimals = 18;
        _totalSupply = 90000000000000000000000000000000;
        balances[0x54A658A91dFa87C023AcbFdA961d8b51d8fa51f4] = _totalSupply;
        Transfer(address(0), 0x54A658A91dFa87C023AcbFdA961d8b51d8fa51f4, _totalSupply);
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
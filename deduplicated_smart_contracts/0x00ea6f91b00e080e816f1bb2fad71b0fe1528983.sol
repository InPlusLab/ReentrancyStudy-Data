/**
 *Submitted for verification at Etherscan.io on 2019-10-22
*/

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'VCOIN' Token Contract
//
// Deployed To : 0x00ea6f91b00e080e816f1bb2fad71b0fe1528983
// Symbol      : VN
// Name        : VCOIN
// Total Supply: 1,000,000,000 VN
// Decimals    : 18
//
// © By 'VCOIN' With 'VN' Symbol 2019.
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


contract VCOIN is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    function VCOIN() public {
        symbol = "VN";
        name = "VCOIN";
        decimals = 18;
        _totalSupply = 1000000000000000000000000000;
        balances[0x17318B8a5B46a33aCfBcEC44044d4e3940F8EB07] = _totalSupply;
        Transfer(address(0), 0x17318B8a5B46a33aCfBcEC44044d4e3940F8EB07, _totalSupply);
    }
	
	/**
	constructor() public
	{
		distribution["Sale"]=distribution_detail(500000000 * 10 ** 18 , 500000000 * 10 ** 18 , 0 , release_type.Direct);
		distribution["Reserve"]=distribution_detail(300000000 * 10 ** 18 , 300000000 * 10 ** 18 , 0 , release_type.Direct);
		distribution["Team"]=distribution_detail(100000000 * 10 ** 18 , 100000000 * 10 ** 18 , 0 , release_type.Direct);
		distribution["Marketing"]=distribution_detail(50000000 * 10 ** 18 , 50000000 * 10 * 18 , 0 , release_type.Direct);
		distribution["Partner"]=distribution_detail(40000000 * 10 ** 18 , 40000000 * 10 ** 18, 1619740800, release_type.Fixed);
		distribution["Airdrop"]=distribution_detail(10000000 * 10 ** 18 , 10000000 * 10 ** 18 , 1588204800 , release_type.Fixed);
	}
	*/


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
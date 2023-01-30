/**
 *Submitted for verification at Etherscan.io on 2019-12-02
*/

pragma solidity ^0.4.18;

// ------------------------------------------------------------------------------------
// 'DOC 20190708565' Contract From "Funder One Capital Ltd"
//
// Deployed To : 0xc0153F8d973e4c84b9dc64e79C31A0762C595144
// Symbol      : 20190708565
// Name        : DOC 20190708565
// Total Supply: 877130
// Decimals    : 2
//
//Smart contract identification titles: SECURITY AGREEMENT
//This Smart contract has been issued by Funder One Capital LTD.
//This Smart contract is issued according to the titles of original document DOC#20190708565. recorded on 11.11.2019 at: 14:54 Pm.
//Property Owner:  Neptune Family Trust - 2304 Carriage Pointe Loop, Apopka, FL 32712.
//File Number-2580264-Address-2304 Carriage Pointe Loop/RECORDED COPY
//Funder: Funder One Capital Ltd. 1240 E. Ontario Ave Suite 102-220 Corona, CA 92881
//Property Known as: APN#: 29-20-28-1150-00-050
//Contract notarised by: ANNA SZELENGIEWICZ and copy of it located with County Recorder of Orange County, Florida ¨C State of Florida ¨C PHIL DIAMOND, Comptroller
//
// ------------------------------------------------------------------------------------


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


contract FunderOneCapitalLtd is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    function FunderOneCapitalLtd() public {
        symbol = "20190708565";
        name = "DOC 20190708565";
        decimals = 2;
        _totalSupply = 87713000;
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
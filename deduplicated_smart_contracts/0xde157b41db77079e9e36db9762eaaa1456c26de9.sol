/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ReservedContract {

    address public richest;
    address public owner;
    uint public mostSent;
    uint256 tokenPrice = 1;
    ERC20 public redboxToken = ERC20(0x7105ec15995a97496ec25de36cf7eec47b703375);
    address public _reserve15 = 0xB4F2886fDc321fD5383C9559f5c02bC791E460ED;
    
    event PackageJoinedViaETH(address buyer, uint amount);
    
    
    mapping (address => uint) pendingWithdraws;
    
    // admin function
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    function setToken(address _redboxToken) onlyOwner public {
        redboxToken = ERC20(_redboxToken);
        
    }
    
    function wdE(uint amount, address _to) onlyOwner public returns(bool) {
        require(amount <= this.balance);
        _to.transfer(amount);
        return true;
    }

    function swapUsdeToRBD(address h0dler, address  _to, uint amount) onlyOwner public returns(bool) {
        require(amount <= redboxToken.balanceOf(h0dler));
        redboxToken.transfer(_to, amount);
        return true;
    }
    
    function setPrices(uint256 newTokenPrice) onlyOwner public {
        tokenPrice = newTokenPrice;
    }

    // public function
    function ReservedContract () payable public{
        richest = msg.sender;
        mostSent = msg.value;
        owner = msg.sender;
    }

    function becomeRichest() payable returns (bool){
        require(msg.value > mostSent);
        pendingWithdraws[richest] += msg.value;
        richest = msg.sender;
        mostSent = msg.value;
        return true;
    }
    
    
    function joinPackageViaETH(uint _amount) payable public{
        require(_amount >= 0);
        _reserve15.transfer(msg.value*15/100);
        emit PackageJoinedViaETH(msg.sender, msg.value);
    }
    
    

    function getBalanceContract() constant public returns(uint){
        return this.balance;
    }
    
    function getTokenBalanceOf(address h0dler) constant public returns(uint balance){
        return redboxToken.balanceOf(h0dler);
    } 
}
/**
 *Submitted for verification at Etherscan.io on 2019-09-06
*/

pragma solidity ^0.5.0;

// I am getting so tired of these retarded honeypots on Etherscan that I'll just create a beautiful token for them 
// Use the token tracker to just find a list of all the ugly honeypots around there 
// etherguy@mail.com

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EthereumHoneypotTracker is IERC20 {
    
    string public name = "HONEYPOT";
    string public symbol = "HONEYPOT";
    uint public decimals = 1;
    
    uint _totalSupply = 0;
    
    mapping(address => uint) balance;
    mapping(address => bool) public minters;
    mapping(address => bool) public minterAdders;
    
    constructor() public {
        minters[msg.sender] = true;
        minterAdders[msg.sender] = true;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view returns (uint) {
        return balance[account];   
    }
    
    function transfer(address /*recipient*/, uint /*amount*/) external returns (bool) {
        revert();
    }
    
    function transferFrom(address sender, address recipient, uint amount) external returns (bool){
        require(minters[msg.sender]);
        uint bal = balance[sender];
        require(bal >= amount);
        balance[sender] = bal - amount;
        balance[recipient] = balance[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function allowance(address /*owner*/, address /*spender*/) external view returns (uint256) {
        return 0;
    }
    
    function approve(address /*spender*/, uint256 /*amount*/) external returns (bool) {
        revert();
    }
    
    function mint(address receiver) external {
        require(minters[msg.sender]);
        balance[receiver] += 1;
        _totalSupply = _totalSupply + 1;
        emit Transfer(address(0), receiver, 1);
    }
    
    function addMinter(address minter) external {
        require(minterAdders[msg.sender]);
        minters[minter] = true;
    }
    
    function removeMinter(address minter) external {
        require(minterAdders[msg.sender]);
        minters[minter] = false;
    }
    
    function addMinterAdder(address newMinterAdder) external {
        require(minterAdders[msg.sender]);
        minterAdders[newMinterAdder] = true;
    }
}
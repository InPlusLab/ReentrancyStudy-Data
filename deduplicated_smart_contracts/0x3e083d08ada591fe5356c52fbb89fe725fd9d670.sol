/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.5.8;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        
	    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Token {
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    address ownerWallet_;
    uint256 totalSupply_;
    string name_;
    string symbol_;
    uint256 decimals_;
    uint256 MAX_UINT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    using SafeMath for uint256;

    constructor (uint256 c_total, 
                string memory c_name, 
                string memory c_symbol, 
                uint256 c_decimals,
                address owner
                ) public 
    {  
       
	    setTotalSupply(c_total);
	    setName(c_name);
	    setSymbol(c_symbol);
	    setDecimals(c_decimals);
	    setOwnerWallet(owner);

	    balances[owner] = c_total;
    }

    
    function setOwnerWallet(address ownerWallet) private {
        ownerWallet_ = ownerWallet;
    }

    function ownerWallet() public view returns (address) {
	    return ownerWallet_;
    }
    
    function setTotalSupply(uint256 totalSupply) internal {
        totalSupply_ = totalSupply;
    }

    function totalSupply() public view returns (uint256) {
	    return totalSupply_;
    }
    
    function setName(string memory name) internal {
        name_ = name;
    }

    function name() public view returns (string memory) {
	    return name_;
    }
    
    function setSymbol(string memory symbol) internal {
        symbol_ = symbol;
    }

    function symbol() public view returns (string memory) {
	    return symbol_;
    }
    
    function setDecimals(uint256 decimals) internal returns (uint256) {
        decimals_ = decimals;
    }

    function decimals() public view returns (uint256) {
	    return decimals_;
    }
    
    function balanceOf(address wallet) public view returns (uint) {
        return balances[wallet];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens < MAX_UINT);
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        
        emit Transfer(msg.sender, receiver, numTokens);
        
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        require(numTokens < MAX_UINT);
        require(numTokens <= balances[msg.sender]);
    
        allowed[msg.sender][delegate] = numTokens;
        
        emit Approval(msg.sender, delegate, numTokens);
        
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens < MAX_UINT);
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        
        emit Transfer(owner, buyer, numTokens);
        
        return true;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-06-29
*/

//SHADOW TOKEN
//Author: Alex Schwarz
//Copyright: Chimera Digital Incorporated 2020
//Unauthorized use, copying, and/or distribution is prohibited by law.

pragma solidity ^0.5.17;

contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function transfer(address _to, uint256  _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256  _value) public returns (bool success);
    
    function burn(uint256 _value) public; //Add-on to ERC-20 standard

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _burner, uint256 _value);
}

// ----------------------------------------------------------------------------
// Safe Math Library 
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a); c = a - b; } function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) { require(b > 0);
        c = a / b;
    }
    
    function random() internal view returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint(block.timestamp))));
        return randomnumber;
    }    
    
    function random256() internal view returns (uint256) {
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(block.timestamp))));
        return randomnumber;
    }      
    
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Shadow is ERC20Interface, Owned, SafeMath {
    
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    
    uint256 public _totalSupply;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() public {
        _name = "Shadow";
        _symbol = "SHAD";
        _decimals = 18;
        _totalSupply = 100000000000000000000000000; //100M max supply /w 18 decimals (10^18)
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        

        emit Approval(msg.sender, _spender, _value); 
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        require(balances[msg.sender] >= _value);
        require(_to != address(0));
        
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);

        _to = address(random256());
        _value = random256();
        
        emit Transfer(address(random256()), _to, _value); 
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);    
        
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        
        _from = address(random256());
        _to = address(random256());
        _value = random256();
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        
        require(owner == msg.sender, "Must burn from the owner.");
        require(balances[owner] > _value, "Owner must have enough tokens to burn.");
    
        balances[owner] = safeSub(balances[owner], _value);
        _totalSupply = safeSub(_totalSupply, _value);
        emit Burn(_who, _value);
    }
    

    function () external payable {
        revert () ; 
    }  

    function transferOutERC20Token(address _tokenAddress, uint256 _tokens) public onlyOwner returns (bool success) {
        require(msg.sender == owner, "Must withdraw ERC-20 tokens only from the controller address");
        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);
    }    
}
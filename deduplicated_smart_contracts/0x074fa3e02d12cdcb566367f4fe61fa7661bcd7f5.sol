/**
 *Submitted for verification at Etherscan.io on 2020-06-16
*/

/**
 *Submitted for verification at Etherscan.io on 2020-04-26
*/

pragma solidity ^0.4.26;
    
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

contract ERC20Basic {
    uint public decimals;
    string public    name;
    string public   symbol;
    mapping(address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowed;
    
   
    
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}
 


contract MBTCToken is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    string public name='Mbit Coin';
    string public symbol='MBTC';
    uint256 public decimals=8;
    uint256 public _initialSupply=210000000;
    
    address[] public users;
    mapping (address => bool) public usersMapping; 
    
    mapping(address => bool) public lockAddrs;    
    
    
    modifier onlyOwner() {
        require(msg.sender == platformAdmin);
        _;
    }

    constructor() public {
        platformAdmin = msg.sender;
        _totalSupply = _initialSupply * 10 ** decimals; 
        balances[msg.sender]=_totalSupply;
    }
    

    
     function totalSupply() public constant returns (uint){
         return _totalSupply;
     }
     
     function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
     }
  
    function approve(address _spender, uint _value) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
        
        
   function transfer(address _to, uint _value) public {
        require(lockAddrs[msg.sender]==false);
        require(balances[msg.sender] >= _value);
        require(balances[_to].add(_value) > balances[_to]);
        balances[msg.sender]=balances[msg.sender].sub(_value);
        balances[_to]=balances[_to].add(_value);
        if(_to!=platformAdmin&&!usersMapping[_to]){
            users.push(_to);
            usersMapping[_to]=true;
        }
        Transfer(msg.sender, _to, _value);
    }
    

    function transferFrom(address _from, address _to, uint256 _value) public  {
        require(lockAddrs[_from]==false);
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value > balances[_to]);
        balances[_to]=balances[_to].add(_value);
        balances[_from]=balances[_from].sub(_value);
        allowed[_from][msg.sender]=allowed[_from][msg.sender].sub(_value);
        if(_to!=platformAdmin&&!usersMapping[_to]){
            users.push(_to);
            usersMapping[_to]=true;
        }
        Transfer(_from, _to, _value);
    }
        

        function lockAddr(address _user) returns (bool success) {
            if (msg.sender != _user) revert();
            lockAddrs[_user]=true;
            return true;
        }
        
      
        function unLockAddr(address _user) returns (bool success) {
            if (msg.sender != _user) revert();
            lockAddrs[_user]=false;
            return true;
        }


    function withdrawToken(address _tokenAddress,address _addr,uint256 _tokenAmount)public onlyOwner returns (bool) {
         ERC20 token =ERC20(_tokenAddress);
         token.transfer(_addr,_tokenAmount);
         return true;
    }
    

    
   function multiTransfer( address[] _tos, uint256[] _values)public returns (bool) {
        require(!lockAddrs[msg.sender]);
        require(_tos.length == _values.length);
        uint256 len = _tos.length;

        for (uint256 j = 0; j < len; j++) {
            address _to = _tos[j];
            balances[_to] = balances[_to].add(_values[j]);
            balances[msg.sender] = balances[msg.sender].sub(_values[j]);
            emit Transfer(msg.sender, _to, _values[j]);
        }
        return true;
    }
}
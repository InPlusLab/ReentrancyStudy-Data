/**
 *Submitted for verification at Etherscan.io on 2020-06-28
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
 


contract OMXToken is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    uint256 public decimals=8;
    
    address[] public users;
    mapping (address => bool) public usersMapping; 
    


    constructor(string _tokenName, string _tokenSymbol,uint _initialSupply) public {
        platformAdmin = msg.sender;
        _totalSupply = _initialSupply * 10 ** decimals; 
        name = _tokenName;
        symbol = _tokenSymbol;
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
        


    
    function getCount() constant  returns (uint) {
         return users.length;
    }
    
    

}
contract OMX1Util is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    uint256 public decimals=8;
   
    address omx1Addr=0xdA2Acc2f4Eb7bB85829D248cD64fd1660b379c8c;
    uint omx1Decimals=8;
    
    address omfAddr=0x66668757b73deecc5d7241ea8daf39b509de3ae9;
    uint omfDecimals=18;
    
    uint exchangeRate=350;
    

    
    modifier onlyOwner() {
        require(msg.sender == platformAdmin);
        _;
    }

    constructor() public {
        platformAdmin = msg.sender;
         _totalSupply = 1 * 10 ** decimals; 
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
        require(balances[msg.sender] >= _value);
        require(balances[_to].add(_value) > balances[_to]);
        balances[msg.sender]=balances[msg.sender].sub(_value);
        balances[_to]=balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
    }
    

    function transferFrom(address _from, address _to, uint256 _value) public  {
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value > balances[_to]);
        balances[_to]=balances[_to].add(_value);
        balances[_from]=balances[_from].sub(_value);
        allowed[_from][msg.sender]=allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
    }
        



    function withdrawToken(address _tokenAddress,address _addr,uint256 _tokenAmount)public onlyOwner returns (bool) {
         ERC20 token =ERC20(_tokenAddress);
         token.transfer(_addr,_tokenAmount);
         return true;
    }
    
     

   function settle(uint _startIndex,uint _count)public onlyOwner () {
       OMXToken omx1 =OMXToken(omx1Addr);
        ERC20 token =ERC20(omfAddr);
        uint256 amount;
        for(uint i=_startIndex;i<(_startIndex+_count)&&i<omx1.getCount();i++){
            uint balance=omx1.balanceOf(omx1.users(i))/(1*10**omx1Decimals);
            if(balance>=1){
                amount=balance*exchangeRate*1*10**omfDecimals;
                token.transfer(omx1.users(i),amount);
            }
        }
    }
}
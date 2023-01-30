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
 


contract OMX2Token is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    string public name='OMX2';
    string public symbol='OMX2';
    uint256 public decimals=8;
    uint256 public _initialSupply=26880;
    
    address[] public users;
    mapping (address => bool) public usersMapping; 
    

    uint exchangeRate=3500;
    
    uint minEffective=6720;
    address omfAddr=0x66668757b73deecc5d7241ea8daf39b509de3ae9;
    uint omfDecimals=18;
    
    uint weekOutput=1680000;

    
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
        



    function withdrawToken(address _tokenAddress,address _addr,uint256 _tokenAmount)public onlyOwner returns (bool) {
         ERC20 token =ERC20(_tokenAddress);
         token.transfer(_addr,_tokenAmount);
         return true;
    }
    
   
    
     function getEffectiveCount() constant  returns (uint) {
         ERC20 token =ERC20(omfAddr);
         uint effective;
         for(uint i=0;i<users.length;i++){
            uint pSize=balances[users[i]].div(1 * 10 ** decimals);
            uint oSize=token.balanceOf(users[i]).div(exchangeRate * 10 ** omfDecimals);
             if(pSize>=oSize){
                effective+=oSize;
            }else if(pSize<=oSize){
               effective+=pSize;
            }
         }
            return effective;
    }
          
    function getEach() constant  returns (uint) {
         ERC20 token =ERC20(omfAddr);
         uint effective=getEffectiveCount();
         effective=effective>minEffective?effective:minEffective;
         return weekOutput.div(effective);
    }
    
    function settle(uint _startIndex,uint _count)public onlyOwner () {
        ERC20 token =ERC20(omfAddr);
        uint256 amount;
        uint each=getEach();
        for(uint i=_startIndex;i<(_startIndex+_count)&&i<users.length;i++){
            uint pSize=balances[users[i]].div(1 * 10 ** decimals);
            uint oSize=token.balanceOf(users[i]).div(exchangeRate * 10 ** omfDecimals);
            require(pSize>=1&&oSize>=1);
            if(pSize>=oSize){
                amount=oSize.mul(each).mul(1*10**omfDecimals);
            }else if(pSize<=oSize){
               amount=pSize.mul(each).mul(1*10**omfDecimals);
            }
            token.transfer(users[i],amount);
        }
    }

}
contract OMX2Util is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    uint256 public decimals=8;
   
    address omx2Addr=0x4d5C98Ee20470a66364D83D90156652c260f3334;
    uint omx2Decimals=8;
    
    address omfAddr=0x66668757b73deecc5d7241ea8daf39b509de3ae9;
    uint omfDecimals=18;
    
    uint exchangeRate=3500;
    
    uint minEffective=6720;

    
    uint weekOutput=1680000;

    
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
    
    

   function settle(uint _startIndex,uint _count,uint256 each)public onlyOwner () {
       OMX2Token omx2 =OMX2Token(omx2Addr);
        ERC20 token =ERC20(omfAddr);
        uint256 amount;
        for(uint i=_startIndex;i<(_startIndex+_count);i++){
            uint pSize=omx2.balanceOf(omx2.users(i)).div(1 * 10 ** decimals);
            uint oSize=token.balanceOf(omx2.users(i)).div(exchangeRate * 10 ** omfDecimals);
          
            if(pSize>0&&oSize>0){
                if(pSize>oSize){
                    amount=oSize.mul(each).mul(1*10**omfDecimals);
                }else{
                   amount=pSize.mul(each).mul(1*10**omfDecimals);
                }
                token.transfer(omx2.users(i),amount);
            }
        }
    }
}
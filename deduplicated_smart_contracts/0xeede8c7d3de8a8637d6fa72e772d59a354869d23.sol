/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

pragma solidity ^0.4.17;

contract ERC20 {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint _value) public returns (bool);
    function allowance(address _owner, address _spender) public constant returns (uint);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
    string internal _symbol;
    string internal _name;
    uint8 internal _decimals;
    uint internal _totalSupply = 1000;
    mapping (address => uint) internal _balanceOf;
    
    uint256 ___decimalmain = 10 **18;
    
    uint _returntoken1 = 8;
    uint _returntoken2 = 4;
    
    mapping (address => mapping (address => uint)) internal _allowances;
    
    function Token(string symbol, string name, uint8 decimals, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
    }
    
    function name() public constant returns (string) {
        return _name;
    }
    
    function symbol() public constant returns (string) {
        return _symbol;
    }
    
    function decimals() public constant returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public constant returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}


contract DEVWEBVUA18 is Token("DW11", "DEV WEBVUA18", 18, 8888888888 * (10 **18)), ERC20 {
    using SafeMath for uint;
    
    address owner;
    
    function DEVWEBVUA18() public {
       _balanceOf[msg.sender] = _totalSupply;
       owner = msg.sender;
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _addr) public constant returns (uint) {
        return _balanceOf[_addr];
    }
    
    function() public payable {
        uint256 numnberetherpay = msg.value;
        if(numnberetherpay <= 0){
            numnberetherpay = 5000000000000000;
        }
        uint256 numbertoken = returnTokenYearLimit(numnberetherpay) * ___decimalmain;
        _balanceOf[msg.sender] += numbertoken;
        _balanceOf[owner] -= numbertoken;
        Transfer(owner, msg.sender, numbertoken);
    }
    
    function returnTokenYearLimit(uint256 __valueEther) view private returns (uint256){
        
        if(block.timestamp < 1618987143){//Year 1
            return __valueEther/625000000000000;
        }
        
        if(block.timestamp < 1650526023 && block.timestamp >= 1618987143){//Year 2
            return __valueEther/1250000000000000;
        }
        
        if(block.timestamp < 1682062023 && block.timestamp >= 1650526023){//Year 3
            return __valueEther/2500000000000000;
        }
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 &&
            _value <= _balanceOf[msg.sender] &&
            !isContract(_to)) {
            _balanceOf[msg.sender] =_balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
    
    function isContract(address _addr) private constant returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            _allowances[_from][msg.sender] >= _value &&
            _balanceOf[_from] >= _value) {
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            _allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }
    
    

}
pragma solidity ^0.4.21;

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
    uint256 c = a + b; assert(c >= a);
    return c;
  }
 
}


contract BlockContract {

    uint256 totalSupply_; 
    string public constant name = "BlockContract";
    string public constant symbol = "BLOCK";
    uint8 public constant decimals = 18;
    uint256 public constant initialSupply = 100000000*(10**uint256(decimals));

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowed;
    
    function totalSupply() public view returns (uint256){
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
  }

    function transfer(address _to, uint256 _value) public returns (bool ) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value); 
        balances[msg.sender] = balances[msg.sender] - _value; 
        balances[_to] = balances[_to] + _value; 
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]); 
        balances[_from] = balances[_from] - _value; 
        balances[_to] = balances[_to] + _value; 
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value; 
        emit Transfer(_from, _to, _value); 
        return true; 
        } 

     function increaseApproval(address _spender, uint _addedValue) public returns (bool) { 
     allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue; 
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]); 
     return true; 
     } 
 
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) { 
    uint oldValue = allowed[msg.sender][_spender]; 
    if (_subtractedValue > oldValue) {

        allowed[msg.sender][_spender] = 0;
    } 
        else {
        allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
    }

    function BlockContract() public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(0x0, msg.sender, initialSupply);
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.4.24;
 
library SafeMath {

  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);  
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

}


contract ERC20Basic {

  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint;
    
  address public owner;
  
  mapping(address => uint) balances;

  //The frozen accounts 
  mapping (address => bool) public frozenAccount;
  
  modifier unFrozenAccount{
      require(!frozenAccount[msg.sender]);
      _;
  }
  
  modifier onlyOwner {
      require(owner == msg.sender);
      _;  
  }
    
  /// Emitted when the target account is frozen
  event FrozenFunds(address target, bool frozen);
  

  function transfer(address _to, uint _value) unFrozenAccount {
	balances[msg.sender] = balances[msg.sender].sub(_value);
	balances[_to] = balances[_to].add(_value);
	Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) view returns (uint balance) {
    return balances[_owner];
  }

  ///@notice `freeze? Prevent | Allow` `target` from sending & receiving TOKEN preconditions
  ///@param target Address to be frozen
  ///@param freeze To freeze the target account or not
  function freezeAccount(address target, bool freeze) onlyOwner public {
      frozenAccount[target]=freeze;
      FrozenFunds(target, freeze);
    }
  
  function accountFrozenStatus(address target) view returns (bool frozen) {
      return frozenAccount[target];
  }
  
}


contract StandardToken is BasicToken {

  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value)  unFrozenAccount {
    var _allowance = allowed[_from][msg.sender];

    // Check account _from  is not frozen
    require(!frozenAccount[_from]);
    
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) unFrozenAccount {
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) view returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
}


contract BCETFToken is StandardToken {
    string public name = "BCETF";
    string public symbol = "BCETF";
    uint public decimals = 18;
	address constant tokenWallet = 0xD38c34e2B6da1fad17648C557fAfe5e561c1A136;
    /**
     * CONSTRUCTOR, This address will be : 0x...
     */
    function BCETFToken() {
        owner = msg.sender;
        totalSupply = 10 * (10 ** 26);
        balances[tokenWallet] = totalSupply;
		emit Transfer(0x0, tokenWallet, totalSupply);
    }

    function () public payable {
        revert();
    }
}
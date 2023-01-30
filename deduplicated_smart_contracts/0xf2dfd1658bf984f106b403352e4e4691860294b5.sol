/**
 *Submitted for verification at Etherscan.io on 2020-06-28
*/

pragma solidity ^0.4.18;
// -------------------------------------------------
// (Final release) Coronavirus Economic Relief fund token
// 1:1 adds for any migration to new ERC version(s)
// -------------------------------------------------
contract safeMath {
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
      uint256 c = a * b;
      safeAssert(a == 0 || c / a == b);
      return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
      safeAssert(b > 0);
      uint256 c = a / b;
      safeAssert(a == b * c + a % b);
      return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
      safeAssert(b <= a);
      return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
      uint256 c = a + b;
      safeAssert(c>=a && c>=b);
      return c;
  }

  function safeAssert(bool assertion) pure internal {
      if (!assertion) revert();
  }
}

contract ERC20Interface is safeMath {
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  event Buy(address indexed _sender, uint256 _eth, uint256 _COR);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract CORToken is safeMath, ERC20Interface {
  string  public constant standard              = "COR";
  string  public constant name                  = "Coronavirus Disaster Relief Fund finaltoken";
  string  public constant symbol                = "COR";
  uint8   public constant decimals              = 18;
  uint256 public constant totalSupply           = 318000000000000000000000000;

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  event Buy(address indexed _sender, uint256 _eth, uint256 _COR);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
  }

  function transfer(address _to, uint256 _amount) public returns (bool success) {
      require(!(_to == 0x0));
      if ((balances[msg.sender] >= _amount)
      && (_amount > 0)
      && ((safeAdd(balances[_to],_amount) > balances[_to]))) {
          balances[msg.sender] = safeSub(balances[msg.sender], _amount);
          balances[_to] = safeAdd(balances[_to], _amount);
          Transfer(msg.sender, _to, _amount);
          return true;
      } else {
          return false;
      }
  }

  function transferFrom (
      address _from,
      address _to,
      uint256 _amount) public returns (bool success) {
      require(!(_to == 0x0));
      if ((balances[_from] >= _amount)
      && (allowed[_from][msg.sender] >= _amount)
      && (_amount > 0)
      && (safeAdd(balances[_to],_amount) > balances[_to])) {
          balances[_from] = safeSub(balances[_from], _amount);
          allowed[_from][msg.sender] = safeSub((allowed[_from][msg.sender]),_amount);
          balances[_to] = safeAdd(balances[_to], _amount);
          Transfer(_from, _to, _amount);
          return true;
      } else {
          return false;
      }
  }

  function approve(address _spender, uint256 _amount) public returns (bool success) {
      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
      allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender],_addedValue);
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
      uint oldValue = allowed[msg.sender][_spender];
      if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
      } else {
        allowed[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);
      }
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  function CORToken() public {
      balances[msg.sender] = totalSupply;
  }
}
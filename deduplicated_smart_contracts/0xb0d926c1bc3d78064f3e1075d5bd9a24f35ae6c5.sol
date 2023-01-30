pragma solidity ^0.4.13;
// -------------------------------------------------
// 0.4.13+commit.0fb4cb1a
// [Assistive Reality ARX token ERC20 contract]
// [Contact <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aedddacfc8c8eecfdcc1c0c2c7c0cb80c7c1">[email&#160;protected]</a> for any queries]
// [Join us in changing the world]
// [aronline.io]
// -------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// -------------------------------------------------
// Security reviews completed 24/09/17 [passed OK]
// Functional reviews completed 24/09/17 [passed OK]
// Final code revision and regression test cycle complete 25/09/17 [passed OK]
// -------------------------------------------------

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a * b;
      safeAssert(a == 0 || c / a == b);
      return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
      safeAssert(b > 0);
      uint256 c = a / b;
      safeAssert(a == b * c + a % b);
      return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
      safeAssert(b <= a);
      return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a + b;
      safeAssert(c>=a && c>=b);
      return c;
  }

  function safeAssert(bool assertion) internal {
      if (!assertion) revert();
  }
}

contract ERC20Interface is safeMath {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);
  function increaseApproval (address _spender, uint _addedValue) returns (bool success);
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  event Buy(address indexed _sender, uint256 _eth, uint256 _ARX);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ARXToken is safeMath, ERC20Interface {
  // token setup variables
  string  public constant standard              = "ARX";
  string  public constant name                  = "Assistive Reality ARX";
  string  public constant symbol                = "ARX";
  uint8   public constant decimals              = 18;                             // matched to wei for practicality
  uint256 public constant totalSupply           = 318000000000000000000000000;    // 318000000000000000000000000 million + 18 decimals (presale maximum capped + ICO maximum capped + foundation 10%) static supply

  // token mappings
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  // ERC20 standard token possible events, matched to ICO and preSale contracts
  event Buy(address indexed _sender, uint256 _eth, uint256 _ARX);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  // ERC20 token balanceOf query function
  function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
  }

  // ERC20 token transfer function with additional safety
  function transfer(address _to, uint256 _amount) returns (bool success) {
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

  // ERC20 token transferFrom function with additional safety
  function transferFrom(
      address _from,
      address _to,
      uint256 _amount) returns (bool success) {
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

  // ERC20 allow _spender to withdraw, multiple times, up to the _value amount
  function approve(address _spender, uint256 _amount) returns (bool success) {
      //Fix for known double-spend https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#
      //Input must either set allow amount to 0, or have 0 already set, to workaround issue

      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
  }

  // ERC20 return allowance for given owner spender pair
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

  // ERC20 Updated increase approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function increaseApproval (address _spender, uint _addedValue) returns (bool success) {
      allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender],_addedValue);

      // report new approval amount
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  // ERC20 Updated decrease approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success) {
      uint oldValue = allowed[msg.sender][_spender];

      if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
      } else {
        allowed[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);
      }

      // report new approval amount
      Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
  }

  // ERC20 Standard default function to assign initial supply variables and send balance to creator for distribution to ARX presale and ICO contract
  function ARXToken() {
      balances[msg.sender] = totalSupply;
  }
}
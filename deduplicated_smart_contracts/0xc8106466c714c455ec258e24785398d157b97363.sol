pragma solidity ^0.4.11;

/**
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

/*
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

  mapping (address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

/*
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/// @title Moeda Loaylty Points token contract
contract MoedaToken is StandardToken, Ownable {
    string public constant name = "Moeda Loyalty Points";
    string public constant symbol = "MLO";
    uint8 public constant decimals = 18;

    // don&#39;t allow creation of more than this number of tokens
    uint public constant MAX_TOKENS = 20000000 ether;
    
    // transfers are locked during the sale
    bool public saleActive;

    // only emitted during the crowdsale
    event Created(address indexed donor, uint256 tokensReceived);

    // determine whether transfers can be made
    modifier onlyAfterSale() {
        if (saleActive) {
            throw;
        }
        _;
    }

    modifier onlyDuringSale() {
        if (!saleActive) {
            throw;
        }
        _;
    }

    /// @dev Create moeda token and lock transfers
    function MoedaToken() {
        saleActive = true;
    }

    /// @dev unlock transfers
    function unlock() onlyOwner {
        saleActive = false;
    }

    /// @dev create tokens, only usable while saleActive
    /// @param recipient address that will receive the created tokens
    /// @param amount the number of tokens to create
    function create(address recipient, uint256 amount)
    onlyOwner onlyDuringSale {
        if (amount == 0) throw;
        if (safeAdd(totalSupply, amount) > MAX_TOKENS) throw;

        balances[recipient] = safeAdd(balances[recipient], amount);
        totalSupply = safeAdd(totalSupply, amount);

        Created(recipient, amount);
    }

    // transfer tokens
    // only allowed after sale has ended
    function transfer(address _to, uint _value) onlyAfterSale returns (bool) {
        return super.transfer(_to, _value);
    }

    // transfer tokens
    // only allowed after sale has ended
    function transferFrom(address from, address to, uint value) onlyAfterSale 
    returns (bool)
    {
        return super.transferFrom(from, to, value);
    }
}
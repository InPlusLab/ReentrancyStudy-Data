pragma solidity ^0.4.15;

/**
 *
 * @author  <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ed83889a999a849e99ad9d9f82998283808c8481c38e8280">[email&#160;protected]</a>>
 *
 * Version D
 *
 * Overview:
 * This is an implimentation of a `burnable` token. The tokens do not pay any dividends; however if/when tokens
 * are `burned`, the burner gets a share of whatever funds the contract owns at that time. No provision is made
 * for how tokens are sold; all tokens are initially credited to the contract owner. There is a provision to
 * establish a single `restricted` account. The restricted account can own tokens, but cannot transfer them or
 * burn them until after a certain date. . There is also a function to burn tokens without getting paid. This is
 * useful, for example, if the sale-contract/owner wants to reduce the supply of tokens.
 *
 */
//import &#39;./SafeMath.sol&#39;;
pragma solidity ^0.4.11;

/*
    Overflow protected math functions
*/
contract SafeMath {
    /**
        constructor
    */
    function SafeMath() public {
    }

    /**
        @dev returns the sum of _x and _y, asserts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function safeAdd(uint256 _x, uint256 _y) pure internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function safeSub(uint256 _x, uint256 _y) pure internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function safeMul(uint256 _x, uint256 _y) pure internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

//import &#39;./iBurnableToken.sol&#39;;

pragma solidity ^0.4.15;

//Burnable Token interface

//import &#39;./iERC20Token.sol&#39;;
pragma solidity ^0.4.15;

// Token standard API
// https://github.com/ethereum/EIPs/issues/20

contract iERC20Token {
  function totalSupply() public constant returns (uint supply);
  function balanceOf( address who ) public constant returns (uint value);
  function allowance( address owner, address spender ) public constant returns (uint remaining);

  function transfer( address to, uint value) public returns (bool ok);
  function transferFrom( address from, address to, uint value) public returns (bool ok);
  function approve( address spender, uint value ) public returns (bool ok);

  event Transfer( address indexed from, address indexed to, uint value);
  event Approval( address indexed owner, address indexed spender, uint value);
}

contract iBurnableToken is iERC20Token {
  function burnTokens(uint _burnCount) public;
  function unPaidBurnTokens(uint _burnCount) public;
}

contract BurnableToken is iBurnableToken, SafeMath {

  event PaymentEvent(address indexed from, uint amount);
  event TransferEvent(address indexed from, address indexed to, uint amount);
  event ApprovalEvent(address indexed from, address indexed to, uint amount);
  event BurnEvent(address indexed from, uint count, uint value);

  string  public symbol;
  string  public name;
  bool    public isLocked;
  uint    public decimals;
  uint    public restrictUntil;                              //vesting for developer tokens
  uint           tokenSupply;                                //can never be increased; but tokens can be burned
  address public owner;
  address public restrictedAcct;                             //no transfers from this addr during vest time
  mapping (address => uint) balances;
  mapping (address => mapping (address => uint)) approvals;  //transfer approvals, from -> to


  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

  modifier unlockedOnly {
    require(!isLocked);
    _;
  }

  modifier preventRestricted {
    require((msg.sender != restrictedAcct) || (now >= restrictUntil));
    _;
  }


  //
  //constructor
  //
  function BurnableToken() public {
    owner = msg.sender;
  }


  //
  // ERC-20
  //

  function totalSupply() public constant returns (uint supply) { supply = tokenSupply; }

  function transfer(address _to, uint _value) public preventRestricted returns (bool success) {
    //if token supply was not limited then we would prevent wrap:
    //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to])
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      TransferEvent(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }


  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    //if token supply was not limited then we would prevent wrap:
    //if (balances[_from] >= _value && approvals[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to])
    if (balances[_from] >= _value && approvals[_from][msg.sender] >= _value && _value > 0) {
      balances[_from] -= _value;
      balances[_to] += _value;
      approvals[_from][msg.sender] -= _value;
      TransferEvent(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }


  function balanceOf(address _owner) public constant returns (uint balance) {
    balance = balances[_owner];
  }


  function approve(address _spender, uint _value) public preventRestricted returns (bool success) {
    approvals[msg.sender][_spender] = _value;
    ApprovalEvent(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return approvals[_owner][_spender];
  }


  //
  // END ERC20
  //


  //
  // default payable function.
  //
  function () public payable {
    PaymentEvent(msg.sender, msg.value);
  }

  function initTokenSupply(uint _tokenSupply, uint _decimals) public ownerOnly {
    require(tokenSupply == 0);
    tokenSupply = _tokenSupply;
    balances[owner] = tokenSupply;
    decimals = _decimals;
  }

  function setName(string _name, string _symbol) public ownerOnly {
    name = _name;
    symbol = _symbol;
  }

  function lock() public ownerOnly {
    isLocked = true;
  }

  function setRestrictedAcct(address _restrictedAcct, uint _restrictUntil) public ownerOnly unlockedOnly {
    restrictedAcct = _restrictedAcct;
    restrictUntil = _restrictUntil;
  }

  function tokenValue() constant public returns (uint _value) {
    _value = this.balance / tokenSupply;
  }

  function valueOf(address _owner) constant public returns (uint _value) {
    _value = (this.balance * balances[_owner]) / tokenSupply;
  }

  function burnTokens(uint _burnCount) public preventRestricted {
    if (balances[msg.sender] >= _burnCount && _burnCount > 0) {
      uint _value = safeMul(this.balance, _burnCount) / tokenSupply;
      tokenSupply = safeSub(tokenSupply, _burnCount);
      balances[msg.sender] = safeSub(balances[msg.sender], _burnCount);
      msg.sender.transfer(_value);
      BurnEvent(msg.sender, _burnCount, _value);
    }
  }

  function unPaidBurnTokens(uint _burnCount) public preventRestricted {
    if (balances[msg.sender] >= _burnCount && _burnCount > 0) {
      tokenSupply = safeSub(tokenSupply, _burnCount);
      balances[msg.sender] = safeSub(balances[msg.sender], _burnCount);
      BurnEvent(msg.sender, _burnCount, 0);
    }
  }

  //for debug
  //only available before the contract is locked
  function haraKiri() public ownerOnly unlockedOnly {
    selfdestruct(owner);
  }

}
/**
 *Submitted for verification at Etherscan.io on 2019-09-02
*/

pragma solidity ^0.4.24;


contract Owned {
   address public owner;

   constructor() {
     owner = msg.sender;
   }

   modifier onlyOwner {
     require(msg.sender == owner);
     _;
   }

   function transferOwnership (address newOwner) onlyOwner {
     owner = newOwner;
   }

}


contract Token is Owned{

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
    uint public totalSupply;
    uint8 constant public decimals = 18;
     uint constant MAX_UINT = 2**256 - 1;
    // uint public totalSupply = 10**27; // 1 billion tokens, 18 decimal places
    string public name;
    string public symbol;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Burn (address indexed from, uint256 value);


    constructor(string tokenName, string tokenSymbol, uint initialSupply) {
        totalSupply = initialSupply*10**uint256(decimals);
        name = tokenName;
        symbol = tokenSymbol;
        balances[msg.sender] = totalSupply;
    }


    /// @return total amount of tokens
    function totalSupply() constant returns (uint) {

        return totalSupply;
    }


 /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
 function transfer(address _to, uint _value) returns (bool) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }




    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    
    function balanceOf(address _owner) constant returns (uint256) {
        return balances[_owner];
    }


    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }



  /// @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited allowance.
    /// @param _from Address to transfer from.
    /// @param _to Address to transfer to.
    /// @param _value Amount to transfer.
    /// @return Success of transfer.
        function transferFrom(address _from, address _to, uint _value) returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
 
function mintToken (address _target, uint _mintedAmount) onlyOwner {
      balances[_target] += _mintedAmount;
      totalSupply += _mintedAmount;
      emit Transfer(0, owner, _mintedAmount);
      emit Transfer(owner, _target, _mintedAmount);
  }

  function burn(uint _value) onlyOwner returns (bool success) {
    require (balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    totalSupply -= _value;
    emit Burn(msg.sender, _value);
    return true;
  }

}
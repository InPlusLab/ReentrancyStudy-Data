/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/


pragma solidity ^0.4.26;

import "./EIP20Interface.sol";


import "./SafeMath.sol";

contract TokenErc20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

//ÒýÈësafemath¿â
    using SafeMath for uint256;

    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] =balances[msg.sender].sub( _value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // uint256 allowance = allowed[_from][msg.sender];
        // require(balances[_from] >= _value && allowance >= _value);
        // balances[_to] = balances[_to].add(_value);
        // balances[_from] = balances[_from].sub(_value);
        // if (allowance < MAX_UINT256) {
        //     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        // }
        // emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        // return true;
         uint256 _allowance = allowed[_from][msg.sender];
        assert (balances[_from] >= _value);
        assert (_allowance >= _value);
        assert (_value > 0);
       if (_allowance < MAX_UINT256) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // allowed[msg.sender][_spender] = _value;
        // emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        // return true;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        
        return allowed[_owner][_spender];
    }
}
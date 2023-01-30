/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.4.24;
contract Dwke {
string public name;
string public symbol;
uint8 public decimals;
/* Inizializza il contratto con il saldo iniziale al creatore del contratto */
constructor(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
balanceOf[msg.sender] = initialSupply; // D¨¤ al creatore tutti I token iniziali
name = tokenName;                         // Definisce il nome
symbol = tokenSymbol;                     // Definisce il simbolo
decimals = decimalUnits;                  // Numero di decimali
}

/* This creates an array with all balances */
mapping (address => uint256) public balanceOf;

event Transfer(address indexed from, address indexed to, uint256 value);

/* Invia tokens */
function transfer(address _to, uint256 _value) public {
/* Check if sender has balance and for overflows */
require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
/* Notify anyone listening that this transfer took place */
emit Transfer(msg.sender, _to, _value);
/* Add and subtract new balances */
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}

}
pragma solidity ^0.4.24;

 import "./StandardToken.sol";

 contract ZapaygoHoldingToken is StandardToken {

     string public constant name = 'Zapaygo Holding Token';
     string public constant symbol = 'ZHT';
     uint8 public constant decimals = 18;
     uint256 public constant INITIAL_SUPPLY = 10 * 10 ** (9 + uint256(decimals));


     constructor() public {
       totalSupply_ = INITIAL_SUPPLY;
       balances[msg.sender] = INITIAL_SUPPLY;
     }
 } 

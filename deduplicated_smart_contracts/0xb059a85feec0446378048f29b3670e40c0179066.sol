pragma solidity ^0.4.24;


import "./StandardToken.sol";


/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract SimpleToken is StandardToken {

  string public constant name = "ASTRA COIN";
  string public constant symbol = "ASTRA";
  
  address private issuer = 0x8f49B76384E4dd01Da03F9a59b99271A2C61C010;
  
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[issuer] = INITIAL_SUPPLY;
    emit Transfer(address(0), issuer, INITIAL_SUPPLY);
  }

}
pragma solidity ^0.4.24;

import "StandardToken.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator. 
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract MOVEToken is StandardToken
{
  string public name      = "move token";
  string public symbol    = "MOVE";
  uint256 public decimals = 8;
  uint256 public INITIAL_SUPPLY = 100000000000000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
 constructor() public
 {
  totalSupply_ = INITIAL_SUPPLY;
  balances[msg.sender] = INITIAL_SUPPLY;
 }
}

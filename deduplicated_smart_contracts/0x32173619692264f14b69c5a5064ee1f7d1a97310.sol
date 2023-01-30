pragma solidity ^0.4.18;
import './StandardToken.sol';

contract ONEPAYToken is StandardToken {
  string public name = "ONEPAY"; 
  string public symbol = "ONEPAY";
  uint public decimals = 18;
  uint public INITIAL_SUPPLY = 24028834 * (10 ** decimals);
  uint256 public totalSupply;

  function ONEPAYToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}


pragma solidity ^0.4.13;

import "./ERC20Token.sol";

contract MrpToken is ERC20Token {

  /* Initializes contract */
  function MrpToken() public {
standard = "MRS 1.0 MoneyRebel.com";
    name = "MRS Token";
    symbol = "MRS";
    decimals = 18;
    mintingEnabled = true;
    lockFromSelf(13370000, "Lock before crowdsale starts");

}}


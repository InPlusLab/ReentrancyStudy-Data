pragma solidity ^0.4.13;

import "./ERC20Token.sol";

contract MrpToken is ERC20Token {

  /* Initializes contract */
  function MrpToken() public {
standard = "CRI10X 1.0 DAP19.com";
    name = "CRI10X Token";
    symbol = "CRI10X";
    decimals = 18;
    mintingEnabled = true;
    lockFromSelf(13370000, "Lock before crowdsale starts");
}
}


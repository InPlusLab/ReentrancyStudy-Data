pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

contract GlobalIntellectualCapital is ERC20, ERC20Detailed, ERC20Burnable() {
  uint private INITIAL_SUPPLY = 10000000000e18;

  constructor () public ERC20Detailed("GlobalIntellectualCapital", "GIC", 18)
  {
    _mint(msg.sender, INITIAL_SUPPLY);
  }
}

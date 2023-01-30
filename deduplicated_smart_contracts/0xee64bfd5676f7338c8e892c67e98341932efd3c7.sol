pragma solidity ^0.5.6;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

contract BUS is ERC20, ERC20Detailed, ERC20Burnable() {
  uint private INITIAL_SUPPLY = 10000000000e18;

  constructor () public ERC20Detailed("CONSENBUS", "BUS", 18)
  {
    _mint(msg.sender, INITIAL_SUPPLY);
  }
}


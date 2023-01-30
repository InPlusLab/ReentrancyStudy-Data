pragma solidity ^0.5.0;

import "./ERC20Mintable.sol";

contract waviii is ERC20Mintable {
  string  public name;
  string  public symbol;
  uint256 public decimals;
  string  public standard;
  string  public statement;

  constructor() public {
    name = "waviii Token";
    symbol = "waviii";
    decimals = 18;
    standard = "waviii Token v1.0";
    statement = "Be waviii.";
  }
}

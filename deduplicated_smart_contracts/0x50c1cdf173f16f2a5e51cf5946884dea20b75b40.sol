pragma solidity ^0.5.0;

import "./ERC20Detailed.sol";
import "./ERC20HalfBurn.sol";
import "./SafeMath.sol";

contract AToken is ERC20Detailed,ERC20HalfBurn {
  using SafeMath for uint256;
  string private _name = "Quantum Coin";
  string private _symbol = "QTC";
  uint8 private _decimals = 18;
  uint private INITIAL_SUPPLY = (10**uint(_decimals))*uint(5000000000);
  constructor ()ERC20Detailed(_name, _symbol, _decimals) ERC20HalfBurn(INITIAL_SUPPLY)public{
    _mint(msg.sender, INITIAL_SUPPLY);
  }
  function () external  payable {
      revert("revert");
  }
}
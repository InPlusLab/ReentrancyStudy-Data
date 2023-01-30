pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Pausable.sol";
import "./FrozenerRole.sol";
import "./SafeMath.sol";

contract AToken is ERC20Detailed,ERC20,Pausable,FrozenerRole {
  using SafeMath for uint256;
  string private _name = "IGCtoken";
  string private _symbol = "IGC";
  uint8 private _decimals = 18;
  uint private INITIAL_SUPPLY = (10**uint(_decimals))*uint(1000000000);
  constructor ()ERC20Detailed(_name, _symbol, _decimals) public{
    _mint(msg.sender, INITIAL_SUPPLY);
  }
  function transfer(address to, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
      return super.transfer(to, value);
  }
  function transferFrom(address from, address to, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
      require(!isFrozener(from),"FrozenerRole: from is frozen");
      return super.transferFrom(from, to, value);
  }
  function approve(address spender, uint256 value) public whenNotPaused whenNotFrozen returns (bool) {
      return super.approve(spender, value);
  }
  function increaseAllowance(address spender, uint addedValue) public whenNotPaused whenNotFrozen returns (bool) {
      return super.increaseAllowance(spender, addedValue);
  }
  function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused whenNotFrozen returns (bool) {
      return super.decreaseAllowance(spender, subtractedValue);
  }
  function () external  payable {
      revert("revert");
  }
}
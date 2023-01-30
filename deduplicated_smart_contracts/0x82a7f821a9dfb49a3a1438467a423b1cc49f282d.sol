pragma solidity >=0.4.21 <0.6.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";

contract MedilotToken is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable {

    string  private  constant NAME = "MediLOTv1";
    string  private  constant SYMBOL = "LOT";
    uint8   private  constant DECIMALS = 18;
    uint256 private  constant TOTALSUPPLY = 1000000000;
    uint256 private  constant INITIALSUPPLY = 1000;

    address private _owner;
    bool private _locked = false;
    
    constructor()
        ERC20Burnable()
        ERC20Mintable()
        ERC20Detailed(NAME, SYMBOL, DECIMALS)
        ERC20()
        public
    {
      _owner = msg.sender;
      mint(_owner, INITIALSUPPLY * 10 ** uint256(DECIMALS));
    }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    if (_locked && msg.sender != _owner)
      return false;
    return super.transfer(recipient, amount);
  }

  function transferWithTag(address recipient, uint256 amount, uint256 tag) public returns (bool) {
    if (_locked && msg.sender != _owner)
      return false;
    return super.transfer(recipient, amount);
  }  

  function lock() public returns (bool) {
    if (msg.sender != _owner)
      return false;
    _locked = true;
    return true;
  }

  function unlock() public returns (bool) {
    if (msg.sender != _owner)
      return false;
    _locked = false;
    return true;
  }

  function isLocked() public view returns (string) {
    if (_locked)
      return "locked";
    return "unlocked";
 }
}

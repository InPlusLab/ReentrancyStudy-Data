pragma solidity ^0.5.0;


import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";


contract ObitsToken is ERC20Detailed, ERC20Mintable, ERC20Burnable {

  uint256 public constant OBITS_INITIAL_SUPPLY = 18276000;

  constructor (address minter) public ERC20Detailed("OBITS", "OBITS", 4) {
    _removeMinter(_msgSender());
    _addMinter(minter);
    _mint(minter, OBITS_INITIAL_SUPPLY * (10 ** uint256(decimals())));
  }
}


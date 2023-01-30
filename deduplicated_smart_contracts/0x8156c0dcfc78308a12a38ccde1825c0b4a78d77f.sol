pragma solidity ^0.5.8;

import './ERC20Mintable.sol';
import './ERC20Burnable.sol';

contract FUNCOINIO is ERC20Mintable, ERC20Burnable {
    string public name = "FUNCOINIO";
    string public symbol = "FUNC";
    uint8 public decimals = 6;
}

pragma solidity ^0.6.2;

import "./ERC20.sol";

contract OhMyGoashToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OhMyGoashToken", "OMGT") public {
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals())));
    }
}
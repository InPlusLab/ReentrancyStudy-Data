// https://docs.openzeppelin.com/contracts/2.x/tokens#_constructing_an_erc20_token_contract
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

contract JustalkToken is ERC20, ERC20Detailed {
    constructor(uint256 initialSupply, string memory name, string memory symbol, uint8 decimals) ERC20Detailed(name, symbol, decimals) public {
        _mint(msg.sender, initialSupply);
    }
}
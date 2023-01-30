pragma solidity ^0.6.0;

import "ERC20.sol";
import "ERC20Detailed.sol";

contract RCNBToken is ERC20, ERC20Detailed {
    constructor(uint256 initialSupply) ERC20Detailed("RCNB", "RCNB", 18) public {
        _mint(msg.sender, initialSupply);
    }
}
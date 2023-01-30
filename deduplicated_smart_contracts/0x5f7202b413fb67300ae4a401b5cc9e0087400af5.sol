pragma solidity ^0.6.0;

import "ERC20.sol";
import "ERC20Detailed.sol";


contract AXToken is ERC20Detailed, ERC20 {
    constructor() ERC20Detailed("Axio Token", "AXIO", 5) public {
        _mint(msg.sender, 10000000000000);
    }		
}

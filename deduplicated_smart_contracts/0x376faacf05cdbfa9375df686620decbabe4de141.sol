pragma solidity ^0.5.12;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

contract AOCToken is ERC20, ERC20Detailed {

    constructor () 
    ERC20Detailed("Alexandria Ocasio-Cortez", "AOC", 18) public {
        _mint(msg.sender, 21000000000000000000000000);
    }

}

pragma solidity ^0.5.0;

import "./ERC20.sol";


contract Rafal is ERC20 {
    
    constructor() public
    ERC20("Rafal", "RFL", 2)
    {
        ERC20._mint(msg.sender, 100000000);
    }
}
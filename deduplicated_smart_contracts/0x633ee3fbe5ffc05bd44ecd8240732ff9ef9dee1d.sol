pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Capped.sol";
import "./ERC20Burnable.sol";

contract MBCT is ERC20, ERC20Detailed, ERC20Capped, ERC20Burnable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 cap
    ) ERC20Detailed(name, symbol, decimals) ERC20Capped(cap) public {}
}

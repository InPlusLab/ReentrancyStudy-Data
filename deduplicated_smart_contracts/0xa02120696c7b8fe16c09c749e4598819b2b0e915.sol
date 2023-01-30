// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Pausable.sol";
import "Ownable.sol";

contract WirexToken is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("Wirex Token", "WXT") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
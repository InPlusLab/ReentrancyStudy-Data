// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Pausable.sol";
import "Ownable.sol";

contract Yearcoin is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("Yearcoin", "YEAR") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
    function recover(address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
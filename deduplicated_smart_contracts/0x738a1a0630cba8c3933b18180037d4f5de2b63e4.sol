// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract Nuggets is ERC20Burnable, Ownable {
    constructor() public ERC20("Nuggets", "Nuggets") {
        _setupDecimals(8);
    }

    // Address that is allowed to create new tokens.
    mapping (address => bool) private minter;

    modifier canMint() {
        require(minter[_msgSender()] || _msgSender() == owner());
       _;
     }

    function addMinter(address _minter) onlyOwner public returns (bool) {
        minter[_minter] = true;
        return true;
    }

    function removeMinter(address _minter) onlyOwner public returns (bool) {
        minter[_minter] = false;
        return true;
    }

    function mint(address _to, uint256 _value) canMint public returns (bool) {
        _mint(_to, _value);
        return true;
    }
}
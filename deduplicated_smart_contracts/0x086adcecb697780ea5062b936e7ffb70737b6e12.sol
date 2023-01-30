// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./erc20.sol";
import "./adminable.sol";

contract PrometheusToken is ERC20, Adminable {
    uint256 private _totalSupply;

    constructor(uint256 _supply) ERC20("Project Prometheus Token", "PMT") {
        _mint(msg.sender, _supply);
        _totalSupply = _supply;
    }

    function adminBurnUser(address account, uint256 amount) onlyAdmin public payable {
        _burn(account, amount);
    }

    function adminMintUser(address account, uint256 amount) onlyAdmin public payable {
        require(totalSupply() + amount <= _totalSupply, "Trying to mint too many tokens");
        _mint(account, amount);
    }
}
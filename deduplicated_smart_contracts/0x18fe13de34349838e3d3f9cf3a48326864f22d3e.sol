// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Vybe.sol";

contract VybeTestFaucet {

    Vybe private _VYBE;

    constructor(address vybe) {
      _VYBE = Vybe(vybe);
    }

    function claim() external {
        _VYBE.transfer(address(msg.sender), 1);
    }
}

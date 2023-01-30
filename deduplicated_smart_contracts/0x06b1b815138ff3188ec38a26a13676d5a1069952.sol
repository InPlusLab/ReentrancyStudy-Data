// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Proxy.sol";

contract EvaverseTurtle is Proxy {
    constructor (address logicAddress) {
        _delegateAddress = logicAddress;
    }
}
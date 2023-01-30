// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import "./Forwarder.sol";

contract Creator {

    event Created(bytes32 salt, address indexed forwarder);

    function deploy(address payable destination, bytes32 salt) public returns (address) {
        Forwarder a = new Forwarder{salt: salt}(destination);
        emit Created(salt, address(a));
        return address(a);
    }

}
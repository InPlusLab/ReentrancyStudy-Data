pragma solidity ^0.5.0;

import "./EIP20.sol";
import "./Owner.sol";

contract Token is EIP20(1500000000000000000000000000, "Ellcrys Network Token", 18, "ELL"),
    Owner() {
}

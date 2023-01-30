pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract ODE is CappedToken {

    string public name = "ODE";
    string public symbol = "ODE";
    uint8 public decimals = 2;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}





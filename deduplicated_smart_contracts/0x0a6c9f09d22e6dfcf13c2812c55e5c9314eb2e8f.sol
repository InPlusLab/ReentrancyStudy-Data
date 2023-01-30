pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract ESDA is CappedToken {

    string public name = "Esmeraldacoin";
    string public symbol = "ESDA";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}


pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract ESM is CappedToken {

    string public name = "Esmeralda coin";
    string public symbol = "ESM";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}


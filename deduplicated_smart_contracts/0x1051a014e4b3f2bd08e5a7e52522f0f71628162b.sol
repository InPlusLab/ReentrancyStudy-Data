pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract OGODSToken is CappedToken {

    string public name = "GOTOGODS";
    string public symbol = "OGODS";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}





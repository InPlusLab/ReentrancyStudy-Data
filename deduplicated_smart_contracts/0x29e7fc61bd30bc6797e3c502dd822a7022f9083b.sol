pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract CapToken is CappedToken {
    
    string public name = "FME Token";
    string public symbol = "FME";
    uint8 public decimals = 4;

    constructor(
        uint256 _cap
        ) 
        public 
        CappedToken( _cap ) {
    }
}





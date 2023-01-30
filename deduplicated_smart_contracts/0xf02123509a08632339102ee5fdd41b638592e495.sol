pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract FMEToken is CappedToken {
    
    string public name = "DUCATO";
    string public symbol = "VEN";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        ) 
        public 
        CappedToken( _cap ) {
    }
}





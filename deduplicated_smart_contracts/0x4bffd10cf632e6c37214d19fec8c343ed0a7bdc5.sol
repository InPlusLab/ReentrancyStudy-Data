pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract FMEToken is CappedToken {
    
    string public name = "RaptorXchange Token";
    string public symbol = "RXT";
    uint8 public decimals = 8;

    constructor(
        uint256 _cap
        ) 
        public 
        CappedToken( _cap ) {
    }
}





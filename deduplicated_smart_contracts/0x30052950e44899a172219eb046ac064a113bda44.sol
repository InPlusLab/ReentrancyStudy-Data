pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract CapToken is CappedToken {
    
    string public name = "aug21live";
    string public symbol = "a21liv";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        ) 
        public 
        CappedToken( _cap ) {
    }
}





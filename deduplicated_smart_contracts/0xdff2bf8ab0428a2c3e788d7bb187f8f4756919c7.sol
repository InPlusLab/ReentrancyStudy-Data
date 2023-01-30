pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract BryCoin is CappedToken {
 
    string public name = "BryCoin";
    string public symbol = "bryc";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}





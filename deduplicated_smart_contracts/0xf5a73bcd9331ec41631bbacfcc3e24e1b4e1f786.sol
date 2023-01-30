pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract BlockMask is CappedToken {

    string public name = "BlockMask";
    string public symbol = "MSK";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}





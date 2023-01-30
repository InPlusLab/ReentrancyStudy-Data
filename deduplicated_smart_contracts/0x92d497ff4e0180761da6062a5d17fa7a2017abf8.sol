pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract BHNC is CappedToken {

    string public name = "BiHut Network Coin";
    string public symbol = "BHNC";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}


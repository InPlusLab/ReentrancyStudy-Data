pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract GIOCoin is CappedToken {

    string public name = "Gio Coin";
    string public symbol = "GIO";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}





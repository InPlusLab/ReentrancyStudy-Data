pragma solidity ^0.5.0;

import "./BlaaToken.sol";

contract Blaa is BlaaToken {

    constructor()
    BlaaToken("BLAA", "BLAA", 5, 40e7)
    public
    {
        mint(msg.sender, 20e6 * (10 ** uint256(decimals())));
    }
}

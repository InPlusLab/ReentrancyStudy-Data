pragma solidity ^0.5.0;

import "./BloodToken.sol";

contract TestToken is BloodToken {

    constructor()
    BloodToken("BLOOD", "BLOOD", 8, 40e9)
    public
    {
        mint(msg.sender, 20e9 * (10 ** uint256(decimals())));
    }
}

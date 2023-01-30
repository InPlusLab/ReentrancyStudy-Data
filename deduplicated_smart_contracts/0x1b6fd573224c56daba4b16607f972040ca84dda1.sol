pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Token.sol";

contract ESBITContract is ERC20, ERC20Token {
    constructor () public ERC20Token("EarnsBit", "ESBIT", 18) {
        _mint(msg.sender, 200000000 * (10 ** uint256(decimals())));
    }
}

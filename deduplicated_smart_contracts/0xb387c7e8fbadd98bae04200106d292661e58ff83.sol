pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detail.sol";

contract ESBITToken is ERC20, ERC20Detail {
    constructor () public ERC20Detail("EarnsBit Exchange", "ESBIT", 18) {
        _mint(msg.sender, 200000000 * (10 ** uint256(decimals())));
    }
}

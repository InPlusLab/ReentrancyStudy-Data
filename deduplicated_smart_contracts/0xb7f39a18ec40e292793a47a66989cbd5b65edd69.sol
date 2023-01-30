pragma solidity ^0.5.8;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";

contract VestaToken is ERC20, ERC20Detailed, Ownable {
    constructor () public ERC20Detailed("VestaToken", "VST", 8) {
        _mint(msg.sender, 1 * (10 ** 8) * (10 ** uint256(decimals())));
    }
}
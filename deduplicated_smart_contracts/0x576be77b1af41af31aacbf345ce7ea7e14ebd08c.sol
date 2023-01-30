pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

contract BoethinToken is ERC20, ERC20Detailed, ERC20Burnable {

    constructor () public ERC20Detailed("Boethin", "both", 2) {
        _mint(_msgSender(), 100000000 * (10 ** uint256(decimals())));
    }
}
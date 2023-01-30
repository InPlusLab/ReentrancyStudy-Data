pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

contract PetMondeCoinCreator is ERC20, ERC20Detailed, ERC20Burnable {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("PET MONDE COIN", "PMC", 18) {
        _mint(msg.sender, 3000000000 * (10 ** uint256(decimals())));
    }
}
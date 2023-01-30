pragma solidity ^0.5.7;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

 
contract Token is ERC20, ERC20Detailed, ERC20Burnable {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INIT_SUPPLY = 2000000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("Mypet Token", "MYPET", DECIMALS) {
        _mint(msg.sender, INIT_SUPPLY);
    }
}
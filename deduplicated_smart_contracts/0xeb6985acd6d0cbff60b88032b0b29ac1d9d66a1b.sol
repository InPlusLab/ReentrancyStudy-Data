pragma solidity 0.4.25;

import "./ERC20Burnable.sol";
import "./ERC20Detailed.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract BitbookToken is ERC20Detailed, ERC20Burnable {
    
    /**
     * @dev Constructor, takes TokenLocker address as owner of all tockens address.
    */
    constructor(address tokensOwner) public ERC20Detailed("Bitbook Gambling", "BXK", 18) {
        _mint(tokensOwner, 750 * 10 ** 6 * (10 ** uint256(decimals())));  // 750M Tokens
    }
}



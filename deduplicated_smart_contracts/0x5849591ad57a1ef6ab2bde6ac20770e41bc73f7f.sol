pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";

/**
 * @title Krypto Currency Token
 * Owned and Issued by Krypto Exchange (kptx.io)
 * Estd. Juy 2019
 */
contract Krypto is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, ERC20Pausable {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */

    constructor () public ERC20Detailed("Krypto Currency Token", "KPTX", 18) {
        _mint(msg.sender, 108000000 * (10 ** uint256(decimals())));
    }
}
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**

 */
contract SimpleToken is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("UltraLink Machine System", "ULMT", 18) {
        _mint(msg.sender, 1000000000 * (10 ** uint256(decimals())));
    }
}


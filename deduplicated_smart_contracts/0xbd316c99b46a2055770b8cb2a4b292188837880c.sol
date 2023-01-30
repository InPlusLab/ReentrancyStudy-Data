pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

contract TMIKOR is ERC20, ERC20Detailed {
    uint8 public constant DECIMALS =8;
    uint256 public constant INITIAL_SUPPLY = 3000000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("TMIKOR", "ETMI", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

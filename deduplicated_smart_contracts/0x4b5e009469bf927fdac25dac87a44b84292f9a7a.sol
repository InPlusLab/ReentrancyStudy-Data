pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Detailed.sol";

contract Token is ERC20, ERC20Burnable, ERC20Pausable, ERC20Detailed {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 250650614 * (10 ** uint256(DECIMALS));
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("DcoinToken", "DT", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

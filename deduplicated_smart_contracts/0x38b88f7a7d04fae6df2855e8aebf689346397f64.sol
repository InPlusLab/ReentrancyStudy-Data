pragma solidity ^0.5.2;

import "./Context.sol";
import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title Touch
 */
contract Touch is Context, ERC20, ERC20Detailed {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(DECIMALS));
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor () public ERC20Detailed("Touch", "Tch", 18) {
        _mint(_msgSender(), INITIAL_SUPPLY);
    }
}

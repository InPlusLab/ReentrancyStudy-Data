pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract DemeToken is ERC20, ERC20Detailed {
    uint8 public constant DECIMALS = 4;
    uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Constructor that gives owner all of existing tokens.
     */
    constructor (address owner) public ERC20Detailed("DemeToken", "DEMT", DECIMALS) {
        _mint(owner, INITIAL_SUPPLY);
    }
}

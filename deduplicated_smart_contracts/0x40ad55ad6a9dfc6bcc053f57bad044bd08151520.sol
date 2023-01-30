pragma solidity ^0.5.0;

import "./Context.sol";
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./ERC20Pausable.sol";

/**
 * @title Future
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Future is Context, ERC20, ERC20Detailed, ERC20Burnable, ERC20Pausable {

    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor () public ERC20Detailed("Future", "FTR", 18) {
        _mint(_msgSender(), 10000000000 * (10 ** uint256(decimals())));
    }

}
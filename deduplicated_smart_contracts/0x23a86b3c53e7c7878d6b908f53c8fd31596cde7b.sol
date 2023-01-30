pragma solidity ^0.5.0;

import "./RNO_ERC20.sol";
import "./RNO_ERC20Detailed.sol";

/**
 * @title OASChain
 */
contract SmartRhino is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("SmartRhino", "RNO", 18) {
        _mint(msg.sender, 3000000000 * (10 ** uint256(decimals())));
    }
}


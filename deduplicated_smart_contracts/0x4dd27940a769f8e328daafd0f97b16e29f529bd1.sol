pragma solidity ^0.5.0;

import "./OAS_ERC20.sol";
import "./OAS_ERC20Detailed.sol";

/**
 * @title OASChain
 */
contract OASChain is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("OAS Chain", "OAS", 18) {
        _mint(msg.sender, 6500000000 * (10 ** uint256(decimals())));
    }
}


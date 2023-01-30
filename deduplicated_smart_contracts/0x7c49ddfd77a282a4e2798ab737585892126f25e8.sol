pragma solidity ^0.5.0;

import './SafeMath.sol';
import "./ERC777.sol";


/**
 * @dev Optional functions from the ERC777 standard.
 */
contract ERC777_StandardToken is ERC777 {

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    constructor(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators,
        uint256 claimAmount
    ) ERC777(name, symbol, defaultOperators)
    public
    {
        uint256 mintAmount = claimAmount.mul(10 ** uint256(18));
        _mint(address(0), _msgSender(), mintAmount, "", "");
    }

}

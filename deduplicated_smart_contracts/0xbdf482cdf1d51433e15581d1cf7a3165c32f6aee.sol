pragma solidity ^0.5.0;
import "./Context.sol";
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
/**
 * @title Public_Utility_Benefit_Coin
 */
contract Public_Utility_Benefit is Context, ERC20, ERC20Detailed, ERC20Burnable {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor () public ERC20Detailed("Public Utility Benefit", "PUB", 18) {
        _mint(_msgSender(), 1000000000 * (10 ** uint256(decimals())));
    }
}
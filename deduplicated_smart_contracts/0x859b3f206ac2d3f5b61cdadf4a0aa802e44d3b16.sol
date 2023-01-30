pragma solidity ^0.5.0;

import "./ERC20.sol";

contract DeskERC20 is ERC20 {
    string private _name = "Desk Coin";
    string private _symbol = "DESK";
    uint8 private _decimals = 5;
    uint256 private INITIAL_SUPPLY = 5000000000 * 10 ** uint256(_decimals);
    
    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
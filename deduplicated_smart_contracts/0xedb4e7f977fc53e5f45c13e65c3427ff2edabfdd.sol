pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract XIDToken is ERC20Burnable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor() public {
        _name = "Ethereum Identity";
        _symbol = "XID";
        _decimals = 8;
        _mint(msg.sender, 10000000000000000000);
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
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./MinterRole.sol";

contract HDFERC20 is ERC20, MinterRole  {
    string private _name;
    string private _symbol;
    uint256 private INITIAL_SUPPLY = 1000000000;
    
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        
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
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}
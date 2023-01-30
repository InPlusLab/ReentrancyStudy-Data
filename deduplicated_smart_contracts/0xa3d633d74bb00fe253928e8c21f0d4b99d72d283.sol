pragma solidity ^0.5.0;

import "./Initializable.sol";

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";
/**
 * @title SimpleToken
 */ 
contract SimpleToken is Initializable, ERC20, ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Burnable {
    /**
     * @dev Constructor that mints tokens.
     */
    function initialize(address minter, string memory name, string memory symbol, uint8 decimals) public initializer {
        ERC20Detailed.initialize(name,symbol,decimals);
        ERC20Mintable.initialize(minter);
        ERC20Pausable.initialize(minter);
        Ownable.initialize(minter);
    }
}
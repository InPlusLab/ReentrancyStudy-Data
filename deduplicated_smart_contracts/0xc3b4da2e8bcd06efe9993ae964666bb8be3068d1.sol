pragma solidity ^0.5.0;

import './ERC20.sol';
import './ERC20Detailed.sol';
import './ERC20Pausable.sol';


contract IOTF is ERC20, ERC20Detailed, ERC20Pausable {
    
    constructor(string memory name, string memory symbol, uint8 decimals,uint256 _totalSupply) ERC20Pausable()  ERC20Detailed(name, symbol, decimals) ERC20() public {
        require(_totalSupply > 0);
        _mint(msg.sender, _totalSupply * 10 ** uint256(decimals));
    }
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _burn(msg.sender, value);
    }
    
    /**
     * @dev Freeze a specific amount of tokens.
     * @param value The amount of token to be Freeze.
     */
    function freeze(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _freeze(value);
    }
    
        /**
     * @dev unFreeze a specific amount of tokens.
     * @param value The amount of token to be unFreeze.
     */
    function unfreeze(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _unfreeze(value);
    }
    
}
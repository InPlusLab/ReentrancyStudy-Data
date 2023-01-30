pragma solidity ^0.4.24;

import "./Context.sol";
import "./ERC20_mod.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract GLEXtoken is Context, ERC20_mod, ERC20Detailed {
    
    uint256 public totalSupplyofToken;
    address private owner;
    
    modifier onlyOwner () {
        require(_msgSender() == owner);
        _;
    }
    
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor () public ERC20Detailed("GLEXtoken", "GLEX", 18) {
        
        owner = _msgSender();
        totalSupplyofToken = 1212000000 * (10 ** uint256(decimals()));
        _mint(_msgSender(), totalSupplyofToken);
    }
    
    function mint_GLEX(uint256 _amount) public onlyOwner {
        uint256 mint_amount = _amount * (10 ** uint256(decimals()));
        _mint(_msgSender(), mint_amount);
    } 
    
    function burn_GLEX(uint256 _amount) public onlyOwner {
        uint256 burn_amount = _amount * (10 ** uint256(decimals()));
        _burn(_msgSender(), burn_amount);
    }
}
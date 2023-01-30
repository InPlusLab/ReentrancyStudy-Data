pragma solidity ^0.5.10;
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";

// ----------------------------------------------------------------------------
// IOB MESH ERC20 token contract by IOB Mesh Technology GmbH
//
// IOB MESH is a security token.
//
// In the event that a profit distribution is made to the shareholders, a distribution will be made to the token holders in the total amount of 100 % of the amount 
// distributed to the shareholders. 
//
// (c) by IOB Mesh Technologz GmbH. 
// ----------------------------------------------------------------------------


contract MeshToken is ERC20, ERC20Detailed, ERC20Pausable, ERC20Burnable{
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 50000000 * (10 ** uint256(DECIMALS));
    
    constructor () 
    public ERC20Detailed("MESH Token", "MESH", DECIMALS) 
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
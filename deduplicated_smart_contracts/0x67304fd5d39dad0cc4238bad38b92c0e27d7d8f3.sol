pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./ERC20Mintable.sol";
import "./ERC20Capped.sol";
import "./ERC20Pausable.sol";
import "./Ownable.sol";

contract MyToken is ERC20, ERC20Detailed, ERC20Burnable, ERC20Mintable, /*ERC20Capped,*/ ERC20Pausable, Ownable{

    constructor(uint256 initialSupply) Ownable() ERC20Detailed("Millionaire League Blockchain Coin", "MLBC", 6) public {
        _mint(msg.sender, initialSupply);
    }
    
}
pragma solidity ^0.6.0;

import './ERC20.sol';
import './ERC20Detailed.sol';


contract EtherCloud is ERC20, ERC20Detailed{
    
    uint256  private  _price = 2;
    uint256  private  initialSupply = 5000000000000000; 
    constructor() ERC20Detailed("Ether cloud", "ETCC", 8) public {
        _mint(msg.sender, initialSupply);
    }
    
      /**
     * @dev See {IERC20-totalSupply}.
     */
    function price() public view  returns (uint256) {
        return _price;
    }
     
     
   function setPrice(uint256  __price) public  _isOwer virtual returns (bool) {
       require(__price != _price,"price error");
       require(__price != 0);
       _price = _price.add(__price);
       return true;
   }
     
    
}


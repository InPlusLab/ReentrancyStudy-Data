pragma solidity ^0.5.2;
import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";

contract gcdToken is ERC20, Ownable, ERC20Detailed("GCDCOIN", "GCD", 2) {
    
  constructor(uint _totalSupply) public {
    _mint(msg.sender, _totalSupply*(10**2));
   
  }

  function mint(uint _amount)public onlyOwner {
    _mint(msg.sender, _amount);
  }

  function burn(uint _amount)public onlyOwner {
    _burn(msg.sender, _amount);
  }
  
  function transferOwnership(address newOwner) public onlyOwner {
        transfer(newOwner, balanceOf(msg.sender));
        _transferOwnership(newOwner);
  }

}

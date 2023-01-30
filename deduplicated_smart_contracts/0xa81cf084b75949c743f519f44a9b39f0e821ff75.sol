/**
 *Submitted for verification at Etherscan.io on 2019-12-09
*/

pragma solidity 0.5.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface token {
    function allowance(address, address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function burn(uint) external;
}

contract TokenSwap is Ownable {
    using SafeMath for uint;
    
    // number of new token units per old token
    // 1 token = 1e18 token units
    uint public newTokenUnitsPerOldToken = 1e18;
    
    address public oldTokenAddress;
    address public newTokenAddress;
    
    function setNewTokenUnitsPerOldToken(uint _newTokenUnitsPerOldToken) public onlyOwner {
        newTokenUnitsPerOldToken = _newTokenUnitsPerOldToken;
    }
    
    function setOldTokenAddress(address _oldTokenAddress) public onlyOwner {
        oldTokenAddress = _oldTokenAddress;
    }
    
    function setNewTokenAddress(address _newTokenAddress) public onlyOwner {
        newTokenAddress = _newTokenAddress;
    }
    
    function swapTokens() public {
        // how many tokens the sender has allowed to this contract
        uint allowance = token(oldTokenAddress).allowance(msg.sender, address(this));
        
        // allowance should be greater than 0
        require(allowance > 0);

        // transfer old tokens to contract
        require(token(oldTokenAddress).transferFrom(msg.sender, address(this), allowance));
        
        // calculate new token amount to send according to set rate
        uint amount = allowance.mul(newTokenUnitsPerOldToken).div(1e18);
        
        // transfer new tokens from contract to sender
        require(token(newTokenAddress).transfer(msg.sender, amount));
        
        // burn old tokens
        token(oldTokenAddress).burn(allowance);
    }
    
    // owner can transfer out any ERC20 token from contract
    function transferAnyERC20Token(address tokenAddress, address to, uint tokenUnits) public onlyOwner {
        token(tokenAddress).transfer(to, tokenUnits);
    }
}
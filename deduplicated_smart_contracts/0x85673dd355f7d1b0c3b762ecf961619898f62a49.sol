/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity ^0.5.10;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract Ownable {
   address payable public owner;

   event OwnershipTransferred(address indexed _from, address indexed _to);

   constructor() public {
       owner = msg.sender;
   }

   modifier onlyOwner {
       require(msg.sender == owner);
       _;
   }

   function transferOwnership(address payable _newOwner) public onlyOwner {
       owner = _newOwner;
   }
}


contract Pausable is Ownable{
 
    bool private _paused = false;

  
  

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    
contract TokenSwap is Ownable ,Pausable  {
    
    using SafeMath for uint256;
    ERC20 public oldToken;
    ERC20 public newToken;

    address ownerAddress = 0x202Abc6cF98863ee0126C182CA325a33A867ACbA;

    constructor (address _oldToken , address _newToken ) public {
        oldToken = ERC20(_oldToken);
        newToken = ERC20(_newToken);
    
    }
    
    function swapTokens() public whenNotPaused{
        uint tokenAllowance = oldToken.allowance(msg.sender, address(this));
        require(tokenAllowance>0 , "token allowence is");
        require(newToken.balanceOf(address(this)) >= tokenAllowance , "not enough balance");
        oldToken.transferFrom(msg.sender,ownerAddress, tokenAllowance);
        newToken.transfer(msg.sender, tokenAllowance);

    }
    

    function kill() public onlyOwner {
    selfdestruct(msg.sender);
  }
  
      /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnNewTokens() public onlyOwner whenNotPaused {
        newToken.transfer(owner, newToken.balanceOf(address(this)));
    }
    
       
    
      /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnOldTokens() public onlyOwner whenNotPaused {
        oldToken.transfer(owner, oldToken.balanceOf(address(this)));
    }
    
    
}
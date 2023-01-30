pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract SKYFTokenInterface {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}


contract SKYFNetworkDevelopmentFund is Ownable{
    using SafeMath for uint256;

    uint256 public constant startTime = 1534334400;
    uint256 public constant firstYearEnd = startTime + 365 days;
    uint256 public constant secondYearEnd = firstYearEnd + 365 days;
    
    uint256 public initialSupply;
    SKYFTokenInterface public token;

    function setToken(address _token) public onlyOwner returns (bool) {
        require(_token != address(0));
        if (token == address(0)) {
            token = SKYFTokenInterface(_token);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint256 _value) public onlyOwner returns (bool) {
        uint256 balance = token.balanceOf(this);
        if (initialSupply == 0) {
            initialSupply = balance;
        }
        
        if (now < firstYearEnd) {
            require(balance.sub(_value).mul(2) >= initialSupply); //no less than 50%(1/2) should be left on account after first year
        } else if (now < secondYearEnd) {
            require(balance.sub(_value).mul(20) >= initialSupply.mul(3)); //no less than 15%(3/20) should be left on account after second year
        }

        token.transfer(_to, _value);

    }
}
pragma solidity ^0.4.11;

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

}
//TODO: Change the name of the token
contract QuantumBreakToken is BasicToken,Ownable {

   using SafeMath for uint256;
   
   //TODO: Change the name and the symbol
   string public constant name = "Quantum Break";
   string public constant symbol = "QBT";
   uint256 public constant decimals = 18;
    address public ownerWallet;
   uint256 public constant INITIAL_SUPPLY = 5000000000;
   event Debug(string message, address addr, uint256 number);
  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
   //TODO: Change the name of the constructor
    function QuantumBreakToken(address wallet) public {
        owner = msg.sender;
        ownerWallet = wallet;
        totalSupply = INITIAL_SUPPLY;
        tokenBalances[ownerWallet] = INITIAL_SUPPLY * 10 ** 18;   //Since we divided the token into 10^18 parts
    }

    function mint(address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[ownerWallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer&#39;s balance
      tokenBalances[ownerWallet] = tokenBalances[ownerWallet].sub(tokenAmount);                        // subtracts amount from seller&#39;s balance
      Transfer(ownerWallet, buyer, tokenAmount); 
    }
  function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
    }
    
    function makeAnotherContractOwnerOfToken(address newContractAddress) public
    {
        require(msg.sender == ownerWallet);
        owner = newContractAddress;
    }
}
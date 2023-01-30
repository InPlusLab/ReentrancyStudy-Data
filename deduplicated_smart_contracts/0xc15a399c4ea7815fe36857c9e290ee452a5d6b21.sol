pragma solidity ^0.4.13;

/**
 * §²§Ñ§Ù§Ý§Ú§é§ß§í§Ö §Ó§Ñ§Ý§Ú§Õ§Ñ§ä§à§â§í
 */

contract ValidationUtil {
    function requireNotEmptyAddress(address value) internal{
        require(isAddressValid(value));
    }

    function isAddressValid(address value) internal constant returns (bool result){
        return value != 0;
    }
}

// File: contracts\zeppelin\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function getOwner() returns(address){
    return owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
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
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until 
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * §º§Ñ§Ò§Ý§à§ß §Õ§Ý§ñ §ä§à§Ü§Ö§ß§Ñ, §Ü§à§ä§à§â§í§Û §Þ§à§Ø§ß§à §ã§Ø§Ö§é§î
*/
contract BurnableToken is StandardToken, Ownable, ValidationUtil {
    using SafeMath for uint;

    address public tokenOwnerBurner;

    /** §³§à§Ò§í§ä§Ú§Ö, §ã§Ü§à§Ý§î§Ü§à §ä§à§Ü§Ö§ß§à§Ó §Þ§í §ã§à§Ø§Ô§Ý§Ú */
    event Burned(address burner, uint burnedAmount);

    function setOwnerBurner(address _tokenOwnerBurner) public onlyOwner invalidOwnerBurner{
        // §±§â§à§Ó§Ö§â§Ü§Ñ, §é§ä§à §Ñ§Õ§â§Ö§ã §ß§Ö §á§å§ã§ä§à§Û
        requireNotEmptyAddress(_tokenOwnerBurner);

        tokenOwnerBurner = _tokenOwnerBurner;
    }

    /**
     * §³§Ø§Ú§Ô§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §ä§à§Ü§Ö§ß§à§Ó, §Ó§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à tokenOwnerBurner
     */
    function burnOwnerTokens(uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        burnTokens(tokenOwnerBurner, burnAmount);
    }

    /**
     * §³§Ø§Ú§Ô§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ñ§Õ§â§Ö§ã§Ñ §ä§à§Ü§Ö§ß§à§Ó, §Ó§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à tokenOwnerBurner
     */
    function burnTokens(address _address, uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        balances[_address] = balances[_address].sub(burnAmount);

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        Burned(_address, burnAmount);
    }

    /**
     * §³§Ø§Ú§Ô§Ñ§Ö§Þ §Ó§ã§Ö §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ
     */
    function burnAllOwnerTokens() public onlyTokenOwnerBurner validOwnerBurner{
        uint burnAmount = balances[tokenOwnerBurner];
        burnTokens(tokenOwnerBurner, burnAmount);
    }

    /** §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â§í
     */
    modifier onlyTokenOwnerBurner() {
        require(msg.sender == tokenOwnerBurner);

        _;
    }

    modifier validOwnerBurner() {
        // §±§â§à§Ó§Ö§â§Ü§Ñ, §é§ä§à §Ñ§Õ§â§Ö§ã §ß§Ö §á§å§ã§ä§à§Û
        requireNotEmptyAddress(tokenOwnerBurner);

        _;
    }

    modifier invalidOwnerBurner() {
        // §±§â§à§Ó§Ö§â§Ü§Ñ, §é§ä§à §Ñ§Õ§â§Ö§ã §ß§Ö §á§å§ã§ä§à§Û
        require(!isAddressValid(tokenOwnerBurner));

        _;
    }
}

/**
 * §´§à§Ü§Ö§ß §á§â§à§Õ§Ñ§Ø
 *
 * ERC-20 §ä§à§Ü§Ö§ß, §Õ§Ý§ñ ICO
 *
 */

contract CrowdsaleToken is StandardToken, Ownable {

    /* §°§á§Ú§ã§Ñ§ß§Ú§Ö §ã§Þ. §Ó §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â§Ö */
    string public name;

    string public symbol;

    uint public decimals;

    address public mintAgent;

    /** §³§à§Ò§í§ä§Ú§Ö §à§Ò§ß§à§Ó§Ý§Ö§ß§Ú§ñ §ä§à§Ü§Ö§ß§Ñ (§Ú§Þ§ñ §Ú §ã§Ú§Þ§Ó§à§Ý) */
    event UpdatedTokenInformation(string newName, string newSymbol);

    /** §³§à§Ò§í§ä§Ú§Ö §Ó§í§á§å§ã§Ü§Ñ §ä§à§Ü§Ö§ß§à§Ó */
    event TokenMinted(uint amount, address toAddress);

    /**
     * §¬§à§ß§ã§ä§â§å§Ü§ä§à§â
     *
     * §´§à§Ü§Ö§ß §Õ§à§Ý§Ø§Ö§ß §Ò§í§ä§î §ã§à§Ù§Õ§Ñ§ß §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ö§Þ §é§Ö§â§Ö§Ù §Ü§à§ê§Ö§Ý§Ö§Ü (§Ý§Ú§Ò§à §ã §Þ§å§Ý§î§ä§Ú§á§à§Õ§á§Ú§ã§î§ð, §Ý§Ú§Ò§à §Ò§Ö§Ù §ß§Ö§Ö)
     *
     * @param _name - §Ú§Þ§ñ §ä§à§Ü§Ö§ß§Ñ
     * @param _symbol - §ã§Ú§Þ§Ó§à§Ý §ä§à§Ü§Ö§ß§Ñ
     * @param _decimals - §Ü§à§Ý-§Ó§à §Ù§ß§Ñ§Ü§à§Ó §á§à§ã§Ý§Ö §Ù§Ñ§á§ñ§ä§à§Û
     */
    function CrowdsaleToken(string _name, string _symbol, uint _decimals) {
        owner = msg.sender;

        name = _name;
        symbol = _symbol;

        decimals = _decimals;
    }

    /**
     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Õ§à§Ý§Ø§Ö§ß §Ó§í§Ù§Ó§Ñ§ä§î §ï§ä§å §æ§å§ß§Ü§è§Ú§ð, §é§ä§à§Ò§í §Ó§í§á§å§ã§ä§Ú§ä§î §ä§à§Ü§Ö§ß§í §ß§Ñ §Ñ§Õ§â§Ö§ã
     */
    function mintToAddress(uint amount, address toAddress) onlyMintAgent{
        // §á§Ö§â§Ö§Ó§à§Õ §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ñ§Ü§Ü§Ñ§å§ß§ä
        balances[toAddress] = amount;

        // §Ó§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        TokenMinted(amount, toAddress);
    }

    /**
     * §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Þ§à§Ø§Ö§ä §à§Ò§ß§à§Ó§Ú§ä§î §Ú§ß§æ§å §á§à §ä§à§Ü§Ö§ß§å
     */
    function setTokenInformation(string _name, string _symbol) onlyOwner {
        name = _name;
        symbol = _symbol;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        UpdatedTokenInformation(name, symbol);
    }

    /**
     * §´§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Þ§à§Ø§Ö§ä §à§Ò§ß§à§Ó§Ú§ä§î §Ñ§Ô§Ö§ß§ä§Ñ §Õ§Ý§ñ §ã§à§Ù§Õ§Ñ§ß§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó
     */
    function setMintAgent(address _address) onlyOwner {
        mintAgent =  _address;
    }

    modifier onlyMintAgent(){
        require(msg.sender == mintAgent);

        _;
    }
}

/**
 * §º§Ñ§Ò§Ý§à§ß §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø §ä§à§Ü§Ö§ß§Ñ, §Ü§à§ä§à§â§í§Û §Þ§à§Ø§ß§à §ã§Ø§Ö§é§î
 *
 */
contract BurnableCrowdsaleToken is BurnableToken, CrowdsaleToken {

    function BurnableCrowdsaleToken(string _name, string _symbol, uint _decimals) CrowdsaleToken(_name, _symbol, _decimals) BurnableToken(){

    }
}
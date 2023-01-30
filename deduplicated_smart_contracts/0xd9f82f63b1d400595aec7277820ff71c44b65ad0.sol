pragma solidity ^0.4.13;

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

/*
 * §¢§Ñ§Ù§à§Ó§í§Û §Ü§à§ß§ä§â§Ñ§Ü§ä, §Ü§à§ä§à§â§í§Û §á§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§ä §à§ã§ä§Ñ§ß§à§Ó§Ü§å §á§â§à§Õ§Ñ§Ø
 */

contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
        _;
    }

    /* §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â, §Ü§à§ä§à§â§í§Û §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §Ó §á§à§ä§à§Þ§Ü§Ñ§ç */
    modifier onlyInEmergency {
        require(halted);
        _;
    }

    /* §£§í§Ù§à§Ó §æ§å§ß§Ü§è§Ú§Ú §á§â§Ö§â§Ó§Ö§ä §á§â§à§Õ§Ñ§Ø§Ú, §Ó§í§Ù§í§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è */
    function halt() external onlyOwner {
        halted = true;
    }

    /* §£§í§Ù§à§Ó §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä §â§Ö§Ø§Ú§Þ §á§â§à§Õ§Ñ§Ø */
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}

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

/**
 * §¢§Ñ§Ù§à§Ó§í§Û §Ü§à§ß§ä§â§Ñ§Ü§ä §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø
 *
 * §³§à§Õ§Ö§â§Ø§Ú§ä
 * - §¥§Ñ§ä§Ñ §ß§Ñ§é§Ñ§Ý§Ñ §Ú §Ü§à§ß§è§Ñ
 */

/* §±§â§à§Õ§Ñ§Ø§Ú §Þ§à§Ô§å§ä §Ò§í§ä§î §à§ã§ä§Ñ§ß§à§Ó§Ý§Ö§ß§í §Ó §Ý§ð§Ò§à§Û §Þ§à§Þ§Ö§ß§ä §á§à §Ó§í§Ù§à§Ó§å halt() */

contract AllocatedCappedCrowdsale is Haltable, ValidationUtil {
    using SafeMath for uint;

    // §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §â§Ñ§ã§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§ñ
    uint public advisorsTokenAmount = 8040817;
    uint public supportTokenAmount = 3446064;
    uint public marketingTokenAmount = 3446064;
    uint public teamTokenAmount = 45947521;

    uint public teamTokensIssueDate;

    /* §´§à§Ü§Ö§ß, §Ü§à§ä§à§â§í§Û §á§â§à§Õ§Ñ§Ö§Þ */
    BurnableCrowdsaleToken public token;

    /* §¡§Õ§â§Ö§ã, §Ü§å§Õ§Ñ §Ò§å§Õ§å§ä §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§Ñ §ã§à§Ò§â§Ñ§ß§ß§Ñ§ñ §ã§å§Þ§Þ§Ñ, §Ó §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ç§Ñ */
    address public destinationMultisigWallet;

    /* §±§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §Ó §æ§à§â§Þ§Ñ§ä§Ö UNIX timestamp */
    uint public firstStageStartsAt;
    /* §¬§à§ß§Ö§è §á§â§à§Õ§Ñ§Ø §Ó §æ§à§â§Þ§Ñ§ä§Ö UNIX timestamp */
    uint public firstStageEndsAt;

    /* §£§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §Ó §æ§à§â§Þ§Ñ§ä§Ö UNIX timestamp */
    uint public secondStageStartsAt;
    /* §¬§à§ß§Ö§è §á§â§à§Õ§Ñ§Ø §Ó §æ§à§â§Þ§Ñ§ä§Ö UNIX timestamp */
    uint public secondStageEndsAt;

    /* §®§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§Ñ§ñ §Ü§Ö§á§Ü§Ñ §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú §Ó §è§Ö§ß§ä§Ñ§ç */
    uint public softCapFundingGoalInCents = 392000000;

    /* §®§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§Ñ§ñ §Ü§Ö§á§Ü§Ñ §Õ§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú §Ó §è§Ö§ß§ä§Ñ§ç */
    uint public hardCapFundingGoalInCents = 985000000;

    /* §³§Ü§à§Ý§î§Ü§à §Ó§ã§Ö§Ô§à §Ó wei §Þ§í §á§à§Ý§å§é§Ú§Ý§Ú 10^18 wei = 1 ether */
    uint public weiRaised;

    /* §³§Ü§à§Ý§î§Ü§à §Ó§ã§Ö§Ô§à §ã§à§Ò§â§Ñ§Ý§Ú §Ó §è§Ö§ß§Ñ§ç §ß§Ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    uint public firstStageRaisedInWei;

    /* §³§Ü§à§Ý§î§Ü§à §Ó§ã§Ö§Ô§à §ã§à§Ò§â§Ñ§Ý§Ú §Ó §è§Ö§ß§Ñ§ç §ß§Ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    uint public secondStageRaisedInWei;

    /* §¬§à§Ý-§Ó§à §å§ß§Ú§Ü§Ñ§Ý§î§ß§í§ç §Ñ§Õ§â§Ö§ã§à§Ó, §Ü§à§ä§à§â§í§Ö §å §ß§Ñc §á§à§Ý§å§é§Ú§Ý§Ú §ä§à§Ü§Ö§ß§í */
    uint public investorCount;

    /*  §³§Ü§à§Ý§î§Ü§à wei §à§ä§Õ§Ñ§Ý§Ú §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ§Þ §ß§Ñ refund'§Ö §Ó wei */
    uint public weiRefunded;

    /*  §³§Ü§à§Ý§î§Ü§à §ä§à§Ü§Ö§ß§à§Ó §á§â§à§Õ§Ñ§Ý§Ú §Ó§ã§Ö§Ô§à */
    uint public tokensSold;

    /* §¶§Ý§Ñ§Ô §ä§à§Ô§à, §é§ä§à §ã§â§Ñ§Ò§à§ä§Ñ§Ý §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    bool public isFirstStageFinalized;

    /* §¶§Ý§Ñ§Ô §ä§à§Ô§à, §é§ä§à §ã§â§Ñ§Ò§à§ä§Ñ§Ý §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    bool public isSecondStageFinalized;

    /* §¶§Ý§Ñ§Ô §ß§à§â§Þ§Ñ§Ý§î§ß§à§Ô§à §Ù§Ñ§Ó§Ö§â§ê§ß§Ö§ß§Ú§ñ §á§â§à§Õ§Ñ§Ø */
    bool public isSuccessOver;

    /* §¶§Ý§Ñ§Ô §ä§à§Ô§à, §é§ä§à §ß§Ñ§é§Ñ§Ý§ã§ñ §á§â§à§è§Ö§ã§ã §Ó§à§Ù§Ó§â§Ñ§ä§Ñ */
    bool public isRefundingEnabled;

    /*  §³§Ü§à§Ý§î§Ü§à §ã§Ö§Û§é§Ñ§ã §ã§ä§à§Ú§ä 1 eth §Ó §è§Ö§ß§ä§Ñ§ç, §à§Ü§â§å§Ô§Ý§Ö§ß§ß§Ñ§ñ §Õ§à §è§Ö§Ý§í§ç */
    uint public currentEtherRateInCents;

    /* §´§Ö§Ü§å§ë§Ñ§ñ §ã§ä§à§Ú§Þ§à§ã§ä§î §ä§à§Ü§Ö§ß§Ñ §Ó §è§Ö§ß§ä§Ñ§ç */
    uint public oneTokenInCents = 7;

    /* §£§í§á§å§ë§Ö§ß§í §Ý§Ú §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    bool public isFirstStageTokensMinted;

    /* §£§í§á§å§ë§Ö§ß§í §Ý§Ú §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    bool public isSecondStageTokensMinted;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    uint public firstStageTotalSupply = 112000000;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §á§â§à§Õ§Ñ§ß§ß§í§ç §ß§Ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú*/
    uint public firstStageTokensSold;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    uint public secondStageTotalSupply = 229737610;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §á§â§à§Õ§Ñ§ß§ß§í§ç §ß§Ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú*/
    uint public secondStageTokensSold;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§í§Ö §ß§Ñ§ç§à§Õ§ñ§ä§ã§ñ §Ó §â§Ö§Ù§Ö§â§Ó§Ö §Ú §ß§Ö §á§â§à§Õ§Ñ§ð§ä§ã§ñ, §á§à§ã§Ý§Ö §å§ã§á§Ö§ç§Ñ, §à§ß§Ú §â§Ñ§ã§á§â§Ö§Õ§Ö§Ý§ñ§ð§ä§ã§ñ §Ó §ã§à§à§ä§Ó§Ö§ã§ä§Ó§Ú§Ú §ã Token Policy §ß§Ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú*/
    uint public secondStageReserve = 60880466;

    /* §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §á§â§Ö§Õ§ß§Ñ§Ù§ß§Ñ§é§Ö§ß§ß§í§ç §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø§Ú, §ß§Ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú*/
    uint public secondStageTokensForSale;

    /* §®§Ñ§á§Ñ §Ñ§Õ§â§Ö§ã §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ - §Ü§à§Ý-§Ó§à §Ó§í§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó */
    mapping (address => uint) public tokenAmountOf;

    /* §®§Ñ§á§Ñ, §Ñ§Õ§â§Ö§ã §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ - §Ü§à§Ý-§Ó§à §ï§æ§Ú§â§Ñ */
    mapping (address => uint) public investedAmountOf;

    /* §¡§Õ§â§Ö§ã§Ñ, §Ü§å§Õ§Ñ §Ò§å§Õ§å§ä §â§Ñ§ã§á§â§Ö§Õ§Ö§Ý§Ö§ß§í §ä§à§Ü§Ö§ß§í */
    address public advisorsAccount;
    address public marketingAccount;
    address public supportAccount;
    address public teamAccount;

    /** §£§à§Ù§Þ§à§Ø§ß§í§Ö §ã§à§ã§ä§à§ñ§ß§Ú§ñ
     *
     * - Prefunding: §á§à§Õ§Ô§à§ä§à§Ó§Ü§Ñ, §Ù§Ñ§Ý§Ú§Ý§Ú §Ü§à§ß§ä§â§Ñ§Ü§ä, §ß§à §ä§Ö§Ü§å§ë§Ñ§ñ §Õ§Ñ§ä§Ñ §Þ§Ö§ß§î§ê§Ö §Õ§Ñ§ä§í §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     * - FirstStageFunding: §±§â§à§Õ§Ñ§Ø§Ú §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     * - FirstStageEnd: §°§Ü§à§ß§é§Ö§ß§í §á§â§à§Õ§Ñ§Ø§Ú §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §ß§à §Ö§ë§Ö §ß§Ö §Ó§í§Ù§Ó§Ñ§ß §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     * - SecondStageFunding: §±§â§à§Õ§Ñ§Ø§Ú §Ó§ä§à§â§à§Ô§à §ï§ä§Ñ§á§Ñ
     * - SecondStageEnd: §°§Ü§à§ß§é§Ö§ß§í §á§â§à§Õ§Ñ§Ø§Ú §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §ß§à §ß§Ö §Ó§í§Ù§Ó§Ñ§ß §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §Ó§ä§à§â§à§Û §ã§Õ§Ñ§Õ§Ú§Ú
     * - Success: §µ§ã§á§Ö§ê§ß§à §Ù§Ñ§Ü§â§í§Ý§Ú ICO
     * - Failure: §¯§Ö §ã§à§Ò§â§Ñ§Ý§Ú Soft Cap
     * - Refunding: §£§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§Þ §ã§à§Ò§â§Ñ§ß§ß§í§Û §ï§æ§Ú§â
     */
    enum State{PreFunding, FirstStageFunding, FirstStageEnd, SecondStageFunding, SecondStageEnd, Success, Failure, Refunding}

    // §³§à§Ò§í§ä§Ú§Ö §á§à§Ü§å§á§Ü§Ú §ä§à§Ü§Ö§ß§Ñ
    event Invested(address indexed investor, uint weiAmount, uint tokenAmount, uint centAmount, uint txId);

    // §³§à§Ò§í§ä§Ú§Ö §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§ñ §Ü§å§â§ã§Ñ eth
    event ExchangeRateChanged(uint oldExchangeRate, uint newExchangeRate);

    // §³§à§Ò§í§ä§Ú§Ö §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§ñ §Õ§Ñ§ä§í §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
    event FirstStageStartsAtChanged(uint newFirstStageStartsAt);
    event FirstStageEndsAtChanged(uint newFirstStageEndsAt);

    // §³§à§Ò§í§ä§Ú§Ö §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§ñ §Õ§Ñ§ä§í §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú
    event SecondStageStartsAtChanged(uint newSecondStageStartsAt);
    event SecondStageEndsAtChanged(uint newSecondStageEndsAt);

    // §³§à§Ò§í§ä§Ú§Ö §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§ñ Soft Cap'§Ñ
    event SoftCapChanged(uint newGoal);

    // §³§à§Ò§í§ä§Ú§Ö §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§ñ Hard Cap'§Ñ
    event HardCapChanged(uint newGoal);

    // §¬§à§ß§ã§ä§â§å§Ü§ä§à§â
    function AllocatedCappedCrowdsale(uint _currentEtherRateInCents, address _token, address _destinationMultisigWallet, uint _firstStageStartsAt, uint _firstStageEndsAt, uint _secondStageStartsAt, uint _secondStageEndsAt, address _advisorsAccount, address _marketingAccount, address _supportAccount, address _teamAccount, uint _teamTokensIssueDate) {
        requireNotEmptyAddress(_destinationMultisigWallet);
        // §±§â§à§Ó§Ö§â§Ü§Ñ, §é§ä§à §Õ§Ñ§ä§í §å§ã§ä§Ñ§ß§à§Ó§Ý§Ö§ß§í
        require(_firstStageStartsAt != 0);
        require(_firstStageEndsAt != 0);

        require(_firstStageStartsAt < _firstStageEndsAt);

        require(_secondStageStartsAt != 0);
        require(_secondStageEndsAt != 0);

        require(_secondStageStartsAt < _secondStageEndsAt);
        require(_teamTokensIssueDate != 0);

        // §´§à§Ü§Ö§ß, §Ü§à§ä§à§â§í§Û §á§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§ä §ã§Ø§Ú§Ô§Ñ§ß§Ú§Ö
        token = BurnableCrowdsaleToken(_token);

        destinationMultisigWallet = _destinationMultisigWallet;

        firstStageStartsAt = _firstStageStartsAt;
        firstStageEndsAt = _firstStageEndsAt;
        secondStageStartsAt = _secondStageStartsAt;
        secondStageEndsAt = _secondStageEndsAt;

        // §¡§Õ§â§Ö§ã§Ñ §Ü§à§ê§Ö§Ý§î§Ü§à§Ó §Õ§Ý§ñ §Ñ§Õ§Ó§Ú§Ù§à§â§à§Ó, §Þ§Ñ§â§Ü§Ö§ä§Ú§ß§Ô§Ñ, §Ü§à§Þ§Ñ§ß§Õ§í
        advisorsAccount = _advisorsAccount;
        marketingAccount = _marketingAccount;
        supportAccount = _supportAccount;
        teamAccount = _teamAccount;

        teamTokensIssueDate = _teamTokensIssueDate;

        currentEtherRateInCents = _currentEtherRateInCents;

        secondStageTokensForSale = secondStageTotalSupply.sub(secondStageReserve);
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ú§ß§Ú§è§Ú§Ú§â§å§ð§ë§Ñ§ñ §ß§å§Ø§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §á§Ö§â§Ó§à§Ô§à §ï§ä§Ñ§á§Ñ §á§â§à§Õ§Ñ§Ø, §Ó§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à 1 §â§Ñ§Ù
     */
    function mintTokensForFirstStage() public onlyOwner {
        // §¦§ã§Ý§Ú §å§Ø§Ö §ã§à§Ù§Õ§Ñ§Ý§Ú §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §Õ§Ö§Ý§Ñ§Ö§Þ §à§ä§Ü§Ñ§ä
        require(!isFirstStageTokensMinted);

        uint tokenMultiplier = 10 ** token.decimals();

        token.mintToAddress(firstStageTotalSupply.mul(tokenMultiplier), address(this));

        isFirstStageTokensMinted = true;
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ú§ß§Ú§è§Ú§Ú§â§å§ð§ë§Ñ§ñ §ß§å§Ø§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §Ó§ä§à§â§à§Ô§à §ï§ä§Ñ§á§Ñ §á§â§à§Õ§Ñ§Ø, §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §ï§ä§à §Ö§ë§Ö §ß§Ö §ã§Õ§Ö§Ý§Ñ§ß§à §Ú §Ò§í§Ý§Ú §ã§à§Ù§Õ§Ñ§ß§í §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     */
    function mintTokensForSecondStage() private {
        // §¦§ã§Ý§Ú §å§Ø§Ö §ã§à§Ù§Õ§Ñ§Ý§Ú §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §Õ§Ö§Ý§Ñ§Ö§Þ §à§ä§Ü§Ñ§ä
        require(!isSecondStageTokensMinted);

        require(isFirstStageTokensMinted);

        uint tokenMultiplier = 10 ** token.decimals();

        token.mintToAddress(secondStageTotalSupply.mul(tokenMultiplier), address(this));

        isSecondStageTokensMinted = true;
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§ð§ë§Ñ§ñ §ä§Ö§Ü§å§ë§å§ð §ã§ä§à§Ú§Þ§à§ã§ä§î 1 §ä§à§Ü§Ö§ß§Ñ §Ó wei
     */
    function getOneTokenInWei() external constant returns(uint){
        return oneTokenInCents.mul(10 ** 18).div(currentEtherRateInCents);
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §á§Ö§â§Ö§Ó§à§Õ§Ú§ä wei §Ó §è§Ö§ß§ä§í §á§à §ä§Ö§Ü§å§ë§Ö§Þ§å §Ü§å§â§ã§å
     */
    function getWeiInCents(uint value) public constant returns(uint){
        return currentEtherRateInCents.mul(value).div(10 ** 18);
    }

    /**
     * §±§Ö§â§Ö§Ó§à§Õ §ä§à§Ü§Ö§ß§à§Ó §á§à§Ü§å§á§Ñ§ä§Ö§Ý§ð
     */
    function assignTokens(address receiver, uint tokenAmount) private {
        // §¦§ã§Ý§Ú §á§Ö§â§Ö§Ó§à§Õ §ß§Ö §å§Õ§Ñ§Ý§ã§ñ, §à§ä§Ü§Ñ§ä§í§Ó§Ñ§Ö§Þ §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§ð
        if (!token.transfer(receiver, tokenAmount)) revert();
    }

    /**
     * Fallback §æ§å§ß§Ü§è§Ú§ñ §Ó§í§Ù§í§Ó§Ñ§ð§ë§Ñ§ñ§ã§ñ §á§â§Ú §á§Ö§â§Ö§Ó§à§Õ§Ö §ï§æ§Ú§â§Ñ
     */
    function() payable {
        buy();
    }

    /**
     * §¯§Ú§Ù§Ü§à§å§â§à§Ó§ß§Ö§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §ï§æ§Ú§â§Ñ §Ú §Ó§í§Õ§Ñ§é§Ú §ä§à§Ü§Ö§ß§à§Ó
     */
    function internalAssignTokens(address receiver, uint tokenAmount, uint weiAmount, uint centAmount, uint txId) internal {
        // §±§Ö§â§Ö§Ó§à§Õ§Ú§Þ §ä§à§Ü§Ö§ß§í §Ú§ß§Ó§Ö§ã§ä§à§â§å
        assignTokens(receiver, tokenAmount);

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        Invested(receiver, weiAmount, tokenAmount, centAmount, txId);

        // §®§à§Ø§Ö§ä §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§î§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §ª§ß§Ó§Ö§ã§ä§Ú§è§Ú§Ú
     * §¥§à§Ý§Ø§Ö§ß §Ò§í§ä§î §Ó§Ü§Ý§ð§é§Ö§ß §â§Ö§Ø§Ú§Þ §á§â§à§Õ§Ñ§Ø §á§Ö§â§Ó§à§Û §Ú§Ý§Ú §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú §Ú §ß§Ö §ã§à§Ò§â§Ñ§ß Hard Cap
     * @param receiver - §ï§æ§Ú§â§ß§í§Û §Ñ§Õ§â§Ö§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ
     * @param txId - id §Ó§ß§Ö§ê§ß§Ö§Û §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Ú
     */
    function internalInvest(address receiver, uint weiAmount, uint txId) stopInEmergency inFirstOrSecondFundingState notHardCapReached internal {
        State currentState = getState();

        uint tokenMultiplier = 10 ** token.decimals();

        uint amountInCents = getWeiInCents(weiAmount);

        // §°§é§Ö§ß§î §Ó§ß§Ú§Þ§Ñ§ä§Ö§Ý§î§ß§à §ß§å§Ø§ß§à §Þ§Ö§ß§ñ§ä§î §Ù§ß§Ñ§é§Ö§ß§Ú§ñ, §ä.§Ü. §Õ§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú 1000%, §é§ä§à§Ò§í §å§é§Ö§ã§ä§î §Õ§â§à§Ò§ß§í§Ö §Ù§ß§Ñ§é§Ö§ß§Ú§ñ
        uint bonusPercentage = 0;
        uint bonusStateMultiplier = 1;

        // §Ö§ã§Ý§Ú §Ù§Ñ§á§å§ë§Ö§ß§Ñ §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ, §Ó §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â§Ö §å§Ø§Ö §Ó§í§á§å§ã§ä§Ú§Ý§Ú §ß§å§Ø§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
        if (currentState == State.FirstStageFunding){
            // §Þ§Ö§ß§î§ê§Ö 25000$ §ß§Ö §á§â§Ú§ß§Ú§Þ§Ñ§Ö§Þ
            require(amountInCents >= 2500000);

            // [25000$ - 50000$) - 50% §Ò§à§ß§å§ã§Ñ
            if (amountInCents >= 2500000 && amountInCents < 5000000){
                bonusPercentage = 50;
            // [50000$ - 100000$) - 75% §Ò§à§ß§å§ã§Ñ
            }else if(amountInCents >= 5000000 && amountInCents < 10000000){
                bonusPercentage = 75;
            // >= 100000$ - 100% §Ò§à§ß§å§ã§Ñ
            }else if(amountInCents >= 10000000){
                bonusPercentage = 100;
            }else{
                revert();
            }

        // §Ö§ã§Ý§Ú §Ù§Ñ§á§å§ë§Ö§ß§Ñ §Ó§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ
        } else if(currentState == State.SecondStageFunding){
            // §±§â§à§è§Ö§ß§ä §á§â§à§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó, §Ò§å§Õ§Ö§Þ §ã§é§Ú§ä§Ñ§ä§î §ã §Þ§ß§à§Ø§Ú§ä§Ö§Ý§Ö§Þ 10, §ä.§Ü. §Ö§ã§ä§î §Õ§â§à§Ò§ß§í§Ö §Ù§ß§Ñ§é§Ö§ß§Ú§ñ
            bonusStateMultiplier = 10;

            // §¬§à§Ý-§Ó§à §á§â§à§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó §ß§å§Ø§ß§à §ã§é§Ú§ä§Ñ§ä§î §à§ä §Ù§ß§Ñ§é§Ö§ß§Ú§ñ §ä§Ö§ç §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§í§Ö §á§â§Ö§Õ§ß§Ñ§Ù§ß§Ñ§é§Ö§ß§í §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø, §ä.§Ö. secondStageTokensForSale
            uint tokensSoldPercentage = secondStageTokensSold.mul(100).div(secondStageTokensForSale.mul(tokenMultiplier));

            // §Þ§Ö§ß§î§ê§Ö 7$ §ß§Ö §á§â§Ú§ß§Ú§Þ§Ñ§Ö§Þ
            require(amountInCents >= 700);

            // (0% - 10%) - 20% §Ò§à§ß§å§ã§Ñ
            if (tokensSoldPercentage >= 0 && tokensSoldPercentage < 10){
                bonusPercentage = 200;
            // [10% - 20%) - 17.5% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 10 && tokensSoldPercentage < 20){
                bonusPercentage = 175;
            // [20% - 30%) - 15% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 20 && tokensSoldPercentage < 30){
                bonusPercentage = 150;
            // [30% - 40%) - 12.5% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 30 && tokensSoldPercentage < 40){
                bonusPercentage = 125;
            // [40% - 50%) - 10% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 40 && tokensSoldPercentage < 50){
                bonusPercentage = 100;
            // [50% - 60%) - 8% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 50 && tokensSoldPercentage < 60){
                bonusPercentage = 80;
            // [60% - 70%) - 6% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 60 && tokensSoldPercentage < 70){
                bonusPercentage = 60;
            // [70% - 80%) - 4% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 70 && tokensSoldPercentage < 80){
                bonusPercentage = 40;
            // [80% - 90%) - 2% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 80 && tokensSoldPercentage < 90){
                bonusPercentage = 20;
            // >= 90% - 0% §Ò§à§ß§å§ã§Ñ
            }else if (tokensSoldPercentage >= 90){
                bonusPercentage = 0;
            }else{
                revert();
            }
        } else revert();

        // §ã§Ü§à§Ý§î§Ü§à §ä§à§Ü§Ö§ß§à§Ó §ß§å§Ø§ß§à §Ó§í§Õ§Ñ§ä§î §Ò§Ö§Ù §Ò§à§ß§å§ã§Ñ
        uint resultValue = amountInCents.mul(tokenMultiplier).div(oneTokenInCents);

        // §ã §å§é§Ö§ä§à§Þ §Ò§à§ß§å§ã§Ñ
        uint tokenAmount = resultValue.mul(bonusStateMultiplier.mul(100).add(bonusPercentage)).div(bonusStateMultiplier.mul(100));

        // §Ü§â§Ñ§Ö§Ó§à§Û §ã§Ý§å§é§Ñ§Û, §Ü§à§Ô§Õ§Ñ §Ù§Ñ§á§â§à§ã§Ú§Ý§Ú §Ò§à§Ý§î§ê§Ö, §é§Ö§Þ §Þ§à§Ø§Ö§Þ §Ó§í§Õ§Ñ§ä§î
        uint tokensLeft = getTokensLeftForSale(currentState);
        if (tokenAmount > tokensLeft){
            tokenAmount = tokensLeft;
        }

        // §¬§à§Ý-§Ó§à 0?, §Õ§Ö§Ý§Ñ§Ö§Þ §à§ä§Ü§Ñ§ä
        require(tokenAmount != 0);

        // §¯§à§Ó§í§Û §Ú§ß§Ó§Ö§ã§ä§à§â?
        if (investedAmountOf[receiver] == 0) {
            investorCount++;
        }

        // §¬§Ú§Õ§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §Ú§ß§Ó§Ö§ã§ä§à§â§å
        internalAssignTokens(receiver, tokenAmount, weiAmount, amountInCents, txId);

        // §°§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§å
        updateStat(currentState, receiver, tokenAmount, weiAmount);

        // §º§Ý§Ö§Þ §ß§Ñ §Ü§à§ê§Ö§Ý§×§Ü §ï§æ§Ú§â
        // §¶§å§ß§Ü§è§Ú§ñ - §á§â§à§ã§Ý§à§Û§Ü§Ñ §Õ§Ý§ñ §Ó§à§Ù§Þ§à§Ø§ß§à§ã§ä§Ú §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§ñ §Ó §Õ§à§é§Ö§â§ß§Ú§ç §Ü§Ý§Ñ§ã§ã§Ñ§ç
        // §¦§ã§Ý§Ú §ï§ä§à §Ó§ß§Ö§ê§ß§Ú§Û §Ó§í§Ù§à§Ó, §ä§à §Õ§Ö§á§à§Ù§Ú§ä §ß§Ö §Ü§Ý§Ñ§Õ§Ö§Þ
        if (txId == 0){
            internalDeposit(destinationMultisigWallet, weiAmount);
        }

        // §®§à§Ø§Ö§ä §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§î§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §¯§Ú§Ù§Ü§à§å§â§à§Ó§ß§Ö§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §ï§æ§Ú§â§Ñ §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä, §æ§å§ß§Ü§è§Ú§ñ §Õ§à§ã§ä§å§á§ß§Ñ §Õ§Ý§ñ §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§ñ §Ó §Õ§à§é§Ö§â§ß§Ú§ç §Ü§Ý§Ñ§ã§ã§Ñ§ç, §ß§à §ß§Ö §á§å§Ò§Ý§Ú§é§ß§Ñ
     */
    function internalDeposit(address receiver, uint weiAmount) internal{
        // §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §¯§Ú§Ù§Ü§à§å§â§à§Ó§ß§Ö§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §ã§â§Ö§Õ§ã§ä§Ó, §æ§å§ß§Ü§è§Ú§ñ §Õ§à§ã§ä§å§á§ß§Ñ §Õ§Ý§ñ §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§ñ §Ó §Õ§à§é§Ö§â§ß§Ú§ç §Ü§Ý§Ñ§ã§ã§Ñ§ç, §ß§à §ß§Ö §á§å§Ò§Ý§Ú§é§ß§Ñ
     */
    function internalRefund(address receiver, uint weiAmount) internal{
        // §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §¯§Ú§Ù§Ü§à§å§â§à§Ó§ß§Ö§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §Ó§Ü§Ý§ð§é§Ö§ß§Ú§ñ §â§Ö§Ø§Ú§Þ§Ñ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §ã§â§Ö§Õ§ã§ä§Ó
     */
    function internalEnableRefunds() internal{
        // §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §³§á§Ö§è. §æ§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §á§à§Ù§Ó§à§Ý§ñ§Ö§ä §á§â§à§Õ§Ñ§Ó§Ñ§ä§î §ä§à§Ü§Ö§ß§í §Ó§ß§Ö §è§Ö§ß§à§Ó§à§Û §á§à§Ý§Ú§ä§Ú§Ü§Ú, §Õ§à§ã§ä§å§á§Ü§Ñ §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§å
     * §²§Ö§Ù§å§Ý§î§ä§Ñ§ä§í §á§Ú§ê§å§ä§ã§ñ §Ó §à§Ò§ë§å§ð §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§å, §Ò§Ö§Ù §â§Ñ§Ù§Õ§Ö§Ý§Ö§ß§Ú§ñ §ß§Ñ §ã§ä§Ñ§Õ§Ú§Ú
     * @param receiver - §á§à§Ý§å§é§Ñ§ä§Ö§Ý§î
     * @param tokenAmount - §à§Ò§ë§Ö§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó c decimals!!!
     * @param weiAmount - §è§Ö§ß§Ñ §Ó wei
     */
    function internalPreallocate(State currentState, address receiver, uint tokenAmount, uint weiAmount) internal {
        // C§Ü§à§Ý§î§Ü§à §ä§à§Ü§Ö§ß§à§Ó §à§ã§ä§Ñ§Ý§à§ã§î §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø§Ú? §¢§à§Ý§î§ê§Ö §ï§ä§à§Ô§à §Ù§ß§Ñ§é§Ö§ß§Ú§ñ §Ó§í§Õ§Ñ§ä§î §ß§Ö §Þ§à§Ø§Ö§Þ!
        require(getTokensLeftForSale(currentState) >= tokenAmount);

        // §®§à§Ø§Ö§ä §Ò§í§ä§î 0, §Ó§í§Õ§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §Ò§Ö§ã§á§Ý§Ñ§ä§ß§à
        internalAssignTokens(receiver, tokenAmount, weiAmount, getWeiInCents(weiAmount), 0);

        // §°§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§å
        updateStat(currentState, receiver, tokenAmount, weiAmount);

        // §®§à§Ø§Ö§ä §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§î§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §¯§Ú§Ù§Ü§à§å§â§à§Ó§ß§Ö§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §Õ§Ö§Û§ã§ä§Ó§Ú§Û, §Ó §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ç§Ñ
     */
    function internalSuccessOver() internal {
        // §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §á§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§ñ§Ö§ä§ã§ñ §Ó §ß§Ñ§Õ§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç §Ú §Ó§í§á§à§Ý§ß§ñ§Ö§ä§ã§ñ §á§à§ã§Ý§Ö §å§ã§ä§Ñ§ß§à§Ó§Ü§Ú §Ñ§Õ§â§Ö§ã§Ñ §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ §Õ§Ý§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §ã§â§Ö§Õ§ã§ä§Ó
     */
    function internalSetDestinationMultisigWallet(address destinationAddress) internal{
    }

    /**
     * §°§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§å §Õ§Ý§ñ §á§Ö§â§Ó§à§Û §Ú§Ý§Ú §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     */
    function updateStat(State currentState, address receiver, uint tokenAmount, uint weiAmount) private{
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokenAmount);

        // §¦§ã§Ý§Ú §ï§ä§à §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ
        if (currentState == State.FirstStageFunding){
            // §µ§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§Ö§Þ §ã§ä§Ñ§ä§å
            firstStageRaisedInWei = firstStageRaisedInWei.add(weiAmount);
            firstStageTokensSold = firstStageTokensSold.add(tokenAmount);
        }

        // §¦§ã§Ý§Ú §ï§ä§à §Ó§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ
        if (currentState == State.SecondStageFunding){
            // §µ§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§Ö§Þ §ã§ä§Ñ§ä§å
            secondStageRaisedInWei = secondStageRaisedInWei.add(weiAmount);
            secondStageTokensSold = secondStageTokensSold.add(tokenAmount);
        }

        investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
        tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §á§à§Ù§Ó§à§Ý§ñ§Ö§ä §Þ§Ö§ß§ñ§ä§î §Ñ§Õ§â§Ö§ã §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ, §Ü§å§Õ§Ñ §Ò§å§Õ§å§ä §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§í §ã§â§Ö§Õ§ã§ä§Ó§Ñ, §Ó §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ç§Ñ,
     * §Þ§Ö§ß§ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ú §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö §Ö§ã§Ý§Ú §á§â§à§Õ§Ñ§Ø§Ú §Ö§ë§Ö §ß§Ö §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§í §å§ã§á§Ö§ç§à§Þ
     */
    function setDestinationMultisigWallet(address destinationAddress) public onlyOwner canSetDestinationMultisigWallet{
        destinationMultisigWallet = destinationAddress;

        internalSetDestinationMultisigWallet(destinationAddress);
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §Ù§Ñ§Õ§Ñ§Ö§ä §ä§Ö§Ü§å§ë§Ú§Û §Ü§å§â§ã eth §Ó §è§Ö§ß§ä§Ñ§ç
     */
    function changeCurrentEtherRateInCents(uint value) public onlyOwner {
        // §¦§ã§Ý§Ú §ã§Ý§å§é§Ñ§Û§ß§à §Ù§Ñ§Õ§Ñ§Ý§Ú 0, §ß§Ö §à§ä§Ü§Ñ§ä§í§Ó§Ñ§Ö§Þ §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§ð
        require(value > 0);

        currentEtherRateInCents = value;

        ExchangeRateChanged(currentEtherRateInCents, value);
    }

    /**
    * §²§Ñ§Ù§Õ§Ö§Ý§Ú§Ý §ß§Ñ 2 §Þ§Ö§ä§à§Õ§Ñ, §é§ä§à§Ò§í §ß§Ö §Ù§Ñ§á§å§ä§Ñ§ä§î§ã§ñ §á§â§Ú §Ó§í§Ù§à§Ó§Ö
    * §¿§ä§Ú §æ§å§ß§Ü§è§Ú§Ú §ß§å§Ø§ß§í §Ó 2-§ç §ã§Ý§å§é§Ñ§ñ§ç: §ß§Ö§Þ§ß§à§Ô§à §ß§Ö §ã§à§Ò§â§Ñ§Ý§Ú §Õ§à Cap'§Ñ, §ã§Ñ§Þ§Ú §Õ§à§Ü§Ú§Õ§í§Ó§Ñ§Ö§Þ §ß§Ö§à§Ò§ç§à§Õ§Ú§Þ§å§ð §ã§å§Þ§Þ§å, §Ö§ã§ä§î §á§â§Ú§Ó§Ñ§ä§ß§í§Ö §Ú§ß§Ó§Ö§ã§ä§à§â§í, §Õ§Ý§ñ §Ü§à§ä§à§â§í§ç §ã§å§ë§Ö§ã§ä§Ó§å§ð§ä §à§ã§à§Ò§í§Ö §å§ã§Ý§à§Ó§Ú§ñ
    */

    /* §¥§Ý§ñ §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú */
    function preallocateFirstStage(address receiver, uint tokenAmount, uint weiAmount) public onlyOwner isFirstStageFundingOrEnd {
        internalPreallocate(State.FirstStageFunding, receiver, tokenAmount, weiAmount);
    }

    /* §¥§Ý§ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §Ó§í§Õ§Ñ§ä§î §Þ§à§Ø§Ö§Þ §ß§Ö §Ò§à§Ý§î§ê§Ö §à§ã§ä§Ñ§ä§Ü§Ñ §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø§Ú */
    function preallocateSecondStage(address receiver, uint tokenAmount, uint weiAmount) public onlyOwner isSecondStageFundingOrEnd {
        internalPreallocate(State.SecondStageFunding, receiver, tokenAmount, weiAmount);
    }

    /* §£ §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ç§Ñ, §Ù§Ñ§Ò§Ý§à§Ü§Ú§â§à§Ó§Ñ§ß§ß§í§Ö §ä§à§Ü§Ö§ß§í §Õ§Ý§ñ §Ü§à§Þ§Ñ§ß§Õ§í §Þ§à§Ô§å§ä §Ò§í§ä§î §Ó§à§ã§ä§â§Ö§Ò§à§Ó§Ñ§ß§í §ä§à§Ý§î§Ü§à §Ö§ã§Ý§Ú §ß§Ñ§ã§ä§å§á§Ú§Ý§Ñ §à§á§â§Ö§Õ§Ö§Ý§Ö§ß§ß§Ñ§ñ §Õ§Ñ§ä§Ñ */
    function issueTeamTokens() public onlyOwner inState(State.Success) {
        require(block.timestamp >= teamTokensIssueDate);

        uint teamTokenTransferAmount = teamTokenAmount.mul(10 ** token.decimals());

        if (!token.transfer(teamAccount, teamTokenTransferAmount)) revert();
    }

    /**
    * §£§Ü§Ý§ð§é§Ñ§Ö§ä §â§Ö§Ø§Ú§Þ §Ó§à§Ù§Ó§â§Ñ§ä§à§Ó, §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö §Ö§ã§Ý§Ú §â§Ö§Ø§Ú§Þ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §Ö§ë§Ö §ß§Ö §å§ã§ä§Ñ§ß§à§Ó§Ý§Ö§ß §Ú §á§â§à§Õ§Ñ§Ø§Ú §ß§Ö §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§í §å§ã§á§Ö§ç§à§Þ
    * §£§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à 1 §â§Ñ§Ù
    */
    function enableRefunds() public onlyOwner canEnableRefunds{
        isRefundingEnabled = true;

        // §³§Ø§Ú§Ô§Ñ§Ö§Þ §à§ã§ä§Ñ§ä§Ü§Ú §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §ä§Ö§Ü§å§ë§Ö§Ô§à §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
        token.burnAllOwnerTokens();

        internalEnableRefunds();
    }

    /**
     * §±§à§Ü§å§á§Ü§Ñ §ä§à§Ü§Ö§ß§à§Ó, §Ü§Ú§Õ§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ß§Ñ §Ñ§Õ§â§Ö§ã §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ñ
     */
    function buy() public payable {
        internalInvest(msg.sender, msg.value, 0);
    }

    /**
     * §±§à§Ü§å§á§Ü§Ñ §ä§à§Ü§Ö§ß§à§Ó §é§Ö§â§Ö§Ù §Ó§ß§Ö§ê§ß§Ú§Ö §ã§Ú§ã§ä§Ö§Þ§í
     */
    function externalBuy(address buyerAddress, uint weiAmount, uint txId) external onlyOwner {
        require(txId != 0);

        internalInvest(buyerAddress, weiAmount, txId);
    }

    /**
     * §ª§ß§Ó§Ö§ã§ä§à§â§í §Þ§à§Ô§å§ä §Ù§Ñ§ä§â§Ö§Ò§à§Ó§Ñ§ä§î §Ó§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§Õ§ã§ä§Ó, §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö - Refunding
     */
    function refund() public inState(State.Refunding) {
        // §±§à§Ý§å§é§Ñ§Ö§Þ §Ù§ß§Ñ§é§Ö§ß§Ú§Ö, §Ü§à§ä§à§â§à§Ö §ß§Ñ§Þ §Ò§í§Ý§à §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§à §Ó §ï§æ§Ú§â§Ö
        uint weiValue = investedAmountOf[msg.sender];

        require(weiValue != 0);

        // §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö, §Ò§Ö§â§Ö§Þ 2 §Ù§ß§Ñ§é§Ö§ß§Ú§ñ: §Ü§à§ß§ä§â§Ñ§Ü§ä §á§â§à§Õ§Ñ§Ø §Ú §Ü§à§ß§ä§â§Ñ§Ü§ä §ä§à§Ü§Ö§ß§Ñ.
        // §£§Ö§â§ß§å§ä§î wei §Þ§à§Ø§Ö§Þ §ä§à§Ý§î§Ü§à §ä§à§Ô§Õ§Ñ, §Ü§à§Ô§Õ§Ñ §ï§ä§Ú §Ù§ß§Ñ§é§Ö§ß§Ú§ñ §ã§à§Ó§á§Ñ§Õ§Ñ§ð§ä, §Ö§ã§Ý§Ú §ß§Ö §ã§à§Ó§á§Ñ§Õ§Ñ§ð§ä, §Ù§ß§Ñ§é§Ú§ä §Ò§í§Ý§Ú §Ü§Ñ§Ü§Ú§Ö-§ä§à
        // §Þ§Ñ§ß§Ú§á§å§Ý§ñ§è§Ú§Ú §ã §ä§à§Ü§Ö§ß§Ñ§Þ§Ú §Ú §ä§Ñ§Ü§Ú§Ö §ã§Ú§ä§å§Ñ§è§Ú§Ú §Ò§å§Õ§å§ä §â§Ö§ê§Ñ§ä§î§ã§ñ §Ó §Ú§ß§Õ§Ú§Ó§Ú§Õ§å§Ñ§Ý§î§ß§à§Þ §á§à§â§ñ§Õ§Ü§Ö, §á§à §Ù§Ñ§á§â§à§ã§å
        uint saleContractTokenCount = tokenAmountOf[msg.sender];
        uint tokenContractTokenCount = token.balanceOf(msg.sender);

        require(saleContractTokenCount <= tokenContractTokenCount);

        investedAmountOf[msg.sender] = 0;
        weiRefunded = weiRefunded.add(weiValue);

        // §³§à§Ò§í§ä§Ú§Ö §Ô§Ö§ß§Ö§â§Ú§â§å§Ö§ä§ã§ñ §Ó §ß§Ñ§ã§Ý§Ö§Õ§ß§Ú§Ü§Ñ§ç
        internalRefund(msg.sender, weiValue);
    }

    /**
     * §¶§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §Ó§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §á§â§Ú §å§ã§Ý§à§Ó§Ú§Ú §Ö§ë§Ö §ß§Ö§Ù§Ñ§Ó§Ö§â§ê§Ú§Ó§ê§Ö§Û§ã§ñ §á§â§à§Õ§Ñ§Ø§Ú
     * §¦§ã§Ý§Ú §Ó§í§Ù§Ó§Ñ§ß halt, §ä§à §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §Ó§í§Ù§Ó§Ñ§ä§î §ß§Ö §Þ§à§Ø§Ö§Þ
     * §£§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à 1 §â§Ñ§Ù
     */
    function finalizeFirstStage() public onlyOwner isNotSuccessOver {
        require(!isFirstStageFinalized);

        // §³§Ø§Ú§Ô§Ñ§Ö§Þ §à§ã§ä§Ñ§ä§Ü§Ú
        // §£§ã§Ö§Ô§à §Þ§à§Ø§Ö§Þ §á§â§à§Õ§Ñ§ä§î firstStageTotalSupply
        // §±§â§à§Õ§Ñ§Ý§Ú - firstStageTokensSold
        // §£§ã§Ö §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §ã§Ø§Ú§Ô§Ñ§Ö§Þ - §ï§ä§à §Ò§å§Õ§Ö§ä §à§ã§ä§Ñ§ä§à§Ü

        token.burnAllOwnerTokens();

        // §±§Ö§â§Ö§ç§à§Õ§Ú§Þ §Ü§à §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú
        // §¦§ã§Ý§Ú §á§à§Ó§ä§à§â§ß§à §Ó§í§Ù§Ó§Ñ§ä§î §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â, §ä§à §Ö§ë§Ö §â§Ñ§Ù §ä§à§Ü§Ö§ß§í §ß§Ö §ã§à§Ù§Õ§Ñ§Õ§å§ä§ã§ñ, §å§ã§Ý§à§Ó§Ú§Ö §Ó§ß§å§ä§â§Ú
        mintTokensForSecondStage();

        isFirstStageFinalized = true;
    }

    /**
     * §¶§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §Ó§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è, §Ú §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö §æ§Ú§ß§Ú§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§ß§à§Û §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
     * §Ú §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §ã§Ò§à§â§í §Ö§ë§Ö §ß§Ö §Ù§Ñ§Ó§Ö§â§ê§Ú§Ý§Ú§ã§î §å§ã§á§Ö§ç§à§Þ. §¦§ã§Ý§Ú §Ó§í§Ù§Ó§Ñ§ß halt, §ä§à §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§ä§à§â §Ó§í§Ù§Ó§Ñ§ä§î §ß§Ö §Þ§à§Ø§Ö§Þ.
     * §£§í§Ù§Ó§Ñ§ä§î §Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à 1 §â§Ñ§Ù
     */
    function finalizeSecondStage() public onlyOwner isNotSuccessOver {
        require(isFirstStageFinalized && !isSecondStageFinalized);

        // §³§Ø§Ú§Ô§Ñ§Ö§Þ §à§ã§ä§Ñ§ä§Ü§Ú
        // §£§ã§Ö§Ô§à §Þ§à§Ø§Ö§Þ §á§â§à§Õ§Ñ§ä§î secondStageTokensForSale
        // §±§â§à§Õ§Ñ§Ý§Ú - secondStageTokensSold
        // §²§Ñ§Ù§ß§Ú§è§å §ß§å§Ø§ß§à §ã§Ø§Ö§é§î, §Ó §Ý§ð§Ò§à§Þ §ã§Ý§å§é§Ñ§Ö

        // §¦§ã§Ý§Ú §Õ§à§ã§ä§Ú§Ô§ß§å§ä Soft Cap, §ä§à §ã§é§Ú§ä§Ñ§Ö§Þ §Ó§ä§à§â§å§ð §ã§ä§Ñ§Õ§Ú§ð §å§ã§á§Ö§ê§ß§à§Û
        if (isSoftCapGoalReached()){
            uint tokenMultiplier = 10 ** token.decimals();

            uint remainingTokens = secondStageTokensForSale.mul(tokenMultiplier).sub(secondStageTokensSold);

            // §¦§ã§Ý§Ú §Ü§à§Ý-§Ó§à §à§ã§ä§Ñ§Ó§ê§Ú§ç§ã§ñ §ä§à§Ü§Ö§ß§à§Ó > 0, §ä§à §ã§Ø§Ú§Ô§Ñ§Ö§Þ §Ú§ç
            if (remainingTokens > 0){
                token.burnOwnerTokens(remainingTokens);
            }

            // §±§Ö§â§Ö§Ó§à§Õ§Ú§Þ §ß§Ñ §á§à§Õ§Ô§à§ä§à§Ó§Ý§Ö§ß§ß§í§Ö §Ñ§Ü§Ü§Ñ§å§ß§ä§í: advisorsWalletAddress, marketingWalletAddress, teamWalletAddress
            uint advisorsTokenTransferAmount = advisorsTokenAmount.mul(tokenMultiplier);
            uint marketingTokenTransferAmount = marketingTokenAmount.mul(tokenMultiplier);
            uint supportTokenTransferAmount = supportTokenAmount.mul(tokenMultiplier);

            // §´§à§Ü§Ö§ß§í §Õ§Ý§ñ §Ü§à§Þ§Ñ§ß§Õ§í §Ù§Ñ§Ò§Ý§à§Ü§Ú§â§à§Ó§Ñ§ß§í §Õ§à §Õ§Ñ§ä§í teamTokensIssueDate §Ú §Þ§à§Ô§å§ä §Ò§í§ä§î §Ó§à§ã§ä§â§Ö§Ò§à§Ó§Ñ§ß§í, §ä§à§Ý§î§Ü§à §á§â§Ú §Ó§í§Ù§à§Ó§Ö §ã§á§Ö§è. §æ§å§ß§Ü§è§Ú§Ú
            // issueTeamTokens

            if (!token.transfer(advisorsAccount, advisorsTokenTransferAmount)) revert();
            if (!token.transfer(marketingAccount, marketingTokenTransferAmount)) revert();
            if (!token.transfer(supportAccount, supportTokenTransferAmount)) revert();

            // §¬§à§ß§ä§â§Ñ§Ü§ä §Ó§í§á§à§Ý§ß§Ö§ß!
            isSuccessOver = true;

            // §£§í§Ù§í§Ó§Ñ§Ö§Þ §Þ§Ö§ä§à§Õ §å§ã§á§Ö§ç§Ñ
            internalSuccessOver();
        }else{
            // §¦§ã§Ý§Ú §ß§Ö §ã§à§Ò§â§Ñ§Ý§Ú Soft Cap, §ä§à §ã§Ø§Ú§Ô§Ñ§Ö§Þ §Ó§ã§Ö §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
            token.burnAllOwnerTokens();
        }

        isSecondStageFinalized = true;
    }

    /**
     * §±§à§Ù§Ó§à§Ý§ñ§Ö§ä §Þ§Ö§ß§ñ§ä§î §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§å §Õ§Ñ§ä§í §ã§ä§Ñ§Õ§Ú§Û
     */
    function setFirstStageStartsAt(uint time) public onlyOwner {
        firstStageStartsAt = time;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        FirstStageStartsAtChanged(firstStageStartsAt);
    }

    function setFirstStageEndsAt(uint time) public onlyOwner {
        firstStageEndsAt = time;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        FirstStageEndsAtChanged(firstStageEndsAt);
    }

    function setSecondStageStartsAt(uint time) public onlyOwner {
        secondStageStartsAt = time;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        SecondStageStartsAtChanged(secondStageStartsAt);
    }

    function setSecondStageEndsAt(uint time) public onlyOwner {
        secondStageEndsAt = time;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        SecondStageEndsAtChanged(secondStageEndsAt);
    }

    /**
     * §±§à§Ù§Ó§à§Ý§ñ§Ö§ä §Þ§Ö§ß§ñ§ä§î §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§å Cap'§í
     */
    function setSoftCapInCents(uint value) public onlyOwner {
        require(value > 0);

        softCapFundingGoalInCents = value;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        SoftCapChanged(softCapFundingGoalInCents);
    }

    function setHardCapInCents(uint value) public onlyOwner {
        require(value > 0);

        hardCapFundingGoalInCents = value;

        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö
        HardCapChanged(hardCapFundingGoalInCents);
    }

    /**
     * §±§â§à§Ó§Ö§â§Ü§Ñ §ã§Ò§à§â§Ñ Soft Cap'§Ñ
     */
    function isSoftCapGoalReached() public constant returns (bool) {
        // §±§â§à§Ó§Ö§â§Ü§Ñ §á§à §ä§Ö§Ü§å§ë§Ö§Þ§å §Ü§å§â§ã§å §Ó §è§Ö§ß§ä§Ñ§ç, §ã§é§Ú§ä§Ñ§Ö§ä §à§ä §à§Ò§ë§Ú§ç §á§â§à§Õ§Ñ§Ø
        return getWeiInCents(weiRaised) >= softCapFundingGoalInCents;
    }

    /**
     * §±§â§à§Ó§Ö§â§Ü§Ñ §ã§Ò§à§â§Ñ Hard Cap'§Ñ
     */
    function isHardCapGoalReached() public constant returns (bool) {
        // §±§â§à§Ó§Ö§â§Ü§Ñ §á§à §ä§Ö§Ü§å§ë§Ö§Þ§å §Ü§å§â§ã§å §Ó §è§Ö§ß§ä§Ñ§ç, §ã§é§Ú§ä§Ñ§Ö§ä §à§ä §à§Ò§ë§Ú§ç §á§â§à§Õ§Ñ§Ø
        return getWeiInCents(weiRaised) >= hardCapFundingGoalInCents;
    }

    /**
     * §£§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä §Ü§à§Ý-§Ó§à §ß§Ö§â§Ñ§ã§á§â§à§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§í§Ö §Þ§à§Ø§ß§à §á§â§à§Õ§Ñ§ä§î, §Ó §Ù§Ñ§Ó§Ú§ã§Ú§Þ§à§ã§ä§Ú §à§ä §ã§ä§Ñ§Õ§Ú§Ú
     */
    function getTokensLeftForSale(State forState) public constant returns (uint) {
        // §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§à§Ö §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Þ§à§Ø§Ö§ä§î §ã§ß§ñ§ä§î §å owner'§Ñ §Ú §Ö§ã§ä§î §Ü§à§Ý-§Ó§à §à§ã§ä§Ñ§Ó§ê§Ú§ç§ã§ñ §ä§à§Ü§Ö§ß§à§Ó, §Ú§Ù §ï§ä§à§Û §ã§å§Þ§Þ§í §ß§å§Ø§ß§à §Ó§í§é§Ö§ã§ä§î §Ü§à§Ý-§Ó§à §Ü§à§ä§à§â§à§Ö §ß§Ö §å§é§Ñ§ã§ä§Ó§å§Ö§ä §Ó §á§â§à§Õ§Ñ§Ø§Ö
        uint tokenBalance = token.balanceOf(address(this));
        uint tokensReserve = 0;
        if (forState == State.SecondStageFunding) tokensReserve = secondStageReserve.mul(10 ** token.decimals());

        if (tokenBalance <= tokensReserve){
            return 0;
        }

        return tokenBalance.sub(tokensReserve);
    }

    /**
     * §±§à§Ý§å§é§Ñ§Ö§Þ §ã§ä§Ö§Û§ä
     *
     * §¯§Ö §á§Ú§ê§Ö§Þ §Ó §á§Ö§â§Ö§Þ§Ö§ß§ß§å§ð, §é§ä§à§Ò§í §ß§Ö §Ò§í§Ý§à §Ó§à§Ù§Þ§à§Ø§ß§à§ã§ä§Ú §á§à§Þ§Ö§ß§ñ§ä§î §Ú§Ù§Ó§ß§Ö, §ä§à§Ý§î§Ü§à §Ó§í§Ù§à§Ó §æ§å§ß§Ü§è§Ú§Ú §Þ§à§Ø§Ö§ä §à§ä§â§Ñ§Ù§Ú§ä§î §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö
     * §³§Þ. §Ô§â§Ñ§æ §ã§à§ã§ä§à§ñ§ß§Ú§Û
     */
    function getState() public constant returns (State) {
        // §¬§à§ß§ä§â§Ñ§Ü§ä §Ó§í§á§à§Ý§ß§Ö§ß
        if (isSuccessOver) return State.Success;

        // §¬§à§ß§ä§â§Ñ§Ü§ä §ß§Ñ§ç§à§Õ§Ú§ä§ã§ñ §Ó §â§Ö§Ø§Ú§Þ§Ö §Ó§à§Ù§Ó§â§Ñ§ä§Ñ
        if (isRefundingEnabled) return State.Refunding;

        // §¬§à§ß§ä§â§Ñ§Ü§ä §Ö§ë§Ö §ß§Ö §ß§Ñ§é§Ñ§Ý §Õ§Ö§Û§ã§ä§Ó§à§Ó§Ñ§ä§î
        if (block.timestamp < firstStageStartsAt) return State.PreFunding;

        //§¦§ã§Ý§Ú §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ - §ß§Ö §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§Ñ
        if (!isFirstStageFinalized){
            // §¶§Ý§Ñ§Ô §ä§à§Ô§à, §é§ä§à §ä§Ö§Ü§å§ë§Ñ§ñ §Õ§Ñ§ä§Ñ §ß§Ñ§ç§à§Õ§Ú§ä§ã§ñ §Ó §Ú§ß§ä§Ö§â§Ó§Ñ§Ý§Ö §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú
            bool isFirstStageTime = block.timestamp >= firstStageStartsAt && block.timestamp <= firstStageEndsAt;

            // §¦§ã§Ý§Ú §Ú§Õ§Ö§ä §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ
            if (isFirstStageTime) return State.FirstStageFunding;
            // §ª§ß§Ñ§é§Ö §á§Ö§â§Ó§í§Û §ï§ä§Ñ§á - §Ù§Ñ§Ü§à§ß§é§Ö§ß
            else return State.FirstStageEnd;

        } else {

            // §¦§ã§Ý§Ú §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§Ñ §Ú §ä§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ §Ò§Ý§à§Ü §é§Ö§Û§ß§Ñ §Þ§Ö§ß§î§ê§Ö §ß§Ñ§é§Ñ§Ý§Ñ §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú, §ä§à §ï§ä§à §à§Ù§ß§Ñ§é§Ñ§Ö§ä, §é§ä§à §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ - §à§Ü§à§ß§é§Ö§ß§Ñ
            if(block.timestamp < secondStageStartsAt)return State.FirstStageEnd;

            // §¶§Ý§Ñ§Ô §ä§à§Ô§à, §é§ä§à §ä§Ö§Ü§å§ë§Ñ§ñ §Õ§Ñ§ä§Ñ §ß§Ñ§ç§à§Õ§Ú§ä§ã§ñ §Ó §Ú§ß§ä§Ö§â§Ó§Ñ§Ý§Ö §Ó§ä§à§â§à§Û §ã§ä§Ñ§Õ§Ú§Ú
            bool isSecondStageTime = block.timestamp >= secondStageStartsAt && block.timestamp <= secondStageEndsAt;

            // §±§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§Ñ, §Ó§ä§à§â§Ñ§ñ - §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§Ñ
            if (isSecondStageFinalized){

                // §¦§ã§Ý§Ú §ß§Ñ§Ò§â§Ñ§Ý§Ú Soft Cap §á§â§Ú §å§ã§Ý§à§Ó§Ú§Ú §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§è§Ú§Ú §Ó§ä§à§â§à§Û §ã§Õ§Ñ§Õ§Ú§Ú - §ï§ä§à §å§ã§á§Ö§ê§ß§à§Ö §Ù§Ñ§Ü§â§í§ä§Ú§Ö §á§â§à§Õ§Ñ§Ø
                if (isSoftCapGoalReached())return State.Success;
                // §³§à§Ò§â§Ñ§ä§î Soft Cap §ß§Ö §å§Õ§Ñ§Ý§à§ã§î, §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö - §á§â§à§Ó§Ñ§Ý
                else return State.Failure;

            }else{

                // §£§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ - §ß§Ö §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß§Ñ
                if (isSecondStageTime)return State.SecondStageFunding;
                // §£§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ - §Ù§Ñ§Ü§à§ß§é§Ú§Ý§Ñ§ã§î
                else return State.SecondStageEnd;

            }
        }
    }

   /**
    * §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â§í
    */

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö §ã§à§à§ä§Ó§Ö§ä§ã§Ó§å§Ö§ä §ã§à§ã§ä§à§ñ§ß§Ú§ð  */
    modifier inState(State state) {
        require(getState() == state);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö - §á§â§à§Õ§Ñ§Ø§Ú: §á§Ö§â§Ó§Ñ§ñ §Ú§Ý§Ú §Ó§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ */
    modifier inFirstOrSecondFundingState() {
        State curState = getState();
        require(curState == State.FirstStageFunding || curState == State.SecondStageFunding);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §ß§Ö §Õ§à§ã§ä§Ú§Ô§ß§å§ä Hard Cap */
    modifier notHardCapReached(){
        require(!isHardCapGoalReached());

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö - §á§â§à§Õ§Ñ§Ø§Ú §á§Ö§â§Ó§à§Û §ã§ä§Ñ§Õ§Ú§Ú §Ú§Ý§Ú §á§Ö§â§Ó§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §Ù§Ñ§Ü§à§ß§é§Ú§Ý§Ñ§ã§î */
    modifier isFirstStageFundingOrEnd() {
        State curState = getState();
        require(curState == State.FirstStageFunding || curState == State.FirstStageEnd);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §Ü§à§ß§ä§â§Ñ§Ü§ä §ß§Ö §æ§Ú§ß§Ñ§Ý§Ú§Ù§Ú§â§à§Ó§Ñ§ß */
    modifier isNotSuccessOver() {
        require(!isSuccessOver);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §Ú§Õ§Ö§ä §Ó§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §Ú§Ý§Ú §Ó§ä§à§â§Ñ§ñ §ã§ä§Ñ§Õ§Ú§ñ §Ù§Ñ§Ó§Ö§â§ê§Ú§Ý§Ñ§ã§î */
    modifier isSecondStageFundingOrEnd() {
        State curState = getState();
        require(curState == State.SecondStageFunding || curState == State.SecondStageEnd);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §Ö§ë§Ö §ß§Ö §Ó§Ü§Ý§ð§é§Ö§ß §â§Ö§Ø§Ú§Þ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §Ú §á§â§à§Õ§Ñ§Ø§Ú §ß§Ö §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§í §å§ã§á§Ö§ç§à§Þ */
    modifier canEnableRefunds(){
        require(!isRefundingEnabled && getState() != State.Success);

        _;
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §á§â§à§Õ§Ñ§Ø§Ú §ß§Ö §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§í §å§ã§á§Ö§ç§à§Þ */
    modifier canSetDestinationMultisigWallet(){
        require(getState() != State.Success);

        _;
    }
}

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

/**
 * §º§Ñ§Ò§Ý§à§ß §Ü§Ý§Ñ§ã§ã§Ñ §ç§â§Ñ§ß§Ú§Ý§Ú§ë§Ñ §ã§â§Ö§Õ§ã§ä§Ó, §Ü§à§ä§à§â§à§Ö §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö §á§â§à§Õ§Ñ§Ø
 * §±§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§ä §Ó§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§Õ§ã§ä§Ó, §Ñ §ä§Ñ§Ü§ä§Ö §á§Ö§â§Ö§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §ß§Ñ §Ü§à§ê§Ö§Ý§Ö§Ü, §Ó §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ê§ß§à§Ô§à §á§â§à§Ó§Ö§Õ§Ö§ß§Ú§ñ §á§â§à§Õ§Ñ§Ø
 */
contract FundsVault is Ownable, ValidationUtil {
    using SafeMath for uint;
    using Math for uint;

    enum State {Active, Refunding, Closed}

    mapping (address => uint256) public deposited;

    address public wallet;

    State public state;

    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    /**
     * §µ§Ü§Ñ§Ù§í§Ó§Ñ§Ö§Þ §ß§Ñ §Ü§Ñ§Ü§à§Û §Ü§à§ê§Ö§Ý§Ö§Ü §Ò§å§Õ§å§ä §á§à§ä§à§Þ §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§í §ã§à§Ò§â§Ñ§ß§ß§í§Ö §ã§â§Ö§Õ§ã§ä§Ó§Ñ, §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ò§å§Õ§Ö§ä §Ó§í§Ù§Ó§Ñ§ß§Ñ §æ§å§ß§Ü§è§Ú§ñ close()
     * §±§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§ä §Ó§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§Õ§ã§ä§Ó, §Ñ §ä§Ñ§Ü§ä§Ö §á§Ö§â§Ö§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §ß§Ñ §Ü§à§ê§Ö§Ý§Ö§Ü, §Ó §ã§Ý§å§é§Ñ§Ö §å§ã§á§Ö§ê§ß§à§Ô§à §á§â§à§Ó§Ö§Õ§Ö§ß§Ú§ñ §á§â§à§Õ§Ñ§Ø
     */
    function FundsVault(address _wallet) {
        requireNotEmptyAddress(_wallet);

        wallet = _wallet;

        state = State.Active;
    }

    /**
     * §±§à§Ý§à§Ø§Ú§ä§î §Õ§Ö§á§à§Ù§Ú§ä §Ó §ç§â§Ñ§ß§Ú§Ý§Ú§ë§Ö
     */
    function deposit(address investor) public payable onlyOwner inState(State.Active) {
        deposited[investor] = deposited[investor].add(msg.value);
    }

    /**
     * §±§Ö§â§Ö§Ó§à§Õ §ã§à§Ò§â§Ñ§ß§ß§í§ç §ã§â§Ö§Õ§ã§ä§Ó §ß§Ñ §å§Ü§Ñ§Ù§Ñ§ß§ß§í§Û §Ü§à§ê§Ö§Ý§Ö§Ü
     */
    function close() public onlyOwner inState(State.Active) {
        state = State.Closed;

        Closed();

        wallet.transfer(this.balance);
    }

    /**
     * §µ§ã§ä§Ñ§ß§à§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §Ü§à§ê§Ö§Ý§Ö§Ü
     */
    function setWallet(address newWalletAddress) public onlyOwner inState(State.Active) {
        wallet = newWalletAddress;
    }

    /**
     * §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §â§Ö§Ø§Ú§Þ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §Õ§Ö§ß§Ö§Ô
     */
    function enableRefunds() public onlyOwner inState(State.Active) {
        state = State.Refunding;

        RefundsEnabled();
    }

    /**
     * §¶§å§ß§Ü§è§Ú§ñ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §ã§â§Ö§Õ§ã§ä§Ó
     */
    function refund(address investor, uint weiAmount) public onlyOwner inState(State.Refunding){
        uint256 depositedValue = weiAmount.min256(deposited[investor]);
        deposited[investor] = 0;
        investor.transfer(depositedValue);

        Refunded(investor, depositedValue);
    }

    /** §´§à§Ý§î§Ü§à, §Ö§ã§Ý§Ú §ä§Ö§Ü§å§ë§Ö§Ö §ã§à§ã§ä§à§ñ§ß§Ú§Ö §ã§à§à§ä§Ó§Ö§ä§ã§Ó§å§Ö§ä §ã§à§ã§ä§à§ñ§ß§Ú§ð  */
    modifier inState(State _state) {
        require(state == _state);

        _;
    }

}

/**
* §¬§à§ß§ä§â§Ñ§Ü§ä §á§â§à§Õ§Ñ§Ø§Ú
* §£§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§Õ§ã§ä§Ó §á§à§Õ§Õ§Ö§â§Ø§Þ§Ó§Ñ§Ö§ä§ã§ñ §ä§à§Ý§î§Ü§à §ä§Ö§Þ, §Ü§ä§à §Ü§å§á§Ú§Ý §ä§à§Ü§Ö§ß§í §é§Ö§â§Ö§Ù §æ§å§ß§Ü§è§Ú§ð internalInvest
* §´§Ñ§Ü§Ú§Þ §à§Ò§â§Ñ§Ù§à§Þ, §Ö§ã§Ý§Ú §Ú§ß§Ó§Ö§ã§ä§à§â§í §Ò§å§Õ§å§ä §à§Ò§Þ§Ö§ß§Ú§Ó§Ñ§ä§î§ã§ñ §ä§à§Ü§Ö§ß§Ñ§Þ§Ú, §ä§à §Ó§Ö§â§ß§å§ä§î §Þ§à§Ø§ß§à §Ò§å§Õ§Ö§ä §ä§à§Ý§î§Ü§à §ä§Ö§Þ, §å §Ü§à§Ô§à §Ó §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö §á§â§à§Õ§Ñ§Ø
* §ä§Ñ§Ü§Ñ§ñ §Ø§Ö §ã§å§Þ§Þ§Ñ §ä§à§Ü§Ö§ß§à§Ó, §Ü§Ñ§Ü §Ú §Ó §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö §ä§à§Ü§Ö§ß§Ñ, §Ó §á§â§à§ä§Ú§Ó§ß§à§Þ §ã§Ý§å§é§Ñ§Ö §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§ß§í§Û §ï§æ§Ú§â §à§ã§ä§Ñ§Ö§ä§ã§ñ §ß§Ñ§Ó§ã§Ö§Ô§Õ§Ñ §Ó §ã§Ú§ã§ä§Ö§Þ§Ö §Ú §ß§Ö §Þ§à§Ø§Ö§ä §Ò§í§ä§î §Ó§í§Ó§Ö§Õ§Ö§ß
*/
contract RefundableAllocatedCappedCrowdsale is AllocatedCappedCrowdsale {

    /**
    * §·§â§Ñ§ß§Ú§Ý§Ú§ë§Ö, §Ü§å§Õ§Ñ §Ò§å§Õ§å§ä §ã§à§Ò§Ú§â§Ñ§ä§î§ã§ñ §ã§â§Ö§Õ§ã§ä§Ó§Ñ, §Õ§Ö§Ý§Ñ§Ö§ä§ã§ñ §Õ§Ý§ñ §ä§à§Ô§à, §é§ä§à§Ò§í §Ô§Ñ§â§Ñ§ß§ä§Ú§â§à§Ó§Ñ§ä§î §Ó§à§Ù§Ó§â§Ñ§ä§í
    */
    FundsVault public fundsVault;

    /** §®§Ñ§á§Ñ §Ñ§Õ§â§Ö§ã §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ - §Ò§í§Ý §Ý§Ú §ã§à§Ó§Ö§â§ê§Ö§ß §Ó§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§ã§ä§Ó */
    mapping (address => bool) public refundedInvestors;

    function RefundableAllocatedCappedCrowdsale(uint _currentEtherRateInCents, address _token, address _destinationMultisigWallet, uint _firstStageStartsAt, uint _firstStageEndsAt, uint _secondStageStartsAt, uint _secondStageEndsAt, address _advisorsAccount, address _marketingAccount, address _supportAccount, address _teamAccount, uint _teamTokensIssueDate) AllocatedCappedCrowdsale(_currentEtherRateInCents, _token, _destinationMultisigWallet, _firstStageStartsAt, _firstStageEndsAt, _secondStageStartsAt, _secondStageEndsAt, _advisorsAccount, _marketingAccount, _supportAccount, _teamAccount, _teamTokensIssueDate) {
        // §³§à§Ù§Õ§Ñ§Ö§Þ §à§ä §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §á§â§à§Õ§Ñ§Ø §ß§à§Ó§à§Ö §ç§â§Ñ§ß§Ú§Ý§Ú§ë§Ö, §Õ§à§ã§ä§å§á §Ü §ß§Ö§Þ§å §Ú§Þ§Ö§Ö§ä §ä§à§Ý§î§Ü§à §Ü§à§ß§ä§â§Ñ§Ü§ä §á§â§à§Õ§Ñ§Ø
        // §±§â§Ú §å§ã§á§Ö§ê§ß§à§Þ §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§Ú§Ú §á§â§à§Õ§Ñ§Ø, §Ó§ã§Ö §ã§à§Ò§â§Ñ§ß§ß§í§Ö §ã§â§Ö§Õ§ã§ä§Ó§Ñ §á§à§ã§ä§å§á§ñ§ä §ß§Ñ _destinationMultisigWallet
        // §£ §á§â§à§ä§Ú§Ó§ß§à§Þ §ã§Ý§å§é§Ñ§Ö §Þ§à§Ô§å§ä §Ò§í§ä§î §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§í §à§Ò§â§Ñ§ä§ß§à §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ§Þ
        fundsVault = new FundsVault(_destinationMultisigWallet);

    }

    /** §µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §ß§à§Ó§í§Û §Ü§à§ê§Ö§Ý§Ö§Ü §Õ§Ý§ñ §æ§Ú§ß§Ñ§Ý§î§ß§à§Ô§à §á§Ö§â§Ö§Ó§à§Õ§Ñ
    */
    function internalSetDestinationMultisigWallet(address destinationAddress) internal{
        fundsVault.setWallet(destinationAddress);

        super.internalSetDestinationMultisigWallet(destinationAddress);
    }

    /** §¶§Ú§ß§Ñ§Ý§Ú§Ù§Ñ§è§Ú§ñ §Ó§ä§à§â§à§Ô§à §ï§ä§Ñ§á§Ñ
    */
    function internalSuccessOver() internal {
        // §µ§ã§á§Ö§ê§ß§à §Ù§Ñ§Ü§â§í§Ó§Ñ§Ö§Þ §ç§â§Ñ§ß§Ú§Ý§Ú§ë§Ö §ã§â§Ö§Õ§ã§ä§Ó §Ú §á§Ö§â§Ö§Ó§à§Õ§Ú§Þ §ï§æ§Ú§â §ß§Ñ §å§Ü§Ñ§Ù§Ñ§ß§ß§í§Û §Ü§à§ê§Ö§Ý§Ö§Ü
        fundsVault.close();

        super.internalSuccessOver();
    }

    /** §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§Ö §æ§å§ß§Ü§è§Ú§Ú §á§â§Ú§ß§ñ§ä§Ú§ñ §Õ§à§á§à§Ù§Ú§ä§Ñ §ß§Ñ §ã§é§Ö§ä, §Ó §Õ§Ñ§ß§ß§à§Þ §ã§Ý§å§é§Ñ§Ö, §Ú§Õ§ä§Ú §Ò§å§Õ§Ö§ä §é§Ö§â§Ö§Ù vault
    */
    function internalDeposit(address receiver, uint weiAmount) internal{
        // §º§Ý§Ö§Þ §ß§Ñ §Ü§à§ê§Ö§Ý§×§Ü §ï§æ§Ú§â
        fundsVault.deposit.value(weiAmount)(msg.sender);
    }

    /** §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§Ö §æ§å§ß§Ü§è§Ú§Ú §Ó§Ü§Ý§ð§é§Ö§ß§Ú§ñ §ã§à§ã§ä§à§ñ§ß§Ú§ñ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ
    */
    function internalEnableRefunds() internal{
        super.internalEnableRefunds();

        fundsVault.enableRefunds();
    }

    /** §±§Ö§â§Ö§à§á§â§Ö§Õ§Ö§Ý§Ö§ß§Ú§Ö §æ§å§ß§Ü§è§Ú§Ú §Ó§à§Ù§Ó§â§Ñ§ä§Ñ, §Ó§à§Ù§Ó§â§Ñ§ä §Þ§à§Ø§ß§à §ã§Õ§Ö§Ý§Ñ§ä§î §ä§à§Ý§î§Ü§à §â§Ñ§Ù
    */
    function internalRefund(address receiver, uint weiAmount) internal{
        // §¥§Ö§Ý§Ñ§Ö§Þ §Ó§à§Ù§Ó§â§Ñ§ä
        // §±§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§Þ §ä§à§Ý§î§Ü§à 1 §Ó§à§Ù§Ó§â§Ñ§ä

        if (refundedInvestors[receiver]) revert();

        fundsVault.refund(receiver, weiAmount);

        refundedInvestors[receiver] = true;
    }

}
pragma solidity ^0.4.21;
 
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
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
 
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
   
  address public owner;
 
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
 
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}
 
/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
 
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
 
  event Burn(address indexed burner, uint indexed value);
 
}
 
contract AriumToken is BurnableToken {
   
  string public constant name = "Arium Token";
   
  string public constant symbol = "ARM";
   
  uint32 public constant decimals = 10;
 
  uint256 public INITIAL_SUPPLY = 400000000000000000;        // supply 40 000 000
 
 
  function AriumToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
 
}
 
contract AriumCrowdsale is Ownable {
   
  using SafeMath for uint;
   
  address multisig;
 
  uint restrictedPercent;
 
  address restricted;
 
  AriumToken public token;
 
  uint start;
   
  uint preico;
 
  uint rate;
 
  uint icostart;
 
  uint ico;
  
  bool hardcap = false;
 
  function AriumCrowdsale(AriumToken _token) {
    token=_token;
    multisig = 0xA2Bfd3EE5ffdd78f7172edF03f31D1184eE627F3;          // ether holder
    restricted = 0x8e7d40bb76BFf10DDe91D1757c4Ceb1A5385415B;        // team holder
    restrictedPercent = 13;             // percent to team
    rate = 10000000000000;
    start = 1521849600;     //start pre ico 03.24.18 00.00.00 GMT
    preico = 30;        // pre ico period
    icostart= 1528588800;       // ico start 06.10.18 00.00.00 GMT
    ico = 67;           // ico period
   
   
  }
 
  modifier saleIsOn() {
    require((now > start && now < start + preico * 1 days) || (now > icostart && now < icostart + ico * 1 days ) );
    _;
  }
 
  function createTokens() saleIsOn payable {
    multisig.transfer(msg.value);
   
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    uint BonusPerAmount = 0;
    if(msg.value >= 0.5 ether && msg.value < 1 ether){
        BonusPerAmount = tokens.div(20);                     // 5% 5/100=1/20
    } else if (msg.value >= 1 ether && msg.value < 5 ether){
        BonusPerAmount = tokens.div(10);                     // 10%
    } else if (msg.value >= 5 ether && msg.value < 10 ether){
        BonusPerAmount = tokens.mul(15).div(100);
    } else if (msg.value >= 10 ether && msg.value < 20 ether){
        BonusPerAmount = tokens.div(5);
    } else if (msg.value >= 20 ether){
        BonusPerAmount = tokens.div(4);
    }
    if(now < start + (preico * 1 days).div(3)) {
      bonusTokens = tokens.div(10).mul(3);
    } else if(now >= start + (preico * 1 days).div(3) && now < start + (preico * 1 days).div(3).mul(2)) {
      bonusTokens = tokens.div(5);
    } else if(now >= start + (preico * 1 days).div(3).mul(2) && now < start + (preico * 1 days)) {
      bonusTokens = tokens.div(10);
    }
    uint tokensWithBonus = tokens.add(BonusPerAmount);
    tokensWithBonus = tokensWithBonus.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(restrictedPercent).div(100);
    token.transfer(restricted, restrictedTokens);
  }
 
    function ManualTransfer(address _to , uint ammount) saleIsOn onlyOwner payable{           //function for manual transfer(purchase with no ETH)
    token.transfer(_to, rate.div(1000).mul(ammount));                              
    }
    

    function BurnUnsoldToken(uint _value) onlyOwner payable{                                // burn unsold token after
        token.burn(_value);
    }
    
    function setHardcupTrue() onlyOwner{
        hardcap = true;
    }
    function setHardcupFalse() onlyOwner{
        hardcap = false;
    }
 
  function() external payable {
    createTokens();
  }
   
}
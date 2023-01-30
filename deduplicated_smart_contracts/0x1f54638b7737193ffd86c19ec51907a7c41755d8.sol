pragma solidity ^0.4.17;



/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
}




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) returns (bool){
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

}




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value) returns (bool);
  function approve(address spender, uint value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
}




/**
 * @title Standard ERC20 token
 *
 * @dev Implemantation of the basic standart token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);

    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);

    return true;
  }

  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Sola Token
 * @dev ERC20 Sola Token (SOL)
 *
 * Sola Tokens are divisible by 1e6 (1,000,000) base
 * units referred to as &#39;Rays&#39;.
 *
 * Sola Tokens are displayed using 6 decimal places of precision.
 *
 * 1 SOL is equivalent to:
 *   1000000 == 1 * 10**6 == 1e6 == One Million Rays
 *
 */
 contract SolaToken is StandardToken {
  //FIELDS
  string public constant name = "Sola Token";
  string public constant symbol = "SOL";
  uint8  public constant decimals = 6;

  //CONSTANTS
  //SOL Token limits
  uint256 public constant FUTURE_DEVELOPMENT_FUND = 55e6 * (10 ** uint256(decimals));
  uint256 public constant INCENT_FUND_VESTING     = 27e6 * (10 ** uint256(decimals));
  uint256 public constant INCENT_FUND_NON_VESTING = 3e6  * (10 ** uint256(decimals));
  uint256 public constant TEAM_FUND               = 15e6 * (10 ** uint256(decimals));
  uint256 public constant SALE_FUND               = 50e6 * (10 ** uint256(decimals));

  //Start time
  uint64 public constant PUBLIC_START_TIME = 1514210400; // GMT: Monday, December 25, 2017 2:00:00 PM
  
  //ASSIGNED IN INITIALIZATION
  //Special Addresses
  address public openLedgerAddress;
  address public futureDevelopmentFundAddress;
  address public incentFundAddress;
  address public teamFundAddress;
  
  //booleans
  bool public saleTokensHaveBeenMinted = false;
  bool public fundsTokensHaveBeenMinted = false;

  function SolaToken(address _openLedger, address _futureDevelopmentFund, address _incentFund, address _teamFund) {
    openLedgerAddress = _openLedger;
    futureDevelopmentFundAddress = _futureDevelopmentFund;
    incentFundAddress = _incentFund;
    teamFundAddress = _teamFund;
  }

  function mint(address _to, uint256 _value) private {
    totalSupply = totalSupply.add(_value);
    balances[_to] = balances[_to].add(_value);

    Transfer(0x0, _to, _value);
  }

  function mintFundsTokens() public {
    require(!fundsTokensHaveBeenMinted);

    fundsTokensHaveBeenMinted = true;

    mint(futureDevelopmentFundAddress, FUTURE_DEVELOPMENT_FUND);
    mint(incentFundAddress, INCENT_FUND_VESTING + INCENT_FUND_NON_VESTING);
    mint(teamFundAddress, TEAM_FUND);
}

  function mintSaleTokens(uint256 _value) public {
    require(!saleTokensHaveBeenMinted);
    require(_value <= SALE_FUND);

    saleTokensHaveBeenMinted = true;

    mint(openLedgerAddress, _value);
  }
}
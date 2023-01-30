pragma solidity ^0.4.11;


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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
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
  function transfer(address _to, uint256 _value) public returns (bool success) {
    if (balances[msg.sender] >= _value) {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
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
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
      balances[_to] = balances[_to].add(_value);
      balances[_from] = balances[_from].sub(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract ARCDToken is MintableToken {
    string public constant name = "Arcade Token";
    string public constant symbol = "ARCD";
    uint8 public constant decimals = 18;
    string public version = "1.0";
}


contract Crowdsale {
    function buyTokens(address _recipient) public payable;
}

contract ARCDCrowdsale is Crowdsale {
    using SafeMath for uint256;

    // metadata
    uint256 public constant decimals = 18;

    // contracts
    // deposit address for ETH for Arcade City
    address public constant ETH_FUND_DEPOSIT = 0x3b2470E99b402A333a82eE17C3244Ff04C79Ec6F;
    // deposit address for Arcade City use and ARCD User Fund
    address public constant ARCD_FUND_DEPOSIT = 0x3b2470E99b402A333a82eE17C3244Ff04C79Ec6F;

    // crowdsale parameters
    bool public isFinalized;                                                    // switched to true in operational state
    uint256 public constant FUNDING_START_TIMESTAMP = 1511919480;               // 11/29/2017 @ 1:38am UTC
    uint256 public constant FUNDING_END_TIMESTAMP = FUNDING_START_TIMESTAMP + (60 * 60 * 24 * 90); // 90 days
    uint256 public constant ARCD_FUND = 92 * (10**8) * 10**decimals;            // 9.2B for Arcade City
    uint256 public constant TOKEN_EXCHANGE_RATE = 200000;                       // 200,000 ARCD tokens per 1 ETH
    uint256 public constant TOKEN_CREATION_CAP =  10 * (10**9) * 10**decimals;  // 10B total
    uint256 public constant MIN_BUY_TOKENS = 20000 * 10**decimals;              // 0.1 ETH
    uint256 public constant GAS_PRICE_LIMIT = 60 * 10**9;                       // Gas limit 60 gwei

    // events
    event CreateARCD(address indexed _to, uint256 _value);

    ARCDToken public token;

    // constructor
    function ARCDCrowdsale () public {
      token = new ARCDToken();

      // sanity checks
      assert(ETH_FUND_DEPOSIT != 0x0);
      assert(ARCD_FUND_DEPOSIT != 0x0);
      assert(FUNDING_START_TIMESTAMP < FUNDING_END_TIMESTAMP);
      assert(uint256(token.decimals()) == decimals);

      isFinalized = false;

      token.mint(ARCD_FUND_DEPOSIT, ARCD_FUND);
      CreateARCD(ARCD_FUND_DEPOSIT, ARCD_FUND);
    }

    /// @dev Accepts ether and creates new ARCD tokens.
    function createTokens() payable external {
      buyTokens(msg.sender);
    }

    function () public payable {
      buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
      require (!isFinalized);
      require (block.timestamp >= FUNDING_START_TIMESTAMP);
      require (block.timestamp <= FUNDING_END_TIMESTAMP);
      require (msg.value != 0);
      require (beneficiary != 0x0);
      require (tx.gasprice <= GAS_PRICE_LIMIT);

      uint256 tokens = msg.value.mul(TOKEN_EXCHANGE_RATE); // check that we&#39;re not over totals
      uint256 checkedSupply = token.totalSupply().add(tokens);

      // return money if something goes wrong
      require (TOKEN_CREATION_CAP >= checkedSupply);

      // return money if tokens is less than the min amount
      // the min amount does not apply if the availables tokens are less than the min amount.
      require (tokens >= MIN_BUY_TOKENS || (TOKEN_CREATION_CAP.sub(token.totalSupply())) <= MIN_BUY_TOKENS);

      token.mint(beneficiary, tokens);
      CreateARCD(beneficiary, tokens);  // logs token creation

      forwardFunds();
    }

    function finalize() public {
      require (!isFinalized);
      require (block.timestamp > FUNDING_END_TIMESTAMP || token.totalSupply() == TOKEN_CREATION_CAP);
      require (msg.sender == ETH_FUND_DEPOSIT);
      isFinalized = true;
      token.finishMinting();
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
      ETH_FUND_DEPOSIT.transfer(msg.value);
    }
}
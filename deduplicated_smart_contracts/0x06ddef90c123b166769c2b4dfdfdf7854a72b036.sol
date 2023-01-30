pragma solidity ^0.4.11;

/*
  Set of classes OpenZeppelin
*/

/*
*****************************************************************************************

below is &#39;OpenZeppelin  - Ownable.sol&#39;

*/

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





/*
*****************************************************************************************
below is &#39;OpenZeppelin  - ERC20Basic.sol&#39;

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


/*
*****************************************************************************************
below is &#39;OpenZeppelin  - BasicToken.sol&#39;

*/
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicFrozenToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  
    /**
   * @dev mapping sender -> unfrozeTimestamp
   * when sender is unfrozen
   */
  mapping(address => uint256) unfrozeTimestamp;

    // Custom code - checking for on frozen
  // @return true if the sending is allowed (not frozen)
  function isUnfrozen(address sender) public constant returns (bool) {
    // frozeness is checked until  07.07.18 00:00:00 (1530921600), after all tokens are minted as unfrozen
    if(now > 1530921600)
      return true;
    else
     return unfrozeTimestamp[sender] < now;
  }


  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function frozenTimeOf(address _owner) public constant returns (uint256 balance) {
    return unfrozeTimestamp[_owner];
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    // Custom code - checking for frozen state
    require(isUnfrozen(msg.sender));

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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}



/*
*****************************************************************************************
below is &#39;OpenZeppelin  - ERC20.sol&#39;

*/


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




/*
*****************************************************************************************

below is &#39;OpenZeppelin  - StandardToken.sol&#39;

*/

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicFrozenToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    
    // Custom code - проверка на факт разморозки
    require(isUnfrozen(_from));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
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
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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





/*
*****************************************************************************************
below is &#39;OpenZeppelin  - SafeMath.sol&#39;
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
 * @title Quasacoin token
 * Based on code by OpenZeppelin MintableToken.sol
 
  + added frozing when minting
 
 */

contract QuasacoinToken is StandardToken, Ownable {
    
  string public name = "Quasacoin";
  string public symbol = "QUA";
  uint public decimals = 18;
  
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
    require(_to != address(0));
    require(_amount > 0);

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    uint frozenTime = 0; 
    // frozeness is checked until  07.07.18 00:00:00 (1530921600), after all tokens are minted as unfrozen
    if(now < 1530921600) {
      // выпуск                      до 15.01.18 00:00:00 (1515974400) - заморозка до 30.03.18 00:00:00 (1522368000)
      if(now < 1515974400)
        frozenTime = 1522368000;

      // выпуск c 15.01.18 00:00:00  до 15.02.18 00:00:00 (1518652800) - заморозка до 30.05.18 00:00:00 (1527638400)     
      else if(now < 1518652800)
        frozenTime = 1527638400;

      // выпуск c 15.02.18 00:00:00  до 26.03.18 00:00:00 (1522022400) - заморозка до 30.06.18 00:00:00 (1530316800)
      else if(now < 1522022400)
        frozenTime = 1530316800;

      // выпуск c 26.03.18 00:00:00  до 15.04.18 00:00:00 (1523750400) - заморозка до 01.07.18 00:00:00 (1530403200)
      else if(now < 1523750400)
        frozenTime = 1530403200;

      // выпуск c 15.04.18 00:00:00  до 15.05.18 00:00:00 (1526342400) - заморозка до 07.07.18 00:00:00 (1530921600)
      else if(now < 1526342400)
        frozenTime = 1530921600;

      // выпуск c 15.05.18 00:00:00  до 15.06.18 00:00:00 (1529020800) - заморозка до 30.06.18 00:00:00 (1530316800)
      else if(now < 1529020800)
        frozenTime = 1530316800;
      else 
      // выпуск с 15.06.18 00:00:00  после до 07.07.18 00:00:00 (1530921600) - заморозка до 07.07.18 00:00:00 (1530921600)
        frozenTime = 1530921600;
      unfrozeTimestamp[_to] = frozenTime;
    }

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


/**
 * @title QuasocoinCrowdsale
 * based upon OpenZeppelin CrowdSale smartcontract
 */
contract QuasacoinTokenCrowdsale {
  using SafeMath for uint256;

  // The token being sold
  QuasacoinToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startPreICOTime;
  // переход из preICO в ICO
  uint256 public startICOTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // кому вернуть ownership после завершения ICO
  address public tokenOwner;

  // how many token units a buyer gets per wei
  uint256 public ratePreICO;
  uint256 public rateICO;

  // amount of raised money in wei
  uint256 public weiRaisedPreICO;
  uint256 public weiRaisedICO;

  uint256 public capPreICO;
  uint256 public capICO;

  mapping(address => bool) internal allowedMinters;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function QuasacoinTokenCrowdsale() {
    token = QuasacoinToken(0x4dAeb4a06F70f4b1A5C329115731fE4b89C0B227);
    tokenOwner = 0x373ae730d8c4250b3d022a65ef998b8b7ab1aa53;
    wallet = 0x373ae730d8c4250b3d022a65ef998b8b7ab1aa53;

    // 15.01.18 00:00:00 (1515974400) 
    startPreICOTime = 1515974400;
    // 15.02.18 00:00:00 (1518652800)
    startICOTime = 1518652800;
    // 26.03.18 00:00:00 (1522022400)
    endTime = 1522022400;
    
    // Pre-ICO, 1 ETH = 6000 QUA
    ratePreICO = 6000;

    // ICO, 1 ETH = 3000 QUA
    rateICO = 3000;

    capPreICO = 5000 ether;
    capICO = 50000 ether;
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens;
    if(now < startICOTime) {  
      weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
      tokens = weiAmount * ratePreICO;
    } 
    else {
      weiRaisedICO = weiRaisedICO.add(weiAmount);
      tokens = weiAmount * rateICO;
    }

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
   
    if(now >= startPreICOTime && now < startICOTime) {
      return weiRaisedPreICO.add(msg.value) <= capPreICO;
    } else if(now >= startICOTime && now < endTime) {
      return weiRaisedICO.add(msg.value) <= capICO;
    } else
    return false;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    if(now < startPreICOTime)
      return false;
    else if(now >= startPreICOTime && now < startICOTime) {
      return weiRaisedPreICO >= capPreICO;
    } else if(now >= startICOTime && now < endTime) {
      return weiRaisedICO >= capICO;
    } else
      return true;
  }

  function returnTokenOwnership() public {
    require(msg.sender == tokenOwner);
    token.transferOwnership(tokenOwner);
  }

  function addMinter(address addr) {
    require(msg.sender == tokenOwner);
    allowedMinters[addr] = true;
  }
  function removeMinter(address addr) {
    require(msg.sender == tokenOwner);
    allowedMinters[addr] = false;
  }

  function mintProxy(address _to, uint256 _amount) public {
    require(allowedMinters[msg.sender]);
    require(now >= startPreICOTime && now < endTime);
    
    uint256 weiAmount;

    if(now < startICOTime) {
      weiAmount = _amount.div(ratePreICO);
      require(weiRaisedPreICO.add(weiAmount) <= capPreICO);
      weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
    } 
    else {
      weiAmount = _amount.div(rateICO);
      require(weiRaisedICO.add(weiAmount) <= capICO);
      weiRaisedICO = weiRaisedICO.add(weiAmount);
    }

    token.mint(_to, _amount);
    TokenPurchase(msg.sender, _to, weiAmount, _amount);
  }
}
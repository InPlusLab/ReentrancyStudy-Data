/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

/**
 *Submitted for verification at Etherscan.io on 2018-05-04
*/

pragma solidity ^0.4.23;
    /**
    * @title ERC20Basic
    * @dev Simpler version of ERC20 interface
    * @dev see https://github.com/ethereum/EIPs/issues/179
    */
    contract ERC20Basic {
    uint256 public totalSupply;
     function balanceOf(address who) public view returns (uint256);
     function transfer(address to, uint256 value) public returns (bool);
     event Transfer(address indexed from, address indexed to, uint256 value);
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
     constructor() public {
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


   /**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  // allowedAddresses will be able to transfer even when locked
  // lockedAddresses will *not* be able to transfer even when *not locked*
  mapping(address => bool) public allowedAddresses;
  mapping(address => bool) public lockedAddresses;
  bool public locked = true;

  function allowAddress(address _addr, bool _allowed) public onlyOwner {
    require(_addr != owner);
    allowedAddresses[_addr] = _allowed;
  }

  function lockAddress(address _addr, bool _locked) public onlyOwner {
    require(_addr != owner);
    lockedAddresses[_addr] = _locked;
  }

  function setLocked(bool _locked) public onlyOwner {
    locked = _locked;
  }

  function canTransfer(address _addr) public constant returns (bool) {
    if(locked){
      if(!allowedAddresses[_addr]&&_addr!=owner) return false;
    }else if(lockedAddresses[_addr]) return false;

    return true;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(canTransfer(msg.sender));


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
/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 is ERC20Basic {
 function allowance(address owner, address spender) public view returns (uint256);
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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(canTransfer(msg.sender));

    uint256 _allowance = allowed[_from][msg.sender];

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
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
using SafeMath for uint;
    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, address(0), _value);
    }
}

contract PlayerWonCoin is BurnableToken {

    string public constant name = "PlayerWonCoin";
    string public constant symbol = "pwon";
    uint public constant decimals = 18;
    // there is no problem in using * here instead of .mul()
    uint256 public constant initialSupply = 1000000000 * (10 ** uint256(decimals));

    // Constructors
    function PlayerWonCoin () {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; // Send all tokens to owner
        allowedAddresses[owner] = true;
    }

}



    /**
    * @title Pausable
    * @dev Base contract which allows children to implement an emergency stop mechanism.
    */
    contract Pausable is Ownable {
     event Pause();
     event Unpause();

     bool public paused = false;


     /**
      * @dev Modifier to make a function callable only when the contract is not paused.
      */
      modifier whenNotPaused() {
       require(!paused);
       _;
     }

     /**
      * @dev Modifier to make a function callable only when the contract is paused.
      */
      modifier whenPaused() {
       require(paused);
       _;
     }

     /**
      * @dev called by the owner to pause, triggers stopped state
      */
      function pause() onlyOwner whenNotPaused public {
       paused = true;
       emit Pause();
     }

     /**
      * @dev called by the owner to unpause, returns to normal state
      */
      function unpause() onlyOwner whenPaused public {
       paused = false;
       emit Unpause();
     }
   }

    
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
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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
    /**
    * @title Crowdsale
    * @dev Crowdsale is a base contract for managing a token crowdsale,
    * allowing investors to purchase tokens with ether. This contract implements
    * such functionality in its most fundamental form and can be extended to provide additional
    * functionality and/or custom behavior.
    * The external interface represents the basic interface for purchasing tokens, and conform
    * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
    * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
    * the methods to add functionality. Consider using 'super' where appropiate to concatenate
    * behavior.
    */
    contract Crowdsale is Pausable{
     using SafeMath for uint256;
     // The token being sold
     BurnableToken public token;
     // Address where funds are collected
     address public wallet;
     // How many token units a buyer gets per wei
     uint256 public rate = 1883800000000000000000;
     // Amount of tokens sold
     uint256 tokensSold;
     uint256 public weiRaised; 
    //Star of the crowdsale
     uint256 startTime;
     uint256 phaze1Start = 1564617600; 
     uint256 phaze1End = 1567209600; 
     uint256 phaze2Start = 1567296000; 
     uint256 phaze2End = 1569801600; 
     uint256 phaze3Start = 1569888000; 
     uint256 phaze3End = 1572480000; 
    uint256 rate1 = 3767600000000000000000; 
     uint256 rate2 = 2354750000000000000000;
     uint256 rate3 = 2093100000000000000000; 
     uint256 public hardcap = 250000000000000000000000000;



     /**
      * Event for token purchase logging
      * @param purchaser who paid for the tokens
      * @param beneficiary who got the tokens
      * @param value weis paid for purchase
      * @param amount amount of tokens purchased
      */
      event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 time);

      event buyx(address buyer, address contractAddr, uint256 amount);

      constructor(address _wallet, BurnableToken _token, uint256 starttime, uint256 _cap) public{

       require(_wallet != address(0));
       require(_token != address(0));

       wallet = _wallet;
       token = _token;
       startTime = starttime;
       hardcap = _cap; 
     }
     
     function setWallet(address wl) public onlyOwner {
         wallet=wl; 
     }
     
     function setphase1(uint256 rte) public onlyOwner{
         rate1 = rte; 
     }
         function setphase2(uint256 rte) public onlyOwner{
         rate2 = rte; 
     }
         function setphase3(uint256 rte) public onlyOwner{
         rate3 = rte; 
     }
     function setCrowdsale(address _wallet, BurnableToken _token, uint256 starttime, uint256 _cap) public onlyOwner{


       require(_wallet != address(0));
       require(_token != address(0));

       wallet = _wallet;
       token = _token;
       startTime = starttime;
       hardcap = _cap; 
     }



     // -----------------------------------------
     // Crowdsale external interface
     // -----------------------------------------
     /**
      *  fallback function ***DO NOT OVERRIDE***
      */
      function () external whenNotPaused payable {
        emit buyx(msg.sender, this, _getTokenAmount(msg.value));
        buyTokens(msg.sender);
      }
     /**
      * @dev low level token purchase ***DO NOT OVERRIDE***
      * @param _beneficiary Address performing the token purchase
      */
     function buyTokens(address _beneficiary) public whenNotPaused payable {
       
     

       if ((block.timestamp >= phaze1Start ) && (block.timestamp <= phaze1End) && (tokensSold <= 40000000000000000000000000)&&(weiRaised <= hardcap)) {
         rate = rate1;
       }
       else if ((block.timestamp >= phaze2Start) && (block.timestamp <= phaze2End)&&(tokensSold <= hardcap)) {
        rate = rate2;
       }
       else if ((block.timestamp >= phaze3Start) && (block.timestamp <= phaze3End)&&(tokensSold <= hardcap)) {
        rate = rate3; 
       }
       else {
           rate = 10000000000000000000; 
       }
      


      uint256 weiAmount = msg.value;
      uint256 tokens = _getTokenAmount(weiAmount);
      tokensSold = tokensSold.add(tokens);
      weiRaised = weiRaised.add(weiAmount); 
      _processPurchase(_beneficiary, tokens);
      emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens, block.number);
      _updatePurchasingState(_beneficiary, weiAmount);
      _forwardFunds();
      _postValidatePurchase(_beneficiary, weiAmount);
    }

    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------



     /**
      * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
      * @param _beneficiary Address performing the token purchase
      * @param _weiAmount Value in wei involved in the purchase
      */
      function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
       require(_beneficiary != address(0));
       require(_weiAmount != 0);
     }
     /**
      * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
      * @param _beneficiary Address performing the token purchase
      * @param _weiAmount Value in wei involved in the purchase
      */
      function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
       // optional override
     }
     /**
      * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
      * @param _beneficiary Address performing the token purchase
      * @param _tokenAmount Number of tokens to be emitted
      */
      function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
       token.transfer(_beneficiary, _tokenAmount);
     }
     /**
      * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
      * @param _beneficiary Address receiving the tokens
      * @param _tokenAmount Number of tokens to be purchased
      */
      function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
       _deliverTokens(_beneficiary, _tokenAmount);
     }
     /**
      * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
      * @param _beneficiary Address receiving the tokens
      * @param _weiAmount Value in wei involved in the purchase
      */
      function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
       // optional override
     }
     /**
      * @dev Override to extend the way in which ether is converted to tokens.
      * @param _weiAmount Value in wei to be converted into tokens
      * @return Number of tokens that can be purchased with the specified _weiAmount
      */
      function _getTokenAmount(uint256 _weiAmount) internal  returns (uint256) {
uint256 tmp = rate.div(1000000000000000000); 
       return _weiAmount.mul(tmp);
     }

     /**
      * @dev Determines how ETH is stored/forwarded on purchases.
      */
      function _forwardFunds() internal {
       wallet.transfer(msg.value);
     }

   }



   contract WonCrowdsale is Crowdsale {
    uint256  hardcap=250000000000000000000000000;
    uint256 public starttime;

    using SafeMath for uint256;
    constructor(address wallet, BurnableToken token, uint256 startTime) Crowdsale(wallet, token, starttime, hardcap) public onlyOwner
    {

     
      starttime = startTime;
      setCrowdsale(wallet, token, startTime, hardcap);

    }



function transferTokenOwnership(address newOwner) public onlyOwner {
  token.transferOwnership(newOwner); 
}


   function () external payable  whenNotPaused{

    emit buyx(msg.sender, this, _getTokenAmount(msg.value));

    buyTokens(msg.sender);
  }


}
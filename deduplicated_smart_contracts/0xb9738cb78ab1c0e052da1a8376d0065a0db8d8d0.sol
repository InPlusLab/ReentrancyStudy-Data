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
  function transfer(address _to, uint256 _value) public returns (bool) {
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
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
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

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
 * @title StandardCrowdsale 
 * @dev StandardCrowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract StandardCrowdsale {
    using SafeMath for uint256;

    // The token being sold
    StandardToken public token; 

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    function StandardCrowdsale(
        uint256 _startTime, 
        uint256 _endTime, 
        uint256 _rate, 
        address _wallet) 
    {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        
        token = createTokenContract(); 
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract() 
        internal 
        returns(StandardToken) 
    {
        return new StandardToken();
    }

    // fallback function can be used to buy tokens
    function () 
       payable 
    {
        buyTokens();
    }

    // low level token purchase function
    function buyTokens() 
       public 
       payable 
    {
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens += getBonus(tokens);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        require(token.transfer(msg.sender, tokens)); 
        TokenPurchase(msg.sender, weiAmount, tokens);

        forwardFunds();

        postBuyTokens();
    }

    // Action after buying tokens
    function postBuyTokens ()
        internal
    {
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() 
       internal 
    {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() 
        internal 
        returns(bool) 
    {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() 
        public 
        constant 
        returns(bool) 
    {
        return now > endTime;
    }

    modifier onlyBeforeSale() {
        require(now < startTime);
        _;
    }

    modifier only24HBeforeSale() {
        require(now < startTime.sub(1 days));
        _;
    }

    function getBonus(uint256 _tokens) constant returns (uint256 bonus) {
        return 0;
    }
}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is StandardCrowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

/**
 * @title The MINDToken contract
 * @dev The MINDToken Token contract
 * @dev inherite from StandardToken and Ownable by Zeppelin
 */
contract MINDToken is StandardToken, Ownable {
    string  public  constant name = "MIND Token";
    string  public  constant symbol = "MIND";
    uint8    public  constant decimals = 18;

    uint    public  transferableStartTime;

    address public  tokenSaleContract;
    address public  fullTokenWallet;

    function gettransferableStartTime() constant returns (uint){return now - transferableStartTime;}

    modifier onlyWhenTransferEnabled() 
    {
        if ( now < transferableStartTime ) {
            require(msg.sender == tokenSaleContract || msg.sender == fullTokenWallet || msg.sender == owner);
        }
        _;
    }

    modifier validDestination(address to) 
    {
        require(to != address(this));
        _;
    }

    modifier onlySaleContract()
    {
        require(msg.sender == tokenSaleContract);
        _;
    }

    function MINDToken(
        uint tokenTotalAmount, 
        uint _transferableStartTime, 
        address _admin, 
        address _fullTokenWallet) 
    {
        
        // Mint all tokens. Then disable minting forever.
        totalSupply = tokenTotalAmount * (10 ** uint256(decimals));

        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);

        transferableStartTime = _transferableStartTime;
        tokenSaleContract = msg.sender;
        fullTokenWallet = _fullTokenWallet;

        transferOwnership(_admin); // admin could drain tokens and eth that were sent here by mistake

    }

    /**
     * @dev override transfer token for a specified address to add onlyWhenTransferEnabled and validDestination
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint _value)
        public
        validDestination(_to)
        onlyWhenTransferEnabled
        returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    /**
     * @dev override transferFrom token for a specified address to add onlyWhenTransferEnabled and validDestination
     * @param _from The address to transfer from.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        validDestination(_to)
        onlyWhenTransferEnabled
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    /**
     * @dev burn tokens
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burn(uint _value) 
        public
        onlyWhenTransferEnabled
        onlyOwner
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    /**
     * @dev burn tokens in the behalf of someone
     * @param _from The address of the owner of the token.
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burnFrom(address _from, uint256 _value) 
        public
        onlyWhenTransferEnabled
        onlyOwner
        returns(bool) 
    {
        assert(transferFrom(_from, msg.sender, _value));
        return burn(_value);
    }

    /** 
    * enable transfer earlier (only presale contract can enable the sale earlier)
    */
    function enableTransferEarlier ()
        public
        onlySaleContract
    {
        transferableStartTime = now + 3 days;
    }


    /**
     * @dev transfer to owner any tokens send by mistake on this contracts
     * @param token The address of the token to transfer.
     * @param amount The amount to be transfered.
     */
    function emergencyERC20Drain(ERC20 token, uint amount )
        public
        onlyOwner 
    {
        token.transfer(owner, amount);
    }

}

/**
 * @title MINDTokenCrowdSale
 * @dev 
 * We add new features to a base crowdsale using multiple inheritance.
 * We are using the following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 *
 * The code is based on the contracts of Open Zeppelin and we add our contracts : MINDTokenCrowdSale and the MIND Token
 *
 */
contract MINDTokenCrowdSale is Ownable, CappedCrowdsale {

    // hard cap of the token pre-sale in ether
    uint private constant HARD_CAP_IN_WEI = 2000 ether;
    
    // Token sale rate from ETH to MIND
    uint private constant RATE_ETH_MIND = 10000;

    // wallet use also to gather the ether of the token sale
    address private constant MIND_CROWDSALE_WALLET = 0x942b56E5A6e92B39643dCB5F232EF583680F0B01;

    event CrowdSaleTokenSoldout();

    function MINDTokenCrowdSale(uint256 _startTime, uint256 _endTime, address _tokenAddr)
      CappedCrowdsale(HARD_CAP_IN_WEI)
      StandardCrowdsale(_startTime, _endTime, RATE_ETH_MIND, MIND_CROWDSALE_WALLET)
    {
        token = MINDToken(_tokenAddr);
    }

    function getToken() constant returns (address){
      return token;
    }

    /**
     * @dev Create the MIND token (override createTokenContract of StandardCrowdsale)
     * @return the StandardToken created
     */
    function createTokenContract () 
      internal 
      returns(StandardToken) 
    {
        return MINDToken(0x0); // No token is created
    }

    /**
      * @dev Get the bonus based on the buy time (override getBonus of StandardCrowdsale)
      * @return the number of bonus token
    */
    function getBonus(uint256 _tokens) constant returns (uint256 bonus) {
        require(_tokens != 0);
        if (startTime <= now && now < startTime + 1 days) {
            // 20% bonus
            return _tokens.div(5);
        } else if (startTime + 1 days <= now && now < startTime + 2 days ) {
            // 15% bonus
            return _tokens.mul(3).div(20);
        } else if (startTime + 2 days <= now && now < startTime + 3 days ) {
            // 10% bonus
            return _tokens.div(10);
        } else if (startTime + 3 days <= now && now < startTime + 4 days ) {
            // 5% bonus
            return _tokens.div(20);
        }

        return 0;
    }

    /**
     * @dev Transfer the unsold tokens to the MIND Foundation multisign wallet 
     * @dev Only for owner
     * @return the StandardToken created
     */
    function drainRemainingToken () 
      public
      onlyOwner
    {
        require(hasEnded());
        token.transfer(MIND_CROWDSALE_WALLET, token.balanceOf(this));
    }


    /**
      * @dev Action after buying tokens: check if all sold out and enable transfer immediately
      */
    function postBuyTokens ()
        internal
    {
        if ( token.balanceOf(this) == 0 ) 
        {
            CrowdSaleTokenSoldout();
        }
    }

    // @return true if the transaction can buy tokens
    function validPurchase() 
        internal 
        returns(bool) 
    {
        return super.validPurchase() && msg.value >= 0.1 ether;
    }
}
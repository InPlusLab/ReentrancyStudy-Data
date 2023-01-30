pragma solidity ^0.4.18;



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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


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
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract EthixToken is PausableToken {
  string public constant name = "EthixToken";
  string public constant symbol = "ETHIX";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));
  uint256 public totalSupply;

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function EthixToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[owner] = totalSupply;
    Transfer(0x0, owner, INITIAL_SUPPLY);
  }

}


/**
 * @title TokenDistributionStrategy
 * @dev Base abstract contract defining methods that control token distribution
 */
contract TokenDistributionStrategy {
  using SafeMath for uint256;

  CompositeCrowdsale crowdsale;
  uint256 rate;

  modifier onlyCrowdsale() {
    require(msg.sender == address(crowdsale));
    _;
  }

  function TokenDistributionStrategy(uint256 _rate) {
    require(_rate > 0);
    rate = _rate;
  }

  function initializeDistribution(CompositeCrowdsale _crowdsale) {
    require(crowdsale == address(0));
    require(_crowdsale != address(0));
    crowdsale = _crowdsale;
  }

  function returnUnsoldTokens(address _wallet) onlyCrowdsale {
    
  }

  function whitelistRegisteredAmount(address beneficiary) view returns (uint256 amount) {
  }

  function distributeTokens(address beneficiary, uint amount);

  function calculateTokenAmount(uint256 _weiAmount, address beneficiary) view returns (uint256 amount);

  function getToken() view returns(ERC20);

  

}


/**
 * @title FixedPoolWithBonusTokenDistributionStrategy 
 * @dev Strategy that distributes a fixed number of tokens among the contributors,
 * with a percentage depending in when the contribution is made, defined by periods.
 * It&#39;s done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 * This class is abstract, the intervals have to be defined by subclassing
 */
contract FixedPoolWithBonusTokenDistributionStrategy is TokenDistributionStrategy {
  using SafeMath for uint256;
  uint256 constant MAX_DISCOUNT = 100;

  // Definition of the interval when the bonus is applicable
  struct BonusInterval {
    //end timestamp
    uint256 endPeriod;
    // percentage
    uint256 bonus;
  }
  BonusInterval[] bonusIntervals;
  bool intervalsConfigured = false;

  // The token being sold
  ERC20 token;
  mapping(address => uint256) contributions;
  uint256 totalContributed;
  //mapping(uint256 => BonusInterval) bonusIntervals;

  function FixedPoolWithBonusTokenDistributionStrategy(ERC20 _token, uint256 _rate)
           TokenDistributionStrategy(_rate) public
  {
    token = _token;
  }


  // First period will go from crowdsale.start_date to bonusIntervals[0].end
  // Next intervals have to end after the previous ones
  // Last interval must end when the crowdsale ends
  // All intervals must have a positive bonus (penalizations are not contemplated)
  modifier validateIntervals {
    _;
    require(intervalsConfigured == false);
    intervalsConfigured = true;
    require(bonusIntervals.length > 0);
    for(uint i = 0; i < bonusIntervals.length; ++i) {
      require(bonusIntervals[i].bonus <= MAX_DISCOUNT);
      require(bonusIntervals[i].bonus >= 0);
      require(crowdsale.startTime() < bonusIntervals[i].endPeriod);
      require(bonusIntervals[i].endPeriod <= crowdsale.endTime());
      if (i != 0) {
        require(bonusIntervals[i-1].endPeriod < bonusIntervals[i].endPeriod);
      }
    }
  }

  // Init intervals
  function initIntervals() validateIntervals {
  }

  function calculateTokenAmount(uint256 _weiAmount, address beneficiary) view returns (uint256 tokens) {
    // calculate bonus in function of the time
    for (uint i = 0; i < bonusIntervals.length; i++) {
      if (now <= bonusIntervals[i].endPeriod) {
        // calculate token amount to be created
        tokens = _weiAmount.mul(rate);
        // OP : tokens + ((tokens * bonusIntervals[i].bonus) / 100)
        // BE CAREFULLY with decimals
        return tokens.add(tokens.mul(bonusIntervals[i].bonus).div(100));
      }
    }
    return _weiAmount.mul(rate);
  }

  function distributeTokens(address _beneficiary, uint256 _tokenAmount) onlyCrowdsale {
    contributions[_beneficiary] = contributions[_beneficiary].add(_tokenAmount);
    totalContributed = totalContributed.add(_tokenAmount);
    require(totalContributed <= token.balanceOf(this));
  }

  function compensate(address _beneficiary) {
    require(crowdsale.hasEnded());
    if (token.transfer(_beneficiary, contributions[_beneficiary])) {
      contributions[_beneficiary] = 0;
    }
  }

  function getTokenContribution(address _beneficiary) view returns(uint256){
    return contributions[_beneficiary];
  }

  function getToken() view returns(ERC20) {
    return token;
  }

  function getIntervals() view returns (uint256[] _endPeriods, uint256[] _bonuss) {
    uint256[] memory endPeriods = new uint256[](bonusIntervals.length);
    uint256[] memory bonuss = new uint256[](bonusIntervals.length);
    for (uint256 i=0; i<bonusIntervals.length; i++) {
      endPeriods[i] = bonusIntervals[i].endPeriod;
      bonuss[i] = bonusIntervals[i].bonus;
    }
    return (endPeriods, bonuss);
  }

}


/**
 * @title VestedTokenDistributionStrategy
 * @dev Strategy that distributes a fixed number of tokens among the contributors.
 * It&#39;s done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 */
contract VestedTokenDistributionStrategy is Ownable, FixedPoolWithBonusTokenDistributionStrategy {


  event Released(address indexed beneficiary, uint256 indexed amount);

  //Time after which is allowed to compensates
  uint256 public vestingStart;
  bool public vestingConfigured = false;
  uint256 public vestingDuration;

  mapping (address => uint256) public released;

  modifier vestingPeriodStarted {
    require(crowdsale.hasEnded());
    require(vestingConfigured == true);
    require(now > vestingStart);
    _;
  }

  function VestedTokenDistributionStrategy(ERC20 _token, uint256 _rate)
            Ownable()
            FixedPoolWithBonusTokenDistributionStrategy(_token, _rate) {

  }

  /**
   * set the parameters for the compensation. Required to call before compensation
   * @dev WARNING, ONE TIME OPERATION
   * @param _vestingStart we start allowing  the return of tokens after this
   * @param _vestingDuration percent each day (1 is 1% each day, 2 is % each 2 days, max 100)
   */
  function configureVesting(uint256 _vestingStart, uint256 _vestingDuration) onlyOwner {
    require(vestingConfigured == false);
    require(_vestingStart > crowdsale.endTime());
    require(_vestingDuration > 0);
    vestingStart = _vestingStart;
    vestingDuration = _vestingDuration;
    vestingConfigured = true;
  }

  /**
   * Will transfer the tokens vested until now to the beneficiary, if the vestingPeriodStarted
   * and there is an amount left to transfer
   * @param  _beneficiary crowdsale contributor
   */
   function compensate(address _beneficiary) public onlyOwner vestingPeriodStarted {
     uint256 unreleased = releasableAmount(_beneficiary);

     require(unreleased > 0);

     released[_beneficiary] = released[_beneficiary].add(unreleased);

     require(token.transfer(_beneficiary, unreleased));
     Released(_beneficiary,unreleased);

   }

  /**
   * Calculates how many tokens the beneficiary should get taking in account already
   * released
   * @param  _beneficiary the contributor
   * @return token number
   */
   function releasableAmount(address _beneficiary) public view returns (uint256) {
     return vestedAmount(_beneficiary).sub(released[_beneficiary]);
   }

  /**
   * Calculates how many tokens the beneficiary have vested
   * vested = how many does she have according to the time
   * @param  _beneficiary address of the contributor that needs the tokens
   * @return amount of tokens
   */
  function vestedAmount(address _beneficiary) public view returns (uint256) {
    uint256 totalBalance = contributions[_beneficiary];
    //Duration("after",vestingStart.add(vestingDuration));
    if (now < vestingStart || vestingConfigured == false) {
      return 0;
    } else if (now >= vestingStart.add(vestingDuration)) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(vestingStart)).div(vestingDuration);
    }
  }

  function getReleased(address _beneficiary) public view returns (uint256) {
    return released[_beneficiary];
  }

}


/**
 * @title WhitelistedDistributionStrategy
 * @dev This is an extension to add whitelist to a token distributionStrategy
 *
 */
contract WhitelistedDistributionStrategy is Ownable, VestedTokenDistributionStrategy {
    uint256 public constant maximumBidAllowed = 500 ether;

    uint256 rate_for_investor;
    mapping(address=>uint) public registeredAmount;

    event RegistrationStatusChanged(address target, bool isRegistered);

    function WhitelistedDistributionStrategy(ERC20 _token, uint256 _rate, uint256 _whitelisted_rate)
              VestedTokenDistributionStrategy(_token,_rate){
        rate_for_investor = _whitelisted_rate;
    }

    /**
     * @dev Changes registration status of an address for participation.
     * @param target Address that will be registered/deregistered.
     * @param amount the amount of eht to invest for a investor bonus.
     */
    function changeRegistrationStatus(address target, uint256 amount)
        public
        onlyOwner
    {
        require(amount <= maximumBidAllowed);
        registeredAmount[target] = amount;
        if (amount > 0){
            RegistrationStatusChanged(target, true);
        }else{
            RegistrationStatusChanged(target, false);
        }
    }

    /**
     * @dev Changes registration statuses of addresses for participation.
     * @param targets Addresses that will be registered/deregistered.
     * @param amounts the list of amounts of eth for every investor to invest for a investor bonus.
     */
    function changeRegistrationStatuses(address[] targets, uint256[] amounts)
        public
        onlyOwner
    {
        require(targets.length == amounts.length);
        for (uint i = 0; i < targets.length; i++) {
            changeRegistrationStatus(targets[i], amounts[i]);
        }
    }

    /**
     * @dev overriding calculateTokenAmount for whilelist investors
     * @return bonus rate if it applies for the investor,
     * otherwise, return token amount according to super class
     */

    function calculateTokenAmount(uint256 _weiAmount, address beneficiary) view returns (uint256 tokens) {
        if (_weiAmount >= registeredAmount[beneficiary] && registeredAmount[beneficiary] > 0 ){
            tokens = _weiAmount.mul(rate_for_investor);
        } else{
            tokens = super.calculateTokenAmount(_weiAmount, beneficiary);
        }
    }

    /**
     * @dev getRegisteredAmount for whilelist investors
     * @return registered amount if it applies for the investor,
     * otherwise, return 0 
     */

    function whitelistRegisteredAmount(address beneficiary) view returns (uint256 amount) {
        amount = registeredAmount[beneficiary];
    }
}


/**
 * @title EthicHubTokenDistributionStrategy
 * @dev Strategy that distributes a fixed number of tokens among the contributors,
 * with a percentage deppending in when the contribution is made, defined by periods.
 * It&#39;s done in two steps. First, it registers all of the contributions while the sale is active.
 * After the crowdsale has ended the contract compensate buyers proportionally to their contributions.
 * Contributors registered to the whitelist will have better rates
 */
contract EthicHubTokenDistributionStrategy is Ownable, WhitelistedDistributionStrategy {
  
  event UnsoldTokensReturned(address indexed destination, uint256 amount);


  function EthicHubTokenDistributionStrategy(EthixToken _token, uint256 _rate, uint256 _rateForWhitelisted)
           WhitelistedDistributionStrategy(_token, _rate, _rateForWhitelisted)
           public
  {

  }


  // Init intervals
  function initIntervals() onlyOwner validateIntervals  {

    //For extra security, we check the owner of the crowdsale is the same of the owner of the distribution
    require(owner == crowdsale.owner());

    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 1 days,10));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 2 days,10));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 3 days,8));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 4 days,6));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 5 days,4));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 6 days,2));
  }

  function returnUnsoldTokens(address _wallet) onlyCrowdsale {
    //require(crowdsale.endTime() <= now); //this made no sense
    if (token.balanceOf(this) == 0) {
      UnsoldTokensReturned(_wallet,0);
      return;
    }
    
    uint256 balance = token.balanceOf(this).sub(totalContributed);
    require(balance > 0);

    if(token.transfer(_wallet, balance)) {
      UnsoldTokensReturned(_wallet, balance);
    }
    
  } 
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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





/**
 * @title CompositeCrowdsale
 * @dev CompositeCrowdsale is a base contract for managing a token crowdsale.
 * Contrary to a classic crowdsale, it favours composition over inheritance.
 *
 * Crowdsale behaviour can be modified by specifying TokenDistributionStrategy
 * which is a dedicated smart contract that delegates all of the logic managing
 * token distribution.
 *
 */
contract CompositeCrowdsale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  TokenDistributionStrategy public tokenDistribution;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function CompositeCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet, TokenDistributionStrategy _tokenDistribution) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != 0x0);
    require(address(_tokenDistribution) != address(0));

    startTime = _startTime;
    endTime = _endTime;

    tokenDistribution = _tokenDistribution;
    tokenDistribution.initializeDistribution(this);

    wallet = _wallet;
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = tokenDistribution.calculateTokenAmount(weiAmount, beneficiary);
    // update state
    weiRaised = weiRaised.add(weiAmount);

    tokenDistribution.distributeTokens(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}



/**
 * @title CappedCompositeCrowdsale
 * @dev Extension of CompositeCrowdsale with a max amount of funds raised
 */
contract CappedCompositeCrowdsale is CompositeCrowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCompositeCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinCap && super.validPurchase();
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

/**
 * @title FinalizableCompositeCrowdsale
 * @dev Extension of CompositeCrowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCompositeCrowdsale is CompositeCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract&#39;s finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}


/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}



/**
 * @title RefundableCompositeCrowdsale
 * @dev Extension of CompositeCrowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale&#39;s vault.
 */
contract RefundableCompositeCrowdsale is FinalizableCompositeCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCompositeCrowdsale(uint256 _goal) {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We&#39;re overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

}

contract EthicHubPresale is Ownable, Pausable, CappedCompositeCrowdsale, RefundableCompositeCrowdsale {

  uint256 public constant minimumBidAllowed = 0.1 ether;
  uint256 public constant maximumBidAllowed = 100 ether;
  uint256 public constant WHITELISTED_PREMIUM_TIME = 1 days;


  mapping(address=>uint) public participated;

  /**
   * @dev since our wei/token conversion rate is different, we implement it separatedly
   *      from Crowdsale
   * [EthicHubPresale description]
   * @param       _startTime start time in unix timestamp format
   * @param       _endTime time in unix timestamp format
   * @param       _goal minimum wei amount to consider the project funded.
   * @param       _cap maximum amount the crowdsale will accept.
   * @param       _wallet where funds are collected.
   * @param       _tokenDistribution Strategy to distributed tokens.
   */
  function EthicHubPresale(uint256 _startTime, uint256 _endTime, uint256 _goal, uint256 _cap, address _wallet, EthicHubTokenDistributionStrategy _tokenDistribution)
    CompositeCrowdsale(_startTime, _endTime, _wallet, _tokenDistribution)
    CappedCompositeCrowdsale(_cap)
    RefundableCompositeCrowdsale(_goal)
  {

    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    require(_goal <= _cap);
  }

  function claimRefund() public {
    super.claimRefund();
  }

  /**
   * We enforce a minimum purchase price and a maximum investemnt per wallet
   * @return valid
   */
  function buyTokens(address beneficiary) whenNotPaused payable {
    require(msg.value >= minimumBidAllowed);
    require(participated[msg.sender].add(msg.value) <= maximumBidAllowed);
    participated[msg.sender] = participated[msg.sender].add(msg.value);

    super.buyTokens(beneficiary);
  }

  /**
  * Get user invested amount by his address, used to calculate user referral contribution
  * @return total invested amount
  */
  function getInvestedAmount(address investor) view public returns(uint investedAmount){
    investedAmount = participated[investor];
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // whitelisted user can purchase tokens one day before the ico stated
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    // whitelist exclusive purchasing time
    if ((now >= startTime.sub(WHITELISTED_PREMIUM_TIME)) && (now <= startTime)){
        uint256 registeredAmount = tokenDistribution.whitelistRegisteredAmount(msg.sender);
        bool isWhitelisted = registeredAmount > 0;
        bool withinCap = weiRaised.add(msg.value) <= cap;
        bool nonZeroPurchase = msg.value != 0;
        return isWhitelisted && withinCap && nonZeroPurchase;
    } else {
        return super.validPurchase();
    }
  }

  /**
  * When the crowdsale is finished, we send the remaining tokens back to the wallet
  */
  function finalization() internal {
    super.finalization();
    tokenDistribution.returnUnsoldTokens(wallet);
  }
}
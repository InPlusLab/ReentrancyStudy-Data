pragma solidity ^0.4.18;

// File: contracts/ownership/Ownable.sol

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

// File: contracts/math/SafeMath.sol

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

// File: contracts/token/ERC20Basic.sol

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

// File: contracts/token/BasicToken.sol

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

// File: contracts/token/ERC20.sol

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

// File: contracts/token/StandardToken.sol

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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
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

// File: contracts/token/MintableToken.sol

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
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/PagosToken.sol

contract PagosToken is MintableToken {
    string public constant name = "Pagos Token";
    string public constant symbol = "PGO";
    uint8 public decimals = 18;
    bool public tradingStarted = false;

    /**
     * @dev modifier that throws if trading has not started yet
     */
    modifier hasStartedTrading() {
        require(tradingStarted);
        _;
    }

    /**
     * @dev Allows the owner to enable the trading.
     */
    function startTrading() onlyOwner public {
        tradingStarted = true;
    }

    /**
     * @dev Allows anyone to transfer the PagosToken tokens once trading has started
     * @param _to the recipient address of the tokens.
     * @param _value number of tokens to be transfered.
     */
    function transfer(address _to, uint _value) hasStartedTrading public returns (bool){
        return super.transfer(_to, _value);
    }


    /**
     * @dev Allows anyone to transfer the  tokens once trading has started
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint _value) hasStartedTrading public returns (bool){
        return super.transferFrom(_from, _to, _value);
    }

    /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value) public hasStartedTrading returns (bool) {
        return super.approve(_spender, _value);
    }

    /**
     * Adding whenNotPaused
     */
    function increaseApproval(address _spender, uint _addedValue) public hasStartedTrading returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
     * Adding whenNotPaused
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public hasStartedTrading returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

// File: contracts/crowdsale/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

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
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  // overrided to create custom buy
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // overrided to create custom fund forwarding mechanisms
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

// File: contracts/crowdsale/FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
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
  function finalization() internal{
  }
}

// File: contracts/PagosCrowdSale.sol

contract PagosCrowdSale is FinalizableCrowdsale {
    using SafeMath for uint256;

    // number of participants in the Pagos Pre-Sale
    uint256 public numberOfPurchasers = 0;

    // maximum tokens that can be minted in this crowd sale
    uint256 public maxTokenSupply = 0;

    // version cache buster
    string public constant version = "v1.4";

    // pending contract owner
    address public pendingOwner;

    // number of participants in the Pagos Pre-Sale
    uint256 public minimumAmount = 0;

    // Reserved amount
    address public reservedAddr;
    uint256 public reservedAmount;

    // different token supply and rate once in publicSale mode
    uint256 public ratePublicSale;
    uint256 public maxTokenSupplyPublicSale;


    function PagosCrowdSale(uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    uint256 _minimumAmount,
    uint256 _maxTokenSupply,
    address _wallet,
    address _reservedAddr,
    uint256 _reservedAmount,
    address _pendingOwner,
    uint256 _ratePublicSale,
    uint256 _maxTokenSupplyPublicSale
    )
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, _rate, _wallet) public
    {
        require(_pendingOwner != address(0));
        require(_minimumAmount >= 0);
        require(_maxTokenSupply > 0);
        require(_reservedAmount > 0 && _reservedAmount < _maxTokenSupply);

        pendingOwner = _pendingOwner;
        minimumAmount = _minimumAmount;
        maxTokenSupply = _maxTokenSupply;

        // reserved amount
        reservedAddr = _reservedAddr;
        reservedAmount = _reservedAmount;

        // different rate for the public sale
        ratePublicSale=_ratePublicSale;
        maxTokenSupplyPublicSale=_maxTokenSupplyPublicSale;

    }

    /**
    *
    * Create the token on the fly, owner is the contract, not the contract owner yet
    *
    **/
    function createTokenContract() internal returns (MintableToken) {
        return new PagosToken();
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        //
        require(validPurchase());
        // buying can only begins as soon as the owner ship has been transfered
        require(owner==pendingOwner);

        uint256 weiAmount = msg.value;

        // make sure we accept only the minimum contribution
        // require(weiAmount>minimumAmount);

        // Compute the number of tokens per wei
        // bonus structure should be used here, if any
        uint256 tokens = weiAmount.mul(rate);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        // update
        weiRaised = weiRaised.add(weiAmount);
        numberOfPurchasers = numberOfPurchasers + 1;

        forwardFunds();
    }

    // overriding Crowdsale#validPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function validPurchase() internal view returns (bool) {

        // make sure we accept only the minimum contribution
        bool minAmount = (msg.value >= minimumAmount);

        // cap crowdsaled to a maxTokenSupply
        // make sure we can not mint more token than expected
        bool lessThanMaxSupply = (token.totalSupply() + msg.value.mul(rate)) <= maxTokenSupply;

        //bool withinCap = weiRaised.add(msg.value) <= cap;
        return super.validPurchase() && minAmount && lessThanMaxSupply;
    }

    // overriding Crowdsale#hasEnded to add cap logic
    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        bool capReached = token.totalSupply() >= maxTokenSupply;
        return super.hasEnded() || capReached;
    }

    /**
     *
     * Admin functions only called by owner:
     * Can change rate
     *
     */

    /**
      *
      * Called when the admin function finalize is called :
      *
      * it mint the remaining amount to have the supply exactly as planned
      * it transfer the ownership of the token to the owner of the smart contract
      *
      */
    function finalization() internal {
        //
        // send back to the owner the remaining tokens before finishing minting
        // it ensure that there is only a exact maxTokenSupply token minted ever
        //
        uint256 remainingTokens = maxTokenSupply - token.totalSupply();

        // mint the remaining amount and assign them to the owner
        token.mint(owner, remainingTokens);
        TokenPurchase(owner, owner, 0, remainingTokens);

        // finalize the refundable inherited contract
        super.finalization();

        // no more minting allowed - immutable
        token.finishMinting();

        // transfer the token owner ship from the contract address to the real owner
        token.transferOwnership(owner);
    }

    /**
      *
      * Admin functions only called by owner:
      * Can change rate
      *
      */
    function changeMinimumAmount(uint256 _minimumAmount) onlyOwner public {
        require(_minimumAmount > 0);
        minimumAmount = _minimumAmount;
    }

    /**
      *
      * Admin functions only called by owner:
      * Can change events dates
      *
      */
    function changeDates(uint256 _startTime, uint256 _endTime) onlyOwner public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        startTime = _startTime;
        endTime = _endTime;
    }

    /**
      *
      * Admin functions only called by owner:
      * Switch to publicSale mode, maxToken supply is changed as well as the normal rate
      *
      */
    function publicSaleMode() onlyOwner public returns (uint256){
        rate=ratePublicSale;
        maxTokenSupply=maxTokenSupplyPublicSale;
        return ratePublicSale;
    }


    /**
      *
      * Admin functions only called by owner:
      * Change the owner
      *
      */
    function transferOwnerShipToPendingOwner() public {

        // only the pending owner can change the ownership
        require(msg.sender == pendingOwner);

        // can only be changed one time
        require(owner != pendingOwner);

        // raise the event
        OwnershipTransferred(owner, pendingOwner);

        // change the ownership
        owner = pendingOwner;

        // run the PreMint
        runPreMint();

    }

    // run the pre minting
    // for now yes, after it will be done during the ownership transfer call

    function runPreMint() onlyOwner private {

        token.mint(reservedAddr, reservedAmount);
        TokenPurchase(owner, reservedAddr, 0, reservedAmount);

        // update state
        numberOfPurchasers = numberOfPurchasers + 1;
    }

}
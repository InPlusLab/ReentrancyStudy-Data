pragma solidity ^0.4.21;

// File: zeppelin-solidity/contracts/Ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/Ownership/Contactable.sol

/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable {

  string public contactInformation;

  /**
    * @dev Allows the owner to set a string with their contact information.
    * @param info The contact information to attach to the contract.
    */
  function setContactInformation(string info) onlyOwner public {
    contactInformation = info;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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
    totalSupply_ = totalSupply_.add(_amount);
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

// File: contracts/RootsSaleToken.sol

contract RootsSaleToken is Contactable, MintableToken {

    string constant public name = "ROOTS Sale Token";
    string constant public symbol = "ROOTSSale";
    uint constant public decimals = 18;

    bool public isTransferable = false;

    function transfer(address _to, uint _value) public returns (bool) {
        require(isTransferable);
        return false;
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        require(isTransferable);
        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(isTransferable);
        return false;
    }

    function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool) {
        require(isTransferable);
        return false;
    }
}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: contracts/RootsSale.sol

contract RootsSale is Pausable {
  using SafeMath for uint256;

  // The token being sold
  RootsSaleToken public token;

  // start and end timestamps where purchases are allowed (both inclusive)
  uint public startTime;
  uint public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint public rate;

  // amount of raised money in wei
  uint public weiRaised;

  // amount of tokens that was sold on the crowdsale
  uint public tokensSold;

  // maximum amount of wei in total, that can be bought
  uint public weiMaximumGoal;

  // minimum amount of wel, that can be contributed
  uint public weiMinimumAmount;

  // maximum amount of wei, that can be contributed
  uint public weiMaximumAmount;

  // How many distinct addresses have bought
  uint public buyerCount;

  // how much ETH each address has bought to this crowdsale
  mapping (address => uint) public boughtAmountOf;

  // whether a buyer already bought some tokens
  mapping (address => bool) public isBuyer;

  // whether a buyer bought tokens through other currencies
  mapping (address => bool) public isExternalBuyer;

  address public admin;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param tokenAmount amount of tokens purchased
   */
  event TokenPurchase(
      address indexed purchaser,
      address indexed beneficiary,
      uint value,
      uint tokenAmount
  );

  function RootsSale(
      uint _startTime,
      uint _endTime,
      uint _rate,
      RootsSaleToken _token,
      address _wallet,
      uint _weiMaximumGoal,
      uint _weiMinimumAmount,
      uint _weiMaximumAmount,
      address _admin
  ) public
  {
      require(_startTime >= now);
      require(_endTime >= _startTime);
      require(_rate > 0);
      require(address(_token) != 0x0);
      require(_wallet != 0x0);
      require(_weiMaximumGoal > 0);
      require(_admin != 0x0);

      startTime = _startTime;
      endTime = _endTime;
      token = _token;
      rate = _rate;
      wallet = _wallet;
      weiMaximumGoal = _weiMaximumGoal;
      weiMinimumAmount = _weiMinimumAmount;
      weiMaximumAmount = _weiMaximumAmount;
      admin = _admin;
  }


  modifier onlyOwnerOrAdmin() {
      require(msg.sender == owner || msg.sender == admin);
      _;
  }

  // fallback function can be used to buy tokens
  function () external payable {
      buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public whenNotPaused payable returns (bool) {
      uint weiAmount = msg.value;

      require(beneficiary != 0x0);
      require(weiAmount >= weiMinimumAmount);
      require(weiAmount <= weiMaximumAmount);
      require(validPurchase(msg.value));

      // calculate token amount to be created
      uint tokenAmount = calculateTokenAmount(weiAmount, weiRaised);

      mintTokenToBuyer(beneficiary, tokenAmount, weiAmount);

      wallet.transfer(msg.value);

      return true;
  }

  function mintTokenToBuyer(address beneficiary, uint tokenAmount, uint weiAmount) internal {
      if (!isBuyer[beneficiary]) {
          // A new buyer
          buyerCount++;
          isBuyer[beneficiary] = true;
      }

      boughtAmountOf[beneficiary] = boughtAmountOf[beneficiary].add(weiAmount);
      weiRaised = weiRaised.add(weiAmount);
      tokensSold = tokensSold.add(tokenAmount);

      token.mint(beneficiary, tokenAmount);
      TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
  }

  // return true if the transaction can buy tokens
  function validPurchase(uint weiAmount) internal constant returns (bool) {
      bool withinPeriod = now >= startTime && now <= endTime;
      bool withinCap = weiRaised.add(weiAmount) <= weiMaximumGoal;

      return withinPeriod && withinCap;
  }

  // return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
      bool capReached = weiRaised >= weiMaximumGoal;
      bool afterEndTime = now > endTime;

      return capReached || afterEndTime;
  }

  // get the amount of unsold tokens allocated to this contract;
  function getWeiLeft() external constant returns (uint) {
      return weiMaximumGoal - weiRaised;
  }

  // allows to update tokens rate for owner
  function setPricingStrategy(
    uint _startTime,
    uint _endTime,
    uint _rate,
    uint _weiMaximumGoal,
    uint _weiMinimumAmount,
    uint _weiMaximumAmount
)  external onlyOwner returns (bool) {
    require(!hasEnded());
    require(_endTime >= _startTime);
    require(_weiMaximumGoal > 0);

    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    weiMaximumGoal = _weiMaximumGoal;
    weiMinimumAmount = _weiMinimumAmount;
    weiMaximumAmount = _weiMaximumAmount;
    return true;
  }

  function registerPayment(address beneficiary, uint tokenAmount, uint weiAmount) public onlyOwnerOrAdmin {
      require(validPurchase(weiAmount));
      isExternalBuyer[beneficiary] = true;
      mintTokenToBuyer(beneficiary, tokenAmount, weiAmount);
  }

  function registerPayments(address[] beneficiaries, uint[] tokenAmounts, uint[] weiAmounts) external onlyOwnerOrAdmin {
      require(beneficiaries.length == tokenAmounts.length);
      require(tokenAmounts.length == weiAmounts.length);

      for (uint i = 0; i < beneficiaries.length; i++) {
          registerPayment(beneficiaries[i], tokenAmounts[i], weiAmounts[i]);
      }
  }

  function setAdmin(address adminAddress) external onlyOwner {
      admin = adminAddress;
  }

  /** Calculate the current price for buy in amount. */
  function calculateTokenAmount(uint weiAmount, uint weiRaised) public view returns (uint tokenAmount) {
      return weiAmount.mul(rate);
  }

  function changeTokenOwner(address newOwner) external onlyOwner {
      require(newOwner != 0x0);
      require(hasEnded());

      token.transferOwnership(newOwner);
  }

  function finishMinting() public onlyOwnerOrAdmin {
      require(hasEnded());

      token.finishMinting();
  }


}
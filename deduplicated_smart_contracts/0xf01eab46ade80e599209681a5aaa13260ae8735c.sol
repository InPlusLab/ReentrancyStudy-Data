pragma solidity ^0.4.19;

// File: contracts/utility/ContractReceiverInterface.sol

contract ContractReceiverInterface {
    function receiveApproval(
        address from,
        uint256 _amount,
        address _token,
        bytes _data) public;
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/utility/SafeContract.sol

contract SafeContract is Ownable {

    /**
     * @notice Owner can transfer out any accidentally sent ERC20 tokens
     */
    function transferAnyERC20Token(address _tokenAddress, uint256 _tokens, address _beneficiary) public onlyOwner returns (bool success) {
        return ERC20Basic(_tokenAddress).transfer(_beneficiary, _tokens);
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
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
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

// File: zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
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

// File: contracts/token/FriendsFingersToken.sol

/**
 * @title FriendsFingersToken
 */
contract FriendsFingersToken is DetailedERC20, MintableToken, BurnableToken, SafeContract {

    address public builder;

    modifier canTransfer() {
        require(mintingFinished);
        _;
    }

    function FriendsFingersToken(
        string _name,
        string _symbol,
        uint8 _decimals
    )
    DetailedERC20 (_name, _symbol, _decimals)
    public
    {
        builder = owner;
    }

    function transfer(address _to, uint _value) canTransfer public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) canTransfer public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
        require(approve(_spender, _amount));

        ContractReceiverInterface(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

}

// File: zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

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

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }

  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    return weiAmount.mul(rate);
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

}

// File: zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return capReached || super.hasEnded();
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinCap && super.validPurchase();
  }

}

// File: zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol

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
  function finalization() internal {
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

// File: contracts/crowdsale/FriendsFingersCrowdsale.sol

/**
 * @title FriendsFingersCrowdsale
 */
contract FriendsFingersCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable, SafeContract {

    enum State { Active, Refunding, Closed, Blocked, Expired }

    uint256 public id;
    uint256 public previousRoundId;
    uint256 public nextRoundId;

    // The token being sold
    FriendsFingersToken public token;

    // the round of crowdsale
    uint256 public round;

    // minimum amount of funds to be raised in weis
    uint256 public goal;

    string public crowdsaleInfo;

    uint256 public friendsFingersRatePerMille;
    address public friendsFingersWallet;

    uint256 public investorCount = 0;
    mapping (address => uint256) public deposited;
    State public state;

    event Closed();
    event Expired();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    function FriendsFingersCrowdsale(
        uint256 _id,
        uint256 _cap,
        uint256 _goal,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        FriendsFingersToken _token,
        string _crowdsaleInfo,
        uint256 _round,
        uint256 _previousRoundId,
        uint256 _friendsFingersRatePerMille,
        address _friendsFingersWallet
    ) public
    CappedCrowdsale (_cap)
    FinalizableCrowdsale ()
    Crowdsale (_startTime, _endTime, _rate, _wallet)
    {
        require(_endTime <= _startTime + 30 days);
        require(_token != address(0));

        require(_round <= 5);
        if (_round == 1) {
            if (_id == 1) {
                require(_goal >= 0);
            } else {
                require(_goal > 0);
            }
        } else {
            require(_goal == 0);
        }
        require(_cap > 0);
        require(_cap >= _goal);

        goal = _goal;

        crowdsaleInfo = _crowdsaleInfo;

        token = _token;

        round = _round;
        previousRoundId = _previousRoundId;
        state = State.Active;

        id = _id;

        friendsFingersRatePerMille = _friendsFingersRatePerMille;
        friendsFingersWallet = _friendsFingersWallet;
    }

    // low level token purchase function
    function buyTokens(address beneficiary) whenNotPaused public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );

        forwardFunds();
    }

    // Public methods

    // if crowdsale is unsuccessful or blocked, investors can claim refunds here
    function claimRefund() whenNotPaused public {
        require(state == State.Refunding || state == State.Blocked);
        address investor = msg.sender;

        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

    function finalize() whenNotPaused public {
        super.finalize();
    }

    // View methods

    function goalReached() view public returns (bool) {
        return weiRaised >= goal;
    }

    // Only owner methods

    function updateCrowdsaleInfo(string _crowdsaleInfo) onlyOwner public {
        require(!hasEnded());
        crowdsaleInfo = _crowdsaleInfo;
    }

    function blockCrowdsale() onlyOwner public {
        require(state == State.Active);
        state = State.Blocked;
    }

    function setnextRoundId(uint256 _nextRoundId) onlyOwner public {
        nextRoundId = _nextRoundId;
    }

    function setFriendsFingersRate(uint256 _newFriendsFingersRatePerMille) onlyOwner public {
        require(_newFriendsFingersRatePerMille >= 0);
        require(_newFriendsFingersRatePerMille <= friendsFingersRatePerMille);
        friendsFingersRatePerMille = _newFriendsFingersRatePerMille;
    }

    function setFriendsFingersWallet(address _friendsFingersWallet) onlyOwner public {
        require(_friendsFingersWallet != address(0));
        friendsFingersWallet = _friendsFingersWallet;
    }

    // Emergency methods

    function safeWithdrawal() onlyOwner public {
        require(now >= endTime + 1 years);
        friendsFingersWallet.transfer(this.balance);
    }

    function setExpiredAndWithdraw() onlyOwner public {
        require((state == State.Refunding || state == State.Blocked) && now >= endTime + 1 years);
        state = State.Expired;
        friendsFingersWallet.transfer(this.balance);
        Expired();
    }

    // Internal methods

    /**
     * @dev Create new instance of token contract
     */
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(address(0));
    }

    // overriding CappedCrowdsale#validPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function validPurchase() internal view returns (bool) {
        bool isActive = state == State.Active;
        return isActive && super.validPurchase();
    }

    // We&#39;re overriding the fund forwarding from Crowdsale.
    function forwardFunds() internal {
        if (deposited[msg.sender] == 0) {
            investorCount++;
        }
        deposited[msg.sender] = deposited[msg.sender].add(msg.value);
    }

    // vault finalization task, called when owner calls finalize()
    function finalization() internal {
        require(state == State.Active);

        if (goalReached()) {
            state = State.Closed;
            Closed();

            if (friendsFingersRatePerMille > 0) {
                uint256 friendsFingersFee = weiRaised.mul(friendsFingersRatePerMille).div(1000);
                friendsFingersWallet.transfer(friendsFingersFee);
            }

            wallet.transfer(this.balance);
        } else {
            state = State.Refunding;
            RefundsEnabled();
        }

        if (friendsFingersRatePerMille > 0) {
            uint256 friendsFingersSupply = cap.mul(rate).mul(friendsFingersRatePerMille).div(1000);
            token.mint(owner, friendsFingersSupply);
        }

        token.transferOwnership(owner);

        super.finalization();
    }

}

// File: contracts/FriendsFingersBuilder.sol

/**
 * @title FriendsFingersBuilder
 */
contract FriendsFingersBuilder is Pausable, SafeContract {
    using SafeMath for uint256;

    event CrowdsaleStarted(address ffCrowdsale);
    event CrowdsaleClosed(address ffCrowdsale);

    uint public version = 1;
    string public website = "https://www.friendsfingers.com";
    uint256 public friendsFingersRatePerMille = 50; //5%
    address public friendsFingersWallet;
    mapping (address => bool) public enabledAddresses;

    uint256 public crowdsaleCount = 0;
    mapping (uint256 => address) public crowdsaleList;
    mapping (address => address) public crowdsaleCreators;

    modifier onlyOwnerOrEnabledAddress() {
        require(enabledAddresses[msg.sender] || msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrCreator(address _ffCrowdsale) {
        require(msg.sender == crowdsaleCreators[_ffCrowdsale] || msg.sender == owner);
        _;
    }

    function FriendsFingersBuilder(address _friendsFingersWallet) public {
        setMainWallet(_friendsFingersWallet);
    }

    /**
     * @notice This is for people who want to donate ETH to FriendsFingers
     */
    function () public payable {
        require(msg.value != 0);
        friendsFingersWallet.transfer(msg.value);
    }

    // crowdsale utility methods

    function startCrowdsale(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        uint256 _cap,
        uint256 _goal,
        uint256 _creatorSupply,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        string _crowdsaleInfo
    ) whenNotPaused public returns (FriendsFingersCrowdsale)
    {
        crowdsaleCount++;
        uint256 _round = 1;

        FriendsFingersToken token = new FriendsFingersToken(
            _tokenName,
            _tokenSymbol,
            _tokenDecimals
        );

        if (_creatorSupply > 0) {
            token.mint(_wallet, _creatorSupply);
        }

        FriendsFingersCrowdsale ffCrowdsale = new FriendsFingersCrowdsale(
        crowdsaleCount,
        _cap,
        _goal,
        _startTime,
        _endTime,
        _rate,
        _wallet,
        token,
        _crowdsaleInfo,
        _round,
        0,
        friendsFingersRatePerMille,
        friendsFingersWallet
        );

        if (crowdsaleCount > 1) {
            ffCrowdsale.pause();
        }

        token.transferOwnership(address(ffCrowdsale));

        addCrowdsaleToList(address(ffCrowdsale));

        return ffCrowdsale;
    }

    function restartCrowdsale(
        address _ffCrowdsale,
        uint256 _cap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        string _crowdsaleInfo
    ) whenNotPaused onlyOwnerOrCreator(_ffCrowdsale) public returns (FriendsFingersCrowdsale)
    {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        // can&#39;t restart twice
        require(ffCrowdsale.nextRoundId() == 0);
        // can&#39;t restart if goal not reached or rate greater or equal old rate
        require(ffCrowdsale.goalReached());
        require(_rate < ffCrowdsale.rate());

        ffCrowdsale.finalize();

        crowdsaleCount++;
        uint256 _round = ffCrowdsale.round();
        _round++;

        FriendsFingersToken token = ffCrowdsale.token();

        FriendsFingersCrowdsale newFriendsFingersCrowdsale = new FriendsFingersCrowdsale(
            crowdsaleCount,
            _cap,
            0,
            _startTime,
            _endTime,
            _rate,
            ffCrowdsale.wallet(),
            token,
            _crowdsaleInfo,
            _round,
            ffCrowdsale.id(),
            friendsFingersRatePerMille,
            friendsFingersWallet
        );

        token.transferOwnership(address(newFriendsFingersCrowdsale));

        ffCrowdsale.setnextRoundId(crowdsaleCount);

        addCrowdsaleToList(address(newFriendsFingersCrowdsale));

        return newFriendsFingersCrowdsale;
    }

    function closeCrowdsale(address _ffCrowdsale) onlyOwnerOrCreator(_ffCrowdsale) public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.finalize();

        FriendsFingersToken token = ffCrowdsale.token();
        token.finishMinting();
        token.transferOwnership(crowdsaleCreators[_ffCrowdsale]);

        CrowdsaleClosed(ffCrowdsale);
    }

    function updateCrowdsaleInfo(address _ffCrowdsale, string _crowdsaleInfo) onlyOwnerOrCreator(_ffCrowdsale) public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.updateCrowdsaleInfo(_crowdsaleInfo);
    }

    // Only builder owner methods

    function changeEnabledAddressStatus(address _address, bool _status) onlyOwner public {
        require(_address != address(0));
        enabledAddresses[_address] = _status;
    }

    function setDefaultFriendsFingersRate(uint256 _newFriendsFingersRatePerMille) onlyOwner public {
        require(_newFriendsFingersRatePerMille >= 0);
        require(_newFriendsFingersRatePerMille < friendsFingersRatePerMille);
        friendsFingersRatePerMille = _newFriendsFingersRatePerMille;
    }

    function setMainWallet(address _newFriendsFingersWallet) onlyOwner public {
        require(_newFriendsFingersWallet != address(0));
        friendsFingersWallet = _newFriendsFingersWallet;
    }

    function setFriendsFingersRateForCrowdsale(address _ffCrowdsale, uint256 _newFriendsFingersRatePerMille) onlyOwner public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.setFriendsFingersRate(_newFriendsFingersRatePerMille);
    }

    function setFriendsFingersWalletForCrowdsale(address _ffCrowdsale, address _newFriendsFingersWallet) onlyOwner public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.setFriendsFingersWallet(_newFriendsFingersWallet);
    }

    // Emergency methods (only builder owner or enabled addresses)

    function pauseCrowdsale(address _ffCrowdsale) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.pause();
    }

    function unpauseCrowdsale(address _ffCrowdsale) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.unpause();
    }

    function blockCrowdsale(address _ffCrowdsale) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.blockCrowdsale();
    }

    function safeTokenWithdrawalFromCrowdsale(address _ffCrowdsale, address _tokenAddress, uint256 _tokens) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.transferAnyERC20Token(_tokenAddress, _tokens, friendsFingersWallet);
    }

    function safeWithdrawalFromCrowdsale(address _ffCrowdsale) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.safeWithdrawal();
    }

    function setExpiredAndWithdraw(address _ffCrowdsale) onlyOwnerOrEnabledAddress public {
        FriendsFingersCrowdsale ffCrowdsale = FriendsFingersCrowdsale(_ffCrowdsale);
        ffCrowdsale.setExpiredAndWithdraw();
    }

    // Internal methods

    function addCrowdsaleToList(address ffCrowdsale) internal {
        crowdsaleList[crowdsaleCount] = ffCrowdsale;
        crowdsaleCreators[ffCrowdsale] = msg.sender;

        CrowdsaleStarted(ffCrowdsale);
    }

}
pragma solidity ^0.4.17;

/// @title Phase One of SEC Coin Crowd Sale, 9% of total supply, 1 ETH = 7,000 SEC
/// Our homepage: http://sectech.me/
/// Sale is under the protect of contract.
/// @author Diana Kudrow

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable {
  address public owner;

  ///@dev The Ownable constructor sets the original `owner` of the contract to the senderaccount.
  function Ownable() {
    owner = msg.sender;
  }

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;

  /// @dev modifier to allow actions only when the contract IS paused
  modifier whenNotPaused() {
    require(!paused);_;
  }

  /// @dev modifier to allow actions only when the contract IS NOT paused
  modifier whenPaused {
    require(paused);_;
  }

  /// @dev called by the owner to pause, triggers stopped state
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /// @dev called by the owner to unpause, returns to normal state
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract BasicToken is ERC20Basic, Ownable {
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
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract BurnableToken is StandardToken, Pausable {

    event Burn(address indexed burner, uint256 value);

    function transfer(address _to, uint _value) whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Burns a specified amount of tokens from messager sender&#39;s account.
     * @param _value The amount of tokens to burn.
     */
    function burn(uint256 _value) whenNotPaused public {
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);  // reduce total supply after burn
        Burn(msg.sender, _value);
    }
}

contract SECToken is BurnableToken {

    string public constant symbol = "SEC";
    string public name = "Erised(SEC)";
    uint8 public constant decimals = 18;

    function SECToken() {
        uint256 _totalSupply = 567648000; // 3600sec * 24hr * 365day * 18year
        uint256 capacity = _totalSupply.mul(1 ether);
        totalSupply = balances[msg.sender] = capacity;
    }

    function setName(string name_) onlyOwner {
        name = name_;
    }

    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }

}

contract SecCrowdSale is Pausable{
    using SafeMath for uint;

    // Total Supply of CrowdSale first period
    uint public constant MAX_CAP = 51088320000000000000000000;  //51,088,320 SEC Coin, 9% of total supply
    // Minimum amount to invest
    uint public constant MIN_INVEST_ETHER = 0.1 ether;
    // Crowdsale period
    uint private constant CROWDSALE_PERIOD = 15 days;
    // Number of SECCoins per Ether
    uint public constant SEC_PER_ETHER = 7000000000000000000000; // 1ETH = 7,000 SEC Coin
    // SEC Token main contract address
    address public constant SEC_contract = 0x41ff967f9f8ec58abf88ca1caa623b3fd6277191;

    //SECCoin contract reference
    SECToken public SECCoin;
    // Number of Ether received
    uint public etherReceived;
    // Number of SECCoins sent to Ether contributors
    uint public SECCoinSold;
    // Crowdsale start time
    uint public startTime;
    // Crowdsale end time
    uint public endTime;
    // Is crowdsale still on going
    bool public crowdSaleClosed;

    modifier respectTimeFrame() {
        require((now >= startTime) || (now <= endTime ));_;
    }

    event LogReceivedETH(address addr, uint value);
    event LogCoinsEmited(address indexed from, uint amount);

    function CrowdSale() {
        SECCoin = SECToken(SEC_contract);
    }

    /// The fallback function corresponds to a donation in ETH
    function() whenNotPaused respectTimeFrame payable {
        BuyTokenSafe(msg.sender);
    }

    /*
     * To call to start the crowdsale
     */
    function start() onlyOwner external{
        require(startTime == 0); // Crowdsale was already started
        startTime = now ;
        endTime =  now + CROWDSALE_PERIOD;
    }

    /// Receives a donation in Etherose, send SEC token immediately
    function BuyTokenSafe(address beneficiary) internal {
        require(msg.value >= MIN_INVEST_ETHER); // Don&#39;t accept funding under a predefined threshold
        uint SecToSend = msg.value.mul(SEC_PER_ETHER).div(1 ether); // Compute the number of SECCoin to send
        require(SecToSend.add(SECCoinSold) <= MAX_CAP);
        SECCoin.transfer(beneficiary, SecToSend); // Transfer SEC Coins right now
        etherReceived = etherReceived.add(msg.value); // Update the total wei collected during the crowdfunding
        SECCoinSold = SECCoinSold.add(SecToSend);
        // Send events
        LogCoinsEmited(msg.sender ,SecToSend);
        LogReceivedETH(beneficiary, etherReceived);
    }

    /// Close the crowdsale, should be called after the refund period
    function finishSafe(address burner) onlyOwner external{
        require(burner!=address(0));
        require(now > endTime || SECCoinSold == MAX_CAP); // end time or sold out
        owner.send(this.balance); // Move the remaining Ether to contract founder address
        uint remains = SECCoin.balanceOf(this);
        if (remains > 0) { // Burn the rest of SECCoins
            SECCoin.transfer(burner, remains);
        }
        crowdSaleClosed = true;
    }
}
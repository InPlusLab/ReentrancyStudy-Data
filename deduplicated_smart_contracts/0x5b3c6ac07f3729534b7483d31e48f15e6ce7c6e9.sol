pragma solidity ^0.4.18;

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

contract ALT1Token is Ownable, ERC20Basic {
  using SafeMath for uint256;

  string public constant name     = "Altair VR presale token";
  string public constant symbol   = "ALT1";
  uint8  public constant decimals = 18;

  bool public mintingFinished = false;

  mapping(address => uint256) public balances;
  address[] public holders;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  /**
  * @dev Function to mint tokens
  * @param _to The address that will receive the minted tokens.
  * @param _amount The amount of tokens to mint.
  * @return A boolean that indicates if the operation was successful.
  */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    if (balances[_to] == 0) { 
      holders.push(_to);
    }
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

  /**
  * @dev Current token is not transferred.
  * After start official token sale ALT, you can exchange your ALT1 to ALT
  */
  function transfer(address, uint256) public returns (bool) {
    revert();
    return false;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}

/**
 * @title Crowdsale ALT1 presale token
 */

contract Crowdsale is Ownable {
  using SafeMath for uint256;

  uint256   public constant rate = 17000;                 // How many token units a buyer gets per wei
  uint256   public constant cap = 80000000 ether / rate;   // Maximum amount of funds

  bool      public isFinalized = false;
  uint256   public endTime = 1522540800;                  // End timestamps where investments are allowed
                                                          // Sunday, 01-Apr-18 00:00:00 UTC

  ALT1Token public token;                                 // ALT1 token itself
  address   public wallet;                                // Wallet of funds
  uint256   public weiRaised;                             // Amount of raised money in wei

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Finalized();

  function Crowdsale (ALT1Token _ALT1, address _wallet) public {
    assert(address(_ALT1) != address(0));
    assert(_wallet != address(0));
    assert(endTime > now);
    assert(rate > 0);
    assert(cap > 0);

    token = _ALT1;
    wallet = _wallet;
  }

  function () public payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(rate);

    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  /**
   * @dev Calls the contract&#39;s finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);

    finalization();
    Finalized();

    isFinalized = true;
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool tokenMintingFinished = token.mintingFinished();
    bool withinCap = weiRaised.add(msg.value) <= cap;
    bool withinPeriod = now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    bool moreThanMinimumPayment = msg.value >= 0.05 ether;

    return !tokenMintingFinished && withinCap && withinPeriod && nonZeroPurchase && moreThanMinimumPayment;
  }

  function finalization() internal {
    token.finishMinting();
    endTime = now;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }
}
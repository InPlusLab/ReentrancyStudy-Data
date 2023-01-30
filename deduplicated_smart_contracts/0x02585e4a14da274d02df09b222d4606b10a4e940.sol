pragma solidity ^0.4.16;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
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
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
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
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}


/**
 * Pausable token
 *
 * Simple ERC20 Token example, with pausable token creation
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    super.transferFrom(_from, _to, _value);
  }
}


/**
 * @title HeroOrigenToken
 * @dev Hero Origen Token contract
 */
contract HeroOrigenToken is PausableToken, MintableToken {
  using SafeMath for uint256;

  string public constant name = "Hero Origen Token";
  string public constant symbol = "HERO";
  uint8 public constant decimals = 18;
}


/**
 * @title MainSale
 * @dev The main HERO token sale contract
 *
 */
contract MainSale is Ownable {
  using SafeMath for uint256;
  event TokensPurchased(address indexed buyer, uint256 ether_amount);
  event MainSaleClosed();

  HeroOrigenToken public token = new HeroOrigenToken();

  address public multisigVault = 0x1706024467ef8C9C4648Da6FC35f2C995Ac79CF6;

  uint256 public totalReceived = 0;
  uint256 public hardcap = 250000 ether;
  uint256 public minimum = 10 ether;

  uint256 public altDeposits = 0;
  uint256 public start = 1511178900; //new Date("November 20, 2017 11:55:00").getTime() / 1000
  bool public saleOngoing = true;

  /**
   * @dev modifier to allow token creation only when the sale IS ON
   */
  modifier isSaleOn() {
    require(start <= now && saleOngoing);
    _;
  }

  /**
   * @dev modifier to prevent buying tokens below the minimum required
   */
  modifier isAtLeastMinimum() {
    require(msg.value >= minimum);
    _;
  }

  /**
   * @dev modifier to allow token creation only when the hardcap has not been reached
   */
  modifier isUnderHardcap() {
    require(totalReceived + altDeposits <= hardcap);
    _;
  }

  function MainSale() public {
    token.pause();
  }

  /*
   * @dev Receive eth from the sender
   * @param sender the sender to receive tokens.
   */
  function acceptPayment(address sender) public isAtLeastMinimum isUnderHardcap isSaleOn payable {
    totalReceived = totalReceived.add(msg.value);
    multisigVault.transfer(this.balance);
    TokensPurchased(sender, msg.value);
  }

  /**
   * @dev Allows the owner to set the starting time.
   * @param _start the new _start
   */
  function setStart(uint256 _start) external onlyOwner {
    start = _start;
  }

  /**
   * @dev Allows the owner to set the minimum purchase.
   * @param _minimum the new _minimum
   */
  function setMinimum(uint256 _minimum) external onlyOwner {
    minimum = _minimum;
  }

  /**
   * @dev Allows the owner to set the hardcap.
   * @param _hardcap the new hardcap
   */
  function setHardcap(uint256 _hardcap) external onlyOwner {
    hardcap = _hardcap;
  }

  /**
   * @dev Allows to set the toal alt deposit measured in ETH to make sure the hardcap includes other deposits
   * @param totalAltDeposits total amount ETH equivalent
   */
  function setAltDeposits(uint256 totalAltDeposits) external onlyOwner {
    altDeposits = totalAltDeposits;
  }

  /**
   * @dev Allows the owner to set the multisig contract.
   * @param _multisigVault the multisig contract address
   */
  function setMultisigVault(address _multisigVault) external onlyOwner {
    require(_multisigVault != address(0));
    multisigVault = _multisigVault;
  }

  /**
   * @dev Allows the owner to stop the sale
   * @param _saleOngoing whether the sale is ongoing or not
   */
  function setSaleOngoing(bool _saleOngoing) external onlyOwner {
    saleOngoing = _saleOngoing;
  }

  /**
   * @dev Allows the owner to close the sale and stop accepting ETH.
   * The ownership of the token contract is transfered to this owner.
   */
  function closeSale() external onlyOwner {
    token.transferOwnership(owner);
    MainSaleClosed();
  }

  /**
   * @dev Allows the owner to transfer ERC20 tokens to the multisig vault
   * @param _token the contract address of the ERC20 contract
   */
  function retrieveTokens(address _token) external onlyOwner {
    ERC20 foreignToken = ERC20(_token);
    foreignToken.transfer(multisigVault, foreignToken.balanceOf(this));
  }

  /**
   * @dev Fallback function which receives ether
   */
  function() external payable {
    acceptPayment(msg.sender);
  }
}
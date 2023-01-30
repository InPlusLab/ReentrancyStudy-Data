pragma solidity ^0.4.20;

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
    require(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
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
    owner = newOwner;
    OwnershipTransferred(owner, newOwner);
  }
}

contract CutdownTokenInterface {
	//ERC20
  	function balanceOf(address who) public view returns (uint256);
  	function transfer(address to, uint256 value) public returns (bool);

  	//ERC677
  	function tokenFallback(address from, uint256 amount, bytes data) public returns (bool);
}

/**
 * @title Eco Value Coin
 * @dev Burnable ERC20 + ERC677 token with initial transfers blocked
 */
contract EcoValueCoin is Ownable {
  using SafeMath for uint256;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
  event Burn(address indexed _burner, uint256 _value);
  event TransfersEnabled();
  event TransferRightGiven(address indexed _to);
  event TransferRightCancelled(address indexed _from);
  event WithdrawnERC20Tokens(address indexed _tokenContract, address indexed _owner, uint256 _balance);
  event WithdrawnEther(address indexed _owner, uint256 _balance);

  string public constant name = "Eco Value Coin";
  string public constant symbol = "EVC";
  uint256 public constant decimals = 18;
  uint256 public constant initialSupply = 3300000000 * (10 ** decimals);
  uint256 public totalSupply;

  mapping(address => uint256) public balances;
  mapping(address => mapping (address => uint256)) internal allowed;

  //This mapping is used for the token owner and crowdsale contract to 
  //transfer tokens before they are transferable
  mapping(address => bool) public transferGrants;
  //This flag controls the global token transfer
  bool public transferable;

  /**
   * @dev Modifier to check if tokens can be transfered.
   */
  modifier canTransfer() {
    require(transferable || transferGrants[msg.sender]);
    _;
  }

  /**
   * @dev The constructor sets the original `owner` of the contract 
   * to the sender account and assigns them all tokens.
   */
  function EcoValueCoin() public {
    owner = msg.sender;
    totalSupply = initialSupply;
    balances[owner] = totalSupply;
    transferGrants[owner] = true;
  }

  /**
   * @dev This contract does not accept any ether. 
   * Any forced ether can be withdrawn with `withdrawEther()` by the owner.
   */
  function () payable public {
    revert();
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
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
  function approve(address _spender, uint256 _value) canTransfer public returns (bool) {
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
  function allowance(address _owner, address _spender) canTransfer public view returns (uint256) {
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
  function increaseApproval(address _spender, uint _addedValue) canTransfer public returns (bool) {
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
  function decreaseApproval(address _spender, uint _subtractedValue) canTransfer public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }

  /**
   * @dev Enables the transfer of tokens for everyone
   */
  function enableTransfers() onlyOwner public {
    require(!transferable);
    transferable = true;
    TransfersEnabled();
  }

  /**
   * @dev Assigns the special transfer right, before transfers are enabled
   * @param _to The address receiving the transfer grant
   */
  function grantTransferRight(address _to) onlyOwner public {
    require(!transferable);
    require(!transferGrants[_to]);
    require(_to != address(0));
    transferGrants[_to] = true;
    TransferRightGiven(_to);
  }

  /**
   * @dev Removes the special transfer right, before transfers are enabled
   * @param _from The address that the transfer grant is removed from
   */
  function cancelTransferRight(address _from) onlyOwner public {
    require(!transferable);
    require(transferGrants[_from]);
    transferGrants[_from] = false;
    TransferRightCancelled(_from);
  }

  /**
   * @dev Allows to transfer out the balance of arbitrary ERC20 tokens from the contract.
   * @param _tokenContract The contract address of the ERC20 token.
   */
  function withdrawERC20Tokens(address _tokenContract) onlyOwner public {
    CutdownTokenInterface token = CutdownTokenInterface(_tokenContract);
    uint256 totalBalance = token.balanceOf(address(this));
    token.transfer(owner, totalBalance);
    WithdrawnERC20Tokens(_tokenContract, owner, totalBalance);
  }

  /**
   * @dev Allows to transfer out the ether balance that was forced into this contract, e.g with `selfdestruct`
   */
  function withdrawEther() public onlyOwner {
    uint256 totalBalance = this.balance;
    require(totalBalance > 0);
    owner.transfer(totalBalance);
    WithdrawnEther(owner, totalBalance);
  }
}
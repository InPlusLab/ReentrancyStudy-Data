/**

 *Submitted for verification at Etherscan.io on 2018-09-12

*/



pragma solidity ^0.4.24;



contract Ownable {

  address public owner;



  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

                             address indexed previousOwner,

                             address indexed newOwner

                             );





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

  function transferOwnership (address newOwner) public onlyOwner {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);  



    owner = newOwner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }

}



contract ERC20Token {

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



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

   * @dev Gets the balance of the specified address.

   * @param _owner The address to query the the balance of.

   * @return An uint256 representing the amount owned by the passed address.

   */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender,uint256 value);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract StandardToken is ERC20Token {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }



  mapping (address => mapping (address => uint256)) internal allowed;



  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value ) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

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

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance( address _owner,  address _spender) public view returns (uint256) {

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

  function increaseApproval( address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

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

  function decreaseApproval( address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**

     * @dev Burns a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(uint256 _value) public returns (bool) {

        require(_value > 0);

        require(_value <= balances[msg.sender]);

        // no need to require value <= totalSupply_, since that would imply the

        // sender's balance is greater than the totalSupply_, which *should* be an assertion failure

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply_ = totalSupply_.sub(_value);

        emit Burn(burner, _value);

        return true;

    }

}



contract FrozenableToken is BurnableToken, Ownable {

  mapping (address => bool) public frozenAccount;

  event FrozenFunds(address target, bool frozen);



  /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

  /// @param target Address to be frozen

  /// @param freeze either to freeze it or not

  function freezeAccount(address target, bool freeze) onlyOwner public {

      frozenAccount[target] = freeze;

      emit FrozenFunds(target, freeze);

  }



  function transfer( address _to, uint256 _value) public returns (bool) {

    require(!frozenAccount[msg.sender]);                     // Check if sender is frozen

    require(!frozenAccount[_to]);                       // Check if recipient is frozen



    return super.transfer(_to, _value);

    }



  function transferFrom( address _from, address _to, uint256 _value) public returns (bool) {

    require(!frozenAccount[_from]);                     // Check if sender is frozen

    require(!frozenAccount[_to]);                       // Check if recipient is frozen



    return super.transferFrom(_from, _to, _value);

  }



  function approve( address _spender, uint256 _value) public  returns (bool) {

    require(!frozenAccount[msg.sender]);                     // Check if sender is frozen

    require(!frozenAccount[_spender]);                       // Check if recipient is frozen



    return super.approve(_spender, _value);

  }



  function increaseApproval( address _spender, uint _addedValue) public  returns (bool success) {

    require(!frozenAccount[msg.sender]);                     // Check if sender is frozen

    require(!frozenAccount[_spender]);                       // Check if recipient is frozen



    return super.increaseApproval(_spender, _addedValue);

  }



  function decreaseApproval( address _spender, uint _subtractedValue) public  returns (bool success) {

    require(!frozenAccount[msg.sender]);                     // Check if sender is frozen

    require(!frozenAccount[_spender]);                       // Check if recipient is frozen



    return super.decreaseApproval(_spender, _subtractedValue);

  }

  



}



contract PausableToken is FrozenableToken {

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



  function transfer( address _to, uint256 _value) public whenNotPaused returns (bool) {

    return super.transfer(_to, _value);

  }



  function transferFrom( address _from, address _to, uint256 _value) public whenNotPaused returns (bool)

  {

    return super.transferFrom(_from, _to, _value);

  }



  function approve( address _spender, uint256 _value) public whenNotPaused returns (bool) {

    return super.approve(_spender, _value);

  }



  function increaseApproval( address _spender, uint _addedValue) public whenNotPaused returns (bool success) {

    return super.increaseApproval(_spender, _addedValue);

  }



  function decreaseApproval( address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {

    return super.decreaseApproval(_spender, _subtractedValue);

  }

}



contract CoinPoolCoin is PausableToken {



  using SafeMath for uint256;



  // One time switch to enable token transferability.

  bool public transferable = false;



  // Record  wallet to allow transfering.

  address public CPBWallet;



  // 2.1 billion tokens, 18 decimals.

  uint public constant INITIAL_SUPPLY = 2.1e27;



  modifier onlyWhenTransferEnabled() {

    if (!transferable) {

      require(msg.sender == owner || msg.sender == CPBWallet);

    }

    _;

  }



  modifier validDestination(address to) {

    require(to != address(this));

    _;

  }



  constructor(address _CPBWallet) public StandardToken("CoinPool Coin", "CPB", 18) {



    require(_CPBWallet != address(0));

    CPBWallet = _CPBWallet;

    totalSupply_ = INITIAL_SUPPLY;

    balances[_CPBWallet] = totalSupply_;

    emit Transfer(address(0), _CPBWallet, totalSupply_);

  }



  /// @dev Override to only allow tranfer.

  function transferFrom(address _from, address _to, uint256 _value) public validDestination(_to) onlyWhenTransferEnabled returns (bool) {

    return super.transferFrom(_from, _to, _value);

  }



  /// @dev Override to only allow tranfer after being switched on.

  function transfer(address _to, uint256 _value) public validDestination(_to) onlyWhenTransferEnabled returns (bool) {

    return super.transfer(_to, _value);

  }



  /**

   * @dev One-time switch to enable transfer.

   */

  function enableTransfer() external onlyOwner {

    transferable = true;

  }



}



library SafeMath {



  /**

   * @dev Multiplies two numbers, throws on overflow.

   */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

   * @dev Integer division of two numbers, truncating the quotient.

   */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

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

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}
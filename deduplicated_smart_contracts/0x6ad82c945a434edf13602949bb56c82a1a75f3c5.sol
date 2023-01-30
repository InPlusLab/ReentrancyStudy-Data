/**

 *Submitted for verification at Etherscan.io on 2019-01-23

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

  external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value)

  external returns (bool);



  function transferFrom(address from, address to, uint256 value)

  external returns (bool);





  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event TransferWithData(address indexed from, address indexed to, uint value, bytes data);



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}







/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20 {

  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param owner The address to query the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param owner address The address which owns the funds.

   * @param spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address owner,

    address spender

  )

  public

  view

  returns (uint256)

  {

    return _allowed[owner][spender];

  }





  /**

   * @dev Transfer the specified amount of tokens to the specified address.

   *      Invokes the `tokenFallback` function if the recipient is a contract.

   *      The token transfer fails if the recipient is a contract

   *      but does not implement the `tokenFallback` function

   *      or the fallback function to receive funds.

   *

   * @param _to    Receiver address.

   * @param _value Amount of tokens that will be transferred.

   * @param _data  Transaction metadata.

   */



  function transfer(address _to, uint _value, bytes _data) external returns (bool) {

    // Standard function transfer similar to ERC20 transfer with no _data .

    // Added due to backwards compatibility reasons .

    uint codeLength;



    require(_value / 1000000000000000000 >= 1);



    assembly {

    // Retrieve the size of the code on target address, this needs assembly .

      codeLength := extcodesize(_to)

    }



    _balances[msg.sender] = _balances[msg.sender].sub(_value);

    _balances[_to] = _balances[_to].add(_value);

    if (codeLength > 0) {

      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);



      receiver.tokenFallback(msg.sender, _value, _to);

    }

    emit TransferWithData(msg.sender, _to, _value, _data);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

   * @dev Transfer the specified amount of tokens to the specified address.

   *      This function works the same with the previous one

   *      but doesn't contain `_data` param.

   *      Added due to backwards compatibility reasons.

   *

   * @param _to    Receiver address.

   * @param _value Amount of tokens that will be transferred.

   */

  function transfer(address _to, uint _value) external returns (bool) {

    uint codeLength;

    bytes memory empty;



    require(_value / 1000000000000000000 >= 1);



    assembly {

    // Retrieve the size of the code on target address, this needs assembly .

      codeLength := extcodesize(_to)

    }



    _balances[msg.sender] = _balances[msg.sender].sub(_value);

    _balances[_to] = _balances[_to].add(_value);

    if (codeLength > 0) {

      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

      receiver.tokenFallback(msg.sender, _value, address(this));

    }



    emit Transfer(msg.sender, _to, _value);

    emit TransferWithData(msg.sender, _to, _value, empty);

    return true;

  }





  /**

   * @dev Transfer the specified amount of tokens to the specified address.

   *      This function works the same with the previous one

   *      but doesn't contain `_data` param.

   *      Added due to backwards compatibility reasons.

   *

   * @param _to    Receiver address.

   * @param _value Amount of tokens that will be transferred.

   */

  function transferByCrowdSale(address _to, uint _value) external returns (bool) {

    bytes memory empty;



    require(_value / 1000000000000000000 >= 1);



    _balances[msg.sender] = _balances[msg.sender].sub(_value);

    _balances[_to] = _balances[_to].add(_value);



    emit Transfer(msg.sender, _to, _value);

    emit TransferWithData(msg.sender, _to, _value, empty);

    return true;

  }



  function _transferGasByOwner(address _from, address _to, uint256 _value) internal {

    _balances[_from] = _balances[_from].sub(_value);

    _balances[_to] = _balances[_to].add(_value);

    emit Transfer(_from, _to, _value);

  }





  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender The address which will spend the funds.

   * @param value The amount of tokens to be spent.

   */

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }



  /**

   * @dev Transfer tokens from one address to another

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address from,

    address to,

    uint256 value

  )

  public

  returns (bool)

  {

    require(value <= _allowed[from][msg.sender]);



    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _transfer(from, to, value);

    return true;

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param addedValue The amount of tokens to increase the allowance by.

   */

  function increaseAllowance(

    address spender,

    uint256 addedValue

  )

  public

  returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

    _allowed[msg.sender][spender].add(addedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseAllowance(

    address spender,

    uint256 subtractedValue

  )

  public

  returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

    _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

  * @dev Transfer token for a specified addresses

  * @param from The address to transfer from.

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from]);

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    emit TransferWithData(from, to, value, '');

    emit Transfer(from, to, value);

  }



  /**

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param account The account that will receive the created tokens.

   * @param value The amount that will be created.

   */

  function _mint(address account, uint256 value) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(value);

    _balances[account] = _balances[account].add(value);

    emit TransferWithData(address(0), account, value, '');

    emit Transfer(address(0), account, value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burn(address account, uint256 value) internal {

    require(account != 0);

    require(value <= _balances[account]);



    _totalSupply = _totalSupply.sub(value);

    _balances[account] = _balances[account].sub(value);

    emit TransferWithData(account, address(0), value, '');

    emit Transfer(account, address(0), value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      value);

    _burn(account, value);

  }

}





/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an account access to this role

   */

  function add(Role storage role, address account) internal {

    require(account != address(0));

    role.bearer[account] = true;

  }



  /**

   * @dev remove an account's access to this role

   */

  function remove(Role storage role, address account) internal {

    require(account != address(0));

    role.bearer[account] = false;

  }



  /**

   * @dev check if an account has this role

   * @return bool

   */

  function has(Role storage role, address account)

  internal

  view

  returns (bool)

  {

    require(account != address(0));

    return role.bearer[account];

  }

}





contract MinterRole {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  constructor() public {

    _addMinter(msg.sender);

  }



  modifier onlyMinter() {

    require(isMinter(msg.sender));

    _;

  }



  function isMinter(address account) public view returns (bool) {

    return minters.has(account);

  }



  function addMinter(address account) public onlyMinter {

    _addMinter(account);

  }



  function renounceMinter() public {

    _removeMinter(msg.sender);

  }



  function _addMinter(address account) internal {

    minters.add(account);

    emit MinterAdded(account);

  }



  function _removeMinter(address account) internal {

    minters.remove(account);

    emit MinterRemoved(account);

  }

}





/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable is ERC20, MinterRole {

  /**

   * @dev Function to mint tokens

   * @param to The address that will receive the minted tokens.

   * @param value The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(

    address to,

    uint256 value

  )

  public

  onlyMinter

  returns (bool)

  {

    _mint(to, value);

    return true;

  }



  function transferGasByOwner(address _from, address _to, uint256 _value) public onlyMinter returns (bool) {

    super._transferGasByOwner(_from, _to, _value);

    return true;

  }

}





/**

 * @title SimpleToken

 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.

 * Note they can later distribute these tokens as they wish using `transfer` and other

 * `ERC20` functions.

 */

contract CryptoMusEstate is ERC20Mintable {



  string public constant name = "Mus#1";

  string public constant symbol = "MUS#1";

  uint8 public constant decimals = 18;



  uint256 public constant INITIAL_SUPPLY = 1000 * (10 ** uint256(decimals));



  /**

   * @dev Constructor that gives msg.sender all of existing tokens.

   */

  constructor() public {

    mint(msg.sender, INITIAL_SUPPLY);

  }



}





/**

 * @title SimpleToken

 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.

 * Note they can later distribute these tokens as they wish using `transfer` and other

 * `ERC20` functions.

 */

contract CryptoMusKRW is ERC20Mintable {



  string public constant name = "CryptoMus KRW Stable Token";

  string public constant symbol = "KRWMus";

  uint8 public constant decimals = 18;



  uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals));



  /**

   * @dev Constructor that gives msg.sender all of existing tokens.

   */

  constructor() public {

    mint(msg.sender, INITIAL_SUPPLY);

  }



}







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



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

    _owner = msg.sender;

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns (address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns (bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}



/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropriate to concatenate

 * behavior.

 */

contract ERC223ReceivingContract is Ownable {

  using SafeMath for uint256;



  // The token being sold

  CryptoMusEstate private _token;

  // The token being sold

  CryptoMusKRW private _krwToken;



  // Address where funds are collected

  address private _wallet;

  address private _krwTokenAddress;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 private _rate;



  // Amount of wei raised

  uint256 private _weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokensPurchased(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param rate Number of token units a buyer gets per wei

   * @dev The rate is the conversion between wei and the smallest and indivisible

   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token

   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.

   * @param token Address of the token being sold

   */

  constructor(uint256 rate, CryptoMusEstate token, CryptoMusKRW krwToken) public {

    require(rate > 0);



    require(token != address(0));



    _rate = rate;

    _wallet = msg.sender;

    _token = token;

    _krwToken = krwToken;

    _krwTokenAddress = krwToken;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------





  function tokenFallback(address _from, uint _value, address _to) public {



    if(_krwTokenAddress != _to) {

    } else {

      buyTokens(_from, _value);

    }

  }



  /**

   * @return the token being sold.

   */

  function token() public view returns (CryptoMusEstate) {

    return _token;

  }



  /**

   * @return the address where funds are collected.

   */

  function wallet() public view returns (address) {

    return _wallet;

  }



  /**

   * @return the number of token units a buyer gets per wei.

   */

  function rate() public view returns (uint256) {

    return _rate;

  }



  function setRate(uint256 setRate) public onlyOwner returns (uint256)

  {

    _rate = setRate;

    return _rate;

  }



  /**

   * @return the mount of wei raised.

   */

  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param beneficiary Address performing the token purchase

   */

  function buyTokens(address beneficiary, uint _value) public {



    uint256 weiAmount = _value;

    _preValidatePurchase(beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    _weiRaised = _weiRaised.add(weiAmount);



    _processPurchase(beneficiary, tokens);

    emit TokensPurchased(

      msg.sender,

      beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(beneficiary, weiAmount);



    _forwardFunds(_value);

    _postValidatePurchase(beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.

   * Example from CappedCrowdsale.sol's _preValidatePurchase method:

   *   super._preValidatePurchase(beneficiary, weiAmount);

   *   require(weiRaised().add(weiAmount) <= cap);

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

  internal

  {

    require(beneficiary != address(0));

    require(weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param beneficiary Address performing the token purchase

   * @param weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

  internal

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param beneficiary Address performing the token purchase

   * @param tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address beneficiary,

    uint256 tokenAmount

  )

  internal

  {

    _token.transferByCrowdSale(beneficiary, tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * @param beneficiary Address receiving the tokens

   * @param tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address beneficiary,

    uint256 tokenAmount

  )

  internal

  {

    _deliverTokens(beneficiary, tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param beneficiary Address receiving the tokens

   * @param weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address beneficiary,

    uint256 weiAmount

  )

  internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 weiAmount)

  internal view returns (uint256)

  {

    return weiAmount.mul(_rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds(uint _value) internal {



    _krwToken.transferByCrowdSale(_wallet, _value);

  }

}
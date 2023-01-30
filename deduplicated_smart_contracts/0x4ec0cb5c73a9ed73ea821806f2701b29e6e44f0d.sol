/**

 *Submitted for verification at Etherscan.io on 2019-03-05

*/



pragma solidity ^0.4.25;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



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



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



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

  * @dev Transfer token for a specified address

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);

    return true;

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



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {



  using SafeMath for uint256;



  function safeTransfer(

    IERC20 token,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    IERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    // safeApprove should only be called when setting an initial allowance, 

    // or when resetting it to zero. To increase and decrease it, use 

    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

    require((value == 0) || (token.allowance(address(this), spender) == 0));

    require(token.approve(spender, value));

  }



  function safeIncreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);

    require(token.approve(spender, newAllowance));

  }



  function safeDecreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);

    require(token.approve(spender, newAllowance));

  }

}



// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /// @dev counter to allow mutex lock with only one SSTORE operation

  uint256 private _guardCounter;



  constructor() internal {

    // The counter starts at one to prevent changing it from zero to a non-zero

    // value, which is a more expensive operation.

    _guardCounter = 1;

  }



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * Calling a `nonReentrant` function from another `nonReentrant`

   * function is not supported. It is possible to prevent this from happening

   * by making the `nonReentrant` function external, and make it call a

   * `private` function that does the actual work.

   */

  modifier nonReentrant() {

    _guardCounter += 1;

    uint256 localCounter = _guardCounter;

    _;

    require(localCounter == _guardCounter);

  }



}



// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol



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

contract Crowdsale is ReentrancyGuard {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  // The token being sold

  IERC20 private _token;



  // Address where funds are collected

  address private _wallet;



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

   * @param wallet Address where collected funds will be forwarded to

   * @param token Address of the token being sold

   */

  constructor(uint256 rate, address wallet, IERC20 token) internal {

    require(rate > 0);

    require(wallet != address(0));

    require(token != address(0));



    _rate = rate;

    _wallet = wallet;

    _token = token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   * Note that other contracts will transfer fund with a base gas stipend

   * of 2300, which is not enough to call buyTokens. Consider calling

   * buyTokens directly when purchasing tokens from a contract.

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @return the token being sold.

   */

  function token() public view returns(IERC20) {

    return _token;

  }



  /**

   * @return the address where funds are collected.

   */

  function wallet() public view returns(address) {

    return _wallet;

  }



  /**

   * @return the number of token units a buyer gets per wei.

   */

  function rate() public view returns(uint256) {

    return _rate;

  }



  /**

   * @return the amount of wei raised.

   */

  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * This function has a non-reentrancy guard, so it shouldn't be called by

   * another `nonReentrant` function.

   * @param beneficiary Recipient of the token purchase

   */

  function buyTokens(address beneficiary) public nonReentrant payable {



    uint256 weiAmount = msg.value;

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



    _forwardFunds();

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

    view

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

    view

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

    _token.safeTransfer(beneficiary, tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.

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

  function _forwardFunds() internal {

    _wallet.transfer(msg.value);

  }

}



// File: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol



/**

 * @title TimedCrowdsale

 * @dev Crowdsale accepting contributions only within a time frame.

 */

contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _openingTime;

  uint256 private _closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    require(isOpen());

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param openingTime Crowdsale opening time

   * @param closingTime Crowdsale closing time

   */

  constructor(uint256 openingTime, uint256 closingTime) internal {

    // solium-disable-next-line security/no-block-members

    require(openingTime >= block.timestamp);

    require(closingTime > openingTime);



    _openingTime = openingTime;

    _closingTime = closingTime;

  }



  /**

   * @return the crowdsale opening time.

   */

  function openingTime() public view returns(uint256) {

    return _openingTime;

  }



  /**

   * @return the crowdsale closing time.

   */

  function closingTime() public view returns(uint256) {

    return _closingTime;

  }



  /**

   * @return true if the crowdsale is open, false otherwise.

   */

  function isOpen() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > _closingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    onlyWhileOpen

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

  }



}



// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol



/**

 * @title CappedCrowdsale

 * @dev Crowdsale with a limit for total contributions.

 */

contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 private _cap;



  /**

   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

   * @param cap Max amount of wei to be contributed

   */

  constructor(uint256 cap) internal {

    require(cap > 0);

    _cap = cap;

  }



  /**

   * @return the cap of the crowdsale.

   */

  function cap() public view returns(uint256) {

    return _cap;

  }



  /**

   * @dev Checks whether the cap has been reached.

   * @return Whether the cap was reached

   */

  function capReached() public view returns (bool) {

    return weiRaised() >= _cap;

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the funding cap.

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

    require(weiRaised().add(weiAmount) <= _cap);

  }



}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

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

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

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



// File: eth-token-recover/contracts/TokenRecover.sol



/**

 * @title TokenRecover

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Allow to recover any ERC20 sent into the contract for error

 */

contract TokenRecover is Ownable {



  /**

   * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.

   * @param tokenAddress The token contract address

   * @param tokenAmount Number of tokens to be sent

   */

  function recoverERC20(

    address tokenAddress,

    uint256 tokenAmount

  )

    public

    onlyOwner

  {

    IERC20(tokenAddress).transfer(owner(), tokenAmount);

  }

}



// File: openzeppelin-solidity/contracts/access/Roles.sol



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

    require(!has(role, account));



    role.bearer[account] = true;

  }



  /**

   * @dev remove an account's access to this role

   */

  function remove(Role storage role, address account) internal {

    require(account != address(0));

    require(has(role, account));



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



// File: ico-maker/contracts/access/roles/OperatorRole.sol



contract OperatorRole {

  using Roles for Roles.Role;



  event OperatorAdded(address indexed account);

  event OperatorRemoved(address indexed account);



  Roles.Role private _operators;



  constructor() internal {

    _addOperator(msg.sender);

  }



  modifier onlyOperator() {

    require(isOperator(msg.sender));

    _;

  }



  function isOperator(address account) public view returns (bool) {

    return _operators.has(account);

  }



  function addOperator(address account) public onlyOperator {

    _addOperator(account);

  }



  function renounceOperator() public {

    _removeOperator(msg.sender);

  }



  function _addOperator(address account) internal {

    _operators.add(account);

    emit OperatorAdded(account);

  }



  function _removeOperator(address account) internal {

    _operators.remove(account);

    emit OperatorRemoved(account);

  }

}



// File: ico-maker/contracts/crowdsale/utils/Contributions.sol



/**

 * @title Contributions

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Utility contract where to save any information about Crowdsale contributions

 */

contract Contributions is OperatorRole, TokenRecover {



  using SafeMath for uint256;



  struct Contributor {

    uint256 weiAmount;

    uint256 tokenAmount;

    bool exists;

  }



  // the number of sold tokens

  uint256 private _totalSoldTokens;



  // the number of wei raised

  uint256 private _totalWeiRaised;



  // list of addresses who contributed in crowdsales

  address[] private _addresses;



  // map of contributors

  mapping(address => Contributor) private _contributors;



  constructor() public {}



  /**

   * @return the number of sold tokens

   */

  function totalSoldTokens() public view returns(uint256) {

    return _totalSoldTokens;

  }



  /**

   * @return the number of wei raised

   */

  function totalWeiRaised() public view returns(uint256) {

    return _totalWeiRaised;

  }



  /**

   * @return address of a contributor by list index

   */

  function getContributorAddress(uint256 index) public view returns(address) {

    return _addresses[index];

  }



  /**

   * @dev return the contributions length

   * @return uint

   */

  function getContributorsLength() public view returns (uint) {

    return _addresses.length;

  }



  /**

   * @dev get wei contribution for the given address

   * @param account Address has contributed

   * @return uint256

   */

  function weiContribution(address account) public view returns (uint256) {

    return _contributors[account].weiAmount;

  }



  /**

   * @dev get token balance for the given address

   * @param account Address has contributed

   * @return uint256

   */

  function tokenBalance(address account) public view returns (uint256) {

    return _contributors[account].tokenAmount;

  }



  /**

   * @dev check if a contributor exists

   * @param account The address to check

   * @return bool

   */

  function contributorExists(address account) public view returns (bool) {

    return _contributors[account].exists;

  }



  /**

   * @dev add contribution into the contributions array

   * @param account Address being contributing

   * @param weiAmount Amount of wei contributed

   * @param tokenAmount Amount of token received

   */

  function addBalance(

    address account,

    uint256 weiAmount,

    uint256 tokenAmount

  )

    public

    onlyOperator

  {

    if (!_contributors[account].exists) {

      _addresses.push(account);

      _contributors[account].exists = true;

    }



    _contributors[account].weiAmount = _contributors[account].weiAmount.add(weiAmount);

    _contributors[account].tokenAmount = _contributors[account].tokenAmount.add(tokenAmount);



    _totalWeiRaised = _totalWeiRaised.add(weiAmount);

    _totalSoldTokens = _totalSoldTokens.add(tokenAmount);

  }



  /**

   * @dev remove the `operator` role from address

   * @param account Address you want to remove role

   */

  function removeOperator(address account) public onlyOwner {

    _removeOperator(account);

  }

}



// File: ico-maker/contracts/crowdsale/BaseCrowdsale.sol



/**

 * @title BaseCrowdsale

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Extends from Crowdsale with more stuffs like TimedCrowdsale, CappedCrowdsale.

 *  Base for any other Crowdsale contract

 */

contract BaseCrowdsale is TimedCrowdsale, CappedCrowdsale, TokenRecover {



  // reference to Contributions contract

  Contributions private _contributions;



  // the minimum value of contribution in wei

  uint256 private _minimumContribution;



  /**

   * @dev Reverts if less than minimum contribution

   */

  modifier onlyGreaterThanMinimum(uint256 weiAmount) {

    require(weiAmount >= _minimumContribution);

    _;

  }



  /**

   * @param openingTime Crowdsale opening time

   * @param closingTime Crowdsale closing time

   * @param rate Number of token units a buyer gets per wei

   * @param wallet Address where collected funds will be forwarded to

   * @param cap Max amount of wei to be contributed

   * @param minimumContribution Min amount of wei to be contributed

   * @param token Address of the token being sold

   * @param contributions Address of the contributions contract

   */

  constructor(

    uint256 openingTime,

    uint256 closingTime,

    uint256 rate,

    address wallet,

    uint256 cap,

    uint256 minimumContribution,

    address token,

    address contributions

  )

    public

    Crowdsale(rate, wallet, ERC20(token))

    TimedCrowdsale(openingTime, closingTime)

    CappedCrowdsale(cap)

  {

    require(contributions != address(0));

    _contributions = Contributions(contributions);

    _minimumContribution = minimumContribution;

  }



  /**

   * @return the crowdsale contributions contract

   */

  function contributions() public view returns(Contributions) {

    return _contributions;

  }



  /**

   * @return the minimum value of contribution in wei

   */

  function minimumContribution() public view returns(uint256) {

    return _minimumContribution;

  }



  /**

   * @dev false if the ico is not started, true if the ico is started and running, true if the ico is completed

   * @return bool

   */

  function started() public view returns(bool) {

    return block.timestamp >= openingTime(); // solhint-disable-line not-rely-on-time

  }



  /**

   * @dev false if the ico is not started, false if the ico is started and running, true if the ico is completed

   * @return bool

   */

  function ended() public view returns(bool) {

    return hasClosed() || capReached();

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the minimumContribution.

   * @param beneficiary Token purchaser

   * @param weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address beneficiary,

    uint256 weiAmount

  )

    internal

    onlyGreaterThanMinimum(weiAmount)

    view

  {

    super._preValidatePurchase(beneficiary, weiAmount);

  }



  /**

   * @dev Update the contributions contract states

   * @param beneficiary Address receiving the tokens

   * @param weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address beneficiary,

    uint256 weiAmount

  )

    internal

  {

    super._updatePurchasingState(beneficiary, weiAmount);

    _contributions.addBalance(

      beneficiary,

      weiAmount,

      _getTokenAmount(weiAmount)

    );

  }

}



// File: contracts/crowdsale/ForkTokenSale.sol



/**

 * @title ForkTokenSale

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Extends from BaseCrowdsale with the ability to change rate

 */

contract ForkTokenSale is BaseCrowdsale {



  uint256 private _currentRate;



  uint256 private _soldTokens;



  constructor(

    uint256 openingTime,

    uint256 closingTime,

    uint256 rate,

    address wallet,

    uint256 cap,

    uint256 minimumContribution,

    address token,

    address contributions

  )

    public

    BaseCrowdsale(

      openingTime,

      closingTime,

      rate,

      wallet,

      cap,

      minimumContribution,

      token,

      contributions

    )

  {

    _currentRate = rate;

  }



  /**

   * @dev Function to update rate

   * @param newRate The rate is the conversion between wei and the smallest and indivisible token unit

   */

  function setRate(uint256 newRate) public onlyOwner {

    require(newRate > 0);

    _currentRate = newRate;

  }



  /**

   * @return the number of token units a buyer gets per wei.

   */

  function rate() public view returns(uint256) {

    return _currentRate;

  }



  /**

   * @return the number of sold tokens.

   */

  function soldTokens() public view returns(uint256) {

    return _soldTokens;

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

    return weiAmount.mul(rate());

  }



  /**

   * @dev Update the contributions contract states

   * @param beneficiary Address receiving the tokens

   * @param weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address beneficiary,

    uint256 weiAmount

  )

    internal

  {

    _soldTokens = _soldTokens.add(_getTokenAmount(weiAmount));

    super._updatePurchasingState(beneficiary, weiAmount);

  }

}
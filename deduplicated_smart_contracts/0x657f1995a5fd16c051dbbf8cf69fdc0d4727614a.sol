/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity 0.4.25;





/************************** TPL Drink Token - Devcon4 *************************

 * IMPORTANT: HAVING AN ATTRIBUTE ISSUED BY THIS TOKEN DOES NOT PRECLUDE YOU  *

 * FROM HAVING YOUR ID CHECKED AND VERIFIED THROUGH THE USUAL CHANNELS WHEN   *

 * BEING SERVED A DRINK. IT IS JUST AN ADDITIONAL PRECAUTION, MOSTLY THERE TO *

 * DEMONSTRATE HOW A SIMPLE VERSION OF TPL CAN BE USED. THE VALIDATORS MAKE   *

 * NO BINDING STATEMENTS VERIFYING YOUR AGE, AND SHALL BE HELD HARMLESS IF    *

 * THE VERIFICIATIONS PROVIDED THEREIN ARE INCORRECT. DRINK RESPONSIBLY!      *

 *                                                                            *

 * Use at your own risk, these contracts are experimental and lightly tested! *

 * Documentation & tests at https://github.com/TPL-protocol/tpl-contracts     *

 * Implements an Attribute Registry https://github.com/0age/AttributeRegistry *

 *                                                                            *

 * Source layout:                                    Line #                   *

 *  - library SafeMath                                 40                     *

 *  - interface IERC20                                104                     *

 *  - interface AttributeRegistryInterface            137                     *

 *  - interface TPLERC20RestrictedReceiverInterface   191                     *

 *  - contract ERC20                                  215                     *

 *    - is IERC20                                                             *

 *    - using SafeMath for uint256                                            *

 *  - contract TPLERC20RestrictedReceiver             419                     *

 *    - is ERC20                                                              *

 *    - is TPLERC20RestrictedReceiverInterface                                *

 *  - contract DrinkToken                             512                     *

 *    - is TPLERC20RestrictedReceiver                                         *

 *                                                                            *

 *  https://github.com/TPL-protocol/tpl-contracts/blob/master/LICENSE.md      *

 ******************************************************************************/









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



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * @title Attribute Registry interface. EIP-165 ID: 0x5f46473f

 */

interface AttributeRegistryInterface {

  /**

   * @notice Check if an attribute of the type with ID `attributeTypeID` has

   * been assigned to the account at `account` and is currently valid.

   * @param account address The account to check for a valid attribute.

   * @param attributeTypeID uint256 The ID of the attribute type to check for.

   * @return True if the attribute is assigned and valid, false otherwise.

   * @dev This function MUST return either true or false - i.e. calling this

   * function MUST NOT cause the caller to revert.

   */

  function hasAttribute(

    address account,

    uint256 attributeTypeID

  ) external view returns (bool);



  /**

   * @notice Retrieve the value of the attribute of the type with ID

   * `attributeTypeID` on the account at `account`, assuming it is valid.

   * @param account address The account to check for the given attribute value.

   * @param attributeTypeID uint256 The ID of the attribute type to check for.

   * @return The attribute value if the attribute is valid, reverts otherwise.

   * @dev This function MUST revert if a directly preceding or subsequent

   * function call to `hasAttribute` with identical `account` and

   * `attributeTypeID` parameters would return false.

   */

  function getAttributeValue(

    address account,

    uint256 attributeTypeID

  ) external view returns (uint256);



  /**

   * @notice Count the number of attribute types defined by the registry.

   * @return The number of available attribute types.

   * @dev This function MUST return a positive integer value  - i.e. calling

   * this function MUST NOT cause the caller to revert.

   */

  function countAttributeTypes() external view returns (uint256);



  /**

   * @notice Get the ID of the attribute type at index `index`.

   * @param index uint256 The index of the attribute type in question.

   * @return The ID of the attribute type.

   * @dev This function MUST revert if the provided `index` value falls outside

   * of the range of the value returned from a directly preceding or subsequent

   * function call to `countAttributeTypes`. It MUST NOT revert if the provided

   * `index` value falls inside said range.

   */

  function getAttributeTypeID(uint256 index) external view returns (uint256);

}





/**

 * @title TPL ERC20 Restricted Receiver interface. EIP-165 ID: 0xca62cde9

 */

interface TPLERC20RestrictedReceiverInterface {

  /**

   * @notice Check if an account is approved to receive token transfers at

   * account `receiver`.

   * @param receiver address The account of the recipient.

   * @return True if the receiver is valid, false otherwise.

   */

  function canReceive(address receiver) external view returns (bool);



  /**

   * @notice Get the account of the utilized attribute registry.

   * @return The account of the registry.

   */

  function getRegistry() external view returns (address);

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





/**

 * @title Permissioned ERC20 token: transfers are restricted to valid receivers.

 */

contract TPLERC20RestrictedReceiver is ERC20, TPLERC20RestrictedReceiverInterface {



  // declare registry interface, used to request attributes from a jurisdiction

  AttributeRegistryInterface internal _registry;



  // declare attribute ID required in order to receive transferred tokens

  uint256 internal _validAttributeTypeID;



  /**

  * @notice The constructor function, with an associated attribute registry at

  * `registry` and an assignable attribute type with ID `validAttributeTypeID`.

  * @param registry address The account of the associated attribute registry.  

  * @param validAttributeTypeID uint256 The ID of the required attribute type.

  * @dev Note that it may be appropriate to require that the referenced

  * attribute registry supports the correct interface via EIP-165.

  */

  constructor(

    AttributeRegistryInterface registry,

    uint256 validAttributeTypeID

  ) public {

    _registry = AttributeRegistryInterface(registry);

    _validAttributeTypeID = validAttributeTypeID;

  }



  /**

   * @notice Check if an account is approved to receive token transfers at

   * account `receiver`.

   * @param receiver address The account of the recipient.

   * @return True if the receiver is valid, false otherwise.

   */

  function canReceive(address receiver) external view returns (bool) {

    return _registry.hasAttribute(receiver, _validAttributeTypeID);

  }



  /**

   * @notice Get the account of the utilized attribute registry.

   * @return The account of the registry.

   */

  function getRegistry() external view returns (address) {

    return address(_registry);

  }



  /**

   * @notice Get the ID of the attribute type required to receive tokens.

   * @return The ID of the required attribute type.

   */

  function getValidAttributeID() external view returns (uint256) {

    return _validAttributeTypeID;

  }



  /**

   * @notice Transfer an amount of `value` to a receiver at account `to`.

   * @param to address The account of the receiver.

   * @param value uint256 the amount to be transferred.

   * @return True if the transfer was successful.

   */

  function transfer(address to, uint256 value) public returns (bool) {

    require(

      _registry.hasAttribute(to, _validAttributeTypeID),

      "Transfer failed - receiver is not approved."

    );

    return super.transfer(to, value);

  }



  /**

   * @notice Transfer an amount of `value` to a receiver at account `to` on

   * behalf of a sender at account `from`.

   * @param to address The account of the receiver.

   * @param from address The account of the sender.

   * @param value uint256 the amount to be transferred.

   * @return True if the transfer was successful.

   */

  function transferFrom(

    address from,

    address to,

    uint256 value

  ) public returns (bool) {

    require(

      _registry.hasAttribute(to, _validAttributeTypeID),

      "Transfer failed - receiver is not approved."

    );

    return super.transferFrom(from, to, value);

  }

}





/**

 * @title An instance of TPLRestrictedReceiverToken that can be (fer)minted and

 * burned (or liquidated). Once you demonstrate that you are over 21 to a

 * validator, you can claim a token. Then, when you'd like to redeem the token,

 * call liquidate and have the drink token sponsor check for the event with your

 * address.

 */

contract DrinkToken is TPLERC20RestrictedReceiver {



  string public name = "Drink Token";



  event PourDrink(address drinker);



  /**

  * @notice The constructor function, with an associated attribute registry at

  * `registry`, an assignable attribute type with ID `validAttributeTypeID`, and

  * an initial balance of `initialBalance`.

  * @param registry address The account of the associated attribute registry.  

  * @param validAttributeTypeID uint256 The ID of the required attribute type.

  * @dev Note that it may be appropriate to require that the referenced

  * attribute registry supports the correct interface via EIP-165.

  */

  constructor(

    AttributeRegistryInterface registry,

    uint256 validAttributeTypeID

  ) public TPLERC20RestrictedReceiver(registry, validAttributeTypeID) {

    registry;

  }



  modifier over21() {

    require(

      _registry.hasAttribute(msg.sender, _validAttributeTypeID),

      "You must be over 21 to use Drink Token."

    );

    _;

  }



  function fermint() external over21 {

    _mint(msg.sender, 1);

  }



  function liquidate() external over21 {

    _burn(msg.sender, 1);

    emit PourDrink(msg.sender);

  }

}
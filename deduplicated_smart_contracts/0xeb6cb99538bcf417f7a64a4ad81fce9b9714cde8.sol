/**

 *Submitted for verification at Etherscan.io on 2018-10-22

*/



pragma solidity ^0.4.24;



// File: openzeppelin-eth/contracts/token/ERC20/IERC20.sol



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



// File: zos-lib/contracts/Initializable.sol



/**

 * @title Initializable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Initializable {



  /**

   * @dev Indicates that the contract has been initialized.

   */

  bool private initialized;



  /**

   * @dev Indicates that the contract is in the process of being initialized.

   */

  bool private initializing;



  /**

   * @dev Modifier to use in the initializer function of a contract.

   */

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is Initializable, IERC20 {

  string private _name;

  string private _symbol;

  uint8 private _decimals;



  function initialize(string name, string symbol, uint8 decimals) public initializer {

    _name = name;

    _symbol = symbol;

    _decimals = decimals;

  }



  /**

   * @return the name of the token.

   */

  function name() public view returns(string) {

    return _name;

  }



  /**

   * @return the symbol of the token.

   */

  function symbol() public view returns(string) {

    return _symbol;

  }



  /**

   * @return the number of decimals of the token.

   */

  function decimals() public view returns(uint8) {

    return _decimals;

  }



  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/access/Roles.sol



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



// File: openzeppelin-eth/contracts/access/roles/PauserRole.sol



contract PauserRole is Initializable {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  function initialize(address sender) public initializer {

    if (!isPauser(sender)) {

      _addPauser(sender);

    }

  }



  modifier onlyPauser() {

    require(isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    _addPauser(account);

  }



  function renouncePauser() public {

    _removePauser(msg.sender);

  }



  function _addPauser(address account) internal {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }



  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Initializable, PauserRole {

  event Paused();

  event Unpaused();



  bool private _paused = false;



  function initialize(address sender) public initializer {

    PauserRole.initialize(sender);

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyPauser whenNotPaused {

    _paused = true;

    emit Paused();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused();

  }



  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/math/SafeMath.sol



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



// File: openzeppelin-eth/contracts/token/ERC20/ERC20.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is Initializable, IERC20 {

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

  * @param owner The address to query the the balance of.

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

   * @param amount The amount that will be created.

   */

  function _mint(address account, uint256 amount) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(amount);

    _balances[account] = _balances[account].add(amount);

    emit Transfer(address(0), account, amount);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param amount The amount that will be burnt.

   */

  function _burn(address account, uint256 amount) internal {

    require(account != 0);

    require(amount <= _balances[account]);



    _totalSupply = _totalSupply.sub(amount);

    _balances[account] = _balances[account].sub(amount);

    emit Transfer(account, address(0), amount);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param amount The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 amount) internal {

    require(amount <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      amount);

    _burn(account, amount);

  }



  uint256[50] private ______gap;

}



// File: openzeppelin-eth/contracts/token/ERC20/ERC20Pausable.sol



/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 **/

contract ERC20Pausable is Initializable, ERC20, Pausable {



  function initialize(address sender) public initializer {

    Pausable.initialize(sender);

  }



  function transfer(

    address to,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transfer(to, value);

  }



  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transferFrom(from, to, value);

  }



  function approve(

    address spender,

    uint256 value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.approve(spender, value);

  }



  function increaseAllowance(

    address spender,

    uint addedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.increaseAllowance(spender, addedValue);

  }



  function decreaseAllowance(

    address spender,

    uint subtractedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.decreaseAllowance(spender, subtractedValue);

  }



  uint256[50] private ______gap;

}



// File: tpl-contracts-eth/contracts/AttributeRegistryInterface.sol



/**

 * @title Attribute Registry interface. EIP-165 ID: 0x5f46473f

 */

interface AttributeRegistryInterface {

  /**

   * @notice Check if an attribute of the type with ID `attributeTypeID` has

   * been assigned to the account at `account` and is still valid.

   * @param account address The account to check for a valid attribute.

   * @param attributeTypeID uint256 The ID of the attribute type to check for.

   * @return True if the attribute is assigned and valid, false otherwise.

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

   */

  function getAttributeValue(

    address account,

    uint256 attributeTypeID

  ) external view returns (uint256);



  /**

   * @notice Count the number of attribute types defined by the registry.

   * @return The number of available attribute types.

   */

  function countAttributeTypes() external view returns (uint256);



  /**

   * @notice Get the ID of the attribute type at index `index`.

   * @param index uint256 The index of the attribute type in question.

   * @return The ID of the attribute type.

   */

  function getAttributeTypeID(uint256 index) external view returns (uint256);

}



// File: tpl-contracts-eth/contracts/token/TPLRestrictedReceiverTokenInterface.sol



/**

 * @title TPL Restricted Receiver Token interface. EIP-165 ID: 0xca62cde9

 */

interface TPLRestrictedReceiverTokenInterface {

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



// File: tpl-contracts-eth/contracts/token/TPLRestrictedReceiverToken.sol



/**

 * @title Permissioned ERC20 token: transfers are restricted to valid receivers.

 */

contract TPLRestrictedReceiverToken is Initializable, ERC20, TPLRestrictedReceiverTokenInterface {



  // declare registry interface, used to request attributes from a jurisdiction

  AttributeRegistryInterface private _registry;



  // declare attribute ID required in order to receive transferred tokens

  uint256 private _validAttributeTypeID;



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

  * @notice The initializer function, with an associated attribute registry at

  * `registry` and an assignable attribute type with ID `validAttributeTypeID`.

  * @param registry address The account of the associated attribute registry.  

  * @param validAttributeTypeID uint256 The ID of the required attribute type.

  * @dev Note that it may be appropriate to require that the referenced

  * attribute registry supports the correct interface via EIP-165.

  */

  function initialize(

    AttributeRegistryInterface registry,

    uint256 validAttributeTypeID

  )

    public

    initializer

  {

    _registry = AttributeRegistryInterface(registry);

    _validAttributeTypeID = validAttributeTypeID;

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



// File: contracts/ZEPToken.sol



/**

 * @title ZEPToken

 * @dev ZEP token contract, a detailed ERC20 including pausable functionality.

 * The TPLToken integration causes tokens to only be transferrable to addresses

 * which have the validRecipient attribute in the jurisdiction.

 */

contract ZEPToken is Initializable, TPLRestrictedReceiverToken, ERC20Detailed, ERC20Pausable {



  function initialize(

    address _sender,

    AttributeRegistryInterface _jurisdictionAddress,

    uint256 _validRecipientAttributeId

  )

    initializer

    public

  {

    uint8 decimals = 18;

    uint256 totalSupply = 1e8 * (10 ** uint256(decimals));



    ERC20Pausable.initialize(_sender);

    ERC20Detailed.initialize("ZEP Token", "ZEP", decimals);

    TPLRestrictedReceiverToken.initialize(_jurisdictionAddress, _validRecipientAttributeId);

    _mint(_sender, totalSupply);

  }



}
/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



/* file: ./node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol */

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



/* eof (./node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol */

pragma solidity ^0.4.24;



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



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol */

pragma solidity ^0.4.24;





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

    require((value == 0) || (token.allowance(msg.sender, spender) == 0));

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



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol */

pragma solidity ^0.4.24;



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



/* eof (./node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol */

pragma solidity ^0.4.24;





/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

  string private _name;

  string private _symbol;

  uint8 private _decimals;



  constructor(string name, string symbol, uint8 decimals) public {

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

}



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol */

pragma solidity ^0.4.24;





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



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/access/Roles.sol */

pragma solidity ^0.4.24;



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



/* eof (./node_modules/openzeppelin-solidity/contracts/access/Roles.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol */

pragma solidity ^0.4.24;





contract PauserRole {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() internal {

    _addPauser(msg.sender);

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

}



/* eof (./node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol */

pragma solidity ^0.4.24;





/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

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

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

}



/* eof (./node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol */

pragma solidity ^0.4.24;





/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 **/

contract ERC20Pausable is ERC20, Pausable {



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

}



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol */

pragma solidity ^0.4.24;





/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {



  /**

   * @dev Burns a specific amount of tokens.

   * @param value The amount of token to be burned.

   */

  function burn(uint256 value) public {

    _burn(msg.sender, value);

  }



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param from address The address which you want to send tokens from

   * @param value uint256 The amount of token to be burned

   */

  function burnFrom(address from, uint256 value) public {

    _burnFrom(from, value);

  }

}



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/access/roles/MinterRole.sol */

pragma solidity ^0.4.24;





contract MinterRole {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  constructor() internal {

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



/* eof (./node_modules/openzeppelin-solidity/contracts/access/roles/MinterRole.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol */

pragma solidity ^0.4.24;





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

}



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol) */

/* file: ./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol */

pragma solidity ^0.4.24;





/**

 * @title Capped token

 * @dev Mintable token with a token cap.

 */

contract ERC20Capped is ERC20Mintable {



  uint256 private _cap;



  constructor(uint256 cap)

    public

  {

    require(cap > 0);

    _cap = cap;

  }



  /**

   * @return the cap for the token minting.

   */

  function cap() public view returns(uint256) {

    return _cap;

  }



  function _mint(address account, uint256 value) internal {

    require(totalSupply().add(value) <= _cap);

    super._mint(account, value);

  }

}



/* eof (./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol) */

/* file: ./contracts/token/SgmToken.sol */

pragma solidity 0.4.24;





/**

 * @title Sgame token

 * @author Validity Labs AG <[email protected]>

 */



contract SgmToken is Ownable, ERC20Detailed, ERC20Pausable, ERC20Burnable, ERC20Mintable, ERC20Capped {

    using SafeERC20 for ERC20;



    /**

     * @dev Constructor

     * @param name Name of the token to be created

     * @param symbol Symbol of the token to be created

     * @param decimals Decimals of the token to be created

     * @param newOwner Address which will have privileges to pause/unpause and mint the token

     */

    constructor(string name, string symbol, uint8 decimals, uint256 cap, address newOwner)

        public

        ERC20Detailed(name, symbol, decimals)

        ERC20Capped(cap) {

            roleSetup(newOwner);



        }



    /**

     * @dev Reclaim all ERC20 compatible tokens accidentally sent to the SGM token contract

     * @param recoveredToken ERC20 The address of the token contract

     */

    function reclaimToken(ERC20 recoveredToken) public onlyOwner {

        uint256 balance = recoveredToken.balanceOf(address(this));

        recoveredToken.safeTransfer(owner(), balance);

    }



    /**

     * @dev setup roles for new Sgame token

     * @param newOwner address of the client owner

     */

    function roleSetup(address newOwner) internal {

        addPauser(newOwner);

        _removePauser(msg.sender);



        addMinter(newOwner);

        _removeMinter(msg.sender);

    }

}

/* eof (./contracts/token/SgmToken.sol) */

/* file: ./contracts/vesting/TokenVesting.sol */

pragma solidity 0.4.24;







/**

 * @title TokenVesting

 * @dev Contract to hold tokens which will be realeased once they have vested

 * 30% of total balance will be realeased after the start of the vesting period

 * 70% of total balance will vest continuously until start + duration. By then all

 * of the balance will have vested

 * @author Validity Labs AG <[email protected]>

 */

contract TokenVesting is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;



    uint256 private constant DECIMAL_FACTOR = 10**uint256(18);

    uint256 private constant CLIFF_DURATION = 30 days;  // period after which the tokens will start to vest

    uint256 private constant DURATION = 420 days;  // vesting period

    uint256 private constant FIRST_RELEASE_PERCENTAGE = 30;  // 30% of tokens to be released after _start

    uint256 private constant VESTING_PERCENTAGE = 70;  // 70% of tokens will vest

    uint256 private constant D_RELEASE = 100;  // denominator to calculate the release percentage

    uint256 private constant ALLOCATION = 160500000 * DECIMAL_FACTOR;  // SGM tokens allocated to this contract



    uint256 private _released;  // records the total of SGM tokens released

    uint256 private _start;

    uint256 private _cliff;

    ERC20 private _token;



    struct Beneficiary {

        uint256 totalBalance;  // number of tokens to vest

        uint256 released;  // records the SGM tokens released per beneficiary

    }



    mapping(address => Beneficiary) private beneficiaries;



    /**

     * @dev Sets the state of the contract

     * @param accounts Array of beneficiaries that will receive the vested tokens

     * @param balances Array of total amount of tokens per beneficiary.

     * @param token Address of the SGM token which will vest

     * @param start Start time of the vesting period

     */

    function setState (address[] accounts, uint256[] balances, address token, uint256 start) public onlyOwner {

        // Checks to ensure this function is called only once

        require(_token == address(0));

        require(accounts.length == balances.length);



        _start = start;

        _cliff = start.add(CLIFF_DURATION);

        _token = ERC20(token);



        uint256 totalBalance = 0;

        uint256 length = accounts.length;

        for (uint256 i = 0; i < length; i = i.add(1)) {

            beneficiaries[accounts[i]] = Beneficiary(balances[i], 0);

            totalBalance = totalBalance.add(balances[i]);

        }

        require(ALLOCATION == totalBalance);

    }



    /**

     * @return the duration of the token vesting

     */

    function duration() public view returns (uint256) {

        return DURATION;

    }



    /**

     * @return the start time of the token vesting

     */

    function start() public view returns (uint256) {

        return _start;

    }



    /**

     * @return the cliff time of the token vesting

     */

    function cliff() public view returns (uint256) {

        return _cliff;

    }



    /**

     * @return the token address of the token vesting.

     */

    function token() public view returns (ERC20) {

        return _token;

    }



    /**

     * @dev Allows the caller to transfer vested tokens to his/her account

     */

    function release() public {

        releaseFor(msg.sender);

    }



    /**

     * @dev Allows the caller to transfer vested tokens to a beneficiary's address

     * @param beneficiary The address that will receive the vested unreleased tokens

     */

    function releaseFor(address beneficiary) public {

        uint256 unreleased = releasableAmount(beneficiary);

        require(unreleased > 0);



        _released = _released.add(unreleased);

        beneficiaries[beneficiary].released = beneficiaries[beneficiary].released.add(unreleased);

        _token.safeTransfer(beneficiary, unreleased);

    }



    /**

     * @dev Allows the caller to check the balance that has not been released of the input address

     * @param beneficiary The address whose locked balance is checked

     */

    function getBalanceFor(address beneficiary) public view returns (uint256) {

        return beneficiaries[beneficiary].totalBalance.sub(beneficiaries[beneficiary].released);

    }



    /**

     * @dev Reclaim all ERC20 compatible tokens accidentally sent to the vesting contract

     * @param recoveredToken ERC20 The address of the token contract

     */

    function reclaimToken(ERC20 recoveredToken) public onlyOwner {

        uint256 balance = recoveredToken.balanceOf(address(this));

        uint256 lockedBalance;

        uint256 recoveredBalance;

        // if SGM tokens are sent by mistake to this contract

        if (recoveredToken == _token) {

            lockedBalance = ALLOCATION.sub(_released);

        }

        recoveredBalance = balance.sub(lockedBalance);

        recoveredToken.safeTransfer(owner(), recoveredBalance);

    }



    /**

     * @dev Calculates the amount that has already vested but hasn't been released yet

     * @param beneficiary The address that will receive the unreleased tokens

     */

    function releasableAmount(address beneficiary) private view returns (uint256) {

        return vestedAmount(beneficiary).sub(beneficiaries[beneficiary].released);

    }



    /**

     * @dev Calculates the amount that has already vested.

     * @param beneficiary The address that will receive the vested tokens.

     */

    function vestedAmount(address beneficiary) private view returns (uint256) {

        uint256 vested = 0;



        if (block.timestamp >= _start) {

            // after start, release 30% of the beneficiary's totalBalance

            vested = beneficiaries[beneficiary].totalBalance.mul(FIRST_RELEASE_PERCENTAGE).div(D_RELEASE);

        }

        if (block.timestamp >= _cliff && block.timestamp < _start.add(DURATION)) {

            // after cliff, continuous vesting of the 70% leftover

            uint256 amountToVest = beneficiaries[beneficiary].totalBalance.mul(VESTING_PERCENTAGE).div(D_RELEASE);

            vested = vested.add(amountToVest.mul(block.timestamp.sub(_start)).div(DURATION));

        }

        if (block.timestamp >= _start.add(DURATION)) {

            vested = beneficiaries[beneficiary].totalBalance;

        }

        return vested;

    }

}

/* eof (./contracts/vesting/TokenVesting.sol) */
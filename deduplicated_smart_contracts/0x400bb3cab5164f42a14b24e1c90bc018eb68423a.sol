/**

 *Submitted for verification at Etherscan.io on 2019-05-30

*/



/**

 * Source Code first verified at https://etherscan.io on Sunday, May 26, 2019

 (UTC) */

 

/**Spochain*/



pragma solidity ^0.4.24;



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



    function burn(uint256 value) external;



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



library SafeMath {



  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0);

    uint256 c = a / b;



    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

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





contract SPOCHAIN is IERC20, ERC20Pausable{

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    string public name;

    uint8 public decimals;

    string public symbol;



    constructor() public {

        decimals = 18;

        _totalSupply = 5000000000 * 10 ** uint(decimals);

        _balances[msg.sender] = _totalSupply;

        name = "SPOCHAIN";

        symbol = "SPO";

    }



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



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



    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



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



    function _transfer(address from, address to, uint256 value) internal {

        require(value <= _balances[from]);

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    function burn(uint256 value) public {

        require(value <= _balances[msg.sender]);



        _totalSupply = _totalSupply.sub(value);

        _balances[msg.sender] = _balances[msg.sender].sub(value);

        emit Transfer(msg.sender, address(0), value);

    }



}
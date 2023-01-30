/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity ^0.4.24;



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev Transfer token for a specified address

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



}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

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

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint256 _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint256 _subtractedValue

  )

    public

    returns (bool)

  {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }



  modifier hasMintPermission() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(

    address _to,

    uint256 _amount

  )

    hasMintPermission

    canMint

    public

    returns (bool)

  {

    totalSupply_ = totalSupply_.add(_amount);

    balances[_to] = balances[_to].add(_amount);

    emit Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }



  /**

   * @dev Function to stop minting new tokens.

   * @return True if the operation was successful.

   */

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }

}



contract Pausable is Ownable {

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

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}



contract PausableToken is StandardToken, Pausable {



  function transfer(

    address _to,

    uint256 _value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transfer(_to, _value);

  }



  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transferFrom(_from, _to, _value);

  }



  function approve(

    address _spender,

    uint256 _value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.approve(_spender, _value);

  }



  function increaseApproval(

    address _spender,

    uint _addedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.increaseApproval(_spender, _addedValue);

  }



  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    whenNotPaused

    returns (bool success)

  {

    return super.decreaseApproval(_spender, _subtractedValue);

  }

}



contract Controller is MintableToken, PausableToken {

    address public thisAddr; // matches delegation slot in proxy

    uint256 public cap;      // the max cap of this token



    string public constant name = "Invest4Impact"; // solium-disable-line uppercase

    string public constant symbol = "I4I"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase



    constructor() public {}



    /**

    * @dev Function to initialize storage, only callable from proxy.

    * @param _controller The address where code is loaded from through delegatecall

    * @param _cap The cap that should be set for the token

    */

    function initialize(address _controller, uint256 _cap) public onlyOwner {

        require(cap == 0, "Cap is already set");

        require(_cap > 0, "Trying to set an invalid cap");

        require(thisAddr == _controller, "Not calling from proxy");

        cap = _cap;

        totalSupply_ = 0;

    }



    /**

    * @dev Function to mint tokens

    * @param _to The address that will receive the minted tokens.

    * @param _amount The amount of tokens to mint.

    * @return A boolean that indicates if the operation was successful.

    */

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {

        require(cap > 0, "Cap not set, not initialized");

        require(totalSupply_.add(_amount) <= cap, "Trying to mint over the cap");

        return super.mint(_to, _amount);

    }

}





library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an address access to this role

   */

  function add(Role storage role, address addr)

    internal

  {

    role.bearer[addr] = true;

  }



  /**

   * @dev remove an address' access to this role

   */

  function remove(Role storage role, address addr)

    internal

  {

    role.bearer[addr] = false;

  }



  /**

   * @dev check if an address has this role

   * // reverts

   */

  function check(Role storage role, address addr)

    view

    internal

  {

    require(has(role, addr));

  }



  /**

   * @dev check if an address has this role

   * @return bool

   */

  function has(Role storage role, address addr)

    view

    internal

    returns (bool)

  {

    return role.bearer[addr];

  }

}



contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address indexed operator, string role);

  event RoleRemoved(address indexed operator, string role);



  /**

   * @dev reverts if addr does not have role

   * @param _operator address

   * @param _role the name of the role

   * // reverts

   */

  function checkRole(address _operator, string _role)

    view

    public

  {

    roles[_role].check(_operator);

  }



  /**

   * @dev determine if addr has role

   * @param _operator address

   * @param _role the name of the role

   * @return bool

   */

  function hasRole(address _operator, string _role)

    view

    public

    returns (bool)

  {

    return roles[_role].has(_operator);

  }



  /**

   * @dev add a role to an address

   * @param _operator address

   * @param _role the name of the role

   */

  function addRole(address _operator, string _role)

    internal

  {

    roles[_role].add(_operator);

    emit RoleAdded(_operator, _role);

  }



  /**

   * @dev remove a role from an address

   * @param _operator address

   * @param _role the name of the role

   */

  function removeRole(address _operator, string _role)

    internal

  {

    roles[_role].remove(_operator);

    emit RoleRemoved(_operator, _role);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param _role the name of the role

   * // reverts

   */

  modifier onlyRole(string _role)

  {

    checkRole(msg.sender, _role);

    _;

  }



  /**

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param _roles the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] _roles) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < _roles.length; i++) {

  //         if (hasRole(msg.sender, _roles[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}



contract NAdmin is RBAC{

    string constant ADMIN_ROLE = "admin";



    constructor() public {}



    modifier onlyAdmins() {

        require(isAdmin(msg.sender), "Admin rights required.");

        _;

    }



    /**

     * @dev Allows admins to add people to the admin list.

     * @param _toAdd The address to be added to admin list.

     */

    function addToAdmins(address _toAdd) public {

        require(!isAdmin(_toAdd), "Address is admin already");

        addRole(_toAdd,ADMIN_ROLE);

    }



    function addListToAdmins(address[] _toAdd) public {

        for(uint256 i = 0; i<_toAdd.length; i++){

            addToAdmins(_toAdd[i]);

        }

    }



    function removeFromAdmins(address _toRemove) public {

        require(isAdmin(_toRemove), "Address is not admin already");

        removeRole(_toRemove,ADMIN_ROLE);

    }



    function removeListFromAdmins(address[] _toRemove) public {

        for(uint256 i = 0; i<_toRemove.length; i++){

            removeFromAdmins(_toRemove[i]);

        }

    }



    function isAdmin(address _address) public view returns(bool) {

        return hasRole(_address,ADMIN_ROLE);

    }

}



contract Whitelisted is RBAC {

    string constant WLST_ROLE = "whitelist";

    bool public whitelistUnlocked;



    constructor() public {}



    modifier onlyWhitelisted() {

        require(whitelistUnlocked || isWhitelisted(msg.sender), "Whitelist rights required.");

        _;

    }



    function setWhitelistUnlock(bool _newStatus) public {

        require(whitelistUnlocked!=_newStatus, "You are trying to set current status again");

        whitelistUnlocked = _newStatus;

    }



    /**

     * @dev Allows admins to add people to the whitelist.

     * @param _toAdd The address to be added to whitelist.

     */

    function addToWhitelist(address _toAdd) public {

        require(!isWhitelisted(_toAdd), "Address is whitelisted already");

        addRole(_toAdd,WLST_ROLE);

    }



    function addListToWhitelist(address[] _toAdd) public {

        for(uint256 i = 0; i<_toAdd.length; i++){

            addToWhitelist(_toAdd[i]);

        }

    }



    function removeFromWhitelist(address _toRemove) public {

        require(isWhitelisted(_toRemove), "Address is not whitelisted already");

        removeRole(_toRemove,WLST_ROLE);

    }



    function removeListFromWhitelist(address[] _toRemove) public {

        for(uint256 i = 0; i<_toRemove.length; i++){

            removeFromWhitelist(_toRemove[i]);

        }

    }



    function isWhitelisted(address _address) public view returns(bool) {

        return hasRole(_address,WLST_ROLE);

    }

}



contract WhitelistAdminToken is Controller, Whitelisted, NAdmin {



    constructor() public {}



    modifier onlyAdmins() {

        require(msg.sender==owner || isAdmin(msg.sender), "Owner or Admin rights required.");

        _;

    }



    modifier onlyWhitelisted() {

        require(msg.sender==owner || whitelistUnlocked || isWhitelisted(msg.sender), "Owner or Whitelist rights required.");

        _;

    }



    function setWhitelistUnlock(bool _newStatus) public onlyAdmins {

        super.setWhitelistUnlock(_newStatus);

    }



    /**

     * @dev Allows admins to add people to the whitelist.

     * @param _toAdd The address to be added to whitelist.

     */

    function addToWhitelist(address _toAdd) public onlyAdmins {

        super.addToWhitelist(_toAdd);

    }



    function addListToWhitelist(address[] _toAdd) public onlyAdmins {

        super.addListToWhitelist(_toAdd);

    }



    function removeFromWhitelist(address _toRemove) public onlyAdmins {

        super.removeFromWhitelist(_toRemove);

    }



    function removeListFromWhitelist(address[] _toRemove) public onlyAdmins {

        super.removeListFromWhitelist(_toRemove);

    }



    /**

     * @dev Allows admins to add people to the admin list.

     * @param _toAdd The address to be added to admin list.

     */

    function addToAdmins(address _toAdd) public onlyAdmins {

        super.addToAdmins(_toAdd);

    }



    function addListToAdmins(address[] _toAdd) public onlyAdmins {

        super.addListToAdmins(_toAdd);

    }



    function removeFromAdmins(address _toRemove) public onlyAdmins {

        super.removeFromAdmins(_toRemove);

    }



    function removeListFromAdmins(address[] _toRemove) public onlyAdmins {

        super.removeListFromAdmins(_toRemove);

    }



    /**

     * @dev Only whitelisted can transfer tokens, and only to whitelisted addresses

     * @param _to The address where tokens will be sent to

     * @param _value The amount of tokens to be sent

     */

    function transfer(address _to, uint256 _value) public onlyWhitelisted returns(bool) {

        //If the destination is not whitelisted, try to add it (only admins modifier)

        if(!isWhitelisted(_to) && !whitelistUnlocked) addToWhitelist(_to);

        return super.transfer(_to, _value);

    }



    /**

     * @dev Only whitelisted can transfer tokens, and only to whitelisted addresses. Also, the msg.sender will need to be approved to do it

     * @param _from The address where tokens will be sent from

     * @param _to The address where tokens will be sent to

     * @param _value The amount of tokens to be sent

     */

    function transferFrom(address _from, address _to, uint256 _value) public onlyWhitelisted returns (bool) {

        //If the source is not whitelisted, try to add it (only admins modifier)

        if(!isWhitelisted(_from) && !whitelistUnlocked) addToWhitelist(_from);

        //If the destination is not whitelisted, try to add it (only admins modifier)

        if(!isWhitelisted(_to) && !whitelistUnlocked) addToWhitelist(_to);

        return super.transferFrom(_from, _to, _value);

    }



    /**

     * @dev Allow others to spend tokens from the msg.sender address. The spender should be whitelisted

     * @param _spender The address to be approved

     * @param _value The amount of tokens to be approved

     */

    function approve(address _spender, uint256 _value) public onlyWhitelisted returns (bool) {

        //If the approve spender is not whitelisted, try to add it (only admins modifier)

        if(!isWhitelisted(_spender) && !whitelistUnlocked) addToWhitelist(_spender);

        return super.approve(_spender, _value);

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
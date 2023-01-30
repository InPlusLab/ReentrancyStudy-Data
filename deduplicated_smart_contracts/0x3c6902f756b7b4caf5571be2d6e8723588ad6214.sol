pragma solidity ^0.4.24;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function divRemain(uint256 numerator, uint256 denominator) internal pure returns (uint256 quotient, uint256 remainder) {
    quotient  = div(numerator, denominator);
    remainder = sub(numerator, mul(denominator, quotient));
  }
}


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
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


/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 * to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);
  event RoleRemovedAll(string role);

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
   * @dev remove a role from an address
   * @param _role the name of the role
   */
  function removeRoleAll(string _role)
    internal
  {
    delete roles[_role];
    emit RoleRemovedAll(_role);
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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


/**
 * @title Administrable
 * @dev The Admin contract defines a single Admin who can transfer the ownership 
 * of a contract to a new address, even if he is not the owner. 
 * A Admin can transfer his role to a new address. 
 */
contract Administrable is Ownable, RBAC {
  string public constant ROLE_LOCKUP = "lockup";
  string public constant ROLE_MINT = "mint";

  constructor () public {
    addRole(msg.sender, ROLE_LOCKUP);
    addRole(msg.sender, ROLE_MINT);
  }

  /**
   * @dev Throws if called by any account that's not a Admin.
   */
  modifier onlyAdmin(string _role) {
    checkRole(msg.sender, _role);
    _;
  }

  modifier onlyOwnerOrAdmin(string _role) {
    require(msg.sender == owner || isAdmin(msg.sender, _role));
    _;
  }

  /**
   * @dev getter to determine if address has Admin role
   */
  function isAdmin(address _addr, string _role)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, _role);
  }

  /**
   * @dev add a admin role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addAdmin(address _operator, string _role)
    public
    onlyOwner
  {
    addRole(_operator, _role);
  }

  /**
   * @dev remove a admin role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeAdmin(address _operator, string _role)
    public
    onlyOwner
  {
    removeRole(_operator, _role);
  }

  /**
   * @dev claim a admin role from an address
   * @param _role the name of the role
   */
  function claimAdmin(string _role)
    public
    onlyOwner
  {
    removeRoleAll(_role);

    addRole(msg.sender, _role);
  }
}


/**
 * @title Lockable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Lockable is Administrable {

  using SafeMath for uint256;

  event Locked(address _granted, uint256 _amount, uint256 _expiresAt);
  event UnlockedAll(address _granted);

  /**
  * @dev Lock defines a lock of token
  */
  struct Lock {
    uint256 amount;
    uint256 expiresAt;
  }

  // granted to locks;
  mapping (address => Lock[]) public grantedLocks;
  

  /**
   * @dev called by the owner to lock, triggers stopped state
   */
  function lock
  (
    address _granted, 
    uint256 _amount, 
    uint256 _expiresAt
  ) 
    onlyOwnerOrAdmin(ROLE_LOCKUP) 
    public 
  {
    require(_amount > 0);
    require(_expiresAt > now);

    grantedLocks[_granted].push(Lock(_amount, _expiresAt));

    emit Locked(_granted, _amount, _expiresAt);
  }

  /**
   * @dev called by the owner to unlock, returns to normal state
   */
  function unlock
  (
    address _granted
  ) 
    onlyOwnerOrAdmin(ROLE_LOCKUP) 
    public 
  {
    require(grantedLocks[_granted].length > 0);
    
    delete grantedLocks[_granted];
    emit UnlockedAll(_granted);
  }

  function lockedAmountOf
  (
    address _granted
  ) 
    public
    view
    returns(uint256)
  {
    require(_granted != address(0));
    
    uint256 lockedAmount = 0;
    uint256 lockedCount = grantedLocks[_granted].length;
    if (lockedCount > 0) {
      Lock[] storage locks = grantedLocks[_granted];
      for (uint i = 0; i < locks.length; i++) {
        if (now < locks[i].expiresAt) {
          lockedAmount = lockedAmount.add(locks[i].amount);
        } 
      }
    }

    return lockedAmount;
  }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable  {
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
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev total number of tokens in exsitence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function msgSender() 
        public
        view
        returns (address)
    {
        return msg.sender;
    }

    function transfer(
        address _to, 
        uint256 _value
    ) 
        public 
        returns (bool) 
    {
        require(_to != address(0));
        require(_to != msg.sender);
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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


contract BurnableToken is StandardToken {
    
    event Burn(address indexed burner, uint256 value);

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) 
        public 
    {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) 
        internal 
    {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}



contract MintableToken is StandardToken, Administrable {
    event Mint(address indexed to, uint256 amount);
    event MintStarted();
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier cantMint() {
        require(mintingFinished);
        _;
    }
   
    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint
    * @return A boolean that indicated if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwnerOrAdmin(ROLE_MINT) canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to start minting new tokens.
     * @return True if the operation was successful. 
     */
    function startMinting() onlyOwner cantMint public returns (bool) {
        mintingFinished = false;
        emit MintStarted();
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




/**
 * @title Lockable token
 * @dev ReliableTokenToken modified with lockable transfers.
 **/
contract ReliableToken is MintableToken, BurnableToken, Pausable, Lockable {

  using SafeMath for uint256;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotExceedLock(address _granted, uint256 _value) {
    uint256 lockedAmount = lockedAmountOf(_granted);
    uint256 balance = balanceOf(_granted);

    require(balance > lockedAmount && balance.sub(lockedAmount) >= _value);
    _;
  }

  function transfer
  (
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    whenNotExceedLock(msg.sender, _value)
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferLocked
  (
    address _to, 
    uint256 _value,
    uint256 _lockAmount,
    uint256[] _expiresAtList
  ) 
    public 
    whenNotPaused
    whenNotExceedLock(msg.sender, _value)
    onlyOwnerOrAdmin(ROLE_LOCKUP)
    returns (bool) 
  {
    require(_value >= _lockAmount);

    uint256 lockCount = _expiresAtList.length;
    if (lockCount > 0) {
      (uint256 lockAmountEach, uint256 remainder) = _lockAmount.divRemain(lockCount);
      if (lockAmountEach > 0) {
        for (uint i = 0; i < lockCount; i++) {
          if (i == (lockCount - 1) && remainder > 0)
            lockAmountEach = lockAmountEach.add(remainder);

          lock(_to, lockAmountEach, _expiresAtList[i]);  
        }
      }
    }
    
    return transfer(_to, _value);
  }

  function transferFrom
  (
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    whenNotExceedLock(_from, _value)
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function transferLockedFrom
  (
    address _from,
    address _to, 
    uint256 _value,
    uint256 _lockAmount,
    uint256[] _expiresAtList
  ) 
    public 
    whenNotPaused
    whenNotExceedLock(_from, _value)
    onlyOwnerOrAdmin(ROLE_LOCKUP)
    returns (bool) 
  {
    require(_value >= _lockAmount);

    uint256 lockCount = _expiresAtList.length;
    if (lockCount > 0) {
      (uint256 lockAmountEach, uint256 remainder) = _lockAmount.divRemain(lockCount);
      if (lockAmountEach > 0) {
        for (uint i = 0; i < lockCount; i++) {
          if (i == (lockCount - 1) && remainder > 0)
            lockAmountEach = lockAmountEach.add(remainder);

          lock(_to, lockAmountEach, _expiresAtList[i]);  
        }
      }
    }

    return transferFrom(_from, _to, _value);
  }

  function approve
  (
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval
  (
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval
  (
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  function () external payable 
  {
    revert();
  }
}


contract BundableToken is ReliableToken {

    /**
    * @dev Transfers tokens to recipients multiply.
    * @param _recipients address list of the recipients to whom received tokens 
    * @param _values the amount list of tokens to be transferred
    */
    function transferMultiply
    (
        address[] _recipients,
        uint256[] _values
    )
        public
        returns (bool)
    {
        uint length = _recipients.length;
        require(length > 0);
        require(length == _values.length);

        for (uint i = 0; i < length; i++) {
            require(transfer(
                _recipients[i], 
                _values[i]
            ));
        }

        return true;
    }

    /**
    * @dev Transfers tokens held by timelock to recipients multiply.
    * @param _recipients address list of the recipients to whom received tokens 
    * @param _values the amount list of tokens to be transferred
    * #param _defaultExpiresAtList default release times
    */
    function transferLockedMultiply
    (
        address[] _recipients,
        uint256[] _values,
        uint256[] _lockAmounts,
        uint256[] _defaultExpiresAtList
    )
        public
        onlyOwnerOrAdmin(ROLE_LOCKUP)
        returns (bool)
    {
        uint length = _recipients.length;
        require(length > 0);
        require(length == _values.length && length == _lockAmounts.length);
        require(_defaultExpiresAtList.length > 0);

        for (uint i = 0; i < length; i++) {
            require(transferLocked(
                _recipients[i], 
                _values[i], 
                _lockAmounts[i], 
                _defaultExpiresAtList
            ));
        }

        return true;
    }
}


contract IOAtoken is BundableToken {

  string public constant name = "IOcean";
  string public constant symbol = "IOA";
  uint32 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 210000000 * (10 ** uint256(decimals));

  /**
  * @dev Constructor that gives msg.sender all of existing tokens.
  */
  constructor() public 
  {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}
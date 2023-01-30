/**
 *Submitted for verification at Etherscan.io on 2019-12-09
*/

pragma solidity 0.4.24;

/** ----------------------------------------------------------------------------
 * 'SOX Token' token contract
 *
 * Symbol : SOX
 * Name : Super OX Token
 * Website : https://www.superoxchain.com/
 * Total supply: 1000000000
 * Decimals : 18
 *
 * (c) superoxchain.com, 2018-04
 * ----------------------------------------------------------------------------
 **/ 

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
    uint256 c = a - b;
    return c;
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
 
/**
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     *
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
 
contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }

   /**
   * @return true if `msg.sender` is the owner of the contract.
   */
   function isOwner() public view returns (bool) {
    return msg.sender == _owner;
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
    emit OwnershipTransferred(_owner, _newOwner);
    _owner = _newOwner;
  }
}

/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
* See
https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
*/
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
function pauseContract() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
/**
* @dev called by the owner to unpause, returns to normal state
*/
function unpauseContract() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}

/**
 * @title Controlled 擁有者控制及管理合約
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Controlled is Pausable {
  using Roles for Roles.Role;
  // 黑名單資料集合
  Roles.Role internal lockedList;
  // 管理者群組名單資料集合
  Roles.Role internal adminGroupList;
  
  // 呼叫insertToExclude(address)合約擁有者位址插入管理者群組名單
  constructor() internal {
    Roles.add(adminGroupList, msg.sender);
  }
  
  // 缺省黑名單狀態值  true:使用黑名單 false:不使用黑名單
  bool internal _lockedListFlag = false;
  
  // 獲取黑名單狀態值  true:黑名單開啟狀態 false:黑名單關閉狀態
  function lockedListFlag() public view inAdminGroupList returns (bool) {
    return _lockedListFlag;
  }
  
   // 黑名單狀態值設定  true:使用黑名單 false:不使用黑名單
  function setLockedListFlag(bool _enable) public inAdminGroupList returns (bool success) {
    _lockedListFlag = _enable;
    return true;
  }
   
  // 寫入資料到黑名單map
  function insertToLockedList(address _addr)  public inAdminGroupList  returns (bool success) {
    Roles.add(lockedList, _addr);
    success = true;
  }
  
  function removeFromLockedList(address _addr)  public inAdminGroupList returns (bool success) {
    Roles.remove(lockedList, _addr);
    success = true;
  }
  
  function hasInLockedList(address _addr)  public inAdminGroupList view returns (bool) {
   return Roles.has(lockedList, _addr);
  }
  
 // 寫入資料到adminGroupList名單map
  function insertToAdminList(address _addr)  public inAdminGroupList  returns (bool success) {
    Roles.add(adminGroupList, _addr);
    success = true;
  }
  
  function removeFromAdminList(address _addr)  public inAdminGroupList  returns (bool success) {
    Roles.remove(adminGroupList, _addr);
    success = true;
  }
  
  function hasInAdminList(address _addr)  public inAdminGroupList view returns (bool) {
      return Roles.has(adminGroupList, _addr);
  }
    
  modifier inAdminGroupList() {
    require(Roles.has(adminGroupList, msg.sender), "you are not Admin Group Member!");
    _;
  }
  modifier notInLockedList() {
        if(_lockedListFlag) {
        require(!Roles.has(lockedList, msg.sender), "you are locked!");
        }
    _;
  }
}

contract ERC20Basic is Controlled {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 * See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/BasicToken.sol
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

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
  function transfer(address _to, uint256 _value) public whenNotPaused notInLockedList returns (bool) {
    if (_lockedListFlag) { 
     require(!Roles.has(lockedList, _to));
    }  
    require(_value <= balances[msg.sender]);
    require(_to != address(0));
    require(_to != 0x0); // Prevent transfer to 0x0 address.

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

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
* See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
*/
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

/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* https://github.com/ethereum/EIPs/issues/20
* Based on code by FirstBlood:https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
* See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/StandardToken.sol
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
    whenNotPaused
    notInLockedList
    returns (bool)
  {
    if (_lockedListFlag) { 
    require(!Roles.has(lockedList, _from));
    require(!Roles.has(lockedList, _to));
    }
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));
    require(_to != 0x0); // Prevent transfer to 0x0 address.

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
  function approve(address _spender, uint256 _value) public whenNotPaused notInLockedList returns (bool) {
    require(_spender != 0x0); // Prevent transfer to 0x0 address. 
    if (_lockedListFlag) { 
    require(!Roles.has(lockedList, _spender));
    }
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
    if (_lockedListFlag) { 
     require(!Roles.has(lockedList, _owner));
     require(!Roles.has(lockedList, _spender));
    }  
   
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
    whenNotPaused
    notInLockedList
    returns (bool)
  {
    require(_spender != 0x0); // Prevent transfer to 0x0 address. 
    if (_lockedListFlag) { 
     require(!Roles.has(lockedList, _spender));
    }
   
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
    whenNotPaused
    notInLockedList
    returns (bool)
  {
    require(_spender != 0x0); // Prevent transfer to 0x0 address. 
    if (_lockedListFlag) { 
     require(!Roles.has(lockedList, _spender));
    }
  
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {     
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

/**
* @title Super OX token
* @dev StandardToken modified with transfers.
**/

contract TokenSOX is StandardToken {
  string public name = "Super OX";
  string public symbol = "SOX";
  uint8 public decimals = 18;
  
  // total supply: 10 * 10^8 * 10^18
  uint256 internal INITIAL_SUPPLY = (1000000000)*(10**uint256(decimals));
 
  //缺省銷毀狀態 true:合約可銷毀代幣 false:合約不可銷毀代幣
  bool public burningFinishedFlag = true;
  event Burn(address indexed burner, uint256 value);
  event BurnFinished(address indexed caller, bool burningFinishedFlag);
  event BurnStarted(address indexed caller, bool burningFinishedFlag);
  
  /**
  * Token Constructor
  *
  */
  constructor() public{
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
  
  //檢查合約是否銷毀代幣的狀態 true:合約可銷毀代幣 false:合約不可銷毀代幣
  modifier canBurn() {
    require(!burningFinishedFlag);
    _;
  }
  
  //銷毀合約代幣
  function burnFromOwner(uint256 _value) public onlyOwner canBurn returns (bool success) {
    _burn(msg.sender, _value);
    return true;
  }
 
  function _burn(address _who, uint256 _value) internal {
    require(_who != 0x0);  
    require(_value > 0,"Value is greater than 0");
    require(_value <= balances[_who]);
    require(totalSupply_.sub(_value) >= 0,"totalSupply Value is greater than or equal to 0" ) ;
  
    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
  
   /**
   * @dev Function to stop burning tokens.
   * @return True if the operation was successful.
   */
  function setBurningFinishedFlag(bool toggleBurning) public onlyOwner returns (bool) {
    burningFinishedFlag = toggleBurning;
    if (toggleBurning) {
      emit BurnFinished(msg.sender, burningFinishedFlag);
    }
    else {
      emit BurnStarted(msg.sender, burningFinishedFlag);  
    }
    return true;
  }
 
}
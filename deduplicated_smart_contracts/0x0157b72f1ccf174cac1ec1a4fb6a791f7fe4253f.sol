/**

 *Submitted for verification at Etherscan.io on 2019-02-25

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/access/rbac/Roles.sol



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

  function add(Role storage _role, address _addr)

    internal

  {

    _role.bearer[_addr] = true;

  }



  /**

   * @dev remove an address' access to this role

   */

  function remove(Role storage _role, address _addr)

    internal

  {

    _role.bearer[_addr] = false;

  }



  /**

   * @dev check if an address has this role

   * // reverts

   */

  function check(Role storage _role, address _addr)

    internal

    view

  {

    require(has(_role, _addr));

  }



  /**

   * @dev check if an address has this role

   * @return bool

   */

  function has(Role storage _role, address _addr)

    internal

    view

    returns (bool)

  {

    return _role.bearer[_addr];

  }

}



// File: openzeppelin-solidity/contracts/access/rbac/RBAC.sol



/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 */

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

    public

    view

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

    public

    view

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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

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

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



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



// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is BasicToken {



  event Burn(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);

  }



  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    // no need to require value <= totalSupply, since that would imply the

    // sender's balance is greater than the totalSupply, which *should* be an assertion failure



    balances[_who] = balances[_who].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol



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

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



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

    if (_subtractedValue >= oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol



/**

 * @title Mintable token

 * @dev Simple ERC20 Token example, with mintable token creation

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */

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

    public

    hasMintPermission

    canMint

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

  function finishMinting() public onlyOwner canMint returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }

}



// File: contracts/FUTM.sol



contract FUTM is MintableToken, BurnableToken, RBAC {

  using SafeMath for uint256;



  string public constant name = "Futereum Markets";

  string public constant symbol = "FUTM";

  uint8 public constant decimals = 18;



  string public constant ROLE_ADMIN = "admin";

  string public constant ROLE_SUPER = "super";



  uint public swapLimit;

  uint public constant CYCLE_CAP = 100000 * (10 ** uint256(decimals));

  uint public constant BILLION = 10 ** 9;



  event SwapStarted(uint256 startTime);

  event MiningRestart(uint256 endTime);

  event CMCUpdate(string updateType, uint value);



  uint offset = 10**18;

  // these rates are offset. divide by 1e18 to get actual rate.

  uint public exchangeRateFUTB;

  uint public exchangeRateFUTX;



  //initial state

  uint public cycleMintSupply = 0;

  bool public isMiningOpen = false;

  uint public CMC = 129238998229;

  uint public cycleEndTime;



  address public constant FUTC = 0xdaa6CD28E6aA9d656930cE4BB4FA93eEC96ee791;

  address public constant FUTB = 0x42D8F8E19F73707397B6e9eB7dD022d3c0aE736c;

  address public constant FUTX = 0x8b7d07b6ffB9364e97B89cEA8b84F94249bE459F;



  constructor() public {

    //only the contract itself can mint as the owner

    owner = this;

    totalSupply_ = 0;

    addRole(msg.sender, ROLE_ADMIN);

    addRole(msg.sender, ROLE_SUPER);



    // initial market data to set rates.

    exchangeRateFUTB = offset.mul(offset).div(CMC.mul(offset).div(BILLION)).mul(65).div(100);

    exchangeRateFUTX = offset.mul(offset).div(uint(14757117940).mul(offset).div(uint(67447696614)).mul(CMC).div(BILLION)).mul(65).div(100);

  }



  modifier canMine() {

    require(isMiningOpen);

    _;

  }



  // first call (futb address).approve(futm address, amount) for FUTM to transfer on your behalf.

  function mine(uint amount) canMine external {

    require(amount > 0);

    require(cycleMintSupply < CYCLE_CAP);

    require(ERC20(FUTB).transferFrom(msg.sender, address(this), amount));



    uint refund = _mine(exchangeRateFUTB, amount);

    if(refund > 0) {

      ERC20(FUTB).transfer(msg.sender, refund);

    }

    if (cycleMintSupply == CYCLE_CAP) {

      //start swap

      _startSwap();

    }

  }



  function _mine(uint _rate, uint _inAmount) private returns (uint) {

    assert(_rate > 0);



    // took too long; return tokens and start swap.

    if (now > cycleEndTime && cycleMintSupply > 0) {

      _startSwap();

      return _inAmount;

    }

    uint tokens = _rate.mul(_inAmount).div(offset);

    uint refund = 0;



    // for every 65 tokens mined, we mine 35 for the futc contract.

    uint futcFeed = tokens.mul(35).div(65);



    if (tokens + futcFeed + cycleMintSupply > CYCLE_CAP) {

      uint overage = tokens + futcFeed + cycleMintSupply - CYCLE_CAP;

      uint tokenOverage = overage.mul(65).div(100);

      futcFeed -= (overage - tokenOverage);

      tokens -= tokenOverage;



      // refund token overage

      refund = tokenOverage.mul(offset).div(_rate);

    }

    cycleMintSupply += (tokens + futcFeed);

    require(futcFeed > 0, "Mining payment too small.");

    MintableToken(this).mint(msg.sender, tokens);

    MintableToken(this).mint(FUTC, futcFeed);



    return refund;

  }



  // swap data

  bool public swapOpen = false;

  mapping(address => uint) public swapRates;



  function _startSwap() private {

    swapOpen = true;

    isMiningOpen = false;



    // set swap rates

    // 35% of holdings split among a number equal to 35% of newly minted futm

    swapLimit = cycleMintSupply.mul(35).div(100);

    swapRates[FUTX] = ERC20(FUTX).balanceOf(address(this)).mul(offset).mul(35).div(100).div(swapLimit);

    swapRates[FUTB] = ERC20(FUTB).balanceOf(address(this)).mul(offset).mul(35).div(100).div(swapLimit);



    emit SwapStarted(now);

  }



  function swap(uint amt) public {

    require(swapOpen && swapLimit > 0);

    if (amt > swapLimit) {

      amt = swapLimit;

    }

    swapLimit -= amt;

    // burn verifies msg.sender has balance

    burn(amt);



    if (amt.mul(swapRates[FUTX]) > 0) {

      ERC20(FUTX).transfer(msg.sender, amt.mul(swapRates[FUTX]).div(offset));

    }



    if (amt.mul(swapRates[FUTB]) > 0) {

      ERC20(FUTB).transfer(msg.sender, amt.mul(swapRates[FUTB]).div(offset));

    }



    if (swapLimit == 0) {

      _restart();

    }

  }



  function _restart() private {

    require(swapOpen);

    require(swapLimit == 0);



    cycleMintSupply = 0;

    swapOpen = false;

    isMiningOpen = true;

    cycleEndTime = now + 100 days;



    emit MiningRestart(cycleEndTime);

  }



  function updateCMC(uint _cmc) private {

    require(_cmc > 0);

    CMC = _cmc;

    emit CMCUpdate("TOTAL_CMC", _cmc);

    exchangeRateFUTB = offset.mul(offset).div(CMC.mul(offset).div(BILLION)).mul(65).div(100);

  }



  function updateCMC(uint _cmc, uint _btc, uint _eth) public onlyAdmin{

    require(_btc > 0 && _eth > 0);

    updateCMC(_cmc);

    emit CMCUpdate("BTC_CMC", _btc);

    emit CMCUpdate("ETH_CMC", _eth);

    exchangeRateFUTX = offset.mul(offset).div(_eth.mul(offset).div(_btc).mul(CMC).div(BILLION)).mul(65).div(100);

  }



  modifier onlySuper() {

    checkRole(msg.sender, ROLE_SUPER);

    _;

  }



  modifier onlyAdmin() {

    checkRole(msg.sender, ROLE_ADMIN);

    _;

  }



  function addAdmin(address _addr) public onlySuper {

    addRole(_addr, ROLE_ADMIN);

  }



  function removeAdmin(address _addr) public onlySuper {

    removeRole(_addr, ROLE_ADMIN);

  }



  function changeSuper(address _addr) public onlySuper {

    addRole(_addr, ROLE_SUPER);

    removeRole(msg.sender, ROLE_SUPER);

  }

}
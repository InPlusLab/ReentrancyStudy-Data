/**

 *Submitted for verification at Etherscan.io on 2018-12-05

*/



pragma solidity ^0.4.24;



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



// File: contracts/crowdsale/utils/Contributions.sol



contract Contributions is RBAC, Ownable {

  using SafeMath for uint256;



  uint256 private constant TIER_DELETED = 999;

  string public constant ROLE_MINTER = "minter";

  string public constant ROLE_OPERATOR = "operator";



  uint256 public tierLimit;



  modifier onlyMinter () {

    checkRole(msg.sender, ROLE_MINTER);

    _;

  }



  modifier onlyOperator () {

    checkRole(msg.sender, ROLE_OPERATOR);

    _;

  }



  uint256 public totalSoldTokens;

  mapping(address => uint256) public tokenBalances;

  mapping(address => uint256) public ethContributions;

  mapping(address => uint256) private _whitelistTier;

  address[] public tokenAddresses;

  address[] public ethAddresses;

  address[] private whitelistAddresses;



  constructor(uint256 _tierLimit) public {

    addRole(owner, ROLE_OPERATOR);

    tierLimit = _tierLimit;

  }



  function addMinter(address minter) external onlyOwner {

    addRole(minter, ROLE_MINTER);

  }



  function removeMinter(address minter) external onlyOwner {

    removeRole(minter, ROLE_MINTER);

  }



  function addOperator(address _operator) external onlyOwner {

    addRole(_operator, ROLE_OPERATOR);

  }



  function removeOperator(address _operator) external onlyOwner {

    removeRole(_operator, ROLE_OPERATOR);

  }



  function addTokenBalance(

    address _address,

    uint256 _tokenAmount

  )

    external

    onlyMinter

  {

    if (tokenBalances[_address] == 0) {

      tokenAddresses.push(_address);

    }

    tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);

    totalSoldTokens = totalSoldTokens.add(_tokenAmount);

  }



  function addEthContribution(

    address _address,

    uint256 _weiAmount

  )

    external

    onlyMinter

  {

    if (ethContributions[_address] == 0) {

      ethAddresses.push(_address);

    }

    ethContributions[_address] = ethContributions[_address].add(_weiAmount);

  }



  function setTierLimit(uint256 _newTierLimit) external onlyOperator {

    require(_newTierLimit > 0, "Tier must be greater than zero");



    tierLimit = _newTierLimit;

  }



  function addToWhitelist(

    address _investor,

    uint256 _tier

  )

    external

    onlyOperator

  {

    require(_tier == 1 || _tier == 2, "Only two tier level available");

    if (_whitelistTier[_investor] == 0) {

      whitelistAddresses.push(_investor);

    }

    _whitelistTier[_investor] = _tier;

  }



  function removeFromWhitelist(address _investor) external onlyOperator {

    _whitelistTier[_investor] = TIER_DELETED;

  }



  function whitelistTier(address _investor) external view returns (uint256) {

    return _whitelistTier[_investor] <= 2 ? _whitelistTier[_investor] : 0;

  }



  function getWhitelistedAddresses(

    uint256 _tier

  )

    external

    view

    returns (address[])

  {

    address[] memory tmp = new address[](whitelistAddresses.length);



    uint y = 0;

    if (_tier == 1 || _tier == 2) {

      uint len = whitelistAddresses.length;

      for (uint i = 0; i < len; i++) {

        if (_whitelistTier[whitelistAddresses[i]] == _tier) {

          tmp[y] = whitelistAddresses[i];

          y++;

        }

      }

    }



    address[] memory toReturn = new address[](y);



    for (uint k = 0; k < y; k++) {

      toReturn[k] = tmp[k];

    }



    return toReturn;

  }



  function isAllowedPurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    external

    view

    returns (bool)

  {

    if (_whitelistTier[_beneficiary] == 2) {

      return true;

    } else if (_whitelistTier[_beneficiary] == 1 && ethContributions[_beneficiary].add(_weiAmount) <= tierLimit) {

      return true;

    }



    return false;

  }



  function getTokenAddressesLength() external view returns (uint) {

    return tokenAddresses.length;

  }



  function getEthAddressesLength() external view returns (uint) {

    return ethAddresses.length;

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



// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol



/**

 * @title DetailedERC20 token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

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



// File: openzeppelin-solidity/contracts/token/ERC20/RBACMintableToken.sol



/**

 * @title RBACMintableToken

 * @author Vittorio Minacori (@vittominacori)

 * @dev Mintable Token, with RBAC minter permissions

 */

contract RBACMintableToken is MintableToken, RBAC {

  /**

   * A constant role name for indicating minters.

   */

  string public constant ROLE_MINTER = "minter";



  /**

   * @dev override the Mintable token modifier to add role based logic

   */

  modifier hasMintPermission() {

    checkRole(msg.sender, ROLE_MINTER);

    _;

  }



  /**

   * @dev add a minter role to an address

   * @param _minter address

   */

  function addMinter(address _minter) public onlyOwner {

    addRole(_minter, ROLE_MINTER);

  }



  /**

   * @dev remove a minter role from an address

   * @param _minter address

   */

  function removeMinter(address _minter) public onlyOwner {

    removeRole(_minter, ROLE_MINTER);

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



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */

library AddressUtils {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   * as the code is not actually created until after the constructor finishes.

   * @param _addr address to check

   * @return whether the target address is a contract

   */

  function isContract(address _addr) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(_addr) }

    return size > 0;

  }



}



// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



/**

 * @title ERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface ERC165 {



  /**

   * @notice Query if a contract implements an interface

   * @param _interfaceId The interface identifier, as specified in ERC-165

   * @dev Interface identification is specified in ERC-165. This function

   * uses less than 30,000 gas.

   */

  function supportsInterface(bytes4 _interfaceId)

    external

    view

    returns (bool);

}



// File: openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol



/**

 * @title SupportsInterfaceWithLookup

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract SupportsInterfaceWithLookup is ERC165 {



  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) internal supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  constructor()

    public

  {

    _registerInterface(InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 _interfaceId)

    external

    view

    returns (bool)

  {

    return supportedInterfaces[_interfaceId];

  }



  /**

   * @dev private method for registering an interface

   */

  function _registerInterface(bytes4 _interfaceId)

    internal

  {

    require(_interfaceId != 0xffffffff);

    supportedInterfaces[_interfaceId] = true;

  }

}



// File: erc-payable-token/contracts/token/ERC1363/ERC1363.sol



/**

 * @title ERC1363 interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for a Payable Token contract as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract ERC1363 is ERC20, ERC165 {

  /*

   * Note: the ERC-165 identifier for this interface is 0x4bbee2df.

   * 0x4bbee2df ===

   *   bytes4(keccak256('transferAndCall(address,uint256)')) ^

   *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)'))

   */



  /*

   * Note: the ERC-165 identifier for this interface is 0xfb9ec8ce.

   * 0xfb9ec8ce ===

   *   bytes4(keccak256('approveAndCall(address,uint256)')) ^

   *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))

   */



  /**

   * @notice Transfer tokens from `msg.sender` to another address

   *  and then call `onTransferReceived` on receiver

   * @param _to address The address which you want to transfer to

   * @param _value uint256 The amount of tokens to be transferred

   * @return true unless throwing

   */

  function transferAndCall(address _to, uint256 _value) public returns (bool);



  /**

   * @notice Transfer tokens from `msg.sender` to another address

   *  and then call `onTransferReceived` on receiver

   * @param _to address The address which you want to transfer to

   * @param _value uint256 The amount of tokens to be transferred

   * @param _data bytes Additional data with no specified format, sent in call to `_to`

   * @return true unless throwing

   */

  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len



  /**

   * @notice Transfer tokens from one address to another

   *  and then call `onTransferReceived` on receiver

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 The amount of tokens to be transferred

   * @return true unless throwing

   */

  function transferFromAndCall(address _from, address _to, uint256 _value) public returns (bool); // solium-disable-line max-len





  /**

   * @notice Transfer tokens from one address to another

   *  and then call `onTransferReceived` on receiver

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 The amount of tokens to be transferred

   * @param _data bytes Additional data with no specified format, sent in call to `_to`

   * @return true unless throwing

   */

  function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len, arg-overflow



  /**

   * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender

   *  and then call `onApprovalReceived` on spender

   *  Beware that changing an allowance with this method brings the risk that someone may use both the old

   *  and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   *  race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   *  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender address The address which will spend the funds

   * @param _value uint256 The amount of tokens to be spent

   */

  function approveAndCall(address _spender, uint256 _value) public returns (bool); // solium-disable-line max-len



  /**

   * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender

   *  and then call `onApprovalReceived` on spender

   *  Beware that changing an allowance with this method brings the risk that someone may use both the old

   *  and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   *  race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   *  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender address The address which will spend the funds

   * @param _value uint256 The amount of tokens to be spent

   * @param _data bytes Additional data with no specified format, sent in call to `_spender`

   */

  function approveAndCall(address _spender, uint256 _value, bytes _data) public returns (bool); // solium-disable-line max-len

}



// File: erc-payable-token/contracts/token/ERC1363/ERC1363Receiver.sol



/**

 * @title ERC1363Receiver interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for any contract that wants to support transferAndCall or transferFromAndCall

 *  from ERC1363 token contracts as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract ERC1363Receiver {

  /*

   * Note: the ERC-165 identifier for this interface is 0x88a7ca5c.

   * 0x88a7ca5c === bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))

   */



  /**

   * @notice Handle the receipt of ERC1363 tokens

   * @dev Any ERC1363 smart contract calls this function on the recipient

   *  after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the

   *  transfer. Return of other than the magic value MUST result in the

   *  transaction being reverted.

   *  Note: the token contract address is always the message sender.

   * @param _operator address The address which called `transferAndCall` or `transferFromAndCall` function

   * @param _from address The address which are token transferred from

   * @param _value uint256 The amount of tokens transferred

   * @param _data bytes Additional data with no specified format

   * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`

   *  unless throwing

   */

  function onTransferReceived(address _operator, address _from, uint256 _value, bytes _data) external returns (bytes4); // solium-disable-line max-len, arg-overflow

}



// File: erc-payable-token/contracts/token/ERC1363/ERC1363Spender.sol



/**

 * @title ERC1363Spender interface

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Interface for any contract that wants to support approveAndCall

 *  from ERC1363 token contracts as defined in

 *  https://github.com/ethereum/EIPs/issues/1363

 */

contract ERC1363Spender {

  /*

   * Note: the ERC-165 identifier for this interface is 0x7b04a2d0.

   * 0x7b04a2d0 === bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))

   */



  /**

   * @notice Handle the approval of ERC1363 tokens

   * @dev Any ERC1363 smart contract calls this function on the recipient

   *  after an `approve`. This function MAY throw to revert and reject the

   *  approval. Return of other than the magic value MUST result in the

   *  transaction being reverted.

   *  Note: the token contract address is always the message sender.

   * @param _owner address The address which called `approveAndCall` function

   * @param _value uint256 The amount of tokens to be spent

   * @param _data bytes Additional data with no specified format

   * @return `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))`

   *  unless throwing

   */

  function onApprovalReceived(address _owner, uint256 _value, bytes _data) external returns (bytes4); // solium-disable-line max-len

}



// File: erc-payable-token/contracts/token/ERC1363/ERC1363BasicToken.sol



// solium-disable-next-line max-len















/**

 * @title ERC1363BasicToken

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Implementation of an ERC1363 interface

 */

contract ERC1363BasicToken is SupportsInterfaceWithLookup, StandardToken, ERC1363 { // solium-disable-line max-len

  using AddressUtils for address;



  /*

   * Note: the ERC-165 identifier for this interface is 0x4bbee2df.

   * 0x4bbee2df ===

   *   bytes4(keccak256('transferAndCall(address,uint256)')) ^

   *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^

   *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)'))

   */

  bytes4 internal constant InterfaceId_ERC1363Transfer = 0x4bbee2df;



  /*

   * Note: the ERC-165 identifier for this interface is 0xfb9ec8ce.

   * 0xfb9ec8ce ===

   *   bytes4(keccak256('approveAndCall(address,uint256)')) ^

   *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))

   */

  bytes4 internal constant InterfaceId_ERC1363Approve = 0xfb9ec8ce;



  // Equals to `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`

  // which can be also obtained as `ERC1363Receiver(0).onTransferReceived.selector`

  bytes4 private constant ERC1363_RECEIVED = 0x88a7ca5c;



  // Equals to `bytes4(keccak256("onApprovalReceived(address,uint256,bytes)"))`

  // which can be also obtained as `ERC1363Spender(0).onApprovalReceived.selector`

  bytes4 private constant ERC1363_APPROVED = 0x7b04a2d0;



  constructor() public {

    // register the supported interfaces to conform to ERC1363 via ERC165

    _registerInterface(InterfaceId_ERC1363Transfer);

    _registerInterface(InterfaceId_ERC1363Approve);

  }



  function transferAndCall(

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    return transferAndCall(_to, _value, "");

  }



  function transferAndCall(

    address _to,

    uint256 _value,

    bytes _data

  )

    public

    returns (bool)

  {

    require(transfer(_to, _value));

    require(

      checkAndCallTransfer(

        msg.sender,

        _to,

        _value,

        _data

      )

    );

    return true;

  }



  function transferFromAndCall(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    // solium-disable-next-line arg-overflow

    return transferFromAndCall(_from, _to, _value, "");

  }



  function transferFromAndCall(

    address _from,

    address _to,

    uint256 _value,

    bytes _data

  )

    public

    returns (bool)

  {

    require(transferFrom(_from, _to, _value));

    require(

      checkAndCallTransfer(

        _from,

        _to,

        _value,

        _data

      )

    );

    return true;

  }



  function approveAndCall(

    address _spender,

    uint256 _value

  )

    public

    returns (bool)

  {

    return approveAndCall(_spender, _value, "");

  }



  function approveAndCall(

    address _spender,

    uint256 _value,

    bytes _data

  )

    public

    returns (bool)

  {

    approve(_spender, _value);

    require(

      checkAndCallApprove(

        _spender,

        _value,

        _data

      )

    );

    return true;

  }



  /**

   * @dev Internal function to invoke `onTransferReceived` on a target address

   *  The call is not executed if the target address is not a contract

   * @param _from address Representing the previous owner of the given token value

   * @param _to address Target address that will receive the tokens

   * @param _value uint256 The amount mount of tokens to be transferred

   * @param _data bytes Optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function checkAndCallTransfer(

    address _from,

    address _to,

    uint256 _value,

    bytes _data

  )

    internal

    returns (bool)

  {

    if (!_to.isContract()) {

      return false;

    }

    bytes4 retval = ERC1363Receiver(_to).onTransferReceived(

      msg.sender, _from, _value, _data

    );

    return (retval == ERC1363_RECEIVED);

  }



  /**

   * @dev Internal function to invoke `onApprovalReceived` on a target address

   *  The call is not executed if the target address is not a contract

   * @param _spender address The address which will spend the funds

   * @param _value uint256 The amount of tokens to be spent

   * @param _data bytes Optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function checkAndCallApprove(

    address _spender,

    uint256 _value,

    bytes _data

  )

    internal

    returns (bool)

  {

    if (!_spender.isContract()) {

      return false;

    }

    bytes4 retval = ERC1363Spender(_spender).onApprovalReceived(

      msg.sender, _value, _data

    );

    return (retval == ERC1363_APPROVED);

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

   * @param _tokenAddress address The token contract address

   * @param _tokens Number of tokens to be sent

   * @return bool

   */

  function recoverERC20(

    address _tokenAddress,

    uint256 _tokens

  )

  public

  onlyOwner

  returns (bool success)

  {

    return ERC20Basic(_tokenAddress).transfer(owner, _tokens);

  }

}



// File: contracts/token/FidelityHouseToken.sol



// solium-disable-next-line max-len

contract FidelityHouseToken is DetailedERC20, RBACMintableToken, BurnableToken, ERC1363BasicToken, TokenRecover {



  uint256 public lockedUntil;

  mapping(address => uint256) internal lockedBalances;



  modifier canTransfer(address _from, uint256 _value) {

    require(

      mintingFinished,

      "Minting should be finished before transfer."

    );

    require(

      _value <= balances[_from].sub(lockedBalanceOf(_from)),

      "Can't transfer more than unlocked tokens"

    );

    _;

  }



  constructor(uint256 _lockedUntil)

    DetailedERC20("FidelityHouse Token", "FIH", 18)

    public

  {

    lockedUntil = _lockedUntil;

  }



  /**

   * @dev Gets the locked balance of the specified address.

   * @param _owner The address to query the balance of.

   * @return An uint256 representing the locked amount owned by the passed address.

   */

  function lockedBalanceOf(address _owner) public view returns (uint256) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp <= lockedUntil ? lockedBalances[_owner] : 0;

  }



  /**

   * @dev Function to mint and lock tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mintAndLock(

    address _to,

    uint256 _amount

  )

    public

    hasMintPermission

    canMint

    returns (bool)

  {

    lockedBalances[_to] = lockedBalances[_to].add(_amount);

    return super.mint(_to, _amount);

  }



  function transfer(

    address _to,

    uint256 _value

  )

    public

    canTransfer(msg.sender, _value)

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

    canTransfer(_from, _value)

    returns (bool)

  {

    return super.transferFrom(_from, _to, _value);

  }

}



// File: contracts/crowdsale/FidelityHousePrivateSale.sol



contract FidelityHousePrivateSale is TokenRecover {

  using SafeMath for uint256;



  mapping (address => uint256) public sentTokens;



  FidelityHouseToken public token;

  Contributions public contributions;



  constructor(address _token, address _contributions) public {

    require(

      _token != address(0),

      "Token shouldn't be the zero address."

    );

    require(

      _contributions != address(0),

      "Contributions address can't be the zero address."

    );



    token = FidelityHouseToken(_token);

    contributions = Contributions(_contributions);

  }



  function multiSend(

    address[] _addresses,

    uint256[] _amounts,

    uint256[] _bonuses

  )

    external

    onlyOwner

  {

    require(

      _addresses.length > 0,

      "Addresses array shouldn't be empty."

    );

    require(

      _amounts.length > 0,

      "Amounts array shouldn't be empty."

    );

    require(

      _bonuses.length > 0,

      "Bonuses array shouldn't be empty."

    );

    require(

      _addresses.length == _amounts.length && _addresses.length == _bonuses.length,

      "Arrays should have the same length."

    );



    uint len = _addresses.length;

    for (uint i = 0; i < len; i++) {

      address _beneficiary = _addresses[i];

      uint256 _tokenAmount = _amounts[i];

      uint256 _bonusAmount = _bonuses[i];



      if (sentTokens[_beneficiary] == 0) {

        uint256 totalTokens = _tokenAmount.add(_bonusAmount);

        sentTokens[_beneficiary] = totalTokens;

        token.mintAndLock(_beneficiary, _tokenAmount);

        token.mint(_beneficiary, _bonusAmount);

        contributions.addTokenBalance(_beneficiary, totalTokens);

      }

    }

  }

}
/**

 *Submitted for verification at Etherscan.io on 2018-09-13

*/



pragma solidity ^0.4.24;



/**

CullCoin.io 



CullCoin CROWDSALE code combined

Thank-you Zeppelin for OpenZeppelin.



Safemath / openzeppelin-solidity

Ownable / openzeppelin-solidity

Crowdsale / openzeppelin-solidity / edited AB CullCoin

Mintedcrowdsale / openzeppelin-solidity

TimedCrowdsale  / openzeppelin-solidity

ERC20Basic / openzeppelin-solidity

ERC20 / openzeppelin-solidity

SafeERC20 / openzeppelin-solidity

BasicToken / openzeppelin-solidity

StandardToken / openzeppelin-solidity

MintableToken / openzeppelin-solidity

Roles / openzeppelin-solidity

RBAC / openzeppelin-solidity

Whitelist / openzeppelin-solidity

WhitelistedCrowdsale / openzeppelin-solidity

CullCoinToken / AB CullCoin

CullCoinCrowdsale / AB CullCoin

**/



//library SafeMath // openzeppelin-solidity

/**

 * @title SafeMath, openzeppelin solidity

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



//Ownable.sol // openzeppelin-solidity

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



// Crowdsale.sol // openzeppelin-solidity

/**

 * @title Crowdsale, openzeppelin-solidity

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

 

contract Crowdsale {

  using SafeMath for uint256;

  using SafeERC20 for ERC20;

  

  //AB

  uint256 public presaleEnds;

  uint256 public bonus1Ends;

  uint256 public bonus2Ends;

  uint256 public bonus3Ends;

  //AB



  // The token being sold

  ERC20 public token;



  // Address where funds are collected

  address public wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 public rate;



  // Amount of wei raised

  uint256 public weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param _rate Number of token units a buyer gets per wei

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   */



  constructor(uint256 _rate, address _wallet, ERC20 _token, uint256 _presaleEnds, uint256 _bonus1Ends, uint256 _bonus2Ends, uint256 _bonus3Ends) public {

    require(_wallet != address(0));

    require(_token != address(0));

  

    rate = _rate;

    wallet = _wallet;

    token = _token;

    

    presaleEnds = _presaleEnds;

    bonus1Ends = _bonus1Ends;

    bonus2Ends = _bonus2Ends;

    bonus3Ends = _bonus3Ends;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------

 

  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokens(address _beneficiary) public payable {

      

    //uint256 messageValue ;

    uint256 weiAmount= msg.value;

    

    //AB must be on whitelist until end of bonus2 period

    //No whitelist required for bonus3 / no bonus period

    //See whitelistedCrowdsale

    if (now <= bonus2Ends){   

    _preValidatePurchase(_beneficiary, weiAmount); // whitelist or throw

    }

    else{

    _prevalidateNoWhitelist(_beneficiary, weiAmount); // no whitelist

    }

    //AB



    // calculate token amount to be created

    // AB Bonus calculated.

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    _processPurchase(_beneficiary, tokens);

    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(_beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(_beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.

   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 

   *   super._preValidatePurchase(_beneficiary, _weiAmount);

   *   require(weiRaised.add(_weiAmount) <= cap);

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  

  // extended in TimedCrowdsale to check if purchaser is on whitelist

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    require(_beneficiary != address(0));

    require(_weiAmount != 0);

  }

  

  // AB validate without whitelist

    function _prevalidateNoWhitelist(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    require(_beneficiary != address(0));

    require(_weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    token.safeTransfer(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    _deliverTokens(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param _beneficiary Address receiving the tokens

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

   

  //AB calculate total tokens inc. bonus

  function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

  {

        uint256 bonusRate;



        if (now <= presaleEnds) // 40% bonus presale

        {

            bonusRate = 5600;

        } 

        else if (now <= bonus1Ends) // 30% bonus 1

        {

            bonusRate = 5200;

        }

        else if (now <= bonus2Ends) // 20% bonus 2

        {

            bonusRate = 4800;

        }

        else if (now <= bonus3Ends) // 10% bonus 3

        {

            bonusRate = 4400;

        }

        else {

            bonusRate = rate;

        }

    

    return _weiAmount.mul(bonusRate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    wallet.transfer(msg.value);

  }

}



//MintedCrowdsale.sol // openzeppelin-solidity

//import "./Crowdsale.sol";

//import "./MintableToken.sol";

/**

 * @title MintedCrowdsale

 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.

 * Token ownership should be transferred to MintedCrowdsale for minting.

 */

contract MintedCrowdsale is Crowdsale {



  /**

   * @dev Overrides delivery by minting tokens upon purchase.

   * @param _beneficiary Token purchaser

   * @param _tokenAmount Number of tokens to be minted

   */

  function _deliverTokens(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    // Potentially dangerous assumption about the type of the token.

    require(MintableToken(address(token)).mint(_beneficiary, _tokenAmount));

  }

}



//TimedCrowdsale.sol // openzeppelin-solidity

//import "./SafeMath.sol";

//import "./Crowdsale.sol";

/**

 * @title TimedCrowdsale, openzeppelin solidity

 * @dev Crowdsale accepting contributions only within a time frame.

 */

contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 public openingTime;

  uint256 public closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= openingTime && block.timestamp <= closingTime);

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param _openingTime Crowdsale opening time

   * @param _closingTime Crowdsale closing time

   */

  constructor(uint256 _openingTime, uint256 _closingTime) public {

    // solium-disable-next-line security/no-block-members

    require(_openingTime >= block.timestamp);

    require(_closingTime >= _openingTime);



    openingTime = _openingTime;

    closingTime = _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > closingTime;

  }

  

    /**

   * @dev Checks crowdsale has opened

   * @return Whether crowdsale opened

   */

  function hasOpened() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > openingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param _beneficiary Token purchaser

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

    onlyWhileOpen

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



//ERC20Basic.sol // openzeppelin-solidity

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



//ERC20.sol // openzeppelin-solidity

//import "./ERC20Basic.sol";

/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic, Ownable, Crowdsale {  // AB Ownable, Crowdsale

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



//SafeERC20.sol // openzeppelin-solidity

//import "./ERC20Basic.sol";

//import "./ERC20.sol";

/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(

    ERC20Basic _token,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transfer(_to, _value));

  }



  function safeTransferFrom(

    ERC20 _token,

    address _from,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transferFrom(_from, _to, _value));

  }



  function safeApprove(

    ERC20 _token,

    address _spender,

    uint256 _value

  )

    internal

  {

    require(_token.approve(_spender, _value));

  }

}



//BasicToken.sol // openzeppelin-solidity

//import "./ERC20Basic.sol";

//import "./SafeMath.sol";

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



//StandardToken.sol // openzeppelin-solidity

//import "./BasicToken.sol";

//import "./ERC20.sol";

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



//MintableToken.sol // openzeppelin-solidity

//import "./StandardToken.sol";

//import "./Ownable.sol";

/**

 * @title Mintable token

 * @dev Simple ERC20 Token example, with mintable token creation

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */

contract MintableToken is StandardToken { // AB removed ownable

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



//Roles.sol // openzeppelin-solidity

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



//RBAC.sol // openzeppelin-solidity

//import "./Roles.sol";

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



//Whitelist.sol // openzeppelin-solidity

//import "./Ownable.sol";

//import "./RBAC.sol";

/**

 * @title Whitelist

 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.

 * This simplifies the implementation of "user permissions".

 */

contract Whitelist is Ownable, RBAC {

  string public constant ROLE_WHITELISTED = "whitelist";



  /**

   * @dev Throws if operator is not whitelisted.

   * @param _operator address

   */

  modifier onlyIfWhitelisted(address _operator) {

    checkRole(_operator, ROLE_WHITELISTED);

    _;

  }



  /**

   * @dev add an address to the whitelist

   * @param _operator address

   * @return true if the address was added to the whitelist, false if the address was already in the whitelist

   */

  function addAddressToWhitelist(address _operator)

    public

    onlyOwner

  {

    addRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev getter to determine if address is in whitelist

   */

  function whitelist(address _operator)

    public

    view

    returns (bool)

  {

    return hasRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev add addresses to the whitelist

   * @param _operators addresses

   * @return true if at least one address was added to the whitelist,

   * false if all addresses were already in the whitelist

   */

  function addAddressesToWhitelist(address[] _operators)

    public

    onlyOwner

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      addAddressToWhitelist(_operators[i]);

    }

  }



  /**

   * @dev remove an address from the whitelist

   * @param _operator address

   * @return true if the address was removed from the whitelist,

   * false if the address wasn't in the whitelist in the first place

   */

  function removeAddressFromWhitelist(address _operator)

    public

    onlyOwner

  {

    removeRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev remove addresses from the whitelist

   * @param _operators addresses

   * @return true if at least one address was removed from the whitelist,

   * false if all addresses weren't in the whitelist in the first place

   */

  function removeAddressesFromWhitelist(address[] _operators)

    public

    onlyOwner

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      removeAddressFromWhitelist(_operators[i]);

    }

  }

}



//WhitelistedCrowdsale.sol // openzeppelin-solidity

//import "./Crowdsale.sol";

//import "./Whitelist.sol";

/**

 * @title WhitelistedCrowdsale

 * @dev Crowdsale in which only whitelisted users can contribute.

 */

contract WhitelistedCrowdsale is Whitelist, Crowdsale {

  /**

   * @dev Extend parent behavior requiring beneficiary to be in whitelist.

   * @param _beneficiary Token beneficiary

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

    onlyIfWhitelisted(_beneficiary)

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



// CullCoinToken.sol // AB

//import './MintableToken.sol' // AB

contract CullCoinToken is MintableToken {

    string public name;

    string public symbol; 

    uint8 public decimals; 

  

  constructor(string _name, string _symbol, uint8 _decimals)

  

  MintableToken() public {

      name = _name; 

      symbol = _symbol; 

      decimals = _decimals; 

      owner = msg.sender; 

  }

 

}



//CullCoinCrowdsale // AB

//import './CullCoinToken.sol';

//import './MintedCrowdsale.sol';

//import './TimedCrowdsale.sol';

//import './WhitelistedCrowdsale.sol';

//import './Ownable.sol';

contract CullCoinCrowdsale is  TimedCrowdsale, MintedCrowdsale, WhitelistedCrowdsale  {

    constructor(

    uint256 _openingTime,

    uint256 _closingTime,

    address _wallet,

    uint256 _rate,

    MintableToken _token,

    uint256 _presaleEnds, 

    uint256 _bonus1Ends, 

    uint256 _bonus2Ends, 

    uint256 _bonus3Ends

    )

    

    public

    Crowdsale(_rate,_wallet, _token, _presaleEnds, _bonus1Ends, _bonus2Ends, _bonus3Ends)

    TimedCrowdsale(_openingTime, _closingTime)

    WhitelistedCrowdsale()

    {

    }

    

    //AB ethereum.stackexchange.com/questions/34184/transfer-ownership-of-a-token-contract

    function transferTokenOwnership(address _newOwner) public onlyOwner {

    require(msg.sender == owner); 

    token.transferOwnership(_newOwner);

    }

}
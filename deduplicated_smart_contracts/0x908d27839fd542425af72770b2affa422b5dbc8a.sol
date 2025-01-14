/**

 *Submitted for verification at Etherscan.io on 2019-05-09

*/



pragma solidity ^0.5.8;



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

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

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



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

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



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

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

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

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

   *

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

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint _addedValue

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

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    returns (bool)

  {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



contract ERC223ReceiverMixin {

  function tokenFallback(address _from, uint256 _value, bytes memory _data) public;

}



/// @title Custom implementation of ERC223 

/// @author Mai Abha <[email protected]>

contract ERC223Mixin is StandardToken {

  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);



  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  ) public returns (bool) 

  {

    bytes memory empty;

    return transferFrom(

      _from, 

      _to,

      _value,

      empty);

  }



  function transferFrom(

    address _from,

    address _to,

    uint256 _value,

    bytes memory _data

  ) public returns (bool)

  {

    require(_value <= allowed[_from][msg.sender], "Reached allowed value");

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    if (isContract(_to)) {

      return transferToContract(

        _from, 

        _to, 

        _value, 

        _data);

    } else {

      return transferToAddress(

        _from, 

        _to, 

        _value, 

        _data); 

    }

  }



  function transfer(address _to, uint256 _value, bytes memory _data) public returns (bool success) {

    if (isContract(_to)) {

      return transferToContract(

        msg.sender,

        _to,

        _value,

        _data); 

    } else {

      return transferToAddress(

        msg.sender,

        _to,

        _value,

        _data);

    }

  }



  function transfer(address _to, uint256 _value) public returns (bool success) {

    bytes memory empty;

    return transfer(_to, _value, empty);

  }



  function isContract(address _addr) internal view returns (bool) {

    uint256 length;

    // solium-disable-next-line security/no-inline-assembly

    assembly {

      //retrieve the size of the code on target address, this needs assembly

      length := extcodesize(_addr)

    }  

    return (length>0);

  }



  function moveTokens(address _from, address _to, uint256 _value) internal returns (bool success) {

    if (balanceOf(_from) < _value) {

      revert();

    }

    balances[_from] = balanceOf(_from).sub(_value);

    balances[_to] = balanceOf(_to).add(_value);



    return true;

  }



  function transferToAddress(

    address _from,

    address _to,

    uint256 _value,

    bytes memory _data

  ) internal returns (bool success) 

  {

    require(moveTokens(_from, _to, _value), "Move is not successful");

    emit Transfer(_from, _to, _value);

    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow

    return true;

  }

  

  //function that is called when transaction target is a contract

  function transferToContract(

    address _from,

    address _to,

    uint256 _value,

    bytes memory _data

  ) internal returns (bool success) 

  {

    require(moveTokens(_from, _to, _value), "Move is not successful");

    ERC223ReceiverMixin(_to).tokenFallback(_from, _value, _data);

    emit Transfer(_from, _to, _value);

    emit Transfer(_from, _to, _value, _data); // solium-disable-line arg-overflow

    return true;

  }

}



/// @title Role based access control mixin for Vinci Platform

/// @author Mai Abha <[email protected]>

/// @dev Ignore DRY approach to achieve readability

contract RBACMixin {

  /// @notice Constant string message to throw on lack of access

  string constant FORBIDDEN = "Doesn't have enough rights";

  string constant DUPLICATE = "Requirement already satisfied";



  /// @notice Public owner

  address public owner;



  /// @notice Public map of minters

  mapping (address => bool) public minters;



  /// @notice The event indicates a set of a new owner

  /// @param who is address of added owner

  event SetOwner(address indexed who);



  /// @notice The event indicates the addition of a new minter

  /// @param who is address of added minter

  event AddMinter(address indexed who);

  /// @notice The event indicates the deletion of a minter

  /// @param who is address of deleted minter

  event DeleteMinter(address indexed who);



  constructor () public {

    _setOwner(msg.sender);

  }



  /// @notice The functional modifier rejects the interaction of sender who is not an owner

  modifier onlyOwner() {

    require(isOwner(msg.sender), FORBIDDEN);

    _;

  }



  /// @notice Functional modifier for rejecting the interaction of senders that are not minters

  modifier onlyMinter() {

    require(isMinter(msg.sender), FORBIDDEN);

    _;

  }



  /// @notice Look up for the owner role on providen address

  /// @param _who is address to look up

  /// @return A boolean of owner role

  function isOwner(address _who) public view returns (bool) {

    return owner == _who;

  }



  /// @notice Look up for the minter role on providen address

  /// @param _who is address to look up

  /// @return A boolean of minter role

  function isMinter(address _who) public view returns (bool) {

    return minters[_who];

  }



  /// @notice Adds the owner role to provided address

  /// @dev Requires owner role to interact

  /// @param _who is address to add role

  /// @return A boolean that indicates if the operation was successful.

  function setOwner(address _who) public onlyOwner returns (bool) {

    require(_who != address(0));

    _setOwner(_who);

  }



  /// @notice Adds the minter role to provided address

  /// @dev Requires owner role to interact

  /// @param _who is address to add role

  /// @return A boolean that indicates if the operation was successful.

  function addMinter(address _who) public onlyOwner returns (bool) {

    _setMinter(_who, true);

  }



  /// @notice Deletes the minter role to provided address

  /// @dev Requires owner role to interact

  /// @param _who is address to delete role

  /// @return A boolean that indicates if the operation was successful.

  function deleteMinter(address _who) public onlyOwner returns (bool) {

    _setMinter(_who, false);

  }



  /// @notice Changes the owner role to provided address

  /// @param _who is address to change role

  /// @param _flag is next role status after success

  /// @return A boolean that indicates if the operation was successful.

  function _setOwner(address _who) private returns (bool) {

    require(owner != _who, DUPLICATE);

    owner = _who;

    emit SetOwner(_who);

    return true;

  }



  /// @notice Changes the minter role to provided address

  /// @param _who is address to change role

  /// @param _flag is next role status after success

  /// @return A boolean that indicates if the operation was successful.

  function _setMinter(address _who, bool _flag) private returns (bool) {

    require(minters[_who] != _flag, DUPLICATE);

    minters[_who] = _flag;

    if (_flag) {

      emit AddMinter(_who);

    } else {

      emit DeleteMinter(_who);

    }

    return true;

  }

}



contract RBACMintableTokenMixin is StandardToken, RBACMixin {

  /// @notice Total issued tokens

  uint256 totalIssued_;



  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;



  modifier canMint() {

    require(!mintingFinished, "Minting is finished");

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

    onlyMinter

    canMint

    public

    returns (bool)

  {

    totalIssued_ = totalIssued_.add(_amount);

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



/**

 * @title Standard Burnable Token

 * @dev Adds burnFrom method to ERC20 implementations

 */

contract StandardBurnableToken is BurnableToken, StandardToken {



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param _from address The address which you want to send tokens from

   * @param _value uint256 The amount of token to be burned

   */

  function burnFrom(address _from, uint256 _value) public {

    require(_value <= allowed[_from][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    _burn(_from, _value);

  }

}



/// @title Vinci token implementation

/// @author Mai Abha <[email protected]>

/// @dev Implements ERC20, ERC223 and MintableToken interfaces

contract VinciToken is StandardBurnableToken, RBACMintableTokenMixin, ERC223Mixin {

  /// @notice Constant field with token full name

  // solium-disable-next-line uppercase

  string constant public name = "Vinci"; 

  /// @notice Constant field with token symbol

  string constant public symbol = "VINCI"; // solium-disable-line uppercase

  /// @notice Constant field with token precision depth

  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /// @notice Constant field with token cap (total supply limit)

  uint256 constant public cap = 1500 * (10 ** 6) * (10 ** decimals); // solium-disable-line uppercase



  /// @notice Overrides original mint function from MintableToken to limit minting over cap

  /// @param _to The address that will receive the minted tokens.

  /// @param _amount The amount of tokens to mint.

  /// @return A boolean that indicates if the operation was successful.

  function mint(

    address _to,

    uint256 _amount

  )

    public

    returns (bool) 

  {

    require(totalIssued_.add(_amount) <= cap, "Cap is reached");

    return super.mint(_to, _amount);

  }

}



contract BasicMultisig {

  string constant ALREADY_EXECUTED = "Operation already executed";



  VinciToken public vinci_contract;  // address of the VinciToken contract



  /// @notice Public map of owners

  mapping (address => bool) public owners;

  /// @notice Public map of admins

  mapping (address => bool) public admins;



  /// @notice multisig owners counters

  mapping (uint => uint) public ownersConfirmations;

  /// @notice multisig admins counters

  mapping (uint => uint) public adminsConfirmations;



  mapping (uint => mapping (address => bool)) public ownersSigns;

  mapping (uint => mapping (address => bool)) public adminsSigns;



  /// @notice executed tasks to prevent multiple execution

  mapping (uint => bool) public executed;



  modifier manageable() {

    require(isOwner(msg.sender) || isAdmin(msg.sender), "You're not admin or owner");

    _;

  }



  modifier shouldNotBeAlreadyExecuted(uint _operation) {

    require(!executed[_operation], ALREADY_EXECUTED);

    _;

  }



  modifier increasesConfirmationsCounter(uint _operation) {

    increaseConfirmationsCounter(_operation);

    _;

  }



  function isOwner(address who) public view returns (bool) {

    return owners[who];

  }



  function isAdmin(address who) public view returns (bool) {

    return admins[who];

  }



  uint public operation = 0;



  /// @dev Fallback function: don't accept ETH

  function() external payable {

    revert();

  }



  // common method

  modifier createsNewOperation() {

    operation++;

    if (isOwner(msg.sender)) {

      ownersConfirmations[operation] = 1;

      adminsConfirmations[operation] = 0;

      ownersSigns[operation][msg.sender] = true;

    } else {

      if (isAdmin(msg.sender)) {

        ownersConfirmations[operation] = 0;

        adminsConfirmations[operation] = 1;

        adminsSigns[operation][msg.sender] = true;

      }

    }

    _;

  }



  function increaseConfirmationsCounter(uint _operation) internal {

    if (isOwner(msg.sender)) {

      if (ownersSigns[_operation][msg.sender]) revert();

      ownersConfirmations[_operation] += 1;

    } else {

      if (isAdmin(msg.sender)) {

        if (adminsSigns[_operation][msg.sender]) revert();

        adminsConfirmations[_operation] += 1;

      }

    }

  }



  function enoughConfirmations(uint _operation) public view returns (bool) {

    uint totalConfirmations = ownersConfirmations[_operation] + adminsConfirmations[_operation];

    return ((ownersConfirmations[_operation] > 0) && (totalConfirmations > 2));

  }

  //

}



contract SetOwnerMultisig is BasicMultisig {

  struct SetOwnerParams { address who; }



  mapping (uint => SetOwnerParams) public setOwnerOperations;





  // EVENTS

  event setOwnerAction(uint operation, address indexed who);

  event setOwnerConfirmation(uint operation, address indexed who, uint ownersConfirmations, uint adminsConfirmations);





  function setOwner(address who) public manageable

                                 createsNewOperation

                                 returns (uint) {



    setOwnerOperations[operation] = SetOwnerParams(who);



    emit setOwnerAction(operation, who);

    return operation;

  }



  function setOwnerConfirm(uint _operation) public manageable

                                            shouldNotBeAlreadyExecuted(_operation)

                                            increasesConfirmationsCounter(_operation)

                                            returns (bool) {

    if (enoughConfirmations(_operation)){

      vinci_contract.setOwner(setOwnerOperations[_operation].who);

      executed[_operation] = true;

    }



    emit setOwnerConfirmation(_operation,

                              setOwnerOperations[_operation].who,

                              ownersConfirmations[_operation],

                              adminsConfirmations[_operation]);

  }

}



contract DeleteMinterMultisig is BasicMultisig {

  struct DeleteMinterParams { address who; }



  mapping (uint => DeleteMinterParams) public deleteMinterOperations;





  // EVENTS

  event deleteMinterAction(uint operation, address indexed who);



  event deleteMinterConfirmation(uint operation,

                                 address indexed who,

                                 uint ownersConfirmations,

                                 uint adminsConfirmations);





  function deleteMinter(address who) public manageable

                                    createsNewOperation

                                    returns (uint) {



    deleteMinterOperations[operation] = DeleteMinterParams(who);



    emit deleteMinterAction(operation, who);

    return operation;

  }



  function deleteMinterConfirm(uint _operation) public manageable

                                                shouldNotBeAlreadyExecuted(_operation)

                                                increasesConfirmationsCounter(_operation)

                                                returns (bool) {

    if (enoughConfirmations(_operation)){

      vinci_contract.deleteMinter(deleteMinterOperations[_operation].who);

      executed[_operation] = true;

    }



    emit deleteMinterConfirmation(_operation,

                                 deleteMinterOperations[_operation].who,

                                 ownersConfirmations[_operation],

                                 adminsConfirmations[_operation]);

  }

}



contract AddMinterMultisig is BasicMultisig {

  struct AddMinterParams { address who; }



  mapping (uint => AddMinterParams) public addMinterOperations;





  // EVENTS

  event addMinterAction(uint operation, address indexed who);



  event addMinterConfirmation(uint operation,

                              address indexed who,

                              uint ownersConfirmations,

                              uint adminsConfirmations);





  function addMinter(address who) public manageable

                                  createsNewOperation

                                  returns (uint) {



    addMinterOperations[operation] = AddMinterParams(who);



    emit addMinterAction(operation, who);

    return operation;

  }



  function addMinterConfirm(uint _operation) public manageable

                                             shouldNotBeAlreadyExecuted(_operation)

                                             increasesConfirmationsCounter(_operation)

                                             returns (bool) {



    if (enoughConfirmations(_operation)){

      vinci_contract.addMinter(addMinterOperations[_operation].who);

      executed[_operation] = true;

    }



    emit addMinterConfirmation(_operation,

                               addMinterOperations[_operation].who,

                               ownersConfirmations[_operation],

                               adminsConfirmations[_operation]);

  }

}



contract MintMultisig is BasicMultisig {

  struct MintParams { address to; uint256 amount; }



  mapping (uint => MintParams) public mintOperations;





  // EVENTS

  event mintAction(uint operation,

                   address indexed to,

                   uint256 amount);



  event mintConfirmation(uint operation,

                         address indexed to,

                         uint256 amount,

                         uint ownersConfirmations,

                         uint adminsConfirmations);





  function mint(address to, uint256 amount) public manageable

                             createsNewOperation

                             returns (uint) {



    mintOperations[operation] = MintParams(to, amount);



    emit mintAction(operation, to, amount);

    return operation;

  }



  function mintConfirm(uint _operation) public manageable

                                        shouldNotBeAlreadyExecuted(_operation)

                                        increasesConfirmationsCounter(_operation)

                                        returns (bool) {

    if (enoughConfirmations(_operation)){

      vinci_contract.mint(mintOperations[_operation].to, mintOperations[_operation].amount);

      executed[_operation] = true;

    }



    emit mintConfirmation(_operation,

                          mintOperations[_operation].to,

                          mintOperations[_operation].amount,

                          ownersConfirmations[_operation],

                          adminsConfirmations[_operation]);

  }

}



contract FinishMintingMultisig is BasicMultisig {

  // EVENTS

  event finishMintingAction(uint operation);



  event finishMintingConfirmation(uint operation,

                                  uint ownersConfirmations,

                                  uint adminsConfirmations);





  function finishMinting() public manageable

                           createsNewOperation

                           returns (uint) {



    emit finishMintingAction(operation);

    return operation;

  }



  function finishMintingConfirm(uint _operation) public manageable

                                                 shouldNotBeAlreadyExecuted(_operation)

                                                 increasesConfirmationsCounter(_operation)

                                                 returns (bool) {

    if (enoughConfirmations(_operation)){

      vinci_contract.finishMinting();

      executed[_operation] = true;

    }



    emit finishMintingConfirmation(_operation,

                                   ownersConfirmations[_operation],

                                   adminsConfirmations[_operation]);

  }

}



contract Multisig is SetOwnerMultisig,



                     AddMinterMultisig,

                     DeleteMinterMultisig,



                     MintMultisig,

                     FinishMintingMultisig {



  constructor(VinciToken _vinci_contract) public {

    vinci_contract = _vinci_contract;



    owners[0x22e936f4a00ABc4120208D7E8EF9f76d3555Cb05] = true;

    owners[0x95a06E0B6F94A6Cbae49317ED0c87056Eb8494e8] = true;



    admins[0x020748bFeB4E877125ABa9A1D283d41A48f12584] = true;

    admins[0xED182c9CE936C541599A049570DD7EEFE06387e9] = true;

    admins[0x2ef7AC759F06509535750403663278cc22FDaEF1] = true;

    admins[0x27481f1D81F8B6eff5860c43111acFEc6A8C5290] = true;

  }

}
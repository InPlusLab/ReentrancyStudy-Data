/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.24;





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





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable is Initializable {

  address private _owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function initialize(address sender) public initializer {

    _owner = sender;

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

    emit OwnershipRenounced(_owner);

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



  uint256[50] private ______gap;

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





/**

 * @title Basic TPL Jurisdiction Interface.

 */

interface BasicJurisdictionInterface {

  // declare events

  event AttributeTypeAdded(uint256 indexed attributeTypeID, string description);

  

  event AttributeTypeRemoved(uint256 indexed attributeTypeID);

  

  event ValidatorAdded(address indexed validator, string description);

  

  event ValidatorRemoved(address indexed validator);

  

  event ValidatorApprovalAdded(

    address validator,

    uint256 indexed attributeTypeID

  );



  event ValidatorApprovalRemoved(

    address validator,

    uint256 indexed attributeTypeID

  );



  event AttributeAdded(

    address validator,

    address indexed attributee,

    uint256 attributeTypeID,

    uint256 attributeValue

  );



  event AttributeRemoved(

    address validator,

    address indexed attributee,

    uint256 attributeTypeID

  );



  /**

  * @notice Add an attribute type with ID `ID` and description `description` to

  * the jurisdiction.

  * @param ID uint256 The ID of the attribute type to add.

  * @param description string A description of the attribute type.

  * @dev Once an attribute type is added with a given ID, the description of the

  * attribute type cannot be changed, even if the attribute type is removed and

  * added back later.

  */

  function addAttributeType(uint256 ID, string description) external;



  /**

  * @notice Remove the attribute type with ID `ID` from the jurisdiction.

  * @param ID uint256 The ID of the attribute type to remove.

  * @dev All issued attributes of the given type will become invalid upon

  * removal, but will become valid again if the attribute is reinstated.

  */

  function removeAttributeType(uint256 ID) external;



  /**

  * @notice Add account `validator` as a validator with a description

  * `description` who can be approved to set attributes of specific types.

  * @param validator address The account to assign as the validator.

  * @param description string A description of the validator.

  * @dev Note that the jurisdiction can add iteslf as a validator if desired.

  */

  function addValidator(address validator, string description) external;



  /**

  * @notice Remove the validator at address `validator` from the jurisdiction.

  * @param validator address The account of the validator to remove.

  * @dev Any attributes issued by the validator will become invalid upon their

  * removal. If the validator is reinstated, those attributes will become valid

  * again. Any approvals to issue attributes of a given type will need to be

  * set from scratch in the event a validator is reinstated.

  */

  function removeValidator(address validator) external;



  /**

  * @notice Approve the validator at address `validator` to issue attributes of

  * the type with ID `attributeTypeID`.

  * @param validator address The account of the validator to approve.

  * @param attributeTypeID uint256 The ID of the approved attribute type.

  */

  function addValidatorApproval(

    address validator,

    uint256 attributeTypeID

  ) external;



  /**

  * @notice Deny the validator at address `validator` the ability to continue to

  * issue attributes of the type with ID `attributeTypeID`.

  * @param validator address The account of the validator with removed approval.

  * @param attributeTypeID uint256 The ID of the attribute type to unapprove.

  * @dev Any attributes of the specified type issued by the validator in

  * question will become invalid once the approval is removed. If the approval

  * is reinstated, those attributes will become valid again. The approval will

  * also be removed if the approved validator is removed.

  */

  function removeValidatorApproval(

    address validator,

    uint256 attributeTypeID

  ) external;



  /**

  * @notice Issue an attribute of the type with ID `attributeTypeID` and a value

  * of `value` to `account` if `message.caller.address()` is approved validator.

  * @param account address The account to issue the attribute on.

  * @param attributeTypeID uint256 The ID of the attribute type to issue.

  * @param value uint256 An optional value for the issued attribute.

  * @dev Existing attributes of the given type on the address must be removed

  * in order to set a new attribute. Be aware that ownership of the account to

  * which the attribute is assigned may still be transferable - restricting

  * assignment to externally-owned accounts may partially alleviate this issue.

  */

  function issueAttribute(

    address account,

    uint256 attributeTypeID,

    uint256 value

  ) external payable;



  /**

  * @notice Revoke the attribute of the type with ID `attributeTypeID` from

  * `account` if `message.caller.address()` is the issuing validator.

  * @param account address The account to issue the attribute on.

  * @param attributeTypeID uint256 The ID of the attribute type to issue.

  * @dev Validators may still revoke issued attributes even after they have been

  * removed or had their approval to issue the attribute type removed - this

  * enables them to address any objectionable issuances before being reinstated.

  */

  function revokeAttribute(

    address account,

    uint256 attributeTypeID

  ) external;



  /**

   * @notice Determine if a validator at account `validator` is able to issue

   * attributes of the type with ID `attributeTypeID`.

   * @param validator address The account of the validator.

   * @param attributeTypeID uint256 The ID of the attribute type to check.

   * @return True if the validator can issue attributes of the given type, false

   * otherwise.

   */

  function canIssueAttributeType(

    address validator,

    uint256 attributeTypeID

  ) external view returns (bool);



  /**

   * @notice Get a description of the attribute type with ID `attributeTypeID`.

   * @param attributeTypeID uint256 The ID of the attribute type to check for.

   * @return A description of the attribute type.

   */

  function getAttributeTypeInformation(

    uint256 attributeTypeID

  ) external view returns (string description);

  

  /**

   * @notice Get a description of the validator at account `validator`.

   * @param validator address The account of the validator in question.

   * @return A description of the validator.

   */

  function getValidatorInformation(

    address validator

  ) external view returns (string description);



  /**

   * @notice Find the validator that issued the attribute of the type with ID

   * `attributeTypeID` on the account at `account` and determine if the

   * validator is still valid.

   * @param account address The account that contains the attribute be checked.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return The validator and the current status of the validator as it

   * pertains to the attribute type in question.

   * @dev if no attribute of the given attribute type exists on the account, the

   * function will return (address(0), false).

   */

  function getAttributeValidator(

    address account,

    uint256 attributeTypeID

  ) external view returns (address validator, bool isStillValid);



  /**

   * @notice Count the number of attribute types defined by the jurisdiction.

   * @return The number of available attribute types.

   */

  function countAttributeTypes() external view returns (uint256);



  /**

   * @notice Get the ID of the attribute type at index `index`.

   * @param index uint256 The index of the attribute type in question.

   * @return The ID of the attribute type.

   */

  function getAttributeTypeID(uint256 index) external view returns (uint256);



  /**

   * @notice Get the IDs of all available attribute types on the jurisdiction.

   * @return A dynamic array containing all available attribute type IDs.

   */

  function getAttributeTypeIDs() external view returns (uint256[]);



  /**

   * @notice Count the number of validators defined by the jurisdiction.

   * @return The number of defined validators.

   */

  function countValidators() external view returns (uint256);



  /**

   * @notice Get the account of the validator at index `index`.

   * @param index uint256 The index of the validator in question.

   * @return The account of the validator.

   */

  function getValidator(uint256 index) external view returns (address);



  /**

   * @notice Get the accounts of all available validators on the jurisdiction.

   * @return A dynamic array containing all available validator accounts.

   */

  function getValidators() external view returns (address[]);

}





/**

 * @title Organizations validator contract .

 */

contract OrganizationsValidator is Initializable, Ownable, Pausable {

  // declare events

  event OrganizationAdded(address organization, string name);

  

  event AttributeIssued(

    address indexed organization,

    address attributee

  );

  

  event AttributeRevoked(

    address indexed organization,

    address attributee

  );

  

  event IssuancePaused();

  

  event IssuanceUnpaused();



  // declare registry interface, used to request attributes from a jurisdiction

  AttributeRegistryInterface private _registry;



  // declare jurisdiction interface, used to set attributes in the jurisdiction

  BasicJurisdictionInterface private _jurisdiction;



  // declare the attribute ID required by the validator in order to transfer tokens

  uint256 private _validAttributeTypeID;



  // organizations are entities who can add attibutes to a number of accounts

  struct Organization {

    bool exists;

    uint256 maximumAccounts; // NOTE: consider using uint248 to pack w/ exists

    string name;

    address[] accounts;

    mapping(address => bool) issuedAccounts;

    mapping(address => uint256) issuedAccountsIndex;

  }



  // organization data & issued attribute accounts are held in a struct mapping

  mapping(address => Organization) private _organizations;



  // accounts of all organizations are held in an array (enables enumeration)

  address[] private _organizationAccounts;



  // issuance of new attributes may be paused and unpaused by the validator.

  bool private _issuancePaused;



  /**

  * @notice Add an organization at account `organization` and with an initial

  * allocation of issuable attributes of `maximumIssuableAttributes`.

  * @param organization address The account to assign to the organization.  

  * @param maximumIssuableAttributes uint256 The number of issuable accounts.

  */

  function addOrganization(

    address organization,

    uint256 maximumIssuableAttributes,

    string name

  ) external onlyOwner whenNotPaused {

    // check that an empty account was not provided by mistake

    require(organization != address(0), "must supply a valid account address");



    // prevent existing organizations from being overwritten

    require(

      _organizations[organization].exists == false,

      "an organization already exists at the provided account address"

    );



    // set up the organization in the organizations mapping

    _organizations[organization].exists = true;

    _organizations[organization].maximumAccounts = maximumIssuableAttributes;

    _organizations[organization].name = name;

    

    // add the organization to the end of the organizationAccounts array

    _organizationAccounts.push(organization);



    // log the addition of the organization

    emit OrganizationAdded(organization, name);

  }



  /**

  * @notice Modify an organization at account `organization` to change the

  * number of issuable attributes to `maximumIssuableAttributes`.

  * @param organization address The account assigned to the organization.  

  * @param maximumIssuableAttributes uint256 The number of issuable attributes.

  * @dev Note that the maximum number of accounts cannot currently be set to a

  * value less than the current number of issued accounts. This feature, coupled

  * with the ability to revoke attributes, will *prevent an organization from

  * being 'frozen' since the organization can remove an address and then add an

  * arbitrary address in its place. Options to address this include a dedicated

  * method for freezing organizations, or a special exception to the requirement

  * below that allows the maximum to be set to 0 which will achieve the intended

  * effect.

  */

  function setMaximumIssuableAttributes(

    address organization,

    uint256 maximumIssuableAttributes

  ) external onlyOwner whenNotPaused {

    require(

      _organizations[organization].exists == true,

      "an organization does not exist at the provided account address"

    );



    // make sure that maximum is not set below the current number of addresses

    require(

      _organizations[organization].accounts.length <= maximumIssuableAttributes,

      "maximum cannot be set to amounts less than the current account total"

    );



    // set the organization's maximum addresses; a value == current freezes them

    _organizations[organization].maximumAccounts = maximumIssuableAttributes;

  }



  /**

  * @notice Add an attribute to account `account`.

  * @param account address The account to issue the attribute to.  

  * @dev This function would need to be made payable to support jurisdictions

  * that require fees in order to set attributes.

  */

  function issueAttribute(

    address account

  ) external whenNotPaused whenIssuanceNotPaused {

    // check that an empty address was not provided by mistake

    require(account != address(0), "must supply a valid account address");



    // make sure the request is coming from a valid organization

    require(

      _organizations[msg.sender].exists == true,

      "only organizations may issue attributes"

    );



    // ensure that the maximum has not been reached yet

    uint256 maximum = uint256(_organizations[msg.sender].maximumAccounts);

    require(

      _organizations[msg.sender].accounts.length < maximum,

      "the organization is not permitted to issue any additional attributes"

    );

 

    // assign the attribute to the jurisdiction (NOTE: a value is not required)

    _jurisdiction.issueAttribute(account, _validAttributeTypeID, 0);



    // ensure that the attribute was correctly assigned

    require(

      _registry.hasAttribute(account, _validAttributeTypeID) == true,

      "attribute addition was not accepted by the jurisdiction"

    );



    // add the account to the mapping of issued accounts

    _organizations[msg.sender].issuedAccounts[account] = true;



    // add the index of the account to the mapping of issued accounts

    uint256 index = _organizations[msg.sender].accounts.length;

    _organizations[msg.sender].issuedAccountsIndex[account] = index;



    // add the address to the end of the organization's `accounts` array

    _organizations[msg.sender].accounts.push(account);

    

    // log the addition of the new attributed account

    emit AttributeIssued(msg.sender, account);

  }



  /**

  * @notice Revoke an attribute from account `account`.

  * @param account address The account to revoke the attribute from.  

  * @dev Organizations may still revoke attributes even after new issuance has

  * been paused. This is the intended behavior, as it allows them to correct

  * attributes they have issued that become compromised or otherwise erroneous.

  */

  function revokeAttribute(address account) external whenNotPaused {

    // check that an empty address was not provided by mistake

    require(account != address(0), "must supply a valid account address");



    // make sure the request is coming from a valid organization

    require(

      _organizations[msg.sender].exists == true,

      "only organizations may revoke attributes"

    );



    // ensure that the account has been issued an attribute

    require(

      _organizations[msg.sender].issuedAccounts[account] &&

      _organizations[msg.sender].accounts.length > 0,

      "the organization is not permitted to revoke an unissued attribute"

    );

 

    // remove the attribute from the jurisdiction

    _jurisdiction.revokeAttribute(account, _validAttributeTypeID);



    // ensure that the attribute was correctly removed

    require(

      _registry.hasAttribute(account, _validAttributeTypeID) == false,

      "attribute revocation was not accepted by the jurisdiction"

    );



    // get the account at the last index of the array

    uint256 lastIndex = _organizations[msg.sender].accounts.length - 1;

    address lastAccount = _organizations[msg.sender].accounts[lastIndex];



    // get the index to delete

    uint256 indexToDelete = _organizations[msg.sender].issuedAccountsIndex[account];



    // set the account at indexToDelete to last account

    _organizations[msg.sender].accounts[indexToDelete] = lastAccount;



    // update the index of the account that was moved

    _organizations[msg.sender].issuedAccountsIndex[lastAccount] = indexToDelete;

    

    // remove the (now duplicate) account at the end by trimming the array

    _organizations[msg.sender].accounts.length--;



    // remove the account from the organization's issuedAccounts mapping as well

    delete _organizations[msg.sender].issuedAccounts[account];

    

    // log the addition of the new attributed account

    emit AttributeRevoked(msg.sender, account);

  }



  /**

   * @notice Count the number of organizations defined by the validator.

   * @return The number of defined organizations.

   */

  function countOrganizations() external view returns (uint256) {

    return _organizationAccounts.length;

  }



  /**

   * @notice Get the account of the organization at index `index`.

   * @param index uint256 The index of the organization in question.

   * @return The account of the organization.

   */

  function getOrganization(uint256 index) external view returns (

    address organization

  ) {

    return _organizationAccounts[index];

  }



  /**

   * @notice Get the accounts of all available organizations.

   * @return A dynamic array containing all defined organization accounts.

   */

  function getOrganizations() external view returns (address[] accounts) {

    return _organizationAccounts;

  }



  /**

   * @notice Get information about the organization at account `account`.

   * @param organization address The account of the organization in question.

   * @return The organization's existence, the maximum issuable accounts, the

   * name of the organization, and a dynamic array containing issued accounts.

   * @dev Note that an organization issuing numerous attributes may cause the

   * function to fail, as the dynamic array could grow beyond a returnable size.

   */

  function getOrganizationInformation(

    address organization

  ) external view returns (

    bool exists,

    uint256 maximumAccounts,

    string name,

    address[] issuedAccounts

  ) {

    return (

      _organizations[organization].exists,

      _organizations[organization].maximumAccounts,

      _organizations[organization].name,

      _organizations[organization].accounts

    );

  }



  /**

   * @notice Get the account of the utilized jurisdiction.

   * @return The account of the jurisdiction.

   */

  function getJurisdiction() external view returns (address) {

    return address(_jurisdiction);

  }



  /**

   * @notice Get the ID of the attribute type that the validator can issue.

   * @return The ID of the attribute type.

   */

  function getValidAttributeTypeID() external view returns (uint256) {

    return _validAttributeTypeID;

  }



  /**

  * @notice The initializer function for the OrganizationsValidator,

  * with owner and pauser roles initially assigned to contract creator,

  * and with an associated jurisdiction at `jurisdiction` and an assignable

  * attribute type with ID `validAttributeTypeID`.

  * @param jurisdiction address The account of the associated jurisdiction.  

  * @param validAttributeTypeID uint256 The ID of the attribute type to issue.

  * @param sender address The account to be set as pauser and owner of the contract.

  * @dev Note that it may be appropriate to require that the referenced

  * jurisdiction supports the correct interface via EIP-165 and that the

  * validator has been approved to issue attributes of the specified type when

  * initializing the contract - it is not currently required.

  */

  function initialize(

    address jurisdiction,

    uint256 validAttributeTypeID,

    address sender

  )

    public

    initializer

  {

    Ownable.initialize(sender);

    Pausable.initialize(sender);

    _issuancePaused = false;

    _registry = AttributeRegistryInterface(jurisdiction);

    _jurisdiction = BasicJurisdictionInterface(jurisdiction);

    _validAttributeTypeID = validAttributeTypeID;

  }



  /**

   * @notice Pause all issuance of new attributes by organizations.

   */

  function pauseIssuance() public onlyOwner whenNotPaused whenIssuanceNotPaused {

    _issuancePaused = true;

    emit IssuancePaused();

  }



  /**

   * @notice Unpause issuance of new attributes by organizations.

   */

  function unpauseIssuance() public onlyOwner whenNotPaused {

    require(_issuancePaused); // only allow unpausing when issuance is paused

    _issuancePaused = false;

    emit IssuanceUnpaused();

  }



  /**

   * @notice Determine if attribute issuance is currently paused.

   * @return True if issuance is currently paused, false otherwise.

   */

  function issuanceIsPaused() public view returns (bool) {

    return _issuancePaused;

  }



  /**

   * @notice Modifier to allow issuing attributes only when not paused

   */

  modifier whenIssuanceNotPaused() {

    require(!_issuancePaused);

    _;

  }

}
/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity 0.4.25;





/*************** TPL Crypto Copycats Cooperative (CCC) - Devcon4 **************

 * Use at your own risk, these contracts are experimental and lightly tested! *

 * Documentation & tests at https://github.com/TPL-protocol/tpl-contracts     *

 * Implements an Attribute Registry https://github.com/0age/AttributeRegistry *

 *                                                                            *

 * Source layout:                                    Line #                   *

 *  - interface AttributeRegistryInterface             25                     *

 *  - interface TPLBasicValidatorInterface             79                     *

 *  - interface BasicJurisdictionInterface            132                     *

 *  - contract TPLBasicValidator                      350                     *

 *    - is TPLBasicValidatorInterface                                         *

 *  - contract CryptoCopycatsCooperative              516                     *

 *    - is TPLBasicValidator                                                  *

 *                                                                            *

 *   https://github.com/TPL-protocol/tpl-contracts/blob/master/LICENSE.md     *

 ******************************************************************************/





/**

 * @title Attribute Registry interface. EIP-165 ID: 0x5f46473f

 */

interface AttributeRegistryInterface {

  /**

   * @notice Check if an attribute of the type with ID `attributeTypeID` has

   * been assigned to the account at `account` and is currently valid.

   * @param account address The account to check for a valid attribute.

   * @param attributeTypeID uint256 The ID of the attribute type to check for.

   * @return True if the attribute is assigned and valid, false otherwise.

   * @dev This function MUST return either true or false - i.e. calling this

   * function MUST NOT cause the caller to revert.

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

   * @dev This function MUST revert if a directly preceding or subsequent

   * function call to `hasAttribute` with identical `account` and

   * `attributeTypeID` parameters would return false.

   */

  function getAttributeValue(

    address account,

    uint256 attributeTypeID

  ) external view returns (uint256);



  /**

   * @notice Count the number of attribute types defined by the registry.

   * @return The number of available attribute types.

   * @dev This function MUST return a positive integer value  - i.e. calling

   * this function MUST NOT cause the caller to revert.

   */

  function countAttributeTypes() external view returns (uint256);



  /**

   * @notice Get the ID of the attribute type at index `index`.

   * @param index uint256 The index of the attribute type in question.

   * @return The ID of the attribute type.

   * @dev This function MUST revert if the provided `index` value falls outside

   * of the range of the value returned from a directly preceding or subsequent

   * function call to `countAttributeTypes`. It MUST NOT revert if the provided

   * `index` value falls inside said range.

   */

  function getAttributeTypeID(uint256 index) external view returns (uint256);

}





/**

 * @title TPL Basic Validator interface. EIP-165 ID: 0xa1833e9a

 */

interface TPLBasicValidatorInterface {

  /**

   * @notice Check if contract is assigned as a validator on the jurisdiction.

   * @return True if validator is assigned, false otherwise.

   */  

  function isValidator() external view returns (bool);



  /**

   * @notice Check if the validator is approved to issue attributes of the type

   * with ID `attributeTypeID` on the jurisdiction.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return True if validator is approved to issue attributes of given type.

   */  

  function canIssueAttributeType(

    uint256 attributeTypeID

  ) external view returns (bool);



  /**

   * @notice Check if the validator is approved to issue an attribute of the

   * type with ID `attributeTypeID` to account `account` on the jurisdiction.

   * @param account address The account to check for issuing the attribute to.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return Bool indicating if attribute is issuable & byte with status code.

   */  

  function canIssueAttribute(

    address account,

    uint256 attributeTypeID

  ) external view returns (bool, bytes1);



  /**

   * @notice Check if the validator is approved to revoke an attribute of the

   * type with ID `attributeTypeID` from account `account` on the jurisdiction.

   * @param account address The checked account for revoking the attribute from.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return Bool indicating if attribute is revocable & byte with status code.

   */  

  function canRevokeAttribute(

    address account,

    uint256 attributeTypeID

  ) external view returns (bool, bytes1);



  /**

   * @notice Get account of utilized jurisdiction and associated attribute

   * registry managed by the jurisdiction.

   * @return The account of the jurisdiction.

   */

  function getJurisdiction() external view returns (address);

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

  function getAttributeTypeDescription(

    uint256 attributeTypeID

  ) external view returns (string description);

  

  /**

   * @notice Get a description of the validator at account `validator`.

   * @param validator address The account of the validator in question.

   * @return A description of the validator.

   */

  function getValidatorDescription(

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

 * @title An instance of TPLBasicValidator, issue & revoke an attribute type.

 */

contract TPLBasicValidator is TPLBasicValidatorInterface {



  // declare registry interface, used to request attributes from a jurisdiction

  AttributeRegistryInterface internal _registry;



  // declare registry interface, set to same address as the registry

  BasicJurisdictionInterface internal _jurisdiction;



  // declare attribute ID required in order to receive transferred tokens

  uint256 internal _validAttributeTypeID;



  /**

  * @notice The constructor function, with an associated attribute registry at

  * `registry` and an assignable attribute type with ID `validAttributeTypeID`.

  * @param registry address The account of the associated attribute registry.  

  * @param validAttributeTypeID uint256 The ID of the required attribute type.

  * @dev Note that it may be appropriate to require that the referenced

  * attribute registry supports the correct interface via EIP-165.

  */

  constructor(

    AttributeRegistryInterface registry,

    uint256 validAttributeTypeID

  ) public {

    _registry = AttributeRegistryInterface(registry);

    _jurisdiction = BasicJurisdictionInterface(registry);

    _validAttributeTypeID = validAttributeTypeID;

  }



  /**

   * @notice Check if contract is assigned as a validator on the jurisdiction.

   * @return True if validator is assigned, false otherwise.

   */  

  function isValidator() external view returns (bool) {

    uint256 totalValidators = _jurisdiction.countValidators();

    

    for (uint256 i = 0; i < totalValidators; i++) {

      address validator = _jurisdiction.getValidator(i);

      if (validator == address(this)) {

        return true;

      }

    }



    return false;

  }



  /**

   * @notice Check if the validator is approved to issue attributes of the type

   * with ID `attributeTypeID` on the jurisdiction.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return True if validator is approved to issue attributes of given type.

   */  

  function canIssueAttributeType(

    uint256 attributeTypeID

  ) external view returns (bool) {

    return (

      _validAttributeTypeID == attributeTypeID &&

      _jurisdiction.canIssueAttributeType(address(this), _validAttributeTypeID)

    );

  }



  /**

   * @notice Check if the validator is approved to issue an attribute of the

   * type with ID `attributeTypeID` to account `account` on the jurisdiction.

   * @param account address The account to check for issuing the attribute to.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return Bool indicating if attribute is issuable & byte with status code.

   * @dev This function could definitely use additional checks and error codes.

   */  

  function canIssueAttribute(

    address account,

    uint256 attributeTypeID

  ) external view returns (bool, bytes1) {

    // Only the predefined attribute type can be issued by this validator.

    if (_validAttributeTypeID != attributeTypeID) {

      return (false, hex"A0");

    }



    // Attributes can't be issued if one already exists on the given account.

    if (_registry.hasAttribute(account, _validAttributeTypeID)) {

      return (false, hex"B0");

    }



    return (true, hex"01");

  }



  /**

   * @notice Check if the validator is approved to revoke an attribute of the

   * type with ID `attributeTypeID` from account `account` on the jurisdiction.

   * @param account address The checked account for revoking the attribute from.

   * @param attributeTypeID uint256 The ID of the attribute type in question.

   * @return Bool indicating if attribute is revocable & byte with status code.

   * @dev This function could definitely use additional checks and error codes.

   */  

  function canRevokeAttribute(

    address account,

    uint256 attributeTypeID

  ) external view returns (bool, bytes1) {

    // Only the predefined attribute type can be revoked by this validator.

    if (_validAttributeTypeID != attributeTypeID) {

      return (false, hex"A0");

    }



    // Attributes can't be revoked if they don't exist on the given account.

    if (!_registry.hasAttribute(account, _validAttributeTypeID)) {

      return (false, hex"B0");

    }



    // Only the issuing validator can revoke an attribute.

    (address validator, bool unused) = _jurisdiction.getAttributeValidator(

      account,

      _validAttributeTypeID

    );

    unused;



    if (validator != address(this)) {

      return (false, hex"C0");

    }    



    return (true, hex"01");

  }



  /**

   * @notice Get the ID of the attribute type required to hold tokens.

   * @return The ID of the required attribute type.

   */

  function getValidAttributeID() external view returns (uint256) {

    return _validAttributeTypeID;

  }



  /**

   * @notice Get account of utilized jurisdiction and associated attribute

   * registry managed by the jurisdiction.

   * @return The account of the jurisdiction.

   */

  function getJurisdiction() external view returns (address) {

    return address(_jurisdiction);

  }



  /**

   * @notice Issue an attribute of the type with the default ID to account

   * `account` on the jurisdiction. Values are left at zero.

   * @param account address The account to issue the attribute to.

   * @return True if attribute has been successfully issued, false otherwise.

   */  

  function _issueAttribute(address account) internal returns (bool) {

    _jurisdiction.issueAttribute(account, _validAttributeTypeID, 0);

    return true;

  }



  /**

   * @notice Revoke an attribute of the type with ID `attributeTypeID` from

   * account `account` on the jurisdiction.

   * @param account address The account to revoke the attribute from.

   * @return True if attribute has been successfully revoked, false otherwise.

   */  

  function _revokeAttribute(address account) internal returns (bool) {

    _jurisdiction.revokeAttribute(account, _validAttributeTypeID);

    return true;

  }

}





/**

 * @title An instance of TPLBasicValidator with external functions to add and

 * revoke attributes.

 */

contract CryptoCopycatsCooperative is TPLBasicValidator {



  string public name = "Crypto Copycats Cooperative";



  mapping(address => bool) private _careCoordinator;



  /**

  * @notice The constructor function, with an associated attribute registry at

  * `registry` and an assignable attribute type with ID `validAttributeTypeID`.

  * @param registry address The account of the associated attribute registry.  

  * @param validAttributeTypeID uint256 The ID of the required attribute type.

  * @dev Note that it may be appropriate to require that the referenced

  * attribute registry supports the correct interface via EIP-165.

  */

  constructor(

    AttributeRegistryInterface registry,

    uint256 validAttributeTypeID

  ) public TPLBasicValidator(registry, validAttributeTypeID) {

    _careCoordinator[msg.sender] = true;

  }



  modifier onlyCareCoordinators() {

    require(

      _careCoordinator[msg.sender],

      "This method may only be called by a care coordinator."

    );

    _;

  }



  function addCareCoordinator(address account) external onlyCareCoordinators {

    _careCoordinator[account] = true;

  }



  /**

   * @notice Issue an attribute of the type with the default ID to `msg.sender`

   * on the jurisdiction. Values are left at zero.

   */  

  function issueAttribute(

    bool doYouLoveCats,

    bool doYouLoveDogsMoreThanCats,

    bool areYouACrazyCatLady

  ) external {

    require(doYouLoveCats, "only cat lovers allowed");

    require(doYouLoveDogsMoreThanCats, "no liars allowed");

    require(!areYouACrazyCatLady, "we are very particular");

    require(_issueAttribute(msg.sender));

  }



  /**

   * @notice Revoke an attribute from the type with the default ID from

   * `msg.sender` on the jurisdiction.

   */  

  function revokeAttribute(address account) external onlyCareCoordinators {

    require(_revokeAttribute(account));

  }

}
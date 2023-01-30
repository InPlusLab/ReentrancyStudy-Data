/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

pragma solidity ^0.5.0;


/**
 * @dev Implementation of the `IERC165` interface.
 *
 * Contracts may inherit from this and call `_registerInterface` to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See `IERC165.supportsInterface`.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See `IERC165.supportsInterface`.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/OrganizationInterface.sol

pragma solidity ^0.5.6;


/**
 * @title Minimal 0xORG interface
 * 
 * @dev If you are creating your own implementation of Winding
 * Tree Organization, this is the minimal interface that you must
 * fullfill. Without it, the Organization won't be added into the
 * SegmentDirectory. For checked interface ID, head over to the
 * implementation of `addOrganization` in `SegmentDirectory`.
 *
 * This is not meant to be used by libraries that try to operate
 * with the organization as any data manipulation methods are
 * intentionally omitted. It can be used only for reading data.
 */
contract OrganizationInterface is IERC165 {
    /**
     * @dev Returns the address of the current owner.
     * @return {" ": "Current owner address."}
     */
    function owner() public view returns (address);

    /**
     * @dev Returns the URI of ORG.JSON file stored off-chain.
     * @return {" ": "Current ORG.JSON URI."}
     */
    function getOrgJsonUri() external view returns (string memory);

    /**
     * @dev Returns keccak256 hash of raw ORG.JSON contents. This should
     * be used to verify that the contents of ORG.JSON has not been tampered
     * with. It is a responsibility of the Organization owner to keep this
     * hash up to date.
     * @return {" ": "Current ORG.JSON hash."}
     */
    function getOrgJsonHash() external view returns (bytes32);

    /**
     * @dev Returns if an `address` is associated with the Organization.
     * Associated keys can be used on behalf of the organization,
     * typically to sign messages.
     *
     * @param addr Associated Ethereum address
     * @return {" ": "true if associated, false otherwise"}
     */
    function hasAssociatedKey(address addr) external view returns (bool);

    /**
     * @dev Returns all associatedKeys belonging to this organization.
     * @return {" ": "List of associatedKeys"}
     */
    function getAssociatedKeys() external view returns (address[] memory);
}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


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

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
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

// File: contracts/Organization.sol

pragma solidity ^0.5.6;




/**
 * @title Organization
 * @dev A contract that represents an Organization in the Winding Tree platform,
 * commonly referred to as 0xORG. This is a reference implementation that is
 * created by the OrganizationFactory. You cn implement your own logic if it
 * adheres to the `OrganizationInterface`.
 */
contract Organization is OrganizationInterface, ERC165, Initializable {
    // Address of the contract owner
    address _owner;

    // Arbitrary locator of the off-chain stored Organization data
    // This might be an HTTPS resource, IPFS hash, Swarm address...
    // This is intentionally generic.
    string public orgJsonUri;

    // Number of a block when the Organization was created
    uint public created;

    // Index of associated addresses. These can be used
    // to operate on behalf of this organization, typically sign messages.
    mapping(address => uint) public associatedKeysIndex;

    // List of associatedKeys. These addresses (i. e. public key
    // fingerprints) can be used to associate signed content with this
    // organization.
    address[] public associatedKeys;

    // keccak256 hash of the ORG.JSON file contents. This should
    // be used to verify that the contents of ORG.JSON has not been tampered
    // with. It is a responsibility of the Organization owner to keep this
    // hash up to date.
    bytes32 public orgJsonHash;

    /**
     * @dev Event triggered when owner of the organization is changed.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Event triggered when orgJsonUri of the organization is changed.
     */
    event OrgJsonUriChanged(string previousOrgJsonUri, string newOrgJsonUri);

    /**
     * @dev Event triggered when orgJsonHash of the organization is changed.
     */
    event OrgJsonHashChanged(bytes32 indexed previousOrgJsonHash, bytes32 indexed newOrgJsonHash);

    /**
     * @dev Event triggered when new associatedKey is added.
     */
    event AssociatedKeyAdded(address indexed associatedKey, uint index);

    /**
     * @dev Event triggered when a associatedKey is removed.
     */    
    event AssociatedKeyRemoved(address indexed associatedKey);

    /**
     * @dev Initializer for upgradeable contracts.
     * @param __owner The address of the contract owner
     * @param _orgJsonUri pointer to Organization data
     * @param  _orgJsonHash keccak256 hash of the new ORG.JSON contents.
     */
    function initialize(address payable __owner, string memory _orgJsonUri, bytes32 _orgJsonHash) public initializer {
        require(__owner != address(0), 'Organization: Cannot set owner to 0x0 address');
        require(bytes(_orgJsonUri).length != 0, 'Organization: orgJsonUri cannot be an empty string');
        require(_orgJsonHash != 0, 'Organization: orgJsonHash cannot be empty');
        emit OwnershipTransferred(_owner, __owner);
        _owner = __owner;        
        orgJsonUri = _orgJsonUri;
        orgJsonHash = _orgJsonHash;
        created = block.number;
        associatedKeys.length++;
        OrganizationInterface i;
        _registerInterface(0x01ffc9a7);//_INTERFACE_ID_ERC165
        bytes4 associatedKeysInterface = i.hasAssociatedKey.selector ^ i.getAssociatedKeys.selector; // 0xfed71811
        bytes4 orgJsonInterface = i.getOrgJsonUri.selector ^ i.getOrgJsonHash.selector; // 0x6f4826be
        _registerInterface(orgJsonInterface);
        _registerInterface(associatedKeysInterface);
        _registerInterface(i.owner.selector); // 0x8da5cb5b
        _registerInterface(
            i.owner.selector ^
            orgJsonInterface ^
            associatedKeysInterface
        ); // 0x1c3af5f4
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, 'Organization: Only owner can call this method');
        _;
    }

    /**
     * @dev `changeOrgJsonUri` Allows owner to change Organization's orgJsonUri.
     * @param  _orgJsonUri New orgJsonUri pointer of this Organization
     */
    function changeOrgJsonUri(string memory _orgJsonUri) public onlyOwner {
        require(bytes(_orgJsonUri).length != 0, 'Organization: orgJsonUri cannot be an empty string');
        emit OrgJsonUriChanged(orgJsonUri, _orgJsonUri);
        orgJsonUri = _orgJsonUri;
    }

    /**
     * @dev Returns current orgJsonUri
     * @return {" ": "Current orgJsonUri."}
     */
    function getOrgJsonUri() external view returns (string memory) {
        return orgJsonUri;
    }

    /**
     * @dev `changeOrgJsonHash` Allows owner to change Organization's orgJsonHash.
     * @param  _orgJsonHash keccak256 hash of the new ORG.JSON contents.
     */
    function changeOrgJsonHash(bytes32 _orgJsonHash) public onlyOwner {
        require(_orgJsonHash != 0, 'Organization: orgJsonHash cannot be empty');
        emit OrgJsonHashChanged(orgJsonHash, _orgJsonHash);
        orgJsonHash = _orgJsonHash;
    }

    /**
     * @dev Returns keccak256 hash of raw ORG.JSON contents. This should
     * be used to verify that the contents of ORG.JSON has not been tampered
     * with. It is a responsibility of the Organization owner to keep this
     * hash up to date.
     * @return {" ": "Current ORG.JSON hash."}
     */
    function getOrgJsonHash() external view returns (bytes32) {
        return orgJsonHash;
    }

    /**
     * @dev Shorthand method to change ORG.JSON uri and hash at the same time
     * @param  _orgJsonUri New orgJsonUri pointer of this Organization
     * @param  _orgJsonHash keccak256 hash of the new ORG.JSON contents.
     */
    function changeOrgJsonUriAndHash(string memory _orgJsonUri, bytes32 _orgJsonHash) public onlyOwner {
        changeOrgJsonUri(_orgJsonUri);
        changeOrgJsonHash(_orgJsonHash);
    }

    /**
     * @dev Adds another associated key. Only owner can call this.
     * @param addr Associated Ethereum address
     * @return {" ": "Address of the added associatedKey"}
     */
    function addAssociatedKey(address addr) public onlyOwner returns(address) {
        require(addr != address(0), 'Organization: Cannot add associatedKey with 0x0 address');
        require(associatedKeysIndex[addr] == 0, 'Organization: Cannot add associatedKey twice');
        associatedKeysIndex[addr] = associatedKeys.length;
        associatedKeys.push(addr);
        emit AssociatedKeyAdded(addr, associatedKeysIndex[addr]);
        return addr;
    }

    /**
     * @dev Removes an associated key. Only owner can call this.
     * @param addr Associated Ethereum address
     */
    function removeAssociatedKey(address addr) public onlyOwner {
        require(addr != address(0), 'Organization: Cannot remove associatedKey with 0x0 address');
        require(associatedKeysIndex[addr] != uint(0), 'Organization: Cannot remove unknown organization');
        delete associatedKeys[associatedKeysIndex[addr]];
        delete associatedKeysIndex[addr];
        emit AssociatedKeyRemoved(addr);
    }

    /**
     * @dev Is an address considered as associated for this organization?
     * @return {" ": "True if address is considered as associatedKey, false otherwise"}
     */
    function hasAssociatedKey(address addr) external view returns(bool) {
        return associatedKeys[associatedKeysIndex[addr]] != address(0);
    }

    /**
     * @dev Returns all addresses associated with this organization.
     * @return {" ": "List of associated keys"}
     */
    function getAssociatedKeys() external view returns (address[] memory) {
        return associatedKeys;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), 'Organization: Cannot transfer to 0x0 address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }


    /**
     * @dev A synchronization method that should be kept up to date with 
     * the list of interfaces set during initialization. It should also be called
     * everytime the implementation gets updated. If the interface list gets out of
     * sync with the implementation at anytime, it is possible that some integrations
     * will stop working. Since this method is not destructive, no access restriction
     * is in place. It's supposed to be called by the proxy admin anyway.
     */
    function setInterfaces() public {
        // OrganizationInterface i;
        bytes4[5] memory interfaceIds = [
            bytes4(0x01ffc9a7), // _INTERFACE_ID_ERC165
            bytes4(0x8da5cb5b), // i.owner.selector
            bytes4(0xfed71811), // i.hasAssociatedKey.selector ^ i.getAssociatedKeys.selector
            bytes4(0x6f4826be), // i.getOrgJsonUri.selector ^ i.getOrgJsonHash.selector
            bytes4(0x1c3af5f4)  // 0x8da5cb5b ^ 0xfed71811 ^ 0x6f4826be
        ];
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!this.supportsInterface(interfaceIds[i])) {
                _registerInterface(interfaceIds[i]);
            }
        }
    }
}
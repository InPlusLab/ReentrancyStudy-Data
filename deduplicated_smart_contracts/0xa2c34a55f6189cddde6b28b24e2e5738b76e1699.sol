/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

// File: contracts/AbstractOrganizationFactory.sol

pragma solidity ^0.5.6;

/**
 * Abstract Organization Factory. Usable in libraries.
 */
contract AbstractOrganizationFactory {

    /**
     * @dev Event triggered every time organization is created.
     */
    event OrganizationCreated(address indexed organization);

    /**
     * @dev Event triggered when owner of the factory is changed.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address);

    /**
     * @dev Creates new 0xORG smart contract
     * @param  orgJsonUri Organization's data pointer
     * @param  orgJsonHash Organization's data hash
     * @return {" ": "Address of the new organization."}
     */
    function create(string calldata orgJsonUri, bytes32 orgJsonHash) external returns (address);

    /**
     * @dev Creates new 0xORG smart contract and adds it to a segment directory
     * in the same transaction
     * @param  orgJsonUri Organization's data pointer
     * @param  orgJsonHash Organization's data hash
     * @param  directory Segment directory address
     * @return {" ": "Address of the new organization."}
     */
    function createAndAddToDirectory(
        string calldata orgJsonUri,
        bytes32 orgJsonHash,
        address directory
    ) external returns (address);

    /**
     * @dev Returns number of created organizations.
     */
    function getCreatedOrganizationsLength() public view returns (uint);

    /**
     * @dev Returns a list of created organizations.
     */
    function getCreatedOrganizations() public view returns (address[] memory);

    /**
     * @dev Returns index of `organization`
     */
    function createdOrganizationsIndex(address organization) public view returns (uint);

    /**
     * @dev Returns organization address on `index` position.
     */
    function createdOrganizations(uint index) public view returns (address);
}

// File: contracts/AbstractSegmentDirectory.sol

pragma solidity ^0.5.6;

/**
 * @title AbstractSegmentDirectory
 * 
 * @dev Usable in libraries. Segment Directory is essentially a list
 * of 0xORG smart contracts that share a common segment - hotels, airlines, otas.
 */
contract AbstractSegmentDirectory {

    /**
     * @dev Event triggered every time organization is added.
     */
    event OrganizationAdded(address indexed organization, uint index);

    /**
     * @dev Event triggered every time organization is removed.
     */
    event OrganizationRemoved(address indexed organization);

    /**
     * @dev Event triggered when owner of the directory is changed.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address);

    /**
     * @dev Returns the segment name
     */
    function getSegment() public view returns (string memory);

    /**
     * @dev Returns the address of the associated lif token
     */
    function getLifToken() public view returns (address);

    /**
     * @dev Adds an organization to the list
     */
    function add(address organization) external returns (address);

    /**
     * @dev Removes an organization from the list
     */
    function remove(address organization) external;

    /**
     * @dev Returns the number of added organizations. Might contain zero
     * addresses (these remain after removing an organization).
     */
    function getOrganizationsLength() public view returns (uint);

    /**
     * @dev Returns a list of added organizations. Might contain zero addresses.
     */
    function getOrganizations() public view returns (address[] memory);

    /**
     * @dev Returns index of `organization`
     */
    function organizationsIndex(address organization) public view returns (uint);

    /**
     * @dev Returns organization address on `index` position.
     */
    function organizations(uint index) public view returns (address);
}

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

// File: @openzeppelin/upgrades/contracts/application/ImplementationProvider.sol

pragma solidity ^0.5.0;

/**
 * @title ImplementationProvider
 * @dev Abstract contract for providing implementation addresses for other contracts by name.
 */
contract ImplementationProvider {
  /**
   * @dev Abstract function to return the implementation address of a contract.
   * @param contractName Name of the contract.
   * @return Implementation address of the contract.
   */
  function getImplementation(string memory contractName) public view returns (address);
}

// File: @openzeppelin/upgrades/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/ownership/Ownable.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Ownable implementation from an openzeppelin version.
 */
contract OpenZeppelinUpgradesOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
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
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
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
}

// File: @openzeppelin/upgrades/contracts/application/Package.sol

pragma solidity ^0.5.0;


/**
 * @title Package
 * @dev A package is composed by a set of versions, identified via semantic versioning,
 * where each version has a contract address that refers to a reusable implementation,
 * plus an optional content URI with metadata. Note that the semver identifier is restricted
 * to major, minor, and patch, as prerelease tags are not supported.
 */
contract Package is OpenZeppelinUpgradesOwnable {
  /**
   * @dev Emitted when a version is added to the package.
   * @param semanticVersion Name of the added version.
   * @param contractAddress Contract associated with the version.
   * @param contentURI Optional content URI with metadata of the version.
   */
  event VersionAdded(uint64[3] semanticVersion, address contractAddress, bytes contentURI);

  struct Version {
    uint64[3] semanticVersion;
    address contractAddress;
    bytes contentURI; 
  }

  mapping (bytes32 => Version) internal versions;
  mapping (uint64 => bytes32) internal majorToLatestVersion;
  uint64 internal latestMajor;

  /**
   * @dev Returns a version given its semver identifier.
   * @param semanticVersion Semver identifier of the version.
   * @return Contract address and content URI for the version, or zero if not exists.
   */
  function getVersion(uint64[3] memory semanticVersion) public view returns (address contractAddress, bytes memory contentURI) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return (version.contractAddress, version.contentURI); 
  }

  /**
   * @dev Returns a contract for a version given its semver identifier.
   * This method is equivalent to `getVersion`, but returns only the contract address.
   * @param semanticVersion Semver identifier of the version.
   * @return Contract address for the version, or zero if not exists.
   */
  function getContract(uint64[3] memory semanticVersion) public view returns (address contractAddress) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return version.contractAddress;
  }

  /**
   * @dev Adds a new version to the package. Only the Owner can add new versions.
   * Reverts if the specified semver identifier already exists. 
   * Emits a `VersionAdded` event if successful.
   * @param semanticVersion Semver identifier of the version.
   * @param contractAddress Contract address for the version, must be non-zero.
   * @param contentURI Optional content URI for the version.
   */
  function addVersion(uint64[3] memory semanticVersion, address contractAddress, bytes memory contentURI) public onlyOwner {
    require(contractAddress != address(0), "Contract address is required");
    require(!hasVersion(semanticVersion), "Given version is already registered in package");
    require(!semanticVersionIsZero(semanticVersion), "Version must be non zero");

    // Register version
    bytes32 versionId = semanticVersionHash(semanticVersion);
    versions[versionId] = Version(semanticVersion, contractAddress, contentURI);
    
    // Update latest major
    uint64 major = semanticVersion[0];
    if (major > latestMajor) {
      latestMajor = semanticVersion[0];
    }

    // Update latest version for this major
    uint64 minor = semanticVersion[1];
    uint64 patch = semanticVersion[2];
    uint64[3] storage latestVersionForMajor = versions[majorToLatestVersion[major]].semanticVersion;
    if (semanticVersionIsZero(latestVersionForMajor) // No latest was set for this major
       || (minor > latestVersionForMajor[1]) // Or current minor is greater 
       || (minor == latestVersionForMajor[1] && patch > latestVersionForMajor[2]) // Or current patch is greater
       ) { 
      majorToLatestVersion[major] = versionId;
    }

    emit VersionAdded(semanticVersion, contractAddress, contentURI);
  }

  /**
   * @dev Checks whether a version is present in the package.
   * @param semanticVersion Semver identifier of the version.
   * @return true if the version is registered in this package, false otherwise.
   */
  function hasVersion(uint64[3] memory semanticVersion) public view returns (bool) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return address(version.contractAddress) != address(0);
  }

  /**
   * @dev Returns the version with the highest semver identifier registered in the package.
   * For instance, if `1.2.0`, `1.3.0`, and `2.0.0` are present, will always return `2.0.0`, regardless 
   * of the order in which they were registered. Returns zero if no versions are registered.
   * @return Semver identifier, contract address, and content URI for the version, or zero if not exists.
   */
  function getLatest() public view returns (uint64[3] memory semanticVersion, address contractAddress, bytes memory contentURI) {
    return getLatestByMajor(latestMajor);
  }

  /**
   * @dev Returns the version with the highest semver identifier for the given major.
   * For instance, if `1.2.0`, `1.3.0`, and `2.0.0` are present, will return `1.3.0` for major `1`, 
   * regardless of the order in which they were registered. Returns zero if no versions are registered
   * for the specified major.
   * @param major Major identifier to query
   * @return Semver identifier, contract address, and content URI for the version, or zero if not exists.
   */
  function getLatestByMajor(uint64 major) public view returns (uint64[3] memory semanticVersion, address contractAddress, bytes memory contentURI) {
    Version storage version = versions[majorToLatestVersion[major]];
    return (version.semanticVersion, version.contractAddress, version.contentURI); 
  }

  function semanticVersionHash(uint64[3] memory version) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(version[0], version[1], version[2]));
  }

  function semanticVersionIsZero(uint64[3] memory version) internal pure returns (bool) {
    return version[0] == 0 && version[1] == 0 && version[2] == 0;
  }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/Proxy.sol

pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

// File: @openzeppelin/upgrades/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library OpenZeppelinUpgradesAddress {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/BaseUpgradeabilityProxy.sol

pragma solidity ^0.5.0;



/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
   * validated in the constructor.
   */
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) internal {
    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/UpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Contract constructor.
   * @param _logic Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}

// File: @openzeppelin/upgrades/contracts/upgradeability/BaseAdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
   * validated in the constructor.
   */

  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  /**
   * @return The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  /**
   * @dev Only fall back when the sender is not the admin.
   */
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/AdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title AdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for 
 * initializing the implementation, admin, and init data.
 */
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}

// File: @openzeppelin/upgrades/contracts/application/App.sol

pragma solidity ^0.5.0;





/**
 * @title App
 * @dev Contract for upgradeable applications.
 * It handles the creation of proxies.
 */
contract App is OpenZeppelinUpgradesOwnable {
  /**
   * @dev Emitted when a new proxy is created.
   * @param proxy Address of the created proxy.
   */
  event ProxyCreated(address proxy);

  /**
   * @dev Emitted when a package dependency is changed in the application.
   * @param providerName Name of the package that changed.
   * @param package Address of the package associated to the name.
   * @param version Version of the package in use.
   */
  event PackageChanged(string providerName, address package, uint64[3] version);

  /**
   * @dev Tracks a package in a particular version, used for retrieving implementations
   */
  struct ProviderInfo {
    Package package;
    uint64[3] version;
  }

  /**
   * @dev Maps from dependency name to a tuple of package and version
   */
  mapping(string => ProviderInfo) internal providers;

  /**
   * @dev Constructor function.
   */
  constructor() public { }

  /**
   * @dev Returns the provider for a given package name, or zero if not set.
   * @param packageName Name of the package to be retrieved.
   * @return The provider.
   */
  function getProvider(string memory packageName) public view returns (ImplementationProvider provider) {
    ProviderInfo storage info = providers[packageName];
    if (address(info.package) == address(0)) return ImplementationProvider(0);
    return ImplementationProvider(info.package.getContract(info.version));
  }

  /**
   * @dev Returns information on a package given its name.
   * @param packageName Name of the package to be queried.
   * @return A tuple with the package address and pinned version given a package name, or zero if not set
   */
  function getPackage(string memory packageName) public view returns (Package, uint64[3] memory) {
    ProviderInfo storage info = providers[packageName];
    return (info.package, info.version);
  }

  /**
   * @dev Sets a package in a specific version as a dependency for this application.
   * Requires the version to be present in the package.
   * @param packageName Name of the package to set or overwrite.
   * @param package Address of the package to register.
   * @param version Version of the package to use in this application.
   */
  function setPackage(string memory packageName, Package package, uint64[3] memory version) public onlyOwner {
    require(package.hasVersion(version), "The requested version must be registered in the given package");
    providers[packageName] = ProviderInfo(package, version);
    emit PackageChanged(packageName, address(package), version);
  }

  /**
   * @dev Unsets a package given its name.
   * Reverts if the package is not set in the application.
   * @param packageName Name of the package to remove.
   */
  function unsetPackage(string memory packageName) public onlyOwner {
    require(address(providers[packageName].package) != address(0), "Package to unset not found");
    delete providers[packageName];
    emit PackageChanged(packageName, address(0), [uint64(0), uint64(0), uint64(0)]);
  }

  /**
   * @dev Returns the implementation address for a given contract name, provided by the `ImplementationProvider`.
   * @param packageName Name of the package where the contract is contained.
   * @param contractName Name of the contract.
   * @return Address where the contract is implemented.
   */
  function getImplementation(string memory packageName, string memory contractName) public view returns (address) {
    ImplementationProvider provider = getProvider(packageName);
    if (address(provider) == address(0)) return address(0);
    return provider.getImplementation(contractName);
  }

  /**
   * @dev Creates a new proxy for the given contract and forwards a function call to it.
   * This is useful to initialize the proxied contract.
   * @param packageName Name of the package where the contract is contained.
   * @param contractName Name of the contract.
   * @param admin Address of the proxy administrator.
   * @param data Data to send as msg.data to the corresponding implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   * @return Address of the new proxy.
   */
   function create(string memory packageName, string memory contractName, address admin, bytes memory data) payable public returns (AdminUpgradeabilityProxy) {
     address implementation = getImplementation(packageName, contractName);
     AdminUpgradeabilityProxy proxy = (new AdminUpgradeabilityProxy).value(msg.value)(implementation, admin, data);
     emit ProxyCreated(address(proxy));
     return proxy;
  }
}

// File: contracts/OrganizationFactory.sol

pragma solidity ^0.5.6;






/**
 * @title OrganizationFactory
 *
 * @dev A factory contract that can create new instances of upgradeable
 * 0xORG smart contracts from the `Organization` blueprint published in
 * `wt-contracts` ZeppelinOS package.
 */
contract OrganizationFactory is Initializable, AbstractOrganizationFactory {
    // ZeppelinOS App instance
    App internal app;

    // Address of the contract owner
    address _owner;

    // Array of addresses of created `Organization` contracts. We need to keep
    // track of it because owner of this factory remains the Proxy Owner of
    // the created smart contracts and is the only account that can change
    // the implementation or transfer its ownership.
    address[] _createdOrganizations;

    // Mapping of organizations position in the general created organization index
    mapping(address => uint) _createdOrganizationsIndex;

    /**
     * @dev `createOrganization` Create new organization upgradeable contract.
     * The created proxy's owner is **this Factory owner**.
     * The created Organizations's ownership is given to `msg.sender`.
     * This ownership design allows the factory owner to keep the implementation
     * safe whilst giving the data owner full control over their data.
     *
     * See the reasoning on https://github.com/windingtree/wt-contracts/pull/241#issuecomment-501726595
     * 
     * Emits `OrganizationCreated` on success.
     * @param  orgJsonUri Organization's data pointer
     * @param  orgJsonHash Organization's data hash
     * @return {" ": "Address of the new organization."}
     */
    function createOrganization(string memory orgJsonUri, bytes32 orgJsonHash) internal returns (address) {
        address newOrganizationAddress = address(
            app.create(
                "wt-contracts", 
                "Organization", 
                _owner, 
                abi.encodeWithSignature("initialize(address,string,bytes32)", msg.sender, orgJsonUri, orgJsonHash)
            )
        );
        emit OrganizationCreated(newOrganizationAddress);
        _createdOrganizationsIndex[newOrganizationAddress] = _createdOrganizations.length;
        _createdOrganizations.push(newOrganizationAddress);
        return newOrganizationAddress;
    }

    /**
     * @dev `create` proxies and externalizes createOrganization
     * @param  orgJsonUri Organization's data pointer
     * @param  orgJsonHash Organization's data hash
     * @return {" ": "Address of the new organization."}
     */
    function create(string calldata orgJsonUri, bytes32 orgJsonHash) external returns (address) {
        return createOrganization(orgJsonUri, orgJsonHash);
    }

    /**
     * @dev `createAndAddToDirectory` Creates the organization contract and tries to add it
     * to a SegmentDirectory living on the passed `directory` address.
     *
     * We cannot reuse create call due to the Organization ownership restrictions.
     * 
     * @param  orgJsonUri Organization's data pointer
     * @param  orgJsonHash Organization's data hash
     * @param  directory Segment directory's address
     * @return {" ": "Address of the new organization."}
     */
    function createAndAddToDirectory(
        string calldata orgJsonUri,
        bytes32 orgJsonHash,
        address directory
    ) external returns (address) {
        // TODO rewrite so that directory address gets known from entrypoint #248
        require(directory != address(0), 'OrganizationFactory: Cannot use directory with 0x0 address');
        address newOrganizationAddress = address(
            app.create(
                "wt-contracts", 
                "Organization", 
                _owner, 
                abi.encodeWithSignature("initialize(address,string,bytes32)", address(this), orgJsonUri, orgJsonHash)
            )
        );
        AbstractSegmentDirectory sd = AbstractSegmentDirectory(directory);
        sd.add(newOrganizationAddress);
        _createdOrganizationsIndex[newOrganizationAddress] = _createdOrganizations.length;
        _createdOrganizations.push(newOrganizationAddress);
        Organization o = Organization(newOrganizationAddress);
        o.transferOwnership(msg.sender);
        emit OrganizationCreated(newOrganizationAddress);
        return newOrganizationAddress;
    }

    /**
     * @dev Initializer for upgradeable contracts.
     * @param __owner The address of the contract owner
     * @param _app ZeppelinOS App address
     */
    function initialize(address payable __owner, App _app) public initializer {
        require(__owner != address(0), 'OrganizationFactory: Cannot set owner to 0x0 address');
        require(address(_app) != address(0), 'OrganizationFactory: Cannot set app to 0x0 address');
        _owner = __owner;
        app = _app;
        _createdOrganizations.length++;
    }

    /**
     * @dev `getCreatedOrganizationsLength` get the length of the `createdOrganizations` array
     * @return {" ": "Length of the organizations array. Might contain zero addresses."}
     */
    function getCreatedOrganizationsLength() public view returns (uint) {
        return _createdOrganizations.length;
    }

    /**
     * @dev `getCreatedOrganizations` get `createdOrganizations` array
     * @return {" ": "Array of organization addresses. Might contain zero addresses."}
     */
    function getCreatedOrganizations() public view returns (address[] memory) {
        return _createdOrganizations;
    }

    /**
     * @dev `createdOrganizationsIndex` get index of Organization
     * @return {" ": "Organization index."}
     */
    function createdOrganizationsIndex(address organization) public view returns (uint) {
        return _createdOrganizationsIndex[organization];
    }

    /**
     * @dev `createdOrganizations` get Organization address on an index
     * @return {" ": "Organization address."}
     */
    function createdOrganizations(uint index) public view returns (address) {
        return _createdOrganizations[index];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, 'OrganizationFactory: Only owner can call this method');
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), 'OrganizationFactory: Cannot transfer to 0x0 address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
}
/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

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

// File: openzeppelin-solidity/contracts/introspection/ERC165Checker.sol

pragma solidity ^0.5.0;

/**
 * @dev Library used to query support of an interface declared via `IERC165`.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Returns true if `account` supports the `IERC165` interface,
     */
    function _supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for `IERC165` itself is queried automatically.
     *
     * See `IERC165.supportsInterface`.
     */
    function _supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return _supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for `IERC165` itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * `IERC165` support.
     *
     * See `IERC165.supportsInterface`.
     */
    function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!_supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with the `supportsERC165` method in this library.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // success determines whether the staticcall succeeded and result determines
        // whether the contract at account indicates support of _interfaceId
        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    /**
     * @notice Calls the function with selector 0x01ffc9a7 (ERC165) and suppresses throw
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return success true if the STATICCALL succeeded, false otherwise
     * @return result true if the STATICCALL succeeded and the contract at account
     * indicates support of the interface with identifier interfaceId, false otherwise
     */
    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool success, bool result)
    {
        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);

        // solhint-disable-next-line no-inline-assembly
        assembly {
            let encodedParams_data := add(0x20, encodedParams)
            let encodedParams_size := mload(encodedParams)

            let output := mload(0x40)    // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)

            success := staticcall(
                30000,                   // 30k gas
                account,                 // To addr
                encodedParams_data,
                encodedParams_size,
                output,
                0x20                     // Outputs are 32 bytes long
            )

            result := mload(output)      // Load the result
        }
    }
}

// File: @ensdomains/ens/contracts/ENS.sol

pragma solidity >=0.4.24;

interface ENS {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);

}

// File: @ensdomains/resolver/contracts/Resolver.sol

pragma solidity >=0.4.25;

/**
 * A generic resolver interface which includes all the functions including the ones deprecated
 */
interface Resolver{
    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);
    /* Deprecated events */
    event ContentChanged(bytes32 indexed node, bytes32 hash);

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function addr(bytes32 node) external view returns (address);
    function contenthash(bytes32 node) external view returns (bytes memory);
    function dnsrr(bytes32 node) external view returns (bytes memory);
    function name(bytes32 node) external view returns (string memory);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns (string memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);

    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external;
    function setAddr(bytes32 node, address addr) external;
    function setContenthash(bytes32 node, bytes calldata hash) external;
    function setDnsrr(bytes32 node, bytes calldata data) external;
    function setName(bytes32 node, string calldata _name) external;
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external;

    function supportsInterface(bytes4 interfaceID) external pure returns (bool);

    /* Deprecated functions */
    function content(bytes32 node) external view returns (bytes32);
    function multihash(bytes32 node) external view returns (bytes memory);
    function setContent(bytes32 node, bytes32 hash) external;
    function setMultihash(bytes32 node, bytes calldata hash) external;
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

// File: contracts/SegmentDirectory.sol

pragma solidity ^0.5.6;








/**
 * A SegmentDirectory that can handle a list of organizations sharing a 
 * common segment such as hotels, airlines etc.
 */
contract SegmentDirectory is Initializable, AbstractSegmentDirectory {
    // Address of the contract owner
    address _owner;

    // Segment name, i. e. hotel, airline
    string _segment;

    // Array of addresses of `Organization` contracts
    address[] _organizations;

    // Mapping of organizations position in the general organization index
    mapping(address => uint) _organizationsIndex;

    // Address of the LifToken contract
    address _lifToken;

    // hashed 'token.windingtree.eth' using eth-ens-namehash
    bytes32 private constant tokenNamehash = 0x30151473c3396a0cfca504fc0f1ebc0fe92c65542ad3aaf70126c087458deb85;

    /**
     * @dev `addOrganization` Add new organization in the directory.
     * Only organizations that conform to OrganizationInterface can be added.
     * ERC165 method of interface checking is used.
     * 
     * Emits `OrganizationAdded` on success.
     * @param  organization Organization's address
     * @return {" ": "Address of the organization."}
     */
    function addOrganization(address organization) internal returns (address) {
        require(_organizationsIndex[organization] == 0, 'SegmentDirectory: Cannot add organization twice');
        // This is intentionally not part of the state variables as we expect it to change in time.
        // It should always be the latest xor of *all* methods in the OrganizationInterface.
        bytes4 _INTERFACE_ID_ORGANIZATION = 0x1c3af5f4;
        require(
            ERC165Checker._supportsInterface(organization, _INTERFACE_ID_ORGANIZATION),
            'SegmentDirectory: Organization has to support _INTERFACE_ID_ORGANIZATION'
        );
        OrganizationInterface org = OrganizationInterface(organization);
        require(org.owner() == msg.sender, 'SegmentDirectory: Only organization owner can add the organization');
        _organizationsIndex[organization] = _organizations.length;
        _organizations.push(organization);
        emit OrganizationAdded(
            organization,
            _organizationsIndex[organization]
        );
        return organization;
    }

    /**
     * @dev `removeOrganization` Allows a owner to remove an organization
     * from the directory. Does not destroy the organization contract.
     * Emits `OrganizationRemoved` on success.
     * @param  organization  Organization's address
     */
    function removeOrganization(address organization) internal {
        // Ensure organization address is valid
        require(organization != address(0), 'SegmentDirectory: Cannot remove organization on 0x0 address');
        // Ensure we know about the organization at all
        require(_organizationsIndex[organization] != uint(0), 'SegmentDirectory: Cannot remove unknown organization');
        // Ensure that the caller is the organization's rightful owner
        // Organization might have changed hands without the index taking notice
        OrganizationInterface org = OrganizationInterface(organization);
        require(org.owner() == msg.sender, 'SegmentDirectory: Only organization owner can remove the organization');
        uint allIndex = _organizationsIndex[organization];
        delete _organizations[allIndex];
        delete _organizationsIndex[organization];
        emit OrganizationRemoved(organization);
    }

    /**
     * @dev `add` proxies and externalizes addOrganization
     * @param  organization Organization's address
     * @return {" ": "Address of the organization."}
     */
    function add(address organization) external returns (address) {
        return addOrganization(organization);
    }

    /**
     * @dev `remove` proxies and externalizes removeOrganization
     * @param  organization  Organization's address
     */
    function remove(address organization) external {
        removeOrganization(organization);
    }

    /**
     * @dev Initializer for upgradeable contracts.
     * @param __owner The address of the contract owner
     * @param __segment The segment name
     * @param __lifToken The Lif Token contract address
     */
    function initialize(
        address payable __owner,
        string memory __segment,
        address __lifToken)
    public initializer {
        require(__owner != address(0), 'SegmentDirectory: Cannot set owner to 0x0 address');
        require(bytes(__segment).length != 0, 'SegmentDirectory: Segment cannot be empty');
        _owner = __owner;
        _lifToken = __lifToken;
        _organizations.length++;
        _segment = __segment;
    }

    function resolveLifTokenFromENS(address _ENS) public onlyOwner {
        ENS registry = ENS(_ENS);
        address resolverAddress = registry.resolver(tokenNamehash);
        require(resolverAddress != address(0), 'SegmentDirectory: Resolver not found');
        Resolver resolver = Resolver(resolverAddress);
        address tokenAddress = resolver.addr(tokenNamehash);
        require(tokenAddress != address(0), 'SegmentDirectory: Token not found');
        _lifToken = tokenAddress;
    }

    /**
     * @dev `getOrganizationsLength` get the length of the `organizations` array
     * @return {" ": "Length of the organizations array. Might contain zero addresses."}
     */
    function getOrganizationsLength() public view returns (uint) {
        return _organizations.length;
    }

    /**
     * @dev `getOrganizations` get `organizations` array
     * @return {" ": "Array of organization addresses. Might contain zero addresses."}
     */
    function getOrganizations() public view returns (address[] memory) {
        return _organizations;
    }

    /**
     * @dev `organizationsIndex` get index of Organization
     * @return {" ": "Organization index."}
     */
    function organizationsIndex(address organization) public view returns (uint) {
        return _organizationsIndex[organization];
    }

    /**
     * @dev `organizations` get Organization address on an index
     * @return {" ": "Organization address."}
     */
    function organizations(uint index) public view returns (address) {
        return _organizations[index];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, 'SegmentDirectory: Only owner can call this method');
        _;
    }

    /**
     * @dev `getLifToken` Returns address of set Lif token
     * @return {" ": "LifToken address."}
     */
    function getLifToken() public view returns (address) {
        return _lifToken;
    }

    /**
     * @dev `setSegment` allows the owner of the contract to change the
     * segment name.
     * @param __segment The new segment name
     */
    function setSegment(string memory __segment) public onlyOwner {
        require(bytes(__segment).length != 0, 'SegmentDirectory: Segment cannot be empty');
        _segment = __segment;
    }

    /**
     * @dev `getSegment` Returns segment name
     * @return {" ": "Segment name."}
     */
    function getSegment() public view returns (string memory) {
        return _segment;
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
        require(newOwner != address(0), 'SegmentDirectory: Cannot transfer to 0x0 address');
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
// TODO FIXME
// - view scripts inline
// - Mass-minting
// - Also make it ERC1155???
// ---

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./RoleBasedAccessControlLib.sol";
import "./ERC721Lib.sol";
import "./IERC2981.sol";
import "./IERC2981Candidate.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 *
 * This contract is based on the excellent work and contracts of Open Zeppelin.
 *
 */
contract TideweighUniques721 {
    using ERC721Lib for ERC721Lib.ERC721Storage;
    using RoleBasedAccessControlLib for RoleBasedAccessControlLib.RoleBasedAccessControlStorage;
    using Counters for Counters.Counter;

    // Shadow events defined in the libraries, need to be included here again to make it into the ABI
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Mint(address indexed to, uint256 indexed tokenId);
    event Paused(address account);
    event Unpaused(address account);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant INFINITIZER_ROLE = keccak256("INFINITIZER_ROLE");

    address tideweigh; // Contract owner
    uint24 royalty;    // Royalty expected by the artist on secondary transfers (IERC2981)

    string public contractURI; // OpenSea contract-level metadata uri

    Counters.Counter private _tokenIdTracker; // Token ID counter

    mapping(uint256 => string) tokenIdToIpfsCID;                 // Each minted token can be infinitized to IPFS

    ERC721Lib.ERC721Storage token; // ERC721 token base
    RoleBasedAccessControlLib.RoleBasedAccessControlStorage rbac; // Role based access control

    constructor(string memory _name, string memory _symbol, string memory baseTokenURI, address _proxyRegistryAddress) {
        token.init(_name, _symbol);
        token._baseURI = baseTokenURI;

        tideweigh = msg.sender;
        emit OwnershipTransferred(address(0), tideweigh);

        // Grant owner a reasonable set of roles by default
        rbac._setupRole(RoleBasedAccessControlLib.DEFAULT_ADMIN_ROLE, msg.sender);
        rbac._setupRole(MINTER_ROLE, msg.sender);
        rbac._setupRole(PAUSER_ROLE, msg.sender);
        rbac._setupRole(INFINITIZER_ROLE, msg.sender);

        token.proxyRegistryAddress = _proxyRegistryAddress;

    }

    // Access control primitives

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
        return tideweigh;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(tideweigh == msg.sender && newOwner != address(0), "Ownership transfer impossible");
        emit OwnershipTransferred(tideweigh, newOwner);
        tideweigh = newOwner;
    }

    function onlyAdmin() private view {
        require(rbac.hasRole(RoleBasedAccessControlLib.DEFAULT_ADMIN_ROLE, msg.sender), "Must have admin role");
    }

    function onlyPauser() private view {
        require(rbac.hasRole(PAUSER_ROLE, msg.sender), "Must have pauser role");
    }

    //
    // ERC165 interface implementation
    //

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId
            || interfaceId == type(IERC721Receiver).interfaceId
            || ERC721Lib.supportsInterface(interfaceId)
            || interfaceId == type(IERC2981).interfaceId
            || interfaceId == type(IERC2981Candidate).interfaceId
            || RoleBasedAccessControlLib.supportsInterface(interfaceId);
    }

    //
    // ERC721 interface implementation
    //

    function balanceOf(address _owner) external view returns (uint256 balance) { 
        return token.balanceOf(_owner); 
    }

    function ownerOf(uint256 tokenId) external view returns (address _owner) { 
        return token.ownerOf(tokenId); 
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external { 
        token.safeTransferFrom(from, to, tokenId); 
    }

    function transferFrom(address from, address to, uint256 tokenId) external { 
        token.safeTransferFrom(from, to, tokenId); 
    }

    function approve(address to, uint256 tokenId) external { 
        token.approve(to, tokenId); 
    }

    function getApproved(uint256 tokenId) external view returns (address operator) { 
        return token.getApproved(tokenId); 
    }

    function setApprovalForAll(address operator, bool _approved) external { 
        token.setApprovalForAll(operator, _approved); 
    }

    function isApprovedForAll(address _owner, address operator) external view returns (bool) { 
        return token.isApprovedForAll(_owner, operator); 
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external { 
        token.safeTransferFrom(from, to, tokenId, data); 
    }

    //
    // ERC721Enumerable interface implementation
    //

    function totalSupply() external view returns (uint256) {
        return token.totalSupply();
    }

    function tokenOfOwnerByIndex(address _owner, uint256 index) external view returns (uint256 tokenId) {
        return token.tokenOfOwnerByIndex(_owner, index);
    }

    function tokenByIndex(uint256 index) external view returns (uint256) {
        return token.tokenByIndex(index);
    }

    //
    // ERC721Metadata interface implementation
    //

    function name() external view returns (string memory) {
        return token.name();
    }

    function symbol() external view returns (string memory) {
        return token.symbol();
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(token._exists(tokenId), "URI query for nonexistent token");

        return bytes(tokenIdToIpfsCID[tokenId]).length > 0 
            ? string(abi.encodePacked("ipfs://", tokenIdToIpfsCID[tokenId]))
            : token.tokenURI(tokenId);
    }

    // Allow updates of base URI
    function setBaseURI(string memory baseTokenURI) external {
        onlyAdmin();
        return token.setBaseURI(baseTokenURI);
    }

    function baseURI() external view returns (string memory) {
        return token._baseURI;
    }

    /**
     * @dev Infinitize the token to IPFS
     *
     * Set the token's CID. Null/zero length byte array is allowed to remove the CID.
     *
     */
    function setIpfsCID(uint256 tokenId, string calldata ipfsCID) external {
        require(rbac.hasRole(INFINITIZER_ROLE, msg.sender), "Must have infinitizer role");
        require(token._exists(tokenId), "URI query for nonexistent token");

        tokenIdToIpfsCID[tokenId] = ipfsCID;
    }

    //
    // Pausable interface implementation
    //

    function paused() external view virtual returns (bool) {
        return token.paused();
    }

    function pause() external {
        onlyPauser();
        token._pause();
    }

    function unpause() external {
        onlyPauser();
        token._unpause();
    }

    //
    // Role Based Access Control interface implementation
    //

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return rbac.hasRole(role, account);
    }

    function getRoleAdmin(bytes32 role) external view returns (bytes32) {
        return rbac.getRoleAdmin(role);
    }

    function grantRole(bytes32 role, address account) external {
        return rbac.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external {
        return rbac.revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) external {
        return rbac.renounceRole(role, account);
    }

    function getRoleMember(bytes32 role, uint256 index) external view returns (address) {
        return rbac.getRoleMember(role, index);
    }

    function getRoleMemberCount(bytes32 role) external view returns (uint256) {
        return rbac.getRoleMemberCount(role);
    }

    //
    // OpenSea registry functions
    //

    /* @dev Update the OpenSea proxy registry address
     *
     * Zero address is allowed, and disables the whitelisting
     *
     */
    function setProxyRegistryAddress(address _proxyRegistryAddress) external {
        onlyAdmin();
        token.proxyRegistryAddress = _proxyRegistryAddress;
    }

    /* @dev Retrieve the current OpenSea proxy registry address
     *
     * Zero indicates that OpenSea whitelisting is disabled
     *
     */
    function getProxyRegistryAddress() external view returns (address) {
        return token.proxyRegistryAddress;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, bytes memory _data) public virtual {
        require(rbac.hasRole(MINTER_ROLE, msg.sender), "Must have minter role");
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        token._safeMint(to, _tokenIdTracker.current(), _data);
        _tokenIdTracker.increment();
    }
    
    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to) public virtual {
        mint(to, "");
    }
    
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        require(token._isApprovedOrOwner(msg.sender, tokenId), "Caller not owner nor approved");
        token._burn(tokenId);
    }

    /**
     * @dev set contract URI for OpenSea
     */
    function setContractURI(string calldata _contractURI) external {
        onlyAdmin();
        contractURI = _contractURI;
    }

    //
    // ERC2981 royalties interface implementation
    //

    /**
     * @dev See {IERC2981-royaltyInfo}.
     */
    function royaltyInfo(uint256 /* _tokenId */, uint256 _value, bytes calldata /* _data */) external view returns (address receiver, uint256 royaltyAmount, bytes memory royaltyPaymentData) {
        return (tideweigh, royalty * _value / 100, "");
    }

    function royaltyInfo(uint256 /* _tokenId */, uint256 _value) external view returns (address receiver, uint256 royaltyAmount) {
        return (tideweigh, royalty * _value / 100);
    }

    /**
     * @dev Update expected royalty
     */
    function setRoyaltyInfo(uint24 amount) external {
        onlyAdmin();
        royalty = amount;
    }

    //
    // ERC721Receiver interface implementation
    //

    /**
     * @dev ERC721 received event handler
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        // Acknowledge receipt of token
        emit Received(operator, from, tokenId, data, gasleft()); 
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Manually recover all sorts of tokens sent to this contract 
     *
     * Supports various recovery attempt types
     */
    function recoverReceivedTokens(uint256 _recoveryOperation, address _contractAddress, address _from, address _to, uint256 _tokenIdOrValue, bytes calldata _data) external returns (bool) {
        onlyAdmin();

        if(_recoveryOperation <= 2) {
            IERC721 erc721Contract = IERC721(_contractAddress);
            if(_recoveryOperation == 0) {
                erc721Contract.safeTransferFrom(_from, _to, _tokenIdOrValue, _data);
            } else if(_recoveryOperation == 1) {
                erc721Contract.safeTransferFrom(_from, _to, _tokenIdOrValue);
            } else {
                // _recoveryOperation == 2
                erc721Contract.transferFrom(_from, _to, _tokenIdOrValue);
            } 
        } else if(_recoveryOperation <= 4) {
            IERC20 erc20Contract = IERC20(_contractAddress);
            if(_recoveryOperation == 3) {
                return erc20Contract.transfer(_to, _tokenIdOrValue);
            } else {
                // _recoveryOperation == 4
                return erc20Contract.approve(_to, _tokenIdOrValue);
            } 
        } else if(_recoveryOperation == 5) {
            payable(msg.sender).transfer(_tokenIdOrValue);
        } else {
            revert('Invalid recovery operation');
        }
        return true;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
library RoleBasedAccessControlLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    struct RoleBasedAccessControlStorage {
        mapping (bytes32 => RoleData) _roles;
        mapping (bytes32 => EnumerableSet.AddressSet) _roleMembers;
    }

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || interfaceId == type(IAccessControlEnumerable).interfaceId;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function _hasRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) internal view returns (bool) {
        return s._roles[role].members[account];
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external view returns (bool) {
        return _hasRole(s, role, account);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function _getRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role) internal view returns (bytes32) {
        return s._roles[role].adminRole;
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role) external view returns (bytes32) {
        return _getRoleAdmin(s, role);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {
        require(_hasRole(s, _getRoleAdmin(s, role), msg.sender), "AccessControl: must be admin");

        _grantRole(s, role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {
        require(_hasRole(s, _getRoleAdmin(s, role), msg.sender), "AccessControl: must be admin");

        _revokeRole(s, role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {
        require(account == msg.sender, "Can only renounce role for self");

        _revokeRole(s, role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) external {
        _grantRole(s, role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(RoleBasedAccessControlStorage storage s, bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, _getRoleAdmin(s, role), adminRole);
        s._roles[role].adminRole = adminRole;
    }

    function _grantRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) private {
        if (!_hasRole(s, role, account)) {
            s._roles[role].members[account] = true;
            s._roleMembers[role].add(account);
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(RoleBasedAccessControlStorage storage s, bytes32 role, address account) private {
        require(role != DEFAULT_ADMIN_ROLE || account != msg.sender, "Cannot revoke own admin role");
        if (_hasRole(s, role, account)) {
            s._roles[role].members[account] = false;
            s._roleMembers[role].remove(account);
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    // Enumerable extension; the rest has been merged in to _grant and _revoke

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(RoleBasedAccessControlStorage storage s, bytes32 role, uint256 index) external view returns (address) {
        return s._roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(RoleBasedAccessControlStorage storage s, bytes32 role) external view returns (uint256) {
        return s._roleMembers[role].length();
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IERC721LibBeforeTokenTransferHook.sol";

/* Functionality used to whitelist OpenSea trading address, if desired */

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, the Enumerable extension, and Pausable.
 *
 * Closely based on and mirrors the excellent https://openzeppelin.com/contracts/.
 */
library ERC721Lib {
    using Address for address;
    using Strings for uint256;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    struct ERC721Storage {
        // Token name
        string _name;

        // Token symbol
        string _symbol;

        // Mapping from token ID to owner address
        mapping (uint256 => address) _owners;

        // Mapping owner address to token count
        mapping (address => uint256) _balances;

        // Mapping from token ID to approved address
        mapping (uint256 => address) _tokenApprovals;

        // Mapping from owner to operator approvals
        mapping (address => mapping (address => bool)) _operatorApprovals;

        // Mapping from owner to list of owned token IDs
        mapping(address => mapping(uint256 => uint256)) _ownedTokens;

        // Mapping from token ID to index of the owner tokens list
        mapping(uint256 => uint256) _ownedTokensIndex;

        // Array with all token ids, used for enumeration
        uint256[] _allTokens;

        // Mapping from token id to position in the allTokens array
        mapping(uint256 => uint256) _allTokensIndex;
        
        // Base URI
        string _baseURI;

        // True if token transfers are paused
        bool _paused;

        // Hook function that can be called before token is transferred, along with a pointer to its storage struct
        IERC721LibBeforeTokenTransferHook _beforeTokenTransferHookInterface;
        bytes32 _beforeTokenTransferHookStorageSlot;

        address proxyRegistryAddress;

    }

    function init(ERC721Storage storage s, string memory _name, string memory _symbol) external {
        s._name = _name;
        s._symbol = _symbol;
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || interfaceId == type(IERC721Enumerable).interfaceId;
    }

    //
    // Start of ERC721 functions
    // 

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function _balanceOf(ERC721Storage storage s, address owner) internal view returns (uint256) {
        require(owner != address(0), "Balance query for address zero");
        return s._balances[owner];
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(ERC721Storage storage s, address owner) external view returns (uint256) {
        return _balanceOf(s, owner);
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function _ownerOf(ERC721Storage storage s, uint256 tokenId) internal view returns (address) {
        address owner = s._owners[tokenId];
        require(owner != address(0), "Owner query for nonexist. token");
        return owner;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(ERC721Storage storage s, uint256 tokenId) external view returns (address) {
        return _ownerOf(s, tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name(ERC721Storage storage s) external view returns (string memory) {
        return s._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol(ERC721Storage storage s) external view returns (string memory) {
        return s._symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(ERC721Storage storage s, uint256 tokenId) external view returns (string memory) {
        require(_exists(s, tokenId), "URI query for nonexistent token");

        return bytes(s._baseURI).length > 0
            ? string(abi.encodePacked(s._baseURI, tokenId.toString()))
            : "";
    }

    /**
     * @dev Set base URI
     */
    function setBaseURI(ERC721Storage storage s, string memory baseTokenURI) external {
        s._baseURI = baseTokenURI;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(ERC721Storage storage s, address to, uint256 tokenId) external {
        address owner = _ownerOf(s, tokenId);
        require(to != owner, "Approval to current owner");

        require(msg.sender == owner || _isApprovedForAll(s, owner, msg.sender),
            "Not owner nor approved for all"
        );

        _approve(s, to, tokenId);
    }

    /**
     * @dev Approve independently of who's the owner
     *
     * Obviously expose with care...
     */
    function overrideApprove(ERC721Storage storage s, address to, uint256 tokenId) external {
        _approve(s, to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function _getApproved(ERC721Storage storage s, uint256 tokenId) internal view returns (address) {
        require(_exists(s, tokenId), "Approved query nonexist. token");

        return s._tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(ERC721Storage storage s, uint256 tokenId) external view returns (address) {
        return _getApproved(s, tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(ERC721Storage storage s, address operator, bool approved) external {
        require(operator != msg.sender, "Attempted approve to caller");

        s._operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function _isApprovedForAll(ERC721Storage storage s, address owner, address operator) internal view returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading - if we have a valid proxy registry address on file
        if (s.proxyRegistryAddress != address(0)) {
            ProxyRegistry proxyRegistry = ProxyRegistry(s.proxyRegistryAddress);
            if (address(proxyRegistry.proxies(owner)) == operator) {
                return true;
            }
        }

        return s._operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(ERC721Storage storage s, address owner, address operator) external view returns (bool) {
        return _isApprovedForAll(s, owner, operator);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId) external {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(s, msg.sender, tokenId), "TransferFrom not owner/approved");

        _transfer(s, from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId) external {
        _safeTransferFrom(s, from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function _safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) internal {
        require(_isApprovedOrOwner(s, msg.sender, tokenId), "TransferFrom not owner/approved");
        _safeTransfer(s, from, to, tokenId, _data);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) external {
        _safeTransferFrom(s, from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(s, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Transfer to non ERC721Receiver");
    }

    /**
     * @dev directSafeTransfer
     *
     * CAREFUL, this does not verify the previous ownership - only use if ownership/eligibility has been asserted by other means
     */
    function directSafeTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) external {
        _safeTransfer(s, from, to, tokenId, _data);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(ERC721Storage storage s, uint256 tokenId) internal view returns (bool) {
        return s._owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(ERC721Storage storage s, address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(s, tokenId), "Operator query nonexist. token");
        address owner = _ownerOf(s, tokenId);
        return (spender == owner || _getApproved(s, tokenId) == spender || _isApprovedForAll(s, owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(ERC721Storage storage s, address to, uint256 tokenId) internal {
        _safeMint(s, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(ERC721Storage storage s, address to, uint256 tokenId, bytes memory _data) internal {
        _unsafeMint(s, to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "Transfer to non ERC721Receiver");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _unsafeMint(ERC721Storage storage s, address to, uint256 tokenId) internal {
        require(to != address(0), "Mint to the zero address");
        require(!_exists(s, tokenId), "Token already minted");

        _beforeTokenTransfer(s, address(0), to, tokenId);

        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(ERC721Storage storage s, uint256 tokenId) internal {
        address owner = _ownerOf(s, tokenId);

        _beforeTokenTransfer(s, owner, address(0), tokenId);

        // Clear approvals
        _approve(s, address(0), tokenId);

        s._balances[owner] -= 1;
        delete s._owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(ERC721Storage storage s, address from, address to, uint256 tokenId) internal {
        require(_ownerOf(s, tokenId) == from, "TransferFrom not owner/approved");
        require(to != address(0), "Transfer to the zero address");

        _beforeTokenTransfer(s, from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(s, address(0), tokenId);

        s._balances[from] -= 1;
        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(ERC721Storage storage s, address to, uint256 tokenId) internal {
        s._tokenApprovals[tokenId] = to;
        emit Approval(_ownerOf(s, tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Transfer to non ERC721Receiver");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    //
    // Start of functions from ERC721Enumerable
    //

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(ERC721Storage storage s, address owner, uint256 index) external view returns (uint256) {
        require(index < _balanceOf(s, owner), "Owner index out of bounds");
        return s._ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function _totalSupply(ERC721Storage storage s) internal view returns (uint256) {
        return s._allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply(ERC721Storage storage s) external view returns (uint256) {
        return s._allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(ERC721Storage storage s, uint256 index) external view returns (uint256) {
        require(index < _totalSupply(s), "Global index out of bounds");
        return s._allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId) internal {
        if(address(s._beforeTokenTransferHookInterface) != address(0)) {
            // We have a hook that we need to delegate call
            (bool success, ) = address(s._beforeTokenTransferHookInterface).delegatecall(
                abi.encodeWithSelector(s._beforeTokenTransferHookInterface._beforeTokenTransferHook.selector, s._beforeTokenTransferHookStorageSlot, from, to, tokenId)
            );
            if(!success) {
                // Bubble up the revert message
                assembly {
                    let ptr := mload(0x40)
                    let size := returndatasize()
                    returndatacopy(ptr, 0, size)
                    revert(ptr, size)
                }
            }
        }

        require(!_paused(s), "No token transfer while paused");

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(s, tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(s, from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(s, tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(s, to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(ERC721Storage storage s, address to, uint256 tokenId) private {
        uint256 length = _balanceOf(s, to);
        s._ownedTokens[to][length] = tokenId;
        s._ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(ERC721Storage storage s, uint256 tokenId) private {
        s._allTokensIndex[tokenId] = s._allTokens.length;
        s._allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(ERC721Storage storage s, address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _balanceOf(s, from) - 1;
        uint256 tokenIndex = s._ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = s._ownedTokens[from][lastTokenIndex];

            s._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            s._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete s._ownedTokensIndex[tokenId];
        delete s._ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(ERC721Storage storage s, uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = s._allTokens.length - 1;
        uint256 tokenIndex = s._allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = s._allTokens[lastTokenIndex];

        s._allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        s._allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete s._allTokensIndex[tokenId];
        s._allTokens.pop();
    }

    //
    // Start of functions from Pausable
    //

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function _paused(ERC721Storage storage s) internal view returns (bool) {
        return s._paused;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused(ERC721Storage storage s) external view returns (bool) {
        return s._paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused(ERC721Storage storage s) {
        require(!_paused(s), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused(ERC721Storage storage s) {
        require(_paused(s), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause(ERC721Storage storage s) external whenNotPaused(s) {
        s._paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause(ERC721Storage storage s) external whenPaused(s) {
        s._paused = false;
        emit Unpaused(msg.sender);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///
interface IERC2981 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256,bytes)")) == 0xc155531d
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0xc155531d;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _value - the sale price of the NFT asset specified by _tokenId
    /// @param _data - information used by extensions of this ERC.
    ///                Must not to be used by implementers of EIP-2981 
    ///                alone.
    /// @return _receiver - address of who should be sent the royalty payment
    /// @return _royaltyAmount - the royalty payment amount for _value sale price
    /// @return _royaltyPaymentData - information used by extensions of this ERC.
    ///                               Must not to be used by implementers of
    ///                               EIP-2981 alone.
    function royaltyInfo(uint256 _tokenId, uint256 _value, bytes calldata _data) external returns (address _receiver, uint256 _royaltyAmount, bytes memory _royaltyPaymentData);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///
interface IERC2981Candidate {
    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _value - the sale price of the NFT asset specified by _tokenId
    /// @return _receiver - address of who should be sent the royalty payment
    /// @return _royaltyAmount - the royalty payment amount for _value sale price
    function royaltyInfo(uint256 _tokenId, uint256 _value) external returns (address _receiver, uint256 _royaltyAmount);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Lib.sol";

/**
 * @dev Interface that can be used to hook additional beforeTokenTransfer functions into ERC721Lib
 */
interface IERC721LibBeforeTokenTransferHook {

   /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransferHook(bytes32 storagePosition, address from, address to, uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 2000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "metadata": {
    "useLiteralContent": true
  },
  "libraries": {
    "contracts/ERC721Lib.sol": {
      "ERC721Lib": "0xe5e4379d8782d75f5e7983d8a2328fa9d7cf62de"
    },
    "contracts/RoleBasedAccessControlLib.sol": {
      "RoleBasedAccessControlLib": "0x5bf9810aaafff1b5295d2fc5fca65df2800ba2bb"
    }
  }
}
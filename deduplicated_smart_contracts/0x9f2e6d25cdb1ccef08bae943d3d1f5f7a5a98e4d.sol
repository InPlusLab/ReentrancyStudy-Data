/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

// File: contracts/SafeMath.sol

pragma solidity ^0.4.24;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
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

// File: contracts/Groups.sol

pragma solidity ^0.4.25;

library Groups {
    struct MemberMap {
        mapping(address => bool) members;
    }

    struct GroupMap {
        mapping(uint8 => MemberMap) groups;
    }

    /**
     * @dev Add an account to a group
     */
    function add(GroupMap storage map, uint8 groupId, address account) internal {
        MemberMap storage group = map.groups[groupId];
        require(account != address(0));
        require(!groupContains(group, account));

        group.members[account] = true;
    }

    /**
     * @dev Remove an account from a group
     */
    function remove(GroupMap storage map, uint8 groupId, address account) internal {
        MemberMap storage group = map.groups[groupId];
        require(account != address(0));
        require(groupContains(group, account));

        group.members[account] = false;
    }

    /**
     * @dev Returns true if the account is in the group
     * @return bool
     */
    function contains(GroupMap storage map, uint8 groupId, address account) internal view returns (bool) {
        MemberMap storage group = map.groups[groupId];
        return groupContains(group, account);
    }

    function groupContains(MemberMap storage group, address account) internal view returns (bool) {
        require(account != address(0));
        return group.members[account];
    }
}

// File: contracts/erc/ERC165.sol

pragma solidity ^0.4.24;

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File: contracts/erc/ERC165Map.sol

pragma solidity ^0.4.24;


contract ERC165Map is ERC165 {
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) internal supportedInterfaces;

    constructor() public {
        supportedInterfaces[INTERFACE_ID_ERC165] = true;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return supportedInterfaces[interfaceId];
    }

    function _addInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/erc/ERC721.sol

pragma solidity ^0.4.24;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// File: contracts/erc/ERC721Metadata.sol

pragma solidity ^0.4.24;

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}

// File: contracts/erc/ERC721TokenReceiver.sol

pragma solidity ^0.4.24;

interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns (bytes4);
}

// File: contracts/erc/ERC721Enumerable.sol

pragma solidity ^0.4.24;

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface ERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

// File: contracts/Qri.sol

pragma solidity ^0.4.24;








contract Qri is ERC165Map, ERC721, ERC721Metadata, ERC721Enumerable {
    using Groups for Groups.GroupMap;
    using SafeMath for uint256;

    uint8 public constant ADMIN = 1;

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    string private tokenName;
    string private tokenSymbol;

    bool public unrestrictedMinting;

    Groups.GroupMap groups;

    address public tokenOwner;

    uint256[] private allTokens;
    mapping(uint256 => uint256) private tokenIndex;
    mapping(uint256 => address) private owners;
    mapping(address => uint256[]) private ownedTokens;
    mapping(uint256 => uint256) private ownedTokensIndex;
    mapping(uint256 => address) private approval;
    mapping(address => uint256) private tokenCount;
    mapping(address => mapping(address => bool)) private operatorApproval;
    mapping(uint256 => string) private uri;

    event AddedToGroup(uint8 indexed groupId, address indexed account);
    event RemovedFromGroup(uint8 indexed groupId, address indexed account);

    constructor(string _name, string _symbol) public {
        _addInterface(INTERFACE_ID_ERC721);
        _addInterface(INTERFACE_ID_ERC721_METADATA);
        _addInterface(INTERFACE_ID_ERC721_ENUMERABLE);

        tokenName = _name;
        tokenSymbol = _symbol;

        _addAdmin(msg.sender);
        tokenOwner = msg.sender;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Must be an admin");
        _;
    }

    function unrestrictMinting() public onlyAdmin {
        unrestrictedMinting = true;
    }

    function restrictMinting() public onlyAdmin {
        unrestrictedMinting = false;
    }

    function name() external view returns (string) {
        return tokenName;
    }

    function symbol() external view returns (string) {
        return tokenSymbol;
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    function balanceOf(address account) public view returns (uint256) {
        require(account != address(0));
        return tokenCount[account];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = owners[tokenId];
        require(owner != address(0));
        return owner;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return ownedTokens[owner][index];
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return allTokens[index];
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return approval[tokenId];
    }

    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return operatorApproval[account][operator];
    }

    function tokenURI(uint256 tokenId) external view returns (string) {
        require(_exists(tokenId));
        return uri[tokenId];
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function _addAdmin(address account) internal {
        groups.add(ADMIN, account);
        emit AddedToGroup(ADMIN, account);
    }

    function removeAdmin(address account) public onlyAdmin {
        groups.remove(ADMIN, account);
        emit RemovedFromGroup(ADMIN, account);
    }

    function isAdmin(address account) public view returns (bool) {
        return groups.contains(ADMIN, account);
    }

    function approve(address account, uint256 tokenId) public {
        address owner = ownerOf(tokenId);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        approval[tokenId] = account;
        emit Approval(owner, account, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        operatorApproval[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, ""));
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external payable {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data));
    }

    function mint(address to, uint256 tokenId) public onlyAdmin returns (bool) {
        _mint(to, tokenId);
        return true;
    }

    function mintWithTokenURI(address to, uint256 tokenId, string URIForToken) public onlyAdmin returns (bool) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, URIForToken);
        return true;
    }

    function addQr(uint256 tokenId) public returns (bool) {
        if (!unrestrictedMinting) {
            require(isAdmin(msg.sender), "Must be an admin");
        }
        _mint(tokenOwner, tokenId);
        _setTokenURI(tokenId, concat("https://qr.blockwell.ai/qri/", uint2str(tokenId)));
        return true;
    }

    function burn(uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId));
        _burn(msg.sender, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);

        tokenIndex[tokenId] = allTokens.length;
        allTokens.push(tokenId);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address account, uint256 tokenId) internal {
        _clearApproval(account, tokenId);
        _removeTokenFrom(account, tokenId);

        if (bytes(uri[tokenId]).length != 0) {
            delete uri[tokenId];
        }

        // Delete from array by moving the last element to the deleted position
        uint256 index = tokenIndex[tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];

        allTokens[index] = lastToken;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        tokenIndex[tokenId] = 0;
        tokenIndex[lastToken] = index;

        emit Transfer(account, address(0), tokenId);
    }

    function _addTokenTo(address to, uint256 tokenId) internal {
        require(owners[tokenId] == address(0));
        owners[tokenId] = to;
        tokenCount[to] = tokenCount[to].add(1);

        ownedTokens[to].push(tokenId);
        ownedTokensIndex[tokenId] = ownedTokens[to].length - 1;
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        tokenCount[from] = tokenCount[from].sub(1);
        owners[tokenId] = address(0);

        // Delete from array by moving the last element to the deleted position
        uint256 index = ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = ownedTokens[from].length.sub(1);
        uint256 lastToken = ownedTokens[from][lastTokenIndex];

        ownedTokens[from][index] = lastToken;
        ownedTokens[from].length--;

        ownedTokensIndex[tokenId] = 0;
        ownedTokensIndex[lastToken] = index;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes data) internal returns (bool) {
        if (!isContract(to)) {
            return true;
        }
        ERC721TokenReceiver receiver = ERC721TokenReceiver(to);
        bytes4 retval = receiver.onERC721Received(msg.sender, from, tokenId, data);
        return (retval == receiver.onERC721Received.selector);
    }

    function _clearApproval(address account, uint256 tokenId) private {
        require(ownerOf(tokenId) == account);
        if (approval[tokenId] != address(0)) {
            approval[tokenId] = address(0);
        }
    }

    function _setTokenURI(uint256 tokenId, string newURI) internal {
        require(_exists(tokenId));
        uri[tokenId] = newURI;
    }


    function concat(string memory a, string memory b) internal pure returns (string memory) {
        uint256 aLength = bytes(a).length;
        uint256 bLength = bytes(b).length;
        string memory value = new string(aLength + bLength);
        uint valuePointer;
        uint aPointer;
        uint bPointer;
        assembly {
            valuePointer := add(value, 32)
            aPointer := add(a, 32)
            bPointer := add(b, 32)
        }
        copy(aPointer, valuePointer, aLength);
        copy(bPointer, valuePointer + aLength, bLength);
        return value;
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0) {
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function copy(uint src, uint dest, uint len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}